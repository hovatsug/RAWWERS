from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest

from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.payouts import EarningsEntryStatus, EarningsHoldReason, EarningsSourceType, PayoutRequestStatus
from app.services.payouts import (
    approve_payout_request,
    create_earnings_entry,
    create_earnings_hold,
    create_payout_request,
    ensure_default_platform_fee_policy,
    mark_payout_paid_manual,
    payout_balance_view,
    reverse_earnings_entries_for_source,
    settle_due_earnings_entries,
)


def _seed_user(db_session, user_id: str, roles: list[UserRoleType]) -> uuid.UUID:
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
    for role in roles:
        exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).one_or_none()
        if not exists:
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.flush()
    return uid


def _make_available_entry(db_session, *, pro_user_id: uuid.UUID, source_id: uuid.UUID, gross: Decimal) -> None:
    row = create_earnings_entry(
        db_session,
        pro_user_id=pro_user_id,
        source_type=EarningsSourceType.gig_base,
        source_id=source_id,
        gross_eur=gross,
        metadata={},
    )
    assert row is not None
    row.available_at = datetime.now(timezone.utc) - timedelta(days=1)
    settle_due_earnings_entries(db_session)


def test_earnings_entry_idempotent(db_session):
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000301", [UserRoleType.pro])
    source_id = uuid.UUID("00000000-0000-0000-0000-000000000302")

    a = create_earnings_entry(
        db_session,
        pro_user_id=pro_id,
        source_type=EarningsSourceType.gig_base,
        source_id=source_id,
        gross_eur=Decimal("120.00"),
        metadata={},
    )
    b = create_earnings_entry(
        db_session,
        pro_user_id=pro_id,
        source_type=EarningsSourceType.gig_base,
        source_id=source_id,
        gross_eur=Decimal("120.00"),
        metadata={},
    )
    db_session.commit()

    assert a is not None
    assert b is not None
    assert a.id == b.id


def test_settlement_delay_moves_pending_to_available(db_session):
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000311", [UserRoleType.pro])
    source_id = uuid.UUID("00000000-0000-0000-0000-000000000312")

    policy = ensure_default_platform_fee_policy(db_session)
    policy.settlement_delay_days = 0

    row = create_earnings_entry(
        db_session,
        pro_user_id=pro_id,
        source_type=EarningsSourceType.gig_base,
        source_id=source_id,
        gross_eur=Decimal("100.00"),
        metadata={},
    )
    assert row is not None
    assert row.status == EarningsEntryStatus.pending

    row.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    changed = settle_due_earnings_entries(db_session)
    db_session.commit()

    assert changed >= 1
    assert row.status == EarningsEntryStatus.available


def test_dispute_hold_blocks_availability(db_session):
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000321", [UserRoleType.pro])
    source_id = uuid.UUID("00000000-0000-0000-0000-000000000322")

    row = create_earnings_entry(
        db_session,
        pro_user_id=pro_id,
        source_type=EarningsSourceType.gig_base,
        source_id=source_id,
        gross_eur=Decimal("140.00"),
        metadata={},
    )
    assert row is not None
    create_earnings_hold(
        db_session,
        pro_user_id=pro_id,
        reason=EarningsHoldReason.dispute_open,
        amount_eur=None,
        source_type=EarningsSourceType.gig_base.value,
        source_id=source_id,
        created_by_admin_id=None,
    )

    row.available_at = datetime.now(timezone.utc) - timedelta(seconds=1)
    settle_due_earnings_entries(db_session)
    db_session.commit()

    assert row.status == EarningsEntryStatus.held


def test_payout_request_cannot_exceed_available(db_session):
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000331", [UserRoleType.pro])

    _make_available_entry(
        db_session,
        pro_user_id=pro_id,
        source_id=uuid.UUID("00000000-0000-0000-0000-000000000332"),
        gross=Decimal("100.00"),
    )
    db_session.commit()

    with pytest.raises(APIError):
        create_payout_request(db_session, pro_user_id=pro_id, amount_eur=Decimal("90.00"))


def test_approval_allocates_and_prevents_double_spending(db_session):
    admin_id = _seed_user(db_session, "00000000-0000-0000-0000-0000000000aa", [UserRoleType.admin])
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000341", [UserRoleType.pro])

    _make_available_entry(
        db_session,
        pro_user_id=pro_id,
        source_id=uuid.UUID("00000000-0000-0000-0000-000000000342"),
        gross=Decimal("200.00"),
    )

    req = create_payout_request(db_session, pro_user_id=pro_id, amount_eur=Decimal("100.00"))
    approve_payout_request(db_session, payout_request_id=req.id, admin_user_id=admin_id)
    db_session.commit()

    assert req.status == PayoutRequestStatus.approved

    with pytest.raises(APIError):
        create_payout_request(db_session, pro_user_id=pro_id, amount_eur=Decimal("100.00"))


def test_refund_reverses_earnings_and_updates_balance(db_session):
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000351", [UserRoleType.pro])
    source_id = uuid.UUID("00000000-0000-0000-0000-000000000352")

    _make_available_entry(
        db_session,
        pro_user_id=pro_id,
        source_id=source_id,
        gross=Decimal("100.00"),
    )

    reversed_count = reverse_earnings_entries_for_source(
        db_session,
        source_type=EarningsSourceType.gig_base,
        source_id=source_id,
        reason="test_refund",
    )
    db_session.commit()

    balance = payout_balance_view(db_session, pro_user_id=pro_id)
    assert reversed_count == 1
    assert balance["available_eur"] == Decimal("0.00")


def test_manual_mark_paid_flow(db_session):
    admin_id = _seed_user(db_session, "00000000-0000-0000-0000-0000000000ab", [UserRoleType.admin])
    pro_id = _seed_user(db_session, "00000000-0000-0000-0000-000000000361", [UserRoleType.pro])

    _make_available_entry(
        db_session,
        pro_user_id=pro_id,
        source_id=uuid.UUID("00000000-0000-0000-0000-000000000362"),
        gross=Decimal("100.00"),
    )

    req = create_payout_request(db_session, pro_user_id=pro_id, amount_eur=Decimal("80.00"))
    approve_payout_request(db_session, payout_request_id=req.id, admin_user_id=admin_id)

    row = mark_payout_paid_manual(
        db_session,
        payout_request_id=req.id,
        admin_user_id=admin_id,
        reference={"bank_transfer_ref": "BT-123"},
    )
    db_session.commit()

    assert row.status == PayoutRequestStatus.paid
    assert row.reference.get("bank_transfer_ref") == "BT-123"
