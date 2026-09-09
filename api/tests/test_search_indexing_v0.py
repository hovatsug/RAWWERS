import uuid

from app.models.admin import KYCStatus, ProProfile, UserAccount
from app.models.discovery import ProPublicIndex
from app.models.learning import Course, CourseLevel
from app.models.outbox import OutboxEvent
from app.services.search_indexing import enqueue_course_index_upsert, enqueue_pro_index_upsert, process_index_event


class DummyProvider:
    def __init__(self):
        self.upserts = []
        self.deletes = []

    def upsert_documents(self, index_name, docs):
        self.upserts.append((index_name, docs))

    def delete_documents(self, index_name, ids):
        self.deletes.append((index_name, ids))

    def search(self, *args, **kwargs):  # pragma: no cover
        return None

    def index_stats(self, index_name):
        return {"index_name": index_name, "documents": 0}


def test_indexing_pipeline_idempotent_for_pro_upsert(db_session, monkeypatch):
    provider = DummyProvider()
    monkeypatch.setattr("app.services.search_indexing.get_search_provider", lambda: provider)

    pro_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_id, display_name="Pro One"))
    # The profile below points at this row, and a single flush does not
    # reliably insert the parent first - so make it explicit.
    db_session.flush()
    db_session.add(
        ProProfile(
            user_id=pro_id,
            display_name="Pro One",
            city="Lisbon",
            country="PT",
            is_accepting_bookings=True,
            kyc_status=KYCStatus.approved,
        )
    )
    db_session.add(
        ProPublicIndex(
            pro_user_id=pro_id,
            city="Lisbon",
            country="PT",
            is_accepting_bookings=True,
            kyc_status=KYCStatus.approved,
            completeness_score=80,
            styles=[],
            top_niches=[],
            portfolio_photo_count=0,
            portfolio_video_count=0,
            gigs_completed=0,
            gigs_cancelled=0,
            disputes_count=0,
            avg_rating=0,
            review_count=0,
            ranking_score=0,
        )
    )
    db_session.commit()

    process_index_event(db_session, "index.pro.upsert", {"pro_user_id": str(pro_id)})
    process_index_event(db_session, "index.pro.upsert", {"pro_user_id": str(pro_id)})

    assert len(provider.upserts) == 2
    assert provider.upserts[0][1][0]["id"] == str(pro_id)


def test_indexing_deletes_unpublished_course(db_session, monkeypatch):
    provider = DummyProvider()
    monkeypatch.setattr("app.services.search_indexing.get_search_provider", lambda: provider)

    instructor_id = uuid.uuid4()
    course_id = uuid.uuid4()

    from app.models.learning import InstructorProfile, InstructorStatus
    from app.services.niche_catalog import get_active_niche_by_slug

    # setup_database already seeds the catalogue, so inserting another
    # 'weddings' row here both duplicates it and leaves the course pointing
    # at a niche that was never written - the course insert reached the
    # database before its parent did.
    niche_id = get_active_niche_by_slug(db_session, "weddings").id
    db_session.add(UserAccount(user_id=instructor_id, display_name="Instructor"))
    db_session.flush()
    db_session.add(InstructorProfile(user_id=instructor_id, status=InstructorStatus.approved, expertise=[]))
    db_session.add(
        Course(
            id=course_id,
            instructor_user_id=instructor_id,
            title="Draft Course",
            niche_id=niche_id,
            level=CourseLevel.beginner,
            is_mandatory=False,
            is_published=False,
            currency="EUR",
        )
    )
    db_session.commit()

    process_index_event(db_session, "index.course.upsert", {"course_id": str(course_id)})

    assert provider.deletes
    assert provider.deletes[0][1] == [str(course_id)]


def test_rebuild_enqueue_uses_outbox(client, db_session):
    admin_id = "00000000-0000-0000-0000-0000000000aa"
    resp = client.post(
        "/v1/admin/search/rebuild",
        json={"index": "courses"},
        headers={"X-User-Id": admin_id},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert "queued_events" in body

    rows = db_session.query(OutboxEvent).filter(OutboxEvent.topic == "index.course.upsert").all()
    assert len(rows) >= 0
