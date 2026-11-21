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
        return False

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


def _mux_signing_key() -> str:
    """Mux gives the signing key's private key base64-encoded (a PEM inside);
    a PEM pasted as is works too."""
    raw = (settings.mux_signing_key_private or "").strip()
    if raw.startswith("-----BEGIN"):
        return raw.replace("\\n", "\n")
    import base64

    try:
        decoded = base64.b64decode(raw, validate=False).decode("utf-8")
    except Exception:
        return raw
    return decoded if decoded.startswith("-----BEGIN") else raw


def create_mux_playback_token(
    playback_id: str, expires_in_seconds: int = 300, *, audience: str = "v", extra: dict | None = None
) -> str:
    """A signed playback token (RS256): `sub` the playback id, `aud` "v" to
    play, "t" for a thumbnail, `exp`. The key id goes in the header and in the
    claims, as Mux's examples differ on where. A video token carries the
    resolution cap (MUX_PLAYBACK_MAX_RESOLUTION): with a signed playback id,
    Mux reads playback modifiers from the token only."""
    now = datetime.now(timezone.utc)
    payload = {
        "sub": playback_id,
        "aud": audience,
        "exp": int((now + timedelta(seconds=expires_in_seconds)).timestamp()),
        "iat": int(now.timestamp()),
        "kid": settings.mux_signing_key_id,
        **({"max_resolution": settings.mux_playback_max_resolution} if audience == "v" else {}),
        **(extra or {}),
    }
    return jwt.encode(
        payload,
        _mux_signing_key(),
        algorithm="RS256",
        headers={"kid": settings.mux_signing_key_id},
    )
