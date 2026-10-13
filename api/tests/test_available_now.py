""""Available now": a photographer who can shoot within the next day, at short
notice, while their app is open.

Turning it on lowers the notice for the next 24 hours to the photographer's
preparation time - for packages flagged as fine at short notice - and nothing
else. It is one value inside the one rule every path asks (bookable_time), so
the calendar, the request, accepting, confirming a slot, the check before
payment and the sweep cannot disagree; working hours, blocked time, existing
bookings, holds, buffers and the daily limit all still apply.

It counts only while it is switched on (available_until in the future,
persisted) AND the app has checked in within the last two minutes: the
platform cannot reach a photographer whose app is closed, so it must not
offer them at two hours' notice. A short-notice request is answered and paid
on a short clock - 30 minutes each, settings - capped by the shoot's start,
and keeps those terms if the toggle changes afterwards.
"""
import json
import time
import uuid
from datetime import datetime, time as dtime, timedelta, timezone
from zoneinfo import ZoneInfo

import pytest
from app.core.config import get_settings
from app.models.booking import BookingRequest, BookingRequestStatus, ProBlackoutDate, ProPackage, ProSchedulingPolicy
from app.models.gig import Gig, GigStatus
from app.services.cache import get_redis_client
from sqlalchemy import select

from tests.test_bookable_time import TZ, _no_stripe, _paid_gig, _pay, _pro, _request, _second_client  # noqa: F401 - _no_stripe is autouse
from tests.live_pro import make_live

ALL_DAY = tuple((day, dtime(0, 0), dtime(23, 59)) for day in range(7))


@pytest.fixture(autouse=True)
def _no_presence_left_over():
    redis = get_redis_client()
    for pattern in ("presence:pro:*", "available:pro:*"):
        for key in redis.scan_iter(match=pattern):
            redis.delete(key)
    yield


def _short_notice_pro(db_session, *, flagged=True, notice_hours=24, max_per_day=None, buffer=15):
    pro = _pro(db_session, rules=ALL_DAY, notice_hours=notice_hours, max_per_day=max_per_day, buffer=buffer)
    make_live(db_session, pro.id)
    package = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    package.short_notice_ok = flagged
    db_session.commit()
    return pro


def _seen(pro, seconds_ago=0):
    """A heartbeat `seconds_ago`, as the presence key holds it."""
    get_redis_client().set(
        f"presence:pro:{pro.uuid}", json.dumps({"ts": time.time() - seconds_ago, "visible": True}), ex=300
    )


def _toggle(client, pro, on=True):
    return client.put("/v1/pro/available-now", headers={"X-User-Id": pro.id}, json={"switched_on": on})


def _available(client, db_session, pro):
    _seen(pro)
    resp = _toggle(client, pro)
    assert resp.status_code == 200, resp.text
    return resp.json()


def _slot_in(hours: int):
    """A one-hour slot on the hour, about `hours` ahead, inside one local
    day - the all-day rule ends at 23:59, so 23:00 is moved to midnight."""
    tz = ZoneInfo(TZ)
    start = (datetime.now(timezone.utc) + timedelta(hours=hours)).astimezone(tz)
    start = start.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)
    if start.hour == 23:
        start += timedelta(hours=1)
    return start.astimezone(timezone.utc), (start + timedelta(hours=1)).astimezone(timezone.utc)


def _offered(client, pro, start) -> bool:
    day = start.astimezone(ZoneInfo(TZ)).date()
    resp = client.get(
        f"/v1/client/pros/{pro.id}/availability",
        params={"package_id": pro.package_id, "from": day.isoformat(), "to": day.isoformat()},
        headers={"X-User-Id": pro.client_id},
    )
    assert resp.status_code == 200, resp.text
    return any(
        datetime.fromisoformat(s["start_at"]).astimezone(timezone.utc) == start
        for d in resp.json()["days"]
        for s in d["start_times"]
    )


