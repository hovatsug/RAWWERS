"""A booking's RAWW follow its earning (services/raww_earning.py).

Owner's decision (2026-11-03): the 5% credit, in RAWW at the stamped rate,
pending until the earning is available with no hold, back to pending if it
is held; refunds and price reductions write the difference at the original
rate; a full refund reverses all; spent RAWW are not clawed back from cash.
"""
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.payouts import EarningsHoldReason
from app.models.shelf import ProRawwBalance, ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus
from app.services import raww_ledger as ledger
from app.services.payouts import create_earnings_hold, release_earnings_holds_for_source
from app.services.photographer_money import record_gig_earnings, photographer_money
from app.services.raww_earning import raww_for
from app.services.shelf_settings import shelf_settings

from tests.test_photographer_money import _complete, _gig, _pay, _pro, _settle

D = Decimal


def _raww(db, pro):
    db.expire_all()
    balance = db.get(ProRawwBalance, pro)
    if balance is None:
        return (0, 0)
    assert (balance.spendable, balance.pending) == ledger.ledger_totals(db, pro)
    return balance.spendable, balance.pending


def _entries(db, pro):
    return db.execute(select(ProRawwLedgerEntry).where(ProRawwLedgerEntry.pro_user_id == pro).order_by(ProRawwLedgerEntry.created_at)).scalars().all()


def _booking(db, pro, gross="150.00"):
    gig = _gig(db, pro, minimum=gross)
    payment = _pay(db, gig, gross)
    _complete(db, gig)
    return gig, payment


@pytest.mark.parametrize(("eur", "rate", "raww"), [("7.50", "0.10", 75), ("7.45", "0.10", 75), ("7.44", "0.10", 74), ("7.50", "0.12", 63)])
def test_whole_rawws_to_the_nearest(eur, rate, raww):
    assert raww_for(D(eur), D(rate)) == raww


def test_a_150_euro_booking_earns_75_pending_rawws_stamped_with_the_rate(db_session):
    pro = _pro(db_session)
    gig, _ = _booking(db_session, pro)

    assert _raww(db_session, pro) == (0, 75)
    [entry] = _entries(db_session, pro)
    assert (entry.kind, entry.raww_eur_value, entry.eur_basis, entry.gig_id) == (RawwEntryKind.earn_booking, D("0.1000"), D("7.50"), gig.id)


def test_they_become_spendable_when_the_earning_settles(db_session):
    pro = _pro(db_session)
    _booking(db_session, pro)

    _settle(db_session, pro)

    assert _raww(db_session, pro) == (75, 0)


def test_a_held_earning_keeps_them_pending_until_the_hold_is_released(db_session):
    pro = _pro(db_session)
    gig, _ = _booking(db_session, pro)
    create_earnings_hold(db_session, pro_user_id=pro, reason=EarningsHoldReason.client_reported_problem, amount_eur=None, source_type="gig_base", source_id=gig.id, created_by_admin_id=None)
    db_session.commit()

    _settle(db_session, pro)
    assert _raww(db_session, pro) == (0, 75), "past its date, but held"

    release_earnings_holds_for_source(db_session, pro_user_id=pro, source_type="gig_base", source_id=gig.id)
    db_session.commit()
    assert _raww(db_session, pro) == (75, 0)


def test_a_hold_after_settling_takes_them_back_to_pending(db_session):
    pro = _pro(db_session)
    gig, _ = _booking(db_session, pro)
    _settle(db_session, pro)

    create_earnings_hold(db_session, pro_user_id=pro, reason=EarningsHoldReason.dispute_open, amount_eur=None, source_type="gig_base", source_id=gig.id, created_by_admin_id=None)
    db_session.commit()

    assert _raww(db_session, pro) == (0, 75)


def test_a_hold_on_all_their_earnings_counts_too(db_session):
    pro = _pro(db_session)
    _booking(db_session, pro)
    _settle(db_session, pro)

    create_earnings_hold(db_session, pro_user_id=pro, reason=EarningsHoldReason.compliance, amount_eur=None, source_type=None, source_id=None, created_by_admin_id=None)
    db_session.commit()

    assert _raww(db_session, pro) == (0, 75)


def test_a_partial_refund_reverses_the_difference_at_the_original_rate(db_session):
    pro = _pro(db_session)
    gig, payment = _booking(db_session, pro)
    shelf_settings(db_session).raww_eur_value = D("0.20")  # a later change of value
    payment.amount_refunded = D("50.00")
    db_session.commit()

    record_gig_earnings(db_session, gig)
    db_session.commit()

    assert _raww(db_session, pro) == (0, 50), "5% of 100 at the original 0.10"
    reversal = _entries(db_session, pro)[-1]
    assert (reversal.kind, reversal.amount, reversal.raww_eur_value) == (RawwEntryKind.reverse_booking, -25, D("0.1000"))


