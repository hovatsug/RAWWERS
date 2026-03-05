from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.learning import (
    Certificate,
    CertificateType,
    Course,
    CourseLevel,
    CourseModuleType,
    CoursePricingMode,
    CourseQuiz,
    CourseReview,
    CourseReviewDecision,
    CourseSale,
    CourseSaleStatus,
    CourseStatus,
    CourseModule,
    CurriculumPath,
    CurriculumRequirement,
    CurriculumRequirementType,
    Enrollment,
    EnrollmentStatus,
    InstructorProfile,
    InstructorStatus,
    Lesson,
    LessonContentType,
    LessonProgress,
    ProgressStatus,
    QuizAttempt,
    QuizQuestion,
    LearningFeePolicy,
    LearningPartner,
    LearningPartnerStatus,
    ModuleProgress,
)
from app.models.media import MediaAsset, MediaKind
from app.models.niche import CertificationRecord, Niche, SkillTier
from app.services.analytics import log_event
from app.services.discovery_index import recompute_pro_public_index
from app.services.gamification import queue_evaluate_user_milestones
from app.services.niche_skills import recompute_pro_niche_skills
from app.services.niche_skills import enqueue_niche_skill_recalc
from app.services.notifications import enqueue_notification

SHORT_VIDEO_MAX_DURATION_SECONDS = 900

LEVEL_BASE_SCORE = {
    CourseLevel.beginner: 60,
    CourseLevel.intermediate: 70,
    CourseLevel.advanced: 80,
    CourseLevel.master: 90,
}


def ensure_instructor_profile(db: Session, user_id: uuid.UUID) -> InstructorProfile:
    profile = db.get(InstructorProfile, user_id)
    if profile:
        return profile
    profile = InstructorProfile(user_id=user_id, status=InstructorStatus.pending, expertise=[])
    db.add(profile)
    db.flush()
    return profile


def require_approved_instructor(db: Session, user_id: uuid.UUID) -> InstructorProfile:
    profile = ensure_instructor_profile(db, user_id)
    if profile.status != InstructorStatus.approved:
        raise APIError(code="forbidden", message="Instructor approval required", status_code=403)
    return profile


def validate_course_media_ownership(db: Session, user_id: uuid.UUID, media_asset_id: uuid.UUID | None, *, must_be_video: bool) -> None:
    if not media_asset_id:
        return
    asset = db.get(MediaAsset, media_asset_id)
    if not asset:
        raise APIError(code="validation_error", message="Media asset not found", status_code=422)
    if asset.owner_user_id != user_id:
        raise APIError(code="forbidden", message="Media asset must be owned by instructor", status_code=403)
    if must_be_video and asset.kind != MediaKind.video:
        raise APIError(code="validation_error", message="Expected video media asset", status_code=422)
    if not must_be_video and asset.kind != MediaKind.photo:
        raise APIError(code="validation_error", message="Expected photo media asset", status_code=422)


def validate_lesson_payload(content_type: LessonContentType, video_media_asset_id: uuid.UUID | None) -> None:
    if content_type == LessonContentType.video and not video_media_asset_id:
        raise APIError(code="validation_error", message="video_media_asset_id is required for video lessons", status_code=422)


def assert_course_publishable(db: Session, course: Course, instructor_user_id: uuid.UUID) -> None:
    modules = db.execute(
        select(CourseModule).where(CourseModule.course_id == course.id).order_by(CourseModule.sort_order.asc())
    ).scalars().all()
    if not modules:
        raise APIError(code="validation_error", message="Course must have at least one module", status_code=422)

    module_ids = [m.id for m in modules]
    lessons = db.execute(select(Lesson).where(Lesson.module_id.in_(module_ids))).scalars().all() if module_ids else []
    if not lessons:
        raise APIError(code="validation_error", message="Course must have at least one lesson", status_code=422)

    if course.thumbnail_media_asset_id:
        validate_course_media_ownership(db, instructor_user_id, course.thumbnail_media_asset_id, must_be_video=False)
    if course.intro_video_media_asset_id:
        validate_course_media_ownership(db, instructor_user_id, course.intro_video_media_asset_id, must_be_video=True)

    for lesson in lessons:
        if lesson.content_type == LessonContentType.video:
            validate_course_media_ownership(db, instructor_user_id, lesson.video_media_asset_id, must_be_video=True)
            if lesson.duration_seconds and lesson.duration_seconds > SHORT_VIDEO_MAX_DURATION_SECONDS:
                raise APIError(
                    code="validation_error",
                    message=f"Video lesson exceeds short-video policy ({SHORT_VIDEO_MAX_DURATION_SECONDS}s)",
                    status_code=422,
                )


