from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import Date, DateTime, Enum, ForeignKey, Index, Integer, JSON, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class ChatThreadStatus(str, enum.Enum):
    open = "open"
    pro_takeover = "pro_takeover"
    pro_active = "pro_active"
    closed = "closed"


class ChatSenderType(str, enum.Enum):
    client = "client"
    ai = "ai"
    pro = "pro"
    system = "system"


class PlatformPolicy(Base):
    __tablename__ = "platform_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    key: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    value: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ChatThread(Base):
    __tablename__ = "chat_thread"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    client_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    session_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    status: Mapped[ChatThreadStatus] = mapped_column(
        Enum(ChatThreadStatus, name="chat_thread_status", native_enum=False),
        nullable=False,
        default=ChatThreadStatus.open,
    )
    context_snapshot: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    token_budget_used: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ChatMessage(Base):
    __tablename__ = "chat_message"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    thread_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("chat_thread.id"), nullable=False, index=True)
    sender_type: Mapped[ChatSenderType] = mapped_column(
        Enum(ChatSenderType, name="chat_sender_type", native_enum=False),
        nullable=False,
    )
    sender_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    content_redacted: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class ChatHandoff(Base):
    __tablename__ = "chat_handoff"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    thread_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("chat_thread.id"), nullable=False, index=True)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))


class ProAITone(str, enum.Enum):
    premium = "premium"
    friendly = "friendly"
    direct = "direct"


class LeadProfile(Base):
    __tablename__ = "lead_profile"

    thread_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("chat_thread.id"), primary_key=True)
    niche_slug: Mapped[str | None] = mapped_column(Text, nullable=True)
    desired_date: Mapped[datetime.date | None] = mapped_column(Date(), nullable=True)
    date_flex_days: Mapped[int | None] = mapped_column(Integer, nullable=True)
    location: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    budget_min: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    budget_max: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    style_tags: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class ProAIProfile(Base):
    __tablename__ = "pro_ai_profile"

    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    is_enabled: Mapped[bool] = mapped_column(nullable=False, default=True)
    tone: Mapped[ProAITone] = mapped_column(
        Enum(ProAITone, name="pro_ai_tone", native_enum=False),
        nullable=False,
        default=ProAITone.premium,
    )
    faq: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    do_not_say: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    preferred_packages: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class AIInteractionLog(Base):
    __tablename__ = "ai_interaction_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    thread_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("chat_thread.id"), nullable=False, index=True)
    request_id: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    model: Mapped[str] = mapped_column(Text, nullable=False)
    prompt_hash: Mapped[str] = mapped_column(Text, nullable=False)
    input_summary: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    output_summary: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    safety_flags: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    tokens_in: Mapped[int | None] = mapped_column(Integer, nullable=True)
    tokens_out: Mapped[int | None] = mapped_column(Integer, nullable=True)
    latency_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


Index("ix_chat_message_thread_created", ChatMessage.thread_id, ChatMessage.created_at.desc())
