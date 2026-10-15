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

  - it is at least the notice away: `advance_notice_hours`, or - while the
    photographer is "available now" and for a package that allows it - their
    preparation time, for anything in the next 24 hours (notice_minutes_for);
  - one working-hours rule wholly contains it (a night shift owns the small
    hours of the next day - see availability_rules);
  - no blocked time touches it, from either table (availability_blocks);
  - the photographer's local day is under `max_bookings_per_day`;
  - it clears every existing booking by the policy's buffers.

What counts as a booking, i.e. what holds time:

  - a reserved or confirmed slot;
  - a paid gig's scheduled time;
  - an accepted gig awaiting payment, until its pay deadline (deadlines.py)
    - once a photographer has said yes, the hour is not theirs to sell again
    while the client pays;
  - a pending request, until it expires - first come, first served. A
    request holds against requests made after it, and not against earlier
    ones: when a photographer accepts a request, only pending requests older
    than it stand in its way. Otherwise two overlapping pending requests
    (made before holds existed) would each block the other for ever.

Holding only paid time let two clients request the same hour, the
photographer accept both, and both pay. That was reproduced before this
changed; tests/test_bookable_time.py covers it end to end.

`refusal_for` is the rule; `check_bookable` raises it for one time;
`bookable_windows` lists every bookable window in a date range. The last two
apply the same rule, so a window the calendar offers is one the request
accepts, and the reverse. `check_offered` closes the other half: a request
must be one of the windows the package offers at all, not merely free time.

Scheduling presets (per package) decide only which windows are candidates
and what a booking occupies - see `Shape`. The rule above is the same for
every preset, with two differences a preset genuinely changes:

  - full day: "within working hours" means the photographer works that
    weekday (a whole date never fits inside 09:00-18:00), and notice counts
    from that day's first working hour. It occupies the whole local date, so
    the ordinary overlap check is what closes the date to everything else,
    and what keeps it from being booked on a date with anything on it.
  - buffers: owed between two bookings if either was made under an interval
    preset. Two block bookings need none: the photographer drew that
    boundary deliberately, and it is the separation.
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
import logging

import stripe

from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    ConfirmedSlot,
    PackageSessionBlock,
    ProAvailabilityRule,
    ProPackage,
    ProSchedulingPolicy,
    SchedulingPreset,
    SessionBlockLabel,
)
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment
from app.services import available_now
from app.services.availability_blocks import blocked_intervals
from app.services.availability_rules import any_rule_covers, rule_window

logger = logging.getLogger(__name__)

# How long an accepted, unpaid booking holds its time is its own pay
# deadline, fixed at acceptance - see app/services/deadlines.py. Gigs from
# before that was recorded had the standard window from when they were made.
_STANDARD_PAY_WINDOW = timedelta(hours=24)


def _pay_deadline_column():
    return func.coalesce(Gig.pay_deadline_at, Gig.created_at + _STANDARD_PAY_WINDOW)

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
    # Made under an interval preset - or before presets existed. Such a
    # booking keeps its buffers whatever is booked next to it.
    buffered: bool = True


def _buffered(preset) -> bool:
    return preset in (None, SchedulingPreset.interval, SchedulingPreset.interval.value)


@dataclass(frozen=True)
class Shape:
    """How one package's bookable windows are laid out.

    interval: starts every `interval` (None: the photographer's slot length)
    through each working-hours window, each `duration` long.
    blocks: each (label, local start, local end), every date.
    full_day: the whole local date, every date.
    """

    preset: SchedulingPreset
    duration: timedelta
    interval: timedelta | None = None
    blocks: tuple[tuple[SessionBlockLabel, time, time], ...] = ()
    # The package may be booked at the photographer's preparation time while
    # they are "available now".
    short_notice_ok: bool = False


@dataclass(frozen=True)
class Window:
    start: datetime
    end: datetime
    label: SessionBlockLabel | None = None


def request_preset(request: BookingRequest) -> SchedulingPreset:
    """The preset a request was made under. Before presets: interval."""
    return SchedulingPreset(request.scheduling_preset or SchedulingPreset.interval)


def gig_preset(gig: Gig) -> SchedulingPreset:
    """The preset a gig's booking was made under, carried from its request."""
    return SchedulingPreset((gig.meta or {}).get("scheduling_preset") or SchedulingPreset.interval)


