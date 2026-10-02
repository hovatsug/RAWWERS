"""When a photographer can be booked - one answer, everywhere.

Six places used to decide this and no two agreed. The client's booking
request refused only a window wholly inside blocked time, so it took a 3am
Sunday booking from someone who does not work Sundays. The slot list read one
of the two blocked-time tables and ignored the per-day cap. Confirming a slot
read the other table's absence the same way. Accepting a request used the
lenient check again.

The matrix below is the proof they now agree: for each reason a time can be
unbookable, every entry point is asked about the same time and must refuse
it - and for a time that is fine, every entry point must accept it. An entry
point that kept its own copy of the rules fails somewhere in the matrix.
"""
import uuid
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta, timezone
from decimal import Decimal

import pytest

from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    ConfirmedSlot,
    ProAvailabilityException,
    ProAvailabilityRule,
    ProBlackoutDate,
    ProPackage,
    ProSchedulingPolicy,
)
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche

from tests.test_client_launch import _enable_city_and_flags, _seed_pro, _seed_user

TZ = "Europe/Lisbon"


@pytest.fixture(autouse=True)
def _no_stripe(monkeypatch):
    """Accepting a request creates a PaymentIntent. Stubbed the way
    test_pro_onboarding_booking does, so an accepted request reads as 200
    rather than as a network error."""
    from types import SimpleNamespace

    def fake(pi_id="pi_test"):
        return SimpleNamespace(id=pi_id, client_secret=f"{pi_id}_secret", status="requires_payment_method", amount=12000, currency="eur", metadata={})

    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.create", lambda **kwargs: fake(f"pi_{uuid.uuid4().hex[:8]}"))
    monkeypatch.setattr("app.services.payment_intents.stripe.PaymentIntent.retrieve", lambda pi_id: fake(pi_id))


def _future_weekday(weekday: int, weeks_out: int = 3) -> date:
    """Far enough out that notice never decides a test that is not about it."""
    base = datetime.now(timezone.utc).date() + timedelta(weeks=weeks_out)
    return base + timedelta(days=(weekday - base.weekday()) % 7)


def _utc(day: date, hour: int, minute: int = 0, tz: str = TZ) -> datetime:
    from zoneinfo import ZoneInfo

    return datetime.combine(day, time(hour, minute), tzinfo=ZoneInfo(tz)).astimezone(timezone.utc)


@dataclass
class Pro:
    id: str
    uuid: uuid.UUID
    package_id: str
    client_id: str


def _pro(db_session, *, rules=((0, time(9), time(18)),), notice_hours=24, max_per_day=None, buffer=15) -> Pro:
    """A live photographer in Lisbon with one 60-minute package."""
    _enable_city_and_flags(db_session)
    pro_id = str(uuid.uuid4())
    pro_uuid = _seed_pro(db_session, pro_id)
    for weekday, start, end in rules:
        db_session.add(
            ProAvailabilityRule(
                pro_user_id=pro_uuid, day_of_week=weekday, start_time=start, end_time=end, timezone=TZ, location_mode="both"
            )
        )
    db_session.add(
        ProSchedulingPolicy(
            pro_user_id=pro_uuid,
            slot_length_minutes=60,
            buffer_before_minutes=buffer,
            buffer_after_minutes=buffer,
            advance_notice_hours=notice_hours,
            max_bookings_per_day=max_per_day,
        )
    )
    db_session.commit()
    package_id = str(db_session.query(ProPackage).filter_by(pro_user_id=pro_uuid).first().id)
    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, [UserRoleType.client])
    return Pro(id=pro_id, uuid=pro_uuid, package_id=package_id, client_id=client_id)


