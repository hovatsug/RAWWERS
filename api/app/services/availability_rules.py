"""Weekly availability rules, including the ones that cross midnight.

A rule is (weekday, start_time, end_time, timezone). When `end_time` is
not after `start_time` the rule ends the following day, and `weekday`
anchors the *start*: Friday 20:00-02:00 is Friday night into Saturday
morning, and belongs to Friday.

That one decision is why this module exists rather than the comparison
being written out at each call site. It was previously inlined three
times - the booking-request check, the slot check, and the slot
generator - and every one of them assumed a rule began and ended on the
same day, so an events photographer could not be booked at all.
"""
from __future__ import annotations

from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

from app.core.errors import APIError

# A shift that crosses midnight is a night's work, not a standing offer.
# Without a bound, 20:00-19:00 - a plausible typo for 20:00-19:00 the same
# evening - reads as 23 hours of availability rather than a mistake, and
# nothing downstream would question it. All-day availability is a
# non-wrapping 00:00-23:59, which is unaffected by this cap.
MAX_OVERNIGHT_SPAN = timedelta(hours=16)


def wraps_midnight(start: time, end: time) -> bool:
    return end <= start


def rule_span(start: time, end: time) -> timedelta:
    """How long the rule lasts, following it into the next day if it wraps."""
    base = datetime(2000, 1, 1)
    start_at = datetime.combine(base, start)
    end_at = datetime.combine(base + timedelta(days=1) if wraps_midnight(start, end) else base, end)
    return end_at - start_at


def validate_rule_times(start: time, end: time) -> None:
    """Raises a 422 describing what is wrong, in the terms the pro used.

    A wrapping rule is allowed; one that nearly laps itself is not.
    """
    if not wraps_midnight(start, end):
        return
    span = rule_span(start, end)
    if span > MAX_OVERNIGHT_SPAN:
        hours = int(MAX_OVERNIGHT_SPAN.total_seconds() // 3600)
        raise APIError(
            code="validation_error",
            message=(
                f"A shift crossing midnight cannot be longer than {hours} hours. "
                "For all-day availability use 00:00 to 23:59."
            ),
            status_code=422,
        )


def rule_window(rule, anchor: date) -> tuple[datetime, datetime]:
    """The rule's concrete window for the day it starts on, as tz-aware
    datetimes. `anchor` is the local date the rule begins."""
    tz = ZoneInfo(rule.timezone)
    start_at = datetime.combine(anchor, rule.start_time).replace(tzinfo=tz)
    end_date = anchor + timedelta(days=1) if wraps_midnight(rule.start_time, rule.end_time) else anchor
    end_at = datetime.combine(end_date, rule.end_time).replace(tzinfo=tz)
    return start_at, end_at


def rule_covers(rule, start_at_utc: datetime, end_at_utc: datetime) -> bool:
    """Whether this rule wholly contains [start, end).

    Checks the slot's own local date and the one before it: the tail of a
    wrapping rule falls on the day *after* the rule's weekday, so a slot at
    Saturday 01:00 has to be matched against Friday's rule.
    """
    tz = ZoneInfo(rule.timezone)
    local_start = start_at_utc.astimezone(tz)

    for days_back in (0, 1):
        anchor = (local_start - timedelta(days=days_back)).date()
        if anchor.weekday() != rule.day_of_week:
            continue
        window_start, window_end = rule_window(rule, anchor)
        if window_start <= start_at_utc and end_at_utc <= window_end:
            return True
    return False


def any_rule_covers(rules, start_at_utc: datetime, end_at_utc: datetime) -> bool:
    return any(rule_covers(rule, start_at_utc, end_at_utc) for rule in rules)
