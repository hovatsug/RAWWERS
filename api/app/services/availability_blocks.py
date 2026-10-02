"""Time a photographer has marked as unavailable, across both families
that record it.

Two tables hold the same fact for historical reasons: ProBlackoutDate,
written by the deprecated POST /v1/pro/me/availability/blackouts, and
ProAvailabilityException, written by PUT /v1/pro/scheduling/exceptions.
Enforcement used to read one or the other depending on which endpoint
created the booking, which meant blocked time silently did nothing on
the path the client app actually uses.

Everything that decides whether someone can be booked reads through
here, so a photographer's blocked time counts no matter which endpoint
recorded it. That is also what makes deprecating the blackout route
safe: existing rows keep blocking, they just stop gaining new company.
"""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.booking import ProAvailabilityException, ProBlackoutDate


def blocked_intervals(
    db: Session, pro_user_id: uuid.UUID, *, start: datetime, end: datetime
) -> list[tuple[datetime, datetime]]:
    """Every blocked interval overlapping [start, end), from both tables,
    merged and sorted. Overlapping and touching intervals are coalesced so
    two adjacent blocks read as the one continuous unavailability they
    represent."""
    blackouts = db.execute(
        select(ProBlackoutDate.start_at, ProBlackoutDate.end_at).where(
            ProBlackoutDate.pro_user_id == pro_user_id,
            ProBlackoutDate.start_at < end,
            ProBlackoutDate.end_at > start,
        )
    ).all()
    exceptions = db.execute(
        select(ProAvailabilityException.start_at_utc, ProAvailabilityException.end_at_utc).where(
            ProAvailabilityException.pro_user_id == pro_user_id,
            ProAvailabilityException.start_at_utc < end,
            ProAvailabilityException.end_at_utc > start,
        )
    ).all()

    raw = sorted(
        [(row[0], row[1]) for row in list(blackouts) + list(exceptions)],
        key=lambda pair: pair[0],
    )
    merged: list[tuple[datetime, datetime]] = []
    for block_start, block_end in raw:
        if merged and block_start <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], block_end))
        else:
            merged.append((block_start, block_end))
    return merged
