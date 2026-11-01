"""Putting a photo into a proof gallery: the rules, and the server-side attach.

Two ways in, one set of rules. The pro app attaches each photo itself
(`POST /proof-galleries/{id}/items`), retrying until its watermark preview is
ready. A delivery that named its gallery when it started (`delivery_gallery_id`)
is attached here, by the worker, the moment processing finishes - so nothing
has to stay open on the photographer's side for photos to land (owner's
decision 3). The app's attach stays as the fallback, and the two can meet:
both lock the gallery row first, so one of them adds the photo and the other
finds it there.
"""
from __future__ import annotations

import logging

from sqlalchemy import and_, func, or_, select, update
from sqlalchemy.orm import Session

from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaStatus, MediaVariant, ObjectStatus
from app.services.gig_state import GALLERY_DELIVERABLE_STATUSES

logger = logging.getLogger(__name__)

#: A gallery being put together, or open for selection. Not after the
#: selection is made.
OPEN_GALLERY_STATUSES = frozenset({ProofGalleryStatus.draft, ProofGalleryStatus.published})


def lock_gallery(db: Session, gallery_id) -> ProofGallery | None:
    """The gallery, locked until the transaction ends, so two attaches cannot
    both take the same next place or both add the same photo."""
    return db.execute(select(ProofGallery).where(ProofGallery.id == gallery_id).with_for_update()).scalar_one_or_none()


def next_sort_order(db: Session, gallery_id) -> int:
    """After the last photo in the gallery. Call with the gallery locked."""
    last = db.execute(select(func.max(ProofGalleryItem.sort_order)).where(ProofGalleryItem.gallery_id == gallery_id)).scalar_one()
    return (last or 0) + 1


#: Where a delivery's export position is kept (`MediaAsset.meta`): the n-th
#: photo of the Lightroom export that sent it (owner's decision 3).
DELIVERY_POSITION_KEY = "delivery_position"


#: Which export a delivery came in, as the plug-in names it, and that
#: export's number in its gallery: 1 for the first export to arrive there, 2
#: for the next (owner's decision, 2026-11-01: each export follows the one
#: before it as a block). A delivery with a position but no number - from a
#: plug-in that names no export (1.0.0) - counts as export 0.
DELIVERY_EXPORT_KEY = "delivery_export"
DELIVERY_EXPORT_NUMBER_KEY = "delivery_export_number"


def _meta_int(asset: MediaAsset, key: str) -> int | None:
    value = (asset.meta or {}).get(key)
    return value if isinstance(value, int) and not isinstance(value, bool) else None


def delivery_position(asset: MediaAsset) -> int | None:
    return _meta_int(asset, DELIVERY_POSITION_KEY)


def delivery_place(asset: MediaAsset) -> tuple[int, int] | None:
    """(export number, position), the order the gallery keeps; None for a
    photo with no position."""
    position = delivery_position(asset)
    if position is None:
        return None
    return (_meta_int(asset, DELIVERY_EXPORT_NUMBER_KEY) or 0, position)


def export_number(db: Session, gallery_id, export_id: str) -> int:
    """The number of the export `export_id` in this gallery: the one it was
    given when its first photo started, or the next one. Call with the gallery
    locked, so two photos of a new export starting at once get the same
    number and two new exports do not."""
    known = db.execute(
        select(MediaAsset.meta[DELIVERY_EXPORT_NUMBER_KEY].as_integer())
        .where(MediaAsset.delivery_gallery_id == gallery_id, MediaAsset.meta[DELIVERY_EXPORT_KEY].astext == export_id)
        .limit(1)
    ).scalar_one_or_none()
    if known is not None:
        return known
    last = db.execute(
        select(func.max(MediaAsset.meta[DELIVERY_EXPORT_NUMBER_KEY].as_integer())).where(MediaAsset.delivery_gallery_id == gallery_id)
    ).scalar_one()
    return (last or 0) + 1


def place_for_delivery(db: Session, gallery_id, place: tuple[int, int] | None) -> int:
    """The place for a delivery, in export order. Call with the gallery locked.

    Processing finishes in any order, so the place is chosen as the photo
    joins: just before the first delivered photo that comes after it - from a
    later export, or later in the same export - the photos from there on
    moving down one; with none, or no position, after everything. Photos the
    phone added keep their order, and the same place twice keeps the order
    they arrived.
    """
    if place is None:
        return next_sort_order(db, gallery_id)
    number, position = place
    their_number = func.coalesce(MediaAsset.meta[DELIVERY_EXPORT_NUMBER_KEY].as_integer(), 0)
    their_position = MediaAsset.meta[DELIVERY_POSITION_KEY].as_integer()
    later = db.execute(
        select(func.min(ProofGalleryItem.sort_order))
        .join(MediaAsset, MediaAsset.id == ProofGalleryItem.media_asset_id)
        .where(
            ProofGalleryItem.gallery_id == gallery_id,
            their_position.is_not(None),
            or_(their_number > number, and_(their_number == number, their_position > position)),
        )
    ).scalar_one()
    if later is None:
        return next_sort_order(db, gallery_id)
    db.execute(
        update(ProofGalleryItem)
        .where(ProofGalleryItem.gallery_id == gallery_id, ProofGalleryItem.sort_order >= later)
        .values(sort_order=ProofGalleryItem.sort_order + 1)
        .execution_options(synchronize_session="fetch")
    )
    return later


def has_ready_watermark_preview(db: Session, asset_id) -> bool:
    """What a client sees in the gallery; a photo without one cannot join."""
    return (
        db.execute(
            select(MediaObject.id).where(
                MediaObject.media_asset_id == asset_id,
                MediaObject.variant == MediaVariant.watermark_preview,
                MediaObject.status == ObjectStatus.ready,
            )
        ).first()
        is not None
    )


def is_in_gallery(db: Session, gallery_id, asset_id) -> bool:
    return (
        db.execute(
            select(ProofGalleryItem.id).where(ProofGalleryItem.gallery_id == gallery_id, ProofGalleryItem.media_asset_id == asset_id)
        ).first()
        is not None
    )


def attach_delivered_proof(db: Session, asset: MediaAsset) -> bool:
    """Add a processed delivery to the gallery it was uploaded for.

    Called by the worker with the photo just marked ready, in the same
    transaction. Whatever stops it - no gallery named, the gallery closed or
    the booking cancelled since the upload began, the photo already there -
    is not an error: the photo stays processed, and the photographer still
    sees it in their uploads. Returns whether it was added.
    """
    if asset.delivery_gallery_id is None or asset.kind != MediaKind.photo or asset.status != MediaStatus.ready:
        return False
    gallery = lock_gallery(db, asset.delivery_gallery_id)
    if gallery is None or gallery.pro_user_id != asset.owner_user_id or gallery.status not in OPEN_GALLERY_STATUSES:
        return False
    gig = db.get(Gig, gallery.gig_id)
    if gig is None or gig.status not in GALLERY_DELIVERABLE_STATUSES:
        return False
    if not has_ready_watermark_preview(db, asset.id) or is_in_gallery(db, gallery.id, asset.id):
        return False
    sort_order = place_for_delivery(db, gallery.id, delivery_place(asset))
    db.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=sort_order))
    db.flush()
    return True
