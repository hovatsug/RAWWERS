from __future__ import annotations

import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, DateTime, Enum, ForeignKey, Integer, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base


class PrintPartnerMode(str, enum.Enum):
    api = "api"
    manual = "manual"


class PrintProductType(str, enum.Enum):
    print = "print"
    canvas = "canvas"
    frame = "frame"
    album = "album"


class PrintOrderStatus(str, enum.Enum):
    draft = "draft"
    pending_payment = "pending_payment"
    paid = "paid"
    in_production = "in_production"
    shipped = "shipped"
    delivered = "delivered"
    cancelled = "cancelled"
    refunded = "refunded"
    failed = "failed"


class PrintExportStatus(str, enum.Enum):
    queued = "queued"
    processing = "processing"
    done = "done"
    failed = "failed"


class PrintEventActorType(str, enum.Enum):
    client = "client"
    admin = "admin"
    system = "system"
    partner = "partner"


class PrintPartner(Base):
    __tablename__ = "print_partner"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    mode: Mapped[PrintPartnerMode] = mapped_column(
        Enum(PrintPartnerMode, name="print_partner_mode", native_enum=False), nullable=False, default=PrintPartnerMode.manual
    )
    api_base_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    api_key_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class PrintProduct(Base):
    __tablename__ = "print_product"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    partner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("print_partner.id"), nullable=False, index=True)
    sku: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    name_key: Mapped[str] = mapped_column(Text, nullable=False)
    description_key: Mapped[str] = mapped_column(Text, nullable=False)
    type: Mapped[PrintProductType] = mapped_column(Enum(PrintProductType, name="print_product_type", native_enum=False), nullable=False)
    options: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    base_cost_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    markup_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=40)
    retail_price_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    production_specs: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class ShippingAddress(Base):
    __tablename__ = "shipping_address"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    encrypted_fields: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    country: Mapped[str | None] = mapped_column(Text, nullable=True)
    postal_code_hash: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class PrintOrder(Base):
    __tablename__ = "print_order"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    gig_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("gig.id"), nullable=False, index=True)
    partner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("print_partner.id"), nullable=False, index=True)
    status: Mapped[PrintOrderStatus] = mapped_column(
        Enum(PrintOrderStatus, name="print_order_status", native_enum=False), nullable=False, default=PrintOrderStatus.draft, index=True
    )
    subtotal_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    shipping_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    total_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    stripe_payment_intent_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    shipping_address_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("shipping_address.id"), nullable=True)
    partner_order_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    tracking_code: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class PrintOrderItem(Base):
    __tablename__ = "print_order_item"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    print_order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("print_order.id"), nullable=False, index=True)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("print_product.id"), nullable=False, index=True)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    selected_media: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    options_snapshot: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    unit_price_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    line_total_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)


class PrintExportJob(Base):
    __tablename__ = "print_export_job"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    print_order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("print_order.id"), nullable=False, index=True)
    status: Mapped[PrintExportStatus] = mapped_column(
        Enum(PrintExportStatus, name="print_export_status", native_enum=False), nullable=False, default=PrintExportStatus.queued
    )
    output_files: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    failure_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc)
    )


class PrintEvent(Base):
    __tablename__ = "print_event"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    print_order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("print_order.id"), nullable=False, index=True)
    from_status: Mapped[str | None] = mapped_column(Text, nullable=True)
    to_status: Mapped[str] = mapped_column(Text, nullable=False)
    actor_type: Mapped[PrintEventActorType] = mapped_column(
        Enum(PrintEventActorType, name="print_event_actor_type", native_enum=False), nullable=False
    )
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), index=True)
