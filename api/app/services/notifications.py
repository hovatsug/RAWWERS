from __future__ import annotations

import hashlib
import logging
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserAccount
from app.models.communication import (
    EmailMessage,
    EmailMessageStatus,
    Notification,
    NotificationDigestMode,
    NotificationEvent,
    NotificationEventChannel,
    NotificationPreference,
    NotificationSeverity,
    NotificationStatus,
    NotificationTopicPreference,
    ScheduledNotification,
)
from app.services.metrics import increment_notification_event
from app.services.outbox import enqueue_outbox_event
from app.services.rate_limit import enforce_named_rate_limit

logger = logging.getLogger(__name__)
settings = get_settings()

TOPICS = {
    "booking": "booking",
    "payments": "payments",
    "proofs": "proofs",
    "review": "reviews",
    "reviews": "reviews",
    "course": "courses",
    "certificate": "courses",
    "store": "store",
    "repair": "repairs",
    "loaner": "repairs",
    "title": "gamification",
    "quest": "gamification",
    "auth": "security",
    "password": "security",
}


@dataclass(frozen=True)
class RenderedTemplate:
    template_key: str
    subject: str
    title: str
    body: str
    action: dict


_TEMPLATE_REGISTRY: dict[str, dict[str, str]] = {
    "booking.request_received": {
        "subject": "New booking request",
        "title": "New booking request",
        "body": "You received a booking request.",
    },
    "booking.request_accepted": {
        "subject": "Booking request accepted",
        "title": "Booking accepted",
        "body": "Your booking request was accepted.",
    },
    "booking.request_declined": {
        "subject": "Booking request declined",
        "title": "Booking declined",
        "body": "Your booking request was declined.",
    },
    "payment.succeeded": {
        "subject": "Payment succeeded",
        "title": "Payment confirmed",
        "body": "Your payment was successful.",
    },
    "payment.failed": {
        "subject": "Payment failed",
        "title": "Payment failed",
        "body": "Your payment could not be processed.",
    },
    "proofs.gallery_published": {
        "subject": "Proof gallery ready",
        "title": "Your gallery is ready",
        "body": "Your proof gallery has been published.",
    },
    "proofs.selection_due_reminder": {
        "subject": "Photo selection reminder",
        "title": "Selection reminder",
        "body": "Please complete your photo selection.",
    },
    "proofs.delivery_completed": {
        "subject": "Delivery completed",
        "title": "Delivery complete",
        "body": "Your final delivery is complete.",
    },
    "review.request": {
        "subject": "Review request",
        "title": "Leave a review",
        "body": "Please review your recent experience.",
    },
    "course.completed": {
        "subject": "Course completed",
        "title": "Course complete",
        "body": "You completed your course.",
    },
    "certificate.issued": {
        "subject": "Certificate issued",
        "title": "Certificate available",
        "body": "Your certificate has been issued.",
    },
    "store.order_paid": {
        "subject": "Store order paid",
        "title": "Order confirmed",
        "body": "Your store order was paid.",
    },
    "store.order_shipped": {
        "subject": "Order shipped",
        "title": "Order shipped",
        "body": "Your order is on the way.",
    },
    "repair.quote_sent": {
        "subject": "Repair quote sent",
        "title": "Repair quote available",
        "body": "Your repair quote is ready.",
    },
    "repair.return_shipped": {
        "subject": "Repair return shipped",
        "title": "Return shipped",
        "body": "Your repaired item is on its way back.",
    },
    "loaner.approved": {
        "subject": "Loaner approved",
        "title": "Loaner approved",
        "body": "Your loaner request was approved.",
    },
    "title.awarded": {
        "subject": "New title awarded",
        "title": "Title awarded",
        "body": "You earned a new title.",
    },
    "quest.completed": {
        "subject": "Quest completed",
        "title": "Quest completed",
        "body": "You completed a quest.",
    },
    "auth.new_login": {
        "subject": "New login detected",
        "title": "New login",
        "body": "A new login was detected on your account.",
    },
    "password.reset": {
        "subject": "Password changed",
        "title": "Password updated",
        "body": "Your password was changed successfully.",
    },
    "consent.updated": {
        "subject": "Usage consent updated",
        "title": "Media usage consent updated",
        "body": "A client updated media usage consent for a gig.",
    },
    "consent.reminder": {
        "subject": "Set media consent",
        "title": "Media consent reminder",
        "body": "Please review your media usage consent preferences.",
    },
}


def topic_for_type(notification_type: str) -> str:
    prefix = (notification_type or "").split(".", 1)[0]
    return TOPICS.get(prefix, "general")


