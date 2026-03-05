import uuid
from decimal import Decimal

import pytest

from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.risk import RiskActionType, RiskLevel
from app.models.reward import RewardEntryType
from app.core.errors import APIError
from app.services.payouts import create_payout_request
from app.services.rewards import add_reward_entry
from app.services.trust_safety import (
    apply_risk_action,
    clear_risk_action,
    get_or_create_risk_profile,
    has_active_risk_action,
    reconcile_risk_profile,
    risk_hash_device,
    risk_hash_ip,
    risk_hash_session,
    set_risk_score_manual,
    trigger_risk_rule,
)


def _ensure_user(db_session, user_id: uuid.UUID, *, email: str, roles: list[UserRoleType] | None = None) -> None:
    row = db_session.get(UserAccount, user_id)
    if row is None:
        db_session.add(UserAccount(user_id=user_id, email=email))
    for role in roles or []:
        exists = db_session.query(UserRole).filter_by(user_id=user_id, role=role).first()
        if not exists:
            db_session.add(UserRole(user_id=user_id, role=role))
    db_session.commit()


def test_rule_trigger_applies_score_and_actions(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="risk1@example.com", roles=[UserRoleType.client])

    event = trigger_risk_rule(db_session, user_id=user_id, rule_id="booking.spam", payload={"count": 9})
    db_session.commit()

    assert event is not None
    profile = get_or_create_risk_profile(db_session, user_id)
    assert profile.risk_score >= 20
    assert profile.risk_level in {RiskLevel.medium, RiskLevel.high, RiskLevel.critical}
    assert has_active_risk_action(db_session, user_id=user_id, action_type=RiskActionType.throttle_bookings)


def test_hashing_does_not_store_raw_identifiers():
    ip = "203.0.113.7"
    device_id = "ios-device-123"
    session_id = "session-abc"

    assert risk_hash_ip(ip) != ip
    assert risk_hash_device(device_id) != device_id
    assert risk_hash_session(session_id) != session_id


def test_freeze_rewards_blocks_reward_grants(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="risk-reward@example.com", roles=[UserRoleType.client])

    apply_risk_action(db_session, user_id=user_id, action_type=RiskActionType.freeze_rewards, reason="test")
    row = add_reward_entry(
        db_session,
        user_id=user_id,
        amount=100,
        entry_type=RewardEntryType.earn,
        reference_type="test",
        reference_id="abc",
    )
    db_session.commit()

    assert row is None


def test_freeze_payouts_blocks_payout_requests(db_session):
    pro_user_id = uuid.uuid4()
    _ensure_user(db_session, pro_user_id, email="risk-pro@example.com", roles=[UserRoleType.pro])

    apply_risk_action(db_session, user_id=pro_user_id, action_type=RiskActionType.freeze_payouts, reason="test")
    with pytest.raises(APIError) as exc:
        create_payout_request(db_session, pro_user_id=pro_user_id, amount_eur=Decimal("60.00"))
    assert "frozen" in str(exc.value).lower()


def test_admin_clear_action_resumes_user_state(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="risk-clear@example.com", roles=[UserRoleType.client])

    apply_risk_action(db_session, user_id=user_id, action_type=RiskActionType.freeze_rewards, reason="test")
    assert has_active_risk_action(db_session, user_id=user_id, action_type=RiskActionType.freeze_rewards)

    cleared = clear_risk_action(db_session, user_id=user_id, action_type=RiskActionType.freeze_rewards)
    db_session.commit()

    assert cleared is True
    assert not has_active_risk_action(db_session, user_id=user_id, action_type=RiskActionType.freeze_rewards)


def test_reconciliation_corrects_score_drift(db_session):
    user_id = uuid.uuid4()
    _ensure_user(db_session, user_id, email="risk-reconcile@example.com", roles=[UserRoleType.client])

    trigger_risk_rule(db_session, user_id=user_id, rule_id="booking.spam", payload={"count": 6})
    profile = set_risk_score_manual(db_session, user_id=user_id, score=99, note="drift")
    assert profile.risk_score == 99

    reconciled = reconcile_risk_profile(db_session, user_id=user_id)
    db_session.commit()

    assert reconciled.risk_score == 20


def test_admin_risk_endpoints(client, db_session):
    admin_id = uuid.UUID("00000000-0000-0000-0000-0000000000aa")
    _ensure_user(db_session, admin_id, email="admin@example.com", roles=[UserRoleType.admin])

    put_resp = client.put(
        "/v1/admin/risk/rules/booking.spam",
        headers={"X-User-Id": str(admin_id)},
        json={"is_active": True, "params": {"window_hours": 24, "max_requests": 5}, "score_delta": 20, "action_on_trigger": {"actions": ["throttle_bookings"]}},
    )
    assert put_resp.status_code == 200

    list_resp = client.get("/v1/admin/risk/rules", headers={"X-User-Id": str(admin_id)})
    assert list_resp.status_code == 200
    assert any(item["id"] == "booking.spam" for item in list_resp.json())
