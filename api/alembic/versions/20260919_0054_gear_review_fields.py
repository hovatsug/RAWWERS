"""Who decided a gear verification that needed a person, and why.

`pending_review` rows are decided by an admin, and until now the decision left
no trace on the row: no reviewer, no time, no note. Approving a body also has
to be able to say what its sensor is, since an unknown model is by definition
not in the reference table.

Revision ID: 20260919_0054
Revises: 20260915_0053
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "20260919_0054"
down_revision = "20260915_0053"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("gear_verification", sa.Column("reviewed_by", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("gear_verification", sa.Column("reviewed_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("gear_verification", sa.Column("review_note", sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column("gear_verification", "review_note")
    op.drop_column("gear_verification", "reviewed_at")
    op.drop_column("gear_verification", "reviewed_by")