def render_template(notification_type: str, payload: dict | None = None) -> RenderedTemplate:
    payload = payload or {}
    raw = _TEMPLATE_REGISTRY.get(notification_type, {
        "subject": "Update from RAWWERS",
        "title": "New update",
        "body": "You have a new notification.",
    })
    action = _sanitize_action(payload.get("action") or {})
    return RenderedTemplate(
        template_key=notification_type,
        subject=str(raw.get("subject", "Update from RAWWERS"))[:255],
        title=str(payload.get("title") or raw.get("title") or "Update")[:255],
        body=str(payload.get("body") or raw.get("body") or "")[:5000],
        action=action,
    )


def compute_dedupe_key(*, notification_type: str, user_id: uuid.UUID, reference_id: str | None) -> str:
    raw = f"{notification_type}:{user_id}:{reference_id or ''}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def enqueue_notification(
    db: Session,
    *,
    user_id: uuid.UUID,
    notification_type: str,
    payload: dict | None = None,
    reference_type: str | None = None,
    reference_id: str | None = None,
    severity: NotificationSeverity = NotificationSeverity.info,
    dedupe_key: str | None = None,
) -> None:
    dedupe = dedupe_key or compute_dedupe_key(notification_type=notification_type, user_id=user_id, reference_id=reference_id)
    topic = topic_for_type(notification_type)
    shared_payload = {
        "user_id": str(user_id),
        "type": notification_type,
        "topic": topic,
        "payload": payload or {},
        "reference_type": reference_type,
        "reference_id": reference_id,
        "severity": severity.value,
        "dedupe_key": dedupe,
    }
    enqueue_outbox_event(
        db,
        topic="notify.create_inapp",
        payload=shared_payload,
        idempotency_key=f"notify-inapp:{dedupe}",
        idempotency_scope="notifications",
    )
    enqueue_outbox_event(
        db,
        topic="notify.send_email",
        payload=shared_payload,
        idempotency_key=f"notify-email:{dedupe}",
        idempotency_scope="notifications",
    )


def process_outbox_notification(topic: str, payload: dict, db: Session) -> None:
    if topic == "notify.create_inapp":
        _create_inapp_from_payload(db, payload)
        return
    if topic == "notify.send_email":
        _send_email_from_payload(db, payload)
        return


def process_due_scheduled_notifications(db: Session, *, limit: int = 100) -> int:
    now = datetime.now(timezone.utc)
    rows = db.execute(
        select(ScheduledNotification)
        .where(ScheduledNotification.send_at <= now)
        .order_by(ScheduledNotification.send_at.asc())
        .limit(limit)
    ).scalars().all()
    sent = 0
    for row in rows:
        if row.channel != NotificationEventChannel.email:
            db.delete(row)
            continue
        outcome = _send_email_from_payload(db, row.payload, allow_schedule=False)
        if outcome == "sent":
            db.delete(row)
            sent += 1
        elif outcome == "duplicate":
            db.delete(row)
    return sent


def get_or_create_preferences(db: Session, user_id: uuid.UUID) -> NotificationPreference:
    row = db.get(NotificationPreference, user_id)
    if row:
        return row
    row = NotificationPreference(user_id=user_id, timezone_name=settings.notification_default_timezone)
    db.add(row)
    db.flush()
    return row


def list_topic_preferences(db: Session, user_id: uuid.UUID) -> list[NotificationTopicPreference]:
    return db.execute(
        select(NotificationTopicPreference)
        .where(NotificationTopicPreference.user_id == user_id)
        .order_by(NotificationTopicPreference.topic.asc())
    ).scalars().all()


def upsert_topic_preference(
    db: Session,
    *,
    user_id: uuid.UUID,
    topic: str,
    email_enabled: bool,
    inapp_enabled: bool,
) -> NotificationTopicPreference:
    row = db.execute(
        select(NotificationTopicPreference).where(
            NotificationTopicPreference.user_id == user_id,
            NotificationTopicPreference.topic == topic,
        )
    ).scalar_one_or_none()
    if row is None:
        row = NotificationTopicPreference(
            user_id=user_id,
            topic=topic,
            email_enabled=email_enabled,
            inapp_enabled=inapp_enabled,
        )
        db.add(row)
    else:
        row.email_enabled = email_enabled
        row.inapp_enabled = inapp_enabled
    db.flush()
    return row


