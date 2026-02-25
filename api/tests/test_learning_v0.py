import uuid
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.learning import (
    Certificate,
    Course,
    CourseLevel,
    CourseModule,
    Enrollment,
    InstructorProfile,
    InstructorStatus,
    Lesson,
    LessonContentType,
    NicheProgramRequirement,
)
from app.models.niche import CertificationRecord, Niche, ProNicheSkill

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not exists:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _seed_approved_instructor(db_session, user_id: str):
    uid = uuid.UUID(user_id)
    row = db_session.get(InstructorProfile, uid)
    if not row:
        row = InstructorProfile(user_id=uid)
        db_session.add(row)
    row.status = InstructorStatus.approved
    row.expertise = ["portraits"]
    db_session.commit()


def _seed_published_course(db_session, instructor_user_id: str, niche_slug: str = "portraits") -> Course:
    niche = db_session.query(Niche).filter_by(slug=niche_slug).first()
    assert niche is not None
    course = Course(
        instructor_user_id=uuid.UUID(instructor_user_id),
        title="Portrait Mastery",
        summary="Learn portraits",
        niche_id=niche.id,
        level=CourseLevel.intermediate,
        is_mandatory=False,
        is_published=True,
        price=None,
        currency="EUR",
    )
    db_session.add(course)
    db_session.flush()
    module = CourseModule(course_id=course.id, title="Basics", sort_order=1)
    db_session.add(module)
    db_session.flush()
    lesson = Lesson(
        module_id=module.id,
        title="Setup",
        content_type=LessonContentType.text,
        body_text="Body",
        sort_order=1,
        is_preview_free=False,
    )
    db_session.add(lesson)
    db_session.commit()
    db_session.refresh(course)
    return course


def test_non_approved_instructor_cannot_publish(client, db_session):
    instructor_id = str(uuid.uuid4())
    _ensure_user_role(db_session, instructor_id, UserRoleType.pro)
    course = _seed_published_course(db_session, instructor_id)
    course.is_published = False
    db_session.commit()

    resp = client.post(f"/v1/instructor/courses/{course.id}/publish", headers={"X-User-Id": instructor_id})
    assert resp.status_code == 403


def test_only_course_owner_instructor_can_edit(client, db_session):
    owner_id = str(uuid.uuid4())
    other_id = str(uuid.uuid4())
    _ensure_user_role(db_session, owner_id, UserRoleType.pro)
    _ensure_user_role(db_session, other_id, UserRoleType.pro)
    _seed_approved_instructor(db_session, owner_id)
    _seed_approved_instructor(db_session, other_id)

    course = _seed_published_course(db_session, owner_id)
    course.is_published = False
    db_session.commit()

    resp = client.put(
        f"/v1/instructor/courses/{course.id}",
        headers={"X-User-Id": other_id},
        json={"title": "Hacked"},
    )
    assert resp.status_code == 404


def test_completion_issues_certificate_and_certification_record(client, db_session):
    instructor_id = str(uuid.uuid4())
    learner_id = str(uuid.uuid4())
    _ensure_user_role(db_session, instructor_id, UserRoleType.pro)
    _ensure_user_role(db_session, learner_id, UserRoleType.pro)
    _seed_approved_instructor(db_session, instructor_id)

    course = _seed_published_course(db_session, instructor_id)
    enroll_resp = client.post(f"/v1/courses/{course.id}/enroll", headers={"X-User-Id": learner_id})
    assert enroll_resp.status_code == 200
    enrollment_id = enroll_resp.json()["enrollment_id"]

    lesson = db_session.query(Lesson).join(CourseModule, CourseModule.id == Lesson.module_id).filter(CourseModule.course_id == course.id).first()
    assert lesson is not None
    progress_resp = client.post(
        f"/v1/enrollments/{enrollment_id}/lessons/{lesson.id}/progress",
        headers={"X-User-Id": learner_id},
        json={"status": "completed", "progress_percent": 100},
    )
    assert progress_resp.status_code == 200

    certificate = db_session.query(Certificate).filter_by(user_id=uuid.UUID(learner_id), course_id=course.id).first()
    assert certificate is not None
    cert_record = db_session.query(CertificationRecord).filter_by(
        pro_user_id=uuid.UUID(learner_id),
        niche_id=course.niche_id,
    ).first()
    assert cert_record is not None
    assert cert_record.score >= 60


def test_certification_completion_triggers_niche_skill_recompute(client, db_session):
    instructor_id = str(uuid.uuid4())
    learner_id = str(uuid.uuid4())
    _ensure_user_role(db_session, instructor_id, UserRoleType.pro)
    _ensure_user_role(db_session, learner_id, UserRoleType.pro)
    _seed_approved_instructor(db_session, instructor_id)

    course = _seed_published_course(db_session, instructor_id)
    enrollment_id = client.post(f"/v1/courses/{course.id}/enroll", headers={"X-User-Id": learner_id}).json()["enrollment_id"]
    lesson = db_session.query(Lesson).join(CourseModule, CourseModule.id == Lesson.module_id).filter(CourseModule.course_id == course.id).first()
    assert lesson is not None
    client.post(
        f"/v1/enrollments/{enrollment_id}/lessons/{lesson.id}/progress",
        headers={"X-User-Id": learner_id},
        json={"status": "completed", "progress_percent": 100},
    )

    skill = db_session.query(ProNicheSkill).filter_by(pro_user_id=uuid.UUID(learner_id), niche_id=course.niche_id).first()
    assert skill is not None
    assert skill.certification_score >= 60


def test_admin_can_configure_niche_requirements(client, db_session):
    _ensure_user_role(db_session, ADMIN_ID, UserRoleType.admin)
    instructor_id = str(uuid.uuid4())
    _ensure_user_role(db_session, instructor_id, UserRoleType.pro)
    _seed_approved_instructor(db_session, instructor_id)
    course = _seed_published_course(db_session, instructor_id, niche_slug="weddings")

    resp = client.post(
        "/v1/admin/niches/weddings/requirements",
        headers={"X-User-Id": ADMIN_ID},
        json={"tier_target": "pro", "course_ids": [str(course.id)], "is_mandatory": True},
    )
    assert resp.status_code == 200
    row = db_session.query(NicheProgramRequirement).filter_by(course_id=course.id).first()
    assert row is not None


def test_lesson_progress_access_control(client, db_session):
    instructor_id = str(uuid.uuid4())
    learner_id = str(uuid.uuid4())
    outsider_id = str(uuid.uuid4())
    _ensure_user_role(db_session, instructor_id, UserRoleType.pro)
    _ensure_user_role(db_session, learner_id, UserRoleType.pro)
    _ensure_user_role(db_session, outsider_id, UserRoleType.pro)
    _seed_approved_instructor(db_session, instructor_id)

    course = _seed_published_course(db_session, instructor_id)
    enrollment_id = client.post(f"/v1/courses/{course.id}/enroll", headers={"X-User-Id": learner_id}).json()["enrollment_id"]
    lesson = db_session.query(Lesson).join(CourseModule, CourseModule.id == Lesson.module_id).filter(CourseModule.course_id == course.id).first()
    assert lesson is not None
    denied = client.post(
        f"/v1/enrollments/{enrollment_id}/lessons/{lesson.id}/progress",
        headers={"X-User-Id": outsider_id},
        json={"status": "completed", "progress_percent": 100},
    )
    assert denied.status_code == 403
