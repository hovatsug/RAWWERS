"""POST /v1/client/bookings/{id}/pay, specifically the guard against paying
for a booking that has already gone through.

A client can re-hit this endpoint for reasons that have nothing to do with
double-paying on purpose: reopening the booking screen before a webhook has
updated local state, a stale Pay button surviving a backgrounded app, a
retried request after a flaky connection. The gig's own status is already
authoritative here (whatever the client believes, the backend will not
create a second PaymentIntent once `create_or_get_gig_payment_intent`'s
existing-row check kicks in) - what was missing was telling the two 409
cases apart: "you can't pay for this (yet or ever)" and "you already did",
which call for different client behaviour. The former is a dead end; the
latter should read as reassurance and point the screen at a refresh, not at
a retry.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.gig import Gig, GigStatus

from tests.test_booking_close import _ensure_account
from tests.test_client_gallery_access import _package


def _booking_with_gig(db_session, client_id: str, pro_id: str, *, gig_status: GigStatus):
    now = datetime.now(timezone.utc)
    pkg = _package(db_session, pro_id)
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=gig_status,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()

    booking = BookingRequest(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        package_id=pkg.id,
        status=BookingRequestStatus.accepted,
        requested_start=now + timedelta(days=3),
        requested_end=now + timedelta(days=3, hours=2),
        expires_at=now + timedelta(days=1),
    )
    db_session.add(booking)
    db_session.flush()
    gig.meta = {**(gig.meta or {}), "booking_request_id": str(booking.id)}
    db_session.commit()
    db_session.refresh(gig)
    db_session.refresh(booking)
    return booking, gig


def _pay(client, booking_id, user_id):
    return client.post(
        f"/v1/client/bookings/{booking_id}/pay",
        headers={"X-User-Id": user_id},
        json={"payment_mode": "full"},
    )


def test_paying_for_a_gig_that_already_moved_past_payment_says_so_distinctly(client, db_session, user_id):
    """Once the gig is `paid` (or further along), re-hitting pay must read as
    reassurance, not as the same dead-end error a genuinely wrong booking
    state gets - the whole point of a client re-tapping in this window is
    that it does not yet know the first attempt worked."""
    _ensure_account(db_session, user_id)
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, user_id, pro_id, gig_status=GigStatus.paid)

    response = _pay(client, booking.id, user_id)

    assert response.status_code == 409
    body = response.json()
    assert body["error"]["code"] == "already_paid"


def test_paying_for_a_gig_further_along_than_paid_still_reads_as_already_paid(client, db_session, user_id):
    """`scheduled`, `shoot_done`, and everything after `paid` are all still
    "this succeeded", not "this is broken" - the shoot having since happened
    does not turn a stale Pay tap into a real error."""
    _ensure_account(db_session, user_id)
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, user_id, pro_id, gig_status=GigStatus.shoot_done)

    response = _pay(client, booking.id, user_id)

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "already_paid"


def test_paying_for_a_gig_that_was_never_accepted_is_a_real_error_not_already_paid(client, db_session, user_id):
    """A booking still `requested` failed the check one line above the
    already-paid one this test guards - confirming the new code path did not
    swallow every 409 into "already paid"."""
    _ensure_account(db_session, user_id)
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, pro_id)
    now = datetime.now(timezone.utc)
    pkg = _package(db_session, pro_id)
    booking = BookingRequest(
        client_user_id=uuid.UUID(user_id),
        pro_user_id=uuid.UUID(pro_id),
        package_id=pkg.id,
        status=BookingRequestStatus.pending,
        requested_start=now + timedelta(days=3),
        requested_end=now + timedelta(days=3, hours=2),
        expires_at=now + timedelta(days=1),
    )
    db_session.add(booking)
    db_session.commit()

    response = _pay(client, booking.id, user_id)

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "invalid_state"


def test_paying_for_a_cancelled_gig_is_a_real_error_not_already_paid(client, db_session, user_id):
    """Cancelled and refunded are also "not awaiting payment", but they are
    not "already paid" either - conflating them would tell a client whose
    booking fell through that everything is fine."""
    _ensure_account(db_session, user_id)
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, user_id, pro_id, gig_status=GigStatus.cancelled_by_client)

    response = _pay(client, booking.id, user_id)

    assert response.status_code == 409
    assert response.json()["error"]["code"] == "invalid_state"
