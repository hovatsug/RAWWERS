"""niche skill matrix v2: per-niche score policy events badges

Revision ID: 20260305_0037
Revises: 20260305_0036
Create Date: 2026-03-05 22:10:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260305_0037"
down_revision: Union[str, Sequence[str], None] = "20260305_0036"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

pro_niche_skill_event_type_enum = sa.Enum(
    "recalculated",
    "promoted",
    "demoted",
    "admin_override",
    "verified_set",
    name="pro_niche_skill_event_type",
    native_enum=False,
)
pro_niche_skill_actor_type_enum = sa.Enum("system", "admin", name="pro_niche_skill_actor_type", native_enum=False)


def upgrade() -> None:
    op.add_column("niche", sa.Column("name_key", sa.Text(), nullable=True))

    op.add_column("pro_niche_skill", sa.Column("score", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("pro_niche_skill", sa.Column("verified", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("pro_niche_skill", sa.Column("gigs_completed", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("pro_niche_skill", sa.Column("avg_rating", sa.Numeric(3, 2), nullable=False, server_default="0.00"))
    op.add_column("pro_niche_skill", sa.Column("review_count", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("pro_niche_skill", sa.Column("last_promotion_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("pro_niche_skill", sa.Column("last_demotion_at", sa.DateTime(timezone=True), nullable=True))
    op.create_index("ix_pro_niche_skill_verified", "pro_niche_skill", ["verified"])

    op.add_column("pro_public_index", sa.Column("niche_tiers", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))
    op.add_column("pro_public_index", sa.Column("verified_niches", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")))

    op.create_table(
        "pro_niche_skill_event",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("pro_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("event_type", pro_niche_skill_event_type_enum, nullable=False),
        sa.Column("from_tier", sa.Text(), nullable=True),
        sa.Column("to_tier", sa.Text(), nullable=True),
        sa.Column("score_before", sa.Integer(), nullable=True),
        sa.Column("score_after", sa.Integer(), nullable=True),
        sa.Column("reasons", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("actor_type", pro_niche_skill_actor_type_enum, nullable=False),
        sa.Column("actor_user_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_pro_niche_skill_event_pro_user_id", "pro_niche_skill_event", ["pro_user_id"])
    op.create_index("ix_pro_niche_skill_event_niche_id", "pro_niche_skill_event", ["niche_id"])
    op.create_index("ix_pro_niche_skill_event_event_type", "pro_niche_skill_event", ["event_type"])
    op.create_index("ix_pro_niche_skill_event_created_at", "pro_niche_skill_event", ["created_at"])

    op.create_table(
        "niche_tier_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("thresholds", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("niche_id", name="uq_niche_tier_policy_niche"),
    )
    op.create_index("ix_niche_tier_policy_niche_id", "niche_tier_policy", ["niche_id"])

    op.create_table(
        "badge",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("code", sa.Text(), nullable=False),
        sa.Column("name_key", sa.Text(), nullable=False),
        sa.Column("description_key", sa.Text(), nullable=False),
        sa.Column("icon_ref", sa.Text(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_badge_code", "badge", ["code"], unique=True)

    op.create_table(
        "user_badge",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("badge_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("badge.id"), nullable=False),
        sa.Column("awarded_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("source", sa.Text(), nullable=False, server_default="niche_skill"),
        sa.UniqueConstraint("user_id", "badge_id", name="uq_user_badge_user_badge"),
    )
    op.create_index("ix_user_badge_user_id", "user_badge", ["user_id"])
    op.create_index("ix_user_badge_badge_id", "user_badge", ["badge_id"])


def downgrade() -> None:
    op.drop_index("ix_user_badge_badge_id", table_name="user_badge")
    op.drop_index("ix_user_badge_user_id", table_name="user_badge")
    op.drop_table("user_badge")

    op.drop_index("ix_badge_code", table_name="badge")
    op.drop_table("badge")

    op.drop_index("ix_niche_tier_policy_niche_id", table_name="niche_tier_policy")
    op.drop_table("niche_tier_policy")

    op.drop_index("ix_pro_niche_skill_event_created_at", table_name="pro_niche_skill_event")
    op.drop_index("ix_pro_niche_skill_event_event_type", table_name="pro_niche_skill_event")
    op.drop_index("ix_pro_niche_skill_event_niche_id", table_name="pro_niche_skill_event")
    op.drop_index("ix_pro_niche_skill_event_pro_user_id", table_name="pro_niche_skill_event")
    op.drop_table("pro_niche_skill_event")

    op.drop_column("pro_public_index", "verified_niches")
    op.drop_column("pro_public_index", "niche_tiers")

    op.drop_index("ix_pro_niche_skill_verified", table_name="pro_niche_skill")
    op.drop_column("pro_niche_skill", "last_demotion_at")
    op.drop_column("pro_niche_skill", "last_promotion_at")
    op.drop_column("pro_niche_skill", "review_count")
    op.drop_column("pro_niche_skill", "avg_rating")
    op.drop_column("pro_niche_skill", "gigs_completed")
    op.drop_column("pro_niche_skill", "verified")
    op.drop_column("pro_niche_skill", "score")

    op.drop_column("niche", "name_key")
