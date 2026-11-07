"""The Shelf: a photographer's RAWW and the gear store they are spent in.

Owner's decision (2026-11-03). A photographer's RAWW live on their own
ledger here, separate from the reward ledger clients share (rewards.py):
the two are different currencies with different values, and one user can
hold both.

- `ProRawwLedgerEntry`: every change to a photographer's RAWW, append
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

from sqlalchemy import BigInteger, CheckConstraint, DateTime, Enum, ForeignKey, Index, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


def _now() -> datetime:
    return datetime.now(timezone.utc)


class RawwEntryKind(str, enum.Enum):
    #: A booking's 5% credit, in RAWW at the rate stamped on the entry.
    earn_booking = "earn_booking"
    #: A refund or price reduction lowering that credit (negative).
    reverse_booking = "reverse_booking"
    #: An order on The Shelf (negative).
    spend_order = "spend_order"
    #: A cancelled order's RAWW given back (positive).
    refund_order = "refund_order"
    #: The spendable balance expired after long inactivity (negative).
    expire = "expire"
    #: An admin's correction, with a required note (either sign).
    admin_adjust = "admin_adjust"
    #: An extra-image purchase's 5% credit, in RAWW at the rate stamped on
    #: the entry (source: the purchase; gig_id: its booking).
    earn_extras = "earn_extras"
    #: A refund lowering that credit (negative).
    reverse_extras = "reverse_extras"


#: Kinds that follow a booking's earning: pending until it settles.
BOOKING_KINDS = (RawwEntryKind.earn_booking, RawwEntryKind.reverse_booking)
#: Kinds that follow an extras purchase's own earning, the same way.
EXTRAS_KINDS = (RawwEntryKind.earn_extras, RawwEntryKind.reverse_extras)
#: Every kind earned from work: pending until its earning settles.
EARNING_KINDS = BOOKING_KINDS + EXTRAS_KINDS


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
    #: Signed, whole RAWW.
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
    "DRAFT - not reviewed. RAWW are a reward for photographers on RAWWERS. They have no cash value, "
    "cannot be sold, transferred or exchanged for money, and can only be spent on The Shelf. RAWW from "
    "a booking become spendable once that booking's earning has settled. Unused RAWW expire after a long "
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
    #: Used only to suggest a RAWW price from a GBP street price.
    gbp_eur_rate: Mapped[Decimal] = mapped_column(Numeric(10, 4), nullable=False)
    #: How far below street price the suggested price sits.
    shelf_discount_percent: Mapped[int] = mapped_column(nullable=False)
    inactivity_months: Mapped[int] = mapped_column(nullable=False)
    warning_days: Mapped[int] = mapped_column(nullable=False)
    #: Five RAWW amounts, one per level: the band an item's price should sit in.
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


class ShelfStockStatus(str, enum.Enum):
    in_stock = "in_stock"
    out_of_stock = "out_of_stock"


#: Currencies an item's prices may be entered in (converted for the price
#: helper with the settings' rate).
SHELF_CURRENCIES = ("GBP", "EUR")


class ShelfItem(Base):
    """Something on The Shelf. Its RAWW price is typed by an admin; the
    street price and the supplier's cost are there for the price helper and
    the margin, never shown to photographers as a euro price."""

    __tablename__ = "shelf_item"
    __table_args__ = (
        CheckConstraint("level BETWEEN 1 AND 5", name="ck_shelf_item_level"),
        CheckConstraint("price_raww > 0", name="ck_shelf_item_price"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    brand: Mapped[str | None] = mapped_column(Text, nullable=True)
    #: Free text for the beta: "battery", "charger", "card", "ssd", "light", "merch"...
    category: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    #: The supplier's product image, linked (the beta has no image upload).
    image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    level: Mapped[int] = mapped_column(nullable=False)
    price_raww: Mapped[int] = mapped_column(BigInteger, nullable=False)
    street_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    street_currency: Mapped[str] = mapped_column(Text, nullable=False, default="GBP")
    supplier_cost: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    supplier_currency: Mapped[str] = mapped_column(Text, nullable=False, default="GBP")
    supplier_name: Mapped[str] = mapped_column(Text, nullable=False)
    supplier_sku: Mapped[str | None] = mapped_column(Text, nullable=True)
    supplier_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    stock_status: Mapped[ShelfStockStatus] = mapped_column(
        Enum(ShelfStockStatus, name="shelf_stock_status", native_enum=False, length=16), nullable=False, default=ShelfStockStatus.in_stock
    )
    active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, onupdate=_now)


class ShelfItemCompat(Base):
    """A camera an item fits. An item with none fits everyone (a card, an
    SSD, a light, merch); one with any is shown only to photographers who
    own one of them."""

    __tablename__ = "shelf_item_compat"

    item_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shelf_item.id", ondelete="CASCADE"), primary_key=True)
    camera_model: Mapped[str] = mapped_column(Text, ForeignKey("camera_model_reference.normalised_model"), primary_key=True)


class ShelfWishlistItem(Base):
    """An item a photographer wants, up to the settings' wish list size."""

    __tablename__ = "shelf_wishlist_item"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    item_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shelf_item.id", ondelete="CASCADE"), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


