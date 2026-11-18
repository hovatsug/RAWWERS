"""The photo that represents a photographer: their cover (BETA_SCOPE #74).

One rule, decided here, read by every place that shows a photographer's
image (the Discover card and the listing preview built from it, the client
profile, the admin preview, search, the Pro app's portfolio badge), so the
apps and Discover never disagree about it:

1. The cover they chose, while it is still one of their own portfolio photos
   that is ready to show.
2. Otherwise their earliest ready portfolio photo tagged with their main
   niche.
3. Otherwise their earliest ready portfolio photo.
4. Otherwise none: they have no photo to show.

"Ready to show" is what resolve_image_urls can sign: a ready photo with a
ready thumbnail or original. Earliest (oldest upload first, then id), not
newest, so the automatic cover does not change each time a photo is added -
only when it is removed, or when they choose one.
"""

from __future__ import annotations

import uuid
from collections.abc import Iterable

from sqlalchemy import and_, exists, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import ProProfile
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, ObjectStatus
from app.models.niche import Niche, ProNiche

_SHOWABLE_VARIANTS = (MediaVariant.thumbnail, MediaVariant.original)


def _showable():
    """The conditions for a photo that can be a cover, as SQL."""
    return and_(
        MediaAsset.kind == MediaKind.photo,
        MediaAsset.purpose == MediaPurpose.portfolio_reel,
        MediaAsset.status == MediaStatus.ready,
        exists().where(
            MediaObject.media_asset_id == MediaAsset.id,
            MediaObject.variant.in_(_SHOWABLE_VARIANTS),
            MediaObject.status == ObjectStatus.ready,
        ),
    )


def effective_cover_ids(db: Session, pro_user_ids: Iterable[uuid.UUID]) -> dict[uuid.UUID, uuid.UUID]:
    """Each photographer's cover by the rule above; a photographer with no
    photo to show is absent. Three queries for any number of photographers."""
    wanted = {pro_id for pro_id in pro_user_ids if pro_id is not None}
    if not wanted:
        return {}

    chosen = dict(
        db.execute(
            select(ProProfile.user_id, ProProfile.cover_media_asset_id).where(
                ProProfile.user_id.in_(wanted), ProProfile.cover_media_asset_id.is_not(None)
            )
        ).all()
    )
    result: dict[uuid.UUID, uuid.UUID] = {}
    if chosen:
        valid = db.execute(
            select(MediaAsset.owner_user_id, MediaAsset.id).where(MediaAsset.id.in_(set(chosen.values())), _showable())
        ).all()
        for owner_id, asset_id in valid:
            # Only their own photo counts, whatever the profile row says.
            if chosen.get(owner_id) == asset_id:
                result[owner_id] = asset_id

    missing = wanted - result.keys()
    if not missing:
        return result

    main = dict(
        db.execute(
            select(ProNiche.pro_user_id, Niche.slug)
            .join(Niche, Niche.id == ProNiche.niche_id)
            .where(ProNiche.pro_user_id.in_(missing), ProNiche.is_primary.is_(True))
        ).all()
    )
    rows = db.execute(
        select(MediaAsset.owner_user_id, MediaAsset.id, MediaAsset.niche_tags)
        .where(MediaAsset.owner_user_id.in_(missing), _showable())
        .order_by(MediaAsset.owner_user_id, MediaAsset.created_at.asc(), MediaAsset.id.asc())
    ).all()
    earliest: dict[uuid.UUID, uuid.UUID] = {}
    earliest_main: dict[uuid.UUID, uuid.UUID] = {}
    for owner_id, asset_id, tags in rows:
        earliest.setdefault(owner_id, asset_id)
        slug = main.get(owner_id)
        if slug and slug in (tags or []):
            earliest_main.setdefault(owner_id, asset_id)
    for owner_id in missing:
        pick = earliest_main.get(owner_id) or earliest.get(owner_id)
        if pick is not None:
            result[owner_id] = pick
    return result


def effective_cover_id(db: Session, pro_user_id: uuid.UUID) -> uuid.UUID | None:
    return effective_cover_ids(db, [pro_user_id]).get(pro_user_id)


NOT_READY_MESSAGE = "This photo is still being prepared. Once it shows in your portfolio, you can make it your cover."


def set_cover(db: Session, pro_user_id: uuid.UUID, media_asset_id: uuid.UUID, *, source: str) -> bool:
    """Makes one of the photographer's own ready portfolio photos their
    cover. Anything that is not their portfolio photo is the same 404; a
    video is refused; a photo still processing is refused with a reason.
    Choosing the cover they already have changes nothing and returns False.
    Otherwise the Discover index is recomputed (which also refreshes the
    Discover cache and the search index) and an audit record is kept. The
    caller commits."""
    from app.services.audit import add_admin_audit_log
    from app.services.discovery_index import recompute_pro_public_index

    asset = db.get(MediaAsset, media_asset_id)
    if (
        asset is None
        or asset.owner_user_id != pro_user_id
        or asset.purpose != MediaPurpose.portfolio_reel
        or asset.status == MediaStatus.deleted
    ):
        raise APIError(code="not_found", message="Photo not found", status_code=404)
    if asset.kind != MediaKind.photo:
        raise APIError(code="cover_not_a_photo", message="Only a photo can be your cover.", status_code=422)
    showable = db.execute(select(MediaAsset.id).where(MediaAsset.id == asset.id, _showable())).first()
    if showable is None:
        raise APIError(code="cover_not_ready", message=NOT_READY_MESSAGE, status_code=409)

    profile = db.execute(select(ProProfile).where(ProProfile.user_id == pro_user_id).with_for_update()).scalar_one_or_none()
    if profile is None:
        raise APIError(code="not_found", message="No pro profile", status_code=404)
    if profile.cover_media_asset_id == asset.id:
        return False
    previous = profile.cover_media_asset_id
    profile.cover_media_asset_id = asset.id
    db.flush()
    recompute_pro_public_index(db, pro_user_id)
    add_admin_audit_log(
        db,
        actor_user_id=pro_user_id,
        target_type="media_asset",
        target_id=str(asset.id),
        action="cover_set",
        metadata={"source": source, "previous": str(previous) if previous else None},
    )
    return True
