"""Working hours that cross midnight.

An events or nightlife photographer works 20:00 to 02:00. Before this,
they could not save those hours at all - and if such a rule reached the
database anyway, every check refused every slot, including squarely
mid-shift. events_nightlife is a seeded niche, so this was a category of
photographer the product could not serve.
"""
import uuid
from datetime import date, datetime, time, timedelta, timezone

import pytest

from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProAvailabilityRule, ProSchedulingPolicy
from app.services.availability_rules import (
    MAX_OVERNIGHT_SPAN,
    any_rule_covers,
    rule_span,
    validate_rule_times,
    wraps_midnight,
)
from app.services.scheduling import generate_candidate_slots, validate_slot_available


def _seed_pro(db_session, *, weekday: int, start: time, end: time, tz: str = "UTC") -> uuid.UUID:
    uid = uuid.uuid4()
    # Committed before anything referencing it: pro_profile has a real
    # foreign key to user_account, and batching the two into one flush
    # leaves the ordering to SQLAlchemy's discretion.
    db_session.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db_session.commit()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=uid, kyc_status=KYCStatus.approved, is_accepting_bookings=True))
    db_session.add(
        ProAvailabilityRule(
            pro_user_id=uid, day_of_week=weekday, start_time=start, end_time=end, timezone=tz, location_mode="both"
        )
    )
    db_session.add(
        ProSchedulingPolicy(
            pro_user_id=uid,
            slot_length_minutes=60,
            buffer_before_minutes=0,
            buffer_after_minutes=0,
            advance_notice_hours=0,
            max_bookings_per_day=None,
        )
    )
    db_session.commit()
    return uid


def _next_weekday(weekday: int, *, weeks_out: int = 4) -> date:
    """A date comfortably in the future, so advance-notice never decides
    the outcome of a test about availability windows."""
    today = datetime.now(timezone.utc).date() + timedelta(weeks=weeks_out)
    return today + timedelta(days=(weekday - today.weekday()) % 7)


# --- the model -----------------------------------------------------------


def test_a_rule_ending_before_it_starts_wraps_to_the_next_day():
    assert wraps_midnight(time(20, 0), time(2, 0))
    assert rule_span(time(20, 0), time(2, 0)) == timedelta(hours=6)
    assert not wraps_midnight(time(9, 0), time(17, 0))
    assert rule_span(time(9, 0), time(17, 0)) == timedelta(hours=8)


def test_a_night_shift_is_accepted_and_a_near_lap_is_not():
    validate_rule_times(time(20, 0), time(2, 0))
    validate_rule_times(time(16, 0), time(8, 0))  # exactly at the cap

    with pytest.raises(APIError) as caught:
        # 23 hours: a typo for an evening shift, not a shift.
        validate_rule_times(time(20, 0), time(19, 0))
    assert "crossing midnight" in caught.value.message
    # The message has to name the alternative, or a pro who wants all-day
    # availability is stuck guessing.
    assert "00:00 to 23:59" in caught.value.message


def test_all_day_availability_is_unaffected_by_the_cap():
    # 23h59m, but not wrapping - the cap is about shifts that cross
    # midnight, not about long days.
    validate_rule_times(time(0, 0), time(23, 59))
    assert rule_span(time(0, 0), time(23, 59)) > MAX_OVERNIGHT_SPAN


# --- the three checks ----------------------------------------------------


def test_slot_check_accepts_mid_shift_and_after_midnight(db_session):
    friday = 4
    uid = _seed_pro(db_session, weekday=friday, start=time(20, 0), end=time(2, 0))
    day = _next_weekday(friday)

    def at(d: date, hour: int) -> datetime:
        return datetime.combine(d, time(hour, 0), tzinfo=timezone.utc)

    # Mid-shift, before midnight.
    validate_slot_available(db_session, pro_user_id=uid, start_at_utc=at(day, 21), end_at_utc=at(day, 22))
    # After midnight: belongs to Friday's rule even though it is Saturday.
    validate_slot_available(
        db_session, pro_user_id=uid, start_at_utc=at(day + timedelta(days=1), 1), end_at_utc=at(day + timedelta(days=1), 2)
    )


