import hashlib
import hmac
import json
import time
import uuid

from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility, WebhookEvent
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

    events = db_session.query(WebhookEvent).filter_by(external_event_id="evt_123").all()
    assert len(events) == 1

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
