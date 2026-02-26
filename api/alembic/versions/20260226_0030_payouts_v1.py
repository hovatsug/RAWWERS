"""payouts v1

Revision ID: 20260226_0030
Revises: 20260226_0029
Create Date: 2026-02-26 20:15:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0030"
down_revision: Union[str, Sequence[str], None] = "20260226_0029"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


earnings_source_type = sa.Enum("gig_base", "extra_images", "studioverse_sale", name="earnings_source_type", native_enum=False)
earnings_entry_status = sa.Enum("pending", "available", "held", "reversed", name="earnings_entry_status", native_enum=False)
earnings_hold_reason = sa.Enum("dispute_open", "refund_risk", "compliance", "manual", name="earnings_hold_reason", native_enum=False)
payout_method = sa.Enum("stripe_connect", "bank_manual", name="payout_method", native_enum=False)
payout_account_status = sa.Enum("not_set", "pending_verification", "active", "disabled", name="payout_account_status", native_enum=False)
payout_request_status = sa.Enum(
    "requested",
    "approved",
    "rejected",
    "processing",
    "paid",
    "failed",
    "cancelled",
    name="payout_request_status",
    native_enum=False,
)


def upgrade() -> None:
    op.create_table(
        "earnings_ledger_entry",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("source_type", earnings_source_type, nullable=False),
        sa.Column("source_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("gross_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("platform_fee_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("net_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("status", earnings_entry_status, nullable=False, server_default="pending"),
        sa.Column("available_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("reversed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("source_type", "source_id", "pro_user_id", name="uq_earnings_source_pro"),
    )
    op.create_index("ix_earnings_ledger_entry_pro_user_id", "earnings_ledger_entry", ["pro_user_id"])
    op.create_index("ix_earnings_ledger_entry_source_id", "earnings_ledger_entry", ["source_id"])
    op.create_index("ix_earnings_ledger_entry_status", "earnings_ledger_entry", ["status"])
    op.create_index("ix_earnings_ledger_entry_available_at", "earnings_ledger_entry", ["available_at"])
    op.create_index("ix_earnings_entry_pro_status", "earnings_ledger_entry", ["pro_user_id", "status"])

    op.create_table(
        "earnings_balance_snapshot",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pending_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("available_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("held_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "earnings_hold",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", earnings_hold_reason, nullable=False),
        sa.Column("amount_eur", sa.Numeric(12, 2), nullable=True),
        sa.Column("source_type", sa.Text(), nullable=True),
        sa.Column("source_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_by_admin_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("released_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_earnings_hold_pro_user_id", "earnings_hold", ["pro_user_id"])
    op.create_index("ix_earnings_hold_pro_released", "earnings_hold", ["pro_user_id", "released_at"])

    op.create_table(
        "payout_account",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("payout_method", payout_method, nullable=False, server_default="bank_manual"),
        sa.Column("stripe_connect_account_id", sa.Text(), nullable=True),
        sa.Column("bank_details_encrypted", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("status", payout_account_status, nullable=False, server_default="not_set"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "payout_request",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("amount_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("status", payout_request_status, nullable=False, server_default="requested"),
        sa.Column("requested_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("approved_by_admin_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("paid_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("failure_reason", sa.Text(), nullable=True),
        sa.Column("reference", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_payout_request_pro_user_id", "payout_request", ["pro_user_id"])
    op.create_index("ix_payout_request_status", "payout_request", ["status"])
    op.create_index("ix_payout_request_pro_created", "payout_request", ["pro_user_id", "created_at"])

    op.create_table(
        "payout_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("payout_request_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("type", sa.Text(), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_payout_event_payout_request_id", "payout_event", ["payout_request_id"])

    op.create_table(
        "payout_allocation",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("payout_request_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("earnings_ledger_entry_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("amount_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("payout_request_id", "earnings_ledger_entry_id", name="uq_payout_allocation_unique"),
    )
    op.create_index("ix_payout_allocation_payout_request_id", "payout_allocation", ["payout_request_id"])
    op.create_index("ix_payout_allocation_earnings_ledger_entry_id", "payout_allocation", ["earnings_ledger_entry_id"])

    op.create_table(
        "platform_fee_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("fee_percent_gigs", sa.Integer(), nullable=False, server_default="20"),
        sa.Column("fee_percent_extras", sa.Integer(), nullable=False, server_default="20"),
        sa.Column("fee_percent_studioverse", sa.Integer(), nullable=False, server_default="20"),
        sa.Column("settlement_delay_days", sa.Integer(), nullable=False, server_default="7"),
        sa.Column("dispute_hold_days", sa.Integer(), nullable=False, server_default="14"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "tax_profile",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("vat_number", sa.Text(), nullable=True),
        sa.Column("country", sa.Text(), nullable=True),
        sa.Column("legal_name", sa.Text(), nullable=True),
        sa.Column("address_ref", sa.Text(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("tax_profile")
    op.drop_table("platform_fee_policy")

    op.drop_index("ix_payout_allocation_earnings_ledger_entry_id", table_name="payout_allocation")
    op.drop_index("ix_payout_allocation_payout_request_id", table_name="payout_allocation")
    op.drop_table("payout_allocation")

    op.drop_index("ix_payout_event_payout_request_id", table_name="payout_event")
    op.drop_table("payout_event")

    op.drop_index("ix_payout_request_pro_created", table_name="payout_request")
    op.drop_index("ix_payout_request_status", table_name="payout_request")
    op.drop_index("ix_payout_request_pro_user_id", table_name="payout_request")
    op.drop_table("payout_request")

    op.drop_table("payout_account")

    op.drop_index("ix_earnings_hold_pro_released", table_name="earnings_hold")
    op.drop_index("ix_earnings_hold_pro_user_id", table_name="earnings_hold")
    op.drop_table("earnings_hold")

    op.drop_table("earnings_balance_snapshot")

    op.drop_index("ix_earnings_entry_pro_status", table_name="earnings_ledger_entry")
    op.drop_index("ix_earnings_ledger_entry_available_at", table_name="earnings_ledger_entry")
    op.drop_index("ix_earnings_ledger_entry_status", table_name="earnings_ledger_entry")
    op.drop_index("ix_earnings_ledger_entry_source_id", table_name="earnings_ledger_entry")
    op.drop_index("ix_earnings_ledger_entry_pro_user_id", table_name="earnings_ledger_entry")
    op.drop_table("earnings_ledger_entry")
