"""Chargebacks, from Stripe's dispute - the source of truth - start to end.

Only charge.dispute.created was handled: the gig went to `disputed` and the
ledger took the amount off. Nothing handled the end. A lost chargeback left
the booking disputed for good, Stripe's fee (EUR 20 here) never reached the
ledger and the photographer was paid anyway; a won one left the deduction
in the ledger. Now any charge.dispute.* event only names the dispute; the
dispute is fetched from Stripe and our records reconciled to it - any order,
any repetition.

The ledger mirrors the dispute's balance transactions: the amount taken and
the fee when the funds are withdrawn, the amount put back when won (Stripe
keeps the fee even then), and a closing line when lost. Interim policy for
the beta: the platform absorbs a lost chargeback, recorded in the ledger and
as an admin item; the photographer's earnings are untouched unless an admin
recorded a photographer-fault finding on that booking. Lost ends the booking
as `refunded` - the client has their money back - with its finals revoked;
won gives it back as it was before.

The fixtures are a chargeback won and one lost in Stripe test mode
(tests/fixtures/stripe, chargeback_scenarios).
"""
import copy
import json
import random
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from pathlib import Path

import pytest
from app.api.v1.webhooks import _apply_stripe_event
from app.models.admin import MoneyAttentionItem, ProFaultEvent
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.models.media_rights import GigEntitlementType
from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType
from app.services.bookable_time import load_calendar
from app.services.media_rights import has_valid_entitlement, upsert_gig_entitlement
from sqlalchemy import select

from tests.test_refund_routes import _account

CAPTURE = json.loads((Path(__file__).parent / "fixtures" / "stripe" / "captured_events.json").read_text())
SCENARIOS = CAPTURE["chargeback_scenarios"]
CHARGEBACK_LEDGER = {
    LedgerEntryType.chargeback_opened, LedgerEntryType.chargeback_fee, LedgerEntryType.chargeback_won, LedgerEntryType.chargeback_lost,
}


class _StripeDisputes:
    """stripe.Dispute.retrieve, answering with what Stripe holds now."""

    def __init__(self):
        self.by_id: dict[str, dict] = {}

    def retrieve(self, dispute_id, **_kwargs):
        return copy.deepcopy(self.by_id[dispute_id])


@pytest.fixture
def stripe_disputes(monkeypatch):
    fake = _StripeDisputes()
    monkeypatch.setattr("app.services.chargebacks.stripe.Dispute.retrieve", fake.retrieve)
    return fake


def _renamed(scenario: dict, suffix: str) -> dict:
    text = json.dumps(scenario)
    ids = {scenario["payment_intent"], scenario["dispute"]["id"], scenario["dispute"]["charge"]}
    ids |= {bt["id"] for bt in scenario["dispute"]["balance_transactions"]}
    for old in ids:
        text = text.replace(old, f"{old}_{suffix}")
    return json.loads(text)


def _booking(db_session, scenario, *, status=GigStatus.paid):
    client_id, pro_id = _account(db_session), _account(db_session)
    amount = (Decimal(scenario["amount"]) / 100).quantize(Decimal("0.01"))
    start = datetime.now(timezone.utc).replace(microsecond=0) + timedelta(days=6)
    gig = Gig(
        client_user_id=uuid.UUID(client_id), pro_user_id=uuid.UUID(pro_id), status=status, currency="EUR",
        amount_minimum=amount, amount_platform_fee=Decimal("0.00"), amount_pro_gross=amount, meta={},
        scheduled_start=start, scheduled_end=start + timedelta(hours=2),
    )
    db_session.add(gig)
    db_session.flush()
    db_session.add(
        StripePayment(
            gig_id=gig.id, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
            stripe_payment_intent_id=scenario["payment_intent"], amount=amount, currency="EUR",
            meta={"paid_at": (datetime.now(timezone.utc) - timedelta(days=2)).isoformat()},
        )
    )
    db_session.add(
        EarningsLedgerEntry(
            pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.gig_base, source_id=gig.id,
            gross_eur=amount, platform_fee_eur=Decimal("0.00"), net_eur=amount, status=EarningsEntryStatus.pending,
            available_at=datetime.now(timezone.utc) + timedelta(days=7), meta={"fee_percent": "0"},
        )
    )
    for kind in (GigEntitlementType.download_finals, GigEntitlementType.download_extras):
        upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=gig.client_user_id, entitlement_type=kind)
    db_session.commit()
    return gig


