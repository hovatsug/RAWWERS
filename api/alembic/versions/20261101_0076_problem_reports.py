"""Review gate: "Report a problem" before downloading.

One new table, nothing existing changes. The hold it places uses a new
value of earnings_hold.reason, a plain varchar with no check constraint, so
no column changes either.

Revision ID: 20261101_0076
Revises: 20261031_0075
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261101_0076"
down_revision = "20261031_0075"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "problem_report",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False, unique=True),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.String(length=64), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("earnings_hold_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("earnings_hold.id"), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_problem_report_gig_id", "problem_report", ["gig_id"])
    op.create_index("ix_problem_report_client_user_id", "problem_report", ["client_user_id"])
    op.create_index("ix_problem_report_pro_user_id", "problem_report", ["pro_user_id"])


def downgrade() -> None:
    op.drop_index("ix_problem_report_pro_user_id", table_name="problem_report")
    op.drop_index("ix_problem_report_client_user_id", table_name="problem_report")
    op.drop_index("ix_problem_report_gig_id", table_name="problem_report")
    op.drop_table("problem_report")
