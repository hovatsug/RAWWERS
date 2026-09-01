from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import Dispute, DisputeCategory, DisputeStatus, UserAccount, UserRole, UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche
from app.models.outbox import OutboxEvent
from app.models.payouts import EarningsEntryStatus, EarningsSourceType
from app.services.disputes import escalate_due_disputes
from app.services.gig_state import find_and_flag_stuck_gigs
from app.services.payouts import create_earnings_entry, settle_due_earnings_entries
from app.services.scheduling import expire_pending_booking_requests
from app.tasks.scheduled import expire_booking_requests_task, sweep_stuck_bookings_task

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _stuck_gig_notifications(db_session, gig_id) -> list[OutboxEvent]:
    rows = db_session.query(OutboxEvent).filter_by(topic="notify.create_inapp").all()
    return [row for row in rows if (row.payload or {}).get("reference_id") == str(gig_id)]


def _seed_user(db_session, user_id, roles=()):
    uid = uuid.UUID(user_id) if isinstance(user_id, str) else user_id
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
    for role in roles:
        if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.flush()
    return uid


def _make_package(db_session, pro_id) -> ProPackage:
    pkg = ProPackage(
        pro_user_id=pro_id,
        niche_id=db_session.query(Niche).filter_by(slug="portraits").first().id,
        title="Pkg",
        duration_minutes=60,
        price=Decimal("100.00"),
        currency="EUR",
        included_photos=10,
        extra_photo_price=Decimal("10.00"),
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
    )
    db_session.add(pkg)
    db_session.flush()
    return pkg


def _make_booking_request(
    db_session, *, pro_id, client_id, package_id, status=BookingRequestStatus.pending, expires_at=None
) -> BookingRequest:
    req = BookingRequest(
        pro_user_id=pro_id,
        client_user_id=client_id,
        package_id=package_id,
        requested_start=datetime.now(timezone.utc),
        requested_end=datetime.now(timezone.utc) + timedelta(hours=1),
        status=status,
        expires_at=expires_at or (datetime.now(timezone.utc) + timedelta(hours=1)),
    )
    db_session.add(req)
    db_session.flush()
    return req


def _make_gig(db_session, *, client_id, pro_id, status=GigStatus.paid, updated_at=None) -> Gig:
    gig = Gig(
        client_user_id=client_id,
        pro_user_id=pro_id,
        status=status,
        currency="EUR",
        amount_total=Decimal("120.00"),
        amount_platform_fee=Decimal("24.00"),
        amount_pro_gross=Decimal("96.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    if updated_at is not None:
        db_session.query(Gig).filter_by(id=gig.id).update({"updated_at": updated_at})
        db_session.flush()
        db_session.refresh(gig)
    return gig


def _make_dispute(
    db_session, *, gig_id, opened_by, against, status=DisputeStatus.open, due_response_at=None
) -> Dispute:
    dispute = Dispute(
        gig_id=gig_id,
        opened_by_user_id=opened_by,
        against_user_id=against,
        category=DisputeCategory.billing,
        status=status,
        summary="issue",
        reason="issue",
        currency="EUR",
        due_response_at=due_response_at,
    )
    db_session.add(dispute)
    db_session.flush()
    return dispute


# --- expire_booking_requests -------------------------------------------------


def test_expire_booking_requests_transitions_past_deadline(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pkg = _make_package(db_session, pro_id)
    req = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db_session.commit()

    count = expire_pending_booking_requests(db_session)
    db_session.commit()

    assert count == 1
    db_session.refresh(req)
    assert req.status == BookingRequestStatus.expired


def test_expire_booking_requests_leaves_future_deadline_untouched(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pkg = _make_package(db_session, pro_id)
    req = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=1),
    )
    db_session.commit()

    count = expire_pending_booking_requests(db_session)
    db_session.commit()

    assert count == 0
    db_session.refresh(req)
    assert req.status == BookingRequestStatus.pending


def test_expire_booking_requests_idempotent_on_rerun(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pkg = _make_package(db_session, pro_id)
    req = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db_session.commit()

    first = expire_pending_booking_requests(db_session)
    db_session.commit()
    second = expire_pending_booking_requests(db_session)
    db_session.commit()

    assert first == 1
    assert second == 0
    db_session.refresh(req)
    assert req.status == BookingRequestStatus.expired


def test_expire_booking_requests_ignores_terminal_state(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pkg = _make_package(db_session, pro_id)
    req = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        status=BookingRequestStatus.cancelled,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db_session.commit()

    count = expire_pending_booking_requests(db_session)
    db_session.commit()

    assert count == 0
    db_session.refresh(req)
    assert req.status == BookingRequestStatus.cancelled


def test_expire_booking_requests_error_isolation(db_session, monkeypatch):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pkg = _make_package(db_session, pro_id)
    good1 = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=10),
    )
    bad = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    good2 = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=1),
    )
    db_session.commit()

    import app.services.scheduling as scheduling_module

    real_cls = scheduling_module.BookingRequestTransition

    def flaky(*args, booking_request_id=None, **kwargs):
        if booking_request_id == bad.id:
            raise RuntimeError("simulated failure")
        return real_cls(*args, booking_request_id=booking_request_id, **kwargs)

    monkeypatch.setattr(scheduling_module, "BookingRequestTransition", flaky)

    count = expire_pending_booking_requests(db_session)
    db_session.commit()

    assert count == 2
    db_session.refresh(good1)
    db_session.refresh(bad)
    db_session.refresh(good2)
    assert good1.status == BookingRequestStatus.expired
    assert bad.status == BookingRequestStatus.pending
    assert good2.status == BookingRequestStatus.expired