def _deliver(db_session, stripe_disputes, events, *, truth: dict | None = None):
    """Each event, with Stripe holding the dispute as of that event - or, for
    a late delivery, as `truth` (its final state)."""
    for event in events:
        obj = event["data"]["object"]
        stripe_disputes.by_id[obj["id"]] = truth or obj
        _apply_stripe_event(db_session, event["type"], copy.deepcopy(obj))
        db_session.commit()
    db_session.expire_all()


def _state(db_session, gig):
    db_session.expire_all()
    g = db_session.get(Gig, gig.id)
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    ledger = sorted(
        (l.entry_type.value, str(l.amount))
        for l in db_session.execute(select(LedgerEntry).where(LedgerEntry.gig_id == gig.id)).scalars()
        if l.entry_type in CHARGEBACK_LEDGER
    )
    earnings = db_session.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_id == gig.id)).scalar_one()
    items = sorted(
        (i.kind, i.status, str(i.amount))
        for i in db_session.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id)).scalars()
    )
    finals = has_valid_entitlement(db_session, gig_id=gig.id, user_id=g.client_user_id, entitlement_type=GigEntitlementType.download_finals)
    return {"gig": g.status.value, "payment": payment.status.value, "ledger": ledger, "earnings": earnings.status.value, "attention": items, "finals": finals}


def _holds_time(db_session, gig) -> bool:
    db_session.expire_all()
    g = db_session.get(Gig, gig.id)
    cal = load_calendar(db_session, pro_user_id=g.pro_user_id, start=g.scheduled_start, end=g.scheduled_end)
    return any(b.gig_id == g.id for b in cal.bookings)


# --- the fixtures ----------------------------------------------------------------------------


def test_the_fixtures_are_a_real_won_and_a_real_lost_chargeback():
    assert SCENARIOS["won"]["dispute"]["status"] == "won"
    assert SCENARIOS["lost"]["dispute"]["status"] == "lost"
    for scenario in SCENARIOS.values():
        assert all(e["id"].startswith("evt_") and e["api_version"] == CAPTURE["api_versions"][0] for e in scenario["events"])


# --- open ------------------------------------------------------------------------------------


def test_an_open_chargeback_holds_the_booking_and_records_what_stripe_took(db_session, stripe_disputes):
    gig = _booking(db_session, SCENARIOS["lost"])
    opening = [e for e in SCENARIOS["lost"]["events"] if e["data"]["object"]["status"] not in ("lost", "won")]

    _deliver(db_session, stripe_disputes, opening)

    state = _state(db_session, gig)
    assert state["gig"] == "disputed" and state["payment"] == "disputed"
    assert state["ledger"] == [("chargeback_fee", "-20.00"), ("chargeback_opened", "-120.00")]
    assert ("chargeback_evidence_due", "open", "120.00") in state["attention"]
    assert _holds_time(db_session, gig)
    assert state["finals"] is True


def test_the_evidence_deadline_is_on_the_item(db_session, stripe_disputes):
    gig = _booking(db_session, SCENARIOS["lost"])
    first = SCENARIOS["lost"]["events"][0]

    _deliver(db_session, stripe_disputes, [first])

    [item] = db_session.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id)).scalars().all()
    due = datetime.fromtimestamp(first["data"]["object"]["evidence_details"]["due_by"], timezone.utc)
    assert item.kind == "chargeback_evidence_due"
    assert item.due_at == due


# --- lost ------------------------------------------------------------------------------------


