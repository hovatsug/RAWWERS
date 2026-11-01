"""What a delivery token may see: the gigs that can take photos, and little else.

The plugin's client picker needs to tell one booking from another, nothing
more: the client's first name and last initial, the shoot date, the package
or niche, how many photos it includes, and how far the delivery has got. A
client with no usable name is shown by the start of their email address, cut
the same way, and failing that by the booking ("Client #3461c5"): a row is
never dropped or left blank.
Everything returned is built here, field by field - no model is handed out
whole - so nothing else about the client (email, phone, address, messages,
payments) and nothing about money can leak through a field added to a model
later. tests/test_delivery_gigs.py holds it to that.
"""
from __future__ import annotations

import re
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import UserAccount
from app.models.booking import ConfirmedSlot
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.gig import Gig
from app.models.media import MediaAsset, MediaStatus
from app.schemas.delivery import DeliveryGigView
from app.services.gig_state import GALLERY_DELIVERABLE_STATUSES

_NOT_A_NAME = re.compile(r"[@\d]")
_EMAIL_SEPARATORS = re.compile(r"[._+\-]+")


def client_short_name(display_name: str | None) -> str | None:
    """'Ana Maria Silva' -> 'Ana S.'. None for no name, or one that looks like
    an email address or a phone number."""
    parts = (display_name or "").split()
    if not parts or any(_NOT_A_NAME.search(part) for part in parts):
        return None
    if len(parts) == 1:
        return parts[0][:40]
    return f"{parts[0][:40]} {parts[-1][0].upper()}."


def _email_name(email: str | None) -> str | None:
    """'ana.maria.silva@x' -> 'ana S.': the part before the @, split where a
    name would be, without the pieces that hold digits."""
    if not email or "@" not in email:
        return None
    words = [w for w in _EMAIL_SEPARATORS.split(email.split("@", 1)[0]) if w and not _NOT_A_NAME.search(w)]
    return client_short_name(" ".join(words))


def client_label(display_name: str | None, email: str | None, gig_id: uuid.UUID) -> str:
    """The client as the picker shows them: never blank, never their email."""
    return client_short_name(display_name) or _email_name(email) or f"Client #{str(gig_id)[:6]}"


def _shoot_start(db: Session, gig: Gig) -> datetime | None:
    if gig.scheduled_start is not None:
        return gig.scheduled_start
    slot = db.execute(select(ConfirmedSlot.start_at_utc).where(ConfirmedSlot.gig_id == gig.id)).scalar_one_or_none()
    return slot


def _counts(db: Session, gallery_id: uuid.UUID | None) -> tuple[int, int]:
    if gallery_id is None:
        return 0, 0
    in_gallery = db.execute(select(func.count()).select_from(ProofGalleryItem).where(ProofGalleryItem.gallery_id == gallery_id)).scalar_one()
    processing = db.execute(
        select(func.count())
        .select_from(MediaAsset)
        .where(MediaAsset.delivery_gallery_id == gallery_id, MediaAsset.status == MediaStatus.processing)
    ).scalar_one()
    return int(in_gallery), int(processing)


def deliverable_gigs(db: Session, pro_user_id: uuid.UUID) -> list[DeliveryGigView]:
    """The photographer's gigs that can receive photos from the plugin: paid
    and still open (paid, scheduled, shoot_done), and not yet sent to the
    client. A gallery in progress can take more. A shoot still to come is
    listed too: the pro app may make, fill and send a gallery for a paid
    booking at any time, and nothing here is sent to the client. Soonest
    shoot first."""
    rows = db.execute(
        select(Gig, ProofGallery)
        .outerjoin(ProofGallery, ProofGallery.gig_id == Gig.id)
        .where(Gig.pro_user_id == pro_user_id, Gig.status.in_(GALLERY_DELIVERABLE_STATUSES))
    ).all()
    views: list[tuple[datetime | None, DeliveryGigView]] = []
    for gig, gallery in rows:
        if gallery is not None and gallery.status != ProofGalleryStatus.draft:
            continue
        start = _shoot_start(db, gig)
        meta = gig.meta or {}
        snapshot = meta.get("pricing_snapshot") if isinstance(meta.get("pricing_snapshot"), dict) else {}
        included = gallery.included_photos if gallery is not None else snapshot.get("included_photos")
        in_gallery, processing = _counts(db, gallery.id if gallery else None)
        client = db.get(UserAccount, gig.client_user_id)
        views.append(
            (
                start,
                DeliveryGigView(
                    gig_id=gig.id,
                    gallery_id=gallery.id if gallery else None,
                    client_name=client_label(client.display_name if client else None, client.email if client else None, gig.id),
                    shoot_starts_at=start,
                    shoot_starts_at_epoch=int(start.timestamp()) if start else None,
                    package_title=snapshot.get("package_title") if isinstance(snapshot.get("package_title"), str) else None,
                    niche_name=meta.get("niche_name") if isinstance(meta.get("niche_name"), str) else None,
                    included_photos=included if isinstance(included, int) and not isinstance(included, bool) else 10,
                    delivery_state="in_progress" if in_gallery or processing else "waiting_for_photos",
                    photos_in_gallery=in_gallery,
                    photos_processing=processing,
                ),
            )
        )
    far_future = datetime.max.replace(tzinfo=timezone.utc)
    views.sort(key=lambda pair: pair[0] or far_future)
    return [view for _, view in views]


def own_gig(db: Session, pro_user_id: uuid.UUID, gig_id: uuid.UUID) -> Gig:
    """The photographer's gig, or the same 404 whether it is someone else's
    or does not exist: a token learns nothing about other gigs."""
    gig = db.get(Gig, gig_id)
    if gig is None or gig.pro_user_id != pro_user_id:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    return gig
