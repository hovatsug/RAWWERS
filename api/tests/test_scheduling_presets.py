"""Scheduling presets: how a package's bookable times are laid out.

Each package chooses one:

  - interval: step through working hours. No interval means the photographer's
    own slot length - today's hourly behaviour, unchanged for every existing
    package. 240 is the 4-hour preset.
  - blocks: Morning / Afternoon / Evening, with times the photographer sets
    per package. The names are labels; the times are theirs.
  - full_day: the whole date, and nothing else that date.

All of them run through the one rule in bookable_time (notice, working hours,
blocked time, the day's cap, existing bookings and holds), so every booking
path still agrees - the matrix in test_bookable_time covers the paths; these
cover what each preset offers, what it occupies, and that a time it did not
offer cannot be requested.
"""
import uuid
from datetime import date, datetime, time, timedelta, timezone
from zoneinfo import ZoneInfo

import pytest

from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    PackageSessionBlock,
    ProPackage,
    SchedulingPreset,
    SessionBlockLabel,
)
from app.models.gig import GigStatus

from tests.test_bookable_time import (  # noqa: F401 - _no_stripe is an autouse fixture
    MONDAY,
    TZ,
    Pro,
    _calendar,
    _future_weekday,
    _no_stripe,
    _paid_gig,
    _pro,
    _request,
    _second_client,
    _utc,
)


def _set_preset(db_session, pro: Pro, preset: SchedulingPreset, *, interval: int | None = None, blocks=(), duration=None):
    package = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    package.scheduling_preset = preset
    package.interval_minutes = interval
    if duration is not None:
        package.duration_minutes = duration
    db_session.query(PackageSessionBlock).filter_by(package_id=package.id).delete()
    for label, start, end in blocks:
        db_session.add(PackageSessionBlock(package_id=package.id, label=label, start_time=start, end_time=end))
    db_session.commit()


def _second_package(db_session, pro: Pro, preset: SchedulingPreset, **kw) -> str:
    """Another package for the same photographer - their calendar is shared."""
    first = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    package = ProPackage(
        pro_user_id=pro.uuid,
        niche_id=first.niche_id,
        title=f"{preset.value} package",
        duration_minutes=kw.pop("duration", 60),
        price=first.price,
        currency="EUR",
        included_photos=10,
        extra_photo_price=first.extra_photo_price,
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
        scheduling_preset=preset,
        interval_minutes=kw.pop("interval", None),
    )
    db_session.add(package)
    db_session.flush()
    for label, start, end in kw.pop("blocks", ()):
        db_session.add(PackageSessionBlock(package_id=package.id, label=label, start_time=start, end_time=end))
    db_session.commit()
    return str(package.id)


def _offered(client, pro: Pro, day: date, package_id: str | None = None) -> list[dict]:
    resp = _calendar(client, pro, day, day, package_id=package_id)
    assert resp.status_code == 200, resp.text
    return resp.json()["days"][0]["start_times"]


def _local(t: dict) -> str:
    return t["local_time"]


def _ask(client, pro: Pro, start: datetime, end: datetime, *, client_id: str | None = None, package_id: str | None = None):
    return client.post(
        "/v1/client/bookings/request",
        headers={"X-User-Id": client_id or pro.client_id},
        json={
            "pro_user_id": pro.id,
            "niche_slug": "portraits",
            "date_window": {"start_at": start.isoformat(), "end_at": end.isoformat()},
            "location": "Lisbon",
            "package_id": package_id or pro.package_id,
        },
    )


# ---------------------------------------------------------------------------
# Interval: hourly unchanged, 4-hour as a step.
# ---------------------------------------------------------------------------


