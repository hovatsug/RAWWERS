"""Delivered photos are in the order they were exported, not the order they finish.

Owner's decision 3 (2026-11-01): the plugin sends each photo's export
position and the server sorts by it; the phone keeps its selection order.
Processing finishes in any order (three uploads at once, sizes differ, a
retry comes back a day later), so the place is chosen when the photo joins
the gallery: before the first delivered photo with a later position, else
after everything already there. Photos added from the phone keep the places
they were given.

Storage and the broker are fakes: no network in tests.
"""
import uuid

import pytest
from sqlalchemy import select

from app.models.gallery import ProofGalleryItem
from app.models.media import MediaAsset, MediaStatus
from app.services.gallery_items import DELIVERY_POSITION_KEY
from tests.test_delivery_gigs import SHA, _gig, _h, _pro, _start, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)
from tests.test_server_attach import _gallery, _items, _photo, _run, store  # noqa: F401  (fixture)


def _delivery(db_session, store, pro, gallery_id, position):
    asset_id = _photo(db_session, store, pro, gallery_id=gallery_id)
    if position is not None:
        asset = db_session.get(MediaAsset, asset_id)
        asset.meta = {**(asset.meta or {}), DELIVERY_POSITION_KEY: position}
        db_session.commit()
    return asset_id


def _order(db_session, gallery_id):
    return [i.media_asset_id for i in _items(db_session, gallery_id)]


def test_photos_finishing_out_of_order_land_in_export_order(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    by_position = {p: _delivery(db_session, store, pro, gallery.id, p) for p in (1, 2, 3, 4)}

    for p in (3, 1, 4, 2):
        _run(by_position[p])

    assert _order(db_session, gallery.id) == [by_position[p] for p in (1, 2, 3, 4)]


def test_a_photo_retried_later_goes_back_into_its_place(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    by_position = {p: _delivery(db_session, store, pro, gallery.id, p) for p in (1, 2, 3, 4, 5)}
    for p in (1, 2, 4, 5):
        _run(by_position[p])

    _run(by_position[3])

    assert _order(db_session, gallery.id) == [by_position[p] for p in (1, 2, 3, 4, 5)]
    assert [i.sort_order for i in _items(db_session, gallery.id)] == [1, 2, 3, 4, 5]


def test_photos_added_from_the_phone_keep_their_places(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    phone_first = _photo(db_session, store, pro, status=MediaStatus.ready)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=phone_first, sort_order=1))
    db_session.commit()
    second, fourth = (_delivery(db_session, store, pro, gallery.id, p) for p in (2, 4))
    _run(second)
    _run(fourth)
    phone_later = _photo(db_session, store, pro, status=MediaStatus.ready)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=phone_later, sort_order=4))
    db_session.commit()

    third = _delivery(db_session, store, pro, gallery.id, 3)
    _run(third)

    # The phone's photos stay in the order they were added; the delivery
    # slots in among the other deliveries.
    assert _order(db_session, gallery.id) == [phone_first, second, third, fourth, phone_later]


def test_a_position_after_every_delivery_goes_after_everything(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    first = _delivery(db_session, store, pro, gallery.id, 1)
    _run(first)
    phone = _photo(db_session, store, pro, status=MediaStatus.ready)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=phone, sort_order=2))
    db_session.commit()

    last = _delivery(db_session, store, pro, gallery.id, 9)
    _run(last)

    assert _order(db_session, gallery.id) == [first, phone, last]


def test_the_same_position_twice_keeps_the_order_they_arrived(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    a, b = (_delivery(db_session, store, pro, gallery.id, 2) for _ in range(2))
    one = _delivery(db_session, store, pro, gallery.id, 1)

    for asset_id in (a, b, one):
        _run(asset_id)

    assert _order(db_session, gallery.id) == [one, a, b]


def test_a_delivery_without_a_position_goes_last(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    unplaced = _delivery(db_session, store, pro, gallery.id, None)
    placed = _delivery(db_session, store, pro, gallery.id, 5)

    _run(unplaced)
    _run(placed)

    assert _order(db_session, gallery.id) == [unplaced, placed]


# --- the plugin's route ------------------------------------------------------------------


def test_the_export_position_is_kept_with_the_upload(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    started = client.post(
        f"/v1/delivery/gigs/{gig.id}/uploads",
        headers=_h(token),
        json={"file_name": "IMG_0007.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000, "sha256": SHA, "position": 7},
    )

    assert started.status_code == 200, started.text
    db_session.expire_all()
    asset = db_session.get(MediaAsset, uuid.UUID(started.json()["media_asset_id"]))
    assert asset.meta[DELIVERY_POSITION_KEY] == 7


def test_an_upload_without_a_position_still_starts(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    started = _start(client, token, gig.id)

    assert started.status_code == 200, started.text
    db_session.expire_all()
    assert DELIVERY_POSITION_KEY not in db_session.get(MediaAsset, uuid.UUID(started.json()["media_asset_id"])).meta


@pytest.mark.parametrize("position", [0, -1, 1_000_001, "first"])
def test_a_position_that_is_not_a_place_is_refused(client, db_session, position):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    started = client.post(
        f"/v1/delivery/gigs/{gig.id}/uploads",
        headers=_h(token),
        json={"file_name": "IMG_0007.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000, "sha256": SHA, "position": position},
    )

    assert started.status_code == 422


@pytest.mark.parametrize("arrived", [True, False], ids=["in the gallery", "still uploading"])
def test_a_file_already_there_keeps_its_first_position(client, db_session, arrived):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    body = {"file_name": "IMG_0007.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000, "sha256": SHA}
    first = client.post(f"/v1/delivery/gigs/{gig.id}/uploads", headers=_h(token), json={**body, "position": 3}).json()
    if arrived:
        db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"])).status = MediaStatus.ready
        db_session.commit()

    again = client.post(f"/v1/delivery/gigs/{gig.id}/uploads", headers=_h(token), json={**body, "position": 40}).json()

    assert again["media_asset_id"] == first["media_asset_id"] and again["duplicate"] is arrived
    db_session.expire_all()
    asset = db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"]))
    assert asset.meta[DELIVERY_POSITION_KEY] == 3
    assert db_session.execute(select(MediaAsset.id).where(MediaAsset.checksum == SHA)).all() == [(asset.id,)]
