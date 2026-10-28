from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, DateTime, Enum, Index, Integer, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class EarningsSourceType(str, enum.Enum):
    gig_base = "gig_base"
    extra_images = "extra_images"
    studioverse_sale = "studioverse_sale"


class EarningsEntryStatus(str, enum.Enum):
    pending = "pending"
    available = "available"
    held = "held"
    reversed = "reversed"


class EarningsHoldReason(str, enum.Enum):
    dispute_open = "dispute_open"
    refund_risk = "refund_risk"
    compliance = "compliance"
    manual = "manual"


class PayoutMethod(str, enum.Enum):
    stripe_connect = "stripe_connect"
    bank_manual = "bank_manual"


class PayoutAccountStatus(str, enum.Enum):
    not_set = "not_set"
    pending_verification = "pending_verification"
    active = "active"
    disabled = "disabled"


class PayoutSetupState(str, enum.Enum):
    """Where a photographer's payout setup stands, as the app shows it.

    Not stored: worked out from the Stripe account on every status read, by
    the same function that gives the stored PayoutAccountStatus
    (stripe_connect.setup_from_account), so the two cannot disagree. ready
    is exactly the stored active.
    """

    not_started = "not_started"
    in_progress = "in_progress"
    under_review = "under_review"
    action_needed = "action_needed"
    ready = "ready"
    disabled = "disabled"


class PayoutRequestStatus(str, enum.Enum):
    requested = "requested"
    approved = "approved"
    rejected = "rejected"
    processing = "processing"
    paid = "paid"
    failed = "failed"
    cancelled = "cancelled"


class EarningsLedgerEntry(Base):
    __tablename__ = "earnings_ledger_entry"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    source_type: Mapped[EarningsSourceType] = mapped_column(
        Enum(EarningsSourceType, name="earnings_source_type", native_enum=False, length=64),
        nullable=False,
    )
    source_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    gross_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    platform_fee_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    net_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    status: Mapped[EarningsEntryStatus] = mapped_column(
        Enum(EarningsEntryStatus, name="earnings_entry_status", native_enum=False, length=64),
        nullable=False,
        default=EarningsEntryStatus.pending,
        index=True,
    )
    available_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    reversed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("source_type", "source_id", "pro_user_id", name="uq_earnings_source_pro"),)


class EarningsBalanceSnapshot(Base):
    __tablename__ = "earnings_balance_snapshot"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    pending_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    available_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    held_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class EarningsHold(Base):
    __tablename__ = "earnings_hold"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    reason: Mapped[EarningsHoldReason] = mapped_column(
        Enum(EarningsHoldReason, name="earnings_hold_reason", native_enum=False, length=64),
        nullable=False,
    )
    amount_eur: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    source_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    source_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_by_admin_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    released_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class PayoutAccount(Base):
    __tablename__ = "payout_account"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    payout_method: Mapped[PayoutMethod] = mapped_column(
        Enum(PayoutMethod, name="payout_method", native_enum=False, length=64),
        nullable=False,
        default=PayoutMethod.bank_manual,
    )
    stripe_connect_account_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    bank_details_encrypted: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    status: Mapped[PayoutAccountStatus] = mapped_column(
        Enum(PayoutAccountStatus, name="payout_account_status", native_enum=False, length=64),
        nullable=False,
        default=PayoutAccountStatus.not_set,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class PayoutRequest(Base):
    __tablename__ = "payout_request"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    amount_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    status: Mapped[PayoutRequestStatus] = mapped_column(
        Enum(PayoutRequestStatus, name="payout_request_status", native_enum=False, length=64),
        nullable=False,
        default=PayoutRequestStatus.requested,
        index=True,
    )
    requested_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    approved_by_admin_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    paid_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    failure_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    reference: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class PayoutEvent(Base):
    __tablename__ = "payout_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    payout_request_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    type: Mapped[str] = mapped_column(Text, nullable=False)
    payload: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class PayoutAllocation(Base):
    __tablename__ = "payout_allocation"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    payout_request_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    earnings_ledger_entry_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    amount_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("payout_request_id", "earnings_ledger_entry_id", name="uq_payout_allocation_unique"),)


