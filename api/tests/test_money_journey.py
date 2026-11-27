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


def _paid_euro_booking(j):
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")
    booking = j.book(client, pro)
    j.checkout(client, booking)
    j.card_pays(booking.base_intent)
    return pro, client, booking


def _pay_out_everything(j, pro, amount):
    j.jump_past_settlement_delay(pro)
    j.settle()
    payout = j.request_payout(pro, amount)
    j.approve_payout(payout["id"])
    j.confirm_transfers()
    return payout


def test_scenario_3a_fewer_photos_delivered_than_the_package_includes(journey):
    """The package includes 20 (96.00 paid); the photographer delivers 15.
    The client may then choose 15 (never fewer than 10): 15 x 4.80 = 72.00.
    The 24.00 not delivered is refunded under photographer_non_delivery, the
    earning follows the new price (72.00 = 10.80 + 3.60 + 57.60) and an
    admin is asked to review the short delivery."""
    j = journey()
    pro, client, booking = _paid_euro_booking(j)
    j.deliver(pro, booking, 15)
    chosen = j.choose(client, booking, 15)
    assert chosen["quote"]["minimum_photos"] == 15
    assert (D(chosen["quote"]["amount_total"]), D(chosen["quote"]["refund_amount"])) == (D("72.00"), D("24.00"))
    assert chosen["submitted"]["difference_required"] is False

    assert [(r.payment_intent, r.amount) for r in j.stripe.refunds] == [(booking.base_intent, 2400)]
    assert j.reductions(booking) == [
        ("selection", D("96.00"), D("72.00"), [("photographer_non_delivery", D("24.00"))], D("24.00")),
    ]
    assert j.attention_items(booking) == [("photographer_short_delivery", D("24.00"))]
    j.announce_refunds()
    assert j.refund_cases(booking) == [("refunded", D("24.00"))]
    assert [(p.kind.value, p.amount, p.amount_refunded) for p in j.payments(booking)] == [("base", D("96.00"), D("24.00"))]
    assert j.captured(booking) == [D("96.00")]

    gig = j.gig(booking)
    assert (gig.status.value, gig.amount_final, gig.final_gross) == ("completed", D("72.00"), D("72.00"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("10.80"), D("3.60"), D("57.60"))
    assert_split_reconciles(gig)
    assert [(e.source_type.value, e.gross, e.platform_fee, e.net) for e in j.entries(pro)] == [
        ("gig_base", D("72.00"), D("14.40"), D("57.60")),
    ]
    assert sum(r.amount for r in j.raww(pro)) == 36  # 3.60 at 0.10

    j.review(client, booking)
    payout = _pay_out_everything(j, pro, D("57.60"))
    assert [(t.source_transaction, t.amount) for t in j.stripe.transfers] == [
        (j.stripe.intents[booking.base_intent].latest_charge, 5760),
    ]
    wallet = j.wallet(pro)
    assert (wallet.paid_out, wallet.available) == (D("57.60"), D("0.00"))
    assert_wallet_balances(wallet)
    # 96.00 in, 24.00 back to the client, 57.60 to the photographer: 14.40 left.
    assert j.stripe.balance["eur"] == cents("14.40")
    j.replay_all(new_ids=True)
    assert len(j.stripe.refunds) == 1 and j.stripe.balance["eur"] == cents("14.40")
    assert [(e.gross, e.net) for e in j.entries(pro)] == [(D("72.00"), D("57.60"))]
    assert [t.amount for t in j.payout_transfers(payout["id"])] == [D("57.60")]


def test_scenario_3b_a_difference_paid_for_a_selection_that_became_cheaper(journey):
    """The client chooses 30 and confirms the 31.74 difference with their
    bank, which is still deciding; meanwhile they change to the 20 the
    package includes, which completes the booking at 96.00. The bank then
    says yes: the 31.74 is for photos already paid for, and goes straight
    back (duplicate_payment). The photographer earns on 96.00:
    14.40 + 4.80 + 76.80."""
    j = journey()
    pro, client, booking = _paid_euro_booking(j)
    j.deliver(pro, booking, 30)
    j.choose(client, booking, 30)
    stale = booking.difference_intent
    j.stripe.processing(stale)
    final = j.choose(client, booking, 20)
    assert final["submitted"]["difference_required"] is False
    gig = j.gig(booking)
    assert (gig.status.value, gig.amount_final) == ("completed", D("96.00"))
    assert j.stripe.refunds == []

    j.card_pays(stale)  # the bank's late yes
    assert [(r.payment_intent, r.amount) for r in j.stripe.refunds] == [(stale, 3174)]
    assert j.reductions(booking)[-1][3] == [("duplicate_payment", D("31.74"))]
    assert j.reductions(booking)[-1][4] == D("31.74")
    j.announce_refunds()
    assert [(p.kind.value, p.status.value, p.amount, p.amount_refunded) for p in j.payments(booking)] == [
        ("base", "succeeded", D("96.00"), D("0.00")), ("difference", "refunded", D("31.74"), D("31.74")),
    ]
    assert j.captured(booking) == [D("96.00"), D("31.74")]
    gig = j.gig(booking)
    assert (gig.amount_final, gig.final_gross) == (D("96.00"), D("96.00"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("14.40"), D("4.80"), D("76.80"))
    assert [(e.source_type.value, e.gross, e.net) for e in j.entries(pro)] == [("gig_base", D("96.00"), D("76.80"))]

    j.review(client, booking)
    _pay_out_everything(j, pro, D("76.80"))
    assert [t.amount for t in j.stripe.transfers] == [7680]
    assert j.stripe.balance["eur"] == cents("19.20")  # 127.74 in, 31.74 back, 76.80 out
    assert_wallet_balances(j.wallet(pro))


def _completed_euro_booking(j, photos=30):
    pro, client, booking = _paid_euro_booking(j)
    j.deliver(pro, booking, photos)
    j.choose(client, booking, photos)
    if booking.difference_intent:
        j.card_pays(booking.difference_intent)
    j.review(client, booking)
    return pro, client, booking


def test_scenario_4a_admin_price_reduction_after_completion(journey):
    """Completed at 127.74 (96.00 + 31.74). The admin lowers the price by
    20.00 (mutual_agreement): refunded from the most recent payment (the
    difference); the earning follows 107.74 = 16.16 + 5.39 + 86.19
    (16.161 and 5.387 rounded on their own). 86.19 is paid out. A second
    reduction of 10.00 after the payout takes the earning to 97.74 =
    14.66 + 4.89 + 78.19: 8.00 more was paid out than earned, shown as an
    adjustment owed, never as a negative withdrawable amount."""
    j = journey()
    pro, client, booking = _completed_euro_booking(j)
    path = f"/v1/admin/gigs/{booking.gig_id}/price-reductions"
    lines = [{"reason_code": "mutual_agreement", "amount": "20.00"}]

    preview = j.call("POST", f"{path}/preview", "admin", json={"lines": lines})
    assert (D(preview["from_amount"]), D(preview["to_amount"]), D(preview["client_refund"])) == (D("127.74"), D("107.74"), D("20.00"))
    assert (D(preview["photographer_cash_before"]), D(preview["photographer_cash_after"])) == (D("102.19"), D("86.19"))
    assert j.stripe.refunds == []  # a preview changes nothing

    done = j.call("POST", path, "admin", json={"lines": lines, "note": "Agreed with the client", "idempotency_key": "r1"})
    assert (D(done["from_amount"]), D(done["to_amount"]), D(done["refund_amount"])) == (D("127.74"), D("107.74"), D("20.00"))
    again = j.call("POST", path, "admin", json={"lines": lines, "note": "Agreed with the client", "idempotency_key": "r1"})
    assert again["id"] == done["id"]  # the same click twice is one reduction
    assert [(r.payment_intent, r.amount) for r in j.stripe.refunds] == [(booking.difference_intent, 2000)]
    j.announce_refunds()
    assert [(p.kind.value, p.amount_refunded) for p in j.payments(booking)] == [("base", D("0.00")), ("difference", D("20.00"))]
    assert j.captured(booking) == [D("96.00"), D("31.74")]
    gig = j.gig(booking)
    assert (gig.amount_final, gig.final_gross) == (D("107.74"), D("107.74"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("16.16"), D("5.39"), D("86.19"))
    assert [(e.gross, e.platform_fee, e.net) for e in j.entries(pro)] == [(D("107.74"), D("21.55"), D("86.19"))]
    assert sum(r.amount for r in j.raww(pro)) == 54  # 5.39 at 0.10

    payout = _pay_out_everything(j, pro, D("86.19"))
    assert [(t.source_transaction, t.amount) for t in j.stripe.transfers] == [
        (j.stripe.intents[booking.base_intent].latest_charge, 8619),
    ]
    assert j.stripe.balance["eur"] == cents("21.55")

    j.call("POST", path, "admin", json={"lines": [{"reason_code": "mutual_agreement", "amount": "10.00"}],
                                        "note": "A second agreement", "idempotency_key": "r2"})
    j.announce_refunds()
    assert [(r.payment_intent, r.amount) for r in j.stripe.refunds] == [(booking.difference_intent, 2000), (booking.difference_intent, 1000)]
    gig = j.gig(booking)
    assert (gig.final_gross, gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (
        D("97.74"), D("14.66"), D("4.89"), D("78.19"))
    wallet = j.wallet(pro)
    assert (wallet.lifetime, wallet.paid_out, wallet.available) == (D("78.19"), D("86.19"), D("-8.00"))
    assert (wallet.withdrawable, wallet.adjustment_owed) == (D("0.00"), D("8.00"))
    assert_wallet_balances(wallet)
    assert j.request_payout(pro, D("45.00"), expect=422)["error"]["code"] == "validation_error"
    assert [t.amount for t in j.payout_transfers(payout["id"])] == [D("86.19")]  # nothing sent back or again
    assert j.stripe.balance["eur"] == cents("11.55")


def test_scenario_4b_admin_refund_on_a_paid_booking_not_yet_complete(journey):
    """Paid 96.00; before delivery the admin refunds 30.00. The client then
    chooses the 20 the package includes: the price stays 96.00, but the
    booking earns what was kept, 66.00 = 9.90 + 3.30 + 52.80."""
    j = journey()
    pro, client, booking = _paid_euro_booking(j)
    case = j.call("POST", f"/v1/admin/gigs/{booking.gig_id}/refunds", "admin", json={"amount": "30.00", "reason": "Agreed partial refund"})
    assert (case["status"], D(case["amount"])) == ("processing", D("30.00"))
    assert [(r.payment_intent, r.amount) for r in j.stripe.refunds] == [(booking.base_intent, 3000)]
    twice = j.call("POST", f"/v1/admin/gigs/{booking.gig_id}/refunds", "admin", json={"amount": "30.00", "reason": "Agreed partial refund"})
    assert twice["id"] == case["id"] and len(j.stripe.refunds) == 1  # a second click while it is under way
    j.announce_refunds()
    assert j.captured(booking) == [D("96.00")]
    assert j.refund_cases(booking) == [("refunded", D("30.00"))]
    assert [(p.kind.value, p.status.value, p.amount_refunded) for p in j.payments(booking)] == [("base", "succeeded", D("30.00"))]
    assert j.gig(booking).status.value == "paid"

    j.deliver(pro, booking, 20)
    j.choose(client, booking, 20)
    gig = j.gig(booking)
    assert (gig.status.value, gig.amount_final, gig.final_gross) == ("completed", D("96.00"), D("66.00"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("9.90"), D("3.30"), D("52.80"))
    assert_split_reconciles(gig)
    assert [(e.gross, e.net) for e in j.entries(pro)] == [(D("66.00"), D("52.80"))]
    assert len(j.stripe.refunds) == 1  # completing refunds nothing more

    j.review(client, booking)
    _pay_out_everything(j, pro, D("52.80"))
    assert [t.amount for t in j.stripe.transfers] == [5280]
    assert j.stripe.balance["eur"] == cents("13.20")  # 96.00 - 30.00 - 52.80
    assert_wallet_balances(j.wallet(pro))


def test_scenario_7_client_credit_comes_out_of_the_platforms_share(journey):
    """The client holds 15.00 of credit (1,500 points, from marketing
    permissions on an earlier booking). At checkout it takes off at most 10%
    of the 96.00 price: 9.60, so the card pays 86.40 and 5.40 of credit is
    left. The photographer is paid on the full price (96.00 = 14.40 +
    4.80 + 76.80); the 9.60 comes out of the platform's share: Stripe keeps
    86.40 - 76.80 = 9.60, not 19.20."""
    from app.models.reward import RewardEntryType
    from app.services.client_credit import balance_points
    from app.services.rewards import add_reward_entry

    j = journey()
    j.open_city()
    j.set_price_cap()
    pro = j.photographer()
    client = j.sign_up("client")
    booking = j.book(client, pro)
    # The credit, as a marketing permission awards it (that flow is tested in
    # test_marketing_consent_*); written here.
    add_reward_entry(j.db, user_id=uuid.UUID(client.user_id), amount=1500, entry_type=RewardEntryType.earn,
                     reference_type="marketing_consent", reference_id=booking.gig_id, currency="EUR")
    j.db.commit()

    preview = j.call("GET", f"/v1/client/bookings/{booking.request_id}/credit", client)
    assert (D(preview["discount"]), D(preview["total"])) == (D("9.60"), D("86.40"))
    pay = j.checkout(client, booking, use_credit=True)
    assert (D(pay["amount"]), D(pay["credit"])) == (D("86.40"), D("9.60"))
    assert j.stripe.intents[booking.base_intent].amount == 8640
    j.card_pays(booking.base_intent)
    assert balance_points(j.db, uuid.UUID(client.user_id), "EUR") == 540
    assert j.captured(booking) == [D("86.40")]  # the card's money; the credit is not cash

    j.deliver(pro, booking, 20)
    j.choose(client, booking, 20)
    gig = j.gig(booking)
    assert (gig.status.value, gig.amount_final, gig.final_gross) == ("completed", D("96.00"), D("96.00"))
    assert (gig.final_platform_retained, gig.final_pro_raww, gig.final_pro_cash) == (D("14.40"), D("4.80"), D("76.80"))
    assert [(e.gross, e.net) for e in j.entries(pro)] == [(D("96.00"), D("76.80"))]
    assert sum(r.amount for r in j.raww(pro)) == 48
    assert j.stripe.refunds == []  # the credit is not "overpaid" money

    j.review(client, booking)
    _pay_out_everything(j, pro, D("76.80"))
    assert [(t.source_transaction, t.amount) for t in j.stripe.transfers] == [
        (j.stripe.intents[booking.base_intent].latest_charge, 7680),
    ]
    assert j.stripe.balance["eur"] == cents("9.60")  # 14.40 + 4.80 - 9.60 of credit
    assert_wallet_balances(j.wallet(pro))
