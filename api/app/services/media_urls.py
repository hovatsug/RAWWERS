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
from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, ObjectStatus
from app.models.media_rights import MediaDerivative, MediaDerivativeKind
from app.services.storage import create_presigned_get, stable_presigned_gets

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

    # Stable URLs: the same photo keeps the same URL across responses, so the
    # phone's cache recognises it (see storage.stable_presigned_gets).
    urls = stable_presigned_gets((key for _, key in best.values()), expires_in)
    return {asset_id: urls[storage_key] for asset_id, (_, storage_key) in best.items()}


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

    urls = stable_presigned_gets((storage_key for _, _, storage_key in rows), expires_in)
    resolved: dict[uuid.UUID, dict[MediaVariant, str]] = {}
    for asset_id, variant, storage_key in rows:
        resolved.setdefault(asset_id, {})[variant] = urls[storage_key]
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
    preferred: Iterable[uuid.UUID] = (),
) -> dict[uuid.UUID, str]:
    """One photograph per photographer, from a given niche: their cover
    (any id in `preferred`) when it is tagged with that niche, otherwise
    their newest photo tagged with it.

    A profile carries a single cover, so a wedding row built from covers shows
    whatever each photographer chose as their overall best - which for a
    portrait specialist who also shoots weddings is a portrait. Every
    photograph in a wedding row should be wedding work, and `niche_tags` on
    the asset is what makes that possible.

    One query for the whole row. Returns nothing for a photographer with no
    tagged photo in that niche; the caller falls back to their profile cover,
    which is the honest second-best rather than a blank tile.
    """
    images = resolve_niche_cover_images(db, pro_user_ids, niche_slug=niche_slug, expires_in=expires_in, preferred=preferred)
    return {owner_id: image.url for owner_id, image in images.items()}


def resolve_niche_cover_images(
    db: Session,
    pro_user_ids: Iterable[uuid.UUID],
    *,
    niche_slug: str,
    expires_in: int = 900,
    preferred: Iterable[uuid.UUID] = (),
) -> dict[uuid.UUID, SizedImage]:
    """resolve_niche_cover_urls with each photo's shape (a home tile leans
    its crop up for a portrait), as resolve_sized_image_urls sends it: the
    card copy, else the web copy, else the thumbnail."""
    wanted = {pro_id for pro_id in pro_user_ids if pro_id is not None}
    if not wanted:
        return {}
    lead = {asset_id for asset_id in preferred if asset_id is not None}

    rows = db.execute(
        select(MediaAsset.owner_user_id, MediaObject.storage_key, MediaAsset.id)
        .join(MediaObject, MediaObject.media_asset_id == MediaAsset.id)
        .where(
            MediaAsset.owner_user_id.in_(wanted),
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
            MediaAsset.niche_tags.contains([niche_slug]),
            MediaObject.variant == MediaVariant.thumbnail,
            MediaObject.status == ObjectStatus.ready,
        )
        .order_by(
            MediaAsset.owner_user_id,
            *([MediaAsset.id.in_(lead).desc()] if lead else []),
            MediaAsset.created_at.desc(),
        )
    ).all()

    # First row per owner wins - their cover, else the newest tagged photo.
    best: dict[uuid.UUID, uuid.UUID] = {}
    for owner_id, _storage_key, asset_id in rows:
        best.setdefault(owner_id, asset_id)

    images = resolve_sized_image_urls(db, best.values(), expires_in=expires_in)
    return {owner_id: images[asset_id] for owner_id, asset_id in best.items() if asset_id in images}


#: What a card shows, best first: the card copy, else the web copy.
_CARD_FIRST: tuple[MediaDerivativeKind, ...] = (MediaDerivativeKind.card, MediaDerivativeKind.web_res)


@dataclass(frozen=True)
class SizedImage:
    """A signed image URL with the photo's shape, so an app can tell a
    portrait from a landscape before it has the image (the crop leans up for
    a portrait). Width and height are None when nothing recorded them."""

    url: str
    width: int | None = None
    height: int | None = None


