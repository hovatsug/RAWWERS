"""Multi-currency M3: display rates and the display currency
(docs/MULTI_CURRENCY.md 4.1, 2.2, 6.1 migrations 2 and 4).

- fx_rate: the ECB's euro reference rates, one row per (currency,
  publication day); for display and reporting only, never for money.
- user_account.display_currency (null: the default currency, GBP).

Downgrade drops both: rates are fetched again, and a chosen display
currency is a preference; nothing is ever converted with either on the
money path.

Revision ID: 20261114_0098
Revises: 20261114_0097
Create Date: 2026-11-14
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261114_0098"
down_revision = "20261114_0097"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "fx_rate",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("base", sa.CHAR(3), nullable=False),
        sa.Column("quote", sa.CHAR(3), nullable=False),
        sa.Column("rate", sa.Numeric(18, 8), nullable=False),
        sa.Column("as_of", sa.Date(), nullable=False),
        sa.Column("fetched_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("source", sa.Text(), nullable=False),
        sa.UniqueConstraint("base", "quote", "as_of", name="uq_fx_rate_base_quote_as_of"),
        sa.CheckConstraint("rate > 0", name="ck_fx_rate_positive"),
    )
    op.create_index("ix_fx_rate_quote", "fx_rate", ["quote"])
    op.create_index("ix_fx_rate_as_of", "fx_rate", ["as_of"])
    op.add_column("user_account", sa.Column("display_currency", sa.CHAR(3), nullable=True))


def downgrade() -> None:
    op.drop_column("user_account", "display_currency")
    op.drop_table("fx_rate")
