import uuid
from datetime import datetime, timezone
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaProvider, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.reward import (
    DiscountRedemption,
    DiscountRedemptionStatus,
    RedemptionContextType,
    ReminderJob,
    RewardRule,
)
from app.services.rewards import issue_reward, reserve_points_for_discount


def _ensure_user(db_session, user_id: str, roles: list[UserRoleType] | None = None) -> None:
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    for role in roles or []:
        exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
        if not exists:
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.commit()


def _create_gig(db_session, client_id: str, pro_id: str, status: GigStatus = GigStatus.paid) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=status,
        currency="EUR",
        amount_total=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)
    return gig


def _create_publishable_gallery(db_session, gig: Gig, pro_id: str) -> ProofGallery:
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=1,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=ProofGalleryStatus.draft,
    )
    db_session.add(gallery)
    db_session.flush()

    asset = MediaAsset(
        owner_user_id=uuid.UUID(pro_id),
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.watermark_preview,
            storage_key=f"wm/{asset.id}",
            status=ObjectStatus.ready,
        )
    )
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.commit()
    db_session.refresh(gallery)
    return gallery


def test_claim_referral_once_and_no_self_referral(client, db_session):
    referrer = str(uuid.uuid4())
    referred = str(uuid.uuid4())
    _ensure_user(db_session, referrer, [UserRoleType.client])
    _ensure_user(db_session, referred, [UserRoleType.client])

    mine = client.get("/v1/referrals/me", headers={"X-User-Id": referrer})
    assert mine.status_code == 200
    code = mine.json()["code"]

    claim = client.post("/v1/referrals/claim", headers={"X-User-Id": referred}, json={"code": code})
    assert claim.status_code == 200

    claim_again = client.post("/v1/referrals/claim", headers={"X-User-Id": referred}, json={"code": code})
    assert claim_again.status_code == 409

    self_claim = client.post("/v1/referrals/claim", headers={"X-User-Id": referrer}, json={"code": code})
    assert self_claim.status_code == 422


def test_reward_issue_respects_daily_cap(db_session):
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.add(
        RewardRule(
            code="cap_test_rule",
            is_enabled=True,
            amount=300,
            currency="RAWW_POINTS",
            daily_cap_per_user=500,
            lifetime_cap_per_user=5000,
            meta={},
        )
    )
    db_session.commit()

    first = issue_reward(db_session, user_id=user_id, rule_code="cap_test_rule", reference_type="test", reference_id="1")
    second = issue_reward(db_session, user_id=user_id, rule_code="cap_test_rule", reference_type="test", reference_id="2")
    db_session.commit()

    assert first is not None
    assert second is None


def test_spend_reserves_points_and_prevents_overspend(client, db_session):
    user_id = str(uuid.uuid4())
    _ensure_user(db_session, user_id, [UserRoleType.client])

    adjust = client.post(
        "/v1/admin/rewards/adjust",
        headers={"X-User-Id": "00000000-0000-0000-0000-0000000000aa"},
        json={"user_id": user_id, "amount": 200, "reason": "seed"},
    )
    assert adjust.status_code == 200

    context_id = str(uuid.uuid4())
    spend = client.post(
        "/v1/rewards/spend",
        headers={"X-User-Id": user_id},
        json={"context_type": "gig_payment", "context_id": context_id, "points": 150, "payment_amount": "100.00", "currency": "EUR"},
    )
    assert spend.status_code == 200
    assert spend.json()["status"] == "reserved"

    too_much = client.post(
        "/v1/rewards/spend",
        headers={"X-User-Id": user_id},
        json={
            "context_type": "gig_payment",
            "context_id": str(uuid.uuid4()),
            "points": 1000,
            "payment_amount": "100.00",
            "currency": "EUR",
        },
    )
    assert too_much.status_code == 422


def test_payment_succeeded_finalizes_gig_redemption(client, db_session, monkeypatch):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_user(db_session, client_id, [UserRoleType.client])
    _ensure_user(db_session, pro_id, [UserRoleType.pro])

    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.payment_pending)
    payment = StripePayment(
        gig_id=gig.id,
        client_user_id=uuid.UUID(client_id),
        status=PaymentStatus.pending,
        stripe_payment_intent_id="pi_reward_apply_1",
        amount=Decimal("95.00"),
        currency="EUR",
        meta={"created_at": datetime.now(timezone.utc).isoformat()},
    )
    db_session.add(payment)
    db_session.commit()

    client.post(
        "/v1/admin/rewards/adjust",
        headers={"X-User-Id": "00000000-0000-0000-0000-0000000000aa"},
        json={"user_id": client_id, "amount": 500, "reason": "seed"},
    )
    reserve_points_for_discount(
        db_session,
        user_id=uuid.UUID(client_id),
        context_type=RedemptionContextType.gig_payment,
        context_id=gig.id,
        points=200,
        payment_amount=Decimal("100.00"),
        currency="EUR",
    )
    db_session.commit()

    event = {"id": "evt_reward_apply_1", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_reward_apply_1"}}}
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)
    resp = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert resp.status_code == 200

    redemption = db_session.query(DiscountRedemption).filter_by(context_type=RedemptionContextType.gig_payment, context_id=gig.id).one()
    assert redemption.status == DiscountRedemptionStatus.applied


def test_publish_gallery_schedules_reminders(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user(db_session, pro_id, [UserRoleType.pro])
    _ensure_user(db_session, client_id, [UserRoleType.client])
    gig = _create_gig(db_session, client_id, pro_id, status=GigStatus.paid)
    gallery = _create_publishable_gallery(db_session, gig, pro_id)

    publish = client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers={"X-User-Id": pro_id})
    assert publish.status_code == 200

    jobs = db_session.query(ReminderJob).filter_by(reference_id=gallery.id).all()
    assert len(jobs) == 2
