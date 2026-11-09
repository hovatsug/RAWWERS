"""Brevo's delivery events (POST /v1/webhooks/brevo), with sample payloads in
the shape Brevo's transactional webhook sends."""
import uuid

import pytest

from app.core.config import get_settings
from app.models.communication import EmailMessage, EmailMessageStatus
from app.services.brevo_events import event_name
from app.services.email_suppression import suppression_reason
from app.services.notifications import get_or_create_preferences

from tests.test_notifications_v1 import _ensure_user

TOKEN = "brevo-webhook-test-token"
URL = "/v1/webhooks/brevo"


def _sample(event, email, message_id, **extra):
    return {
        "event": event,
        "email": email,
        "id": 4567,
        "date": "2026-11-09 12:00:00",
        "ts": 1762689600,
        "message-id": message_id,
        "ts_event": 1762689605,
        "subject": "New booking request on RAWWERS",
        "tag": '["booking.request_received"]',
        "tags": ["booking.request_received"],
        "sending_ip": "185.41.28.109",
        **extra,
    }


@pytest.fixture
def on(monkeypatch):
    monkeypatch.setattr(get_settings(), "brevo_webhook_token", TOKEN)


def _sent(db, email):
    user = uuid.uuid4()
    _ensure_user(db, user, email)
    row = EmailMessage(
        user_id=user, to_email=email, template_key="booking.request_received", subject="s", provider="brevo",
        provider_message_id=f"<{uuid.uuid4().hex}@smtp-relay.mailin.fr>", status=EmailMessageStatus.sent,
        dedupe_key=f"t:{uuid.uuid4()}", meta={},
    )
    db.add(row)
    db.commit()
    return user, row


def _post(client, body, token=TOKEN, how="bearer"):
    if how == "bearer":
        return client.post(URL, json=body, headers={"Authorization": f"Bearer {token}"})
    return client.post(f"{URL}?token={token}", json=body)


def test_without_a_token_set_the_route_is_off(client):
    # Dev: Brevo cannot reach it, so it is not there.
    assert _post(client, _sample("hard_bounce", "a@example.com", "<x>")).status_code == 404


def test_a_wrong_or_missing_token_is_refused(client, db_session, on):
    a = f"{uuid.uuid4().hex[:6]}@example.com"
    assert _post(client, _sample("hard_bounce", a, "<x>"), token="wrong").status_code == 401
    assert client.post(URL, json=_sample("hard_bounce", a, "<x>")).status_code == 401
    assert suppression_reason(db_session, a, security=False) is None


def test_a_hard_bounce_marks_the_message_and_stops_the_address(client, db_session, on):
    a = f"{uuid.uuid4().hex[:6]}@example.com"
    _user, row = _sent(db_session, a)
    resp = _post(client, _sample("hard_bounce", a, row.provider_message_id, reason="550 5.1.1 user unknown"))
    assert resp.status_code == 200
    db_session.expire_all()
    db_session.refresh(row)
    assert row.status == EmailMessageStatus.sent  # sending's outcome; delivery is beside it
    assert row.meta["delivery"]["event"] == "hard_bounce" and "user unknown" in row.meta["delivery"]["reason"]
    assert suppression_reason(db_session, a, security=True) == "hard_bounce"


def test_a_complaint_by_query_token_switches_the_account_s_email_off(client, db_session, on):
    a = f"{uuid.uuid4().hex[:6]}@example.com"
    user, row = _sent(db_session, a)
    assert _post(client, _sample("spam", a, row.provider_message_id), how="query").status_code == 200
    db_session.expire_all()
    assert get_or_create_preferences(db_session, user).channel_email_enabled is False
    assert suppression_reason(db_session, a, security=False) == "spam"
    assert suppression_reason(db_session, a, security=True) is None


def test_replaying_an_event_changes_nothing(client, db_session, on):
    a = f"{uuid.uuid4().hex[:6]}@example.com"
    _user, row = _sent(db_session, a)
    for _ in range(3):
        assert _post(client, _sample("soft_bounce", a, row.provider_message_id)).status_code == 200
    db_session.expire_all()
    db_session.refresh(row)
    assert len(row.meta["delivery_events"]) == 1
    assert suppression_reason(db_session, a, security=False) is None  # one soft bounce, counted once


def test_delivered_and_opened_are_recorded_and_suppress_nothing(client, db_session, on):
    a = f"{uuid.uuid4().hex[:6]}@example.com"
    _user, row = _sent(db_session, a)
    _post(client, _sample("delivered", a, row.provider_message_id))
    _post(client, _sample("opened", a, row.provider_message_id, ts_event=1762689700))
    db_session.expire_all()
    db_session.refresh(row)
    assert [e["event"] for e in row.meta["delivery_events"]] == ["delivered", "opened"]
    assert suppression_reason(db_session, a, security=False) is None


def test_a_batch_and_an_unknown_message_are_handled(client, db_session, on):
    a, b = (f"{uuid.uuid4().hex[:6]}@example.com" for _ in range(2))
    body = [_sample("invalid_email", a, "<never-ours>"), _sample("blocked", b, "<also-not>")]
    assert _post(client, body).status_code == 200
    assert suppression_reason(db_session, a, security=True) == "invalid_email"
    assert suppression_reason(db_session, b, security=True) == "blocked"


def test_brevo_s_spellings_are_one_name():
    assert [event_name(n) for n in ("hardBounce", "hard_bounce", "softBounce", "invalid_email", "complaint", "spam", "uniqueOpened")] == [
        "hard_bounce", "hard_bounce", "soft_bounce", "invalid_email", "spam", "spam", "unique_opened",
    ]
