from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal
from typing import Any

from pydantic import BaseModel, Field

from app.models.learning import (
    CertificateType,
    CoursePricingMode,
    CourseStatus,
    CurriculumRequirementType,
    CourseLevel,
    CourseModuleType,
    CourseReviewDecision,
    EnrollmentStatus,
    InstructorStatus,
    LessonContentType,
    LearningPartnerStatus,
    ProgressStatus,
)
from app.models.niche import SkillTier


class CourseListItem(BaseModel):
    id: uuid.UUID
    instructor_user_id: uuid.UUID
    creator_user_id: uuid.UUID | None = None
    partner_id: uuid.UUID | None = None
    title: str
    title_key: str | None = None
    title_custom: str | None = None
    summary: str | None = None
    description_key: str | None = None
    description_custom: str | None = None
    localized_fields: dict[str, str | None] = Field(default_factory=dict)
    niche_slug: str
    niche_slugs: list[str] = Field(default_factory=list)
    language: str = "en-GB"
    level: CourseLevel
    is_mandatory: bool
    is_published: bool
    status: CourseStatus = CourseStatus.draft
    pricing_mode: CoursePricingMode = CoursePricingMode.free
    price: Decimal | None = None
    price_eur: Decimal | None = None
    currency: str
    estimated_minutes: int | None = None
    thumbnail_media_asset_id: uuid.UUID | None = None
    intro_video_media_asset_id: uuid.UUID | None = None
    approved_at: datetime | None = None


class CourseListResponse(BaseModel):
    total: int
    items: list[CourseListItem]


class LessonView(BaseModel):
    id: uuid.UUID
    module_id: uuid.UUID
    title: str
    content_type: LessonContentType
    body_text: str | None = None
    video_media_asset_id: uuid.UUID | None = None
    duration_seconds: int | None = None
    sort_order: int
    is_preview_free: bool
    has_quiz: bool = False


class CourseModuleView(BaseModel):
    id: uuid.UUID
    course_id: uuid.UUID
    title: str
    sort_order: int
    type: CourseModuleType = CourseModuleType.video
    mux_asset_id: str | None = None
    duration_seconds: int | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)
    lessons: list[LessonView] = Field(default_factory=list)


class CourseDetailResponse(BaseModel):
    course: CourseListItem
    modules: list[CourseModuleView] = Field(default_factory=list)
    is_enrolled: bool = False


class EnrollResponse(BaseModel):
    enrollment_id: uuid.UUID
    status: EnrollmentStatus
    started_at: datetime
    paid: bool = False
    stripe_payment_intent_id: str | None = None


class EnrollmentView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    course_id: uuid.UUID
    course_title: str
    niche_slug: str
    status: EnrollmentStatus
    started_at: datetime
    completed_at: datetime | None = None


class MyEnrollmentsResponse(BaseModel):
    total: int
    items: list[EnrollmentView]


class UpdateLessonProgressRequest(BaseModel):
    status: ProgressStatus
    progress_percent: int = Field(ge=0, le=100)


class UpdateLessonProgressResponse(BaseModel):
    enrollment_id: uuid.UUID
    lesson_id: uuid.UUID
    status: ProgressStatus
    progress_percent: int
    enrollment_status: EnrollmentStatus
    enrollment_completed_at: datetime | None = None
    certificate_issued: bool = False


class QuizAttemptRequest(BaseModel):
    answers: list[int] = Field(default_factory=list)


class QuizAttemptResponse(BaseModel):
    score_percent: int
    passed: bool


class CertificateView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    certificate_type: CertificateType = CertificateType.course
    course_id: uuid.UUID | None = None
    curriculum_path_id: uuid.UUID | None = None
    course_title: str | None = None
    niche_slug: str | None = None
    certificate_code: str
    verification_code: str | None = None
    issued_at: datetime
    revoked_at: datetime | None = None
    pdf_storage_key: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class MyCertificatesResponse(BaseModel):
    total: int
    items: list[CertificateView]


class InstructorCourseCreateRequest(BaseModel):
    title: str
    niche_slug: str
    level: CourseLevel
    summary: str | None = None
    price: Decimal | None = None
    currency: str = "EUR"
    is_mandatory: bool = False
    thumbnail_media_asset_id: uuid.UUID | None = None
    intro_video_media_asset_id: uuid.UUID | None = None
    estimated_minutes: int | None = None
    language: str = "en-GB"
    niche_slugs: list[str] = Field(default_factory=list)
    pricing_mode: CoursePricingMode | None = None
    partner_id: uuid.UUID | None = None


class InstructorCourseUpdateRequest(BaseModel):
    title: str | None = None
    summary: str | None = None
    level: CourseLevel | None = None
    is_mandatory: bool | None = None
    price: Decimal | None = None
    currency: str | None = None
    thumbnail_media_asset_id: uuid.UUID | None = None
    intro_video_media_asset_id: uuid.UUID | None = None
    estimated_minutes: int | None = None


