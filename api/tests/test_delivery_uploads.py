"""Delivery uploads: their own rate bucket, and one photo per file per gallery.

A wedding is 400-1000 photos. They used to share the 30-an-hour `uploads`
bucket with every other upload, so a delivery stopped at photo 31. Proofs now
count against `delivery_uploads` (2,000 an hour per photographer); every other
purpose keeps the 30.

An upload may name its gallery and the SHA-256 of its file. The same file sent
to the same gallery again - a retry, an app killed mid-batch and restarted, an
export run twice - is then the photo already there, not a second copy. The
worker checks the hash against the bytes that arrived, so a wrong one cannot
pass a different file off as a duplicate.

R2 and the broker are replaced with fakes: no network in tests.
"""
import hashlib
import io
import uuid
from decimal import Decimal

import pytest
from PIL import Image
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

import app.tasks.media_tasks as tasks
from app.models.gallery import ProofGallery, ProofGalleryStatus
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
from app.services import rate_limit

SHA = hashlib.sha256(b"IMG_0412").hexdigest()


@pytest.fixture(autouse=True)
def fake_r2(monkeypatch):
    signed = lambda storage_key, content_type, expires_in=900: f"https://r2.invalid/{storage_key}?sig={uuid.uuid4().hex}"
    monkeypatch.setattr("app.services.photo_uploads.create_presigned_put", signed)
    monkeypatch.setattr("app.api.v1.media.create_presigned_put", signed)
    monkeypatch.setattr("app.api.v1.media.create_multipart_upload", lambda key, content_type: f"up-{uuid.uuid4().hex}")
    monkeypatch.setattr("app.api.v1.media.process_photo_variants.delay", lambda *_a, **_k: None)


def _h(user_id):
    return {"X-User-Id": str(user_id)}


def _gallery(db_session, pro_id=None, *, gig_status=GigStatus.paid, status=ProofGalleryStatus.draft) -> ProofGallery:
    pro_id = pro_id or uuid.uuid4()
    gig = Gig(
        client_user_id=uuid.uuid4(),
        pro_user_id=pro_id,
        status=gig_status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=pro_id,
        client_user_id=gig.client_user_id,
        included_photos=10,
        extra_photo_price=Decimal("5.00"),
        currency="EUR",
        status=status,
    )
    db_session.add(gallery)
    db_session.commit()
    return gallery


def _create(client, user_id, *, purpose="proof", **extra):
    body = {"purpose": purpose, "content_type": "image/jpeg", "file_name": "IMG_0412.jpg", **extra}
    return client.post("/v1/media/photos/uploads", headers=_h(user_id), json=body)


def _set_status(db_session, asset_id, status):
    db_session.expire_all()
    db_session.get(MediaAsset, uuid.UUID(asset_id)).status = status
    db_session.commit()


# --- the delivery bucket -----------------------------------------------------------


def test_a_delivery_is_not_stopped_by_the_30_an_hour_upload_limit(client, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (2, 3600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "auth_mutation", (2, 60))
    pro = uuid.uuid4()

    codes = [_create(client, pro).status_code for _ in range(5)]

    assert codes == [200] * 5


def test_a_delivery_has_its_own_limit(client, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_uploads", (2, 3600))
    pro = uuid.uuid4()

    codes = [_create(client, pro).status_code for _ in range(3)]

    assert codes == [200, 200, 429]


def test_the_delivery_limit_is_2000_an_hour():
    assert rate_limit.RATE_LIMIT_RULES["delivery_uploads"] == (2000, 3600)
    assert rate_limit.RATE_LIMIT_RULES["uploads"] == (30, 3600)


@pytest.mark.parametrize("purpose", ["portfolio_reel", "other"])
def test_every_other_upload_keeps_the_30_an_hour_limit(client, monkeypatch, purpose):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (2, 3600))
    pro = uuid.uuid4()

    codes = [_create(client, pro, purpose=purpose).status_code for _ in range(3)]

    assert codes == [200, 200, 429]


def test_a_delivery_retry_and_a_large_file_count_against_the_delivery_bucket(client, monkeypatch):
    pro = uuid.uuid4()
    asset_id = _create(client, pro).json()["media_asset_id"]
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (0, 3600))

    refreshed = client.post(f"/v1/media/photos/{asset_id}/upload-url", headers=_h(pro))
    started = client.post(f"/v1/media/photos/{asset_id}/multipart", headers=_h(pro), json={"byte_size": 20_000_000})

    assert (refreshed.status_code, started.status_code) == (200, 200), (refreshed.text, started.text)

    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_uploads", (0, 3600))
    assert client.post(f"/v1/media/photos/{asset_id}/upload-url", headers=_h(pro)).status_code == 429


