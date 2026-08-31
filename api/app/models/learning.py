import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import CHAR, CheckConstraint, DateTime, Enum, ForeignKey, Index, Integer, JSON, Numeric, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.models.media import Base
from app.models.niche import SkillTier


class InstructorStatus(str, enum.Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class CourseLevel(str, enum.Enum):
    beginner = "beginner"
    intermediate = "intermediate"
    advanced = "advanced"
    master = "master"


class LessonContentType(str, enum.Enum):
    text = "text"
    video = "video"
    quiz = "quiz"


class EnrollmentStatus(str, enum.Enum):
    enrolled = "enrolled"
    active = "active"
    completed = "completed"
    revoked = "revoked"
    refunded = "refunded"
    cancelled = "cancelled"


class ProgressStatus(str, enum.Enum):
    not_started = "not_started"
    in_progress = "in_progress"
    completed = "completed"


class RequirementType(str, enum.Enum):
    course = "course"


class LearningPartnerStatus(str, enum.Enum):
    active = "active"
    suspended = "suspended"


class CoursePricingMode(str, enum.Enum):
    free = "free"
    paid = "paid"


class CourseStatus(str, enum.Enum):
    draft = "draft"
    submitted = "submitted"
    approved = "approved"
    rejected = "rejected"
    delisted = "delisted"


class CourseModuleType(str, enum.Enum):
    video = "video"
    quiz = "quiz"
    assignment = "assignment"
    reading = "reading"


class CurriculumRequirementType(str, enum.Enum):
    mandatory = "mandatory"
    optional = "optional"


class CertificateType(str, enum.Enum):
    course = "course"
    curriculum = "curriculum"


class CourseSaleStatus(str, enum.Enum):
    paid = "paid"
    refunded = "refunded"


class CourseReviewDecision(str, enum.Enum):
    approved = "approved"
    rejected = "rejected"


class LearningFeePolicy(Base):
    __tablename__ = "learning_fee_policy"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    platform_fee_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=30)
    mux_cost_reserve_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=10)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class LearningPartner(Base):
    __tablename__ = "learning_partner"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    brand: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    contact_email: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[LearningPartnerStatus] = mapped_column(
        Enum(LearningPartnerStatus, name="learning_partner_status", native_enum=False),
        nullable=False,
        default=LearningPartnerStatus.active,
        index=True,
    )
    payout_account_ref: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class InstructorProfile(Base):
    __tablename__ = "instructor_profile"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), primary_key=True)
    status: Mapped[InstructorStatus] = mapped_column(
        Enum(InstructorStatus, name="instructor_status", native_enum=False),
        nullable=False,
        default=InstructorStatus.pending,
        index=True,
    )
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    expertise: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    approved_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), nullable=True)
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    rejected_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class Course(Base):
    __tablename__ = "course"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    instructor_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    creator_user_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=True, index=True)
    partner_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("learning_partner.id"), nullable=True, index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    title_key: Mapped[str | None] = mapped_column(Text, nullable=True)
    title_custom: Mapped[str | None] = mapped_column(Text, nullable=True)
    summary: Mapped[str | None] = mapped_column(Text, nullable=True)
    description_key: Mapped[str | None] = mapped_column(Text, nullable=True)
    description_custom: Mapped[str | None] = mapped_column(Text, nullable=True)
    language: Mapped[str] = mapped_column(Text, nullable=False, default="en-GB")
    niche_slugs: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    level: Mapped[CourseLevel] = mapped_column(Enum(CourseLevel, name="course_level", native_enum=False), nullable=False)
    pricing_mode: Mapped[CoursePricingMode] = mapped_column(
        Enum(CoursePricingMode, name="course_pricing_mode", native_enum=False),
        nullable=False,
        default=CoursePricingMode.free,
        index=True,
    )
    status: Mapped[CourseStatus] = mapped_column(
        Enum(CourseStatus, name="course_status", native_enum=False),
        nullable=False,
        default=CourseStatus.draft,
        index=True,
    )
    is_mandatory: Mapped[bool] = mapped_column(nullable=False, default=False)
    is_published: Mapped[bool] = mapped_column(nullable=False, default=False)
    price: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    price_eur: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    currency: Mapped[str] = mapped_column(CHAR(3), nullable=False, default="EUR")
    thumbnail_media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=True)
    intro_video_media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=True)
    estimated_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    mux_metadata: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class CourseModule(Base):
    __tablename__ = "course_module"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False)
    type: Mapped[CourseModuleType] = mapped_column(
        Enum(CourseModuleType, name="course_module_type", native_enum=False),
        nullable=False,
        default=CourseModuleType.video,
    )
    mux_asset_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    duration_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("course_id", "sort_order", name="uq_course_module_course_sort"),)


