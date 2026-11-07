"""The Shelf: each item's photos (1 to 4, the first the cover).

Revision ID: 20261107_0089
Revises: 20261107_0088
Create Date: 2026-11-07

A new table. Items keep `image_url` (the supplier's link) as a fallback
until their photos are uploaded.
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261107_0089"
down_revision = "20261107_0088"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "shelf_item_image",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("item_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shelf_item.id", ondelete="CASCADE"), nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("status", sa.Text(), nullable=False, server_default="uploading"),
        sa.Column("width", sa.Integer(), nullable=True),
        sa.Column("height", sa.Integer(), nullable=True),
        sa.Column("failure_reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_shelf_item_image_item_id", "shelf_item_image", ["item_id"])


def downgrade() -> None:
    op.drop_index("ix_shelf_item_image_item_id", table_name="shelf_item_image")
    op.drop_table("shelf_item_image")
