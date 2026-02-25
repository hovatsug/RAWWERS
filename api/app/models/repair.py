import enum
import uuid
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, Date, DateTime, Enum, ForeignKey, Index, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.niche import SkillTier


class GearCategory(str, enum.Enum):
    camera_body = "camera_body"
    lens = "lens"
    lighting = "lighting"
    audio = "audio"
    tripod = "tripod"
    drone = "drone"
    accessory = "accessory"


class RepairUrgency(str, enum.Enum):
    low = "low"
    normal = "normal"
    high = "high"


class RepairTicketStatus(str, enum.Enum):
    submitted = "submitted"
    partner_assigned = "partner_assigned"
    awaiting_quote = "awaiting_quote"
    quote_sent = "quote_sent"
    quote_approved = "quote_approved"
    quote_declined = "quote_declined"
    in_repair = "in_repair"
    ready_for_return = "ready_for_return"
    shipped_back = "shipped_back"
    closed = "closed"
    cancelled = "cancelled"


class RepairOutcome(str, enum.Enum):
    fixed = "fixed"
    not_fixed = "not_fixed"
    replaced = "replaced"
    unknown = "unknown"


class LoanerRequestStatus(str, enum.Enum):
    requested = "requested"
    approved = "approved"
    declined = "declined"
    ready_for_pickup = "ready_for_pickup"
    shipped_to_pro = "shipped_to_pro"
    in_use = "in_use"
    return_due = "return_due"
    returned = "returned"
    closed = "closed"
    cancelled = "cancelled"


class RepairActorType(str, enum.Enum):
    pro = "pro"
    admin = "admin"
    partner = "partner"
    system = "system"


class GearItem(Base):
    __tablename__ = "gear_item"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    category: Mapped[GearCategory] = mapped_column(Enum(GearCategory, name="gear_category", native_enum=False), nullable=False)
    brand: Mapped[str | None] = mapped_column(Text, nullable=True)
    model: Mapped[str | None] = mapped_column(Text, nullable=True)
    serial_number: Mapped[str | None] = mapped_column(Text, nullable=True)
    purchase_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RepairPartner(Base):
    __tablename__ = "repair_partner"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    country: Mapped[str] = mapped_column(Text, nullable=False)
    city: Mapped[str] = mapped_column(Text, nullable=False)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    service_radius_km: Mapped[int | None] = mapped_column(nullable=True)
    shipping_supported: Mapped[bool] = mapped_column(nullable=False, default=False)
    pickup_supported: Mapped[bool] = mapped_column(nullable=False, default=False)
    brands_supported: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    categories_supported: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    sla_quote_hours: Mapped[int | None] = mapped_column(nullable=True)
    sla_turnaround_days: Mapped[int | None] = mapped_column(nullable=True)
    loaner_supported: Mapped[bool] = mapped_column(nullable=False, default=False)
    loaner_categories: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    contact: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    partner_terms: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class GearBenefitPolicy(Base):
    __tablename__ = "gear_benefit_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    require_kyc_approved: Mapped[bool] = mapped_column(nullable=False, default=True)
    min_tier_any_niche: Mapped[SkillTier] = mapped_column(
        Enum(SkillTier, name="skill_tier", native_enum=False),
        nullable=False,
        default=SkillTier.skilled,
    )
    require_not_banned: Mapped[bool] = mapped_column(nullable=False, default=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class GearBenefitOverride(Base):
    __tablename__ = "gear_benefit_override"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, unique=True, index=True)
    is_allowed: Mapped[bool] = mapped_column(nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    granted_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class RepairTicket(Base):
    __tablename__ = "repair_ticket"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    gear_item_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("gear_item.id"), nullable=True, index=True)
    partner_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("repair_partner.id"), nullable=True, index=True)
    status: Mapped[RepairTicketStatus] = mapped_column(
        Enum(RepairTicketStatus, name="repair_ticket_status", native_enum=False),
        nullable=False,
        default=RepairTicketStatus.submitted,
    )
    urgency: Mapped[RepairUrgency] = mapped_column(
        Enum(RepairUrgency, name="repair_urgency", native_enum=False),
        nullable=False,
        default=RepairUrgency.normal,
    )
    issue_description: Mapped[str] = mapped_column(Text, nullable=False)
    evidence_media_asset_ids: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    quote_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    quote_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    quote_sent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    quote_approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    repair_started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    repair_completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    return_shipped_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    shipping: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    outcome: Mapped[RepairOutcome] = mapped_column(
        Enum(RepairOutcome, name="repair_outcome", native_enum=False),
        nullable=False,
        default=RepairOutcome.unknown,
    )
    reopened_from_ticket_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class RepairEvent(Base):
    __tablename__ = "repair_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ticket_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("repair_ticket.id"), nullable=False, index=True)
    from_status: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_status: Mapped[str] = mapped_column(Text, nullable=False)
    actor_type: Mapped[RepairActorType] = mapped_column(
        Enum(RepairActorType, name="repair_actor_type", native_enum=False),
        nullable=False,
    )
    actor_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class LoanerRequest(Base):
    __tablename__ = "loaner_request"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ticket_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("repair_ticket.id"), nullable=False, index=True)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    partner_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("repair_partner.id"), nullable=True, index=True)
    status: Mapped[LoanerRequestStatus] = mapped_column(
        Enum(LoanerRequestStatus, name="loaner_request_status", native_enum=False),
        nullable=False,
        default=LoanerRequestStatus.requested,
    )
    category: Mapped[GearCategory] = mapped_column(Enum(GearCategory, name="gear_category", native_enum=False), nullable=False)
    terms_snapshot: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    deposit_required: Mapped[bool] = mapped_column(nullable=False, default=False)
    deposit_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    deposit_reference: Mapped[str | None] = mapped_column(Text, nullable=True)
    max_days: Mapped[int | None] = mapped_column(nullable=True)
    start_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    due_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    shipping: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class LoanerEvent(Base):
    __tablename__ = "loaner_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    loaner_request_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("loaner_request.id"), nullable=False, index=True)
    from_status: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_status: Mapped[str] = mapped_column(Text, nullable=False)
    actor_type: Mapped[RepairActorType] = mapped_column(
        Enum(RepairActorType, name="repair_actor_type", native_enum=False),
        nullable=False,
    )
    actor_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class RepairPartnerScore(Base):
    __tablename__ = "repair_partner_score"

    partner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("repair_partner.id"), primary_key=True)
    tickets_count: Mapped[int] = mapped_column(nullable=False, default=0)
    avg_quote_hours: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    avg_turnaround_days: Mapped[Decimal | None] = mapped_column(Numeric(10, 2), nullable=True)
    reopen_rate: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)
    dispute_rate: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)
    loaner_fulfillment_rate: Mapped[Decimal | None] = mapped_column(Numeric(5, 2), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


Index("ix_gear_item_pro_category_brand", GearItem.pro_user_id, GearItem.category, GearItem.brand)
Index("ix_repair_partner_country_city", RepairPartner.country, RepairPartner.city)
