import uuid
from decimal import Decimal

from app.models.admin import UserRole, UserRoleType
from app.models.client_rewards_pricing import (
    ConsentRewardPolicy,
    ConsentRewardLevel,
    ExtraImagePricingPolicy,
    ExtraImagePurchase,
    ShareRewardThreshold,
    ShareRewardMetric,
    ShareLinkView,
    ShareRewardGrant,
)
from app.models.gallery import (
    ClientSelection,
    ClientSelectionItem,
    ProofGallery,
    ProofGalleryItem,
    ProofGalleryStatus,
    SelectionStatus,
)
from app.models.gig import Gig, GigStatus
from app.models.media import (
    MediaAsset,
    MediaKind,
    MediaObject,
    MediaProvider,
    MediaPurpose,
    MediaStatus,
    MediaVariant,
    MediaVisibility,
    ObjectStatus,
)
from app.models.media_rights import GigEntitlementType, GigMediaEntitlement
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.reward import RewardBalance, RewardEntryType, RewardLedgerEntry
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from sqlalchemy import select


class DummyStripePI:
    def __init__(self, pi_id: str, client_secret: str, status: str = "requires_payment_method"):
        self.id = pi_id
        self.client_secret = client_secret
        self.status = status


def _create_gig(db_session, client_id: str, pro_id: str, niche_id=None) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche_id,
        status=GigStatus.paid,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)
    return gig


def _create_photo_asset(db_session, owner_user_id: str, with_wm: bool = True) -> MediaAsset:
    asset = MediaAsset(
        owner_user_id=uuid.UUID(owner_user_id),
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        content_type="image/jpeg",
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.original,
            storage_key=f"users/{owner_user_id}/photo/{asset.id}_orig.jpg",
            status=ObjectStatus.ready,
            width=2000,
            height=1200,
        )
    )
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.thumbnail,
            storage_key=f"users/{owner_user_id}/photo/{asset.id}_thumb.jpg",
            status=ObjectStatus.ready,
            width=512,
            height=300,
        )
    )
    if with_wm:
        db_session.add(
            MediaObject(
                media_asset_id=asset.id,
                variant=MediaVariant.watermark_preview,
                storage_key=f"users/{owner_user_id}/photo/{asset.id}_wm.jpg",
                status=ObjectStatus.ready,
                width=2000,
                height=1200,
            )
        )
    db_session.commit()
    db_session.refresh(asset)
    return asset


def _create_gallery_with_selection(db_session, gig: Gig, pro_id: str, client_id: str, selected: int = 2) -> tuple[ProofGallery, ClientSelection, list[MediaAsset]]:
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=1,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=ProofGalleryStatus.published,
    )
    db_session.add(gallery)
    db_session.flush()

    assets = []
    for i in range(max(selected, 2)):
        asset = _create_photo_asset(db_session, pro_id, with_wm=True)
        assets.append(asset)
        db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=i + 1))
    db_session.flush()

    selection = ClientSelection(gallery_id=gallery.id, client_user_id=uuid.UUID(client_id), version=1, status=SelectionStatus.submitted)
    db_session.add(selection)
    db_session.flush()
    for asset in assets[:selected]:
        db_session.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=asset.id))

    db_session.commit()
    db_session.refresh(gallery)
    db_session.refresh(selection)
    return gallery, selection, assets


def test_consent_reward_idempotent_and_clawback(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)

    db_session.add(
        ConsentRewardPolicy(
            consent_level=ConsentRewardLevel.both_pro_and_rawwers,
            points_award=100,
            cooldown_hours=48,
            allow_clawback=True,
            max_awards_per_user_per_month=100,
        )
    )
    db_session.add(
        ConsentRewardPolicy(
            consent_level=ConsentRewardLevel.none,
            points_award=0,
            cooldown_hours=48,
            allow_clawback=True,
            max_awards_per_user_per_month=100,
        )
    )
    db_session.commit()

    r1 = client.put(
        f"/v1/gigs/{gig.id}/consent",
        headers={"X-User-Id": client_id},
        json={"consent_level": "both_pro_and_rawwers", "scope": {}},
    )
    assert r1.status_code == 200
    dispatch_outbox_events_task(limit=100)

    r2 = client.put(
        f"/v1/gigs/{gig.id}/consent",
        headers={"X-User-Id": client_id},
        json={"consent_level": "both_pro_and_rawwers", "scope": {}},
    )
    assert r2.status_code == 200
    dispatch_outbox_events_task(limit=100)

    earns = db_session.query(RewardLedgerEntry).filter(
        RewardLedgerEntry.user_id == uuid.UUID(client_id),
        RewardLedgerEntry.reference_type == "consent_reward",
        RewardLedgerEntry.entry_type == RewardEntryType.earn,
    ).all()
    assert len(earns) == 1

    r3 = client.put(
        f"/v1/gigs/{gig.id}/consent",
        headers={"X-User-Id": client_id},
        json={"consent_level": "none", "scope": {}},
    )
    assert r3.status_code == 200
    dispatch_outbox_events_task(limit=100)

    clawbacks = db_session.query(RewardLedgerEntry).filter(
        RewardLedgerEntry.user_id == uuid.UUID(client_id),
        RewardLedgerEntry.reference_type == "consent_clawback",
    ).all()
    assert len(clawbacks) == 1
    assert clawbacks[0].amount < 0


