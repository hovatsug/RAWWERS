""""Available now" and "Online now" - the two Discover rows that are worked
out on every request.

The home response is cached until the public index changes; presence and
availability change by the minute. So these two rows are never part of the
cached response. Client home computes them after the cache, on cached and
fresh responses alike, from:

  - the photographers eligible in this city (and niche) - the same five gates
    as every other row, one indexed query;
  - one batched presence read for all of them (presence.live_states);
  - for "Available now" only: one query for who is switched on with a
    short-notice package, then the one availability rule every booking path
    uses (bookable_time.bookable_windows) on at most AVAILABLE_CANDIDATE_CAP
    of them, for a real start in the next 24 hours.

Neither row's order uses gigs, rating, tier or ranking. "Available now" is by
preparation time - the soonest a client can have someone - then a daily
rotation; "Online now" by the daily rotation alone. The rotation is a hash of
the day, the viewer and the photographer: stable for one viewer through a
day, different across viewers and days, so a newcomer is on the same terms as
anyone.

If Redis cannot answer, both rows are left out. Nothing here is ever
guessed, and nothing that reaches a client says when anyone was last seen or
until when they are available.
"""
from __future__ import annotations

import hashlib
import logging
import time
import uuid
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.booking import ProPackage, ProSchedulingPolicy
from app.services import presence
from app.services.bookable_time import first_bookable_starts, shape_for_package

logger = logging.getLogger(__name__)

ROW_SIZE = 12
# How many switched-on photographers may be put through the availability
# rule per request. Each check reads one calendar; the cap bounds the cost of
# a request whatever the city's size. Twice a row: enough for a full row even
# when some have no start left today.
AVAILABLE_CANDIDATE_CAP = 2 * ROW_SIZE
HORIZON = timedelta(hours=24)


def rotation_day(now: datetime | None = None) -> date:
    return (now or datetime.now(timezone.utc)).date()


def viewer_seed(user_id: uuid.UUID | None, country: str, city: str) -> str:
    """Each signed-in client their own order; guests in a city share one."""
    return str(user_id) if user_id else f"guest:{country.strip().upper()}:{city.strip().lower()}"


def rotation_key(pro_user_id: uuid.UUID, *, day: date, seed: str) -> str:
    return hashlib.sha256(f"{day.isoformat()}|{seed}|{pro_user_id}".encode()).hexdigest()


@dataclass
class LiveRows:
    available: list[uuid.UUID] = field(default_factory=list)
    online: list[uuid.UUID] = field(default_factory=list)
    # Preparation time, for the card's "ready in about N hours" - only for
    # photographers who passed every "Available now" check.
    ready_in: dict[uuid.UUID, int] = field(default_factory=dict)
    timings_ms: dict[str, float] = field(default_factory=dict)
    candidates_checked: int = 0
    # The one presence read, kept so the same lookup sets every card's dot:
    # every card on a home screen is one of the eligible photographers.
    # None when Redis could not say.
    states: dict | None = None


def compute(
    db: Session,
    *,
    eligible: list[uuid.UUID],
    niche_id: uuid.UUID | None,
    seed: str,
    now: datetime | None = None,
) -> LiveRows:
    now = now or datetime.now(timezone.utc)
    day = rotation_day(now)
    out = LiveRows()
    started = time.perf_counter()

    states = presence.live_states(eligible)
    out.states = states
    out.timings_ms["presence"] = (time.perf_counter() - started) * 1000
    if not states:  # None: Redis could not say. {}: nobody has the app open.
        return out

    by_rotation = lambda pro_id: rotation_key(pro_id, day=day, seed=seed)  # noqa: E731
    out.online = sorted((p for p in eligible if presence.is_shown(states.get(str(p)))), key=by_rotation)[:ROW_SIZE]

    fresh_for = get_settings().available_now_fresh_seconds
    fresh = [p for p in eligible if (s := states.get(str(p))) is not None and s[0] <= fresh_for]
    if fresh:
        t = time.perf_counter()
        prep = dict(
            db.execute(
                select(ProSchedulingPolicy.pro_user_id, ProSchedulingPolicy.short_notice_prep_minutes).where(
                    ProSchedulingPolicy.pro_user_id.in_(fresh), ProSchedulingPolicy.available_until > now
                )
            ).all()
        )
        packages: dict[uuid.UUID, list[ProPackage]] = {}
        if prep:
            query = select(ProPackage).where(
                ProPackage.pro_user_id.in_(list(prep)),
                ProPackage.is_active.is_(True),
                ProPackage.short_notice_ok.is_(True),
            )
            if niche_id is not None:
                query = query.where(ProPackage.niche_id == niche_id)
            for package in db.execute(query.order_by(ProPackage.duration_minutes, ProPackage.id)).scalars():
                packages.setdefault(package.pro_user_id, []).append(package)
        out.timings_ms["switched_on"] = (time.perf_counter() - t) * 1000

        candidates = sorted(packages, key=lambda p: (prep[p], by_rotation(p)))[:AVAILABLE_CANDIDATE_CAP]
        t = time.perf_counter()
        if candidates:
            # One batched calendar load for every candidate, then each judged
            # in row order until the row is full - a real start in the next
            # 24 hours, by the rule every booking path uses: working hours,
            # blocked time, bookings, holds, buffers, the daily limit and the
            # short notice all apply.
            found = first_bookable_starts(
                db,
                shapes_by_pro={p: [shape_for_package(db, pkg) for pkg in packages[p]] for p in candidates},
                after=now,
                before=now + HORIZON,
                want=ROW_SIZE,
                presence_states=states,
            )
            out.candidates_checked = len(candidates)
            out.available = [p for p in candidates if p in found]
            out.ready_in = {p: prep[p] for p in out.available}
        out.timings_ms["bookable"] = (time.perf_counter() - t) * 1000

    out.timings_ms["total"] = (time.perf_counter() - started) * 1000
    logger.info(
        "live_rows",
        extra={
            "eligible": len(eligible),
            "available": len(out.available),
            "online": len(out.online),
            "candidates_checked": out.candidates_checked,
            "timings_ms": {k: round(v, 1) for k, v in out.timings_ms.items()},
        },
    )
    return out