class ShelfProAddress(Base):
    """The photographer's saved shipping address for The Shelf (one; each
    order keeps its own encrypted copy)."""

    __tablename__ = "shelf_pro_address"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    shipping_address_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shipping_address.id"), nullable=False)


class ShelfOrderStatus(str, enum.Enum):
    placed = "placed"
    #: Ordered from the supplier (their reference recorded).
    ordered = "ordered"
    shipped = "shipped"
    delivered = "delivered"
    cancelled = "cancelled"
    #: Cancelled and the RAWW given back.
    refunded = "refunded"


class ShelfOrder(Base):
    """One item ordered with RAWW. Everything that priced it is copied onto
    it: the title, the RAWW price and the RAWW value then, and the address."""

    __tablename__ = "shelf_order"
    __table_args__ = (UniqueConstraint("pro_user_id", "client_request_id", name="uq_shelf_order_request"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    item_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shelf_item.id"), nullable=False, index=True)
    #: The app's id for this attempt: the same request twice is one order.
    client_request_id: Mapped[str] = mapped_column(Text, nullable=False)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    supplier_name: Mapped[str] = mapped_column(Text, nullable=False)
    supplier_sku: Mapped[str | None] = mapped_column(Text, nullable=True)
    level: Mapped[int] = mapped_column(nullable=False)
    price_raww: Mapped[int] = mapped_column(BigInteger, nullable=False)
    raww_eur_value: Mapped[Decimal] = mapped_column(Numeric(10, 4), nullable=False)
    status: Mapped[ShelfOrderStatus] = mapped_column(
        Enum(ShelfOrderStatus, name="shelf_order_status", native_enum=False, length=16), nullable=False, index=True
    )
    #: The address it ships to, encrypted (services/addresses.py).
    shipping_address: Mapped[dict] = mapped_column(JSONB, nullable=False)
    country: Mapped[str] = mapped_column(Text, nullable=False)
    supplier_order_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    tracking_code: Mapped[str | None] = mapped_column(Text, nullable=True)
    tracking_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    cancel_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    placed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, index=True)
    ordered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    shipped_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    delivered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    cancelled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    refunded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now, onupdate=_now)


class ShelfOrderEvent(Base):
    """Every status change of an order: from what, to what, by whom, when."""

    __tablename__ = "shelf_order_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shelf_order.id"), nullable=False, index=True)
    from_status: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_status: Mapped[str] = mapped_column(Text, nullable=False)
    #: "pro", "admin" or "system".
    actor_type: Mapped[str] = mapped_column(Text, nullable=False)
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=_now)


class ShelfItemImage(Base):
    """One of an item's 1 to 4 photos; position 0 is the cover. Uploaded by
    an admin (services/shelf_images.py), checked, then sized by the worker
    to 400, 800 and 1600 px on the long edge."""

    __tablename__ = "shelf_item_image"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    item_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("shelf_item.id", ondelete="CASCADE"), nullable=False, index=True)
    media_asset_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=False)
    position: Mapped[int] = mapped_column(nullable=False, default=0)
    #: uploading, processing, ready, failed.
    status: Mapped[str] = mapped_column(Text, nullable=False, default="uploading")
    width: Mapped[int | None] = mapped_column(nullable=True)
    height: Mapped[int | None] = mapped_column(nullable=True)
    failure_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
