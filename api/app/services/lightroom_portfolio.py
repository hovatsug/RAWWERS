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
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant
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
        message="That niche is not one of yours (niches are removed in the RAWWERS Pro app). "
        "Edit the collection and choose its niche again, or add it there with Add a niche.",
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


def live_in_gallery(db: Session, gallery_id: uuid.UUID) -> list[MediaAsset]:
    """A gig gallery's photos, not failed or removed, newest first."""
    return list(
        db.execute(
            select(MediaAsset)
            .where(
                MediaAsset.delivery_gallery_id == gallery_id,
                MediaAsset.status.not_in([MediaStatus.failed, MediaStatus.deleted]),
            )
            .order_by(MediaAsset.created_at.desc())
        ).scalars().all()
    )


def match_existing(
    live: list[MediaAsset], *, checksum: str, publish_key: str | None, image_sha256: str | None
) -> tuple[MediaAsset | None, MediaAsset | None]:
    """Among `live` (one niche, or one gig's gallery): (the same photo, or
    None; an older version of the same Lightroom photo, or None).

    The same photo is, in order:
    1. the same Lightroom photo (`publish_key`: per collection, or per gig)
       whose upload never finished: resumed, whatever the new render;
    2. the same Lightroom photo with the same picture (`image_sha256`) or
       the same file (`checksum`): Lightroom renders again on every export,
       and the export time it writes changes the file's hash;
    3. any of them with the same picture or the same file (a virtual copy,
       another catalog, a plug-in before 1.2.3/1.2.4).
    The same Lightroom photo with another picture was edited: not the same
    photo; it is returned second, as the version an edit may replace."""

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
    return None, next((a for a in keyed if a.status in _ON_SERVER), None)


def existing_copy(
    db: Session,
    pro_user_id: uuid.UUID,
    slug: str,
    *,
    checksum: str,
    publish_key: str | None = None,
    image_sha256: str | None = None,
) -> tuple[MediaAsset | None, MediaAsset | None]:
    """What the server has of this photo in this niche (match_existing).
    Another niche is never the same photo."""
    return match_existing(
        _live_in_niche(db, pro_user_id, slug), checksum=checksum, publish_key=publish_key, image_sha256=image_sha256
    )


# --- Replacing an edited photo's old version (1.2.4) -------------------------------------------
#
# The server removes the old version itself, when the new one is finished.
# It removes only a photo that is, all at once:
# - the same photographer's, published from Lightroom, processing or ready;
# - in the same niche as the new version;
# - the same Lightroom photo: the same publish key, or - for a photo
#   published before keys existed - the very photo Lightroom names as the
#   one this re-publish replaces;
# - not used by anything else (the profile cover, a gig gallery, a client's
#   selection, a banner, a dispute, a share link... any row that points at it).
# Deliveries are never replaced: an edited photo exported again is added.

#: The asset's own rows, not things that depend on it.
_OWN_TABLES = {"media_asset", "media_object", "media_derivative", "media_access_log"}
#: In media_asset.meta of a new version: the old one it replaces when finished.
REPLACES_KEY = "replaces"


#: What a table that points at a photo is, in the photographer's words.
_USE_NAMES = {
    "proof_gallery_item": "a client's gallery",
    "client_selection_item": "a client's selection",
    "review": "a review",
    "niche_banner": "a niche banner on Discover",
    "dispute_evidence": "a dispute",
    "share_link": "a share link",
    "content_pack": "a content pack",
}
COVER_REASON = "it is your profile cover"


def _json_uses():
    """Lists of photo ids kept as JSON, which a foreign key does not show:
    (column, what it is)."""
    from app.models.admin import DisputeMessage
    from app.models.commerce import Product
    from app.models.repair import RepairTicket
    from app.models.studioverse import ContentPack

    return [
        (DisputeMessage.evidence_media_asset_ids, "a dispute"),
        (ContentPack.preview_media_asset_ids, "a content pack"),
        (Product.images_media_asset_ids, "a product listing"),
        (RepairTicket.evidence_media_asset_ids, "a repair ticket"),
    ]


