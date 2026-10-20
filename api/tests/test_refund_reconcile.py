"""Refund events: Stripe is the source of truth, replayed from real events.

The fixtures are real Stripe test-mode events (tests/fixtures/stripe), with
the API version they were rendered in. What Stripe "says" at any point in a
scenario is rebuilt from those same events: the latest version of each
refund object delivered so far.

The handler no longer trusts an event's payload. Any refund-related event
only names the payment; the payment's refunds are then fetched from Stripe
and our records reconciled to them - so the order events arrive in, and how
often, cannot change the outcome. Before, charge.refunded (which carries no
refund id on our API version) recorded only the first of several partial
refunds, admin refund cases never settled, and a refund that failed left the
booking refunded, the ledger claiming the money had gone back, and nobody
told the client was still owed.
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
from app.models.admin import MoneyAttentionItem, RefundCase, RefundCaseStatus, RefundPaymentScope
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType
from sqlalchemy import select

from tests.test_refund_routes import _account

CAPTURE = json.loads((Path(__file__).parent / "fixtures" / "stripe" / "captured_events.json").read_text())
SCENARIOS = CAPTURE["refund_scenarios"]
REFUND_OBJECT_EVENTS = {"refund.created", "refund.updated", "refund.failed", "charge.refund.updated"}


def _refund_truth(events) -> list[dict]:
    """Stripe's refunds for the payment, as of the last of these events."""
    latest: dict[str, dict] = {}
    for event in events:
        if event["type"] in REFUND_OBJECT_EVENTS:
            obj = event["data"]["object"]
            latest[obj["id"]] = obj  # a later delivery is a later version
    return sorted(latest.values(), key=lambda r: (r["created"], r["id"]))


def _renamed(scenario: dict, suffix: str) -> dict:
    """The same scenario under fresh payment and refund ids, so several
    bookings can replay it side by side."""
    text = json.dumps(scenario)
    ids = {scenario["payment_intent"]} | {r["id"] for r in scenario["refunds"]}
    for old in ids:
        text = text.replace(old, f"{old}_{suffix}")
    return json.loads(text)


class _StripeRefunds:
    """stripe.Refund.list, answering with whatever Stripe holds now."""

    def __init__(self):
        self.by_intent: dict[str, list[dict]] = {}
        self.calls = 0

    def list(self, payment_intent=None, **_kwargs):
        self.calls += 1
        data = copy.deepcopy(self.by_intent.get(payment_intent, []))
        return type("RefundList", (), {"data": data, "auto_paging_iter": lambda self: iter(data)})()


@pytest.fixture
def stripe_truth(monkeypatch):
    fake = _StripeRefunds()
    monkeypatch.setattr("app.services.refund_reconcile.stripe.Refund.list", fake.list)
    return fake


def _booking(db_session, scenario, *, status=GigStatus.paid, earnings=True):
    client_id, pro_id = _account(db_session), _account(db_session)
    amount = (Decimal(scenario["amount"]) / 100).quantize(Decimal("0.01"))
    gig = Gig(
        client_user_id=uuid.UUID(client_id), pro_user_id=uuid.UUID(pro_id), status=status, currency="EUR",
        amount_minimum=amount, amount_platform_fee=Decimal("0.00"), amount_pro_gross=amount, meta={},
    )
    db_session.add(gig)
    db_session.flush()
    db_session.add(
        StripePayment(
            gig_id=gig.id, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
            stripe_payment_intent_id=scenario["payment_intent"], amount=amount, currency="EUR",
            meta={"paid_at": (datetime.now(timezone.utc) - timedelta(hours=2)).isoformat()},
        )
    )
    if earnings:
        db_session.add(
            EarningsLedgerEntry(
                pro_user_id=gig.pro_user_id, source_type=EarningsSourceType.gig_base, source_id=gig.id,
                gross_eur=amount, platform_fee_eur=Decimal("0.00"), net_eur=amount, status=EarningsEntryStatus.pending,
                available_at=datetime.now(timezone.utc) + timedelta(days=7), meta={"fee_percent": "0"},
            )
        )
    db_session.commit()
    return gig


