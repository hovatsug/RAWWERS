"""stripe_payment: support multiple payments per gig (base/difference/extras)

Revision ID: 20260902_0039
Revises: 20260305_0038
Create Date: 2026-09-02 00:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "20260902_0039"
down_revision: Union[str, Sequence[str], None] = "20260305_0038"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

stripe_payment_kind_enum = sa.Enum(
    "base",
    "difference",
    "extras",
    name="stripe_payment_kind",
    native_enum=False,
)


def upgrade() -> None:
    op.drop_constraint("stripe_payment_gig_id_key", "stripe_payment", type_="unique")
    op.add_column(
        "stripe_payment",
        sa.Column("kind", stripe_payment_kind_enum, nullable=False, server_default="base"),
    )
    op.alter_column("stripe_payment", "kind", server_default=None)


def downgrade() -> None:
    op.drop_column("stripe_payment", "kind")
    op.create_unique_constraint("stripe_payment_gig_id_key", "stripe_payment", ["gig_id"])
