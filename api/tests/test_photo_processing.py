"""The order derivatives become usable in, and what a failure leaves behind.

Delivery waits on one thing - a ready watermark preview - so that is made and
committed first and the other derivatives follow. That makes a photo
attachable earlier (measured on real R2), and it also means a failure can now
happen *after* a photo became attachable. These pin what has to hold then:
the final is downloadable from the moment the photo is attachable, a
transient failure is retried, and a photo whose processing gave up cannot be
delivered.

Storage is replaced with an in-memory store; the real-R2 behaviour was
measured separately.
"""
import io
import uuid

import pytest
from app.db.session import SessionLocal
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
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from celery.exceptions import Retry
from PIL import Image
from sqlalchemy import select

import app.tasks.media_tasks as tasks


def _jpeg(width=3000, height=2000) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (width, height), (90, 120, 150)).save(buf, "JPEG", quality=80)
    return buf.getvalue()


class _Store:
    def __init__(self):
        self.objects: dict[str, bytes] = {}
        self.order: list[str] = []
        self.cache_control: dict[str, str | None] = {}
        self.fail_suffixes: set[str] = set()
        self.seen_when_others_started: dict | None = None
        self.asset_id = None

    def download(self, key, max_bytes=0):
        return self.objects[key]

    def upload(self, key, payload, content_type="image/jpeg", cache_control=None):
        if any(key.endswith(s) for s in self.fail_suffixes):
            raise ConnectionError("R2 unreachable")
        if key.endswith("_thumbnail.jpg") and self.seen_when_others_started is None:
            # What a delivery attach would see at the moment the other three
            # derivatives start going up - read through a separate connection.
            with SessionLocal() as other:
                wm = other.execute(
                    select(MediaObject).where(
                        MediaObject.media_asset_id == self.asset_id,
                        MediaObject.variant == MediaVariant.watermark_preview,
                        MediaObject.status == ObjectStatus.ready,
                    )
                ).first()
                final = other.execute(
                    select(MediaDerivative).where(
                        MediaDerivative.media_asset_id == self.asset_id,
                        MediaDerivative.kind == MediaDerivativeKind.full_res,
                    )
                ).first()
                self.seen_when_others_started = {"watermark_preview": wm is not None, "full_res": final is not None}
        self.order.append(key.rsplit("_", 1)[-1])
        self.cache_control[key.rsplit("_", 1)[-1]] = cache_control
        self.objects[key] = payload


@pytest.fixture
def store(monkeypatch):
    # retry() would put a real message on the broker - which the dev worker
    # also listens to. What is under test is the decision to retry, so it
    # raises Celery's Retry and schedules nothing.
    def retry(exc=None, countdown=None, **_):
        raise Retry(exc=exc, when=countdown)

    monkeypatch.setattr(tasks.process_photo_variants, "retry", retry)
    s = _Store()
    monkeypatch.setattr(tasks, "download_object_bytes", s.download)
    monkeypatch.setattr(tasks, "upload_object_bytes", s.upload)
    monkeypatch.setattr(tasks, "_watermark_text", lambda db, asset: "RAWWERS • Test")
    return s


def _asset(db_session, store, visibility=MediaVisibility.client_only, purpose=MediaPurpose.proof) -> uuid.UUID:
    owner = uuid.uuid4()
    key = f"users/{owner}/photos/{uuid.uuid4()}.jpg"
    store.objects[key] = _jpeg()
    asset = MediaAsset(
        owner_user_id=owner,
        kind=MediaKind.photo,
        purpose=purpose,
        provider=MediaProvider.r2,
        status=MediaStatus.processing,
        visibility=visibility,
        content_type="image/jpeg",
        byte_size=len(store.objects[key]),
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=key, status=ObjectStatus.created))
    db_session.commit()
    store.asset_id = asset.id
    return asset.id


def _run(asset_id, retries=0):
    """One execution, as the worker would run attempt number `retries`."""
    tasks.process_photo_variants.push_request(retries=retries)
    try:
        tasks.process_photo_variants.run(str(asset_id))
    finally:
        tasks.process_photo_variants.pop_request()


def test_the_watermark_preview_is_attachable_before_the_rest_go_up_and_its_final_is_already_there(db_session, store):
    asset_id = _asset(db_session, store)

    _run(asset_id)

    assert store.order[0] == "preview.jpg", "the one delivery waits for goes first"
    assert store.seen_when_others_started == {"watermark_preview": True, "full_res": True}, (
        "committed - visible to another connection - before the other derivatives started"
    )
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready


def test_a_failure_after_the_preview_is_retried_not_given_up_on(db_session, store):
    asset_id = _asset(db_session, store)
    store.fail_suffixes = {"_web_res.jpg"}

    with pytest.raises(Retry):
        _run(asset_id, retries=0)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.processing, "not failed on the first error"

    store.fail_suffixes = set()
    _run(asset_id, retries=1)  # the retry, once R2 is back
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready


def test_after_the_last_retry_it_is_failed_but_never_left_without_its_final(db_session, store):
    asset_id = _asset(db_session, store)
    store.fail_suffixes = {"_web_res.jpg"}

    _run(asset_id, retries=tasks.process_photo_variants.max_retries)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.failed
    final = db_session.execute(
        select(MediaDerivative).where(MediaDerivative.media_asset_id == asset_id, MediaDerivative.kind == MediaDerivativeKind.full_res)
    ).scalar_one_or_none()
    assert final is not None, "anything that was ever attachable has a downloadable final"


def test_a_photo_whose_processing_failed_cannot_join_a_gallery(client, db_session):
    """Its watermark preview is ready (it is made first), so the old rule -
    "a ready watermark preview" - would have let it in."""
    from tests.test_gig_and_gallery_guards import _draft_gallery, _h
    from tests.test_proof_gallery import _create_photo_asset

    gig, gallery_id = _draft_gallery(client, db_session)
    failed = _create_photo_asset(db_session, str(gig.pro_user_id))
    failed.status = MediaStatus.failed
    ready = _create_photo_asset(db_session, str(gig.pro_user_id))
    db_session.commit()

    refused = client.post(f"/v1/proof-galleries/{gallery_id}/items", headers=_h(gig.pro_user_id), json={"media_asset_ids": [str(failed.id)]})
    accepted = client.post(f"/v1/proof-galleries/{gallery_id}/items", headers=_h(gig.pro_user_id), json={"media_asset_ids": [str(ready.id)]})

    assert refused.status_code == 409, refused.text
    assert "Upload it again" in refused.json()["error"]["message"]
    assert accepted.status_code == 200, accepted.text


def test_a_clients_proofs_are_never_marked_for_shared_caches(db_session, store):
    """web_res is the unwatermarked copy a client gets only once it is paid
    for; the previews are that one client's. `public` would let any shared
    cache keep them."""
    asset_id = _asset(db_session, store)

    _run(asset_id)

    assert set(store.cache_control) == {"preview.jpg", "thumbnail.jpg", "watermarked.jpg", "res.jpg"}
    assert all(v.startswith("private,") for v in store.cache_control.values()), store.cache_control


def test_public_portfolio_work_may_be_cached_anywhere(db_session, store):
    asset_id = _asset(db_session, store, visibility=MediaVisibility.public, purpose=MediaPurpose.portfolio_reel)

    _run(asset_id)

    assert all(v.startswith("public,") for v in store.cache_control.values()), store.cache_control


@pytest.mark.parametrize("visibility", [v for v in MediaVisibility if v != MediaVisibility.public])
def test_anything_short_of_public_is_private(visibility):
    from app.services.storage import derivative_cache_control

    assert derivative_cache_control(visibility).startswith("private,")