def upsert_lesson_progress(
    db: Session,
    enrollment: Enrollment,
    lesson: Lesson,
    status: ProgressStatus,
    progress_percent: int,
) -> LessonProgress:
    row = db.execute(
        select(LessonProgress).where(
            LessonProgress.enrollment_id == enrollment.id,
            LessonProgress.lesson_id == lesson.id,
        )
    ).scalar_one_or_none()
    if not row:
        row = LessonProgress(
            enrollment_id=enrollment.id,
            lesson_id=lesson.id,
            status=ProgressStatus.not_started,
            progress_percent=0,
            meta={},
        )
        db.add(row)

    row.status = status
    row.progress_percent = progress_percent
    if status == ProgressStatus.completed:
        row.completed_at = datetime.now(timezone.utc)
        if row.progress_percent < 100:
            row.progress_percent = 100
    else:
        row.completed_at = None
    db.flush()
    return row


def evaluate_enrollment_completion(db: Session, enrollment: Enrollment) -> bool:
    course = db.get(Course, enrollment.course_id)
    if not course:
        return False
    module_ids = db.execute(select(CourseModule.id).where(CourseModule.course_id == course.id)).scalars().all()
    if not module_ids:
        return False

    lessons = db.execute(select(Lesson).where(Lesson.module_id.in_(module_ids))).scalars().all()
    if not lessons:
        return False

    lesson_ids = [l.id for l in lessons]
    completed_progress_count = db.execute(
        select(func.count())
        .select_from(LessonProgress)
        .where(
            LessonProgress.enrollment_id == enrollment.id,
            LessonProgress.lesson_id.in_(lesson_ids),
            LessonProgress.status == ProgressStatus.completed,
        )
    ).scalar_one()
    if completed_progress_count < len(lessons):
        return False

    quiz_lesson_ids = db.execute(select(QuizQuestion.lesson_id).where(QuizQuestion.lesson_id.in_(lesson_ids))).scalars().all()
    unique_quiz_lesson_ids = sorted(set(quiz_lesson_ids))
    for lesson_id in unique_quiz_lesson_ids:
        passed = db.execute(
            select(QuizAttempt)
            .where(
                QuizAttempt.enrollment_id == enrollment.id,
                QuizAttempt.lesson_id == lesson_id,
                QuizAttempt.passed.is_(True),
            )
            .order_by(QuizAttempt.created_at.desc())
        ).scalar_one_or_none()
        if not passed:
            return False
    return True


def mark_enrollment_completed(db: Session, enrollment: Enrollment) -> None:
    now = datetime.now(timezone.utc)
    enrollment.status = EnrollmentStatus.completed
    enrollment.completed_at = now
    enrollment.updated_at = now
    db.flush()


