from __future__ import annotations

import enum
import uuid
from datetime import datetime, time, timezone

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Index, Integer, JSON, Text, Time, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class ConsentChannel(str, enum.Enum):
    sms = "sms"
    email = "email"
    phone_call = "phone_call"


class ConsentScope(str, enum.Enum):
    transactional = "transactional"
    marketing = "marketing"


class FollowupChannel(str, enum.Enum):
    in_app = "in_app"
    email = "email"
    sms = "sms"
    phone_call = "phone_call"


class FollowupJobStatus(str, enum.Enum):
    scheduled = "scheduled"
    running = "running"
    sent = "sent"
    skipped = "skipped"
    failed = "failed"
    cancelled = "cancelled"


class CallDirection(str, enum.Enum):
    outbound = "outbound"


class CallPurpose(str, enum.Enum):
    booking_confirmation = "booking_confirmation"
    payment_nudge = "payment_nudge"
    request_nudge = "request_nudge"
    reschedule = "reschedule"


class CallSessionStatus(str, enum.Enum):
    queued = "queued"
    dialing = "dialing"
    in_progress = "in_progress"
    completed = "completed"
    failed = "failed"
    cancelled = "cancelled"


class CallOutcome(str, enum.Enum):
    connected = "connected"
    no_answer = "no_answer"
    busy = "busy"
    failed = "failed"
    voicemail = "voicemail"
    cancelled = "cancelled"
    unknown = "unknown"


class NotificationStatus(str, enum.Enum):
    unread = "unread"
    read = "read"


class NotificationSeverity(str, enum.Enum):
    info = "info"
    important = "important"
    critical = "critical"


class NotificationDigestMode(str, enum.Enum):
    instant = "instant"
    daily = "daily"
    weekly = "weekly"


class EmailMessageStatus(str, enum.Enum):
    queued = "queued"
    sent = "sent"
    failed = "failed"


class NotificationEventChannel(str, enum.Enum):
    inapp = "inapp"
    email = "email"


class UserContact(Base):
    __tablename__ = "user_contact"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    phone_e164: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    timezone_name: Mapped[str] = mapped_column("timezone", Text, nullable=False, default="Europe/Lisbon")
    quiet_hours_start: Mapped[time] = mapped_column(Time(timezone=False), nullable=False, default=lambda: time(hour=22, minute=0))
    quiet_hours_end: Mapped[time] = mapped_column(Time(timezone=False), nullable=False, default=lambda: time(hour=8, minute=0))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ContactConsent(Base):
    __tablename__ = "contact_consent"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    channel: Mapped[ConsentChannel] = mapped_column(
        Enum(ConsentChannel, name="consent_channel", native_enum=False),
        nullable=False,
    )
    scope: Mapped[ConsentScope] = mapped_column(
        Enum(ConsentScope, name="consent_scope", native_enum=False),
        nullable=False,
    )
    granted: Mapped[bool] = mapped_column(nullable=False)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    source: Mapped[str] = mapped_column(Text, nullable=False)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class FollowupRule(Base):
    __tablename__ = "followup_rule"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    is_enabled: Mapped[bool] = mapped_column(nullable=False, default=True)
    trigger: Mapped[str] = mapped_column(Text, nullable=False)
    delay_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    channel: Mapped[FollowupChannel] = mapped_column(
        Enum(FollowupChannel, name="followup_channel", native_enum=False),
        nullable=False,
    )
    max_attempts: Mapped[int] = mapped_column(Integer, nullable=False, default=2)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class FollowupJob(Base):
    __tablename__ = "followup_job"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    rule_code: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    target_type: Mapped[str] = mapped_column(Text, nullable=False)
    target_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    scheduled_for: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    status: Mapped[FollowupJobStatus] = mapped_column(
        Enum(FollowupJobStatus, name="followup_job_status", native_enum=False),
        nullable=False,
        default=FollowupJobStatus.scheduled,
    )
    attempt: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    last_error: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (
        UniqueConstraint(
            "rule_code",
            "user_id",
            "target_type",
            "target_id",
            "scheduled_for",
            name="uq_followup_job_unique",
        ),
    )


