"""pro_profile.travel_radius_km: how far a photographer will travel for a
shoot. Nullable rather than defaulted, because a client filtering on
distance needs to distinguish "will not travel" from "has not said" -
backfilling every existing pro to 0 would assert the first about people
who have only ever been asked the second.

Revision ID: 20260904_0044
Revises: 20260904_0043
Create Date: 2026-09-04 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20260904_0044"
down_revision: Union[str, Sequence[str], None] = "20260904_0043"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("pro_profile", sa.Column("travel_radius_km", sa.Integer(), nullable=True))


def downgrade() -> None:
    op.drop_column("pro_profile", "travel_radius_km")