def _our_case(db_session, gig, refund, *, status=RefundCaseStatus.processing, source="admin"):
    """A refund case our own route wrote when it asked Stripe for this refund."""
    case = RefundCase(
        gig_id=gig.id, requested_by_user_id=gig.client_user_id, payment_scope=RefundPaymentScope.booking_payment,
        reference_id=gig.id, stripe_payment_intent_id=refund["payment_intent"], status=status,
        amount=(Decimal(refund["amount"]) / 100).quantize(Decimal("0.01")), currency="EUR", amount_refunded=Decimal("0.00"),
        meta={"stripe_refund_id": refund["id"], "source": source},
    )
    db_session.add(case)
    db_session.commit()
    return case


def _deliver(db_session, stripe_truth, events, *, truth_from=None):
    """Deliver events one by one; Stripe answers with what it holds at that
    point (truth_from: all events of the scenario, i.e. a late delivery)."""
    for i, event in enumerate(events):
        pi = event["data"]["object"].get("payment_intent")
        stripe_truth.by_intent[pi] = _refund_truth(truth_from if truth_from is not None else events[: i + 1])
        _apply_stripe_event(db_session, event["type"], copy.deepcopy(event["data"]["object"]))
        db_session.commit()
    db_session.expire_all()


def _state(db_session, gig):
    db_session.expire_all()
    payment = db_session.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one()
    ledger = sorted(
        (l.entry_type.value, str(l.amount), l.reference_id)
        for l in db_session.execute(select(LedgerEntry).where(LedgerEntry.gig_id == gig.id)).scalars()
        if l.entry_type in (LedgerEntryType.refund_succeeded, LedgerEntryType.refund_failed)
    )
    cases = sorted(
        (str(c.amount), c.status.value, (c.meta or {}).get("stripe_refund_id"), (c.meta or {}).get("source"))
        for c in db_session.execute(select(RefundCase).where(RefundCase.gig_id == gig.id)).scalars()
    )
    earnings = db_session.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_id == gig.id)).scalar_one_or_none()
    items = sorted(
        (i.kind, str(i.amount), i.stripe_refund_id)
        for i in db_session.execute(select(MoneyAttentionItem).where(MoneyAttentionItem.gig_id == gig.id)).scalars()
    )
    return {
        "payment": (payment.status.value, str(payment.amount_refunded)),
        "gig": db_session.get(Gig, gig.id).status.value,
        "ledger": ledger,
        "cases": cases,
        "earnings": (earnings.status.value, str(earnings.gross_eur)) if earnings else None,
        "attention": items,
    }


def _events(name):
    return SCENARIOS[name]["events"]


def _refunds(name):
    return SCENARIOS[name]["refunds"]


# --- the fixtures are what they claim ------------------------------------------------------


def test_the_fixtures_are_real_captured_events_with_their_api_version():
    assert CAPTURE["mode"] == "test"
    assert CAPTURE["api_versions"] and all(v for v in CAPTURE["api_versions"])
    for name, scenario in SCENARIOS.items():
        for event in scenario["events"]:
            assert event["id"].startswith("evt_") and event["object"] == "event", name
            assert event["api_version"] in CAPTURE["api_versions"]
    assert {"full", "partial", "two_partials", "refund_fails"} <= set(SCENARIOS)


# --- reconciled from Stripe, whatever the order ---------------------------------------------


def test_a_full_refund(db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["full"])
    [refund] = _refunds("full")
    _our_case(db_session, gig, refund, source="client_refund", status=RefundCaseStatus.refund_initiated)

    _deliver(db_session, stripe_truth, _events("full"))

    state = _state(db_session, gig)
    amount = str((Decimal(refund["amount"]) / 100).quantize(Decimal("0.01")))
    assert state["payment"] == ("refunded", amount)
    assert state["ledger"] == [("refund_succeeded", f"-{amount}", refund["id"])]
    assert state["cases"] == [(amount, "refunded", refund["id"], "client_refund")]
    assert state["gig"] == "refunded"
    assert state["earnings"][0] == "reversed"
    assert state["attention"] == []


def test_two_partial_refunds_are_two_ledger_lines(db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["two_partials"])

    _deliver(db_session, stripe_truth, _events("two_partials"))

    state = _state(db_session, gig)
    refunds = _refunds("two_partials")
    total = sum(r["amount"] for r in refunds)
    assert sorted(l[2] for l in state["ledger"]) == sorted(r["id"] for r in refunds), "one line per refund, by its id"
    assert state["payment"] == ("succeeded", str((Decimal(total) / 100).quantize(Decimal("0.01"))))
    assert state["gig"] == "paid"


