import uuid
from datetime import datetime, timezone
from decimal import Decimal

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.learning import (
    Certificate,
    Course,
    CourseLevel,
    CourseModule,
    CoursePricingMode,
    CourseQuiz,
    CourseSale,
    CourseStatus,
    CurriculumPath,
    CurriculumRequirement,
    CurriculumRequirementType,
    Enrollment,
)
from app.models.niche import Niche

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


def _seed_approved_course(db_session, creator_user_id: str, *, paid: bool) -> tuple[Course, CourseModule]:
    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    assert niche is not None
    course = Course(
        instructor_user_id=uuid.UUID(creator_user_id),
        creator_user_id=uuid.UUID(creator_user_id),
        niche_id=niche.id,
        niche_slugs=["portraits"],
        title="Lighting 101",
        title_custom="Lighting 101",
        summary="Course summary",
        description_custom="Course summary",
        language="en-GB",
        level=CourseLevel.beginner,
        pricing_mode=CoursePricingMode.paid if paid else CoursePricingMode.free,
        price=Decimal("29.00") if paid else None,
        price_eur=Decimal("29.00") if paid else None,
        currency="EUR",
        status=CourseStatus.approved,
        is_published=True,
        approved_at=datetime.now(timezone.utc),
    )
    db_session.add(course)
    db_session.flush()
    module = CourseModule(
        course_id=course.id,
        title="Module 1",
        sort_order=1,
        duration_seconds=10,
    )
    db_session.add(module)
    db_session.commit()
    return course, module


def test_partner_submission_and_admin_review_workflow(client, db_session):
    partner_user_id = str(uuid.uuid4())
    _ensure_user_role(db_session, partner_user_id, UserRoleType.pro)
    _ensure_user_role(db_session, ADMIN_ID, UserRoleType.admin)

    create = client.post(
        "/v1/partner/learn/courses",
        headers={"X-User-Id": partner_user_id},
        json={
            "title_custom": "Wedding Masterclass",
            "description_custom": "Deep dive",
            "niche_slugs": ["weddings"],
            "pricing_mode": "free",
        },
    )
    assert create.status_code == 200
    course_id = create.json()["id"]

    submit = client.post(f"/v1/partner/learn/courses/{course_id}/submit", headers={"X-User-Id": partner_user_id})
    assert submit.status_code == 200
    assert submit.json()["status"] == "submitted"

    review = client.post(
        f"/v1/admin/learn/courses/{course_id}/review",
        headers={"X-User-Id": ADMIN_ID},
        json={"decision": "approved", "notes": "ready"},
    )
    assert review.status_code == 200
    assert review.json()["status"] == "approved"

    listed = client.get("/v1/learn/courses")
    assert listed.status_code == 200
    assert any(item["id"] == course_id for item in listed.json()["items"])


def test_paid_and_free_enrollment_rules(client, db_session):
    creator = str(uuid.uuid4())
    learner = str(uuid.uuid4())
    _ensure_user_role(db_session, creator, UserRoleType.pro)
    _ensure_user_role(db_session, learner, UserRoleType.pro)

    free_course, _ = _seed_approved_course(db_session, creator, paid=False)
    paid_course, _ = _seed_approved_course(db_session, creator, paid=True)

    free_resp = client.post(f"/v1/learn/courses/{free_course.id}/enroll", headers={"X-User-Id": learner})
    assert free_resp.status_code == 200
    assert free_resp.json()["paid"] is True

    paid_resp = client.post(f"/v1/learn/courses/{paid_course.id}/enroll", headers={"X-User-Id": learner})
    assert paid_resp.status_code == 200
    assert paid_resp.json()["paid"] is False
    enrollment_id = paid_resp.json()["enrollment_id"]

    settle = client.post(f"/v1/learn/enrollments/{enrollment_id}/pay", headers={"X-User-Id": learner})
    assert settle.status_code == 200
    assert settle.json()["paid"] is True

    sale = db_session.query(CourseSale).filter_by(course_id=paid_course.id, user_id=uuid.UUID(learner)).first()
    assert sale is not None


def test_video_progress_anticheat_caps_delta(client, db_session):
    creator = str(uuid.uuid4())
    learner = str(uuid.uuid4())
    _ensure_user_role(db_session, creator, UserRoleType.pro)
    _ensure_user_role(db_session, learner, UserRoleType.pro)

    course, module = _seed_approved_course(db_session, creator, paid=False)
    enroll_resp = client.post(f"/v1/learn/courses/{course.id}/enroll", headers={"X-User-Id": learner})
    enrollment_id = enroll_resp.json()["enrollment_id"]

    progress = client.post(
        f"/v1/learn/enrollments/{enrollment_id}/modules/{module.id}/progress",
        headers={"X-User-Id": learner},
        json={"watch_seconds_delta": 1000, "position_seconds": 5},
    )
    assert progress.status_code == 200
    assert progress.json()["watch_seconds"] <= 60


def test_quiz_completion_and_certificate_verification(client, db_session):
    creator = str(uuid.uuid4())
    learner = str(uuid.uuid4())
    _ensure_user_role(db_session, creator, UserRoleType.pro)
    _ensure_user_role(db_session, learner, UserRoleType.pro)

    course, module = _seed_approved_course(db_session, creator, paid=False)
    db_session.add(
        CourseQuiz(
            module_id=module.id,
            questions=[
                {"prompt": "Q1", "choices": ["A", "B"], "correct_index": 1},
                {"prompt": "Q2", "choices": ["A", "B"], "correct_index": 0},
            ],
            pass_score_percent=70,
        )
    )
    path = CurriculumPath(niche_slug="portraits", name="Portrait Path", is_active=True)
    db_session.add(path)
    db_session.flush()
    db_session.add(
        CurriculumRequirement(
            curriculum_path_id=path.id,
            course_id=course.id,
            requirement_type=CurriculumRequirementType.mandatory,
            min_score_percent=70,
            order_index=1,
        )
    )
    db_session.commit()

    enroll_resp = client.post(f"/v1/learn/courses/{course.id}/enroll", headers={"X-User-Id": learner})
    enrollment_id = enroll_resp.json()["enrollment_id"]

    progress = client.post(
        f"/v1/learn/enrollments/{enrollment_id}/modules/{module.id}/progress",
        headers={"X-User-Id": learner},
        json={"watch_seconds_delta": 30, "position_seconds": 10},
    )
    assert progress.status_code == 200

    quiz = client.post(
        f"/v1/learn/enrollments/{enrollment_id}/modules/{module.id}/quiz",
        headers={"X-User-Id": learner},
        json={"answers": [1, 0]},
    )
    assert quiz.status_code == 200
    assert quiz.json()["passed"] is True

    cert_rows = db_session.query(Certificate).filter_by(user_id=uuid.UUID(learner)).all()
    assert len(cert_rows) >= 2
    verify_code = cert_rows[0].verification_code or cert_rows[0].certificate_code
    verify = client.get(f"/v1/learn/certificates/{verify_code}")
    assert verify.status_code == 200
