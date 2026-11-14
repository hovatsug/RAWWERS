"""Multi-currency M7: one transfer per client payment, each sent from that
payment's charge (`source_transaction`) - docs/MULTI_CURRENCY.md 10.4,
services/payout_transfers.py.

Hand-computed, at the 20% fee: a £100.00 booking earns the photographer
£80.00, a £50.00 booking £40.00, a £150.00 one £120.00."""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.api.v1.webhooks import _apply_stripe_event
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.payouts import (
    EarningsSourceType,
    PayoutAccountStatus,
    PayoutMethod,
    PayoutRequestStatus,
    PayoutTransfer,
    PayoutTransferStatus,
)
from app.services import payout_transfers, payouts as payouts_service
from app.services.payouts import (
    approve_payout_request,
    create_earnings_entry,
    create_payout_request,
    execute_payout_request,
    retry_payout_transfers,
    settle_due_earnings_entries,
)
from app.services.photographer_money import photographer_money

D = Decimal


class FakeTransfers:
    """Stripe's Transfer, Balance and PaymentIntent, recorded."""

    def __init__(self):
        self.creates: list[dict] = []
        self.fail_on: set[int] = set()  # create call numbers (1-based) that raise
        self.listed: list[dict] = []  # what Transfer.list returns
        self.balance: dict[str, int] = {}
        self.retrieved: list[str] = []

    def create(self, **kw):
        self.creates.append(kw)
        if len(self.creates) in self.fail_on:
            raise RuntimeError("Stripe said no")
        return type("T", (), {"id": f"tr_{len(self.creates)}"})()

    def list(self, **kw):
        return {"data": self.listed}

    def balance_retrieve(self, **kw):
        return {"available": [{"currency": c, "amount": a} for c, a in self.balance.items()]}

    def intent_retrieve(self, pi_id, **kw):
        self.retrieved.append(pi_id)
        return {"id": pi_id, "latest_charge": f"ch_from_{pi_id}"}


@pytest.fixture
def stripe_fake(monkeypatch) -> FakeTransfers:
    fake = FakeTransfers()
    monkeypatch.setattr("stripe.Transfer.create", fake.create)
    monkeypatch.setattr("stripe.Transfer.list", fake.list)
    monkeypatch.setattr("stripe.Balance.retrieve", fake.balance_retrieve)
    monkeypatch.setattr("stripe.PaymentIntent.retrieve", fake.intent_retrieve)
    return fake


def _pro(db) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db.flush()
    db.add(UserRole(user_id=uid, role=UserRoleType.pro))
    db.add(ProProfile(user_id=uid, display_name="Mo", country="GB"))
    db.flush()
    account = payouts_service.get_or_create_payout_account(db, pro_user_id=uid)
    account.payout_method = PayoutMethod.stripe_connect
    account.status = PayoutAccountStatus.active
    account.stripe_connect_account_id = "acct_gb"
    account.updated_at = datetime.now(timezone.utc) - timedelta(days=3)  # not just changed (payout anomaly rule)
    db.commit()
    return uid


def _admin(db) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db.flush()
    db.add(UserRole(user_id=uid, role=UserRoleType.admin))
    db.commit()
    return uid


def _payment(db, gig, amount: str, *, kind=StripePaymentKind.base, charge: str | None = "auto", minutes=0) -> StripePayment:
    payment = StripePayment(
        gig_id=gig.id, kind=kind, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
        stripe_payment_intent_id=f"pi_{uuid.uuid4().hex}", amount=D(amount), amount_refunded=D("0.00"), currency="GBP",
        stripe_charge_id=(f"ch_{uuid.uuid4().hex[:10]}" if charge == "auto" else charge), meta={},
        created_at=datetime.now(timezone.utc) + timedelta(minutes=minutes),
    )
    db.add(payment)
    db.flush()
    return payment


