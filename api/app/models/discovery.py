import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, Integer, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.admin import KYCStatus
from app.models.media import Base


class ProPublicIndex(Base):
    __tablename__ = "pro_public_index"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    city: Mapped[str | None] = mapped_column(Text, nullable=True)
    country: Mapped[str | None] = mapped_column(Text, nullable=True)
    styles: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    min_package_price: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    max_package_price: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    is_accepting_bookings: Mapped[bool] = mapped_column(nullable=False, default=False, index=True)
    kyc_status: Mapped[KYCStatus] = mapped_column(
        Enum(KYCStatus, name="kyc_status", native_enum=False),
        nullable=False,
        default=KYCStatus.unsubmitted,
        index=True,
    )
    completeness_score: Mapped[int] = mapped_column(Integer, nullable=False, default=0, index=True)
    portfolio_photo_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    portfolio_video_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    gigs_completed: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    gigs_cancelled: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    disputes_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    avg_response_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    avg_rating: Mapped[Decimal] = mapped_column(Numeric(3, 2), nullable=False, default=Decimal("0.00"))
    review_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    ranking_score: Mapped[Decimal] = mapped_column(Numeric(10, 4), nullable=False, default=Decimal("0.0000"))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class AnalyticsEvent(Base):
    __tablename__ = "analytics_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    session_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    event_name: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    properties: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)
