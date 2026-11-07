"""Selection difference: the count of photos a booking has paid for.

Revision ID: 20261107_0090
Revises: 20261107_0089
Create Date: 2026-11-07

`gig.selection_paid_count` is nullable. Null means only the deposit, which
pays for the minimum selection; it is set when a selection is submitted or a
difference payment succeeds. Existing bookings stay null (no backfill): the
count is always derived from the money collected, so a null is never wrong.
"""
import sqlalchemy as sa
from alembic import op

revision = "20261107_0090"
down_revision = "20261107_0089"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("gig", sa.Column("selection_paid_count", sa.Integer(), nullable=True))


def downgrade() -> None:
    op.drop_column("gig", "selection_paid_count")