def _paid_gig(db_session, pro: Pro, start: datetime, end: datetime, *, status=GigStatus.paid, with_slot=False) -> Gig:
    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    other_client = uuid.uuid4()
    db_session.add(UserAccount(user_id=other_client))
    db_session.commit()
    gig = Gig(
        client_user_id=other_client,
        pro_user_id=pro.uuid,
        niche_id=niche.id,
        status=status,
        currency="EUR",
        amount_minimum=Decimal("120.00"),
        amount_platform_fee=Decimal("24.00"),
        amount_pro_gross=Decimal("96.00"),
        scheduled_start=start,
        scheduled_end=end,
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    if with_slot:
        db_session.add(
            ConfirmedSlot(
                gig_id=gig.id,
                pro_user_id=pro.uuid,
                client_user_id=other_client,
                start_at_utc=start,
                end_at_utc=end,
                status="confirmed",
            )
        )
    db_session.commit()
    return gig


# ---------------------------------------------------------------------------
# Every entry point, asked about one [start, end).
# ---------------------------------------------------------------------------


def _via_client_request(client, db_session, pro: Pro, start, end) -> bool:
    resp = client.post(
        "/v1/client/bookings/request",
        headers={"X-User-Id": pro.client_id},
        json={
            "pro_user_id": pro.id,
            "niche_slug": "portraits",
            "date_window": {"start_at": start.isoformat(), "end_at": end.isoformat()},
            "location": "Lisbon",
            "package_id": pro.package_id,
        },
    )
    assert resp.status_code in (200, 409), resp.text
    return resp.status_code == 200


def _via_accept(client, db_session, pro: Pro, start, end) -> bool:
    booking = BookingRequest(
        pro_user_id=pro.uuid,
        client_user_id=uuid.UUID(pro.client_id),
        package_id=uuid.UUID(pro.package_id),
        requested_start=start,
        requested_end=end,
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
    )
    db_session.add(booking)
    db_session.commit()
    resp = client.post(f"/v1/booking-requests/{booking.id}/accept", headers={"X-User-Id": pro.id})
    assert resp.status_code in (200, 409), resp.text
    return resp.status_code == 200


def _via_pro_side_request(client, db_session, pro: Pro, start, end) -> bool:
    from app.api.v1.pro_onboarding import _validate_availability

    try:
        _validate_availability(db_session, pro.uuid, start, end)
        return True
    except APIError:
        return False


def _via_confirm_check(client, db_session, pro: Pro, start, end) -> bool:
    from app.services.scheduling import validate_slot_available

    try:
        validate_slot_available(db_session, pro_user_id=pro.uuid, start_at_utc=start, end_at_utc=end)
        return True
    except APIError:
        return False


def _via_pro_slot_list(client, db_session, pro: Pro, start, end) -> bool:
    resp = client.get(
        "/v1/pro/scheduling/slots",
        params={"from": (start.date() - timedelta(days=1)).isoformat(), "to": (end.date() + timedelta(days=1)).isoformat()},
        headers={"X-User-Id": pro.id},
    )
    assert resp.status_code == 200, resp.text
    starts = {datetime.fromisoformat(s["start_at_utc"]) for s in resp.json()["slots"]}
    return start in starts


def _via_client_calendar(client, db_session, pro: Pro, start, end) -> bool:
    # The calendar refuses a range starting in the past, so a time a few
    # hours away is asked about from today.
    today = datetime.now(timezone.utc).date()
    resp = client.get(
        f"/v1/client/pros/{pro.id}/availability",
        params={
            "package_id": pro.package_id,
            "from": max(today, start.date() - timedelta(days=1)).isoformat(),
            "to": (end.date() + timedelta(days=1)).isoformat(),
        },
        headers={"X-User-Id": pro.client_id},
    )
    assert resp.status_code == 200, resp.text
    starts = {datetime.fromisoformat(t["start_at"]) for day in resp.json()["days"] for t in day["start_times"]}
    return start in starts


ENTRY_POINTS = {
    "client booking request": _via_client_request,
    "pro accepting a request": _via_accept,
    "chat / pro-side request": _via_pro_side_request,
    "confirming a slot": _via_confirm_check,
    "the pro's slot list": _via_pro_slot_list,
    "the client calendar": _via_client_calendar,
}


# Each case: how to set up the photographer, and the hour asked about.
MONDAY = 0


def _fine(db_session, pro, day):
    return _utc(day, 10)


def _outside_hours(db_session, pro, day):
    return _utc(day, 20)  # works 09-18


def _a_day_off(db_session, pro, day):
    return _utc(day + timedelta(days=6), 3)  # the 3am Sunday


def _too_soon(db_session, pro, day):
    # Tomorrow's Monday-equivalent: inside the 24h notice. Rules cover every
    # day for this case so only notice can refuse it.
    soon = datetime.now(timezone.utc) + timedelta(hours=3)
    return soon.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)


def _in_an_exception(db_session, pro, day):
    db_session.add(ProAvailabilityException(pro_user_id=pro.uuid, start_at_utc=_utc(day, 9), end_at_utc=_utc(day, 12), reason="dentist"))
    db_session.commit()
    return _utc(day, 10)


