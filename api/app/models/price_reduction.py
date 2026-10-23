"""Reductions of what a client owes after paying, and the data they are
judged by: the reason codes, and the delivery review threshold.

Both reason codes and the threshold are rows an admin edits, not constants:
which reasons exist, what they are called and whether one may carry a
photographer-fault finding are policy, and policy is data.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import Boolean, CHAR, DateTime, ForeignKey, Integer, Numeric, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class PriceReductionReason(Base):
    """Why a price came down. `may_carry_fault`: only these reasons can have
    a photographer-fault finding recorded against them (photographer
    non-delivery); a client's own choice never can."""

    __tablename__ = "price_reduction_reason"

    code: Mapped[str] = mapped_column(Text, primary_key=True)
    label: Mapped[str] = mapped_column(Text, nullable=False)
    #: What the client is told, in plain words.
    client_wording: Mapped[str] = mapped_column(Text, nullable=False)
    may_carry_fault: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class PriceReduction(Base):
    """One reduction of a booking's final price, with its breakdown by
    reason and the refund it caused. Keyed by the event that caused it, so
    the same reduction applied twice is recorded - and refunded - once."""

    __tablename__ = "price_reduction"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    idempotency_key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    #: "selection" (the client chose fewer photos than they paid for) or
    #: "admin" (an admin reduced the price by hand).
    source: Mapped[str] = mapped_column(Text, nullable=False)
    from_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    to_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    #: [{"reason_code": ..., "amount": "15.96"}, ...] - sums to from - to.
    lines: Mapped[list] = mapped_column(JSONB, nullable=False, default=list)
    refund_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False)
    note: Mapped[str] = mapped_column(Text, nullable=False)
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class DeliveryReviewPolicy(Base):
    """One row. A booking whose gallery holds fewer photos than were
    included by at least `shortfall_min_photos` is flagged for an admin to
    review - a flag, never an automatic finding or strike."""

    __tablename__ = "delivery_review_policy"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, default=1)
    shortfall_min_photos: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    updated_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
