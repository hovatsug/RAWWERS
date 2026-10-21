"""Chargebacks on the admin attention list.

money_attention_item gains the Stripe dispute an item is about (one item
per dispute and kind) and a due date - a chargeback's evidence deadline.
The new ledger type chargeback_fee needs no migration (entry_type is a
varchar).

Revision ID: 20261021_0067
Revises: 20261020_0066
"""
import sqlalchemy as sa
from alembic import op

revision = "20261021_0067"
down_revision = "20261020_0066"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("money_attention_item", sa.Column("stripe_dispute_id", sa.Text(), nullable=True))
    op.add_column("money_attention_item", sa.Column("due_at", sa.DateTime(timezone=True), nullable=True))
    op.create_unique_constraint("uq_money_attention_kind_dispute", "money_attention_item", ["kind", "stripe_dispute_id"])


def downgrade() -> None:
    op.drop_constraint("uq_money_attention_kind_dispute", "money_attention_item", type_="unique")
    op.drop_column("money_attention_item", "due_at")
    op.drop_column("money_attention_item", "stripe_dispute_id")
