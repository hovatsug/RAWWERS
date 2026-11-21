"""A fake Mux, for development and tests only (MUX_FAKE=true).

Built before any real Mux round trip had been tried (2026-11-21). With this on, the whole
"Meet the photographer" video flow runs locally: the Pro app uploads to an
address on the dev API instead of Mux's, the fake "encodes" it and sends
the events Mux would send - through the same outbox and the same handler as
real webhooks (webhooks._apply_mux_event) - and playback is a small bundled
sample clip served by the dev API.

It cannot run anywhere else: `fake_mux_allowed()` is false outside the
development environments whatever MUX_FAKE says, and its routes live in the
dev-only router, which answers 404 outside development before anything else.

What it simulates: a direct upload created; the file arriving; the asset
created; ready with a playback id and the clip's real duration (read from the
MP4/MOV header), or errored when the file is not a video; an asset deleted.
`send_events` can also deliver events twice or out of order, for tests.
"""
from __future__ import annotations

import json
import struct
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

import jwt

from app.core.config import get_settings

DEV_ENVIRONMENTS = frozenset({"development", "dev", "local", "test"})
#: The token the fake's "playback" accepts: signed here, never by a Mux key.
_FAKE_TOKEN_SECRET = "fake-mux-development-only"
_KEY = "fakemux:"
#: Seconds between the file arriving and the fake asset being ready, so the
#: app shows "processing" for a moment, as with Mux.
PROCESSING_SECONDS = 6
SAMPLE_CLIP = Path(__file__).resolve().parents[1] / "dev_assets" / "fake_mux_sample.mp4"


def fake_mux_allowed() -> bool:
    conf = get_settings()
    return bool(conf.mux_fake) and (conf.app_env or "").strip().lower() in DEV_ENVIRONMENTS


def _redis():
    from app.services.cache import get_redis_client

    return get_redis_client()


def _save(kind: str, obj_id: str, data: dict) -> None:
    _redis().set(f"{_KEY}{kind}:{obj_id}", json.dumps(data), ex=7 * 24 * 3600)


def _load(kind: str, obj_id: str) -> dict | None:
    raw = _redis().get(f"{_KEY}{kind}:{obj_id}")
    return json.loads(raw) if raw else None


def mp4_duration_seconds(data: bytes) -> float | None:
    """The duration in an MP4 or MOV file's header (moov > mvhd), or None when
    the bytes are not one."""
    def boxes(buf: bytes, start: int, end: int):
        pos = start
        while pos + 8 <= end:
            size, kind = struct.unpack(">I4s", buf[pos:pos + 8])
            header = 8
            if size == 1 and pos + 16 <= end:
                size = struct.unpack(">Q", buf[pos + 8:pos + 16])[0]
                header = 16
            elif size == 0:
                size = end - pos
            if size < header:
                return
            yield kind, pos + header, pos + size
            pos += size

    for kind, body, end in boxes(data, 0, len(data)):
        if kind != b"moov":
            continue
        for inner, ibody, _iend in boxes(data, body, end):
            if inner != b"mvhd":
                continue
            version = data[ibody]
            if version == 1:
                timescale, duration = struct.unpack(">IQ", data[ibody + 20:ibody + 32])
            else:
                timescale, duration = struct.unpack(">II", data[ibody + 12:ibody + 20])
            return duration / timescale if timescale else None
    return None


class FakeMuxClient:
    fake = True

    def create_direct_upload(self, cors_origin: str | None = None, *, passthrough: str | None = None, base_url: str | None = None) -> dict:
        upload_id = f"fake-up-{uuid.uuid4().hex}"
        base = (base_url or "http://localhost:8000").rstrip("/")
        data = {"id": upload_id, "url": f"{base}/v1/dev/fake-mux/uploads/{upload_id}", "timeout": 3600,
                "status": "waiting", "passthrough": passthrough}
        _save("upload", upload_id, data)
        return data

    def get_upload(self, upload_id: str) -> dict | None:
        return _load("upload", upload_id)

    def get_asset(self, asset_id: str) -> dict | None:
        asset = _load("asset", asset_id)
        return None if asset is None or asset.get("status") == "deleted" else asset

    def delete_asset(self, asset_id: str) -> None:
        if fake_fail_next_delete():
            raise RuntimeError("fake Mux: delete failed (simulated)")
        asset = _load("asset", asset_id)
        if asset is not None:
            _save("asset", asset_id, {**asset, "status": "deleted"})

    def cancel_upload(self, upload_id: str) -> None:
        upload = _load("upload", upload_id)
        if upload is not None and upload.get("status") == "waiting":
            _save("upload", upload_id, {**upload, "status": "cancelled"})

    def playback_url(self, playback_id: str, *, expires_in: int, base_url: str | None = None) -> str:
        return f"{(base_url or 'http://localhost:8000').rstrip('/')}/v1/dev/fake-mux/play/{playback_id}.mp4?token={fake_token(playback_id, 'v', expires_in)}"

    def poster_url(self, playback_id: str, *, expires_in: int, base_url: str | None = None) -> str:
        return f"{(base_url or 'http://localhost:8000').rstrip('/')}/v1/dev/fake-mux/poster/{playback_id}.jpg?token={fake_token(playback_id, 't', expires_in)}"


