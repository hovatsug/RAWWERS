from __future__ import annotations

import hashlib
import hmac
import time
from datetime import datetime, timedelta, timezone

import jwt

from app.core.config import get_settings

settings = get_settings()


def verify_mux_webhook_signature(raw_body: bytes, signature_header: str | None) -> bool:
    secret = settings.mux_webhook_secret

    if not secret:
        return settings.app_env != "production"

    if not signature_header:
        return False

    parts = {}
    for item in signature_header.split(","):
        if "=" not in item:
            continue
        key, value = item.split("=", 1)
        parts[key.strip()] = value.strip()

    ts = parts.get("t")
    sig = parts.get("v1")
    if not ts or not sig:
        return False

    try:
        timestamp = int(ts)
    except ValueError:
        return False

    if abs(int(time.time()) - timestamp) > 300:
        return False

    signed_payload = f"{ts}.{raw_body.decode('utf-8')}".encode("utf-8")
    expected = hmac.new(secret.encode("utf-8"), signed_payload, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, sig)


def create_mux_playback_token(playback_id: str, expires_in_seconds: int = 300) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": playback_id,
        "aud": "v",
        "exp": int((now + timedelta(seconds=expires_in_seconds)).timestamp()),
        "iat": int(now.timestamp()),
    }
    return jwt.encode(
        payload,
        settings.mux_signing_key_private,
        algorithm="RS256",
        headers={"kid": settings.mux_signing_key_id},
    )
