import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, ForeignKey, Index, Integer, Text, Time, Numeric
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class BookingRequestStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    declined = "declined"
    expired = "expired"
    cancelled = "cancelled"


class ProPackage(Base):
    __tablename__ = "pro_package"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
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
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ProBlackoutDate(Base):
    __tablename__ = "pro_blackout_date"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


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


Index("ix_booking_request_package_id", BookingRequest.package_id)
