import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, ForeignKey, Index, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.media import Base


class UserRoleType(str, enum.Enum):
    admin = "admin"
    pro = "pro"
    client = "client"


class UserAccountStatus(str, enum.Enum):
    active = "active"
    disabled = "disabled"
    deleted = "deleted"


class KYCStatus(str, enum.Enum):
    unsubmitted = "unsubmitted"
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class BanActionType(str, enum.Enum):
    none = "none"
    warning = "warning"
    suspended = "suspended"
    banned = "banned"


class DisputeStatus(str, enum.Enum):
    open = "open"
    awaiting_response = "awaiting_response"
    in_review = "in_review"
    awaiting_admin = "awaiting_admin"
    under_review = "under_review"
    resolved_refund = "resolved_refund"
    resolved_no_refund = "resolved_no_refund"
    resolved_partial_refund = "resolved_partial_refund"
    cancelled = "cancelled"
    closed = "closed"


class DisputeCategory(str, enum.Enum):
    no_show = "no_show"
    late_cancellation = "late_cancellation"
    late_delivery = "late_delivery"
    deliverable_quality = "deliverable_quality"
    billing = "billing"
    fraud = "fraud"
    quality = "quality"
    harassment = "harassment"
    payment = "payment"
    other = "other"


class EvidenceKind(str, enum.Enum):
    text = "text"
    media = "media"


class RefundCaseStatus(str, enum.Enum):
    pending = "pending"
    refund_initiated = "refund_initiated"
    refunded = "refunded"
    cancelled = "cancelled"
    requested = "requested"
    approved = "approved"
    rejected = "rejected"
    processing = "processing"
    succeeded = "succeeded"
    failed = "failed"


class DisputeActorType(str, enum.Enum):
    client = "client"
    pro = "pro"
    admin = "admin"
    system = "system"


class RefundPaymentScope(str, enum.Enum):
    booking_payment = "booking_payment"
    extra_image_purchase = "extra_image_purchase"


class EntitlementHoldType(str, enum.Enum):
    downloads_frozen = "downloads_frozen"
    share_disabled = "share_disabled"


class ProQualityPenaltyType(str, enum.Enum):
    warning = "warning"
    visibility_downrank = "visibility_downrank"
    temporary_suspension = "temporary_suspension"


class ProQualityPenaltySeverity(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"


class RefundPolicyDefaultAction(str, enum.Enum):
    full_refund = "full_refund"
    partial_refund = "partial_refund"
    no_refund = "no_refund"
    admin_review = "admin_review"


class UserAccount(Base):
    __tablename__ = "user_account"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    email: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True, index=True)
    phone_e164: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True, index=True)
    password_hash: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[UserAccountStatus] = mapped_column(
        Enum(UserAccountStatus, name="user_account_status", native_enum=False),
        nullable=False,
        default=UserAccountStatus.active,
        index=True,
    )
    email_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    last_login_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    display_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class UserRole(Base):
    __tablename__ = "user_role"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    role: Mapped[UserRoleType] = mapped_column(Enum(UserRoleType, name="user_role_type", native_enum=False), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("user_id", "role", name="uq_user_role_user_role"),)


class ProProfile(Base):
    __tablename__ = "pro_profile"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), primary_key=True)
    display_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    headline: Mapped[str | None] = mapped_column(Text, nullable=True)
    cover_media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    city: Mapped[str | None] = mapped_column(Text, nullable=True)
    country: Mapped[str | None] = mapped_column(Text, nullable=True)
    languages: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    styles: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    gear: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    is_accepting_bookings: Mapped[bool] = mapped_column(nullable=False, default=False)
    completeness_score: Mapped[int] = mapped_column(nullable=False, default=0)
    kyc_status: Mapped[KYCStatus] = mapped_column(Enum(KYCStatus, name="kyc_status", native_enum=False), nullable=False, default=KYCStatus.unsubmitted)
    kyc_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    kyc_updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class BanAction(Base):
    __tablename__ = "ban_action"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    action: Mapped[BanActionType] = mapped_column(Enum(BanActionType, name="ban_action_type", native_enum=False), nullable=False)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    actor_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    starts_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    ends_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class AdminAuditLog(Base):
    __tablename__ = "admin_audit_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    actor_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    target_type: Mapped[str] = mapped_column(Text, nullable=False)
    target_id: Mapped[str] = mapped_column(Text, nullable=False)
    action: Mapped[str] = mapped_column(Text, nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class Dispute(Base):
    __tablename__ = "dispute"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=True, index=True)
    extra_purchase_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("extra_image_purchase.id"), nullable=True, index=True)
    opened_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    against_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    status: Mapped[DisputeStatus] = mapped_column(Enum(DisputeStatus, name="dispute_status", native_enum=False), nullable=False)
    category: Mapped[DisputeCategory] = mapped_column(Enum(DisputeCategory, name="dispute_category", native_enum=False), nullable=False)
    requested_refund_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    opened_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    due_response_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    resolution: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    summary: Mapped[str] = mapped_column(Text, nullable=False)
    resolution_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    evidences: Mapped[list["DisputeEvidence"]] = relationship(back_populates="dispute", cascade="all, delete-orphan")


