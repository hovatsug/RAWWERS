import hashlib
import hmac
import json
import time
import uuid

from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.services.security import verify_mux_webhook_signature


def _mux_signature(secret: str, body: bytes, timestamp: int | None = None) -> str:
    ts = timestamp or int(time.time())
    msg = f"{ts}.{body.decode('utf-8')}".encode("utf-8")
    sig = hmac.new(secret.encode("utf-8"), msg, hashlib.sha256).hexdigest()
    return f"t={ts},v1={sig}"


def test_signature_wrapper_invalid_returns_false():
    payload = b'{"hello":"world"}'
    assert verify_mux_webhook_signature(payload, "t=123,v1=bad") is False


def test_webhook_idempotency(client, db_session):
    asset = MediaAsset(
        owner_user_id=uuid.uuid4(),
        kind=MediaKind.video,
        purpose=MediaPurpose.video_review,
        provider=MediaProvider.mux,
        provider_upload_id="upload_1",
        provider_asset_id="asset_1",
        status=MediaStatus.uploading,
        visibility=MediaVisibility.owner_only,
        meta={},
    )
    db_session.add(asset)
    db_session.commit()

    event = {
        "id": "evt_123",
        "type": "video.asset.ready",
        "data": {"id": "asset_1", "playback_ids": [{"id": "play_abc"}]},
    }
    body = json.dumps(event).encode("utf-8")
    signature = _mux_signature("test-webhook-secret", body)

    first = client.post(
        "/v1/webhooks/mux",
        data=body,
        headers={"content-type": "application/json", "mux-signature": signature},
    )
    assert first.status_code == 200

    second = client.post(
        "/v1/webhooks/mux",
        data=body,
        headers={"content-type": "application/json", "mux-signature": signature},
    )
    assert second.status_code == 200

    # A repeat delivery (Mux retries for 24 hours) is recorded once: one
    # outbox event, keyed by Mux's event id. (This asserted a WebhookEvent
    # row, which this route no longer writes, and failed (KNOWN_FAILURES).)
    from app.models.outbox import IdempotencyKey, OutboxEvent

    assert db_session.query(OutboxEvent).filter(OutboxEvent.topic == "mux.event").count() == 1
    assert db_session.query(IdempotencyKey).filter_by(key="mux:evt_123").count() == 1

    # The worker applies it.
    from app.tasks.outbox_tasks import dispatch_outbox_events_task

    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()
    db_session.refresh(asset)
    assert asset.status == MediaStatus.ready
    assert asset.meta.get("playback_id") == "play_abc"


def test_webhook_invalid_signature_returns_401(client):
    payload = {"id": "evt_invalid", "type": "video.asset.ready", "data": {"id": "asset_1"}}
    resp = client.post(
        "/v1/webhooks/mux",
        json=payload,
        headers={"mux-signature": "t=111,v1=bad"},
    )
    assert resp.status_code == 401


# --- The four events, out-of-order delivery, and the quick answer ------------

from app.api.v1.webhooks import HANDLED_MUX_EVENTS, _apply_mux_event  # noqa: E402
from app.models.outbox import OutboxEvent  # noqa: E402


def _video(db, *, upload_id=None, asset_id=None, status=MediaStatus.uploading):
    asset = MediaAsset(
        owner_user_id=uuid.uuid4(), kind=MediaKind.video, purpose=MediaPurpose.video_review, provider=MediaProvider.mux,
        provider_upload_id=upload_id or f"up_{uuid.uuid4().hex[:8]}", provider_asset_id=asset_id,
        status=status, visibility=MediaVisibility.owner_only, meta={},
    )
    db.add(asset)
    db.commit()
    return asset


def test_the_four_events_mux_sends_are_handled():
    assert {"video.upload.asset_created", "video.asset.ready", "video.asset.errored", "video.upload.errored"} <= HANDLED_MUX_EVENTS


def test_asset_created_links_the_asset_and_marks_it_processing(db_session):
    v = _video(db_session)
    _apply_mux_event(db_session, "video.upload.asset_created", {"id": v.provider_upload_id, "asset_id": "as_1"})
    db_session.commit()
    db_session.refresh(v)
    assert v.status == MediaStatus.processing
    assert v.provider_asset_id == "as_1"


