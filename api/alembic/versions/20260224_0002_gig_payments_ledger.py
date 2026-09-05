"""gig state machine, stripe payment, and ledger

Revision ID: 20260224_0002
Revises: 20260224_0001
Create Date: 2026-02-24 21:10:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260224_0002"
down_revision: Union[str, Sequence[str], None] = "20260224_0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


gig_status_enum = sa.Enum(
    "draft",
    "requested",
    "accepted",
    "payment_pending",
    "paid",
    "scheduled",
    "shoot_done",
    "proofs_delivered",
    "selection_pending",
    "final_delivered",
    "completed",
    "cancelled_by_client",
    "cancelled_by_pro",
    "refunded",
    "disputed",
    name="gig_status",
    native_enum=False,
)

ledger_entry_type_enum = sa.Enum(
    "payment_authorized",
    "payment_captured",
    "platform_fee",
    "payout_hold_created",
    "payout_hold_released",
    "refund_initiated",
    "refund_succeeded",
    "chargeback_opened",
    "chargeback_won",
    "chargeback_lost",
    name="ledger_entry_type",
    native_enum=False,
)

payment_status_enum = sa.Enum(
    "pending",
    "requires_action",
    "succeeded",
    "failed",
    "cancelled",
    "refunded",
    "disputed",
    name="payment_status",
    native_enum=False,
)


def upgrade() -> None:
    op.create_table(
        "gig",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", gig_status_enum, nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("amount_total", sa.Numeric(12, 2), nullable=False),
        sa.Column("amount_platform_fee", sa.Numeric(12, 2), nullable=False),
        sa.Column("amount_pro_gross", sa.Numeric(12, 2), nullable=False),
        sa.Column("scheduled_start", sa.DateTime(timezone=True), nullable=True),
        sa.Column("scheduled_end", sa.DateTime(timezone=True), nullable=True),
        sa.Column("location_text", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_gig_client_user_id", "gig", ["client_user_id"])
    op.create_index("ix_gig_pro_user_id", "gig", ["pro_user_id"])
    op.create_index("ix_gig_status", "gig", ["status"])

    op.create_table(
        "gig_transition",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("from_status", gig_status_enum, nullable=False),
        sa.Column("to_status", gig_status_enum, nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_gig_transition_gig_id", "gig_transition", ["gig_id"])

    op.create_table(
        "stripe_payment",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False, unique=True),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", payment_status_enum, nullable=False),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=False, unique=True),
        sa.Column("stripe_customer_id", sa.Text(), nullable=True),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False),
        sa.Column("last_error", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_stripe_payment_gig_id", "stripe_payment", ["gig_id"])
    op.create_index("ix_stripe_payment_client_user_id", "stripe_payment", ["client_user_id"])
    op.create_index("ix_stripe_payment_status", "stripe_payment", ["status"])
    op.create_index("ix_stripe_payment_intent", "stripe_payment", ["stripe_payment_intent_id"])

    op.create_table(
        "ledger_entry",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("entry_type", ledger_entry_type_enum, nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("reference_type", sa.Text(), nullable=True),
        sa.Column("reference_id", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_ledger_entry_gig_id", "ledger_entry", ["gig_id"])
    op.create_index("ix_ledger_entry_type", "ledger_entry", ["entry_type"])
    op.create_index("ix_ledger_entry_gig_created", "ledger_entry", ["gig_id", sa.text("created_at DESC")])

    op.create_table(
        "stripe_webhook_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("external_event_id", sa.Text(), nullable=False, unique=True),
        sa.Column("event_type", sa.Text(), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("received_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("stripe_webhook_event")

    op.drop_index("ix_ledger_entry_gig_created", table_name="ledger_entry")
    op.drop_index("ix_ledger_entry_type", table_name="ledger_entry")
    op.drop_index("ix_ledger_entry_gig_id", table_name="ledger_entry")
    op.drop_table("ledger_entry")

    op.drop_index("ix_stripe_payment_intent", table_name="stripe_payment")
    op.drop_index("ix_stripe_payment_status", table_name="stripe_payment")
    op.drop_index("ix_stripe_payment_client_user_id", table_name="stripe_payment")
    op.drop_index("ix_stripe_payment_gig_id", table_name="stripe_payment")
    op.drop_table("stripe_payment")

    op.drop_index("ix_gig_transition_gig_id", table_name="gig_transition")
    op.drop_table("gig_transition")

    op.drop_index("ix_gig_status", table_name="gig")
    op.drop_index("ix_gig_pro_user_id", table_name="gig")
    op.drop_index("ix_gig_client_user_id", table_name="gig")
    op.drop_table("gig")
