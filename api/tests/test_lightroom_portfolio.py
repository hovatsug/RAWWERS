"""Publishing to the portfolio from the Lightroom plug-in (docs/LIGHTROOM_PORTFOLIO.md).

The plug-in's token reaches the photographer's own portfolio through
/v1/delivery/portfolio only, with the app's limits (25 MB, JPEG, 30 uploads an
hour, 30 starts a minute) and processing; it removes only photos it
published; the routes need plug-in 1.1.0. Storage and the broker are fakes.
"""
import hashlib
import io
import uuid

import pytest
from PIL import Image
from sqlalchemy import select

import app.tasks.media_tasks as tasks
from app.models.admin import ProProfile
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, MediaVisibility, ObjectStatus
from app.models.niche import Niche, ProNiche
from app.services import rate_limit
from tests.test_delivery_gigs import _pro, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)

SHA = hashlib.sha256(b"P_0412").hexdigest()


def _h(token, version="1.1.0"):
    headers = {"Authorization": f"Bearer {token}"}
    if version:
        headers["X-Rawwers-Plugin-Version"] = version
    return headers


def _niches(db, pro, *slugs, primary=None):
    found = {n.slug: n for n in db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars()}
    for slug in slugs:
        db.add(ProNiche(pro_user_id=pro, niche_id=found[slug].id, is_primary=slug == primary))
    db.commit()


@pytest.fixture
def two_niches(db_session):
    slugs = [n.slug for n in db_session.execute(select(Niche).where(Niche.is_active.is_(True)).order_by(Niche.slug)).scalars()][:3]
    assert len(slugs) == 3
    return slugs