def depended_on(db: Session, asset: MediaAsset) -> str | None:
    """What uses this photo besides the portfolio, in plain words, or None.
    Every row of any table that points at it (a client's gallery or
    selection, a share link's access, a banner, a dispute, a review...), and
    the JSON lists of photo ids."""
    from app.models.media import Base

    if asset.delivery_gallery_id is not None or asset.purpose != MediaPurpose.portfolio_reel:
        return "it is part of a gig delivery"
    profile = db.get(ProProfile, asset.owner_user_id)
    if profile is not None and profile.cover_media_asset_id == asset.id:
        return COVER_REASON
    for table in Base.metadata.sorted_tables:
        if table.name in _OWN_TABLES:
            continue
        for fk in table.foreign_keys:
            if fk.column.table.name == "media_asset" and fk.column.name == "id":
                if db.execute(select(fk.parent).where(fk.parent == asset.id).limit(1)).first():
                    return "it is used in " + _USE_NAMES.get(table.name, "another part of RAWWERS (" + table.name.replace("_", " ") + ")")
    for column, name in _json_uses():
        if db.execute(select(column).where(column.contains([str(asset.id)])).limit(1)).first():
            return "it is used in " + name
    return None


def replaceable(
    db: Session,
    candidate: MediaAsset | None,
    *,
    pro_user_id: uuid.UUID,
    slug: str,
    publish_key: str | None,
    previous_id: uuid.UUID | None,
) -> tuple[MediaAsset | None, str | None]:
    """(the old version that may be removed, or None; why one was kept)."""
    if candidate is None:
        return None, None
    meta = candidate.meta or {}
    if (
        candidate.owner_user_id != pro_user_id
        or not is_from_lightroom(candidate)
        or meta.get(LIGHTROOM_NICHE_KEY) != slug
        or candidate.status not in _ON_SERVER
    ):
        return None, None
    same_photo = bool(publish_key) and meta.get(PUBLISH_KEY) == publish_key
    named_by_lightroom = previous_id is not None and candidate.id == previous_id and not meta.get(PUBLISH_KEY)
    if not (same_photo or named_by_lightroom):
        return None, None
    reason = depended_on(db, candidate)
    if reason:
        return None, f"The old version was kept in your portfolio: {reason}."
    return candidate, None


def old_version(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    slug: str,
    publish_key: str | None,
    previous_id: uuid.UUID | None,
    keyed: MediaAsset | None,
    new_id: uuid.UUID | None = None,
) -> tuple[MediaAsset | None, str | None]:
    """The old version this publish replaces: the one Lightroom names
    (`previous_id`), else an older one with the same key (`keyed`)."""
    named = db.get(MediaAsset, previous_id) if previous_id else None
    for candidate in (named, keyed):
        if candidate is not None and candidate.id != new_id:
            found, kept = replaceable(
                db, candidate, pro_user_id=pro_user_id, slug=slug, publish_key=publish_key, previous_id=previous_id
            )
            if found or kept:
                return found, kept
    return None, None


def published_copy(db: Session, pro_user_id: uuid.UUID, slug: str, checksum: str) -> MediaAsset | None:
    """This file, already published from Lightroom to this niche (the
    file-hash guard alone, as before 1.2.3)."""
    return existing_copy(db, pro_user_id, slug, checksum=checksum)[0]


def mark_published(
    asset: MediaAsset,
    *,
    slug: str,
    checksum: str,
    publish_key: str | None = None,
    image_sha256: str | None = None,
    replaces: uuid.UUID | None = None,
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
    if replaces:
        meta[REPLACES_KEY] = str(replaces)
    asset.meta = meta
    asset.niche_tags = [slug]


def resume_with(db: Session, asset: MediaAsset, *, checksum: str, image_sha256: str | None) -> None:
    """A waiting upload taken over by a new render of the same photo: the
    finish and the worker check the new file's hash. Parts of the old
    render already in storage are no use with the new one: dropped, so the
    upload starts its parts again."""
    from app.services.storage import abort_multipart_upload

    if asset.status not in _WAITING:
        return
    meta = dict(asset.meta or {})
    if asset.checksum != checksum and meta.get("multipart"):
        original = db.execute(
            select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant == MediaVariant.original)
        ).scalar_one_or_none()
        if original is not None:
            try:
                abort_multipart_upload(original.storage_key, meta["multipart"]["upload_id"])
            except Exception:
                logger.warning("resumed upload %s: storage did not drop the old parts", asset.id, exc_info=True)
        meta.pop("multipart", None)
    asset.checksum = checksum
    if image_sha256:
        meta[IMAGE_SHA_KEY] = image_sha256.lower()
    asset.meta = meta


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


class Finished:
    """What a finish did: the photo's status, and the old version it
    replaced (or why it was kept)."""

    def __init__(self, status: MediaStatus, replaced: uuid.UUID | None = None, old_kept: str | None = None):
        self.status, self.replaced, self.old_kept = status, replaced, old_kept


