from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.learning import (
    Certificate,
    Course,
    CourseLevel,
    CourseModule,
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
)
from app.models.media import MediaAsset, MediaKind
from app.models.niche import CertificationRecord, Niche, SkillTier
from app.services.analytics import log_event
from app.services.discovery_index import recompute_pro_public_index
from app.services.niche_skills import recompute_pro_niche_skills

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
