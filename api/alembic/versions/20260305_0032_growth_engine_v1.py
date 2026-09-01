"""growth engine v1

Revision ID: 20260305_0032
Revises: 20260226_0031
Create Date: 2026-03-05 18:30:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260305_0032"
down_revision: Union[str, Sequence[str], None] = "20260226_0031"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


referral_link_status_enum = sa.Enum(
    "clicked",
    "registered",
    "converted",
    "blocked",
    name="referral_link_status",
    native_enum=False,
)

referral_conversion_type_enum = sa.Enum(
    "booking_paid",
    "extras_paid",
    "studioverse_paid",
    name="referral_conversion_type",
    native_enum=False,
)


def upgrade() -> None:
    referral_link_status_enum.create(op.get_bind(), checkfirst=True)
    referral_conversion_type_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "referral_profile",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("referral_code", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_referral_profile_referral_code", "referral_profile", ["referral_code"], unique=True)

    op.create_table(
        "referral_link",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("referrer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("referee_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("referee_email_hash", sa.Text(), nullable=True),
        sa.Column("status", referral_link_status_enum, nullable=False, server_default="clicked"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_referral_link_referrer_user_id", "referral_link", ["referrer_user_id"])
    op.create_index("ix_referral_link_referee_user_id", "referral_link", ["referee_user_id"])
    op.create_index("ix_referral_link_referee_email_hash", "referral_link", ["referee_email_hash"])
    op.create_index("ix_referral_link_status", "referral_link", ["status"])
    op.create_index("ix_referral_link_referrer_referee", "referral_link", ["referrer_user_id", "referee_user_id"], unique=True)

    op.create_table(
        "attribution_touch",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("session_id", sa.Text(), nullable=True),
        sa.Column("source", sa.Text(), nullable=True),
        sa.Column("medium", sa.Text(), nullable=True),
        sa.Column("campaign", sa.Text(), nullable=True),
        sa.Column("content", sa.Text(), nullable=True),
        sa.Column("term", sa.Text(), nullable=True),
        sa.Column("referrer_url_hash", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_attribution_touch_user_id", "attribution_touch", ["user_id"])
    op.create_index("ix_attribution_touch_session_id", "attribution_touch", ["session_id"])
    op.create_index("ix_attribution_touch_created_at", "attribution_touch", ["created_at"])

    op.create_table(
        "conversion_attribution",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("conversion_type", referral_conversion_type_enum, nullable=False),
        sa.Column("conversion_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("attributed_to", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_conversion_attribution_user_id", "conversion_attribution", ["user_id"])
    op.create_index("ix_conversion_attribution_conversion_type", "conversion_attribution", ["conversion_type"])
    op.create_index("ix_conversion_attribution_conversion_id", "conversion_attribution", ["conversion_id"])

    op.create_table(
        "referral_reward_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("conversion_type", sa.Text(), nullable=False),
        sa.Column("referrer_points", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("referee_points", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("max_rewards_per_referrer_per_month", sa.BigInteger(), nullable=False, server_default="20"),
        sa.Column("min_conversion_value_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("cooldown_days", sa.BigInteger(), nullable=False, server_default="30"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_referral_reward_policy_conversion_type", "referral_reward_policy", ["conversion_type"], unique=True)

    op.create_table(
        "referral_reward_grant",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("referrer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("referee_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("conversion_type", sa.Text(), nullable=False),
        sa.Column("conversion_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reward_ledger_entry_ids", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("granted_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_referral_reward_grant_referrer_user_id", "referral_reward_grant", ["referrer_user_id"])
    op.create_index("ix_referral_reward_grant_referee_user_id", "referral_reward_grant", ["referee_user_id"])
    op.create_index("ix_referral_reward_grant_conversion_id", "referral_reward_grant", ["conversion_id"])
    op.create_index("ix_referral_reward_grant_conversion", "referral_reward_grant", ["conversion_type", "conversion_id"], unique=True)

    op.create_table(
        "referral_blacklist",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_referral_blacklist_user_id", "referral_blacklist", ["user_id"], unique=True)


def downgrade() -> None:
    op.drop_index("ix_referral_blacklist_user_id", table_name="referral_blacklist")
    op.drop_table("referral_blacklist")

    op.drop_index("ix_referral_reward_grant_conversion", table_name="referral_reward_grant")
    op.drop_index("ix_referral_reward_grant_conversion_id", table_name="referral_reward_grant")
    op.drop_index("ix_referral_reward_grant_referee_user_id", table_name="referral_reward_grant")
    op.drop_index("ix_referral_reward_grant_referrer_user_id", table_name="referral_reward_grant")
    op.drop_table("referral_reward_grant")

    op.drop_index("ix_referral_reward_policy_conversion_type", table_name="referral_reward_policy")
    op.drop_table("referral_reward_policy")

    op.drop_index("ix_conversion_attribution_conversion_id", table_name="conversion_attribution")
    op.drop_index("ix_conversion_attribution_conversion_type", table_name="conversion_attribution")
    op.drop_index("ix_conversion_attribution_user_id", table_name="conversion_attribution")
    op.drop_table("conversion_attribution")

    op.drop_index("ix_attribution_touch_created_at", table_name="attribution_touch")
    op.drop_index("ix_attribution_touch_session_id", table_name="attribution_touch")
    op.drop_index("ix_attribution_touch_user_id", table_name="attribution_touch")
    op.drop_table("attribution_touch")

    op.drop_index("ix_referral_link_referrer_referee", table_name="referral_link")
    op.drop_index("ix_referral_link_status", table_name="referral_link")
    op.drop_index("ix_referral_link_referee_email_hash", table_name="referral_link")
    op.drop_index("ix_referral_link_referee_user_id", table_name="referral_link")
    op.drop_index("ix_referral_link_referrer_user_id", table_name="referral_link")
    op.drop_table("referral_link")

    op.drop_index("ix_referral_profile_referral_code", table_name="referral_profile")
    op.drop_table("referral_profile")

    referral_conversion_type_enum.drop(op.get_bind(), checkfirst=True)
    referral_link_status_enum.drop(op.get_bind(), checkfirst=True)
