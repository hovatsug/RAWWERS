"""A payment Stripe took whose `payment_intent.succeeded` never reached us.

Found 2026-11-02 in dev: the webhook forwarder had stopped, the client was
charged, and the booking kept reading "Payment due". Every Pay tap handed
the paid intent back to the payment sheet, which can only answer "unexpected
error". Wherever we fetch the intent from Stripe anyway, a `succeeded` status
is now recorded the way the webhook would record it.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
import stripe
from sqlalchemy import func, select

from app.models.gig import GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.services.bookable_time import expire_unpaid_gigs

from tests.test_booking_close import _ensure_account
from tests.test_client_booking_pay import _booking_with_gig, _pay


class _PI:
    def __init__(self, pi_id, status, amount_received=10000):
        self.id = pi_id
        self.status = status
        self.client_secret = f"{pi_id}_secret"
        self.amount = 10000
        self.amount_received = amount_received


@pytest.fixture
def stripe_says(monkeypatch):
    """What Stripe answers for each intent, and what it refuses to cancel."""
    answers: dict[str, _PI] = {}
    monkeypatch.setattr("stripe.PaymentIntent.retrieve", lambda pi_id, **_: answers[pi_id])

    def cancel(pi_id, **_):
        if answers[pi_id].status in ("succeeded", "processing"):
            raise stripe.error.InvalidRequestError("You cannot cancel this PaymentIntent", "intent")
        answers[pi_id].status = "canceled"
        return answers[pi_id]

    monkeypatch.setattr("stripe.PaymentIntent.cancel", cancel)
    return answers


def _pending_gig_with_intent(db_session, client_id, stripe_says, *, stripe_status, deadline_in=timedelta(hours=2)):
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)
    booking, gig = _booking_with_gig(db_session, client_id, pro_id, gig_status=GigStatus.payment_pending)
    gig.pay_deadline_at = datetime.now(timezone.utc) + deadline_in
    pi_id = f"pi_{uuid.uuid4().hex[:12]}"
    db_session.add(
        StripePayment(
            gig_id=gig.id,
            kind=StripePaymentKind.base,
            client_user_id=gig.client_user_id,
            status=PaymentStatus.pending,
            stripe_payment_intent_id=pi_id,
            amount=Decimal("100.00"),
            currency="EUR",
            meta={},
        )
    )
    db_session.commit()
    stripe_says[pi_id] = _PI(pi_id, stripe_status)
    return booking, gig, pi_id


def _captured(db_session, gig, pi_id):
    return db_session.execute(
        select(func.count()).select_from(LedgerEntry).where(
            LedgerEntry.gig_id == gig.id,
            LedgerEntry.entry_type == LedgerEntryType.payment_captured,
            LedgerEntry.reference_id == pi_id,
        )
    ).scalar_one()


def test_paying_again_after_stripe_took_the_money_records_it_and_says_already_paid(client, db_session, user_id, stripe_says):
    booking, gig, pi_id = _pending_gig_with_intent(db_session, user_id, stripe_says, stripe_status="succeeded")

    response = _pay(client, booking.id, user_id)

    assert response.status_code == 409, response.text
    assert response.json()["error"]["code"] == "already_paid"
    db_session.expire_all()
    assert db_session.get(type(gig), gig.id).status == GigStatus.paid
    payment = db_session.execute(select(StripePayment).where(StripePayment.stripe_payment_intent_id == pi_id)).scalar_one()
    assert payment.status == PaymentStatus.succeeded
    assert _captured(db_session, gig, pi_id) == 1


def test_recording_it_twice_changes_nothing(client, db_session, user_id, stripe_says):
    booking, gig, pi_id = _pending_gig_with_intent(db_session, user_id, stripe_says, stripe_status="succeeded")
    _pay(client, booking.id, user_id)

    again = _pay(client, booking.id, user_id)

    assert again.json()["error"]["code"] == "already_paid"
    assert _captured(db_session, gig, pi_id) == 1


def test_an_intent_still_waiting_for_a_card_is_handed_back_as_before(client, db_session, user_id, stripe_says):
    booking, gig, pi_id = _pending_gig_with_intent(db_session, user_id, stripe_says, stripe_status="requires_payment_method")

    response = _pay(client, booking.id, user_id)

    assert response.status_code == 200, response.text
    assert response.json()["payment_intent_id"] == pi_id
    db_session.expire_all()
    assert db_session.get(type(gig), gig.id).status == GigStatus.payment_pending


def test_the_expiry_job_records_a_payment_stripe_took_instead_of_leaving_it(db_session, stripe_says):
    client_id = str(uuid.uuid4())
    _, gig, pi_id = _pending_gig_with_intent(db_session, client_id, stripe_says, stripe_status="succeeded", deadline_in=timedelta(hours=-1))

    assert expire_unpaid_gigs(db_session) == 0
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(type(gig), gig.id).status == GigStatus.paid
    assert _captured(db_session, gig, pi_id) == 1


def test_the_expiry_job_leaves_a_payment_still_going_through(db_session, stripe_says):
    client_id = str(uuid.uuid4())
    _, gig, pi_id = _pending_gig_with_intent(db_session, client_id, stripe_says, stripe_status="processing", deadline_in=timedelta(hours=-1))

    assert expire_unpaid_gigs(db_session) == 0
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(type(gig), gig.id).status == GigStatus.payment_pending
    assert _captured(db_session, gig, pi_id) == 0


def test_the_expiry_job_still_cancels_a_payment_nobody_made(db_session, stripe_says):
    client_id = str(uuid.uuid4())
    _, gig, _ = _pending_gig_with_intent(db_session, client_id, stripe_says, stripe_status="requires_payment_method", deadline_in=timedelta(hours=-1))

    assert expire_unpaid_gigs(db_session) == 1
    db_session.commit()

    db_session.expire_all()
    assert db_session.get(type(gig), gig.id).status == GigStatus.cancelled_by_client
