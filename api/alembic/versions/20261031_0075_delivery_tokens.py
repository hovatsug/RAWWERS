"""Lightroom pairing: one-time pairing codes and delivery tokens.

Two new tables, nothing existing changes. Only hashes of codes and tokens
are stored.

Revision ID: 20261031_0075
Revises: 20261029_0074
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261031_0075"
down_revision = "20261029_0074"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "delivery_pairing_code",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("code_hash", sa.Text(), nullable=False, unique=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_delivery_pairing_code_pro_user_id", "delivery_pairing_code", ["pro_user_id"])
    op.create_table(
        "delivery_token",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("token_hash", sa.Text(), nullable=False, unique=True),
        sa.Column("token_prefix", sa.Text(), nullable=False),
        sa.Column("device_name", sa.Text(), nullable=False),
        sa.Column("plugin_version", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_used_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("revoked_reason", sa.Text(), nullable=True),
    )
    op.create_index("ix_delivery_token_pro_user_id", "delivery_token", ["pro_user_id"])
    op.create_index("ix_delivery_token_pro_active", "delivery_token", ["pro_user_id", "revoked_at"])


def downgrade() -> None:
    op.drop_index("ix_delivery_token_pro_active", table_name="delivery_token")
    op.drop_index("ix_delivery_token_pro_user_id", table_name="delivery_token")
    op.drop_table("delivery_token")
    op.drop_index("ix_delivery_pairing_code_pro_user_id", table_name="delivery_pairing_code")
    op.drop_table("delivery_pairing_code")
