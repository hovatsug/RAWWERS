"""The "Meet the photographer" video (BETA_SCOPE #37, MUST 2026-11-21).

Run against the development fake Mux (services/mux_fake.py): the same routes,
the same outbox and the same webhook handler as with real Mux. What real Mux
alone can show is a post-deploy check (DEPLOY_CHECKLIST).
"""
import base64
import hashlib
import hmac
import json
import time
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

import jwt
import pytest
from sqlalchemy import select

from app.api.v1.webhooks import _apply_mux_event
from app.core.config import get_settings
from app.models.admin import AdminAuditLog, UserRoleType
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.media import MediaAsset, MediaPurpose, MediaStatus
from app.services import mux_fake, rate_limit
from app.services import presentation_video as pv
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from tests.test_client_launch import _enable_city_and_flags, _seed_pro, _seed_user

SAMPLE = (Path(__file__).resolve().parents[1] / "app" / "dev_assets" / "fake_mux_sample.mp4").read_bytes()


@pytest.fixture(autouse=True)
def fake_mux(monkeypatch):
    settings = get_settings()
    monkeypatch.setattr(settings, "mux_fake", True)
    monkeypatch.setattr(settings, "presentation_video_enabled", True)
    monkeypatch.setattr(mux_fake, "PROCESSING_SECONDS", 0)
    monkeypatch.setattr("app.tasks.outbox_tasks.dispatch_outbox_events_task.delay", lambda *a, **k: None, raising=False)
    for name in ("presentation_video", "public_read", "auth_mutation"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))


def _city():
    return f"Videotown {uuid.uuid4().hex[:8]}"


def _pro(db, city=None):
    pro = str(uuid.uuid4())
    _seed_pro(db, pro, city=city or _city(), country="PT")
    db.commit()
    return uuid.UUID(pro)


def _h(user):
    return {"X-User-Id": str(user)}


def _start(client, pro, *, request_id=None, byte_size=len(SAMPLE), seconds=4.0, content_type="video/mp4"):
    return client.post("/v1/pro/me/presentation-video/uploads", headers=_h(pro), json={
        "byte_size": byte_size, "duration_seconds": seconds, "content_type": content_type,
        "request_id": request_id or uuid.uuid4().hex})


def _put(client, upload_url, body=SAMPLE):
    path = "/" + upload_url.split("/", 3)[3]
    return client.put(path, content=body, headers={"content-type": "video/mp4"})


def _settle():
    dispatch_outbox_events_task(limit=500)


def _upload_ready(client, db, pro, **kw) -> uuid.UUID:
    started = _start(client, pro, **kw)
    assert started.status_code == 200, started.text
    assert _put(client, started.json()["upload_url"]).status_code == 200
    assert client.post(f"/v1/pro/me/presentation-video/{started.json()['media_asset_id']}/uploaded", headers=_h(pro)).status_code == 200
    db.commit()
    _settle()
    db.expire_all()
    return uuid.UUID(started.json()["media_asset_id"])


def _state(client, pro):
    answer = client.get("/v1/pro/me/presentation-video", headers=_h(pro))
    assert answer.status_code == 200, answer.text
    return answer.json()


def _viewer(db):
    viewer = str(uuid.uuid4())
    _seed_user(db, viewer, [UserRoleType.client])
    db.commit()
    return viewer


def _profile_video(client, db, pro, city):
    _enable_city_and_flags(db, city=city, country="PT")
    answer = client.get(f"/v1/client/pros/{pro}", params={"country": "PT", "city": city}, headers={"X-User-Id": _viewer(db)})
    assert answer.status_code == 200, answer.text
    meet = answer.json().get("meet")
    return (meet or {}).get("video")


def _play(client, db, pro):
    return client.post(f"/v1/client/pros/{pro}/presentation-video/playback", headers={"X-User-Id": _viewer(db)})


def _fake_asset(video: MediaAsset) -> dict | None:
    return mux_fake._load("asset", video.provider_asset_id)


# --- the whole flow ---------------------------------------------------------------------------