def issue_certificate_for_enrollment(db: Session, enrollment_id: uuid.UUID) -> Certificate:
    enrollment = db.get(Enrollment, enrollment_id)
    if not enrollment:
        raise APIError(code="not_found", message="Enrollment not found", status_code=404)
    course = db.get(Course, enrollment.course_id)
    if not course:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    niche = db.get(Niche, course.niche_id)
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)

    certificate = db.execute(
        select(Certificate).where(Certificate.user_id == enrollment.user_id, Certificate.course_id == enrollment.course_id)
    ).scalar_one_or_none()
    if not certificate:
        issued_at = datetime.now(timezone.utc)
        certificate = Certificate(
            user_id=enrollment.user_id,
            course_id=enrollment.course_id,
            niche_id=course.niche_id,
            certificate_code=_build_certificate_code(enrollment.user_id, course.id),
            issued_at=issued_at,
            pdf_storage_key=None,
            meta={"course_level": course.level.value},
        )
        db.add(certificate)
        db.flush()

    cert_score = _compute_certification_score(db, enrollment.id, course.level)
    cert_code = f"{niche.slug}.{course.id}.completion"
    expires_at = None
    if course.level in {CourseLevel.advanced, CourseLevel.master}:
        expires_at = (datetime.now(timezone.utc) + timedelta(days=365 * 2)).replace(microsecond=0)

    cert_record = db.execute(
        select(CertificationRecord).where(
            CertificationRecord.pro_user_id == enrollment.user_id,
            CertificationRecord.niche_id == course.niche_id,
            CertificationRecord.cert_code == cert_code,
        )
    ).scalar_one_or_none()
    now = datetime.now(timezone.utc)
    if not cert_record:
        cert_record = CertificationRecord(
            pro_user_id=enrollment.user_id,
            niche_id=course.niche_id,
            cert_code=cert_code,
            score=cert_score,
            completed_at=now,
            expires_at=expires_at,
        )
        db.add(cert_record)
    else:
        cert_record.score = cert_score
        cert_record.completed_at = now
        cert_record.expires_at = expires_at

    recompute_pro_niche_skills(db, enrollment.user_id, course.niche_id)
    enqueue_niche_skill_recalc(db, pro_user_id=enrollment.user_id, niche_id=course.niche_id, reason="certificate_issued")
    recompute_pro_public_index(db, enrollment.user_id)
    log_event(
        db,
        event_name="course.completed",
        user_id=enrollment.user_id,
        properties={"course_id": str(course.id), "enrollment_id": str(enrollment.id), "niche_slug": niche.slug},
    )
    log_event(
        db,
        event_name="certificate.issued",
        user_id=enrollment.user_id,
        properties={"course_id": str(course.id), "certificate_code": certificate.certificate_code},
    )
    queue_evaluate_user_milestones(enrollment.user_id, course.niche_id)
    db.flush()
    return certificate


def queue_or_issue_certificate(db: Session, enrollment_id: uuid.UUID) -> bool:
    from app.tasks.learning_tasks import issue_certificate_task

    try:
        issue_certificate_task.delay(str(enrollment_id))
        return True
    except Exception:
        issue_certificate_for_enrollment(db, enrollment_id)
        return True


def grade_quiz_answers(questions: list[QuizQuestion], answers: list[int]) -> tuple[int, bool]:
    if not questions:
        raise APIError(code="validation_error", message="No quiz questions for lesson", status_code=422)
    if len(answers) != len(questions):
        raise APIError(code="validation_error", message="answers length does not match question count", status_code=422)

    correct = 0
    for idx, question in enumerate(questions):
        if answers[idx] == question.correct_index:
            correct += 1
    score_percent = int(round((correct * 100) / len(questions)))
    passed = score_percent >= 70
    return score_percent, passed


def replace_niche_program_requirements(
    db: Session,
    niche_id: uuid.UUID,
    tier_target: SkillTier,
    course_ids: list[uuid.UUID],
    is_mandatory: bool,
) -> int:
    from app.models.learning import NicheProgramRequirement, RequirementType

    valid_courses = db.execute(
        select(Course.id).where(Course.id.in_(course_ids), Course.niche_id == niche_id)
    ).scalars().all()
    valid_course_ids = list(valid_courses)
    if len(valid_course_ids) != len(set(course_ids)):
        raise APIError(code="validation_error", message="All course_ids must belong to the given niche", status_code=422)

    db.execute(
        delete(NicheProgramRequirement).where(
            NicheProgramRequirement.niche_id == niche_id,
            NicheProgramRequirement.tier_target == tier_target,
        )
    )
    for course_id in valid_course_ids:
        db.add(
            NicheProgramRequirement(
                niche_id=niche_id,
                tier_target=tier_target,
                requirement_type=RequirementType.course,
                course_id=course_id,
                is_mandatory=is_mandatory,
            )
        )
    db.flush()
    return len(valid_course_ids)


def _compute_certification_score(db: Session, enrollment_id: uuid.UUID, level: CourseLevel) -> int:
    max_quiz_score = db.execute(
        select(func.max(QuizAttempt.score_percent)).where(QuizAttempt.enrollment_id == enrollment_id)
    ).scalar_one()
    if max_quiz_score is not None:
        return max(0, min(100, int(max_quiz_score)))
    return LEVEL_BASE_SCORE.get(level, 60)