def replace_old_version(db: Session, asset: MediaAsset) -> tuple[uuid.UUID | None, str | None]:
    """Removes the old version a finished photo was started to replace, if
    it still may be (the rules above, checked again now). The caller holds
    lock_pro_for_recompute and commits."""
    meta = asset.meta or {}
    old_id = meta.get(REPLACES_KEY)
    if not old_id or asset.status not in _ON_SERVER:
        return None, None
    old = db.get(MediaAsset, uuid.UUID(old_id))
    found, kept = replaceable(
        db,
        old,
        pro_user_id=asset.owner_user_id,
        slug=meta.get(LIGHTROOM_NICHE_KEY),
        publish_key=meta.get(PUBLISH_KEY),
        previous_id=old.id if old is not None and not (old.meta or {}).get(PUBLISH_KEY) else None,
    )
    asset.meta = {k: v for k, v in meta.items() if k != REPLACES_KEY}
    if found is None:
        return None, kept
    remove(db, found)
    return found.id, None


def finish(db: Session, asset: MediaAsset, *, byte_size: int | None) -> Finished:
    """The file is in storage: the photo goes to processing and its niche's
    skills and the Discover index are recomputed, in one transaction (before
    1.2.3 the photo was committed as processing first, so a failed recompute
    left it processing, untagged, and refused the plug-in's retry). The old
    version it replaces, if any, is removed in the same transaction.
    Finishing a photo that is already processing or ready answers its status
    again. Commits; the worker is queued after the commit."""
    from app.services.photo_uploads import max_photo_bytes
    from app.services.niche_skills import lock_pro_for_recompute
    from app.tasks.media_tasks import process_photo_variants

    lock_pro_for_recompute(db, asset.owner_user_id)
    db.refresh(asset)
    if asset.status in _ON_SERVER:
        ensure_tagged(db, asset)
        replaced, kept = replace_old_version(db, asset)
        db.commit()
        return Finished(asset.status, replaced, kept)
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
    replaced, kept = replace_old_version(db, asset)
    db.commit()
    process_photo_variants.delay(str(asset.id))
    return Finished(asset.status, replaced, kept)


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


# --- A photographer removing their own portfolio photo ------------------------------------------
#
# One path for the plug-in (DELETE /v1/delivery/portfolio/{id}: only photos it
# published) and the Pro app (DELETE /v1/pro/me/portfolio/{id}: any of their
# portfolio photos), owner's request of 2026-11-17 (BETA_SCOPE #11, first
# half). Checked in this order:
# - the photographer's own portfolio photo, else 404 (a token or an app
#   learns nothing about anyone else's photos);
# - removed already: success, nothing changes, nothing is recorded;
# - used by anything but the cover (depended_on): kept, 409 photo_in_use;
# - a live photographer (approved for the public) may not drop below the
#   portfolio minimum (portfolio_min_items, 12): 409 portfolio_minimum.
# Then remove() below, and an audit record. The cover may be removed: it is
# cleared, and another of their ready photos is shown until they choose one
# (services/profile_cover.py).

#: In media_asset.meta of a removed photo: who removed it ("app",
#: "lightroom"). A photo removed in the app is never sent again by an edit
#: re-published from Lightroom (start_portfolio_upload refuses it).
REMOVED_KEY = "removed"


def is_live(db: Session, pro_user_id: uuid.UUID) -> bool:
    """Approved for the public: the listing clients can find."""
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    onboarding = db.get(ProOnboarding, pro_user_id)
    return onboarding is not None and onboarding.status == ProOnboardingStatus.approved_public


