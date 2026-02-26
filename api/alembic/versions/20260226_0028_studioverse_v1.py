"""studioverse v1

Revision ID: 20260226_0028
Revises: 20260226_0027
Create Date: 2026-02-26 17:30:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0028"
down_revision: Union[str, Sequence[str], None] = "20260226_0027"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


content_pack_category = sa.Enum(
    "preset",
    "lut",
    "social_pack",
    "template",
    "captions",
    "thumbnail_pack",
    "reel_pack",
    "other",
    name="content_pack_category",
    native_enum=False,
)
content_pack_status = sa.Enum("draft", "submitted", "approved", "rejected", "delisted", name="content_pack_status", native_enum=False)
pack_source_type = sa.Enum("gig", "template_upload", name="pack_source_type", native_enum=False)
content_pack_payment_method = sa.Enum("stripe", "raww_credits", "mixed", name="content_pack_payment_method", native_enum=False)
content_pack_order_status = sa.Enum("pending", "paid", "failed", "refunded", name="content_pack_order_status", native_enum=False)
royalty_ledger_status = sa.Enum("pending", "settled", "reversed", name="royalty_ledger_status", native_enum=False)
content_pack_review_decision = sa.Enum("approved", "rejected", name="content_pack_review_decision", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "content_pack",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("creator_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("category", content_pack_category, nullable=False),
        sa.Column("niche_slugs", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("tags", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("price_eur", sa.Numeric(12, 2), nullable=True),
        sa.Column("price_raww", sa.BigInteger(), nullable=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("cover_media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=True),
        sa.Column("preview_media_asset_ids", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("pack_file_storage_key", sa.Text(), nullable=False),
        sa.Column("pack_file_bytes", sa.BigInteger(), nullable=True),
        sa.Column("license_code", sa.Text(), nullable=False),
        sa.Column("status", content_pack_status, nullable=False, server_default="draft"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_content_pack_creator_user_id", "content_pack", ["creator_user_id"])
    op.create_index("ix_content_pack_status", "content_pack", ["status"])
    op.create_index("ix_content_pack_status_updated", "content_pack", ["status", "updated_at"])

    op.create_table(
        "content_pack_version",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column("pack_file_storage_key", sa.Text(), nullable=False),
        sa.Column("release_notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("content_pack_id", "version", name="uq_content_pack_version"),
    )
    op.create_index("ix_content_pack_version_content_pack_id", "content_pack_version", ["content_pack_id"])

    op.create_table(
        "content_license",
        sa.Column("code", sa.Text(), primary_key=True),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("terms", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "pack_source_reference",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("source_type", pack_source_type, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=True),
        sa.Column("evidence", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column(
            "requires_consent_level",
            sa.Enum(
                "none",
                "pro_marketing_only",
                "rawwers_marketing_only",
                "both_pro_and_rawwers",
                name="gig_consent_level",
                native_enum=False,
            ),
            nullable=False,
            server_default="both_pro_and_rawwers",
        ),
        sa.Column("is_consent_verified", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_pack_source_reference_content_pack_id", "pack_source_reference", ["content_pack_id"])
    op.create_index("ix_pack_source_reference_gig_id", "pack_source_reference", ["gig_id"])

    op.create_table(
        "content_pack_order",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("buyer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("price_eur_paid", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("price_raww_paid", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("payment_method", content_pack_payment_method, nullable=False),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True),
        sa.Column("status", content_pack_order_status, nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_content_pack_order_buyer_user_id", "content_pack_order", ["buyer_user_id"])
    op.create_index("ix_content_pack_order_content_pack_id", "content_pack_order", ["content_pack_id"])
    op.create_index("ix_content_pack_order_status", "content_pack_order", ["status"])
    op.create_index("ix_content_pack_order_stripe_payment_intent_id", "content_pack_order", ["stripe_payment_intent_id"])
    op.create_index("ix_content_pack_order_buyer_created", "content_pack_order", ["buyer_user_id", "created_at"])

    op.create_table(
        "content_pack_entitlement",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack_order.id"), nullable=False, unique=True),
        sa.Column("buyer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("valid_from", sa.DateTime(timezone=True), nullable=False),
        sa.Column("valid_until", sa.DateTime(timezone=True), nullable=True),
        sa.Column("download_limit", sa.Integer(), nullable=False, server_default="20"),
        sa.Column("downloads_used", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_content_pack_entitlement_order_id", "content_pack_entitlement", ["order_id"])
    op.create_index("ix_content_pack_entitlement_buyer_user_id", "content_pack_entitlement", ["buyer_user_id"])
    op.create_index("ix_content_pack_entitlement_content_pack_id", "content_pack_entitlement", ["content_pack_id"])

    op.create_table(
        "royalty_rule",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("category", sa.Text(), nullable=True),
        sa.Column("platform_fee_percent", sa.Integer(), nullable=False),
        sa.Column("creator_percent", sa.Integer(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_royalty_rule_category", "royalty_rule", ["category"])

    op.create_table(
        "royalty_ledger_entry",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("content_pack_order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack_order.id"), nullable=False),
        sa.Column("creator_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("gross_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("fee_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("net_creator_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("gross_raww", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("fee_raww", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("net_creator_raww", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("status", royalty_ledger_status, nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_royalty_ledger_entry_content_pack_order_id", "royalty_ledger_entry", ["content_pack_order_id"])
    op.create_index("ix_royalty_ledger_entry_creator_user_id", "royalty_ledger_entry", ["creator_user_id"])
    op.create_index("ix_royalty_ledger_entry_status", "royalty_ledger_entry", ["status"])

    op.create_table(
        "content_pack_review",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("reviewer_admin_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("decision", content_pack_review_decision, nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_content_pack_review_content_pack_id", "content_pack_review", ["content_pack_id"])
    op.create_index("ix_content_pack_review_reviewer_admin_id", "content_pack_review", ["reviewer_admin_id"])

    op.create_table(
        "content_pack_takedown",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("admin_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_content_pack_takedown_content_pack_id", "content_pack_takedown", ["content_pack_id"])
    op.create_index("ix_content_pack_takedown_admin_user_id", "content_pack_takedown", ["admin_user_id"])

    op.create_table(
        "pack_download_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("order_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack_order.id"), nullable=False),
        sa.Column("entitlement_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack_entitlement.id"), nullable=False),
        sa.Column("buyer_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("content_pack_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("content_pack.id"), nullable=False),
        sa.Column("download_number", sa.Integer(), nullable=False),
        sa.Column("ip_hash", sa.Text(), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_pack_download_log_order_id", "pack_download_log", ["order_id"])
    op.create_index("ix_pack_download_log_entitlement_id", "pack_download_log", ["entitlement_id"])
    op.create_index("ix_pack_download_log_buyer_user_id", "pack_download_log", ["buyer_user_id"])
    op.create_index("ix_pack_download_log_content_pack_id", "pack_download_log", ["content_pack_id"])
    op.create_index("ix_pack_download_log_created_at", "pack_download_log", ["created_at"])
    op.create_index("ix_pack_download_log_pack_created", "pack_download_log", ["content_pack_id", "created_at"])

    op.execute(
        """
        INSERT INTO content_license (code, name, terms)
        VALUES
            ('standard_personal', 'Standard Personal', '{"commercial": false, "redistribution": false}'::jsonb),
            ('standard_commercial', 'Standard Commercial', '{"commercial": true, "redistribution": false}'::jsonb)
        ON CONFLICT (code) DO NOTHING
        """
    )
    op.execute(
        """
        INSERT INTO royalty_rule (id, category, platform_fee_percent, creator_percent)
        VALUES ('00000000-0000-0000-0000-000000002801', NULL, 20, 80)
        """
    )


def downgrade() -> None:
    op.drop_index("ix_pack_download_log_pack_created", table_name="pack_download_log")
    op.drop_index("ix_pack_download_log_created_at", table_name="pack_download_log")
    op.drop_index("ix_pack_download_log_content_pack_id", table_name="pack_download_log")
    op.drop_index("ix_pack_download_log_buyer_user_id", table_name="pack_download_log")
    op.drop_index("ix_pack_download_log_entitlement_id", table_name="pack_download_log")
    op.drop_index("ix_pack_download_log_order_id", table_name="pack_download_log")
    op.drop_table("pack_download_log")

    op.drop_index("ix_content_pack_takedown_admin_user_id", table_name="content_pack_takedown")
    op.drop_index("ix_content_pack_takedown_content_pack_id", table_name="content_pack_takedown")
    op.drop_table("content_pack_takedown")

    op.drop_index("ix_content_pack_review_reviewer_admin_id", table_name="content_pack_review")
    op.drop_index("ix_content_pack_review_content_pack_id", table_name="content_pack_review")
    op.drop_table("content_pack_review")

    op.drop_index("ix_royalty_ledger_entry_status", table_name="royalty_ledger_entry")
    op.drop_index("ix_royalty_ledger_entry_creator_user_id", table_name="royalty_ledger_entry")
    op.drop_index("ix_royalty_ledger_entry_content_pack_order_id", table_name="royalty_ledger_entry")
    op.drop_table("royalty_ledger_entry")

    op.drop_index("ix_royalty_rule_category", table_name="royalty_rule")
    op.drop_table("royalty_rule")

    op.drop_index("ix_content_pack_entitlement_content_pack_id", table_name="content_pack_entitlement")
    op.drop_index("ix_content_pack_entitlement_buyer_user_id", table_name="content_pack_entitlement")
    op.drop_index("ix_content_pack_entitlement_order_id", table_name="content_pack_entitlement")
    op.drop_table("content_pack_entitlement")

    op.drop_index("ix_content_pack_order_buyer_created", table_name="content_pack_order")
    op.drop_index("ix_content_pack_order_stripe_payment_intent_id", table_name="content_pack_order")
    op.drop_index("ix_content_pack_order_status", table_name="content_pack_order")
    op.drop_index("ix_content_pack_order_content_pack_id", table_name="content_pack_order")
    op.drop_index("ix_content_pack_order_buyer_user_id", table_name="content_pack_order")
    op.drop_table("content_pack_order")

    op.drop_index("ix_pack_source_reference_gig_id", table_name="pack_source_reference")
    op.drop_index("ix_pack_source_reference_content_pack_id", table_name="pack_source_reference")
    op.drop_table("pack_source_reference")

    op.drop_table("content_license")

    op.drop_index("ix_content_pack_version_content_pack_id", table_name="content_pack_version")
    op.drop_table("content_pack_version")

    op.drop_index("ix_content_pack_status_updated", table_name="content_pack")
    op.drop_index("ix_content_pack_status", table_name="content_pack")
    op.drop_index("ix_content_pack_creator_user_id", table_name="content_pack")
    op.drop_table("content_pack")

    content_pack_review_decision.drop(op.get_bind(), checkfirst=True)
    royalty_ledger_status.drop(op.get_bind(), checkfirst=True)
    content_pack_order_status.drop(op.get_bind(), checkfirst=True)
    content_pack_payment_method.drop(op.get_bind(), checkfirst=True)
    pack_source_type.drop(op.get_bind(), checkfirst=True)
    content_pack_status.drop(op.get_bind(), checkfirst=True)
    content_pack_category.drop(op.get_bind(), checkfirst=True)
