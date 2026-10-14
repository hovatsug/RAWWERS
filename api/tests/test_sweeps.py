"""The two sweeps that release held time - unanswered requests and unpaid
bookings - run every minute.

Correctness never waited for them: accept, confirm-slot, payment and the
holds all read the deadlines themselves. The sweeps make the status the
lists show catch up, and on a 30-minute short-notice clock a quarter of an
hour late was visible. Every minute means two things must hold: a run that
overlaps the previous one does nothing, and a run with nothing due costs one
indexed query.
"""
import uuid
from datetime import datetime, timedelta, timezone

from app.core.config import get_settings
from app.db.session import engine
from app.models.admin import UserRoleType
from app.models.booking import BookingRequestStatus
from app.models.gig import GigStatus
from app.services.bookable_time import expire_unpaid_gigs
from app.services.scheduling import expire_pending_booking_requests
from app.tasks import scheduled
from app.tasks.celery_app import celery_app
from sqlalchemy import event, text

from tests.test_scheduled_tasks import _make_booking_request, _make_gig, _make_package, _seed_user

LONG_AGO = datetime(2000, 1, 1, tzinfo=timezone.utc)


def test_both_sweeps_run_every_minute():
    assert get_settings().booking_request_expiry_sweep_interval_seconds == 60
    schedule = celery_app.conf.beat_schedule
    for name in ("expire-booking-requests", "expire-unpaid-gigs"):
        assert schedule[name]["schedule"] == timedelta(seconds=60), name


def _due_request(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    package = _make_package(db_session, pro_id)
    request = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=package.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=1),
    )
    db_session.commit()
    return request


def _due_gig(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    gig = _make_gig(db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.payment_pending)
    gig.pay_deadline_at = datetime.now(timezone.utc) - timedelta(minutes=1)
    db_session.commit()
    return gig


class _AnotherRun:
    """A sweep already under way: its lock, held from another connection."""

    def __init__(self, key: int):
        self.key = key

    def __enter__(self):
        self.conn = engine.connect()
        self.trans = self.conn.begin()
        assert self.conn.execute(text("SELECT pg_try_advisory_xact_lock(:k)"), {"k": self.key}).scalar()
        return self

    def __exit__(self, *exc):
        self.trans.rollback()
        self.conn.close()


def test_a_request_sweep_that_overlaps_a_running_one_does_nothing(db_session):
    request = _due_request(db_session)

    with _AnotherRun(scheduled.SWEEP_LOCK_KEYS["expire_booking_requests"]):
        assert scheduled.expire_booking_requests_task.run() == 0
        db_session.refresh(request)
        assert request.status == BookingRequestStatus.pending

    assert scheduled.expire_booking_requests_task.run() >= 1
    db_session.refresh(request)
    assert request.status == BookingRequestStatus.expired


def test_an_unpaid_booking_sweep_that_overlaps_a_running_one_does_nothing(db_session):
    gig = _due_gig(db_session)

    with _AnotherRun(scheduled.SWEEP_LOCK_KEYS["expire_unpaid_gigs"]):
        assert scheduled.expire_unpaid_gigs_task.run() == 0
        db_session.refresh(gig)
        assert gig.status == GigStatus.payment_pending

    assert scheduled.expire_unpaid_gigs_task.run() >= 1
    db_session.refresh(gig)
    assert gig.status != GigStatus.payment_pending


def test_the_two_sweeps_do_not_block_each_other(db_session):
    request = _due_request(db_session)

    with _AnotherRun(scheduled.SWEEP_LOCK_KEYS["expire_unpaid_gigs"]):
        assert scheduled.expire_booking_requests_task.run() >= 1

    db_session.refresh(request)
    assert request.status == BookingRequestStatus.expired


def _statements(db_session, run) -> list[str]:
    seen = []
    bind = db_session.get_bind()
    listener = lambda conn, cursor, statement, *args: seen.append(statement)  # noqa: E731
    event.listen(bind, "before_cursor_execute", listener)
    try:
        run()
    finally:
        event.remove(bind, "before_cursor_execute", listener)
    return seen


def test_a_request_sweep_with_nothing_due_is_one_query(db_session):
    statements = _statements(db_session, lambda: expire_pending_booking_requests(db_session, now=LONG_AGO))
    assert len(statements) == 1, statements
    assert statements[0].lstrip().upper().startswith("SELECT")


def test_an_unpaid_booking_sweep_with_nothing_due_is_one_query(db_session):
    statements = _statements(db_session, lambda: expire_unpaid_gigs(db_session, now=LONG_AGO))
    assert len(statements) == 1, statements
    assert statements[0].lstrip().upper().startswith("SELECT")


def test_the_request_sweeps_query_can_use_its_index(db_session):
    """With sequential scans ruled out, the planner still has a way in: the
    partial index on pending requests' deadlines. Without it, every minute's
    run reads the whole table."""
    db_session.execute(text("SET LOCAL enable_seqscan = off"))
    plan = "\n".join(
        row[0]
        for row in db_session.execute(
            text("EXPLAIN SELECT id FROM booking_request WHERE status = 'pending' AND expires_at < now() ORDER BY expires_at LIMIT 100")
        )
    )
    db_session.rollback()
    assert "ix_booking_request_pending_expires" in plan, plan
