"""Each Lightroom export follows the one before it, as a block.

Owner's decision (2026-11-01): a later export goes after the earlier ones,
and an export keeps its own order. Positions restart at 1 in every export,
so position alone mixed a second export in among the first. The plug-in now
names its export (`export_id`); the server numbers the gallery's exports in
the order they first arrive, and a photo's place is (export number,
position). A photo from a plug-in that names no export (1.0.0) counts as
export 0: before any numbered export, ordered by position as before.

Storage and the broker are fakes: no network in tests.
"""
import uuid

import pytest

from app.models.gallery import ProofGalleryItem
from app.models.media import MediaAsset, MediaStatus
from app.services.gallery_items import DELIVERY_EXPORT_NUMBER_KEY, DELIVERY_POSITION_KEY
from tests.test_delivery_gigs import SHA, _gig, _h, _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)
from tests.test_server_attach import _gallery, _items, _photo, _run, store  # noqa: F401  (fixture)


def _delivery(db_session, store, pro, gallery_id, export, position):
    asset_id = _photo(db_session, store, pro, gallery_id=gallery_id)
    asset = db_session.get(MediaAsset, asset_id)
    meta = {**(asset.meta or {}), DELIVERY_POSITION_KEY: position}
    if export is not None:
        meta[DELIVERY_EXPORT_NUMBER_KEY] = export
    asset.meta = meta
    db_session.commit()
    return asset_id


def _order(db_session, gallery_id):
    return [i.media_asset_id for i in _items(db_session, gallery_id)]


def test_a_second_export_goes_after_the_first_whatever_order_they_finish(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    first = {p: _delivery(db_session, store, pro, gallery.id, 1, p) for p in (1, 2, 3)}
    second = {p: _delivery(db_session, store, pro, gallery.id, 2, p) for p in (1, 2)}

    for asset_id in (second[2], first[3], second[1], first[1], first[2]):
        _run(asset_id)

    assert _order(db_session, gallery.id) == [first[1], first[2], first[3], second[1], second[2]]


def test_a_photo_of_the_first_export_retried_later_goes_back_into_its_block(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    first = {p: _delivery(db_session, store, pro, gallery.id, 1, p) for p in (1, 2, 3)}
    second = {p: _delivery(db_session, store, pro, gallery.id, 2, p) for p in (1, 2)}
    for asset_id in (first[1], first[3], second[1], second[2]):
        _run(asset_id)

    _run(first[2])

    assert _order(db_session, gallery.id) == [first[1], first[2], first[3], second[1], second[2]]
    assert [i.sort_order for i in _items(db_session, gallery.id)] == [1, 2, 3, 4, 5]


def test_a_photo_from_a_plugin_that_names_no_export_comes_before_numbered_exports(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    numbered = _delivery(db_session, store, pro, gallery.id, 1, 1)
    unnamed = _delivery(db_session, store, pro, gallery.id, None, 5)
    _run(numbered)

    _run(unnamed)

    assert _order(db_session, gallery.id) == [unnamed, numbered]


def test_photos_added_from_the_phone_keep_their_places_between_exports(db_session, store):
    pro = uuid.uuid4()
    gallery = _gallery(db_session, pro)
    a1 = _delivery(db_session, store, pro, gallery.id, 1, 1)
    _run(a1)
    phone = _photo(db_session, store, pro, status=MediaStatus.ready)
    db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=phone, sort_order=2))
    db_session.commit()
    b1 = _delivery(db_session, store, pro, gallery.id, 2, 1)
    _run(b1)

    a2 = _delivery(db_session, store, pro, gallery.id, 1, 2)
    _run(a2)

    # a2 goes before the second export; the phone's photo is not moved.
    assert _order(db_session, gallery.id) == [a1, phone, a2, b1]


# --- the plugin's route ------------------------------------------------------------------


def _start(client, token, gig_id, *, export_id, position, sha=None):
    body = {"file_name": f"IMG_{position}.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000,
            "sha256": sha or uuid.uuid4().hex * 2, "position": position}
    if export_id is not None:
        body["export_id"] = export_id
    resp = client.post(f"/v1/delivery/gigs/{gig_id}/uploads", headers=_h(token), json=body)
    assert resp.status_code == 200, resp.text
    return resp.json()


def _meta(db_session, started):
    db_session.expire_all()
    return db_session.get(MediaAsset, uuid.UUID(started["media_asset_id"])).meta


def test_exports_are_numbered_in_the_order_they_first_arrive(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    a1 = _start(client, token, gig.id, export_id="export-a", position=1)
    b1 = _start(client, token, gig.id, export_id="export-b", position=1)
    a2 = _start(client, token, gig.id, export_id="export-a", position=2)
    c1 = _start(client, token, gig.id, export_id="export-c", position=1)

    assert [_meta(db_session, s)[DELIVERY_EXPORT_NUMBER_KEY] for s in (a1, b1, a2, c1)] == [1, 2, 1, 3]


def test_each_gallery_numbers_its_own_exports(client, db_session):
    pro = _pro(db_session)
    token = _token(client, pro)
    one, two = _gig(db_session, pro), _gig(db_session, pro)

    _start(client, token, one.id, export_id="export-a", position=1)
    first_in_two = _start(client, token, two.id, export_id="export-b", position=1)

    assert _meta(db_session, first_in_two)[DELIVERY_EXPORT_NUMBER_KEY] == 1


def test_a_file_sent_again_in_a_later_export_keeps_its_first_place(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    first = _start(client, token, gig.id, export_id="export-a", position=3, sha=SHA)
    _start(client, token, gig.id, export_id="export-b", position=1)

    again = _start(client, token, gig.id, export_id="export-b", position=9, sha=SHA)

    assert again["media_asset_id"] == first["media_asset_id"]
    meta = _meta(db_session, again)
    assert (meta[DELIVERY_EXPORT_NUMBER_KEY], meta[DELIVERY_POSITION_KEY]) == (1, 3)


def test_an_upload_naming_no_export_gets_no_number(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)

    started = _start(client, token, gig.id, export_id=None, position=4)

    meta = _meta(db_session, started)
    assert meta[DELIVERY_POSITION_KEY] == 4 and DELIVERY_EXPORT_NUMBER_KEY not in meta


@pytest.mark.parametrize("export_id", ["", "x" * 65, "has space", "a/b", 7])
def test_an_export_name_that_is_not_a_plain_name_is_refused(client, db_session, export_id):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    resp = client.post(
        f"/v1/delivery/gigs/{gig.id}/uploads",
        headers=_h(token),
        json={"file_name": "IMG_1.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000, "sha256": SHA,
              "position": 1, "export_id": export_id},
    )
    assert resp.status_code == 422
