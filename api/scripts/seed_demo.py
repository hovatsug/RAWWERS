#!/usr/bin/env python3
"""Demo data for seeing each new feature in the simulator. Development only.

One module, extended at every step of the presence work, so a finished
feature is visible in the app rather than present only in tests:

  response_time   seven Lisbon photographers whose request history puts them
                  in every label state (this step)
  chat            conversations with Alex Lens (pro1@rawwers.dev): two with
                  unread messages, one with the assistant's labelled replies,
                  one already read
  presence        a refresher that re-heartbeats a few seeded photographers
                  every minute through the real route - freshness is never
                  relaxed for the demo. Runs until stopped:
                    ... scripts/seed_demo.py --refresh-presence
                    ... scripts/seed_demo.py --stop-presence-refresher
  available now   two of the online four (Ines, Tomas) with a package that
                  may be booked at short notice; the presence refresher
                  also keeps them switched on, through the real toggle,
                  and switches them off when it stops. Short notice still
                  needs working hours inside the next 24 hours - the step
                  prints the earliest short-notice slot each one has.
  live rows       Discover's "Available now" and "Online now" show Ines and
                  Tomas, and three photographers are set up to be left out,
                  one per rule: Patricia online with her dot hidden (not in
                  Online now), Nuno switched on but never checking in, and
                  Simao switched on and online with the next three days
                  blocked (neither in Available now; Simao still in Online
                  now).

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


# --- chat --------------------------------------------------------------------

CHAT_PRO_EMAIL = "pro1@rawwers.dev"  # Alex Lens - the login the demo is seen from

# Seed-only clients with real-looking names: the photographer's inbox shows
# who wrote, and "Seed requester 3" would make the demo read as a test.
CHAT_CLIENTS = [
    SeedUser(
        user_id=uuid.UUID(f"00000000-0000-0000-0000-0000000c{n:04d}"),
        email=f"seed.chat{n}@rawwers.dev",
        password="Passw0rd!",
        display_name=name,
        roles=(UserRoleType.client,),
    )
    for n, name in enumerate(("Marta Ribeiro", "Joao Pereira", "Sofia Almeida"), start=1)
]


@dataclass(frozen=True)
class Line:
    by: str  # "client" or "pro"
    text: str
    hours_ago: float


# Per client: the conversation, oldest first, and whether the photographer
# has read it. The assistant's replies are not scripted - they come from the
# real handler, as they would in the app.
CONVERSATIONS: dict[str, tuple[list[Line], bool]] = {
    "seed.chat1@rawwers.dev": (
        [
            Line("client", "Hi Alex! Are you free for a family shoot on a Saturday morning in May?", 5),
            Line("client", "We're four - two kids, 3 and 6. Somewhere outdoors if possible.", 4.5),
        ],
        False,
    ),
    "seed.chat2@rawwers.dev": (
        [Line("client", "Do you do LinkedIn headshots? It would be for five people at our office.", 2)],
        False,
    ),
    "seed.chat3@rawwers.dev": (
        [
            Line("client", "Hello! How long does a portrait session usually take?", 30),
            Line("pro", "Hi Sofia - about an hour, and you get the proofs within three days.", 29),
            Line("client", "Perfect, thank you!", 28.5),
        ],
        True,
    ),
}


def _run_queued_assistant_replies(db, thread_id: uuid.UUID) -> None:
    """What the worker would do with this conversation's queued assistant
    replies, done now so the demo does not change the next time a worker
    runs."""
    from app.models.outbox import OutboxEvent, OutboxEventStatus
    from app.services.outbox import mark_outbox_delivered
    from app.tasks.outbox_tasks import _dispatch_event

    events = db.execute(
        select(OutboxEvent).where(
            OutboxEvent.topic == "ai.reply.generate",
            OutboxEvent.status == OutboxEventStatus.pending,
            OutboxEvent.payload["thread_id"].astext == str(thread_id),
        )
    ).scalars().all()
    for event in events:
        _dispatch_event(db, event.topic, event.payload)
        mark_outbox_delivered(db, event)
    db.commit()


def _delete_thread(db, thread_id: uuid.UUID) -> None:
    from sqlalchemy import delete

    from app.models.chat import AIInteractionLog, ChatHandoff, ChatMessage, ChatThread, LeadProfile

    for model in (ChatMessage, ChatHandoff, LeadProfile, AIInteractionLog):
        db.execute(delete(model).where(model.thread_id == thread_id))
    db.execute(delete(ChatThread).where(ChatThread.id == thread_id))
    db.commit()


def _people_lines(db, thread_id: uuid.UUID) -> list[tuple[str, str]]:
    from app.models.chat import ChatMessage, ChatSenderType

    rows = db.execute(
        select(ChatMessage.sender_type, ChatMessage.content)
        .where(ChatMessage.thread_id == thread_id, ChatMessage.sender_type.in_([ChatSenderType.client, ChatSenderType.pro]))
        .order_by(ChatMessage.created_at)
    ).all()
    return [(sender.value, content) for sender, content in rows]


def seed_chat(db, *, dry_run: bool) -> list[str]:
    from app.models.chat import ChatMessage, ChatSenderType, ChatThread

    pro = db.execute(select(UserAccount).where(UserAccount.email == CHAT_PRO_EMAIL)).scalar_one_or_none()
    if pro is None:
        return [f"{CHAT_PRO_EMAIL}: missing - run seed_dev.py first"]
    if dry_run:
        return [f"{CHAT_PRO_EMAIL}: would hold {len(CONVERSATIONS)} conversations"]
    for person in CHAT_CLIENTS:
        _upsert_user(db, person)
    db.commit()
    api = _api()
    keys_before = _limiter_keys([pro.user_id])
    by_email = {p.email: p for p in CHAT_CLIENTS}
    now = datetime.now(timezone.utc)
    report = []
    for email, (script, read) in CONVERSATIONS.items():
        person = by_email[email]
        thread = db.execute(
            select(ChatThread).where(ChatThread.pro_user_id == pro.user_id, ChatThread.client_user_id == person.user_id)
        ).scalar_one_or_none()
        wanted = [(line.by, line.text) for line in script]
        if thread is not None and _people_lines(db, thread.id) != wanted:
            # Not the scripted conversation: start it again rather than patch
            # a history message by message.
            _delete_thread(db, thread.id)
            thread = None
        if thread is None:
            resp = api.post("/v1/chat/threads", headers=_headers(db, person.user_id), json={"pro_user_id": str(pro.user_id)})
            if resp.status_code != 200:
                raise RuntimeError(f"{email}: opening the conversation refused ({resp.status_code}): {resp.text}")
            thread_id = uuid.UUID(resp.json()["id"])
            _run_queued_assistant_replies(db, thread_id)
            for line in script:
                user_id, path = (
                    (person.user_id, f"/v1/chat/threads/{thread_id}/messages")
                    if line.by == "client"
                    else (pro.user_id, f"/v1/pro/chat/threads/{thread_id}/messages")
                )
                resp = api.post(path, headers=_headers(db, user_id), json={"content": line.text})
                if resp.status_code != 200:
                    raise RuntimeError(f"{email}: message refused ({resp.status_code}): {resp.text}")
                _run_queued_assistant_replies(db, thread_id)
            db.expire_all()
            thread = db.get(ChatThread, thread_id)
        # Into the past, keeping each message in its turn: a scripted line at
        # its time, anything between (the assistant) just after the line
        # before it.
        messages = db.execute(select(ChatMessage).where(ChatMessage.thread_id == thread.id).order_by(ChatMessage.created_at)).scalars().all()
        lines = iter(script)
        at = now - timedelta(hours=script[0].hours_ago, minutes=1)
        for message in messages:
            if message.sender_type in (ChatSenderType.client, ChatSenderType.pro):
                at = now - timedelta(hours=next(lines).hours_ago)
            else:
                at = at + timedelta(seconds=40)
            message.created_at = at
        thread.created_at = now - timedelta(hours=script[0].hours_ago, minutes=2)
        thread.pro_last_read_at = (at + timedelta(minutes=5)) if read else None
        db.commit()
        unread = sum(1 for m in messages if m.sender_type == ChatSenderType.client and (thread.pro_last_read_at is None or m.created_at > thread.pro_last_read_at))
        assistant = sum(1 for m in messages if m.sender_type == ChatSenderType.ai)
        report.append(f"{person.display_name}: {len(messages)} messages, {assistant} from the assistant, {unread} unread for Alex")
    created = (_limiter_keys([p.user_id for p in CHAT_CLIENTS]) | _limiter_keys([pro.user_id])) - keys_before
    report.append(f"rate-limiter keys created by this run, removed: {_clear_limiter_keys(created)}")
    return report


# --- available now ------------------------------------------------------------

# Switched on by the presence refresher; a subset of PRESENCE_EMAILS, because
# "available now" only counts while the app is checking in.
AVAILABLE_EMAILS = ("ines.carvalho@rawwers.dev", "tomas.belmonte@rawwers.dev")

# The three ways to be left out of Discover's live rows, one photographer
# each, so each can be seen not happening:
#   hidden dot  online, but hides the dot           -> not in "Online now"
#   stale       switched on, app never checks in    -> not in "Available now"
#   no start    switched on and online, but every
#               hour blocked for the next three days -> not in "Available now"
#                                                       (still in "Online now")
HIDDEN_DOT_EMAIL = "patricia.boaventura@rawwers.dev"
STALE_EMAIL = "nuno.bastos@rawwers.dev"
NO_START_EMAIL = "simao.vasques@rawwers.dev"
SWITCHED_ON_EMAILS = AVAILABLE_EMAILS + (STALE_EMAIL, NO_START_EMAIL)
BLOCK_REASON = "demo: away - no start in the next 24 hours"


def _short_notice_package(db, pro_id: uuid.UUID) -> ProPackage | None:
    """The package to flag: the shortest active one - an hour's portrait is
    what can be shot at a couple of hours' notice, a full day is not."""
    return db.execute(
        select(ProPackage)
        .where(ProPackage.pro_user_id == pro_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.duration_minutes, ProPackage.id)
        .limit(1)
    ).scalar_one_or_none()


