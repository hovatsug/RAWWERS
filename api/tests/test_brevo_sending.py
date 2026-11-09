"""Email through Brevo (services/mail.py): what is sent, and when nothing is.

Brevo's HTTP API is stubbed: no test reaches it (conftest clears the key)."""
import pathlib
import uuid

import pytest
import requests

from app.core.config import Settings, get_settings
from app.models.communication import EmailMessage, EmailMessageStatus
from app.models.outbox import OutboxEvent, OutboxEventStatus
from app.services import mail
from app.services.email_suppression import record_event
from app.services.notifications import enqueue_notification

from tests.test_email_allowlist import _deliver, _user

TESTER = "tester@example.com"


class _Resp:
    def __init__(self, status, data=None, text=""):
        self.status_code, self._data, self.text = status, data or {}, text

    def json(self):
        return self._data


class FakeBrevo:
    """Stands in for requests.post to Brevo."""

    def __init__(self, *answers):
        self.answers, self.sent = list(answers), []

    def __call__(self, url, json=None, headers=None, timeout=None):
        assert url == mail.BREVO_SEND_URL
        self.sent.append({"body": json, "headers": headers})
        answer = self.answers.pop(0) if self.answers else _Resp(201, {"messageId": f"<m{len(self.sent)}@smtp-relay.mailin.fr>"})
        if isinstance(answer, Exception):
            raise answer
        return answer


@pytest.fixture
def brevo(monkeypatch):
    """Brevo configured, in development, with one address on the allowlist."""
    conf = get_settings()
    monkeypatch.setattr(conf, "brevo_api_key", "test-brevo-key")
    monkeypatch.setattr(conf, "brevo_sender_email", "hello@mail.rawwers.com")
    monkeypatch.setattr(conf, "brevo_sender_name", "RAWWERS")
    monkeypatch.setattr(conf, "app_env", "development")
    monkeypatch.setattr(conf, "email_sending_enabled", None)
    monkeypatch.setattr(conf, "email_dev_allowlist", TESTER)
    fake = FakeBrevo()
    monkeypatch.setattr("app.services.mail.requests.post", fake)
    return fake


def _booking_request(db, to):
    user = _user(db, to)
    enqueue_notification(
        db, user_id=user, notification_type="booking.request_received", reference_id=f"b-{uuid.uuid4().hex[:6]}",
        payload={"title": "New booking request", "body": "A client requested a booking."},
    )
    _deliver(db)
    return user


# --- Which provider, and the switch ------------------------------------------

def test_sending_is_off_in_production_unless_set_and_on_elsewhere():
    base = dict(_env_file=None, MUX_TOKEN_ID="x", MUX_TOKEN_SECRET="x", CONNECT_RETURN_URL="https://a.example/r", CONNECT_REFRESH_URL="https://a.example/f")
    assert Settings(**base, APP_ENV="production", UNSUBSCRIBE_SIGNING_KEYS="k:s").email_sending_on is False
    assert Settings(**base, APP_ENV="development").email_sending_on is True
    assert Settings(**base, APP_ENV="development", EMAIL_SENDING_ENABLED="false").email_sending_on is False


def test_production_with_sending_on_must_have_brevo_and_unsubscribe_keys():
    base = dict(_env_file=None, MUX_TOKEN_ID="x", MUX_TOKEN_SECRET="x", CONNECT_RETURN_URL="https://a.example/r", CONNECT_REFRESH_URL="https://a.example/f", APP_ENV="production", EMAIL_SENDING_ENABLED="true")
    with pytest.raises(ValueError, match="BREVO_API_KEY"):
        Settings(**base, UNSUBSCRIBE_SIGNING_KEYS="k:s", BREVO_SENDER_EMAIL="a@b.c")
    with pytest.raises(ValueError, match="UNSUBSCRIBE_SIGNING_KEYS"):
        Settings(**base, BREVO_API_KEY="k", BREVO_SENDER_EMAIL="a@b.c")
    assert Settings(**base, BREVO_API_KEY="k", BREVO_SENDER_EMAIL="a@b.c", UNSUBSCRIBE_SIGNING_KEYS="k:s").email_sending_on


def test_brevo_only_when_configured_and_sending_is_on(brevo, monkeypatch):
    conf = get_settings()
    assert isinstance(mail.get_mail_provider(), mail.BrevoMailProvider)
    monkeypatch.setattr(conf, "email_sending_enabled", False)
    assert isinstance(mail.get_mail_provider(), mail.ConsoleMailProvider)
    monkeypatch.setattr(conf, "email_sending_enabled", None)
    monkeypatch.setattr(conf, "brevo_api_key", "")
    assert isinstance(mail.get_mail_provider(), mail.ConsoleMailProvider)


def test_no_code_but_mail_py_calls_a_provider_directly():
    app_dir = pathlib.Path(__file__).resolve().parents[1] / "app"
    callers = [
        str(p.relative_to(app_dir)) for p in app_dir.rglob("*.py")
        if ".send_template_email(" in p.read_text() and p.name != "mail.py"
    ]
    assert callers == []


# --- The dev allowlist and the switch, end to end ----------------------------

def test_in_dev_an_address_not_on_the_allowlist_is_never_sent_to(db_session, brevo):
    user = _booking_request(db_session, "real.person@gmail.com")
    assert brevo.sent == []
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert (row.status, row.error) == (EmailMessageStatus.blocked, "not_on_dev_allowlist")