def test_recording_the_same_refund_twice_reverses_once(db_session):
    pro = _pro(db_session)
    gig, payment = _booking(db_session, pro)
    payment.amount_refunded = D("50.00")
    db_session.commit()

    for _ in range(2):
        record_gig_earnings(db_session, gig)
        db_session.commit()

    assert _raww(db_session, pro) == (0, 50)
    assert len(_entries(db_session, pro)) == 2


def test_a_full_refund_reverses_all(db_session):
    pro = _pro(db_session)
    gig, payment = _booking(db_session, pro)
    _settle(db_session, pro)
    payment.amount_refunded = D("150.00")
    db_session.commit()

    record_gig_earnings(db_session, gig)
    db_session.commit()

    assert _raww(db_session, pro) == (0, 0)


def test_a_refund_after_spending_goes_negative_and_takes_no_cash(db_session):
    pro = _pro(db_session)
    gig, payment = _booking(db_session, pro)
    _settle(db_session, pro)
    ledger.spend(db_session, pro_user_id=pro, amount=75, source_type="shelf_order", source_id="o1")
    db_session.commit()
    cash_before = photographer_money(db_session, pro).lifetime

    payment.amount_refunded = D("150.00")
    db_session.commit()
    record_gig_earnings(db_session, gig)
    db_session.commit()

    assert _raww(db_session, pro) == (-75, 0)
    assert photographer_money(db_session, pro).lifetime == D("0.00") and cash_before == D("120.00"), "the cash follows the refund, not the RAWW"


def test_a_booking_not_yet_completed_earns_nothing(db_session):
    pro = _pro(db_session)
    gig = _gig(db_session, pro, minimum="150.00")
    _pay(db_session, gig, "150.00")

    record_gig_earnings(db_session, gig)
    db_session.commit()

    assert _raww(db_session, pro) == (0, 0)


def _available_with_a_bare_hold(db, pro, gig, **hold):
    """An earning still marked available while a hold row is active: the
    RAWW must read the hold itself, not only the earning's status."""
    from app.models.payouts import EarningsHold
    from app.services.raww_earning import sync_pro_raww_status

    db.add(EarningsHold(pro_user_id=pro, reason=EarningsHoldReason.manual, **hold))
    db.flush()
    sync_pro_raww_status(db, pro)
    db.commit()


def test_an_active_hold_on_the_booking_keeps_them_pending_whatever_the_earnings_status(db_session):
    pro = _pro(db_session)
    gig, _ = _booking(db_session, pro)
    _settle(db_session, pro)

    _available_with_a_bare_hold(db_session, pro, gig, source_type="gig_base", source_id=gig.id)

    assert _raww(db_session, pro) == (0, 75)


def test_an_active_hold_on_everything_keeps_them_pending_whatever_the_earnings_status(db_session):
    pro = _pro(db_session)
    gig, _ = _booking(db_session, pro)
    _settle(db_session, pro)

    _available_with_a_bare_hold(db_session, pro, gig, source_type=None, source_id=None)

    assert _raww(db_session, pro) == (0, 75)


def test_an_earning_marked_held_keeps_them_pending_without_a_hold_row(db_session):
    from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry
    from app.services.raww_earning import sync_pro_raww_status

    pro = _pro(db_session)
    gig, _ = _booking(db_session, pro)
    _settle(db_session, pro)
    earning = db_session.execute(select(EarningsLedgerEntry).where(EarningsLedgerEntry.source_id == gig.id)).scalar_one()
    earning.status = EarningsEntryStatus.held
    db_session.flush()

    sync_pro_raww_status(db_session, pro)
    db_session.commit()

    assert _raww(db_session, pro) == (0, 75)


def test_the_same_refund_recorded_twice_at_once_reverses_once():
    import threading
    import time

    from app.models.gig import Gig, StripePayment
    from tests.conftest import TestingSessionLocal

    setup = TestingSessionLocal()
    try:
        pro = _pro(setup)
        gig, payment = _booking(setup, pro)
        payment.amount_refunded = D("50.00")
        setup.commit()
        gig_id = gig.id
    finally:
        setup.close()

    held, other = TestingSessionLocal(), TestingSessionLocal()
    errors = []

    def second():
        try:
            record_gig_earnings(other, other.get(Gig, gig_id))
            other.commit()
        except Exception as error:  # noqa: BLE001
            errors.append(error)
            other.rollback()

    try:
        record_gig_earnings(held, held.get(Gig, gig_id))
        thread = threading.Thread(target=second)
        thread.start()
        time.sleep(0.6)
        held.commit()
        thread.join(timeout=20)
    finally:
        held.close()
        other.close()

    check = TestingSessionLocal()
    try:
        assert not errors, errors
        assert _raww(check, pro) == (0, 50)
        assert len(_entries(check, pro)) == 2
    finally:
        check.close()
