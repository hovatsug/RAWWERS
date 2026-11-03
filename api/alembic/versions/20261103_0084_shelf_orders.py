"""The Shelf: orders, their history, and the photographer's saved address.

New tables only.

Revision ID: 20261103_0084
Revises: 20261103_0083
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261103_0084"
down_revision = "20261103_0083"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "shelf_pro_address",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("shipping_address_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shipping_address.id"), nullable=False),
    )
    op.create_table(
        "shelf_order",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("item_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shelf_item.id"), nullable=False),
        sa.Column("client_request_id", sa.Text(), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("supplier_name", sa.Text(), nullable=False),
        sa.Column("supplier_sku", sa.Text(), nullable=True),
        sa.Column("level", sa.Integer(), nullable=False),
        sa.Column("price_raww", sa.BigInteger(), nullable=False),
        sa.Column("raww_eur_value", sa.Numeric(10, 4), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("shipping_address", postgresql.JSONB(), nullable=False),
        sa.Column("country", sa.Text(), nullable=False),
        sa.Column("supplier_order_ref", sa.Text(), nullable=True),
        sa.Column("tracking_code", sa.Text(), nullable=True),
        sa.Column("tracking_url", sa.Text(), nullable=True),
        sa.Column("cancel_reason", sa.Text(), nullable=True),
        sa.Column("placed_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("ordered_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("shipped_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("delivered_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("cancelled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("refunded_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("pro_user_id", "client_request_id", name="uq_shelf_order_request"),
    )
    op.create_index("ix_shelf_order_pro_user_id", "shelf_order", ["pro_user_id"])
    op.create_index("ix_shelf_order_item_id", "shelf_order", ["item_id"])
    op.create_index("ix_shelf_order_status", "shelf_order", ["status"])
    op.create_index("ix_shelf_order_placed_at", "shelf_order", ["placed_at"])
    op.create_table(
        "shelf_order_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shelf_order.id"), nullable=False),
        sa.Column("from_status", sa.Text(), nullable=True),
        sa.Column("to_status", sa.Text(), nullable=False),
        sa.Column("actor_type", sa.Text(), nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_shelf_order_event_order_id", "shelf_order_event", ["order_id"])


def downgrade() -> None:
    op.drop_table("shelf_order_event")
    op.drop_table("shelf_order")
    op.drop_table("shelf_pro_address")