def _frozen_hourly_starts(db_session, pro_uuid, duration: timedelta, from_date: date, to_date: date):
    """The generator as it was before presets, copied here unchanged.

    Kept as a reference rather than trusted to memory: every existing package
    is hourly, and "unchanged" should be a comparison, not a claim.
    """
    from app.services.availability_rules import rule_window
    from app.services.bookable_time import load_calendar, refusal_for

    cal = load_calendar(
        db_session,
        pro_user_id=pro_uuid,
        start=datetime.combine(from_date, time(0), tzinfo=timezone.utc),
        end=datetime.combine(to_date + timedelta(days=1), time(0), tzinfo=timezone.utc),
    )
    if not cal.rules:
        return []
    step = timedelta(minutes=cal.policy.slot_length_minutes)
    now = datetime.now(timezone.utc)
    found = {}
    anchor = from_date - timedelta(days=1)
    while anchor <= to_date:
        for rule in cal.rules:
            if rule.day_of_week != anchor.weekday():
                continue
            window_start, window_end = rule_window(rule, anchor)
            start = window_start
            while start + duration <= window_end:
                local_day = start.astimezone(cal.tz).date()
                s, e = start.astimezone(timezone.utc), (start + duration).astimezone(timezone.utc)
                if from_date <= local_day <= to_date and refusal_for(cal, s, e, now=now) is None:
                    found[s] = e
                start += step
        anchor += timedelta(days=1)
    return sorted(found.items())


@pytest.mark.parametrize(
    "rules,extras",
    [
        (((0, time(9), time(18)),), "plain"),
        (((4, time(20), time(2)), (5, time(10), time(14))), "night shift"),
        (tuple((d, time(7), time(22)) for d in range(7)), "with bookings and blocks"),
    ],
)
def test_an_hourly_package_offers_exactly_what_it_did_before(client, db_session, rules, extras):
    from app.models.booking import ProAvailabilityException
    from app.services.bookable_time import bookable_starts

    pro = _pro(db_session, rules=rules)
    start_day = _future_weekday(MONDAY)
    if extras == "with bookings and blocks":
        _paid_gig(db_session, pro, _utc(start_day, 11), _utc(start_day, 12))
        db_session.add(ProAvailabilityException(pro_user_id=pro.uuid, start_at_utc=_utc(start_day + timedelta(days=1), 9), end_at_utc=_utc(start_day + timedelta(days=1), 15)))
        db_session.commit()
    package = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    assert package.scheduling_preset == SchedulingPreset.interval and package.interval_minutes is None, "the default"

    for duration in (timedelta(minutes=60), timedelta(minutes=90), timedelta(minutes=180)):
        before = _frozen_hourly_starts(db_session, pro.uuid, duration, start_day, start_day + timedelta(days=6))
        _cal, after = bookable_starts(
            db_session, pro_user_id=pro.uuid, duration=duration, from_date=start_day, to_date=start_day + timedelta(days=6)
        )
        assert after == before, f"{extras}, {duration}: hourly changed"
        assert before, "the comparison must have something in it to mean anything"


def test_a_four_hour_package_steps_by_four_hours_from_the_start_of_the_working_day(client, db_session):
    pro = _pro(db_session)  # Monday 09-18
    _set_preset(db_session, pro, SchedulingPreset.interval, interval=240)
    monday = _future_weekday(MONDAY)
    # 09:00, 13:00, and 17:00 because a one-hour shoot still fits before 18:00.
    assert [_local(t) for t in _offered(client, pro, monday)] == ["09:00", "13:00", "17:00"]


def test_a_four_hour_package_only_offers_starts_where_its_shoot_fits(client, db_session):
    pro = _pro(db_session)
    _set_preset(db_session, pro, SchedulingPreset.interval, interval=240, duration=240)
    monday = _future_weekday(MONDAY)
    assert [_local(t) for t in _offered(client, pro, monday)] == ["09:00", "13:00"]


# ---------------------------------------------------------------------------
# Named blocks: the photographer's own times.
# ---------------------------------------------------------------------------


SUNRISE_BLOCKS = (
    (SessionBlockLabel.morning, time(5, 45), time(10, 15)),
    (SessionBlockLabel.afternoon, time(13, 20), time(17, 50)),
)


def test_blocks_are_the_photographers_own_times_not_a_fixed_grid(client, db_session):
    """05:45-10:15 and 13:20-17:50: nothing like a typical morning or
    afternoon, so if these come back the times are genuinely theirs."""
    pro = _pro(db_session, rules=((0, time(5), time(22)),))
    _set_preset(db_session, pro, SchedulingPreset.blocks, blocks=SUNRISE_BLOCKS, duration=180)
    monday = _future_weekday(MONDAY)

    offered = _offered(client, pro, monday)
    assert [(t["label"], t["local_time"], t["local_end_time"]) for t in offered] == [
        ("morning", "05:45", "10:15"),
        ("afternoon", "13:20", "17:50"),
    ], "no Evening was defined, so none is offered"


