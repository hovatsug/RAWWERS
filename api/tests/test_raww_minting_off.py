"""Event minting into the shared reward ledger is off by default.

Owner's decision (2026-11-03): photographers earn RAWW from the 5% credit
on The Shelf's own ledger. The older per-event minting (proof_of_gigs) stays
in the code, dormant behind `raww_minting_enabled`, and balances it already
paid are neither converted nor deleted.
"""
import uuid

from sqlalchemy import func, select

from app.models.admin import UserAccount
from app.models.proof_of_gigs import RawwIssuanceEventType, RawwMintEvent
from app.models.reward import RewardBalance, RewardLedgerEntry
from app.services.feature_flags import is_feature_enabled
from app.services.proof_of_gigs import process_raww_mint_event


def test_minting_is_off_unless_an_admin_turns_it_on(db_session):
    assert is_feature_enabled(db_session, "raww_minting_enabled") is False


def test_an_event_mints_nothing_and_keeps_existing_balances(db_session):
    pro = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro))
    db_session.flush()
    db_session.add(RewardBalance(user_id=pro, balance=750))
    db_session.commit()

    result = process_raww_mint_event(
        db_session,
        payload={"event_type": RawwIssuanceEventType.review_posted.value, "review_id": str(uuid.uuid4()), "pro_user_id": str(pro)},
    )

    assert result is None
    assert db_session.execute(select(func.count()).select_from(RawwMintEvent)).scalar_one() == 0
    assert db_session.execute(select(func.count()).select_from(RewardLedgerEntry)).scalar_one() == 0
    assert db_session.get(RewardBalance, pro).balance == 750
