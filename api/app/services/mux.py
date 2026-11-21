from __future__ import annotations

import logging

import requests

from app.core.config import get_settings
from app.core.errors import APIError

settings = get_settings()
logger = logging.getLogger(__name__)

#: What every direct upload asks Mux for (checked against Mux's documentation
#: on 2026-11-21, docs/MUX_LOCAL_WEBHOOKS.md "Assumptions"):
#: - `playback_policies: ["signed"]` only. A public playback id plays for
#:   anyone who has it, without a token; this used to ask for both and keep
#:   whichever id came first.
#: - `video_quality: "basic"`: no encoding charge, the cheapest that suits a
#:   one-minute profile video; `max_resolution_tier: "1080p"`, so a 4K phone
#:   clip is not stored or billed at the 2160p rate.
#: - `passthrough`: our media asset id, which every asset event carries back.
NEW_ASSET_SETTINGS = {
    "playback_policies": ["signed"],
    "video_quality": "basic",
    "max_resolution_tier": "1080p",
}
#: Seconds the upload URL stays open (Mux's default is 3600).
UPLOAD_TIMEOUT_SECONDS = 3600


def mux_keys_configured() -> bool:
    """The real Mux needs API access and a playback signing key."""
    conf = get_settings()
    return all((conf.mux_token_id, conf.mux_token_secret, conf.mux_signing_key_id, conf.mux_signing_key_private))


class MuxClient:
    base_url = "https://api.mux.com/video/v1"
    fake = False

    def __init__(self) -> None:
        self.auth = (settings.mux_token_id, settings.mux_token_secret)

    def create_direct_upload(self, cors_origin: str | None = None, *, passthrough: str | None = None, base_url: str | None = None) -> dict:
        payload: dict = {
            "new_asset_settings": {**NEW_ASSET_SETTINGS, **({"passthrough": passthrough} if passthrough else {})},
            "timeout": UPLOAD_TIMEOUT_SECONDS,
            # Marked required in Mux's schema; it only matters to browsers.
            "cors_origin": cors_origin or "*",
        }
        resp = requests.post(f"{self.base_url}/uploads", auth=self.auth, json=payload, timeout=15)
        if resp.status_code >= 400:
            logger.error("mux_create_upload_failed", extra={"status_code": resp.status_code})
            raise APIError(code="mux_error", message="The video service did not answer. Try again in a few minutes.", status_code=502)
        return resp.json()["data"]

    def _get(self, path: str) -> dict | None:
        """One Mux object, or None if Mux no longer has it."""
        resp = requests.get(f"{self.base_url}/{path}", auth=self.auth, timeout=15)
        if resp.status_code == 404:
            return None
        if resp.status_code >= 400:
            logger.error("mux_get_failed", extra={"path": path.split("/")[0], "status_code": resp.status_code})
            raise APIError(code="mux_error", message="Failed to read from Mux", status_code=502)
        return resp.json()["data"]

    def get_upload(self, upload_id: str) -> dict | None:
        return self._get(f"uploads/{upload_id}")

    def get_asset(self, asset_id: str) -> dict | None:
        return self._get(f"assets/{asset_id}")

    def delete_asset(self, asset_id: str) -> None:
        """Gone at Mux. 204 is success; a 404 (the documentation does not say
        what an already-deleted asset answers) is taken as gone too. Anything
        else raises, and the caller keeps the deletion pending."""
        resp = requests.delete(f"{self.base_url}/assets/{asset_id}", auth=self.auth, timeout=15)
        if resp.status_code in (200, 204, 404):
            return
        logger.error("mux_delete_asset_failed", extra={"status_code": resp.status_code})
        raise APIError(code="mux_error", message="Failed to delete from Mux", status_code=502)

    def cancel_upload(self, upload_id: str) -> None:
        """Close an upload no asset was made from (PUT /uploads/{id}/cancel).
        Best effort: an upload left open times out by itself."""
        try:
            requests.put(f"{self.base_url}/uploads/{upload_id}/cancel", auth=self.auth, timeout=15)
        except Exception:
            logger.warning("mux_cancel_upload_failed", exc_info=True)

    def playback_url(self, playback_id: str, *, expires_in: int, base_url: str | None = None) -> str:
        from app.services.security import create_mux_playback_token

        return f"https://stream.mux.com/{playback_id}.m3u8?token={create_mux_playback_token(playback_id, expires_in_seconds=expires_in)}"

    def poster_url(self, playback_id: str, *, expires_in: int, base_url: str | None = None) -> str:
        """A signed playback id needs its own token for a thumbnail (audience
        "t"); thumbnail options go in the token, never in the URL."""
        from app.services.security import create_mux_playback_token

        token = create_mux_playback_token(playback_id, expires_in_seconds=expires_in, audience="t", extra={"time": 1, "width": 720})
        return f"https://image.mux.com/{playback_id}/thumbnail.jpg?token={token}"


def get_mux_client():
    """The fake in development or tests when MUX_FAKE is on; the real Mux
    otherwise. Outside development MUX_FAKE is ignored, whatever it says."""
    from app.services.mux_fake import FakeMuxClient, fake_mux_allowed

    if fake_mux_allowed():
        return FakeMuxClient()
    return MuxClient()


def mux_available() -> bool:
    from app.services.mux_fake import fake_mux_allowed

    return fake_mux_allowed() or mux_keys_configured()