class CreateModuleRequest(BaseModel):
    title: str
    sort_order: int
    type: CourseModuleType = CourseModuleType.video
    mux_asset_id: str | None = None
    duration_seconds: int | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class CreateLessonRequest(BaseModel):
    title: str
    content_type: LessonContentType
    body_text: str | None = None
    video_media_asset_id: uuid.UUID | None = None
    duration_seconds: int | None = None
    sort_order: int
    is_preview_free: bool = False


class AdminSetInstructorStatusRequest(BaseModel):
    bio: str | None = None
    expertise: list[str] = Field(default_factory=list)
    reason: str | None = None


class AdminCourseListResponse(BaseModel):
    total: int
    items: list[CourseListItem]


class AdminNicheRequirementsUpsertRequest(BaseModel):
    tier_target: SkillTier
    course_ids: list[uuid.UUID] = Field(default_factory=list)
    is_mandatory: bool = True


class AdminNicheRequirementsUpsertResponse(BaseModel):
    niche_slug: str
    tier_target: SkillTier
    count: int


class InstructorProfileView(BaseModel):
    user_id: uuid.UUID
    status: InstructorStatus
    bio: str | None = None
    expertise: list[str] = Field(default_factory=list)
    approved_by: uuid.UUID | None = None
    approved_at: datetime | None = None
    rejected_reason: str | None = None
    created_at: datetime
    updated_at: datetime


class CurriculumPathView(BaseModel):
    id: uuid.UUID
    niche_slug: str
    name: str
    description: str | None = None
    is_active: bool


class CurriculumRequirementView(BaseModel):
    id: uuid.UUID
    curriculum_path_id: uuid.UUID
    course_id: uuid.UUID
    requirement_type: CurriculumRequirementType
    min_score_percent: int
    order_index: int


class LearningCourseListResponse(BaseModel):
    total: int
    items: list[CourseListItem]


class LearningCourseDetailResponse(BaseModel):
    course: CourseListItem
    modules: list[CourseModuleView] = Field(default_factory=list)
    enrolled: bool = False


class EnrollCourseRequest(BaseModel):
    return_url: str | None = None


class ModuleProgressRequest(BaseModel):
    watch_seconds_delta: int = Field(ge=0, le=3600)
    position_seconds: int = Field(ge=0)


class ModuleProgressView(BaseModel):
    enrollment_id: uuid.UUID
    module_id: uuid.UUID
    status: ProgressStatus
    watch_seconds: int
    last_position_seconds: int
    quiz_score_percent: int | None = None


class ModuleQuizRequest(BaseModel):
    answers: list[int] = Field(default_factory=list)


class ModuleQuizResponse(BaseModel):
    score_percent: int
    passed: bool


class PublicCertificateView(BaseModel):
    verification_code: str
    certificate_type: CertificateType
    issued_at: datetime
    revoked_at: datetime | None = None
    user_id: uuid.UUID
    course_id: uuid.UUID | None = None
    curriculum_path_id: uuid.UUID | None = None
    niche_slug: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class LearningPartnerView(BaseModel):
    id: uuid.UUID
    name: str
    brand: dict[str, Any] = Field(default_factory=dict)
    contact_email: str | None = None
    status: LearningPartnerStatus
    payout_account_ref: str | None = None


class LearningPartnerUpsertRequest(BaseModel):
    id: uuid.UUID | None = None
    name: str
    brand: dict[str, Any] = Field(default_factory=dict)
    contact_email: str | None = None
    status: LearningPartnerStatus = LearningPartnerStatus.active
    payout_account_ref: str | None = None


class PartnerCourseCreateRequest(BaseModel):
    partner_id: uuid.UUID | None = None
    title_custom: str
    description_custom: str | None = None
    language: str = "en-GB"
    niche_slugs: list[str] = Field(default_factory=list)
    level: CourseLevel = CourseLevel.beginner
    pricing_mode: CoursePricingMode = CoursePricingMode.free
    price_eur: Decimal | None = None
    currency: str = "EUR"


class PartnerCourseUpdateRequest(BaseModel):
    title_custom: str | None = None
    description_custom: str | None = None
    language: str | None = None
    niche_slugs: list[str] | None = None
    level: CourseLevel | None = None
    pricing_mode: CoursePricingMode | None = None
    price_eur: Decimal | None = None
    currency: str | None = None


class AdminCourseReviewRequest(BaseModel):
    decision: CourseReviewDecision
    notes: str | None = None


class LearningSalesItem(BaseModel):
    id: uuid.UUID
    course_id: uuid.UUID
    user_id: uuid.UUID
    gross_eur: Decimal
    platform_fee_eur: Decimal
    partner_net_eur: Decimal
    stripe_payment_intent_id: str
    status: str
    created_at: datetime


class LearningFeePolicyView(BaseModel):
    id: uuid.UUID
    platform_fee_percent: int
    mux_cost_reserve_percent: int
    metadata: dict[str, Any] = Field(default_factory=dict)
    updated_at: datetime


class LearningFeePolicyUpsertRequest(BaseModel):
    platform_fee_percent: int = Field(ge=0, le=100)
    mux_cost_reserve_percent: int = Field(ge=0, le=100)
    metadata: dict[str, Any] = Field(default_factory=dict)
