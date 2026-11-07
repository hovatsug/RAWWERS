"""Selection difference: a payment is for a COUNT of photos on the booking's
own curve, not for particular photos (owner's rule, 2026-11-07).

- Within what was paid for, choosing or switching photos costs nothing.
- Past it: pay price(selection) - what was paid.
- Below it, at finish: the rest is refunded through the normal refund path
  ("You'll get EUR X back" is said before confirming).
- A payment made for a selection that has since changed is cancelled and
  replaced; if it still succeeds, it just raises the paid count. Never
  charged twice for the same count; never a successful payment unmatched.

The booking here: 20 photos included (deposit P(20)), 30 delivered.
"""
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from types import SimpleNamespace

import pytest
import stripe
from sqlalchemy import select

from app.models.gig import GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.price_reduction import PriceReduction
from app.services import stripe_reconcile
from app.services.package_pricing import compute_package_total

from tests.test_download_payment_gate import (  # noqa: F401 - fixtures
    FakePI,
    FakeStripe,
    _cents,
    _difference_rows,
    _downloads,
    _save,
    _setup,
    _submit,
    _webhook,
    fake_stripe,
    rated,
)


@pytest.fixture
def refunds(monkeypatch):
    made = []

    def create(**kwargs):
        made.append(kwargs)
        return SimpleNamespace(id=f"re_{len(made)}", status="pending")

    monkeypatch.setattr("app.services.price_reduction.stripe.Refund.create", create)
    return made


def P(db, gig, n) -> Decimal:
    return compute_package_total(db, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=n)


def _paid_at_stripe_without_webhook(fake, row):
    """Stripe took the money; the webhook never came."""
    pi = fake.pis[row.stripe_payment_intent_id]
    pi.status = "succeeded"
    pi.amount_received = pi.amount


def _quote(client, gallery, client_id, count):
    resp = client.get(f"/v1/proof-galleries/{gallery.id}/selection-quote", params={"selected_count": count}, headers={"X-User-Id": client_id})
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_the_earlier_case_A_paid_then_a_larger_B_pays_only_the_photos_past_A(client, db_session, fake_stripe, refunds, monkeypatch):
    """The case found on 2026-11-04: the client paid for A (25), the webhook
    was missed, and they submit B (30). B used to be refused (409, "already
    being processed") and the booking later closed on A. Now A is recorded
    first and B costs P(30) - P(25)."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    assert a.amount == P(db_session, gig, 25) - gig.amount_minimum
    _paid_at_stripe_without_webhook(fake_stripe, a)

    _save(client, gallery, client_id, assets[:30])
    shown = _quote(client, gallery, client_id, 30)
    resp = _submit(client, gallery, client_id)

    owed = P(db_session, gig, 30) - P(db_session, gig, 25)
    assert Decimal(shown["amount_due"]) == owed, "the price shown before confirming"
    assert resp.status_code == 200, resp.text
    assert Decimal(resp.json()["difference_amount"]) == owed
    a, b = _difference_rows(db_session, gig)
    assert (a.status, b.status, b.amount) == (PaymentStatus.succeeded, PaymentStatus.pending, owed)
    db_session.refresh(gig)
    assert gig.selection_paid_count == 25

    _webhook(client, monkeypatch, "payment_intent.succeeded", b.stripe_payment_intent_id, amount_received=_cents(owed))
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed and gig.selection_paid_count == 30
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 30
    assert refunds == []


def test_A_paid_then_a_smaller_B_is_refunded_the_difference_at_finish(client, db_session, fake_stripe, refunds):
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:30])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    _paid_at_stripe_without_webhook(fake_stripe, a)

    _save(client, gallery, client_id, assets[:22])
    shown = _quote(client, gallery, client_id, 22)
    resp = _submit(client, gallery, client_id)

    back = P(db_session, gig, 30) - P(db_session, gig, 22)
    assert (Decimal(shown["amount_due"]), Decimal(shown["refund_amount"])) == (Decimal("0.00"), back)
    assert resp.status_code == 200, resp.text
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed and gig.amount_final == P(db_session, gig, 22)
    assert [r["amount"] for r in refunds] == [_cents(back)]
    assert refunds[0]["payment_intent"] == a.stripe_payment_intent_id
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 22


def test_switching_photos_within_what_was_paid_for_costs_nothing(client, db_session, fake_stripe, refunds):
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    _paid_at_stripe_without_webhook(fake_stripe, a)

    _save(client, gallery, client_id, assets[5:30])  # 25 others
    resp = _submit(client, gallery, client_id)

    assert resp.status_code == 200 and resp.json()["difference_required"] is False, resp.text
    assert len(fake_stripe.creates) == 1 and refunds == []
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 25


def test_an_old_payment_that_succeeds_as_it_is_replaced_raises_the_count_and_is_not_charged_again(client, db_session, fake_stripe, refunds, monkeypatch):
    """A (25) waits on 3-D Secure; the client submits B (30), so A is
    cancelled - but Stripe refuses: A has just succeeded. It is recorded,
    the client is asked to confirm again, and B then costs P(30) - P(25)."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    fake_stripe.pis[a.stripe_payment_intent_id].status = "requires_action"

    def cancel_too_late(pi_id, **_kwargs):
        pi = fake_stripe.pis[pi_id]
        pi.status, pi.amount_received = "succeeded", pi.amount
        raise stripe.InvalidRequestError("This PaymentIntent's status is succeeded.", "status")

    monkeypatch.setattr("stripe.PaymentIntent.cancel", cancel_too_late)
    _save(client, gallery, client_id, assets[:30])
    first = _submit(client, gallery, client_id)
    assert first.status_code == 409 and "earlier payment" in first.json()["error"]["message"]
    assert _difference_rows(db_session, gig)[0].status == PaymentStatus.succeeded

    _save(client, gallery, client_id, assets[:30])
    again = _submit(client, gallery, client_id)

    owed = P(db_session, gig, 30) - P(db_session, gig, 25)
    assert again.status_code == 200 and Decimal(again.json()["difference_amount"]) == owed
    assert len(fake_stripe.creates) == 2


