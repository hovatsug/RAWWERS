"""multi-region outbox + idempotency

Revision ID: 20260225_0016
Revises: 20260225_0015
Create Date: 2026-02-26 01:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0016"
down_revision: Union[str, Sequence[str], None] = "20260225_0015"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


outbox_event_status_enum = sa.Enum("pending", "processing", "delivered", "failed", name="outbox_event_status", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "outbox_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("topic", sa.Text(), nullable=False),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("status", outbox_event_status_enum, nullable=False, server_default="pending"),
        sa.Column("attempts", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("next_attempt_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_outbox_event_topic", "outbox_event", ["topic"])
    op.create_index("ix_outbox_event_status", "outbox_event", ["status"])
    op.create_index("ix_outbox_event_next_attempt_at", "outbox_event", ["next_attempt_at"])

    op.create_table(
        "idempotency_key",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("key", sa.Text(), nullable=False),
        sa.Column("scope", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
    )
    op.create_index("ix_idempotency_key_key", "idempotency_key", ["key"], unique=True)
    op.create_index("ix_idempotency_key_scope", "idempotency_key", ["scope"])


def downgrade() -> None:
    op.drop_index("ix_idempotency_key_scope", table_name="idempotency_key")
    op.drop_index("ix_idempotency_key_key", table_name="idempotency_key")
    op.drop_table("idempotency_key")

    op.drop_index("ix_outbox_event_next_attempt_at", table_name="outbox_event")
    op.drop_index("ix_outbox_event_status", table_name="outbox_event")
    op.drop_index("ix_outbox_event_topic", table_name="outbox_event")
    op.drop_table("outbox_event")