def _build_certificate_code(user_id: uuid.UUID, course_id: uuid.UUID) -> str:
    return f"RWR-{str(course_id).split('-')[0].upper()}-{str(user_id).split('-')[0].upper()}"


def get_or_create_fee_policy(db: Session) -> LearningFeePolicy:
    row = db.execute(select(LearningFeePolicy).order_by(LearningFeePolicy.updated_at.desc())).scalar_one_or_none()
    if row:
        return row
    row = LearningFeePolicy(platform_fee_percent=30, mux_cost_reserve_percent=10, metadata={})
    db.add(row)
    db.flush()
    return row


def upsert_learning_partner(
    db: Session,
    *,
    partner_id: uuid.UUID | None,
    name: str,
    brand: dict,
    contact_email: str | None,
    status: LearningPartnerStatus,
    payout_account_ref: str | None,
) -> LearningPartner:
    row = db.get(LearningPartner, partner_id) if partner_id else None
    if not row:
        row = LearningPartner(name=name, brand=brand or {}, contact_email=contact_email, status=status, payout_account_ref=payout_account_ref)
        db.add(row)
    else:
        row.name = name
        row.brand = brand or {}
        row.contact_email = contact_email
        row.status = status
        row.payout_account_ref = payout_account_ref
        row.updated_at = datetime.now(timezone.utc)
    db.flush()
    return row


def list_learning_partners(db: Session) -> list[LearningPartner]:
    return db.execute(select(LearningPartner).order_by(LearningPartner.created_at.desc())).scalars().all()


def create_partner_course(
    db: Session,
    *,
    creator_user_id: uuid.UUID,
    instructor_user_id: uuid.UUID,
    partner_id: uuid.UUID | None,
    title_custom: str,
    description_custom: str | None,
    language: str,
    niche_slugs: list[str],
    level: CourseLevel,
    pricing_mode: CoursePricingMode,
    price_eur: Decimal | None,
    currency: str,
) -> Course:
    if pricing_mode == CoursePricingMode.paid and (price_eur is None or price_eur <= 0):
        raise APIError(code="validation_error", message="Paid courses require price_eur > 0", status_code=422)
    niche_row = None
    if niche_slugs:
        niche_row = db.execute(select(Niche).where(Niche.slug == niche_slugs[0])).scalar_one_or_none()
    if niche_row is None:
        niche_row = db.execute(select(Niche).order_by(Niche.slug.asc())).scalar_one_or_none()
    if niche_row is None:
        raise APIError(code="validation_error", message="No niche configured", status_code=422)

    course = Course(
        instructor_user_id=instructor_user_id,
        creator_user_id=creator_user_id,
        partner_id=partner_id,
        title=title_custom,
        title_custom=title_custom,
        summary=description_custom,
        description_custom=description_custom,
        language=language,
        niche_slugs=niche_slugs,
        niche_id=niche_row.id,
        level=level,
        pricing_mode=pricing_mode,
        status=CourseStatus.draft,
        is_published=False,
        price=price_eur,
        price_eur=price_eur,
        currency=currency.upper(),
    )
    db.add(course)
    db.flush()
    return course


def submit_course_for_review(db: Session, *, course: Course, actor_user_id: uuid.UUID) -> Course:
    if course.creator_user_id != actor_user_id and course.instructor_user_id != actor_user_id:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)
    if course.status not in {CourseStatus.draft, CourseStatus.rejected}:
        raise APIError(code="invalid_state", message="Course cannot be submitted in current state", status_code=409)
    course.status = CourseStatus.submitted
    course.updated_at = datetime.now(timezone.utc)
    db.flush()
    return course


def review_course_submission(
    db: Session,
    *,
    course: Course,
    reviewer_admin_id: uuid.UUID,
    decision: CourseReviewDecision,
    notes: str | None,
) -> Course:
    review = CourseReview(
        course_id=course.id,
        reviewer_admin_id=reviewer_admin_id,
        decision=decision,
        notes=notes,
    )
    db.add(review)
    if decision == CourseReviewDecision.approved:
        course.status = CourseStatus.approved
        course.is_published = True
        course.approved_at = datetime.now(timezone.utc)
        course.updated_at = datetime.now(timezone.utc)
        log_event(db, event_name="learning.course_approved", user_id=course.creator_user_id, properties={"course_id": str(course.id)})
    else:
        course.status = CourseStatus.rejected
        course.is_published = False
        course.updated_at = datetime.now(timezone.utc)
    db.flush()
    return course


