"""Money an admin has to act on, from refund reconciliation.

A table for items raised when reconciling a payment's refunds with Stripe:
a client still owed after their refund failed, and a refund made outside
RAWWERS (in the Stripe dashboard) that was adopted into our records. One
per Stripe refund and kind. The new ledger type refund_failed needs no
migration: ledger_entry.entry_type is a plain varchar(64).

Revision ID: 20261020_0066
Revises: 20261019_0065
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261020_0066"
down_revision = "20261019_0065"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "money_attention_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("kind", sa.Text(), nullable=False),
        sa.Column("status", sa.Text(), nullable=False, server_default="open"),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=True),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("refund_case_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("refund_case.id"), nullable=True),
        sa.Column("stripe_refund_id", sa.Text(), nullable=True),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("resolved_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("kind", "stripe_refund_id", name="uq_money_attention_kind_refund"),
    )
    op.create_index("ix_money_attention_item_kind", "money_attention_item", ["kind"])
    op.create_index("ix_money_attention_item_status", "money_attention_item", ["status"])
    op.create_index("ix_money_attention_item_gig_id", "money_attention_item", ["gig_id"])


def downgrade() -> None:
    op.drop_index("ix_money_attention_item_gig_id", table_name="money_attention_item")
    op.drop_index("ix_money_attention_item_status", table_name="money_attention_item")
    op.drop_index("ix_money_attention_item_kind", table_name="money_attention_item")
    op.drop_table("money_attention_item")
