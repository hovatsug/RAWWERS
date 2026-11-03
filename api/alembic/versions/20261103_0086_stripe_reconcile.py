"""The Stripe reconcile job: its runs, and Money attention items keyed by
the payment it could not match.

Revision ID: 20261103_0086
Revises: 20261103_0085
Create Date: 2026-11-03

A new table and one nullable column with its unique constraint (one item
per kind and payment intent). Existing items keep null.
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261103_0086"
down_revision = "20261103_0085"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "stripe_reconcile_run",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("dry_run", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("checked", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("recorded", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("flagged", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("error", sa.Text(), nullable=True),
        sa.Column("details", postgresql.JSONB(), nullable=False, server_default=sa.text("'[]'::jsonb")),
    )
    op.create_index("ix_stripe_reconcile_run_started_at", "stripe_reconcile_run", ["started_at"])
    op.add_column("money_attention_item", sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True))
    op.create_unique_constraint(
        "uq_money_attention_kind_payment_intent", "money_attention_item", ["kind", "stripe_payment_intent_id"]
    )


def downgrade() -> None:
    op.drop_constraint("uq_money_attention_kind_payment_intent", "money_attention_item", type_="unique")
    op.drop_column("money_attention_item", "stripe_payment_intent_id")
    op.drop_index("ix_stripe_reconcile_run_started_at", table_name="stripe_reconcile_run")
    op.drop_table("stripe_reconcile_run")
