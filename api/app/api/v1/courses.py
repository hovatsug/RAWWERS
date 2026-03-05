from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import (
    get_db_read_session,
    get_db_session,
    get_locale,
    get_optional_current_user,
    require_admin,
    require_not_banned,
)
from app.core.errors import APIError
from app.models.learning import (
    Certificate,
    CertificateType,
    Course,
    CourseLevel,
    CoursePricingMode,
    CourseStatus,
    CourseReviewDecision,
    CourseSale,
    CourseModule,
    CourseQuiz,
    CurriculumPath,
    Enrollment,
    EnrollmentStatus,
    Lesson,
    LessonContentType,
    LearningPartnerStatus,
    ModuleProgress,
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
    CurriculumPathView,
    EnrollCourseRequest,
    EnrollmentView,
    EnrollResponse,
    LearningCourseDetailResponse,
    LearningCourseListResponse,
    LearningFeePolicyUpsertRequest,
    LearningFeePolicyView,
    LearningPartnerUpsertRequest,
    LearningPartnerView,
    LearningSalesItem,
    ModuleProgressRequest,
    ModuleProgressView,
    ModuleQuizRequest,
    ModuleQuizResponse,
    PartnerCourseCreateRequest,
    PartnerCourseUpdateRequest,
    PublicCertificateView,
    InstructorCourseCreateRequest,
    InstructorCourseUpdateRequest,
    LessonView,
    MyCertificatesResponse,
    MyEnrollmentsResponse,
    QuizAttemptRequest,
    QuizAttemptResponse,
    UpdateLessonProgressRequest,
    UpdateLessonProgressResponse,
    AdminCourseReviewRequest,
)
from app.schemas.media import CurrentUser
from app.services.authz import enforce_not_banned
from app.services.learning import (
    assert_course_publishable,
    create_partner_course,
    evaluate_enrollment_completion,
    get_course_modules,
    get_or_create_fee_policy,
    grade_quiz_answers,
    issue_learning_certificate_for_course,
    list_curricula,
    list_learning_courses,
    list_learning_partners,
    maybe_issue_curriculum_certificate,
    enroll_user_in_course,
    review_course_submission,
    score_module_quiz,
    settle_paid_enrollment,
    submit_course_for_review,
    try_complete_enrollment,
    upsert_learning_partner,
    upsert_module_progress,
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
                    Enrollment.status.in_([EnrollmentStatus.active, EnrollmentStatus.enrolled, EnrollmentStatus.completed]),
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
            status=EnrollmentStatus.enrolled,
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
    if enrollment.status not in {EnrollmentStatus.active, EnrollmentStatus.enrolled, EnrollmentStatus.completed}:
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
    if enrollment.status not in {EnrollmentStatus.active, EnrollmentStatus.enrolled, EnrollmentStatus.completed}:
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


@router.get("/learn/curricula", response_model=list[CurriculumPathView])
def learn_curricula(
    niche: str | None = None,
    _: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> list[CurriculumPathView]:
    rows = list_curricula(db, niche=niche)
    db.commit()
    return [CurriculumPathView.model_validate(row, from_attributes=True) for row in rows]


@router.get("/learn/courses", response_model=LearningCourseListResponse)
def learn_courses(
    search: str | None = None,
    niche: str | None = None,
    pricing: CoursePricingMode | None = None,
    db: Session = Depends(get_db_read_session),
) -> LearningCourseListResponse:
    rows = list_learning_courses(db, search=search, niche=niche, pricing=pricing)
    items = [_course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB") for row in rows]
    db.commit()
    return LearningCourseListResponse(total=len(items), items=items)


@router.get("/learn/courses/{course_id}", response_model=LearningCourseDetailResponse)
def learn_course_detail(
    course_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> LearningCourseDetailResponse:
    course = db.get(Course, course_id)
    if not course or course.status != CourseStatus.approved or not course.is_published:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    modules = get_course_modules(db, course_id=course.id)
    enrolled = (
        db.execute(select(Enrollment).where(Enrollment.user_id == user.user_id, Enrollment.course_id == course.id)).scalar_one_or_none()
        is not None
    )
    module_views = [
        CourseModuleView(
            id=item.id,
            course_id=item.course_id,
            title=item.title,
            sort_order=item.sort_order,
            type=item.type,
            mux_asset_id=item.mux_asset_id,
            duration_seconds=item.duration_seconds,
            metadata=item.meta or {},
            lessons=[],
        )
        for item in modules
    ]
    db.commit()
    return LearningCourseDetailResponse(
        course=_course_item(db, course, (course.niche_slugs[0] if course.niche_slugs else ""), locale="en-GB"),
        modules=module_views,
        enrolled=enrolled,
    )


@router.post("/learn/courses/{course_id}/enroll", response_model=EnrollResponse)
def learn_enroll_course(
    course_id: uuid.UUID,
    _: EnrollCourseRequest | None = None,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EnrollResponse:
    course = db.get(Course, course_id)
    if not course or course.status != CourseStatus.approved or not course.is_published:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    enrollment = enroll_user_in_course(db, user_id=user.user_id, course=course)
    db.commit()
    return EnrollResponse(
        enrollment_id=enrollment.id,
        status=enrollment.status,
        started_at=enrollment.started_at,
        paid=enrollment.paid,
        stripe_payment_intent_id=enrollment.stripe_payment_intent_id,
    )


@router.post("/learn/enrollments/{enrollment_id}/pay", response_model=EnrollResponse)
def learn_settle_enrollment_payment(
    enrollment_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EnrollResponse:
    enrollment = db.get(Enrollment, enrollment_id)
    if not enrollment or enrollment.user_id != user.user_id:
        raise APIError(code="not_found", message="Enrollment not found", status_code=404)
    if enrollment.paid:
        db.commit()
        return EnrollResponse(
            enrollment_id=enrollment.id,
            status=enrollment.status,
            started_at=enrollment.started_at,
            paid=enrollment.paid,
            stripe_payment_intent_id=enrollment.stripe_payment_intent_id,
        )
    if not enrollment.stripe_payment_intent_id:
        enrollment.stripe_payment_intent_id = f"pi_learn_{uuid.uuid4().hex[:24]}"
    settle_paid_enrollment(db, enrollment=enrollment, stripe_payment_intent_id=enrollment.stripe_payment_intent_id)
    db.commit()
    return EnrollResponse(
        enrollment_id=enrollment.id,
        status=enrollment.status,
        started_at=enrollment.started_at,
        paid=enrollment.paid,
        stripe_payment_intent_id=enrollment.stripe_payment_intent_id,
    )


@router.post("/learn/enrollments/{enrollment_id}/modules/{module_id}/progress", response_model=ModuleProgressView)
def learn_module_progress(
    enrollment_id: uuid.UUID,
    module_id: uuid.UUID,
    body: ModuleProgressRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ModuleProgressView:
    enrollment = db.get(Enrollment, enrollment_id)
    if not enrollment or enrollment.user_id != user.user_id:
        raise APIError(code="not_found", message="Enrollment not found", status_code=404)
    module = db.get(CourseModule, module_id)
    if not module or module.course_id != enrollment.course_id:
        raise APIError(code="validation_error", message="Module does not belong to enrollment course", status_code=422)
    row = upsert_module_progress(
        db,
        enrollment=enrollment,
        module=module,
        watch_seconds_delta=body.watch_seconds_delta,
        position_seconds=body.position_seconds,
    )
    if try_complete_enrollment(db, enrollment=enrollment):
        issue_learning_certificate_for_course(db, enrollment=enrollment)
        course = db.get(Course, enrollment.course_id)
        if course:
            maybe_issue_curriculum_certificate(db, user_id=user.user_id, course=course)
    db.commit()
    return ModuleProgressView(
        enrollment_id=enrollment.id,
        module_id=module.id,
        status=row.status,
        watch_seconds=row.watch_seconds,
        last_position_seconds=row.last_position_seconds,
        quiz_score_percent=row.quiz_score_percent,
    )


@router.post("/learn/enrollments/{enrollment_id}/modules/{module_id}/quiz", response_model=ModuleQuizResponse)
def learn_module_quiz(
    enrollment_id: uuid.UUID,
    module_id: uuid.UUID,
    body: ModuleQuizRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ModuleQuizResponse:
    enrollment = db.get(Enrollment, enrollment_id)
    if not enrollment or enrollment.user_id != user.user_id:
        raise APIError(code="not_found", message="Enrollment not found", status_code=404)
    module = db.get(CourseModule, module_id)
    if not module or module.course_id != enrollment.course_id:
        raise APIError(code="validation_error", message="Module does not belong to enrollment course", status_code=422)
    _, score, passed = score_module_quiz(db, enrollment=enrollment, module=module, answers=body.answers)
    if try_complete_enrollment(db, enrollment=enrollment):
        issue_learning_certificate_for_course(db, enrollment=enrollment)
        course = db.get(Course, enrollment.course_id)
        if course:
            maybe_issue_curriculum_certificate(db, user_id=user.user_id, course=course)
    db.commit()
    return ModuleQuizResponse(score_percent=score, passed=passed)


@router.get("/learn/certificates/mine", response_model=MyCertificatesResponse)
def learn_my_certificates(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> MyCertificatesResponse:
    rows = db.execute(
        select(Certificate, Course)
        .outerjoin(Course, Course.id == Certificate.course_id)
        .where(Certificate.user_id == user.user_id)
        .order_by(Certificate.issued_at.desc())
    ).all()
    items = [
        CertificateView(
            id=cert.id,
            user_id=cert.user_id,
            certificate_type=cert.certificate_type,
            course_id=cert.course_id,
            curriculum_path_id=cert.curriculum_path_id,
            course_title=(course.title_custom or course.title if course else None),
            niche_slug=cert.niche_slug,
            certificate_code=cert.certificate_code,
            verification_code=cert.verification_code,
            issued_at=cert.issued_at,
            revoked_at=cert.revoked_at,
            pdf_storage_key=cert.pdf_storage_key,
            metadata=cert.meta or {},
        )
        for cert, course in rows
    ]
    db.commit()
    return MyCertificatesResponse(total=len(items), items=items)


@router.get("/learn/certificates/{verification_code}", response_model=PublicCertificateView)
def learn_verify_certificate(
    verification_code: str,
    db: Session = Depends(get_db_read_session),
) -> PublicCertificateView:
    row = db.execute(
        select(Certificate).where(
            (Certificate.verification_code == verification_code) | (Certificate.certificate_code == verification_code)
        )
    ).scalar_one_or_none()
    if not row:
        raise APIError(code="not_found", message="Certificate not found", status_code=404)
    db.commit()
    return PublicCertificateView(
        verification_code=row.verification_code or row.certificate_code,
        certificate_type=row.certificate_type,
        issued_at=row.issued_at,
        revoked_at=row.revoked_at,
        user_id=row.user_id,
        course_id=row.course_id,
        curriculum_path_id=row.curriculum_path_id,
        niche_slug=row.niche_slug,
        metadata=row.meta or {},
    )


@router.post("/partner/learn/courses", response_model=CourseListItem)
def partner_create_course(
    body: PartnerCourseCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    row = create_partner_course(
        db,
        creator_user_id=user.user_id,
        instructor_user_id=user.user_id,
        partner_id=body.partner_id,
        title_custom=body.title_custom,
        description_custom=body.description_custom,
        language=body.language,
        niche_slugs=body.niche_slugs,
        level=body.level,
        pricing_mode=body.pricing_mode,
        price_eur=body.price_eur,
        currency=body.currency,
    )
    db.commit()
    return _course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB")


@router.put("/partner/learn/courses/{course_id}", response_model=CourseListItem)
def partner_update_course(
    course_id: uuid.UUID,
    body: PartnerCourseUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    row = db.get(Course, course_id)
    if not row or row.creator_user_id != user.user_id:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    if row.status not in {CourseStatus.draft, CourseStatus.rejected}:
        raise APIError(code="invalid_state", message="Only draft/rejected courses can be edited", status_code=409)
    for field in ["title_custom", "description_custom", "language", "level", "pricing_mode"]:
        value = getattr(body, field)
        if value is not None:
            setattr(row, field, value)
    if body.title_custom is not None:
        row.title = body.title_custom
    if body.description_custom is not None:
        row.summary = body.description_custom
    if body.niche_slugs is not None:
        row.niche_slugs = body.niche_slugs
        if body.niche_slugs:
            niche_row = db.execute(select(Niche).where(Niche.slug == body.niche_slugs[0])).scalar_one_or_none()
            if niche_row:
                row.niche_id = niche_row.id
    if body.price_eur is not None:
        row.price_eur = body.price_eur
        row.price = body.price_eur
    if body.currency is not None:
        row.currency = body.currency.upper()
    row.updated_at = datetime.now(timezone.utc)
    db.commit()
    return _course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB")


@router.post("/partner/learn/courses/{course_id}/submit", response_model=CourseListItem)
def partner_submit_course(
    course_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    row = db.get(Course, course_id)
    if not row:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    submit_course_for_review(db, course=row, actor_user_id=user.user_id)
    db.commit()
    return _course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB")


@router.get("/partner/learn/courses/mine", response_model=LearningCourseListResponse)
def partner_my_courses(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> LearningCourseListResponse:
    rows = db.execute(select(Course).where(Course.creator_user_id == user.user_id).order_by(Course.updated_at.desc())).scalars().all()
    items = [_course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB") for row in rows]
    db.commit()
    return LearningCourseListResponse(total=len(items), items=items)


@router.get("/admin/learn/courses", response_model=LearningCourseListResponse)
def admin_learn_courses(
    status: CourseStatus | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_read_session),
) -> LearningCourseListResponse:
    stmt = select(Course)
    if status:
        stmt = stmt.where(Course.status == status)
    rows = db.execute(stmt.order_by(Course.updated_at.desc())).scalars().all()
    items = [_course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB") for row in rows]
    db.commit()
    return LearningCourseListResponse(total=len(items), items=items)


@router.post("/admin/learn/courses/{course_id}/review", response_model=CourseListItem)
def admin_review_course(
    course_id: uuid.UUID,
    body: AdminCourseReviewRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    row = db.get(Course, course_id)
    if not row:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    review_course_submission(db, course=row, reviewer_admin_id=actor.user_id, decision=body.decision, notes=body.notes)
    if body.decision == CourseReviewDecision.approved:
        enqueue_course_index_upsert(db, row.id, idempotency_suffix="approved")
    db.commit()
    return _course_item(db, row, (row.niche_slugs[0] if row.niche_slugs else ""), locale="en-GB")


@router.get("/admin/learn/partners", response_model=list[LearningPartnerView])
def admin_learning_partners(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_read_session),
) -> list[LearningPartnerView]:
    rows = list_learning_partners(db)
    db.commit()
    return [LearningPartnerView.model_validate(item, from_attributes=True) for item in rows]


@router.post("/admin/learn/partners", response_model=LearningPartnerView)
def admin_upsert_learning_partner(
    body: LearningPartnerUpsertRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> LearningPartnerView:
    row = upsert_learning_partner(
        db,
        partner_id=body.id,
        name=body.name,
        brand=body.brand,
        contact_email=body.contact_email,
        status=body.status,
        payout_account_ref=body.payout_account_ref,
    )
    db.commit()
    return LearningPartnerView.model_validate(row, from_attributes=True)


@router.get("/admin/learn/sales", response_model=list[LearningSalesItem])
def admin_learning_sales(
    partner_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_read_session),
) -> list[LearningSalesItem]:
    stmt = select(CourseSale, Course).join(Course, Course.id == CourseSale.course_id)
    if partner_id:
        stmt = stmt.where(Course.partner_id == partner_id)
    rows = db.execute(stmt.order_by(CourseSale.created_at.desc())).all()
    db.commit()
    return [
        LearningSalesItem(
            id=sale.id,
            course_id=sale.course_id,
            user_id=sale.user_id,
            gross_eur=sale.gross_eur,
            platform_fee_eur=sale.platform_fee_eur,
            partner_net_eur=sale.partner_net_eur,
            stripe_payment_intent_id=sale.stripe_payment_intent_id,
            status=sale.status.value,
            created_at=sale.created_at,
        )
        for sale, _course in rows
    ]


@router.get("/admin/learn/fee-policy", response_model=LearningFeePolicyView)
def admin_get_learning_fee_policy(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_read_session),
) -> LearningFeePolicyView:
    row = get_or_create_fee_policy(db)
    db.commit()
    return LearningFeePolicyView.model_validate(row, from_attributes=True)


@router.put("/admin/learn/fee-policy", response_model=LearningFeePolicyView)
def admin_upsert_learning_fee_policy(
    body: LearningFeePolicyUpsertRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> LearningFeePolicyView:
    row = get_or_create_fee_policy(db)
    row.platform_fee_percent = body.platform_fee_percent
    row.mux_cost_reserve_percent = body.mux_cost_reserve_percent
    row.metadata = body.metadata
    row.updated_at = datetime.now(timezone.utc)
    db.commit()
    return LearningFeePolicyView.model_validate(row, from_attributes=True)


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
        base_fields={"title": course.title_custom or course.title, "summary": course.description_custom or course.summary},
    )
    return CourseListItem(
        id=course.id,
        instructor_user_id=course.instructor_user_id,
        creator_user_id=course.creator_user_id,
        partner_id=course.partner_id,
        title=str(localized.get("title") or course.title_custom or course.title),
        title_key=course.title_key,
        title_custom=course.title_custom,
        summary=(str(localized.get("summary")) if localized.get("summary") is not None else course.description_custom or course.summary),
        description_key=course.description_key,
        description_custom=course.description_custom,
        localized_fields={"title": localized.get("title"), "summary": localized.get("summary")},
        niche_slug=niche_slug,
        niche_slugs=[str(item) for item in (course.niche_slugs or [])],
        language=course.language,
        level=course.level,
        is_mandatory=course.is_mandatory,
        is_published=course.is_published,
        status=course.status,
        pricing_mode=course.pricing_mode,
        price=course.price,
        price_eur=course.price_eur,
        currency=course.currency,
        estimated_minutes=course.estimated_minutes,
        thumbnail_media_asset_id=course.thumbnail_media_asset_id,
        intro_video_media_asset_id=course.intro_video_media_asset_id,
        approved_at=course.approved_at,
    )


def _niche_slug_map(db: Session, niche_ids: list[uuid.UUID]) -> dict[uuid.UUID, str]:
    if not niche_ids:
        return {}
    rows = db.execute(select(Niche).where(Niche.id.in_(list(set(niche_ids))))).scalars().all()
    return {item.id: item.slug for item in rows}
