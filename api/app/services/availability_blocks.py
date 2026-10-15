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
    return blocked_intervals_for(db, [pro_user_id], start=start, end=end)[pro_user_id]


def blocked_intervals_for(
    db: Session, pro_user_ids: list[uuid.UUID], *, start: datetime, end: datetime
) -> dict[uuid.UUID, list[tuple[datetime, datetime]]]:
    """blocked_intervals for several photographers in two queries."""
    ids = list(dict.fromkeys(pro_user_ids))
    raw: dict[uuid.UUID, list[tuple[datetime, datetime]]] = {pro_id: [] for pro_id in ids}
    for pro_id, block_start, block_end in db.execute(
        select(ProBlackoutDate.pro_user_id, ProBlackoutDate.start_at, ProBlackoutDate.end_at).where(
            ProBlackoutDate.pro_user_id.in_(ids),
            ProBlackoutDate.start_at < end,
            ProBlackoutDate.end_at > start,
        )
    ).all():
        raw[pro_id].append((block_start, block_end))
    for pro_id, block_start, block_end in db.execute(
        select(ProAvailabilityException.pro_user_id, ProAvailabilityException.start_at_utc, ProAvailabilityException.end_at_utc).where(
            ProAvailabilityException.pro_user_id.in_(ids),
            ProAvailabilityException.start_at_utc < end,
            ProAvailabilityException.end_at_utc > start,
        )
    ).all():
        raw[pro_id].append((block_start, block_end))
    return {pro_id: _merge(blocks) for pro_id, blocks in raw.items()}


def _merge(blocks: list[tuple[datetime, datetime]]) -> list[tuple[datetime, datetime]]:
    merged: list[tuple[datetime, datetime]] = []
    for block_start, block_end in sorted(blocks, key=lambda pair: pair[0]):
        if merged and block_start <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], block_end))
        else:
            merged.append((block_start, block_end))
    return merged