def mark_notification_read(db: Session, *, user_id: uuid.UUID, notification_id: uuid.UUID) -> bool:
    note = db.execute(
        select(Notification).where(Notification.id == notification_id, Notification.user_id == user_id)
    ).scalar_one_or_none()
    if note is None:
        return False
    now = datetime.now(timezone.utc)
    note.read_at = now
    note.status = NotificationStatus.read
    db.flush()
    return True


def mark_all_notifications_read(db: Session, *, user_id: uuid.UUID) -> int:
    now = datetime.now(timezone.utc)
    rows = db.execute(
        select(Notification).where(Notification.user_id == user_id, Notification.read_at.is_(None))
    ).scalars().all()
    for row in rows:
        row.read_at = now
        row.status = NotificationStatus.read
    db.flush()
    return len(rows)


def list_notifications(
    db: Session,
    *,
    user_id: uuid.UUID,
    unread_only: bool,
    limit: int,
    cursor: str | None,
) -> tuple[list[Notification], str | None]:
    query = select(Notification).where(Notification.user_id == user_id)
    if unread_only:
        query = query.where(Notification.read_at.is_(None))
    if cursor:
        try:
            cursor_dt = datetime.fromisoformat(cursor)
            if cursor_dt.tzinfo is None:
                cursor_dt = cursor_dt.replace(tzinfo=timezone.utc)
            query = query.where(Notification.created_at < cursor_dt)
        except ValueError:
            pass
    rows = db.execute(query.order_by(Notification.created_at.desc()).limit(max(1, min(100, limit)))).scalars().all()
    next_cursor = rows[-1].created_at.isoformat() if rows else None
    return rows, next_cursor


def resend_email_message(db: Session, message: EmailMessage) -> None:
    if message.status != EmailMessageStatus.failed:
        raise APIError(code="validation_error", message="Only failed emails can be resent", status_code=400)
    user_id = message.user_id
    dedupe = f"{message.dedupe_key}:resend:{uuid.uuid4()}"
    payload = {
        "user_id": str(user_id) if user_id else None,
        "type": message.template_key,
        "topic": topic_for_type(message.template_key),
        "payload": (message.meta or {}).get("payload") or {},
        "reference_type": (message.meta or {}).get("reference_type"),
        "reference_id": (message.meta or {}).get("reference_id"),
        "severity": (message.meta or {}).get("severity") or NotificationSeverity.info.value,
        "dedupe_key": dedupe,
        "to_email": message.to_email,
    }
    enqueue_outbox_event(
        db,
        topic="notify.send_email",
        payload=payload,
        idempotency_key=f"notify-email:{dedupe}",
        idempotency_scope="notifications",
    )


def _create_inapp_from_payload(db: Session, payload: dict) -> str:
    user_id = _parse_user_id(payload.get("user_id"))
    notification_type = str(payload.get("type") or "")
    if not notification_type:
        return "skipped"
    topic = str(payload.get("topic") or topic_for_type(notification_type))
    dedupe_key = str(payload.get("dedupe_key") or "")
    prefs = get_or_create_preferences(db, user_id)
    topic_pref = _get_topic_pref(db, user_id, topic)
    if not prefs.channel_inapp_enabled or (topic_pref and not topic_pref.inapp_enabled):
        increment_notification_event("inapp", "suppressed")
        return "suppressed"

    if dedupe_key and _notification_event_exists(db, channel=NotificationEventChannel.inapp, dedupe_key=dedupe_key):
        increment_notification_event("inapp", "duplicate")
        return "duplicate"

    try:
        enforce_named_rate_limit("notifications_inapp", principal=str(user_id))
        enforce_named_rate_limit("notifications_burst", principal=f"inapp:{user_id}:{notification_type}")
    except APIError:
        increment_notification_event("inapp", "rate_limited")
        return "rate_limited"

    rendered = render_template(notification_type, payload.get("payload") or {})
    severity = _parse_severity(payload.get("severity"))
    row = Notification(
        user_id=user_id,
        topic=topic,
        type=notification_type,
        title=rendered.title,
        body=rendered.body,
        action=rendered.action,
        deep_link=rendered.action.get("url") if rendered.action else None,
        severity=severity,
        status=NotificationStatus.unread,
        read_at=None,
        meta={
            "reference_type": payload.get("reference_type"),
            "reference_id": payload.get("reference_id"),
        },
    )
    db.add(row)
    if dedupe_key:
        db.add(
            NotificationEvent(
                user_id=user_id,
                topic=topic,
                type=notification_type,
                channel=NotificationEventChannel.inapp,
                reference_type=payload.get("reference_type"),
                reference_id=str(payload.get("reference_id")) if payload.get("reference_id") is not None else None,
                dedupe_key=dedupe_key,
            )
        )
    db.flush()
    increment_notification_event("inapp", "sent")
    return "sent"