def _user_id(db, email: str) -> uuid.UUID | None:
    return db.execute(select(UserAccount.user_id).where(UserAccount.email == email)).scalar_one_or_none()


def _block_next_days(api, db, pro_id: uuid.UUID) -> int:
    """Every hour of the next three days blocked, through the photographer's
    own blocked-time route. The route replaces their whole set - this is a
    demo account, made for this."""
    now = datetime.now(timezone.utc)
    resp = api.put(
        "/v1/pro/scheduling/exceptions",
        headers=_headers(db, pro_id),
        json={"items": [{"start_at_utc": (now - timedelta(hours=1)).isoformat(), "end_at_utc": (now + timedelta(days=3)).isoformat(), "reason": BLOCK_REASON}]},
    )
    return resp.status_code


def seed_available_now(db, *, dry_run: bool) -> list[str]:
    """Flag one package per demo photographer as fine at short notice,
    through the photographer's own package route (sent with its niche, as
    the route requires). Already flagged is left alone. Then set up the
    three exclusion cases: hide one dot, block one calendar (the stale one
    needs nothing - it simply never checks in)."""
    api = _api()
    lines = []
    for email in SWITCHED_ON_EMAILS:
        pro_id = db.execute(select(UserAccount.user_id).where(UserAccount.email == email)).scalar_one_or_none()
        package = _short_notice_package(db, pro_id) if pro_id else None
        if package is None:
            lines.append(f"{email}: no active package - skipped")
            continue
        if package.short_notice_ok:
            lines.append(f"{email}: '{package.title}' already bookable at short notice")
        elif dry_run:
            lines.append(f"{email}: would flag '{package.title}'")
        else:
            resp = api.put(
                f"/v1/pro/me/packages/{package.id}",
                headers=_headers(db, pro_id),
                json={"niche_id": str(package.niche_id), "short_notice_ok": True},
            )
            if resp.status_code != 200:
                raise RuntimeError(f"{email}: flagging refused ({resp.status_code}): {resp.text}")
            db.expire_all()
            lines.append(f"{email}: flagged '{package.title}' ({package.duration_minutes} min)")
        _ensure_working_hours(api, db, pro_id)
    hidden, blocked = _user_id(db, HIDDEN_DOT_EMAIL), _user_id(db, NO_START_EMAIL)
    if dry_run:
        lines.append(f"would hide {HIDDEN_DOT_EMAIL}'s dot and block {NO_START_EMAIL}'s next three days")
    else:
        if hidden:
            status = api.put("/v1/pro/presence/visibility", headers=_headers(db, hidden), json={"visible": False}).status_code
            lines.append(f"{HIDDEN_DOT_EMAIL}: dot hidden ({status}) - online, but not in Online now")
        if blocked:
            lines.append(f"{NO_START_EMAIL}: next three days blocked ({_block_next_days(api, db, blocked)}) - online, not in Available now")
        lines.append(f"{STALE_EMAIL}: switched on by the refresher but never checks in - not in Available now")
    lines.append("switched on only while --refresh-presence runs; see the slots it prints")
    return lines