def list_learning_courses(
    db: Session,
    *,
    search: str | None,
    niche: str | None,
    pricing: CoursePricingMode | None,
) -> list[Course]:
    stmt = select(Course).where(Course.status == CourseStatus.approved, Course.is_published.is_(True))
    if pricing:
        stmt = stmt.where(Course.pricing_mode == pricing)
    rows = db.execute(stmt.order_by(Course.updated_at.desc())).scalars().all()
    if niche:
        rows = [row for row in rows if niche in (row.niche_slugs or [])]
    if search:
        needle = search.lower()
        rows = [row for row in rows if needle in (row.title_custom or row.title or "").lower() or needle in (row.description_custom or row.summary or "").lower()]
    return rows


def list_curricula(db: Session, *, niche: str | None) -> list[CurriculumPath]:
    stmt = select(CurriculumPath).where(CurriculumPath.is_active.is_(True))
    if niche:
        stmt = stmt.where(CurriculumPath.niche_slug == niche)
    return db.execute(stmt.order_by(CurriculumPath.name.asc())).scalars().all()


def get_course_modules(db: Session, *, course_id: uuid.UUID) -> list[CourseModule]:
    return db.execute(select(CourseModule).where(CourseModule.course_id == course_id).order_by(CourseModule.sort_order.asc())).scalars().all()


def enroll_user_in_course(db: Session, *, user_id: uuid.UUID, course: Course) -> Enrollment:
    row = db.execute(select(Enrollment).where(Enrollment.user_id == user_id, Enrollment.course_id == course.id)).scalar_one_or_none()
    if row:
        return row
    paid = course.pricing_mode != CoursePricingMode.paid or (course.price_eur is None or course.price_eur <= 0)
    stripe_payment_intent_id = None if paid else f"pi_learn_{uuid.uuid4().hex[:24]}"
    row = Enrollment(
        user_id=user_id,
        course_id=course.id,
        status=EnrollmentStatus.enrolled,
        paid=paid,
        stripe_payment_intent_id=stripe_payment_intent_id,
        enrolled_at=datetime.now(timezone.utc),
        started_at=datetime.now(timezone.utc),
    )
    db.add(row)
    db.flush()
    log_event(db, event_name="learn.enrolled", user_id=user_id, properties={"course_id": str(course.id), "paid": paid})
    return row


def settle_paid_enrollment(
    db: Session,
    *,
    enrollment: Enrollment,
    stripe_payment_intent_id: str,
) -> Enrollment:
    if enrollment.paid:
        return enrollment
    course = db.get(Course, enrollment.course_id)
    if not course:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    policy = get_or_create_fee_policy(db)
    gross = Decimal(str(course.price_eur or course.price or 0)).quantize(Decimal("0.01"))
    platform_fee = (gross * Decimal(policy.platform_fee_percent) / Decimal(100)).quantize(Decimal("0.01"))
    partner_net = (gross - platform_fee).quantize(Decimal("0.01"))
    mux_reserve = (gross * Decimal(policy.mux_cost_reserve_percent) / Decimal(100)).quantize(Decimal("0.01"))
    sale = CourseSale(
        course_id=course.id,
        user_id=enrollment.user_id,
        gross_eur=gross,
        platform_fee_eur=platform_fee,
        partner_net_eur=partner_net,
        stripe_payment_intent_id=stripe_payment_intent_id,
        status=CourseSaleStatus.paid,
        mux_minutes_consumed=0,
        mux_cost_reserve_eur=mux_reserve,
    )
    db.add(sale)
    enrollment.paid = True
    enrollment.stripe_payment_intent_id = stripe_payment_intent_id
    enrollment.updated_at = datetime.now(timezone.utc)
    log_event(db, event_name="learn.paid_course_purchased", user_id=enrollment.user_id, properties={"course_id": str(course.id)})
    db.flush()
    return enrollment


