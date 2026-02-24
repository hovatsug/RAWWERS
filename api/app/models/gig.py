import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, ForeignKey, Index, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.media import Base


class GigStatus(str, enum.Enum):
    draft = "draft"
    requested = "requested"
    accepted = "accepted"
    payment_pending = "payment_pending"
    paid = "paid"
    scheduled = "scheduled"
    shoot_done = "shoot_done"
    proofs_delivered = "proofs_delivered"
    selection_pending = "selection_pending"
    final_delivered = "final_delivered"
    completed = "completed"
    cancelled_by_client = "cancelled_by_client"
    cancelled_by_pro = "cancelled_by_pro"
    refunded = "refunded"
    disputed = "disputed"


class LedgerEntryType(str, enum.Enum):
    payment_authorized = "payment_authorized"
    payment_captured = "payment_captured"
    platform_fee = "platform_fee"
    payout_hold_created = "payout_hold_created"
    payout_hold_released = "payout_hold_released"
    refund_initiated = "refund_initiated"
    refund_succeeded = "refund_succeeded"
    chargeback_opened = "chargeback_opened"
    chargeback_won = "chargeback_won"
    chargeback_lost = "chargeback_lost"
    upsell_captured = "upsell_captured"
    upsell_platform_fee = "upsell_platform_fee"
    upsell_payout_hold_created = "upsell_payout_hold_created"


class PaymentStatus(str, enum.Enum):
    pending = "pending"
    requires_action = "requires_action"
    succeeded = "succeeded"
    failed = "failed"
    cancelled = "cancelled"
    refunded = "refunded"
    disputed = "disputed"


class Gig(Base):
    __tablename__ = "gig"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), index=True, nullable=False)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), index=True, nullable=False)
    status: Mapped[GigStatus] = mapped_column(Enum(GigStatus, name="gig_status", native_enum=False), index=True, nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    amount_total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    amount_platform_fee: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    amount_pro_gross: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    scheduled_start: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    scheduled_end: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    location_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    transitions: Mapped[list["GigTransition"]] = relationship(back_populates="gig", cascade="all, delete-orphan")
    payment: Mapped["StripePayment"] = relationship(back_populates="gig", uselist=False)
    ledger_entries: Mapped[list["LedgerEntry"]] = relationship(back_populates="gig", cascade="all, delete-orphan")


class GigTransition(Base):
    __tablename__ = "gig_transition"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    from_status: Mapped[GigStatus] = mapped_column(Enum(GigStatus, name="gig_status", native_enum=False), nullable=False)
    to_status: Mapped[GigStatus] = mapped_column(Enum(GigStatus, name="gig_status", native_enum=False), nullable=False)
    actor_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    gig: Mapped[Gig] = relationship(back_populates="transitions")


class StripePayment(Base):
    __tablename__ = "stripe_payment"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, unique=True, index=True)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), index=True, nullable=False)
    status: Mapped[PaymentStatus] = mapped_column(Enum(PaymentStatus, name="payment_status", native_enum=False), index=True, nullable=False)
    stripe_payment_intent_id: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    stripe_customer_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False)
    last_error: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    gig: Mapped[Gig] = relationship(back_populates="payment")


class LedgerEntry(Base):
    __tablename__ = "ledger_entry"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    entry_type: Mapped[LedgerEntryType] = mapped_column(Enum(LedgerEntryType, name="ledger_entry_type", native_enum=False), index=True, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    reference_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    reference_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    gig: Mapped[Gig] = relationship(back_populates="ledger_entries")


class StripeWebhookEvent(Base):
    __tablename__ = "stripe_webhook_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    external_event_id: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    event_type: Mapped[str] = mapped_column(Text, nullable=False)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False)
    received_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


Index("ix_ledger_entry_gig_created", LedgerEntry.gig_id, LedgerEntry.created_at.desc())
