"""Addresses not to email, from Brevo's delivery events (services/email_suppression.py)."""
import uuid
from datetime import datetime, timedelta, timezone

from app.models.communication import EmailSuppression
from app.services.email_suppression import record_event, suppression_reason
from app.services.notifications import get_or_create_preferences

from tests.test_notifications_v1 import _ensure_user

T0 = datetime(2026, 11, 9, 12, tzinfo=timezone.utc)


def _addr():
    return f"{uuid.uuid4().hex[:8]}@example.com"


def test_a_hard_bounce_stops_every_email_even_security(db_session):
    a = _addr()
    record_event(db_session, event="hard_bounce", email=a.upper(), message_id="<m1>")
    assert suppression_reason(db_session, a, security=False) == "hard_bounce"
    assert suppression_reason(db_session, a, security=True) == "hard_bounce"


def test_invalid_and_blocked_are_undeliverable_too(db_session):
    for event in ("invalid_email", "blocked"):
        a = _addr()
        record_event(db_session, event=event, email=a)
        assert suppression_reason(db_session, a, security=True) == event


def test_a_complaint_stops_all_but_security_and_switches_email_off(db_session):
    user, a = uuid.uuid4(), _addr()
    _ensure_user(db_session, user, a)
    record_event(db_session, event="spam", email=a, message_id="<m2>")
    assert suppression_reason(db_session, a, security=False) == "spam"
    assert suppression_reason(db_session, a, security=True) is None
    assert get_or_create_preferences(db_session, user).channel_email_enabled is False


def test_three_soft_bounces_in_a_week_pause_non_security_mail_for_30_days(db_session):
    a = _addr()
    for n in range(2):
        record_event(db_session, event="soft_bounce", email=a, message_id=f"<s{n}>", at=T0 + timedelta(days=n))
    assert suppression_reason(db_session, a, security=False, now=T0 + timedelta(days=2)) is None
    record_event(db_session, event="soft_bounce", email=a, message_id="<s2>", at=T0 + timedelta(days=2))
    assert suppression_reason(db_session, a, security=False, now=T0 + timedelta(days=3)) == "soft_bounce"
    assert suppression_reason(db_session, a, security=True, now=T0 + timedelta(days=3)) is None
    assert suppression_reason(db_session, a, security=False, now=T0 + timedelta(days=33)) is None


def test_a_replayed_soft_bounce_counts_once(db_session):
    a = _addr()
    for _ in range(3):
        record_event(db_session, event="soft_bounce", email=a, message_id="<same>", at=T0)
    assert suppression_reason(db_session, a, security=False, now=T0) is None


def test_soft_bounces_spread_over_more_than_a_week_do_not_pause(db_session):
    a = _addr()
    for n in range(3):
        record_event(db_session, event="soft_bounce", email=a, message_id=f"<w{n}>", at=T0 + timedelta(days=4 * n))
    assert suppression_reason(db_session, a, security=False, now=T0 + timedelta(days=9)) is None


def test_a_suppression_only_grows(db_session):
    a = _addr()
    record_event(db_session, event="hard_bounce", email=a, message_id="<h>")
    record_event(db_session, event="spam", email=a, message_id="<c>")
    for n in range(3):
        record_event(db_session, event="soft_bounce", email=a, message_id=f"<x{n}>", at=T0)
    row = db_session.query(EmailSuppression).filter_by(email=a).one()
    assert (row.scope, row.reason, row.until) == ("all", "hard_bounce", None)
    # A complaint after a soft-bounce pause makes it permanent.
    b = _addr()
    for n in range(3):
        record_event(db_session, event="soft_bounce", email=b, message_id=f"<y{n}>", at=T0)
    record_event(db_session, event="spam", email=b)
    assert suppression_reason(db_session, b, security=False, now=T0 + timedelta(days=400)) == "spam"


def test_delivery_events_suppress_nothing_and_a_new_address_starts_clean(db_session):
    a = _addr()
    record_event(db_session, event="delivered", email=a)
    record_event(db_session, event="opened", email=a)
    assert db_session.query(EmailSuppression).filter_by(email=a).count() == 0
    record_event(db_session, event="hard_bounce", email=a)
    assert suppression_reason(db_session, _addr(), security=False) is None