def _booking(db, pro, price: str, *, paid: list[str] | None = None, charge="auto") -> tuple[Gig, list[StripePayment]]:
    """A completed £ booking paid by `paid` (the base payment, then
    differences), with its earning available."""
    client = uuid.uuid4()
    db.add(UserAccount(user_id=client))
    db.flush()
    gig = Gig(client_user_id=client, pro_user_id=pro, status=GigStatus.completed, currency="GBP", amount_minimum=D(price),
              amount_final=D(price), amount_platform_fee=D("0.00"), amount_pro_gross=D("0.00"), meta={})
    db.add(gig)
    db.flush()
    payments = [
        _payment(db, gig, amount, kind=StripePaymentKind.base if i == 0 else StripePaymentKind.difference, charge=charge, minutes=i)
        for i, amount in enumerate(paid or [price])
    ]
    entry = create_earnings_entry(
        db, pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=gig.id, gross=D(price), currency="GBP",
        stripe_payment_id=payments[0].id,
    )
    entry.available_at = datetime.now(timezone.utc) - timedelta(days=1)
    db.flush()
    settle_due_earnings_entries(db)
    db.commit()
    return gig, payments


def _unfunded_earning(db, pro, gross: str) -> None:
    """An earning with no payment of ours behind it (a legacy upsell)."""
    entry = create_earnings_entry(
        db, pro_user_id=pro, source_type=EarningsSourceType.extra_images, source_id=uuid.uuid4(), gross=D(gross), currency="GBP"
    )
    entry.available_at = datetime.now(timezone.utc) - timedelta(days=1)
    db.flush()
    settle_due_earnings_entries(db)
    db.commit()


def _approved(db, pro, amount: str):
    row = create_payout_request(db, pro_user_id=pro, amount=D(amount))
    approve_payout_request(db, payout_request_id=row.id, admin_user_id=_admin(db))
    db.commit()
    return row


def _rows(db, payout) -> list[PayoutTransfer]:
    return payout_transfers.transfers_of(db, payout.id)


# --- one transfer per payment, from its charge ----------------------------------------------------


def test_a_payout_is_sent_from_the_bookings_charge(db_session, stripe_fake):
    pro = _pro(db_session)
    _gig, [payment] = _booking(db_session, pro, "100.00")
    payout = _approved(db_session, pro, "80.00")

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert payout.status == PayoutRequestStatus.paid
    [sent] = stripe_fake.creates
    assert sent["source_transaction"] == payment.stripe_charge_id
    assert (sent["amount"], sent["currency"], sent["destination"]) == (8000, "gbp", "acct_gb")
    assert sent["idempotency_key"] == f"payout-transfer:{payout.id}:{payment.id}"
    [row] = _rows(db_session, payout)
    assert (row.status, row.amount, row.stripe_transfer_id, row.stripe_charge_id) == (
        PayoutTransferStatus.paid, D("80.00"), "tr_1", payment.stripe_charge_id
    )


def test_two_bookings_make_two_transfers_each_from_its_own_charge(db_session, stripe_fake):
    pro = _pro(db_session)
    _g1, [p1] = _booking(db_session, pro, "100.00")  # earns £80.00
    _g2, [p2] = _booking(db_session, pro, "100.00")  # earns £80.00
    payout = _approved(db_session, pro, "100.00")  # oldest first: £80.00, then £20.00 of the second £80.00

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert payout.status == PayoutRequestStatus.paid
    by_charge = {c["source_transaction"]: c["amount"] for c in stripe_fake.creates}
    assert by_charge == {p1.stripe_charge_id: 8000, p2.stripe_charge_id: 2000}
    assert sorted(payout.reference["stripe_transfer_ids"]) == ["tr_1", "tr_2"]

    # The rest of the second booking's earning, in the next payout, from the same charge.
    stripe_fake.creates.clear()
    later = _approved(db_session, pro, "60.00")
    execute_payout_request(db_session, payout_request_id=later.id)
    [sent] = stripe_fake.creates
    assert (sent["source_transaction"], sent["amount"]) == (p2.stripe_charge_id, 6000)


