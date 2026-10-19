"""Photographer-fault events, kept apart from refunds and from ranking.

A table for explicit findings that a photographer was at fault, written
when the admin resolving a dispute says so. Refunds no longer apply the
"quality penalty"; existing pro_quality_penalty rows are kept as history.
Nothing reads this table for ranking.

Revision ID: 20261019_0065
Revises: 20261019_0064
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261019_0065"
down_revision = "20261019_0064"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "pro_fault_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=True),
        sa.Column("dispute_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("dispute.id"), nullable=True),
        sa.Column("kind", sa.Text(), nullable=False),
        sa.Column("severity", sa.Text(), nullable=False, server_default="medium"),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("recorded_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("dispute_id", "kind", name="uq_pro_fault_event_dispute_kind"),
    )
    op.create_index("ix_pro_fault_event_pro_user_id", "pro_fault_event", ["pro_user_id"])


def downgrade() -> None:
    op.drop_index("ix_pro_fault_event_pro_user_id", table_name="pro_fault_event")
    op.drop_table("pro_fault_event")
