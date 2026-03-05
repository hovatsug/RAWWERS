"""listing card: pro profile cover media field

Revision ID: 20260305_0038
Revises: 20260305_0037
Create Date: 2026-03-05 23:15:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260305_0038"
down_revision: Union[str, Sequence[str], None] = "20260305_0037"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("pro_profile", sa.Column("cover_media_asset_id", postgresql.UUID(as_uuid=True), nullable=True))


def downgrade() -> None:
    op.drop_column("pro_profile", "cover_media_asset_id")
