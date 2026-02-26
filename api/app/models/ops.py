import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, Enum, Index, JSON, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class AbuseSeverity(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"


class AbuseSignalStatus(str, enum.Enum):
    open = "open"
    resolved = "resolved"
    ignored = "ignored"


class FeatureFlagScope(str, enum.Enum):
    global_scope = "global"
    user = "user"
    pro = "pro"
    admin = "admin"


class WebhookSecurityLog(Base):
    __tablename__ = "webhook_security_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    event_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    signature_valid: Mapped[bool] = mapped_column(nullable=False)
    ip: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    received_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class AbuseSignal(Base):
    __tablename__ = "abuse_signal"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    ip_hash: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    signal_type: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    severity: Mapped[AbuseSeverity] = mapped_column(
        Enum(AbuseSeverity, name="abuse_severity", native_enum=False),
        nullable=False,
        default=AbuseSeverity.low,
        index=True,
    )
    evidence: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    status: Mapped[AbuseSignalStatus] = mapped_column(
        Enum(AbuseSignalStatus, name="abuse_signal_status", native_enum=False),
        nullable=False,
        default=AbuseSignalStatus.open,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class FeatureFlag(Base):
    __tablename__ = "feature_flag"

    key: Mapped[str] = mapped_column(Text, primary_key=True)
    is_enabled: Mapped[bool] = mapped_column(nullable=False, default=True)
    scope: Mapped[FeatureFlagScope] = mapped_column(
        Enum(FeatureFlagScope, name="feature_flag_scope", native_enum=False),
        nullable=False,
        default=FeatureFlagScope.global_scope,
    )
    rules: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


Index("ix_abuse_signal_type_status", AbuseSignal.signal_type, AbuseSignal.status)
