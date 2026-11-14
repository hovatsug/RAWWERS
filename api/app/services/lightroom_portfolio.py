"""Portfolio photos published from the Lightroom plug-in (docs/LIGHTROOM_PORTFOLIO.md).

The portfolio is the photographer's `portfolio_reel` photos; its only
sections are niches. The plug-in publishes a photo into one niche through
the same upload, limits and processing as the pro app (app/api/v1/media.py),
and is marked here so that:

- publishing the same file to the same niche again is answered as already
  there (Lightroom resumes a publish by publishing again);
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
        message="That niche is not one of yours. Choose the collection's niche again, or add the niche in the RAWWERS Pro app.",
        status_code=422,
    )


def is_from_lightroom(asset: MediaAsset) -> bool:
    return asset.purpose == MediaPurpose.portfolio_reel and bool((asset.meta or {}).get(LIGHTROOM_NICHE_KEY))


def published_copy(db: Session, pro_user_id: uuid.UUID, slug: str, checksum: str) -> MediaAsset | None:
    """This file, already published from Lightroom to this niche and not
    failed or removed."""
    candidates = db.execute(
        select(MediaAsset).where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.checksum == checksum,
            MediaAsset.status.not_in([MediaStatus.failed, MediaStatus.deleted]),
        )
    ).scalars().all()
    for asset in candidates:
        if (asset.meta or {}).get(LIGHTROOM_NICHE_KEY) == slug:
            return asset
    return None


def mark_published(asset: MediaAsset, *, slug: str, checksum: str) -> None:
    asset.checksum = checksum
    asset.meta = {**(asset.meta or {}), LIGHTROOM_NICHE_KEY: slug, "source": "lightroom"}


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
