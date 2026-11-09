"""Email suppression: addresses not to email, from Brevo's delivery events.

Revision ID: 20261109_0091
Revises: 20261107_0090
Create Date: 2026-11-09

A new table only; nothing existing changes.
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261109_0091"
down_revision = "20261107_0090"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "email_suppression",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.Text(), nullable=False),
        sa.Column("scope", sa.Text(), nullable=True),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("until", sa.DateTime(timezone=True), nullable=True),
        sa.Column("source_message_id", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("email", name="uq_email_suppression_email"),
    )
    op.create_index("ix_email_suppression_email", "email_suppression", ["email"])


def downgrade() -> None:
    op.drop_index("ix_email_suppression_email", table_name="email_suppression")
    op.drop_table("email_suppression")
