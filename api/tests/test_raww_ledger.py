"""The Shelf's RAWW ledger (services/raww_ledger.py), on its own.

The rules: one entry per (pro, kind, source); the balance always equals its
entries; booking credit is pending until moved, both ways; spending needs
the spendable balance, which may be negative and then refuses everything;
an admin adjustment needs a note; expiry takes the whole spendable balance
once per inactivity period; earning and spending restart that clock.
"""
import threading
import time
import uuid
from decimal import Decimal

import pytest
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError

from app.core.errors import APIError
from app.models.shelf import ProRawwBalance, ProRawwLedgerEntry, RawwEntryKind, RawwEntryStatus
from app.services import raww_ledger as ledger

from tests.conftest import TestingSessionLocal


def _earn(db, pro, gig, amount, status=RawwEntryStatus.pending):
    return ledger.post_entry(
        db, pro_user_id=pro, kind=RawwEntryKind.earn_booking, amount=amount, status=status,
        source_type="gig", source_id=str(gig), gig_id=gig, raww_eur_value=Decimal("0.10"), eur_basis=Decimal(amount) / 10,
    )


def _consistent(db, pro):
    balance = db.get(ProRawwBalance, pro)
    db.refresh(balance)
    assert (balance.spendable, balance.pending) == ledger.ledger_totals(db, pro)
    return balance


def test_a_booking_credit_is_pending_until_it_settles(db_session):
    pro, gig = uuid.uuid4(), uuid.uuid4()
    _earn(db_session, pro, gig, 75)

    balance = _consistent(db_session, pro)
    assert (balance.spendable, balance.pending) == (0, 75)

    assert ledger.set_booking_status(db_session, pro_user_id=pro, gig_id=gig, status=RawwEntryStatus.spendable) == 1
    balance = _consistent(db_session, pro)
    assert (balance.spendable, balance.pending) == (75, 0)


def test_a_settled_credit_held_again_goes_back_to_pending(db_session):
    pro, gig = uuid.uuid4(), uuid.uuid4()
    _earn(db_session, pro, gig, 75, status=RawwEntryStatus.spendable)

    ledger.set_booking_status(db_session, pro_user_id=pro, gig_id=gig, status=RawwEntryStatus.pending)

    balance = _consistent(db_session, pro)
    assert (balance.spendable, balance.pending) == (0, 75)


def test_the_same_source_twice_is_one_entry(db_session):
    pro, gig = uuid.uuid4(), uuid.uuid4()
    first = _earn(db_session, pro, gig, 75)
    again = _earn(db_session, pro, gig, 75)

    assert again.id == first.id
    assert _consistent(db_session, pro).pending == 75


def test_the_database_refuses_a_second_row_for_a_source(db_session):
    pro = uuid.uuid4()
    for _ in range(2):
        db_session.add(ProRawwLedgerEntry(
            pro_user_id=pro, kind=RawwEntryKind.earn_booking, amount=1, status=RawwEntryStatus.pending,
            source_type="gig", source_id="g", meta={},
        ))
    with pytest.raises(IntegrityError):
        db_session.flush()
    db_session.rollback()


def test_spending_takes_from_spendable_only(db_session):
    pro = uuid.uuid4()
    _earn(db_session, pro, uuid.uuid4(), 100, status=RawwEntryStatus.spendable)
    _earn(db_session, pro, uuid.uuid4(), 500)  # pending: not spendable

    with pytest.raises(APIError) as refused:
        ledger.spend(db_session, pro_user_id=pro, amount=101, source_type="shelf_order", source_id="o1")
    assert refused.value.code == "insufficient_raww"

    ledger.spend(db_session, pro_user_id=pro, amount=100, source_type="shelf_order", source_id="o1")
    balance = _consistent(db_session, pro)
    assert (balance.spendable, balance.pending) == (0, 500)


def test_a_negative_balance_refuses_every_spend(db_session):
    pro, gig = uuid.uuid4(), uuid.uuid4()
    _earn(db_session, pro, gig, 100, status=RawwEntryStatus.spendable)
    ledger.spend(db_session, pro_user_id=pro, amount=100, source_type="shelf_order", source_id="o1")
    ledger.post_entry(
        db_session, pro_user_id=pro, kind=RawwEntryKind.reverse_booking, amount=-60, status=RawwEntryStatus.spendable,
        source_type="gig", source_id=f"{gig}:refund", gig_id=gig,
    )
    assert _consistent(db_session, pro).spendable == -60
    _earn(db_session, pro, uuid.uuid4(), 50, status=RawwEntryStatus.spendable)

    with pytest.raises(APIError):
        ledger.spend(db_session, pro_user_id=pro, amount=1, source_type="shelf_order", source_id="o2")
    assert _consistent(db_session, pro).spendable == -10


