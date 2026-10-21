"""A dispute pauses a booking; one that ends without a refund gives it back.

enter_dispute stores the status a gig had before its dispute - whether the
client or photographer opened it, or Stripe reported a chargeback - and
leave_dispute_without_refund returns the gig to it once no dispute on it is
still open. `disputed` holds the calendar (bookable_time), so the time a
disputed shoot was booked for is not given away meanwhile.

Neither goes through ALLOWED_TRANSITIONS: entering is possible from any
status a dispute can be opened on (a chargeback can come after completion),
and leaving goes only to the stored status. The admin status route still
cannot move a disputed gig anywhere (test_admin_gig_status).
"""
from __future__ import annotations

import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.admin import Dispute, DisputeStatus
from app.models.gig import Gig, GigStatus, GigTransition

OPEN_DISPUTE_STATUSES = (
    DisputeStatus.open,
    DisputeStatus.awaiting_response,
    DisputeStatus.in_review,
    DisputeStatus.awaiting_admin,
    DisputeStatus.under_review,
)


def enter_dispute(db: Session, gig: Gig, *, actor_user_id: uuid.UUID, reason: str) -> None:
    if gig.status == GigStatus.disputed:
        return
    gig.meta = {**(gig.meta or {}), "pre_dispute_status": gig.status.value}
    db.add(GigTransition(gig_id=gig.id, from_status=gig.status, to_status=GigStatus.disputed, actor_user_id=actor_user_id, reason=reason))
    gig.status = GigStatus.disputed


def leave_dispute_without_refund(db: Session, gig: Gig | None, *, actor_user_id: uuid.UUID, reason: str) -> bool:
    """Back to the stored status, if the gig is still disputed and no other
    dispute on it is open. Call after the dispute's own status has changed."""
    if gig is None or gig.status != GigStatus.disputed:
        return False
    db.flush()
    still_open = db.execute(
        select(Dispute.id).where(Dispute.gig_id == gig.id, Dispute.status.in_(OPEN_DISPUTE_STATUSES))
    ).first()
    if still_open:
        return False
    back_to = GigStatus((gig.meta or {}).get("pre_dispute_status") or GigStatus.paid.value)
    db.add(GigTransition(gig_id=gig.id, from_status=GigStatus.disputed, to_status=back_to, actor_user_id=actor_user_id, reason=reason))
    gig.status = back_to
    meta = dict(gig.meta or {})
    meta.pop("pre_dispute_status", None)
    gig.meta = meta
    return True