class CallSession(Base):
    __tablename__ = "call_session"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider: Mapped[str] = mapped_column(Text, nullable=False)
    direction: Mapped[CallDirection] = mapped_column(
        Enum(CallDirection, name="call_direction", native_enum=False),
        nullable=False,
        default=CallDirection.outbound,
    )
    pro_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    recipient_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    recipient_phone_e164: Mapped[str] = mapped_column(Text, nullable=False)
    purpose: Mapped[CallPurpose] = mapped_column(
        Enum(CallPurpose, name="call_purpose", native_enum=False),
        nullable=False,
    )
    status: Mapped[CallSessionStatus] = mapped_column(
        Enum(CallSessionStatus, name="call_session_status", native_enum=False),
        nullable=False,
        default=CallSessionStatus.queued,
    )
    provider_call_id: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True)
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    outcome: Mapped[CallOutcome] = mapped_column(
        Enum(CallOutcome, name="call_outcome", native_enum=False),
        nullable=False,
        default=CallOutcome.unknown,
    )
    transcript: Mapped[str | None] = mapped_column(Text, nullable=True)
    summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class CallEvent(Base):
    __tablename__ = "call_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    call_session_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("call_session.id"), nullable=False, index=True)
    event_type: Mapped[str] = mapped_column(Text, nullable=False)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class Notification(Base):
    __tablename__ = "notification"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    topic: Mapped[str] = mapped_column(Text, nullable=False, default="general", index=True)
    type: Mapped[str] = mapped_column(Text, nullable=False, default="generic", index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    deep_link: Mapped[str | None] = mapped_column(Text, nullable=True)  # Legacy field.
    action: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    severity: Mapped[NotificationSeverity] = mapped_column(
        Enum(NotificationSeverity, name="notification_severity", native_enum=False),
        nullable=False,
        default=NotificationSeverity.info,
    )
    status: Mapped[NotificationStatus] = mapped_column(
        Enum(NotificationStatus, name="notification_status", native_enum=False),
        nullable=False,
        default=NotificationStatus.unread,
    )
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class NotificationPreference(Base):
    __tablename__ = "notification_preference"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    timezone_name: Mapped[str] = mapped_column("timezone", Text, nullable=False, default="Europe/Lisbon")
    quiet_hours_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    quiet_start_local: Mapped[time | None] = mapped_column(Time(timezone=False), nullable=True)
    quiet_end_local: Mapped[time | None] = mapped_column(Time(timezone=False), nullable=True)
    channel_email_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    channel_inapp_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    digest_mode: Mapped[NotificationDigestMode] = mapped_column(
        Enum(NotificationDigestMode, name="notification_digest_mode", native_enum=False),
        nullable=False,
        default=NotificationDigestMode.instant,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class NotificationTopicPreference(Base):
    __tablename__ = "notification_topic_preference"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    topic: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    email_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    inapp_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("user_id", "topic", name="uq_notification_topic_preference_user_topic"),)


class EmailMessage(Base):
    __tablename__ = "email_message"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    to_email: Mapped[str] = mapped_column(Text, nullable=False)
    template_key: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    subject: Mapped[str] = mapped_column(Text, nullable=False)
    provider: Mapped[str | None] = mapped_column(Text, nullable=True)
    provider_message_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[EmailMessageStatus] = mapped_column(
        Enum(EmailMessageStatus, name="email_message_status", native_enum=False),
        nullable=False,
        default=EmailMessageStatus.queued,
    )
    error: Mapped[str | None] = mapped_column(Text, nullable=True)
    dedupe_key: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class NotificationEvent(Base):
    __tablename__ = "notification_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    topic: Mapped[str] = mapped_column(Text, nullable=False)
    type: Mapped[str] = mapped_column(Text, nullable=False)
    channel: Mapped[NotificationEventChannel] = mapped_column(
        Enum(NotificationEventChannel, name="notification_event_channel", native_enum=False),
        nullable=False,
    )
    reference_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    reference_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    dedupe_key: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("channel", "dedupe_key", name="uq_notification_event_channel_dedupe"),)


class ScheduledNotification(Base):
    __tablename__ = "scheduled_notification"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    channel: Mapped[NotificationEventChannel] = mapped_column(
        Enum(NotificationEventChannel, name="scheduled_notification_channel", native_enum=False),
        nullable=False,
        default=NotificationEventChannel.email,
    )
    send_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    dedupe_key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


Index("ix_followup_job_user_scheduled", FollowupJob.user_id, FollowupJob.scheduled_for)
Index("ix_call_session_recipient_created", CallSession.recipient_user_id, CallSession.created_at.desc())
Index("ix_notification_user_created", Notification.user_id, Notification.created_at.desc())
Index("ix_notification_user_read", Notification.user_id, Notification.read_at)
Index("ix_notification_event_user_created", NotificationEvent.user_id, NotificationEvent.created_at.desc())
