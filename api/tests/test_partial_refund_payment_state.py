"""A partial refund leaves the payment succeeded, with what has been refunded.

An admin refund marked its payment `pending` - the status of a payment not
yet made - the moment it was asked for, whatever the amount. A booking with
30% refunded then looked unpaid everywhere that reads the status: every
later refund route answered "no payment", the finals gate saw no settled
deposit, and a difference payment looked like an open charge to retry. Now
the payment keeps `succeeded` until everything on it is back, and
`amount_refunded` records how much is - taken from Stripe's charge.refunded,
as Stripe holds them (services/refund_reconcile).
"""
import copy
import uuid
from decimal import Decimal

from app.api.v1.webhooks import _apply_stripe_event
from app.models.gig import PaymentStatus, StripePayment
from app.services.payment_intents import base_payment_succeeded, list_succeeded_payments_for_gig

from tests.test_refund_caps import _admin_refund, stripe_all  # noqa: F401 - fixture
from tests.test_refund_reconcile import SCENARIOS, stripe_truth  # noqa: F401 - fixture
from tests.test_refund_routes import _paid_booking, stripe_refunds  # noqa: F401 - fixture


def _payment(db_session, gig) -> StripePayment:
    db_session.expire_all()
    return db_session.query(StripePayment).filter_by(gig_id=gig.id).order_by(StripePayment.created_at).first()


def _charge_refunded(db_session, stripe_truth, payment, *refunded: Decimal, stale_total: Decimal | None = None):
    """Stripe now holds these refunds on the payment, and sends its
    charge.refunded (captured shapes, this payment's ids). stale_total: an
    old charge.refunded delivered late, carrying a smaller running total."""
    from app.models.admin import RefundCase

    pi = payment.stripe_payment_intent_id
    template = SCENARIOS["full"]["refunds"][0]
    # Refunds our routes asked for carry the ids Stripe gave them.
    ours = [
        c.meta["stripe_refund_id"]
        for c in db_session.query(RefundCase).filter(RefundCase.stripe_payment_intent_id == pi).order_by(RefundCase.created_at)
        if (c.meta or {}).get("stripe_refund_id")
    ]
    stripe_truth.by_intent[pi] = [
        {**copy.deepcopy(template), "id": ours[n] if n < len(ours) else f"re_{pi}_{n}", "payment_intent": pi,
         "status": "succeeded", "amount": int(a * 100), "created": template["created"] + n}
        for n, a in enumerate(refunded)
    ]
    charge = copy.deepcopy(next(e for e in SCENARIOS["full"]["events"] if e["type"] == "charge.refunded")["data"]["object"])
    total = stale_total if stale_total is not None else sum(refunded, Decimal("0"))
    charge.update(payment_intent=pi, amount=int(payment.amount * 100), amount_refunded=int(total * 100), refunded=total >= payment.amount)
    _apply_stripe_event(db_session, "charge.refunded", charge)
    db_session.commit()


def test_asking_for_a_partial_refund_leaves_the_payment_succeeded(client, db_session, stripe_all, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)

    assert _admin_refund(client, gig, amount=Decimal("30.00")).status_code == 200

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.succeeded
    assert payment.amount_refunded == Decimal("0.00"), "nothing is back until Stripe says so"


def test_stripe_saying_part_is_back_records_how_much(client, db_session, stripe_all, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)
    _admin_refund(client, gig, amount=Decimal("30.00"))

    _charge_refunded(db_session, stripe_truth, _payment(db_session, gig), Decimal("30.00"))

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.succeeded
    assert payment.amount_refunded == Decimal("30.00")


def test_two_partials_add_up_and_an_old_event_never_lowers_it(client, db_session, stripe_all, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)
    payment = _payment(db_session, gig)

    _charge_refunded(db_session, stripe_truth, payment, Decimal("30.00"))
    _charge_refunded(db_session, stripe_truth, payment, Decimal("30.00"), Decimal("20.00"))
    _charge_refunded(db_session, stripe_truth, payment, Decimal("30.00"), Decimal("20.00"), stale_total=Decimal("30.00"))  # delivered late

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.succeeded
    assert payment.amount_refunded == Decimal("50.00")


def test_everything_back_makes_it_refunded(client, db_session, stripe_all, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)
    payment = _payment(db_session, gig)

    _charge_refunded(db_session, stripe_truth, payment, Decimal("30.00"))
    _charge_refunded(db_session, stripe_truth, payment, Decimal("30.00"), Decimal("70.00"))

    payment = _payment(db_session, gig)
    assert payment.status == PaymentStatus.refunded
    assert payment.amount_refunded == Decimal("100.00")


def test_after_a_partial_the_booking_still_counts_as_paid(client, db_session, stripe_all, stripe_truth):
    """The finals gate and every refund route read the status."""
    gig, _client, _pro = _paid_booking(db_session)
    _admin_refund(client, gig, amount=Decimal("30.00"))
    _charge_refunded(db_session, stripe_truth, _payment(db_session, gig), Decimal("30.00"))
    db_session.expire_all()

    assert base_payment_succeeded(db_session, gig)
    assert len(list_succeeded_payments_for_gig(db_session, gig.id)) == 1


def test_after_a_partial_the_rest_can_still_be_refunded(client, db_session, stripe_all, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)
    first = _admin_refund(client, gig, amount=Decimal("30.00"))
    # Stripe's event settles the admin case: the in-flight slot is free again.
    _charge_refunded(db_session, stripe_truth, _payment(db_session, gig), Decimal("30.00"))
    from app.models.admin import RefundCase, RefundCaseStatus

    db_session.expire_all()
    assert db_session.get(RefundCase, uuid.UUID(first.json()["id"])).status == RefundCaseStatus.refunded

    resp = _admin_refund(client, gig, amount=Decimal("70.00"))

    assert resp.status_code == 200, resp.text
    assert [c["amount"] for c in stripe_all.calls] == [3000, 7000]
