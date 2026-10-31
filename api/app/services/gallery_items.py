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

from sqlalchemy import func, select
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
    db.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=next_sort_order(db, gallery.id)))
    db.flush()
    return True
