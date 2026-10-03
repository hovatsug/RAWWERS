"""A package's scheduling configuration: kept consistent on save.

The preset decides which windows a package offers (bookable_time). A
configuration that could never offer anything sensible - blocks with no
block, a shoot longer than its block, blocks that overlap - is refused here,
when the photographer saves it, rather than discovered by a client finding
an empty calendar.
"""
from __future__ import annotations

from datetime import time

from sqlalchemy import delete
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.booking import ALLOWED_INTERVAL_MINUTES, PackageSessionBlock, ProPackage, SchedulingPreset

_DAY = 24 * 60


def _minutes(at: time) -> int:
    return at.hour * 60 + at.minute


def _span(start: time, end: time) -> tuple[int, int]:
    """[start, end) in minutes from midnight; an end at or before the start
    runs into the next day, as a night shift does."""
    s, e = _minutes(start), _minutes(end)
    return s, (e if e > s else e + _DAY)


def _refuse(message: str) -> APIError:
    return APIError(code="validation_error", message=message, status_code=422)


def validate_schedule(preset: SchedulingPreset, interval_minutes: int | None, blocks: list, duration_minutes: int) -> None:
    if preset == SchedulingPreset.interval:
        if blocks:
            raise _refuse("Session blocks are only for a package booked in blocks.")
        if interval_minutes is not None and interval_minutes not in ALLOWED_INTERVAL_MINUTES:
            raise _refuse("The interval must be hourly (none) or 4 hours (240 minutes).")
        return
    if interval_minutes is not None:
        raise _refuse("An interval is only for a package booked by the hour or every 4 hours.")
    if preset == SchedulingPreset.full_day:
        if blocks:
            raise _refuse("A full-day package has no session blocks: it books the whole date.")
        return

    # blocks
    if not blocks:
        raise _refuse("A package booked in blocks needs at least one block.")
    labels = [b.label for b in blocks]
    if len(set(labels)) != len(labels):
        raise _refuse("Each block - Morning, Afternoon, Evening - can be set once.")
    spans = []
    for b in blocks:
        if b.start_time == b.end_time:
            raise _refuse(f"The {b.label.value} block must start and end at different times.")
        start, end = _span(b.start_time, b.end_time)
        if end - start < duration_minutes:
            raise _refuse(f"The {b.label.value} block is shorter than the {duration_minutes}-minute shoot it is for.")
        spans.append((b.label, start, end))
    # Overlap on a repeating day: a block running past midnight meets the
    # next day's early blocks, so each is compared a day either side too.
    for i, (label_a, a_start, a_end) in enumerate(spans):
        for label_b, b_start, b_end in spans[i + 1 :]:
            for shift in (-_DAY, 0, _DAY):
                if a_start < b_end + shift and b_start + shift < a_end:
                    raise _refuse(f"The {label_a.value} and {label_b.value} blocks overlap.")


def apply_schedule(
    db: Session, package: ProPackage, preset: SchedulingPreset, interval_minutes: int | None, blocks: list
) -> None:
    """Validate against the package's duration and store the configuration,
    replacing any blocks it had."""
    validate_schedule(preset, interval_minutes, blocks, package.duration_minutes)
    package.scheduling_preset = preset
    package.interval_minutes = interval_minutes
    db.flush()
    db.execute(delete(PackageSessionBlock).where(PackageSessionBlock.package_id == package.id))
    for b in blocks:
        db.add(PackageSessionBlock(package_id=package.id, label=b.label, start_time=b.start_time, end_time=b.end_time))
    db.flush()


def current_blocks(db: Session, package: ProPackage) -> list[PackageSessionBlock]:
    from sqlalchemy import select

    return list(db.execute(select(PackageSessionBlock).where(PackageSessionBlock.package_id == package.id)).scalars())
