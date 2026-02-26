"""launch ops rollout invites onboarding

Revision ID: 20260226_0023
Revises: 20260226_0022
Create Date: 2026-02-26 06:10:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0023"
down_revision: Union[str, Sequence[str], None] = "20260226_0022"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


invite_allowed_role_enum = sa.Enum("pro", "client", "both", name="invite_allowed_role", native_enum=False)
invite_code_status_enum = sa.Enum("issued", "redeemed", "revoked", "expired", name="invite_code_status", native_enum=False)
pro_onboarding_status_enum = sa.Enum(
    "started",
    "profile_completed",
    "portfolio_uploaded",
    "packages_configured",
    "niches_selected",
    "kyc_submitted",
    "kyc_approved",
    "ready_for_review",
    "approved_public",
    "rejected",
    name="pro_onboarding_status",
    native_enum=False,
)
pro_onboarding_actor_type_enum = sa.Enum("pro", "admin", "system", name="pro_onboarding_actor_type", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "rollout_city",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("country", sa.Text(), nullable=False),
        sa.Column("city", sa.Text(), nullable=False),
        sa.Column("is_pro_onboarding_enabled", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("is_client_browsing_enabled", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("country", "city", name="uq_rollout_city_country_city"),
    )

    op.create_table(
        "rollout_flag_override",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False, unique=True),
        sa.Column("can_access_pro_onboarding", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("can_access_client_app", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("granted_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("granted_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_rollout_flag_override_user_id", "rollout_flag_override", ["user_id"])

    op.create_table(
        "invite_wave",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code_prefix", sa.Text(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("max_invites", sa.Integer(), nullable=False),
        sa.Column("used_invites", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("allowed_role", invite_allowed_role_enum, nullable=False, server_default="pro"),
        sa.Column("allowed_cities", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "invite_code",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("wave_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("invite_wave.id"), nullable=False),
        sa.Column("code", sa.Text(), nullable=False, unique=True),
        sa.Column("issued_to_email", sa.Text(), nullable=True),
        sa.Column("issued_by_admin_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("redeemed_by_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("redeemed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("status", invite_code_status_enum, nullable=False, server_default="issued"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_invite_code_wave_id", "invite_code", ["wave_id"])
    op.create_index("ix_invite_code_code", "invite_code", ["code"])

    op.create_table(
        "pro_onboarding",
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("status", pro_onboarding_status_enum, nullable=False, server_default="started"),
        sa.Column("current_city", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("invite_code_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("invite_code.id"), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "pro_onboarding_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("from_status", sa.Text(), nullable=True),
        sa.Column("to_status", sa.Text(), nullable=False),
        sa.Column("actor_type", pro_onboarding_actor_type_enum, nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_pro_onboarding_event_pro_user_id", "pro_onboarding_event", ["pro_user_id"])
    op.create_index("ix_pro_onboarding_event_created_at", "pro_onboarding_event", ["created_at"])

    op.create_table(
        "onboarding_requirement",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("key", sa.Text(), nullable=False, unique=True),
        sa.Column("value", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("onboarding_requirement")

    op.drop_index("ix_pro_onboarding_event_created_at", table_name="pro_onboarding_event")
    op.drop_index("ix_pro_onboarding_event_pro_user_id", table_name="pro_onboarding_event")
    op.drop_table("pro_onboarding_event")

    op.drop_table("pro_onboarding")

    op.drop_index("ix_invite_code_code", table_name="invite_code")
    op.drop_index("ix_invite_code_wave_id", table_name="invite_code")
    op.drop_table("invite_code")

    op.drop_table("invite_wave")

    op.drop_index("ix_rollout_flag_override_user_id", table_name="rollout_flag_override")
    op.drop_table("rollout_flag_override")

    op.drop_table("rollout_city")

    pro_onboarding_actor_type_enum.drop(op.get_bind(), checkfirst=True)
    pro_onboarding_status_enum.drop(op.get_bind(), checkfirst=True)
    invite_code_status_enum.drop(op.get_bind(), checkfirst=True)
    invite_allowed_role_enum.drop(op.get_bind(), checkfirst=True)
