"""Failed emails: transient ones are retried, our-side ones raise an alert,
and the admin lists and resends them (services/email_alerts.py)."""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
import requests

from app.core.config import get_settings
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.communication import EmailMessage, EmailMessageStatus
from app.models.outbox import OutboxEvent, OutboxEventStatus
from app.services import email_alerts, mail
from app.services.auth_service import register_user
from app.services.outbox import mark_outbox_failed

from tests.test_brevo_sending import TESTER, _booking_request, _Resp, brevo  # noqa: F401 - fixture
from tests.test_email_allowlist import _deliver


@pytest.fixture
def reported(monkeypatch):
    """What would have gone to Sentry."""
    sent = []
    monkeypatch.setattr(email_alerts, "capture_message", lambda message, **kw: sent.append((message, kw)))
    return sent


@pytest.fixture
def admin_id(db_session, monkeypatch):
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid))
    db_session.flush()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.admin))
    db_session.commit()
    monkeypatch.setattr(get_settings(), "admin_user_ids", str(uid))
    return uid


def _admin_alerts(db, admin):
    return [
        e for e in db.query(OutboxEvent).filter_by(topic="notify.create_inapp").all()
        if e.payload.get("user_id") == str(admin) and e.payload.get("type") == "admin.email_failing"
    ]


def test_brevo_401_and_403_are_configuration_errors():
    for status in (401, 403):
        fake = lambda url, json=None, headers=None, timeout=None, s=status: _Resp(s, text='{"message":"unrecognised IP address"}')  # noqa: E731
        provider = mail.BrevoMailProvider(api_key="k", sender_email="a@b.c", sender_name="R")
        with pytest.MonkeyPatch.context() as mp:
            mp.setattr("app.services.mail.requests.post", fake)
            with pytest.raises(mail.MailConfigError):
                provider.send_template_email(email=TESTER, template_key="k", subject="s", text_body="t")
    assert issubclass(mail.MailConfigError, mail.MailRejected)


def test_an_unauthorised_ip_is_not_retried_and_alerts_sentry_and_the_admins(db_session, brevo, reported, admin_id):
    brevo.answers = [_Resp(401, text='{"code":"unauthorized","message":"unrecognised IP address 203.0.113.9"}')]
    user = _booking_request(db_session, TESTER)

    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.status == EmailMessageStatus.failed
    assert row.meta["failure"] == "config"
    # Not retried: the outbox event is done, and Brevo was asked once.
    [event] = db_session.query(OutboxEvent).filter_by(topic="notify.send_email").filter(
        OutboxEvent.payload["user_id"].astext == str(user)
    ).all()
    assert event.status == OutboxEventStatus.delivered
    assert len(brevo.sent) == 1
    # Sentry, without the address.
    assert [m for m, _ in reported] == ["email not sent: config"]
    assert TESTER not in repr(reported)
    # One in-app alert for the admin.
    assert len(_admin_alerts(db_session, admin_id)) == 1


def test_alerts_are_at_most_one_an_hour(db_session, brevo, reported, admin_id, monkeypatch):
    other = "tester2@example.com"
    monkeypatch.setattr(get_settings(), "email_dev_allowlist", f"{TESTER},{other}")
    brevo.answers = [_Resp(401), _Resp(401)]
    _booking_request(db_session, TESTER)
    _booking_request(db_session, other)
    assert len(reported) == 2
    assert len(_admin_alerts(db_session, admin_id)) == 1


def test_a_refused_email_goes_to_sentry_but_not_to_the_admins(db_session, brevo, reported, admin_id):
    brevo.answers = [_Resp(400, text='{"code":"invalid_parameter"}')]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.meta["failure"] == "rejected"
    assert [m for m, _ in reported] == ["email not sent: rejected"]
    assert _admin_alerts(db_session, admin_id) == []


