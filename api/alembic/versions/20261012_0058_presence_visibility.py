"""Whether a photographer shows clients a dot while their app is open.

On by default - existing photographers included - and told so in Settings
and at onboarding. Hiding it hides only the dot: whether they are online is
still known to the assistant's hold and to "Available now". This column is
the source of truth; the presence key in Redis carries a copy for the
batched lookup, and anything unreadable there reads as hidden.

Revision ID: 20261012_0058
Revises: 20261012_0057
"""
from alembic import op
import sqlalchemy as sa

revision = "20261012_0058"
down_revision = "20261012_0057"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("pro_profile", sa.Column("presence_visible", sa.Boolean(), nullable=False, server_default=sa.true()))


def downgrade() -> None:
    op.drop_column("pro_profile", "presence_visible")
