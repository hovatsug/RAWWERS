"""Client credit's money rules: the checkout cap and the marketing budget.

Revision ID: 20261107_0088
Revises: 20261107_0087
Create Date: 2026-11-07

One settings row, created on first use with its defaults (10%, EUR 300).
"""
import sqlalchemy as sa
from alembic import op

revision = "20261107_0088"
down_revision = "20261107_0087"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "client_credit_settings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("max_discount_percent", sa.Integer(), nullable=False, server_default="10"),
        sa.Column("monthly_marketing_credit_budget_eur", sa.Numeric(12, 2), nullable=False, server_default="300.00"),
        sa.Column("alerted_80_month", sa.Text(), nullable=True),
        sa.Column("alerted_100_month", sa.Text(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("client_credit_settings")
