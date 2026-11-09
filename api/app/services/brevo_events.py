"""Brevo's delivery events (POST /v1/webhooks/brevo).

Each event is written on its email_message (meta["delivery"], the latest,
and meta["delivery_events"], each once) and applied to the address through
services/email_suppression: a hard bounce, an invalid address or a block
stops all mail to it; a complaint or Brevo's own unsubscribe stops all but
security mail and switches the account's email off; soft bounces are
counted. The message's status stays what sending set (sent): the delivery
outcome is beside it. Replaying an event changes nothing.
"""
from __future__ import annotations

import re
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.communication import EmailMessage
from app.services.email_suppression import record_event

#: Brevo names some events in camelCase in some payloads, and calls a
#: complaint "spam"; one spelling here.
_ALIASES = {"complaint": "spam", "hardbounce": "hard_bounce", "softbounce": "soft_bounce", "invalid": "invalid_email"}


def event_name(raw: str | None) -> str:
    name = re.sub(r"(?<!^)(?=[A-Z])", "_", str(raw or "")).lower().replace("-", "_")
    return _ALIASES.get(name.replace("_", ""), name)


def _at(event: dict) -> datetime:
    ts = event.get("ts_event") or event.get("ts")
    if isinstance(ts, (int, float)):
        return datetime.fromtimestamp(ts, tz=timezone.utc)
    try:
        at = datetime.fromisoformat(str(event.get("date")))
        return at if at.tzinfo else at.replace(tzinfo=timezone.utc)
    except ValueError:
        return datetime.now(timezone.utc)


def apply_event(db: Session, event: dict) -> str:
    """One Brevo event. Returns its normalised name."""
    name = event_name(event.get("event"))
    email = str(event.get("email") or "")
    message_id = event.get("message-id") or event.get("messageId") or event.get("message_id")
    at = _at(event)
    if message_id:
        row = db.execute(select(EmailMessage).where(EmailMessage.provider_message_id == message_id)).scalar_one_or_none()
        if row is not None:
            seen = list((row.meta or {}).get("delivery_events", []))
            entry = {"event": name, "at": at.isoformat(), "reason": event.get("reason")}
            if all((e.get("event"), e.get("at")) != (name, entry["at"]) for e in seen):
                seen.append(entry)
            row.meta = {**(row.meta or {}), "delivery": entry, "delivery_events": seen}
            email = email or row.to_email
    if email:
        record_event(db, event=name, email=email, message_id=message_id, at=at)
    db.flush()
    return name