def test_a_block_outside_working_hours_is_never_offered(client, db_session):
    pro = _pro(db_session)  # Monday 09-18
    _set_preset(db_session, pro, SchedulingPreset.blocks, blocks=SUNRISE_BLOCKS, duration=180)
    monday = _future_weekday(MONDAY)
    # 05:45 starts before work; 13:20-17:50 is inside it.
    assert [t["label"] for t in _offered(client, pro, monday)] == ["afternoon"]


def test_booking_a_block_occupies_the_whole_block(client, db_session):
    pro = _pro(db_session, rules=((0, time(5), time(22)),))
    _set_preset(db_session, pro, SchedulingPreset.blocks, blocks=SUNRISE_BLOCKS, duration=60)
    hourly = _second_package(db_session, pro, SchedulingPreset.interval)
    monday = _future_weekday(MONDAY)

    assert _ask(client, pro, _utc(monday, 5, 45), _utc(monday, 10, 15)).status_code == 200
    # The one-hour shoot does not free the rest of the block.
    hourly_starts = [_local(t) for t in _offered(client, pro, monday, package_id=hourly)]
    for held in ("06:00", "07:00", "08:00", "09:00"):
        assert held not in hourly_starts, f"{held} is inside the booked Morning block"


def test_adjacent_blocks_need_no_buffer_between_them(client, db_session):
    """The photographer drew the boundary; it is the separation."""
    pro = _pro(db_session, rules=((0, time(5), time(22)),))
    adjacent = (
        (SessionBlockLabel.morning, time(6), time(11)),
        (SessionBlockLabel.afternoon, time(11), time(16)),
    )
    _set_preset(db_session, pro, SchedulingPreset.blocks, blocks=adjacent, duration=120)
    monday = _future_weekday(MONDAY)

    assert _ask(client, pro, _utc(monday, 6), _utc(monday, 11)).status_code == 200
    assert [t["label"] for t in _offered(client, pro, monday)] == ["afternoon"]
    second = _ask(client, pro, _utc(monday, 11), _utc(monday, 16), client_id=_second_client(db_session))
    assert second.status_code == 200, second.text


def test_an_hourly_booking_next_to_a_block_keeps_its_buffer(client, db_session):
    """No buffer between two blocks - but an hourly shoot ending at 11:00 still
    needs its 15 minutes before an 11:00 block."""
    pro = _pro(db_session, rules=((0, time(5), time(22)),))
    _set_preset(db_session, pro, SchedulingPreset.blocks, blocks=((SessionBlockLabel.afternoon, time(11), time(16)),), duration=60)
    hourly = _second_package(db_session, pro, SchedulingPreset.interval)
    monday = _future_weekday(MONDAY)

    assert _ask(client, pro, _utc(monday, 10), _utc(monday, 11), package_id=hourly).status_code == 200
    assert _offered(client, pro, monday) == [], "the block clashes with the hourly shoot's buffer"


# ---------------------------------------------------------------------------
# Full day: the date, and nothing else on it.
# ---------------------------------------------------------------------------


def _local_midnight(day: date) -> datetime:
    return datetime.combine(day, time(0), tzinfo=ZoneInfo(TZ))


def test_a_full_day_is_offered_once_per_working_day_as_the_whole_date(client, db_session):
    pro = _pro(db_session)  # works Mondays only
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    monday = _future_weekday(MONDAY)

    offered = _offered(client, pro, monday)
    assert len(offered) == 1
    assert datetime.fromisoformat(offered[0]["start_at"]) == _local_midnight(monday)
    assert datetime.fromisoformat(offered[0]["end_at"]) == _local_midnight(monday + timedelta(days=1))
    assert _offered(client, pro, monday + timedelta(days=1)) == [], "not on a day they do not work"


def _book_full_day(client, pro: Pro, day: date):
    return _ask(client, pro, _local_midnight(day), _local_midnight(day + timedelta(days=1)))


