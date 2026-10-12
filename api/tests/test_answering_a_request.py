"""Who may turn a booking request into a booking, and when.

Accept and confirm-slot both answer a request by creating its gig, and they
used to disagree: confirm-slot checked neither the request's status nor its
deadline, so a photographer could turn a request the client had withdrawn,
or one they had declined themselves, or one long expired, into an unpaid
booking - and skip the KYC check accept makes. Both now ask one function,
and these run every rule through both routes.
"""
import uuid
from datetime import datetime, time, timedelta, timezone

import pytest
from app.core.config import get_settings
from app.models.admin import KYCStatus, ProProfile
from app.models.booking import BookingRequest, BookingRequestStatus
from app.models.gig import Gig
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from sqlalchemy import func, select

from tests.test_bookable_time import _future_weekday, _no_stripe, _pro, _utc  # noqa: F401 - _no_stripe is an autouse fixture

S = BookingRequestStatus


def _request(db_session, pro, *, status=S.pending, expires_in=timedelta(hours=6)) -> tuple[BookingRequest, datetime, datetime]:
    day = _future_weekday(0)
    start, end = _utc(day, 10), _utc(day, 11)
    request = BookingRequest(
        pro_user_id=pro.uuid,
        client_user_id=uuid.UUID(pro.client_id),
        package_id=uuid.UUID(pro.package_id),
        requested_start=start,
        requested_end=end,
        status=status,
        created_at=datetime.now(timezone.utc) - timedelta(hours=2),
        expires_at=datetime.now(timezone.utc) + expires_in,
    )
    db_session.add(request)
    db_session.commit()
    return request, start, end


def _accept(client, pro, request, start, end):
    return client.post(f"/v1/booking-requests/{request.id}/accept", headers={"X-User-Id": pro.id})


def _confirm(client, pro, request, start, end):
    return client.post(
        f"/v1/pro/bookings/{request.id}/confirm-slot",
        headers={"X-User-Id": pro.id},
        json={"start_at_utc": start.isoformat(), "end_at_utc": end.isoformat()},
    )


ROUTES = pytest.mark.parametrize("answer", [_accept, _confirm], ids=["accept", "confirm-slot"])


def _gigs(db_session, request) -> int:
    db_session.expire_all()
    return db_session.execute(
        select(func.count()).select_from(Gig).where(Gig.meta["booking_request_id"].astext == str(request.id))
    ).scalar_one()


def _weekly_pro(db_session):
    return _pro(db_session, rules=((0, time(9), time(18)),))


@ROUTES
def test_a_pending_request_inside_its_deadline_becomes_one_booking(client, db_session, answer):
    pro = _weekly_pro(db_session)
    request, start, end = _request(db_session, pro)

    resp = answer(client, pro, request, start, end)

    assert resp.status_code == 200, resp.text
    db_session.refresh(request)
    assert request.status == S.accepted
    assert _gigs(db_session, request) == 1


@ROUTES
def test_answering_an_accepted_request_again_returns_its_own_booking(client, db_session, answer):
    pro = _weekly_pro(db_session)
    request, start, end = _request(db_session, pro)
    first = answer(client, pro, request, start, end)
    assert first.status_code == 200, first.text

    second = answer(client, pro, request, start, end)

    assert second.status_code == 200, second.text
    assert _gigs(db_session, request) == 1, "no duplicate booking"


@ROUTES
@pytest.mark.parametrize(
    "status,expires_in,code",
    [
        (S.pending, -timedelta(minutes=1), "request_expired"),  # past its deadline, the sweep not run yet
        (S.expired, -timedelta(hours=6), "request_expired"),
        (S.declined, timedelta(hours=6), "request_declined"),
        (S.cancelled, timedelta(hours=6), "request_cancelled"),
    ],
    ids=["pending-past-deadline", "expired", "declined", "cancelled"],
)
def test_a_request_that_can_no_longer_be_answered_is_refused_and_books_nothing(client, db_session, answer, status, expires_in, code):
    pro = _weekly_pro(db_session)
    request, start, end = _request(db_session, pro, status=status, expires_in=expires_in)

    resp = answer(client, pro, request, start, end)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == code
    db_session.refresh(request)
    assert request.status == status, "the request is left as it was"
    assert _gigs(db_session, request) == 0


@ROUTES
def test_a_photographer_without_approved_kyc_cannot_take_a_booking(client, db_session, answer, monkeypatch):
    # The suite allows unverified photographers, as dev does; this rule is
    # about the environments that do not.
    monkeypatch.setattr(get_settings(), "allow_unverified_pro", False)
    pro = _weekly_pro(db_session)
    db_session.get(ProProfile, pro.uuid).kyc_status = KYCStatus.pending
    db_session.commit()
    request, start, end = _request(db_session, pro)

    resp = answer(client, pro, request, start, end)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "kyc_required"
    assert _gigs(db_session, request) == 0


@ROUTES
def test_a_photographer_who_is_not_live_cannot_take_a_booking(client, db_session, answer):
    pro = _weekly_pro(db_session)
    db_session.get(ProOnboarding, pro.uuid).status = ProOnboardingStatus.ready_for_review
    db_session.commit()
    request, start, end = _request(db_session, pro)

    resp = answer(client, pro, request, start, end)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "pro_not_live"
    assert _gigs(db_session, request) == 0

