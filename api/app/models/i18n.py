from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Enum, Index, Integer, JSON, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class I18nKeyAuditStatus(str, enum.Enum):
    present = "present"
    missing = "missing"
    unused = "unused"


class UserLocalePreference(Base):
    __tablename__ = "user_locale_preference"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    locale: Mapped[str] = mapped_column(Text, nullable=False, default="en-GB")
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class I18nBundle(Base):
    __tablename__ = "i18n_bundle"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    locale: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    namespace: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    version: Mapped[int] = mapped_column(Integer, nullable=False)
    content: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("locale", "namespace", "version", name="uq_i18n_bundle_locale_namespace_version"),)


class I18nKeyAudit(Base):
    __tablename__ = "i18n_key_audit"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    locale: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    namespace: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    key: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    status: Mapped[I18nKeyAuditStatus] = mapped_column(
        Enum(I18nKeyAuditStatus, name="i18n_key_audit_status", native_enum=False),
        nullable=False,
        default=I18nKeyAuditStatus.present,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("locale", "namespace", "key", name="uq_i18n_key_audit_locale_namespace_key"),)


class LocalizedText(Base):
    __tablename__ = "localized_text"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    entity_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    locale: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    fields: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("entity_type", "entity_id", "locale", name="uq_localized_text_entity_locale"),)


Index("ix_localized_text_entity", LocalizedText.entity_type, LocalizedText.entity_id)
