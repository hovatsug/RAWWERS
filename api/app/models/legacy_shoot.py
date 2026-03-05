from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, ForeignKey, Integer, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class LegacyBookingStatus(str, enum.Enum):
    brief_pending = "brief_pending"
    brief_submitted = "brief_submitted"
    pro_assigned = "pro_assigned"
    scheduled = "scheduled"
    shoot_done = "shoot_done"
    edit_in_progress = "edit_in_progress"
    client_review = "client_review"
    approved = "approved"
    delivered = "delivered"
    cancelled = "cancelled"


class LegacyPaymentMode(str, enum.Enum):
    full = "full"
    deposit = "deposit"


class LegacyTone(str, enum.Enum):
    cinematic = "cinematic"
    documentary = "documentary"
    intimate = "intimate"
    heroic = "heroic"
    minimalist = "minimalist"


class LegacyPrivacyLevel(str, enum.Enum):
    private = "private"
    family_only = "family_only"
    public_opt_in = "public_opt_in"


class VaultItemType(str, enum.Enum):
    photo_set = "photo_set"
    storybook_pdf = "storybook_pdf"
    cinematic_video = "cinematic_video"
    voice_audio = "voice_audio"
    notes = "notes"
    other = "other"


class VaultItemStatus(str, enum.Enum):
    draft = "draft"
    submitted = "submitted"
    approved = "approved"
    rejected = "rejected"
    final = "final"


class VaultAccessAction(str, enum.Enum):
    view = "view"
    download = "download"
    upload = "upload"


class LegacyReviewStage(str, enum.Enum):
    edit_preview = "edit_preview"
    final_delivery = "final_delivery"


class LegacyReviewResponse(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    changes_requested = "changes_requested"
    rejected = "rejected"


class PremiumProduct(Base):
    __tablename__ = "premium_product"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    name_key: Mapped[str] = mapped_column(Text, nullable=False)
    description_key: Mapped[str] = mapped_column(Text, nullable=False)
    base_price_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    deposit_price_eur: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False, default=180)
    eligibility_rules: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class LegacyBooking(Base):
    __tablename__ = "legacy_booking"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, unique=True, index=True)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    assigned_pro_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    status: Mapped[LegacyBookingStatus] = mapped_column(
        Enum(LegacyBookingStatus, name="legacy_booking_status", native_enum=False), nullable=False, default=LegacyBookingStatus.brief_pending, index=True
    )
    price_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    payment_mode: Mapped[LegacyPaymentMode] = mapped_column(
        Enum(LegacyPaymentMode, name="legacy_payment_mode", native_enum=False), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class LegacyBrief(Base):
    __tablename__ = "legacy_brief"

    legacy_booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("legacy_booking.id"), primary_key=True)
    answers: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    tone: Mapped[LegacyTone | None] = mapped_column(Enum(LegacyTone, name="legacy_tone", native_enum=False), nullable=True)
    privacy_level: Mapped[LegacyPrivacyLevel] = mapped_column(
        Enum(LegacyPrivacyLevel, name="legacy_privacy_level", native_enum=False), nullable=False, default=LegacyPrivacyLevel.private
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class VaultItem(Base):
    __tablename__ = "vault_item"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    legacy_booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("legacy_booking.id"), nullable=False, index=True)
    type: Mapped[VaultItemType] = mapped_column(Enum(VaultItemType, name="vault_item_type", native_enum=False), nullable=False)
    storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    content_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    bytes: Mapped[int | None] = mapped_column(nullable=True)
    version: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    status: Mapped[VaultItemStatus] = mapped_column(
        Enum(VaultItemStatus, name="vault_item_status", native_enum=False), nullable=False, default=VaultItemStatus.draft, index=True
    )
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class VaultAccessLog(Base):
    __tablename__ = "vault_access_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    legacy_booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("legacy_booking.id"), nullable=False, index=True)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    action: Mapped[VaultAccessAction] = mapped_column(
        Enum(VaultAccessAction, name="vault_access_action", native_enum=False), nullable=False
    )
    vault_item_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("vault_item.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class LegacyReview(Base):
    __tablename__ = "legacy_review"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    legacy_booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("legacy_booking.id"), nullable=False, index=True)
    stage: Mapped[LegacyReviewStage] = mapped_column(
        Enum(LegacyReviewStage, name="legacy_review_stage", native_enum=False), nullable=False
    )
    submitted_by: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    client_response: Mapped[LegacyReviewResponse] = mapped_column(
        Enum(LegacyReviewResponse, name="legacy_review_response", native_enum=False), nullable=False, default=LegacyReviewResponse.pending
    )
    client_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    item_ids: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class LegacyMarketingConsent(Base):
    __tablename__ = "legacy_marketing_consent"

    legacy_booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("legacy_booking.id"), primary_key=True)
    consent: Mapped[bool] = mapped_column(nullable=False, default=False)
    channels: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )
