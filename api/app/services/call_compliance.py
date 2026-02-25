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
        timezone_name="Europe/Lisbon",
        quiet_hours_start=time(hour=22, minute=0),
        quiet_hours_end=time(hour=8, minute=0),
    )
    db.add(row)
    db.flush()
    return row


def has_transactional_phone_consent(db: Session, user_id: uuid.UUID) -> bool:
    row = db.execute(
        select(ContactConsent)
        .where(
            ContactConsent.user_id == user_id,
            ContactConsent.channel == ConsentChannel.phone_call,
            ContactConsent.scope == ConsentScope.transactional,
            ContactConsent.granted.is_(True),
            ContactConsent.revoked_at.is_(None),
        )
        .order_by(ContactConsent.granted_at.desc())
    ).scalar_one_or_none()
    if not row:
        return False
    if (row.meta or {}).get("one_time") is True:
        return False
    return True


def transcription_allowed(db: Session, user_id: uuid.UUID) -> bool:
    row = db.execute(
        select(ContactConsent)
        .where(
            ContactConsent.user_id == user_id,
            ContactConsent.channel == ConsentChannel.phone_call,
            ContactConsent.scope == ConsentScope.transactional,
            ContactConsent.granted.is_(True),
            ContactConsent.revoked_at.is_(None),
        )
        .order_by(ContactConsent.granted_at.desc())
    ).scalar_one_or_none()
    if not row:
        return False
    return bool((row.meta or {}).get("transcription_ok"))


def is_quiet_hours_now(contact: UserContact, now_utc: datetime | None = None) -> bool:
    now_utc = now_utc or datetime.now(timezone.utc)
    try:
        tz = ZoneInfo(contact.timezone_name)
    except Exception:
        tz = ZoneInfo("Europe/Lisbon")
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
