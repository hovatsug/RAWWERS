"""pro store commerce v0

Revision ID: 20260225_0014
Revises: 20260225_0013
Create Date: 2026-02-25 23:40:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0014"
down_revision: Union[str, Sequence[str], None] = "20260225_0013"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


partner_api_type_enum = sa.Enum("manual", "feed_url", "api", name="partner_api_type", native_enum=False)
product_stock_status_enum = sa.Enum("in_stock", "backorder", "out_of_stock", "unknown", name="product_stock_status", native_enum=False)
price_rule_applies_to_enum = sa.Enum("category", "brand", "sku", "all", name="price_rule_applies_to", native_enum=False)
price_rule_discount_type_enum = sa.Enum("percent", "fixed", name="price_rule_discount_type", native_enum=False)
store_order_status_enum = sa.Enum(
    "created",
    "payment_pending",
    "paid",
    "submitted_to_partner",
    "shipped",
    "delivered",
    "cancelled",
    "refunded",
    name="store_order_status",
    native_enum=False,
)
store_order_payment_status_enum = sa.Enum("pending", "succeeded", "failed", "cancelled", name="store_order_payment_status", native_enum=False)
skill_tier_enum = sa.Enum("rookie", "skilled", "pro", "elite", "master", name="skill_tier", native_enum=False)
old_redemption_context_type_enum = sa.Enum("gig_payment", "upsell_purchase", name="redemption_context_type", native_enum=False)
new_redemption_context_type_enum = sa.Enum("gig_payment", "upsell_purchase", "commerce_order", name="redemption_context_type", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "commerce_partner",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("country", sa.Text(), nullable=True),
        sa.Column("api_type", partner_api_type_enum, nullable=False, server_default="manual"),
        sa.Column("api_config", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "product",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("commerce_partner.id"), nullable=False),
        sa.Column("partner_sku", sa.Text(), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("category", sa.Text(), nullable=True),
        sa.Column("brand", sa.Text(), nullable=True),
        sa.Column("images_media_asset_ids", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("attributes", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("msrp_price", sa.Numeric(12, 2), nullable=True),
        sa.Column("partner_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("is_available", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("stock_status", product_stock_status_enum, nullable=False, server_default="unknown"),
        sa.Column("shipping_estimate_days", sa.Integer(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("partner_id", "partner_sku", name="uq_product_partner_sku"),
    )
    op.create_index("ix_product_partner_id", "product", ["partner_id"])
    op.create_index("ix_product_partner_sku", "product", ["partner_sku"])

    op.create_table(
        "price_rule",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("commerce_partner.id"), nullable=True),
        sa.Column("applies_to", price_rule_applies_to_enum, nullable=False),
        sa.Column("match_value", sa.Text(), nullable=True),
        sa.Column("discount_type", price_rule_discount_type_enum, nullable=False),
        sa.Column("discount_value", sa.Numeric(12, 2), nullable=False),
        sa.Column("min_tier", skill_tier_enum, nullable=False, server_default="skilled"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_price_rule_partner_id", "price_rule", ["partner_id"])

    op.create_table(
        "store_access_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("min_tier_any_niche", skill_tier_enum, nullable=False, server_default="skilled"),
        sa.Column("require_kyc_approved", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("require_not_banned", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "store_access_override",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False, unique=True),
        sa.Column("is_allowed", sa.Boolean(), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("granted_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("granted_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_store_access_override_pro_user_id", "store_access_override", ["pro_user_id"])

    op.create_table(
        "cart",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False, unique=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_cart_user_id", "cart", ["user_id"])

    op.create_table(
        "cart_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("cart_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("cart.id"), nullable=False),
        sa.Column("product_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("product.id"), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("cart_id", "product_id", name="uq_cart_item_cart_product"),
    )
    op.create_index("ix_cart_item_cart_id", "cart_item", ["cart_id"])
    op.create_index("ix_cart_item_product_id", "cart_item", ["product_id"])

    op.create_table(
        "order",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("commerce_partner.id"), nullable=False),
        sa.Column("status", store_order_status_enum, nullable=False, server_default="created"),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("subtotal", sa.Numeric(12, 2), nullable=False),
        sa.Column("discounts_total", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("points_spent", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("total", sa.Numeric(12, 2), nullable=False),
        sa.Column("shipping_address", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("partner_order_id", sa.Text(), nullable=True),
        sa.Column("tracking", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_order_user_id", "order", ["user_id"])
    op.create_index("ix_order_partner_id", "order", ["partner_id"])
    op.create_index("ix_order_user_created", "order", ["user_id", sa.text("created_at DESC")])

    op.create_table(
        "order_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("order.id"), nullable=False),
        sa.Column("product_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("product.id"), nullable=False),
        sa.Column("title_snapshot", sa.Text(), nullable=False),
        sa.Column("sku_snapshot", sa.Text(), nullable=True),
        sa.Column("unit_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("discount_amount", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("final_unit_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("order_id", "product_id", name="uq_order_item_order_product"),
    )
    op.create_index("ix_order_item_order_id", "order_item", ["order_id"])
    op.create_index("ix_order_item_product_id", "order_item", ["product_id"])

    op.create_table(
        "order_payment",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("order.id"), nullable=False, unique=True),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True, unique=True),
        sa.Column("status", store_order_payment_status_enum, nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_order_payment_order_id", "order_payment", ["order_id"])

    op.alter_column(
        "discount_redemption",
        "context_type",
        existing_type=old_redemption_context_type_enum,
        type_=new_redemption_context_type_enum,
        existing_nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        "discount_redemption",
        "context_type",
        existing_type=new_redemption_context_type_enum,
        type_=old_redemption_context_type_enum,
        existing_nullable=False,
    )

    op.drop_index("ix_order_payment_order_id", table_name="order_payment")
    op.drop_table("order_payment")

    op.drop_index("ix_order_item_product_id", table_name="order_item")
    op.drop_index("ix_order_item_order_id", table_name="order_item")
    op.drop_table("order_item")

    op.drop_index("ix_order_user_created", table_name="order")
    op.drop_index("ix_order_partner_id", table_name="order")
    op.drop_index("ix_order_user_id", table_name="order")
    op.drop_table("order")

    op.drop_index("ix_cart_item_product_id", table_name="cart_item")
    op.drop_index("ix_cart_item_cart_id", table_name="cart_item")
    op.drop_table("cart_item")

    op.drop_index("ix_cart_user_id", table_name="cart")
    op.drop_table("cart")

    op.drop_index("ix_store_access_override_pro_user_id", table_name="store_access_override")
    op.drop_table("store_access_override")

    op.drop_table("store_access_policy")

    op.drop_index("ix_price_rule_partner_id", table_name="price_rule")
    op.drop_table("price_rule")

    op.drop_index("ix_product_partner_sku", table_name="product")
    op.drop_index("ix_product_partner_id", table_name="product")
    op.drop_table("product")

    op.drop_table("commerce_partner")
