"""How quickly a photographer answers booking requests - honestly.

The old measure was the mean time to accept or decline, over every reply
ever. It left out requests nobody answered, so a photographer who ignored
most requests and answered a few quickly looked fast - the opposite of what
a client needs to know. This one:

  - takes the photographer's last RESPONSE_SAMPLE_SIZE *resolved* requests:
    accepted, declined, or expired unanswered. A client withdrawing a request
    before any reply is not the photographer's response, and is left out.
  - counts an expired request as the whole wait the client sat through (its
    expiry window), so ignoring requests reads as slow, never as missing.
  - uses the median, so one outlier does not decide the label.
  - says nothing until MIN_RESOLVED requests have resolved - expired ones
    included, so ignoring everyone cannot hide behind "no history yet".

Read from the transition log, by `to_status`: the expiry sweep records the
photographer as the actor of an expiry, so going by the actor would make an
ignored request look like a reply.
"""
from __future__ import annotations

import enum
import statistics
import uuid

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition

RESPONSE_SAMPLE_SIZE = 10
MIN_RESOLVED = 3

_RESOLVED = (BookingRequestStatus.accepted, BookingRequestStatus.declined, BookingRequestStatus.expired)


class ResponseBucket(str, enum.Enum):
    within_hour = "within_hour"
    few_hours = "few_hours"
    within_day = "within_day"
    over_day = "over_day"
    no_history = "no_history"


#: Upper bounds, in minutes, of the buckets a client may be shown.
_BUCKETS = ((60, ResponseBucket.within_hour), (6 * 60, ResponseBucket.few_hours), (24 * 60, ResponseBucket.within_day))


def response_median_minutes(db: Session, pro_user_id: uuid.UUID) -> tuple[int | None, int]:
    """The median response time over the recent sample, and how many requests
    it was taken over. None when fewer than MIN_RESOLVED have resolved."""
    rows = db.execute(
        select(BookingRequestTransition.to_status, BookingRequestTransition.created_at, BookingRequest.created_at, BookingRequest.expires_at)
        .join(BookingRequest, BookingRequest.id == BookingRequestTransition.booking_request_id)
        .where(
            BookingRequest.pro_user_id == pro_user_id,
            BookingRequestTransition.from_status == BookingRequestStatus.pending,
            BookingRequestTransition.to_status.in_(_RESOLVED),
        )
        .order_by(BookingRequestTransition.created_at.desc())
        .limit(RESPONSE_SAMPLE_SIZE)
    ).all()
    minutes: list[float] = []
    for to_status, resolved_at, asked_at, expires_at in rows:
        if to_status == BookingRequestStatus.expired:
            # Never answered: the client waited the whole window.
            minutes.append(max(0.0, (expires_at - asked_at).total_seconds() / 60))
        else:
            minutes.append(max(0.0, (resolved_at - asked_at).total_seconds() / 60))
    if len(minutes) < MIN_RESOLVED:
        return None, len(minutes)
    return int(statistics.median(minutes)), len(minutes)


def bucket_for(median_minutes: int | None) -> ResponseBucket:
    if median_minutes is None:
        return ResponseBucket.no_history
    for upper, bucket in _BUCKETS:
        if median_minutes <= upper:
            return bucket
    return ResponseBucket.over_day


#: What a client is shown for each bucket.
_CLIENT_LABELS = {
    ResponseBucket.within_hour: "Usually replies within an hour",
    ResponseBucket.few_hours: "Usually replies within a few hours",
    ResponseBucket.within_day: "Usually replies within a day",
    ResponseBucket.no_history: "No response history yet",
}


def client_label(bucket: str | ResponseBucket | None) -> str | None:
    """The label a client sees, or None to show nothing.

    `over_day` is stored but not shown. Until push or email exists, a request
    that expired partly measures the platform's failure to reach the
    photographer - their app was closed and nothing told them - rather than
    their behaviour, so a slow label would blame them for it. Revisit when
    alerts exist; the bucket is already computed for that.
    """
    if bucket is None:
        return None
    return _CLIENT_LABELS.get(ResponseBucket(bucket))


def card_label(bucket: str | ResponseBucket | None) -> str | None:
    """The label for a discover card: a positive bucket only. "No response
    history yet" belongs on the profile - on a card it would sit on nearly
    every photographer and say nothing that tells them apart."""
    if bucket is None or ResponseBucket(bucket) == ResponseBucket.no_history:
        return None
    return client_label(bucket)
