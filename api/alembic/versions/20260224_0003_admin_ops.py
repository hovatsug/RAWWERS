"""admin ops, kyc, bans, disputes, refund cases

Revision ID: 20260224_0003
Revises: 20260224_0002
Create Date: 2026-02-24 22:20:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260224_0003"
down_revision: Union[str, Sequence[str], None] = "20260224_0002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


user_role_type_enum = sa.Enum("admin", "pro", "client", name="user_role_type", native_enum=False)
kyc_status_enum = sa.Enum("unsubmitted", "pending", "approved", "rejected", name="kyc_status", native_enum=False)
ban_action_type_enum = sa.Enum("none", "warning", "suspended", "banned", name="ban_action_type", native_enum=False)
dispute_status_enum = sa.Enum(
    "open",
    "under_review",
    "resolved_refund",
    "resolved_no_refund",
    "resolved_partial_refund",
    "closed",
    name="dispute_status",
    native_enum=False,
)
dispute_category_enum = sa.Enum(
    "quality",
    "no_show",
    "late_delivery",
    "harassment",
    "payment",
    "other",
    name="dispute_category",
    native_enum=False,
)
evidence_kind_enum = sa.Enum("text", "media", name="evidence_kind", native_enum=False)
refund_case_status_enum = sa.Enum(
    "requested",
    "approved",
    "rejected",
    "processing",
    "succeeded",
    "failed",
    name="refund_case_status",
    native_enum=False,
)


def upgrade() -> None:
    op.create_table(
        "user_account",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("email", sa.Text(), nullable=True),
        sa.Column("display_name", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "user_role",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("role", user_role_type_enum, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("user_id", "role", name="uq_user_role_user_role"),
    )
    op.create_index("ix_user_role_user_id", "user_role", ["user_id"])

    op.create_table(
        "pro_profile",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), primary_key=True, nullable=False),
        sa.Column("kyc_status", kyc_status_enum, nullable=False, server_default="unsubmitted"),
        sa.Column("kyc_note", sa.Text(), nullable=True),
        sa.Column("kyc_updated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.create_table(
        "ban_action",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("action", ban_action_type_enum, nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("starts_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("ends_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_ban_action_user_id", "ban_action", ["user_id"])
    op.create_index("ix_ban_action_user_created", "ban_action", ["user_id", sa.text("created_at DESC")])

    op.create_table(
        "admin_audit_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("target_type", sa.Text(), nullable=False),
        sa.Column("target_id", sa.Text(), nullable=False),
        sa.Column("action", sa.Text(), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_admin_audit_log_actor_user_id", "admin_audit_log", ["actor_user_id"])

    op.create_table(
        "dispute",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("opened_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", dispute_status_enum, nullable=False),
        sa.Column("category", dispute_category_enum, nullable=False),
        sa.Column("summary", sa.Text(), nullable=False),
        sa.Column("resolution_note", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_dispute_gig_id", "dispute", ["gig_id"])
    op.create_index("ix_dispute_opened_by_user_id", "dispute", ["opened_by_user_id"])

    op.create_table(
        "dispute_evidence",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("dispute_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("dispute.id"), nullable=False),
        sa.Column("submitted_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("kind", evidence_kind_enum, nullable=False),
        sa.Column("text", sa.Text(), nullable=True),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_dispute_evidence_dispute_id", "dispute_evidence", ["dispute_id"])

    op.create_table(
        "refund_case",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("dispute_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("dispute.id"), nullable=True),
        sa.Column("requested_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", refund_case_status_enum, nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("admin_note", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_refund_case_gig_id", "refund_case", ["gig_id"])


def downgrade() -> None:
    op.drop_index("ix_refund_case_gig_id", table_name="refund_case")
    op.drop_table("refund_case")

    op.drop_index("ix_dispute_evidence_dispute_id", table_name="dispute_evidence")
    op.drop_table("dispute_evidence")

    op.drop_index("ix_dispute_opened_by_user_id", table_name="dispute")
    op.drop_index("ix_dispute_gig_id", table_name="dispute")
    op.drop_table("dispute")

    op.drop_index("ix_admin_audit_log_actor_user_id", table_name="admin_audit_log")
    op.drop_table("admin_audit_log")

    op.drop_index("ix_ban_action_user_created", table_name="ban_action")
    op.drop_index("ix_ban_action_user_id", table_name="ban_action")
    op.drop_table("ban_action")

    op.drop_table("pro_profile")

    op.drop_index("ix_user_role_user_id", table_name="user_role")
    op.drop_table("user_role")

    op.drop_table("user_account")
