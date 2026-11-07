"""Selection add-on window: until when a client may add photos, and the setting.

Revision ID: 20261107_0087
Revises: 20261103_0086
Create Date: 2026-11-07

`gig.addon_window_ends_at` is nullable and stays null on existing bookings
(their selections closed before add-ons existed). The setting defaults to 7.
"""
import sqlalchemy as sa
from alembic import op

revision = "20261107_0087"
down_revision = "20261103_0086"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("gig", sa.Column("addon_window_ends_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column(
        "delivery_review_policy",
        sa.Column("selection_addon_days", sa.Integer(), nullable=False, server_default="7"),
    )


def downgrade() -> None:
    op.drop_column("delivery_review_policy", "selection_addon_days")
    op.drop_column("gig", "addon_window_ends_at")
