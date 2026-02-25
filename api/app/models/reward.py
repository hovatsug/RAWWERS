import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, BigInteger, DateTime, Enum, Index, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class ReferralOwnerRole(str, enum.Enum):
    client = "client"
    pro = "pro"


class AttributionType(str, enum.Enum):
    signup = "signup"


class RewardEntryType(str, enum.Enum):
    earn = "earn"
    spend = "spend"
    adjustment = "adjustment"


class RedemptionContextType(str, enum.Enum):
    gig_payment = "gig_payment"
    upsell_purchase = "upsell_purchase"
    commerce_order = "commerce_order"


class DiscountRedemptionStatus(str, enum.Enum):
    reserved = "reserved"
    applied = "applied"
    released = "released"


class ReminderKind(str, enum.Enum):
    proof_selection_reminder = "proof_selection_reminder"


class ReminderStatus(str, enum.Enum):
    scheduled = "scheduled"
    sent = "sent"
    cancelled = "cancelled"


class ReferralCode(Base):
    __tablename__ = "referral_code"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    role: Mapped[ReferralOwnerRole] = mapped_column(
        Enum(ReferralOwnerRole, name="referral_owner_role", native_enum=False),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ReferralAttribution(Base):
    __tablename__ = "referral_attribution"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    referred_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, unique=True, index=True)
    referrer_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    referral_code: Mapped[str] = mapped_column(Text, nullable=False)
    attribution_type: Mapped[AttributionType] = mapped_column(
        Enum(AttributionType, name="attribution_type", native_enum=False),
        nullable=False,
        default=AttributionType.signup,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class RewardRule(Base):
    __tablename__ = "reward_rule"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    is_enabled: Mapped[bool] = mapped_column(nullable=False, default=True)
    amount: Mapped[int] = mapped_column(BigInteger, nullable=False)
    currency: Mapped[str] = mapped_column(Text, nullable=False, default="RAWW_POINTS")
    daily_cap_per_user: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    lifetime_cap_per_user: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RewardLedgerEntry(Base):
    __tablename__ = "reward_ledger_entry"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    entry_type: Mapped[RewardEntryType] = mapped_column(
        Enum(RewardEntryType, name="reward_entry_type", native_enum=False),
        nullable=False,
    )
    rule_code: Mapped[str | None] = mapped_column(Text, nullable=True)
    amount: Mapped[int] = mapped_column(BigInteger, nullable=False)
    balance_after: Mapped[int] = mapped_column(BigInteger, nullable=False)
    reference_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    reference_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class RewardBalance(Base):
    __tablename__ = "reward_balance"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    balance: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class DiscountRedemption(Base):
    __tablename__ = "discount_redemption"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    context_type: Mapped[RedemptionContextType] = mapped_column(
        Enum(RedemptionContextType, name="redemption_context_type", native_enum=False),
        nullable=False,
    )
    context_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    points_spent: Mapped[int] = mapped_column(BigInteger, nullable=False)
    discount_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    status: Mapped[DiscountRedemptionStatus] = mapped_column(
        Enum(DiscountRedemptionStatus, name="discount_redemption_status", native_enum=False),
        nullable=False,
        default=DiscountRedemptionStatus.reserved,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ReminderJob(Base):
    __tablename__ = "reminder_job"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    kind: Mapped[ReminderKind] = mapped_column(
        Enum(ReminderKind, name="reminder_kind", native_enum=False),
        nullable=False,
    )
    reference_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    scheduled_for: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    status: Mapped[ReminderStatus] = mapped_column(
        Enum(ReminderStatus, name="reminder_status", native_enum=False),
        nullable=False,
        default=ReminderStatus.scheduled,
    )
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


Index("ix_reward_ledger_user_created", RewardLedgerEntry.user_id, RewardLedgerEntry.created_at.desc())
