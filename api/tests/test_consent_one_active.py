"""At most one active phone-call consent per person (2026-11-17).

Granting consent again used to add a second active row; the lookups expected
one and raised, so the call request and the telephony webhook answered 500
(tests/test_followups_calls.py::test_transcript_not_stored_without_explicit_consent).
Now a grant supersedes the active consent, a revoke revokes every active
one, the lookups take the newest of any duplicates written before, and no
transcript is stored without an active consent with transcription allowed.
"""
import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select

from app.models.admin import UserRoleType
from app.models.communication import (
    CallSession,
    CallSessionStatus,
    ConsentChannel,
    ConsentScope,
    ContactConsent,
)
from app.services.call_compliance import (
    has_transactional_phone_consent,
    transcription_allowed,
)
from tests.test_followups_calls import _ensure_role, _grant_phone_consent, _set_contact


def _consent(client, user_id, *, granted=True, transcription_ok=False):
    resp = client.post(
        "/v1/me/consent",
        headers={"X-User-Id": user_id},
        json={"channel": "phone_call", "scope": "transactional", "granted": granted, "source": "in_app_toggle",
              "metadata": {"transcription_ok": transcription_ok}},
    )
    assert resp.status_code == 200, resp.text
    return resp.json()


def _active(db_session, user_id):
    db_session.expire_all()
    return db_session.execute(
        select(ContactConsent).where(
            ContactConsent.user_id == uuid.UUID(user_id),
            ContactConsent.channel == ConsentChannel.phone_call,
            ContactConsent.scope == ConsentScope.transactional,
            ContactConsent.granted.is_(True),
            ContactConsent.revoked_at.is_(None),
        )
    ).scalars().all()


def _person(db_session):
    user_id = str(uuid.uuid4())
    _ensure_role(db_session, user_id, UserRoleType.client)
    _set_contact(db_session, user_id)
    return user_id


def _plant_duplicates(db_session, user_id, *, newest_transcription_ok):
    """Two active rows, as a double grant left them before the fix."""
    now = datetime.now(UTC)
    for age, ok in ((timedelta(minutes=5), not newest_transcription_ok), (timedelta(0), newest_transcription_ok)):
        db_session.add(ContactConsent(user_id=uuid.UUID(user_id), channel=ConsentChannel.phone_call, scope=ConsentScope.transactional,
                                      granted=True, granted_at=now - age, revoked_at=None, source="in_app_toggle",
                                      meta={"transcription_ok": ok}))
    db_session.commit()


def _a_call(client, db_session, user_id):
    queued = client.post("/v1/calls/request", headers={"X-User-Id": user_id},
                         json={"recipient_user_id": user_id, "purpose": "booking_confirmation", "source": "call_me_button"})
    assert queued.status_code == 200, queued.text
    return db_session.get(CallSession, uuid.UUID(queued.json()["id"]))


def _webhook_with_transcript(client, db_session, session, transcript):
    """The provider reports the call ended, with a transcript. One call is
    reused (there is a daily limit of calls per person)."""
    session.provider_call_id = f"mock-call-{session.id}"
    session.status = CallSessionStatus.dialing
    session.transcript = None
    db_session.commit()
    hook = client.post("/v1/webhooks/telephony", json={"provider_call_id": session.provider_call_id, "status": "completed",
                                                       "outcome": "connected", "transcript": transcript, "payload": {}})
    assert hook.status_code == 200, hook.text
    db_session.refresh(session)
    return session.transcript


def test_granting_twice_leaves_one_active_consent_the_newest(client, db_session):
    user_id = _person(db_session)
    first = _consent(client, user_id, transcription_ok=False)
    second = _consent(client, user_id, transcription_ok=True)
    active = _active(db_session, user_id)
    assert [str(row.id) for row in active] == [second["id"]]
    old = db_session.get(ContactConsent, uuid.UUID(first["id"]))
    assert old.revoked_at is not None and old.meta.get("superseded_by") == second["id"]
    assert transcription_allowed(db_session, uuid.UUID(user_id)) is True


def test_revoking_revokes_every_active_consent_including_old_duplicates(client, db_session):
    user_id = _person(db_session)
    _plant_duplicates(db_session, user_id, newest_transcription_ok=True)
    assert len(_active(db_session, user_id)) == 2
    _consent(client, user_id, granted=False)
    assert _active(db_session, user_id) == []
    assert has_transactional_phone_consent(db_session, uuid.UUID(user_id)) is False
    assert transcription_allowed(db_session, uuid.UUID(user_id)) is False


def test_the_lookups_take_the_newest_of_old_duplicates(client, db_session):
    user_id = _person(db_session)
    _plant_duplicates(db_session, user_id, newest_transcription_ok=False)
    assert has_transactional_phone_consent(db_session, uuid.UUID(user_id)) is True
    assert transcription_allowed(db_session, uuid.UUID(user_id)) is False
    # A call to this person is allowed and does not fail on the duplicates.
    queued = client.post("/v1/calls/request", headers={"X-User-Id": user_id},
                         json={"recipient_user_id": user_id, "purpose": "booking_confirmation"})
    assert queued.status_code == 200, queued.text


def test_a_grant_over_old_duplicates_leaves_one(client, db_session):
    user_id = _person(db_session)
    _plant_duplicates(db_session, user_id, newest_transcription_ok=True)
    latest = _consent(client, user_id, transcription_ok=False)
    assert [str(row.id) for row in _active(db_session, user_id)] == [latest["id"]]


def test_no_transcript_without_consent_before_a_grant_and_after_a_revoke(client, db_session):
    user_id = _person(db_session)
    session = _a_call(client, db_session, user_id)
    # Never consented: the call-me button allows the call, not a transcript.
    assert _webhook_with_transcript(client, db_session, session, "Before") is None
    # Consented with transcription: stored.
    _grant_phone_consent(client, user_id, transcription_ok=True)
    assert _webhook_with_transcript(client, db_session, session, "Stored") == "Stored"
    # Revoked: not stored again.
    _consent(client, user_id, granted=False)
    assert _webhook_with_transcript(client, db_session, session, "After") is None
