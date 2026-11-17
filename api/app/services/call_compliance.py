from __future__ import annotations

import uuid
from datetime import datetime, time, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.communication import (
    CallSession,
    CallSessionStatus,
    ConsentChannel,
    ConsentScope,
    ContactConsent,
    UserContact,
)

settings = get_settings()


def get_or_create_user_contact(db: Session, user_id: uuid.UUID) -> UserContact:
    row = db.get(UserContact, user_id)
    if row:
        return row
    row = UserContact(
        user_id=user_id,
        timezone_name="Europe/London",
        quiet_hours_start=time(hour=22, minute=0),
        quiet_hours_end=time(hour=8, minute=0),
    )
    db.add(row)
    db.flush()
    return row


def active_consents(
    db: Session, user_id: uuid.UUID, channel: ConsentChannel, scope: ConsentScope
) -> list[ContactConsent]:
    """Every granted, unrevoked consent for this person, channel and scope,
    newest first. Since 2026-11-17 there is at most one (`record_consent`),
    but rows written before may hold several: callers use the newest."""
    return list(
        db.execute(
            select(ContactConsent)
            .where(
                ContactConsent.user_id == user_id,
                ContactConsent.channel == channel,
                ContactConsent.scope == scope,
                ContactConsent.granted.is_(True),
                ContactConsent.revoked_at.is_(None),
            )
            .order_by(ContactConsent.granted_at.desc(), ContactConsent.created_at.desc())
        ).scalars().all()
    )


def _newest_phone_consent(db: Session, user_id: uuid.UUID) -> ContactConsent | None:
    # Was scalar_one_or_none(): a person who had granted twice made it raise,
    # and the call request and the telephony webhook answered 500.
    rows = active_consents(db, user_id, ConsentChannel.phone_call, ConsentScope.transactional)
    return rows[0] if rows else None


def record_consent(
    db: Session,
    *,
    user_id: uuid.UUID,
    channel: ConsentChannel,
    scope: ConsentScope,
    granted: bool,
    source: str,
    meta: dict | None,
    now: datetime | None = None,
) -> ContactConsent:
    """Grant or revoke, leaving at most one active consent.

    A grant **supersedes** any active one: the earlier rows are revoked at
    this moment and the new row (with what the person agreed to now, such
    as `transcription_ok`) is the only active one. Superseding rather than
    returning the existing row keeps a record of each choice, and a changed
    choice takes effect. A revoke revokes every active row. Both hold a
    transaction lock per person, channel and scope, so two requests at once
    cannot both add an active row."""
    now = now or datetime.now(timezone.utc)
    db.execute(select(func.pg_advisory_xact_lock(func.hashtext(f"contact_consent:{user_id}:{channel.value}:{scope.value}"))))
    new_id = uuid.uuid4()
    for row in active_consents(db, user_id, channel, scope):
        row.revoked_at = now
        if granted:
            row.meta = {**(row.meta or {}), "superseded_by": str(new_id)}
    consent = ContactConsent(
        id=new_id,
        user_id=user_id,
        channel=channel,
        scope=scope,
        granted=granted,
        granted_at=now,
        revoked_at=None if granted else now,
        source=source,
        meta=meta or {},
    )
    db.add(consent)
    db.flush()
    return consent


def has_transactional_phone_consent(db: Session, user_id: uuid.UUID) -> bool:
    row = _newest_phone_consent(db, user_id)
    if not row:
        return False
    if (row.meta or {}).get("one_time") is True:
        return False
    return True


def transcription_allowed(db: Session, user_id: uuid.UUID) -> bool:
    row = _newest_phone_consent(db, user_id)
    if not row:
        return False
    return bool((row.meta or {}).get("transcription_ok"))


def is_quiet_hours_now(contact: UserContact, now_utc: datetime | None = None) -> bool:
    now_utc = now_utc or datetime.now(timezone.utc)
    try:
        tz = ZoneInfo(contact.timezone_name)
    except Exception:
        tz = ZoneInfo("Europe/London")
    local_now = now_utc.astimezone(tz).time()
    start = contact.quiet_hours_start
    end = contact.quiet_hours_end
    if start == end:
        return False
    if start < end:
        return start <= local_now < end
    return local_now >= start or local_now < end


def enforce_call_rate_limits(db: Session, recipient_user_id: uuid.UUID, pro_user_id: uuid.UUID | None, now_utc: datetime | None = None) -> None:
    now_utc = now_utc or datetime.now(timezone.utc)
    start = now_utc.replace(hour=0, minute=0, second=0, microsecond=0)
    end = start.replace(hour=23, minute=59, second=59, microsecond=999999)

    recipient_count = db.execute(
        select(func.count())
        .select_from(CallSession)
        .where(
            CallSession.recipient_user_id == recipient_user_id,
            CallSession.created_at >= start,
            CallSession.created_at <= end,
            CallSession.status.in_(
                [
                    CallSessionStatus.queued,
                    CallSessionStatus.dialing,
                    CallSessionStatus.in_progress,
                    CallSessionStatus.completed,
                ]
            ),
        )
    ).scalar_one()
    if recipient_count >= settings.call_rate_limit_per_user_per_day:
        raise APIError(code="rate_limited", message="Recipient call limit reached for today", status_code=429)

    if pro_user_id:
        pro_count = db.execute(
            select(func.count())
            .select_from(CallSession)
            .where(
                CallSession.pro_user_id == pro_user_id,
                CallSession.created_at >= start,
                CallSession.created_at <= end,
                CallSession.status.in_(
                    [
                        CallSessionStatus.queued,
                        CallSessionStatus.dialing,
                        CallSessionStatus.in_progress,
                        CallSessionStatus.completed,
                    ]
                ),
            )
        ).scalar_one()
        if pro_count >= settings.call_rate_limit_per_pro_per_day:
            raise APIError(code="rate_limited", message="Pro call limit reached for today", status_code=429)


def enforce_call_allowed(
    db: Session,
    recipient_user_id: uuid.UUID,
    pro_user_id: uuid.UUID | None,
    allow_one_time_call_me: bool = False,
) -> UserContact:
    contact = get_or_create_user_contact(db, recipient_user_id)
    if is_quiet_hours_now(contact):
        raise APIError(code="quiet_hours", message="Calls are blocked during recipient quiet hours", status_code=409)
    if not allow_one_time_call_me and not has_transactional_phone_consent(db, recipient_user_id):
        raise APIError(code="consent_required", message="Transactional phone consent required", status_code=409)
    enforce_call_rate_limits(db, recipient_user_id, pro_user_id)
    return contact