def test_upload_processing_ready_and_a_client_plays_it(client, db_session):
    city = _city()
    pro = _pro(db_session, city)
    started = _start(client, pro)
    assert started.status_code == 200, started.text
    assert _state(client, pro)["pending"]["status"] == "uploading"
    assert _put(client, started.json()["upload_url"]).status_code == 200
    client.post(f"/v1/pro/me/presentation-video/{started.json()['media_asset_id']}/uploaded", headers=_h(pro))
    assert _state(client, pro)["pending"]["status"] == "processing"
    assert _profile_video(client, db_session, pro, city) is None, "shown while not ready"
    _settle()
    state = _state(client, pro)
    assert state["shown"]["status"] == "ready" and state["shown"]["duration_seconds"] == 4 and state["pending"] is None
    video = _profile_video(client, db_session, pro, city)
    assert video and video["poster_url"] and video["duration_seconds"] == 4
    played = _play(client, db_session, pro)
    assert played.status_code == 200, played.text
    assert played.json()["expires_in"] == 300
    clip = client.get("/" + played.json()["playback_url"].split("/", 3)[3])
    assert clip.status_code == 200 and clip.content[4:8] == b"ftyp"
    ranged = client.get("/" + played.json()["playback_url"].split("/", 3)[3], headers={"range": "bytes=0-99"})
    assert ranged.status_code == 206 and len(ranged.content) == 100, "iOS plays a video in byte ranges"


# --- ownership, live, ready ---------------------------------------------------------------------


def test_another_photographers_video_cannot_be_touched(client, db_session):
    owner, other = _pro(db_session), _pro(db_session)
    video_id = _upload_ready(client, db_session, owner)
    for answer in (client.post(f"/v1/pro/me/presentation-video/{video_id}/uploaded", headers=_h(other)),
                   client.delete(f"/v1/pro/me/presentation-video/{video_id}", headers=_h(other))):
        assert answer.status_code == 404, answer.text
    db_session.expire_all()
    assert db_session.get(MediaAsset, video_id).status == MediaStatus.ready


def test_a_client_cannot_start_an_upload(client, db_session):
    assert _start(client, uuid.UUID(_viewer(db_session))).status_code == 403


@pytest.mark.parametrize("how", ["not_approved", "banned"])
def test_a_photographer_who_is_not_live_shows_no_video(client, db_session, how):
    city = _city()
    pro = _pro(db_session, city)
    _upload_ready(client, db_session, pro)
    if how == "not_approved":
        db_session.get(ProOnboarding, pro).status = ProOnboardingStatus.ready_for_review
    else:
        from app.models.admin import BanAction, BanActionType

        db_session.add(BanAction(user_id=pro, action=BanActionType.banned, reason="test", actor_user_id=uuid.uuid4()))
    db_session.commit()
    assert pv.client_video(db_session, pro) is None
    assert _play(client, db_session, pro).status_code == 404


def test_a_video_still_processing_is_never_shown_or_played(client, db_session):
    city = _city()
    pro = _pro(db_session, city)
    started = _start(client, pro)
    client.post(f"/v1/pro/me/presentation-video/{started.json()['media_asset_id']}/uploaded", headers=_h(pro))
    assert _profile_video(client, db_session, pro, city) is None
    assert _play(client, db_session, pro).status_code == 404


# --- events -------------------------------------------------------------------------------------


def _sign(body: bytes) -> str:
    ts = int(time.time())
    sig = hmac.new(b"test-webhook-secret", f"{ts}.{body.decode()}".encode(), hashlib.sha256).hexdigest()
    return f"t={ts},v1={sig}"


def _pending_video(db, pro) -> MediaAsset:
    db.expire_all()
    return pv.pending_video(db, pro)


def test_a_repeated_webhook_is_applied_once(client, db_session):
    pro = _pro(db_session)
    _start(client, pro)
    video = _pending_video(db_session, pro)
    event = {"id": f"evt_{uuid.uuid4().hex}", "type": "video.asset.ready", "data": {
        "id": "as_rep", "upload_id": video.provider_upload_id, "duration": 10.0, "passthrough": str(video.id),
        "playback_ids": [{"id": "pb_public", "policy": "public"}, {"id": "pb_signed", "policy": "signed"}]}}
    body = json.dumps(event).encode()
    for _ in range(2):
        assert client.post("/v1/webhooks/mux", content=body, headers={"content-type": "application/json", "mux-signature": _sign(body)}).status_code == 200
    from app.models.outbox import OutboxEvent

    assert db_session.query(OutboxEvent).filter(OutboxEvent.payload["id"].astext == event["id"]).count() == 1
    _settle()
    db_session.expire_all()
    db_session.refresh(video)
    assert video.status == MediaStatus.ready
    assert video.meta["playback_id"] == "pb_signed", "the public playback id was kept"


