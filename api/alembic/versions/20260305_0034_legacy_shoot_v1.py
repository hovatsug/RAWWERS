"""legacy shoot v1

Revision ID: 20260305_0034
Revises: 20260305_0033
Create Date: 2026-03-05 20:15:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260305_0034"
down_revision: Union[str, Sequence[str], None] = "20260305_0033"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


legacy_booking_status = sa.Enum(
    "brief_pending",
    "brief_submitted",
    "pro_assigned",
    "scheduled",
    "shoot_done",
    "edit_in_progress",
    "client_review",
    "approved",
    "delivered",
    "cancelled",
    name="legacy_booking_status",
    native_enum=False,
)
legacy_payment_mode = sa.Enum("full", "deposit", name="legacy_payment_mode", native_enum=False)
legacy_tone = sa.Enum("cinematic", "documentary", "intimate", "heroic", "minimalist", name="legacy_tone", native_enum=False)
legacy_privacy_level = sa.Enum("private", "family_only", "public_opt_in", name="legacy_privacy_level", native_enum=False)
vault_item_type = sa.Enum(
    "photo_set",
    "storybook_pdf",
    "cinematic_video",
    "voice_audio",
    "notes",
    "other",
    name="vault_item_type",
    native_enum=False,
)
vault_item_status = sa.Enum("draft", "submitted", "approved", "rejected", "final", name="vault_item_status", native_enum=False)
vault_access_action = sa.Enum("view", "download", "upload", name="vault_access_action", native_enum=False)
legacy_review_stage = sa.Enum("edit_preview", "final_delivery", name="legacy_review_stage", native_enum=False)
legacy_review_response = sa.Enum("pending", "approved", "changes_requested", "rejected", name="legacy_review_response", native_enum=False)


def upgrade() -> None:
    legacy_booking_status.create(op.get_bind(), checkfirst=True)
    legacy_payment_mode.create(op.get_bind(), checkfirst=True)
    legacy_tone.create(op.get_bind(), checkfirst=True)
    legacy_privacy_level.create(op.get_bind(), checkfirst=True)
    vault_item_type.create(op.get_bind(), checkfirst=True)
    vault_item_status.create(op.get_bind(), checkfirst=True)
    vault_access_action.create(op.get_bind(), checkfirst=True)
    legacy_review_stage.create(op.get_bind(), checkfirst=True)
    legacy_review_response.create(op.get_bind(), checkfirst=True)

    op.create_table(
        "premium_product",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code", sa.Text(), nullable=False),
        sa.Column("name_key", sa.Text(), nullable=False),
        sa.Column("description_key", sa.Text(), nullable=False),
        sa.Column("base_price_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("deposit_price_eur", sa.Numeric(12, 2), nullable=True),
        sa.Column("duration_minutes", sa.Integer(), nullable=False, server_default="180"),
        sa.Column("eligibility_rules", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_premium_product_code", "premium_product", ["code"], unique=True)

    op.create_table(
        "legacy_booking",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("assigned_pro_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("status", legacy_booking_status, nullable=False, server_default="brief_pending"),
        sa.Column("price_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("payment_mode", legacy_payment_mode, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_legacy_booking_gig_id", "legacy_booking", ["gig_id"], unique=True)
    op.create_index("ix_legacy_booking_client_user_id", "legacy_booking", ["client_user_id"])
    op.create_index("ix_legacy_booking_assigned_pro_user_id", "legacy_booking", ["assigned_pro_user_id"])
    op.create_index("ix_legacy_booking_status", "legacy_booking", ["status"])

    op.create_table(
        "legacy_brief",
        sa.Column("legacy_booking_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("legacy_booking.id"), primary_key=True, nullable=False),
        sa.Column("answers", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("tone", legacy_tone, nullable=True),
        sa.Column("privacy_level", legacy_privacy_level, nullable=False, server_default="private"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "vault_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("legacy_booking_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("legacy_booking.id"), nullable=False),
        sa.Column("type", vault_item_type, nullable=False),
        sa.Column("storage_key", sa.Text(), nullable=False),
        sa.Column("content_type", sa.Text(), nullable=True),
        sa.Column("bytes", sa.BigInteger(), nullable=True),
        sa.Column("version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("status", vault_item_status, nullable=False, server_default="draft"),
        sa.Column("created_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_vault_item_legacy_booking_id", "vault_item", ["legacy_booking_id"])
    op.create_index("ix_vault_item_status", "vault_item", ["status"])

    op.create_table(
        "vault_access_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("legacy_booking_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("legacy_booking.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("action", vault_access_action, nullable=False),
        sa.Column("vault_item_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("vault_item.id"), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_vault_access_log_legacy_booking_id", "vault_access_log", ["legacy_booking_id"])
    op.create_index("ix_vault_access_log_user_id", "vault_access_log", ["user_id"])
    op.create_index("ix_vault_access_log_created_at", "vault_access_log", ["created_at"])

    op.create_table(
        "legacy_review",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("legacy_booking_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("legacy_booking.id"), nullable=False),
        sa.Column("stage", legacy_review_stage, nullable=False),
        sa.Column("submitted_by", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_response", legacy_review_response, nullable=False, server_default="pending"),
        sa.Column("client_notes", sa.Text(), nullable=True),
        sa.Column("item_ids", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_legacy_review_legacy_booking_id", "legacy_review", ["legacy_booking_id"])
    op.create_index("ix_legacy_review_submitted_by", "legacy_review", ["submitted_by"])

    op.create_table(
        "legacy_marketing_consent",
        sa.Column("legacy_booking_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("legacy_booking.id"), primary_key=True, nullable=False),
        sa.Column("consent", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("channels", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("legacy_marketing_consent")

    op.drop_index("ix_legacy_review_submitted_by", table_name="legacy_review")
    op.drop_index("ix_legacy_review_legacy_booking_id", table_name="legacy_review")
    op.drop_table("legacy_review")

    op.drop_index("ix_vault_access_log_created_at", table_name="vault_access_log")
    op.drop_index("ix_vault_access_log_user_id", table_name="vault_access_log")
    op.drop_index("ix_vault_access_log_legacy_booking_id", table_name="vault_access_log")
    op.drop_table("vault_access_log")

    op.drop_index("ix_vault_item_status", table_name="vault_item")
    op.drop_index("ix_vault_item_legacy_booking_id", table_name="vault_item")
    op.drop_table("vault_item")

    op.drop_table("legacy_brief")

    op.drop_index("ix_legacy_booking_status", table_name="legacy_booking")
    op.drop_index("ix_legacy_booking_assigned_pro_user_id", table_name="legacy_booking")
    op.drop_index("ix_legacy_booking_client_user_id", table_name="legacy_booking")
    op.drop_index("ix_legacy_booking_gig_id", table_name="legacy_booking")
    op.drop_table("legacy_booking")

    op.drop_index("ix_premium_product_code", table_name="premium_product")
    op.drop_table("premium_product")

    legacy_review_response.drop(op.get_bind(), checkfirst=True)
    legacy_review_stage.drop(op.get_bind(), checkfirst=True)
    vault_access_action.drop(op.get_bind(), checkfirst=True)
    vault_item_status.drop(op.get_bind(), checkfirst=True)
    vault_item_type.drop(op.get_bind(), checkfirst=True)
    legacy_privacy_level.drop(op.get_bind(), checkfirst=True)
    legacy_tone.drop(op.get_bind(), checkfirst=True)
    legacy_payment_mode.drop(op.get_bind(), checkfirst=True)
    legacy_booking_status.drop(op.get_bind(), checkfirst=True)