def _earliest_short_notice_slot(api, db, pro_id: uuid.UUID) -> str:
    """What a client would be offered inside the next 24 hours, as the
    client's own availability route answers it."""
    package = _short_notice_package(db, pro_id)
    today = date.today()
    resp = api.get(
        f"/v1/client/pros/{pro_id}/availability",
        params={"package_id": str(package.id), "from": today.isoformat(), "to": (today + timedelta(days=1)).isoformat()},
        headers=_headers(db, pro_id),
    )
    if resp.status_code != 200:
        return f"availability {resp.status_code}"
    horizon = datetime.now(timezone.utc) + timedelta(hours=24)
    for day in resp.json()["days"]:
        for window in day["start_times"]:
            if datetime.fromisoformat(window["start_at"]) <= horizon:
                return window["start_at"]
    return "none in the next 24h (outside working hours)"


def _keep_available(api, db, pro_ids: list[uuid.UUID], *, on: bool) -> list[str]:
    """Through the real toggle. Switched on again only when under an hour
    is left, so the until time a photographer sees moves rarely."""
    out = []
    for pro_id in pro_ids:
        headers = _headers(db, pro_id)
        if on:
            view = api.get("/v1/pro/available-now", headers=headers).json()
            until = view.get("available_until")
            if until and datetime.fromisoformat(until) - datetime.now(timezone.utc) > timedelta(hours=1):
                out.append("on")
                continue
        out.append(str(api.put("/v1/pro/available-now", headers=headers, json={"switched_on": on}).status_code))
    return out