class DisputeEvidence(Base):
    __tablename__ = "dispute_evidence"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    dispute_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("dispute.id"), nullable=False, index=True)
    submitted_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    kind: Mapped[EvidenceKind] = mapped_column(Enum(EvidenceKind, name="evidence_kind", native_enum=False), nullable=False)
    text: Mapped[str | None] = mapped_column(Text, nullable=True)
    media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    dispute: Mapped[Dispute] = relationship(back_populates="evidences")


class RefundCase(Base):
    __tablename__ = "refund_case"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=True, index=True)
    dispute_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("dispute.id"), nullable=True)
    requested_by_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    payment_scope: Mapped[RefundPaymentScope | None] = mapped_column(
        Enum(RefundPaymentScope, name="refund_payment_scope", native_enum=False),
        nullable=True,
    )
    reference_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    stripe_payment_intent_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    amount_authorized: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    amount_refunded: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    status: Mapped[RefundCaseStatus] = mapped_column(Enum(RefundCaseStatus, name="refund_case_status", native_enum=False), nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    admin_note: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class DisputeMessage(Base):
    __tablename__ = "dispute_message"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    dispute_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("dispute.id"), nullable=False, index=True)
    sender_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_media_asset_ids: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class DisputeEvent(Base):
    __tablename__ = "dispute_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    dispute_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("dispute.id"), nullable=False, index=True)
    from_status: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_status: Mapped[str] = mapped_column(Text, nullable=False)
    actor_type: Mapped[DisputeActorType] = mapped_column(
        Enum(DisputeActorType, name="dispute_actor_type", native_enum=False),
        nullable=False,
    )
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class RefundEvent(Base):
    __tablename__ = "refund_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    refund_case_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("refund_case.id"), nullable=False, index=True)
    type: Mapped[str] = mapped_column(Text, nullable=False)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class GigContractSnapshot(Base):
    __tablename__ = "gig_contract_snapshot"

    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), primary_key=True)
    snapshot: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class DeliverySlaSnapshot(Base):
    __tablename__ = "delivery_sla_snapshot"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    proofs_due_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    finals_due_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    proofs_published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    finals_delivered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class EntitlementHold(Base):
    __tablename__ = "entitlement_hold"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    hold_type: Mapped[EntitlementHoldType] = mapped_column(
        Enum(EntitlementHoldType, name="entitlement_hold_type", native_enum=False),
        nullable=False,
    )
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    released_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class ProQualityPenalty(Base):
    __tablename__ = "pro_quality_penalty"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    dispute_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("dispute.id"), nullable=True, index=True)
    type: Mapped[ProQualityPenaltyType] = mapped_column(
        Enum(ProQualityPenaltyType, name="pro_quality_penalty_type", native_enum=False),
        nullable=False,
    )
    severity: Mapped[ProQualityPenaltySeverity] = mapped_column(
        Enum(ProQualityPenaltySeverity, name="pro_quality_penalty_severity", native_enum=False),
        nullable=False,
    )
    applied_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)


class RefundPolicy(Base):
    __tablename__ = "refund_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    category: Mapped[DisputeCategory] = mapped_column(
        Enum(DisputeCategory, name="dispute_category", native_enum=False),
        nullable=False,
        unique=True,
    )
    default_action: Mapped[RefundPolicyDefaultAction] = mapped_column(
        Enum(RefundPolicyDefaultAction, name="refund_policy_default_action", native_enum=False),
        nullable=False,
    )
    max_refund_percent: Mapped[int | None] = mapped_column(nullable=True)
    response_window_hours: Mapped[int] = mapped_column(nullable=False, default=72)
    requires_evidence: Mapped[bool] = mapped_column(nullable=False, default=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


Index("ix_ban_action_user_created", BanAction.user_id, BanAction.created_at.desc())
Index("ix_dispute_status", Dispute.status)
Index("ix_dispute_opened_at", Dispute.opened_at)
