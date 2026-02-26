"""comms sales engine v1

Revision ID: 20260226_0027
Revises: 20260226_0026
Create Date: 2026-02-26 15:20:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0027"
down_revision: Union[str, Sequence[str], None] = "20260226_0026"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


pro_ai_tone_enum = sa.Enum("premium", "friendly", "direct", name="pro_ai_tone", native_enum=False)


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        op.execute("ALTER TYPE chat_thread_status ADD VALUE IF NOT EXISTS 'pro_active'")

    op.alter_column("chat_thread", "client_user_id", existing_type=postgresql.UUID(as_uuid=True), nullable=True)
    op.add_column("chat_thread", sa.Column("session_id", sa.Text(), nullable=True))
    op.create_index("ix_chat_thread_session_id", "chat_thread", ["session_id"])
    if bind.dialect.name == "postgresql":
        op.execute(
            """
            CREATE UNIQUE INDEX IF NOT EXISTS uq_chat_thread_pro_client_auth
            ON chat_thread (pro_user_id, client_user_id)
            WHERE client_user_id IS NOT NULL
            """
        )

    op.add_column("chat_message", sa.Column("content_redacted", sa.Text(), nullable=True))

    op.create_table(
        "lead_profile",
        sa.Column("thread_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("chat_thread.id"), primary_key=True, nullable=False),
        sa.Column("niche_slug", sa.Text(), nullable=True),
        sa.Column("desired_date", sa.Date(), nullable=True),
        sa.Column("date_flex_days", sa.Integer(), nullable=True),
        sa.Column("location", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("budget_min", sa.Numeric(12, 2), nullable=True),
        sa.Column("budget_max", sa.Numeric(12, 2), nullable=True),
        sa.Column("style_tags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "pro_ai_profile",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("is_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("tone", pro_ai_tone_enum, nullable=False, server_default="premium"),
        sa.Column("faq", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("do_not_say", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("preferred_packages", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "ai_interaction_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("thread_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("chat_thread.id"), nullable=False),
        sa.Column("request_id", sa.Text(), nullable=False),
        sa.Column("model", sa.Text(), nullable=False),
        sa.Column("prompt_hash", sa.Text(), nullable=False),
        sa.Column("input_summary", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("output_summary", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("safety_flags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("tokens_in", sa.Integer(), nullable=True),
        sa.Column("tokens_out", sa.Integer(), nullable=True),
        sa.Column("latency_ms", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_ai_interaction_log_thread_id", "ai_interaction_log", ["thread_id"])
    op.create_index("ix_ai_interaction_log_request_id", "ai_interaction_log", ["request_id"])
    op.create_index("ix_ai_interaction_log_created_at", "ai_interaction_log", ["created_at"])


def downgrade() -> None:
    op.drop_index("ix_ai_interaction_log_created_at", table_name="ai_interaction_log")
    op.drop_index("ix_ai_interaction_log_request_id", table_name="ai_interaction_log")
    op.drop_index("ix_ai_interaction_log_thread_id", table_name="ai_interaction_log")
    op.drop_table("ai_interaction_log")
    op.drop_table("pro_ai_profile")
    op.drop_table("lead_profile")

    op.drop_column("chat_message", "content_redacted")
    op.drop_index("ix_chat_thread_session_id", table_name="chat_thread")
    op.drop_column("chat_thread", "session_id")
    op.alter_column("chat_thread", "client_user_id", existing_type=postgresql.UUID(as_uuid=True), nullable=False)

    pro_ai_tone_enum.drop(op.get_bind(), checkfirst=True)
