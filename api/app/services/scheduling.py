from __future__ import annotations

import uuid
from datetime import date, datetime, time, timedelta, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.booking import (
    BookingRequest,
    BookingTimeRequest,
    ConfirmedSlot,
    ProAvailabilityException,
    ProAvailabilityRule,
    ProSchedulingPolicy,
)
from app.models.communication import FollowupChannel, FollowupJob, FollowupJobStatus, FollowupRule


def get_or_create_scheduling_policy(db: Session, *, pro_user_id: uuid.UUID) -> ProSchedulingPolicy:
    row = db.get(ProSchedulingPolicy, pro_user_id)
    if row:
        return row
    row = ProSchedulingPolicy(
        pro_user_id=pro_user_id,
        slot_length_minutes=60,
        buffer_before_minutes=15,
        buffer_after_minutes=15,
        advance_notice_hours=24,
        max_bookings_per_day=None,
    )
    db.add(row)
    db.flush()
    return row


def generate_candidate_slots(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    from_date: date,
    to_date: date,
) -> list[tuple[datetime, datetime, str]]:
    if to_date < from_date:
        raise APIError(code="validation_error", message="to must be >= from", status_code=422)
    policy = get_or_create_scheduling_policy(db, pro_user_id=pro_user_id)
    rules = db.execute(
        select(ProAvailabilityRule)
        .where(ProAvailabilityRule.pro_user_id == pro_user_id)
        .order_by(ProAvailabilityRule.day_of_week.asc(), ProAvailabilityRule.start_time.asc())
    ).scalars().all()
    if not rules:
        return []
    exceptions = db.execute(
        select(ProAvailabilityException)
        .where(
            ProAvailabilityException.pro_user_id == pro_user_id,
            ProAvailabilityException.end_at_utc > datetime.combine(from_date, time(0, 0), tzinfo=timezone.utc),
            ProAvailabilityException.start_at_utc < datetime.combine(to_date + timedelta(days=1), time(0, 0), tzinfo=timezone.utc),
        )
    ).scalars().all()
    confirmed = db.execute(
        select(ConfirmedSlot).where(
            ConfirmedSlot.pro_user_id == pro_user_id,
            ConfirmedSlot.status.in_(["reserved", "confirmed"]),
            ConfirmedSlot.end_at_utc > datetime.combine(from_date, time(0, 0), tzinfo=timezone.utc),
            ConfirmedSlot.start_at_utc < datetime.combine(to_date + timedelta(days=1), time(0, 0), tzinfo=timezone.utc),
        )
    ).scalars().all()

    out: list[tuple[datetime, datetime, str]] = []
    current = from_date
    while current <= to_date:
        weekday = current.weekday()
        for rule in [r for r in rules if r.day_of_week == weekday]:
            tz = ZoneInfo(rule.timezone)
            block_start_local = datetime.combine(current, rule.start_time).replace(tzinfo=tz)
            block_end_local = datetime.combine(current, rule.end_time).replace(tzinfo=tz)
            slot_start_local = block_start_local
            while slot_start_local + timedelta(minutes=policy.slot_length_minutes) <= block_end_local:
                slot_end_local = slot_start_local + timedelta(minutes=policy.slot_length_minutes)
                slot_start_utc = slot_start_local.astimezone(timezone.utc)
                slot_end_utc = slot_end_local.astimezone(timezone.utc)

                if slot_start_utc < datetime.now(timezone.utc) + timedelta(hours=policy.advance_notice_hours):
                    slot_start_local += timedelta(minutes=policy.slot_length_minutes)
                    continue
                if _overlaps_exceptions(slot_start_utc, slot_end_utc, exceptions):
                    slot_start_local += timedelta(minutes=policy.slot_length_minutes)
                    continue
                if _overlaps_confirmed(
                    slot_start_utc - timedelta(minutes=policy.buffer_before_minutes),
                    slot_end_utc + timedelta(minutes=policy.buffer_after_minutes),
                    confirmed,
                ):
                    slot_start_local += timedelta(minutes=policy.slot_length_minutes)
                    continue
                out.append((slot_start_utc, slot_end_utc, rule.timezone))
                slot_start_local += timedelta(minutes=policy.slot_length_minutes)
        current += timedelta(days=1)
    return out