def test_events_out_of_order_still_end_ready(db_session, client):
    pro = _pro(db_session)
    _start(client, pro)
    video = _pending_video(db_session, pro)
    ready = {"id": "as_ooo", "upload_id": video.provider_upload_id, "duration": 5,
             "playback_ids": [{"id": "pb_ooo", "policy": "signed"}], "passthrough": str(video.id)}
    _apply_mux_event(db_session, "video.asset.ready", ready)
    _apply_mux_event(db_session, "video.upload.asset_created", {"id": video.provider_upload_id, "asset_id": "as_ooo"})
    _apply_mux_event(db_session, "video.asset.errored", {"id": "as_ooo", "errors": {"type": "late"}})
    db_session.commit()
    db_session.refresh(video)
    assert video.status == MediaStatus.ready and video.provider_asset_id == "as_ooo"


def test_a_forged_webhook_signature_is_refused(client, db_session):
    pro = _pro(db_session)
    _start(client, pro)
    video = _pending_video(db_session, pro)
    body = json.dumps({"id": f"evt_{uuid.uuid4().hex}", "type": "video.asset.ready",
                       "data": {"id": "as_forged", "upload_id": video.provider_upload_id, "playback_ids": [{"id": "x", "policy": "signed"}]}}).encode()
    ts = int(time.time())
    forged = f"t={ts},v1=" + hmac.new(b"not-the-secret", f"{ts}.{body.decode()}".encode(), hashlib.sha256).hexdigest()
    assert client.post("/v1/webhooks/mux", content=body, headers={"content-type": "application/json", "mux-signature": forged}).status_code == 401
    _settle()
    db_session.refresh(video)
    assert video.status != MediaStatus.ready


def test_an_asset_deleted_at_mux_disappears(client, db_session):
    city = _city()
    pro = _pro(db_session, city)
    video_id = _upload_ready(client, db_session, pro)
    video = db_session.get(MediaAsset, video_id)
    _apply_mux_event(db_session, "video.asset.deleted", {"id": video.provider_asset_id})
    db_session.commit()
    assert _profile_video(client, db_session, pro, city) is None


# --- one at a time, limits ---------------------------------------------------------------------


def test_a_new_video_replaces_the_shown_one_only_once_ready(client, db_session):
    city = _city()
    pro = _pro(db_session, city)
    first = _upload_ready(client, db_session, pro)
    started = _start(client, pro)
    assert _state(client, pro)["shown"]["media_asset_id"] == str(first), "the old one stays while the new one uploads"
    _put(client, started.json()["upload_url"])
    _settle()
    db_session.expire_all()
    ready = db_session.execute(select(MediaAsset).where(
        MediaAsset.owner_user_id == pro, MediaAsset.purpose == MediaPurpose.presentation_video, MediaAsset.status == MediaStatus.ready)).scalars().all()
    assert [v.id for v in ready] == [uuid.UUID(started.json()["media_asset_id"])], "a second active video"
    old = db_session.get(MediaAsset, first)
    assert old.status == MediaStatus.deleted and _fake_asset(old)["status"] == "deleted", "the replaced video's Mux asset is left"


def test_starting_a_new_upload_retires_the_one_in_progress(client, db_session):
    pro = _pro(db_session)
    a, b = _start(client, pro), _start(client, pro)
    db_session.expire_all()
    assert db_session.get(MediaAsset, uuid.UUID(a.json()["media_asset_id"])).status == MediaStatus.deleted
    assert db_session.get(MediaAsset, uuid.UUID(b.json()["media_asset_id"])).status == MediaStatus.uploading


@pytest.mark.parametrize(("kw", "code"), [
    ({"seconds": 75}, "video_too_long"),
    ({"byte_size": pv.MAX_BYTES + 1}, "video_too_large"),
    # 100 MB, to save mobile data (owner, 2026-11-21): 150 MB is refused.
    ({"byte_size": 150_000_000}, "video_too_large"),
    ({"content_type": "video/x-msvideo"}, "validation_error"),
])
def test_limits_are_enforced_on_the_server(client, db_session, kw, code):
    answer = _start(client, _pro(db_session), **kw)
    assert answer.status_code == 422 and answer.json()["error"]["code"] == code
    assert answer.json()["error"]["message"]