def test_a_booking_paid_in_two_payments_draws_on_the_first_then_the_second(db_session, stripe_fake):
    pro = _pro(db_session)
    # £150.00 earns £120.00: £100.00 is all the base charge holds, £20.00 from the difference.
    _gig, [base, diff] = _booking(db_session, pro, "150.00", paid=["100.00", "50.00"])
    payout = _approved(db_session, pro, "120.00")

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert payout.status == PayoutRequestStatus.paid
    by_charge = {c["source_transaction"]: c["amount"] for c in stripe_fake.creates}
    assert by_charge == {base.stripe_charge_id: 10000, diff.stripe_charge_id: 2000}


def test_a_payment_without_its_charge_recorded_reads_it_from_stripe_once(db_session, stripe_fake):
    pro = _pro(db_session)
    _gig, [payment] = _booking(db_session, pro, "100.00", charge=None)
    payout = _approved(db_session, pro, "80.00")

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert stripe_fake.retrieved == [payment.stripe_payment_intent_id]
    assert stripe_fake.creates[0]["source_transaction"] == f"ch_from_{payment.stripe_payment_intent_id}"
    assert payment.stripe_charge_id == f"ch_from_{payment.stripe_payment_intent_id}"


def test_the_payment_webhook_records_the_charge(db_session):
    pro = _pro(db_session)
    client = uuid.uuid4()
    db_session.add(UserAccount(user_id=client))
    db_session.flush()
    gig = Gig(client_user_id=client, pro_user_id=pro, status=GigStatus.payment_pending, currency="GBP", amount_minimum=D("100.00"),
              amount_platform_fee=D("0.00"), amount_pro_gross=D("0.00"), meta={})
    db_session.add(gig)
    db_session.flush()
    payment = StripePayment(gig_id=gig.id, kind=StripePaymentKind.base, client_user_id=client, status=PaymentStatus.pending,
                            stripe_payment_intent_id="pi_charge_rec", amount=D("100.00"), currency="GBP", meta={})
    db_session.add(payment)
    db_session.commit()

    _apply_stripe_event(
        db_session, "payment_intent.succeeded",
        {"id": "pi_charge_rec", "amount_received": 10000, "currency": "gbp", "latest_charge": "ch_recorded", "metadata": {}},
    )
    assert payment.stripe_charge_id == "ch_recorded"


# --- the invariant: never more from a charge than is left of it ---------------------------------


def test_a_charge_that_cannot_cover_its_earnings_stops_the_payout_before_anything_is_sent(db_session, stripe_fake):
    pro = _pro(db_session)
    _gig, [payment] = _booking(db_session, pro, "100.00")
    payout = _approved(db_session, pro, "80.00")
    payment.amount_refunded = D("30.00")  # a bug upstream: £70.00 left on the charge for an £80.00 earning
    db_session.flush()

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert stripe_fake.creates == []
    assert _rows(db_session, payout) == []  # stopped at planning: nothing written
    assert payout.status == PayoutRequestStatus.failed
    assert payout.failure_reason.startswith("transfer_invariant_breach")


def test_a_refund_after_planning_stops_the_transfer_at_sending(db_session, stripe_fake):
    pro = _pro(db_session)
    _gig, [payment] = _booking(db_session, pro, "100.00")
    payout = _approved(db_session, pro, "80.00")
    payout_transfers.plan_transfers(db_session, payout)
    payment.amount_refunded = D("30.00")
    db_session.flush()

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert stripe_fake.creates == []
    assert payout.status == PayoutRequestStatus.failed
    assert "transfer_invariant_breach" in payout.failure_reason


# --- a failed transfer is retried alone; the money stays reserved ---------------------------------


