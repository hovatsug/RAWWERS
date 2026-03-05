"""trust safety v1

Revision ID: 20260305_0033
Revises: 20260305_0032
Create Date: 2026-03-05 18:45:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260305_0033"
down_revision: Union[str, Sequence[str], None] = "20260305_0032"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


risk_level_enum = sa.Enum("low", "medium", "high", "critical", name="risk_level", native_enum=False)
risk_action_type_enum = sa.Enum(
    "throttle_bookings",
    "disable_share_links",
    "freeze_rewards",
    "freeze_payouts",
    "require_verification",
    "force_logout",
    "manual_review",
    name="risk_action_type",
    native_enum=False,
)
risk_action_status_enum = sa.Enum("active", "cleared", name="risk_action_status", native_enum=False)


def upgrade() -> None:
    risk_level_enum.create(op.get_bind(), checkfirst=True)
    risk_action_type_enum.create(op.get_bind(), checkfirst=True)
    risk_action_status_enum.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "device_fingerprint",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("fingerprint_hash", sa.Text(), nullable=False),
        sa.Column("first_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
    )
    op.create_index("ix_device_fingerprint_user_id", "device_fingerprint", ["user_id"])
    op.create_index("ix_device_fingerprint_fingerprint_hash", "device_fingerprint", ["fingerprint_hash"])

    op.create_table(
        "ip_signal",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("ip_hash", sa.Text(), nullable=False),
        sa.Column("first_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
    )
    op.create_index("ix_ip_signal_ip_hash", "ip_signal", ["ip_hash"], unique=True)

    op.create_table(
        "session_signal",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("session_id_hash", sa.Text(), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("device_fingerprint_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("ip_hash", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_session_signal_session_id_hash", "session_signal", ["session_id_hash"])
    op.create_index("ix_session_signal_user_id", "session_signal", ["user_id"])
    op.create_index("ix_session_signal_device_fingerprint_id", "session_signal", ["device_fingerprint_id"])
    op.create_index("ix_session_signal_ip_hash", "session_signal", ["ip_hash"])

    op.create_table(
        "risk_profile",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("risk_score", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("risk_level", risk_level_enum, nullable=False, server_default="low"),
        sa.Column("reasons", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("flags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("last_calculated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_risk_profile_risk_level", "risk_profile", ["risk_level"])

    op.create_table(
        "risk_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("rule_id", sa.Text(), nullable=False),
        sa.Column("delta", sa.Integer(), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_risk_event_user_id", "risk_event", ["user_id"])
    op.create_index("ix_risk_event_rule_id", "risk_event", ["rule_id"])
    op.create_index("ix_risk_event_created_at", "risk_event", ["created_at"])

    op.create_table(
        "risk_action",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("action_type", risk_action_type_enum, nullable=False),
        sa.Column("status", risk_action_status_enum, nullable=False, server_default="active"),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("cleared_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_risk_action_user_id", "risk_action", ["user_id"])
    op.create_index("ix_risk_action_action_type", "risk_action", ["action_type"])
    op.create_index("ix_risk_action_status", "risk_action", ["status"])

    op.create_table(
        "risk_rule",
        sa.Column("id", sa.Text(), primary_key=True, nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("params", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("score_delta", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("action_on_trigger", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("risk_rule")

    op.drop_index("ix_risk_action_status", table_name="risk_action")
    op.drop_index("ix_risk_action_action_type", table_name="risk_action")
    op.drop_index("ix_risk_action_user_id", table_name="risk_action")
    op.drop_table("risk_action")

    op.drop_index("ix_risk_event_created_at", table_name="risk_event")
    op.drop_index("ix_risk_event_rule_id", table_name="risk_event")
    op.drop_index("ix_risk_event_user_id", table_name="risk_event")
    op.drop_table("risk_event")

    op.drop_index("ix_risk_profile_risk_level", table_name="risk_profile")
    op.drop_table("risk_profile")

    op.drop_index("ix_session_signal_ip_hash", table_name="session_signal")
    op.drop_index("ix_session_signal_device_fingerprint_id", table_name="session_signal")
    op.drop_index("ix_session_signal_user_id", table_name="session_signal")
    op.drop_index("ix_session_signal_session_id_hash", table_name="session_signal")
    op.drop_table("session_signal")

    op.drop_index("ix_ip_signal_ip_hash", table_name="ip_signal")
    op.drop_table("ip_signal")

    op.drop_index("ix_device_fingerprint_fingerprint_hash", table_name="device_fingerprint")
    op.drop_index("ix_device_fingerprint_user_id", table_name="device_fingerprint")
    op.drop_table("device_fingerprint")

    risk_action_status_enum.drop(op.get_bind(), checkfirst=True)
    risk_action_type_enum.drop(op.get_bind(), checkfirst=True)
    risk_level_enum.drop(op.get_bind(), checkfirst=True)
