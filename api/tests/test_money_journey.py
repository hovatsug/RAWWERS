"""The money path, end to end, through the routes (tests/money_journey.py).

Each test is one whole journey on its own database, from its own internet
address: none depends on another or on the order the suite runs in.

Every amount is written out by hand from the owner's rules, not read back
from the code under test:
- a package of N photos costs N x the entry rate; extras follow the niche's
  curve from photo N+1 (decision of 2026-11-01; the approved Portraits table:
  20 photos at 4.80 = 96.00, 10 extras 31.74);
- the platform's 20% divides into 15% kept and 5% returned to the
  photographer as RAWW credit, each rounded to the cent on its own; the
  photographer's cash is the remainder;
- RAWWERS absorbs Stripe's processing fee out of its 15%: the photographer's
  cash never depends on it, and nothing here models it.
"""
from __future__ import annotations

from datetime import timedelta
from decimal import Decimal as D

import pytest

from tests.money_journey import LISBON_EUR, Journey, assert_split_reconciles, assert_wallet_balances, cents


@pytest.fixture
def journey(proxied_client, db_session, monkeypatch):
    return lambda world=LISBON_EUR: Journey(proxied_client, db_session, monkeypatch, world)


def test_scenario_1_happy_path_in_euros(journey):
    j = journey()
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")

    # Booking and payment: the package, 20 photos at 4.80.
    booking = j.book(client, pro)
    pay = j.checkout(client, booking)
    assert D(pay["amount"]) == D("96.00") and pay["currency"] == "EUR"
    assert j.stripe.intents[booking.base_intent].amount == 9600
    j.card_pays(booking.base_intent)
    gig = j.gig(booking)
    assert gig.status.value == "paid"
    assert gig.amount_minimum == D("96.00")

    # Delivery of 30; the client chooses all 30: 10 extras, 31.74 more.
    j.deliver(pro, booking, 30)
    chosen = j.choose(client, booking, 30)
    assert D(chosen["quote"]["amount_total"]) == D("127.74")
    assert D(chosen["quote"]["amount_due"]) == D("31.74")
    assert chosen["submitted"]["difference_required"] is True
    assert D(chosen["submitted"]["difference_amount"]) == D("31.74")
    assert j.stripe.intents[booking.difference_intent].amount == 3174
    assert j.gig(booking).status.value == "paid"  # not complete until the difference is paid
    j.card_pays(booking.difference_intent)

    # Complete, with the split stamped: 127.74 = 19.16 kept + 6.39 RAWW + 102.19 cash.
    gig = j.gig(booking)
    assert gig.status.value == "completed"
    assert (gig.amount_final, gig.final_gross) == (D("127.74"), D("127.74"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("19.16"), D("6.39"), D("102.19"))
    assert gig.final_client_raww in (None, D("0.00"))
    assert_split_reconciles(gig)
    assert j.captured(booking) == [D("96.00"), D("31.74")]  # the booking's ledger: each payment once
    payments = j.payments(booking)
    assert [(p.kind.value, p.status.value, p.amount, p.amount_refunded or D("0.00")) for p in payments] == [
        ("base", "succeeded", D("96.00"), D("0.00")),
        ("difference", "succeeded", D("31.74"), D("0.00")),
    ]

    # One earning for the whole booking, at the stamped split, waiting 7 days.
    entries = j.entries(pro)
    assert [(e.source_type.value, e.status.value, e.gross, e.platform_fee, e.net, e.currency) for e in entries] == [
        ("gig_base", "pending", D("127.74"), D("25.55"), D("102.19"), "EUR"),
    ]
    assert abs((entries[0].available_at - entries[0].created_at) - timedelta(days=7)) < timedelta(minutes=1)
    j.review(client, booking)

    # The RAWW credit: 6.39 at 0.10 a RAWW is 64, pending while the earning is.
    raww = j.raww(pro)
    assert sum(r.amount for r in raww) == 64

    # Before the 7 days: the sweep leaves it, the payout is refused.
    assert j.settle() == 0
    wallet = j.wallet(pro)
    assert (wallet.pending, wallet.available) == (D("102.19"), D("0.00"))
    assert_wallet_balances(wallet)
    refused = j.request_payout(pro, D("102.19"), expect=422)
    assert refused["error"]["code"] == "validation_error"

    # The clock moves past the delay; the sweep makes it available.
    assert j.jump_past_settlement_delay(pro) == 1
    assert j.settle() == 1
    wallet = j.wallet(pro)
    assert (wallet.pending, wallet.available, wallet.lifetime) == (D("0.00"), D("102.19"), D("102.19"))

    # Payout of everything, approved; one transfer from each charge.
    payout = j.request_payout(pro, D("102.19"))
    assert (payout["status"], D(payout["amount"])) == ("requested", D("102.19"))
    assert j.wallet(pro).requested == D("102.19")
    j.approve_payout(payout["id"])
    sent = j.stripe.transfers_to(j.account_id)
    base_charge, difference_charge = (j.stripe.intents[booking.base_intent].latest_charge,
                                      j.stripe.intents[booking.difference_intent].latest_charge)
    assert sorted((t.source_transaction, t.amount, t.currency) for t in sent) == sorted([
        (base_charge, 9600, "eur"), (difference_charge, 619, "eur"),
    ])
    assert sum(t.amount for t in sent) == cents("102.19")
    assert all(t.transfer_group == f"payout:{payout['id']}" for t in sent)
    rows = j.payout_transfers(payout["id"])
    assert sorted(r.amount for r in rows) == [D("6.19"), D("96.00")]
    j.confirm_transfers()

    paid = [p for p in j.call("GET", "/v1/pro/payouts", pro)["items"] if p["id"] == payout["id"]][0]
    assert paid["status"] == "paid"
    wallet = j.wallet(pro)
    assert (wallet.paid_out, wallet.available, wallet.requested, wallet.reserved) == (D("102.19"), D("0.00"), D("0.00"), D("0.00"))
    assert_wallet_balances(wallet)

    # What Stripe holds: 127.74 in, 102.19 out to the photographer, 25.55 left
    # (the platform's 19.16 and the 6.39 behind the RAWW credit).
    assert j.stripe.balance["eur"] == cents("25.55")
    assert j.mail.keys_to(client.email).count("payment.succeeded") == 2  # one receipt per payment