def test_a_lost_chargeback_ends_the_booking_and_the_platform_absorbs_it(db_session, stripe_disputes):
    gig = _booking(db_session, SCENARIOS["lost"])

    _deliver(db_session, stripe_disputes, SCENARIOS["lost"]["events"])

    state = _state(db_session, gig)
    assert state["gig"] == "refunded", "over: the client has their money back, through their bank"
    assert state["ledger"] == [("chargeback_fee", "-20.00"), ("chargeback_lost", "0.00"), ("chargeback_opened", "-120.00")]
    assert state["finals"] is False
    assert state["earnings"] == "pending", "the photographer's earnings are untouched"
    assert ("chargeback_lost", "open", "140.00") in state["attention"], "amount and fee, absorbed"
    assert ("chargeback_evidence_due", "resolved", "120.00") in state["attention"]
    assert not _holds_time(db_session, gig)


def test_a_lost_chargeback_with_a_fault_finding_reverses_the_earnings(db_session, stripe_disputes):
    gig = _booking(db_session, SCENARIOS["lost"])
    db_session.add(ProFaultEvent(pro_user_id=gig.pro_user_id, gig_id=gig.id, dispute_id=None, kind="chargeback_at_fault", severity="high"))
    db_session.commit()

    _deliver(db_session, stripe_disputes, SCENARIOS["lost"]["events"])

    assert _state(db_session, gig)["earnings"] == "reversed"


# --- won -------------------------------------------------------------------------------------


@pytest.mark.parametrize("before", [GigStatus.paid, GigStatus.completed])
def test_a_won_chargeback_puts_it_all_back(db_session, stripe_disputes, before):
    gig = _booking(db_session, SCENARIOS["won"], status=before)

    _deliver(db_session, stripe_disputes, SCENARIOS["won"]["events"])

    state = _state(db_session, gig)
    assert state["gig"] == before.value
    assert state["payment"] == "succeeded"
    assert state["ledger"] == [("chargeback_fee", "-20.00"), ("chargeback_opened", "-120.00"), ("chargeback_won", "120.00")], "Stripe keeps the fee"
    assert state["finals"] is True and state["earnings"] == "pending"
    assert [a for a in state["attention"] if a[0] == "chargeback_lost"] == []
    assert ("chargeback_evidence_due", "resolved", "120.00") in state["attention"]


# --- any order, any repetition ---------------------------------------------------------------


@pytest.mark.parametrize("name", ["won", "lost"])
def test_any_order_and_any_repetition_ends_the_same(db_session, stripe_disputes, name):
    states = []
    for n, arrange in enumerate((list, lambda e: list(reversed(e)), lambda e: random.Random(3).sample(e, len(e)), lambda e: e + e)):
        scenario = _renamed(SCENARIOS[name], f"o{n}")
        gig = _booking(db_session, scenario)
        _deliver(db_session, stripe_disputes, arrange(list(scenario["events"])), truth=scenario["dispute"])
        states.append(_state(db_session, gig))
    assert all(s == states[0] for s in states), states


# --- no dispute of ours ---------------------------------------------------------------------


def test_no_dispute_record_of_ours_is_needed(db_session, stripe_disputes):
    from app.models.admin import Dispute

    gig = _booking(db_session, SCENARIOS["won"])
    _deliver(db_session, stripe_disputes, SCENARIOS["won"]["events"])

    assert db_session.execute(select(Dispute).where(Dispute.gig_id == gig.id)).scalars().all() == []
    assert _state(db_session, gig)["gig"] == "paid"


def test_a_line_from_before_is_taken_over_not_doubled(db_session, stripe_disputes):
    """chargeback.created wrote its line keyed on the dispute id."""
    scenario = SCENARIOS["lost"]
    gig = _booking(db_session, scenario)
    db_session.add(
        LedgerEntry(
            gig_id=gig.id, entry_type=LedgerEntryType.chargeback_opened, amount=Decimal("-120.00"), currency="EUR",
            description="Chargeback/dispute opened", reference_type="stripe_dispute", reference_id=scenario["dispute"]["id"],
        )
    )
    db_session.commit()

    _deliver(db_session, stripe_disputes, scenario["events"])

    assert [l for l in _state(db_session, gig)["ledger"] if l[0] == "chargeback_opened"] == [("chargeback_opened", "-120.00")]


def test_a_chargeback_on_a_payment_we_do_not_know_is_ignored(db_session, stripe_disputes):
    scenario = _renamed(SCENARIOS["lost"], "unknown")
    _deliver(db_session, stripe_disputes, scenario["events"])  # must not raise
