"""A booking refunded in full is over: the minimum the cancellation standard
builds on.

The refund webhook recorded the money and changed nothing else - the gig
stayed `paid`, held the photographer's calendar, and the client kept the
finals. Now, once every payment captured for a booking is refunded in full:
the gig becomes `refunded` (from paid or disputed), which frees its time;
finals and extras downloads are revoked; the photographer's earnings for it
are reversed. Once, however often Stripe repeats itself. A partial refund
changes none of that - the shoot may well be happening.
"""
import copy
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from app.api.v1.webhooks import _apply_stripe_event
from app.models.gig import Gig, GigStatus, GigTransition, StripePayment
from app.models.media_rights import GigEntitlementType
from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType
from app.services.bookable_time import load_calendar
from app.services.media_rights import has_valid_entitlement, upsert_gig_entitlement
from sqlalchemy import select

from tests.test_refund_reconcile import SCENARIOS, stripe_truth  # noqa: F401 - fixture
from tests.test_refund_routes import _paid_booking

FULL = SCENARIOS["full"]

FINALS = (GigEntitlementType.download_finals, GigEntitlementType.download_extras)


def _shoot(db_session, gig):
    gig.scheduled_start = datetime.now(timezone.utc).replace(microsecond=0) + timedelta(days=3)
    gig.scheduled_end = gig.scheduled_start + timedelta(hours=2)
    for kind in FINALS:
        upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=gig.client_user_id, entitlement_type=kind)
    db_session.add(
        EarningsLedgerEntry(
            pro_user_id=gig.pro_user_id,
            source_type=EarningsSourceType.gig_base,
            source_id=gig.id,
            gross_eur=Decimal("80.00"),
            platform_fee_eur=Decimal("0.00"),
            net_eur=Decimal("80.00"),
            status=EarningsEntryStatus.pending,
            available_at=datetime.now(timezone.utc) + timedelta(days=7),
            meta={},
        )
    )
    db_session.commit()


def _refunded(db_session, stripe_truth, gig, n=0, amount=None, refund_id=None):
    """Stripe refunds payment n, and sends its charge.refunded - both in the
    shapes captured from Stripe (tests/fixtures/stripe), under this
    booking's ids. The handler then asks Stripe for the refunds."""
    payment = db_session.execute(
        select(StripePayment).where(StripePayment.stripe_payment_intent_id == f"pi_{gig.id.hex[:10]}_{n}")
    ).scalar_one()
    pi = payment.stripe_payment_intent_id
    refund = copy.deepcopy(FULL["refunds"][0])
    refund.update(
        id=refund_id or f"re_{gig.id.hex[:6]}_{n}", payment_intent=pi, status="succeeded",
        amount=int((amount if amount is not None else payment.amount) * 100),
    )
    refunds = [r for r in stripe_truth.by_intent.get(pi, []) if r["id"] != refund["id"]] + [refund]
    stripe_truth.by_intent[pi] = refunds
    charge = copy.deepcopy(next(e for e in FULL["events"] if e["type"] == "charge.refunded")["data"]["object"])
    charge.update(payment_intent=pi, amount=int(payment.amount * 100), amount_refunded=sum(r["amount"] for r in refunds))
    _apply_stripe_event(db_session, "charge.refunded", charge)
    db_session.commit()
    db_session.expire_all()


def _holds_time(db_session, gig) -> bool:
    cal = load_calendar(db_session, pro_user_id=gig.pro_user_id, start=gig.scheduled_start, end=gig.scheduled_end)
    return any(b.gig_id == gig.id for b in cal.bookings)


def _finals(db_session, gig) -> list[bool]:
    return [has_valid_entitlement(db_session, gig_id=gig.id, user_id=gig.client_user_id, entitlement_type=k) for k in FINALS]


def _earnings(db_session, gig) -> EarningsLedgerEntry:
    return db_session.execute(
        select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_id == gig.id)
    ).scalar_one()


@pytest.mark.parametrize("status", [GigStatus.paid, GigStatus.disputed])
def test_a_full_refund_ends_the_booking(db_session, stripe_truth, status):
    gig, _client, _pro = _paid_booking(db_session, status=status)
    _shoot(db_session, gig)
    if status == GigStatus.paid:
        assert _holds_time(db_session, gig)
    assert _finals(db_session, gig) == [True, True]

    _refunded(db_session, stripe_truth, gig)

    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.refunded
    assert not _holds_time(db_session, gig), "the photographer's time is free again"
    assert _finals(db_session, gig) == [False, False]
    assert _earnings(db_session, gig).status == EarningsEntryStatus.reversed
    [transition] = db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()
    assert (transition.from_status, transition.to_status) == (status, GigStatus.refunded)


def test_only_once_however_often_stripe_repeats_itself(db_session, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)
    _shoot(db_session, gig)
    _refunded(db_session, stripe_truth, gig)
    reversed_at = _earnings(db_session, gig).reversed_at

    # Support gives the finals back after the refund; a late or repeated
    # Stripe event must not take them away again.
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=gig.client_user_id, entitlement_type=GigEntitlementType.download_finals)
    db_session.commit()

    _refunded(db_session, stripe_truth, gig)
    _refunded(db_session, stripe_truth, gig)  # and again

    assert _finals(db_session, gig)[0], "settled once: the finals given back stay"

    assert len(db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()) == 1
    assert _earnings(db_session, gig).reversed_at == reversed_at
    assert db_session.get(Gig, gig.id).meta.get("full_refund_settled_at")


def test_a_partial_refund_leaves_the_booking_alone(db_session, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session)
    _shoot(db_session, gig)

    _refunded(db_session, stripe_truth, gig, amount=Decimal("30.00"))

    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.paid
    assert _holds_time(db_session, gig)
    assert _finals(db_session, gig) == [True, True]
    assert _earnings(db_session, gig).status != EarningsEntryStatus.reversed


def test_every_payment_must_be_refunded_first(db_session, stripe_truth):
    gig, _client, _pro = _paid_booking(db_session, payments=2)
    _shoot(db_session, gig)

    _refunded(db_session, stripe_truth, gig, n=1)  # the 20, of 100 + 20
    assert db_session.get(Gig, gig.id).status == GigStatus.paid
    assert _finals(db_session, gig) == [True, True]
    earnings = _earnings(db_session, gig)
    assert earnings.status != EarningsEntryStatus.reversed, "the other payment still pays for most of it"
    # The booking is priced 100 and the client paid 120: the 20 refunded was
    # paid beyond the price, so the photographer's 80 is untouched. Earnings
    # follow the final price net of refunds (photographer_money), no longer
    # every refund's share of whatever was paid.
    assert earnings.net_eur == Decimal("80.00"), "an overpayment refunded takes nothing from the photographer"

    _refunded(db_session, stripe_truth, gig, n=0)
    assert db_session.get(Gig, gig.id).status == GigStatus.refunded
    assert _finals(db_session, gig) == [False, False]
    assert _earnings(db_session, gig).status == EarningsEntryStatus.reversed


def test_further_along_the_status_stays_but_the_finals_still_go(db_session, stripe_truth):
    """Minimal for now: only paid and disputed move to refunded. A booking
    further along keeps its status - the cancellation standard decides what
    it becomes - but money fully returned never leaves the finals open."""
    gig, _client, _pro = _paid_booking(db_session, status=GigStatus.final_delivered)
    _shoot(db_session, gig)

    _refunded(db_session, stripe_truth, gig)

    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.final_delivered
    assert _finals(db_session, gig) == [False, False]
    assert _earnings(db_session, gig).status == EarningsEntryStatus.reversed
