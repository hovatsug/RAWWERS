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

from tests.test_refund_routes import _paid_booking

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


def _refunded(db_session, gig, n=0, amount=None, refund_id=None):
    payment = db_session.execute(
        select(StripePayment).where(StripePayment.stripe_payment_intent_id == f"pi_{gig.id.hex[:10]}_{n}")
    ).scalar_one()
    minor = int(((amount if amount is not None else payment.amount) * 100))
    _apply_stripe_event(
        db_session,
        "refund.succeeded",
        {"id": refund_id or f"re_{gig.id.hex[:6]}_{n}", "payment_intent": payment.stripe_payment_intent_id, "amount": minor},
    )
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
def test_a_full_refund_ends_the_booking(db_session, status):
    gig, _client, _pro = _paid_booking(db_session, status=status)
    _shoot(db_session, gig)
    if status == GigStatus.paid:
        assert _holds_time(db_session, gig)
    assert _finals(db_session, gig) == [True, True]

    _refunded(db_session, gig)

    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.refunded
    assert not _holds_time(db_session, gig), "the photographer's time is free again"
    assert _finals(db_session, gig) == [False, False]
    assert _earnings(db_session, gig).status == EarningsEntryStatus.reversed
    [transition] = db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()
    assert (transition.from_status, transition.to_status) == (status, GigStatus.refunded)


def test_only_once_however_often_stripe_repeats_itself(db_session):
    gig, _client, _pro = _paid_booking(db_session)
    _shoot(db_session, gig)
    _refunded(db_session, gig)
    reversed_at = _earnings(db_session, gig).reversed_at

    # Support gives the finals back after the refund; a late or repeated
    # Stripe event must not take them away again.
    upsert_gig_entitlement(db_session, gig_id=gig.id, user_id=gig.client_user_id, entitlement_type=GigEntitlementType.download_finals)
    db_session.commit()

    _refunded(db_session, gig)
    _refunded(db_session, gig, refund_id="re_charge_refunded_replay")

    assert _finals(db_session, gig)[0], "settled once: the finals given back stay"

    assert len(db_session.execute(select(GigTransition).where(GigTransition.gig_id == gig.id)).scalars().all()) == 1
    assert _earnings(db_session, gig).reversed_at == reversed_at
    assert db_session.get(Gig, gig.id).meta.get("full_refund_settled_at")


def test_a_partial_refund_leaves_the_booking_alone(db_session):
    gig, _client, _pro = _paid_booking(db_session)
    _shoot(db_session, gig)

    _refunded(db_session, gig, amount=Decimal("30.00"))

    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.paid
    assert _holds_time(db_session, gig)
    assert _finals(db_session, gig) == [True, True]
    assert _earnings(db_session, gig).status != EarningsEntryStatus.reversed


def test_every_payment_must_be_refunded_first(db_session):
    gig, _client, _pro = _paid_booking(db_session, payments=2)
    _shoot(db_session, gig)

    _refunded(db_session, gig, n=1)  # the 20, of 100 + 20
    assert db_session.get(Gig, gig.id).status == GigStatus.paid
    assert _finals(db_session, gig) == [True, True]
    earnings = _earnings(db_session, gig)
    assert earnings.status != EarningsEntryStatus.reversed, "the other payment still pays for most of it"
    assert earnings.gross_eur == Decimal("60.00"), "80 earned, less the 20 refunded"

    _refunded(db_session, gig, n=0)
    assert db_session.get(Gig, gig.id).status == GigStatus.refunded
    assert _finals(db_session, gig) == [False, False]
    assert _earnings(db_session, gig).status == EarningsEntryStatus.reversed


def test_further_along_the_status_stays_but_the_finals_still_go(db_session):
    """Minimal for now: only paid and disputed move to refunded. A booking
    further along keeps its status - the cancellation standard decides what
    it becomes - but money fully returned never leaves the finals open."""
    gig, _client, _pro = _paid_booking(db_session, status=GigStatus.final_delivered)
    _shoot(db_session, gig)

    _refunded(db_session, gig)

    gig = db_session.get(Gig, gig.id)
    assert gig.status == GigStatus.final_delivered
    assert _finals(db_session, gig) == [False, False]
    assert _earnings(db_session, gig).status == EarningsEntryStatus.reversed
