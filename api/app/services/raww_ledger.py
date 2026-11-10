"""A photographer's RAWW: the only code that writes their ledger.

Every change is an entry (models/shelf.py) and the balance moves with it,
under the balance row's lock. Idempotent by source: posting the same
(pro, kind, source) twice returns the first entry, checked before and again
after the lock, and the database refuses a second row anyway.

Two buckets:
- pending: a booking's credit until its earning has settled with no hold
  on it (`set_booking_status` moves it, both ways);
- spendable: what The Shelf may take. It can be negative, after a refund
  reverses credit already spent; nothing can be spent until it is back up.

The inactivity clock (`last_activity_at`) restarts on any earn or spend.
"""
from __future__ import annotations

import calendar
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.shelf import BOOKING_KINDS, EARNING_KINDS, EXTRAS_KINDS, ProRawwBalance, ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus

#: Kinds that restart the inactivity clock: earning and spending.
_ACTIVITY_KINDS = (RawwEntryKind.earn_booking, RawwEntryKind.earn_extras, RawwEntryKind.spend_order)


def _now() -> datetime:
    return datetime.now(timezone.utc)


def balance_locked(db: Session, pro_user_id: uuid.UUID) -> ProRawwBalance:
    """The photographer's balance row, locked for this transaction."""
    row = db.execute(select(ProRawwBalance).where(ProRawwBalance.pro_user_id == pro_user_id).with_for_update()).scalar_one_or_none()
    if row is None:
        db.add(ProRawwBalance(pro_user_id=pro_user_id, spendable=0, pending=0))
        db.flush()
        row = db.execute(select(ProRawwBalance).where(ProRawwBalance.pro_user_id == pro_user_id).with_for_update()).scalar_one()
    return row


def get_balance(db: Session, pro_user_id: uuid.UUID) -> ProRawwBalance | None:
    return db.get(ProRawwBalance, pro_user_id)


def _existing(db: Session, pro_user_id: uuid.UUID, kind: RawwEntryKind, source_type: str, source_id: str) -> ProRawwLedgerEntry | None:
    return db.execute(
        select(ProRawwLedgerEntry).where(
            ProRawwLedgerEntry.pro_user_id == pro_user_id,
            ProRawwLedgerEntry.kind == kind,
            ProRawwLedgerEntry.source_type == source_type,
            ProRawwLedgerEntry.source_id == source_id,
        )
    ).scalar_one_or_none()


def find_entry(db: Session, *, pro_user_id: uuid.UUID, kind: RawwEntryKind, source_type: str, source_id: str) -> ProRawwLedgerEntry | None:
    return _existing(db, pro_user_id, kind, source_type, source_id)


def _insert_locked(db: Session, balance: ProRawwBalance, **fields) -> ProRawwLedgerEntry:
    """Write an entry and move the balance with it. The caller holds the lock."""
    entry = ProRawwLedgerEntry(meta={}, **fields)
    if entry.status == RawwEntryStatus.pending:
        balance.pending += entry.amount
    else:
        balance.spendable += entry.amount
    if entry.kind in _ACTIVITY_KINDS and (entry.kind not in EARNING_KINDS or entry.amount > 0):
        balance.last_activity_at = entry.created_at or _now()
        balance.expiry_warned_at = None
    balance.updated_at = _now()
    db.add(entry)
    db.flush()
    return entry


def post_entry(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    kind: RawwEntryKind,
    amount: int,
    source_type: str,
    source_id: str,
    status: RawwEntryStatus = RawwEntryStatus.spendable,
    gig_id: uuid.UUID | None = None,
    raww_eur_value: Decimal | None = None,
    eur_basis: Decimal | None = None,
    note: str | None = None,
    actor_user_id: uuid.UUID | None = None,
    meta: dict | None = None,
) -> ProRawwLedgerEntry | None:
    """Post one entry, once. Returns the entry (an existing one for a source
    already posted), or None for a zero amount, which changes nothing."""
    amount = int(amount)
    if amount == 0:
        return None
    if kind not in EARNING_KINDS and status != RawwEntryStatus.spendable:
        raise ValueError("only entries earned from work can be pending")
    existing = _existing(db, pro_user_id, kind, source_type, source_id)
    if existing:
        return existing
    balance = balance_locked(db, pro_user_id)
    existing = _existing(db, pro_user_id, kind, source_type, source_id)
    if existing:
        return existing
    entry = _insert_locked(
        db,
        balance,
        pro_user_id=pro_user_id,
        kind=kind,
        amount=amount,
        status=status,
        source_type=source_type,
        source_id=source_id,
        gig_id=gig_id,
        raww_eur_value=raww_eur_value,
        eur_basis=eur_basis,
        note=note,
        actor_user_id=actor_user_id,
        created_at=_now(),
        spendable_at=_now() if (kind in EARNING_KINDS and status == RawwEntryStatus.spendable) else None,
    )
    if meta:
        entry.meta = meta
    return entry