def upsert_module_progress(
    db: Session,
    *,
    enrollment: Enrollment,
    module: CourseModule,
    watch_seconds_delta: int,
    position_seconds: int,
) -> ModuleProgress:
    row = db.execute(
        select(ModuleProgress).where(ModuleProgress.enrollment_id == enrollment.id, ModuleProgress.module_id == module.id)
    ).scalar_one_or_none()
    now = datetime.now(timezone.utc)
    if not row:
        row = ModuleProgress(
            enrollment_id=enrollment.id,
            module_id=module.id,
            status=ProgressStatus.not_started,
            watch_seconds=0,
            last_position_seconds=0,
        )
        db.add(row)
        db.flush()

    elapsed = max(1, int((now - (row.updated_at or now)).total_seconds()))
    max_allowed_delta = max(30, elapsed + 10)
    bounded_delta = min(watch_seconds_delta, max_allowed_delta)
    row.watch_seconds = max(0, row.watch_seconds + bounded_delta)
    row.last_position_seconds = position_seconds
    row.updated_at = now
    row.status = ProgressStatus.in_progress if row.watch_seconds > 0 else ProgressStatus.not_started

    if module.duration_seconds and module.duration_seconds > 0:
        completion_threshold = int(module.duration_seconds * 0.9)
        quiz = db.execute(select(CourseQuiz).where(CourseQuiz.module_id == module.id)).scalar_one_or_none()
        quiz_ok = True if not quiz else (row.quiz_score_percent is not None and row.quiz_score_percent >= quiz.pass_score_percent)
        became_completed = row.status != ProgressStatus.completed
        if row.watch_seconds >= completion_threshold and quiz_ok:
            row.status = ProgressStatus.completed
            if became_completed:
                log_event(
                    db,
                    event_name="learn.module_completed",
                    user_id=enrollment.user_id,
                    properties={"enrollment_id": str(enrollment.id), "module_id": str(module.id)},
                )
    db.flush()
    return row


def score_module_quiz(
    db: Session,
    *,
    enrollment: Enrollment,
    module: CourseModule,
    answers: list[int],
) -> tuple[ModuleProgress, int, bool]:
    quiz = db.execute(select(CourseQuiz).where(CourseQuiz.module_id == module.id)).scalar_one_or_none()
    if not quiz:
        raise APIError(code="not_found", message="Quiz not found for module", status_code=404)
    questions = quiz.questions or []
    if not isinstance(questions, list) or not questions:
        raise APIError(code="validation_error", message="Quiz has no questions", status_code=422)
    if len(answers) != len(questions):
        raise APIError(code="validation_error", message="answers length mismatch", status_code=422)
    correct = 0
    for idx, item in enumerate(questions):
        expected = int((item or {}).get("correct_index", -1))
        if answers[idx] == expected:
            correct += 1
    score = int(round((correct * 100) / len(questions)))
    passed = score >= int(quiz.pass_score_percent or 70)

    progress = db.execute(
        select(ModuleProgress).where(ModuleProgress.enrollment_id == enrollment.id, ModuleProgress.module_id == module.id)
    ).scalar_one_or_none()
    if not progress:
        progress = ModuleProgress(
            enrollment_id=enrollment.id,
            module_id=module.id,
            status=ProgressStatus.not_started,
            watch_seconds=0,
            last_position_seconds=0,
        )
        db.add(progress)
        db.flush()
    progress.quiz_score_percent = score
    if passed and module.duration_seconds and progress.watch_seconds >= int(module.duration_seconds * 0.9):
        progress.status = ProgressStatus.completed
    progress.updated_at = datetime.now(timezone.utc)
    db.flush()
    return progress, score, passed


def try_complete_enrollment(db: Session, *, enrollment: Enrollment) -> bool:
    modules = get_course_modules(db, course_id=enrollment.course_id)
    if not modules:
        return False
    module_ids = [m.id for m in modules]
    completed = db.execute(
        select(func.count())
        .select_from(ModuleProgress)
        .where(
            ModuleProgress.enrollment_id == enrollment.id,
            ModuleProgress.module_id.in_(module_ids),
            ModuleProgress.status == ProgressStatus.completed,
        )
    ).scalar_one()
    if completed < len(module_ids):
        return False
    enrollment.status = EnrollmentStatus.completed
    enrollment.completed_at = datetime.now(timezone.utc)
    enrollment.updated_at = datetime.now(timezone.utc)
    log_event(
        db,
        event_name="learn.course_completed",
        user_id=enrollment.user_id,
        properties={"course_id": str(enrollment.course_id), "enrollment_id": str(enrollment.id)},
    )
    enqueue_notification(
        db,
        user_id=enrollment.user_id,
        notification_type="course.completed",
        reference_type="enrollment",
        reference_id=str(enrollment.id),
        payload={"course_id": str(enrollment.course_id)},
    )
    db.flush()
    return True