def test_a_full_day_booking_closes_the_date_to_every_other_preset(client, db_session):
    pro = _pro(db_session, rules=tuple((d, time(6), time(22)) for d in range(7)))
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    hourly = _second_package(db_session, pro, SchedulingPreset.interval)
    four_hour = _second_package(db_session, pro, SchedulingPreset.interval, interval=240)
    blocks = _second_package(db_session, pro, SchedulingPreset.blocks, blocks=((SessionBlockLabel.evening, time(18), time(21)),))
    monday = _future_weekday(MONDAY)

    assert _book_full_day(client, pro, monday).status_code == 200
    for package_id in (hourly, four_hour, blocks, pro.package_id):
        assert _offered(client, pro, monday, package_id=package_id) == [], f"{package_id} still offered on a full-day date"
        assert _offered(client, pro, monday + timedelta(days=1), package_id=package_id), "the next day must be unaffected"
    late = _ask(client, pro, _utc(monday, 20), _utc(monday, 21), client_id=_second_client(db_session), package_id=hourly)
    assert late.status_code == 409


def test_any_booking_on_a_date_closes_it_to_a_full_day(client, db_session):
    pro = _pro(db_session, rules=tuple((d, time(6), time(22)) for d in range(7)))
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    hourly = _second_package(db_session, pro, SchedulingPreset.interval)
    monday = _future_weekday(MONDAY)

    # One short shoot at the end of the day.
    assert _ask(client, pro, _utc(monday, 20), _utc(monday, 21), package_id=hourly).status_code == 200
    assert _offered(client, pro, monday) == []
    assert _book_full_day(client, pro, monday).status_code == 409


def test_a_night_shift_running_past_midnight_closes_the_next_date_to_a_full_day(client, db_session):
    sunday = 6
    pro = _pro(db_session, rules=((sunday, time(20), time(2)), (MONDAY, time(9), time(18))))
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    # A 90-minute shoot, so 23:00-00:30 is a window it genuinely offers.
    hourly = _second_package(db_session, pro, SchedulingPreset.interval, duration=90)
    monday = _future_weekday(MONDAY)
    sunday_date = monday - timedelta(days=1)

    # Sunday 23:00 to Monday 00:30, inside Sunday's night shift.
    resp = _ask(client, pro, _utc(sunday_date, 23), _utc(monday, 0, 30), package_id=hourly)
    assert resp.status_code == 200, resp.text
    assert _offered(client, pro, monday) == [], "Monday starts with a shoot still running"


def test_a_full_day_gig_in_any_holding_state_closes_the_date(client, db_session):
    pro = _pro(db_session, rules=tuple((d, time(6), time(22)) for d in range(7)))
    hourly = _second_package(db_session, pro, SchedulingPreset.interval)
    monday = _future_weekday(MONDAY)
    _paid_gig(db_session, pro, _local_midnight(monday), _local_midnight(monday + timedelta(days=1)), status=GigStatus.paid)
    assert _offered(client, pro, monday, package_id=hourly) == []


# ---------------------------------------------------------------------------
# Only what was offered can be requested.
# ---------------------------------------------------------------------------


def test_an_hourly_package_refuses_a_time_off_its_grid(client, db_session):
    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    resp = _ask(client, pro, _utc(monday, 10, 17), _utc(monday, 11, 17))
    assert resp.status_code == 409, "10:17 was never offered"


def test_a_package_refuses_a_window_of_the_wrong_length(client, db_session):
    pro = _pro(db_session)  # a 60-minute package
    monday = _future_weekday(MONDAY)
    assert _ask(client, pro, _utc(monday, 10), _utc(monday, 13)).status_code == 409


def test_a_block_package_refuses_anything_but_one_of_its_blocks(client, db_session):
    pro = _pro(db_session, rules=((0, time(5), time(22)),))
    _set_preset(db_session, pro, SchedulingPreset.blocks, blocks=SUNRISE_BLOCKS, duration=60)
    monday = _future_weekday(MONDAY)
    assert _ask(client, pro, _utc(monday, 6), _utc(monday, 7)).status_code == 409, "an hour inside the block is not the block"
    assert _ask(client, pro, _utc(monday, 5, 45), _utc(monday, 10, 15)).status_code == 200


def test_a_full_day_package_refuses_part_of_a_day(client, db_session):
    pro = _pro(db_session)
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    monday = _future_weekday(MONDAY)
    assert _ask(client, pro, _utc(monday, 9), _utc(monday, 17)).status_code == 409