# --- presence refresher -------------------------------------------------------

# Online in the demo: four Lisbon photographers, two newcomers among them.
PRESENCE_EMAILS = (
    "ines.carvalho@rawwers.dev",
    "simao.vasques@rawwers.dev",
    "tomas.belmonte@rawwers.dev",
    "patricia.boaventura@rawwers.dev",
)
_STOP_KEY = "demo:presence-refresher:stop"
_RUNNING_KEY = "demo:presence-refresher:running"
_EVERY_SECONDS = 60  # above the server's minimum heartbeat interval


def refresh_presence() -> int:
    """Re-heartbeat the demo photographers every minute until stopped.

    The real heartbeat route, with real tokens: nothing about presence is
    relaxed for the demo, so a photographer is shown online exactly as long
    as a real heartbeat would keep them. One instance at a time; stopped by
    --stop-presence-refresher (checked every minute), Ctrl-C, or removing the
    container. On stopping it clears their presence, so their dots go at once.
    """
    import time

    from app.services.cache import get_redis_client

    redis = get_redis_client()
    if not redis.set(_RUNNING_KEY, "1", nx=True, ex=_EVERY_SECONDS * 2):
        print("presence refresher: another one is running - stop it first")
        return 1
    redis.delete(_STOP_KEY)
    api = _api()
    with SessionLocal() as db:
        pros = [
            row
            for row in db.execute(select(UserAccount.user_id, UserAccount.email).where(UserAccount.email.in_(PRESENCE_EMAILS))).all()
        ]
        available = [
            row.user_id
            for row in db.execute(select(UserAccount.user_id).where(UserAccount.email.in_(SWITCHED_ON_EMAILS))).all()
        ]
    print(f"presence refresher: keeping {len(pros)} photographers online, every {_EVERY_SECONDS}s. Stop with --stop-presence-refresher.")
    print(f"presence refresher: and {len(available)} switched on (two available now, two set up to be left out)")
    first = True
    try:
        while not redis.exists(_STOP_KEY):
            redis.set(_RUNNING_KEY, "1", ex=_EVERY_SECONDS * 2)
            with SessionLocal() as db:
                results = [
                    api.post("/v1/pro/presence/heartbeat", headers=_headers(db, pro_id)).status_code for pro_id, _ in pros
                ]
                # After the heartbeat: switched on counts only while fresh.
                switched = _keep_available(api, db, available, on=True)
                if first:
                    for pro_id in available:
                        print(f"  {pro_id}: earliest short-notice slot {_earliest_short_notice_slot(api, db, pro_id)}")
                    first = False
            print(f"  beat {time.strftime('%H:%M:%S')}: {results} available {switched}", flush=True)
            for _ in range(_EVERY_SECONDS):
                if redis.exists(_STOP_KEY):
                    break
                time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        with SessionLocal() as db:
            _keep_available(api, db, available, on=False)
            for pro_id, _ in pros:
                api.delete("/v1/pro/presence", headers=_headers(db, pro_id))
        redis.delete(_RUNNING_KEY, _STOP_KEY)
        print("presence refresher: stopped, dots cleared, available now switched off")
    return 0


def stop_presence_refresher() -> int:
    from app.services.cache import get_redis_client

    get_redis_client().set(_STOP_KEY, "1", ex=_EVERY_SECONDS * 3)
    print("presence refresher: asked to stop - it will within a second")
    return 0


STEPS = {"response_time": seed_response_time, "chat": seed_chat, "available_now": seed_available_now}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--only", choices=sorted(STEPS), action="append")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--refresh-presence", action="store_true", help="keep the demo photographers online until stopped")
    parser.add_argument("--stop-presence-refresher", action="store_true")
    args = parser.parse_args()
    assert_development_only()
    if args.stop_presence_refresher:
        return stop_presence_refresher()
    if args.refresh_presence:
        return refresh_presence()
    with SessionLocal() as db:
        for name in args.only or list(STEPS):
            print(f"== {name}{' (dry run)' if args.dry_run else ''}")
            for line in STEPS[name](db, dry_run=args.dry_run):
                print("  " + line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