def fake_token(playback_id: str, audience: str, expires_in: int) -> str:
    exp = datetime.now(timezone.utc) + timedelta(seconds=expires_in)
    claims = {"sub": playback_id, "aud": audience, "exp": int(exp.timestamp())}
    if audience == "v":  # As the real token: the cap travels inside it.
        claims["max_resolution"] = get_settings().mux_playback_max_resolution
    return jwt.encode(claims, _FAKE_TOKEN_SECRET, algorithm="HS256")


def fake_token_ok(token: str | None, playback_id: str, audience: str) -> bool:
    try:
        claims = jwt.decode(token or "", _FAKE_TOKEN_SECRET, algorithms=["HS256"], audience=audience)
    except jwt.PyJWTError:
        return False
    return claims.get("sub") == playback_id


def fake_fail_next_delete(set_to: bool | None = None) -> bool:
    """For a test or a manual check of the retry: the next asset deletion
    fails once."""
    key = f"{_KEY}fail-next-delete"
    if set_to is not None:
        _redis().set(key, "1" if set_to else "0", ex=3600)
        return set_to
    return _redis().getdel(key) == "1"


def _event(event_type: str, data: dict) -> dict:
    return {"id": f"fake-evt-{uuid.uuid4().hex}", "type": event_type, "data": data,
            "object": {"type": "asset" if ".asset." in event_type else "upload", "id": data.get("id")}}


def send_events(db, events: list[dict], *, delay_seconds: int = 0) -> None:
    """Deliver events as Mux's webhooks arrive: into the outbox, keyed by
    event id, applied by the worker through the real handler."""
    from app.services.outbox import enqueue_outbox_event

    available = datetime.now(timezone.utc) + timedelta(seconds=delay_seconds) if delay_seconds else None
    for event in events:
        enqueue_outbox_event(db, topic="mux.event", payload=event, idempotency_key=f"mux:{event['id']}",
                             idempotency_scope="mux_ingest", available_at=available)


def receive_file(db, upload_id: str, body: bytes) -> tuple[bool, str]:
    """The Pro app's PUT of the file. (accepted, plain-words answer). Sends
    asset_created now, and ready (or errored, for a file that is not a video)
    a few seconds later. A repeated PUT of a finished upload changes nothing."""
    upload = _load("upload", upload_id)
    if upload is None:
        return False, "This upload address is unknown or has expired."
    if upload.get("status") != "waiting":
        return True, "Already received."
    asset_id = f"fake-asset-{uuid.uuid4().hex}"
    duration = mp4_duration_seconds(body)
    playback_id = f"fake-pb-{uuid.uuid4().hex}"
    ready = duration is not None
    asset = {"id": asset_id, "status": "ready" if ready else "errored", "upload_id": upload_id,
             "passthrough": upload.get("passthrough"), "duration": duration,
             "playback_ids": [{"id": playback_id, "policy": "signed"}] if ready else [],
             "errors": None if ready else {"type": "invalid_input", "messages": ["The file is not a video Mux can read."]}}
    _save("asset", asset_id, asset)
    _save("upload", upload_id, {**upload, "status": "asset_created", "asset_id": asset_id})
    send_events(db, [_event("video.upload.asset_created", {"id": upload_id, "asset_id": asset_id, "status": "asset_created",
                                                           "passthrough": upload.get("passthrough")})])
    send_events(db, [_event("video.asset.ready" if ready else "video.asset.errored", asset)], delay_seconds=PROCESSING_SECONDS)
    return True, "Received."
