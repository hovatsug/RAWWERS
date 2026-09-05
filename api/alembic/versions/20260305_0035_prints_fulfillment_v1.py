"""prints fulfillment v1

Revision ID: 20260305_0035
Revises: 20260305_0034
Create Date: 2026-03-05 20:45:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260305_0035"
down_revision: Union[str, Sequence[str], None] = "20260305_0034"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


print_partner_mode = sa.Enum("api", "manual", name="print_partner_mode", native_enum=False)
print_product_type = sa.Enum("print", "canvas", "frame", "album", name="print_product_type", native_enum=False)
print_order_status = sa.Enum(
    "draft",
    "pending_payment",
    "paid",
    "in_production",
    "shipped",
    "delivered",
    "cancelled",
    "refunded",
    "failed",
    name="print_order_status",
    native_enum=False,
)
print_export_status = sa.Enum("queued", "processing", "done", "failed", name="print_export_status", native_enum=False)
print_event_actor_type = sa.Enum("client", "admin", "system", "partner", name="print_event_actor_type", native_enum=False)


def upgrade() -> None:
    print_partner_mode.create(op.get_bind(), checkfirst=True)
    print_product_type.create(op.get_bind(), checkfirst=True)
    print_order_status.create(op.get_bind(), checkfirst=True)
    print_export_status.create(op.get_bind(), checkfirst=True)
    print_event_actor_type.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "print_partner",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("mode", print_partner_mode, nullable=False, server_default="manual"),
        sa.Column("api_base_url", sa.Text(), nullable=True),
        sa.Column("api_key_ref", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "print_product",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("print_partner.id"), nullable=False),
        sa.Column("sku", sa.Text(), nullable=False),
        sa.Column("name_key", sa.Text(), nullable=False),
        sa.Column("description_key", sa.Text(), nullable=False),
        sa.Column("type", print_product_type, nullable=False),
        sa.Column("options", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("base_cost_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("markup_percent", sa.Integer(), nullable=False, server_default="40"),
        sa.Column("retail_price_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("production_specs", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_print_product_partner_id", "print_product", ["partner_id"])
    op.create_index("ix_print_product_sku", "print_product", ["sku"])

    op.create_table(
        "shipping_address",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("encrypted_fields", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("country", sa.Text(), nullable=True),
        sa.Column("postal_code_hash", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_shipping_address_user_id", "shipping_address", ["user_id"])

    op.create_table(
        "print_order",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("partner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("print_partner.id"), nullable=False),
        sa.Column("status", print_order_status, nullable=False, server_default="draft"),
        sa.Column("subtotal_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("shipping_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("total_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("currency", sa.CHAR(3), nullable=False, server_default="EUR"),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True),
        sa.Column("shipping_address_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shipping_address.id"), nullable=True),
        sa.Column("partner_order_ref", sa.Text(), nullable=True),
        sa.Column("tracking_code", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_print_order_client_user_id", "print_order", ["client_user_id"])
    op.create_index("ix_print_order_gig_id", "print_order", ["gig_id"])
    op.create_index("ix_print_order_partner_id", "print_order", ["partner_id"])
    op.create_index("ix_print_order_status", "print_order", ["status"])
    op.create_index("ix_print_order_stripe_payment_intent_id", "print_order", ["stripe_payment_intent_id"])

    op.create_table(
        "print_order_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("print_order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("print_order.id"), nullable=False),
        sa.Column("product_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("print_product.id"), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("selected_media", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("options_snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("unit_price_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("line_total_eur", sa.Numeric(12, 2), nullable=False),
    )
    op.create_index("ix_print_order_item_print_order_id", "print_order_item", ["print_order_id"])
    op.create_index("ix_print_order_item_product_id", "print_order_item", ["product_id"])

    op.create_table(
        "print_export_job",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("print_order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("print_order.id"), nullable=False),
        sa.Column("status", print_export_status, nullable=False, server_default="queued"),
        sa.Column("output_files", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("failure_reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_print_export_job_print_order_id", "print_export_job", ["print_order_id"])

    op.create_table(
        "print_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("print_order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("print_order.id"), nullable=False),
        sa.Column("from_status", sa.Text(), nullable=True),
        sa.Column("to_status", sa.Text(), nullable=False),
        sa.Column("actor_type", print_event_actor_type, nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_print_event_print_order_id", "print_event", ["print_order_id"])
    op.create_index("ix_print_event_created_at", "print_event", ["created_at"])


def downgrade() -> None:
    op.drop_index("ix_print_event_created_at", table_name="print_event")
    op.drop_index("ix_print_event_print_order_id", table_name="print_event")
    op.drop_table("print_event")

    op.drop_index("ix_print_export_job_print_order_id", table_name="print_export_job")
    op.drop_table("print_export_job")

    op.drop_index("ix_print_order_item_product_id", table_name="print_order_item")
    op.drop_index("ix_print_order_item_print_order_id", table_name="print_order_item")
    op.drop_table("print_order_item")

    op.drop_index("ix_print_order_stripe_payment_intent_id", table_name="print_order")
    op.drop_index("ix_print_order_status", table_name="print_order")
    op.drop_index("ix_print_order_partner_id", table_name="print_order")
    op.drop_index("ix_print_order_gig_id", table_name="print_order")
    op.drop_index("ix_print_order_client_user_id", table_name="print_order")
    op.drop_table("print_order")

    op.drop_index("ix_shipping_address_user_id", table_name="shipping_address")
    op.drop_table("shipping_address")

    op.drop_index("ix_print_product_sku", table_name="print_product")
    op.drop_index("ix_print_product_partner_id", table_name="print_product")
    op.drop_table("print_product")

    op.drop_table("print_partner")

    print_event_actor_type.drop(op.get_bind(), checkfirst=True)
    print_export_status.drop(op.get_bind(), checkfirst=True)
    print_order_status.drop(op.get_bind(), checkfirst=True)
    print_product_type.drop(op.get_bind(), checkfirst=True)
    print_partner_mode.drop(op.get_bind(), checkfirst=True)
