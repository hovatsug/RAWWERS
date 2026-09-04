"""Batch resolution of media asset ids into signed, time-limited image URLs.

Public-facing responses (discover cards, pro profiles) carry media *ids*. On
their own an id forces the caller into one `GET /v1/media/{id}` per image,
which is twenty extra round trips on the first screen a client ever sees - and
those requests 403 anyway for anyone who is not the owner. Resolving a whole
page of ids here in one query lets the URL travel with the card it belongs to.

Signing is a local HMAC computation, not a network call, so the cost of a page
of URLs is the single query above plus some CPU.
"""

from __future__ import annotations

import uuid
from collections.abc import Iterable, Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.media import MediaAsset, MediaKind, MediaObject, MediaStatus, MediaVariant, ObjectStatus
from app.services.storage import create_presigned_get

# A list card wants the 512px thumbnail; the original is the fallback for
# assets uploaded before variant processing ran, or where it failed.
THUMBNAIL_FIRST: tuple[MediaVariant, ...] = (MediaVariant.thumbnail, MediaVariant.original)

# A profile hero is displayed large, so the original leads and the thumbnail is
# the fallback - a 512px image stretched across a phone width looks broken.
ORIGINAL_FIRST: tuple[MediaVariant, ...] = (MediaVariant.original, MediaVariant.thumbnail)


def resolve_image_urls(
    db: Session,
    asset_ids: Iterable[uuid.UUID | None],
    *,
    prefer: Sequence[MediaVariant] = THUMBNAIL_FIRST,
    expires_in: int = 900,
) -> dict[uuid.UUID, str]:
    """Map photo asset ids to a signed URL, skipping anything not ready.

    Ids that are missing, not photos, still processing, or whose objects failed
    are simply absent from the result. Callers render the resulting `None` as
    "no image" rather than as an error - a pro who has not uploaded a cover is
    an ordinary state, not a fault.
    """
    wanted = {asset_id for asset_id in asset_ids if asset_id is not None}
    if not wanted:
        return {}

    rows = db.execute(
        select(MediaObject.media_asset_id, MediaObject.variant, MediaObject.storage_key)
        .join(MediaAsset, MediaAsset.id == MediaObject.media_asset_id)
        .where(
            MediaObject.media_asset_id.in_(wanted),
            MediaObject.variant.in_(tuple(prefer)),
            MediaObject.status == ObjectStatus.ready,
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.status == MediaStatus.ready,
        )
    ).all()

    rank = {variant: position for position, variant in enumerate(prefer)}
    best: dict[uuid.UUID, tuple[int, str]] = {}
    for asset_id, variant, storage_key in rows:
        position = rank[variant]
        current = best.get(asset_id)
        if current is None or position < current[0]:
            best[asset_id] = (position, storage_key)

    return {
        asset_id: create_presigned_get(storage_key, expires_in=expires_in)
        for asset_id, (_, storage_key) in best.items()
    }