def test_a_video_mux_measures_over_60_seconds_is_refused_and_deleted_at_mux(client, db_session, monkeypatch):
    monkeypatch.setattr(mux_fake, "mp4_duration_seconds", lambda _b: 75.0)
    city = _city()
    pro = _pro(db_session, city)
    video_id = _upload_ready(client, db_session, pro, seconds=None)
    video = db_session.get(MediaAsset, video_id)
    assert video.status == MediaStatus.failed
    assert _fake_asset(video)["status"] == "deleted"
    assert "longer than 60 seconds" in _state(client, pro)["pending"]["message"]
    assert _profile_video(client, db_session, pro, city) is None


def test_a_file_that_is_not_a_video_fails_with_what_to_do(client, db_session):
    pro = _pro(db_session)
    started = _start(client, pro)
    _put(client, started.json()["upload_url"], body=b"not a video at all")
    _settle()
    state = _state(client, pro)
    assert state["pending"]["status"] == "failed" and "Try another one" in state["pending"]["message"]
    assert _upload_ready(client, db_session, pro), "a failed video is replaced by uploading again"


# --- recovery -----------------------------------------------------------------------------------


def test_a_retried_start_returns_the_same_upload_never_a_second(client, db_session):
    pro = _pro(db_session)
    a = _start(client, pro, request_id="retry-1234")
    b = _start(client, pro, request_id="retry-1234")
    assert a.json() == b.json()
    count = db_session.execute(select(MediaAsset).where(MediaAsset.owner_user_id == pro,
                                                        MediaAsset.purpose == MediaPurpose.presentation_video)).scalars().all()
    assert len(count) == 1
    vid = a.json()["media_asset_id"]
    for _ in range(2):
        assert client.post(f"/v1/pro/me/presentation-video/{vid}/uploaded", headers=_h(pro)).status_code == 200
    assert _put(client, a.json()["upload_url"]).status_code == 200
    assert _put(client, a.json()["upload_url"]).status_code == 200, "sending the file twice is the same success"


def test_a_stuck_upload_whose_webhook_was_lost_is_recovered_by_mux_sync(client, db_session, monkeypatch):
    from app.services import mux_sync

    pro = _pro(db_session)
    started = _start(client, pro)
    # The file arrives, but the events never do.
    monkeypatch.setattr(mux_fake, "send_events", lambda *a, **k: None)
    _put(client, started.json()["upload_url"])
    video = db_session.get(MediaAsset, uuid.UUID(started.json()["media_asset_id"]))
    old = datetime.now(timezone.utc) - timedelta(minutes=get_settings().mux_sync_stale_minutes + 1)
    db_session.execute(MediaAsset.__table__.update().where(MediaAsset.id == video.id).values(updated_at=old))
    db_session.commit()
    mux_sync.sync_waiting_videos(db_session)
    db_session.commit()
    mux_sync.sync_waiting_videos(db_session)
    db_session.commit()
    db_session.refresh(video)
    assert video.status == MediaStatus.ready


# --- deletion -----------------------------------------------------------------------------------


def test_deleting_the_video_deletes_the_mux_asset(client, db_session):
    city = _city()
    pro = _pro(db_session, city)
    video_id = _upload_ready(client, db_session, pro)
    assert client.delete(f"/v1/pro/me/presentation-video/{video_id}", headers=_h(pro)).status_code == 200
    assert client.delete(f"/v1/pro/me/presentation-video/{video_id}", headers=_h(pro)).status_code == 200, "deleting twice is the same success"
    video = db_session.get(MediaAsset, video_id)
    db_session.refresh(video)
    assert video.status == MediaStatus.deleted and _fake_asset(video)["status"] == "deleted"
    assert _profile_video(client, db_session, pro, city) is None


def test_a_failed_mux_deletion_hides_the_video_at_once_and_is_retried(client, db_session):
    city = _city()
    pro = _pro(db_session, city)
    video_id = _upload_ready(client, db_session, pro)
    mux_fake.fake_fail_next_delete(True)
    assert client.delete(f"/v1/pro/me/presentation-video/{video_id}", headers=_h(pro)).status_code == 200
    video = db_session.get(MediaAsset, video_id)
    db_session.refresh(video)
    assert _profile_video(client, db_session, pro, city) is None, "still shown while Mux keeps it"
    assert video.meta[pv.MUX_DELETE_PENDING] is True and _fake_asset(video)["status"] == "ready"
    assert pv.retry_pending_deletions(db_session) >= 1
    db_session.commit()
    db_session.refresh(video)
    assert video.meta[pv.MUX_DELETE_PENDING] is False and _fake_asset(video)["status"] == "deleted"


