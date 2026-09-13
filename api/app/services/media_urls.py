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
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
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


# A proof gallery is browsed, not glanced at: a client comparing 200 wedding
# photos will still be deciding well after five minutes, and the 300s TTL the
# gallery used to sign with expired mid-session, turning already-rendered
# images into 403s with nothing on screen to explain it. An hour covers a real
# selection sitting, and re-fetching the gallery mints fresh URLs for anyone
# who stays longer.
#
# Long TTLs are safe *here specifically* because these URLs point at
# downscaled, watermarked previews. The finals keep their short window
# (media_rights._signed_ttl_seconds, capped at 300s) - that is the asset worth
# stealing, and nothing about this constant touches it.
GALLERY_PREVIEW_URL_TTL_SECONDS = 3600


# Downloading a final is tap -> share sheet -> pick a destination -> wait for
# the write, and on a slow connection that is easily over a minute. The 60s
# this used to sign with meant a save could 403 *after* the client had paid,
# which is the worst possible moment for it.
#
# Deliberately far shorter than the preview TTL above: a preview is a
# downscaled, watermarked image and a final is the photograph itself, so the
# cost of a leaked URL is not remotely the same. Ten minutes covers a slow
# save without leaving a link to an original lying around for an hour, and
# the app asks for a fresh one per download rather than reusing one minted at
# page load.
FINALS_DOWNLOAD_URL_TTL_SECONDS = 600


def resolve_variant_urls(
    db: Session,
    asset_ids: Iterable[uuid.UUID | None],
    *,
    variants: Sequence[MediaVariant],
    expires_in: int = 900,
    require_ready_asset: bool = True,
) -> dict[uuid.UUID, dict[MediaVariant, str]]:
    """Signed URLs for several variants of many assets, in one query.

    `resolve_image_urls` answers "the best available image for this asset";
    this answers "each of these specific variants, separately", which is what
    a gallery tile needs when it carries both a thumbnail and a preview. The
    per-item form cost two queries and two signatures per photo, so a
    200-photo gallery spent ~400 round trips building one response.

    `require_ready_asset` exists because a proof gallery validates its items
    at attach time and must not drop one afterwards: an asset later marked
    `failed` by a re-run of `process_photo_variants` still has the ready
    objects the gallery was built on, and making a photo disappear part-way
    through a client's selection is worse than serving the preview that is
    demonstrably there. Callers rendering a fresh list keep the default.
    """
    wanted = {asset_id for asset_id in asset_ids if asset_id is not None}
    if not wanted or not variants:
        return {}

    rows = db.execute(
        select(MediaObject.media_asset_id, MediaObject.variant, MediaObject.storage_key)
        .join(MediaAsset, MediaAsset.id == MediaObject.media_asset_id)
        .where(
            MediaObject.media_asset_id.in_(wanted),
            MediaObject.variant.in_(tuple(variants)),
            MediaObject.status == ObjectStatus.ready,
            MediaAsset.kind == MediaKind.photo,
            *([MediaAsset.status == MediaStatus.ready] if require_ready_asset else []),
        )
    ).all()

    resolved: dict[uuid.UUID, dict[MediaVariant, str]] = {}
    for asset_id, variant, storage_key in rows:
        resolved.setdefault(asset_id, {})[variant] = create_presigned_get(storage_key, expires_in=expires_in)
    return resolved


def resolve_derivative_urls(
    db: Session,
    asset_ids: Iterable[uuid.UUID | None],
    *,
    kinds: Sequence[MediaDerivativeKind],
    expires_in: int = 900,
) -> dict[uuid.UUID, dict[MediaDerivativeKind, str]]:
    """The derivative counterpart to `resolve_variant_urls`, in one query.

    The two media tables are separate: `MediaObject` holds original/thumbnail/
    watermark_preview, `MediaDerivative` holds full_res/web_res/thumbnail/
    preview_watermarked. A caller wanting `web_res` - the 2048px unwatermarked
    copy - cannot get it from the variant resolver at all.
    """
    wanted = {asset_id for asset_id in asset_ids if asset_id is not None}
    if not wanted or not kinds:
        return {}

    rows = db.execute(
        select(MediaDerivative.media_asset_id, MediaDerivative.kind, MediaDerivative.storage_key)
        .join(MediaAsset, MediaAsset.id == MediaDerivative.media_asset_id)
        .where(
            MediaDerivative.media_asset_id.in_(wanted),
            MediaDerivative.kind.in_(tuple(kinds)),
            MediaAsset.kind == MediaKind.photo,
        )
    ).all()

    resolved: dict[uuid.UUID, dict[MediaDerivativeKind, str]] = {}
    for asset_id, kind, storage_key in rows:
        resolved.setdefault(asset_id, {})[kind] = create_presigned_get(storage_key, expires_in=expires_in)
    return resolved


def resolve_niche_cover_urls(
    db: Session,
    pro_user_ids: Iterable[uuid.UUID],
    *,
    niche_slug: str,
    expires_in: int = 900,
) -> dict[uuid.UUID, str]:
    """One photograph per photographer, from a given niche.

    A profile carries a single cover, so a wedding row built from covers shows
    whatever each photographer chose as their overall best - which for a
    portrait specialist who also shoots weddings is a portrait. Every
    photograph in a wedding row should be wedding work, and `niche_tags` on
    the asset is what makes that possible.

    One query for the whole row. Returns nothing for a photographer with no
    tagged photo in that niche; the caller falls back to their profile cover,
    which is the honest second-best rather than a blank tile.
    """
    wanted = {pro_id for pro_id in pro_user_ids if pro_id is not None}
    if not wanted:
        return {}

    rows = db.execute(
        select(MediaAsset.owner_user_id, MediaObject.storage_key, MediaAsset.created_at)
        .join(MediaObject, MediaObject.media_asset_id == MediaAsset.id)
        .where(
            MediaAsset.owner_user_id.in_(wanted),
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.status == MediaStatus.ready,
            MediaAsset.niche_tags.contains([niche_slug]),
            MediaObject.variant == MediaVariant.thumbnail,
            MediaObject.status == ObjectStatus.ready,
        )
        .order_by(MediaAsset.owner_user_id, MediaAsset.created_at.desc())
    ).all()

    # First row per owner wins - newest tagged photo in that niche.
    best: dict[uuid.UUID, str] = {}
    for owner_id, storage_key, _created in rows:
        best.setdefault(owner_id, storage_key)

    return {
        owner_id: create_presigned_get(storage_key, expires_in=expires_in)
        for owner_id, storage_key in best.items()
    }