def test_an_admin_adjustment_needs_a_note(db_session):
    pro = uuid.uuid4()
    with pytest.raises(APIError):
        ledger.admin_adjust(db_session, pro_user_id=pro, amount=50, note="  ", actor_user_id=uuid.uuid4())

    entry = ledger.admin_adjust(db_session, pro_user_id=pro, amount=50, note="Return of a damaged lens", actor_user_id=uuid.uuid4())
    assert entry.note == "Return of a damaged lens"
    assert _consistent(db_session, pro).spendable == 50


def test_expiry_takes_the_whole_spendable_balance_once(db_session):
    pro = uuid.uuid4()
    _earn(db_session, pro, uuid.uuid4(), 120, status=RawwEntryStatus.spendable)
    _earn(db_session, pro, uuid.uuid4(), 30)

    entry = ledger.expire_spendable(db_session, pro_user_id=pro)
    again = ledger.expire_spendable(db_session, pro_user_id=pro)

    assert entry.amount == -120
    assert again is None
    balance = _consistent(db_session, pro)
    assert (balance.spendable, balance.pending) == (0, 30), "pending credit does not expire"


def test_earning_and_spending_restart_the_inactivity_clock_and_clear_the_warning(db_session):
    pro = uuid.uuid4()
    _earn(db_session, pro, uuid.uuid4(), 100, status=RawwEntryStatus.spendable)
    balance = db_session.get(ProRawwBalance, pro)
    first_activity = balance.last_activity_at
    assert first_activity is not None
    balance.expiry_warned_at = first_activity
    db_session.flush()

    time.sleep(0.01)
    ledger.spend(db_session, pro_user_id=pro, amount=10, source_type="shelf_order", source_id="o1")
    assert balance.last_activity_at > first_activity
    assert balance.expiry_warned_at is None

    before = balance.last_activity_at
    ledger.admin_adjust(db_session, pro_user_id=pro, amount=5, note="goodwill", actor_user_id=uuid.uuid4())
    assert balance.last_activity_at == before, "an admin's adjustment is not the photographer's activity"


def _race(first, second):
    held, other = TestingSessionLocal(), TestingSessionLocal()
    outcome: dict = {}

    def run_second():
        try:
            outcome["value"] = second(other)
            other.commit()
        except Exception as error:  # noqa: BLE001
            other.rollback()
            outcome["value"] = error

    try:
        first_result = first(held)
        thread = threading.Thread(target=run_second)
        thread.start()
        time.sleep(0.6)
        assert thread.is_alive(), "the second call should be waiting on the balance lock"
        held.commit()
        thread.join(timeout=20)
        return first_result, outcome.get("value")
    finally:
        held.close()
        other.close()


def _seeded_pro(spendable: int) -> uuid.UUID:
    pro = uuid.uuid4()
    db = TestingSessionLocal()
    try:
        _earn(db, pro, uuid.uuid4(), spendable, status=RawwEntryStatus.spendable)
        db.commit()
    finally:
        db.close()
    return pro


def _totals(pro):
    db = TestingSessionLocal()
    try:
        balance = db.get(ProRawwBalance, pro)
        count = db.execute(select(func.count()).select_from(ProRawwLedgerEntry).where(ProRawwLedgerEntry.pro_user_id == pro)).scalar_one()
        assert (balance.spendable, balance.pending) == ledger.ledger_totals(db, pro)
        return balance.spendable, count
    finally:
        db.close()


def test_the_same_booking_credit_arriving_twice_at_once_counts_once():
    pro, gig = _seeded_pro(10), uuid.uuid4()

    def earn(db):
        return _earn(db, pro, gig, 75, status=RawwEntryStatus.spendable).id

    first, second = _race(earn, earn)

    assert second == first
    assert _totals(pro) == (85, 2)


def test_a_double_tap_on_an_order_spends_once():
    pro = _seeded_pro(300)

    def order(db):
        return ledger.spend(db, pro_user_id=pro, amount=200, source_type="shelf_order", source_id="o1").id

    first, second = _race(order, order)

    assert second == first
    assert _totals(pro) == (100, 2)


def test_two_orders_at_once_cannot_take_more_than_there_is():
    pro = _seeded_pro(300)

    first, second = _race(
        lambda db: ledger.spend(db, pro_user_id=pro, amount=200, source_type="shelf_order", source_id="o1").id,
        lambda db: ledger.spend(db, pro_user_id=pro, amount=200, source_type="shelf_order", source_id="o2").id,
    )

    assert isinstance(second, APIError) and second.code == "insufficient_raww"
    assert _totals(pro) == (100, 2)


def test_rawws_an_admin_restores_after_an_expiry_are_not_expired_again_in_that_period(db_session):
    pro = uuid.uuid4()
    _earn(db_session, pro, uuid.uuid4(), 120, status=RawwEntryStatus.spendable)
    ledger.expire_spendable(db_session, pro_user_id=pro)
    ledger.admin_adjust(db_session, pro_user_id=pro, amount=120, note="Expired in error", actor_user_id=uuid.uuid4())

    ledger.expire_spendable(db_session, pro_user_id=pro)

    assert _consistent(db_session, pro).spendable == 120
