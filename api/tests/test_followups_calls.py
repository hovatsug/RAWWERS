import uuid
from datetime import datetime, timedelta, timezone

from app.core.config import get_settings
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.communication import (
    CallOutcome,
    CallSession,
    CallSessionStatus,
    ContactConsent,
    FollowupJob,
    FollowupJobStatus,
    Notification,
    UserContact,
)
from app.services.followups import process_due_followup_jobs, schedule_followups, seed_followup_rules
from app.tasks.call_tasks import execute_outbound_call_task

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _ensure_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _set_contact(db_session, user_id: str, phone: str = "+351911111111", qh_start: str = "22:00:00", qh_end: str = "08:00:00"):
    uid = uuid.UUID(user_id)
    contact = db_session.get(UserContact, uid)
    if not contact:
        contact = UserContact(user_id=uid)
        db_session.add(contact)
    contact.phone_e164 = phone
    contact.timezone_name = "Europe/Lisbon"
    contact.quiet_hours_start = datetime.strptime(qh_start, "%H:%M:%S").time()
    contact.quiet_hours_end = datetime.strptime(qh_end, "%H:%M:%S").time()
    db_session.commit()


def _grant_phone_consent(client, user_id: str, transcription_ok: bool = False):
    resp = client.post(
        "/v1/me/consent",
        headers={"X-User-Id": user_id},
        json={
            "channel": "phone_call",
            "scope": "transactional",
            "granted": True,
            "source": "in_app_toggle",
            "metadata": {"transcription_ok": transcription_ok},
        },
    )
    assert resp.status_code == 200


def test_calling_blocked_without_consent_except_call_me_button(client, db_session):
    client_id = str(uuid.uuid4())
    _ensure_role(db_session, client_id, UserRoleType.client)
    _set_contact(db_session, client_id)

    blocked = client.post(
        "/v1/calls/request",
        headers={"X-User-Id": client_id},
        json={"recipient_user_id": client_id, "purpose": "request_nudge"},
    )
    assert blocked.status_code == 409

    allowed = client.post(
        "/v1/calls/request",
        headers={"X-User-Id": client_id},
        json={"recipient_user_id": client_id, "purpose": "request_nudge", "source": "call_me_button"},
    )
    assert allowed.status_code == 200
    call_id = allowed.json()["id"]
    session = db_session.get(CallSession, uuid.UUID(call_id))
    assert session is not None
    call_me_events = db_session.query(ContactConsent).filter_by(user_id=uuid.UUID(client_id), source="call_me_button").count()
    assert call_me_events >= 1


def test_quiet_hours_enforced(client, db_session):
    client_id = str(uuid.uuid4())
    _ensure_role(db_session, client_id, UserRoleType.client)
    _set_contact(db_session, client_id, qh_start="00:00:00", qh_end="23:59:00")
    _grant_phone_consent(client, client_id)

    resp = client.post(
        "/v1/calls/request",
        headers={"X-User-Id": client_id},
        json={"recipient_user_id": client_id, "purpose": "request_nudge"},
    )
    assert resp.status_code == 409


