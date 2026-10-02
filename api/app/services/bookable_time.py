"""When a photographer can be booked. The one answer.

Six places used to decide this, and no two agreed. The client's booking
request refused only a window wholly inside blocked time, so it accepted 3am
on a Sunday from someone who does not work Sundays. The pro's slot list read
one of the two blocked-time tables and skipped the per-day cap; confirming a
slot skipped the same table; accepting a request used the lenient check; the
chat path skipped notice and existing bookings. And none of them counted a
paid gig as taking up its time, because accepting a request writes the gig's
time without a confirmed slot - so a paid shoot left its hour open.

Everything now asks this module. A time is bookable when all of these hold:

  - it is at least `advance_notice_hours` away;
  - one working-hours rule wholly contains it (a night shift owns the small
    hours of the next day - see availability_rules);
  - no blocked time touches it, from either table (availability_blocks);
  - the photographer's local day is under `max_bookings_per_day`;
  - it clears every existing booking by the policy's buffers.

What counts as a booking, i.e. what holds time:

  - a reserved or confirmed slot;
  - a paid gig's scheduled time;
  - an accepted gig awaiting payment, for PAYMENT_WINDOW after it was
    accepted - once a photographer has said yes, the hour is not theirs to
    sell again while the client pays;
  - a pending request, until it expires - first come, first served. A
    request holds against requests made after it, and not against earlier
    ones: when a photographer accepts a request, only pending requests older
    than it stand in its way. Otherwise two overlapping pending requests
    (made before holds existed) would each block the other for ever.

Holding only paid time let two clients request the same hour, the
photographer accept both, and both pay. That was reproduced before this
changed; tests/test_bookable_time.py covers it end to end.

`refusal_for` is the rule; `check_bookable` raises it for one time;
`bookable_starts` lists every start time in a date range. The last two are
the same loop over the same rule, so a start the calendar offers is one the
request accepts, and the reverse.
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
import logging

import stripe

from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    ConfirmedSlot,
    ProAvailabilityRule,
    ProSchedulingPolicy,
)
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment
from app.services.availability_blocks import blocked_intervals
from app.services.availability_rules import any_rule_covers, rule_window

logger = logging.getLogger(__name__)

# How long an accepted, unpaid booking holds its time. The same 24 hours a
# photographer has to answer a request, and what the client app tells people.
PAYMENT_WINDOW = timedelta(hours=24)

# A gig holds its time once it is paid - "the date is not held until this is
# paid", as the client app tells people. Everything after payment is here so a
# gig that has moved on (shot, delivered) still counts toward its day.
OCCUPYING_GIG_STATUSES = frozenset(
    {
        GigStatus.paid,
        GigStatus.scheduled,
        GigStatus.shoot_done,
        GigStatus.proofs_delivered,
        GigStatus.selection_pending,
        GigStatus.final_delivered,
        GigStatus.completed,
    }
)
_BUSY_SLOT_STATUSES = ("reserved", "confirmed")
_COUNTED_SLOT_STATUSES = ("reserved", "confirmed", "completed")

# Messages are shown to whoever asked - a client picking a time, or a pro
# accepting one - so they say what is wrong in their terms, never which table
# or which other client.
NO_SCHEDULE_MESSAGE = "This photographer has not set their working hours yet."


@dataclass(frozen=True)
class Refusal:
    code: str
    message: str


@dataclass(frozen=True)
class Booking:
    start: datetime
    end: datetime
    gig_id: uuid.UUID | None


@dataclass(frozen=True)
class Calendar:
    """Everything the rule needs for one photographer over one stretch of
    time, loaded once. The rule itself never touches the database."""

    policy: ProSchedulingPolicy
    rules: list[ProAvailabilityRule]
    blocks: list[tuple[datetime, datetime]]
    bookings: list[Booking]
    counted: list[Booking]
    tz: ZoneInfo

    @property
    def has_schedule(self) -> bool:
        return bool(self.rules)


def load_calendar(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    start: datetime,
    end: datetime,
    ignore_gig_id: uuid.UUID | None = None,
    ignore_booking_request_id: uuid.UUID | None = None,
    requests_made_before: datetime | None = None,
) -> Calendar:
    """The photographer's calendar around [start, end).

    Loaded a day wider on each side: a night shift reaches back into the
    previous day, buffers reach past the edges, and the per-day count needs
    the whole local day.
    """
    from app.services.scheduling import get_or_create_scheduling_policy

    policy = get_or_create_scheduling_policy(db, pro_user_id=pro_user_id)
    rules = list(
        db.execute(
            select(ProAvailabilityRule)
            .where(ProAvailabilityRule.pro_user_id == pro_user_id)
            .order_by(ProAvailabilityRule.day_of_week.asc(), ProAvailabilityRule.start_time.asc())
        ).scalars()
    )
    wide_start, wide_end = start - timedelta(days=2), end + timedelta(days=2)

    slots = db.execute(
        select(ConfirmedSlot).where(
            ConfirmedSlot.pro_user_id == pro_user_id,
            ConfirmedSlot.status.in_(_COUNTED_SLOT_STATUSES),
            ConfirmedSlot.start_at_utc < wide_end,
            ConfirmedSlot.end_at_utc > wide_start,
        )
    ).scalars().all()
    now = datetime.now(timezone.utc)
    gigs = db.execute(
        select(Gig).where(
            Gig.pro_user_id == pro_user_id,
            or_(
                Gig.status.in_(OCCUPYING_GIG_STATUSES),
                # Accepted and inside its time to pay. Past it, the gig holds
                # nothing even before the sweep cancels it.
                and_(Gig.status == GigStatus.payment_pending, Gig.created_at > now - PAYMENT_WINDOW),
            ),
            Gig.scheduled_start.is_not(None),
            Gig.scheduled_end.is_not(None),
            Gig.scheduled_start < wide_end,
            Gig.scheduled_end > wide_start,
        )
    ).scalars().all()
    requests = db.execute(
        select(BookingRequest).where(
            BookingRequest.pro_user_id == pro_user_id,
            BookingRequest.status == BookingRequestStatus.pending,
            BookingRequest.expires_at > now,
            BookingRequest.requested_start < wide_end,
            BookingRequest.requested_end > wide_start,
            *([BookingRequest.created_at < requests_made_before] if requests_made_before else []),
        )
    ).scalars().all()

    # A gig with a confirmed slot is one booking, timed by the slot.
    slotted_gigs = {slot.gig_id for slot in slots}
    busy: list[Booking] = []
    counted: list[Booking] = []
    for slot in slots:
        if slot.gig_id == ignore_gig_id:
            continue
        booking = Booking(slot.start_at_utc, slot.end_at_utc, slot.gig_id)
        counted.append(booking)
        if str(getattr(slot.status, "value", slot.status)) in _BUSY_SLOT_STATUSES:
            busy.append(booking)
    for gig in gigs:
        if gig.id == ignore_gig_id or gig.id in slotted_gigs:
            continue
        booking = Booking(gig.scheduled_start, gig.scheduled_end, gig.id)
        busy.append(booking)
        counted.append(booking)
    # A pending request has no gig yet; accepting turns it into one and its
    # status to accepted, so it is never counted twice.
    for request in requests:
        if request.id == ignore_booking_request_id:
            continue
        booking = Booking(request.requested_start, request.requested_end, None)
        busy.append(booking)
        counted.append(booking)

    return Calendar(
        policy=policy,
        rules=rules,
        blocks=blocked_intervals(db, pro_user_id, start=wide_start, end=wide_end),
        bookings=busy,
        counted=counted,
        # Rules carry their own timezone; a photographer's are one zone in
        # practice. With no rules there is nothing to be local to.
        tz=ZoneInfo(rules[0].timezone) if rules else ZoneInfo("UTC"),
    )


def refusal_for(
    cal: Calendar,
    start: datetime,
    end: datetime,
    *,
    now: datetime | None = None,
    at_payment: bool = False,
) -> Refusal | None:
    """Why [start, end) cannot be booked, or None when it can.

    `at_payment` is the check for an hour the photographer already agreed
    to. Notice and working hours were judged when the booking was made - a
    client paying the next morning must not be refused because the shoot is
    now nearer than the notice period. What can still make the hour
    impossible is the calendar since: blocked time, a full day, a clash.
    """
    now = now or datetime.now(timezone.utc)
    policy = cal.policy
    if end <= start:
        return Refusal("validation_error", "The end of a booking must be after its start.")
    if not at_payment:
        if not cal.rules:
            return Refusal("validation_error", NO_SCHEDULE_MESSAGE)
        if start < now + timedelta(hours=policy.advance_notice_hours):
            return Refusal(
                "validation_error",
                f"This photographer needs at least {policy.advance_notice_hours} hours' notice.",
            )
        if not any_rule_covers(cal.rules, start, end):
            return Refusal("validation_error", "That time is outside this photographer's working hours.")
    if any(b_start < end and b_end > start for b_start, b_end in cal.blocks):
        return Refusal("validation_error", "That time is blocked off in this photographer's calendar.")
    if policy.max_bookings_per_day:
        local_day = start.astimezone(cal.tz).date()
        on_day = sum(1 for b in cal.counted if b.start.astimezone(cal.tz).date() == local_day)
        if on_day >= policy.max_bookings_per_day:
            return Refusal("validation_error", "This photographer is fully booked that day.")
    padded_start = start - timedelta(minutes=policy.buffer_before_minutes)
    padded_end = end + timedelta(minutes=policy.buffer_after_minutes)
    if any(b.start < padded_end and b.end > padded_start for b in cal.bookings):
        return Refusal("slot_conflict", "That time clashes with another booking.")
    return None


def check_bookable(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    start_at_utc: datetime,
    end_at_utc: datetime,
    ignore_gig_id: uuid.UUID | None = None,
    ignore_booking_request_id: uuid.UUID | None = None,
    requests_made_before: datetime | None = None,
    at_payment: bool = False,
) -> None:
    """Raise a 409 naming the reason [start, end) cannot be booked.

    `ignore_gig_id` and `ignore_booking_request_id` are the booking being
    placed, accepted or paid for, so it is not refused for overlapping
    itself. See refusal_for on `at_payment`.
    """
    cal = load_calendar(
        db,
        pro_user_id=pro_user_id,
        start=start_at_utc,
        end=end_at_utc,
        ignore_gig_id=ignore_gig_id,
        ignore_booking_request_id=ignore_booking_request_id,
        requests_made_before=requests_made_before,
    )
    refusal = refusal_for(cal, start_at_utc, end_at_utc, at_payment=at_payment)
    if refusal is not None:
        raise APIError(code=refusal.code, message=refusal.message, status_code=409)


def bookable_starts(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    duration: timedelta,
    from_date: date,
    to_date: date,
    step: timedelta | None = None,
) -> tuple[Calendar, list[tuple[datetime, datetime]]]:
    """Every bookable [start, end) of `duration` whose start falls on a local
    date in [from_date, to_date], earliest first.

    Candidates step through each rule's window by the policy's slot length -
    the grid the photographer has chosen - and keep only those `refusal_for`
    passes. Rules are anchored from the day *before* from_date, because a
    night shift that starts then owns the first hours of from_date.
    """
    probe = datetime.combine(from_date, time(0), tzinfo=timezone.utc)
    cal = load_calendar(
        db,
        pro_user_id=pro_user_id,
        start=probe,
        end=datetime.combine(to_date + timedelta(days=1), time(0), tzinfo=timezone.utc),
    )
    if not cal.rules:
        return cal, []
    step = step or timedelta(minutes=cal.policy.slot_length_minutes)
    now = datetime.now(timezone.utc)

    found: dict[datetime, datetime] = {}
    anchor = from_date - timedelta(days=1)
    while anchor <= to_date:
        for rule in cal.rules:
            if rule.day_of_week != anchor.weekday():
                continue
            window_start, window_end = rule_window(rule, anchor)
            start = window_start
            while start + duration <= window_end:
                local_day = start.astimezone(cal.tz).date()
                start_utc = start.astimezone(timezone.utc)
                end_utc = (start + duration).astimezone(timezone.utc)
                if from_date <= local_day <= to_date and refusal_for(cal, start_utc, end_utc, now=now) is None:
                    found[start_utc] = end_utc
                start += step
        anchor += timedelta(days=1)
    return cal, sorted(found.items())


def expire_unpaid_gigs(db: Session, *, now: datetime | None = None, limit: int | None = 100) -> int:
    """Cancel accepted gigs not paid within PAYMENT_WINDOW, releasing their time.

    The rule already stops counting such a gig the moment its window passes;
    this makes it final, and closes its payment so a late charge cannot land
    on a booking that no longer exists.

    The payment is closed first, and the gig cancelled only if that worked.
    If Stripe refuses - the payment succeeded, or is going through right now -
    the gig is left as it is for the webhook to mark paid. Cancelling it
    anyway would leave a client charged for a cancelled booking.
    """
    import app.services.stripe_service  # noqa: F401 - sets the Stripe key
    from app.services.gig_state import transition_gig

    current = now or datetime.now(timezone.utc)
    query = (
        select(Gig)
        .where(Gig.status == GigStatus.payment_pending, Gig.created_at <= current - PAYMENT_WINDOW)
        .order_by(Gig.created_at.asc())
    )
    if limit is not None:
        query = query.limit(limit)

    expired = 0
    for gig in db.execute(query).scalars().all():
        open_payments = db.execute(
            select(StripePayment).where(
                StripePayment.gig_id == gig.id,
                StripePayment.status.in_([PaymentStatus.pending, PaymentStatus.requires_action]),
            )
        ).scalars().all()
        try:
            for payment in open_payments:
                if payment.stripe_payment_intent_id:
                    stripe.PaymentIntent.cancel(payment.stripe_payment_intent_id)
        except stripe.error.StripeError:
            logger.warning("unpaid_gig_payment_not_cancellable", extra={"gig_id": str(gig.id)})
            continue
        try:
            with db.begin_nested():
                for payment in open_payments:
                    payment.status = PaymentStatus.cancelled
                db.add(
                    transition_gig(
                        gig,
                        GigStatus.cancelled_by_client,
                        gig.client_user_id,
                        reason="Not paid within 24 hours of being accepted; the time was released",
                    )
                )
            expired += 1
        except Exception:
            logger.exception("expire_unpaid_gig_failed", extra={"gig_id": str(gig.id)})
    return expired