def test_a_retry_of_any_other_upload_still_counts_against_the_30(client, monkeypatch):
    pro = uuid.uuid4()
    asset_id = _create(client, pro, purpose="other").json()["media_asset_id"]
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (0, 3600))

    assert client.post(f"/v1/media/photos/{asset_id}/upload-url", headers=_h(pro)).status_code == 429
    assert client.post(f"/v1/media/photos/{asset_id}/multipart", headers=_h(pro), json={"byte_size": 20_000_000}).status_code == 429


# --- one photo per file per gallery ---------------------------------------------


def test_the_same_file_again_is_the_photo_already_there(client, db_session):
    gallery = _gallery(db_session)
    first = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()
    _set_status(db_session, first["media_asset_id"], MediaStatus.processing)

    again = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA)

    assert again.status_code == 200, again.text
    assert again.json()["media_asset_id"] == first["media_asset_id"]
    assert again.json()["duplicate"] is True
    assert again.json()["upload"] is None, "nothing to send: the file is already there"
    assert first["duplicate"] is False and first["upload"]["method"] == "PUT"
    assert len(db_session.execute(select(MediaAsset).where(MediaAsset.delivery_gallery_id == gallery.id)).scalars().all()) == 1


def test_a_file_that_never_finished_uploading_is_resumed_not_duplicated(client, db_session):
    gallery = _gallery(db_session)
    first = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()

    again = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()

    assert again["media_asset_id"] == first["media_asset_id"]
    assert again["duplicate"] is False
    assert again["upload"]["storage_key"] == first["upload"]["storage_key"], "the same original, a fresh URL"
    assert again["upload"]["url"] != first["upload"]["url"]


def test_the_hash_is_compared_whatever_its_case(client, db_session):
    gallery = _gallery(db_session)
    first = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA.upper()).json()

    again = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()

    assert again["media_asset_id"] == first["media_asset_id"]
    db_session.expire_all()
    assert db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"])).checksum == SHA


def test_the_same_file_in_another_gallery_is_a_new_photo(client, db_session):
    pro = uuid.uuid4()
    one, two = _gallery(db_session, pro), _gallery(db_session, pro)

    a = _create(client, pro, gallery_id=str(one.id), sha256=SHA).json()
    b = _create(client, pro, gallery_id=str(two.id), sha256=SHA).json()

    assert a["media_asset_id"] != b["media_asset_id"]


@pytest.mark.parametrize("status", [MediaStatus.failed, MediaStatus.deleted])
def test_a_file_whose_photo_failed_can_be_sent_again(client, db_session, status):
    gallery = _gallery(db_session)
    first = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()
    _set_status(db_session, first["media_asset_id"], status)

    again = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()

    assert again["media_asset_id"] != first["media_asset_id"]
    assert again["duplicate"] is False and again["upload"] is not None


def test_without_a_hash_every_upload_is_a_new_photo(client, db_session):
    gallery = _gallery(db_session)

    a = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id)).json()
    b = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id)).json()

    assert a["media_asset_id"] != b["media_asset_id"]
    db_session.expire_all()
    assert db_session.get(MediaAsset, uuid.UUID(a["media_asset_id"])).delivery_gallery_id == gallery.id


def test_the_database_holds_one_live_photo_per_file_per_gallery(db_session):
    """What stops two uploads of the same file racing past the lookup."""
    gallery = _gallery(db_session)

    def asset(status):
        return MediaAsset(
            owner_user_id=gallery.pro_user_id,
            kind=MediaKind.photo,
            purpose=MediaPurpose.proof,
            provider=MediaProvider.r2,
            status=status,
            visibility=MediaVisibility.client_only,
            delivery_gallery_id=gallery.id,
            checksum=SHA,
            meta={},
        )

    db_session.add_all([asset(MediaStatus.failed), asset(MediaStatus.failed), asset(MediaStatus.uploading)])
    db_session.commit()

    db_session.add(asset(MediaStatus.uploading))
    with pytest.raises(IntegrityError):
        db_session.commit()
    db_session.rollback()


def test_two_uploads_of_one_file_that_race_get_one_photo(client, db_session, monkeypatch):
    """The second passed the lookup before the first was committed: the
    database refuses it, and it answers with the photo that won."""
    gallery = _gallery(db_session)
    first = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).json()
    import app.api.v1.media as media

    real, calls = media._live_delivery_duplicate, []

    def missed_once(*args):
        calls.append(args)
        return None if len(calls) == 1 else real(*args)

    monkeypatch.setattr(media, "_live_delivery_duplicate", missed_once)

    again = _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA)

    assert again.status_code == 200, again.text
    assert again.json()["media_asset_id"] == first["media_asset_id"]
    assert len(calls) == 2, "missed by the lookup, found after the insert was refused"


