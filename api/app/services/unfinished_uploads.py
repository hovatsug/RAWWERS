"""Removing uploads started and never finished (owner's decision 4).

An export killed half way, or a phone that lost its connection, leaves a
photo waiting for bytes that will never come. It holds the file's place - the
same file sent to the same gallery again is "already there" - and, sent in
parts, it holds storage the bucket pays for. After `UNFINISHED_UPLOAD_MAX_AGE_HOURS`
untouched (24 by default) it is removed: the parts are aborted, whatever
arrived is deleted, and the photo is marked deleted, so sending the same file
again starts afresh. The bucket's own rule (docs/DEPLOY_CHECKLIST.md) aborts
unfinished parts after a day too; this job is what also tidies the database
and single-PUT uploads, which that rule never sees.
"""
from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaProvider, MediaStatus, MediaVariant, ObjectStatus
from app.services.storage import abort_multipart_upload, delete_object

logger = logging.getLogger(__name__)

#: Still waiting for the photo's bytes.
_WAITING = (MediaStatus.created, MediaStatus.uploading)


def remove_unfinished_uploads(db: Session, *, now: datetime | None = None, limit: int = 500) -> int:
    """Remove up to `limit` photos still waiting for their bytes and untouched
    for the whole period, oldest first. The caller commits. A storage error
    leaves that photo as it was, for the next run. Returns how many were removed."""
    now = now or datetime.now(timezone.utc)
    cutoff = now - timedelta(hours=get_settings().unfinished_upload_max_age_hours)
    assets = db.execute(
        select(MediaAsset)
        .where(
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.provider == MediaProvider.r2,
            MediaAsset.status.in_(_WAITING),
            MediaAsset.updated_at < cutoff,
        )
        .order_by(MediaAsset.updated_at)
        .limit(limit)
        .with_for_update(skip_locked=True)
    ).scalars().all()

    removed = 0
    for asset in assets:
        original = db.execute(
            select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant == MediaVariant.original)
        ).scalar_one_or_none()
        multipart = (asset.meta or {}).get("multipart")
        try:
            if original is not None:
                if multipart and multipart.get("upload_id"):
                    abort_multipart_upload(original.storage_key, multipart["upload_id"])
                # Whatever of a single PUT arrived; nothing there is not an error.
                delete_object(original.storage_key)
        except Exception:
            logger.warning("unfinished upload %s: storage did not answer, left for the next run", asset.id, exc_info=True)
            continue
        asset.status = MediaStatus.deleted
        asset.meta = {**{k: v for k, v in (asset.meta or {}).items() if k != "multipart"}, "removed": "unfinished_upload"}
        if original is not None:
            original.status = ObjectStatus.failed
        removed += 1
    db.flush()
    return removed