def _send_email_from_payload(db: Session, payload: dict, *, allow_schedule: bool = True) -> str:
    from app.services.mail import get_mail_provider

    user_id = _parse_optional_user_id(payload.get("user_id"))
    notification_type = str(payload.get("type") or "")
    if not notification_type:
        return "skipped"
    topic = str(payload.get("topic") or topic_for_type(notification_type))
    dedupe_key = str(payload.get("dedupe_key") or "")

    to_email = payload.get("to_email")
    if not to_email and user_id:
        account = db.get(UserAccount, user_id)
        to_email = account.email if account else None
    if not to_email:
        increment_notification_event("email", "suppressed")
        return "suppressed"

    existing_email = None
    if dedupe_key:
        existing_email = db.execute(select(EmailMessage).where(EmailMessage.dedupe_key == dedupe_key)).scalar_one_or_none()
        if existing_email and existing_email.status in {EmailMessageStatus.sent, EmailMessageStatus.queued}:
            increment_notification_event("email", "duplicate")
            return "duplicate"

    prefs = get_or_create_preferences(db, user_id) if user_id else None
    topic_pref = _get_topic_pref(db, user_id, topic) if user_id else None
    if prefs and (not prefs.channel_email_enabled or (topic_pref and not topic_pref.email_enabled)):
        increment_notification_event("email", "suppressed")
        return "suppressed"

    severity = _parse_severity(payload.get("severity"))
    if prefs and allow_schedule and _should_defer_email(prefs, severity):
        send_at = _next_allowed_send_at(prefs)
        schedule_key = f"sched:{dedupe_key}" if dedupe_key else f"sched:{uuid.uuid4()}"
        if not db.execute(select(ScheduledNotification).where(ScheduledNotification.dedupe_key == schedule_key)).scalar_one_or_none():
            db.add(
                ScheduledNotification(
                    channel=NotificationEventChannel.email,
                    send_at=send_at,
                    payload=payload,
                    dedupe_key=schedule_key,
                )
            )
            db.flush()
        increment_notification_event("email", "deferred")
        return "deferred"

    try:
        principal = str(user_id) if user_id else hashlib.sha256(str(to_email).encode("utf-8")).hexdigest()
        enforce_named_rate_limit("notifications_email", principal=principal)
        enforce_named_rate_limit("notifications_burst", principal=f"email:{principal}:{notification_type}")
    except APIError:
        increment_notification_event("email", "rate_limited")
        return "rate_limited"

    rendered = render_template(notification_type, payload.get("payload") or {})
    provider = get_mail_provider()
    if existing_email is None:
        row = EmailMessage(
            user_id=user_id,
            to_email=str(to_email),
            template_key=rendered.template_key,
            subject=rendered.subject,
            provider=getattr(provider, "provider_name", None),
            status=EmailMessageStatus.queued,
            dedupe_key=dedupe_key or f"email:{uuid.uuid4()}",
            meta={
                "payload": payload.get("payload") or {},
                "reference_type": payload.get("reference_type"),
                "reference_id": payload.get("reference_id"),
                "severity": severity.value,
            },
        )
        db.add(row)
        db.flush()
    else:
        row = existing_email
        row.to_email = str(to_email)
        row.template_key = rendered.template_key
        row.subject = rendered.subject
        row.provider = getattr(provider, "provider_name", None)
        row.status = EmailMessageStatus.queued
        row.error = None

    try:
        provider_message_id = provider.send_template_email(
            email=str(to_email),
            template_key=rendered.template_key,
            subject=rendered.subject,
            text_body=rendered.body,
            unsubscribe_url=_unsubscribe_url(user_id, topic) if user_id else None,
        )
        row.provider_message_id = provider_message_id
        row.status = EmailMessageStatus.sent
        row.error = None
        if dedupe_key and user_id is not None:
            db.add(
                NotificationEvent(
                    user_id=user_id,
                    topic=topic,
                    type=notification_type,
                    channel=NotificationEventChannel.email,
                    reference_type=payload.get("reference_type"),
                    reference_id=str(payload.get("reference_id")) if payload.get("reference_id") is not None else None,
                    dedupe_key=dedupe_key,
                )
            )
        increment_notification_event("email", "sent")
    except Exception as exc:
        row.status = EmailMessageStatus.failed
        row.error = str(exc)[:1000]
        increment_notification_event("email", "failed")
        logger.exception(
            "notification_email_failed",
            extra={"template_key": rendered.template_key, "user_id": str(user_id) if user_id else None},
        )
    db.flush()
    return row.status.value