def spend(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    amount: int,
    source_type: str,
    source_id: str,
    meta: dict | None = None,
) -> ProRawwLedgerEntry:
    """Take `amount` from the spendable balance, or refuse.

    Checked under the lock, so a double tap cannot spend twice and two
    orders cannot together take more than there is. A negative spendable
    balance refuses everything."""
    amount = int(amount)
    if amount <= 0:
        raise ValueError("spend a positive amount")
    balance = balance_locked(db, pro_user_id)
    existing = _existing(db, pro_user_id, RawwEntryKind.spend_order, source_type, source_id)
    if existing:
        return existing
    if balance.spendable < amount:
        raise APIError(
            code="insufficient_raww",
            message=f"You have {max(balance.spendable, 0)} RAWW to spend; this needs {amount}.",
            status_code=409,
        )
    entry = _insert_locked(
        db,
        balance,
        pro_user_id=pro_user_id,
        kind=RawwEntryKind.spend_order,
        amount=-amount,
        status=RawwEntryStatus.spendable,
        source_type=source_type,
        source_id=source_id,
        created_at=_now(),
    )
    if meta:
        entry.meta = meta
    return entry


def set_booking_status(db: Session, *, pro_user_id: uuid.UUID, gig_id: uuid.UUID, status: RawwEntryStatus) -> int:
    """Move a booking's entries to `status`, and their RAWW between the
    buckets. Both directions: an earning held after it settled takes its
    RAWW back to pending. Returns how many entries moved."""
    return _set_status(
        db, pro_user_id, status, ProRawwLedgerEntry.gig_id == gig_id, ProRawwLedgerEntry.kind.in_(BOOKING_KINDS)
    )


def set_extras_status(db: Session, *, pro_user_id: uuid.UUID, purchase_id: str, status: RawwEntryStatus) -> int:
    """The same for one extras purchase's entries, which follow their own
    earning, not the booking's."""
    return _set_status(
        db,
        pro_user_id,
        status,
        ProRawwLedgerEntry.source_type == "extra_images",
        _purchase_entries(purchase_id),
        ProRawwLedgerEntry.kind.in_(EXTRAS_KINDS),
    )


def extras_net(db: Session, *, pro_user_id: uuid.UUID, purchase_id: str) -> int:
    """What one extras purchase's entries add up to now."""
    return int(
        db.execute(
            select(func.coalesce(func.sum(ProRawwLedgerEntry.amount), 0)).where(
                ProRawwLedgerEntry.pro_user_id == pro_user_id,
                ProRawwLedgerEntry.source_type == "extra_images",
                _purchase_entries(purchase_id),
                ProRawwLedgerEntry.kind.in_(EXTRAS_KINDS),
            )
        ).scalar_one()
    )


def _purchase_entries(purchase_id: str):
    """A purchase's first entry is keyed by its id, later ones "<id>:<from>-><to>"."""
    return or_(ProRawwLedgerEntry.source_id == purchase_id, ProRawwLedgerEntry.source_id.like(f"{purchase_id}:%"))


def _set_status(db: Session, pro_user_id: uuid.UUID, status: RawwEntryStatus, *where) -> int:
    balance = balance_locked(db, pro_user_id)
    rows = db.execute(
        select(ProRawwLedgerEntry).where(
            ProRawwLedgerEntry.pro_user_id == pro_user_id,
            ProRawwLedgerEntry.status != status,
            *where,
        )
    ).scalars().all()
    now = _now()
    for row in rows:
        if status == RawwEntryStatus.spendable:
            balance.pending -= row.amount
            balance.spendable += row.amount
            row.spendable_at = now
        else:
            balance.spendable -= row.amount
            balance.pending += row.amount
            row.spendable_at = None
        row.status = status
    if rows:
        balance.updated_at = now
        db.flush()
    return len(rows)