def shape_for_package(db: Session, package: ProPackage) -> Shape:
    preset = SchedulingPreset(package.scheduling_preset or SchedulingPreset.interval)
    blocks: tuple = ()
    if preset == SchedulingPreset.blocks:
        rows = db.execute(
            select(PackageSessionBlock).where(PackageSessionBlock.package_id == package.id)
        ).scalars().all()
        order = list(SessionBlockLabel)
        blocks = tuple(
            sorted(
                ((SessionBlockLabel(r.label), r.start_time, r.end_time) for r in rows),
                key=lambda b: order.index(b[0]),
            )
        )
    return Shape(
        preset=preset,
        short_notice_ok=bool(package.short_notice_ok),
        duration=timedelta(minutes=package.duration_minutes),
        interval=timedelta(minutes=package.interval_minutes) if package.interval_minutes else None,
        blocks=blocks,
    )


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
    # The preparation time to use as notice right now, or None: decided once,
    # when the calendar is loaded (available_now.short_notice_minutes).
    short_notice_minutes: int | None = None

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

    One photographer through load_calendars - the one way calendars are
    loaded, so the batched path the Discover rows use cannot drift from the
    one every booking takes.
    """
    return load_calendars(
        db,
        pro_user_ids=[pro_user_id],
        start=start,
        end=end,
        ignore_gig_id=ignore_gig_id,
        ignore_booking_request_id=ignore_booking_request_id,
        requests_made_before=requests_made_before,
    )[pro_user_id]


def load_calendars(
    db: Session,
    *,
    pro_user_ids: list[uuid.UUID],
    start: datetime,
    end: datetime,
    ignore_gig_id: uuid.UUID | None = None,
    ignore_booking_request_id: uuid.UUID | None = None,
    requests_made_before: datetime | None = None,
    presence_states: dict | None = None,
) -> dict[uuid.UUID, Calendar]:
    """load_calendar for several photographers at once: the same queries
    with IN instead of =, so the cost does not grow with how many.
    `presence_states` reuses a presence read the caller already made."""
    from app.models.booking import ProSchedulingPolicy
    from app.services.availability_blocks import blocked_intervals_for
    from app.services.scheduling import get_or_create_scheduling_policy

    ids = list(dict.fromkeys(pro_user_ids))
    policies = {row.pro_user_id: row for row in db.execute(select(ProSchedulingPolicy).where(ProSchedulingPolicy.pro_user_id.in_(ids))).scalars()}
    for pro_id in ids:
        if pro_id not in policies:
            policies[pro_id] = get_or_create_scheduling_policy(db, pro_user_id=pro_id)

    def by_pro(rows, attr="pro_user_id") -> dict[uuid.UUID, list]:
        grouped: dict[uuid.UUID, list] = {pro_id: [] for pro_id in ids}
        for row in rows:
            grouped[getattr(row, attr)].append(row)
        return grouped

    rules = by_pro(
        db.execute(
            select(ProAvailabilityRule)
            .where(ProAvailabilityRule.pro_user_id.in_(ids))
            .order_by(ProAvailabilityRule.pro_user_id, ProAvailabilityRule.day_of_week.asc(), ProAvailabilityRule.start_time.asc())
        ).scalars()
    )
    wide_start, wide_end = start - timedelta(days=2), end + timedelta(days=2)

    slots = by_pro(
        db.execute(
            select(ConfirmedSlot).where(
                ConfirmedSlot.pro_user_id.in_(ids),
                ConfirmedSlot.status.in_(_COUNTED_SLOT_STATUSES),
                ConfirmedSlot.start_at_utc < wide_end,
                ConfirmedSlot.end_at_utc > wide_start,
            )
        ).scalars()
    )
    now = datetime.now(timezone.utc)
    gigs = by_pro(
        db.execute(
            select(Gig).where(
                Gig.pro_user_id.in_(ids),
                or_(
                    Gig.status.in_(OCCUPYING_GIG_STATUSES),
                    # Accepted and inside its time to pay. Past it, the gig holds
                    # nothing even before the sweep cancels it.
                    and_(Gig.status == GigStatus.payment_pending, _pay_deadline_column() > now),
                ),
                Gig.scheduled_start.is_not(None),
                Gig.scheduled_end.is_not(None),
                Gig.scheduled_start < wide_end,
                Gig.scheduled_end > wide_start,
            )
        ).scalars()
    )
    requests = by_pro(
        db.execute(
            select(BookingRequest).where(
                BookingRequest.pro_user_id.in_(ids),
                BookingRequest.status == BookingRequestStatus.pending,
                BookingRequest.expires_at > now,
                BookingRequest.requested_start < wide_end,
                BookingRequest.requested_end > wide_start,
                *([BookingRequest.created_at < requests_made_before] if requests_made_before else []),
            )
        ).scalars()
    )

    # A gig with a confirmed slot is one booking, timed by the slot. Its
    # preset lives on the gig.
    gig_preset = {gig.id: (gig.meta or {}).get("scheduling_preset") for rows in gigs.values() for gig in rows}
    missing = {slot.gig_id for rows in slots.values() for slot in rows} - set(gig_preset)
    if missing:
        for gig_id, meta in db.execute(select(Gig.id, Gig.meta).where(Gig.id.in_(missing))).all():
            gig_preset[gig_id] = (meta or {}).get("scheduling_preset")

    blocks = blocked_intervals_for(db, ids, start=wide_start, end=wide_end)
    short_notice = available_now.short_notice_minutes_for(policies, now, states=presence_states)

    calendars: dict[uuid.UUID, Calendar] = {}
    for pro_id in ids:
        slotted_gigs = {slot.gig_id for slot in slots[pro_id]}
        busy: list[Booking] = []
        counted: list[Booking] = []
        for slot in slots[pro_id]:
            if slot.gig_id == ignore_gig_id:
                continue
            booking = Booking(slot.start_at_utc, slot.end_at_utc, slot.gig_id, _buffered(gig_preset.get(slot.gig_id)))
            counted.append(booking)
            if str(getattr(slot.status, "value", slot.status)) in _BUSY_SLOT_STATUSES:
                busy.append(booking)
        for gig in gigs[pro_id]:
            if gig.id == ignore_gig_id or gig.id in slotted_gigs:
                continue
            booking = Booking(gig.scheduled_start, gig.scheduled_end, gig.id, _buffered(gig_preset.get(gig.id)))
            busy.append(booking)
            counted.append(booking)
        # A pending request has no gig yet; accepting turns it into one and its
        # status to accepted, so it is never counted twice.
        for request in requests[pro_id]:
            if request.id == ignore_booking_request_id:
                continue
            booking = Booking(request.requested_start, request.requested_end, None, _buffered(request.scheduling_preset))
            busy.append(booking)
            counted.append(booking)
        pro_rules = rules[pro_id]
        calendars[pro_id] = Calendar(
            policy=policies[pro_id],
            rules=pro_rules,
            blocks=blocks[pro_id],
            bookings=busy,
            counted=counted,
            # Rules carry their own timezone; a photographer's are one zone in
            # practice. With no rules there is nothing to be local to.
            tz=ZoneInfo(pro_rules[0].timezone) if pro_rules else ZoneInfo("UTC"),
            short_notice_minutes=short_notice[pro_id],
        )
    return calendars


SHORT_NOTICE_HORIZON = timedelta(hours=24)


def notice_minutes_for(cal: Calendar, start: datetime, *, now: datetime, short_notice_ok: bool) -> int:
    """The notice a booking starting at `start` needs, made `now`: the
    photographer's preparation time if they are available now, the package
    allows it and the start is within the next 24 hours; otherwise their
    usual notice. The one place short notice changes anything."""
    if cal.short_notice_minutes is not None and short_notice_ok and start < now + SHORT_NOTICE_HORIZON:
        return min(cal.short_notice_minutes, cal.policy.advance_notice_hours * 60)
    return cal.policy.advance_notice_hours * 60


def refusal_for(
    cal: Calendar,
    start: datetime,
    end: datetime,
    *,
    now: datetime | None = None,
    at_payment: bool = False,
    preset: SchedulingPreset = SchedulingPreset.interval,
    short_notice_ok: bool = False,
    notice_minutes: int | None = None,
    notice_from: datetime | None = None,
) -> Refusal | None:
    """Why [start, end) cannot be booked, or None when it can.

    Notice is notice_minutes_for(...) - unless `notice_minutes` is given:
    the notice a request was already judged against, measured from
    `notice_from` (when it was made). Accepting or confirming a request
    keeps the terms it was made under, whatever the toggle says now.

    `preset` is the preset the window is being booked under; see the module
    docstring for the two places it changes the answer.

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
    if notice_minutes is None:
        notice_minutes = notice_minutes_for(cal, start, now=now, short_notice_ok=short_notice_ok)
    else:
        now = notice_from or now
    required = timedelta(minutes=notice_minutes)
    notice = Refusal(
        "validation_error",
        f"This photographer needs at least {_hours(notice_minutes)} notice.",
    )
    if not at_payment:
        if not cal.rules:
            return Refusal("validation_error", NO_SCHEDULE_MESSAGE)
        if preset == SchedulingPreset.full_day:
            local_day = start.astimezone(cal.tz).date()
            day_rules = [rule for rule in cal.rules if rule.day_of_week == local_day.weekday()]
            if not day_rules:
                return Refusal("validation_error", "This photographer does not work that day.")
            first_hour = min(rule_window(rule, local_day)[0] for rule in day_rules)
            if first_hour < now + required:
                return notice
        else:
            if start < now + required:
                return notice
            if not any_rule_covers(cal.rules, start, end):
                return Refusal("validation_error", "That time is outside this photographer's working hours.")
    if any(b_start < end and b_end > start for b_start, b_end in cal.blocks):
        return Refusal("validation_error", "That time is blocked off in this photographer's calendar.")
    if policy.max_bookings_per_day:
        local_day = start.astimezone(cal.tz).date()
        on_day = sum(1 for b in cal.counted if b.start.astimezone(cal.tz).date() == local_day)
        if on_day >= policy.max_bookings_per_day:
            return Refusal("validation_error", "This photographer is fully booked that day.")
    before = timedelta(minutes=policy.buffer_before_minutes)
    after = timedelta(minutes=policy.buffer_after_minutes)
    candidate_buffered = _buffered(preset)
    for b in cal.bookings:
        # Buffers are owed if either side was booked by the hour; two blocks
        # the photographer defined sit against each other as drawn.
        pad = candidate_buffered or b.buffered
        if b.start < end + (after if pad else timedelta(0)) and b.end > start - (before if pad else timedelta(0)):
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
    preset: SchedulingPreset = SchedulingPreset.interval,
    short_notice_ok: bool = False,
    notice_minutes: int | None = None,
    notice_from: datetime | None = None,
) -> Calendar:
    """Raise a 409 naming the reason [start, end) cannot be booked; return
    the calendar it was judged against (request creation reads the notice
    it used from it).

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
    refusal = refusal_for(
        cal,
        start_at_utc,
        end_at_utc,
        at_payment=at_payment,
        preset=preset,
        short_notice_ok=short_notice_ok,
        notice_minutes=notice_minutes,
        notice_from=notice_from,
    )
    if refusal is not None:
        raise APIError(code=refusal.code, message=refusal.message, status_code=409)
    return cal


def _hours(minutes: int) -> str:
    if minutes % 60 == 0:
        return "1 hour's" if minutes == 60 else f"{minutes // 60} hours'"
    return f"{minutes} minutes'"


def _local(day: date, at: time, tz: ZoneInfo) -> datetime:
    # The same construction as rule_window, so a block and a working-hours
    # window built for the same local time are the same instant.
    return datetime.combine(day, at).replace(tzinfo=tz)


def _candidates(cal: Calendar, shape: Shape, from_date: date, to_date: date) -> list[Window]:
    """Every window `shape` lays out whose start falls on a local date in
    [from_date, to_date] - before any of them is checked against the rule."""
    found: dict[datetime, Window] = {}

    def keep(window: Window) -> None:
        if from_date <= window.start.astimezone(cal.tz).date() <= to_date:
            utc = Window(window.start.astimezone(timezone.utc), window.end.astimezone(timezone.utc), window.label)
            found.setdefault(utc.start, utc)

    if shape.preset == SchedulingPreset.interval:
        step = shape.interval or timedelta(minutes=cal.policy.slot_length_minutes)
        # From the day *before*: a night shift that starts then owns the first
        # hours of from_date. Anchored to each window's own start, so the
        # photographer's hours decide where the grid falls.
        anchor = from_date - timedelta(days=1)
        while anchor <= to_date:
            for rule in cal.rules:
                if rule.day_of_week != anchor.weekday():
                    continue
                window_start, window_end = rule_window(rule, anchor)
                start = window_start
                while start + shape.duration <= window_end:
                    keep(Window(start, start + shape.duration))
                    start += step
            anchor += timedelta(days=1)
    elif shape.preset == SchedulingPreset.blocks:
        day = from_date
        while day <= to_date:
            for label, block_start, block_end in shape.blocks:
                end_day = day + timedelta(days=1) if block_end <= block_start else day
                keep(Window(_local(day, block_start, cal.tz), _local(end_day, block_end, cal.tz), label))
            day += timedelta(days=1)
    else:  # full_day
        day = from_date
        while day <= to_date:
            keep(Window(_local(day, time(0), cal.tz), _local(day + timedelta(days=1), time(0), cal.tz)))
            day += timedelta(days=1)
    return sorted(found.values(), key=lambda w: w.start)


def _range_calendar(db: Session, pro_user_id: uuid.UUID, from_date: date, to_date: date) -> Calendar:
    return load_calendar(
        db,
        pro_user_id=pro_user_id,
        start=datetime.combine(from_date, time(0), tzinfo=timezone.utc),
        end=datetime.combine(to_date + timedelta(days=1), time(0), tzinfo=timezone.utc),
    )


def bookable_windows(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    shape: Shape,
    from_date: date,
    to_date: date,
) -> tuple[Calendar, list[Window]]:
    """Every window `shape` lays out in [from_date, to_date] that the rule
    allows, earliest first. What the client calendar offers."""
    cal = _range_calendar(db, pro_user_id, from_date, to_date)
    if not cal.rules:
        return cal, []
    now = datetime.now(timezone.utc)
    return cal, [
        w
        for w in _candidates(cal, shape, from_date, to_date)
        if refusal_for(cal, w.start, w.end, now=now, preset=shape.preset, short_notice_ok=shape.short_notice_ok) is None
    ]


def first_bookable_start(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    shapes: list[Shape],
    after: datetime,
    before: datetime,
) -> Window | None:
    """The earliest window any of `shapes` lays out that starts in
    (after, before] and the rule allows. See first_bookable_starts."""
    return first_bookable_starts(db, shapes_by_pro={pro_user_id: shapes}, after=after, before=before, want=1).get(pro_user_id)


def first_bookable_starts(
    db: Session,
    *,
    shapes_by_pro: dict[uuid.UUID, list[Shape]],
    after: datetime,
    before: datetime,
    want: int,
    presence_states: dict | None = None,
) -> dict[uuid.UUID, Window]:
    """For photographers taken in the order given, each one's earliest
    window that starts in (after, before] and the rule allows - stopping
    once `want` have one. What "Available now" asks.

    The same rule as bookable_windows, asked cheaply: every calendar in one
    batched load, then windows tried in time order, stopping at the first
    the rule allows instead of judging every window in the range."""
    from_date, to_date = (after - timedelta(days=1)).date(), (before + timedelta(days=1)).date()
    calendars = load_calendars(
        db,
        pro_user_ids=list(shapes_by_pro),
        start=datetime.combine(from_date, time(0), tzinfo=timezone.utc),
        end=datetime.combine(to_date + timedelta(days=1), time(0), tzinfo=timezone.utc),
        presence_states=presence_states,
    )
    found: dict[uuid.UUID, Window] = {}
    for pro_id, shapes in shapes_by_pro.items():
        cal = calendars[pro_id]
        if not cal.rules:
            continue
        best: Window | None = None
        for shape in shapes:
            for window in _candidates(cal, shape, from_date, to_date):
                if window.start <= after:
                    continue
                if window.start > before or (best is not None and window.start >= best.start):
                    break
                if refusal_for(cal, window.start, window.end, now=after, preset=shape.preset, short_notice_ok=shape.short_notice_ok) is None:
                    best = window
                    break
        if best is not None:
            found[pro_id] = best
            if len(found) == want:
                break
    return found


def bookable_starts(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    duration: timedelta,
    from_date: date,
    to_date: date,
    step: timedelta | None = None,
) -> tuple[Calendar, list[tuple[datetime, datetime]]]:
    """The interval preset as (start, end) pairs - the pro's own slot list,
    which is per photographer rather than per package."""
    cal, windows = bookable_windows(
        db,
        pro_user_id=pro_user_id,
        shape=Shape(preset=SchedulingPreset.interval, duration=duration, interval=step),
        from_date=from_date,
        to_date=to_date,
    )
    return cal, [(w.start, w.end) for w in windows]


NOT_OFFERED_MESSAGE = "That time isn't one this package offers. Pick one of the times on the calendar."


def check_offered(db: Session, *, pro_user_id: uuid.UUID, shape: Shape, start_at_utc: datetime, end_at_utc: datetime) -> None:
    """Raise unless [start, end) is exactly one of the windows `shape` lays out.

    Whether it is free is check_bookable's question. This one is whether it
    is a window this package offers at all: without it a client could ask for
    10:17, or two hours inside a Morning block, or part of a full day, and
    the presets would only ever shape what the calendar shows.
    """
    cal = _range_calendar(db, pro_user_id, start_at_utc.date() - timedelta(days=2), end_at_utc.date() + timedelta(days=1))
    local_day = start_at_utc.astimezone(cal.tz).date()
    offered = {(w.start, w.end) for w in _candidates(cal, shape, local_day - timedelta(days=1), local_day + timedelta(days=1))}
    if (start_at_utc.astimezone(timezone.utc), end_at_utc.astimezone(timezone.utc)) not in offered:
        raise APIError(code="not_offered", message=NOT_OFFERED_MESSAGE, status_code=409)


def expire_unpaid_gigs(db: Session, *, now: datetime | None = None, limit: int | None = 100) -> int:
    """Cancel accepted gigs not paid by their pay deadline, releasing their time.

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
        .where(Gig.status == GigStatus.payment_pending, _pay_deadline_column() <= current)
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
                        reason="Not paid by its pay deadline; the time was released",
                    )
                )
            expired += 1
        except Exception:
            logger.exception("expire_unpaid_gig_failed", extra={"gig_id": str(gig.id)})
    return expired


