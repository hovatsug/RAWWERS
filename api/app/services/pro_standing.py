"""Whether a photographer may take bookings - one rule, asked by everyone.

The discovery index (so Discover, the home rows, Available now and search),
both booking-request routes and both answer paths (accept, confirm-slot) ask
`booking_block_reason`. A banned photographer, or one suspended until a time
not yet reached, is out of all of them: whatever BAN_ENFORCEMENT_MODE says
about their own requests, and whatever the dev override says about
unverified photographers.

Bookings already paid are never touched by it. A ban lists them for an admin
("Money to act on") so a person decides what happens to each.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.admin import BanAction, BanActionType, MoneyAttentionItem, ProProfile
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus

SHUT_OUT = "shut_out"
#: Paid bookings a ban leaves in the photographer's hands. Not completed
#: (nothing left to deliver) and not payment_pending (the unpaid sweep ends
#: those).
_OPEN_PAID_STATUSES = (
    GigStatus.paid,
    GigStatus.scheduled,
    GigStatus.shoot_done,
    GigStatus.proofs_delivered,
    GigStatus.selection_pending,
    GigStatus.final_delivered,
    GigStatus.disputed,
)
BOOKING_REVIEW_KIND = "pro_shut_out_booking"


def latest_ban_action(db: Session, user_id: uuid.UUID) -> BanAction | None:
    return db.execute(
        select(BanAction).where(BanAction.user_id == user_id).order_by(BanAction.created_at.desc(), BanAction.starts_at.desc())
    ).scalars().first()


def is_shut_out(action: BanAction | None, *, now: datetime | None = None) -> bool:
    """Banned, or suspended until a time not yet reached."""
    if action is None:
        return False
    if action.action == BanActionType.banned:
        return True
    if action.action == BanActionType.suspended:
        return action.ends_at is None or (now or datetime.now(timezone.utc)) < action.ends_at
    return False


def booking_block_reason(db: Session, pro_user_id: uuid.UUID) -> str | None:
    """Why this photographer may not take bookings now, or None."""
    if is_shut_out(latest_ban_action(db, pro_user_id)):
        return SHUT_OUT
    return None


def list_open_bookings_for_review(db: Session, pro_user_id: uuid.UUID, *, why: str) -> int:
    """One open admin item per paid booking still in the photographer's
    hands, never two for the same booking. Returns how many were added."""
    gigs = db.execute(
        select(Gig).where(Gig.pro_user_id == pro_user_id, Gig.status.in_(_OPEN_PAID_STATUSES))
    ).scalars().all()
    added = 0
    for gig in gigs:
        listed = db.execute(
            select(MoneyAttentionItem.id).where(
                MoneyAttentionItem.kind == BOOKING_REVIEW_KIND,
                MoneyAttentionItem.gig_id == gig.id,
                MoneyAttentionItem.status == "open",
            )
        ).first()
        if listed:
            continue
        db.add(MoneyAttentionItem(
            kind=BOOKING_REVIEW_KIND, status="open", gig_id=gig.id, client_user_id=gig.client_user_id,
            amount=gig.amount_final if gig.amount_final is not None else gig.amount_minimum, currency=gig.currency,
            note=f"{why}: this paid booking needs a person - rebook it with another photographer, or refund the client.",
        ))
        added += 1
    db.flush()
    return added


def relist_after_suspensions(db: Session, *, now: datetime | None = None) -> int:
    """Photographers whose suspension has run out, put back in the index.
    Returns how many were relisted."""
    from app.services.discovery_index import recompute_pro_public_index

    now = now or datetime.now(timezone.utc)
    candidates = db.execute(
        select(ProPublicIndex.pro_user_id)
        .join(ProProfile, ProProfile.user_id == ProPublicIndex.pro_user_id)
        .where(ProPublicIndex.is_accepting_bookings.is_(False), ProProfile.is_accepting_bookings.is_(True))
    ).scalars().all()
    relisted = 0
    for pro_user_id in candidates:
        action = latest_ban_action(db, pro_user_id)
        if action is None or action.action != BanActionType.suspended or is_shut_out(action, now=now):
            continue
        recompute_pro_public_index(db, pro_user_id)
        relisted += 1
    db.flush()
    return relisted
