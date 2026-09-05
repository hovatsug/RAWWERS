"""backfill portfolio photo visibility: photos uploaded with
purpose=portfolio_reel were hardcoded to owner_only by
create_photo_upload, so no client could fetch a photographer's portfolio
through GET /v1/media/{id}. The video path already defaulted the same
purpose to public. Existing rows are corrected here to match.

Revision ID: 20260904_0043
Revises: 20260902_0042
Create Date: 2026-09-04 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

from alembic import op

revision: str = "20260904_0043"
down_revision: Union[str, Sequence[str], None] = "20260902_0042"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Narrow on purpose: only portfolio photos, and only ones still sitting at
    # the hardcoded default. A pro who deliberately set something else - now
    # possible, since the endpoint accepts a visibility - keeps their choice.
    # media_visibility is native_enum=False, so these are plain varchar values.
    op.execute(
        """
        UPDATE media_asset
        SET visibility = 'public'
        WHERE kind = 'photo'
          AND purpose = 'portfolio_reel'
          AND visibility = 'owner_only'
        """
    )


def downgrade() -> None:
    # Restores the pre-fix state for portfolio photos. Not perfectly
    # reversible: a photo a pro explicitly set to public after the fix is
    # indistinguishable from one this migration changed, and reverts too.
    op.execute(
        """
        UPDATE media_asset
        SET visibility = 'owner_only'
        WHERE kind = 'photo'
          AND purpose = 'portfolio_reel'
          AND visibility = 'public'
        """
    )