def _photo_sizes(db: Session, asset_ids: set[uuid.UUID]) -> dict[uuid.UUID, tuple[int, int]]:
    """Each photo's shape, from whichever of its images recorded one. Every
    copy of a photo has the same proportions, so any of them will do."""
    sizes: dict[uuid.UUID, tuple[int, int]] = {}
    for table, extra in (
        (MediaDerivative, (MediaDerivative.kind.in_((MediaDerivativeKind.card, MediaDerivativeKind.web_res)),)),
        (MediaObject, (MediaObject.status == ObjectStatus.ready,)),
    ):
        missing = asset_ids - sizes.keys()
        if not missing:
            break
        rows = db.execute(
            select(table.media_asset_id, table.width, table.height).where(
                table.media_asset_id.in_(missing), table.width.is_not(None), table.height.is_not(None), *extra
            )
        ).all()
        for asset_id, width, height in rows:
            if width and height:
                sizes.setdefault(asset_id, (int(width), int(height)))
    return sizes


def resolve_sized_image_urls(
    db: Session,
    asset_ids: Iterable[uuid.UUID | None],
    *,
    expires_in: int = 900,
) -> dict[uuid.UUID, SizedImage]:
    """A portfolio photo as a card shows it - the Discover card, Your
    listing, the profile header, the home tiles and carousel - with its
    shape, in a fixed number of queries.

    The card copy (1200 x 800 covered, WebP, about 90 KB). A photo made
    before it existed falls back to the 2048 px web copy, then to the
    thumbnail (else the original), so a card is never empty for a missing
    copy. Only for photos anyone may see: the callers pass covers and
    portfolio photos (profile_cover, resolve_niche_cover_images). URLs are
    stable across responses, so the phone's cache keeps recognising them."""
    wanted = {asset_id for asset_id in asset_ids if asset_id is not None}
    if not wanted:
        return {}
    keys: dict[uuid.UUID, str] = {}
    rows = db.execute(
        select(MediaDerivative.media_asset_id, MediaDerivative.kind, MediaDerivative.storage_key,
               MediaDerivative.width, MediaDerivative.height)
        .join(MediaAsset, MediaAsset.id == MediaDerivative.media_asset_id)
        .where(
            MediaDerivative.media_asset_id.in_(wanted),
            MediaDerivative.kind.in_(_CARD_FIRST),
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.status == MediaStatus.ready,
        )
    ).all()
    ranked: dict[uuid.UUID, tuple[int, str, int | None, int | None]] = {}
    for asset_id, kind, storage_key, width, height in rows:
        position = _CARD_FIRST.index(kind)
        if asset_id not in ranked or position < ranked[asset_id][0]:
            ranked[asset_id] = (position, storage_key, width, height)
    keys.update({asset_id: storage_key for asset_id, (_, storage_key, _w, _h) in ranked.items()})
    # The shape of the copy sent, where it recorded one.
    shown = {asset_id: (w, h) for asset_id, (_, _k, w, h) in ranked.items() if w and h}
    rest = wanted - keys.keys()
    if rest:
        rows = db.execute(
            select(MediaObject.media_asset_id, MediaObject.variant, MediaObject.storage_key)
            .join(MediaAsset, MediaAsset.id == MediaObject.media_asset_id)
            .where(
                MediaObject.media_asset_id.in_(rest),
                MediaObject.variant.in_(THUMBNAIL_FIRST),
                MediaObject.status == ObjectStatus.ready,
                MediaAsset.kind == MediaKind.photo,
                MediaAsset.status == MediaStatus.ready,
            )
        ).all()
        rank = {variant: position for position, variant in enumerate(THUMBNAIL_FIRST)}
        best: dict[uuid.UUID, tuple[int, str]] = {}
        for asset_id, variant, storage_key in rows:
            if asset_id not in best or rank[variant] < best[asset_id][0]:
                best[asset_id] = (rank[variant], storage_key)
        keys.update({asset_id: storage_key for asset_id, (_, storage_key) in best.items()})
    if not keys:
        return {}
    sizes = {**_photo_sizes(db, set(keys) - shown.keys()), **shown}
    urls = stable_presigned_gets(keys.values(), expires_in)
    return {
        asset_id: SizedImage(urls[storage_key], *sizes.get(asset_id, (None, None)))
        for asset_id, storage_key in keys.items()
    }
