from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_session, get_locale, get_optional_current_user, require_not_banned
from app.core.errors import APIError
from app.models.learning import (
    Certificate,
    Course,
    CourseLevel,
    CourseModule,
    Enrollment,
    EnrollmentStatus,
    Lesson,
    LessonContentType,
    ProgressStatus,
    QuizAttempt,
    QuizQuestion,
)
from app.models.niche import Niche
from app.schemas.learning import (
    CourseDetailResponse,
    CourseListItem,
    CourseListResponse,
    CourseModuleView,
    CreateLessonRequest,
    CreateModuleRequest,
    EnrollmentView,
    EnrollResponse,
    InstructorCourseCreateRequest,
    InstructorCourseUpdateRequest,
    LessonView,
    MyCertificatesResponse,
    MyEnrollmentsResponse,
    QuizAttemptRequest,
    QuizAttemptResponse,
    UpdateLessonProgressRequest,
    UpdateLessonProgressResponse,
)
from app.schemas.media import CurrentUser
from app.services.authz import enforce_not_banned
from app.services.learning import (
    assert_course_publishable,
    evaluate_enrollment_completion,
    grade_quiz_answers,
    queue_or_issue_certificate,
    require_approved_instructor,
    upsert_lesson_progress,
    validate_course_media_ownership,
    validate_lesson_payload,
)
from app.services.niche_catalog import ensure_initial_niches, get_niche_by_slug
from app.services.search_indexing import enqueue_course_index_upsert
from app.services.i18n import get_localized_fields

router = APIRouter(tags=["courses"])


@router.get("/courses", response_model=CourseListResponse)
def list_courses(
    niche_slug: str | None = None,
    level: CourseLevel | None = None,
    is_mandatory: bool | None = None,
    free_only: bool = False,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_read_session),
) -> CourseListResponse:
    ensure_initial_niches(db)
    stmt = select(Course).where(Course.is_published.is_(True))
    if niche_slug:
        niche = get_niche_by_slug(db, niche_slug)
        if not niche:
            raise APIError(code="validation_error", message="Unknown niche slug", status_code=422)
        stmt = stmt.where(Course.niche_id == niche.id)
    if level:
        stmt = stmt.where(Course.level == level)
    if is_mandatory is not None:
        stmt = stmt.where(Course.is_mandatory.is_(is_mandatory))
    if free_only:
        stmt = stmt.where(Course.price.is_(None))

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(stmt.order_by(Course.updated_at.desc()).offset(offset).limit(limit)).scalars().all()
    niche_map = _niche_slug_map(db, [item.niche_id for item in rows])
    return CourseListResponse(total=total, items=[_course_item(db, item, niche_map.get(item.niche_id, ""), locale=locale) for item in rows])


