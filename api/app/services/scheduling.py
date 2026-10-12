from __future__ import annotations

import logging
import uuid
from datetime import date, datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    BookingRequestTransition,
    BookingTimeRequest,
    ConfirmedSlot,
    ProSchedulingPolicy,
)
from app.models.communication import FollowupChannel, FollowupJob, FollowupJobStatus, FollowupRule

logger = logging.getLogger(__name__)


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
    """The pro's open slots between two local dates, one slot length each.

    The same rule every booking path checks - see bookable_time. This used to
    keep its own copy, which read one of the two blocked-time tables, skipped
    the per-day cap, missed a night shift that began the day before, and did
    not count a paid gig as taking its time.
    """
    from app.services.bookable_time import bookable_starts

    if to_date < from_date:
        raise APIError(code="validation_error", message="to must be >= from", status_code=422)
    policy = get_or_create_scheduling_policy(db, pro_user_id=pro_user_id)
    cal, starts = bookable_starts(
        db,
        pro_user_id=pro_user_id,
        duration=timedelta(minutes=policy.slot_length_minutes),
        from_date=from_date,
        to_date=to_date,
    )
    return [(start, end, cal.tz.key) for start, end in starts]


def validate_slot_available(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    start_at_utc: datetime,
    end_at_utc: datetime,
    ignore_gig_id: uuid.UUID | None = None,
    ignore_booking_request_id: uuid.UUID | None = None,
    requests_made_before: datetime | None = None,
    preset=None,
) -> None:
    """Raise when [start, end) cannot be booked. See bookable_time."""
    from app.models.booking import SchedulingPreset
    from app.services.bookable_time import check_bookable

    check_bookable(
        db,
        pro_user_id=pro_user_id,
        start_at_utc=start_at_utc,
        end_at_utc=end_at_utc,
        ignore_gig_id=ignore_gig_id,
        ignore_booking_request_id=ignore_booking_request_id,
        requests_made_before=requests_made_before,
        preset=preset or SchedulingPreset.interval,
    )


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


def expire_pending_booking_requests(db: Session, *, now: datetime | None = None, limit: int | None = 100) -> int:
    """Auto-decline booking requests past their pro-response deadline.

    Same transition the manual admin job has always performed
    (BookingRequest.pending -> expired); this just makes it schedulable
    and resilient to a single bad row. The WHERE clause already makes
    re-running safe: an already-expired row won't match again.

    limit=None preserves the admin endpoint's original unbounded
    behaviour; the scheduled sweep passes an explicit batch size.
    """
    current = now or datetime.now(timezone.utc)
    query = (
        select(BookingRequest)
        .where(BookingRequest.status == BookingRequestStatus.pending, BookingRequest.expires_at < current)
        .order_by(BookingRequest.expires_at.asc())
    )
    if limit is not None:
        query = query.limit(limit)
    rows = db.execute(query).scalars().all()

    expired_count = 0
    failed_count = 0
    expired_for: set = set()
    for request in rows:
        try:
            with db.begin_nested():
                request.status = BookingRequestStatus.expired
                db.add(
                    BookingRequestTransition(
                        booking_request_id=request.id,
                        from_status=BookingRequestStatus.pending,
                        to_status=BookingRequestStatus.expired,
                        actor_user_id=request.pro_user_id,
                        reason="Expired by scheduled sweep",
                    )
                )
            expired_count += 1
            expired_for.add(request.pro_user_id)
        except Exception:
            failed_count += 1
            logger.exception("expire_booking_request_failed", extra={"booking_request_id": str(request.id)})

    # An expired request is a slow response: each photographer's label is
    # recomputed (once, however many of theirs expired), which also bumps the
    # public index version so cached cards stop showing the old one.
    from app.services.discovery_index import recompute_pro_public_index

    for pro_user_id in expired_for:
        try:
            with db.begin_nested():
                recompute_pro_public_index(db, pro_user_id)
        except Exception:
            logger.exception("expire_booking_request_reindex_failed", extra={"pro_user_id": str(pro_user_id)})

    logger.info(
        "expire_booking_requests_sweep",
        extra={"scanned": len(rows), "expired": expired_count, "failed": failed_count},
    )
    return expired_count


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
