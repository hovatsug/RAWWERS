from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.prints import (
    PrintEventActorType,
    PrintExportStatus,
    PrintOrderStatus,
    PrintPartnerMode,
    PrintProductType,
)


class PrintPartnerView(BaseModel):
    id: uuid.UUID
    name: str
    mode: PrintPartnerMode
    api_base_url: str | None = None
    api_key_ref: str | None = None
    is_active: bool
    created_at: datetime
    updated_at: datetime


class PrintPartnerUpsertRequest(BaseModel):
    id: uuid.UUID | None = None
    name: str
    mode: PrintPartnerMode = PrintPartnerMode.manual
    api_base_url: str | None = None
    api_key_ref: str | None = None
    is_active: bool = True


class PrintProductView(BaseModel):
    id: uuid.UUID
    partner_id: uuid.UUID
    sku: str
    name_key: str
    description_key: str
    type: PrintProductType
    options: dict = Field(default_factory=dict)
    base_cost_eur: Decimal
    markup_percent: int
    retail_price_eur: Decimal
    production_specs: dict = Field(default_factory=dict)
    is_active: bool
    updated_at: datetime


class PrintProductUpsertRequest(BaseModel):
    id: uuid.UUID | None = None
    partner_id: uuid.UUID
    sku: str
    name_key: str
    description_key: str
    type: PrintProductType
    options: dict = Field(default_factory=dict)
    base_cost_eur: Decimal
    markup_percent: int = 40
    production_specs: dict = Field(default_factory=dict)
    is_active: bool = True


class PrintOrderItemRequest(BaseModel):
    product_id: uuid.UUID
    quantity: int
    selected_media: list[dict] = Field(default_factory=list)
    options_snapshot: dict = Field(default_factory=dict)


class ShippingAddressPayload(BaseModel):
    address_id: uuid.UUID | None = None
    encrypted_fields: dict = Field(default_factory=dict)
    country: str
    postal_code: str | None = None


class PrintOrderCreateRequest(BaseModel):
    partner_id: uuid.UUID
    items: list[PrintOrderItemRequest] = Field(default_factory=list)
    shipping_address: ShippingAddressPayload


class PrintOrderUpdateRequest(BaseModel):
    items: list[PrintOrderItemRequest] | None = None
    shipping_address: ShippingAddressPayload | None = None


class PrintOrderItemView(BaseModel):
    id: uuid.UUID
    print_order_id: uuid.UUID
    product_id: uuid.UUID
    quantity: int
    selected_media: list = Field(default_factory=list)
    options_snapshot: dict = Field(default_factory=dict)
    unit_price_eur: Decimal
    line_total_eur: Decimal


class PrintOrderView(BaseModel):
    id: uuid.UUID
    client_user_id: uuid.UUID
    gig_id: uuid.UUID
    partner_id: uuid.UUID
    status: PrintOrderStatus
    subtotal_eur: Decimal
    shipping_eur: Decimal
    total_eur: Decimal
    currency: str
    stripe_payment_intent_id: str | None = None
    shipping_address_id: uuid.UUID | None = None
    partner_order_ref: str | None = None
    tracking_code: str | None = None
    created_at: datetime
    updated_at: datetime


class PrintOrderDetailResponse(BaseModel):
    order: PrintOrderView
    items: list[PrintOrderItemView] = Field(default_factory=list)


class PrintOrderPayResponse(BaseModel):
    order_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str | None = None


class PrintEventView(BaseModel):
    id: uuid.UUID
    print_order_id: uuid.UUID
    from_status: str | None = None
    to_status: str
    actor_type: PrintEventActorType
    note: str | None = None
    payload: dict = Field(default_factory=dict)
    created_at: datetime


class AdminPrintOrderSetStatusRequest(BaseModel):
    status: PrintOrderStatus
    note: str | None = None


class AdminPrintOrderSetTrackingRequest(BaseModel):
    tracking_code: str
    note: str | None = None


class AdminPrintOrderDetailResponse(BaseModel):
    order: PrintOrderView
    items: list[PrintOrderItemView] = Field(default_factory=list)
    events: list[PrintEventView] = Field(default_factory=list)


class PrintExportJobView(BaseModel):
    id: uuid.UUID
    print_order_id: uuid.UUID
    status: PrintExportStatus
    output_files: list = Field(default_factory=list)
    failure_reason: str | None = None
    created_at: datetime
    updated_at: datetime