@pytest.mark.parametrize("name", ["full", "partial", "two_partials", "refund_fails"])
def test_any_order_and_any_repetition_ends_the_same(db_session, stripe_truth, name):
    """Delivered late, events find Stripe already at its final state."""
    states = []
    for n, arrange in enumerate((list, lambda e: list(reversed(e)), lambda e: random.Random(7).sample(e, len(e)), lambda e: e + e)):
        scenario = _renamed(SCENARIOS[name], f"o{n}")
        gig = _booking(db_session, scenario)
        _deliver(db_session, stripe_truth, arrange(list(scenario["events"])), truth_from=scenario["events"])
        state = _state(db_session, gig)
        # Compare without the ids each round renamed.
        states.append({
            **state,
            "ledger": [(t, a) for t, a, _id in state["ledger"]],
            "cases": [(a, st, src) for a, st, _id, src in state["cases"]],
            "attention": [(k, a) for k, a, _id in state["attention"]],
        })
    assert all(s == states[0] for s in states), states


# --- whose refund is it ---------------------------------------------------------------------


def test_our_admin_refund_case_settles(db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["partial"])
    [refund] = _refunds("partial")
    _our_case(db_session, gig, refund, status=RefundCaseStatus.processing, source="admin")

    _deliver(db_session, stripe_truth, _events("partial"))

    [case] = _state(db_session, gig)["cases"]
    assert case[1] == "refunded"
    assert _state(db_session, gig)["attention"] == []


def test_a_refund_made_outside_our_routes_is_adopted_and_flagged(db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["partial"])
    [refund] = _refunds("partial")

    _deliver(db_session, stripe_truth, _events("partial"))
    _deliver(db_session, stripe_truth, _events("partial"))  # and again: adopted once

    state = _state(db_session, gig)
    amount = str((Decimal(refund["amount"]) / 100).quantize(Decimal("0.01")))
    assert state["cases"] == [(amount, "refunded", refund["id"], "stripe_external")]
    assert state["attention"] == [("refund_outside_rawwers", amount, refund["id"])]
    assert state["ledger"] == [("refund_succeeded", f"-{amount}", refund["id"])]


# --- the refunded share, and no more ---------------------------------------------------------


def test_a_partial_refund_reduces_earnings_by_the_refunded_share(db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["partial"])
    amount = Decimal(SCENARIOS["partial"]["amount"]) / 100
    refunded = Decimal(_refunds("partial")[0]["amount"]) / 100

    _deliver(db_session, stripe_truth, _events("partial"))

    status, gross = _state(db_session, gig)["earnings"]
    assert status != "reversed"
    assert Decimal(gross) == (amount - refunded).quantize(Decimal("0.01"))


def test_a_disputes_partial_refund_reduces_earnings_by_the_share_only(db_session, stripe_truth):
    """Settling a dispute's refund reversed the photographer's whole booking."""
    from app.models.admin import Dispute, DisputeCategory, DisputeStatus

    gig = _booking(db_session, SCENARIOS["partial"], status=GigStatus.disputed)
    [refund] = _refunds("partial")
    dispute = Dispute(
        gig_id=gig.id, opened_by_user_id=gig.client_user_id, against_user_id=gig.pro_user_id, status=DisputeStatus.awaiting_admin,
        category=DisputeCategory.deliverable_quality, currency="EUR", summary="x", resolution={}, meta={},
    )
    db_session.add(dispute)
    db_session.flush()
    case = _our_case(db_session, gig, refund, status=RefundCaseStatus.refund_initiated, source="")
    case.dispute_id = dispute.id
    db_session.commit()

    _deliver(db_session, stripe_truth, _events("partial"))

    status, gross = _state(db_session, gig)["earnings"]
    assert status != "reversed"
    assert Decimal(gross) == (Decimal(SCENARIOS["partial"]["amount"] - refund["amount"]) / 100).quantize(Decimal("0.01"))


# --- a refund that fails ---------------------------------------------------------------------