class Lesson(Base):
    __tablename__ = "lesson"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    module_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course_module.id"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    content_type: Mapped[LessonContentType] = mapped_column(
        Enum(LessonContentType, name="lesson_content_type", native_enum=False),
        nullable=False,
    )
    body_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    video_media_asset_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("media_asset.id"), nullable=True)
    duration_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False)
    is_preview_free: Mapped[bool] = mapped_column(nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (
        UniqueConstraint("module_id", "sort_order", name="uq_lesson_module_sort"),
        CheckConstraint("content_type != 'video' OR video_media_asset_id IS NOT NULL", name="ck_lesson_video_requires_media"),
    )


class Enrollment(Base):
    __tablename__ = "enrollment"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=False, index=True)
    status: Mapped[EnrollmentStatus] = mapped_column(
        Enum(EnrollmentStatus, name="enrollment_status", native_enum=False),
        nullable=False,
        default=EnrollmentStatus.enrolled,
        index=True,
    )
    paid: Mapped[bool] = mapped_column(nullable=False, default=False)
    stripe_payment_intent_id: Mapped[str | None] = mapped_column(Text, nullable=True, index=True)
    enrolled_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    __table_args__ = (UniqueConstraint("user_id", "course_id", name="uq_enrollment_user_course"),)


class LessonProgress(Base):
    __tablename__ = "lesson_progress"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    enrollment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("enrollment.id"), nullable=False, index=True)
    lesson_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("lesson.id"), nullable=False, index=True)
    status: Mapped[ProgressStatus] = mapped_column(
        Enum(ProgressStatus, name="progress_status", native_enum=False),
        nullable=False,
        default=ProgressStatus.not_started,
        index=True,
    )
    progress_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)

    __table_args__ = (
        UniqueConstraint("enrollment_id", "lesson_id", name="uq_lesson_progress_enrollment_lesson"),
        CheckConstraint("progress_percent >= 0 AND progress_percent <= 100", name="ck_lesson_progress_percent"),
    )


class QuizQuestion(Base):
    __tablename__ = "quiz_question"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    lesson_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("lesson.id"), nullable=False, index=True)
    prompt: Mapped[str] = mapped_column(Text, nullable=False)
    choices: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    correct_index: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )


class QuizAttempt(Base):
    __tablename__ = "quiz_attempt"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    enrollment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("enrollment.id"), nullable=False, index=True)
    lesson_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("lesson.id"), nullable=False, index=True)
    score_percent: Mapped[int] = mapped_column(Integer, nullable=False)
    passed: Mapped[bool] = mapped_column(nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (CheckConstraint("score_percent >= 0 AND score_percent <= 100", name="ck_quiz_attempt_score"),)


class Certificate(Base):
    __tablename__ = "certificate"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    certificate_type: Mapped[CertificateType] = mapped_column(
        Enum(CertificateType, name="certificate_type", native_enum=False),
        nullable=False,
        default=CertificateType.course,
        index=True,
    )
    course_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=True, index=True)
    curriculum_path_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("curriculum_path.id"), nullable=True, index=True)
    niche_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=True, index=True)
    niche_slug: Mapped[str | None] = mapped_column(Text, nullable=True)
    certificate_code: Mapped[str] = mapped_column(Text, nullable=False, unique=True, index=True)
    verification_code: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True, index=True)
    issued_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    pdf_storage_key: Mapped[str | None] = mapped_column(Text, nullable=True)
    meta: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)

    __table_args__ = (
        UniqueConstraint("user_id", "course_id", name="uq_certificate_user_course"),
        CheckConstraint(
            "(certificate_type = 'course' AND course_id IS NOT NULL) "
            "OR (certificate_type = 'curriculum' AND curriculum_path_id IS NOT NULL)",
            name="ck_certificate_type_target",
        ),
    )


