"""The suite's clock for call quiet hours: midday Lisbon unless a test opts out.

See `_quiet_hours_at_midday` in conftest. Without it, call tests passed or
failed depending on the hour the suite ran.
"""
import uuid
from datetime import datetime, time, timedelta, timezone

import pytest
from app.models.communication import UserContact
from app.services import call_compliance


def _night_quiet_contact() -> UserContact:
    return UserContact(timezone_name="Europe/Lisbon", quiet_hours_start=time(22, 0), quiet_hours_end=time(8, 0))


def test_by_default_quiet_hours_are_judged_at_midday():
    assert call_compliance.is_quiet_hours_now(_night_quiet_contact()) is False


def test_an_explicit_time_still_wins_over_the_pin():
    three_am = datetime.now(timezone.utc).replace(hour=3, minute=0)
    assert call_compliance.is_quiet_hours_now(_night_quiet_contact(), now_utc=three_am) is True


@pytest.mark.real_clock
def test_real_clock_opts_out_of_the_pin():
    assert call_compliance.is_quiet_hours_now.__module__ == "app.services.call_compliance"


# --- the pin reaches nothing else -------------------------------------------
#
# Holds, request expiry, notice and the sweeps must keep reading the real
# clock: a pin that leaked into them would make the booking tests pass at
# any hour for the wrong reason. Each check below uses a moment halfway
# between real now and Lisbon midday, so real time and a midday clock give
# opposite answers whatever hour the suite runs.


def _midday_utc() -> datetime:
    from zoneinfo import ZoneInfo

    return datetime.now(ZoneInfo("Europe/Lisbon")).replace(hour=12, minute=0, second=0, microsecond=0).astimezone(timezone.utc)


def _between_now_and_midday() -> tuple[datetime, datetime, bool]:
    """(now, the halfway moment, whether real now is after midday)."""
    now, midday = datetime.now(timezone.utc), _midday_utc()
    if abs(now - midday) < timedelta(minutes=10):
        pytest.skip("too close to midday for real time and the pin to disagree")
    return now, now + (midday - now) / 2, now > midday


def test_the_clock_modules_read_is_the_real_one():
    import datetime as real_datetime

    from app.services import bookable_time, scheduling

    for module in (bookable_time, scheduling):
        assert module.datetime is real_datetime.datetime, module.__name__


def test_request_expiry_runs_on_real_time(db_session):
    from tests.test_response_time import _pro_with_package

    from app.models.booking import BookingRequest, BookingRequestStatus
    from app.services.scheduling import expire_pending_booking_requests

    _, halfway, after_midday = _between_now_and_midday()
    pro, package = _pro_with_package(db_session)
    request = BookingRequest(
        pro_user_id=pro,
        client_user_id=uuid.uuid4(),
        package_id=package,
        requested_start=halfway + timedelta(days=10),
        requested_end=halfway + timedelta(days=10, hours=1),
        status=BookingRequestStatus.pending,
        created_at=halfway - timedelta(hours=24),
        expires_at=halfway,
    )
    db_session.add(request)
    db_session.commit()

    expire_pending_booking_requests(db_session, limit=None)
    db_session.commit()
    db_session.refresh(request)

    # Past midday, halfway is already behind real now: it expires. Before
    # midday it is still ahead. A midday clock would answer the other way.
    assert (request.status == BookingRequestStatus.expired) is after_midday


def test_notice_is_measured_from_real_now(db_session):
    from tests.test_bookable_time import _pro

    from app.services.bookable_time import _range_calendar, refusal_for

    now, halfway, after_midday = _between_now_and_midday()
    pro = _pro(db_session, rules=tuple((day, time(0, 0), time(23, 59)) for day in range(7)), notice_hours=24)
    start = halfway + timedelta(hours=24)
    cal = _range_calendar(db_session, pro.uuid, (start - timedelta(days=1)).date(), (start + timedelta(days=1)).date())

    refusal = refusal_for(cal, start, start + timedelta(hours=1))

    # start - real now = 24h + (midday - now) / 2: short of 24 hours' notice
    # only when real now is past midday.
    refused_for_notice = refusal is not None and "notice" in refusal.message
    assert refused_for_notice is after_midday