def test_one_failed_transfer_keeps_the_payout_reserved_and_is_retried_alone(db_session, stripe_fake):
    pro = _pro(db_session)
    _g1, [p1] = _booking(db_session, pro, "100.00")
    _g2, [p2] = _booking(db_session, pro, "50.00")
    payout = _approved(db_session, pro, "120.00")
    stripe_fake.fail_on = {2}

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert payout.status == PayoutRequestStatus.processing
    statuses = sorted(r.status.value for r in _rows(db_session, payout))
    assert statuses == ["failed", "paid"]
    money = photographer_money(db_session, pro)
    assert (money.reserved, money.available) == (D("120.00"), D("0.00"))  # never asked for twice

    failed = next(r for r in _rows(db_session, payout) if r.status == PayoutTransferStatus.failed)
    retry_payout_transfers(db_session, payout_request_id=payout.id)

    assert payout.status == PayoutRequestStatus.paid
    assert len(stripe_fake.creates) == 3  # the paid one was not sent again
    third = stripe_fake.creates[2]
    assert third["source_transaction"] == db_session.get(StripePayment, failed.stripe_payment_id).stripe_charge_id
    assert third["idempotency_key"] == f"payout-transfer:{payout.id}:{failed.stripe_payment_id}:retry1"


def test_a_retry_after_a_timeout_that_went_through_does_not_send_twice(db_session, stripe_fake):
    pro = _pro(db_session)
    _booking(db_session, pro, "100.00")
    _booking(db_session, pro, "50.00")
    payout = _approved(db_session, pro, "120.00")
    stripe_fake.fail_on = {1}  # a timeout: recorded as failed, but Stripe made it
    execute_payout_request(db_session, payout_request_id=payout.id)
    assert payout.status == PayoutRequestStatus.processing
    failed = next(r for r in _rows(db_session, payout) if r.status == PayoutTransferStatus.failed)

    stripe_fake.listed = [{"id": "tr_ghost", "metadata": {"payout_transfer_id": str(failed.id)}, "reversed": False}]
    retry_payout_transfers(db_session, payout_request_id=payout.id)

    assert len(stripe_fake.creates) == 2  # nothing sent a second time
    assert (failed.status, failed.stripe_transfer_id) == (PayoutTransferStatus.paid, "tr_ghost")
    assert payout.status == PayoutRequestStatus.paid


def test_only_a_payout_with_a_failed_or_waiting_transfer_can_be_retried(db_session, stripe_fake, client):
    pro = _pro(db_session)
    _booking(db_session, pro, "100.00")
    payout = _approved(db_session, pro, "80.00")
    execute_payout_request(db_session, payout_request_id=payout.id)
    db_session.commit()

    admin = _admin(db_session)
    resp = client.post(f"/v1/admin/payouts/{payout.id}/retry-transfers", headers={"X-User-Id": str(admin)})
    assert resp.status_code == 409


# --- no payment behind it: only from a balance that covers it -------------------------------------


def test_an_unfunded_earning_waits_when_the_balance_is_short_then_goes(db_session, stripe_fake):
    pro = _pro(db_session)
    _unfunded_earning(db_session, pro, "100.00")  # £80.00 to the photographer
    stripe_fake.balance = {"gbp": 7999}
    payout = _approved(db_session, pro, "80.00")

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert stripe_fake.creates == []
    [row] = _rows(db_session, payout)
    assert (row.status, row.stripe_payment_id) == (PayoutTransferStatus.waiting_funds, None)
    assert payout.status == PayoutRequestStatus.processing  # waits, its money reserved

    stripe_fake.balance = {"gbp": 8000}
    retry_payout_transfers(db_session, payout_request_id=payout.id)

    [sent] = stripe_fake.creates
    assert "source_transaction" not in sent
    assert (sent["amount"], sent["idempotency_key"]) == (8000, f"payout-transfer:{payout.id}:unfunded")
    assert payout.status == PayoutRequestStatus.paid


def test_a_balance_in_another_currency_does_not_cover_an_unfunded_pound_transfer(db_session, stripe_fake):
    pro = _pro(db_session)
    _unfunded_earning(db_session, pro, "100.00")
    stripe_fake.balance = {"eur": 10_000_000}
    payout = _approved(db_session, pro, "80.00")

    execute_payout_request(db_session, payout_request_id=payout.id)

    assert stripe_fake.creates == []
    assert payout.status == PayoutRequestStatus.processing