def test_slot_check_still_refuses_outside_the_shift(db_session):
    friday = 4
    uid = _seed_pro(db_session, weekday=friday, start=time(20, 0), end=time(2, 0))
    day = _next_weekday(friday)

    with pytest.raises(APIError):
        # Saturday lunchtime is well past the tail of Friday's shift.
        validate_slot_available(
            db_session,
            pro_user_id=uid,
            start_at_utc=datetime.combine(day + timedelta(days=1), time(13, 0), tzinfo=timezone.utc),
            end_at_utc=datetime.combine(day + timedelta(days=1), time(14, 0), tzinfo=timezone.utc),
        )


def test_a_slot_straddling_midnight_is_covered(db_session):
    friday = 4
    uid = _seed_pro(db_session, weekday=friday, start=time(20, 0), end=time(2, 0))
    day = _next_weekday(friday)

    validate_slot_available(
        db_session,
        pro_user_id=uid,
        start_at_utc=datetime.combine(day, time(23, 30), tzinfo=timezone.utc),
        end_at_utc=datetime.combine(day + timedelta(days=1), time(0, 30), tzinfo=timezone.utc),
    )


def test_the_generator_emits_slots_past_midnight(db_session):
    friday = 4
    uid = _seed_pro(db_session, weekday=friday, start=time(20, 0), end=time(2, 0))
    day = _next_weekday(friday)

    slots = generate_candidate_slots(db_session, pro_user_id=uid, from_date=day, to_date=day + timedelta(days=1))

    assert len(slots) == 6, "20:00-02:00 at 60-minute slots is six"
    assert slots[0][0].hour == 20
    after_midnight = [s for s in slots if s[0].date() == day + timedelta(days=1)]
    assert len(after_midnight) == 2, "00:00 and 01:00 both belong to Friday's shift"


def test_a_normal_day_generates_as_before(db_session):
    tuesday = 1
    uid = _seed_pro(db_session, weekday=tuesday, start=time(9, 0), end=time(17, 0))
    day = _next_weekday(tuesday)

    slots = generate_candidate_slots(db_session, pro_user_id=uid, from_date=day, to_date=day)
    assert len(slots) == 8
    assert all(s[0].date() == day for s in slots)


def test_booking_request_check_covers_the_after_midnight_tail(db_session):
    from app.api.v1.pro_onboarding import _validate_availability

    friday = 4
    uid = _seed_pro(db_session, weekday=friday, start=time(20, 0), end=time(2, 0))
    day = _next_weekday(friday)

    # The path used by the chat and pro-side request flows.
    _validate_availability(
        db_session,
        uid,
        datetime.combine(day + timedelta(days=1), time(0, 30), tzinfo=timezone.utc),
        datetime.combine(day + timedelta(days=1), time(1, 30), tzinfo=timezone.utc),
    )


def test_all_three_checks_agree_through_one_helper(db_session):
    """The comparison used to be written out three times and drifted; this
    pins them to the same answer for the same rule."""
    friday = 4
    uid = _seed_pro(db_session, weekday=friday, start=time(20, 0), end=time(2, 0))
    day = _next_weekday(friday)
    rules = [
        r for r in db_session.query(ProAvailabilityRule).filter_by(pro_user_id=uid).all()
    ]

    start = datetime.combine(day + timedelta(days=1), time(1, 0), tzinfo=timezone.utc)
    end = start + timedelta(hours=1)

    assert any_rule_covers(rules, start, end)
    validate_slot_available(db_session, pro_user_id=uid, start_at_utc=start, end_at_utc=end)
    generated = generate_candidate_slots(db_session, pro_user_id=uid, from_date=day, to_date=day + timedelta(days=1))
    assert any(s[0] == start for s in generated)