def test_ready_before_asset_created_finds_the_video_by_its_upload(db_session):
    v = _video(db_session)
    ready = {"id": "as_2", "upload_id": v.provider_upload_id, "playback_ids": [{"id": "pb_2"}]}
    _apply_mux_event(db_session, "video.asset.ready", ready)
    db_session.commit()
    db_session.refresh(v)
    assert (v.status, v.provider_asset_id, v.meta.get("playback_id")) == (MediaStatus.ready, "as_2", "pb_2")
    # The late asset_created links what is already linked and leaves it ready.
    _apply_mux_event(db_session, "video.upload.asset_created", {"id": v.provider_upload_id, "asset_id": "as_2"})
    db_session.commit()
    db_session.refresh(v)
    assert v.status == MediaStatus.ready


def test_an_upload_that_errored_or_was_cancelled_fails_the_video(db_session):
    errored, cancelled = _video(db_session), _video(db_session)
    _apply_mux_event(db_session, "video.upload.errored", {"id": errored.provider_upload_id, "error": {"type": "invalid_input", "message": "Not a video"}})
    _apply_mux_event(db_session, "video.upload.cancelled", {"id": cancelled.provider_upload_id})
    db_session.commit()
    db_session.refresh(errored)
    db_session.refresh(cancelled)
    assert errored.status == MediaStatus.failed and errored.meta["mux_error"] == "Not a video"
    assert cancelled.status == MediaStatus.failed and cancelled.meta["mux_error"] == "Upload cancelled"


def test_an_asset_that_errored_fails_and_a_repeat_changes_nothing(db_session):
    v = _video(db_session, asset_id="as_3", status=MediaStatus.processing)
    event = {"id": "as_3", "errors": {"type": "invalid_input", "messages": ["bad codec"]}}
    _apply_mux_event(db_session, "video.asset.errored", event)
    db_session.commit()
    db_session.refresh(v)
    first = (v.status, dict(v.meta))
    _apply_mux_event(db_session, "video.asset.errored", event)
    db_session.commit()
    db_session.refresh(v)
    assert v.status == MediaStatus.failed
    assert (v.status, dict(v.meta)) == first


def test_a_ready_video_is_never_failed_by_a_late_upload_event(db_session):
    v = _video(db_session, asset_id="as_4", status=MediaStatus.ready)
    _apply_mux_event(db_session, "video.upload.errored", {"id": v.provider_upload_id})
    _apply_mux_event(db_session, "video.asset.errored", {"id": "as_4"})
    db_session.commit()
    db_session.refresh(v)
    assert v.status == MediaStatus.ready


def test_the_webhook_answers_at_once_and_leaves_the_work_to_the_worker(client, db_session, monkeypatch):
    queued = []
    monkeypatch.setattr("app.api.v1.webhooks.dispatch_outbox_events_task.delay", lambda *a, **k: queued.append(1))
    v = _video(db_session, asset_id="as_5", status=MediaStatus.processing)
    body = json.dumps({"id": "evt_quick", "type": "video.asset.ready", "data": {"id": "as_5", "playback_ids": [{"id": "pb_5"}]}}).encode()
    resp = client.post("/v1/webhooks/mux", data=body, headers={"content-type": "application/json", "mux-signature": _mux_signature("test-webhook-secret", body)})
    assert resp.status_code == 200
    assert queued == [1]
    db_session.expire_all()
    assert db_session.get(MediaAsset, v.id).status == MediaStatus.processing  # not applied in the request
    assert db_session.query(OutboxEvent).filter(OutboxEvent.topic == "mux.event").count() == 1


def test_an_old_signature_or_no_secret_is_refused(client, monkeypatch):
    body = json.dumps({"id": "evt_old", "type": "video.asset.ready", "data": {"id": "x"}}).encode()
    old = _mux_signature("test-webhook-secret", body, timestamp=int(time.time()) - 3600)
    assert client.post("/v1/webhooks/mux", data=body, headers={"content-type": "application/json", "mux-signature": old}).status_code == 401
    monkeypatch.setattr("app.services.security.settings.mux_webhook_secret", "")
    fresh = _mux_signature("test-webhook-secret", body)
    assert client.post("/v1/webhooks/mux", data=body, headers={"content-type": "application/json", "mux-signature": fresh}).status_code == 401