# --- the webhooks, per transfer ------------------------------------------------------------------


def test_transfer_created_confirms_one_transfer_and_the_payout_only_when_all_are(db_session, stripe_fake):
    pro = _pro(db_session)
    _booking(db_session, pro, "100.00")
    _booking(db_session, pro, "50.00")
    payout = _approved(db_session, pro, "120.00")
    first, second = payout_transfers.plan_transfers(db_session, payout)
    payout.status = PayoutRequestStatus.processing
    db_session.commit()

    _apply_stripe_event(db_session, "transfer.created", {"id": "tr_a", "metadata": {"payout_request_id": str(payout.id), "payout_transfer_id": str(first.id)}})
    assert (first.status, payout.status) == (PayoutTransferStatus.paid, PayoutRequestStatus.processing)

    _apply_stripe_event(db_session, "transfer.created", {"id": "tr_b", "metadata": {"payout_request_id": str(payout.id), "payout_transfer_id": str(second.id)}})
    assert payout.status == PayoutRequestStatus.paid
    assert payout.reference["stripe_transfer_ids"] == ["tr_a", "tr_b"]


def test_one_reversed_transfer_of_two_keeps_the_payout_reserved(db_session, stripe_fake):
    pro = _pro(db_session)
    _booking(db_session, pro, "100.00")
    _booking(db_session, pro, "50.00")
    payout = _approved(db_session, pro, "120.00")
    execute_payout_request(db_session, payout_request_id=payout.id)
    first, _second = _rows(db_session, payout)
    db_session.commit()

    _apply_stripe_event(
        db_session, "transfer.reversed",
        {"id": first.stripe_transfer_id, "reversed": True, "metadata": {"payout_request_id": str(payout.id), "payout_transfer_id": str(first.id)}},
    )

    assert first.status == PayoutTransferStatus.reversed
    assert payout.status == PayoutRequestStatus.processing  # the other part is still sent: not released
    assert photographer_money(db_session, pro).available == D("0.00")


def test_earnings_are_tied_to_the_payment_they_came_from(db_session):
    from app.models.payouts import EarningsLedgerEntry
    from app.services.photographer_money import booking_payment_id, record_gig_earnings

    pro = _pro(db_session)
    client = uuid.uuid4()
    db_session.add(UserAccount(user_id=client))
    db_session.flush()
    gig = Gig(client_user_id=client, pro_user_id=pro, status=GigStatus.completed, currency="GBP", amount_minimum=D("100.00"),
              amount_final=D("100.00"), amount_platform_fee=D("0.00"), amount_pro_gross=D("0.00"), meta={},
              retained_percent=15, pro_raww_percent=5, client_credit_percent=0)
    db_session.add(gig)
    db_session.flush()
    payment = _payment(db_session, gig, "100.00")
    record_gig_earnings(db_session, gig)  # the one place a booking's earning is written

    entry = db_session.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_id == gig.id)).scalar_one()
    assert entry.stripe_payment_id == payment.id == booking_payment_id(db_session, gig)


def test_the_admin_queue_shows_what_is_left_to_send_and_the_route_sends_it(db_session, stripe_fake, client):
    pro = _pro(db_session)
    _booking(db_session, pro, "100.00")
    _booking(db_session, pro, "100.00")
    payout = _approved(db_session, pro, "160.00")
    stripe_fake.fail_on = {2}
    execute_payout_request(db_session, payout_request_id=payout.id)
    db_session.commit()
    admin = {"X-User-Id": str(_admin(db_session))}

    [row] = [r for r in client.get("/v1/admin/payouts/queue", headers=admin).json()["items"] if r["payout_request_id"] == str(payout.id)]
    assert (row["status"], row["transfers_to_retry"]) == ("processing", 1)
    assert "Stripe said no" in row["failure_reason"]

    resp = client.post(f"/v1/admin/payouts/{payout.id}/retry-transfers", headers=admin)
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "paid"
    assert len(stripe_fake.creates) == 3
