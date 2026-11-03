"""The Shelf: a photographer's RAWWS and the gear store they are spent in.

Owner's decision (2026-11-03). A photographer's RAWWS live on their own
ledger here, separate from the reward ledger clients share (rewards.py):
the two are different currencies with different values, and one user can
hold both.

- `ProRawwLedgerEntry`: every change to a photographer's RAWWS, append
  only. Booking entries move from pending to spendable as their earning
  settles (the same states the earnings ledger uses); nothing else changes
  an entry once written. One entry per (pro, kind, source): the same event
  twice is the same entry.
- `ProRawwBalance`: the running totals, always changed under `FOR UPDATE`.
"""
from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import BigInteger, CheckConstraint, DateTime, Enum, Index, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


def _now() -> datetime:
    return datetime.now(timezone.utc)


class RawwEntryKind(str, enum.Enum):
    #: A booking's 5% credit, in RAWWS at the rate stamped on the entry.
    earn_booking = "earn_booking"
    #: A refund or price reduction lowering that credit (negative).
    reverse_booking = "reverse_booking"
    #: An order on The Shelf (negative).
    spend_order = "spend_order"
    #: A cancelled order's RAWWS given back (positive).
    refund_order = "refund_order"
    #: The spendable balance expired after long inactivity (negative).
    expire = "expire"
    #: An admin's correction, with a required note (either sign).
    admin_adjust = "admin_adjust"


#: Kinds that follow a booking's earning: pending until it settles.
BOOKING_KINDS = (RawwEntryKind.earn_booking, RawwEntryKind.reverse_booking)


class RawwEntryStatus(str, enum.Enum):
    #: Counted, not yet spendable: the booking's earning has not settled, or
    #: is held.
    pending = "pending"
    spendable = "spendable"


class ProRawwLedgerEntry(Base):
    __tablename__ = "pro_raww_ledger_entry"
    __table_args__ = (
        UniqueConstraint("pro_user_id", "kind", "source_type", "source_id", name="uq_pro_raww_entry_source"),
        CheckConstraint("amount <> 0", name="ck_pro_raww_entry_amount"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    kind: Mapped[RawwEntryKind] = mapped_column(Enum(RawwEntryKind, name="raww_entry_kind", native_enum=False, length=32), nullable=False)
    #: Signed, whole RAWWS.
    amount: Mapped[int] = mapped_column(BigInteger, nullable=False)
    status: Mapped[RawwEntryStatus] = mapped_column(
        Enum(RawwEntryStatus, name="raww_entry_status", native_enum=False, length=16), nullable=False
    )
    #: What the entry is about: "gig", "shelf_order", "admin", "expiry".
    source_type: Mapped[str] = mapped_column(Text, nullable=False)
    #: Its idempotency key within the source: the same key is the same entry.
    source_id: Mapped[str] = mapped_column(Text, nullable=False)
    #: The gig a booking entry belongs to (also inside source_id), for lookups.
    gig_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    #: Euros per RAWW when the entry was made, and the euros it stood for.
    raww_eur_value: Mapped[Decimal | None] = mapped_column(Numeric(10, 4), nullable=True)
    eur_basis: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    #: When a booking entry became spendable.
    spendable_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, index=True)


Index("ix_pro_raww_entry_pro_created", ProRawwLedgerEntry.pro_user_id, ProRawwLedgerEntry.created_at.desc())


class ProRawwBalance(Base):
    __tablename__ = "pro_raww_balance"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    #: May be negative (a refund after spending): spending waits until it
    #: is back above the price.
    spendable: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    pending: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    #: The last earn or spend; the inactivity expiry counts from here.
    last_activity_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    #: When the expiry warning went out; cleared by any activity.
    expiry_warned_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, onupdate=_now)


#: The Shelf's terms until the lawyer's reviewed text replaces it.
SHELF_TERMS_PLACEHOLDER = (
    "DRAFT - not reviewed. RAWWS are a reward for photographers on RAWWERS. They have no cash value, "
    "cannot be sold, transferred or exchanged for money, and can only be spent on The Shelf. RAWWS from "
    "a booking become spendable once that booking's earning has settled. Unused RAWWS expire after a long "
    "period without earning or spending; you will be told before they do. Items ship to the countries "
    "listed, while stocks last."
)


class ShelfSettings(Base):
    """The Shelf's settings: one row, edited in the admin, every change
    audit-logged. Values that set a price are stamped on what they priced
    (an earning's rate, an order's price and rate), never re-read."""

    __tablename__ = "shelf_settings"

    id: Mapped[int] = mapped_column(primary_key=True, default=1)
    #: Euros one RAWW stands for (an earning is credit in euros / this).
    raww_eur_value: Mapped[Decimal] = mapped_column(Numeric(10, 4), nullable=False)
    #: Used only to suggest a RAWWS price from a GBP street price.
    gbp_eur_rate: Mapped[Decimal] = mapped_column(Numeric(10, 4), nullable=False)
    #: How far below street price the suggested price sits.
    shelf_discount_percent: Mapped[int] = mapped_column(nullable=False)
    inactivity_months: Mapped[int] = mapped_column(nullable=False)
    warning_days: Mapped[int] = mapped_column(nullable=False)
    #: Five RAWWS amounts, one per level: the band an item's price should sit in.
    level_band_raww: Mapped[list] = mapped_column(JSONB, nullable=False)
    #: The highest level each tier sees.
    tier_max_level: Mapped[dict] = mapped_column(JSONB, nullable=False)
    wishlist_max: Mapped[int] = mapped_column(nullable=False)
    max_orders_per_month: Mapped[int] = mapped_column(nullable=False)
    same_item_cooldown_days: Mapped[int] = mapped_column(nullable=False)
    allowed_countries: Mapped[list] = mapped_column(JSONB, nullable=False)
    #: The beta ships free; there is no charged shipping yet.
    free_shipping: Mapped[bool] = mapped_column(nullable=False, default=True)
    shelf_enabled: Mapped[bool] = mapped_column(nullable=False)
    terms_text: Mapped[str] = mapped_column(Text, nullable=False)
    #: Set when the lawyer's reviewed terms are approved; cleared when the
    #: text changes. In production The Shelf is off without it.
    terms_approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    terms_reviewed_by: Mapped[str | None] = mapped_column(Text, nullable=True)
    terms_review_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    terms_approved_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, onupdate=_now)
