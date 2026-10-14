"""An index for the request-expiry sweep, which now runs every minute.

The sweep asks for pending requests past their deadline. With no index on
status or expires_at, every run read the whole booking_request table. A
partial index over pending requests only stays small - it holds what is
waiting for an answer - and turns a run with nothing due into one short
index probe. (The unpaid-booking sweep already has ix_gig_status.)

Revision ID: 20261014_0062
Revises: 20261014_0061
"""
from alembic import op

revision = "20261014_0062"
down_revision = "20261014_0061"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_booking_request_pending_expires "
        "ON booking_request (expires_at) WHERE status = 'pending'"
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS ix_booking_request_pending_expires")