def _in_a_legacy_blackout(db_session, pro, day):
    db_session.add(ProBlackoutDate(pro_user_id=pro.uuid, start_at=_utc(day, 9), end_at=_utc(day, 12), reason="dentist"))
    db_session.commit()
    return _utc(day, 10)


def _partly_blocked(db_session, pro, day):
    # Only the last half hour of the slot is blocked. Not "fully blocked",
    # which is all the client request used to check.
    db_session.add(ProAvailabilityException(pro_user_id=pro.uuid, start_at_utc=_utc(day, 10, 30), end_at_utc=_utc(day, 12)))
    db_session.commit()
    return _utc(day, 10)


def _clashes_with_a_confirmed_slot(db_session, pro, day):
    _paid_gig(db_session, pro, _utc(day, 10), _utc(day, 11), with_slot=True)
    return _utc(day, 10)


def _inside_a_bookings_buffer(db_session, pro, day):
    # A shoot ending at 10:00, and 15 minutes of buffer after it.
    _paid_gig(db_session, pro, _utc(day, 9), _utc(day, 10), with_slot=True)
    return _utc(day, 10)


def _clashes_with_a_paid_gig_without_a_slot(db_session, pro, day):
    # Accepting a request writes the gig's time but no confirmed slot. A paid
    # gig still holds its date - the client app says as much.
    _paid_gig(db_session, pro, _utc(day, 10), _utc(day, 11))
    return _utc(day, 10)


def _other_client(db_session) -> uuid.UUID:
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid))
    db_session.commit()
    return uid


def _pending_request_from_another_client(db_session, pro, day):
    # First come, first served: a request holds its time while it waits for
    # the photographer, and requests already expire on their own.
    db_session.add(
        BookingRequest(
            pro_user_id=pro.uuid,
            client_user_id=_other_client(db_session),
            package_id=uuid.UUID(pro.package_id),
            requested_start=_utc(day, 10),
            requested_end=_utc(day, 11),
            status=BookingRequestStatus.pending,
            expires_at=datetime.now(timezone.utc) + timedelta(hours=20),
        )
    )
    db_session.commit()
    return _utc(day, 10)


def _expired_pending_request(db_session, pro, day):
    # Past its reply deadline but not yet swept: it holds nothing.
    db_session.add(
        BookingRequest(
            pro_user_id=pro.uuid,
            client_user_id=_other_client(db_session),
            package_id=uuid.UUID(pro.package_id),
            requested_start=_utc(day, 10),
            requested_end=_utc(day, 11),
            status=BookingRequestStatus.pending,
            expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
        )
    )
    db_session.commit()
    return _utc(day, 10)


def _accepted_unpaid_gig(db_session, pro, day):
    # Accepted an hour ago, inside its 24 hours to pay.
    gig = _paid_gig(db_session, pro, _utc(day, 10), _utc(day, 11), status=GigStatus.payment_pending)
    gig.created_at = datetime.now(timezone.utc) - timedelta(hours=1)
    db_session.commit()
    return _utc(day, 10)


def _unpaid_gig_past_its_deadline(db_session, pro, day):
    # Not paid within 24 hours of being accepted: it no longer holds the time,
    # even before the sweep gets to cancel it.
    gig = _paid_gig(db_session, pro, _utc(day, 10), _utc(day, 11), status=GigStatus.payment_pending)
    gig.created_at = datetime.now(timezone.utc) - timedelta(hours=25)
    db_session.commit()
    return _utc(day, 10)


def _day_is_full(db_session, pro, day):
    _paid_gig(db_session, pro, _utc(day, 15), _utc(day, 16), with_slot=True)
    return _utc(day, 10)


CASES = {
    # name: (setup, expected bookable, pro options)
    "a fine time": (_fine, True, {}),
    "outside working hours": (_outside_hours, False, {}),
    "a day they do not work (3am Sunday)": (_a_day_off, False, {}),
    "inside the notice period": (_too_soon, False, {"rules": tuple((d, time(0), time(23, 59)) for d in range(7))}),
    "inside a scheduling exception": (_in_an_exception, False, {}),
    "inside a deprecated blackout": (_in_a_legacy_blackout, False, {}),
    "partly blocked": (_partly_blocked, False, {}),
    "clashing with a confirmed slot": (_clashes_with_a_confirmed_slot, False, {}),
    "inside another booking's buffer": (_inside_a_bookings_buffer, False, {}),
    "clashing with a paid gig that has no slot": (_clashes_with_a_paid_gig_without_a_slot, False, {}),
    "a day already at its booking limit": (_day_is_full, False, {"max_per_day": 1}),
    "held by another client's pending request": (_pending_request_from_another_client, False, {}),
    "after that request has expired": (_expired_pending_request, True, {}),
    "held by an accepted, unpaid gig": (_accepted_unpaid_gig, False, {}),
    "after the unpaid gig's 24 hours": (_unpaid_gig_past_its_deadline, True, {}),
}


