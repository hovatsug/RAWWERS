"""e-learning v1: partners curriculum progress certificates and revenue share

Revision ID: 20260305_0036
Revises: 20260305_0035
Create Date: 2026-03-05 20:50:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260305_0036"
down_revision: Union[str, Sequence[str], None] = "20260305_0035"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

learning_partner_status_enum = sa.Enum("active", "suspended", name="learning_partner_status", native_enum=False)
course_pricing_mode_enum = sa.Enum("free", "paid", name="course_pricing_mode", native_enum=False)
course_status_enum = sa.Enum("draft", "submitted", "approved", "rejected", "delisted", name="course_status", native_enum=False)
course_module_type_enum = sa.Enum("video", "quiz", "assignment", "reading", name="course_module_type", native_enum=False)
curriculum_requirement_type_enum = sa.Enum("mandatory", "optional", name="curriculum_requirement_type", native_enum=False)
certificate_type_enum = sa.Enum("course", "curriculum", name="certificate_type", native_enum=False)
course_sale_status_enum = sa.Enum("paid", "refunded", name="course_sale_status", native_enum=False)
course_review_decision_enum = sa.Enum("approved", "rejected", name="course_review_decision", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "learning_partner",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("brand", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("contact_email", sa.Text(), nullable=True),
        sa.Column("status", learning_partner_status_enum, nullable=False, server_default="active"),
        sa.Column("payout_account_ref", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_learning_partner_status", "learning_partner", ["status"])

    op.create_table(
        "learning_fee_policy",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("platform_fee_percent", sa.Integer(), nullable=False, server_default="30"),
        sa.Column("mux_cost_reserve_percent", sa.Integer(), nullable=False, server_default="10"),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )

    op.add_column("course", sa.Column("creator_user_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("course", sa.Column("partner_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("course", sa.Column("title_key", sa.Text(), nullable=True))
    op.add_column("course", sa.Column("title_custom", sa.Text(), nullable=True))
    op.add_column("course", sa.Column("description_key", sa.Text(), nullable=True))
    op.add_column("course", sa.Column("description_custom", sa.Text(), nullable=True))
    op.add_column("course", sa.Column("language", sa.Text(), nullable=False, server_default="en-GB"))
    op.add_column("course", sa.Column("niche_slugs", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")))
    op.add_column("course", sa.Column("pricing_mode", course_pricing_mode_enum, nullable=False, server_default="free"))
    op.add_column("course", sa.Column("status", course_status_enum, nullable=False, server_default="draft"))
    op.add_column("course", sa.Column("price_eur", sa.Numeric(12, 2), nullable=True))
    op.add_column("course", sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("course", sa.Column("mux_metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))
    op.create_foreign_key("fk_course_creator_user", "course", "user_account", ["creator_user_id"], ["user_id"])
    op.create_foreign_key("fk_course_partner", "course", "learning_partner", ["partner_id"], ["id"])
    op.create_index("ix_course_creator_user_id", "course", ["creator_user_id"])
    op.create_index("ix_course_partner_id", "course", ["partner_id"])
    op.create_index("ix_course_status", "course", ["status"])
    op.create_index("ix_course_pricing_mode", "course", ["pricing_mode"])
    op.create_index("ix_course_partner_status", "course", ["partner_id", "status"])

    op.add_column("course_module", sa.Column("type", course_module_type_enum, nullable=False, server_default="video"))
    op.add_column("course_module", sa.Column("mux_asset_id", sa.Text(), nullable=True))
    op.add_column("course_module", sa.Column("duration_seconds", sa.Integer(), nullable=True))
    op.add_column("course_module", sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")))

    op.execute("UPDATE enrollment SET status = 'enrolled' WHERE status = 'active'")
    op.add_column("enrollment", sa.Column("paid", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.add_column("enrollment", sa.Column("stripe_payment_intent_id", sa.Text(), nullable=True))
    op.add_column("enrollment", sa.Column("enrolled_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()))
    op.create_index("ix_enrollment_stripe_payment_intent_id", "enrollment", ["stripe_payment_intent_id"])

    op.create_table(
        "curriculum_path",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("niche_slug", sa.Text(), nullable=False),
        sa.Column("name", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_curriculum_path_niche_slug", "curriculum_path", ["niche_slug"])

    op.alter_column("certificate", "course_id", existing_type=postgresql.UUID(as_uuid=True), nullable=True)
    op.alter_column("certificate", "niche_id", existing_type=postgresql.UUID(as_uuid=True), nullable=True)
    op.add_column("certificate", sa.Column("certificate_type", certificate_type_enum, nullable=False, server_default="course"))
    op.add_column("certificate", sa.Column("curriculum_path_id", postgresql.UUID(as_uuid=True), nullable=True))
    op.add_column("certificate", sa.Column("niche_slug", sa.Text(), nullable=True))
    op.add_column("certificate", sa.Column("verification_code", sa.Text(), nullable=True))
    op.add_column("certificate", sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True))
    op.create_foreign_key("fk_certificate_curriculum_path", "certificate", "curriculum_path", ["curriculum_path_id"], ["id"])
    op.create_index("ix_certificate_certificate_type", "certificate", ["certificate_type"])
    op.create_index("ix_certificate_curriculum_path_id", "certificate", ["curriculum_path_id"])
    op.create_index("ix_certificate_verification_code", "certificate", ["verification_code"], unique=True)

    op.create_table(
        "curriculum_requirement",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("curriculum_path_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("curriculum_path.id"), nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("requirement_type", curriculum_requirement_type_enum, nullable=False),
        sa.Column("min_score_percent", sa.Integer(), nullable=False, server_default="70"),
        sa.Column("order_index", sa.Integer(), nullable=False, server_default="0"),
        sa.UniqueConstraint("curriculum_path_id", "course_id", name="uq_curriculum_path_course"),
    )
    op.create_index("ix_curriculum_requirement_curriculum_path_id", "curriculum_requirement", ["curriculum_path_id"])
    op.create_index("ix_curriculum_requirement_course_id", "curriculum_requirement", ["course_id"])

    op.create_table(
        "course_quiz",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course_module.id"), nullable=False),
        sa.Column("questions", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("pass_score_percent", sa.Integer(), nullable=False, server_default="70"),
        sa.UniqueConstraint("module_id", name="uq_course_quiz_module"),
    )
    op.create_index("ix_course_quiz_module_id", "course_quiz", ["module_id"])

    op.create_table(
        "module_progress",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("enrollment_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("enrollment.id"), nullable=False),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course_module.id"), nullable=False),
        sa.Column("status", sa.Enum("not_started", "in_progress", "completed", name="progress_status", native_enum=False), nullable=False, server_default="not_started"),
        sa.Column("watch_seconds", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_position_seconds", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("quiz_score_percent", sa.Integer(), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("enrollment_id", "module_id", name="uq_module_progress_enrollment_module"),
    )
    op.create_index("ix_module_progress_enrollment_id", "module_progress", ["enrollment_id"])
    op.create_index("ix_module_progress_module_id", "module_progress", ["module_id"])
    op.create_index("ix_module_progress_status", "module_progress", ["status"])

    op.create_table(
        "course_sale",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("gross_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("platform_fee_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("partner_net_eur", sa.Numeric(12, 2), nullable=False),
        sa.Column("stripe_payment_intent_id", sa.Text(), nullable=False),
        sa.Column("status", course_sale_status_enum, nullable=False, server_default="paid"),
        sa.Column("mux_minutes_consumed", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("mux_cost_reserve_eur", sa.Numeric(12, 2), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_course_sale_course_id", "course_sale", ["course_id"])
    op.create_index("ix_course_sale_user_id", "course_sale", ["user_id"])
    op.create_index("ix_course_sale_stripe_payment_intent_id", "course_sale", ["stripe_payment_intent_id"])

    op.create_table(
        "course_review",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("reviewer_admin_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("decision", course_review_decision_enum, nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_course_review_course_id", "course_review", ["course_id"])
    op.create_index("ix_course_review_reviewer_admin_id", "course_review", ["reviewer_admin_id"])


def downgrade() -> None:
    op.drop_index("ix_course_review_reviewer_admin_id", table_name="course_review")
    op.drop_index("ix_course_review_course_id", table_name="course_review")
    op.drop_table("course_review")

    op.drop_index("ix_course_sale_stripe_payment_intent_id", table_name="course_sale")
    op.drop_index("ix_course_sale_user_id", table_name="course_sale")
    op.drop_index("ix_course_sale_course_id", table_name="course_sale")
    op.drop_table("course_sale")

    op.drop_index("ix_module_progress_status", table_name="module_progress")
    op.drop_index("ix_module_progress_module_id", table_name="module_progress")
    op.drop_index("ix_module_progress_enrollment_id", table_name="module_progress")
    op.drop_table("module_progress")

    op.drop_index("ix_course_quiz_module_id", table_name="course_quiz")
    op.drop_table("course_quiz")

    op.drop_index("ix_curriculum_requirement_course_id", table_name="curriculum_requirement")
    op.drop_index("ix_curriculum_requirement_curriculum_path_id", table_name="curriculum_requirement")
    op.drop_table("curriculum_requirement")

    op.drop_index("ix_curriculum_path_niche_slug", table_name="curriculum_path")
    op.drop_table("curriculum_path")

    op.drop_index("ix_certificate_verification_code", table_name="certificate")
    op.drop_index("ix_certificate_curriculum_path_id", table_name="certificate")
    op.drop_index("ix_certificate_certificate_type", table_name="certificate")
    op.drop_constraint("fk_certificate_curriculum_path", "certificate", type_="foreignkey")
    op.drop_column("certificate", "revoked_at")
    op.drop_column("certificate", "verification_code")
    op.drop_column("certificate", "niche_slug")
    op.drop_column("certificate", "curriculum_path_id")
    op.drop_column("certificate", "certificate_type")
    op.alter_column("certificate", "niche_id", existing_type=postgresql.UUID(as_uuid=True), nullable=False)
    op.alter_column("certificate", "course_id", existing_type=postgresql.UUID(as_uuid=True), nullable=False)

    op.drop_index("ix_enrollment_stripe_payment_intent_id", table_name="enrollment")
    op.drop_column("enrollment", "enrolled_at")
    op.drop_column("enrollment", "stripe_payment_intent_id")
    op.drop_column("enrollment", "paid")
    op.execute("UPDATE enrollment SET status = 'active' WHERE status = 'enrolled'")

    op.drop_column("course_module", "metadata")
    op.drop_column("course_module", "duration_seconds")
    op.drop_column("course_module", "mux_asset_id")
    op.drop_column("course_module", "type")

    op.drop_index("ix_course_partner_status", table_name="course")
    op.drop_index("ix_course_pricing_mode", table_name="course")
    op.drop_index("ix_course_status", table_name="course")
    op.drop_index("ix_course_partner_id", table_name="course")
    op.drop_index("ix_course_creator_user_id", table_name="course")
    op.drop_constraint("fk_course_partner", "course", type_="foreignkey")
    op.drop_constraint("fk_course_creator_user", "course", type_="foreignkey")
    op.drop_column("course", "mux_metadata")
    op.drop_column("course", "approved_at")
    op.drop_column("course", "price_eur")
    op.drop_column("course", "status")
    op.drop_column("course", "pricing_mode")
    op.drop_column("course", "niche_slugs")
    op.drop_column("course", "language")
    op.drop_column("course", "description_custom")
    op.drop_column("course", "description_key")
    op.drop_column("course", "title_custom")
    op.drop_column("course", "title_key")
    op.drop_column("course", "partner_id")
    op.drop_column("course", "creator_user_id")

    op.drop_table("learning_fee_policy")
    op.drop_index("ix_learning_partner_status", table_name="learning_partner")
    op.drop_table("learning_partner")