def test_a_busy_brevo_is_retried_quietly_and_giving_up_is_an_error(db_session, brevo, reported, admin_id, caplog):
    brevo.answers = [_Resp(503)]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.meta["failure"] == "transient"
    [event] = db_session.query(OutboxEvent).filter_by(topic="notify.send_email").filter(
        OutboxEvent.payload["user_id"].astext == str(user)
    ).all()
    assert event.status == OutboxEventStatus.pending and event.attempts == 1
    assert event.next_attempt_at > datetime.now(timezone.utc)  # back-off
    assert reported == [] and _admin_alerts(db_session, admin_id) == []

    # The cap: the last attempt gives up, and says so at ERROR (a Sentry event).
    event.attempts = get_settings().outbox_max_attempts - 1
    with caplog.at_level("ERROR"):
        mark_outbox_failed(db_session, event, max_attempts=get_settings().outbox_max_attempts)
    assert event.status == OutboxEventStatus.failed
    assert any(r.message == "outbox_event_gave_up" and r.levelname == "ERROR" for r in caplog.records)


def test_a_failed_code_email_is_recorded_without_its_code_and_never_resent(db_session, brevo, reported, admin_id, client):
    brevo.answers = [_Resp(401)]
    user = register_user(db_session, email=TESTER, password="Passw0rd!long", display_name="T", ip=None, user_agent=None)
    _deliver(db_session)

    [row] = db_session.query(EmailMessage).filter_by(user_id=user.user_id, template_key="email.verify").all()
    assert row.status == EmailMessageStatus.failed
    assert row.meta == {"security": True, "failure": "config"}
    sent_subject = brevo.sent[0]["body"]["subject"]
    code = sent_subject.rsplit(" ", 1)[-1]
    assert len(code) >= 6 and code not in row.subject and code not in (row.error or "") and code not in repr(row.meta)
    assert len(_admin_alerts(db_session, admin_id)) == 1

    admin = {"X-User-Id": str(admin_id)}
    logs = client.get("/v1/admin/notifications/logs", params={"status": "failed"}, headers=admin).json()["items"]
    [item] = [i for i in logs if i["id"] == str(row.id)]
    assert item["security"] is True and item["resendable"] is False
    resp = client.post("/v1/admin/notifications/resend", json={"email_message_id": str(row.id)}, headers=admin)
    assert resp.status_code == 400


def test_the_admin_lists_failed_emails_and_resends_one_once(db_session, brevo, reported, admin_id, client):
    brevo.answers = [_Resp(401)]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    admin = {"X-User-Id": str(admin_id)}

    logs = client.get("/v1/admin/notifications/logs", params={"status": "failed"}, headers=admin).json()["items"]
    [item] = [i for i in logs if i["id"] == str(row.id)]
    assert item["failure"] == "config" and item["resendable"] is True and item["resent_at"] is None

    first = client.post("/v1/admin/notifications/resend", json={"email_message_id": str(row.id)}, headers=admin)
    assert first.status_code == 202, first.text
    _deliver(db_session)  # Brevo answers 201 now
    assert db_session.query(EmailMessage).filter_by(user_id=user, status=EmailMessageStatus.sent).count() == 1

    again = client.post("/v1/admin/notifications/resend", json={"email_message_id": str(row.id)}, headers=admin)
    assert again.status_code == 409 and again.json()["error"]["code"] == "already_resent"
    logs = client.get("/v1/admin/notifications/logs", params={"status": "failed"}, headers=admin).json()["items"]
    [item] = [i for i in logs if i["id"] == str(row.id)]
    assert item["resendable"] is False and item["resent_at"]


def test_a_transient_failure_is_not_resent_while_the_outbox_still_retries(db_session, brevo, admin_id, client):
    brevo.answers = [_Resp(503)]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    admin = {"X-User-Id": str(admin_id)}
    resp = client.post("/v1/admin/notifications/resend", json={"email_message_id": str(row.id)}, headers=admin)
    assert resp.status_code == 409 and resp.json()["error"]["code"] == "still_retrying"
    # An hour on, the outbox has given up: it can be resent.
    row.updated_at = datetime.now(timezone.utc) - timedelta(hours=2)
    db_session.commit()
    resp = client.post("/v1/admin/notifications/resend", json={"email_message_id": str(row.id)}, headers=admin)
    assert resp.status_code == 202, resp.text


def test_a_timeout_is_reported_as_uncertain(db_session, brevo, reported):
    brevo.answers = [requests.Timeout()]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.meta["failure"] == "uncertain"
    assert [m for m, _ in reported] == ["email not sent: uncertain"]
