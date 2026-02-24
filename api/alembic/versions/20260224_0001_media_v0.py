"""media subsystem v0

Revision ID: 20260224_0001
Revises: 
Create Date: 2026-02-24 20:20:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260224_0001"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


media_kind_enum = sa.Enum("photo", "video", name="media_kind", native_enum=False)
media_purpose_enum = sa.Enum(
    "portfolio_reel",
    "video_review",
    "proof",
    "final_delivery",
    "other",
    name="media_purpose",
    native_enum=False,
)
media_provider_enum = sa.Enum("r2", "mux", name="media_provider", native_enum=False)
media_status_enum = sa.Enum(
    "created",
    "uploading",
    "processing",
    "ready",
    "failed",
    "deleted",
    name="media_status",
    native_enum=False,
)
media_visibility_enum = sa.Enum(
    "public",
    "authenticated",
    "owner_only",
    "client_only",
    "purchaser_only",
    name="media_visibility",
    native_enum=False,
)
media_variant_enum = sa.Enum("original", "thumbnail", "watermark_preview", name="media_variant", native_enum=False)
object_status_enum = sa.Enum("created", "processing", "ready", "failed", name="object_status", native_enum=False)
webhook_provider_enum = sa.Enum("mux", name="webhook_provider", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "media_asset",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("owner_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("kind", media_kind_enum, nullable=False),
        sa.Column("purpose", media_purpose_enum, nullable=False),
        sa.Column("provider", media_provider_enum, nullable=False),
        sa.Column("provider_asset_id", sa.Text(), nullable=True),
        sa.Column("provider_upload_id", sa.Text(), nullable=True),
        sa.Column("status", media_status_enum, nullable=False),
        sa.Column("visibility", media_visibility_enum, nullable=False),
        sa.Column("content_type", sa.Text(), nullable=True),
        sa.Column("byte_size", sa.BigInteger(), nullable=True),
        sa.Column("checksum", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_media_asset_owner_user_id", "media_asset", ["owner_user_id"])
    op.create_index("ix_media_asset_owner_created", "media_asset", ["owner_user_id", sa.text("created_at DESC")])
    op.create_index("ix_media_asset_provider_asset", "media_asset", ["provider", "provider_asset_id"])

    op.create_table(
        "media_object",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("variant", media_variant_enum, nullable=False),
        sa.Column("storage_key", sa.Text(), nullable=False),
        sa.Column("width", sa.Integer(), nullable=True),
        sa.Column("height", sa.Integer(), nullable=True),
        sa.Column("status", object_status_enum, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_media_object_media_asset_id", "media_object", ["media_asset_id"])

    op.create_table(
        "webhook_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("provider", webhook_provider_enum, nullable=False),
        sa.Column("external_event_id", sa.Text(), nullable=False),
        sa.Column("event_type", sa.Text(), nullable=False),
        sa.Column("received_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False),
    )
    op.create_index("ux_webhook_provider_external", "webhook_event", ["provider", "external_event_id"], unique=True)


def downgrade() -> None:
    op.drop_index("ux_webhook_provider_external", table_name="webhook_event")
    op.drop_table("webhook_event")

    op.drop_index("ix_media_object_media_asset_id", table_name="media_object")
    op.drop_table("media_object")

    op.drop_index("ix_media_asset_provider_asset", table_name="media_asset")
    op.drop_index("ix_media_asset_owner_created", table_name="media_asset")
    op.drop_index("ix_media_asset_owner_user_id", table_name="media_asset")
    op.drop_table("media_asset")
