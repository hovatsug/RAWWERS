import uuid
from decimal import Decimal

from app.models.gallery import ProofGallery, ProofGalleryItem, UpsellPurchase, UpsellPurchaseStatus
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType
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


class DummyStripePI:
    def __init__(self, pi_id: str, client_secret: str, status: str = "requires_payment_method"):
        self.id = pi_id
        self.client_secret = client_secret
        self.status = status


def _create_gig(db_session, client_id: str, pro_id: str) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=GigStatus.paid,
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


def test_pro_cannot_attach_someone_else_media(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    other_pro = str(uuid.uuid4())

    gig = _create_gig(db_session, client_id, pro_id)
    foreign_asset = _create_photo_asset(db_session, other_pro, with_wm=True)

    create_gallery = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers={"X-User-Id": pro_id},
        json={"included_photos": 2, "extra_photo_price": "10.00"},
    )
    assert create_gallery.status_code == 200
    gallery_id = create_gallery.json()["id"]

    add_items = client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers={"X-User-Id": pro_id},
        json={"media_asset_ids": [str(foreign_asset.id)]},
    )
    assert add_items.status_code == 403


def test_client_cannot_view_gallery_before_publish(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)

    monkeypatch.setattr("app.api.v1.proof_galleries.create_presigned_get", lambda key, expires_in=300: f"https://signed/{key}")

    create_gallery = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers={"X-User-Id": pro_id},
        json={"included_photos": 1, "extra_photo_price": "5.00"},
    )
    gallery_id = create_gallery.json()["id"]

    client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers={"X-User-Id": pro_id},
        json={"media_asset_ids": [str(asset.id)]},
    )

    before_publish = client.get(f"/v1/proof-galleries/{gallery_id}", headers={"X-User-Id": client_id})
    assert before_publish.status_code == 403


def test_client_submit_selection_creates_upsell(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    a1 = _create_photo_asset(db_session, pro_id, with_wm=True)
    a2 = _create_photo_asset(db_session, pro_id, with_wm=True)

    monkeypatch.setattr(
        "app.api.v1.proof_galleries.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_upsell_1", "sec_upsell_1"),
    )

    create_gallery = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers={"X-User-Id": pro_id},
        json={"included_photos": 1, "extra_photo_price": "10.00"},
    )
    gallery_id = create_gallery.json()["id"]

    client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers={"X-User-Id": pro_id},
        json={"media_asset_ids": [str(a1.id), str(a2.id)]},
    )
    client.post(f"/v1/proof-galleries/{gallery_id}/publish", headers={"X-User-Id": pro_id})

    save_selection = client.post(
        f"/v1/proof-galleries/{gallery_id}/selections",
        headers={"X-User-Id": client_id},
        json={"media_asset_ids": [str(a1.id), str(a2.id)]},
    )
    assert save_selection.status_code == 200

    submit = client.post(f"/v1/proof-galleries/{gallery_id}/selections/submit", headers={"X-User-Id": client_id})
    assert submit.status_code == 200
    payload = submit.json()
    assert payload["upsell_required"] is True
    assert payload["payment_intent_id"] == "pi_upsell_1"


def test_upsell_webhook_idempotency(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    a1 = _create_photo_asset(db_session, pro_id, with_wm=True)
    a2 = _create_photo_asset(db_session, pro_id, with_wm=True)

    monkeypatch.setattr(
        "app.api.v1.proof_galleries.stripe.PaymentIntent.create",
        lambda **kwargs: DummyStripePI("pi_upsell_2", "sec_upsell_2"),
    )

    gallery_id = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers={"X-User-Id": pro_id},
        json={"included_photos": 1, "extra_photo_price": "10.00"},
    ).json()["id"]

    client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers={"X-User-Id": pro_id},
        json={"media_asset_ids": [str(a1.id), str(a2.id)]},
    )
    client.post(f"/v1/proof-galleries/{gallery_id}/publish", headers={"X-User-Id": pro_id})
    client.post(
        f"/v1/proof-galleries/{gallery_id}/selections",
        headers={"X-User-Id": client_id},
        json={"media_asset_ids": [str(a1.id), str(a2.id)]},
    )
    client.post(f"/v1/proof-galleries/{gallery_id}/selections/submit", headers={"X-User-Id": client_id})

    event = {
        "id": "evt_upsell_1",
        "type": "payment_intent.succeeded",
        "data": {"object": {"id": "pi_upsell_2"}},
    }
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: event)

    first = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})
    second = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})

    assert first.status_code == 200
    assert second.status_code == 200

    purchase = db_session.query(UpsellPurchase).filter_by(stripe_payment_intent_id="pi_upsell_2").one()
    assert purchase.status == UpsellPurchaseStatus.succeeded

    entries = (
        db_session.query(LedgerEntry)
        .filter(LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == LedgerEntryType.upsell_captured)
        .all()
    )
    assert len(entries) == 1


def test_download_endpoint_only_returns_unlocked_originals(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    a1 = _create_photo_asset(db_session, pro_id, with_wm=True)
    a2 = _create_photo_asset(db_session, pro_id, with_wm=True)

    monkeypatch.setattr("app.api.v1.proof_galleries.create_presigned_get", lambda key, expires_in=60: f"https://signed/{key}")

    gallery_id = client.post(
        f"/v1/gigs/{gig.id}/proof-gallery",
        headers={"X-User-Id": pro_id},
        json={"included_photos": 1, "extra_photo_price": "10.00"},
    ).json()["id"]

    client.post(
        f"/v1/proof-galleries/{gallery_id}/items",
        headers={"X-User-Id": pro_id},
        json={"media_asset_ids": [str(a1.id), str(a2.id)]},
    )
    client.post(f"/v1/proof-galleries/{gallery_id}/publish", headers={"X-User-Id": pro_id})
    client.post(
        f"/v1/proof-galleries/{gallery_id}/selections",
        headers={"X-User-Id": client_id},
        json={"media_asset_ids": [str(a1.id)]},
    )
    client.post(f"/v1/proof-galleries/{gallery_id}/selections/submit", headers={"X-User-Id": client_id})

    downloads = client.get(f"/v1/proof-galleries/{gallery_id}/downloads", headers={"X-User-Id": client_id})
    assert downloads.status_code == 200
    urls = downloads.json()["urls"]
    assert str(a1.id) in urls
    assert str(a2.id) not in urls
