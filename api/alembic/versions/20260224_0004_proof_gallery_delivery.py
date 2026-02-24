"""proof gallery, client selections, upsell purchases, delivery

Revision ID: 20260224_0004
Revises: 20260224_0003
Create Date: 2026-02-24 23:15:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260224_0004"
down_revision: Union[str, Sequence[str], None] = "20260224_0003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


old_ledger_entry_type_enum = sa.Enum(
    "payment_authorized",
    "payment_captured",
    "platform_fee",
    "payout_hold_created",
    "payout_hold_released",
    "refund_initiated",
    "refund_succeeded",
    "chargeback_opened",
    "chargeback_won",
    "chargeback_lost",
    name="ledger_entry_type",
    native_enum=False,
)

new_ledger_entry_type_enum = sa.Enum(
    "payment_authorized",
    "payment_captured",
    "platform_fee",
    "payout_hold_created",
    "payout_hold_released",
    "refund_initiated",
    "refund_succeeded",
    "chargeback_opened",
    "chargeback_won",
    "chargeback_lost",
    "upsell_captured",
    "upsell_platform_fee",
    "upsell_payout_hold_created",
    name="ledger_entry_type",
    native_enum=False,
)

proof_gallery_status_enum = sa.Enum(
    "draft",
    "published",
    "selection_submitted",
    "delivered",
    name="proof_gallery_status",
    native_enum=False,
)

selection_status_enum = sa.Enum("draft", "submitted", "locked", name="selection_status", native_enum=False)

upsell_purchase_status_enum = sa.Enum(
    "pending",
    "succeeded",
    "failed",
    "refunded",
    name="upsell_purchase_status",
    native_enum=False,
)


def upgrade() -> None:
    op.alter_column(
        "ledger_entry",
        "entry_type",
        existing_type=old_ledger_entry_type_enum,
        type_=new_ledger_entry_type_enum,
        existing_nullable=False,
    )

    op.create_table(
        "package_pricing",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.Text(), nullable=True),
        sa.Column("included_photos", sa.Integer(), nullable=False, server_default="20"),
        sa.Column("extra_photo_price", sa.Numeric(12, 2), nullable=False, server_default="10.00"),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_package_pricing_pro_user_id", "package_pricing", ["pro_user_id"])

    op.create_table(
        "proof_gallery",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False, unique=True),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("included_photos", sa.Integer(), nullable=False),
        sa.Column("extra_photo_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False),
        sa.Column("status", proof_gallery_status_enum, nullable=False, server_default="draft"),
        sa.Column("published_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_proof_gallery_gig_id", "proof_gallery", ["gig_id"])
    op.create_index("ix_proof_gallery_pro_user_id", "proof_gallery", ["pro_user_id"])
    op.create_index("ix_proof_gallery_client_user_id", "proof_gallery", ["client_user_id"])

    op.create_table(
        "proof_gallery_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gallery_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("proof_gallery.id"), nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("gallery_id", "media_asset_id", name="uq_gallery_item_unique"),
    )
    op.create_index("ix_proof_gallery_item_gallery_id", "proof_gallery_item", ["gallery_id"])
    op.create_index("ix_proof_gallery_item_media_asset_id", "proof_gallery_item", ["media_asset_id"])

    op.create_table(
        "client_selection",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gallery_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("proof_gallery.id"), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column("status", selection_status_enum, nullable=False, server_default="draft"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_client_selection_gallery_id", "client_selection", ["gallery_id"])
    op.create_index("ix_client_selection_client_user_id", "client_selection", ["client_user_id"])

    op.create_table(
        "client_selection_item",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("selection_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("client_selection.id"), nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("selection_id", "media_asset_id", name="uq_selection_item_unique"),
    )
    op.create_index("ix_client_selection_item_selection_id", "client_selection_item", ["selection_id"])
    op.create_index("ix_client_selection_item_media_asset_id", "client_selection_item", ["media_asset_id"])

    op.create_table(
        "upsell_purchase",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gallery_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("proof_gallery.id"), nullable=False),
        sa.Column("selection_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("client_selection.id"), nullable=False),
        sa.Column("extra_count", sa.Integer(), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False),
        sa.Column("status", upsell_purchase_status_enum, nullable=False, server_default="pending"),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True, unique=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_upsell_purchase_gallery_id", "upsell_purchase", ["gallery_id"])
    op.create_index("ix_upsell_purchase_selection_id", "upsell_purchase", ["selection_id"])
    op.create_index("ix_upsell_purchase_intent", "upsell_purchase", ["stripe_payment_intent_id"])


def downgrade() -> None:
    op.drop_index("ix_upsell_purchase_intent", table_name="upsell_purchase")
    op.drop_index("ix_upsell_purchase_selection_id", table_name="upsell_purchase")
    op.drop_index("ix_upsell_purchase_gallery_id", table_name="upsell_purchase")
    op.drop_table("upsell_purchase")

    op.drop_index("ix_client_selection_item_media_asset_id", table_name="client_selection_item")
    op.drop_index("ix_client_selection_item_selection_id", table_name="client_selection_item")
    op.drop_table("client_selection_item")

    op.drop_index("ix_client_selection_client_user_id", table_name="client_selection")
    op.drop_index("ix_client_selection_gallery_id", table_name="client_selection")
    op.drop_table("client_selection")

    op.drop_index("ix_proof_gallery_item_media_asset_id", table_name="proof_gallery_item")
    op.drop_index("ix_proof_gallery_item_gallery_id", table_name="proof_gallery_item")
    op.drop_table("proof_gallery_item")

    op.drop_index("ix_proof_gallery_client_user_id", table_name="proof_gallery")
    op.drop_index("ix_proof_gallery_pro_user_id", table_name="proof_gallery")
    op.drop_index("ix_proof_gallery_gig_id", table_name="proof_gallery")
    op.drop_table("proof_gallery")

    op.drop_index("ix_package_pricing_pro_user_id", table_name="package_pricing")
    op.drop_table("package_pricing")

    op.alter_column(
        "ledger_entry",
        "entry_type",
        existing_type=new_ledger_entry_type_enum,
        type_=old_ledger_entry_type_enum,
        existing_nullable=False,
    )
