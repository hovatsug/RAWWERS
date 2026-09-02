"""gig entry_rate: persisted per-photo entry rate for recomputing the
package decay curve total at selection time (needed for the B-3
difference charge, independent of whether the pro later edits their
package price)

Revision ID: 20260902_0041
Revises: 20260902_0040
Create Date: 2026-09-02 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = "20260902_0041"
down_revision: Union[str, Sequence[str], None] = "20260902_0040"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("gig", sa.Column("entry_rate", sa.Numeric(12, 2), nullable=True))


def downgrade() -> None:
    op.drop_column("gig", "entry_rate")
