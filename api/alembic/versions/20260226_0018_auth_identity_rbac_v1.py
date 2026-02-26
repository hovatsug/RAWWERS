"""auth + identity + rbac v1

Revision ID: 20260226_0018
Revises: 20260225_0017
Create Date: 2026-02-26 14:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260226_0018"
down_revision: Union[str, Sequence[str], None] = "20260225_0017"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

user_account_status_enum = sa.Enum("active", "disabled", "deleted", name="user_account_status", native_enum=False)


def upgrade() -> None:
    op.add_column("user_account", sa.Column("phone_e164", sa.Text(), nullable=True))
    op.add_column("user_account", sa.Column("password_hash", sa.Text(), nullable=True))
    op.add_column("user_account", sa.Column("status", user_account_status_enum, nullable=False, server_default="active"))
    op.add_column("user_account", sa.Column("email_verified_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("user_account", sa.Column("last_login_at", sa.DateTime(timezone=True), nullable=True))

    op.create_index("ix_user_account_email", "user_account", ["email"], unique=True)
    op.create_index("ix_user_account_phone_e164", "user_account", ["phone_e164"], unique=True)
    op.create_index("ix_user_account_status", "user_account", ["status"])

    op.create_table(
        "session_refresh_token",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("token_hash", sa.Text(), nullable=False, unique=True),
        sa.Column("family_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("issued_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("replaced_by_token_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("session_refresh_token.id"), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("ip_hash", sa.Text(), nullable=True),
    )
    op.create_index("ix_session_refresh_token_user_id", "session_refresh_token", ["user_id"])
    op.create_index("ix_session_refresh_token_family_id", "session_refresh_token", ["family_id"])
    op.create_index("ix_session_refresh_token_user_family", "session_refresh_token", ["user_id", "family_id"])

    op.create_table(
        "email_verification",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("code_hash", sa.Text(), nullable=False, unique=True),
        sa.Column("sent_to_email", sa.Text(), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_email_verification_user_id", "email_verification", ["user_id"])

    op.create_table(
        "password_reset",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("code_hash", sa.Text(), nullable=False, unique=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_password_reset_user_id", "password_reset", ["user_id"])

    op.create_table(
        "auth_event_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=True),
        sa.Column("event_type", sa.Text(), nullable=False),
        sa.Column("ip_hash", sa.Text(), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("request_id", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_auth_event_log_user_id", "auth_event_log", ["user_id"])
    op.create_index("ix_auth_event_log_event_type", "auth_event_log", ["event_type"])
    op.create_index("ix_auth_event_log_created_at", "auth_event_log", ["created_at"])

    op.create_table(
        "impersonation_session",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("admin_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("target_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("request_id", sa.Text(), nullable=True),
    )
    op.create_index("ix_impersonation_session_admin_user_id", "impersonation_session", ["admin_user_id"])
    op.create_index("ix_impersonation_session_target_user_id", "impersonation_session", ["target_user_id"])
    op.create_index("ix_impersonation_session_admin_started", "impersonation_session", ["admin_user_id", "started_at"])


def downgrade() -> None:
    op.drop_index("ix_impersonation_session_admin_started", table_name="impersonation_session")
    op.drop_index("ix_impersonation_session_target_user_id", table_name="impersonation_session")
    op.drop_index("ix_impersonation_session_admin_user_id", table_name="impersonation_session")
    op.drop_table("impersonation_session")

    op.drop_index("ix_auth_event_log_created_at", table_name="auth_event_log")
    op.drop_index("ix_auth_event_log_event_type", table_name="auth_event_log")
    op.drop_index("ix_auth_event_log_user_id", table_name="auth_event_log")
    op.drop_table("auth_event_log")

    op.drop_index("ix_password_reset_user_id", table_name="password_reset")
    op.drop_table("password_reset")

    op.drop_index("ix_email_verification_user_id", table_name="email_verification")
    op.drop_table("email_verification")

    op.drop_index("ix_session_refresh_token_user_family", table_name="session_refresh_token")
    op.drop_index("ix_session_refresh_token_family_id", table_name="session_refresh_token")
    op.drop_index("ix_session_refresh_token_user_id", table_name="session_refresh_token")
    op.drop_table("session_refresh_token")

    op.drop_index("ix_user_account_status", table_name="user_account")
    op.drop_index("ix_user_account_phone_e164", table_name="user_account")
    op.drop_index("ix_user_account_email", table_name="user_account")

    op.drop_column("user_account", "last_login_at")
    op.drop_column("user_account", "email_verified_at")
    op.drop_column("user_account", "status")
    op.drop_column("user_account", "password_hash")
    op.drop_column("user_account", "phone_e164")