def test_rate_limits_enforced(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_role(db_session, client_id, UserRoleType.client)
    _ensure_role(db_session, pro_id, UserRoleType.pro)
    _set_contact(db_session, client_id)
    _grant_phone_consent(client, client_id)

    settings = get_settings()
    old_user_limit = settings.call_rate_limit_per_user_per_day
    settings.call_rate_limit_per_user_per_day = 1
    try:
        first = client.post(
            "/v1/calls/request",
            headers={"X-User-Id": pro_id},
            json={"recipient_user_id": client_id, "purpose": "request_nudge", "pro_user_id": pro_id},
        )
        assert first.status_code == 200
        second = client.post(
            "/v1/calls/request",
            headers={"X-User-Id": pro_id},
            json={"recipient_user_id": client_id, "purpose": "request_nudge", "pro_user_id": pro_id},
        )
        assert second.status_code == 429
    finally:
        settings.call_rate_limit_per_user_per_day = old_user_limit


def test_followup_job_idempotency(client, db_session):
    user_id = str(uuid.uuid4())
    _ensure_role(db_session, user_id, UserRoleType.client)
    seed_followup_rules(db_session)
    db_session.commit()
    target_id = uuid.uuid4()

    first = schedule_followups(
        db_session,
        trigger="payment_pending.client",
        user_id=uuid.UUID(user_id),
        target_type="gig",
        target_id=target_id,
        now=datetime(2026, 2, 25, 12, 0, tzinfo=timezone.utc),
    )
    second = schedule_followups(
        db_session,
        trigger="payment_pending.client",
        user_id=uuid.UUID(user_id),
        target_type="gig",
        target_id=target_id,
        now=datetime(2026, 2, 25, 12, 0, tzinfo=timezone.utc),
    )
    db_session.commit()
    assert len(first) >= 1
    assert len(second) == 0

    total = db_session.query(FollowupJob).filter_by(user_id=uuid.UUID(user_id), target_id=target_id).count()
    assert total == len(first)


def test_mock_telephony_flow_updates_status_and_outcome(client, db_session):
    client_id = str(uuid.uuid4())
    _ensure_role(db_session, client_id, UserRoleType.client)
    _set_contact(db_session, client_id)
    _grant_phone_consent(client, client_id)

    queued = client.post(
        "/v1/calls/request",
        headers={"X-User-Id": client_id},
        json={"recipient_user_id": client_id, "purpose": "booking_confirmation"},
    )
    assert queued.status_code == 200
    call_id = queued.json()["id"]
    execute_outbound_call_task(call_id)

    session = db_session.get(CallSession, uuid.UUID(call_id))
    assert session.status == CallSessionStatus.completed
    assert session.outcome == CallOutcome.connected


def test_transcript_not_stored_without_explicit_consent(client, db_session):
    client_id = str(uuid.uuid4())
    _ensure_role(db_session, client_id, UserRoleType.client)
    _set_contact(db_session, client_id)
    _grant_phone_consent(client, client_id, transcription_ok=False)

    queued = client.post(
        "/v1/calls/request",
        headers={"X-User-Id": client_id},
        json={"recipient_user_id": client_id, "purpose": "booking_confirmation"},
    )
    assert queued.status_code == 200
    call_id = queued.json()["id"]
    execute_outbound_call_task(call_id)

    session = db_session.get(CallSession, uuid.UUID(call_id))
    assert session.status in {CallSessionStatus.completed, CallSessionStatus.dialing}
    assert session.transcript is None

    # Enable transcription and verify storage on webhook.
    _grant_phone_consent(client, client_id, transcription_ok=True)
    session.provider_call_id = f"mock-call-{call_id}"
    session.status = CallSessionStatus.dialing
    db_session.commit()

    webhook = client.post(
        "/v1/webhooks/telephony",
        json={
            "provider_call_id": session.provider_call_id,
            "status": "completed",
            "outcome": "connected",
            "transcript": "User confirmed date and location",
            "payload": {},
        },
    )
    assert webhook.status_code == 200
    db_session.refresh(session)
    assert session.transcript == "User confirmed date and location"


def test_followup_processing_creates_notifications(db_session):
    user_id = str(uuid.uuid4())
    _ensure_role(db_session, user_id, UserRoleType.client)
    seed_followup_rules(db_session)
    db_session.commit()

    schedule_followups(
        db_session,
        trigger="booking_request.pending.client",
        user_id=uuid.UUID(user_id),
        target_type="booking_request",
        target_id=uuid.uuid4(),
        now=datetime.now(timezone.utc) - timedelta(hours=3),
    )
    db_session.commit()
    result = process_due_followup_jobs(db_session, now=datetime.now(timezone.utc))
    db_session.commit()

    assert result["sent"] >= 1
    notifications = db_session.query(Notification).filter_by(user_id=uuid.UUID(user_id)).all()
    assert len(notifications) >= 1
    assert all(n.status.value == "unread" for n in notifications)
