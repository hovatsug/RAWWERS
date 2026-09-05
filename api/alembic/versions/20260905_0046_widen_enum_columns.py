"""Widen dispute.category and refund_case.status.

Both are `Enum(..., native_enum=False)` columns, which Alembic sized to
the longest enum value *at the time the migration was written*. Values
added later exceeded the width, and Postgres rejects the insert:

    dispute.category      varchar(13) < 'deliverable_quality' (19)
    refund_case.status    varchar(10) < 'refund_initiated'    (16)

The effect was that opening a dispute in the two most likely categories
for a photography marketplace - "the photos aren't good" and "they
cancelled late" - returned a 500, and resolving any dispute into a refund
would have hit the second one immediately afterwards. The entire
dispute-to-refund path was unreachable.

Widened well past the current longest value rather than exactly to it, so
the next enum value added does not repeat this. Roughly forty other enum
columns currently sit exactly at their limit; they work today and are
recorded in docs/BACKEND_GAPS.md rather than migrated en masse here.

Revision ID: 20260905_0046
Revises: 20260905_0045
Create Date: 2026-09-05 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20260905_0046"
down_revision: Union[str, Sequence[str], None] = "20260905_0045"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.alter_column("dispute", "category", type_=sa.String(length=64), existing_nullable=False)
    op.alter_column("refund_case", "status", type_=sa.String(length=64), existing_nullable=False)


def downgrade() -> None:
    # Narrowing again would truncate rows written in the meantime, so the
    # downgrade only goes back to the original widths when nothing longer
    # exists. Left as a no-op deliberately: losing a dispute's category is
    # worse than an imperfect downgrade.
    pass
