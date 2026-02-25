from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal
from typing import Any

from pydantic import BaseModel, Field

from app.models.learning import (
    CourseLevel,
    EnrollmentStatus,
    InstructorStatus,
    LessonContentType,
    ProgressStatus,
)
from app.models.niche import SkillTier


class CourseListItem(BaseModel):
    id: uuid.UUID
    instructor_user_id: uuid.UUID
    title: str
    summary: str | None = None
    niche_slug: str
    level: CourseLevel
    is_mandatory: bool
    is_published: bool
    price: Decimal | None = None
    currency: str
    estimated_minutes: int | None = None
    thumbnail_media_asset_id: uuid.UUID | None = None
    intro_video_media_asset_id: uuid.UUID | None = None


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
    lessons: list[LessonView] = Field(default_factory=list)


class CourseDetailResponse(BaseModel):
    course: CourseListItem
    modules: list[CourseModuleView] = Field(default_factory=list)
    is_enrolled: bool = False


class EnrollResponse(BaseModel):
    enrollment_id: uuid.UUID
    status: EnrollmentStatus
    started_at: datetime


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
    course_id: uuid.UUID
    course_title: str
    niche_slug: str
    certificate_code: str
    issued_at: datetime
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