def test_expire_booking_requests_task_wrapper(db_session, monkeypatch):
    import app.tasks.scheduled as scheduled_module

    monkeypatch.setattr(scheduled_module, "SessionLocal", lambda: db_session)
    monkeypatch.setattr(db_session, "close", lambda: None)

    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pkg = _make_package(db_session, pro_id)
    req = _make_booking_request(
        db_session, pro_id=pro_id, client_id=client_id, package_id=pkg.id,
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
    )
    db_session.commit()

    count = expire_booking_requests_task.run()

    assert count == 1
    db_session.refresh(req)
    assert req.status == BookingRequestStatus.expired


# --- release_payout_holds (settle_due_earnings_entries) ----------------------


def test_release_payout_holds_settles_past_available_at(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    entry = create_earnings_entry(
        db_session, pro_user_id=pro_id, source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(), gross_eur=Decimal("100.00"), metadata={},
    )
    entry.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()

    changed = settle_due_earnings_entries(db_session)
    db_session.commit()

    assert changed == 1
    db_session.refresh(entry)
    assert entry.status == EarningsEntryStatus.available


def test_release_payout_holds_leaves_not_yet_due_untouched(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    entry = create_earnings_entry(
        db_session, pro_user_id=pro_id, source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(), gross_eur=Decimal("100.00"), metadata={},
    )
    db_session.commit()
    assert entry.available_at > datetime.now(timezone.utc)

    changed = settle_due_earnings_entries(db_session)
    db_session.commit()

    assert changed == 0
    db_session.refresh(entry)
    assert entry.status == EarningsEntryStatus.pending


def test_release_payout_holds_idempotent_on_rerun(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    entry = create_earnings_entry(
        db_session, pro_user_id=pro_id, source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(), gross_eur=Decimal("100.00"), metadata={},
    )
    entry.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()

    first = settle_due_earnings_entries(db_session)
    db_session.commit()
    second = settle_due_earnings_entries(db_session)
    db_session.commit()

    assert first == 1
    assert second == 0


def test_release_payout_holds_ignores_reversed_entries(db_session):
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    entry = create_earnings_entry(
        db_session, pro_user_id=pro_id, source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(), gross_eur=Decimal("100.00"), metadata={},
    )
    entry.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    entry.reversed_at = datetime.now(timezone.utc)
    db_session.commit()

    changed = settle_due_earnings_entries(db_session)
    db_session.commit()

    assert changed == 0
    db_session.refresh(entry)
    assert entry.status == EarningsEntryStatus.pending


def test_release_payout_holds_error_isolation(db_session, monkeypatch):
    pro_a = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    pro_b = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    good = create_earnings_entry(
        db_session, pro_user_id=pro_a, source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(), gross_eur=Decimal("50.00"), metadata={},
    )
    bad = create_earnings_entry(
        db_session, pro_user_id=pro_b, source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(), gross_eur=Decimal("75.00"), metadata={},
    )
    good.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    bad.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()

    import app.services.payouts as payouts_module

    real_fn = payouts_module._entry_should_be_held

    def flaky(db, *, pro_user_id, source_type, source_id):
        if pro_user_id == pro_b:
            raise RuntimeError("simulated failure")
        return real_fn(db, pro_user_id=pro_user_id, source_type=source_type, source_id=source_id)

    monkeypatch.setattr(payouts_module, "_entry_should_be_held", flaky)

    changed = settle_due_earnings_entries(db_session)
    db_session.commit()

    assert changed == 1
    db_session.refresh(good)
    db_session.refresh(bad)
    assert good.status == EarningsEntryStatus.available
    assert bad.status == EarningsEntryStatus.pending


# --- escalate_stale_disputes (escalate_due_disputes) --------------------------


def test_escalate_stale_disputes_escalates_past_due_response(db_session):
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig = _make_gig(db_session, client_id=client_id, pro_id=pro_id)
    dispute = _make_dispute(
        db_session, gig_id=gig.id, opened_by=client_id, against=pro_id,
        due_response_at=datetime.now(timezone.utc) - timedelta(hours=1),
    )
    db_session.commit()

    count = escalate_due_disputes(db_session)
    db_session.commit()

    assert count == 1
    db_session.refresh(dispute)
    assert dispute.status == DisputeStatus.awaiting_admin


def test_escalate_stale_disputes_leaves_not_yet_due_untouched(db_session):
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig = _make_gig(db_session, client_id=client_id, pro_id=pro_id)
    dispute = _make_dispute(
        db_session, gig_id=gig.id, opened_by=client_id, against=pro_id,
        due_response_at=datetime.now(timezone.utc) + timedelta(hours=1),
    )
    db_session.commit()

    count = escalate_due_disputes(db_session)
    db_session.commit()

    assert count == 0
    db_session.refresh(dispute)
    assert dispute.status == DisputeStatus.open


def test_escalate_stale_disputes_idempotent_on_rerun(db_session):
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig = _make_gig(db_session, client_id=client_id, pro_id=pro_id)
    _make_dispute(
        db_session, gig_id=gig.id, opened_by=client_id, against=pro_id,
        due_response_at=datetime.now(timezone.utc) - timedelta(hours=1),
    )
    db_session.commit()

    first = escalate_due_disputes(db_session)
    db_session.commit()
    second = escalate_due_disputes(db_session)
    db_session.commit()

    assert first == 1
    assert second == 0


def test_escalate_stale_disputes_ignores_terminal_state(db_session):
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig = _make_gig(db_session, client_id=client_id, pro_id=pro_id)
    dispute = _make_dispute(
        db_session, gig_id=gig.id, opened_by=client_id, against=pro_id,
        status=DisputeStatus.resolved_no_refund,
        due_response_at=datetime.now(timezone.utc) - timedelta(hours=1),
    )
    db_session.commit()

    count = escalate_due_disputes(db_session)
    db_session.commit()

    assert count == 0
    db_session.refresh(dispute)
    assert dispute.status == DisputeStatus.resolved_no_refund


def test_escalate_stale_disputes_error_isolation(db_session, monkeypatch):
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig_a = _make_gig(db_session, client_id=client_id, pro_id=pro_id)
    gig_b = _make_gig(db_session, client_id=client_id, pro_id=pro_id)
    good = _make_dispute(
        db_session, gig_id=gig_a.id, opened_by=client_id, against=pro_id,
        due_response_at=datetime.now(timezone.utc) - timedelta(hours=2),
    )
    bad = _make_dispute(
        db_session, gig_id=gig_b.id, opened_by=client_id, against=pro_id,
        due_response_at=datetime.now(timezone.utc) - timedelta(hours=1),
    )
    db_session.commit()

    import app.services.disputes as disputes_module

    real_log_event = disputes_module.log_event

    def flaky(db, *, event_name, user_id, properties=None, **kwargs):
        if properties and properties.get("dispute_id") == str(bad.id):
            raise RuntimeError("simulated failure")
        return real_log_event(db, event_name=event_name, user_id=user_id, properties=properties, **kwargs)

    monkeypatch.setattr(disputes_module, "log_event", flaky)

    count = escalate_due_disputes(db_session)
    db_session.commit()

    assert count == 1
    db_session.refresh(good)
    db_session.refresh(bad)
    assert good.status == DisputeStatus.awaiting_admin
    assert bad.status == DisputeStatus.open


# --- sweep_stuck_bookings ------------------------------------------------------


def test_sweep_stuck_bookings_flags_old_non_terminal_gig(db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig = _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.paid,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=800),
    )
    db_session.commit()

    count = find_and_flag_stuck_gigs(db_session, max_age_hours=720)
    db_session.commit()

    assert count == 1
    assert len(_stuck_gig_notifications(db_session, gig.id)) == 1


def test_sweep_stuck_bookings_leaves_recent_gig_untouched(db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.paid,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=1),
    )
    db_session.commit()

    count = find_and_flag_stuck_gigs(db_session, max_age_hours=720)
    db_session.commit()

    assert count == 0


def test_sweep_stuck_bookings_does_not_repage_same_gig(db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    gig = _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.paid,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=800),
    )
    db_session.commit()

    first = find_and_flag_stuck_gigs(db_session, max_age_hours=720)
    db_session.commit()
    second = find_and_flag_stuck_gigs(db_session, max_age_hours=720)
    db_session.commit()

    # Flagged (and logged) both times - it's still stuck - but the admin
    # notification is deduped per gig via a stable dedupe_key, not resent.
    assert first == 1
    assert second == 1
    assert len(_stuck_gig_notifications(db_session, gig.id)) == 1


