"""The per-photo rate behind a Discover card's total.

`min_package_price` is a starting total. A card showing only that gives a
client a large bare number with no unit and no sense of what it buys - the
same misrepresentation the profile card was fixed for, in a component that
fix never reached.

Two columns rather than one. The rate alone cannot be rendered: the price
component states a rate, a minimum photo count and the total those produce,
and a rate without its photo count is another number with no context.

Both nullable and both null for every existing row until a recompute runs.
That is deliberate - a card renders the total alone when they are absent,
which is exactly today's behaviour, so shipping the column ahead of the
backfill changes nothing rather than showing a wrong number.

Revision ID: 20260914_0050
Revises: 20260913_0049
"""
from alembic import op
import sqlalchemy as sa

revision = "20260914_0050"
down_revision = "20260913_0049"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("pro_public_index", sa.Column("min_entry_rate", sa.Numeric(12, 2), nullable=True))
    op.add_column("pro_public_index", sa.Column("min_entry_photos", sa.Integer(), nullable=True))


def downgrade() -> None:
    op.drop_column("pro_public_index", "min_entry_photos")
    op.drop_column("pro_public_index", "min_entry_rate")
