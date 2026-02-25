from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.commerce import (
    PartnerAPIType,
    PriceRuleAppliesTo,
    PriceRuleDiscountType,
    ProductStockStatus,
    StoreOrderPaymentStatus,
    StoreOrderStatus,
)
from app.models.niche import SkillTier


class StoreAccessResponse(BaseModel):
    allowed: bool
    reason: str
    max_tier: SkillTier | None = None


class StoreProductView(BaseModel):
    id: uuid.UUID
    partner_id: uuid.UUID
    partner_sku: str
    title: str
    description: str | None = None
    category: str | None = None
    brand: str | None = None
    images_media_asset_ids: list = Field(default_factory=list)
    attributes: dict = Field(default_factory=dict)
    currency: str
    msrp_price: Decimal | None = None
    partner_price: Decimal
    is_available: bool
    stock_status: ProductStockStatus
    shipping_estimate_days: int | None = None
    updated_at: datetime


class StoreProductListResponse(BaseModel):
    total: int
    items: list[StoreProductView]


class CartAddItemRequest(BaseModel):
    product_id: uuid.UUID
    quantity: int = Field(gt=0, le=100)


class ShippingAddress(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    line1: str = Field(min_length=1, max_length=180)
    city: str = Field(min_length=1, max_length=120)
    postal_code: str = Field(min_length=1, max_length=32)
    country: str = Field(min_length=2, max_length=3)
    line2: str | None = Field(default=None, max_length=180)
    region: str | None = Field(default=None, max_length=120)
    phone: str | None = Field(default=None, max_length=32)


class StoreCartItemView(BaseModel):
    id: uuid.UUID
    product_id: uuid.UUID
    quantity: int
    product: StoreProductView
    line_subtotal: Decimal


class StoreCartView(BaseModel):
    cart_id: uuid.UUID
    currency: str
    partner_id: uuid.UUID | None = None
    subtotal: Decimal
    items: list[StoreCartItemView] = Field(default_factory=list)
    updated_at: datetime


class StoreCheckoutRequest(BaseModel):
    shipping_address: ShippingAddress
    points_to_spend: int | None = Field(default=None, ge=1)


class OrderItemView(BaseModel):
    id: uuid.UUID
    product_id: uuid.UUID
    title_snapshot: str
    sku_snapshot: str | None = None
    unit_price: Decimal
    discount_amount: Decimal
    final_unit_price: Decimal
    quantity: int
    created_at: datetime


class OrderPaymentView(BaseModel):
    status: StoreOrderPaymentStatus
    stripe_payment_intent_id: str | None = None
    created_at: datetime
    updated_at: datetime


class StoreOrderView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    partner_id: uuid.UUID
    status: StoreOrderStatus
    currency: str
    subtotal: Decimal
    discounts_total: Decimal
    points_spent: int
    total: Decimal
    shipping_address: dict
    partner_order_id: str | None = None
    tracking: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime
    items: list[OrderItemView] = Field(default_factory=list)
    payment: OrderPaymentView | None = None


class StoreCheckoutResponse(BaseModel):
    order: StoreOrderView
    payment_intent_client_secret: str | None = None
    payment_intent_id: str | None = None


class StoreOrdersResponse(BaseModel):
    total: int
    items: list[StoreOrderView]


class AdminPartnerRequest(BaseModel):
    name: str
    country: str | None = None
    api_type: PartnerAPIType = PartnerAPIType.manual
    api_config: dict = Field(default_factory=dict)
    is_active: bool = True


class AdminPartnerView(BaseModel):
    id: uuid.UUID
    name: str
    country: str | None = None
    api_type: PartnerAPIType
    api_config: dict = Field(default_factory=dict)
    is_active: bool
    created_at: datetime
    updated_at: datetime


class AdminProductRequest(BaseModel):
    partner_id: uuid.UUID
    partner_sku: str
    title: str
    description: str | None = None
    category: str | None = None
    brand: str | None = None
    images_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)
    attributes: dict = Field(default_factory=dict)
    currency: str = "EUR"
    msrp_price: Decimal | None = None
    partner_price: Decimal
    is_available: bool = True
    stock_status: ProductStockStatus = ProductStockStatus.unknown
    shipping_estimate_days: int | None = None


class AdminPriceRuleRequest(BaseModel):
    partner_id: uuid.UUID | None = None
    applies_to: PriceRuleAppliesTo
    match_value: str | None = None
    discount_type: PriceRuleDiscountType
    discount_value: Decimal
    min_tier: SkillTier = SkillTier.skilled
    is_active: bool = True


class AdminPriceRuleView(BaseModel):
    id: uuid.UUID
    partner_id: uuid.UUID | None = None
    applies_to: PriceRuleAppliesTo
    match_value: str | None = None
    discount_type: PriceRuleDiscountType
    discount_value: Decimal
    min_tier: SkillTier
    is_active: bool
    created_at: datetime
    updated_at: datetime


class StorePolicyRequest(BaseModel):
    min_tier_any_niche: SkillTier = SkillTier.skilled
    require_kyc_approved: bool = True
    require_not_banned: bool = True
    metadata: dict = Field(default_factory=dict)


class StorePolicyView(BaseModel):
    id: uuid.UUID
    min_tier_any_niche: SkillTier
    require_kyc_approved: bool
    require_not_banned: bool
    meta: dict = Field(default_factory=dict)
    updated_at: datetime


class StoreOverrideRequest(BaseModel):
    is_allowed: bool
    reason: str | None = None
    expires_at: datetime | None = None


class StoreOverrideView(BaseModel):
    pro_user_id: uuid.UUID
    is_allowed: bool
    reason: str | None = None
    granted_by: uuid.UUID | None = None
    granted_at: datetime
    expires_at: datetime | None = None


class AdminOrderStatusUpdateRequest(BaseModel):
    status: StoreOrderStatus
    tracking: dict = Field(default_factory=dict)
    reason: str | None = None
