"""observability + security hardening + abuse baseline

Revision ID: 20260225_0017
Revises: 20260225_0016
Create Date: 2026-02-26 10:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0017"
down_revision: Union[str, Sequence[str], None] = "20260225_0016"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

abuse_severity_enum = sa.Enum("low", "medium", "high", name="abuse_severity", native_enum=False)
abuse_signal_status_enum = sa.Enum("open", "resolved", "ignored", name="abuse_signal_status", native_enum=False)
feature_flag_scope_enum = sa.Enum("global", "user", "pro", "admin", name="feature_flag_scope", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "webhook_security_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("provider", sa.Text(), nullable=False),
        sa.Column("event_id", sa.Text(), nullable=True),
        sa.Column("signature_valid", sa.Boolean(), nullable=False),
        sa.Column("ip", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("received_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_webhook_security_log_provider", "webhook_security_log", ["provider"])
    op.create_index("ix_webhook_security_log_event_id", "webhook_security_log", ["event_id"])
    op.create_index("ix_webhook_security_log_received_at", "webhook_security_log", ["received_at"])

    op.create_table(
        "abuse_signal",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("ip_hash", sa.Text(), nullable=True),
        sa.Column("signal_type", sa.Text(), nullable=False),
        sa.Column("severity", abuse_severity_enum, nullable=False, server_default="low"),
        sa.Column("evidence", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("status", abuse_signal_status_enum, nullable=False, server_default="open"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_abuse_signal_user_id", "abuse_signal", ["user_id"])
    op.create_index("ix_abuse_signal_ip_hash", "abuse_signal", ["ip_hash"])
    op.create_index("ix_abuse_signal_signal_type", "abuse_signal", ["signal_type"])
    op.create_index("ix_abuse_signal_severity", "abuse_signal", ["severity"])
    op.create_index("ix_abuse_signal_status", "abuse_signal", ["status"])
    op.create_index("ix_abuse_signal_created_at", "abuse_signal", ["created_at"])
    op.create_index("ix_abuse_signal_type_status", "abuse_signal", ["signal_type", "status"])

    op.create_table(
        "feature_flag",
        sa.Column("key", sa.Text(), primary_key=True, nullable=False),
        sa.Column("is_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("scope", feature_flag_scope_enum, nullable=False, server_default="global"),
        sa.Column("rules", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_table("feature_flag")

    op.drop_index("ix_abuse_signal_type_status", table_name="abuse_signal")
    op.drop_index("ix_abuse_signal_created_at", table_name="abuse_signal")
    op.drop_index("ix_abuse_signal_status", table_name="abuse_signal")
    op.drop_index("ix_abuse_signal_severity", table_name="abuse_signal")
    op.drop_index("ix_abuse_signal_signal_type", table_name="abuse_signal")
    op.drop_index("ix_abuse_signal_ip_hash", table_name="abuse_signal")
    op.drop_index("ix_abuse_signal_user_id", table_name="abuse_signal")
    op.drop_table("abuse_signal")

    op.drop_index("ix_webhook_security_log_received_at", table_name="webhook_security_log")
    op.drop_index("ix_webhook_security_log_event_id", table_name="webhook_security_log")
    op.drop_index("ix_webhook_security_log_provider", table_name="webhook_security_log")
    op.drop_table("webhook_security_log")
