"""The payout routes, end to end: a photographer asks for their money, an
admin approves or rejects it, and an approved payout is marked paid.

The rules themselves were tested only through the service functions
(test_payouts_v1.py). These go through the routes, which is where who may
call each step, the audit trail, and an all-or-nothing transaction are
decided - money leaves the platform at the end of this chain.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from app.models.admin import AdminAuditLog, UserAccount, UserRole, UserRoleType
from app.models.outbox import OutboxEvent
from app.models.payouts import EarningsSourceType, PayoutAllocation, PayoutRequest, PayoutRequestStatus
from app.models.risk import RiskActionType
from app.services.payouts import create_earnings_entry, payout_balance_view, settle_due_earnings_entries
from app.services.trust_safety import apply_risk_action
from sqlalchemy import func, select

ADMIN = "00000000-0000-0000-0000-0000000000aa"  # the suite's admin (conftest)


def _user(db_session, roles) -> str:
    uid = uuid.uuid4()
    db_session.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db_session.flush()
    for role in roles:
        db_session.add(UserRole(user_id=uid, role=role))
    db_session.commit()
    return str(uid)


def _earned(db_session, pro: str, gross: str) -> None:
    """Earnings settled and available to withdraw."""
    row = create_earnings_entry(
        db_session,
        pro_user_id=uuid.UUID(pro),
        source_type=EarningsSourceType.gig_base,
        source_id=uuid.uuid4(),
        gross_eur=Decimal(gross),
        metadata={},
    )
    row.available_at = datetime.now(timezone.utc) - timedelta(days=1)
    db_session.flush()  # the session does not autoflush; settling must see the date
    settle_due_earnings_entries(db_session)
    db_session.commit()


def _withdrawable(db_session, pro: str) -> Decimal:
    db_session.expire_all()
    return payout_balance_view(db_session, pro_user_id=uuid.UUID(pro))["withdrawable_eur"]


def _request(client, pro: str, amount: str):
    return client.post("/v1/pro/payouts/request", headers={"X-User-Id": pro}, json={"amount_eur": amount})


def _admin(client, path: str, body=None, actor=ADMIN):
    return client.post(path, headers={"X-User-Id": actor}, json=body or {})


def _payout(db_session, payout_id) -> PayoutRequest:
    db_session.expire_all()
    return db_session.get(PayoutRequest, uuid.UUID(payout_id))


def _allocated(db_session, payout_id) -> Decimal:
    return db_session.execute(
        select(func.coalesce(func.sum(PayoutAllocation.amount_eur), 0)).where(PayoutAllocation.payout_request_id == uuid.UUID(payout_id))
    ).scalar_one()


def _audit(db_session, payout_id) -> list[str]:
    db_session.expire_all()
    return [
        row.action
        for row in db_session.execute(
            select(AdminAuditLog).where(AdminAuditLog.target_type == "payout_request", AdminAuditLog.target_id == payout_id).order_by(AdminAuditLog.created_at)
        ).scalars()
    ]


def _executions(db_session, payout_id) -> int:
    db_session.expire_all()
    return sum(1 for e in db_session.execute(select(OutboxEvent).where(OutboxEvent.topic == "payout.execute")).scalars() if e.payload.get("payout_request_id") == payout_id)


@pytest.fixture
def pro(db_session):
    pro = _user(db_session, [UserRoleType.pro])
    _earned(db_session, pro, "200.00")
    assert _withdrawable(db_session, pro) == Decimal("160.00"), "200 earned, less the 20% fee, settled"
    return pro


@pytest.fixture
def requested(client, db_session, pro):
    resp = _request(client, pro, "80.00")
    assert resp.status_code == 200, resp.text
    return resp.json()["id"]


# --- asking for a payout ----------------------------------------------------------------


def test_a_photographer_can_ask_for_what_they_can_withdraw(client, db_session, pro):
    available = _withdrawable(db_session, pro)

    resp = _request(client, pro, str(available))

    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "requested"
    assert Decimal(resp.json()["amount_eur"]) == available


def test_more_than_can_be_withdrawn_is_refused_and_nothing_is_recorded(client, db_session, pro):
    too_much = _withdrawable(db_session, pro) + Decimal("0.01")

    resp = _request(client, pro, str(too_much))

    assert resp.status_code == 422, resp.text
    assert db_session.execute(select(func.count()).select_from(PayoutRequest).where(PayoutRequest.pro_user_id == uuid.UUID(pro))).scalar_one() == 0


def test_less_than_the_minimum_is_refused(client, db_session, pro):
    assert _request(client, pro, "49.99").status_code == 422


def test_amounts_are_kept_to_the_cent(client, db_session, pro):
    resp = _request(client, pro, "60.005")

    assert resp.status_code == 200, resp.text
    assert _payout(db_session, resp.json()["id"]).amount_eur == Decimal("60.01")


def test_a_third_request_in_a_week_is_refused(client, db_session, pro):
    assert _request(client, pro, "50.00").status_code == 200
    assert _request(client, pro, "50.00").status_code == 200

    assert _request(client, pro, "50.00").status_code == 429


def test_frozen_payouts_cannot_be_requested(client, db_session, pro):
    apply_risk_action(db_session, user_id=uuid.UUID(pro), action_type=RiskActionType.freeze_payouts, reason="investigation")
    db_session.commit()

    assert _request(client, pro, "60.00").status_code == 403


def test_only_a_photographer_can_ask(client, db_session):
    someone = _user(db_session, [UserRoleType.client])

    assert _request(client, someone, "60.00").status_code == 403
    assert client.post("/v1/pro/payouts/request", json={"amount_eur": "60.00"}).status_code == 401


# --- approving --------------------------------------------------------------------------


def test_approving_sets_the_money_aside_queues_the_transfer_and_is_audited(client, db_session, pro, requested):
    before = _withdrawable(db_session, pro)

    resp = _admin(client, f"/v1/admin/payouts/{requested}/approve")

    assert resp.status_code == 200, resp.text
    assert _payout(db_session, requested).status == PayoutRequestStatus.approved
    assert _allocated(db_session, requested) == Decimal("80.00")
    # Already out of what can be withdrawn since it was requested; approving
    # moves it from Requested to Reserved, not out of Available again.
    assert _withdrawable(db_session, pro) == before
    assert _executions(db_session, requested) == 1
    assert _audit(db_session, requested) == ["payout_approved"]


def test_only_an_admin_can_approve_not_even_the_photographer(client, db_session, pro, requested):
    for actor in (pro, _user(db_session, [UserRoleType.client])):
        assert _admin(client, f"/v1/admin/payouts/{requested}/approve", actor=actor).status_code == 403

    assert _payout(db_session, requested).status == PayoutRequestStatus.requested
    assert _allocated(db_session, requested) == 0
    assert _executions(db_session, requested) == 0


def test_approving_twice_sets_aside_and_transfers_once(client, db_session, pro, requested):
    assert _admin(client, f"/v1/admin/payouts/{requested}/approve").status_code == 200

    assert _admin(client, f"/v1/admin/payouts/{requested}/approve").status_code == 409

    assert _allocated(db_session, requested) == Decimal("80.00")
    assert _executions(db_session, requested) == 1
    assert _audit(db_session, requested) == ["payout_approved"]


def test_two_requests_cannot_both_be_paid_from_the_same_money(client, db_session, pro):
    """Asking sets the money aside (Requested): a second request can only
    ask for what is still available, so it is refused when asked - before
    anything is approved or allocated."""
    first = _request(client, pro, "150.00").json()["id"]

    resp = _request(client, pro, "150.00")

    assert resp.status_code == 422, resp.text
    assert db_session.query(PayoutRequest).filter(PayoutRequest.pro_user_id == uuid.UUID(str(pro))).count() == 1
    assert _admin(client, f"/v1/admin/payouts/{first}/approve").status_code == 200


def test_an_unknown_payout_is_not_found(client, db_session):
    assert _admin(client, f"/v1/admin/payouts/{uuid.uuid4()}/approve").status_code == 404


# --- rejecting --------------------------------------------------------------------------


def test_rejecting_keeps_the_reason_audits_it_and_leaves_the_money_withdrawable(client, db_session, pro, requested):
    before = _withdrawable(db_session, pro)

    resp = _admin(client, f"/v1/admin/payouts/{requested}/reject", {"reason": "Bank details do not match"})

    assert resp.status_code == 200, resp.text
    row = _payout(db_session, requested)
    assert row.status == PayoutRequestStatus.rejected and row.failure_reason == "Bank details do not match"
    assert _allocated(db_session, requested) == 0
    # Back in Available: it left when it was requested.
    assert _withdrawable(db_session, pro) == before + Decimal("80.00")
    assert _audit(db_session, requested) == ["payout_rejected"]


def test_an_approved_payout_cannot_be_rejected(client, db_session, pro, requested):
    """Its money is already set aside and its transfer queued."""
    _admin(client, f"/v1/admin/payouts/{requested}/approve")

    assert _admin(client, f"/v1/admin/payouts/{requested}/reject", {"reason": "late"}).status_code == 409
    assert _payout(db_session, requested).status == PayoutRequestStatus.approved


def test_only_an_admin_can_reject(client, db_session, pro, requested):
    assert _admin(client, f"/v1/admin/payouts/{requested}/reject", {"reason": "x"}, actor=pro).status_code == 403
    assert _payout(db_session, requested).status == PayoutRequestStatus.requested


# --- marking paid -----------------------------------------------------------------------


def test_marking_an_approved_payout_paid_records_the_reference_and_is_audited(client, db_session, pro, requested):
    _admin(client, f"/v1/admin/payouts/{requested}/approve")
    after_approval = _withdrawable(db_session, pro)

    resp = _admin(client, f"/v1/admin/payouts/{requested}/mark-paid", {"reference": {"bank_transfer_ref": "BT-9"}})

    assert resp.status_code == 200, resp.text
    row = _payout(db_session, requested)
    assert row.status == PayoutRequestStatus.paid and row.paid_at is not None
    assert row.reference["bank_transfer_ref"] == "BT-9"
    assert _withdrawable(db_session, pro) == after_approval, "paid money stays out of the balance"
    assert _audit(db_session, requested) == ["payout_approved", "payout_mark_paid"]


@pytest.mark.parametrize("state", ["requested", "rejected", "paid"])
def test_only_an_approved_payout_can_be_marked_paid(client, db_session, pro, requested, state):
    if state == "rejected":
        _admin(client, f"/v1/admin/payouts/{requested}/reject", {"reason": "x"})
    elif state == "paid":
        _admin(client, f"/v1/admin/payouts/{requested}/approve")
        _admin(client, f"/v1/admin/payouts/{requested}/mark-paid", {"reference": {"ref": "1"}})
    before = _payout(db_session, requested).status

    resp = _admin(client, f"/v1/admin/payouts/{requested}/mark-paid", {"reference": {"ref": "2"}})

    assert resp.status_code == 409, resp.text
    assert _payout(db_session, requested).status == before


def test_only_an_admin_can_mark_paid(client, db_session, pro, requested):
    _admin(client, f"/v1/admin/payouts/{requested}/approve")

    assert _admin(client, f"/v1/admin/payouts/{requested}/mark-paid", {"reference": {}}, actor=pro).status_code == 403
    assert _payout(db_session, requested).status == PayoutRequestStatus.approved
