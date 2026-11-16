"""Publishing to the portfolio again is safe (plug-in 1.2.3, docs/LIGHTROOM_PORTFOLIO.md section 8).

The owner's case of 2026-11-16: two photos published at once; finishing one
deadlocked while recomputing the niche skills, after the photo had already
been committed as processing. The plug-in retried the finish and got
"Photo upload cannot be completed from current state", so Lightroom kept the
photo as new; publishing again rendered it again, Lightroom wrote a new
export time into the file, the SHA-256 differed, and the server made a
second photo.

Now: the plug-in sends a key per Lightroom photo and collection and a hash
of the picture without its metadata; the server answers a photo it has with
that photo; finishing is one transaction and finishing again is a success.
"""
import hashlib
import uuid

import pytest
from sqlalchemy import select
from sqlalchemy.exc import OperationalError

from app.api.v1 import pro_onboarding
from app.models.media import MediaAsset, MediaStatus
from app.services import discovery_index, rate_limit
from tests.test_delivery_gigs import _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)
from tests.test_lightroom_portfolio import _niches, two_niches  # noqa: F401  (fixture)

V = "1.2.3"
# The same picture rendered twice: the file's hash differs (Lightroom writes
# the export time into it), the picture's does not.
RENDER_1 = hashlib.sha256(b"InaFoto-21 exported 03:36:22").hexdigest()
RENDER_2 = hashlib.sha256(b"InaFoto-21 exported 03:40:23").hexdigest()
PICTURE = hashlib.sha256(b"InaFoto-21 pixels").hexdigest()
EDITED = hashlib.sha256(b"InaFoto-21 pixels, exposure +1").hexdigest()
KEY = "lr:5F0C2A9E-PHOTO-UUID:collection-77"


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("uploads", "auth_mutation", "delivery_token_daily", "plugin_portfolio_uploads"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


def _h(token, version=V):
    return {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": version}


def _setup(client, db_session, niches):
    pro = _pro(db_session)
    _niches(db_session, pro, niches[0], niches[1], primary=niches[0])
    return pro, _token(client, pro)


def _start(client, token, slug, *, sha=RENDER_1, picture=PICTURE, key=KEY, version=V):
    body = {"file_name": "InaFoto-21.jpg", "content_type": "image/jpeg", "byte_size": 505_866, "sha256": sha, "niche_slug": slug}
    if picture:
        body["image_sha256"] = picture
    if key:
        body["publish_key"] = key
    return client.post("/v1/delivery/portfolio/uploads", headers=_h(token, version), json=body)


def _finish(client, token, asset_id, *, sha=RENDER_1):
    return client.post(f"/v1/delivery/uploads/{asset_id}/complete", headers=_h(token), json={"byte_size": 505_866, "sha256": sha})


def _photos(db_session, pro):
    db_session.expire_all()
    return db_session.execute(
        select(MediaAsset).where(MediaAsset.owner_user_id == pro, MediaAsset.status.not_in([MediaStatus.failed, MediaStatus.deleted]))
    ).scalars().all()


def _deadlock_once(monkeypatch):
    """The next recompute of the public index fails as the deadlock did."""
    calls = {"n": 0}
    real = discovery_index.recompute_pro_public_index

    def flaky(db, pro_user_id):
        calls["n"] += 1
        if calls["n"] == 1:
            raise OperationalError("UPDATE pro_niche_skill ...", {}, Exception("deadlock detected"))
        return real(db, pro_user_id)

    monkeypatch.setattr(discovery_index, "recompute_pro_public_index", flaky)
    monkeypatch.setattr(pro_onboarding, "recompute_pro_public_index", flaky, raising=False)
    return calls


# --- the owner's case --------------------------------------------------------------------------


def test_the_owners_case_a_failed_finish_then_publishing_again_leaves_one_photo(client, db_session, two_niches, monkeypatch):
    pro, token = _setup(client, db_session, two_niches)
    started = _start(client, token, two_niches[0]).json()
    asset_id = started["media_asset_id"]

    _deadlock_once(monkeypatch)
    try:
        failed = _finish(client, token, asset_id)
        assert failed.status_code >= 500
    except OperationalError:
        pass
    db_session.rollback()  # the request's session ends

    # The plug-in retries the finish: a success, never "current state".
    retried = _finish(client, token, asset_id)
    assert retried.status_code == 200, retried.text
    assert "current state" not in retried.text

    # Publishing again renders the photo again: a new file hash, the same picture.
    again = _start(client, token, two_niches[0], sha=RENDER_2).json()
    assert (again["media_asset_id"], again["duplicate"]) == (asset_id, True)
    photos = _photos(db_session, pro)
    assert [p.id for p in photos] == [uuid.UUID(asset_id)]
    assert photos[0].niche_tags == [two_niches[0]]


def test_a_failed_finish_leaves_the_photo_waiting_not_half_done(client, db_session, two_niches, monkeypatch):
    """Processing and the niche tag are one change: never processing without its niche."""
    pro, token = _setup(client, db_session, two_niches)
    asset_id = _start(client, token, two_niches[0]).json()["media_asset_id"]
    _deadlock_once(monkeypatch)
    try:
        _finish(client, token, asset_id)
    except OperationalError:
        pass
    db_session.rollback()
    asset = _photos(db_session, pro)[0]
    assert asset.status == MediaStatus.uploading


# --- repeated steps ----------------------------------------------------------------------------


def test_finishing_again_after_success_is_the_same_success(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    asset_id = _start(client, token, two_niches[0]).json()["media_asset_id"]
    first = _finish(client, token, asset_id)
    second = _finish(client, token, asset_id)
    assert first.status_code == second.status_code == 200, second.text
    assert first.json() == second.json() == {"ok": True, "current_status": "processing"}
    asset = _photos(db_session, pro)[0]
    asset.status = MediaStatus.ready
    db_session.commit()
    assert _finish(client, token, asset_id).json() == {"ok": True, "current_status": "ready"}


def test_finishing_a_photo_that_was_already_processing_but_untagged_tags_it(client, db_session, two_niches):
    """A photo left by the old bug (processing, no niche) is repaired when touched again."""
    pro, token = _setup(client, db_session, two_niches)
    asset_id = _start(client, token, two_niches[0]).json()["media_asset_id"]
    asset = _photos(db_session, pro)[0]
    asset.status, asset.niche_tags = MediaStatus.processing, []
    db_session.commit()
    assert _finish(client, token, asset_id).status_code == 200
    assert _photos(db_session, pro)[0].niche_tags == [two_niches[0]]
    # and so is starting it again
    asset = _photos(db_session, pro)[0]
    asset.niche_tags = []
    db_session.commit()
    assert _start(client, token, two_niches[0], sha=RENDER_2).json()["duplicate"] is True
    assert _photos(db_session, pro)[0].niche_tags == [two_niches[0]]


def test_a_removed_or_failed_photo_is_refused_in_plain_words(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    asset_id = _start(client, token, two_niches[0]).json()["media_asset_id"]
    asset = _photos(db_session, pro)[0]
    asset.status = MediaStatus.failed
    db_session.commit()
    refused = _finish(client, token, asset_id)
    assert refused.status_code == 409
    message = refused.json()["error"]["message"]
    assert "current state" not in message and "Publish it again" in message


# --- publishing again ----------------------------------------------------------------------------


def test_a_photo_still_processing_is_answered_with_itself(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    _finish(client, token, first["media_asset_id"])
    again = _start(client, token, two_niches[0], sha=RENDER_2).json()
    assert (again["media_asset_id"], again["duplicate"], again["upload"]) == (first["media_asset_id"], True, None)
    assert len(_photos(db_session, pro)) == 1


def test_a_stuck_upload_is_resumed_with_the_new_render_and_finished(client, db_session, two_niches):
    """Lightroom crashed between the start and the finish; the next publish renders again."""
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    resumed = _start(client, token, two_niches[0], sha=RENDER_2).json()
    assert (resumed["media_asset_id"], resumed["duplicate"]) == (first["media_asset_id"], False)
    assert resumed["upload"]["method"] == "PUT"
    finished = _finish(client, token, resumed["media_asset_id"], sha=RENDER_2)
    assert finished.status_code == 200, finished.text
    photos = _photos(db_session, pro)
    assert len(photos) == 1 and photos[0].checksum == RENDER_2 and photos[0].status == MediaStatus.processing


def test_the_same_photo_twice_into_one_niche_is_one_photo(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    _finish(client, token, first["media_asset_id"])
    for sha in (RENDER_1, RENDER_2):
        assert _start(client, token, two_niches[0], sha=sha).json()["media_asset_id"] == first["media_asset_id"]
    assert len(_photos(db_session, pro)) == 1


def test_the_same_picture_from_another_lightroom_photo_is_still_one_photo(client, db_session, two_niches):
    """The second guard: a virtual copy, or another catalog, has another key but the same picture."""
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    _finish(client, token, first["media_asset_id"])
    other = _start(client, token, two_niches[0], sha=RENDER_2, key="lr:OTHER-PHOTO:collection-77").json()
    assert (other["media_asset_id"], other["duplicate"]) == (first["media_asset_id"], True)


def test_the_same_photo_into_two_niches_is_allowed(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    a = _start(client, token, two_niches[0]).json()
    _finish(client, token, a["media_asset_id"])
    b = _start(client, token, two_niches[1], key="lr:5F0C2A9E-PHOTO-UUID:collection-78").json()
    assert b["duplicate"] is False and b["media_asset_id"] != a["media_asset_id"]
    _finish(client, token, b["media_asset_id"])
    tags = sorted(tuple(p.niche_tags) for p in _photos(db_session, pro))
    assert tags == sorted([(two_niches[0],), (two_niches[1],)])


def test_an_edited_photo_is_a_new_photo_that_replaces_the_old_one(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    _finish(client, token, first["media_asset_id"])
    edited = _start(client, token, two_niches[0], sha=RENDER_2, picture=EDITED).json()
    assert edited["duplicate"] is False and edited["media_asset_id"] != first["media_asset_id"]
    assert edited["replaces"] == first["media_asset_id"]


def test_an_older_plugin_without_key_or_picture_hash_keeps_the_file_hash_guard(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0], key=None, picture=None, version="1.2.2").json()
    _finish(client, token, first["media_asset_id"])
    same = _start(client, token, two_niches[0], key=None, picture=None, version="1.2.2").json()
    assert (same["media_asset_id"], same["duplicate"]) == (first["media_asset_id"], True)


# --- counts ----------------------------------------------------------------------------------------


def test_the_portfolio_counts_the_photos_on_the_server_per_niche(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    a = _start(client, token, two_niches[0]).json()
    _finish(client, token, a["media_asset_id"])
    _start(client, token, two_niches[0], sha=RENDER_2)  # the same photo: not counted twice
    b = _start(client, token, two_niches[1], key="lr:x:y").json()
    _finish(client, token, b["media_asset_id"])
    c = _start(client, token, two_niches[1], key="lr:z:y", sha=EDITED, picture=EDITED).json()  # started, not finished
    body = client.get("/v1/delivery/portfolio", headers=_h(token)).json()
    assert body["niche_photo_counts"] == {two_niches[0]: 1, two_niches[1]: 1}
    assert c["duplicate"] is False


def test_a_stuck_upload_is_resumed_even_if_the_photo_was_edited_before_the_retry(client, db_session, two_niches):
    """Nothing of the stuck upload is shown anywhere: the same Lightroom photo takes it over, never a second photo."""
    pro, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    resumed = _start(client, token, two_niches[0], sha=RENDER_2, picture=EDITED).json()
    assert (resumed["media_asset_id"], resumed["duplicate"], resumed["replaces"]) == (first["media_asset_id"], False, None)
    assert _finish(client, token, resumed["media_asset_id"], sha=RENDER_2).status_code == 200
    assert len(_photos(db_session, pro)) == 1
