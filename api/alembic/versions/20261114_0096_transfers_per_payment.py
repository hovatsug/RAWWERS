"""Multi-currency M7: every transfer is funded by one client payment
(docs/MULTI_CURRENCY.md 10.4; high-risk: money).

- stripe_payment.stripe_charge_id: the charge behind the payment (the
  PaymentIntent's latest_charge), written by the payment webhook. Existing
  rows stay null: the payout reads the charge from Stripe the first time it
  needs one (no Stripe call in a migration).
- earnings_ledger_entry.stripe_payment_id: the payment an earning came from.
  Backfill: a booking's earning takes the booking's first base payment that
  went through; an add-on's earning takes its own payment. Others stay null
  (no payment of ours behind them).
- payout_transfer: one row per Stripe transfer of a payout, per payment.

Downgrade refuses while any payout_transfer row exists (it would drop the
record of money sent); otherwise it drops what this revision added.

Revision ID: 20261114_0096
Revises: 20261113_0095
Create Date: 2026-11-14
"""
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "20261114_0096"
down_revision = "20261113_0095"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("stripe_payment", sa.Column("stripe_charge_id", sa.Text(), nullable=True))
    op.create_index("ix_stripe_payment_stripe_charge_id", "stripe_payment", ["stripe_charge_id"])

    op.add_column(
        "earnings_ledger_entry",
        sa.Column("stripe_payment_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("stripe_payment.id"), nullable=True),
    )
    op.create_index("ix_earnings_ledger_entry_stripe_payment_id", "earnings_ledger_entry", ["stripe_payment_id"])

    # A booking's earning: the booking's first base payment that went through.
    op.execute(
        """
        UPDATE earnings_ledger_entry e
        SET stripe_payment_id = (
            SELECT p.id FROM stripe_payment p
            WHERE p.gig_id = e.source_id AND p.kind = 'base'
              AND p.status IN ('succeeded', 'refunded', 'disputed')
            ORDER BY p.created_at ASC LIMIT 1
        )
        WHERE e.source_type = 'gig_base' AND e.stripe_payment_id IS NULL
        """
    )
    # An add-on's earning: its own payment.
    op.execute(
        """
        UPDATE earnings_ledger_entry e
        SET stripe_payment_id = p.id
        FROM extra_image_purchase x
        JOIN stripe_payment p ON p.stripe_payment_intent_id = x.stripe_payment_intent_id
        WHERE e.source_type = 'extra_images' AND e.source_id = x.id AND e.stripe_payment_id IS NULL
        """
    )

    op.create_table(
        "payout_transfer",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("payout_request_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("payout_request.id"), nullable=False),
        sa.Column("stripe_payment_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("stripe_payment.id"), nullable=True),
        sa.Column("currency", sa.CHAR(3), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("stripe_charge_id", sa.Text(), nullable=True),
        sa.Column("stripe_transfer_id", sa.Text(), nullable=True),
        sa.Column("status", sa.String(32), nullable=False),
        sa.Column("attempts", sa.SmallInteger(), nullable=False, server_default="0"),
        sa.Column("failure_reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("payout_request_id", "stripe_payment_id", name="uq_payout_transfer_payment"),
    )
    op.create_index("ix_payout_transfer_payout_request_id", "payout_transfer", ["payout_request_id"])
    op.create_index("ix_payout_transfer_stripe_payment_id", "payout_transfer", ["stripe_payment_id"])
    op.create_index("ix_payout_transfer_stripe_transfer_id", "payout_transfer", ["stripe_transfer_id"])
    op.create_index("ix_payout_transfer_status", "payout_transfer", ["status"])
    op.create_index(
        "uq_payout_transfer_unfunded",
        "payout_transfer",
        ["payout_request_id"],
        unique=True,
        postgresql_where=sa.text("stripe_payment_id IS NULL"),
    )


def downgrade() -> None:
    count = op.get_bind().execute(sa.text("SELECT count(*) FROM payout_transfer")).scalar_one()
    if count:
        raise RuntimeError(
            f"payout_transfer has {count} rows: downgrading would drop the record of money sent. Refused."
        )
    op.drop_table("payout_transfer")
    op.drop_index("ix_earnings_ledger_entry_stripe_payment_id", table_name="earnings_ledger_entry")
    op.drop_column("earnings_ledger_entry", "stripe_payment_id")
    op.drop_index("ix_stripe_payment_stripe_charge_id", table_name="stripe_payment")
    op.drop_column("stripe_payment", "stripe_charge_id")