# --- what an upload may name -----------------------------------------------------


@pytest.mark.parametrize(
    "sha256, with_gallery",
    [
        (SHA, False),  # a duplicate is per gallery: no gallery, nothing to compare with
        ("abc", True),
        ("g" * 64, True),
    ],
    ids=["hash-without-gallery", "short-hash", "not-hex"],
)
def test_a_hash_must_be_a_sha256_for_a_named_gallery(client, db_session, sha256, with_gallery):
    gallery = _gallery(db_session)
    body = {"sha256": sha256, **({"gallery_id": str(gallery.id)} if with_gallery else {})}

    assert _create(client, gallery.pro_user_id, **body).status_code == 422


def test_only_a_delivery_names_a_gallery(client, db_session):
    gallery = _gallery(db_session)

    resp = _create(client, gallery.pro_user_id, purpose="portfolio_reel", gallery_id=str(gallery.id), sha256=SHA)

    assert resp.status_code == 422


def test_only_the_galleries_photographer_can_upload_into_it(client, db_session):
    gallery = _gallery(db_session)

    assert _create(client, uuid.uuid4(), gallery_id=str(gallery.id), sha256=SHA).status_code == 403
    assert _create(client, gallery.pro_user_id, gallery_id=str(uuid.uuid4()), sha256=SHA).status_code == 404


@pytest.mark.parametrize("status", [ProofGalleryStatus.selection_submitted, ProofGalleryStatus.delivered])
def test_a_closed_gallery_takes_no_uploads(client, db_session, status):
    gallery = _gallery(db_session, status=status)

    assert _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).status_code == 409


@pytest.mark.parametrize("gig_status", [GigStatus.cancelled_by_client, GigStatus.completed])
def test_a_booking_that_cannot_take_photos_takes_no_uploads(client, db_session, gig_status):
    gallery = _gallery(db_session, gig_status=gig_status)

    assert _create(client, gallery.pro_user_id, gallery_id=str(gallery.id), sha256=SHA).status_code == 409


# --- the worker checks the hash ----------------------------------------------------


def _jpeg() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (800, 600), (90, 120, 150)).save(buf, "JPEG", quality=80)
    return buf.getvalue()


@pytest.fixture
def store(monkeypatch):
    objects: dict[str, bytes] = {}
    monkeypatch.setattr(tasks, "download_object_bytes", lambda key, max_bytes=0: objects[key])
    monkeypatch.setattr(tasks, "upload_object_bytes", lambda key, payload, *_a, **_k: objects.__setitem__(key, payload))
    monkeypatch.setattr(tasks, "_watermark_text", lambda db, asset: "RAWWERS • Test")
    return objects


def _processing_asset(db_session, store, *, checksum) -> uuid.UUID:
    owner = uuid.uuid4()
    key = f"users/{owner}/photos/{uuid.uuid4()}.jpg"
    store[key] = _jpeg()
    asset = MediaAsset(
        owner_user_id=owner,
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.processing,
        visibility=MediaVisibility.client_only,
        content_type="image/jpeg",
        checksum=checksum(store[key]),
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=key, status=ObjectStatus.created))
    db_session.commit()
    return asset.id


def _run(asset_id):
    tasks.process_photo_variants.push_request(retries=0)
    try:
        tasks.process_photo_variants.run(str(asset_id))
    finally:
        tasks.process_photo_variants.pop_request()


@pytest.mark.parametrize(
    "checksum",
    [lambda data: hashlib.sha256(data).hexdigest(), lambda data: None],
    ids=["matching-hash", "no-hash"],
)
def test_a_file_that_matches_its_hash_is_processed(db_session, store, checksum):
    asset_id = _processing_asset(db_session, store, checksum=checksum)

    _run(asset_id)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready


def test_a_file_that_does_not_match_its_hash_fails_and_is_not_processed(db_session, store):
    asset_id = _processing_asset(db_session, store, checksum=lambda data: hashlib.sha256(b"another file").hexdigest())

    _run(asset_id)

    db_session.expire_all()
    asset = db_session.get(MediaAsset, asset_id)
    assert asset.status == MediaStatus.failed
    assert "does not match" in asset.meta["failure_reason"]
    assert not any(key.endswith("_watermark_preview.jpg") for key in store), "nothing was made from it"
