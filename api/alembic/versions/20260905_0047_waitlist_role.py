"""client_waitlist.role: which side of the marketplace signed up.

Without it the waitlist cannot separate demand from supply, and the whole
point of the list is deciding the next launch market - "200 people in
Porto" means nothing until you know how many of them hold a camera.

Nullable, because rows captured before this exist and guessing their side
would be worse than recording that it was never asked.

Revision ID: 20260905_0047
Revises: 20260905_0046
Create Date: 2026-09-05 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20260905_0047"
down_revision: Union[str, Sequence[str], None] = "20260905_0046"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("client_waitlist", sa.Column("role", sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column("client_waitlist", "role")
