from __future__ import annotations

import logging

import requests

from app.core.config import get_settings
from app.core.errors import APIError

settings = get_settings()
logger = logging.getLogger(__name__)


class MuxClient:
    base_url = "https://api.mux.com/video/v1"

    def __init__(self) -> None:
        self.auth = (settings.mux_token_id, settings.mux_token_secret)

    def create_direct_upload(self, cors_origin: str | None = None) -> dict:
        payload: dict = {
            "new_asset_settings": {
                "playback_policy": ["public", "signed"],
            }
        }
        if cors_origin:
            payload["cors_origin"] = cors_origin

        resp = requests.post(
            f"{self.base_url}/uploads",
            auth=self.auth,
            json=payload,
            timeout=15,
        )
        if resp.status_code >= 400:
            logger.error("mux_create_upload_failed", extra={"status_code": resp.status_code, "body": resp.text})
            raise APIError(code="mux_error", message="Failed to create Mux direct upload", status_code=502)
        return resp.json()["data"]