def issue_learning_certificate_for_course(db: Session, *, enrollment: Enrollment) -> Certificate:
    course = db.get(Course, enrollment.course_id)
    if not course:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    existing = db.execute(
        select(Certificate).where(
            Certificate.user_id == enrollment.user_id,
            Certificate.course_id == enrollment.course_id,
            Certificate.certificate_type == CertificateType.course,
        )
    ).scalar_one_or_none()
    if existing:
        return existing
    code = _build_certificate_code(enrollment.user_id, enrollment.course_id)
    verify = f"VC-{uuid.uuid4().hex[:16].upper()}"
    cert = Certificate(
        user_id=enrollment.user_id,
        certificate_type=CertificateType.course,
        course_id=enrollment.course_id,
        curriculum_path_id=None,
        niche_id=course.niche_id,
        niche_slug=(course.niche_slugs[0] if course.niche_slugs else None),
        certificate_code=code,
        verification_code=verify,
        issued_at=datetime.now(timezone.utc),
        meta={"level": course.level.value},
    )
    db.add(cert)
    enqueue_notification(
        db,
        user_id=enrollment.user_id,
        notification_type="certificate.issued",
        reference_type="certificate",
        reference_id=str(cert.id),
        payload={"course_id": str(course.id)},
    )
    log_event(db, event_name="learn.certificate_issued", user_id=enrollment.user_id, properties={"course_id": str(course.id)})
    db.flush()
    return cert


def maybe_issue_curriculum_certificate(db: Session, *, user_id: uuid.UUID, course: Course) -> list[Certificate]:
    results: list[Certificate] = []
    for niche_slug in (course.niche_slugs or []):
        paths = db.execute(
            select(CurriculumPath).where(CurriculumPath.niche_slug == niche_slug, CurriculumPath.is_active.is_(True))
        ).scalars().all()
        for path in paths:
            reqs = db.execute(
                select(CurriculumRequirement).where(
                    CurriculumRequirement.curriculum_path_id == path.id,
                    CurriculumRequirement.requirement_type == CurriculumRequirementType.mandatory,
                )
            ).scalars().all()
            if not reqs:
                continue
            mandatory_course_ids = [item.course_id for item in reqs]
            completed_count = db.execute(
                select(func.count())
                .select_from(Enrollment)
                .where(
                    Enrollment.user_id == user_id,
                    Enrollment.course_id.in_(mandatory_course_ids),
                    Enrollment.status == EnrollmentStatus.completed,
                )
            ).scalar_one()
            if completed_count < len(mandatory_course_ids):
                continue
            existing = db.execute(
                select(Certificate).where(
                    Certificate.user_id == user_id,
                    Certificate.curriculum_path_id == path.id,
                    Certificate.certificate_type == CertificateType.curriculum,
                )
            ).scalar_one_or_none()
            if existing:
                continue
            cert = Certificate(
                user_id=user_id,
                certificate_type=CertificateType.curriculum,
                course_id=None,
                curriculum_path_id=path.id,
                niche_id=None,
                niche_slug=path.niche_slug,
                certificate_code=f"RWR-CUR-{str(path.id).split('-')[0].upper()}-{str(user_id).split('-')[0].upper()}",
                verification_code=f"VC-{uuid.uuid4().hex[:16].upper()}",
                issued_at=datetime.now(timezone.utc),
                meta={"curriculum_name": path.name},
            )
            db.add(cert)
            results.append(cert)
            niche_row = db.execute(select(Niche).where(Niche.slug == path.niche_slug)).scalar_one_or_none()
            if niche_row:
                enqueue_niche_skill_recalc(
                    db,
                    pro_user_id=user_id,
                    niche_id=niche_row.id,
                    reason="curriculum_certificate_issued",
                )
            log_event(db, event_name="learn.curriculum_completed", user_id=user_id, properties={"curriculum_path_id": str(path.id)})
    if results:
        db.flush()
    return results