def test_a_video_deleted_before_its_mux_events_arrived_has_its_asset_deleted(client, db_session, monkeypatch):
    pro = _pro(db_session)
    started = _start(client, pro)
    vid = started.json()["media_asset_id"]
    # The file reached Mux, and the photographer deleted the video before
    # Mux's events arrived: the asset Mux made must not be left behind.
    monkeypatch.setattr(mux_fake, "send_events", lambda *a, **k: None)
    _put(client, started.json()["upload_url"])
    client.delete(f"/v1/pro/me/presentation-video/{vid}", headers=_h(pro))
    video = db_session.get(MediaAsset, uuid.UUID(vid))
    db_session.refresh(video)
    assert video.status == MediaStatus.deleted and _fake_asset(video)["status"] == "deleted"


def test_an_admin_removes_any_photographers_video(client, db_session):
    from tests.test_studioverse_v1 import ADMIN_ID, _seed_user as seed_admin

    city = _city()
    pro = _pro(db_session, city)
    _upload_ready(client, db_session, pro)
    seed_admin(db_session, ADMIN_ID, [UserRoleType.admin])
    answer = client.delete(f"/v1/admin/pros/{pro}/presentation-video", headers={"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""})
    assert answer.status_code == 200 and answer.json()["removed"] == 1
    assert _profile_video(client, db_session, pro, city) is None
    assert db_session.query(AdminAuditLog).filter_by(action="presentation_video_removed", target_id=str(pro)).count() == 1


def test_removing_a_photographer_removes_their_videos_and_mux_assets(client, db_session):
    pro = _pro(db_session)
    video_id = _upload_ready(client, db_session, pro)
    assert pv.remove_all_for(db_session, pro, reason="account deleted") == 1
    db_session.commit()
    video = db_session.get(MediaAsset, video_id)
    assert video.status == MediaStatus.deleted and _fake_asset(video)["status"] == "deleted"


# --- limits on use ------------------------------------------------------------------------------


def test_starting_uploads_is_rate_limited(client, db_session, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "presentation_video", (1, 3600))
    pro = _pro(db_session)
    assert _start(client, pro).status_code == 200
    assert _start(client, pro).status_code == 429


def test_playback_tokens_expire(monkeypatch):
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric import rsa

    from app.services import security

    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    pem = key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption())
    monkeypatch.setattr(security.settings, "mux_signing_key_private", base64.b64encode(pem).decode(), raising=False)
    monkeypatch.setattr(security.settings, "mux_signing_key_id", "kid-1", raising=False)
    token = security.create_mux_playback_token("pb_1", expires_in_seconds=pv.PLAYBACK_TTL_SECONDS)
    claims = jwt.decode(token, key.public_key(), algorithms=["RS256"], audience="v")
    assert claims["sub"] == "pb_1" and claims["exp"] <= int(time.time()) + 300 and jwt.get_unverified_header(token)["kid"] == "kid-1"
    # The fake's links stop working when their token expires.
    expired = mux_fake.fake_token("pb_1", "v", -1)
    assert mux_fake.fake_token_ok(expired, "pb_1", "v") is False
    assert mux_fake.fake_token_ok(mux_fake.fake_token("pb_1", "v", 300), "pb_1", "v") is True


def test_the_playback_url_caps_resolution_at_720p_inside_its_token(monkeypatch):
    """Owner, 2026-11-21: clients get 720p at most, a setting. Mux reads the
    cap from a signed playback id's token only; the URL carries the token
    and nothing else. Posters carry no playback cap."""
    from urllib.parse import parse_qs, urlsplit

    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric import rsa

    from app.core.config import Settings
    from app.services import mux, security

    assert Settings.model_fields["mux_playback_max_resolution"].default == "720p"
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    pem = key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8, serialization.NoEncryption())
    monkeypatch.setattr(security.settings, "mux_signing_key_private", pem.decode(), raising=False)
    monkeypatch.setattr(security.settings, "mux_signing_key_id", "kid-1", raising=False)
    monkeypatch.setattr(security.settings, "mux_playback_max_resolution", "720p", raising=False)

    def claims_of(url, audience):
        query = parse_qs(urlsplit(url).query)
        assert set(query) == {"token"}, url
        return jwt.decode(query["token"][0], key.public_key(), algorithms=["RS256"], audience=audience)

    assert claims_of(mux.MuxClient().playback_url("pb_1", expires_in=300), "v")["max_resolution"] == "720p"
    assert "max_resolution" not in claims_of(mux.MuxClient().poster_url("pb_1", expires_in=300), "t")
    # A setting: changed without code.
    monkeypatch.setattr(security.settings, "mux_playback_max_resolution", "480p", raising=False)
    assert claims_of(mux.MuxClient().playback_url("pb_1", expires_in=300), "v")["max_resolution"] == "480p"
    # Only Mux's own values are accepted.
    with pytest.raises(ValueError):
        Settings(_env_file=None, MUX_PLAYBACK_MAX_RESOLUTION="900p")


