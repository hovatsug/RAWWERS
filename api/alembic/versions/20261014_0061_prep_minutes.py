"""Available now: preparation time in minutes, from a fixed set of options.

pro_scheduling_policy.short_notice_prep_hours (1-6) becomes
short_notice_prep_minutes, one of 90, 120, 180, 240, 360 (default 120). 90 is
the floor: 30 minutes to accept, 30 to pay and 30 of margin before the start,
so a request at the edge of the notice can still be accepted and paid.

Existing values move up to the nearest option, never down - a photographer
who asked for more preparation time keeps at least that much:
1 -> 90, 2 -> 120, 3 -> 180, 4 -> 240, 5 and 6 -> 360.

Revision ID: 20261014_0061
Revises: 20261013_0060
"""
from alembic import op
import sqlalchemy as sa

revision = "20261014_0061"
down_revision = "20261013_0060"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "pro_scheduling_policy",
        sa.Column("short_notice_prep_minutes", sa.Integer(), nullable=False, server_default="120"),
    )
    op.execute(
        """
        UPDATE pro_scheduling_policy SET short_notice_prep_minutes = CASE
            WHEN short_notice_prep_hours <= 1 THEN 90
            WHEN short_notice_prep_hours = 2 THEN 120
            WHEN short_notice_prep_hours = 3 THEN 180
            WHEN short_notice_prep_hours = 4 THEN 240
            ELSE 360
        END
        """
    )
    op.drop_column("pro_scheduling_policy", "short_notice_prep_hours")


def downgrade() -> None:
    op.add_column(
        "pro_scheduling_policy",
        sa.Column("short_notice_prep_hours", sa.Integer(), nullable=False, server_default="2"),
    )
    op.execute("UPDATE pro_scheduling_policy SET short_notice_prep_hours = CEIL(short_notice_prep_minutes / 60.0)")
    op.drop_column("pro_scheduling_policy", "short_notice_prep_minutes")
