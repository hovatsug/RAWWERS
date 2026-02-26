from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import (
    CHAR,
    JSON,
    BigInteger,
    DateTime,
    Enum,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.media_rights import GigConsentLevel


class ContentPackCategory(str, enum.Enum):
    preset = "preset"
    lut = "lut"
    social_pack = "social_pack"
    template = "template"
    captions = "captions"
    thumbnail_pack = "thumbnail_pack"
    reel_pack = "reel_pack"
    other = "other"


class ContentPackStatus(str, enum.Enum):
    draft = "draft"
    submitted = "submitted"
    approved = "approved"
    rejected = "rejected"
    delisted = "delisted"


class PackSourceType(str, enum.Enum):
    gig = "gig"
    template_upload = "template_upload"


class ContentPackPaymentMethod(str, enum.Enum):
    stripe = "stripe"
    raww_credits = "raww_credits"
    mixed = "mixed"


class ContentPackOrderStatus(str, enum.Enum):
    pending = "pending"
    paid = "paid"
    failed = "failed"
    refunded = "refunded"


class RoyaltyLedgerStatus(str, enum.Enum):
    pending = "pending"
    settled = "settled"
    reversed = "reversed"


class ContentPackReviewDecision(str, enum.Enum):
    approved = "approved"
    rejected = "rejected"


class ContentPack(Base):
    __tablename__ = "content_pack"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    creator_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    category: Mapped[ContentPackCategory] = mapped_column(
        Enum(ContentPackCategory, name="content_pack_category", native_enum=False),
        nullable=False,
    )
    niche_slugs: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    tags: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    price_eur: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    price_raww: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    cover_media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=True)
    preview_media_asset_ids: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    pack_file_storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    pack_file_bytes: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    license_code: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[ContentPackStatus] = mapped_column(
        Enum(ContentPackStatus, name="content_pack_status", native_enum=False),
        nullable=False,
        default=ContentPackStatus.draft,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class ContentPackVersion(Base):
    __tablename__ = "content_pack_version"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    version: Mapped[int] = mapped_column(Integer, nullable=False)
    pack_file_storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    release_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("content_pack_id", "version", name="uq_content_pack_version"),)


class ContentLicense(Base):
    __tablename__ = "content_license"

    code: Mapped[str] = mapped_column(Text, primary_key=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    terms: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class PackSourceReference(Base):
    __tablename__ = "pack_source_reference"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    source_type: Mapped[PackSourceType] = mapped_column(
        Enum(PackSourceType, name="pack_source_type", native_enum=False),
        nullable=False,
    )
    gig_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=True, index=True)
    evidence: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    requires_consent_level: Mapped[GigConsentLevel] = mapped_column(
        Enum(GigConsentLevel, name="gig_consent_level", native_enum=False),
        nullable=False,
        default=GigConsentLevel.both_pro_and_rawwers,
    )
    is_consent_verified: Mapped[bool] = mapped_column(nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ContentPackOrder(Base):
    __tablename__ = "content_pack_order"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    price_eur_paid: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    price_raww_paid: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    payment_method: Mapped[ContentPackPaymentMethod] = mapped_column(
        Enum(ContentPackPaymentMethod, name="content_pack_payment_method", native_enum=False),
        nullable=False,
    )
    stripe_payment_intent_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    status: Mapped[ContentPackOrderStatus] = mapped_column(
        Enum(ContentPackOrderStatus, name="content_pack_order_status", native_enum=False),
        nullable=False,
        default=ContentPackOrderStatus.pending,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ContentPackEntitlement(Base):
    __tablename__ = "content_pack_entitlement"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack_order.id"), nullable=False, unique=True, index=True)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    valid_from: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    valid_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    download_limit: Mapped[int] = mapped_column(Integer, nullable=False, default=20)
    downloads_used: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class RoyaltyRule(Base):
    __tablename__ = "royalty_rule"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    category: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    platform_fee_percent: Mapped[int] = mapped_column(Integer, nullable=False)
    creator_percent: Mapped[int] = mapped_column(Integer, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RoyaltyLedgerEntry(Base):
    __tablename__ = "royalty_ledger_entry"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_pack_order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack_order.id"), nullable=False, index=True)
    creator_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    gross_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    fee_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    net_creator_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    gross_raww: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    fee_raww: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    net_creator_raww: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    status: Mapped[RoyaltyLedgerStatus] = mapped_column(
        Enum(RoyaltyLedgerStatus, name="royalty_ledger_status", native_enum=False),
        nullable=False,
        default=RoyaltyLedgerStatus.pending,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ContentPackReview(Base):
    __tablename__ = "content_pack_review"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    reviewer_admin_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    decision: Mapped[ContentPackReviewDecision] = mapped_column(
        Enum(ContentPackReviewDecision, name="content_pack_review_decision", native_enum=False),
        nullable=False,
    )
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ContentPackTakedown(Base):
    __tablename__ = "content_pack_takedown"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    admin_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class PackDownloadLog(Base):
    __tablename__ = "pack_download_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack_order.id"), nullable=False, index=True)
    entitlement_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack_entitlement.id"), nullable=False, index=True)
    buyer_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    content_pack_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("content_pack.id"), nullable=False, index=True)
    download_number: Mapped[int] = mapped_column(Integer, nullable=False)
    ip_hash: Mapped[str | None] = mapped_column(Text, nullable=True)
    user_agent: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


Index("ix_content_pack_status_updated", ContentPack.status, ContentPack.updated_at.desc())
Index("ix_content_pack_order_buyer_created", ContentPackOrder.buyer_user_id, ContentPackOrder.created_at.desc())
Index("ix_pack_download_log_pack_created", PackDownloadLog.content_pack_id, PackDownloadLog.created_at.desc())