def test_a_refund_that_fails_after_seeming_to_succeed(db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["refund_fails"])
    [refund] = _refunds("refund_fails")
    _our_case(db_session, gig, refund, source="client_refund", status=RefundCaseStatus.refund_initiated)
    events = _events("refund_fails")
    before_failure = [e for e in events if e["type"] != "refund.failed" and e["data"]["object"].get("status") != "failed"]
    amount = str((Decimal(refund["amount"]) / 100).quantize(Decimal("0.01")))

    _deliver(db_session, stripe_truth, before_failure)
    seemed = _state(db_session, gig)
    assert seemed["payment"] == ("refunded", amount) and seemed["gig"] == "refunded"

    _deliver(db_session, stripe_truth, events, truth_from=events)
    _deliver(db_session, stripe_truth, events, truth_from=events)  # Stripe repeats itself

    state = _state(db_session, gig)
    assert state["payment"] == ("succeeded", "0.00"), "the money is still with us"
    assert state["cases"] == [(amount, "failed", refund["id"], "client_refund")]
    assert state["ledger"] == [("refund_failed", amount, refund["id"]), ("refund_succeeded", f"-{amount}", refund["id"])], "only that refund's line is reversed, once"
    assert state["gig"] == "refunded", "never resurrected"
    assert state["earnings"][0] == "reversed", "and neither are the earnings"
    assert state["attention"] == [("client_owed", amount, refund["id"])]


# --- the safety net --------------------------------------------------------------------------


def test_a_case_stuck_in_flight_is_reconciled_by_the_job(db_session, stripe_truth):
    from app.services.refund_reconcile import reconcile_stuck_refund_cases

    gig = _booking(db_session, SCENARIOS["partial"])
    [refund] = _refunds("partial")
    case = _our_case(db_session, gig, refund, status=RefundCaseStatus.processing)
    stripe_truth.by_intent[refund["payment_intent"]] = _refunds("partial")

    assert reconcile_stuck_refund_cases(db_session) == 0, "not stuck yet"
    case.updated_at = datetime.now(timezone.utc) - timedelta(hours=1)
    db_session.commit()

    assert reconcile_stuck_refund_cases(db_session) == 1
    db_session.expire_all()
    assert db_session.get(RefundCase, case.id).status == RefundCaseStatus.refunded


def test_the_job_is_scheduled(db_session):
    from app.tasks.celery_app import celery_app

    names = {entry["task"] for entry in celery_app.conf.beat_schedule.values()}
    assert "app.tasks.scheduled.reconcile_stuck_refunds" in names
    assert celery_app.conf.task_routes["app.tasks.scheduled.reconcile_stuck_refunds"] == {"queue": "media"}


# --- admin attention items -------------------------------------------------------------------

ADMIN = "00000000-0000-0000-0000-0000000000aa"


def test_admins_see_and_resolve_money_attention_items(client, db_session, stripe_truth):
    gig = _booking(db_session, SCENARIOS["refund_fails"])
    events = _events("refund_fails")
    _deliver(db_session, stripe_truth, events, truth_from=events)

    listed = client.get("/v1/admin/money-attention", headers={"X-User-Id": ADMIN})
    assert listed.status_code == 200, listed.text
    mine = {i["kind"]: i for i in listed.json()["items"] if i["gig_id"] == str(gig.id)}
    # No case of ours: adopted as made outside RAWWERS, and the client is owed.
    assert set(mine) == {"client_owed", "refund_outside_rawwers"}
    item = mine["client_owed"]
    assert item["status"] == "open"

    assert client.get("/v1/admin/money-attention", headers={"X-User-Id": str(gig.client_user_id)}).status_code == 403
    done = client.post(f"/v1/admin/money-attention/{item['id']}/resolve", headers={"X-User-Id": ADMIN}, json={"note": "Paid back by bank transfer"})
    assert done.status_code == 200, done.text
    assert done.json()["status"] == "resolved"


def test_a_line_written_before_refund_ids_is_taken_over_not_doubled(db_session, stripe_truth):
    """Lines written before reconciliation were keyed on the payment
    ("refund:<payment intent>"); dev and any earlier deploy have them."""
    gig = _booking(db_session, SCENARIOS["partial"])
    [refund] = _refunds("partial")
    amount = (Decimal(refund["amount"]) / 100).quantize(Decimal("0.01"))
    db_session.add(
        LedgerEntry(
            gig_id=gig.id, entry_type=LedgerEntryType.refund_succeeded, amount=-amount, currency="EUR",
            description="Stripe partial refund", reference_type="stripe_refund", reference_id=f"refund:{refund['payment_intent']}",
        )
    )
    db_session.commit()

    _deliver(db_session, stripe_truth, _events("partial"))

    assert _state(db_session, gig)["ledger"] == [("refund_succeeded", f"-{amount}", refund["id"])]