def validate_slot_available(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    start_at_utc: datetime,
    end_at_utc: datetime,
) -> None:
    if end_at_utc <= start_at_utc:
        raise APIError(code="validation_error", message="end_at_utc must be after start_at_utc", status_code=422)
    policy = get_or_create_scheduling_policy(db, pro_user_id=pro_user_id)
    if start_at_utc < datetime.now(timezone.utc) + timedelta(hours=policy.advance_notice_hours):
        raise APIError(code="validation_error", message="advance notice not satisfied", status_code=409)

    rules = db.execute(select(ProAvailabilityRule).where(ProAvailabilityRule.pro_user_id == pro_user_id)).scalars().all()
    if not rules:
        raise APIError(code="validation_error", message="Pro has no availability rules", status_code=409)
    fits_any_rule = False
    for rule in rules:
        tz = ZoneInfo(rule.timezone)
        local_start = start_at_utc.astimezone(tz)
        local_end = end_at_utc.astimezone(tz)
        if local_start.weekday() != rule.day_of_week:
            continue
        if local_start.timetz().replace(tzinfo=None) >= rule.start_time and local_end.timetz().replace(tzinfo=None) <= rule.end_time:
            fits_any_rule = True
            break
    if not fits_any_rule:
        raise APIError(code="validation_error", message="Slot is outside pro availability rules", status_code=409)

    exceptions = db.execute(
        select(ProAvailabilityException).where(
            ProAvailabilityException.pro_user_id == pro_user_id,
            ProAvailabilityException.start_at_utc < end_at_utc,
            ProAvailabilityException.end_at_utc > start_at_utc,
        )
    ).scalars().all()
    if exceptions:
        raise APIError(code="validation_error", message="Slot overlaps availability exception", status_code=409)

    if policy.max_bookings_per_day:
        day_start = datetime.combine(start_at_utc.date(), time(0, 0), tzinfo=timezone.utc)
        day_end = day_start + timedelta(days=1)
        count = db.execute(
            select(func.count())
            .select_from(ConfirmedSlot)
            .where(
                ConfirmedSlot.pro_user_id == pro_user_id,
                ConfirmedSlot.status.in_(["reserved", "confirmed", "completed"]),
                ConfirmedSlot.start_at_utc >= day_start,
                ConfirmedSlot.start_at_utc < day_end,
            )
        ).scalar_one()
        if count >= policy.max_bookings_per_day:
            raise APIError(code="validation_error", message="max bookings per day reached", status_code=409)

    buffered_start = start_at_utc - timedelta(minutes=policy.buffer_before_minutes)
    buffered_end = end_at_utc + timedelta(minutes=policy.buffer_after_minutes)
    conflict = db.execute(
        select(ConfirmedSlot).where(
            ConfirmedSlot.pro_user_id == pro_user_id,
            ConfirmedSlot.status.in_(["reserved", "confirmed"]),
            ConfirmedSlot.start_at_utc < buffered_end,
            ConfirmedSlot.end_at_utc > buffered_start,
        )
    ).scalar_one_or_none()
    if conflict:
        raise APIError(code="slot_conflict", message="Slot conflicts with existing booking", status_code=409)


def create_slot_reminders(
    db: Session,
    *,
    slot: ConfirmedSlot,
) -> None:
    _ensure_slot_followup_rule(
        db,
        code="slot_reminder_24h",
        delay_minutes=0,
        title="Upcoming shoot in 24h",
        body="Reminder: your shoot is tomorrow.",
    )
    _ensure_slot_followup_rule(
        db,
        code="slot_reminder_2h",
        delay_minutes=0,
        title="Upcoming shoot in 2h",
        body="Reminder: your shoot starts soon.",
    )
    now = datetime.now(timezone.utc)
    reminder_specs = [
        ("slot_reminder_24h", slot.start_at_utc - timedelta(hours=24)),
        ("slot_reminder_2h", slot.start_at_utc - timedelta(hours=2)),
    ]
    for rule_code, scheduled_for in reminder_specs:
        if scheduled_for <= now:
            continue
        for user_id in [slot.client_user_id, slot.pro_user_id]:
            exists = db.execute(
                select(FollowupJob).where(
                    FollowupJob.rule_code == rule_code,
                    FollowupJob.user_id == user_id,
                    FollowupJob.target_type == "confirmed_slot",
                    FollowupJob.target_id == slot.id,
                    FollowupJob.scheduled_for == scheduled_for,
                )
            ).scalar_one_or_none()
            if exists:
                continue
            db.add(
                FollowupJob(
                    rule_code=rule_code,
                    user_id=user_id,
                    target_type="confirmed_slot",
                    target_id=slot.id,
                    scheduled_for=scheduled_for,
                    status=FollowupJobStatus.scheduled,
                    attempt=0,
                )
            )
    db.flush()


def create_booking_time_request(
    db: Session,
    *,
    booking_request_id: uuid.UUID,
    client_timezone: str,
    windows: list[dict],
) -> BookingTimeRequest:
    row = BookingTimeRequest(
        booking_request_id=booking_request_id,
        client_timezone=client_timezone,
        windows=windows,
    )
    db.add(row)
    db.flush()
    return row


def latest_booking_time_request(db: Session, *, booking_request_id: uuid.UUID) -> BookingTimeRequest | None:
    return db.execute(
        select(BookingTimeRequest)
        .where(BookingTimeRequest.booking_request_id == booking_request_id)
        .order_by(BookingTimeRequest.created_at.desc())
    ).scalars().first()


def _ensure_slot_followup_rule(db: Session, *, code: str, delay_minutes: int, title: str, body: str) -> None:
    existing = db.execute(select(FollowupRule).where(FollowupRule.code == code)).scalar_one_or_none()
    if existing:
        return
    db.add(
        FollowupRule(
            code=code,
            is_enabled=True,
            trigger="scheduling.slot.confirmed",
            delay_minutes=delay_minutes,
            channel=FollowupChannel.in_app,
            max_attempts=1,
            meta={"title": title, "body": body},
        )
    )
    db.flush()


def _overlaps_exceptions(start_at_utc: datetime, end_at_utc: datetime, exceptions: list[ProAvailabilityException]) -> bool:
    return any(item.start_at_utc < end_at_utc and item.end_at_utc > start_at_utc for item in exceptions)


def _overlaps_confirmed(start_at_utc: datetime, end_at_utc: datetime, confirmed: list[ConfirmedSlot]) -> bool:
    return any(item.start_at_utc < end_at_utc and item.end_at_utc > start_at_utc for item in confirmed)
