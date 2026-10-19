"""A partial refund leaves the payment succeeded, with what has been refunded.

An admin refund marked its payment `pending` - the status of a payment not
yet made - the moment it was asked for, whatever the amount. A booking with
30% refunded then looked unpaid everywhere that reads the status: every
later refund route answered "no payment", the finals gate saw no settled
deposit, and a difference payment looked like an open charge to retry. Now
the payment keeps `succeeded` until everything on it is back, and
`amount_refunded` records how much is - taken from Stripe's charge.refunded,
which carries the charge's running total.
"""
import uuid
from decimal import Decimal

from app.api.v1.webhooks import _apply_stripe_event
from app.models.gig import PaymentStatus, StripePayment
from app.services.payment_intents import base_payment_succeeded, list_succeeded_payments_for_gig

from tests.test_refund_caps import _admin_refund, stripe_all  # noqa: F401 - fixture
from tests.test_refund_routes import _paid_booking, stripe_refunds  # noqa: F401 - fixture


def _payment(db_session, gig) -> StripePayment:
    db_session.expire_all()
    return db_session.query(StripePayment).filter_by(gig_id=gig.id).order_by(StripePayment.created_at).first()


def _charge_refunded(db_session, payment, total_refunded: Decimal):
    """Stripe's charge.refunded: the charge, with its running total refunded
    and - on the API version we use - no list of refunds."""
    _apply_stripe_event(
        db_session,
        "charge.refunded",
        {
            "id": f"ch_{payment.stripe_payment_intent_id[3:]}",
            "object": "charge",
            "payment_intent": payment.stripe_payment_intent_id,
            "amount": int(payment.amount * 100),
            "amount_refunded": int(total_refunded * 100),
            "refunded": total_refunded >= payment.amount,
        },
    )
    db_session.commit()


def test_asking_for_a_partial_refund_leaves_the_payment_succeeded(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)

    assert _admin_refund(client, gig, amount=Decimal("30.00")).status_code == 200

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.succeeded
    assert payment.amount_refunded == Decimal("0.00"), "nothing is back until Stripe says so"


def test_stripe_saying_part_is_back_records_how_much(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    _admin_refund(client, gig, amount=Decimal("30.00"))

    _charge_refunded(db_session, _payment(db_session, gig), Decimal("30.00"))

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.succeeded
    assert payment.amount_refunded == Decimal("30.00")


def test_two_partials_add_up_and_an_old_event_never_lowers_it(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    payment = _payment(db_session, gig)

    _charge_refunded(db_session, payment, Decimal("30.00"))
    _charge_refunded(db_session, payment, Decimal("50.00"))
    _charge_refunded(db_session, payment, Decimal("30.00"))  # delivered late

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.succeeded
    assert payment.amount_refunded == Decimal("50.00")


def test_everything_back_makes_it_refunded(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    payment = _payment(db_session, gig)

    _charge_refunded(db_session, payment, Decimal("30.00"))
    _charge_refunded(db_session, payment, Decimal("100.00"))

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.refunded
    assert payment.amount_refunded == Decimal("100.00")


def test_after_a_partial_the_booking_still_counts_as_paid(client, db_session, stripe_all):
    """The finals gate and every refund route read the status."""
    gig, _client, _pro = _paid_booking(db_session)
    _admin_refund(client, gig, amount=Decimal("30.00"))
    _charge_refunded(db_session, _payment(db_session, gig), Decimal("30.00"))
    db_session.expire_all()

    assert base_payment_succeeded(db_session, gig)
    assert len(list_succeeded_payments_for_gig(db_session, gig.id)) == 1


def test_after_a_partial_the_rest_can_still_be_refunded(client, db_session, stripe_all):
    gig, _client, _pro = _paid_booking(db_session)
    first = _admin_refund(client, gig, amount=Decimal("30.00"))
    from app.models.admin import RefundCase, RefundCaseStatus

    case = db_session.get(RefundCase, uuid.UUID(first.json()["id"]))
    case.status = RefundCaseStatus.refunded  # settled
    db_session.commit()
    _charge_refunded(db_session, _payment(db_session, gig), Decimal("30.00"))

    resp = _admin_refund(client, gig, amount=Decimal("70.00"))

    assert resp.status_code == 200, resp.text
    assert [c["amount"] for c in stripe_all.calls] == [3000, 7000]
