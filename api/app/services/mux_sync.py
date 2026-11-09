"""Mux videos whose webhook never came.

Mux tells us an upload became an asset, and the asset is ready or failed,
by webhook. If one is lost (or, in dev, nothing forwards them), the video
would sit "uploading" or "processing" for good. This job asks Mux about
each video still waiting after MUX_SYNC_STALE_MINUTES and younger than
MUX_SYNC_MAX_AGE_HOURS, and applies what it hears through the webhook's
own handler (webhooks._apply_mux_event), shaped as the event Mux would
have sent. A run applies only what Mux says has happened, so running it
alongside the webhook, or twice, changes nothing more.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaStatus

logger = logging.getLogger(__name__)

WAITING = (MediaStatus.created, MediaStatus.uploading, MediaStatus.processing)
#: What a Mux upload's status means, as the event it would have sent.
_UPLOAD_EVENTS = {
    "asset_created": "video.upload.asset_created",
    "errored": "video.upload.errored",
    "cancelled": "video.upload.cancelled",
    "timed_out": "video.upload.cancelled",
}
_ASSET_EVENTS = {"ready": "video.asset.ready", "errored": "video.asset.errored"}


@dataclass
class SyncResult:
    checked: int = 0
    applied: list[str] = field(default_factory=list)
    errors: int = 0


def due_videos(db: Session, *, now: datetime | None = None, limit: int = 50) -> list[MediaAsset]:
    conf = get_settings()
    now = now or datetime.now(timezone.utc)
    return list(
        db.execute(
            select(MediaAsset)
            .where(
                MediaAsset.provider == MediaProvider.mux,
                MediaAsset.kind == MediaKind.video,
                MediaAsset.status.in_(WAITING),
                MediaAsset.updated_at <= now - timedelta(minutes=conf.mux_sync_stale_minutes),
                MediaAsset.created_at >= now - timedelta(hours=conf.mux_sync_max_age_hours),
            )
            .order_by(MediaAsset.updated_at.asc())
            .limit(limit)
        ).scalars()
    )


def sync_waiting_videos(db: Session, *, client=None, now: datetime | None = None, limit: int = 50) -> SyncResult:
    from app.api.v1.webhooks import _apply_mux_event
    from app.services.mux import MuxClient

    client = client or MuxClient()
    result = SyncResult()
    for video in due_videos(db, now=now, limit=limit):
        result.checked += 1
        try:
            with db.begin_nested():
                if not video.provider_asset_id and video.provider_upload_id:
                    upload = client.get_upload(video.provider_upload_id)
                    event = _UPLOAD_EVENTS.get((upload or {}).get("status", ""))
                    if event:
                        _apply_mux_event(db, event, upload)
                        result.applied.append(event)
                if video.provider_asset_id and video.status not in (MediaStatus.ready, MediaStatus.failed):
                    asset = client.get_asset(video.provider_asset_id)
                    event = _ASSET_EVENTS.get((asset or {}).get("status", ""))
                    if event:
                        _apply_mux_event(db, event, asset)
                        result.applied.append(event)
        except Exception:
            result.errors += 1
            logger.exception("mux_sync_video_failed", extra={"media_asset_id": str(video.id)})
    if result.applied or result.errors:
        logger.info("mux_sync_run", extra={"checked": result.checked, "applied": len(result.applied), "errors": result.errors})
    return result
