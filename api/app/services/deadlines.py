"""How long a booking request has to be answered, and an accepted booking to
be paid. The one place it is decided.

It used to be a hard-coded 24 hours in each of the three places a request is
made (the client funnel, the photographer's side, a request from chat) and a
24-hour PAYMENT_WINDOW constant. Short-notice booking needs a shorter clock,
and a clock that never runs past the shoot, so it is decided here:

  accept   standard: BOOKING_RESPONSE_DEADLINE_HOURS (24)
           short notice: SHORT_NOTICE_ACCEPT_MINUTES (30)
           never later than the start
  pay      standard: PAYMENT_WINDOW_HOURS (24) from acceptance
           short notice: SHORT_NOTICE_PAY_MINUTES (30)
           never later than PAY_DEADLINE_MARGIN_MINUTES (60) before the start

A request records the terms it was made under (BookingRequest.short_notice,
notice_minutes, pay_window_minutes) and the gig records its pay deadline, so
switching "available now" off afterwards changes nothing for a booking
already on its way.
"""
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta

from app.core.config import get_settings
from app.core.errors import APIError


def _accept_window(short_notice: bool) -> timedelta:
    settings = get_settings()
    return timedelta(minutes=settings.short_notice_accept_minutes) if short_notice else timedelta(hours=settings.booking_response_deadline_hours)


def _pay_window(short_notice: bool) -> timedelta:
    settings = get_settings()
    return timedelta(minutes=settings.short_notice_pay_minutes) if short_notice else timedelta(hours=settings.payment_window_hours)


def accept_deadline(*, now: datetime, start: datetime, short_notice: bool) -> datetime:
    """When a request made `now` for a shoot at `start` expires unanswered."""
    return min(now + _accept_window(short_notice), start)


def pay_deadline(*, accepted_at: datetime, start: datetime, short_notice: bool, window: timedelta | None = None) -> datetime:
    """When a booking accepted at `accepted_at` must be paid by. `window` is
    the request's own recorded window, when it has one."""
    margin = timedelta(minutes=get_settings().pay_deadline_margin_minutes)
    return min(accepted_at + (window if window is not None else _pay_window(short_notice)), start - margin)


@dataclass(frozen=True)
class RequestTerms:
    short_notice: bool
    notice_minutes: int
    expires_at: datetime
    pay_window_minutes: int


def request_terms(*, now: datetime, start: datetime, standard_notice_hours: int, notice_minutes: int) -> RequestTerms:
    """The terms a new request is made under. Short notice means booked inside
    the photographer's usual notice - possible only because they were
    available now, and judged then against `notice_minutes`."""
    short = start < now + timedelta(hours=standard_notice_hours)
    return RequestTerms(
        short_notice=short,
        notice_minutes=notice_minutes,
        expires_at=accept_deadline(now=now, start=start, short_notice=short),
        pay_window_minutes=int(_pay_window(short).total_seconds() // 60),
    )


def pay_deadline_for_request(request, *, accepted_at: datetime) -> datetime:
    window = timedelta(minutes=request.pay_window_minutes) if request.pay_window_minutes is not None else None
    return pay_deadline(accepted_at=accepted_at, start=request.requested_start, short_notice=request.short_notice, window=window)


def pay_deadline_for_terms(terms: RequestTerms, *, start: datetime, accepted_at: datetime) -> datetime:
    """The pay deadline of a booking confirmed now for `start` on `terms` -
    for a time other than the one requested, judged as a new request."""
    return pay_deadline(
        accepted_at=accepted_at,
        start=start,
        short_notice=terms.short_notice,
        window=timedelta(minutes=terms.pay_window_minutes),
    )


def ensure_payable_in_time(request, *, accepted_at: datetime) -> datetime:
    """The pay deadline accepting now would set, refusing if it has already
    passed: a yes the client cannot complete in time books nothing."""
    return refuse_if_too_late_to_pay(pay_deadline_for_request(request, accepted_at=accepted_at), accepted_at=accepted_at)


def refuse_if_too_late_to_pay(deadline: datetime, *, accepted_at: datetime) -> datetime:
    if deadline <= accepted_at:
        raise APIError(
            code="too_late_to_pay",
            message="This shoot starts too soon to be paid for in time. Decline it, or ask the client for a later time.",
            status_code=409,
        )
    return deadline


def gig_pay_deadline(gig) -> datetime:
    """When this gig had to be paid by. Gigs from before deadlines were
    recorded had the standard window from when they were made."""
    if gig.pay_deadline_at is not None:
        return gig.pay_deadline_at
    return gig.created_at + timedelta(hours=get_settings().payment_window_hours)