def test_share_view_dedup_and_threshold_grant_once(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=1,
        extra_photo_price=Decimal("5.00"),
        currency="EUR",
        status=ProofGalleryStatus.published,
    )
    db_session.add(gallery)
    db_session.flush()
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.add(
        ShareRewardThreshold(
            metric=ShareRewardMetric.unique_views_30d,
            threshold_value=1,
            points_award=25,
            max_awards_per_share_link=1,
            is_active=True,
        )
    )
    db_session.commit()

    monkeypatch.setattr("app.api.v1.media_rights.create_presigned_get", lambda key, expires_in=120: f"https://signed/{key}")

    create = client.post(
        f"/v1/gigs/{gig.id}/share-links",
        headers={"X-User-Id": pro_id},
        json={"scope": "proofs"},
    )
    assert create.status_code == 200
    token = create.json()["token"]

    v1 = client.get(f"/v1/share/{token}")
    assert v1.status_code == 200
    client.post(f"/v1/share/{token}/ping", json={"seconds_viewed": 15})
    dispatch_outbox_events_task(limit=100)

    v2 = client.get(f"/v1/share/{token}")
    assert v2.status_code == 200
    client.post(f"/v1/share/{token}/ping", json={"seconds_viewed": 15})
    dispatch_outbox_events_task(limit=100)

    link_views = db_session.query(ShareLinkView).all()
    assert len(link_views) == 1

    grants = db_session.query(ShareRewardGrant).all()
    assert len(grants) == 1


def test_tier_based_price_clamp_and_master_no_cap(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    niche_id = db_session.execute(select(Niche.id)).scalar_one()

    db_session.add(
        ProNicheSkill(
            pro_user_id=uuid.UUID(pro_id),
            niche_id=niche_id,
            tier=SkillTier.rookie,
            capability_score=10,
            certification_score=10,
            confidence=Decimal("0.10"),
        )
    )
    db_session.add(
        ExtraImagePricingPolicy(
            niche_id=niche_id,
            tier=SkillTier.rookie,
            unit_price_min=Decimal("1.00"),
            unit_price_max=Decimal("4.00"),
            is_active=True,
            currency="EUR",
        )
    )
    db_session.commit()

    gig = _create_gig(db_session, client_id, pro_id, niche_id=niche_id)
    gallery, selection, _ = _create_gallery_with_selection(db_session, gig, pro_id, client_id, selected=3)

    monkeypatch.setattr(
        "app.api.v1.proof_galleries.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_price_rookie", "sec_price_rookie"),
    )

    resp = client.post(
        f"/v1/proof-galleries/{gallery.id}/upsell/create-intent",
        headers={"X-User-Id": client_id},
        json={},
    )
    assert resp.status_code == 200

    snap = db_session.query(ExtraImagePurchase).filter_by(stripe_payment_intent_id="pi_price_rookie").one()
    assert snap.unit_price_applied == Decimal("4.00")

    skill = db_session.query(ProNicheSkill).filter_by(pro_user_id=uuid.UUID(pro_id), niche_id=niche_id).one()
    skill.tier = SkillTier.master
    policy_master = db_session.query(ExtraImagePricingPolicy).filter_by(niche_id=niche_id, tier=SkillTier.master).one_or_none()
    if not policy_master:
        db_session.add(
            ExtraImagePricingPolicy(
                niche_id=niche_id,
                tier=SkillTier.master,
                unit_price_min=Decimal("1.00"),
                unit_price_max=None,
                is_active=True,
                currency="EUR",
            )
        )
    db_session.commit()

    monkeypatch.setattr(
        "app.api.v1.proof_galleries.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_price_master", "sec_price_master"),
    )
    resp2 = client.post(
        f"/v1/proof-galleries/{gallery.id}/upsell/create-intent",
        headers={"X-User-Id": client_id},
        json={},
    )
    assert resp2.status_code == 200
    snap2 = db_session.query(ExtraImagePurchase).filter_by(stripe_payment_intent_id="pi_price_master").one()
    assert snap2.unit_price_applied >= Decimal("4.00")


def test_points_redemption_cannot_exceed_subtotal(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery, _, _ = _create_gallery_with_selection(db_session, gig, pro_id, client_id, selected=2)

    db_session.add(RewardBalance(user_id=uuid.UUID(client_id), balance=100000))
    db_session.commit()

    monkeypatch.setattr(
        "app.api.v1.proof_galleries.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_points_cap", "sec_points_cap"),
    )

    resp = client.post(
        f"/v1/proof-galleries/{gallery.id}/upsell/create-intent",
        headers={"X-User-Id": client_id},
        json={"points_to_spend": 100000},
    )
    assert resp.status_code == 200

    snap = db_session.query(ExtraImagePurchase).filter_by(stripe_payment_intent_id="pi_points_cap").one()
    assert snap.discounts_total <= snap.subtotal
    assert snap.total >= Decimal("0.01")


def test_entitlement_unlocks_after_upsell_success(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery, _, _ = _create_gallery_with_selection(db_session, gig, pro_id, client_id, selected=2)

    monkeypatch.setattr(
        "app.api.v1.proof_galleries.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_unlock_1", "sec_unlock_1"),
    )
    client.post(
        f"/v1/proof-galleries/{gallery.id}/upsell/create-intent",
        headers={"X-User-Id": client_id},
        json={},
    )

    event = {"id": "evt_unlock_1", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_unlock_1"}}}
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)

    webhook = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    assert webhook.status_code == 200
    dispatch_outbox_events_task(limit=100)

    entitlement = db_session.query(GigMediaEntitlement).filter_by(
        gig_id=gig.id,
        user_id=uuid.UUID(client_id),
        entitlement_type=GigEntitlementType.download_extras,
    ).one_or_none()
    assert entitlement is not None
    assert (entitlement.quantity_limit or 0) > 0
