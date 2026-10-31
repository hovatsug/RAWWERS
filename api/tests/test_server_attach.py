"""A delivery joins its gallery on the server, when processing finishes.

Owner's decision 3: a photo uploaded for a gallery (delivery_gallery_id) is
attached by the worker in the commit that makes it ready, so neither the
plugin nor the app has to stay open for photos to land. The app's own attach
stays as the fallback; the two meet without a second copy or an error.

What must hold: it joins only the gallery it was uploaded for, only while
that gallery and booking can take photos, only once, after the photos
already there, never if processing failed - and a problem attaching never
costs the photo its processing.

Storage and the broker are fakes: no network in tests.
"""
import io
import uuid
from decimal import Decimal

import pytest
from celery.exceptions import Retry
from PIL import Image
from sqlalchemy import select

import app.tasks.media_tasks as tasks
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
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


def _jpeg() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (900, 600), (90, 120, 150)).save(buf, "JPEG", quality=80)
    return buf.getvalue()


@pytest.fixture
def store(monkeypatch):
    objects: dict[str, bytes] = {}

    def retry(exc=None, countdown=None, **_):
        raise Retry(exc=exc, when=countdown)

    monkeypatch.setattr(tasks.process_photo_variants, "retry", retry)
    monkeypatch.setattr(tasks, "download_object_bytes", lambda key, max_bytes=0: objects[key])
    monkeypatch.setattr(tasks, "object_size", lambda key: len(objects[key]) if key in objects else None)
    monkeypatch.setattr(tasks, "upload_object_bytes", lambda key, payload, *_a, **_k: objects.__setitem__(key, payload))
    monkeypatch.setattr(tasks, "_watermark_text", lambda db, asset: "RAWWERS • Test")
    return objects


def _gallery(db_session, pro_id, *, gig_status=GigStatus.shoot_done, status=ProofGalleryStatus.draft) -> ProofGallery:
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


def _photo(db_session, store, owner, *, gallery_id=None, checksum=None, status=MediaStatus.processing) -> uuid.UUID:
    key = f"users/{owner}/photos/{uuid.uuid4()}.jpg"
    store[key] = _jpeg()
    asset = MediaAsset(
        owner_user_id=owner,
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=status,
        visibility=MediaVisibility.client_only,
        content_type="image/jpeg",
        byte_size=len(store[key]),
        delivery_gallery_id=gallery_id,
        checksum=checksum,
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=key, status=ObjectStatus.created))
    db_session.commit()
    return asset.id


def _run(asset_id, retries=0):
    tasks.process_photo_variants.push_request(retries=retries)
    try:
        tasks.process_photo_variants.run(str(asset_id))
    finally:
        tasks.process_photo_variants.pop_request()


def _items(db_session, gallery_id) -> list[ProofGalleryItem]:
    db_session.expire_all()
    return list(
        db_session.execute(select(ProofGalleryItem).where(ProofGalleryItem.gallery_id == gallery_id).order_by(ProofGalleryItem.sort_order)).scalars()
    )


def test_a_delivery_joins_its_gallery_when_processing_finishes(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)

    _run(asset_id)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready
    assert [i.media_asset_id for i in _items(db_session, gallery.id)] == [asset_id]


def test_a_photo_that_named_no_gallery_joins_none(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro)

    _run(asset_id)

    assert _items(db_session, gallery.id) == []
    assert db_session.execute(select(ProofGalleryItem).where(ProofGalleryItem.media_asset_id == asset_id)).first() is None


def test_deliveries_go_after_the_photos_already_there_in_the_order_they_finish(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    earlier = _photo(db_session, store, pro, status=MediaStatus.ready)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=earlier, sort_order=7))
    db_session.commit()
    ids = [_photo(db_session, store, pro, gallery_id=gallery.id) for _ in range(3)]

    for asset_id in ids:
        _run(asset_id)

    items = _items(db_session, gallery.id)
    assert [i.media_asset_id for i in items] == [earlier, *ids]
    assert [i.sort_order for i in items] == [7, 8, 9, 10]


@pytest.mark.parametrize("status", [ProofGalleryStatus.selection_submitted, ProofGalleryStatus.delivered])
def test_a_gallery_closed_since_the_upload_began_gets_nothing(db_session, store, status):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro, status=status)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)

    _run(asset_id)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready, "still processed"
    assert _items(db_session, gallery.id) == []


def test_a_published_gallery_still_takes_photos_as_the_apps_attach_allows(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro, status=ProofGalleryStatus.published)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)

    _run(asset_id)

    assert [i.media_asset_id for i in _items(db_session, gallery.id)] == [asset_id]


@pytest.mark.parametrize("gig_status", [GigStatus.cancelled_by_client, GigStatus.refunded, GigStatus.completed])
def test_a_booking_that_can_no_longer_take_photos_gets_nothing(db_session, store, gig_status):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro, gig_status=gig_status)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)

    _run(asset_id)

    assert _items(db_session, gallery.id) == []


def test_a_photo_that_failed_never_joins(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id, checksum="0" * 64)

    _run(asset_id)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.failed
    assert _items(db_session, gallery.id) == []


def test_a_photo_that_fails_after_its_preview_never_joins(db_session, store, monkeypatch):
    # The watermark preview is made and committed first; a later failure on
    # the last retry must not leave it in the client's gallery.
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)
    real = tasks._upload_all

    def fail(*_a, **_k):
        raise ConnectionError("R2 unreachable")

    monkeypatch.setattr(tasks, "_upload_all", fail)
    _run(asset_id, retries=tasks.process_photo_variants.max_retries)
    monkeypatch.setattr(tasks, "_upload_all", real)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.failed
    assert _items(db_session, gallery.id) == []


def test_another_photographers_gallery_never_gets_the_photo(db_session, store):
    gallery = _gallery(db_session, uuid.uuid4())
    asset_id = _photo(db_session, store, uuid.uuid4(), gallery_id=gallery.id)

    _run(asset_id)

    assert _items(db_session, gallery.id) == []


def test_already_attached_by_the_app_it_is_not_added_twice(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset_id, sort_order=1))
    db_session.commit()

    _run(asset_id)

    assert len(_items(db_session, gallery.id)) == 1


def test_the_apps_attach_after_the_server_is_a_quiet_no_op(client, db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)
    _run(asset_id)

    response = client.post(
        f"/v1/proof-galleries/{gallery.id}/items",
        headers={"X-User-Id": str(pro)},
        json={"media_asset_ids": [str(asset_id)]},
    )

    assert response.status_code == 200, response.text
    assert len(_items(db_session, gallery.id)) == 1


def test_a_problem_attaching_never_costs_the_photo_its_processing(db_session, store, monkeypatch):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    asset_id = _photo(db_session, store, pro, gallery_id=gallery.id)

    def broken(db, asset):
        raise RuntimeError("lock timeout")

    monkeypatch.setattr(tasks, "attach_delivered_proof", broken)
    _run(asset_id)

    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.ready
    assert _items(db_session, gallery.id) == []


def test_the_app_and_the_server_lock_the_gallery_before_choosing_a_place():
    # Both pick "after the last photo"; without the lock two attaches at once
    # take the same place, or both add the same photo and one of them fails.
    import inspect

    from app.api.v1 import proof_galleries
    from app.services import gallery_items

    assert "lock_gallery(db, gallery_id)" in inspect.getsource(proof_galleries.add_gallery_items)
    assert "with_for_update()" in inspect.getsource(gallery_items.lock_gallery)
    assert "lock_gallery(db, asset.delivery_gallery_id)" in inspect.getsource(gallery_items.attach_delivered_proof)
