from __future__ import annotations

import uuid
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.communication import EmailMessage, Notification, NotificationPreference, ScheduledNotification
from app.models.outbox import OutboxEvent, OutboxEventStatus
from app.services.notifications import enqueue_notification
from app.tasks.outbox_tasks import dispatch_outbox_events_task


def _ensure_user(db_session, user_id: uuid.UUID, email: str = "notify@example.com") -> None:
    if not db_session.get(UserAccount, user_id):
        db_session.add(UserAccount(user_id=user_id, email=email))
        db_session.add(UserRole(user_id=user_id, role=UserRoleType.client))
        db_session.commit()


def test_preferences_suppress_notifications(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id)
    db_session.add(
        NotificationPreference(
            user_id=user_id,
            channel_email_enabled=False,
            channel_inapp_enabled=False,
        )
    )
    db_session.commit()

    enqueue_notification(
        db_session,
        user_id=user_id,
        notification_type="booking.request_received",
        payload={"action": {"label": "View", "url": "/gigs/1"}},
        reference_type="booking",
        reference_id="b1",
    )
    db_session.commit()

    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()

    assert db_session.query(Notification).filter_by(user_id=user_id).count() == 0
    assert db_session.query(EmailMessage).filter_by(user_id=user_id).count() == 0


def test_dedupe_prevents_double_send(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="dedupe@example.com")

    enqueue_notification(
        db_session,
        user_id=user_id,
        notification_type="payment.succeeded",
        payload={"action": {"label": "Open", "url": "/payments/1"}},
        reference_type="payment",
        reference_id="p-123",
    )
    enqueue_notification(
        db_session,
        user_id=user_id,
        notification_type="payment.succeeded",
        payload={"action": {"label": "Open", "url": "/payments/1"}},
        reference_type="payment",
        reference_id="p-123",
    )
    db_session.commit()

    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()

    assert db_session.query(Notification).filter_by(user_id=user_id).count() == 1
    assert db_session.query(EmailMessage).filter_by(user_id=user_id).count() == 1


def test_quiet_hours_defers_non_critical_email(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="quiet@example.com")

    tz = ZoneInfo("Europe/Lisbon")
    local_now = datetime.now(tz)
    start = (local_now - timedelta(hours=1)).time().replace(microsecond=0)
    end = (local_now + timedelta(hours=1)).time().replace(microsecond=0)

    db_session.add(
        NotificationPreference(
            user_id=user_id,
            timezone_name="Europe/Lisbon",
            quiet_hours_enabled=True,
            quiet_start_local=start,
            quiet_end_local=end,
            channel_email_enabled=True,
            channel_inapp_enabled=False,
        )
    )
    db_session.commit()

    enqueue_notification(
        db_session,
        user_id=user_id,
        notification_type="proofs.selection_due_reminder",
        payload={},
        reference_type="gallery",
        reference_id="g-1",
    )
    db_session.commit()

    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()

    assert db_session.query(EmailMessage).filter_by(user_id=user_id).count() == 0
    assert db_session.query(ScheduledNotification).count() >= 1


def test_inapp_read_unread_flow(client, db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="inapp@example.com")
    db_session.add(NotificationPreference(user_id=user_id, channel_email_enabled=False, channel_inapp_enabled=True))
    db_session.commit()

    enqueue_notification(
        db_session,
        user_id=user_id,
        notification_type="booking.request_received",
        payload={},
        reference_type="booking",
        reference_id="b-99",
    )
    db_session.commit()
    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()

    headers = {"X-User-Id": str(user_id)}
    unread = client.get("/v1/me/notifications", params={"unread_only": True}, headers=headers)
    assert unread.status_code == 200
    assert len(unread.json()["items"]) == 1
    note_id = unread.json()["items"][0]["id"]

    read_one = client.post(f"/v1/me/notifications/{note_id}/read", headers=headers)
    assert read_one.status_code == 204

    unread_after = client.get("/v1/me/notifications", params={"unread_only": True}, headers=headers)
    assert unread_after.status_code == 200
    assert unread_after.json()["items"] == []


def test_outbox_notification_retry_is_durable(db_session, monkeypatch):
    class FlakyProvider:
        provider_name = "flaky"

        def __init__(self) -> None:
            self.calls = 0

        def send_template_email(self, **_kwargs):
            self.calls += 1
            if self.calls == 1:
                raise RuntimeError("transient")
            return "msg-2"

        def send_verification_email(self, **_kwargs):
            return None

        def send_password_reset_email(self, **_kwargs):
            return None

    provider = FlakyProvider()
    monkeypatch.setattr("app.services.mail.get_mail_provider", lambda: provider)

    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="retry@example.com")
    db_session.add(NotificationPreference(user_id=user_id, channel_email_enabled=True, channel_inapp_enabled=False))
    db_session.commit()

    enqueue_notification(
        db_session,
        user_id=user_id,
        notification_type="payment.succeeded",
        payload={},
        reference_type="payment",
        reference_id="retry-1",
    )
    db_session.commit()

    dispatch_outbox_events_task(limit=50)
    db_session.expire_all()
    outbox_rows = db_session.query(OutboxEvent).filter_by(topic="notify.send_email").all()
    assert outbox_rows
    assert outbox_rows[0].status in {OutboxEventStatus.pending, OutboxEventStatus.processing}

    dispatch_outbox_events_task(limit=50)
    outbox_rows = db_session.query(OutboxEvent).filter_by(topic="notify.send_email").all()
    assert outbox_rows[0].status == OutboxEventStatus.delivered
    sent = db_session.query(EmailMessage).filter_by(user_id=user_id).all()
    assert len(sent) == 1
    assert sent[0].status.value == "sent"
