"""Available now: short-notice booking while the photographer's app is open.

- pro_scheduling_policy.available_until - the source of truth for the toggle
  (Redis holds a copy for lookups only). Effective while in the future AND the
  app has checked in within two minutes - see app/services/available_now.py.
- pro_scheduling_policy.short_notice_prep_hours - the preparation time that
  replaces the usual notice for the next 24 hours while available (1-6, 2).
- pro_package.short_notice_ok - which packages may be booked that way. Off
  for every existing package; a new one defaults by its preset.
- booking_request.short_notice / notice_minutes / pay_window_minutes - the
  terms a request was made under, kept if the toggle changes afterwards.
- gig.pay_deadline_at - when an accepted booking must be paid by, set at
  acceptance from those terms. Backfilled for gigs already awaiting payment
  as created_at + 24 hours, the window they were made under.

Revision ID: 20261013_0060
Revises: 20261013_0059
"""
from alembic import op
import sqlalchemy as sa

revision = "20261013_0060"
down_revision = "20261013_0059"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("pro_scheduling_policy", sa.Column("available_until", sa.DateTime(timezone=True), nullable=True))
    op.add_column(
        "pro_scheduling_policy",
        sa.Column("short_notice_prep_hours", sa.Integer(), nullable=False, server_default="2"),
    )
    op.add_column("pro_package", sa.Column("short_notice_ok", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("booking_request", sa.Column("short_notice", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("booking_request", sa.Column("notice_minutes", sa.Integer(), nullable=True))
    op.add_column("booking_request", sa.Column("pay_window_minutes", sa.Integer(), nullable=True))
    op.add_column("gig", sa.Column("pay_deadline_at", sa.DateTime(timezone=True), nullable=True))
    op.execute("UPDATE gig SET pay_deadline_at = created_at + interval '24 hours' WHERE status = 'payment_pending'")


def downgrade() -> None:
    op.drop_column("gig", "pay_deadline_at")
    op.drop_column("booking_request", "pay_window_minutes")
    op.drop_column("booking_request", "notice_minutes")
    op.drop_column("booking_request", "short_notice")
    op.drop_column("pro_package", "short_notice_ok")
    op.drop_column("pro_scheduling_policy", "short_notice_prep_hours")
    op.drop_column("pro_scheduling_policy", "available_until")
