"""The business dashboard's own tables (docs/BI.md).

- `bi_daily`: one row per day (Europe/London) per scope and dimension,
  filled by services/bi.recompute_days from the bi_* views. A cache of what
  the views say: recomputing a day gives the same numbers.
- `bi_cost`, `bi_company_cash`: manual entries, admin only, every change
  audit-logged (who and when on the row, and the admin audit log).
- `bi_stripe_txn`, `bi_stripe_sync_day`: Stripe's balance transactions,
  mirrored daily, and which days have been mirrored (a day not mirrored is
  "no data", never zero).

Amounts are integer cents (minor units). Never floats.
"""
from __future__ import annotations

import uuid
from datetime import date, datetime, timezone

from sqlalchemy import BigInteger, Boolean, CheckConstraint, Date, DateTime, Integer, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


def _now() -> datetime:
    return datetime.now(timezone.utc)


#: Manual cost categories a new entry may use. `ad_spend` and `marketing`
#: are marketing spend; the rest are other costs.
COST_CATEGORIES = ("ad_spend", "marketing", "salaries", "software", "legal", "office", "other")
#: Retired categories: rows already using them stay, shown "legacy", and
#: still count; no new entry may use them. `shelf_shipping` comes off the
#: Shelf margin (retired 2026-11-10: shipping is entered per order).
LEGACY_COST_CATEGORIES = ("shelf_shipping",)
SHELF_SHIPPING_RETIRED_ON = "2026-11-10"
MARKETING_CATEGORIES = ("ad_spend", "marketing")


class BiDaily(Base):
    """One day, one scope ("booking": split by niche, country and tier;
    "company": Stripe, RAWW, the Shelf and payouts, not split, with niche,
    country and tier "-")."""

    __tablename__ = "bi_daily"

    day: Mapped[date] = mapped_column(Date, primary_key=True)
    scope: Mapped[str] = mapped_column(Text, primary_key=True)
    niche: Mapped[str] = mapped_column(Text, primary_key=True)
    country: Mapped[str] = mapped_column(Text, primary_key=True)
    tier: Mapped[str] = mapped_column(Text, primary_key=True)
    # booking scope
    gmv_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    gmv_card_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    gmv_credit_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    refund_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    refund_card_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    refund_chargeback_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    refund_credit_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    retained_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    pro_cash_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    pro_raww_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    client_raww_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    bookings: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    other_currency_lines: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    #: Refunds (as a positive amount) split at base rates because the line
    #: names no payment; bookings whose tier is estimated.
    refund_rate_assumed_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    tier_estimated_bookings: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    #: Add-on refunds (positive) dated on the payment's last update: refunded
    #: before each refund was recorded with its own date.
    refund_date_estimated_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    # company scope
    stripe_synced: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    stripe_fee_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    stripe_charge_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    stripe_refund_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    stripe_dispute_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    stripe_transfer_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    stripe_payout_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    payouts_paid_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    raww_issued_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    raww_reversed_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    raww_spent_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    raww_expired_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    raww_adjust_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    shelf_orders: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    shelf_value_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    shelf_cost_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    shelf_cost_not_set_orders: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    shelf_cost_not_set_value_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    #: Orders whose cost is estimated (backfilled), shipping entered per
    #: order, and shipped orders with no shipping entered.
    shelf_cost_estimated_orders: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    shelf_order_shipping_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    shelf_shipping_not_set_orders: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    #: RAWW expiries and adjustments (absolute value) valued at today's rate
    #: because the line has none recorded.
    raww_estimated_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    computed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)

    __table_args__ = (CheckConstraint("scope IN ('booking','company')", name="ck_bi_daily_scope"),)


class BiCost(Base):
    """A cost typed by an admin. Recurring: repeats monthly on the same day
    of the month from `date` until `end_date` (or open-ended)."""

    __tablename__ = "bi_cost"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    end_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    category: Mapped[str] = mapped_column(Text, nullable=False)
    amount_cents: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency: Mapped[str] = mapped_column(Text, nullable=False, default="EUR")
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    recurring: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_by: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    updated_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    deleted_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSONB, nullable=False, default=dict)

    __table_args__ = (CheckConstraint("amount_cents > 0", name="ck_bi_cost_amount"),)


class BiCompanyCash(Base):
    """A company account's balance on a date, typed by an admin. The latest
    entry per account is its balance now."""

    __tablename__ = "bi_company_cash"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    account: Mapped[str] = mapped_column(Text, nullable=False)
    amount_cents: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency: Mapped[str] = mapped_column(Text, nullable=False, default="EUR")
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_by: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    updated_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    deleted_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSONB, nullable=False, default=dict)


class BiStripeTxn(Base):
    """One Stripe balance transaction, as Stripe reports it (amounts signed,
    in cents, fee positive)."""

    __tablename__ = "bi_stripe_txn"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    type: Mapped[str] = mapped_column(Text, nullable=False)
    reporting_category: Mapped[str | None] = mapped_column(Text, nullable=True)
    currency: Mapped[str] = mapped_column(Text, nullable=False)
    amount_cents: Mapped[int] = mapped_column(BigInteger, nullable=False)
    fee_cents: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    net_cents: Mapped[int] = mapped_column(BigInteger, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    available_on: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    source_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str | None] = mapped_column(Text, nullable=True)
    #: Seeded by scripts/seed_bi_demo.py, removed with --remove.
    demo: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    synced_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


class BiStripeSyncDay(Base):
    """A day whose Stripe balance transactions have been mirrored."""

    __tablename__ = "bi_stripe_sync_day"

    day: Mapped[date] = mapped_column(Date, primary_key=True)
    synced_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    txn_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    #: "stripe", or "demo" (scripts/seed_bi_demo.py).
    source: Mapped[str] = mapped_column(Text, nullable=False, default="stripe")


# The views over these and the money tables (created with the tables, dropped before them).
from app.models import bi_views  # noqa: E402,F401
