#!/usr/bin/env python3
"""Demo data for seeing each new feature in the simulator. Development only.

One module, extended at every step of the presence work, so a finished
feature is visible in the app rather than present only in tests:

  response_time   seven Lisbon photographers whose request history puts them
                  in every label state (this step)
  chat            seeded conversations with unread messages (next step)
  presence /      a refresher that re-heartbeats a few seeded photographers
  available now   every minute - freshness is never relaxed for the demo

Everything goes through the real routes, called in-process with real access
tokens: the client's booking request (with its availability check and rate
limit), the photographer's decline, the scheduled expiry sweep. Only then
are the timestamps moved into the past, because a history is the one thing a
real path cannot write in the present. So the rows are exactly what the
product writes, at the times a demo needs.

Re-running repairs rather than duplicates (the standing rule in
_seed_common.py). Each seeded request carries a tag in its notes; an
existing one is brought back to its intended outcome and timestamps. One
that is superseded - its outcome can no longer be reached, or the history
got shorter - is retired: cancelled by its client through the real route if
it is still pending, otherwise deleted with its transitions and follow-ups.
Never by moving it into the past, which would leave invented rows behind.

Requests come from seed-only accounts (seed.requester<n>@rawwers.dev),
never from client@rawwers.dev or anyone a person logs in as, and the
rate-limiter keys the run created are removed at the end - so seeding does
not use up anyone's five requests a day.

Refuses to run unless APP_ENV is development, dev or local. That is stricter
than the seed guard, which also admits staging: demo histories on staging
would put invented response times in front of anyone testing there.

    docker compose run --rm -v "$PWD/..:/repo" -w /repo/api api python scripts/seed_demo.py
    ... scripts/seed_demo.py --only response_time --dry-run
"""
from __future__ import annotations

import argparse
import os
import sys
import uuid
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import SeedUser, _upsert_user, assert_environment_is_seedable  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import ProProfile, UserAccount, UserRoleType  # noqa: E402
from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition, ProPackage  # noqa: E402
from app.models.niche import Niche  # noqa: E402
from app.services.discovery_index import recompute_pro_public_index  # noqa: E402
from app.services.response_time import bucket_for, client_label, response_median_minutes  # noqa: E402

_DEV_ONLY = frozenset({"development", "dev", "local"})


def assert_development_only() -> None:
    assert_environment_is_seedable()
    environment = (os.environ.get("APP_ENV") or "development").strip().lower()
    if environment not in _DEV_ONLY:
        raise RuntimeError(f"Refusing to write demo data: APP_ENV is {environment!r}; demo data is for {sorted(_DEV_ONLY)} only.")


# --- response_time -----------------------------------------------------------

TAG = "[demo:response_time]"
WINDOW = timedelta(hours=24)  # every request path today: 24 hours to answer


@dataclass(frozen=True)
class Reply:
    """One request in a photographer's history. after=None: never answered,
    expired by the sweep."""

    after: timedelta | None
    asked_days_ago: float

    @property
    def outcome(self) -> BookingRequestStatus:
        return BookingRequestStatus.expired if self.after is None else BookingRequestStatus.declined


def _m(minutes: float, days_ago: float) -> Reply:
    return Reply(timedelta(minutes=minutes), days_ago)


def _ignored(days_ago: float) -> Reply:
    return Reply(None, days_ago)


# By email, so the photographers are the same on every database the fake
# photographer seed has filled. All six are in Lisbon's rows. Fast replies
# are declines: the measure counts a decline exactly as an accept, and an
# accept would create an unpaid gig holding real calendar time.
HISTORIES: dict[str, tuple[str, list[Reply]]] = {
    "ines.carvalho@rawwers.dev": ("within_hour", [_m(12, 9), _m(25, 7), _m(40, 5), _m(18, 3)]),
    "simao.vasques@rawwers.dev": ("within_hour", [_m(30, 6), _m(45, 4), _m(20, 2)]),
    "tomas.belmonte@rawwers.dev": ("few_hours", [_m(130, 8), _m(200, 6), _m(240, 4), _m(95, 2)]),
    # Replies between 8 and 20 hours.
    "patricia.boaventura@rawwers.dev": ("within_day", [_m(480, 9), _m(720, 7), _m(900, 5), _m(1200, 3)]),
    # Two quick answers and three ignored requests: what the old average read
    # as "within an hour". An expiry counts as just past the day, so the
    # median is over a day - and clients are shown nothing.
    "daniel.roque@rawwers.dev": ("over_day", [_m(10, 9), _m(15, 7), _ignored(6), _ignored(4), _ignored(2)]),
    # Declined 30 hours in - after the deadline, before the sweep ran. Stored
    # as over a day and, until alerts exist, shown to no client.
    "nuno.bastos@rawwers.dev": ("over_day", [_m(1800, 8), _m(1900, 6), _m(2000, 4)]),
    "bruno.cardoso@rawwers.dev": ("no_history", [_m(20, 5), _m(35, 3)]),
}

