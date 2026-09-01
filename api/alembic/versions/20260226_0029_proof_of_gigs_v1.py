"""proof of gigs v1

Revision ID: 20260226_0029
Revises: 20260226_0028
Create Date: 2026-02-26 18:45:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0029"
down_revision: Union[str, Sequence[str], None] = "20260226_0028"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


raww_issuance_event_type = sa.Enum(
    "gig.completed",
    "gig.delivery_confirmed",
    "review.posted",
    "gig.extras_purchased",
    "studioverse.pack_sold",
    "studioverse.milestone_reached",
    name="raww_issuance_event_type",
    native_enum=False,
)

raww_issuance_cap_scope = sa.Enum(
    "pro_daily",
    "pro_weekly",
    "pro_monthly",
    "global_daily",
    name="raww_issuance_cap_scope",
    native_enum=False,
)

raww_mint_event_status = sa.Enum(
    "minted",
    "blocked",
    "reversed",
    name="raww_mint_event_status",
    native_enum=False,
)


def upgrade() -> None:
    op.create_table(
        "raww_issuance_rule",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("event_type", raww_issuance_event_type, nullable=False, unique=True),
        sa.Column("base_raww", sa.BigInteger(), nullable=False),
        sa.Column("min_eur_value", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("max_raww_per_event", sa.BigInteger(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "raww_multiplier_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("name", sa.Text(), nullable=False, unique=True),
        sa.Column("tier_multipliers", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("rating_curve", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("dispute_penalty", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("refund_penalty_multiplier", sa.Numeric(6, 3), nullable=False, server_default="0.500"),
        sa.Column("abuse_block_threshold", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "raww_issuance_cap",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("scope", raww_issuance_cap_scope, nullable=False, unique=True),
        sa.Column("cap_raww", sa.BigInteger(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "raww_mint_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("event_type", sa.Text(), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reference_type", sa.Text(), nullable=False),
        sa.Column("reference_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("raww_awarded", sa.BigInteger(), nullable=False),
        sa.Column("multiplier_snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("status", raww_mint_event_status, nullable=False, server_default="minted"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("event_type", "reference_type", "reference_id", "pro_user_id", name="uq_raww_mint_event_event_reference_pro"),
    )
    op.create_index("ix_raww_mint_event_event_type", "raww_mint_event", ["event_type"])
    op.create_index("ix_raww_mint_event_pro_user_id", "raww_mint_event", ["pro_user_id"])
    op.create_index("ix_raww_mint_event_reference_type", "raww_mint_event", ["reference_type"])
    op.create_index("ix_raww_mint_event_reference_id", "raww_mint_event", ["reference_id"])
    op.create_index("ix_raww_mint_event_created_at", "raww_mint_event", ["created_at"])
    op.create_index("ix_raww_mint_event_pro_created", "raww_mint_event", ["pro_user_id", "created_at"])

    op.create_table(
        "raww_clawback",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reference_type", sa.Text(), nullable=False),
        sa.Column("reference_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("amount_raww", sa.BigInteger(), nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("created_by_admin_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_raww_clawback_pro_user_id", "raww_clawback", ["pro_user_id"])
    op.create_index("ix_raww_clawback_reference_id", "raww_clawback", ["reference_id"])


def downgrade() -> None:
    op.drop_index("ix_raww_clawback_reference_id", table_name="raww_clawback")
    op.drop_index("ix_raww_clawback_pro_user_id", table_name="raww_clawback")
    op.drop_table("raww_clawback")

    op.drop_index("ix_raww_mint_event_pro_created", table_name="raww_mint_event")
    op.drop_index("ix_raww_mint_event_created_at", table_name="raww_mint_event")
    op.drop_index("ix_raww_mint_event_reference_id", table_name="raww_mint_event")
    op.drop_index("ix_raww_mint_event_reference_type", table_name="raww_mint_event")
    op.drop_index("ix_raww_mint_event_pro_user_id", table_name="raww_mint_event")
    op.drop_index("ix_raww_mint_event_event_type", table_name="raww_mint_event")
    op.drop_table("raww_mint_event")

    op.drop_table("raww_issuance_cap")
    op.drop_table("raww_multiplier_policy")
    op.drop_table("raww_issuance_rule")
