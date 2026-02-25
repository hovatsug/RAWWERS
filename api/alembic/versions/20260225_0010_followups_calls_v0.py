"""followups notifications and calling agent v0

Revision ID: 20260225_0010
Revises: 20260225_0009
Create Date: 2026-02-25 13:00:00.000000
"""

from __future__ import annotations

import uuid
from datetime import datetime, time, timezone
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0010"
down_revision: Union[str, Sequence[str], None] = "20260225_0009"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


consent_channel_enum = sa.Enum("sms", "email", "phone_call", name="consent_channel", native_enum=False)
consent_scope_enum = sa.Enum("transactional", "marketing", name="consent_scope", native_enum=False)
followup_channel_enum = sa.Enum("in_app", "email", "sms", "phone_call", name="followup_channel", native_enum=False)
followup_job_status_enum = sa.Enum(
    "scheduled",
    "running",
    "sent",
    "skipped",
    "failed",
    "cancelled",
    name="followup_job_status",
    native_enum=False,
)
call_direction_enum = sa.Enum("outbound", name="call_direction", native_enum=False)
call_purpose_enum = sa.Enum(
    "booking_confirmation",
    "payment_nudge",
    "request_nudge",
    "reschedule",
    name="call_purpose",
    native_enum=False,
)
call_session_status_enum = sa.Enum(
    "queued",
    "dialing",
    "in_progress",
    "completed",
    "failed",
    "cancelled",
    name="call_session_status",
    native_enum=False,
)
call_outcome_enum = sa.Enum(
    "connected",
    "no_answer",
    "busy",
    "failed",
    "voicemail",
    "cancelled",
    "unknown",
    name="call_outcome",
    native_enum=False,
)
notification_status_enum = sa.Enum("unread", "read", name="notification_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "user_contact",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("phone_e164", sa.Text(), nullable=True),
        sa.Column("timezone", sa.Text(), nullable=False, server_default="Europe/Lisbon"),
        sa.Column("quiet_hours_start", sa.Time(), nullable=False, server_default="22:00:00"),
        sa.Column("quiet_hours_end", sa.Time(), nullable=False, server_default="08:00:00"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_user_contact_phone_e164", "user_contact", ["phone_e164"])

    op.create_table(
        "contact_consent",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("channel", consent_channel_enum, nullable=False),
        sa.Column("scope", consent_scope_enum, nullable=False),
        sa.Column("granted", sa.Boolean(), nullable=False),
        sa.Column("granted_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("source", sa.Text(), nullable=False),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_contact_consent_user_id", "contact_consent", ["user_id"])

    op.create_table(
        "followup_rule",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code", sa.Text(), nullable=False),
        sa.Column("is_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("trigger", sa.Text(), nullable=False),
        sa.Column("delay_minutes", sa.Integer(), nullable=False),
        sa.Column("channel", followup_channel_enum, nullable=False),
        sa.Column("max_attempts", sa.Integer(), nullable=False, server_default="2"),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_followup_rule_code", "followup_rule", ["code"], unique=True)

    op.create_table(
        "followup_job",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("rule_code", sa.Text(), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("target_type", sa.Text(), nullable=False),
        sa.Column("target_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("scheduled_for", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", followup_job_status_enum, nullable=False, server_default="scheduled"),
        sa.Column("attempt", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_error", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint(
            "rule_code",
            "user_id",
            "target_type",
            "target_id",
            "scheduled_for",
            name="uq_followup_job_unique",
        ),
    )
    op.create_index("ix_followup_job_rule_code", "followup_job", ["rule_code"])
    op.create_index("ix_followup_job_user_id", "followup_job", ["user_id"])
    op.create_index("ix_followup_job_target_id", "followup_job", ["target_id"])
    op.create_index("ix_followup_job_scheduled_for", "followup_job", ["scheduled_for"])
    op.create_index("ix_followup_job_user_scheduled", "followup_job", ["user_id", "scheduled_for"])

    op.create_table(
        "call_session",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("provider", sa.Text(), nullable=False),
        sa.Column("direction", call_direction_enum, nullable=False, server_default="outbound"),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("recipient_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("recipient_phone_e164", sa.Text(), nullable=False),
        sa.Column("purpose", call_purpose_enum, nullable=False),
        sa.Column("status", call_session_status_enum, nullable=False, server_default="queued"),
        sa.Column("provider_call_id", sa.Text(), nullable=True, unique=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("ended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("outcome", call_outcome_enum, nullable=False, server_default="unknown"),
        sa.Column("transcript", sa.Text(), nullable=True),
        sa.Column("summary", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_call_session_pro_user_id", "call_session", ["pro_user_id"])
    op.create_index("ix_call_session_recipient_user_id", "call_session", ["recipient_user_id"])
    op.create_index("ix_call_session_recipient_created", "call_session", ["recipient_user_id", sa.text("created_at DESC")])

    op.create_table(
        "call_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("call_session_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("call_session.id"), nullable=False),
        sa.Column("event_type", sa.Text(), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_call_event_call_session_id", "call_event", ["call_session_id"])

    op.create_table(
        "notification",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("body", sa.Text(), nullable=False),
        sa.Column("deep_link", sa.Text(), nullable=True),
        sa.Column("status", notification_status_enum, nullable=False, server_default="unread"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_notification_user_id", "notification", ["user_id"])

    followup_rule_table = sa.table(
        "followup_rule",
        sa.column("id", postgresql.UUID(as_uuid=True)),
        sa.column("code", sa.Text()),
        sa.column("is_enabled", sa.Boolean()),
        sa.column("trigger", sa.Text()),
        sa.column("delay_minutes", sa.Integer()),
        sa.column("channel", followup_channel_enum),
        sa.column("max_attempts", sa.Integer()),
        sa.column("metadata", postgresql.JSONB(astext_type=sa.Text())),
        sa.column("created_at", sa.DateTime(timezone=True)),
        sa.column("updated_at", sa.DateTime(timezone=True)),
    )
    now = datetime.now(timezone.utc)
    op.bulk_insert(
        followup_rule_table,
        [
            {
                "id": uuid.uuid4(),
                "code": "booking_request_pending_2h",
                "is_enabled": True,
                "trigger": "booking_request.pending.client",
                "delay_minutes": 120,
                "channel": "in_app",
                "max_attempts": 2,
                "metadata": {"title": "Booking request pending", "body": "Your request is still pending. You can message the photographer."},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "pro_response_lag_60m",
                "is_enabled": True,
                "trigger": "booking_request.pending.pro",
                "delay_minutes": 60,
                "channel": "in_app",
                "max_attempts": 2,
                "metadata": {"title": "Pending booking request", "body": "A client is waiting for your response."},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "payment_pending_1h",
                "is_enabled": True,
                "trigger": "payment_pending.client",
                "delay_minutes": 60,
                "channel": "in_app",
                "max_attempts": 2,
                "metadata": {"title": "Complete payment", "body": "Your booking is waiting for payment."},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "payment_pending_24h",
                "is_enabled": True,
                "trigger": "payment_pending.client",
                "delay_minutes": 1440,
                "channel": "in_app",
                "max_attempts": 1,
                "metadata": {"title": "Payment reminder", "body": "Your booking payment is still pending."},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "proof_selection_24h",
                "is_enabled": True,
                "trigger": "proof_gallery.published.client",
                "delay_minutes": 1440,
                "channel": "in_app",
                "max_attempts": 2,
                "metadata": {"title": "Select your photos", "body": "Your proof gallery is ready for selection."},
                "created_at": now,
                "updated_at": now,
            },
            {
                "id": uuid.uuid4(),
                "code": "booking_confirmation_30m",
                "is_enabled": True,
                "trigger": "booking_request.accepted.client",
                "delay_minutes": 30,
                "channel": "in_app",
                "max_attempts": 1,
                "metadata": {"title": "Booking accepted", "body": "Your booking request was accepted. Complete payment to confirm."},
                "created_at": now,
                "updated_at": now,
            },
        ],
    )


def downgrade() -> None:
    op.drop_index("ix_notification_user_id", table_name="notification")
    op.drop_table("notification")

    op.drop_index("ix_call_event_call_session_id", table_name="call_event")
    op.drop_table("call_event")

    op.drop_index("ix_call_session_recipient_created", table_name="call_session")
    op.drop_index("ix_call_session_recipient_user_id", table_name="call_session")
    op.drop_index("ix_call_session_pro_user_id", table_name="call_session")
    op.drop_table("call_session")

    op.drop_index("ix_followup_job_user_scheduled", table_name="followup_job")
    op.drop_index("ix_followup_job_scheduled_for", table_name="followup_job")
    op.drop_index("ix_followup_job_target_id", table_name="followup_job")
    op.drop_index("ix_followup_job_user_id", table_name="followup_job")
    op.drop_index("ix_followup_job_rule_code", table_name="followup_job")
    op.drop_table("followup_job")

    op.drop_index("ix_followup_rule_code", table_name="followup_rule")
    op.drop_table("followup_rule")

    op.drop_index("ix_contact_consent_user_id", table_name="contact_consent")
    op.drop_table("contact_consent")

    op.drop_index("ix_user_contact_phone_e164", table_name="user_contact")
    op.drop_table("user_contact")