# Seed-only requesters: nobody logs in as these. The client route allows
# five requests per client per day, so the history is spread over several.
SEED_REQUESTERS = [
    SeedUser(
        user_id=uuid.UUID(f"00000000-0000-0000-0000-0000000d{n:04d}"),
        email=f"seed.requester{n}@rawwers.dev",
        password="Passw0rd!",
        display_name=f"Seed requester {n}",
        roles=(UserRoleType.client,),
    )
    for n in range(1, 8)
]


def _api():
    from fastapi.testclient import TestClient

    from app.main import app

    return TestClient(app, raise_server_exceptions=True)


def _headers(db, user_id: uuid.UUID) -> dict[str, str]:
    from app.services.auth_tokens import create_access_token
    from app.services.authz import get_user_roles

    roles = sorted(r.value for r in get_user_roles(db, user_id))
    token, _ = create_access_token(user_id=user_id, roles=roles, ttl_minutes=15)
    return {"Authorization": f"Bearer {token}"}


def _first_open_window(api, headers, pro_id: uuid.UUID, package_id: uuid.UUID) -> tuple[str, str]:
    start = date.today() + timedelta(days=3)
    resp = api.get(
        f"/v1/client/pros/{pro_id}/availability",
        params={"package_id": str(package_id), "from": start.isoformat(), "to": (start + timedelta(days=28)).isoformat()},
        headers=headers,
    )
    resp.raise_for_status()
    for day in resp.json()["days"]:
        for window in day["start_times"]:
            return window["start_at"], window["end_at"]
    raise RuntimeError(f"{pro_id}: no bookable window in the next four weeks - check its working hours")


def _ensure_working_hours(api, db, pro_id: uuid.UUID) -> bool:
    """A request can only be made for a time the calendar offers, and most
    seeded photographers have no working hours at all. Give one weekday
    hours (Mon-Fri 09:00-18:00 Lisbon) through the photographer's own route -
    only when they have none, so hours someone set are never overwritten."""
    from app.models.booking import ProAvailabilityRule

    if db.execute(select(ProAvailabilityRule.id).where(ProAvailabilityRule.pro_user_id == pro_id).limit(1)).first():
        return False
    resp = api.put(
        "/v1/pro/scheduling/availability-rules",
        headers=_headers(db, pro_id),
        json={
            "rules": [
                {"weekday": day, "start_local": "09:00", "end_local": "18:00", "timezone": "Europe/Lisbon"}
                for day in range(5)
            ]
        },
    )
    if resp.status_code != 200:
        raise RuntimeError(f"{pro_id}: setting working hours refused ({resp.status_code}): {resp.text}")
    db.expire_all()
    return True


def _seeded(db, pro_id: uuid.UUID) -> dict[int, BookingRequest]:
    rows = db.execute(
        select(BookingRequest).where(BookingRequest.pro_user_id == pro_id, BookingRequest.notes.like(f"{TAG} #%"))
    ).scalars().all()
    return {int(r.notes.split("#", 1)[1]): r for r in rows}


def _create(api, db, pro_id: uuid.UUID, client: SeedUser, index: int) -> BookingRequest:
    package = db.execute(
        select(ProPackage).where(ProPackage.pro_user_id == pro_id, ProPackage.is_active.is_(True)).order_by(ProPackage.created_at)
    ).scalars().first()
    niche_slug = db.execute(select(Niche.slug).where(Niche.id == package.niche_id)).scalar_one()
    headers = _headers(db, client.user_id)
    start_at, end_at = _first_open_window(api, headers, pro_id, package.id)
    resp = api.post(
        "/v1/client/bookings/request",
        headers=headers,
        json={
            "pro_user_id": str(pro_id),
            "niche_slug": niche_slug,
            "date_window": {"start_at": start_at, "end_at": end_at},
            "package_id": str(package.id),
            "notes": f"{TAG} #{index}",
        },
    )
    if resp.status_code != 200:
        raise RuntimeError(f"{pro_id}: booking request refused ({resp.status_code}): {resp.text}")
    db.expire_all()
    return db.get(BookingRequest, uuid.UUID(resp.json()["booking_id"]))


def _resolve(api, db, request: BookingRequest, reply: Reply) -> None:
    """Move a pending request to the reply's outcome by the real path."""
    if reply.outcome == BookingRequestStatus.declined:
        resp = api.post(
            f"/v1/booking-requests/{request.id}/decline",
            headers=_headers(db, request.pro_user_id),
            json={"reason": "Not available that day"},
        )
        if resp.status_code != 200:
            raise RuntimeError(f"decline refused ({resp.status_code}): {resp.text}")
    else:
        from app.services.scheduling import expire_pending_booking_requests

        request.expires_at = datetime.now(timezone.utc) - timedelta(seconds=1)
        db.commit()
        expire_pending_booking_requests(db, limit=None)
        db.commit()
    db.expire_all()