@pytest.fixture(autouse=True)
def generous_limits(monkeypatch):
    for name in ("uploads", "auth_mutation", "delivery_token_daily"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


def _setup(client, db_session, two_niches):
    pro = _pro(db_session)
    _niches(db_session, pro, two_niches[0], two_niches[1], primary=two_niches[1])
    return pro, _token(client, pro)


def _start(client, token, slug, *, sha=SHA, size=6_000_000, content_type="image/jpeg", version="1.1.0"):
    return client.post(
        "/v1/delivery/portfolio/uploads",
        headers=_h(token, version),
        json={"file_name": "P_0412.jpg", "content_type": content_type, "byte_size": size, "sha256": sha, "niche_slug": slug},
    )


def _finish(client, token, asset_id, *, sha=SHA):
    return client.post(f"/v1/delivery/uploads/{asset_id}/complete", headers=_h(token), json={"byte_size": 6_000_000, "sha256": sha})


# --- where photos can go ----------------------------------------------------------------------


def test_the_portfolio_lists_the_photographers_own_niches_main_first(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    body = client.get("/v1/delivery/portfolio", headers=_h(token)).json()
    assert [(n["slug"], n["primary"]) for n in body["niches"]] == [(two_niches[1], True), (two_niches[0], False)]
    assert (body["photo_count"], body["photo_minimum"]) == (0, 12)


@pytest.mark.parametrize("version", ["1.0.0", None])
def test_the_portfolio_needs_plugin_1_1_0(client, db_session, two_niches, version):
    _pro_id, token = _setup(client, db_session, two_niches)
    for answer in (
        client.get("/v1/delivery/portfolio", headers=_h(token, version)),
        _start(client, token, two_niches[0], version=version),
        client.delete(f"/v1/delivery/portfolio/{uuid.uuid4()}", headers=_h(token, version)),
    ):
        assert answer.status_code == 426, answer.text
        assert answer.json()["error"]["details"]["minimum_version"] == "1.1.0"
    # Delivery itself still works for a 1.0.0 plug-in.
    assert client.get("/v1/delivery/gigs", headers=_h(token, "1.0.0")).status_code == 200


# --- publishing ----------------------------------------------------------------------------------


def test_a_photo_is_published_public_in_the_niche_and_tagged_when_finished(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    started = _start(client, token, two_niches[0])
    assert started.status_code == 200, started.text
    body = started.json()
    assert body["duplicate"] is False and body["upload"]["method"] == "PUT" and body["use_multipart"] is False

    asset = db_session.get(MediaAsset, uuid.UUID(body["media_asset_id"]))
    assert (asset.owner_user_id, asset.purpose, asset.visibility, asset.checksum) == (pro, MediaPurpose.portfolio_reel, MediaVisibility.public, SHA)

    finished = _finish(client, token, asset.id)
    assert finished.status_code == 200, finished.text
    db_session.expire_all()
    asset = db_session.get(MediaAsset, asset.id)
    assert asset.status == MediaStatus.processing
    assert asset.niche_tags == [two_niches[0]]


def test_a_large_photo_goes_in_parts(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    body = _start(client, token, two_niches[0], size=20_000_000).json()
    assert (body["upload"], body["use_multipart"]) == (None, True)
    assert client.post(f"/v1/delivery/uploads/{body['media_asset_id']}/multipart", headers=_h(token), json={"byte_size": 20_000_000}).status_code == 200


def test_publishing_the_same_file_again_resumes_and_another_niche_is_another_photo(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    first = _start(client, token, two_niches[0]).json()
    # Not finished yet: the same photo, with a fresh address.
    resumed = _start(client, token, two_niches[0]).json()
    assert (resumed["media_asset_id"], resumed["duplicate"]) == (first["media_asset_id"], False)
    assert resumed["upload"]["url"] != first["upload"]["url"]

    _finish(client, token, first["media_asset_id"])
    again = _start(client, token, two_niches[0]).json()
    assert (again["media_asset_id"], again["duplicate"], again["upload"]) == (first["media_asset_id"], True, None)

    other = _start(client, token, two_niches[1]).json()
    assert other["media_asset_id"] != first["media_asset_id"] and other["duplicate"] is False


# --- the app's limits --------------------------------------------------------------------------


def test_the_app_size_limit_applies_25_mb(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    refused = _start(client, token, two_niches[0], size=25_000_001)
    assert refused.status_code == 422 and "larger than 25 MB" in refused.json()["error"]["message"]
    assert _start(client, token, two_niches[0], size=25_000_000).status_code == 200


def test_only_jpeg_is_taken(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    assert _start(client, token, two_niches[0], content_type="image/png").status_code == 422


def test_a_niche_that_is_not_the_photographers_is_refused(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    refused = _start(client, token, two_niches[2])
    assert refused.status_code == 422 and "not one of yours" in refused.json()["error"]["message"]
    assert db_session.execute(select(MediaAsset)).scalars().all() == []


def test_the_plugin_publishes_100_an_hour_the_app_keeps_its_30(monkeypatch):
    """The owner's decision of 2026-11-15: the plug-in's portfolio publish
    has its own 100 an hour; the app's 30 and the device's daily bucket stay."""
    from app.core.config import Settings

    defaults = {name: field.default for name, field in Settings.model_fields.items()}
    assert defaults["rate_limit_plugin_portfolio_uploads_per_hour"] == 100
    assert defaults["rate_limit_uploads_per_hour"] == 30
    assert defaults["rate_limit_delivery_token_uploads_per_day"] == 5000
    # each bucket reads its own setting, by the hour or the day: the rules as
    # built, without this file's generous_limits (and the settings they were
    # built from: other tests clear get_settings' cache)
    monkeypatch.undo()
    settings = rate_limit.settings
    assert rate_limit.RATE_LIMIT_RULES["plugin_portfolio_uploads"] == (settings.rate_limit_plugin_portfolio_uploads_per_hour, 3600)
    assert rate_limit.RATE_LIMIT_RULES["uploads"] == (settings.rate_limit_uploads_per_hour, 3600)
    assert rate_limit.RATE_LIMIT_RULES["delivery_token_daily"] == (settings.rate_limit_delivery_token_uploads_per_day, 86400)


def test_the_plugins_hourly_limit_applies_and_not_the_apps(client, db_session, two_niches, monkeypatch):
    _pro_id, token = _setup(client, db_session, two_niches)
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (1, 3600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "plugin_portfolio_uploads", (3, 3600))
    for sha in ("a", "b", "c"):  # past the app's 1
        assert _start(client, token, two_niches[0], sha=sha * 64).status_code == 200
    fourth = _start(client, token, two_niches[0], sha="d" * 64)
    assert fourth.status_code == 429
    assert fourth.json()["error"]["details"]["bucket"].startswith("plugin_portfolio_uploads:")


def _app_upload(client, pro_id):
    return client.post(
        "/v1/media/photos/uploads",
        headers={"X-User-Id": str(pro_id)},
        json={"purpose": "portfolio_reel", "content_type": "image/jpeg", "file_name": "phone.jpg"},
    )


def test_the_apps_limit_is_unchanged_by_a_plugin_publish(client, db_session, two_niches, monkeypatch):
    pro_id, token = _setup(client, db_session, two_niches)
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (2, 3600))
    for sha in ("a", "b", "c"):  # the plug-in uses none of the app's 2
        assert _start(client, token, two_niches[0], sha=sha * 64).status_code == 200
    assert _app_upload(client, pro_id).status_code == 200
    assert _app_upload(client, pro_id).status_code == 200
    third = _app_upload(client, pro_id)
    assert third.status_code == 429
    assert third.json()["error"]["details"]["bucket"].startswith("uploads:")


def test_the_plugins_retries_and_parts_use_its_bucket_not_the_apps(client, db_session, two_niches, monkeypatch):
    _pro_id, token = _setup(client, db_session, two_niches)
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "uploads", (0, 3600))
    small = _start(client, token, two_niches[0], sha="a" * 64).json()
    assert client.post(f"/v1/delivery/uploads/{small['media_asset_id']}/url", headers=_h(token)).status_code == 200
    large = _start(client, token, two_niches[0], sha="b" * 64, size=20_000_000).json()
    parts = client.post(f"/v1/delivery/uploads/{large['media_asset_id']}/multipart", headers=_h(token), json={"byte_size": 20_000_000})
    assert parts.status_code == 200

    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "plugin_portfolio_uploads", (0, 3600))
    assert client.post(f"/v1/delivery/uploads/{small['media_asset_id']}/url", headers=_h(token)).status_code == 429


def test_the_devices_daily_bucket_applies_too(client, db_session, two_niches, monkeypatch):
    """It still stops a runaway publish, under the plug-in's hourly 100."""
    _pro_id, token = _setup(client, db_session, two_niches)
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_token_daily", (1, 86400))
    assert _start(client, token, two_niches[0], sha="a" * 64).status_code == 200
    assert _start(client, token, two_niches[0], sha="b" * 64).status_code == 429


def test_the_finish_must_name_the_hash_declared_at_the_start(client, db_session, two_niches):
    _pro_id, token = _setup(client, db_session, two_niches)
    body = _start(client, token, two_niches[0]).json()
    assert _finish(client, token, body["media_asset_id"], sha="f" * 64).status_code == 409


@pytest.fixture
def store(monkeypatch):
    objects: dict[str, bytes] = {}
    monkeypatch.setattr(tasks, "download_object_bytes", lambda key, max_bytes=0: objects[key])
    monkeypatch.setattr(tasks, "object_size", lambda key: len(objects[key]) if key in objects else None)
    monkeypatch.setattr(tasks, "upload_object_bytes", lambda key, payload, *_a, **_k: objects.__setitem__(key, payload))
    monkeypatch.setattr(tasks, "_watermark_text", lambda db, asset: "RAWWERS • Test")
    return objects


def _process(db_session, store, client, token, slug, data: bytes, *, last_try=False):
    sha = hashlib.sha256(data).hexdigest()
    body = _start(client, token, slug, sha=sha, size=len(data)).json()
    original = db_session.execute(
        select(MediaObject).where(MediaObject.media_asset_id == uuid.UUID(body["media_asset_id"]), MediaObject.variant == MediaVariant.original)
    ).scalar_one()
    store[original.storage_key] = data
    assert client.post(f"/v1/delivery/uploads/{body['media_asset_id']}/complete", headers=_h(token), json={"byte_size": len(data), "sha256": sha}).status_code == 200
    # A file that cannot be read is retried; on the last try it fails for good.
    tasks.process_photo_variants.push_request(retries=tasks.process_photo_variants.max_retries if last_try else 0)
    try:
        tasks.process_photo_variants.run(body["media_asset_id"])
    finally:
        tasks.process_photo_variants.pop_request()
    db_session.expire_all()
    return db_session.get(MediaAsset, uuid.UUID(body["media_asset_id"]))


def _jpeg(exif_gps: bool = False) -> bytes:
    image = Image.new("RGB", (800, 600), (90, 120, 150))
    buf = io.BytesIO()
    if exif_gps:
        exif = Image.Exif()
        exif[0x8825] = {1: "N", 2: (38.0, 42.0, 0.0)}  # GPSInfo
        image.save(buf, "JPEG", quality=80, exif=exif)
    else:
        image.save(buf, "JPEG", quality=80)
    return buf.getvalue()


def test_a_good_photo_is_processed_and_its_served_copies_carry_no_location(client, db_session, two_niches, store):
    _pro_id, token = _setup(client, db_session, two_niches)
    asset = _process(db_session, store, client, token, two_niches[0], _jpeg(exif_gps=True))
    assert asset.status == MediaStatus.ready
    served = db_session.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant != MediaVariant.original)
    ).scalars().all()
    assert served
    for obj in served:
        assert not Image.open(io.BytesIO(store[obj.storage_key])).getexif().get(0x8825)


def test_a_file_that_is_not_an_image_is_refused(client, db_session, two_niches, store):
    _pro_id, token = _setup(client, db_session, two_niches)
    asset = _process(db_session, store, client, token, two_niches[0], b"not a jpeg at all" * 100, last_try=True)
    assert asset.status == MediaStatus.failed


# --- removing ------------------------------------------------------------------------------------


def _published(client, db_session, token, slug, sha=SHA):
    body = _start(client, token, slug, sha=sha).json()
    asset = db_session.get(MediaAsset, uuid.UUID(body["media_asset_id"]))
    asset.status = MediaStatus.ready
    db_session.commit()
    return asset.id


def test_a_published_photo_is_removed_from_the_portfolio(client, db_session, two_niches, monkeypatch):
    deleted = []
    monkeypatch.setattr("app.services.storage.delete_object", deleted.append)
    pro, token = _setup(client, db_session, two_niches)
    asset_id = _published(client, db_session, token, two_niches[0])
    profile = db_session.get(ProProfile, pro)
    profile.cover_media_asset_id = asset_id
    db_session.commit()

    answer = client.delete(f"/v1/delivery/portfolio/{asset_id}", headers=_h(token))
    assert answer.status_code == 200, answer.text
    db_session.expire_all()
    assert db_session.get(MediaAsset, asset_id).status == MediaStatus.deleted
    assert db_session.get(ProProfile, pro).cover_media_asset_id is None
    assert deleted, "the stored files were left"
    listed = client.get("/v1/pro/me/portfolio", headers={"X-User-Id": str(pro)}).json()["items"]
    assert str(asset_id) not in [i["media_asset_id"] for i in listed]
    # Again: already gone, nothing changes.
    assert client.delete(f"/v1/delivery/portfolio/{asset_id}", headers=_h(token)).status_code == 200


def test_a_photo_added_in_the_app_cannot_be_removed_with_the_token(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    app_photo = MediaAsset(owner_user_id=pro, kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel, provider="r2",
                           status=MediaStatus.ready, visibility=MediaVisibility.public, content_type="image/jpeg", meta={})
    db_session.add(app_photo)
    db_session.commit()
    assert client.delete(f"/v1/delivery/portfolio/{app_photo.id}", headers=_h(token)).status_code == 404
    db_session.expire_all()
    assert db_session.get(MediaAsset, app_photo.id).status == MediaStatus.ready


def test_another_photographers_photo_cannot_be_removed(client, db_session, two_niches):
    _other, other_token = _setup(client, db_session, two_niches)
    theirs = _published(client, db_session, other_token, two_niches[0])
    _me, token = _setup(client, db_session, two_niches)
    assert client.delete(f"/v1/delivery/portfolio/{theirs}", headers=_h(token)).status_code == 404
    db_session.expire_all()
    assert db_session.get(MediaAsset, theirs).status == MediaStatus.ready


def test_another_photographers_upload_cannot_be_finished_or_resent(client, db_session, two_niches):
    _other, other_token = _setup(client, db_session, two_niches)
    theirs = _start(client, other_token, two_niches[0]).json()["media_asset_id"]
    _me, token = _setup(client, db_session, two_niches)
    assert _finish(client, token, theirs).status_code == 404
    assert client.post(f"/v1/delivery/uploads/{theirs}/url", headers=_h(token)).status_code == 404


# --- the token's reach ---------------------------------------------------------------------------


def test_the_token_does_not_open_the_apps_portfolio_routes(client, db_session, two_niches):
    pro, token = _setup(client, db_session, two_niches)
    asset_id = _published(client, db_session, token, two_niches[0])
    for method, path in (
        ("GET", "/v1/pro/me/portfolio"),
        ("POST", f"/v1/pro/me/portfolio/{asset_id}/niches"),
        ("POST", "/v1/media/photos/uploads"),
    ):
        answer = client.request(method, path, headers=_h(token), json={"niche_slugs": [two_niches[1]]})
        assert answer.status_code == 401, (method, path, answer.status_code)


def test_the_portfolio_routes_take_only_the_token(client, db_session, two_niches):
    pro, _token_value = _setup(client, db_session, two_niches)
    assert client.get("/v1/delivery/portfolio", headers={"X-User-Id": str(pro), "X-Rawwers-Plugin-Version": "1.1.0"}).status_code == 401
