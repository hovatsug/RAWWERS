"""The Shelf: its settings row.

New table only; the row is seeded on first read (services/shelf_settings.py).

Revision ID: 20261103_0081
Revises: 20261103_0080
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261103_0081"
down_revision = "20261103_0080"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "shelf_settings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("raww_eur_value", sa.Numeric(10, 4), nullable=False),
        sa.Column("gbp_eur_rate", sa.Numeric(10, 4), nullable=False),
        sa.Column("shelf_discount_percent", sa.Integer(), nullable=False),
        sa.Column("inactivity_months", sa.Integer(), nullable=False),
        sa.Column("warning_days", sa.Integer(), nullable=False),
        sa.Column("level_band_raww", postgresql.JSONB(), nullable=False),
        sa.Column("tier_max_level", postgresql.JSONB(), nullable=False),
        sa.Column("wishlist_max", sa.Integer(), nullable=False),
        sa.Column("max_orders_per_month", sa.Integer(), nullable=False),
        sa.Column("same_item_cooldown_days", sa.Integer(), nullable=False),
        sa.Column("allowed_countries", postgresql.JSONB(), nullable=False),
        sa.Column("free_shipping", sa.Boolean(), nullable=False),
        sa.Column("shelf_enabled", sa.Boolean(), nullable=False),
        sa.Column("terms_text", sa.Text(), nullable=False),
        sa.Column("terms_approved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("terms_reviewed_by", sa.Text(), nullable=True),
        sa.Column("terms_review_note", sa.Text(), nullable=True),
        sa.Column("terms_approved_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("updated_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    )


def downgrade() -> None:
    op.drop_table("shelf_settings")
