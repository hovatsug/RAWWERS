"""Credit used on a booking that is refunded goes back to the client
(owner's decision, 2026-11-07).

All of it on a full refund; on a partial refund the same share as the cash,
rounded down to the cent, so cash back plus credit back is the refunded
share of the booking. Each return is its own "Refunded credit" ledger line,
referenced by booking and refund, spendable like any credit and not counted
against the marketing budget. A EUR 150 booking with EUR 5 credit used is
paid EUR 145 by card.
"""
import uuid
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.api.v1.webhooks import _apply_stripe_event
from app.models.gig import GigStatus, StripePayment
from app.models.reward import RewardLedgerEntry
from app.services import client_credit
from app.services.refund_reconcile import reconcile_payment_refunds

from tests.test_booking_close import _ensure_account
from tests.test_client_booking_pay import _booking_with_gig
from tests.test_client_credit import _give, _h, fake_stripe  # noqa: F401 - fixture

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


@pytest.fixture
def refunds(monkeypatch):
    """What Stripe holds: the refunds per payment intent."""
    held: dict[str, list[dict]] = {}
    monkeypatch.setattr("app.services.refund_reconcile.fetch_refunds", lambda pi: list(held.get(pi, [])))
    return held


def _paid_with_credit(client, db, *, price="150.00", status=GigStatus.payment_pending):
    user_id = str(uuid.uuid4())
    _ensure_account(db, user_id)
    booking, gig = _booking_with_gig(db, user_id, str(uuid.uuid4()), gig_status=status)
    gig.amount_minimum, gig.retained_percent, gig.pro_raww_percent = Decimal(price), 15, 5
    db.commit()
    _give(db, uuid.UUID(user_id), 500)
    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()
    assert (resp["credit_eur"], resp["amount_eur"]) == ("5.00", f"{Decimal(price) - 5:.2f}")
    _apply_stripe_event(db, "payment_intent.succeeded", {"id": resp["payment_intent_id"], "amount_received": int((Decimal(price) - 5) * 100)})
    db.commit()
    assert client.get("/v1/me/credit", headers=_h(user_id)).json()["balance_eur"] == "0.00"
    return user_id, gig, resp["payment_intent_id"]


def _refund(refunds, pi, refund_id, euros, status="succeeded"):
    refunds.setdefault(pi, []).append({"id": refund_id, "status": status, "amount": int(Decimal(euros) * 100), "created": len(refunds.get(pi, []))})


def _reconcile(db, pi):
    assert reconcile_payment_refunds(db, pi, trigger="test")
    db.commit()


def _returns(db, gig):
    return db.execute(
        select(RewardLedgerEntry).where(RewardLedgerEntry.reference_type == client_credit.REFUND_REFERENCE).where(
            RewardLedgerEntry.reference_id.like(f"{gig.id}:%")
        ).order_by(RewardLedgerEntry.created_at)
    ).scalars().all()


def _balance(client, user_id):
    return client.get("/v1/me/credit", headers=_h(user_id)).json()["balance_eur"]


def test_a_full_refund_gives_all_the_credit_back_as_its_own_line(client, db_session, fake_stripe, refunds):
    user_id, gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_full", "145.00")

    _reconcile(db_session, pi)

    [line] = _returns(db_session, gig)
    assert (line.amount, line.reference_id, line.meta["kind"]) == (500, f"{gig.id}:re_full", "refunded_credit")
    assert _balance(client, user_id) == "5.00"
    [item] = [i for i in client.get("/v1/me/credit", headers=_h(user_id)).json()["items"] if i["kind"] == "refunded_credit"]
    assert item["amount_eur"] == "5.00"


def test_a_partial_refund_gives_back_the_same_share_rounded_down(client, db_session, fake_stripe, refunds):
    """EUR 40 of 145 cash back is 27.59% of the booking: EUR 1.37 credit
    (5 x 40/145 = 1.379, down to the cent, not up). Then the rest: the
    whole EUR 5."""
    user_id, gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_a", "40.00")
    _reconcile(db_session, pi)
    assert [line.amount for line in _returns(db_session, gig)] == [137]
    assert _balance(client, user_id) == "1.37"

    _refund(refunds, pi, "re_b", "105.00")
    _reconcile(db_session, pi)

    assert [line.amount for line in _returns(db_session, gig)] == [137, 363]
    assert _balance(client, user_id) == "5.00"


def test_half_back_is_half_the_credit_and_the_photographer_is_paid_on_the_rest(client, db_session, fake_stripe, refunds):
    """EUR 72.50 cash plus EUR 2.50 credit back is half of EUR 150: the
    photographer is paid on the other EUR 75, not on 77.50."""
    from app.services.photographer_money import earned_gross

    user_id, gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_half", "72.50")
    _reconcile(db_session, pi)

    assert _balance(client, user_id) == "2.50"
    assert earned_gross(db_session, gig) == Decimal("75.00")


def test_the_same_refund_delivered_again_gives_nothing_more(client, db_session, fake_stripe, refunds):
    user_id, gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_a", "50.00")
    for _ in range(3):
        _reconcile(db_session, pi)
    _apply_stripe_event(db_session, "charge.refunded", {"id": "ch_x", "payment_intent": pi})
    db_session.commit()

    assert [line.amount for line in _returns(db_session, gig)] == [172]
    assert _balance(client, user_id) == "1.72"


def test_a_failed_refund_gives_no_credit_back(client, db_session, fake_stripe, refunds):
    user_id, gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_failed", "145.00", status="failed")

    _reconcile(db_session, pi)

    assert _returns(db_session, gig) == [] and _balance(client, user_id) == "0.00"


def test_a_cancelled_booking_refunded_in_full_gets_its_credit_back_once(client, db_session, fake_stripe, refunds):
    user_id, gig, pi = _paid_with_credit(client, db_session)
    gig.status = GigStatus.cancelled_by_pro
    db_session.commit()
    _refund(refunds, pi, "re_cancel", "145.00")

    _reconcile(db_session, pi)
    _reconcile(db_session, pi)

    assert [line.amount for line in _returns(db_session, gig)] == [500]
    assert _balance(client, user_id) == "5.00"


def test_refunded_credit_is_not_marketing_credit_and_shows_on_the_admin_month(client, db_session, fake_stripe, refunds):
    client_credit.settings(db_session).monthly_marketing_credit_budget_eur = Decimal("10")
    db_session.commit()
    _user, _gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_full", "145.00")
    _reconcile(db_session, pi)

    month = client.get("/v1/admin/client-credit/budget", headers=ADMIN).json()

    assert (month["awarded_eur"], month["remaining_eur"]) == ("0.00", "10.00")
    assert Decimal(month["returned_on_refunds_eur"]) >= Decimal("5.00")


def test_returned_credit_can_be_spent_again(client, db_session, fake_stripe, refunds):
    user_id, gig, pi = _paid_with_credit(client, db_session)
    _refund(refunds, pi, "re_full", "145.00")
    _reconcile(db_session, pi)

    booking, _other = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()

    assert resp["credit_eur"] == "5.00"


def test_a_booking_paid_without_credit_gets_none(client, db_session, fake_stripe, refunds):
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full"}, headers=_h(user_id)).json()
    _apply_stripe_event(db_session, "payment_intent.succeeded", {"id": resp["payment_intent_id"], "amount_received": 10000})
    db_session.commit()
    _refund(refunds, resp["payment_intent_id"], "re_full", "100.00")

    _reconcile(db_session, resp["payment_intent_id"])

    assert _returns(db_session, gig) == []
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    assert payment.amount_refunded == Decimal("100.00")
