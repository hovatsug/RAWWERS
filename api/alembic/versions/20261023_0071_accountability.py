"""Photographer accountability: the policy row, findings, booking pauses.

accountability_policy: one row (seeded with the agreed defaults: 7-day
window to respond, 14-day grace if unseen, 12-month rolling window, pause at
the second strike, suspension review at the third). photographer_finding:
an admin's recorded fault on a booking reduced for non-delivery, with the
photographer's response and the decision. booking_pause: the admin-controlled
pause on new bookings. Nothing existing is converted - nothing is
retroactive.

Revision ID: 20261023_0071
Revises: 20261023_0070
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261023_0071"
down_revision = "20261023_0070"
branch_labels = None
depends_on = None


def upgrade() -> None:
    policy = op.create_table(
        "accountability_policy",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("contest_window_days", sa.Integer(), nullable=False, server_default="7"),
        sa.Column("unseen_grace_days", sa.Integer(), nullable=False, server_default="14"),
        sa.Column("rolling_window_months", sa.Integer(), nullable=False, server_default="12"),
        sa.Column("pause_at", sa.Integer(), nullable=False, server_default="2"),
        sa.Column("suspension_review_at", sa.Integer(), nullable=False, server_default="3"),
        sa.Column("updated_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.bulk_insert(policy, [{"id": 1}])
    op.create_table(
        "photographer_finding",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("reduction_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("price_reduction.id"), nullable=False),
        sa.Column("reason_code", sa.Text(), nullable=False),
        sa.Column("recorded_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("note", sa.Text(), nullable=False),
        sa.Column("severe", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("severe_note", sa.Text(), nullable=True),
        sa.Column("status", sa.Text(), nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("first_seen_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("response", sa.Text(), nullable=True),
        sa.Column("responded_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("decided_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("decided_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("decision_note", sa.Text(), nullable=True),
        sa.Column("effective_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("consequence", sa.Text(), nullable=True),
        sa.Column("strike_number", sa.Integer(), nullable=True),
    )
    for column in ("pro_user_id", "gig_id", "recorded_by_user_id", "status", "effective_at"):
        op.create_index(f"ix_photographer_finding_{column}", "photographer_finding", [column])
    op.create_table(
        "booking_pause",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("finding_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("photographer_finding.id"), nullable=True),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("lifted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("lifted_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("lift_note", sa.Text(), nullable=True),
    )
    op.create_index("ix_booking_pause_pro_user_id", "booking_pause", ["pro_user_id"])


def downgrade() -> None:
    op.drop_index("ix_booking_pause_pro_user_id", table_name="booking_pause")
    op.drop_table("booking_pause")
    for column in ("pro_user_id", "gig_id", "recorded_by_user_id", "status", "effective_at"):
        op.drop_index(f"ix_photographer_finding_{column}", table_name="photographer_finding")
    op.drop_table("photographer_finding")
    op.drop_table("accountability_policy")
