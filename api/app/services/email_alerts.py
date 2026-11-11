"""When email fails for a reason on our side, someone is told.

A transient failure (no connection, 429, 5xx) is retried by the outbox with
back-off, up to OUTBOX_MAX_ATTEMPTS. A failure that retrying cannot fix
(401/403 from Brevo: the API key, the sender, or this server's IP not on
Brevo's authorised list) is not retried. Instead, `report_email_failure`
sends a Sentry event and puts an in-app alert in front of every admin
(ADMIN_USER_IDS), at most once an hour per kind. The failed email itself is
an `email_message` row with status failed, listed on the admin's Failed
emails page with a Resend button.
"""
from __future__ import annotations

import logging
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.sentry import capture_message

logger = logging.getLogger(__name__)

#: email_message.metadata["failure"]
CONFIG = "config"
REJECTED = "rejected"
UNCERTAIN = "uncertain"
RETRIES_EXHAUSTED = "retries_exhausted"


def failure_kind(exc: BaseException) -> str:
    from app.services.mail import MailConfigError, MailRejected, MailRetryable, MailUncertain

    if isinstance(exc, MailConfigError):
        return CONFIG
    if isinstance(exc, MailUncertain):
        return UNCERTAIN
    if isinstance(exc, MailRejected):
        return REJECTED
    if isinstance(exc, MailRetryable):
        return RETRIES_EXHAUSTED
    return REJECTED


def report_email_failure(db: Session, *, kind: str, template_key: str, error: str, now: datetime | None = None) -> None:
    """Sentry for every failure that will not be retried; an admin alert too
    when it is on our side (CONFIG). The address is never included."""
    capture_message(
        f"email not sent: {kind}",
        level="error",
        tags={"email_failure": kind, "template_key": template_key},
        extra={"error": error[:300]},
    )
    logger.warning("email_failure_reported", extra={"kind": kind, "template_key": template_key})
    if kind != CONFIG:
        return
    from app.services.notifications import enqueue_notification

    hour = (now or datetime.now(timezone.utc)).strftime("%Y%m%d%H")
    for admin_id in get_settings().admin_user_id_set():
        enqueue_notification(
            db,
            user_id=admin_id,
            notification_type="admin.email_failing",
            payload={
                "title": "Emails are not being sent",
                "body": "Brevo refused our request (401/403): check BREVO_API_KEY, the sender, "
                "and that this server's IP is authorised in Brevo. Then resend from Failed emails.",
                "error": error[:300],
            },
            reference_type="email_failure",
            reference_id=f"{CONFIG}:{hour}",
            dedupe_key=f"email-failing:{CONFIG}:{hour}:{admin_id}",
        )
