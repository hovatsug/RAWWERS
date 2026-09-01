from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, Enum, JSON, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class RiskLevel(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"


class RiskActionType(str, enum.Enum):
    throttle_bookings = "throttle_bookings"
    disable_share_links = "disable_share_links"
    freeze_rewards = "freeze_rewards"
    freeze_payouts = "freeze_payouts"
    require_verification = "require_verification"
    force_logout = "force_logout"
    manual_review = "manual_review"


class RiskActionStatus(str, enum.Enum):
    active = "active"
    cleared = "cleared"


class DeviceFingerprint(Base):
    __tablename__ = "device_fingerprint"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    fingerprint_hash: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    first_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)


class IpSignal(Base):
    __tablename__ = "ip_signal"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ip_hash: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    first_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)


class SessionSignal(Base):
    __tablename__ = "session_signal"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id_hash: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    device_fingerprint_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    ip_hash: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class RiskProfile(Base):
    __tablename__ = "risk_profile"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    risk_score: Mapped[int] = mapped_column(nullable=False, default=0)
    risk_level: Mapped[RiskLevel] = mapped_column(
        Enum(RiskLevel, name="risk_level", native_enum=False),
        nullable=False,
        default=RiskLevel.low,
        index=True,
    )
    reasons: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    flags: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    last_calculated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class RiskEvent(Base):
    __tablename__ = "risk_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    rule_id: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    delta: Mapped[int] = mapped_column(nullable=False)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class RiskAction(Base):
    __tablename__ = "risk_action"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    action_type: Mapped[RiskActionType] = mapped_column(
        Enum(RiskActionType, name="risk_action_type", native_enum=False),
        nullable=False,
        index=True,
    )
    status: Mapped[RiskActionStatus] = mapped_column(
        Enum(RiskActionStatus, name="risk_action_status", native_enum=False),
        nullable=False,
        default=RiskActionStatus.active,
        index=True,
    )
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    cleared_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class RiskRule(Base):
    __tablename__ = "risk_rule"

    id: Mapped[str] = mapped_column(Text, primary_key=True)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    params: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    score_delta: Mapped[int] = mapped_column(nullable=False, default=0)
    action_on_trigger: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