def booking_net(db: Session, *, pro_user_id: uuid.UUID, gig_id: uuid.UUID) -> int:
    """What a booking's entries add up to now."""
    return int(
        db.execute(
            select(func.coalesce(func.sum(ProRawwLedgerEntry.amount), 0)).where(
                ProRawwLedgerEntry.pro_user_id == pro_user_id,
                ProRawwLedgerEntry.gig_id == gig_id,
                ProRawwLedgerEntry.kind.in_(BOOKING_KINDS),
            )
        ).scalar_one()
    )


def _current_rate(db: Session) -> Decimal:
    from app.services.shelf_settings import shelf_settings

    return shelf_settings(db).raww_eur_value


def admin_adjust(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    amount: int,
    note: str,
    actor_user_id: uuid.UUID,
    request_id: str | None = None,
) -> ProRawwLedgerEntry:
    """An admin's correction, to the spendable balance. A note is required;
    `request_id` makes a resubmitted form the same adjustment."""
    note = (note or "").strip()
    if not note:
        raise APIError(code="validation_error", message="A note is required for a RAWW adjustment", status_code=422)
    if int(amount) == 0:
        raise APIError(code="validation_error", message="An adjustment must change the balance", status_code=422)
    entry = post_entry(
        db,
        pro_user_id=pro_user_id,
        kind=RawwEntryKind.admin_adjust,
        amount=int(amount),
        source_type="admin",
        source_id=request_id or str(uuid.uuid4()),
        note=note,
        actor_user_id=actor_user_id,
        # The rate on the day, so the dashboard values it as it was.
        raww_eur_value=_current_rate(db),
    )
    assert entry is not None
    return entry


def expire_spendable(db: Session, *, pro_user_id: uuid.UUID) -> ProRawwLedgerEntry | None:
    """Expire the whole spendable balance (nothing when it is not above
    zero). Keyed on the inactivity period, so it happens once per period."""
    balance = balance_locked(db, pro_user_id)
    if balance.spendable <= 0:
        return None
    since = balance.last_activity_at.isoformat() if balance.last_activity_at else "never"
    return post_entry(
        db,
        pro_user_id=pro_user_id,
        kind=RawwEntryKind.expire,
        amount=-balance.spendable,
        source_type="expiry",
        source_id=f"inactive-since:{since}",
        raww_eur_value=_current_rate(db),
    )


def ledger_totals(db: Session, pro_user_id: uuid.UUID) -> tuple[int, int]:
    """(spendable, pending) recomputed from the entries: what the balance
    row must always equal."""
    rows = db.execute(
        select(ProRawwLedgerEntry.status, func.coalesce(func.sum(ProRawwLedgerEntry.amount), 0))
        .where(ProRawwLedgerEntry.pro_user_id == pro_user_id)
        .group_by(ProRawwLedgerEntry.status)
    ).all()
    totals = {status: int(total) for status, total in rows}
    return totals.get(RawwEntryStatus.spendable, 0), totals.get(RawwEntryStatus.pending, 0)


def months_after(start: datetime, months: int) -> datetime:
    """`months` calendar months after `start`, on the same day (the last of
    the month when that day does not exist)."""
    month = start.month - 1 + months
    year, month = start.year + month // 12, month % 12 + 1
    return start.replace(year=year, month=month, day=min(start.day, calendar.monthrange(year, month)[1]))


def expires_at(balance: ProRawwBalance | None, inactivity_months: int) -> datetime | None:
    """When the spendable balance expires if nothing is earned or spent
    before then. None with nothing to expire."""
    if balance is None or balance.spendable <= 0 or balance.last_activity_at is None:
        return None
    return months_after(balance.last_activity_at, inactivity_months)


def in_warning_period(expiry: datetime | None, warning_days: int, now: datetime | None = None) -> bool:
    return expiry is not None and (now or _now()) >= expiry - timedelta(days=warning_days)
