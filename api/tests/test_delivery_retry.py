"""An interrupted "Export To: RAWWERS" run again never doubles the client's gallery (plug-in 1.2.4).

Lightroom renders every photo again on each export and writes the export
time into the file, so the file's SHA-256 - the only guard before 1.2.4 -
differs each time: an export interrupted and run again put the photos
already sent in the gallery a second time. The existing tests sent the very
same hash twice, which no real second export does.

Now the plug-in sends a key per Lightroom photo and gig, and the hash of
the picture without its metadata; the same photo in another gig stays
allowed; finishing or joining parts again is the same success; a stuck
upload is resumed with the new render.
"""
import hashlib
import uuid

import pytest
from sqlalchemy import select

from app.models.gallery import ProofGallery
from app.models.media import MediaAsset, MediaObject, MediaStatus, MediaVariant
from app.services import rate_limit
from tests.test_delivery_gigs import _gig, _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)

V = "1.2.4"
RENDER_1 = hashlib.sha256(b"IMG_0412 exported 10:00:01").hexdigest()
RENDER_2 = hashlib.sha256(b"IMG_0412 exported 10:07:45").hexdigest()
PICTURE = hashlib.sha256(b"IMG_0412 pixels").hexdigest()
EDITED = hashlib.sha256(b"IMG_0412 pixels, warmer").hexdigest()


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("uploads", "delivery_uploads", "delivery_token_daily"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


def _h(token):
    return {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": V}


def _key(gig_id, photo="UUID-IMG_0412"):
    return f"lr:{photo}:gig:{gig_id}"


def _start(client, token, gig_id, *, sha=RENDER_1, picture=PICTURE, key="default", size=6_000_000, position=1):
    body = {"file_name": "IMG_0412.jpg", "content_type": "image/jpeg", "byte_size": size, "sha256": sha, "position": position}
    if picture:
        body["image_sha256"] = picture
    if key:
        body["delivery_key"] = _key(gig_id) if key == "default" else key
    return client.post(f"/v1/delivery/gigs/{gig_id}/uploads", headers=_h(token), json=body)


def _finish(client, token, asset_id, *, sha=RENDER_1):
    return client.post(f"/v1/delivery/uploads/{asset_id}/complete", headers=_h(token), json={"byte_size": 6_000_000, "sha256": sha})


def _setup(client, db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    return pro, gig, _token(client, pro)


def _live(db_session, gallery_id):
    db_session.expire_all()
    return db_session.execute(
        select(MediaAsset).where(MediaAsset.delivery_gallery_id == uuid.UUID(str(gallery_id)), MediaAsset.status.not_in([MediaStatus.failed, MediaStatus.deleted]))
    ).scalars().all()


# --- the bug, reproduced ----------------------------------------------------------------------------


def test_an_interrupted_export_run_again_puts_each_photo_in_the_gallery_once(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    # First export: photo 1 finished, photo 2 started and interrupted.
    one = _start(client, token, gig.id).json()
    _finish(client, token, one["media_asset_id"])
    two = _start(client, token, gig.id, sha=hashlib.sha256(b"IMG_0413 a").hexdigest(),
                 picture=hashlib.sha256(b"IMG_0413 pixels").hexdigest(), key=_key(gig.id, "UUID-IMG_0413"), position=2).json()
    # The export run again: both rendered again, new file hashes, same pictures.
    again_one = _start(client, token, gig.id, sha=RENDER_2).json()
    again_two = _start(client, token, gig.id, sha=hashlib.sha256(b"IMG_0413 b").hexdigest(),
                       picture=hashlib.sha256(b"IMG_0413 pixels").hexdigest(), key=_key(gig.id, "UUID-IMG_0413"), position=2).json()
    assert (again_one["media_asset_id"], again_one["duplicate"]) == (one["media_asset_id"], True)
    assert (again_two["media_asset_id"], again_two["duplicate"]) == (two["media_asset_id"], False)
    assert again_two["upload"]["method"] == "PUT"
    assert _finish(client, token, again_two["media_asset_id"], sha=hashlib.sha256(b"IMG_0413 b").hexdigest()).status_code == 200
    assert len(_live(db_session, one["gallery_id"])) == 2


# --- repeated steps -------------------------------------------------------------------------------


def test_finishing_a_delivery_photo_again_is_the_same_success(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    started = _start(client, token, gig.id).json()
    first = _finish(client, token, started["media_asset_id"])
    second = _finish(client, token, started["media_asset_id"])
    assert first.status_code == second.status_code == 200
    assert first.json()["current_status"] == second.json()["current_status"] == "processing"
    assert "current state" not in second.text


def test_joining_the_parts_again_once_joined_is_the_same_success(client, db_session, monkeypatch):
    _pro_id, gig, token = _setup(client, db_session)
    started = _start(client, token, gig.id, size=20_000_000).json()
    asset_id = started["media_asset_id"]
    assert client.post(f"/v1/delivery/uploads/{asset_id}/multipart", headers=_h(token), json={"byte_size": 20_000_000}).status_code == 200
    # Storage joined the parts; the answer was lost.
    asset = db_session.get(MediaAsset, uuid.UUID(asset_id))
    asset.meta = {k: v for k, v in asset.meta.items() if k != "multipart"}
    db_session.commit()
    monkeypatch.setattr("app.api.v1.delivery.object_size", lambda key: 20_000_000)
    again = client.post(f"/v1/delivery/uploads/{asset_id}/multipart/complete", headers=_h(token))
    assert again.status_code == 200, again.text


# --- stuck uploads ----------------------------------------------------------------------------------


def test_a_stuck_upload_is_resumed_with_the_new_render(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    first = _start(client, token, gig.id).json()
    resumed = _start(client, token, gig.id, sha=RENDER_2).json()
    assert (resumed["media_asset_id"], resumed["duplicate"]) == (first["media_asset_id"], False)
    assert _finish(client, token, resumed["media_asset_id"], sha=RENDER_2).status_code == 200
    (only,) = _live(db_session, first["gallery_id"])
    assert only.checksum == RENDER_2


def test_a_stuck_upload_in_parts_drops_the_old_renders_parts(client, db_session, monkeypatch):
    aborted = []
    monkeypatch.setattr("app.services.storage.abort_multipart_upload", lambda key, upload_id: aborted.append(upload_id))
    _pro_id, gig, token = _setup(client, db_session)
    first = _start(client, token, gig.id, size=20_000_000).json()
    client.post(f"/v1/delivery/uploads/{first['media_asset_id']}/multipart", headers=_h(token), json={"byte_size": 20_000_000})
    resumed = _start(client, token, gig.id, sha=RENDER_2, size=20_000_000).json()
    assert resumed["media_asset_id"] == first["media_asset_id"] and resumed["use_multipart"] is True
    assert len(aborted) == 1
    asset = db_session.get(MediaAsset, uuid.UUID(first["media_asset_id"]))
    db_session.refresh(asset)
    assert "multipart" not in asset.meta and asset.checksum == RENDER_2


# --- what is and is not the same photo --------------------------------------------------------------


def test_the_same_photo_in_two_gigs_is_allowed(client, db_session):
    pro, gig, token = _setup(client, db_session)
    other = _gig(db_session, pro)
    a = _start(client, token, gig.id).json()
    _finish(client, token, a["media_asset_id"])
    b = _start(client, token, other.id).json()
    assert b["duplicate"] is False and b["media_asset_id"] != a["media_asset_id"] and b["gallery_id"] != a["gallery_id"]


def test_the_same_picture_from_another_lightroom_photo_in_one_gig_is_one_photo(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    a = _start(client, token, gig.id).json()
    _finish(client, token, a["media_asset_id"])
    b = _start(client, token, gig.id, sha=RENDER_2, key=_key(gig.id, "UUID-VIRTUAL-COPY")).json()
    assert (b["media_asset_id"], b["duplicate"]) == (a["media_asset_id"], True)


def test_an_edited_photo_exported_again_is_added_and_nothing_is_removed(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    a = _start(client, token, gig.id).json()
    _finish(client, token, a["media_asset_id"])
    b = _start(client, token, gig.id, sha=RENDER_2, picture=EDITED).json()
    assert b["duplicate"] is False and b["media_asset_id"] != a["media_asset_id"]
    _finish(client, token, b["media_asset_id"], sha=RENDER_2)
    assert len(_live(db_session, a["gallery_id"])) == 2


def test_an_older_plugin_keeps_the_file_hash_guard(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    a = _start(client, token, gig.id, picture=None, key=None).json()
    _finish(client, token, a["media_asset_id"])
    b = _start(client, token, gig.id, picture=None, key=None).json()
    assert (b["media_asset_id"], b["duplicate"]) == (a["media_asset_id"], True)


# --- counts ----------------------------------------------------------------------------------------


def test_the_gallery_status_counts_each_photo_once(client, db_session):
    _pro_id, gig, token = _setup(client, db_session)
    a = _start(client, token, gig.id).json()
    _finish(client, token, a["media_asset_id"])
    _start(client, token, gig.id, sha=RENDER_2)  # the same photo again
    status = client.get(f"/v1/delivery/galleries/{a['gallery_id']}/status", headers=_h(token)).json()
    assert (status["processing"], status["uploading"], status["photos_in_gallery"]) == (1, 0, 0)
