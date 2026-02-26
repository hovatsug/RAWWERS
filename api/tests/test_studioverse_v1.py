import uuid
from datetime import datetime, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.media_rights import GigConsentLevel, GigUsageConsent
from app.models.outbox import OutboxEvent
from app.models.reward import RewardBalance
from app.models.studioverse import (
    ContentPackEntitlement,
    ContentPackOrder,
    ContentPackOrderStatus,
    ContentPackPaymentMethod,
    RoyaltyLedgerEntry,
    RoyaltyLedgerStatus,
)
from app.services.studioverse import reverse_paid_order


ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _seed_user(db_session, user_id: str, roles: list[UserRoleType]):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id[:8]}@example.com"))
    for role in roles:
        if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.commit()


def _seed_approved_pro(db_session, pro_id: str):
    pro_uuid = uuid.UUID(pro_id)
    _seed_user(db_session, pro_id, [UserRoleType.pro])
    profile = db_session.get(ProProfile, pro_uuid) or ProProfile(user_id=pro_uuid)
    profile.display_name = "Studio Pro"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.kyc_status = KYCStatus.approved
    profile.is_accepting_bookings = True
    profile.completeness_score = 100
    db_session.add(profile)

    onboarding = db_session.get(ProOnboarding, pro_uuid) or ProOnboarding(pro_user_id=pro_uuid)
    onboarding.status = ProOnboardingStatus.approved_public
    onboarding.current_city = {"city": "Lisbon", "country": "PT"}
    db_session.add(onboarding)
    db_session.commit()


def _create_approved_pack(client, pro_id: str, *, price_eur: str | None = "15.00", price_raww: int | None = 500):
    create_resp = client.post(
        "/v1/studioverse/packs",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Preset Bundle",
            "description": "Curated presets",
            "category": "preset",
            "niche_slugs": ["weddings"],
            "tags": ["warm"],
            "price_eur": price_eur,
            "price_raww": price_raww,
            "currency": "EUR",
            "pack_file_storage_key": "studioverse/packs/preset-bundle.zip",
            "license_code": "standard_commercial",
            "sources": [],
        },
    )
    assert create_resp.status_code == 200
    pack_id = create_resp.json()["id"]

    submit_resp = client.post(f"/v1/studioverse/packs/{pack_id}/submit", headers={"X-User-Id": pro_id})
    assert submit_resp.status_code == 200

    review_resp = client.post(
        f"/v1/admin/studioverse/packs/{pack_id}/review",
        headers={"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""},
        json={"decision": "approved", "notes": "ok"},
    )
    assert review_resp.status_code == 200
    return pack_id


def test_consent_enforcement_blocks_gig_source_without_consent(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro_id)
    _seed_user(db_session, client_id, [UserRoleType.client])

    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=GigStatus.paid,
        currency="EUR",
        amount_total=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        location_text="Lisbon",
    )
    db_session.add(gig)
    db_session.flush()
    db_session.add(
        GigUsageConsent(
            gig_id=gig.id,
            client_user_id=uuid.UUID(client_id),
            pro_user_id=uuid.UUID(pro_id),
            consent_level=GigConsentLevel.none,
            scope={},
            incentive={},
        )
    )
    db_session.commit()

    create_resp = client.post(
        "/v1/studioverse/packs",
        headers={"X-User-Id": pro_id},
        json={
            "title": "From gig",
            "description": "derived pack",
            "category": "template",
            "niche_slugs": ["weddings"],
            "tags": ["derived"],
            "price_eur": "10.00",
            "currency": "EUR",
            "pack_file_storage_key": "studioverse/packs/from-gig.zip",
            "license_code": "standard_commercial",
            "sources": [
                {
                    "source_type": "gig",
                    "gig_id": str(gig.id),
                    "evidence": {"derivative_only": True},
                    "requires_consent_level": "both_pro_and_rawwers",
                }
            ],
        },
    )
    assert create_resp.status_code == 200
    pack_id = create_resp.json()["id"]

    submit_resp = client.post(f"/v1/studioverse/packs/{pack_id}/submit", headers={"X-User-Id": pro_id})
    assert submit_resp.status_code == 403