from app.services.deadlines import RequestTerms  # noqa: E402 - re-exported for the request paths


def check_requestable(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    start_at_utc: datetime,
    end_at_utc: datetime,
    shape: Shape | None,
    ignore_gig_id: uuid.UUID | None = None,
    ignore_booking_request_id: uuid.UUID | None = None,
) -> RequestTerms:
    """For a new request: refuse unless bookable (with short notice where it
    applies) and offered by the package, and return the terms it is made
    under. Every path that makes a request uses this - the client funnel,
    the photographer's side and chat - so none can drift. Confirming a time
    other than the one requested is judged here too, as a request made now;
    the ignore_* arguments are that booking, so it does not clash with
    itself."""
    from app.services.deadlines import request_terms

    now = datetime.now(timezone.utc)
    short_ok = bool(shape and shape.short_notice_ok)
    cal = check_bookable(
        db,
        pro_user_id=pro_user_id,
        start_at_utc=start_at_utc,
        end_at_utc=end_at_utc,
        ignore_gig_id=ignore_gig_id,
        ignore_booking_request_id=ignore_booking_request_id,
        preset=shape.preset if shape else SchedulingPreset.interval,
        short_notice_ok=short_ok,
    )
    if shape is not None:
        check_offered(db, pro_user_id=pro_user_id, shape=shape, start_at_utc=start_at_utc, end_at_utc=end_at_utc)
    return request_terms(
        now=now,
        start=start_at_utc,
        standard_notice_hours=cal.policy.advance_notice_hours,
        notice_minutes=notice_minutes_for(cal, start_at_utc, now=now, short_notice_ok=short_ok),
    )


def apply_request_terms(request: BookingRequest, terms: RequestTerms) -> None:
    request.short_notice = terms.short_notice
    request.notice_minutes = terms.notice_minutes
    request.expires_at = terms.expires_at
    request.pay_window_minutes = terms.pay_window_minutes
