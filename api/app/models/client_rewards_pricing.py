from __future__ import annotations

import enum
import uuid
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, BigInteger, Boolean, Date, DateTime, Enum, ForeignKey, Integer, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.niche import SkillTier


class ConsentRewardLevel(str, enum.Enum):
    none = "none"
    pro_marketing_only = "pro_marketing_only"
    rawwers_marketing_only = "rawwers_marketing_only"
    both_pro_and_rawwers = "both_pro_and_rawwers"


class ShareRewardMetric(str, enum.Enum):
    unique_views_30d = "unique_views_30d"
    conversions_30d = "conversions_30d"


class ExtraImagePurchaseStatus(str, enum.Enum):
    pending = "pending"
    paid = "paid"
    failed = "failed"
    refunded = "refunded"


class ExtraImagePricingPolicy(Base):
    __tablename__ = "extra_image_pricing_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    tier: Mapped[SkillTier] = mapped_column(Enum(SkillTier, name="skill_tier", native_enum=False), nullable=False)
    unit_price_min: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    unit_price_max: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    max_extra_images: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bulk_curve: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("niche_id", "tier", name="uq_extra_image_pricing_policy_niche_tier"),)


class ProExtraImagePrice(Base):
    __tablename__ = "pro_extra_image_price"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    configured_unit_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("pro_user_id", "niche_id", name="uq_pro_extra_image_price_pro_niche"),)


class ConsentRewardPolicy(Base):
    __tablename__ = "consent_reward_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    consent_level: Mapped[ConsentRewardLevel] = mapped_column(
        Enum(ConsentRewardLevel, name="consent_reward_level", native_enum=False), nullable=False, unique=True
    )
    points_award: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    cooldown_hours: Mapped[int] = mapped_column(Integer, nullable=False, default=48)
    allow_clawback: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    max_awards_per_user_per_month: Mapped[int] = mapped_column(Integer, nullable=False, default=10)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class ShareLinkView(Base):
    __tablename__ = "share_link_view"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    share_link_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("share_link.id"), nullable=False, index=True)
    ip_hash: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    ua_hash: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    fingerprint: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    viewed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)
    viewed_on: Mapped[date] = mapped_column(Date, nullable=False, default=lambda: datetime.now(timezone.utc).date(), index=True)
    seconds_viewed: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    __table_args__ = (UniqueConstraint("share_link_id", "fingerprint", "viewed_on", name="uq_share_link_view_daily_fingerprint"),)


class ShareLinkEngagement(Base):
    __tablename__ = "share_link_engagement"

    share_link_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("share_link.id"), primary_key=True)
    unique_views_7d: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    unique_views_30d: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    conversions_30d: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class ShareRewardThreshold(Base):
    __tablename__ = "share_reward_threshold"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    metric: Mapped[ShareRewardMetric] = mapped_column(
        Enum(ShareRewardMetric, name="share_reward_metric", native_enum=False), nullable=False
    )
    threshold_value: Mapped[int] = mapped_column(Integer, nullable=False)
    points_award: Mapped[int] = mapped_column(BigInteger, nullable=False)
    max_awards_per_share_link: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("metric", "threshold_value", name="uq_share_reward_threshold_metric_value"),)


class ShareRewardGrant(Base):
    __tablename__ = "share_reward_grant"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    share_link_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("share_link.id"), nullable=False, index=True)
    metric: Mapped[str] = mapped_column(Text, nullable=False)
    threshold_value: Mapped[int] = mapped_column(Integer, nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    reward_ledger_entry_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("share_link_id", "metric", "threshold_value", "user_id", name="uq_share_reward_grant_unique"),)


class ExtraImagePurchase(Base):
    __tablename__ = "extra_image_purchase"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=True, index=True)
    included_images: Mapped[int] = mapped_column(Integer, nullable=False)
    selected_images: Mapped[int] = mapped_column(Integer, nullable=False)
    extra_images: Mapped[int] = mapped_column(Integer, nullable=False)
    unit_price_applied: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    unit_price_configured: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    policy_unit_price_min: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    policy_unit_price_max: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    subtotal: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    points_spent: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    discounts_total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    stripe_payment_intent_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    status: Mapped[ExtraImagePurchaseStatus] = mapped_column(
        Enum(ExtraImagePurchaseStatus, name="extra_image_purchase_status", native_enum=False), nullable=False, default=ExtraImagePurchaseStatus.pending
    )
    share_link_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("share_link.id"), nullable=True, index=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class ShareFraudSetting(Base):
    __tablename__ = "share_fraud_setting"

    key: Mapped[str] = mapped_column(Text, primary_key=True)
    value: Mapped[int] = mapped_column(Integer, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )
