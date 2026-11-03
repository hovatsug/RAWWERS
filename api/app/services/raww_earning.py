"""A booking's RAWW: its 5% credit, following its earning.

Owner's decision (2026-11-03). When a booking's earning is recorded, the
photographer earns round(final_pro_raww / raww_eur_value) RAWW, the rate
stamped on the entry. They are pending until that earning is available with
no hold on it - the earning's state, not a date - and go back to pending if
it is held again. A refund or price reduction recomputes the target from
the new `final_pro_raww` at the original rate and writes the difference; a
booking that earned nothing loses them all. Spent RAWW are not clawed back
from cash: the spendable balance goes negative instead.

`sync_booking_raww` is called wherever a booking's earning is written
(photographer_money.record_gig_earnings); `sync_pro_raww_status` wherever an
earning's state changes (payouts.refresh_earnings_balance_snapshot, which
every such path already calls).
"""
from __future__ import annotations

import uuid
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from app.models.gig import Gig
from app.models.payouts import EarningsEntryStatus, EarningsHold, EarningsLedgerEntry, EarningsSourceType
from app.models.shelf import BOOKING_KINDS, ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus
from app.services import raww_ledger as ledger
from app.services.shelf_settings import shelf_settings


def raww_for(eur: Decimal, raww_eur_value: Decimal) -> int:
    """Whole RAWW for a euro amount, to the nearest."""
    return int((Decimal(eur) / Decimal(raww_eur_value)).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def _earning(db: Session, gig: Gig) -> EarningsLedgerEntry | None:
    return db.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
            EarningsLedgerEntry.source_id == gig.id,
            EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
        )
    ).scalar_one_or_none()


def _active_holds(db: Session, pro_user_id: uuid.UUID) -> tuple[bool, set[uuid.UUID]]:
    """(a hold on all their earnings, the gigs with a hold of their own)."""
    rows = db.execute(
        select(EarningsHold.source_type, EarningsHold.source_id).where(
            EarningsHold.pro_user_id == pro_user_id,
            EarningsHold.released_at.is_(None),
            or_(
                and_(EarningsHold.source_type.is_(None), EarningsHold.source_id.is_(None)),
                EarningsHold.source_type == EarningsSourceType.gig_base.value,
            ),
        )
    ).all()
    return any(t is None for t, _ in rows), {sid for t, sid in rows if t is not None}


def _wanted(earning: EarningsLedgerEntry | None, holds: tuple[bool, set[uuid.UUID]]) -> RawwEntryStatus:
    everything_held, held_gigs = holds
    if (
        earning is not None
        and earning.status == EarningsEntryStatus.available
        and earning.reversed_at is None
        and not everything_held
        and earning.source_id not in held_gigs
    ):
        return RawwEntryStatus.spendable
    return RawwEntryStatus.pending


def sync_booking_raww(db: Session, gig: Gig) -> None:
    """Bring a booking's RAWW in line with its earning: amount and state."""
    earning = _earning(db, gig)
    first = db.execute(
        select(ProRawwLedgerEntry).where(
            ProRawwLedgerEntry.pro_user_id == gig.pro_user_id,
            ProRawwLedgerEntry.kind == RawwEntryKind.earn_booking,
            ProRawwLedgerEntry.source_type == "gig",
            ProRawwLedgerEntry.source_id == str(gig.id),
        )
    ).scalar_one_or_none()
    if earning is None and first is None:
        return
    # Everything below under the photographer's lock: the net and the target
    # are read and written as one, so two refunds at once cannot both apply
    # their difference to the same starting point.
    ledger.balance_locked(db, gig.pro_user_id)
    rate = first.raww_eur_value if first is not None else shelf_settings(db).raww_eur_value
    earned = earning is not None and earning.status != EarningsEntryStatus.reversed and gig.final_pro_raww is not None
    target = raww_for(gig.final_pro_raww, rate) if earned else 0
    status = _wanted(earning, _active_holds(db, gig.pro_user_id))
    common = dict(
        pro_user_id=gig.pro_user_id,
        status=status,
        gig_id=gig.id,
        raww_eur_value=rate,
        eur_basis=gig.final_pro_raww,
        source_type="gig",
    )
    if first is None:
        ledger.post_entry(db, kind=RawwEntryKind.earn_booking, amount=target, source_id=str(gig.id), **common)
    else:
        net = ledger.booking_net(db, pro_user_id=gig.pro_user_id, gig_id=gig.id)
        if target != net:
            ledger.post_entry(
                db,
                kind=RawwEntryKind.reverse_booking if target < net else RawwEntryKind.earn_booking,
                amount=target - net,
                # The change from one total to another: the same recompute
                # twice is the same entry.
                source_id=f"{gig.id}:{net}->{target}",
                **common,
            )
    ledger.set_booking_status(db, pro_user_id=gig.pro_user_id, gig_id=gig.id, status=status)


def sync_pro_raww_status(db: Session, pro_user_id: uuid.UUID) -> int:
    """Move each of a photographer's bookings' RAWW to the state its
    earning is in now. Returns how many bookings moved."""
    rows = db.execute(
        select(ProRawwLedgerEntry.gig_id, ProRawwLedgerEntry.status)
        .where(
            ProRawwLedgerEntry.pro_user_id == pro_user_id,
            ProRawwLedgerEntry.kind.in_(BOOKING_KINDS),
            ProRawwLedgerEntry.gig_id.is_not(None),
        )
        .distinct()
    ).all()
    if not rows:
        return 0
    statuses: dict[uuid.UUID, set[RawwEntryStatus]] = {}
    for gig_id, status in rows:
        statuses.setdefault(gig_id, set()).add(status)
    earnings = {
        e.source_id: e
        for e in db.execute(
            select(EarningsLedgerEntry).where(
                EarningsLedgerEntry.pro_user_id == pro_user_id,
                EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
                EarningsLedgerEntry.source_id.in_(list(statuses)),
            )
        ).scalars()
    }
    holds = _active_holds(db, pro_user_id)
    moved = 0
    for gig_id, have in statuses.items():
        wanted = _wanted(earnings.get(gig_id), holds)
        if have != {wanted}:
            ledger.set_booking_status(db, pro_user_id=pro_user_id, gig_id=gig_id, status=wanted)
            moved += 1
    return moved