class PlatformFeePolicy(Base):
    __tablename__ = "platform_fee_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    fee_percent_gigs: Mapped[int] = mapped_column(Integer, nullable=False, default=20)
    # How the take above divides. These must sum to fee_percent_gigs, which
    # split_booking() refuses to proceed without - a policy that does not add
    # up would silently lose or invent money on every booking.
    retained_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=15)
    pro_raww_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=5)
    # The most a photographer may pass to their client, out of their own cash.
    max_client_credit_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=10)
    fee_percent_extras: Mapped[int] = mapped_column(Integer, nullable=False, default=20)
    fee_percent_studioverse: Mapped[int] = mapped_column(Integer, nullable=False, default=20)
    settlement_delay_days: Mapped[int] = mapped_column(Integer, nullable=False, default=7)
    dispute_hold_days: Mapped[int] = mapped_column(Integer, nullable=False, default=14)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class VatStatus(str, enum.Enum):
    """Whether a photographer is registered for VAT.

    Three states, not a boolean. Someone who has never been asked is not the
    same as someone who has told us they are not registered, and an invoice
    should be able to say which. Inferring "not registered" from an absent VAT
    number would be the zero-versus-unavailable mistake in a new field.
    """

    not_answered = "not_answered"
    not_registered = "not_registered"
    registered = "registered"


class CountryTaxRule(Base):
    """One country's consumption-tax rules.

    Keyed by country, the same shape `niche_package_price_cap` uses for niche
    and tier. Exactly one row is populated - the UK - so adding a second
    country is a row rather than a rewrite.

    The rate lives here so it can be changed, and is never read live by an
    invoice: a settled invoice reproduces the rate stamped on its gig, for the
    same reason it reproduces the commission rates. The UK rate has changed
    three times this century.
    """

    __tablename__ = "country_tax_rule"

    country: Mapped[str] = mapped_column(CHAR(2), primary_key=True)
    tax_name: Mapped[str] = mapped_column(Text, nullable=False, default="VAT")
    standard_rate_percent: Mapped[int] = mapped_column(Integer, nullable=False)

    #: Turnover above which registration becomes compulsory, in minor units of
    #: the country's own currency. Reference only - the platform sees a
    #: photographer's RAWWERS bookings, which may be a fraction of their
    #: income, so nothing here may infer anybody's status from it.
    registration_threshold: Mapped[Decimal | None] = mapped_column(Numeric(14, 2), nullable=True)
    threshold_currency: Mapped[str | None] = mapped_column(CHAR(3), nullable=True)

    #: A human-readable example, for a form to show beside the input. Not a
    #: validation pattern: rejecting a real number because a regex is out of
    #: date is worse than accepting one that is wrong.
    vat_number_format: Mapped[str | None] = mapped_column(Text, nullable=True)

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )


class TaxProfile(Base):
    __tablename__ = "tax_profile"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    #: Defaults to not_answered, never to not_registered. Most photographers
    #: will turn out not to be registered, but that is a thing they tell us
    #: rather than a thing we assume on their behalf.
    vat_status: Mapped[VatStatus] = mapped_column(
        Enum(VatStatus, name="vat_status", native_enum=False, length=64),
        nullable=False,
        default=VatStatus.not_answered,
        server_default=VatStatus.not_answered.value,
    )
    vat_number: Mapped[str | None] = mapped_column(Text, nullable=True)
    country: Mapped[str | None] = mapped_column(Text, nullable=True)
    legal_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    address_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


Index("ix_earnings_entry_pro_status", EarningsLedgerEntry.pro_user_id, EarningsLedgerEntry.status)
Index("ix_earnings_hold_pro_released", EarningsHold.pro_user_id, EarningsHold.released_at)
Index("ix_payout_request_pro_created", PayoutRequest.pro_user_id, PayoutRequest.created_at.desc())
