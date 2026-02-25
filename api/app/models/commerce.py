import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, JSON, BigInteger, DateTime, Enum, ForeignKey, Index, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.niche import SkillTier


class PartnerAPIType(str, enum.Enum):
    manual = "manual"
    feed_url = "feed_url"
    api = "api"


class ProductStockStatus(str, enum.Enum):
    in_stock = "in_stock"
    backorder = "backorder"
    out_of_stock = "out_of_stock"
    unknown = "unknown"


class PriceRuleAppliesTo(str, enum.Enum):
    category = "category"
    brand = "brand"
    sku = "sku"
    all = "all"


class PriceRuleDiscountType(str, enum.Enum):
    percent = "percent"
    fixed = "fixed"


class StoreOrderStatus(str, enum.Enum):
    created = "created"
    payment_pending = "payment_pending"
    paid = "paid"
    submitted_to_partner = "submitted_to_partner"
    shipped = "shipped"
    delivered = "delivered"
    cancelled = "cancelled"
    refunded = "refunded"


class StoreOrderPaymentStatus(str, enum.Enum):
    pending = "pending"
    succeeded = "succeeded"
    failed = "failed"
    cancelled = "cancelled"


class CommercePartner(Base):
    __tablename__ = "commerce_partner"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    country: Mapped[str | None] = mapped_column(Text, nullable=True)
    api_type: Mapped[PartnerAPIType] = mapped_column(
        Enum(PartnerAPIType, name="partner_api_type", native_enum=False),
        nullable=False,
        default=PartnerAPIType.manual,
    )
    api_config: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class Product(Base):
    __tablename__ = "product"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    partner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("commerce_partner.id"), nullable=False, index=True)
    partner_sku: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    category: Mapped[str | None] = mapped_column(Text, nullable=True)
    brand: Mapped[str | None] = mapped_column(Text, nullable=True)
    images_media_asset_ids: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    attributes: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    msrp_price: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    partner_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    is_available: Mapped[bool] = mapped_column(nullable=False, default=True)
    stock_status: Mapped[ProductStockStatus] = mapped_column(
        Enum(ProductStockStatus, name="product_stock_status", native_enum=False),
        nullable=False,
        default=ProductStockStatus.unknown,
    )
    shipping_estimate_days: Mapped[int | None] = mapped_column(nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("partner_id", "partner_sku", name="uq_product_partner_sku"),)


class PriceRule(Base):
    __tablename__ = "price_rule"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    partner_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("commerce_partner.id"), nullable=True, index=True)
    applies_to: Mapped[PriceRuleAppliesTo] = mapped_column(
        Enum(PriceRuleAppliesTo, name="price_rule_applies_to", native_enum=False),
        nullable=False,
    )
    match_value: Mapped[str | None] = mapped_column(Text, nullable=True)
    discount_type: Mapped[PriceRuleDiscountType] = mapped_column(
        Enum(PriceRuleDiscountType, name="price_rule_discount_type", native_enum=False),
        nullable=False,
    )
    discount_value: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    min_tier: Mapped[SkillTier] = mapped_column(
        Enum(SkillTier, name="skill_tier", native_enum=False),
        nullable=False,
        default=SkillTier.skilled,
    )
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class StoreAccessPolicy(Base):
    __tablename__ = "store_access_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    min_tier_any_niche: Mapped[SkillTier] = mapped_column(
        Enum(SkillTier, name="skill_tier", native_enum=False),
        nullable=False,
        default=SkillTier.skilled,
    )
    require_kyc_approved: Mapped[bool] = mapped_column(nullable=False, default=True)
    require_not_banned: Mapped[bool] = mapped_column(nullable=False, default=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class StoreAccessOverride(Base):
    __tablename__ = "store_access_override"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pro_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, unique=True, index=True)
    is_allowed: Mapped[bool] = mapped_column(nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    granted_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    granted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class Cart(Base):
    __tablename__ = "cart"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, unique=True, index=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class CartItem(Base):
    __tablename__ = "cart_item"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cart_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("cart.id"), nullable=False, index=True)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("product.id"), nullable=False, index=True)
    quantity: Mapped[int] = mapped_column(nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("cart_id", "product_id", name="uq_cart_item_cart_product"),)


class CommerceOrder(Base):
    __tablename__ = "order"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    partner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("commerce_partner.id"), nullable=False, index=True)
    status: Mapped[StoreOrderStatus] = mapped_column(
        Enum(StoreOrderStatus, name="store_order_status", native_enum=False),
        nullable=False,
        default=StoreOrderStatus.created,
    )
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    subtotal: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    discounts_total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    points_spent: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    shipping_address: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    partner_order_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    tracking: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class OrderItem(Base):
    __tablename__ = "order_item"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("order.id"), nullable=False, index=True)
    product_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("product.id"), nullable=False, index=True)
    title_snapshot: Mapped[str] = mapped_column(Text, nullable=False)
    sku_snapshot: Mapped[str | None] = mapped_column(Text, nullable=True)
    unit_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    discount_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    final_unit_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    quantity: Mapped[int] = mapped_column(nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    __table_args__ = (UniqueConstraint("order_id", "product_id", name="uq_order_item_order_product"),)


class OrderPayment(Base):
    __tablename__ = "order_payment"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    order_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("order.id"), nullable=False, unique=True, index=True)
    stripe_payment_intent_id: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True)
    status: Mapped[StoreOrderPaymentStatus] = mapped_column(
        Enum(StoreOrderPaymentStatus, name="store_order_payment_status", native_enum=False),
        nullable=False,
        default=StoreOrderPaymentStatus.pending,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


Index("ix_order_user_created", CommerceOrder.user_id, CommerceOrder.created_at.desc())
