""""Available now": whether a photographer can be booked at short notice
right now. The one place it is decided.

It counts while BOTH hold:

  - switched on: ProSchedulingPolicy.available_until is in the future. That
    column is the source of truth. It switches itself off after
    AVAILABLE_NOW_HOURS (4) so a forgotten toggle cannot stay on for days.
  - the app is open: a heartbeat within AVAILABLE_NOW_FRESH_SECONDS (120) -
    fresher than the dot's five minutes. With no push or email, a request
    reaches a photographer only through an open app, and a short-notice
    request has 30 minutes to be answered.

While it counts, a package flagged short_notice_ok may be booked within the
next 24 hours at the photographer's preparation time instead of their usual
notice. That is the only thing it changes - see bookable_time.

Redis holds a copy (`available:pro:<id>` = the until time, expiring with
it) for lookups across many photographers, such as a Discover row. Nothing
decides a booking from the copy; a missing copy is only a slower lookup.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.booking import ProPackage, ProSchedulingPolicy
from app.services import presence
from app.services.cache import get_redis_client

# The preparation time a photographer may choose. 90 minutes is the floor:
# 30 to accept, 30 to pay and the 30-minute margin before the start, so a
# request at the edge of the notice can still be accepted and paid for.
PREP_MINUTES_OPTIONS = (90, 120, 180, 240, 360)
PREP_MINUTES_DEFAULT = 120


def _key(pro_user_id) -> str:
    return f"available:pro:{pro_user_id}"


def is_switched_on(policy: ProSchedulingPolicy | None, now: datetime | None = None) -> bool:
    now = now or datetime.now(timezone.utc)
    return bool(policy is not None and policy.available_until is not None and policy.available_until > now)


def short_notice_minutes(policy: ProSchedulingPolicy | None, pro_user_id: uuid.UUID, now: datetime | None = None) -> int | None:
    """The preparation time to use as notice right now, or None when short
    notice does not apply (switched off, or the app has gone quiet)."""
    if not is_switched_on(policy, now):
        return None
    if not presence.seen_within(pro_user_id, get_settings().available_now_fresh_seconds):
        return None
    return policy.short_notice_prep_minutes


def default_short_notice_ok(preset, duration_minutes: int) -> bool:
    """What a new package starts with: an hourly-style package of up to
    three hours can usually be shot at a couple of hours' notice; a block or
    a full day is planned. Existing packages were left off."""
    from app.models.booking import SchedulingPreset

    return SchedulingPreset(preset) == SchedulingPreset.interval and duration_minutes <= 180


def eligible_package_ids(db: Session, pro_user_id: uuid.UUID) -> list[uuid.UUID]:
    return list(
        db.execute(
            select(ProPackage.id).where(
                ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True), ProPackage.short_notice_ok.is_(True)
            )
        ).scalars()
    )


def switch(db: Session, policy: ProSchedulingPolicy, *, on: bool, prep_minutes: int | None = None) -> None:
    """Switch on (until now + AVAILABLE_NOW_HOURS) or off. Refuses to switch
    on with no package that may be booked at short notice - a toggle that
    can never produce a booking would only mislead. The column is written
    and flushed; the caller commits, then calls copy_to_redis."""
    if prep_minutes is not None:
        if prep_minutes not in PREP_MINUTES_OPTIONS:
            raise APIError(
                code="validation_error",
                message="Preparation time must be 1.5, 2, 3, 4 or 6 hours.",
                status_code=422,
            )
        policy.short_notice_prep_minutes = prep_minutes
    if on:
        if not eligible_package_ids(db, policy.pro_user_id):
            raise APIError(
                code="no_short_notice_packages",
                message="Choose at least one package that can be booked at short notice first.",
                status_code=409,
            )
        policy.available_until = datetime.now(timezone.utc) + timedelta(hours=get_settings().available_now_hours)
    else:
        policy.available_until = None
    db.flush()


def copy_to_redis(policy: ProSchedulingPolicy) -> None:
    """Mirror the committed column. Best effort: the copy is never trusted
    for a booking, so failing to write it changes nothing that matters."""
    try:
        redis = get_redis_client()
        if is_switched_on(policy):
            seconds = int((policy.available_until - datetime.now(timezone.utc)).total_seconds())
            redis.set(_key(policy.pro_user_id), policy.available_until.isoformat(), ex=max(1, seconds))
        else:
            redis.delete(_key(policy.pro_user_id))
    except Exception:
        pass
