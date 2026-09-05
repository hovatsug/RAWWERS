"""payout.anomaly measured from payout-account change, not settlement.

The old params ({"within_hours_of_first_available": 1}) froze any payout
requested within an hour of money settling. That is the ordinary case for
a photographer withdrawing on the day their earnings clear, not an
anomaly - every photographer's first payout would have hit it. The rule
defends against money landing in a destination someone just swapped in,
so the window now runs from the payout account's last change.

Updated in place: the rule row is seeded once by
ensure_default_risk_rules, which does not revisit existing rows, so
without this an installed database keeps the old params forever.

Revision ID: 20260905_0045
Revises: 20260904_0044
Create Date: 2026-09-05 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20260905_0045"
down_revision: Union[str, Sequence[str], None] = "20260904_0044"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

NEW_PARAMS = '{"within_hours_of_account_change": 24}'
OLD_PARAMS = '{"within_hours_of_first_available": 1}'


def upgrade() -> None:
    op.execute(
        sa.text("UPDATE risk_rule SET params = CAST(:params AS JSON) WHERE id = 'payout.anomaly'")
        .bindparams(params=NEW_PARAMS)
    )


def downgrade() -> None:
    op.execute(
        sa.text("UPDATE risk_rule SET params = CAST(:params AS JSON) WHERE id = 'payout.anomaly'")
        .bindparams(params=OLD_PARAMS)
    )
