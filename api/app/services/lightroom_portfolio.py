"""Portfolio photos published from the Lightroom plug-in (docs/LIGHTROOM_PORTFOLIO.md).

The portfolio is the photographer's `portfolio_reel` photos; its only
sections are niches. The plug-in publishes a photo into one niche through
the same upload, limits and processing as the pro app (app/api/v1/media.py),
and is marked here so that:

- publishing the same photo to the same niche again is answered with the
  photo the server has (Lightroom resumes a publish by publishing again,
  and renders the photo again each time: see existing_copy);
- the plug-in can remove only photos it published, never ones added in the
  app, whatever a stolen token tries.
"""
from __future__ import annotations

import logging
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import ProProfile
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus
from app.models.media_rights import MediaDerivative
from app.models.niche import Niche, ProNiche

logger = logging.getLogger(__name__)

#: In media_asset.meta: the niche a Lightroom-published photo went to.
LIGHTROOM_NICHE_KEY = "lightroom_niche"
#: The oldest plug-in with the portfolio routes.
PORTFOLIO_MIN_PLUGIN = "1.1.0"
#: The oldest plug-in that can list and add niches.
NICHES_MIN_PLUGIN = "1.2.0"


def require_niches_plugin(plugin_version: str | None) -> None:
    from app.services.delivery_access import require_plugin_at_least

    require_plugin_at_least(plugin_version, NICHES_MIN_PLUGIN, feature="Adding a niche from Lightroom")


def niches(db: Session, pro_user_id: uuid.UUID) -> list[tuple[Niche, bool]]:
    """Where the photographer's portfolio photos can go: their own active
    niches, the main one first, then by name."""
    rows = db.execute(
        select(Niche, ProNiche.is_primary)
        .join(ProNiche, ProNiche.niche_id == Niche.id)
        .where(ProNiche.pro_user_id == pro_user_id, Niche.is_active.is_(True))
    ).all()
    return sorted(((n, bool(p)) for n, p in rows), key=lambda item: (not item[1], item[0].name.lower()))


def require_own_niche(db: Session, pro_user_id: uuid.UUID, slug: str) -> Niche:
    for niche, _primary in niches(db, pro_user_id):
        if niche.slug == slug:
            return niche
    raise APIError(
        code="validation_error",
        message="That niche is not one of yours. Edit the collection and choose its niche again, or add it there with Add a niche.",
        status_code=422,
    )


def is_from_lightroom(asset: MediaAsset) -> bool:
    return asset.purpose == MediaPurpose.portfolio_reel and bool((asset.meta or {}).get(LIGHTROOM_NICHE_KEY))


#: In media_asset.meta (1.2.3): the plug-in's key for the Lightroom photo
#: in its collection, and the hash of the picture without its metadata.
PUBLISH_KEY = "lightroom_publish_key"
IMAGE_SHA_KEY = "image_sha256"

_WAITING = (MediaStatus.uploading, MediaStatus.created)
_ON_SERVER = (MediaStatus.processing, MediaStatus.ready)


def _live_in_niche(db: Session, pro_user_id: uuid.UUID, slug: str) -> list[MediaAsset]:
    """This photographer's Lightroom photos in this niche, not failed or
    removed, newest first."""
    rows = db.execute(
        select(MediaAsset)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.status.not_in([MediaStatus.failed, MediaStatus.deleted]),
        )
        .order_by(MediaAsset.created_at.desc())
    ).scalars().all()
    return [a for a in rows if (a.meta or {}).get(LIGHTROOM_NICHE_KEY) == slug]


