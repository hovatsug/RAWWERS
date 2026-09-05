"""payout.anomaly: freeze money landing in a just-changed account.

The rule used to measure from settlement, which froze every photographer
who withdrew on the day their earnings cleared - the ordinary case, not
an anomaly. And the freeze was written inside the request that then
refused, so the rollback discarded it: the photographer was blocked with
nothing recorded, nothing an admin could find, and nothing to lift.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.payouts import PayoutAccount, PayoutAccountStatus, PayoutMethod
from app.models.risk import RiskAction, RiskActionStatus, RiskActionType
from app.services.trust_safety import (
    evaluate_payout_anomaly_rule,
    has_active_risk_action,
)


def _seed(db_session, *, account_changed_hours_ago: float) -> uuid.UUID:
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db_session.commit()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.pro))
    db_session.add(
        PayoutAccount(
            pro_user_id=uid,
            payout_method=PayoutMethod.bank_manual,
            status=PayoutAccountStatus.not_set,
            updated_at=datetime.now(timezone.utc) - timedelta(hours=account_changed_hours_ago),
        )
    )
    db_session.commit()
    return uid


def _frozen(db_session, uid) -> bool:
    return has_active_risk_action(db_session, user_id=uid, action_type=RiskActionType.freeze_payouts)


def test_a_settled_balance_alone_never_freezes(db_session):
    # The bug this replaced: a photographer who waited seven days and
    # withdrew the day it cleared was treated as an anomaly. Settlement
    # timing is now irrelevant to this rule; only the account matters.
    uid = _seed(db_session, account_changed_hours_ago=24 * 30)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    assert not _frozen(db_session, uid)


def test_a_freshly_changed_account_freezes(db_session):
    uid = _seed(db_session, account_changed_hours_ago=0.1)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    assert _frozen(db_session, uid)


def test_the_window_has_an_edge_and_it_holds(db_session):
    just_outside = _seed(db_session, account_changed_hours_ago=25)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=just_outside)
    assert not _frozen(db_session, just_outside)

    just_inside = _seed(db_session, account_changed_hours_ago=23)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=just_inside)
    assert _frozen(db_session, just_inside)


def test_the_freeze_is_committed_so_it_survives_the_refusal(db_session):
    # The caller raises a 403 immediately after this returns. Before, the
    # rollback took the freeze with it and left no trace at all.
    uid = _seed(db_session, account_changed_hours_ago=0.1)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    db_session.rollback()

    actions = db_session.query(RiskAction).filter_by(user_id=uid, status=RiskActionStatus.active).all()
    assert {a.action_type for a in actions} == {RiskActionType.freeze_payouts, RiskActionType.manual_review}


def test_an_admins_clear_is_not_undone_on_the_next_request(db_session):
    # A clear that the rule immediately reverses is not a clear. Only a
    # later account change re-arms it.
    uid = _seed(db_session, account_changed_hours_ago=0.1)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    assert _frozen(db_session, uid)

    action = db_session.query(RiskAction).filter_by(
        user_id=uid, action_type=RiskActionType.freeze_payouts, status=RiskActionStatus.active
    ).one()
    action.status = RiskActionStatus.cleared
    action.cleared_at = datetime.now(timezone.utc)
    db_session.commit()

    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    assert not _frozen(db_session, uid), "the rule re-froze an account an admin had already reviewed"


def test_a_later_account_change_re_arms_the_rule(db_session):
    # The clear covers the change it was reviewing, not every future one -
    # otherwise clearing once would disable the rule for that pro forever.
    uid = _seed(db_session, account_changed_hours_ago=0.1)
    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    action = db_session.query(RiskAction).filter_by(
        user_id=uid, action_type=RiskActionType.freeze_payouts, status=RiskActionStatus.active
    ).one()
    action.status = RiskActionStatus.cleared
    action.cleared_at = datetime.now(timezone.utc)
    db_session.commit()

    account = db_session.query(PayoutAccount).filter_by(pro_user_id=uid).one()
    account.updated_at = datetime.now(timezone.utc)
    db_session.commit()

    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    assert _frozen(db_session, uid)


def test_no_payout_account_means_nothing_to_be_suspicious_of(db_session):
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db_session.commit()
    evaluate_payout_anomaly_rule(db_session, pro_user_id=uid)
    assert not _frozen(db_session, uid)
