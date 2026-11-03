"""The Shelf: My gear's link to the camera catalogue, and the wish list.

Adds a nullable column to gear_item (existing rows keep none) and a new
table.

Revision ID: 20261103_0083
Revises: 20261103_0082
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261103_0083"
down_revision = "20261103_0082"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "gear_item",
        sa.Column("camera_model", sa.Text(), sa.ForeignKey("camera_model_reference.normalised_model", name="fk_gear_item_camera_model"), nullable=True),
    )
    op.create_index("ix_gear_item_camera_model", "gear_item", ["camera_model"])
    op.create_table(
        "shelf_wishlist_item",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("item_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("shelf_item.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )


def downgrade() -> None:
    op.drop_table("shelf_wishlist_item")
    op.drop_index("ix_gear_item_camera_model", table_name="gear_item")
    op.drop_column("gear_item", "camera_model")