def existing_copy(
    db: Session,
    pro_user_id: uuid.UUID,
    slug: str,
    *,
    checksum: str,
    publish_key: str | None = None,
    image_sha256: str | None = None,
) -> tuple[MediaAsset | None, MediaAsset | None]:
    """What the server has of this photo in this niche: (the same photo, or
    None; an older version it replaces, or None).

    The same photo is, in order:
    1. the same Lightroom photo in the same collection (`publish_key`) whose
       upload never finished: resumed, whatever the new render;
    2. the same Lightroom photo with the same picture (`image_sha256`) or
       the same file (`checksum`): Lightroom renders again on every
       publish, and the export time it writes changes the file's hash;
    3. any photo in this niche with the same picture or the same file (a
       virtual copy, another catalog, a plug-in before 1.2.3).
    The same Lightroom photo with another picture was edited: a new photo,
    and the old one is named so the plug-in removes it once the new one is
    finished. Another niche is never the same photo."""
    live = _live_in_niche(db, pro_user_id, slug)

    def same_picture(asset: MediaAsset) -> bool:
        meta = asset.meta or {}
        return asset.checksum == checksum or bool(image_sha256 and meta.get(IMAGE_SHA_KEY) == image_sha256)

    keyed = [a for a in live if publish_key and (a.meta or {}).get(PUBLISH_KEY) == publish_key]
    for asset in keyed:
        if asset.status in _WAITING or same_picture(asset):
            return asset, None
    for asset in live:
        if same_picture(asset):
            return asset, None
    replaced = next((a for a in keyed if a.status in _ON_SERVER), None)
    return None, replaced


def published_copy(db: Session, pro_user_id: uuid.UUID, slug: str, checksum: str) -> MediaAsset | None:
    """This file, already published from Lightroom to this niche (the
    file-hash guard alone, as before 1.2.3)."""
    return existing_copy(db, pro_user_id, slug, checksum=checksum)[0]


def mark_published(
    asset: MediaAsset, *, slug: str, checksum: str, publish_key: str | None = None, image_sha256: str | None = None
) -> None:
    """Marks a photo started from the plug-in. Its niche is set now (the
    lists read only `ready` photos, so it shows nowhere before), so a photo
    from the plug-in is never left without its niche."""
    asset.checksum = checksum
    meta = {**(asset.meta or {}), LIGHTROOM_NICHE_KEY: slug, "source": "lightroom"}
    if publish_key:
        meta[PUBLISH_KEY] = publish_key
    if image_sha256:
        meta[IMAGE_SHA_KEY] = image_sha256.lower()
    asset.meta = meta
    asset.niche_tags = [slug]


def resume_with(asset: MediaAsset, *, checksum: str, image_sha256: str | None) -> None:
    """A waiting upload taken over by a new render of the same photo: the
    finish and the worker check the new file's hash."""
    if asset.status in _WAITING:
        asset.checksum = checksum
        if image_sha256:
            asset.meta = {**(asset.meta or {}), IMAGE_SHA_KEY: image_sha256.lower()}


def _retag(db: Session, asset: MediaAsset, slug: str) -> None:
    """The niche's skills and the Discover index, for a photo tagged with
    its niche. The caller holds lock_pro_for_recompute."""
    from app.services import discovery_index
    from app.services.niche_skills import recompute_pro_niche_skills

    asset.niche_tags = [slug]
    db.flush()
    niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
    if niche is not None:
        recompute_pro_niche_skills(db, asset.owner_user_id, niche.id)
    discovery_index.recompute_pro_public_index(db, asset.owner_user_id)


def ensure_tagged(db: Session, asset: MediaAsset) -> bool:
    """Repairs a photo left processing or ready without its niche (the
    deadlock of 2026-11-16 left two). True when it changed something; the
    caller commits."""
    from app.services.niche_skills import lock_pro_for_recompute

    slug = (asset.meta or {}).get(LIGHTROOM_NICHE_KEY)
    if not slug or asset.status not in _ON_SERVER or slug in (asset.niche_tags or []):
        return False
    lock_pro_for_recompute(db, asset.owner_user_id)
    _retag(db, asset, slug)
    return True


