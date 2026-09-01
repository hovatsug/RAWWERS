"""chat concierge v0

Revision ID: 20260225_0009
Revises: 20260225_0008
Create Date: 2026-02-25 11:30:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0009"
down_revision: Union[str, Sequence[str], None] = "20260225_0008"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


chat_thread_status_enum = sa.Enum("open", "pro_takeover", "closed", name="chat_thread_status", native_enum=False)
chat_sender_type_enum = sa.Enum("client", "ai", "pro", "system", name="chat_sender_type", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "platform_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("key", sa.Text(), nullable=False),
        sa.Column("value", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_platform_policy_key", "platform_policy", ["key"], unique=True)

    op.create_table(
        "chat_thread",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", chat_thread_status_enum, nullable=False, server_default="open"),
        sa.Column("context_snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("token_budget_used", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_chat_thread_pro_user_id", "chat_thread", ["pro_user_id"])
    op.create_index("ix_chat_thread_client_user_id", "chat_thread", ["client_user_id"])

    op.create_table(
        "chat_message",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("thread_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("chat_thread.id"), nullable=False),
        sa.Column("sender_type", chat_sender_type_enum, nullable=False),
        sa.Column("sender_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_chat_message_thread_id", "chat_message", ["thread_id"])
    op.create_index("ix_chat_message_created_at", "chat_message", ["created_at"])
    op.create_index("ix_chat_message_thread_created", "chat_message", ["thread_id", sa.text("created_at DESC")])

    op.create_table(
        "chat_handoff",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("thread_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("chat_thread.id"), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_chat_handoff_thread_id", "chat_handoff", ["thread_id"])


def downgrade() -> None:
    op.drop_index("ix_chat_handoff_thread_id", table_name="chat_handoff")
    op.drop_table("chat_handoff")

    op.drop_index("ix_chat_message_thread_created", table_name="chat_message")
    op.drop_index("ix_chat_message_created_at", table_name="chat_message")
    op.drop_index("ix_chat_message_thread_id", table_name="chat_message")
    op.drop_table("chat_message")

    op.drop_index("ix_chat_thread_client_user_id", table_name="chat_thread")
    op.drop_index("ix_chat_thread_pro_user_id", table_name="chat_thread")
    op.drop_table("chat_thread")

    op.drop_index("ix_platform_policy_key", table_name="platform_policy")
    op.drop_table("platform_policy")
