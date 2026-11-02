"""Marketing wording: language, and who reviewed and published it.

Adds columns to marketing_wording (created in 0077, not deployed anywhere
yet); nothing else changes. The two seeded drafts become English.

Revision ID: 20261102_0078
Revises: 20261102_0077
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261102_0078"
down_revision = "20261102_0077"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("marketing_wording", sa.Column("language", sa.Text(), nullable=False, server_default="en"))
    op.add_column("marketing_wording", sa.Column("created_by_user_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("marketing_wording", sa.Column("reviewed_by", sa.Text(), nullable=True))
    op.add_column("marketing_wording", sa.Column("review_note", sa.Text(), nullable=True))
    op.add_column("marketing_wording", sa.Column("published_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("marketing_wording", sa.Column("published_by_user_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.alter_column("marketing_wording", "language", server_default=None)


def downgrade() -> None:
    for column in ("published_by_user_id", "published_at", "review_note", "reviewed_by", "created_by_user_id", "language"):
        op.drop_column("marketing_wording", column)
