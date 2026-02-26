from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import JSON, BigInteger, DateTime, Enum, Index, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class RawwIssuanceEventType(str, enum.Enum):
    gig_completed = "gig.completed"
    gig_delivery_confirmed = "gig.delivery_confirmed"
    review_posted = "review.posted"
    gig_extras_purchased = "gig.extras_purchased"
    studioverse_pack_sold = "studioverse.pack_sold"
    studioverse_milestone_reached = "studioverse.milestone_reached"


class RawwIssuanceCapScope(str, enum.Enum):
    pro_daily = "pro_daily"
    pro_weekly = "pro_weekly"
    pro_monthly = "pro_monthly"
    global_daily = "global_daily"


class RawwMintEventStatus(str, enum.Enum):
    minted = "minted"
    blocked = "blocked"
    reversed = "reversed"


class RawwIssuanceRule(Base):
    __tablename__ = "raww_issuance_rule"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_type: Mapped[RawwIssuanceEventType] = mapped_column(
        Enum(RawwIssuanceEventType, name="raww_issuance_event_type", native_enum=False),
        nullable=False,
        unique=True,
    )
    base_raww: Mapped[int] = mapped_column(BigInteger, nullable=False)
    min_eur_value: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    max_raww_per_event: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RawwMultiplierPolicy(Base):
    __tablename__ = "raww_multiplier_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    tier_multipliers: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    rating_curve: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    dispute_penalty: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    refund_penalty_multiplier: Mapped[Decimal] = mapped_column(Numeric(6, 3), nullable=False, default=Decimal("0.500"))
    abuse_block_threshold: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RawwIssuanceCap(Base):
    __tablename__ = "raww_issuance_cap"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    scope: Mapped[RawwIssuanceCapScope] = mapped_column(
        Enum(RawwIssuanceCapScope, name="raww_issuance_cap_scope", native_enum=False),
        nullable=False,
        unique=True,
    )
    cap_raww: Mapped[int] = mapped_column(BigInteger, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RawwMintEvent(Base):
    __tablename__ = "raww_mint_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_type: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    reference_type: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    reference_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    raww_awarded: Mapped[int] = mapped_column(BigInteger, nullable=False)
    multiplier_snapshot: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    status: Mapped[RawwMintEventStatus] = mapped_column(
        Enum(RawwMintEventStatus, name="raww_mint_event_status", native_enum=False),
        nullable=False,
        default=RawwMintEventStatus.minted,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)

    __table_args__ = (
        UniqueConstraint("event_type", "reference_type", "reference_id", "pro_user_id", name="uq_raww_mint_event_event_reference_pro"),
    )


class RawwClawback(Base):
    __tablename__ = "raww_clawback"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    reference_type: Mapped[str] = mapped_column(Text, nullable=False)
    reference_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    amount_raww: Mapped[int] = mapped_column(BigInteger, nullable=False)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    created_by_admin_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


Index("ix_raww_mint_event_pro_created", RawwMintEvent.pro_user_id, RawwMintEvent.created_at.desc())