def test_a_payment_for_photos_already_paid_for_that_lands_after_finish_goes_back(client, db_session, fake_stripe, refunds, monkeypatch):
    """Two payments live for the same photos (one left open from before the
    selection changed) and both succeed: the booking stays completed, the
    count is what was chosen, and the second payment is refunded in full -
    once, however often its webhook comes."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    stale = FakePI("pi_stale", "sec_stale", _cents(a.amount))
    fake_stripe.pis[stale.id] = stale
    db_session.add(StripePayment(
        gig_id=gig.id, kind=StripePaymentKind.difference, client_user_id=gig.client_user_id, status=PaymentStatus.pending,
        stripe_payment_intent_id=stale.id, amount=a.amount, currency="EUR", meta={"for_count": 25},
    ))
    db_session.commit()
    _webhook(client, monkeypatch, "payment_intent.succeeded", a.stripe_payment_intent_id, amount_received=_cents(a.amount))
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed

    stale.status = "succeeded"
    for _ in range(2):
        _webhook(client, monkeypatch, "payment_intent.succeeded", stale.id, amount_received=_cents(a.amount))

    db_session.expire_all()
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed and gig.selection_paid_count == 25
    assert gig.amount_final == P(db_session, gig, 25)
    assert [(r["payment_intent"], r["amount"]) for r in refunds] == [(stale.id, _cents(a.amount))]
    reduction = db_session.execute(select(PriceReduction).where(PriceReduction.gig_id == gig.id)).scalars().one()
    assert [line["reason_code"] for line in reduction.lines] == ["duplicate_payment"]


def test_an_open_payment_for_a_changed_selection_is_cancelled_when_nothing_more_is_owed(client, db_session, fake_stripe, refunds):
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)

    _save(client, gallery, client_id, assets[:20])  # back to what the deposit paid for
    assert _submit(client, gallery, client_id).status_code == 200

    assert fake_stripe.cancels == [a.stripe_payment_intent_id]
    assert _difference_rows(db_session, gig)[0].status == PaymentStatus.cancelled
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed


def test_the_reconcile_job_records_a_missed_payment_and_the_booking_closes_on_what_it_paid_for(client, db_session, fake_stripe, refunds):
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    _paid_at_stripe_without_webhook(fake_stripe, a)

    class Gateway:
        def retrieve(self, pi_id):
            return fake_stripe.pis[pi_id]

        def list_succeeded(self, since):
            return []

    stripe_reconcile.run(db_session, gateway=Gateway(), now=datetime.now(timezone.utc) + timedelta(hours=1))
    db_session.commit()

    db_session.expire_all()
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed and gig.selection_paid_count == 25
    assert len(_downloads(client, gallery, client_id).json()["urls"]) == 25
    assert refunds == [] and len(fake_stripe.creates) == 1


def test_a_replaced_payment_that_succeeds_anyway_lowers_the_new_one_to_what_is_left(client, db_session, fake_stripe, refunds, monkeypatch):
    """A (25) was replaced by B (30)'s payment for P(30) - P(20), and then
    A's success arrives after all: it raises the count to 25, and B's
    payment, still waiting for a card, is lowered to P(30) - P(25)."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:25])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    fake_stripe.pis[a.stripe_payment_intent_id].status = "requires_action"
    _save(client, gallery, client_id, assets[:30])
    assert _submit(client, gallery, client_id).status_code == 200
    a, b = _difference_rows(db_session, gig)
    assert b.amount == P(db_session, gig, 30) - gig.amount_minimum

    _webhook(client, monkeypatch, "payment_intent.succeeded", a.stripe_payment_intent_id, amount_received=_cents(a.amount))

    left = P(db_session, gig, 30) - P(db_session, gig, 25)
    assert fake_stripe.modifies[-1] == (b.stripe_payment_intent_id, _cents(left))
    _a, b = _difference_rows(db_session, gig)
    assert b.amount == left
    db_session.refresh(gig)
    assert gig.status == GigStatus.paid and gig.selection_paid_count == 25

    _webhook(client, monkeypatch, "payment_intent.succeeded", b.stripe_payment_intent_id, amount_received=_cents(left))
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed and refunds == []


