import io
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from PIL import Image

from app.models.admin import UserRole, UserRoleType
from app.models.gallery import ProofGallery, ProofGalleryItem
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
from app.models.media_rights import GigUsageConsentEvent, MediaAccessLog, MediaDerivative, MediaDerivativeKind, ShareLink
from app.models.outbox import OutboxEvent
from app.services.media_rights import hash_share_token
from app.tasks.media_tasks import generate_watermarked_preview


def _create_gig(db_session, client_id: str, pro_id: str) -> Gig:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=GigStatus.paid,
        currency="EUR",
        amount_total=Decimal("120.00"),
        amount_platform_fee=Decimal("24.00"),
        amount_pro_gross=Decimal("96.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.commit()
    db_session.refresh(gig)
    return gig


def _create_gallery(db_session, gig: Gig) -> ProofGallery:
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=1,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
    )
    db_session.add(gallery)
    db_session.commit()
    db_session.refresh(gallery)
    return gallery


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
            width=2400,
            height=1600,
        )
    )
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.thumbnail,
            storage_key=f"users/{owner_user_id}/photo/{asset.id}_thumb.jpg",
            status=ObjectStatus.ready,
            width=512,
            height=340,
        )
    )
    if with_wm:
        db_session.add(
            MediaObject(
                media_asset_id=asset.id,
                variant=MediaVariant.watermark_preview,
                storage_key=f"users/{owner_user_id}/photo/{asset.id}_wm.jpg",
                status=ObjectStatus.ready,
                width=2400,
                height=1600,
            )
        )

    db_session.commit()
    db_session.refresh(asset)
    return asset


def test_entitlement_enforced_for_proof_signed_url(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery = _create_gallery(db_session, gig)
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.commit()

    monkeypatch.setattr("app.api.v1.media_rights.create_presigned_get", lambda key, expires_in=120: f"https://signed/{key}")

    denied = client.get(
        f"/v1/gigs/{gig.id}/media/{asset.id}/signed-url",
        headers={"X-User-Id": client_id},
        params={"kind": "preview_watermarked"},
    )
    assert denied.status_code == 403

    published = client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers={"X-User-Id": pro_id})
    assert published.status_code == 200

    allowed = client.get(
        f"/v1/gigs/{gig.id}/media/{asset.id}/signed-url",
        headers={"X-User-Id": client_id},
        params={"kind": "preview_watermarked"},
    )
    assert allowed.status_code == 200
    assert allowed.json()["url"].startswith("https://signed/")


def test_share_link_expiry_max_views_and_revoke(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    admin_id = "00000000-0000-0000-0000-0000000000aa"

    db_session.add(UserRole(user_id=uuid.UUID(admin_id), role=UserRoleType.admin))
    db_session.commit()

    gig = _create_gig(db_session, client_id, pro_id)
    gallery = _create_gallery(db_session, gig)
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.commit()

    client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers={"X-User-Id": pro_id})

    monkeypatch.setattr("app.api.v1.media_rights.create_presigned_get", lambda key, expires_in=120: f"https://signed/{key}")

    create = client.post(
        f"/v1/gigs/{gig.id}/share-links",
        headers={"X-User-Id": pro_id},
        json={"scope": "proofs", "max_views": 1},
    )
    assert create.status_code == 200
    payload = create.json()
    token = payload["token"]

    first = client.get(f"/v1/share/{token}")
    assert first.status_code == 200

    second = client.get(f"/v1/share/{token}")
    assert second.status_code == 404

    create2 = client.post(
        f"/v1/gigs/{gig.id}/share-links",
        headers={"X-User-Id": pro_id},
        json={"scope": "proofs", "expires_at": (datetime.now(timezone.utc) - timedelta(minutes=1)).isoformat()},
    )
    token2 = create2.json()["token"]
    expired = client.get(f"/v1/share/{token2}")
    assert expired.status_code == 404

    share_link = db_session.query(ShareLink).filter_by(token_hash=hash_share_token(token2)).one()
    revoke = client.post(f"/v1/admin/share-links/{share_link.id}/revoke", headers={"X-User-Id": admin_id, "X-Admin-Api-Key": ""})
    assert revoke.status_code == 200


def test_consent_change_creates_event_and_notification(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)

    initial = client.get(f"/v1/gigs/{gig.id}/consent", headers={"X-User-Id": client_id})
    assert initial.status_code == 200

    updated = client.put(
        f"/v1/gigs/{gig.id}/consent",
        headers={"X-User-Id": client_id},
        json={"consent_level": "both_pro_and_rawwers", "scope": {"channels": ["website", "social"]}},
    )
    assert updated.status_code == 200

    events = db_session.query(GigUsageConsentEvent).filter(GigUsageConsentEvent.gig_id == gig.id).all()
    assert len(events) >= 2

    outbox = db_session.query(OutboxEvent).filter(OutboxEvent.topic == "notify.create_inapp").all()
    assert any((row.payload or {}).get("type") == "consent.updated" for row in outbox)


def test_signed_url_logs_media_access(client, db_session, monkeypatch):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    gig = _create_gig(db_session, client_id, pro_id)
    gallery = _create_gallery(db_session, gig)
    asset = _create_photo_asset(db_session, pro_id, with_wm=True)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=1))
    db_session.commit()

    client.post(f"/v1/proof-galleries/{gallery.id}/publish", headers={"X-User-Id": pro_id})

    monkeypatch.setattr("app.api.v1.media_rights.create_presigned_get", lambda key, expires_in=120: f"https://signed/{key}")

    response = client.get(
        f"/v1/gigs/{gig.id}/media/{asset.id}/signed-url",
        headers={"X-User-Id": client_id},
        params={"kind": "preview_watermarked"},
    )
    assert response.status_code == 200
    assert response.json()["url"].startswith("https://signed/")

    logs = db_session.query(MediaAccessLog).filter(MediaAccessLog.gig_id == gig.id, MediaAccessLog.media_asset_id == asset.id).all()
    assert len(logs) == 1
    assert logs[0].derivative_kind == "preview_watermarked"


def test_derivative_generation_job_creates_media_derivative(db_session, monkeypatch):
    owner = str(uuid.uuid4())
    asset = MediaAsset(
        owner_user_id=uuid.UUID(owner),
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.processing,
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
            storage_key=f"users/{owner}/photo/{asset.id}_orig.jpg",
            status=ObjectStatus.ready,
        )
    )
    db_session.commit()

    image = Image.new("RGB", (1200, 800), color="white")
    payload = io.BytesIO()
    image.save(payload, format="JPEG")
    blob = payload.getvalue()

    monkeypatch.setattr("app.tasks.media_tasks.download_object_bytes", lambda key: blob)
    monkeypatch.setattr("app.tasks.media_tasks.upload_object_bytes", lambda key, payload, content_type="image/jpeg": None)

    generate_watermarked_preview(str(asset.id))

    derivative = db_session.query(MediaDerivative).filter(
        MediaDerivative.media_asset_id == asset.id,
        MediaDerivative.kind == MediaDerivativeKind.preview_watermarked,
    ).one_or_none()
    assert derivative is not None
