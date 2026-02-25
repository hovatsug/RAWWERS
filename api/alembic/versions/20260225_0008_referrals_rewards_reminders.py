"""referrals rewards and reminders

Revision ID: 20260225_0008
Revises: 20260225_0007
Create Date: 2026-02-25 03:40:00.000000
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0008"
down_revision: Union[str, Sequence[str], None] = "20260225_0007"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


referral_owner_role_enum = sa.Enum("client", "pro", name="referral_owner_role", native_enum=False)
attribution_type_enum = sa.Enum("signup", name="attribution_type", native_enum=False)
reward_entry_type_enum = sa.Enum("earn", "spend", "adjustment", name="reward_entry_type", native_enum=False)
redemption_context_type_enum = sa.Enum("gig_payment", "upsell_purchase", name="redemption_context_type", native_enum=False)
discount_redemption_status_enum = sa.Enum("reserved", "applied", "released", name="discount_redemption_status", native_enum=False)
reminder_kind_enum = sa.Enum("proof_selection_reminder", name="reminder_kind", native_enum=False)
reminder_status_enum = sa.Enum("scheduled", "sent", "cancelled", name="reminder_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "referral_code",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("owner_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("code", sa.Text(), nullable=False, unique=True),
        sa.Column("role", referral_owner_role_enum, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_referral_code_owner_user_id", "referral_code", ["owner_user_id"])
    op.create_index("ix_referral_code_code", "referral_code", ["code"], unique=True)

    op.create_table(
        "referral_attribution",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("referred_user_id", postgresql.UUID(as_uuid=True), nullable=False, unique=True),
        sa.Column("referrer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("referral_code", sa.Text(), nullable=False),
        sa.Column("attribution_type", attribution_type_enum, nullable=False, server_default="signup"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_referral_attribution_referred_user_id", "referral_attribution", ["referred_user_id"], unique=True)
    op.create_index("ix_referral_attribution_referrer_user_id", "referral_attribution", ["referrer_user_id"])

    op.create_table(
        "reward_rule",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code", sa.Text(), nullable=False, unique=True),
        sa.Column("is_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("amount", sa.BigInteger(), nullable=False),
        sa.Column("currency", sa.Text(), nullable=False, server_default="RAWW_POINTS"),
        sa.Column("daily_cap_per_user", sa.BigInteger(), nullable=True),
        sa.Column("lifetime_cap_per_user", sa.BigInteger(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_reward_rule_code", "reward_rule", ["code"], unique=True)

    op.create_table(
        "reward_balance",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("balance", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "reward_ledger_entry",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("entry_type", reward_entry_type_enum, nullable=False),
        sa.Column("rule_code", sa.Text(), nullable=True),
        sa.Column("amount", sa.BigInteger(), nullable=False),
        sa.Column("balance_after", sa.BigInteger(), nullable=False),
        sa.Column("reference_type", sa.Text(), nullable=True),
        sa.Column("reference_id", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_reward_ledger_entry_user_id", "reward_ledger_entry", ["user_id"])
    op.create_index("ix_reward_ledger_entry_created_at", "reward_ledger_entry", ["created_at"])
    op.create_index("ix_reward_ledger_user_created", "reward_ledger_entry", ["user_id", sa.text("created_at DESC")])

    op.create_table(
        "discount_redemption",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("context_type", redemption_context_type_enum, nullable=False),
        sa.Column("context_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("points_spent", sa.BigInteger(), nullable=False),
        sa.Column("discount_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("status", discount_redemption_status_enum, nullable=False, server_default="reserved"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_discount_redemption_user_id", "discount_redemption", ["user_id"])
    op.create_index("ix_discount_redemption_context_id", "discount_redemption", ["context_id"])
    op.create_index("ix_discount_redemption_status", "discount_redemption", ["status"])

    op.create_table(
        "reminder_job",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("kind", reminder_kind_enum, nullable=False),
        sa.Column("reference_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("scheduled_for", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", reminder_status_enum, nullable=False, server_default="scheduled"),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_reminder_job_user_id", "reminder_job", ["user_id"])
    op.create_index("ix_reminder_job_reference_id", "reminder_job", ["reference_id"])
    op.create_index("ix_reminder_job_scheduled_for", "reminder_job", ["scheduled_for"])

    reward_rule_table = sa.table(
        "reward_rule",
        sa.column("id", postgresql.UUID(as_uuid=True)),
        sa.column("code", sa.Text()),
        sa.column("is_enabled", sa.Boolean()),
        sa.column("amount", sa.BigInteger()),
        sa.column("currency", sa.Text()),
        sa.column("daily_cap_per_user", sa.BigInteger()),
        sa.column("lifetime_cap_per_user", sa.BigInteger()),
        sa.column("metadata", postgresql.JSONB(astext_type=sa.Text())),
        sa.column("created_at", sa.DateTime(timezone=True)),
        sa.column("updated_at", sa.DateTime(timezone=True)),
    )
    now = datetime.now(timezone.utc)
    op.bulk_insert(
        reward_rule_table,
        [
            {
                "id": uuid.uuid4(),
                "code": "client_referral_signup",
                "is_enabled": True,
                "amount": 300,
                "currency": "RAWW_POINTS",
                "daily_cap_per_user": 3000,
                "lifetime_cap_per_user": 30000,
                "metadata": {},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "client_first_booking_paid",
                "is_enabled": True,
                "amount": 500,
                "currency": "RAWW_POINTS",
                "daily_cap_per_user": 5000,
                "lifetime_cap_per_user": 50000,
                "metadata": {},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "pro_referral_signup",
                "is_enabled": True,
                "amount": 700,
                "currency": "RAWW_POINTS",
                "daily_cap_per_user": 7000,
                "lifetime_cap_per_user": 70000,
                "metadata": {},
                "created_at": now,
                "updated_at": now,
            },
        ],
    )


def downgrade() -> None:
    op.drop_index("ix_reminder_job_scheduled_for", table_name="reminder_job")
    op.drop_index("ix_reminder_job_reference_id", table_name="reminder_job")
    op.drop_index("ix_reminder_job_user_id", table_name="reminder_job")
    op.drop_table("reminder_job")

    op.drop_index("ix_discount_redemption_status", table_name="discount_redemption")
    op.drop_index("ix_discount_redemption_context_id", table_name="discount_redemption")
    op.drop_index("ix_discount_redemption_user_id", table_name="discount_redemption")
    op.drop_table("discount_redemption")

    op.drop_index("ix_reward_ledger_user_created", table_name="reward_ledger_entry")
    op.drop_index("ix_reward_ledger_entry_created_at", table_name="reward_ledger_entry")
    op.drop_index("ix_reward_ledger_entry_user_id", table_name="reward_ledger_entry")
    op.drop_table("reward_ledger_entry")

    op.drop_table("reward_balance")

    op.drop_index("ix_reward_rule_code", table_name="reward_rule")
    op.drop_table("reward_rule")

    op.drop_index("ix_referral_attribution_referrer_user_id", table_name="referral_attribution")
    op.drop_index("ix_referral_attribution_referred_user_id", table_name="referral_attribution")
    op.drop_table("referral_attribution")

    op.drop_index("ix_referral_code_code", table_name="referral_code")
    op.drop_index("ix_referral_code_owner_user_id", table_name="referral_code")
    op.drop_table("referral_code")
