"""An admin's decision on a hold a client's reported problem placed.

Owner's decision (2026-11-02). "Report a problem" (download_gate) holds the
photographer's earning for the booking. On its money-attention item an admin
releases the hold or keeps it, each with a note; closing the item without
saying which is refused, so a hold is never left open silently. No refund
is made here: that belongs to the cancellation and refund rules.
"""
from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.admin import MoneyAttentionItem
from app.models.payouts import EarningsEntryStatus, EarningsHold, EarningsLedgerEntry, EarningsSourceType
from app.models.review import ProblemReport
from app.services.payouts import _entry_should_be_held, refresh_earnings_balance_snapshot, release_earnings_hold

#: What an admin may decide for an item with an open hold.
HOLD_OUTCOMES = ("release", "keep")


def open_hold_for_item(db: Session, item: MoneyAttentionItem) -> EarningsHold | None:
    """The hold this item is about, while it is still on: a reported
    problem's. None for every other kind of item, and once released."""
    if item.kind != "client_reported_problem" or item.gig_id is None:
        return None
    report = db.execute(select(ProblemReport).where(ProblemReport.gig_id == item.gig_id)).scalar_one_or_none()
    if report is None or report.earnings_hold_id is None:
        return None
    hold = db.get(EarningsHold, report.earnings_hold_id)
    return hold if hold is not None and hold.released_at is None else None


def release_to_settlement_date(db: Session, hold: EarningsHold) -> None:
    """Release the hold. An earning already due settles now, as any release
    does; one not yet due goes back to waiting for its own date, unless
    another hold still covers it."""
    release_earnings_hold(db, hold)
    if not hold.source_type or not hold.source_id:
        return
    now = datetime.now(timezone.utc)
    rows = db.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.pro_user_id == hold.pro_user_id,
            EarningsLedgerEntry.source_type == EarningsSourceType(hold.source_type),
            EarningsLedgerEntry.source_id == hold.source_id,
            EarningsLedgerEntry.status == EarningsEntryStatus.held,
            EarningsLedgerEntry.available_at > now,
            EarningsLedgerEntry.reversed_at.is_(None),
        )
    ).scalars().all()
    changed = False
    for row in rows:
        if not _entry_should_be_held(db, pro_user_id=row.pro_user_id, source_type=row.source_type.value, source_id=row.source_id):
            row.status = EarningsEntryStatus.pending
            row.updated_at = now
            changed = True
    if changed:
        db.flush()
        refresh_earnings_balance_snapshot(db, pro_user_id=hold.pro_user_id)
