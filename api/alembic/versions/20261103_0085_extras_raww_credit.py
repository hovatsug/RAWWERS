"""Extras earn the RAWW credit: the credit stamped on the earnings entry.

Revision ID: 20261103_0085
Revises: 20261103_0084
Create Date: 2026-11-03

Two nullable columns. Existing entries keep null: extras from before this
release earned no credit and get none (no backfill).
"""
from alembic import op
import sqlalchemy as sa

revision = "20261103_0085"
down_revision = "20261103_0084"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("earnings_ledger_entry", sa.Column("pro_raww_eur", sa.Numeric(12, 2), nullable=True))
    op.add_column("earnings_ledger_entry", sa.Column("pro_raww_percent", sa.SmallInteger(), nullable=True))


def downgrade() -> None:
    op.drop_column("earnings_ledger_entry", "pro_raww_percent")
    op.drop_column("earnings_ledger_entry", "pro_raww_eur")
