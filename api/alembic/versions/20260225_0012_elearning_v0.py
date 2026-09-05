"""e-learning v0: instructors courses enrollment certificates

Revision ID: 20260225_0012
Revises: 20260225_0011
Create Date: 2026-02-25 22:00:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "20260225_0012"
down_revision: Union[str, Sequence[str], None] = "20260225_0011"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


instructor_status_enum = sa.Enum("pending", "approved", "rejected", name="instructor_status", native_enum=False)
course_level_enum = sa.Enum("beginner", "intermediate", "advanced", "master", name="course_level", native_enum=False)
lesson_content_type_enum = sa.Enum("text", "video", "quiz", name="lesson_content_type", native_enum=False)
enrollment_status_enum = sa.Enum("active", "completed", "refunded", "cancelled", name="enrollment_status", native_enum=False)
progress_status_enum = sa.Enum("not_started", "in_progress", "completed", name="progress_status", native_enum=False)
requirement_type_enum = sa.Enum("course", name="requirement_type", native_enum=False)
skill_tier_enum = sa.Enum("rookie", "skilled", "pro", "elite", "master", name="skill_tier", native_enum=False)


def upgrade() -> None:
    op.create_table(
        "instructor_profile",
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), primary_key=True, nullable=False),
        sa.Column("status", instructor_status_enum, nullable=False, server_default="pending"),
        sa.Column("bio", sa.Text(), nullable=True),
        sa.Column("expertise", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("approved_by", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("rejected_reason", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_instructor_profile_status", "instructor_profile", ["status"])

    op.create_table(
        "course",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("instructor_user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("summary", sa.Text(), nullable=True),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("level", course_level_enum, nullable=False),
        sa.Column("is_mandatory", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("is_published", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("price", sa.Numeric(12, 2), nullable=True),
        sa.Column("currency", sa.CHAR(length=3), nullable=False, server_default="EUR"),
        sa.Column("thumbnail_media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=True),
        sa.Column("intro_video_media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=True),
        sa.Column("estimated_minutes", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_course_instructor_user_id", "course", ["instructor_user_id"])
    op.create_index("ix_course_niche_id", "course", ["niche_id"])
    op.create_index("ix_course_niche_published", "course", ["niche_id", "is_published"])
    op.create_index("ix_course_instructor_published", "course", ["instructor_user_id", "is_published"])

    op.create_table(
        "course_module",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("course_id", "sort_order", name="uq_course_module_course_sort"),
    )
    op.create_index("ix_course_module_course_id", "course_module", ["course_id"])

    op.create_table(
        "lesson",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course_module.id"), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("content_type", lesson_content_type_enum, nullable=False),
        sa.Column("body_text", sa.Text(), nullable=True),
        sa.Column("video_media_asset_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("media_asset.id"), nullable=True),
        sa.Column("duration_seconds", sa.Integer(), nullable=True),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("is_preview_free", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("module_id", "sort_order", name="uq_lesson_module_sort"),
        sa.CheckConstraint("content_type != 'video' OR video_media_asset_id IS NOT NULL", name="ck_lesson_video_requires_media"),
    )
    op.create_index("ix_lesson_module_id", "lesson", ["module_id"])

    op.create_table(
        "enrollment",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("status", enrollment_status_enum, nullable=False, server_default="active"),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("user_id", "course_id", name="uq_enrollment_user_course"),
    )
    op.create_index("ix_enrollment_user_id", "enrollment", ["user_id"])
    op.create_index("ix_enrollment_course_id", "enrollment", ["course_id"])
    op.create_index("ix_enrollment_status", "enrollment", ["status"])

    op.create_table(
        "lesson_progress",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("enrollment_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("enrollment.id"), nullable=False),
        sa.Column("lesson_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("lesson.id"), nullable=False),
        sa.Column("status", progress_status_enum, nullable=False, server_default="not_started"),
        sa.Column("progress_percent", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.UniqueConstraint("enrollment_id", "lesson_id", name="uq_lesson_progress_enrollment_lesson"),
        sa.CheckConstraint("progress_percent >= 0 AND progress_percent <= 100", name="ck_lesson_progress_percent"),
    )
    op.create_index("ix_lesson_progress_enrollment_id", "lesson_progress", ["enrollment_id"])
    op.create_index("ix_lesson_progress_lesson_id", "lesson_progress", ["lesson_id"])
    op.create_index("ix_lesson_progress_status", "lesson_progress", ["status"])

    op.create_table(
        "quiz_question",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("lesson_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("lesson.id"), nullable=False),
        sa.Column("prompt", sa.Text(), nullable=False),
        sa.Column("choices", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'[]'::jsonb")),
        sa.Column("correct_index", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index("ix_quiz_question_lesson_id", "quiz_question", ["lesson_id"])

    op.create_table(
        "quiz_attempt",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("enrollment_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("enrollment.id"), nullable=False),
        sa.Column("lesson_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("lesson.id"), nullable=False),
        sa.Column("score_percent", sa.Integer(), nullable=False),
        sa.Column("passed", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("score_percent >= 0 AND score_percent <= 100", name="ck_quiz_attempt_score"),
    )
    op.create_index("ix_quiz_attempt_enrollment_id", "quiz_attempt", ["enrollment_id"])
    op.create_index("ix_quiz_attempt_lesson_id", "quiz_attempt", ["lesson_id"])

    op.create_table(
        "certificate",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("user_account.user_id"), nullable=False),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("certificate_code", sa.Text(), nullable=False),
        sa.Column("issued_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("pdf_storage_key", sa.Text(), nullable=True),
        sa.Column("metadata", postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.UniqueConstraint("user_id", "course_id", name="uq_certificate_user_course"),
    )
    op.create_index("ix_certificate_user_id", "certificate", ["user_id"])
    op.create_index("ix_certificate_course_id", "certificate", ["course_id"])
    op.create_index("ix_certificate_niche_id", "certificate", ["niche_id"])
    op.create_index("ix_certificate_certificate_code", "certificate", ["certificate_code"], unique=True)

    op.create_table(
        "niche_program_requirement",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("niche_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("niche.id"), nullable=False),
        sa.Column("tier_target", skill_tier_enum, nullable=False),
        sa.Column("requirement_type", requirement_type_enum, nullable=False, server_default="course"),
        sa.Column("course_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("course.id"), nullable=False),
        sa.Column("is_mandatory", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("niche_id", "tier_target", "course_id", name="uq_niche_requirement"),
    )
    op.create_index("ix_niche_program_requirement_niche_id", "niche_program_requirement", ["niche_id"])
    op.create_index("ix_niche_program_requirement_course_id", "niche_program_requirement", ["course_id"])


def downgrade() -> None:
    op.drop_index("ix_niche_program_requirement_course_id", table_name="niche_program_requirement")
    op.drop_index("ix_niche_program_requirement_niche_id", table_name="niche_program_requirement")
    op.drop_table("niche_program_requirement")

    op.drop_index("ix_certificate_certificate_code", table_name="certificate")
    op.drop_index("ix_certificate_niche_id", table_name="certificate")
    op.drop_index("ix_certificate_course_id", table_name="certificate")
    op.drop_index("ix_certificate_user_id", table_name="certificate")
    op.drop_table("certificate")

    op.drop_index("ix_quiz_attempt_lesson_id", table_name="quiz_attempt")
    op.drop_index("ix_quiz_attempt_enrollment_id", table_name="quiz_attempt")
    op.drop_table("quiz_attempt")

    op.drop_index("ix_quiz_question_lesson_id", table_name="quiz_question")
    op.drop_table("quiz_question")

    op.drop_index("ix_lesson_progress_status", table_name="lesson_progress")
    op.drop_index("ix_lesson_progress_lesson_id", table_name="lesson_progress")
    op.drop_index("ix_lesson_progress_enrollment_id", table_name="lesson_progress")
    op.drop_table("lesson_progress")

    op.drop_index("ix_enrollment_status", table_name="enrollment")
    op.drop_index("ix_enrollment_course_id", table_name="enrollment")
    op.drop_index("ix_enrollment_user_id", table_name="enrollment")
    op.drop_table("enrollment")

    op.drop_index("ix_lesson_module_id", table_name="lesson")
    op.drop_table("lesson")

    op.drop_index("ix_course_module_course_id", table_name="course_module")
    op.drop_table("course_module")

    op.drop_index("ix_course_instructor_published", table_name="course")
    op.drop_index("ix_course_niche_published", table_name="course")
    op.drop_index("ix_course_niche_id", table_name="course")
    op.drop_index("ix_course_instructor_user_id", table_name="course")
    op.drop_table("course")

    op.drop_index("ix_instructor_profile_status", table_name="instructor_profile")
    op.drop_table("instructor_profile")
