from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import BigInteger, Boolean, DateTime, Enum, ForeignKey, Integer, JSON, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class MediaDerivativeKind(str, enum.Enum):
    preview_watermarked = "preview_watermarked"
    web_res = "web_res"
    full_res = "full_res"
    thumbnail = "thumbnail"


class GigEntitlementType(str, enum.Enum):
    view_proofs = "view_proofs"
    download_finals = "download_finals"
    download_extras = "download_extras"
    share_link_manage = "share_link_manage"


class GigConsentLevel(str, enum.Enum):
    none = "none"
    pro_marketing_only = "pro_marketing_only"
    rawwers_marketing_only = "rawwers_marketing_only"
    both_pro_and_rawwers = "both_pro_and_rawwers"


class ShareLinkScope(str, enum.Enum):
    proofs = "proofs"
    finals = "finals"
    selected_only = "selected_only"


class MediaAccessAction(str, enum.Enum):
    view = "view"
    download = "download"


class MediaDerivative(Base):
    __tablename__ = "media_derivative"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    media_asset_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=False, index=True)
    kind: Mapped[MediaDerivativeKind] = mapped_column(
        Enum(MediaDerivativeKind, name="media_derivative_kind", native_enum=False),
        nullable=False,
    )
    storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    content_type: Mapped[str] = mapped_column(Text, nullable=False)
    bytes: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    width: Mapped[int | None] = mapped_column(Integer, nullable=True)
    height: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("media_asset_id", "kind", name="uq_media_derivative_asset_kind"),)


class GigMediaEntitlement(Base):
    __tablename__ = "gig_media_entitlement"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    entitlement_type: Mapped[GigEntitlementType] = mapped_column(
        Enum(GigEntitlementType, name="gig_entitlement_type", native_enum=False),
        nullable=False,
    )
    quantity_limit: Mapped[int | None] = mapped_column(Integer, nullable=True)
    valid_from: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    valid_until: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)

    __table_args__ = (UniqueConstraint("gig_id", "user_id", "entitlement_type", name="uq_gig_entitlement_unique"),)


class GigUsageConsent(Base):
    __tablename__ = "gig_usage_consent"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, unique=True, index=True)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    consent_level: Mapped[GigConsentLevel] = mapped_column(
        Enum(GigConsentLevel, name="gig_consent_level", native_enum=False),
        nullable=False,
    )
    scope: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    incentive: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    snapshot_at_booking: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class GigUsageConsentEvent(Base):
    __tablename__ = "gig_usage_consent_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    from_level: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_level: Mapped[str] = mapped_column(Text, nullable=False)
    actor_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)


class ShareLink(Base):
    __tablename__ = "share_link"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    created_by_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    scope: Mapped[ShareLinkScope] = mapped_column(Enum(ShareLinkScope, name="share_link_scope", native_enum=False), nullable=False)
    token_hash: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    max_views: Mapped[int | None] = mapped_column(Integer, nullable=True)
    view_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    is_revoked: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class MediaAccessLog(Base):
    __tablename__ = "media_access_log"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True, index=True)
    share_link_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("share_link.id"), nullable=True, index=True)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    media_asset_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=False, index=True)
    derivative_kind: Mapped[str] = mapped_column(Text, nullable=False)
    action: Mapped[MediaAccessAction] = mapped_column(
        Enum(MediaAccessAction, name="media_access_action", native_enum=False),
        nullable=False,
    )
    ip_hash: Mapped[str | None] = mapped_column(Text, nullable=True)
    user_agent: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)
