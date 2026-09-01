"""client rewards + tier pricing v1

Revision ID: 20260226_0021
Revises: 20260226_0020
Create Date: 2026-02-26 02:10:00.000000
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision: str = "20260226_0021"
down_revision: Union[str, Sequence[str], None] = "20260226_0020"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


consent_reward_level_enum = sa.Enum(
    "none",
    "pro_marketing_only",
    "rawwers_marketing_only",
    "both_pro_and_rawwers",
    name="consent_reward_level",
    native_enum=False,
)

share_reward_metric_enum = sa.Enum(
    "unique_views_30d",
    "conversions_30d",
    name="share_reward_metric",
    native_enum=False,
)

extra_image_purchase_status_enum = sa.Enum(
    "pending",
    "paid",
    "failed",
    "refunded",
    name="extra_image_purchase_status",
    native_enum=False,
)

milestone_audience_enum = sa.Enum(
    "pro",
    "client",
    "both",
    name="milestone_audience",
    native_enum=False,
)


def upgrade() -> None:
    op.add_column("milestone", sa.Column("audience", milestone_audience_enum, nullable=False, server_default="both"))

    op.create_table(
        "extra_image_pricing_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("tier", sa.Enum("rookie", "skilled", "pro", "elite", "master", name="skill_tier", native_enum=False), nullable=False),
        sa.Column("unit_price_min", sa.Numeric(12, 2), nullable=False, server_default="0.00"),
        sa.Column("unit_price_max", sa.Numeric(12, 2), nullable=True),
        sa.Column("max_extra_images", sa.Integer(), nullable=True),
        sa.Column("bulk_curve", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("niche_id", "tier", name="uq_extra_image_pricing_policy_niche_tier"),
    )
    op.create_index("ix_extra_image_pricing_policy_niche_id", "extra_image_pricing_policy", ["niche_id"])

    op.create_table(
        "pro_extra_image_price",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("configured_unit_price", sa.Numeric(12, 2), nullable=False),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("pro_user_id", "niche_id", name="uq_pro_extra_image_price_pro_niche"),
    )
    op.create_index("ix_pro_extra_image_price_pro_user_id", "pro_extra_image_price", ["pro_user_id"])
    op.create_index("ix_pro_extra_image_price_niche_id", "pro_extra_image_price", ["niche_id"])

    op.create_table(
        "consent_reward_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("consent_level", consent_reward_level_enum, nullable=False, unique=True),
        sa.Column("points_award", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("cooldown_hours", sa.Integer(), nullable=False, server_default="48"),
        sa.Column("allow_clawback", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("max_awards_per_user_per_month", sa.Integer(), nullable=False, server_default="10"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "share_link_view",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("share_link_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("share_link.id"), nullable=False),
        sa.Column("ip_hash", sa.Text(), nullable=True),
        sa.Column("ua_hash", sa.Text(), nullable=True),
        sa.Column("fingerprint", sa.Text(), nullable=False),
        sa.Column("viewed_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("viewed_on", sa.Date(), nullable=False, server_default=sa.text("CURRENT_DATE")),
        sa.Column("seconds_viewed", sa.Integer(), nullable=False, server_default="0"),
        sa.UniqueConstraint("share_link_id", "fingerprint", "viewed_on", name="uq_share_link_view_daily_fingerprint"),
    )
    op.create_index("ix_share_link_view_share_link_id", "share_link_view", ["share_link_id"])
    op.create_index("ix_share_link_view_ip_hash", "share_link_view", ["ip_hash"])
    op.create_index("ix_share_link_view_ua_hash", "share_link_view", ["ua_hash"])
    op.create_index("ix_share_link_view_fingerprint", "share_link_view", ["fingerprint"])
    op.create_index("ix_share_link_view_viewed_at", "share_link_view", ["viewed_at"])
    op.create_index("ix_share_link_view_viewed_on", "share_link_view", ["viewed_on"])

    op.create_table(
        "share_link_engagement",
        sa.Column("share_link_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("share_link.id"), primary_key=True, nullable=False),
        sa.Column("unique_views_7d", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("unique_views_30d", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("conversions_30d", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )

    op.create_table(
        "share_reward_threshold",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("metric", share_reward_metric_enum, nullable=False),
        sa.Column("threshold_value", sa.Integer(), nullable=False),
        sa.Column("points_award", sa.BigInteger(), nullable=False),
        sa.Column("max_awards_per_share_link", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("metric", "threshold_value", name="uq_share_reward_threshold_metric_value"),
    )

    op.create_table(
        "share_reward_grant",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("share_link_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("share_link.id"), nullable=False),
        sa.Column("metric", sa.Text(), nullable=False),
        sa.Column("threshold_value", sa.Integer(), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reward_ledger_entry_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("granted_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("share_link_id", "metric", "threshold_value", "user_id", name="uq_share_reward_grant_unique"),
    )
    op.create_index("ix_share_reward_grant_share_link_id", "share_reward_grant", ["share_link_id"])
    op.create_index("ix_share_reward_grant_user_id", "share_reward_grant", ["user_id"])

    op.create_table(
        "extra_image_purchase",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("gig_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gig.id"), nullable=False),
        sa.Column("client_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=True),
        sa.Column("included_images", sa.Integer(), nullable=False),
        sa.Column("selected_images", sa.Integer(), nullable=False),
        sa.Column("extra_images", sa.Integer(), nullable=False),
        sa.Column("unit_price_applied", sa.Numeric(12, 2), nullable=False),
        sa.Column("unit_price_configured", sa.Numeric(12, 2), nullable=False),
        sa.Column("policy_unit_price_min", sa.Numeric(12, 2), nullable=False),
        sa.Column("policy_unit_price_max", sa.Numeric(12, 2), nullable=True),
        sa.Column("subtotal", sa.Numeric(12, 2), nullable=False),
        sa.Column("points_spent", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("discounts_total", sa.Numeric(12, 2), nullable=False, server_default="0.00"),
        sa.Column("total", sa.Numeric(12, 2), nullable=False),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True),
        sa.Column("status", extra_image_purchase_status_enum, nullable=False, server_default="pending"),
        sa.Column("share_link_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("share_link.id"), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_extra_image_purchase_gig_id", "extra_image_purchase", ["gig_id"])
    op.create_index("ix_extra_image_purchase_client_user_id", "extra_image_purchase", ["client_user_id"])
    op.create_index("ix_extra_image_purchase_pro_user_id", "extra_image_purchase", ["pro_user_id"])
    op.create_index("ix_extra_image_purchase_niche_id", "extra_image_purchase", ["niche_id"])
    op.create_index("ix_extra_image_purchase_stripe_payment_intent_id", "extra_image_purchase", ["stripe_payment_intent_id"])
    op.create_index("ix_extra_image_purchase_share_link_id", "extra_image_purchase", ["share_link_id"])

    op.create_table(
        "share_fraud_setting",
        sa.Column("key", sa.Text(), primary_key=True, nullable=False),
        sa.Column("value", sa.Integer(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("share_fraud_setting")

    op.drop_index("ix_extra_image_purchase_share_link_id", table_name="extra_image_purchase")
    op.drop_index("ix_extra_image_purchase_stripe_payment_intent_id", table_name="extra_image_purchase")
    op.drop_index("ix_extra_image_purchase_niche_id", table_name="extra_image_purchase")
    op.drop_index("ix_extra_image_purchase_pro_user_id", table_name="extra_image_purchase")
    op.drop_index("ix_extra_image_purchase_client_user_id", table_name="extra_image_purchase")
    op.drop_index("ix_extra_image_purchase_gig_id", table_name="extra_image_purchase")
    op.drop_table("extra_image_purchase")

    op.drop_index("ix_share_reward_grant_user_id", table_name="share_reward_grant")
    op.drop_index("ix_share_reward_grant_share_link_id", table_name="share_reward_grant")
    op.drop_table("share_reward_grant")

    op.drop_table("share_reward_threshold")
    op.drop_table("share_link_engagement")

    op.drop_index("ix_share_link_view_viewed_on", table_name="share_link_view")
    op.drop_index("ix_share_link_view_viewed_at", table_name="share_link_view")
    op.drop_index("ix_share_link_view_fingerprint", table_name="share_link_view")
    op.drop_index("ix_share_link_view_ua_hash", table_name="share_link_view")
    op.drop_index("ix_share_link_view_ip_hash", table_name="share_link_view")
    op.drop_index("ix_share_link_view_share_link_id", table_name="share_link_view")
    op.drop_table("share_link_view")

    op.drop_table("consent_reward_policy")

    op.drop_index("ix_pro_extra_image_price_niche_id", table_name="pro_extra_image_price")
    op.drop_index("ix_pro_extra_image_price_pro_user_id", table_name="pro_extra_image_price")
    op.drop_table("pro_extra_image_price")

    op.drop_index("ix_extra_image_pricing_policy_niche_id", table_name="extra_image_pricing_policy")
    op.drop_table("extra_image_pricing_policy")

    op.drop_column("milestone", "audience")

    milestone_audience_enum.drop(op.get_bind(), checkfirst=True)
    extra_image_purchase_status_enum.drop(op.get_bind(), checkfirst=True)
    share_reward_metric_enum.drop(op.get_bind(), checkfirst=True)
    consent_reward_level_enum.drop(op.get_bind(), checkfirst=True)
