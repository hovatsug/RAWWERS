"""The Shelf: items and the cameras they fit.

New tables only.

Revision ID: 20261103_0082
Revises: 20261103_0081
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261103_0082"
down_revision = "20261103_0081"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "shelf_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("brand", sa.Text(), nullable=True),
        sa.Column("category", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("image_url", sa.Text(), nullable=True),
        sa.Column("level", sa.Integer(), nullable=False),
        sa.Column("price_raww", sa.BigInteger(), nullable=False),
        sa.Column("street_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("street_currency", sa.Text(), nullable=False),
        sa.Column("supplier_cost", sa.Numeric(12, 2), nullable=False),
        sa.Column("supplier_currency", sa.Text(), nullable=False),
        sa.Column("supplier_name", sa.Text(), nullable=False),
        sa.Column("supplier_sku", sa.Text(), nullable=True),
        sa.Column("supplier_url", sa.Text(), nullable=True),
        sa.Column("stock_status", sa.String(length=16), nullable=False),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("level BETWEEN 1 AND 5", name="ck_shelf_item_level"),
        sa.CheckConstraint("price_raww > 0", name="ck_shelf_item_price"),
    )
    op.create_table(
        "shelf_item_compat",
        sa.Column("item_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shelf_item.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("camera_model", sa.Text(), sa.ForeignKey("camera_model_reference.normalised_model"), primary_key=True),
    )


def downgrade() -> None:
    op.drop_table("shelf_item_compat")
    op.drop_table("shelf_item")