class NicheProgramRequirement(Base):
    __tablename__ = "niche_program_requirement"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("niche.id"), nullable=False, index=True)
    tier_target: Mapped[SkillTier] = mapped_column(
        Enum(SkillTier, name="skill_tier", native_enum=False),
        nullable=False,
    )
    requirement_type: Mapped[RequirementType] = mapped_column(
        Enum(RequirementType, name="requirement_type", native_enum=False),
        nullable=False,
        default=RequirementType.course,
    )
    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=False, index=True)
    is_mandatory: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    __table_args__ = (UniqueConstraint("niche_id", "tier_target", "course_id", name="uq_niche_requirement"),)


class CurriculumPath(Base):
    __tablename__ = "curriculum_path"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    niche_slug: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )


class CurriculumRequirement(Base):
    __tablename__ = "curriculum_requirement"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    curriculum_path_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("curriculum_path.id"), nullable=False, index=True
    )
    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=False, index=True)
    requirement_type: Mapped[CurriculumRequirementType] = mapped_column(
        Enum(CurriculumRequirementType, name="curriculum_requirement_type", native_enum=False),
        nullable=False,
    )
    min_score_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=70)
    order_index: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    __table_args__ = (UniqueConstraint("curriculum_path_id", "course_id", name="uq_curriculum_path_course"),)


class CourseQuiz(Base):
    __tablename__ = "course_quiz"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    module_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course_module.id"), nullable=False, unique=True, index=True)
    questions: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    pass_score_percent: Mapped[int] = mapped_column(Integer, nullable=False, default=70)


class ModuleProgress(Base):
    __tablename__ = "module_progress"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    enrollment_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("enrollment.id"), nullable=False, index=True)
    module_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course_module.id"), nullable=False, index=True)
    status: Mapped[ProgressStatus] = mapped_column(
        Enum(ProgressStatus, name="progress_status", native_enum=False),
        nullable=False,
        default=ProgressStatus.not_started,
        index=True,
    )
    watch_seconds: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    last_position_seconds: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    quiz_score_percent: Mapped[int | None] = mapped_column(Integer, nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
    __table_args__ = (UniqueConstraint("enrollment_id", "module_id", name="uq_module_progress_enrollment_module"),)


class CourseSale(Base):
    __tablename__ = "course_sale"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=False, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True)
    gross_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    platform_fee_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    partner_net_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    stripe_payment_intent_id: Mapped[str] = mapped_column(Text, nullable=False, index=True)
    status: Mapped[CourseSaleStatus] = mapped_column(
        Enum(CourseSaleStatus, name="course_sale_status", native_enum=False),
        nullable=False,
        default=CourseSaleStatus.paid,
    )
    mux_minutes_consumed: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    mux_cost_reserve_eur: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=Decimal("0.00"))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )


class CourseReview(Base):
    __tablename__ = "course_review"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("course.id"), nullable=False, index=True)
    reviewer_admin_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("user_account.user_id"), nullable=False, index=True
    )
    decision: Mapped[CourseReviewDecision] = mapped_column(
        Enum(CourseReviewDecision, name="course_review_decision", native_enum=False),
        nullable=False,
    )
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc)
    )


Index("ix_course_niche_published", Course.niche_id, Course.is_published)
Index("ix_course_instructor_published", Course.instructor_user_id, Course.is_published)
Index("ix_course_status", Course.status)
Index("ix_course_partner_status", Course.partner_id, Course.status)
