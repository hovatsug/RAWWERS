"""media delivery rights, consent, share links

Revision ID: 20260226_0020
Revises: 20260226_0019
Create Date: 2026-02-26 01:20:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "20260226_0020"
down_revision: Union[str, Sequence[str], None] = "20260226_0019"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


media_derivative_kind_enum = sa.Enum(
    "preview_watermarked",
    "web_res",
    "full_res",
    "thumbnail",
    name="media_derivative_kind",
    native_enum=False,
)

entitlement_type_enum = sa.Enum(
    "view_proofs",
    "download_finals",
    "download_extras",
    "share_link_manage",
    name="gig_entitlement_type",
    native_enum=False,
)

consent_level_enum = sa.Enum(
    "none",
    "pro_marketing_only",
    "rawwers_marketing_only",
    "both_pro_and_rawwers",
    name="gig_consent_level",
    native_enum=False,
)

share_link_scope_enum = sa.Enum(
    "proofs",
    "finals",
    "selected_only",
    name="share_link_scope",
    native_enum=False,
)

media_access_action_enum = sa.Enum(
    "view",
    "download",
    name="media_access_action",
    native_enum=False,
)


def upgrade() -> None:
    op.create_table(
        "media_derivative",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("kind", media_derivative_kind_enum, nullable=False),
        sa.Column("storage_key", sa.Text(), nullable=False),
        sa.Column("content_type", sa.Text(), nullable=False),
        sa.Column("bytes", sa.BigInteger(), nullable=True),
        sa.Column("width", sa.Integer(), nullable=True),
        sa.Column("height", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("media_asset_id", "kind", name="uq_media_derivative_asset_kind"),
    )
    op.create_index("ix_media_derivative_media_asset_id", "media_derivative", ["media_asset_id"])

    op.create_table(
        "gig_media_entitlement",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("entitlement_type", entitlement_type_enum, nullable=False),
        sa.Column("quantity_limit", sa.Integer(), nullable=True),
        sa.Column("valid_from", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("valid_until", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.UniqueConstraint("gig_id", "user_id", "entitlement_type", name="uq_gig_entitlement_unique"),
    )
    op.create_index("ix_gig_media_entitlement_gig_id", "gig_media_entitlement", ["gig_id"])
    op.create_index("ix_gig_media_entitlement_user_id", "gig_media_entitlement", ["user_id"])

    op.create_table(
        "gig_usage_consent",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False, unique=True),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("consent_level", consent_level_enum, nullable=False),
        sa.Column("scope", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("incentive", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("snapshot_at_booking", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_gig_usage_consent_gig_id", "gig_usage_consent", ["gig_id"])
    op.create_index("ix_gig_usage_consent_client_user_id", "gig_usage_consent", ["client_user_id"])
    op.create_index("ix_gig_usage_consent_pro_user_id", "gig_usage_consent", ["pro_user_id"])

    op.create_table(
        "gig_usage_consent_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("from_level", sa.Text(), nullable=True),
        sa.Column("to_level", sa.Text(), nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_gig_usage_consent_event_gig_id", "gig_usage_consent_event", ["gig_id"])
    op.create_index("ix_gig_usage_consent_event_actor_user_id", "gig_usage_consent_event", ["actor_user_id"])
    op.create_index("ix_gig_usage_consent_event_created_at", "gig_usage_consent_event", ["created_at"])

    op.create_table(
        "share_link",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("scope", share_link_scope_enum, nullable=False),
        sa.Column("token_hash", sa.Text(), nullable=False, unique=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("max_views", sa.Integer(), nullable=True),
        sa.Column("view_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("is_revoked", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_share_link_gig_id", "share_link", ["gig_id"])
    op.create_index("ix_share_link_created_by_user_id", "share_link", ["created_by_user_id"])
    op.create_index("ix_share_link_token_hash", "share_link", ["token_hash"])

    op.create_table(
        "media_access_log",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("share_link_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("share_link.id"), nullable=True),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=False),
        sa.Column("derivative_kind", sa.Text(), nullable=False),
        sa.Column("action", media_access_action_enum, nullable=False),
        sa.Column("ip_hash", sa.Text(), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_media_access_log_user_id", "media_access_log", ["user_id"])
    op.create_index("ix_media_access_log_share_link_id", "media_access_log", ["share_link_id"])
    op.create_index("ix_media_access_log_gig_id", "media_access_log", ["gig_id"])
    op.create_index("ix_media_access_log_media_asset_id", "media_access_log", ["media_asset_id"])
    op.create_index("ix_media_access_log_created_at", "media_access_log", ["created_at"])


def downgrade() -> None:
    op.drop_index("ix_media_access_log_created_at", table_name="media_access_log")
    op.drop_index("ix_media_access_log_media_asset_id", table_name="media_access_log")
    op.drop_index("ix_media_access_log_gig_id", table_name="media_access_log")
    op.drop_index("ix_media_access_log_share_link_id", table_name="media_access_log")
    op.drop_index("ix_media_access_log_user_id", table_name="media_access_log")
    op.drop_table("media_access_log")

    op.drop_index("ix_share_link_token_hash", table_name="share_link")
    op.drop_index("ix_share_link_created_by_user_id", table_name="share_link")
    op.drop_index("ix_share_link_gig_id", table_name="share_link")
    op.drop_table("share_link")

    op.drop_index("ix_gig_usage_consent_event_created_at", table_name="gig_usage_consent_event")
    op.drop_index("ix_gig_usage_consent_event_actor_user_id", table_name="gig_usage_consent_event")
    op.drop_index("ix_gig_usage_consent_event_gig_id", table_name="gig_usage_consent_event")
    op.drop_table("gig_usage_consent_event")

    op.drop_index("ix_gig_usage_consent_pro_user_id", table_name="gig_usage_consent")
    op.drop_index("ix_gig_usage_consent_client_user_id", table_name="gig_usage_consent")
    op.drop_index("ix_gig_usage_consent_gig_id", table_name="gig_usage_consent")
    op.drop_table("gig_usage_consent")

    op.drop_index("ix_gig_media_entitlement_user_id", table_name="gig_media_entitlement")
    op.drop_index("ix_gig_media_entitlement_gig_id", table_name="gig_media_entitlement")
    op.drop_table("gig_media_entitlement")

    op.drop_index("ix_media_derivative_media_asset_id", table_name="media_derivative")
    op.drop_table("media_derivative")

    media_access_action_enum.drop(op.get_bind(), checkfirst=True)
    share_link_scope_enum.drop(op.get_bind(), checkfirst=True)
    consent_level_enum.drop(op.get_bind(), checkfirst=True)
    entitlement_type_enum.drop(op.get_bind(), checkfirst=True)
    media_derivative_kind_enum.drop(op.get_bind(), checkfirst=True)