def test_a_stale_payment_landing_after_a_refunded_finish_is_refunded_too(client, db_session, fake_stripe, refunds, monkeypatch):
    """The finish already refunded what was not chosen; a payment for photos
    already paid for then lands. It is refunded on its own, not swallowed by
    the first refund's record."""
    client_id, gig, gallery, assets = _setup(db_session)
    _save(client, gallery, client_id, assets[:30])
    assert _submit(client, gallery, client_id).status_code == 200
    [a] = _difference_rows(db_session, gig)
    stale = FakePI("pi_stale2", "sec_stale2", 500)
    fake_stripe.pis[stale.id] = stale
    db_session.add(StripePayment(
        gig_id=gig.id, kind=StripePaymentKind.difference, client_user_id=gig.client_user_id, status=PaymentStatus.pending,
        stripe_payment_intent_id=stale.id, amount=Decimal("5.00"), currency="EUR", meta={"for_count": 30},
    ))
    db_session.commit()
    _paid_at_stripe_without_webhook(fake_stripe, a)
    stale.status = "processing"  # left alone at the change, still moving
    _save(client, gallery, client_id, assets[:22])
    assert _submit(client, gallery, client_id).status_code == 200
    assert len(refunds) == 1

    stale.status, stale.amount_received = "succeeded", 500
    _webhook(client, monkeypatch, "payment_intent.succeeded", stale.id, amount_received=500)

    assert [(r["payment_intent"], r["amount"]) for r in refunds][1:] == [(stale.id, 500)]
    db_session.refresh(gig)
    assert gig.status == GigStatus.completed and gig.amount_final == P(db_session, gig, 22)