def _backdate(db, request: BookingRequest, reply: Reply, *, asked: datetime) -> None:
    resolved = asked + (reply.after if reply.after is not None else WINDOW)
    request.created_at = asked
    request.expires_at = asked + WINDOW
    for transition in db.execute(
        select(BookingRequestTransition).where(BookingRequestTransition.booking_request_id == request.id)
    ).scalars():
        transition.created_at = asked if transition.to_status == BookingRequestStatus.pending else resolved


def _retire(api, db, request: BookingRequest) -> None:
    """Take a superseded seeded request out of the history for good."""
    from sqlalchemy import delete

    from app.models.booking import BookingTimeRequest
    from app.models.communication import FollowupJob

    if request.status == BookingRequestStatus.pending:
        resp = api.post(
            f"/v1/booking-requests/{request.id}/cancel",
            headers=_headers(db, request.client_user_id),
            json={"reason": "Superseded demo request"},
        )
        if resp.status_code != 200:
            raise RuntimeError(f"cancel refused ({resp.status_code}): {resp.text}")
        db.expire_all()
        return
    db.execute(delete(FollowupJob).where(FollowupJob.target_type == "booking_request", FollowupJob.target_id == request.id))
    db.execute(delete(BookingTimeRequest).where(BookingTimeRequest.booking_request_id == request.id))
    db.execute(delete(BookingRequestTransition).where(BookingRequestTransition.booking_request_id == request.id))
    db.delete(request)
    db.flush()


def _limiter_keys(principals: list[uuid.UUID]) -> set[str]:
    from app.services.cache import get_redis_client

    redis = get_redis_client()
    keys: set[str] = set()
    for principal in principals:
        keys |= {k.decode() if isinstance(k, bytes) else k for k in redis.scan_iter(match=f"ratelimit:*{principal}*")}
    return keys


def _clear_limiter_keys(keys: set[str]) -> int:
    from app.services.cache import get_redis_client

    return get_redis_client().delete(*keys) if keys else 0


def seed_response_time(db, *, dry_run: bool) -> list[str]:
    for requester in SEED_REQUESTERS:
        if not dry_run:
            _upsert_user(db, requester)
    if not dry_run:
        db.commit()
    api = None if dry_run else _api()
    pro_ids = [
        account.user_id
        for account in db.execute(select(UserAccount).where(UserAccount.email.in_(list(HISTORIES)))).scalars()
    ]
    # Photographers are real logins: only the limiter keys this run creates
    # for them go, not any they already had.
    keys_before = set() if dry_run else _limiter_keys(pro_ids)
    now = datetime.now(timezone.utc)
    report = []
    turn = 0
    for email, (expected, history) in HISTORIES.items():
        account = db.execute(select(UserAccount).where(UserAccount.email == email)).scalar_one_or_none()
        if account is None or db.get(ProProfile, account.user_id) is None:
            report.append(f"{email}: missing - run seed_fake_photographers.py first")
            continue
        pro_id = account.user_id
        if not dry_run and _ensure_working_hours(api, db, pro_id):
            report.append(f"{email}: had no working hours - set Mon-Fri 09:00-18:00 Lisbon")
        existing = _seeded(db, pro_id)
        for index, reply in enumerate(history):
            request = existing.get(index)
            if request is not None and request.status not in (BookingRequestStatus.pending, reply.outcome):
                if not dry_run:
                    _retire(api, db, request)
                    db.commit()
                request = None
            if dry_run:
                continue
            if request is None:
                request = _create(api, db, pro_id, SEED_REQUESTERS[turn % len(SEED_REQUESTERS)], index)
                turn += 1
            if request.status == BookingRequestStatus.pending:
                _resolve(api, db, request, reply)
                request = db.get(BookingRequest, request.id)
            _backdate(db, request, reply, asked=now - timedelta(days=reply.asked_days_ago))
            db.commit()
        # A seeded request past the history's length (the history was
        # shortened) would still count: retire it.
        for index, request in existing.items():
            if index >= len(history) and not dry_run:
                _retire(api, db, request)
        if not dry_run:
            db.commit()
            recompute_pro_public_index(db, pro_id)
            db.commit()
        median, sample = response_median_minutes(db, pro_id)
        bucket = bucket_for(median).value
        label = client_label(bucket)
        ok = "ok" if bucket == expected or dry_run else f"EXPECTED {expected}"
        report.append(f"{email}: {bucket} (median {median}m over {sample}) -> {label or '(nothing shown)'} [{ok}]")
    if not dry_run:
        created = (_limiter_keys([r.user_id for r in SEED_REQUESTERS]) | _limiter_keys(pro_ids)) - keys_before
        report.append(f"rate-limiter keys created by this run, removed: {_clear_limiter_keys(created)}")
    return report


STEPS = {"response_time": seed_response_time}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--only", choices=sorted(STEPS), action="append")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    assert_development_only()
    with SessionLocal() as db:
        for name in args.only or list(STEPS):
            print(f"== {name}{' (dry run)' if args.dry_run else ''}")
            for line in STEPS[name](db, dry_run=args.dry_run):
                print("  " + line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