def test_sweep_stuck_bookings_ignores_terminal_state(db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.completed,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=800),
    )
    db_session.commit()

    count = find_and_flag_stuck_gigs(db_session, max_age_hours=720)
    db_session.commit()

    assert count == 0


def test_sweep_stuck_bookings_error_isolation(db_session, monkeypatch):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    good = _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.paid,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=800),
    )
    bad = _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.paid,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=750),
    )
    db_session.commit()

    import app.services.gig_state as gig_state_module

    real_fn = gig_state_module.enqueue_notification

    def flaky(db, *, user_id, notification_type, reference_id=None, **kwargs):
        if reference_id == str(bad.id):
            raise RuntimeError("simulated failure")
        return real_fn(db, user_id=user_id, notification_type=notification_type, reference_id=reference_id, **kwargs)

    monkeypatch.setattr(gig_state_module, "enqueue_notification", flaky)

    count = find_and_flag_stuck_gigs(db_session, max_age_hours=720)
    db_session.commit()

    assert count == 1
    assert len(_stuck_gig_notifications(db_session, good.id)) == 1
    assert len(_stuck_gig_notifications(db_session, bad.id)) == 0


def test_sweep_stuck_bookings_task_wrapper(db_session, monkeypatch):
    import app.tasks.scheduled as scheduled_module

    monkeypatch.setattr(scheduled_module, "SessionLocal", lambda: db_session)
    monkeypatch.setattr(db_session, "close", lambda: None)

    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    client_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.client])
    pro_id = _seed_user(db_session, str(uuid.uuid4()), [UserRoleType.pro])
    _make_gig(
        db_session, client_id=client_id, pro_id=pro_id, status=GigStatus.paid,
        updated_at=datetime.now(timezone.utc) - timedelta(hours=800),
    )
    db_session.commit()

    count = sweep_stuck_bookings_task.run()

    assert count == 1
