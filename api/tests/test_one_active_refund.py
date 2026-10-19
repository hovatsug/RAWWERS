"""One refund in flight per payment, held by the database.

The cap stops a refund larger than what is left, but two requests at the
same moment each see the whole amount left and each ask Stripe. A partial
unique index on refund_case(stripe_payment_intent_id), over the statuses
still in flight, makes the second one fail - and every path records its
refund case before it asks Stripe, so the one that loses never reaches the
money. Refunds that finished, failed, were cancelled or rejected do not
hold the slot: a later refund of what is left is still possible.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import RefundCase, RefundCaseStatus, RefundPaymentScope
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from tests.test_refund_caps import ADMIN, _admin_refund, _dispute, _earlier_refund, _resolve, stripe_all  # noqa: F401
from tests.test_refund_routes import _paid_booking, _refund, stripe_refunds  # noqa: F401 - fixture

IN_FLIGHT = [
    RefundCaseStatus.pending,
    RefundCaseStatus.requested,
    RefundCaseStatus.approved,
    RefundCaseStatus.refund_initiated,
    RefundCaseStatus.processing,
]
DONE = [
    RefundCaseStatus.refunded,
    RefundCaseStatus.succeeded,
    RefundCaseStatus.failed,
    RefundCaseStatus.cancelled,
    RefundCaseStatus.rejected,
]


def _row(gig, status, amount=Decimal("10.00")) -> RefundCase:
    return RefundCase(
        gig_id=gig.id,
        payment_scope=RefundPaymentScope.booking_payment,
        reference_id=gig.id,
        stripe_payment_intent_id=f"pi_{gig.id.hex[:10]}_0",
        amount_authorized=Decimal("100.00"),
        amount_refunded=Decimal("0.00"),
        status=status,
        amount=amount,
        currency="EUR",
        meta={},
    )


# --- the constraint itself -----------------------------------------------------------------


@pytest.mark.parametrize("first", IN_FLIGHT)
@pytest.mark.parametrize("second", IN_FLIGHT)
def test_the_database_refuses_a_second_refund_in_flight(db_session, first, second):
    gig, _client, _pro = _paid_booking(db_session)
    db_session.add(_row(gig, first))
    db_session.commit()

    db_session.add(_row(gig, second))
    with pytest.raises(IntegrityError):
        db_session.commit()
    db_session.rollback()


@pytest.mark.parametrize("finished", DONE)
def test_a_finished_refund_does_not_hold_the_slot(db_session, finished):
    gig, _client, _pro = _paid_booking(db_session)
    db_session.add(_row(gig, finished))
    db_session.commit()

    db_session.add(_row(gig, RefundCaseStatus.pending))
    db_session.commit()


def test_different_payments_are_independent(db_session):
    gig, _client, _pro = _paid_booking(db_session, payments=2)
    db_session.add(_row(gig, RefundCaseStatus.pending))
    other = _row(gig, RefundCaseStatus.pending)
    other.stripe_payment_intent_id = f"pi_{gig.id.hex[:10]}_1"
    db_session.add(other)
    db_session.commit()


def test_a_case_with_no_payment_intent_is_not_held(db_session):
    gig, _client, _pro = _paid_booking(db_session)
    for _ in range(2):
        row = _row(gig, RefundCaseStatus.pending)
        row.stripe_payment_intent_id = None
        db_session.add(row)
    db_session.commit()


# --- the routes, when a refund is already in flight ----------------------------------------


def test_an_admin_refund_while_another_is_in_flight_is_refused_before_stripe(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"), status=RefundCaseStatus.pending)

    resp = _admin_refund(client, gig, amount=Decimal("20.00"))

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "refund_in_progress"
    assert stripe_all.calls == []


def test_a_client_refund_while_another_is_in_flight_is_refused_before_stripe(client, db_session, stripe_all):
    gig, client_id, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"), status=RefundCaseStatus.refund_initiated)

    resp = _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "refund_in_progress"
    assert stripe_all.calls == []


def test_a_dispute_refund_while_another_is_in_flight_is_refused(client, db_session, stripe_all):
    from app.models.gig import GigStatus

    gig, client_id, _pro = _paid_booking(db_session, status=GigStatus.disputed)
    _earlier_refund(db_session, gig, Decimal("30.00"), status=RefundCaseStatus.processing)
    dispute = _dispute(db_session, gig, client_id)

    resp = _resolve(client, dispute)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "refund_in_progress"
    db_session.expire_all()
    assert db_session.execute(select(RefundCase).where(RefundCase.dispute_id == dispute.id)).scalars().all() == []


def test_once_the_first_finishes_the_rest_can_be_refunded(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"), status=RefundCaseStatus.refunded)

    resp = _admin_refund(client, gig, amount=Decimal("70.00"))

    assert resp.status_code == 200, resp.text


@pytest.mark.parametrize("route", ["admin", "client"])
def test_in_a_race_the_constraint_stops_the_second_before_stripe(client, db_session, stripe_all, monkeypatch, route):
    """Two requests at once both pass the route's own check - each sees no
    refund in flight. Only the database stands between them, and because
    the refund case is written before Stripe is asked, the loser never
    reaches the money."""
    gig, client_id, _pro = _paid_booking(db_session)
    _earlier_refund(db_session, gig, Decimal("30.00"), status=RefundCaseStatus.pending)
    module = "app.api.v1.admin" if route == "admin" else "app.api.v1.gigs"
    monkeypatch.setattr(f"{module}.refund_in_flight", lambda db, payment_intent_id: None)

    resp = _admin_refund(client, gig, amount=Decimal("20.00")) if route == "admin" else _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert resp.json()["error"]["code"] == "refund_in_progress"
    assert stripe_all.calls == []


def test_a_later_refund_of_what_is_left_gets_a_key_of_its_own(client, db_session, stripe_all):
    """The admin refund's key was per payment: a second partial refund
    within Stripe's 24 hours replayed the first, and no money moved."""
    gig, _client, _pro = _paid_booking(db_session)
    first = _admin_refund(client, gig, amount=Decimal("40.00"))
    db_session.expire_all()
    case = db_session.get(RefundCase, uuid.UUID(first.json()["id"]))
    case.status = RefundCaseStatus.refunded  # the webhook settled it
    db_session.commit()

    second = _admin_refund(client, gig, amount=Decimal("60.00"))

    assert second.status_code == 200, second.text
    assert len(stripe_all.by_key) == 2, "two refunds at Stripe, not one replayed"
    assert [c["amount"] for c in stripe_all.calls] == [4000, 6000]


@pytest.mark.parametrize("route", ["admin", "client"])
def test_a_refund_in_flight_on_any_payment_stops_the_whole_request_before_stripe(client, db_session, stripe_all, route):
    """Two payments, the second with a refund in flight. Checked one at a
    time, the first went to Stripe and then the second refused - and the
    rollback lost the record of a refund that had really happened."""
    gig, client_id, _pro = _paid_booking(db_session, payments=2)
    # pending: a processing case makes the admin route answer with that case
    # (its retry path) before it gets as far as this check.
    in_flight = _row(gig, RefundCaseStatus.pending)
    in_flight.stripe_payment_intent_id = f"pi_{gig.id.hex[:10]}_1"
    db_session.add(in_flight)
    db_session.commit()

    resp = _admin_refund(client, gig, amount=Decimal("110.00")) if route == "admin" else _refund(client, gig, client_id)

    assert resp.status_code == 409, resp.text
    assert stripe_all.calls == []
