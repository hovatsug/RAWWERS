"""What a photographer sees of their RAWW: the Wallet card and history."""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType
from app.models.shelf import BOOKING_KINDS, ProRawwLedgerEntry, RawwEntryStatus
from app.services import raww_ledger as ledger
from app.services.shelf_settings import shelf_open, shelf_settings


def wallet(db: Session, pro_user_id: uuid.UUID) -> dict:
    settings = shelf_settings(db)
    balance = ledger.get_balance(db, pro_user_id)
    expiry = ledger.expires_at(balance, settings.inactivity_months)
    pending = db.execute(
        select(ProRawwLedgerEntry.gig_id, func.sum(ProRawwLedgerEntry.amount))
        .where(
            ProRawwLedgerEntry.pro_user_id == pro_user_id,
            ProRawwLedgerEntry.kind.in_(BOOKING_KINDS),
            ProRawwLedgerEntry.status == RawwEntryStatus.pending,
        )
        .group_by(ProRawwLedgerEntry.gig_id)
    ).all()
    earnings = {
        e.source_id: e
        for e in db.execute(
            select(EarningsLedgerEntry).where(
                EarningsLedgerEntry.pro_user_id == pro_user_id,
                EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
                EarningsLedgerEntry.source_id.in_([gig_id for gig_id, _ in pending] or [uuid.uuid4()]),
            )
        ).scalars()
    }
    items = []
    for gig_id, amount in pending:
        if not amount:
            continue
        earning = earnings.get(gig_id)
        held = earning is None or earning.status != EarningsEntryStatus.pending
        items.append({"gig_id": gig_id, "amount": int(amount), "held": held, "expected_at": None if held else earning.available_at})
    items.sort(key=lambda i: (i["expected_at"] is None, i["expected_at"] or datetime.max.replace(tzinfo=None)))
    spendable = balance.spendable if balance else 0
    return {
        "shelf_open": shelf_open(db),
        "spendable": spendable,
        "pending": balance.pending if balance else 0,
        "raww_eur_value": settings.raww_eur_value,
        "pending_bookings": items,
        "expires_at": expiry,
        "expiry_warning": ledger.in_warning_period(expiry, settings.warning_days),
        "inactivity_months": settings.inactivity_months,
    }


def history(db: Session, pro_user_id: uuid.UUID, *, limit: int, offset: int) -> tuple[int, list[ProRawwLedgerEntry]]:
    base = select(ProRawwLedgerEntry).where(ProRawwLedgerEntry.pro_user_id == pro_user_id)
    total = db.execute(select(func.count()).select_from(base.subquery())).scalar_one()
    rows = db.execute(base.order_by(ProRawwLedgerEntry.created_at.desc()).offset(offset).limit(limit)).scalars().all()
    return total, rows


def booking_rawws(db: Session, pro_user_id: uuid.UUID, gig_id: uuid.UUID | None = None) -> int:
    """A booking's RAWW now (or all bookings' together)."""
    query = select(func.coalesce(func.sum(ProRawwLedgerEntry.amount), 0)).where(
        ProRawwLedgerEntry.pro_user_id == pro_user_id, ProRawwLedgerEntry.kind.in_(BOOKING_KINDS)
    )
    if gig_id is not None:
        query = query.where(ProRawwLedgerEntry.gig_id == gig_id)
    return int(db.execute(query).scalar_one())


def invoice_rawws(db: Session, pro_user_id: uuid.UUID, gig_id: uuid.UUID) -> int | None:
    """A booking's RAWW for its invoice, or None for a booking that has no
    RAWW entries: one completed before The Shelf (no backfill, owner's
    decision 2026-11-03), whose invoice shows its euro credit alone rather
    than "0 RAWW" beside it."""
    has_entries = db.execute(
        select(ProRawwLedgerEntry.id)
        .where(
            ProRawwLedgerEntry.pro_user_id == pro_user_id,
            ProRawwLedgerEntry.kind.in_(BOOKING_KINDS),
            ProRawwLedgerEntry.gig_id == gig_id,
        )
        .limit(1)
    ).first()
    return booking_rawws(db, pro_user_id, gig_id) if has_entries else None