@router.get("/courses/{course_id}", response_model=CourseDetailResponse)
def get_course(
    course_id: uuid.UUID,
    user: CurrentUser | None = Depends(get_optional_current_user),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_read_session),
) -> CourseDetailResponse:
    if user:
        enforce_not_banned(db, user.user_id)
    course = db.get(Course, course_id)
    if not course or not course.is_published:
        raise APIError(code="not_found", message="Course not found", status_code=404)

    enrolled = False
    if user:
        enrolled = (
            db.execute(
                select(Enrollment).where(
                    Enrollment.user_id == user.user_id,
                    Enrollment.course_id == course.id,
                    Enrollment.status.in_([EnrollmentStatus.active, EnrollmentStatus.completed]),
                )
            ).scalar_one_or_none()
            is not None
        )

    modules = db.execute(
        select(CourseModule).where(CourseModule.course_id == course.id).order_by(CourseModule.sort_order.asc())
    ).scalars().all()
    module_ids = [item.id for item in modules]
    lessons = (
        db.execute(select(Lesson).where(Lesson.module_id.in_(module_ids)).order_by(Lesson.sort_order.asc())).scalars().all()
        if module_ids
        else []
    )
    quiz_lesson_ids = set(db.execute(select(QuizQuestion.lesson_id).where(QuizQuestion.lesson_id.in_([l.id for l in lessons]))).scalars().all())
    by_module: dict[uuid.UUID, list[LessonView]] = {m.id: [] for m in modules}
    for lesson in lessons:
        can_view_full = enrolled or lesson.is_preview_free
        by_module.setdefault(lesson.module_id, []).append(
            LessonView(
                id=lesson.id,
                module_id=lesson.module_id,
                title=lesson.title,
                content_type=lesson.content_type,
                body_text=lesson.body_text if can_view_full else None,
                video_media_asset_id=lesson.video_media_asset_id if can_view_full else None,
                duration_seconds=lesson.duration_seconds,
                sort_order=lesson.sort_order,
                is_preview_free=lesson.is_preview_free,
                has_quiz=lesson.id in quiz_lesson_ids,
            )
        )

    niche = db.get(Niche, course.niche_id)
    module_views = [
        CourseModuleView(
            id=module.id,
            course_id=module.course_id,
            title=module.title,
            sort_order=module.sort_order,
            lessons=by_module.get(module.id, []),
        )
        for module in modules
    ]
    return CourseDetailResponse(
        course=_course_item(db, course, niche.slug if niche else "", locale=locale),
        modules=module_views,
        is_enrolled=enrolled,
    )


