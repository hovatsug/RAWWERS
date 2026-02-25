"""gamification v0: credentials milestones cycles

Revision ID: 20260225_0013
Revises: 20260225_0012
Create Date: 2026-02-25 23:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0013"
down_revision: Union[str, Sequence[str], None] = "20260225_0012"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


credential_mode_enum = sa.Enum("current", "highest_ever", name="credential_mode", native_enum=False)
milestone_scope_enum = sa.Enum("global", "niche", name="milestone_scope", native_enum=False)
milestone_difficulty_enum = sa.Enum("standard", "advanced", "elite", name="milestone_difficulty", native_enum=False)
milestone_progress_status_enum = sa.Enum("active", "completed", "expired", name="milestone_progress_status", native_enum=False)
skill_tier_enum = sa.Enum("rookie", "skilled", "pro", "elite", "master", name="skill_tier", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "pro_credential",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("credential_code", sa.Text(), nullable=False),
        sa.Column("display_name", sa.Text(), nullable=False),
        sa.Column("tier", skill_tier_enum, nullable=False),
        sa.Column("mode", credential_mode_enum, nullable=False, server_default="highest_ever"),
        sa.Column("awarded_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.UniqueConstraint("pro_user_id", "niche_id", "tier", "mode", name="uq_pro_credential_user_niche_tier_mode"),
    )
    op.create_index("ix_pro_credential_pro_user_id", "pro_credential", ["pro_user_id"])
    op.create_index("ix_pro_credential_niche_id", "pro_credential", ["niche_id"])

    op.create_table(
        "milestone",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code", sa.Text(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("scope", milestone_scope_enum, nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=True),
        sa.Column("difficulty", milestone_difficulty_enum, nullable=False),
        sa.Column("is_repeatable", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("cooldown_days", sa.Integer(), nullable=True),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("criteria", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column("reward_rule_code", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_milestone_code", "milestone", ["code"], unique=True)
    op.create_index("ix_milestone_niche_id", "milestone", ["niche_id"])

    op.create_table(
        "milestone_progress",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("milestone_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("milestone.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", milestone_progress_status_enum, nullable=False, server_default="active"),
        sa.Column("progress_value", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("progress_meta", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_evaluated_at", sa.DateTime(timezone=True), nullable=True),
        sa.UniqueConstraint("milestone_id", "user_id", name="uq_milestone_progress_milestone_user"),
    )
    op.create_index("ix_milestone_progress_milestone_id", "milestone_progress", ["milestone_id"])
    op.create_index("ix_milestone_progress_user_id", "milestone_progress", ["user_id"])

    op.create_table(
        "milestone_completion",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("milestone_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("milestone.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("reward_ledger_entry_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
    )
    op.create_index("ix_milestone_completion_milestone_id", "milestone_completion", ["milestone_id"])
    op.create_index("ix_milestone_completion_user_id", "milestone_completion", ["user_id"])

    op.create_table(
        "performance_cycle",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code", sa.Text(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_performance_cycle_code", "performance_cycle", ["code"], unique=True)

    op.create_table(
        "cycle_points",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("cycle_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("performance_cycle.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("points", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("cycle_id", "user_id", name="uq_cycle_points_cycle_user"),
    )
    op.create_index("ix_cycle_points_cycle_id", "cycle_points", ["cycle_id"])
    op.create_index("ix_cycle_points_user_id", "cycle_points", ["user_id"])

    op.create_table(
        "cycle_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("cycle_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("performance_cycle.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("event_type", sa.Text(), nullable=False),
        sa.Column("points_delta", sa.Integer(), nullable=False),
        sa.Column("reference_type", sa.Text(), nullable=True),
        sa.Column("reference_id", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_cycle_event_cycle_id", "cycle_event", ["cycle_id"])
    op.create_index("ix_cycle_event_user_id", "cycle_event", ["user_id"])
    op.create_index("ix_cycle_event_created_at", "cycle_event", ["created_at"])
    op.create_index("ix_cycle_event_cycle_created", "cycle_event", ["cycle_id", sa.text("created_at DESC")])


def downgrade() -> None:
    op.drop_index("ix_cycle_event_cycle_created", table_name="cycle_event")
    op.drop_index("ix_cycle_event_created_at", table_name="cycle_event")
    op.drop_index("ix_cycle_event_user_id", table_name="cycle_event")
    op.drop_index("ix_cycle_event_cycle_id", table_name="cycle_event")
    op.drop_table("cycle_event")

    op.drop_index("ix_cycle_points_user_id", table_name="cycle_points")
    op.drop_index("ix_cycle_points_cycle_id", table_name="cycle_points")
    op.drop_table("cycle_points")

    op.drop_index("ix_performance_cycle_code", table_name="performance_cycle")
    op.drop_table("performance_cycle")

    op.drop_index("ix_milestone_completion_user_id", table_name="milestone_completion")
    op.drop_index("ix_milestone_completion_milestone_id", table_name="milestone_completion")
    op.drop_table("milestone_completion")

    op.drop_index("ix_milestone_progress_user_id", table_name="milestone_progress")
    op.drop_index("ix_milestone_progress_milestone_id", table_name="milestone_progress")
    op.drop_table("milestone_progress")

    op.drop_index("ix_milestone_niche_id", table_name="milestone")
    op.drop_index("ix_milestone_code", table_name="milestone")
    op.drop_table("milestone")

    op.drop_index("ix_pro_credential_niche_id", table_name="pro_credential")
    op.drop_index("ix_pro_credential_pro_user_id", table_name="pro_credential")
    op.drop_table("pro_credential")
