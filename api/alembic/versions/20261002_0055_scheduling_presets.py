"""How a package's bookable times are laid out.

A package chooses a scheduling preset: interval (hourly by default, or 4-hour),
named blocks at the photographer's own times, or the full day. Every existing
package becomes `interval` with no interval set - the photographer's own slot
length, which is exactly how it was booked before - so nothing changes for
them.

A booking request records the preset it was made under, so it is judged by
those rules even if the package changes later. Existing requests get NULL,
which reads as interval.

Revision ID: 20261002_0055
Revises: 20260919_0054
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "20261002_0055"
down_revision = "20260919_0054"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "pro_package",
        sa.Column("scheduling_preset", sa.String(length=32), nullable=False, server_default="interval"),
    )
    op.add_column("pro_package", sa.Column("interval_minutes", sa.Integer(), nullable=True))
    op.add_column("booking_request", sa.Column("scheduling_preset", sa.String(length=32), nullable=True))

    op.create_table(
        "package_session_block",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "package_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("pro_package.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("label", sa.String(length=32), nullable=False),
        sa.Column("start_time", sa.Time(timezone=False), nullable=False),
        sa.Column("end_time", sa.Time(timezone=False), nullable=False),
        sa.UniqueConstraint("package_id", "label", name="uq_package_session_block_label"),
    )
    op.create_index("ix_package_session_block_package_id", "package_session_block", ["package_id"])


def downgrade() -> None:
    op.drop_index("ix_package_session_block_package_id", table_name="package_session_block")
    op.drop_table("package_session_block")
    op.drop_column("booking_request", "scheduling_preset")
    op.drop_column("pro_package", "interval_minutes")
    op.drop_column("pro_package", "scheduling_preset")
