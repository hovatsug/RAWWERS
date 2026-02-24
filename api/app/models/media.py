import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import BigInteger, DateTime, Enum, ForeignKey, Index, Integer, JSON, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class MediaKind(str, enum.Enum):
    photo = "photo"
    video = "video"


class MediaPurpose(str, enum.Enum):
    portfolio_reel = "portfolio_reel"
    video_review = "video_review"
    proof = "proof"
    final_delivery = "final_delivery"
    other = "other"


class MediaProvider(str, enum.Enum):
    r2 = "r2"
    mux = "mux"


class MediaStatus(str, enum.Enum):
    created = "created"
    uploading = "uploading"
    processing = "processing"
    ready = "ready"
    failed = "failed"
    deleted = "deleted"


class MediaVisibility(str, enum.Enum):
    public = "public"
    authenticated = "authenticated"
    owner_only = "owner_only"
    client_only = "client_only"
    purchaser_only = "purchaser_only"


class MediaVariant(str, enum.Enum):
    original = "original"
    thumbnail = "thumbnail"
    watermark_preview = "watermark_preview"


class ObjectStatus(str, enum.Enum):
    created = "created"
    processing = "processing"
    ready = "ready"
    failed = "failed"


class WebhookProvider(str, enum.Enum):
    mux = "mux"


class MediaAsset(Base):
    __tablename__ = "media_asset"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), index=True, nullable=False)
    kind: Mapped[MediaKind] = mapped_column(Enum(MediaKind, name="media_kind", native_enum=False), nullable=False)
    purpose: Mapped[MediaPurpose] = mapped_column(Enum(MediaPurpose, name="media_purpose", native_enum=False), nullable=False)
    provider: Mapped[MediaProvider] = mapped_column(Enum(MediaProvider, name="media_provider", native_enum=False), nullable=False)
    provider_asset_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    provider_upload_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[MediaStatus] = mapped_column(Enum(MediaStatus, name="media_status", native_enum=False), nullable=False, default=MediaStatus.created)
    visibility: Mapped[MediaVisibility] = mapped_column(Enum(MediaVisibility, name="media_visibility", native_enum=False), nullable=False, default=MediaVisibility.owner_only)
    content_type: Mapped[str | None] = mapped_column(Text, nullable=True)
    byte_size: Mapped[int | None] = mapped_column(BigInteger, nullable=True)
    checksum: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    objects: Mapped[list["MediaObject"]] = relationship(back_populates="media_asset", cascade="all, delete-orphan")


class MediaObject(Base):
    __tablename__ = "media_object"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    media_asset_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=False, index=True)
    variant: Mapped[MediaVariant] = mapped_column(Enum(MediaVariant, name="media_variant", native_enum=False), nullable=False)
    storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    width: Mapped[int | None] = mapped_column(Integer, nullable=True)
    height: Mapped[int | None] = mapped_column(Integer, nullable=True)
    status: Mapped[ObjectStatus] = mapped_column(Enum(ObjectStatus, name="object_status", native_enum=False), nullable=False, default=ObjectStatus.created)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    media_asset: Mapped[MediaAsset] = relationship(back_populates="objects")


class WebhookEvent(Base):
    __tablename__ = "webhook_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider: Mapped[WebhookProvider] = mapped_column(Enum(WebhookProvider, name="webhook_provider", native_enum=False), nullable=False)
    external_event_id: Mapped[str] = mapped_column(Text, nullable=False)
    event_type: Mapped[str] = mapped_column(Text, nullable=False)
    received_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    payload: Mapped[dict] = mapped_column(JSON, nullable=False)


Index("ix_media_asset_owner_created", MediaAsset.owner_user_id, MediaAsset.created_at.desc())
Index("ix_media_asset_provider_asset", MediaAsset.provider, MediaAsset.provider_asset_id)
Index("ux_webhook_provider_external", WebhookEvent.provider, WebhookEvent.external_event_id, unique=True)