def test_the_real_mux_upload_asks_for_signed_basic_1080p(monkeypatch):
    from app.services import mux

    sent = {}

    class Answer:
        status_code = 201

        def json(self):
            return {"data": {"id": "up", "url": "https://storage.example/up"}}

    monkeypatch.setattr(mux.requests, "post", lambda url, auth, json, timeout: sent.update(json) or Answer())
    mux.MuxClient().create_direct_upload(passthrough="our-id")
    assert sent["new_asset_settings"] == {"playback_policies": ["signed"], "video_quality": "basic",
                                          "max_resolution_tier": "1080p", "passthrough": "our-id"}
    assert sent["cors_origin"] == "*" and sent["timeout"] == 3600


# --- the fake stays in development; no Mux means a plain answer ---------------------------------


@pytest.mark.parametrize("env", ["production", "prod", "staging"])
def test_the_fake_cannot_be_on_outside_development(client, monkeypatch, env):
    from app.services.mux import MuxClient, get_mux_client

    monkeypatch.setattr(get_settings(), "app_env", env)
    assert mux_fake.fake_mux_allowed() is False
    assert isinstance(get_mux_client(), MuxClient)


def test_the_fake_routes_answer_404_when_the_fake_is_off(client, monkeypatch):
    monkeypatch.setattr(get_settings(), "mux_fake", False)
    assert client.get("/v1/dev/fake-mux/status").status_code == 404
    assert client.put("/v1/dev/fake-mux/uploads/x", content=b"x").status_code == 404


@pytest.fixture
def no_mux(monkeypatch):
    settings = get_settings()
    monkeypatch.setattr(settings, "mux_fake", False)
    for name in ("mux_token_id", "mux_token_secret", "mux_signing_key_id", "mux_signing_key_private"):
        monkeypatch.setattr(settings, name, "")


def test_with_no_mux_everything_answers_in_plain_words(client, db_session, no_mux):
    city = _city()
    pro = _pro(db_session, city)
    state = _state(client, pro)
    assert state["available"] is False and state["message"] == "Video is not available right now."
    started = _start(client, pro)
    assert started.status_code == 503 and started.json()["error"]["message"] == "Video is not available right now."
    assert _profile_video(client, db_session, pro, city) is None
    assert _play(client, db_session, pro).status_code == 503
    generic = client.post("/v1/media/videos/mux/uploads", headers=_h(pro), json={"purpose": "portfolio_reel"})
    assert generic.status_code == 503 and "not available" in generic.json()["error"]["message"]
    from app.services import mux_sync

    assert mux_sync.sync_waiting_videos(db_session).checked == 0


def test_with_the_switch_off_it_is_not_available(client, db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "presentation_video_enabled", False)
    assert _state(client, _pro(db_session))["available"] is False


def test_an_asset_created_event_for_a_deleted_video_deletes_that_asset(client, db_session):
    pro = _pro(db_session)
    _start(client, pro)
    video = _pending_video(db_session, pro)
    video.status = MediaStatus.deleted
    db_session.commit()
    mux_fake._save("asset", "as_late", {"id": "as_late", "status": "ready"})
    _apply_mux_event(db_session, "video.upload.asset_created", {"id": video.provider_upload_id, "asset_id": "as_late"})
    db_session.commit()
    assert mux_fake._load("asset", "as_late")["status"] == "deleted"
    assert video.meta[pv.MUX_DELETE_PENDING] is False