def require_minimum_kept(db: Session, asset: MediaAsset) -> None:
    """A live photographer keeps at least the portfolio minimum, counted as
    onboarding counts it (ready portfolio photos and videos). A photo not
    ready yet counts for nothing, so removing it is always allowed."""
    from sqlalchemy import func

    from app.services.launch_ops import requirement_value

    if asset.status != MediaStatus.ready or not is_live(db, asset.owner_user_id):
        return
    minimum = int(requirement_value(db, "portfolio_min_items", {"count": 12}).get("count", 12))
    ready = db.execute(
        select(func.count()).select_from(MediaAsset).where(
            MediaAsset.owner_user_id == asset.owner_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
    ).scalar_one()
    if ready - 1 < minimum:
        raise APIError(
            code="portfolio_minimum",
            message=f"Add another photo first, then remove this one. A live listing needs at least {minimum} photos.",
            status_code=409,
        )


def remove_own_photo(
    db: Session,
    pro_user_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    *,
    source: str,
    lightroom_only: bool,
) -> tuple[MediaAsset, bool, bool]:
    """Removes one of this photographer's portfolio photos by the rules
    above. Returns (the photo, whether it was removed now, whether it was
    the cover). The caller commits."""
    from app.services.audit import add_admin_audit_log
    from app.services.niche_skills import lock_pro_for_recompute

    asset = db.get(MediaAsset, media_asset_id)
    if (
        asset is None
        or asset.owner_user_id != pro_user_id
        or asset.purpose != MediaPurpose.portfolio_reel
        or asset.kind not in (MediaKind.photo, MediaKind.video)
        or (lightroom_only and not is_from_lightroom(asset))
    ):
        raise APIError(code="not_found", message="Photo not found", status_code=404)
    if asset.status == MediaStatus.deleted:
        return asset, False, False
    # One removal (or recompute) at a time per photographer: two removals at
    # once cannot both pass the minimum.
    lock_pro_for_recompute(db, pro_user_id)
    db.refresh(asset)
    if asset.status == MediaStatus.deleted:
        return asset, False, False
    reason = depended_on(db, asset)
    if reason and reason != COVER_REASON:
        raise APIError(code="photo_in_use", message=f"This photo was kept in your portfolio: {reason}.", status_code=409)
    require_minimum_kept(db, asset)
    was_cover = reason == COVER_REASON
    remove(db, asset, source=source)
    add_admin_audit_log(
        db,
        actor_user_id=pro_user_id,
        target_type="media_asset",
        target_id=str(asset.id),
        action="portfolio_photo_removed",
        metadata={"source": source, "was_cover": was_cover, "from_lightroom": is_from_lightroom(asset)},
    )
    return asset, True, was_cover


def removed_in_app(db: Session, pro_user_id: uuid.UUID, *, limit: int = 2000) -> list[uuid.UUID]:
    """This photographer's Lightroom photos removed in the Pro app, newest
    first: what the plug-in must not send again unasked (1.2.5)."""
    rows = db.execute(
        select(MediaAsset.id, MediaAsset.meta)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.deleted,
        )
        .order_by(MediaAsset.updated_at.desc())
    ).all()
    found = [asset_id for asset_id, meta in rows if (meta or {}).get(REMOVED_KEY) == "app" and (meta or {}).get(LIGHTROOM_NICHE_KEY)]
    return found[:limit]


REMOVED_IN_APP_MESSAGE = (
    "This photo was removed from your portfolio in the RAWWERS Pro app, so it was not sent again. "
    "To publish it again, take it out of this collection, publish, then add it back."
)


def refuse_resending_removed(db: Session, pro_user_id: uuid.UUID, previous_id: uuid.UUID | None) -> None:
    """A re-publish (an edit, or "Mark to Republish") names the photo it
    replaces. If the photographer removed that photo in the Pro app, it is
    not sent again on the plug-in's own initiative, whatever the plug-in's
    version: they put it back by adding the photo to the collection again."""
    if previous_id is None:
        return
    old = db.get(MediaAsset, previous_id)
    if old is None or old.owner_user_id != pro_user_id or old.status != MediaStatus.deleted:
        return
    if (old.meta or {}).get(REMOVED_KEY) == "app":
        raise APIError(code="photo_removed_in_app", message=REMOVED_IN_APP_MESSAGE, status_code=409)


def own_published(db: Session, pro_user_id: uuid.UUID, media_asset_id: uuid.UUID) -> MediaAsset:
    """A photo this photographer published from Lightroom; anything else is
    the same 404, so the token learns nothing about other photos."""
    asset = db.get(MediaAsset, media_asset_id)
    if asset is None or asset.owner_user_id != pro_user_id or not is_from_lightroom(asset):
        raise APIError(code="not_found", message="Photo not found", status_code=404)
    reason = depended_on(db, asset)
    if reason and reason != COVER_REASON:
        # The cover is cleared by the removal, as before; anything else that
        # points at the photo keeps it.
        raise APIError(code="photo_in_use", message=f"This photo was kept in your portfolio: {reason}.", status_code=409)
    return asset


def remove(db: Session, asset: MediaAsset, *, source: str = "lightroom") -> None:
    """Takes the photo out of the portfolio: no longer listed or served
    (every list reads `ready` only), no longer the cover, its niches'
    skills and the Discover index recomputed, and its files deleted from
    storage (left for the unfinished-uploads sweep if storage does not
    answer). Removing it again changes nothing. No rule is checked here:
    remove_own_photo checks them for a photographer's own removal; the
    replacement of an edited photo's old version checks its own."""
    from app.services.discovery_index import recompute_pro_public_index
    from app.services.niche_skills import recompute_pro_niche_skills
    from app.services.storage import delete_object

    if asset.status == MediaStatus.deleted:
        return
    asset.status = MediaStatus.deleted
    asset.meta = {**(asset.meta or {}), REMOVED_KEY: source}
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