def _booking(db_session, booking_id) -> BookingRequest:
    db_session.expire_all()
    return db_session.get(BookingRequest, uuid.UUID(booking_id))


def _gig_for(db_session, booking_id) -> Gig:
    db_session.expire_all()
    return db_session.execute(select(Gig).where(Gig.meta["booking_request_id"].astext == booking_id)).scalar_one()


# --- what "available now" is -------------------------------------------------------


def test_switched_on_and_seen_in_the_last_two_minutes_is_available(client, db_session):
    pro = _short_notice_pro(db_session)

    body = _available(client, db_session, pro)

    assert body["effective"] is True
    policy = db_session.get(ProSchedulingPolicy, pro.uuid)
    db_session.refresh(policy)
    assert policy.available_until is not None, "the column is the source of truth"


def test_switched_on_but_not_seen_for_over_two_minutes_is_not(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    _seen(pro, seconds_ago=150)  # still online for the dot (5 min), not for this

    start, _ = _slot_in(3)
    assert client.get("/v1/pro/available-now", headers={"X-User-Id": pro.id}).json()["effective"] is False
    assert _offered(client, pro, start) is False


def test_it_switches_itself_off_after_the_set_number_of_hours(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    policy = db_session.get(ProSchedulingPolicy, pro.uuid)
    db_session.refresh(policy)
    hours = get_settings().available_now_hours

    assert timedelta(hours=hours) - timedelta(minutes=1) <= policy.available_until - datetime.now(timezone.utc) <= timedelta(hours=hours)
    policy.available_until = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()
    _seen(pro)

    assert client.get("/v1/pro/available-now", headers={"X-User-Id": pro.id}).json()["effective"] is False


def test_the_redis_copy_is_only_a_copy(client, db_session):
    """Losing it changes nothing about who may be booked at short notice."""
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    get_redis_client().delete(f"available:pro:{pro.uuid}")
    start, _ = _slot_in(3)

    assert _offered(client, pro, start) is True


def test_no_dead_toggle_without_a_short_notice_package(client, db_session):
    pro = _short_notice_pro(db_session, flagged=False)
    _seen(pro)

    resp = _toggle(client, pro)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "no_short_notice_packages"
    db_session.expire_all()
    assert db_session.get(ProSchedulingPolicy, pro.uuid).available_until is None


def test_only_a_photographer_can_switch_it(client, db_session):
    pro = _short_notice_pro(db_session)

    assert client.put("/v1/pro/available-now", headers={"X-User-Id": pro.client_id}, json={"switched_on": True}).status_code == 403


# --- the six paths agree ------------------------------------------------------------


def test_a_slot_three_hours_away_is_offered_requested_accepted_and_paid_when_available(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)

    assert _offered(client, pro, start) is True  # 1. the calendar
    resp = _request(client, pro, pro.client_id, start, end)  # 2. the request
    assert resp.status_code == 200, resp.text
    booking_id = resp.json()["booking_id"]
    accepted = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    assert accepted.status_code == 200, accepted.text  # 3. accepting
    assert _pay(client, pro, booking_id).status_code == 200  # 5. before payment


def test_the_same_slot_is_refused_by_calendar_and_request_when_switched_off(client, db_session):
    pro = _short_notice_pro(db_session)
    _seen(pro)
    start, end = _slot_in(3)

    assert _offered(client, pro, start) is False
    resp = _request(client, pro, pro.client_id, start, end)
    assert resp.status_code == 409, resp.text
    assert "notice" in resp.json()["error"]["message"]


def test_the_same_slot_is_refused_by_both_when_the_app_has_gone_quiet(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    _seen(pro, seconds_ago=150)
    start, end = _slot_in(3)

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


def test_a_short_notice_slot_can_be_confirmed(client, db_session):  # 4. confirming a slot
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    # Confirmed on the terms it was requested on, as accepting is - not
    # whatever the toggle says by the time the photographer answers.
    assert _toggle(client, pro, on=False).status_code == 200

    resp = client.post(
        f"/v1/pro/bookings/{booking_id}/confirm-slot",
        headers={"X-User-Id": pro.id},
        json={"start_at_utc": start.isoformat(), "end_at_utc": end.isoformat()},
    )

    assert resp.status_code == 200, resp.text


def test_a_package_not_flagged_is_never_offered_inside_normal_notice(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    package = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    package.short_notice_ok = False
    db_session.commit()
    start, end = _slot_in(3)

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


def test_short_notice_covers_only_the_next_24_hours(client, db_session):
    pro = _short_notice_pro(db_session, notice_hours=48)
    _available(client, db_session, pro)
    start, end = _slot_in(30)  # beyond the 24 hours, inside the usual 48h notice

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


def test_preparation_time_is_still_notice(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)  # prep 2h by default
    start, end = _slot_in(0)  # within the hour: less than the preparation time

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


# --- what short notice never bypasses ----------------------------------------------


def test_short_notice_does_not_bypass_blocked_time(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    db_session.add(ProBlackoutDate(pro_user_id=pro.uuid, start_at=start - timedelta(minutes=30), end_at=end, reason="dentist"))
    db_session.commit()

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


def test_short_notice_does_not_bypass_an_existing_booking_or_its_buffer(client, db_session):
    pro = _short_notice_pro(db_session, buffer=30)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    _paid_gig(db_session, pro, end + timedelta(minutes=15), end + timedelta(minutes=75))  # inside the buffer

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


def test_short_notice_does_not_bypass_another_clients_hold(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    assert _request(client, pro, pro.client_id, start, end).status_code == 200

    assert _offered(client, pro, start) is False
    assert _request(client, pro, _second_client(db_session), start, end).status_code == 409


def test_short_notice_does_not_bypass_the_daily_limit(client, db_session):
    pro = _short_notice_pro(db_session, max_per_day=1)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    day_start = start.astimezone(ZoneInfo(TZ)).replace(hour=0, minute=0)
    _paid_gig(db_session, pro, day_start.astimezone(timezone.utc), (day_start + timedelta(hours=1)).astimezone(timezone.utc))

    assert _offered(client, pro, start) is False
    assert _request(client, pro, pro.client_id, start, end).status_code == 409


# --- deadlines ---------------------------------------------------------------------


def test_a_short_notice_request_has_30_minutes_to_be_accepted(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    before = datetime.now(timezone.utc)

    booking = _booking(db_session, _request(client, pro, pro.client_id, start, end).json()["booking_id"])

    assert booking.short_notice is True
    assert timedelta(minutes=29) <= booking.expires_at - before <= timedelta(minutes=31)


def test_an_ordinary_request_keeps_its_24_hours(client, db_session):
    pro = _short_notice_pro(db_session, notice_hours=24)
    _available(client, db_session, pro)
    start, end = _slot_in(72)
    before = datetime.now(timezone.utc)

    booking = _booking(db_session, _request(client, pro, pro.client_id, start, end).json()["booking_id"])

    assert booking.short_notice is False
    assert timedelta(hours=23, minutes=59) <= booking.expires_at - before <= timedelta(hours=24, minutes=1)


def test_the_accept_deadline_never_runs_past_the_start(db_session):
    from app.services.deadlines import accept_deadline

    now = datetime.now(timezone.utc)
    start = now + timedelta(minutes=20)

    assert accept_deadline(now=now, start=start, short_notice=True) == start
    assert accept_deadline(now=now, start=now + timedelta(hours=10), short_notice=False) == now + timedelta(hours=10)


def test_the_pay_deadline_is_short_and_leaves_a_margin_before_the_start(db_session):
    from app.services.deadlines import pay_deadline

    settings = get_settings()
    now = datetime.now(timezone.utc)
    far = now + timedelta(days=5)
    near = now + timedelta(minutes=70)

    assert pay_deadline(accepted_at=now, start=far, short_notice=True) == now + timedelta(minutes=settings.short_notice_pay_minutes)
    assert pay_deadline(accepted_at=now, start=far, short_notice=False) == now + timedelta(hours=settings.payment_window_hours)
    assert pay_deadline(accepted_at=now, start=near, short_notice=True) == near - timedelta(minutes=settings.pay_deadline_margin_minutes)


def test_every_way_of_making_a_request_uses_the_one_deadline(client, db_session, monkeypatch):
    """The three hard-coded 24 hours - client funnel, pro-side request,
    request from chat - now all ask deadlines.accept_deadline."""
    import app.services.deadlines as deadlines

    calls = []
    real = deadlines.accept_deadline
    monkeypatch.setattr(deadlines, "accept_deadline", lambda **kw: calls.append(kw) or real(**kw))
    pro = _short_notice_pro(db_session)
    start, end = _slot_in(72)
    assert _request(client, pro, pro.client_id, start, end).status_code == 200
    second = _second_client(db_session)
    resp = client.post(
        f"/v1/pros/{pro.id}/booking-requests",
        headers={"X-User-Id": second},
        json={"package_id": pro.package_id, "requested_start": (start + timedelta(hours=2)).isoformat(), "requested_end": (end + timedelta(hours=2)).isoformat()},
    )
    assert resp.status_code == 200, resp.text

    assert len(calls) == 2
    import inspect

    import app.api.v1.chats as chats
    import app.api.v1.client_launch as client_launch
    import app.api.v1.pro_onboarding as pro_onboarding

    # The chat path is hard to drive end to end; it goes through the same
    # helper, and no request-making code keeps its own 24 hours.
    assert "apply_request_terms(request, terms)" in inspect.getsource(chats._create_booking_request_from_body)
    for function in (chats._create_booking_request_from_body, client_launch.client_booking_request, pro_onboarding.create_booking_request):
        assert "hours=24" not in inspect.getsource(function), function.__name__


def test_the_terms_stay_when_the_toggle_changes(client, db_session):
    """Accepted and paid on the short clock it was requested on, whatever
    the photographer does with the toggle meanwhile."""
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    assert _toggle(client, pro, on=False).status_code == 200

    accepted = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})

    assert accepted.status_code == 200, accepted.text
    gig = _gig_for(db_session, booking_id)
    assert gig.pay_deadline_at - datetime.now(timezone.utc) <= timedelta(minutes=31), "the short pay window it was made under"


def _client_sees(client, pro, booking_id) -> tuple[dict, dict]:
    headers = {"X-User-Id": pro.client_id}
    detail = client.get(f"/v1/client/bookings/{booking_id}", headers=headers)
    listing = client.get("/v1/client/bookings", headers=headers)
    assert detail.status_code == 200 and listing.status_code == 200, (detail.text, listing.text)
    [row] = [i for i in listing.json()["items"] if i["booking_id"] == booking_id]
    return detail.json(), row


@pytest.mark.parametrize("short", [True, False], ids=["short notice", "ordinary"])
def test_the_client_is_told_the_terms_they_booked_on(client, db_session, short):
    """The client's screens wait on a short clock only for a short-notice
    request - and are told when they have to pay by, from the same deadline
    the pay route enforces."""
    pro = _short_notice_pro(db_session)
    if short:
        _available(client, db_session, pro)
    start, end = _slot_in(3 if short else 30)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]

    for view in _client_sees(client, pro, booking_id):
        assert view["short_notice"] is short
        assert view["pay_by"] is None, "nothing to pay before it is accepted"
    request_window = _booking(db_session, booking_id).expires_at - _booking(db_session, booking_id).created_at
    assert (request_window <= timedelta(minutes=30)) is short

    client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    gig = _gig_for(db_session, booking_id)
    for view in _client_sees(client, pro, booking_id):
        assert view["short_notice"] is short
        assert datetime.fromisoformat(view["pay_by"]) == gig.pay_deadline_at
    assert (gig.pay_deadline_at - gig.created_at <= timedelta(minutes=30)) is short


@pytest.mark.parametrize("answer", ["accept", "confirm-slot"])
def test_notice_is_counted_from_when_the_request_was_made(client, db_session, answer):
    """Seven hours ago a client asked for a slot 30 hours ahead - inside the
    photographer's 24 hours' notice. The slot is now 23 hours away. It was
    a valid request and stays answerable; judging notice from the moment of
    answering would refuse a request that did nothing wrong."""
    pro = _short_notice_pro(db_session)
    made_for, _ = _slot_in(30)
    booking_id = _request(client, pro, pro.client_id, made_for, made_for + timedelta(hours=1)).json()["booking_id"]
    start, end = _slot_in(23)
    booking = _booking(db_session, booking_id)
    booking.requested_start, booking.requested_end = start, end
    booking.created_at = start - timedelta(hours=30)  # asked 30 hours ahead
    db_session.commit()
    assert booking.short_notice is False and booking.notice_minutes == 24 * 60

    if answer == "accept":
        resp = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    else:
        resp = client.post(
            f"/v1/pro/bookings/{booking_id}/confirm-slot",
            headers={"X-User-Id": pro.id},
            json={"start_at_utc": start.isoformat(), "end_at_utc": end.isoformat()},
        )

    assert resp.status_code == 200, resp.text


def test_paying_after_the_short_window_is_refused_even_before_the_sweep(client, db_session):
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    gig = _gig_for(db_session, booking_id)
    gig.pay_deadline_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()

    resp = _pay(client, pro, booking_id)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "payment_window_closed"


def test_accepting_too_late_to_pay_in_time_is_refused(client, db_session, monkeypatch):
    """If the pay deadline - capped a margin before the start - has already
    passed, a yes would make a booking nobody can complete."""
    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    # Payment must land further ahead of the start than the start is away.
    monkeypatch.setattr(get_settings(), "pay_deadline_margin_minutes", 6 * 60)

    resp = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "too_late_to_pay"


# --- the sweep (6) -----------------------------------------------------------------


def test_an_unanswered_short_notice_request_expires_on_its_short_clock_and_frees_its_time(client, db_session):
    from app.services.scheduling import expire_pending_booking_requests

    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    booking = _booking(db_session, booking_id)
    booking.expires_at = datetime.now(timezone.utc) - timedelta(seconds=1)  # its 30 minutes are up
    db_session.commit()

    assert _offered(client, pro, start) is True, "freed at once, before any sweep"
    expire_pending_booking_requests(db_session, limit=None)
    db_session.commit()
    assert _booking(db_session, booking_id).status == BookingRequestStatus.expired


def test_an_unpaid_short_notice_booking_is_cancelled_after_its_pay_deadline(client, db_session, monkeypatch):
    from app.services.bookable_time import expire_unpaid_gigs

    # Its open payment is closed with Stripe first, as for any unpaid gig.
    monkeypatch.setattr("app.services.bookable_time.stripe.PaymentIntent.cancel", lambda pi_id: None)

    pro = _short_notice_pro(db_session)
    _available(client, db_session, pro)
    start, end = _slot_in(3)
    booking_id = _request(client, pro, pro.client_id, start, end).json()["booking_id"]
    client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    gig = _gig_for(db_session, booking_id)
    assert _offered(client, pro, start) is False, "held while it may still be paid"
    gig.pay_deadline_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    db_session.commit()

    assert _offered(client, pro, start) is True, "freed the moment its deadline passes"
    expire_unpaid_gigs(db_session, limit=None)
    db_session.commit()
    assert _gig_for(db_session, booking_id).status != GigStatus.payment_pending


# --- what the client sees -------------------------------------------------------------


def test_the_calendar_is_never_served_stale_across_a_toggle(client, db_session):
    pro = _short_notice_pro(db_session)
    _seen(pro)
    start, _ = _slot_in(3)
    assert _offered(client, pro, start) is False

    _toggle(client, pro, on=True)
    assert _offered(client, pro, start) is True
    _toggle(client, pro, on=False)
    assert _offered(client, pro, start) is False
