"""Addresses not to email, from Brevo's delivery events.

| Brevo event                          | Effect on the address                               |
|--------------------------------------|-----------------------------------------------------|
| hard_bounce, invalid_email, blocked  | nothing is sent, not even security mail (it cannot  |
|                                      | arrive)                                             |
| spam (a complaint)                   | email switched off for the account; non-security    |
|                                      | mail never sent again; security mail still goes     |
| unsubscribed (Brevo's own link)      | the same as our "Stop all emails"                   |
| soft_bounce                          | counted; 3 within 7 days stop non-security mail for |
|                                      | 30 days                                             |
| anything else (delivered, opened...) | nothing                                             |

A suppression only grows: a permanent one is never shortened or narrowed
by a later event. Replaying an event changes nothing (soft bounces are
counted once per message). Keyed by address, so a new address starts clean.
"""
from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.communication import EmailSuppression

ALL = "all"
NON_SECURITY = "non_security"
UNDELIVERABLE = frozenset({"hard_bounce", "invalid_email", "blocked"})
SOFT_BOUNCE_LIMIT = 3
SOFT_BOUNCE_WINDOW = timedelta(days=7)
SOFT_BOUNCE_PAUSE = timedelta(days=30)


def _normal(email: str) -> str:
    return (email or "").strip().lower()


def _row(db: Session, email: str) -> EmailSuppression | None:
    return db.execute(select(EmailSuppression).where(EmailSuppression.email == _normal(email))).scalar_one_or_none()


def suppression_reason(db: Session, email: str, *, security: bool, now: datetime | None = None) -> str | None:
    """Why `email` may not be sent this mail, or None if it may."""
    row = _row(db, email)
    if row is None or row.scope is None:
        return None
    now = now or datetime.now(timezone.utc)
    if row.until is not None and row.until <= now:
        return None
    if row.scope == ALL or not security:
        return row.reason or "suppressed"
    return None


def _suppress(row: EmailSuppression, scope: str, reason: str, message_id: str | None, until: datetime | None) -> None:
    """Widen to `scope` until `until` (None: for good). Never narrows: "all"
    (always for good) stays; a for-good suppression is not made temporary;
    a temporary one only gets longer."""
    if row.scope == ALL:
        return
    if scope == NON_SECURITY and row.scope == NON_SECURITY:
        if row.until is None:
            return
        if until is not None and until <= row.until:
            return
    row.scope, row.reason, row.source_message_id, row.until = scope, reason, message_id, until


def record_event(
    db: Session, *, event: str, email: str, message_id: str | None = None, at: datetime | None = None
) -> str | None:
    """Apply one delivery event to its address. Returns the scope now in
    force for it, or None."""
    address = _normal(email)
    if not address or (event not in UNDELIVERABLE and event not in {"spam", "unsubscribed", "soft_bounce"}):
        return None
    at = at or datetime.now(timezone.utc)
    row = _row(db, address)
    if row is None:
        row = EmailSuppression(email=address, meta={})
        db.add(row)
    if event in UNDELIVERABLE:
        _suppress(row, ALL, event, message_id, None)
    elif event in ("spam", "unsubscribed"):
        _suppress(row, NON_SECURITY, event, message_id, None)
        _switch_email_off(db, address)
    else:
        bounces = list((row.meta or {}).get("soft_bounces", []))
        if message_id is None or all(b.get("message_id") != message_id for b in bounces):
            bounces.append({"message_id": message_id, "at": at.isoformat()})
        recent = [b for b in bounces if datetime.fromisoformat(b["at"]) > at - SOFT_BOUNCE_WINDOW]
        row.meta = {**(row.meta or {}), "soft_bounces": recent}
        if len(recent) >= SOFT_BOUNCE_LIMIT:
            _suppress(row, NON_SECURITY, "soft_bounce", message_id, at + SOFT_BOUNCE_PAUSE)
    db.flush()
    return row.scope


def _switch_email_off(db: Session, address: str) -> None:
    """A complaint or Brevo's unsubscribe: the account's "Stop all emails"."""
    from app.models.admin import UserAccount
    from app.services.notifications import get_or_create_preferences

    for user_id in db.execute(select(UserAccount.user_id).where(func.lower(UserAccount.email) == address)).scalars():
        get_or_create_preferences(db, user_id).channel_email_enabled = False