def test_purchase_flows_stripe_and_raww_credits(client, db_session, monkeypatch):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    pro_id = str(uuid.uuid4())
    buyer_stripe = str(uuid.uuid4())
    buyer_credits = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro_id)
    _seed_user(db_session, buyer_stripe, [UserRoleType.client])
    _seed_user(db_session, buyer_credits, [UserRoleType.client])
    pack_id = _create_approved_pack(client, pro_id, price_eur="20.00", price_raww=1200)

    db_session.add(RewardBalance(user_id=uuid.UUID(buyer_credits), balance=3000))
    db_session.commit()

    class _PI:
        id = "pi_studioverse"
        client_secret = "secret"
        status = "succeeded"

    monkeypatch.setattr("app.services.studioverse.stripe.PaymentIntent.create", lambda **kwargs: _PI())

    stripe_resp = client.post(
        f"/v1/studioverse/packs/{pack_id}/checkout",
        headers={"X-User-Id": buyer_stripe},
        json={"payment_method": "stripe"},
    )
    assert stripe_resp.status_code == 200
    assert stripe_resp.json()["order"]["status"] == "paid"

    credits_resp = client.post(
        f"/v1/studioverse/packs/{pack_id}/checkout",
        headers={"X-User-Id": buyer_credits},
        json={"payment_method": "raww_credits"},
    )
    assert credits_resp.status_code == 200
    assert credits_resp.json()["order"]["status"] == "paid"


def test_download_limit_enforced(client, db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    pro_id = str(uuid.uuid4())
    buyer_id = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro_id)
    _seed_user(db_session, buyer_id, [UserRoleType.client])
    pack_id = _create_approved_pack(client, pro_id, price_eur="5.00", price_raww=0)

    order = ContentPackOrder(
        buyer_user_id=uuid.UUID(buyer_id),
        content_pack_id=uuid.UUID(pack_id),
        price_eur_paid=Decimal("5.00"),
        price_raww_paid=0,
        payment_method=ContentPackPaymentMethod.stripe,
        status=ContentPackOrderStatus.paid,
    )
    db_session.add(order)
    db_session.flush()
    db_session.add(
        ContentPackEntitlement(
            order_id=order.id,
            buyer_user_id=uuid.UUID(buyer_id),
            content_pack_id=uuid.UUID(pack_id),
            valid_from=datetime.now(timezone.utc),
            valid_until=None,
            download_limit=1,
            downloads_used=1,
        )
    )
    db_session.commit()

    resp = client.post(f"/v1/studioverse/orders/{order.id}/download", headers={"X-User-Id": buyer_id})
    assert resp.status_code == 403


def test_royalty_reversal_on_refund(client, db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    pro_id = str(uuid.uuid4())
    buyer_id = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro_id)
    _seed_user(db_session, buyer_id, [UserRoleType.client])
    pack_id = _create_approved_pack(client, pro_id, price_eur="0.00", price_raww=1000)

    db_session.add(RewardBalance(user_id=uuid.UUID(buyer_id), balance=3000))
    db_session.commit()

    checkout = client.post(
        f"/v1/studioverse/packs/{pack_id}/checkout",
        headers={"X-User-Id": buyer_id},
        json={"payment_method": "raww_credits"},
    )
    assert checkout.status_code == 200
    order_id = checkout.json()["order"]["id"]

    order = db_session.get(ContentPackOrder, uuid.UUID(order_id))
    reverse_paid_order(db_session, order=order, reason="test_refund")
    db_session.commit()

    db_session.refresh(order)
    royalty = db_session.query(RoyaltyLedgerEntry).filter_by(content_pack_order_id=order.id).one()
    assert order.status == ContentPackOrderStatus.refunded
    assert royalty.status == RoyaltyLedgerStatus.reversed


def test_indexing_triggered_on_approval_and_access_control(client, db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    pro_id = str(uuid.uuid4())
    outsider_id = str(uuid.uuid4())
    _seed_approved_pro(db_session, pro_id)
    _seed_user(db_session, outsider_id, [UserRoleType.client])

    denied = client.post(
        "/v1/studioverse/packs",
        headers={"X-User-Id": outsider_id},
        json={
            "title": "Nope",
            "description": "No role",
            "category": "preset",
            "pack_file_storage_key": "x.zip",
            "license_code": "standard_personal",
            "sources": [],
        },
    )
    assert denied.status_code == 403

    create_resp = client.post(
        "/v1/studioverse/packs",
        headers={"X-User-Id": pro_id},
        json={
            "title": "My Pack",
            "description": "Pack",
            "category": "preset",
            "price_eur": "10.00",
            "pack_file_storage_key": "studioverse/packs/my-pack.zip",
            "license_code": "standard_personal",
            "sources": [],
        },
    )
    assert create_resp.status_code == 200
    pack_id = create_resp.json()["id"]
    submit_resp = client.post(f"/v1/studioverse/packs/{pack_id}/submit", headers={"X-User-Id": pro_id})
    assert submit_resp.status_code == 200

    approve_resp = client.post(
        f"/v1/admin/studioverse/packs/{pack_id}/review",
        headers={"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""},
        json={"decision": "approved", "notes": "ship"},
    )
    assert approve_resp.status_code == 200

    queued = db_session.query(OutboxEvent).filter_by(topic="index.content_pack.upsert").count()
    assert queued >= 1