@router.post("/courses/{course_id}/enroll", response_model=EnrollResponse)
def enroll_course(
    course_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EnrollResponse:
    course = db.get(Course, course_id)
    if not course or not course.is_published:
        raise APIError(code="not_found", message="Course not found", status_code=404)

    enrollment = db.execute(
        select(Enrollment).where(Enrollment.user_id == user.user_id, Enrollment.course_id == course_id)
    ).scalar_one_or_none()
    if not enrollment:
        enrollment = Enrollment(
            user_id=user.user_id,
            course_id=course_id,
            status=EnrollmentStatus.active,
            started_at=datetime.now(timezone.utc),
        )
        db.add(enrollment)
        db.flush()
    db.commit()
    return EnrollResponse(enrollment_id=enrollment.id, status=enrollment.status, started_at=enrollment.started_at)


@router.get("/me/enrollments", response_model=MyEnrollmentsResponse)
def my_enrollments(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MyEnrollmentsResponse:
    rows = db.execute(
        select(Enrollment, Course, Niche)
        .join(Course, Course.id == Enrollment.course_id)
        .join(Niche, Niche.id == Course.niche_id)
        .where(Enrollment.user_id == user.user_id)
        .order_by(Enrollment.created_at.desc())
    ).all()
    items = [
        EnrollmentView(
            id=enrollment.id,
            user_id=enrollment.user_id,
            course_id=course.id,
            course_title=course.title,
            niche_slug=niche.slug,
            status=enrollment.status,
            started_at=enrollment.started_at,
            completed_at=enrollment.completed_at,
        )
        for enrollment, course, niche in rows
    ]
    return MyEnrollmentsResponse(total=len(items), items=items)


@router.post("/enrollments/{enrollment_id}/lessons/{lesson_id}/progress", response_model=UpdateLessonProgressResponse)
def update_lesson_progress(
    enrollment_id: uuid.UUID,
    lesson_id: uuid.UUID,
    body: UpdateLessonProgressRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UpdateLessonProgressResponse:
    enrollment = db.get(Enrollment, enrollment_id)
    if not enrollment:
        raise APIError(code="not_found", message="Enrollment not found", status_code=404)
    if enrollment.user_id != user.user_id:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)
    if enrollment.status not in {EnrollmentStatus.active, EnrollmentStatus.completed}:
        raise APIError(code="invalid_state", message="Enrollment is not active", status_code=409)

    course = db.get(Course, enrollment.course_id)
    if not course:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    lesson = db.get(Lesson, lesson_id)
    if not lesson:
        raise APIError(code="not_found", message="Lesson not found", status_code=404)

    module = db.get(CourseModule, lesson.module_id)
    if not module or module.course_id != course.id:
        raise APIError(code="validation_error", message="Lesson does not belong to enrollment course", status_code=422)

    progress = upsert_lesson_progress(db, enrollment, lesson, body.status, body.progress_percent)

    certificate_issued = False
    if evaluate_enrollment_completion(db, enrollment):
        if enrollment.status != EnrollmentStatus.completed:
            enrollment.status = EnrollmentStatus.completed
            enrollment.completed_at = datetime.now(timezone.utc)
            enrollment.updated_at = datetime.now(timezone.utc)
            certificate_issued = queue_or_issue_certificate(db, enrollment.id)
    db.commit()
    return UpdateLessonProgressResponse(
        enrollment_id=enrollment.id,
        lesson_id=lesson.id,
        status=progress.status,
        progress_percent=progress.progress_percent,
        enrollment_status=enrollment.status,
        enrollment_completed_at=enrollment.completed_at,
        certificate_issued=certificate_issued,
    )


@router.post("/enrollments/{enrollment_id}/lessons/{lesson_id}/quiz-attempt", response_model=QuizAttemptResponse)
def submit_quiz_attempt(
    enrollment_id: uuid.UUID,
    lesson_id: uuid.UUID,
    body: QuizAttemptRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> QuizAttemptResponse:
    enrollment = db.get(Enrollment, enrollment_id)
    if not enrollment:
        raise APIError(code="not_found", message="Enrollment not found", status_code=404)
    if enrollment.user_id != user.user_id:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)
    if enrollment.status not in {EnrollmentStatus.active, EnrollmentStatus.completed}:
        raise APIError(code="invalid_state", message="Enrollment is not active", status_code=409)
    lesson = db.get(Lesson, lesson_id)
    if not lesson:
        raise APIError(code="not_found", message="Lesson not found", status_code=404)

    module = db.get(CourseModule, lesson.module_id)
    if not module or module.course_id != enrollment.course_id:
        raise APIError(code="validation_error", message="Lesson does not belong to enrollment course", status_code=422)

    questions = db.execute(
        select(QuizQuestion).where(QuizQuestion.lesson_id == lesson_id).order_by(QuizQuestion.created_at.asc())
    ).scalars().all()
    score_percent, passed = grade_quiz_answers(questions, body.answers)
    db.add(
        QuizAttempt(
            enrollment_id=enrollment.id,
            lesson_id=lesson.id,
            score_percent=score_percent,
            passed=passed,
        )
    )
    db.flush()
    if evaluate_enrollment_completion(db, enrollment):
        if enrollment.status != EnrollmentStatus.completed:
            enrollment.status = EnrollmentStatus.completed
            enrollment.completed_at = datetime.now(timezone.utc)
            queue_or_issue_certificate(db, enrollment.id)
    db.commit()
    return QuizAttemptResponse(score_percent=score_percent, passed=passed)


@router.get("/me/certificates", response_model=MyCertificatesResponse)
def my_certificates(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MyCertificatesResponse:
    from app.schemas.learning import CertificateView

    rows = db.execute(
        select(Certificate, Course, Niche)
        .join(Course, Course.id == Certificate.course_id)
        .join(Niche, Niche.id == Certificate.niche_id)
        .where(Certificate.user_id == user.user_id)
        .order_by(Certificate.issued_at.desc())
    ).all()
    items = [
        CertificateView(
            id=certificate.id,
            user_id=certificate.user_id,
            course_id=certificate.course_id,
            course_title=course.title,
            niche_slug=niche.slug,
            certificate_code=certificate.certificate_code,
            issued_at=certificate.issued_at,
            pdf_storage_key=certificate.pdf_storage_key,
            metadata=certificate.meta or {},
        )
        for certificate, course, niche in rows
    ]
    return MyCertificatesResponse(total=len(items), items=items)


@router.post("/instructor/courses", response_model=CourseListItem)
def instructor_create_course(
    body: InstructorCourseCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    ensure_initial_niches(db)
    profile = require_approved_instructor(db, user.user_id)
    niche = get_niche_by_slug(db, body.niche_slug)
    if not niche or not niche.is_active:
        raise APIError(code="validation_error", message="Unknown niche", status_code=422)

    if body.price is not None and body.price < 0:
        raise APIError(code="validation_error", message="price must be >= 0", status_code=422)
    validate_course_media_ownership(db, user.user_id, body.thumbnail_media_asset_id, must_be_video=False)
    validate_course_media_ownership(db, user.user_id, body.intro_video_media_asset_id, must_be_video=True)

    course = Course(
        instructor_user_id=user.user_id,
        title=body.title,
        summary=body.summary,
        niche_id=niche.id,
        level=body.level,
        is_mandatory=body.is_mandatory,
        is_published=False,
        price=(body.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP) if body.price is not None else None),
        currency=body.currency.upper(),
        thumbnail_media_asset_id=body.thumbnail_media_asset_id,
        intro_video_media_asset_id=body.intro_video_media_asset_id,
        estimated_minutes=body.estimated_minutes,
    )
    db.add(course)
    db.flush()
    enqueue_course_index_upsert(db, course.id, idempotency_suffix="draft")
    db.commit()
    db.refresh(course)
    return _course_item(db, course, niche.slug, locale="en-GB")


@router.put("/instructor/courses/{course_id}", response_model=CourseListItem)
def instructor_update_course(
    course_id: uuid.UUID,
    body: InstructorCourseUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    require_approved_instructor(db, user.user_id)
    course = db.get(Course, course_id)
    if not course or course.instructor_user_id != user.user_id:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    if course.is_published:
        raise APIError(code="validation_error", message="Only draft courses can be edited", status_code=409)

    for field in ["title", "summary", "level", "is_mandatory", "estimated_minutes"]:
        value = getattr(body, field)
        if value is not None:
            setattr(course, field, value)

    if body.price is not None:
        if body.price < 0:
            raise APIError(code="validation_error", message="price must be >= 0", status_code=422)
        course.price = body.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    if body.currency is not None:
        course.currency = body.currency.upper()
    if body.thumbnail_media_asset_id is not None:
        validate_course_media_ownership(db, user.user_id, body.thumbnail_media_asset_id, must_be_video=False)
        course.thumbnail_media_asset_id = body.thumbnail_media_asset_id
    if body.intro_video_media_asset_id is not None:
        validate_course_media_ownership(db, user.user_id, body.intro_video_media_asset_id, must_be_video=True)
        course.intro_video_media_asset_id = body.intro_video_media_asset_id

    course.updated_at = datetime.now(timezone.utc)
    enqueue_course_index_upsert(db, course.id, idempotency_suffix=course.updated_at.isoformat())
    db.commit()
    db.refresh(course)
    niche = db.get(Niche, course.niche_id)
    return _course_item(db, course, niche.slug if niche else "", locale="en-GB")


@router.post("/instructor/courses/{course_id}/modules", response_model=CourseModuleView)
def instructor_create_module(
    course_id: uuid.UUID,
    body: CreateModuleRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseModuleView:
    require_approved_instructor(db, user.user_id)
    course = db.get(Course, course_id)
    if not course or course.instructor_user_id != user.user_id:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    if course.is_published:
        raise APIError(code="validation_error", message="Only draft courses can be edited", status_code=409)

    existing = db.execute(
        select(CourseModule).where(CourseModule.course_id == course.id, CourseModule.sort_order == body.sort_order)
    ).scalar_one_or_none()
    if existing:
        raise APIError(code="validation_error", message="sort_order already exists in course", status_code=422)
    module = CourseModule(course_id=course.id, title=body.title, sort_order=body.sort_order)
    db.add(module)
    db.commit()
    db.refresh(module)
    return CourseModuleView(id=module.id, course_id=module.course_id, title=module.title, sort_order=module.sort_order, lessons=[])


@router.post("/instructor/modules/{module_id}/lessons", response_model=LessonView)
def instructor_create_lesson(
    module_id: uuid.UUID,
    body: CreateLessonRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LessonView:
    require_approved_instructor(db, user.user_id)
    module = db.get(CourseModule, module_id)
    if not module:
        raise APIError(code="not_found", message="Module not found", status_code=404)
    course = db.get(Course, module.course_id)
    if not course or course.instructor_user_id != user.user_id:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)
    if course.is_published:
        raise APIError(code="validation_error", message="Only draft courses can be edited", status_code=409)

    validate_lesson_payload(body.content_type, body.video_media_asset_id)
    if body.content_type == LessonContentType.video:
        validate_course_media_ownership(db, user.user_id, body.video_media_asset_id, must_be_video=True)
        if body.duration_seconds and body.duration_seconds > 900:
            raise APIError(code="validation_error", message="Video lesson exceeds short-video policy", status_code=422)

    existing = db.execute(
        select(Lesson).where(Lesson.module_id == module.id, Lesson.sort_order == body.sort_order)
    ).scalar_one_or_none()
    if existing:
        raise APIError(code="validation_error", message="sort_order already exists in module", status_code=422)

    lesson = Lesson(
        module_id=module.id,
        title=body.title,
        content_type=body.content_type,
        body_text=body.body_text,
        video_media_asset_id=body.video_media_asset_id,
        duration_seconds=body.duration_seconds,
        sort_order=body.sort_order,
        is_preview_free=body.is_preview_free,
    )
    db.add(lesson)
    db.commit()
    db.refresh(lesson)
    return LessonView(
        id=lesson.id,
        module_id=lesson.module_id,
        title=lesson.title,
        content_type=lesson.content_type,
        body_text=lesson.body_text,
        video_media_asset_id=lesson.video_media_asset_id,
        duration_seconds=lesson.duration_seconds,
        sort_order=lesson.sort_order,
        is_preview_free=lesson.is_preview_free,
        has_quiz=False,
    )


@router.post("/instructor/courses/{course_id}/publish", response_model=CourseListItem)
def instructor_publish_course(
    course_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    require_approved_instructor(db, user.user_id)
    course = db.get(Course, course_id)
    if not course or course.instructor_user_id != user.user_id:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    assert_course_publishable(db, course, user.user_id)
    course.is_published = True
    course.updated_at = datetime.now(timezone.utc)
    enqueue_course_index_upsert(db, course.id, idempotency_suffix=course.updated_at.isoformat())
    db.commit()
    db.refresh(course)
    niche = db.get(Niche, course.niche_id)
    return _course_item(db, course, niche.slug if niche else "", locale="en-GB")


def _course_item(db: Session, course: Course, niche_slug: str, *, locale: str) -> CourseListItem:
    localized = get_localized_fields(
        db,
        entity_type="course",
        entity_id=course.id,
        locale=locale,
        base_fields={"title": course.title, "summary": course.summary},
    )
    return CourseListItem(
        id=course.id,
        instructor_user_id=course.instructor_user_id,
        title=str(localized.get("title") or course.title),
        summary=(str(localized.get("summary")) if localized.get("summary") is not None else course.summary),
        localized_fields={"title": localized.get("title"), "summary": localized.get("summary")},
        niche_slug=niche_slug,
        level=course.level,
        is_mandatory=course.is_mandatory,
        is_published=course.is_published,
        price=course.price,
        currency=course.currency,
        estimated_minutes=course.estimated_minutes,
        thumbnail_media_asset_id=course.thumbnail_media_asset_id,
        intro_video_media_asset_id=course.intro_video_media_asset_id,
    )


def _niche_slug_map(db: Session, niche_ids: list[uuid.UUID]) -> dict[uuid.UUID, str]:
    if not niche_ids:
        return {}
    rows = db.execute(select(Niche).where(Niche.id.in_(list(set(niche_ids))))).scalars().all()
    return {item.id: item.slug for item in rows}