def _unsubscribe_url(user_id: uuid.UUID, topic: str) -> str:
    digest = hashlib.sha256(f"{user_id}:{topic}".encode("utf-8")).hexdigest()[:24]
    return f"{settings.app_public_url.rstrip('/')}/unsubscribe?u={user_id}&t={topic}&s={digest}"


def _sanitize_action(action: dict) -> dict:
    if not isinstance(action, dict):
        return {}
    label = action.get("label")
    url = action.get("url")
    safe: dict = {}
    if isinstance(label, str) and label.strip():
        safe["label"] = label.strip()[:80]
    if isinstance(url, str) and url.startswith("/"):
        safe["url"] = url[:512]
    return safe


def _parse_user_id(value: str | None) -> uuid.UUID:
    if not value:
        raise APIError(code="validation_error", message="Missing user_id", status_code=422)
    return uuid.UUID(value)


def _parse_optional_user_id(value: str | None) -> uuid.UUID | None:
    if not value:
        return None
    return uuid.UUID(value)


def _parse_severity(value: str | None) -> NotificationSeverity:
    try:
        return NotificationSeverity(value or NotificationSeverity.info.value)
    except Exception:
        return NotificationSeverity.info


def _get_topic_pref(db: Session, user_id: uuid.UUID | None, topic: str) -> NotificationTopicPreference | None:
    if user_id is None:
        return None
    return db.execute(
        select(NotificationTopicPreference).where(
            NotificationTopicPreference.user_id == user_id,
            NotificationTopicPreference.topic == topic,
        )
    ).scalar_one_or_none()


def _notification_event_exists(db: Session, *, channel: NotificationEventChannel, dedupe_key: str) -> bool:
    if not dedupe_key:
        return False
    row = db.execute(
        select(NotificationEvent.id).where(
            NotificationEvent.channel == channel,
            NotificationEvent.dedupe_key == dedupe_key,
        )
    ).first()
    return row is not None


def _should_defer_email(pref: NotificationPreference, severity: NotificationSeverity) -> bool:
    if not pref.quiet_hours_enabled:
        return False
    if severity == NotificationSeverity.critical and settings.notification_critical_bypass_quiet_hours:
        return False
    if pref.digest_mode != NotificationDigestMode.instant:
        return True
    return _is_in_quiet_hours(pref)


def _is_in_quiet_hours(pref: NotificationPreference, now_utc: datetime | None = None) -> bool:
    if not pref.quiet_hours_enabled or pref.quiet_start_local is None or pref.quiet_end_local is None:
        return False
    now_utc = now_utc or datetime.now(timezone.utc)
    local_now = now_utc.astimezone(_safe_zone(pref.timezone_name)).timetz().replace(tzinfo=None)
    start = pref.quiet_start_local
    end = pref.quiet_end_local
    if start < end:
        return start <= local_now < end
    return local_now >= start or local_now < end


def _next_allowed_send_at(pref: NotificationPreference, now_utc: datetime | None = None) -> datetime:
    now_utc = now_utc or datetime.now(timezone.utc)
    tz = _safe_zone(pref.timezone_name)
    local_now = now_utc.astimezone(tz)

    if pref.quiet_start_local is None or pref.quiet_end_local is None:
        return now_utc + timedelta(minutes=5)

    if pref.digest_mode == NotificationDigestMode.daily:
        send_local = local_now.replace(hour=9, minute=0, second=0, microsecond=0)
        if send_local <= local_now:
            send_local = send_local + timedelta(days=1)
        return send_local.astimezone(timezone.utc)
    if pref.digest_mode == NotificationDigestMode.weekly:
        send_local = local_now.replace(hour=9, minute=0, second=0, microsecond=0)
        days_until_monday = (7 - send_local.weekday()) % 7
        if days_until_monday == 0 and send_local <= local_now:
            days_until_monday = 7
        send_local = send_local + timedelta(days=days_until_monday)
        return send_local.astimezone(timezone.utc)

    end = pref.quiet_end_local
    send_local = local_now.replace(hour=end.hour, minute=end.minute, second=0, microsecond=0)
    if send_local <= local_now:
        send_local = send_local + timedelta(days=1)
    return send_local.astimezone(timezone.utc)


def _safe_zone(name: str | None) -> ZoneInfo:
    try:
        return ZoneInfo(name or settings.notification_default_timezone)
    except Exception:
        return ZoneInfo(settings.notification_default_timezone)