def test_the_chat_path_refuses_an_unoffered_time_too(client, db_session):
    from app.api.v1.pro_onboarding import _validate_availability
    from app.core.errors import APIError

    pro = _pro(db_session)
    monday = _future_weekday(MONDAY)
    package = db_session.get(ProPackage, uuid.UUID(pro.package_id))
    with pytest.raises(APIError):
        _validate_availability(db_session, pro.uuid, _utc(monday, 10, 17), _utc(monday, 11, 17), package=package)
    _validate_availability(db_session, pro.uuid, _utc(monday, 10), _utc(monday, 11), package=package)


# ---------------------------------------------------------------------------
# A booking is judged by the preset it was made under.
# ---------------------------------------------------------------------------


def test_a_request_records_the_preset_it_was_made_under(client, db_session):
    pro = _pro(db_session)
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    monday = _future_weekday(MONDAY)
    booking_id = _book_full_day(client, pro, monday).json()["booking_id"]
    request = db_session.get(BookingRequest, uuid.UUID(booking_id))
    assert request.scheduling_preset == SchedulingPreset.full_day


def test_changing_the_package_later_does_not_change_how_a_request_is_judged(client, db_session):
    """A full-day request accepted after the photographer switched the package
    to hourly is still a full day: the whole date, not 00:00-24:00 inside
    working hours (which would fail)."""
    pro = _pro(db_session)
    _set_preset(db_session, pro, SchedulingPreset.full_day, duration=480)
    monday = _future_weekday(MONDAY)
    booking_id = _book_full_day(client, pro, monday).json()["booking_id"]

    _set_preset(db_session, pro, SchedulingPreset.interval)
    resp = client.post(f"/v1/booking-requests/{booking_id}/accept", headers={"X-User-Id": pro.id})
    assert resp.status_code == 200, resp.text


# ---------------------------------------------------------------------------
# The package API carries the preset, and refuses a configuration that cannot work.
# ---------------------------------------------------------------------------


def _update(client, pro: Pro, **body):
    # The update route needs the niche on every call.
    return client.put(
        f"/v1/pro/me/packages/{pro.package_id}", headers={"X-User-Id": pro.id}, json={"niche_slug": "portraits", **body}
    )


def test_the_package_api_sets_and_returns_a_preset(client, db_session):
    pro = _pro(db_session)
    resp = _update(
        client,
        pro,
        scheduling_preset="blocks",
        session_blocks=[{"label": "morning", "start_time": "06:00:00", "end_time": "11:00:00"}],
        duration_minutes=120,
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["scheduling_preset"] == "blocks"
    assert body["session_blocks"] == [{"label": "morning", "start_time": "06:00:00", "end_time": "11:00:00"}]


@pytest.mark.parametrize(
    "body,why",
    [
        ({"scheduling_preset": "blocks", "session_blocks": []}, "blocks with no block"),
        ({"scheduling_preset": "blocks", "duration_minutes": 360, "session_blocks": [{"label": "morning", "start_time": "06:00:00", "end_time": "11:00:00"}]}, "a shoot longer than its block"),
        ({"scheduling_preset": "blocks", "session_blocks": [{"label": "morning", "start_time": "06:00:00", "end_time": "11:00:00"}, {"label": "afternoon", "start_time": "10:00:00", "end_time": "14:00:00"}]}, "overlapping blocks"),
        ({"scheduling_preset": "blocks", "session_blocks": [{"label": "morning", "start_time": "06:00:00", "end_time": "11:00:00"}, {"label": "morning", "start_time": "12:00:00", "end_time": "14:00:00"}]}, "the same label twice"),
        ({"scheduling_preset": "interval", "interval_minutes": 90}, "an interval that is not a preset"),
        ({"scheduling_preset": "full_day", "session_blocks": [{"label": "morning", "start_time": "06:00:00", "end_time": "11:00:00"}]}, "blocks on a full-day package"),
    ],
)
def test_the_package_api_refuses_a_configuration_that_cannot_work(client, db_session, body, why):
    pro = _pro(db_session)
    resp = _update(client, pro, **{"duration_minutes": 60, **body})
    assert resp.status_code == 422, f"{why}: {resp.text}"