def finish(db: Session, asset: MediaAsset, *, byte_size: int | None) -> MediaStatus:
    """The file is in storage: the photo goes to processing and its niche's
    skills and the Discover index are recomputed, in one transaction (before
    1.2.3 the photo was committed as processing first, so a failed recompute
    left it processing, untagged, and refused the plug-in's retry). Finishing
    a photo that is already processing or ready answers its status again.
    Commits; the worker is queued after the commit."""
    from app.services.photo_uploads import max_photo_bytes
    from app.services.niche_skills import lock_pro_for_recompute
    from app.tasks.media_tasks import process_photo_variants

    lock_pro_for_recompute(db, asset.owner_user_id)
    db.refresh(asset)
    if asset.status in _ON_SERVER:
        ensure_tagged(db, asset)
        db.commit()
        return asset.status
    if asset.status == MediaStatus.deleted:
        raise APIError(
            code="photo_removed",
            message="This photo was removed from your portfolio. Publish it again to send it anew.",
            status_code=409,
        )
    if asset.status not in _WAITING:
        raise APIError(
            code="photo_failed",
            message="RAWWERS could not process this photo. Publish it again to send it anew.",
            status_code=409,
        )
    if byte_size and byte_size > max_photo_bytes(asset.purpose):
        raise APIError(code="validation_error", message="Larger than 25 MB. Export it smaller.", status_code=422)
    asset.status = MediaStatus.processing
    if byte_size is not None:
        asset.byte_size = byte_size
    _retag(db, asset, (asset.meta or {}).get(LIGHTROOM_NICHE_KEY))
    db.commit()
    process_photo_variants.delay(str(asset.id))
    return asset.status


def niche_counts(db: Session, pro_user_id: uuid.UUID) -> dict[str, int]:
    """Portfolio photos on the server (processing or ready) per niche."""
    rows = db.execute(
        select(MediaAsset.niche_tags).where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status.in_(list(_ON_SERVER)),
        )
    ).scalars().all()
    counts: dict[str, int] = {}
    for tags in rows:
        for slug in tags or []:
            counts[slug] = counts.get(slug, 0) + 1
    return counts


def own_published(db: Session, pro_user_id: uuid.UUID, media_asset_id: uuid.UUID) -> MediaAsset:
    """A photo this photographer published from Lightroom; anything else is
    the same 404, so the token learns nothing about other photos."""
    asset = db.get(MediaAsset, media_asset_id)
    if asset is None or asset.owner_user_id != pro_user_id or not is_from_lightroom(asset):
        raise APIError(code="not_found", message="Photo not found", status_code=404)
    return asset


def remove(db: Session, asset: MediaAsset) -> None:
    """Takes the photo out of the portfolio: no longer listed or served
    (every list reads `ready` only), no longer the cover, its niches'
    skills and the Discover index recomputed, and its files deleted from
    storage (left for the unfinished-uploads sweep if storage does not
    answer). Removing it again changes nothing."""
    from app.services.discovery_index import recompute_pro_public_index
    from app.services.niche_skills import recompute_pro_niche_skills
    from app.services.storage import delete_object

    if asset.status == MediaStatus.deleted:
        return
    asset.status = MediaStatus.deleted
    asset.meta = {**(asset.meta or {}), "removed": "lightroom"}
    profile = db.get(ProProfile, asset.owner_user_id)
    if profile is not None and profile.cover_media_asset_id == asset.id:
        profile.cover_media_asset_id = None
    db.flush()

    for slug in asset.niche_tags or []:
        niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
        if niche is not None:
            recompute_pro_niche_skills(db, asset.owner_user_id, niche.id)
    recompute_pro_public_index(db, asset.owner_user_id)

    keys = [o.storage_key for o in db.execute(select(MediaObject).where(MediaObject.media_asset_id == asset.id)).scalars()]
    keys += [d.storage_key for d in db.execute(select(MediaDerivative).where(MediaDerivative.media_asset_id == asset.id)).scalars()]
    for key in keys:
        try:
            delete_object(key)
        except Exception:
            logger.warning("lightroom portfolio removal %s: storage did not answer for one file", asset.id, exc_info=True)
