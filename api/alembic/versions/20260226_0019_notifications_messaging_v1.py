"""notifications + messaging v1

Revision ID: 20260226_0019
Revises: 20260226_0018
Create Date: 2026-02-26 18:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260226_0019"
down_revision: Union[str, Sequence[str], None] = "20260226_0018"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

notification_severity_enum = sa.Enum("info", "important", "critical", name="notification_severity", native_enum=False)
notification_digest_mode_enum = sa.Enum("instant", "daily", "weekly", name="notification_digest_mode", native_enum=False)
email_message_status_enum = sa.Enum("queued", "sent", "failed", name="email_message_status", native_enum=False)
notification_event_channel_enum = sa.Enum("inapp", "email", name="notification_event_channel", native_enum=False)
scheduled_notification_channel_enum = sa.Enum("inapp", "email", name="scheduled_notification_channel", native_enum=False)


def upgrade() -> None:
    op.add_column("notification", sa.Column("topic", sa.Text(), nullable=False, server_default="general"))
    op.add_column("notification", sa.Column("type", sa.Text(), nullable=False, server_default="generic"))
    op.add_column("notification", sa.Column("action", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))
    op.add_column("notification", sa.Column("severity", notification_severity_enum, nullable=False, server_default="info"))
    op.add_column("notification", sa.Column("read_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("notification", sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))

    op.create_index("ix_notification_topic", "notification", ["topic"])
    op.create_index("ix_notification_type", "notification", ["type"])
    op.create_index("ix_notification_created_at", "notification", ["created_at"])
    op.create_index("ix_notification_user_created", "notification", ["user_id", "created_at"])
    op.create_index("ix_notification_user_read", "notification", ["user_id", "read_at"])

    op.create_table(
        "notification_preference",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), primary_key=True, nullable=False),
        sa.Column("timezone", sa.Text(), nullable=False, server_default="Europe/Lisbon"),
        sa.Column("quiet_hours_enabled", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("quiet_start_local", sa.Time(), nullable=True),
        sa.Column("quiet_end_local", sa.Time(), nullable=True),
        sa.Column("channel_email_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("channel_inapp_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("digest_mode", notification_digest_mode_enum, nullable=False, server_default="instant"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "notification_topic_preference",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("topic", sa.Text(), nullable=False),
        sa.Column("email_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("inapp_enabled", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("user_id", "topic", name="uq_notification_topic_preference_user_topic"),
    )
    op.create_index("ix_notification_topic_preference_user_id", "notification_topic_preference", ["user_id"])
    op.create_index("ix_notification_topic_preference_topic", "notification_topic_preference", ["topic"])

    op.create_table(
        "email_message",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=True),
        sa.Column("to_email", sa.Text(), nullable=False),
        sa.Column("template_key", sa.Text(), nullable=False),
        sa.Column("subject", sa.Text(), nullable=False),
        sa.Column("provider", sa.Text(), nullable=True),
        sa.Column("provider_message_id", sa.Text(), nullable=True),
        sa.Column("status", email_message_status_enum, nullable=False, server_default="queued"),
        sa.Column("error", sa.Text(), nullable=True),
        sa.Column("dedupe_key", sa.Text(), nullable=False),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("dedupe_key", name="uq_email_message_dedupe_key"),
    )
    op.create_index("ix_email_message_user_id", "email_message", ["user_id"])
    op.create_index("ix_email_message_template_key", "email_message", ["template_key"])
    op.create_index("ix_email_message_dedupe_key", "email_message", ["dedupe_key"])

    op.create_table(
        "notification_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("topic", sa.Text(), nullable=False),
        sa.Column("type", sa.Text(), nullable=False),
        sa.Column("channel", notification_event_channel_enum, nullable=False),
        sa.Column("reference_type", sa.Text(), nullable=True),
        sa.Column("reference_id", sa.Text(), nullable=True),
        sa.Column("dedupe_key", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("channel", "dedupe_key", name="uq_notification_event_channel_dedupe"),
    )
    op.create_index("ix_notification_event_user_id", "notification_event", ["user_id"])
    op.create_index("ix_notification_event_dedupe_key", "notification_event", ["dedupe_key"])
    op.create_index("ix_notification_event_user_created", "notification_event", ["user_id", "created_at"])

    op.create_table(
        "scheduled_notification",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("channel", scheduled_notification_channel_enum, nullable=False, server_default="email"),
        sa.Column("send_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("dedupe_key", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("dedupe_key", name="uq_scheduled_notification_dedupe_key"),
    )
    op.create_index("ix_scheduled_notification_send_at", "scheduled_notification", ["send_at"])


def downgrade() -> None:
    op.drop_index("ix_scheduled_notification_send_at", table_name="scheduled_notification")
    op.drop_table("scheduled_notification")

    op.drop_index("ix_notification_event_user_created", table_name="notification_event")
    op.drop_index("ix_notification_event_dedupe_key", table_name="notification_event")
    op.drop_index("ix_notification_event_user_id", table_name="notification_event")
    op.drop_table("notification_event")

    op.drop_index("ix_email_message_dedupe_key", table_name="email_message")
    op.drop_index("ix_email_message_template_key", table_name="email_message")
    op.drop_index("ix_email_message_user_id", table_name="email_message")
    op.drop_table("email_message")

    op.drop_index("ix_notification_topic_preference_topic", table_name="notification_topic_preference")
    op.drop_index("ix_notification_topic_preference_user_id", table_name="notification_topic_preference")
    op.drop_table("notification_topic_preference")

    op.drop_table("notification_preference")

    op.drop_index("ix_notification_user_read", table_name="notification")
    op.drop_index("ix_notification_user_created", table_name="notification")
    op.drop_index("ix_notification_created_at", table_name="notification")
    op.drop_index("ix_notification_type", table_name="notification")
    op.drop_index("ix_notification_topic", table_name="notification")

    op.drop_column("notification", "metadata")
    op.drop_column("notification", "read_at")
    op.drop_column("notification", "severity")
    op.drop_column("notification", "action")
    op.drop_column("notification", "type")
    op.drop_column("notification", "topic")
