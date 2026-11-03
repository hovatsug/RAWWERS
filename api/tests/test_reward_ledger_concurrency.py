"""The same reward event, or the same points payment, arriving twice at once.

The idempotency check in rewards.add_reward_entry ran before the balance
lock: two workers handling one outbox event could both see "not yet", then
take the lock in turn and both credit. reserve_points_for_discount had the
same gap for a double tap. Each now checks again under the lock, and the
database holds one ledger entry per idempotency reference.

Each test holds the first transaction open at the lock, starts the second
in a thread so it passes the early check and waits on the lock, then lets
the first commit.
"""
import threading
import time
import uuid
from decimal import Decimal

import pytest
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError

from app.models.admin import UserAccount
from app.models.reward import (
    DiscountRedemption,
    RedemptionContextType,
    RewardBalance,
    RewardEntryType,
    RewardLedgerEntry,
)
from app.services.rewards import (
    add_reward_entry,
    release_redemption_for_context,
    reserve_points_for_discount,
)

from tests.conftest import TestingSessionLocal


def _user_with_balance(points: int) -> uuid.UUID:
    user_id = uuid.uuid4()
    db = TestingSessionLocal()
    try:
        db.add(UserAccount(user_id=user_id))
        db.flush()
        db.add(RewardBalance(user_id=user_id, balance=points))
        db.commit()
    finally:
        db.close()
    return user_id


def _race(first, second):
    """Run `first` in a held-open transaction, `second` in a thread that
    reaches the lock while `first` holds it, then commit `first`. Returns
    (first's result, second's result or the exception it raised)."""
    held, other = TestingSessionLocal(), TestingSessionLocal()
    outcome: dict = {}

    def run_second():
        try:
            outcome["value"] = second(other)
            other.commit()
        except Exception as error:  # noqa: BLE001 - the test inspects it
            other.rollback()
            outcome["value"] = error

    try:
        first_result = first(held)
        thread = threading.Thread(target=run_second)
        thread.start()
        time.sleep(0.6)  # long enough for the second to pass the early check and wait on the lock
        assert thread.is_alive(), "the second call should be waiting on the balance lock"
        held.commit()
        thread.join(timeout=20)
        return first_result, outcome.get("value")
    finally:
        held.close()
        other.close()


def _count(model, *where) -> int:
    db = TestingSessionLocal()
    try:
        return db.execute(select(func.count()).select_from(model).where(*where)).scalar_one()
    finally:
        db.close()


def _balance(user_id) -> int:
    db = TestingSessionLocal()
    try:
        return db.get(RewardBalance, user_id).balance
    finally:
        db.close()


def test_the_same_award_delivered_twice_at_once_credits_once():
    user_id = _user_with_balance(0)

    def award(db):
        return add_reward_entry(
            db, user_id=user_id, amount=100, entry_type=RewardEntryType.earn,
            reference_type="marketing_consent", reference_id="gig-1",
        ).id

    first, second = _race(award, award)

    assert not isinstance(second, Exception), second
    assert second == first
    assert _count(RewardLedgerEntry, RewardLedgerEntry.user_id == user_id) == 1
    assert _balance(user_id) == 100


def test_a_double_tap_on_a_points_payment_spends_once():
    user_id = _user_with_balance(5000)
    gig_id = uuid.uuid4()

    def spend(db):
        return reserve_points_for_discount(
            db, user_id=user_id, context_type=RedemptionContextType.gig_payment, context_id=gig_id,
            points=1000, payment_amount=Decimal("100.00"), currency="EUR",
        ).id

    first, second = _race(spend, spend)

    assert not isinstance(second, Exception), second
    assert second == first
    assert _count(DiscountRedemption, DiscountRedemption.user_id == user_id) == 1
    assert _balance(user_id) == 4000


def test_the_database_refuses_a_second_entry_for_the_same_reference():
    user_id = _user_with_balance(0)
    db = TestingSessionLocal()
    try:
        for _ in range(2):
            db.add(RewardLedgerEntry(
                user_id=user_id, entry_type=RewardEntryType.earn, amount=100, balance_after=100,
                reference_type="marketing_consent", reference_id="gig-1", meta={},
            ))
        with pytest.raises(IntegrityError):
            db.flush()
        db.rollback()
    finally:
        db.close()


def test_entries_without_a_reference_are_not_constrained():
    user_id = _user_with_balance(0)
    db = TestingSessionLocal()
    try:
        for _ in range(2):
            db.add(RewardLedgerEntry(
                user_id=user_id, entry_type=RewardEntryType.adjustment, amount=1, balance_after=1, meta={},
            ))
        db.commit()
    finally:
        db.close()
    assert _count(RewardLedgerEntry, RewardLedgerEntry.user_id == user_id) == 2


def test_a_released_payment_can_be_paid_with_points_again():
    """Spend and release entries reference the redemption, so paying again
    after a release is a new reference, not a collision."""
    user_id = _user_with_balance(5000)
    gig_id = uuid.uuid4()
    db = TestingSessionLocal()
    try:
        for _ in range(2):
            reserve_points_for_discount(
                db, user_id=user_id, context_type=RedemptionContextType.gig_payment, context_id=gig_id,
                points=1000, payment_amount=Decimal("100.00"), currency="EUR",
            )
            db.commit()
            release_redemption_for_context(db, RedemptionContextType.gig_payment, gig_id, reason="card declined")
            db.commit()
    finally:
        db.close()
    assert _balance(user_id) == 5000
    assert _count(RewardLedgerEntry, RewardLedgerEntry.user_id == user_id) == 4
