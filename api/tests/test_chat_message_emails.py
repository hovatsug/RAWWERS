"""Emails about new chat messages (BETA_SCOPE #69, owner's texts of 2026-11-17).

A client's message emails the photographer, a photographer's reply emails
the client: after the hold (120 s), only if still unread, at most one per
conversation and direction in 15 minutes, never the message text or a link,
never to a suppressed address or an account that cannot be reached. No real
email leaves: the provider is a fake that records what it was handed.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy import select

from app.models.admin import ProProfile, UserAccount, UserAccountStatus, UserRoleType
from app.models.chat import ChatMessage, ChatSenderType
from app.models.communication import EmailMessage, EmailSuppression, NotificationPreference
from app.models.outbox import OutboxEvent, OutboxEventStatus
from app.services import feature_flags
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from tests.test_ai_concierge_v1 import _seed_pro, _seed_user



class _Provider:
    provider_name = "test"

    def __init__(self):
        self.sent = []

    def send_template_email(self, *, email, template_key, subject, text_body, unsubscribe_url=None):
        self.sent.append({"to": email, "key": template_key, "subject": subject, "body": text_body})
        return f"msg-{len(self.sent)}"


@pytest.fixture
def provider(monkeypatch):
    fake = _Provider()
    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: fake)
    return fake


def _people(db_session, *, names=True):
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_user(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)
    for user_id in (pro_id, client_id):
        # Quiet hours off, so the test does not depend on the time it runs.
        db_session.add(NotificationPreference(user_id=uuid.UUID(user_id), channel_email_enabled=True, channel_inapp_enabled=True,
                                              quiet_hours_enabled=False))
    db_session.get(UserAccount, uuid.UUID(client_id)).display_name = "Sam Client" if names else None
    db_session.get(UserAccount, uuid.UUID(pro_id)).display_name = None
    db_session.get(ProProfile, uuid.UUID(pro_id)).display_name = "Ana Lens" if names else ""
    db_session.commit()
    return pro_id, client_id


def _thread(client, pro_id, client_id):
    resp = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id})
    assert resp.status_code == 200, resp.text
    return resp.json()["id"]


def _from_client(client, thread_id, client_id, text="Are you free on 12 June? My number is 0700 000 000"):
    resp = client.post(f"/v1/chat/threads/{thread_id}/messages", headers={"X-User-Id": client_id}, json={"content": text})
    assert resp.status_code == 200, resp.text


def _from_pro(client, thread_id, pro_id, text="Yes, 12 June works for me"):
    resp = client.post(f"/v1/pro/chat/threads/{thread_id}/messages", headers={"X-User-Id": pro_id}, json={"content": text})
    assert resp.status_code == 200, resp.text


def _run(db_session, *, later=timedelta(0)):
    """Run the outbox as if `later` had passed: every chat-email check due
    by then becomes due now, and emails queued before count as that old."""
    db_session.expire_all()
    if later:
        for row in db_session.execute(select(OutboxEvent).where(OutboxEvent.status == OutboxEventStatus.pending)).scalars():
            row.next_attempt_at = row.next_attempt_at - later
        for row in db_session.execute(select(OutboxEvent).where(OutboxEvent.topic == "notify.send_email")).scalars():
            row.created_at = row.created_at - later
        db_session.commit()
    for _ in range(3):  # the check, then the email it queues
        dispatch_outbox_events_task(limit=200)
    db_session.expire_all()


HOLD = timedelta(seconds=121)


def test_a_first_message_emails_the_photographer_after_the_hold_without_the_text(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    _run(db_session)
    assert provider.sent == [], "sent before the hold"
    _run(db_session, later=HOLD)
    pro_email = db_session.get(UserAccount, uuid.UUID(pro_id)).email
    assert len(provider.sent) == 1
    (mail,) = provider.sent
    assert mail["to"] == pro_email and mail["key"] == "chat.message_received"
    assert mail["subject"] == "New message from Sam on RAWWERS"
    assert mail["body"].startswith(
        "Hi Ana, Sam has sent you a message on RAWWERS. Open the app to read it and reply. Quick replies help you win bookings."
    )
    assert "12 June" not in mail["subject"] + mail["body"] and "0700" not in mail["body"]
    assert "http" not in mail["body"].split("\n\n--\n")[0], "a link in the email itself"


def test_a_reply_emails_the_client_not_the_photographer(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    client.post(f"/v1/chat/threads/{thread_id}/read", headers={"X-User-Id": pro_id})
    _from_pro(client, thread_id, pro_id)
    _run(db_session, later=HOLD)
    client_email = db_session.get(UserAccount, uuid.UUID(client_id)).email
    assert [(m["to"], m["key"], m["subject"]) for m in provider.sent] == [(client_email, "chat.reply_received", "Ana replied to you on RAWWERS")]
    assert provider.sent[0]["body"].startswith(
        "Hi Sam, Ana has replied to your message on RAWWERS. Open the app to read it and answer."
    )
    assert "12 June" not in provider.sent[0]["body"]


def test_a_burst_of_messages_sends_one_email(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    for n in range(5):
        _from_client(client, thread_id, client_id, text=f"message {n}")
    _run(db_session, later=HOLD)
    assert len(provider.sent) == 1
    _run(db_session, later=timedelta(minutes=5))  # still inside the window
    assert len(provider.sent) == 1


def test_a_message_read_before_the_hold_sends_nothing(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    read = client.post(f"/v1/chat/threads/{thread_id}/read", headers={"X-User-Id": pro_id})
    assert read.status_code == 200
    _run(db_session, later=HOLD)
    assert provider.sent == []


def test_after_the_window_a_second_email_only_if_something_is_unread(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id, text="first")
    _run(db_session, later=HOLD)
    assert len(provider.sent) == 1
    _from_client(client, thread_id, client_id, text="second, inside the window")
    _run(db_session, later=HOLD)
    assert len(provider.sent) == 1, "a second email inside 15 minutes"
    _run(db_session, later=timedelta(minutes=16))  # the window ends; "second" still unread
    assert len(provider.sent) == 2

    # Read before the next window ends: nothing more.
    _from_client(client, thread_id, client_id, text="third")
    _run(db_session, later=HOLD)
    client.post(f"/v1/chat/threads/{thread_id}/read", headers={"X-User-Id": pro_id})
    _run(db_session, later=timedelta(minutes=16))
    assert len(provider.sent) == 2


def test_a_suppressed_address_gets_no_email(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    pro_email = db_session.get(UserAccount, uuid.UUID(pro_id)).email
    db_session.add(EmailSuppression(email=pro_email.lower(), scope="non_security", reason="unsubscribed"))
    db_session.commit()
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    _run(db_session, later=HOLD)
    assert provider.sent == []
    row = db_session.execute(select(EmailMessage).where(EmailMessage.to_email == pro_email)).scalar_one()
    assert row.status.value == "suppressed"


def test_an_account_that_cannot_be_reached_gets_no_email(client, db_session, provider):
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    db_session.get(UserAccount, uuid.UUID(pro_id)).status = UserAccountStatus.disabled
    db_session.commit()
    _run(db_session, later=HOLD)
    assert provider.sent == []


def test_with_the_assistant_off_the_photographer_is_still_emailed(client, db_session, provider, monkeypatch):
    monkeypatch.setattr(feature_flags, "DEVELOPMENT_ENVS", frozenset())
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    _run(db_session, later=HOLD)
    assert [m["key"] for m in provider.sent] == ["chat.message_received"]
    senders = db_session.execute(select(ChatMessage.sender_type).where(ChatMessage.thread_id == uuid.UUID(thread_id))).scalars().all()
    assert senders == [ChatSenderType.client]


def test_without_first_names_the_email_still_reads_well(client, db_session, provider):
    pro_id, client_id = _people(db_session, names=False)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    _run(db_session, later=HOLD)
    (mail,) = provider.sent
    assert mail["subject"] == "New message from a client on RAWWERS"
    assert mail["body"].startswith("Hi, a client has sent you a message on RAWWERS. Open the app to read it and reply.")
    assert "None" not in mail["subject"] + mail["body"]


def test_a_failed_send_is_in_the_failed_emails_list(client, db_session, monkeypatch):
    from app.services.mail import MailRejected

    class _Refusing(_Provider):
        def send_template_email(self, **_kwargs):
            raise MailRejected("400 invalid sender")

    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: _Refusing())
    pro_id, client_id = _people(db_session)
    thread_id = _thread(client, pro_id, client_id)
    _from_client(client, thread_id, client_id)
    _run(db_session, later=HOLD)
    row = db_session.execute(select(EmailMessage).where(EmailMessage.template_key == "chat.message_received")).scalar_one()
    assert row.status.value == "failed"