def test_the_allowlisted_address_gets_the_email_through_brevo(db_session, brevo):
    user = _booking_request(db_session, "Tester@Example.com")
    [sent] = brevo.sent
    assert sent["headers"]["api-key"] == "test-brevo-key"
    body = sent["body"]
    assert body["to"] == [{"email": "Tester@Example.com"}]
    assert body["sender"] == {"email": "hello@mail.rawwers.com", "name": "RAWWERS"}
    assert body["subject"] == "New booking request on RAWWERS" and body["tags"] == ["booking.request_received"]
    assert body["headers"]["List-Unsubscribe-Post"] == "List-Unsubscribe=One-Click"
    assert "/v1/email/unsubscribe?" in body["headers"]["List-Unsubscribe"]
    assert "Stop these emails: http://localhost:3000/unsubscribe?" in body["textContent"]
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert (row.status, row.provider, row.provider_message_id) == (EmailMessageStatus.sent, "brevo", "<m1@smtp-relay.mailin.fr>")


def test_with_sending_off_brevo_is_never_called(db_session, brevo, monkeypatch):
    monkeypatch.setattr(get_settings(), "email_sending_enabled", False)
    _booking_request(db_session, TESTER)
    assert brevo.sent == []
    # Even a delivering provider handed in directly is held by the switch.
    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: mail.BrevoMailProvider(api_key="k", sender_email="a@b.c", sender_name="R"))
    assert mail.send_email(db_session, email=TESTER, template_key="x", subject="s", text_body="t").status == "blocked"
    assert brevo.sent == []


def test_production_sends_to_anyone_not_suppressed(db_session, brevo, monkeypatch):
    monkeypatch.setattr(get_settings(), "app_env", "production")
    monkeypatch.setattr(get_settings(), "email_sending_enabled", True)
    monkeypatch.setattr(get_settings(), "unsubscribe_signing_keys", "k1:production-secret")
    _booking_request(db_session, "anyone@example.org")
    assert [s["body"]["to"] for s in brevo.sent] == [[{"email": "anyone@example.org"}]]


def test_security_mail_has_no_unsubscribe_header_or_footer(db_session, brevo):
    from app.models.admin import UserAccount
    from app.services.auth_service import _create_email_verification

    user = _user(db_session, TESTER)
    code = _create_email_verification(db_session, db_session.get(UserAccount, user))
    _deliver(db_session)
    [sent] = brevo.sent
    assert sent["body"]["subject"] == f"Your RAWWERS code: {code}"
    assert "headers" not in sent["body"] and "Stop these emails" not in sent["body"]["textContent"]


# --- Bounced and complained addresses ----------------------------------------

def test_a_bounced_address_is_never_emailed_again(db_session, brevo):
    from app.models.admin import UserAccount
    from app.services.auth_service import _create_email_verification

    record_event(db_session, event="hard_bounce", email=TESTER, message_id="<old>")
    user = _booking_request(db_session, TESTER)
    _create_email_verification(db_session, db_session.get(UserAccount, user))
    _deliver(db_session)
    assert brevo.sent == []
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert (row.status, row.error) == (EmailMessageStatus.suppressed, "hard_bounce")


def test_after_a_complaint_only_security_mail_goes(db_session, brevo):
    from app.models.admin import UserAccount
    from app.services.auth_service import _create_email_verification

    record_event(db_session, event="spam", email=TESTER)
    user = _booking_request(db_session, TESTER)
    _create_email_verification(db_session, db_session.get(UserAccount, user))
    _deliver(db_session)
    assert [s["body"]["tags"] for s in brevo.sent] == [["email.verify"]]


# --- Brevo's answers ---------------------------------------------------------

def _provider():
    return mail.BrevoMailProvider(api_key="k", sender_email="a@b.c", sender_name="R")


@pytest.mark.parametrize("answer, error", [
    (_Resp(429), mail.MailRetryable),
    (_Resp(503), mail.MailRetryable),
    (_Resp(400, text='{"code":"invalid_parameter"}'), mail.MailRejected),
    (requests.Timeout(), mail.MailUncertain),
    (requests.ConnectionError(), mail.MailRetryable),
])
def test_brevo_errors_are_told_apart(monkeypatch, answer, error):
    monkeypatch.setattr("app.services.mail.requests.post", FakeBrevo(answer))
    with pytest.raises(error):
        _provider().send_template_email(email=TESTER, template_key="k", subject="s", text_body="t")


def test_a_busy_brevo_is_retried_by_the_outbox_and_sent_once(db_session, brevo):
    brevo.answers = [_Resp(503)]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.status == EmailMessageStatus.failed
    [event] = db_session.query(OutboxEvent).filter_by(topic="notify.send_email").all()
    assert event.status != OutboxEventStatus.delivered
    event.next_attempt_at = event.created_at  # the back-off has passed
    _deliver(db_session)
    db_session.refresh(row)
    assert row.status == EmailMessageStatus.sent
    assert len(brevo.sent) == 2
    assert db_session.query(EmailMessage).filter_by(user_id=user).count() == 1


def test_a_timeout_is_not_resent(db_session, brevo):
    brevo.answers = [requests.Timeout()]
    user = _booking_request(db_session, TESTER)
    [row] = db_session.query(EmailMessage).filter_by(user_id=user).all()
    assert row.status == EmailMessageStatus.failed and "not resent" in row.error
    [event] = db_session.query(OutboxEvent).filter_by(topic="notify.send_email").all()
    assert event.status == OutboxEventStatus.delivered
    assert len(brevo.sent) == 1