@pytest.mark.parametrize("entry", list(ENTRY_POINTS))
@pytest.mark.parametrize("case", list(CASES))
def test_every_entry_point_gives_the_same_answer(client, db_session, case, entry):
    setup, expected, options = CASES[case]
    pro = _pro(db_session, **options)
    day = _future_weekday(MONDAY)
    start = setup(db_session, pro, day)
    end = start + timedelta(hours=1)

    got = ENTRY_POINTS[entry](client, db_session, pro, start, end)
    assert got is expected, f"{entry} said {'bookable' if got else 'not bookable'} for {case}"


# ---------------------------------------------------------------------------
# Overnight shifts, seen from the client calendar.
# ---------------------------------------------------------------------------


def _calendar(client, pro: Pro, start: date, end: date, *, user=None, package_id=None):
    return client.get(
        f"/v1/client/pros/{pro.id}/availability",
        params={"package_id": package_id or pro.package_id, "from": start.isoformat(), "to": end.isoformat()},
        headers={"X-User-Id": user or pro.client_id},
    )


def test_a_night_shift_opens_the_small_hours_of_the_next_day(client, db_session):
    """Friday 20:00-02:00 owns Saturday 00:00-02:00. Asked for Saturday alone,
    the calendar has to look back at Friday's rule - which the slot generator
    used not to, so a range starting on Saturday lost those hours."""
    friday = 4
    pro = _pro(db_session, rules=((friday, time(20), time(2)),))
    saturday = _future_weekday(friday) + timedelta(days=1)

    days = {d["date"]: d for d in _calendar(client, pro, saturday, saturday).json()["days"]}
    starts = days[saturday.isoformat()]["start_times"]
    assert [datetime.fromisoformat(t["start_at"]) for t in starts] == [_utc(saturday, 0), _utc(saturday, 1)]
    # Read in the photographer's own time, not UTC and not the viewer's.
    assert [t["local_time"] for t in starts] == ["00:00", "01:00"]
    assert starts[0]["start_at"].endswith(("+00:00", "+01:00")), "the instant carries the photographer's offset"


def test_a_long_package_only_starts_where_the_whole_shoot_fits(client, db_session):
    pro = _pro(db_session)  # Monday 09-18
    db_session.query(ProPackage).filter_by(id=uuid.UUID(pro.package_id)).update({"duration_minutes": 180})
    db_session.commit()
    monday = _future_weekday(MONDAY)

    day = {d["date"]: d for d in _calendar(client, pro, monday, monday).json()["days"]}[monday.isoformat()]
    local = [t["local_time"] for t in day["start_times"]]
    assert local[0] == "09:00" and local[-1] == "15:00", "a 3-hour shoot cannot start after 15:00 in a 09-18 day"


# ---------------------------------------------------------------------------
# The calendar endpoint itself.
# ---------------------------------------------------------------------------


