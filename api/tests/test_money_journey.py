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

import uuid
from datetime import timedelta
from decimal import Decimal as D

import pytest
from sqlalchemy import select

from tests.money_journey import (
    LISBON_EUR,
    LONDON_GBP,
    Journey,
    KnownBug,
    assert_split_reconciles,
    assert_wallet_balances,
    cents,
    known_bug,
)


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


def test_scenario_2_happy_path_in_pounds(journey):
    """London, Portraits Rookie under the 5.00 cap: 20 photos at 4.50 = 90.00;
    5 extras on the curve (k 0.08, floor 15%) = 17.81, written out:
    4.50 x (e^-0.08 + e^-0.16 + e^-0.24 + e^-0.32 + e^-0.40) = 17.8126...,
    total 107.8126 rounded once to 107.81. Split: 15% = 16.1715 -> 16.17,
    5% = 5.3905 -> 5.39, cash 86.25. The payout minimum is 45.00."""
    j = journey(LONDON_GBP)
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")

    # A package above the Rookie cap is refused; at 4.50 it is not.
    over = j.call("PUT", f"/v1/pro/me/packages/{j.package_id}", pro, expect=422, json={"price": "5.01", "niche_slug": "portraits"})
    assert "5.00" in over["error"]["message"], over

    booking = j.book(client, pro)
    pay = j.checkout(client, booking)
    assert (D(pay["amount"]), pay["currency"]) == (D("90.00"), "GBP")
    assert (j.stripe.intents[booking.base_intent].amount, j.stripe.intents[booking.base_intent].currency) == (9000, "gbp")
    j.card_pays(booking.base_intent)

    j.deliver(pro, booking, 25)
    chosen = j.choose(client, booking, 25)
    assert (D(chosen["quote"]["amount_total"]), D(chosen["quote"]["amount_due"])) == (D("107.81"), D("17.81"))
    assert j.stripe.intents[booking.difference_intent].amount == 1781
    j.card_pays(booking.difference_intent)

    gig = j.gig(booking)
    assert (gig.status.value, gig.currency, gig.final_gross) == ("completed", "GBP", D("107.81"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("16.17"), D("5.39"), D("86.25"))
    assert_split_reconciles(gig)
    assert j.captured(booking) == [D("90.00"), D("17.81")]
    entries = j.entries(pro)
    assert [(e.source_type.value, e.gross, e.platform_fee, e.net, e.currency) for e in entries] == [
        ("gig_base", D("107.81"), D("21.56"), D("86.25"), "GBP"),
    ]
    j.review(client, booking)
    # No pound value for RAWW is set and no exchange rate is known on a new
    # database: the 5.39 credit waits, never valued as if pounds were euros.
    assert sum(r.amount for r in j.raww(pro)) == 0

    assert j.settle() == 0
    assert j.request_payout(pro, D("86.25"), expect=422)["error"]["code"] == "validation_error"
    assert j.jump_past_settlement_delay(pro) == 1
    assert j.settle() == 1
    assert j.wallet(pro).available == D("86.25")

    # The pound minimum: 44.99 is refused, naming 45.00.
    below = j.request_payout(pro, D("44.99"), expect=422)
    assert below["error"]["details"]["minimum"] == "45.00" and below["error"]["details"]["currency"] == "GBP"

    payout = j.request_payout(pro, D("86.25"))
    assert (payout["currency"], D(payout["amount"])) == ("GBP", D("86.25"))
    j.approve_payout(payout["id"])
    # 86.25 fits on the first charge (90.00): one transfer, in pounds.
    sent = j.stripe.transfers_to(j.account_id)
    assert [(t.source_transaction, t.amount, t.currency) for t in sent] == [
        (j.stripe.intents[booking.base_intent].latest_charge, 8625, "gbp"),
    ]
    j.confirm_transfers()
    wallet = j.wallet(pro)
    assert (wallet.currency, wallet.paid_out, wallet.available) == ("GBP", D("86.25"), D("0.00"))
    assert_wallet_balances(wallet)
    assert j.stripe.balance == {"gbp": cents("21.56")}


def _euros_to_payout(j):
    """Scenario 1's journey, without its checks along the way."""
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")
    booking = j.book(client, pro)
    j.checkout(client, booking)
    j.card_pays(booking.base_intent)
    j.deliver(pro, booking, 30)
    j.choose(client, booking, 30)
    j.card_pays(booking.difference_intent)
    j.review(client, booking)
    j.jump_past_settlement_delay(pro)
    j.settle()
    payout = j.request_payout(pro, D("102.19"))
    j.approve_payout(payout["id"])
    j.confirm_transfers()
    return pro, client, booking, payout


def _assert_euro_outcome(j, pro, client, booking, payout):
    """Scenario 1's money, exactly once."""
    gig = j.gig(booking)
    assert gig.status.value == "completed"
    assert (gig.final_gross, gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (
        D("127.74"), D("19.16"), D("6.39"), D("102.19"))
    assert [(p.kind.value, p.status.value, p.amount, p.amount_refunded or D("0.00")) for p in j.payments(booking)] == [
        ("base", "succeeded", D("96.00"), D("0.00")), ("difference", "succeeded", D("31.74"), D("0.00")),
    ]
    assert j.captured(booking) == [D("96.00"), D("31.74")]
    assert [(e.source_type.value, e.gross, e.net, e.reversed_at) for e in j.entries(pro)] == [
        ("gig_base", D("127.74"), D("102.19"), None),
    ]
    assert sum(r.amount for r in j.raww(pro)) == 64
    assert sorted(t.amount for t in j.stripe.transfers) == [619, 9600]
    assert sorted(r.amount for r in j.payout_transfers(payout["id"])) == [D("6.19"), D("96.00")]
    assert j.stripe.refunds == []
    assert j.payout_events(payout["id"]).count("transfer_created") == 2  # one per transfer
    wallet = j.wallet(pro)
    assert (wallet.lifetime, wallet.paid_out, wallet.available, wallet.requested, wallet.reserved) == (
        D("102.19"), D("102.19"), D("0.00"), D("0.00"), D("0.00"))
    assert_wallet_balances(wallet)
    assert j.stripe.balance["eur"] == cents("25.55")
    assert j.mail.keys_to(client.email).count("payment.succeeded") == 2
    assert j.mail.keys_to(pro.email).count("payout.paid") == 1
    assert j.attention_items(booking) == []


def test_scenario_5_every_webhook_replayed_twice_credits_nothing_twice(journey):
    """Every event arrives twice as it happens (the same event id), then the
    whole history again with the same ids, then again under new event ids
    (the same objects, as a related or re-sent event carries them). The
    money is scenario 1's, exactly once."""
    j = journey()
    j.echo = True
    pro, client, booking, payout = _euros_to_payout(j)
    _assert_euro_outcome(j, pro, client, booking, payout)

    # account.updated, two payment_intent.succeeded, two transfer.created.
    assert [e["type"] for e in j.posted] == [
        "account.updated", "payment_intent.succeeded", "payment_intent.succeeded", "transfer.created", "transfer.created",
    ]
    assert j.replay_all(new_ids=False) == 5
    _assert_euro_outcome(j, pro, client, booking, payout)

    j.replay_all(new_ids=True)
    _assert_euro_outcome(j, pro, client, booking, payout)
    # The sweep and the payout worker running again change nothing either.
    j.settle()
    j.work()
    _assert_euro_outcome(j, pro, client, booking, payout)


@pytest.mark.xfail(
    raises=KnownBug, strict=True,
    reason="BETA_SCOPE #103: a re-sent payment_intent.succeeded for an extras purchase raises the download count again",
)
def test_scenario_5_probe_extras_bought_on_a_flat_priced_booking_are_counted_once(journey):
    """The extras purchase (upsell) branch of payment_intent.succeeded, on a
    booking priced the flat way: no entry rate, as on the legacy shoot path
    (every booking made through today's routes is curve-priced, so the gig's
    entry rate is cleared here to reach it). 5 extras are bought and paid;
    the success event is then re-sent under a new event id."""
    from app.models.media_rights import GigEntitlementType, GigMediaEntitlement

    j = journey()
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")
    booking = j.book(client, pro)
    j.checkout(client, booking)
    j.card_pays(booking.base_intent)
    gig = j.gig(booking)
    gig.entry_rate = None
    j.db.commit()

    j.deliver(pro, booking, 25)
    chosen = j.choose(client, booking, 25)
    assert chosen["submitted"]["upsell_required"] is True and chosen["submitted"]["extras_count"] == 5
    upsell_intent = chosen["submitted"]["payment_intent_id"]
    j.card_pays(upsell_intent)

    def extras_allowed() -> int:
        j.db.expire_all()
        row = j.db.execute(
            select(GigMediaEntitlement).where(
                GigMediaEntitlement.gig_id == uuid.UUID(booking.gig_id),
                GigMediaEntitlement.entitlement_type == GigEntitlementType.download_extras,
            )
        ).scalar_one()
        return int(row.quantity_limit)

    def extras_earnings() -> list:
        return [(e.source_type.value, e.gross) for e in j.entries(pro) if e.source_type.value == "extra_images"]

    assert j.stripe.intents[upsell_intent].amount == 2400  # 5 extras at 4.80
    paid_for = extras_allowed()
    earned = extras_earnings()
    assert paid_for == 5 and earned == [("extra_images", D("24.00"))]

    succeeded = [e for e in j.posted if e["type"] == "payment_intent.succeeded" and e["data"]["object"]["id"] == upsell_intent]
    j.send("payment_intent.succeeded", succeeded[0]["data"]["object"])  # the same payment, a new event id

    assert extras_earnings() == earned  # the money is counted once
    allowed = extras_allowed()
    known_bug(allowed == 5, f"after the re-sent event the client may download {allowed} extras; 5 were paid for")


def test_scenario_6_payment_failed_then_retried(journey):
    """The card is declined on the booking's payment and again on the
    difference; each time the client tries again and it goes through. The
    same PaymentIntent is reused each time (no second charge can exist), and
    the money ends as scenario 1's, exactly once."""
    j = journey()
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")
    booking = j.book(client, pro)

    first = j.checkout(client, booking)
    j.card_declined(booking.base_intent)
    gig = j.gig(booking)
    assert gig.status.value == "payment_pending"
    assert [(p.kind.value, p.status.value) for p in j.payments(booking)] == [("base", "failed")]
    assert j.captured(booking) == []
    assert j.mail.keys_to(client.email).count("payment.succeeded") == 0

    again = j.checkout(client, booking)
    assert again["payment_intent_id"] == first["payment_intent_id"]
    assert D(again["amount"]) == D("96.00")
    j.card_pays(booking.base_intent)
    assert j.gig(booking).status.value == "paid"
    assert [(p.kind.value, p.status.value, p.amount) for p in j.payments(booking)] == [("base", "succeeded", D("96.00"))]

    j.deliver(pro, booking, 30)
    j.choose(client, booking, 30)
    difference = booking.difference_intent
    j.card_declined(difference)
    assert j.gig(booking).status.value == "paid"  # not complete: the difference is unpaid
    assert j.entries(pro) == []
    # The client opens the selection again and pays: the same difference intent.
    resubmit = j.choose(client, booking, 30)
    assert resubmit["submitted"]["difference_payment_intent_id"] == difference
    assert D(resubmit["submitted"]["difference_amount"]) == D("31.74")
    j.card_pays(difference)

    j.review(client, booking)
    j.jump_past_settlement_delay(pro)
    j.settle()
    payout = j.request_payout(pro, D("102.19"))
    j.approve_payout(payout["id"])
    j.confirm_transfers()
    assert len(j.stripe.intents) == 2
    assert [c.amount for c in j.stripe.charges.values()] == [9600, 3174]
    _assert_euro_outcome(j, pro, client, booking, payout)
