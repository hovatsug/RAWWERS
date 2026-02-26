import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, ForeignKey, Index, Integer, Text, Time, Numeric, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class BookingRequestStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    declined = "declined"
    expired = "expired"
    cancelled = "cancelled"


class AvailabilityLocationMode(str, enum.Enum):
    on_site = "on_site"
    studio = "studio"
    both = "both"


class ConfirmedSlotStatus(str, enum.Enum):
    reserved = "reserved"
    confirmed = "confirmed"
    cancelled = "cancelled"
    completed = "completed"


class ProPackage(Base):
    __tablename__ = "pro_package"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    included_photos: Mapped[int] = mapped_column(Integer, nullable=False)
    extra_photo_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    proofs_sla_days: Mapped[int] = mapped_column(Integer, nullable=False, default=3)
    finals_sla_days: Mapped[int] = mapped_column(Integer, nullable=False, default=7)
    addons: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class ProAvailabilityRule(Base):
    __tablename__ = "pro_availability_rule"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    day_of_week: Mapped[int] = mapped_column(Integer, nullable=False)
    start_time: Mapped[datetime.time] = mapped_column(Time(timezone=False), nullable=False)
    end_time: Mapped[datetime.time] = mapped_column(Time(timezone=False), nullable=False)
    timezone: Mapped[str] = mapped_column(Text, nullable=False, default="UTC")
    location_mode: Mapped[AvailabilityLocationMode] = mapped_column(
        Enum(AvailabilityLocationMode, name="availability_location_mode", native_enum=False),
        nullable=False,
        default=AvailabilityLocationMode.both,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ProBlackoutDate(Base):
    __tablename__ = "pro_blackout_date"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ProAvailabilityException(Base):
    __tablename__ = "pro_availability_exception"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    start_at_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ProSchedulingPolicy(Base):
    __tablename__ = "pro_scheduling_policy"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    slot_length_minutes: Mapped[int] = mapped_column(Integer, nullable=False, default=60)
    buffer_before_minutes: Mapped[int] = mapped_column(Integer, nullable=False, default=15)
    buffer_after_minutes: Mapped[int] = mapped_column(Integer, nullable=False, default=15)
    advance_notice_hours: Mapped[int] = mapped_column(Integer, nullable=False, default=24)
    max_bookings_per_day: Mapped[int | None] = mapped_column(Integer, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class BookingRequest(Base):
    __tablename__ = "booking_request"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    package_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("pro_package.id"), nullable=False)
    requested_start: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    requested_end: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    location_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[BookingRequestStatus] = mapped_column(
        Enum(BookingRequestStatus, name="booking_request_status", native_enum=False),
        nullable=False,
        default=BookingRequestStatus.pending,
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class BookingRequestTransition(Base):
    __tablename__ = "booking_request_transition"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    booking_request_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("booking_request.id"), nullable=False, index=True)
    from_status: Mapped[BookingRequestStatus] = mapped_column(Enum(BookingRequestStatus, name="booking_request_status", native_enum=False), nullable=False)
    to_status: Mapped[BookingRequestStatus] = mapped_column(Enum(BookingRequestStatus, name="booking_request_status", native_enum=False), nullable=False)
    actor_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class BookingTimeRequest(Base):
    __tablename__ = "booking_time_request"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    booking_request_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("booking_request.id"), nullable=False, index=True)
    client_timezone: Mapped[str] = mapped_column(Text, nullable=False)
    windows: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ConfirmedSlot(Base):
    __tablename__ = "confirmed_slot"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, unique=True, index=True)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    start_at_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at_utc: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    status: Mapped[ConfirmedSlotStatus] = mapped_column(
        Enum(ConfirmedSlotStatus, name="confirmed_slot_status", native_enum=False),
        nullable=False,
        default=ConfirmedSlotStatus.confirmed,
    )
    cancellation_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (
        UniqueConstraint("pro_user_id", "start_at_utc", "end_at_utc", name="uq_confirmed_slot_pro_time"),
    )


class CancellationPolicySnapshot(Base):
    __tablename__ = "cancellation_policy_snapshot"

    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), primary_key=True)
    snapshot: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


Index("ix_booking_request_package_id", BookingRequest.package_id)