def test_the_calendar_says_what_it_needs_to_and_nothing_more(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    db_session.add(ProAvailabilityException(pro_user_id=pro.uuid, start_at_utc=_utc(monday, 12), end_at_utc=_utc(monday, 13), reason="PRIVATE-hospital"))
    db_session.commit()
    _paid_gig(db_session, pro, _utc(monday, 15), _utc(monday, 16), with_slot=True)

    resp = _calendar(client, pro, monday, monday + timedelta(days=6))
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["timezone"] == TZ
    assert body["has_schedule"] is True
    assert body["notice_hours"] == 24
    assert [d["date"] for d in body["days"]] == [(monday + timedelta(days=i)).isoformat() for i in range(7)]
    assert all(set(d) == {"date", "open", "start_times"} for d in body["days"])
    assert "PRIVATE" not in resp.text, "a blocked-time reason reached a client"
    for forbidden in ("reason", "exception", "blackout", "gig", "client_user_id", "end_at"):
        assert forbidden not in resp.text, f"{forbidden} leaked into the calendar"


def test_a_day_with_no_start_times_is_closed(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    days = {d["date"]: d for d in _calendar(client, pro, monday, monday + timedelta(days=1)).json()["days"]}
    assert days[monday.isoformat()]["open"] is True
    assert days[(monday + timedelta(days=1)).isoformat()] == {
        "date": (monday + timedelta(days=1)).isoformat(),
        "open": False,
        "start_times": [],
    }


def test_no_working_hours_yet_is_said_plainly(client, db_session):
    pro = _pro(db_session, rules=())
    monday = _future_weekday(MONDAY)
    body = _calendar(client, pro, monday, monday).json()
    assert body["has_schedule"] is False
    assert all(not d["open"] for d in body["days"])


def test_the_calendar_needs_a_signed_in_user(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    resp = client.get(
        f"/v1/client/pros/{pro.id}/availability",
        params={"package_id": pro.package_id, "from": monday.isoformat(), "to": monday.isoformat()},
    )
    assert resp.status_code == 401


def test_a_photographer_who_is_not_live_has_no_calendar(client, db_session):
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    pro = _pro(db_session)
    db_session.get(ProOnboarding, pro.uuid).status = ProOnboardingStatus.ready_for_review
    db_session.commit()
    monday = _future_weekday(MONDAY)
    assert _calendar(client, pro, monday, monday).status_code == 404


def test_the_package_must_be_theirs(client, db_session):
    pro = _pro(db_session)
    other = _pro(db_session)
    monday = _future_weekday(MONDAY)
    assert _calendar(client, pro, monday, monday, package_id=other.package_id).status_code == 404


@pytest.mark.parametrize(
    "offset_from,offset_to,reason",
    [
        (-1, 0, "starts in the past"),
        (0, 62, "more than 62 days at once"),
        (80, 95, "beyond the 90-day horizon"),
        (5, 4, "ends before it starts"),
    ],
)
def test_the_range_is_bounded(client, db_session, offset_from, offset_to, reason):
    pro = _pro(db_session)
    today = datetime.now(timezone.utc).date()
    resp = _calendar(client, pro, today + timedelta(days=offset_from), today + timedelta(days=offset_to))
    assert resp.status_code == 422, f"{reason}: {resp.text}"


def test_the_old_public_availability_route_is_gone(client, db_session):
    """It needed no sign-in and returned every blackout's free-text reason,
    from the wrong table, in the wrong timezone. Nothing called it."""
    pro = _pro(db_session)
    db_session.add(ProBlackoutDate(pro_user_id=pro.uuid, start_at=_utc(_future_weekday(0), 9), end_at=_utc(_future_weekday(0), 12), reason="PRIVATE"))
    db_session.commit()
    resp = client.get(f"/v1/pro/{pro.id}/availability")
    assert resp.status_code in (404, 405)
    assert "PRIVATE" not in resp.text


# ---------------------------------------------------------------------------
# A booking does not collide with itself.
# ---------------------------------------------------------------------------


def test_confirming_a_gigs_own_time_is_not_a_clash_with_itself(client, db_session):
    """Paid gigs now hold their time. The gig whose slot is being confirmed
    must not be refused for overlapping its own booking."""
    from app.services.bookable_time import check_bookable

    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    gig = _paid_gig(db_session, pro, _utc(monday, 10), _utc(monday, 11))

    check_bookable(db_session, pro_user_id=pro.uuid, start_at_utc=_utc(monday, 10), end_at_utc=_utc(monday, 11), ignore_gig_id=gig.id)
    with pytest.raises(APIError):
        check_bookable(db_session, pro_user_id=pro.uuid, start_at_utc=_utc(monday, 10), end_at_utc=_utc(monday, 11))


# ---------------------------------------------------------------------------
# Two clients, one hour - the double booking this replaced, end to end.
#
# Reproduced before the fix: both requests went through, the photographer
# accepted both, the calendar kept offering the hour, and both gigs were paid.
# ---------------------------------------------------------------------------


def _request(client, pro: Pro, client_id: str, start, end):
    return client.post(
        "/v1/client/bookings/request",
        headers={"X-User-Id": client_id},
        json={
            "pro_user_id": pro.id,
            "niche_slug": "portraits",
            "date_window": {"start_at": start.isoformat(), "end_at": end.isoformat()},
            "location": "Lisbon",
            "package_id": pro.package_id,
        },
    )


def _second_client(db_session) -> str:
    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, [UserRoleType.client])
    return client_id


def _offered(client, pro: Pro, day: date) -> list[str]:
    return [s["local_time"] for s in _calendar(client, pro, day, day).json()["days"][0]["start_times"]]


def test_a_requested_hour_is_held_from_the_moment_it_is_requested(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    start, end = _utc(monday, 10), _utc(monday, 11)

    assert _request(client, pro, pro.client_id, start, end).status_code == 200
    assert "10:00" not in _offered(client, pro, monday), "the calendar still offers a requested hour"

    second = _request(client, pro, _second_client(db_session), start, end)
    assert second.status_code == 409, "a second client could request a held hour"
    assert "clashes" in second.json()["error"]["message"]


def test_accepting_a_request_does_not_clash_with_itself(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    booking_id = _request(client, pro, pro.client_id, _utc(monday, 10), _utc(monday, 11)).json()["booking_id"]

    resp = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    assert resp.status_code == 200, resp.text
    # Accepted, the hour is now held by the gig instead of the request.
    assert "10:00" not in _offered(client, pro, monday)


def test_a_photographer_cannot_accept_two_requests_for_one_hour(client, db_session):
    """Two requests that both exist - one made before holds were enforced,
    say. Accepting the first leaves the second unacceptable."""
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    ids = []
    for client_id in (pro.client_id, _second_client(db_session)):
        booking = BookingRequest(
            pro_user_id=pro.uuid,
            client_user_id=uuid.UUID(client_id),
            package_id=uuid.UUID(pro.package_id),
            requested_start=_utc(monday, 10),
            requested_end=_utc(monday, 11),
            status=BookingRequestStatus.pending,
            expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
        )
        db_session.add(booking)
        db_session.commit()
        ids.append(booking.id)

    first = client.post(f"/v1/booking-requests/{ids[0]}/accept", headers={"X-User-Id": pro.id})
    second = client.post(f"/v1/booking-requests/{ids[1]}/accept", headers={"X-User-Id": pro.id})
    assert first.status_code == 200, first.text
    assert second.status_code == 409, "two accepted bookings for one hour"


# ---------------------------------------------------------------------------
# The last check before money moves.
# ---------------------------------------------------------------------------


def _accepted_booking(client, db_session, pro: Pro, start, end) -> tuple[str, Gig]:
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    resp = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    assert resp.status_code == 200, resp.text
    gig = db_session.query(Gig).filter(Gig.meta["booking_request_id"].astext == booking_id).one()
    return booking_id, gig


def _pay(client, pro: Pro, booking_id: str):
    return client.post(
        f"/v1/client/bookings/{booking_id}/pay", headers={"X-User-Id": pro.client_id}, json={"payment_mode": "full"}
    )


def test_paying_for_your_own_held_hour_goes_through(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    booking_id, _gig = _accepted_booking(client, db_session, pro, _utc(monday, 10), _utc(monday, 11))
    assert _pay(client, pro, booking_id).status_code == 200, "the booking clashed with itself at payment"


def test_paying_is_refused_if_the_hour_has_been_taken_since(client, db_session, monkeypatch):
    """However it happened - an old double acceptance, a block added since -
    the charge is not started for an hour that is no longer the client's."""
    created = []
    import app.services.payment_intents as pi_module

    real_create = pi_module.stripe.PaymentIntent.create
    monkeypatch.setattr(
        "app.services.payment_intents.stripe.PaymentIntent.create",
        lambda **kw: created.append(kw) or real_create(**kw),
    )
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    booking_id, gig = _accepted_booking(client, db_session, pro, _utc(monday, 10), _utc(monday, 11))
    created.clear()
    # Someone else's paid shoot now overlaps, written straight to the table
    # the way a pre-fix double acceptance left it.
    _paid_gig(db_session, pro, _utc(monday, 10, 30), _utc(monday, 11, 30))

    resp = _pay(client, pro, booking_id)
    assert resp.status_code == 409, resp.text
    assert created == [], "a payment was started for an hour that is no longer theirs"


def test_paying_is_not_refused_for_notice_that_was_met_when_booked(client, db_session):
    """Notice is about when a booking is made. A client who booked with
    enough notice and pays the next morning must not be refused because the
    shoot is now closer than the notice period."""
    pro = _pro(db_session, notice_hours=24)
    monday = _future_weekday(MONDAY)
    booking_id, gig = _accepted_booking(client, db_session, pro, _utc(monday, 10), _utc(monday, 11))
    # Move the shoot to within the notice period, as time passing would.
    soon = datetime.now(timezone.utc) + timedelta(hours=5)
    gig.scheduled_start, gig.scheduled_end = soon, soon + timedelta(hours=1)
    db_session.commit()
    assert _pay(client, pro, booking_id).status_code == 200


def test_paying_after_the_24_hours_is_refused_even_before_the_sweep(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    booking_id, gig = _accepted_booking(client, db_session, pro, _utc(monday, 10), _utc(monday, 11))
    gig.created_at = datetime.now(timezone.utc) - timedelta(hours=25)
    db_session.commit()

    resp = _pay(client, pro, booking_id)
    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "payment_window_closed"


# ---------------------------------------------------------------------------
# The 24 hours to pay.
# ---------------------------------------------------------------------------


def _unpaid(db_session, pro: Pro, *, accepted_hours_ago: float, with_intent: str | None = None) -> Gig:
    from app.models.gig import PaymentStatus, StripePayment, StripePaymentKind

    monday = _future_weekday(MONDAY)
    gig = _paid_gig(db_session, pro, _utc(monday, 10), _utc(monday, 11), status=GigStatus.payment_pending)
    gig.created_at = datetime.now(timezone.utc) - timedelta(hours=accepted_hours_ago)
    if with_intent:
        db_session.add(
            StripePayment(
                gig_id=gig.id,
                client_user_id=gig.client_user_id,
                status=PaymentStatus.pending,
                stripe_payment_intent_id=with_intent,
                amount=gig.amount_minimum,
                currency="EUR",
                kind=StripePaymentKind.base,
                meta={},
            )
        )
    db_session.commit()
    return gig


def test_an_unpaid_gig_is_cancelled_after_24_hours_and_its_payment_closed(db_session, monkeypatch):
    from app.services.bookable_time import expire_unpaid_gigs

    cancelled = []
    monkeypatch.setattr("app.services.bookable_time.stripe.PaymentIntent.cancel", lambda pi_id: cancelled.append(pi_id))
    pro = _pro(db_session)
    late = _unpaid(db_session, pro, accepted_hours_ago=25, with_intent="pi_late")
    fresh = _unpaid(db_session, pro, accepted_hours_ago=2, with_intent="pi_fresh")

    assert expire_unpaid_gigs(db_session) == 1
    db_session.commit()
    db_session.refresh(late)
    db_session.refresh(fresh)
    assert late.status == GigStatus.cancelled_by_client
    assert fresh.status == GigStatus.payment_pending
    assert cancelled == ["pi_late"], "the charge could still go through after the time was released"


def test_a_payment_already_going_through_keeps_its_gig(db_session, monkeypatch):
    """If Stripe will not cancel the payment - it succeeded, or is mid-way -
    the gig is left for the webhook to mark paid. Cancelling it anyway would
    leave a client charged for a booking that no longer exists."""
    import stripe

    from app.services.bookable_time import expire_unpaid_gigs

    def refuse(pi_id):
        raise stripe.InvalidRequestError("This PaymentIntent's status is succeeded", param=None)

    monkeypatch.setattr("app.services.bookable_time.stripe.PaymentIntent.cancel", refuse)
    pro = _pro(db_session)
    gig = _unpaid(db_session, pro, accepted_hours_ago=25, with_intent="pi_paying")

    assert expire_unpaid_gigs(db_session) == 0
    db_session.commit()
    db_session.refresh(gig)
    assert gig.status == GigStatus.payment_pending


def test_an_unpaid_gig_with_no_payment_started_is_cancelled_too(db_session, monkeypatch):
    from app.services.bookable_time import expire_unpaid_gigs

    monkeypatch.setattr("app.services.bookable_time.stripe.PaymentIntent.cancel", lambda pi_id: pytest.fail("nothing to cancel"))
    pro = _pro(db_session)
    gig = _unpaid(db_session, pro, accepted_hours_ago=30)
    assert expire_unpaid_gigs(db_session) == 1
    db_session.commit()
    db_session.refresh(gig)
    assert gig.status == GigStatus.cancelled_by_client
