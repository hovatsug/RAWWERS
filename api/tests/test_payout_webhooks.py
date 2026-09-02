import uuid
from decimal import Decimal

from app.models.admin import UserAccount
from app.models.payouts import (
    PayoutAccount,
    PayoutAccountStatus,
    PayoutEvent,
    PayoutMethod,
    PayoutRequest,
    PayoutRequestStatus,
)
from app.api.v1.webhooks import _apply_stripe_event
from sqlalchemy import select


def _ensure_account(db_session, user_id: uuid.UUID):
    if not db_session.get(UserAccount, user_id):
        db_session.add(UserAccount(user_id=user_id))
        db_session.commit()


def _create_payout_request(db_session, pro_id: uuid.UUID, *, status: PayoutRequestStatus) -> PayoutRequest:
    row = PayoutRequest(pro_user_id=pro_id, amount_eur=Decimal("100.00"), status=status, reference={})
    db_session.add(row)
    db_session.commit()
    db_session.refresh(row)
    return row


def _create_payout_account(db_session, pro_id: uuid.UUID, *, stripe_account_id: str, status: PayoutAccountStatus) -> PayoutAccount:
    row = PayoutAccount(
        pro_user_id=pro_id,
        payout_method=PayoutMethod.stripe_connect,
        stripe_connect_account_id=stripe_account_id,
        status=status,
    )
    db_session.add(row)
    db_session.commit()
    db_session.refresh(row)
    return row


# ---------------------------------------------------------------------------
# transfer.created: reconciliation confirmation for a payout request that
# somehow wasn't already marked paid by execute_payout_request's synchronous
# path (e.g. the app crashed between the Stripe call and the DB commit).
# ---------------------------------------------------------------------------


def test_transfer_created_reconciles_a_request_not_already_marked_paid(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    request = _create_payout_request(db_session, pro_id, status=PayoutRequestStatus.processing)

    _apply_stripe_event(
        db_session,
        "transfer.created",
        {"id": "tr_123", "metadata": {"payout_request_id": str(request.id)}},
    )
    db_session.commit()

    db_session.refresh(request)
    assert request.status == PayoutRequestStatus.paid
    assert request.paid_at is not None
    assert request.reference["stripe_transfer_id"] == "tr_123"

    events = db_session.execute(select(PayoutEvent).where(PayoutEvent.payout_request_id == request.id)).scalars().all()
    assert len(events) == 1
    assert events[0].type == "transfer_created"


def test_transfer_created_is_idempotent_and_does_not_regress_an_already_paid_request(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    request = _create_payout_request(db_session, pro_id, status=PayoutRequestStatus.paid)
    request.paid_at = None  # sentinel: prove a second no-op branch doesn't overwrite this
    db_session.commit()

    event = {"id": "tr_456", "metadata": {"payout_request_id": str(request.id)}}
    _apply_stripe_event(db_session, "transfer.created", event)
    db_session.commit()
    _apply_stripe_event(db_session, "transfer.created", event)
    db_session.commit()

    db_session.refresh(request)
    assert request.status == PayoutRequestStatus.paid
    assert request.paid_at is None  # untouched - it was already paid, no reconciliation write happened

    events = db_session.execute(select(PayoutEvent).where(PayoutEvent.payout_request_id == request.id)).scalars().all()
    assert len(events) == 1  # not duplicated on retry


def test_transfer_created_without_matching_payout_request_is_a_noop(db_session):
    _apply_stripe_event(db_session, "transfer.created", {"id": "tr_orphan", "metadata": {"payout_request_id": str(uuid.uuid4())}})
    db_session.commit()  # must not raise


def test_transfer_created_without_metadata_is_a_noop(db_session):
    _apply_stripe_event(db_session, "transfer.created", {"id": "tr_no_meta"})
    db_session.commit()  # must not raise


# ---------------------------------------------------------------------------
# transfer.failed: an async failure after the synchronous path already
# reported success (e.g. the transfer was reversed).
# ---------------------------------------------------------------------------


def test_transfer_failed_marks_a_paid_request_failed(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    request = _create_payout_request(db_session, pro_id, status=PayoutRequestStatus.paid)

    _apply_stripe_event(
        db_session,
        "transfer.failed",
        {"id": "tr_789", "metadata": {"payout_request_id": str(request.id)}, "failure_message": "destination account closed"},
    )
    db_session.commit()

    db_session.refresh(request)
    assert request.status == PayoutRequestStatus.failed
    assert request.failure_reason == "destination account closed"

    events = db_session.execute(select(PayoutEvent).where(PayoutEvent.payout_request_id == request.id)).scalars().all()
    assert len(events) == 1
    assert events[0].type == "transfer_failed"


def test_transfer_failed_is_idempotent(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    request = _create_payout_request(db_session, pro_id, status=PayoutRequestStatus.paid)

    event = {"id": "tr_999", "metadata": {"payout_request_id": str(request.id)}, "failure_message": "insufficient funds"}
    _apply_stripe_event(db_session, "transfer.failed", event)
    db_session.commit()
    _apply_stripe_event(db_session, "transfer.failed", event)
    db_session.commit()

    events = db_session.execute(select(PayoutEvent).where(PayoutEvent.payout_request_id == request.id)).scalars().all()
    assert len(events) == 1


# ---------------------------------------------------------------------------
# account.updated: maps Stripe Connect capability flags onto the coarser
# PayoutAccountStatus enum.
# ---------------------------------------------------------------------------


def test_account_updated_marks_account_active_when_fully_enabled(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    account = _create_payout_account(db_session, pro_id, stripe_account_id="acct_123", status=PayoutAccountStatus.pending_verification)

    _apply_stripe_event(
        db_session,
        "account.updated",
        {"id": "acct_123", "charges_enabled": True, "payouts_enabled": True, "details_submitted": True},
    )
    db_session.commit()

    db_session.refresh(account)
    assert account.status == PayoutAccountStatus.active


def test_account_updated_marks_account_disabled_when_requirements_disabled(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    account = _create_payout_account(db_session, pro_id, stripe_account_id="acct_456", status=PayoutAccountStatus.active)

    _apply_stripe_event(
        db_session,
        "account.updated",
        {
            "id": "acct_456",
            "charges_enabled": False,
            "payouts_enabled": False,
            "details_submitted": True,
            "requirements": {"disabled_reason": "requirements.past_due"},
        },
    )
    db_session.commit()

    db_session.refresh(account)
    assert account.status == PayoutAccountStatus.disabled


def test_account_updated_stays_pending_verification_when_incomplete_and_not_disabled(db_session):
    pro_id = uuid.uuid4()
    _ensure_account(db_session, pro_id)
    account = _create_payout_account(db_session, pro_id, stripe_account_id="acct_789", status=PayoutAccountStatus.not_set)

    _apply_stripe_event(
        db_session,
        "account.updated",
        {"id": "acct_789", "charges_enabled": False, "payouts_enabled": False, "details_submitted": False},
    )
    db_session.commit()

    db_session.refresh(account)
    assert account.status == PayoutAccountStatus.pending_verification


def test_account_updated_without_matching_account_is_a_noop(db_session):
    _apply_stripe_event(
        db_session,
        "account.updated",
        {"id": "acct_unknown", "charges_enabled": True, "payouts_enabled": True, "details_submitted": True},
    )
    db_session.commit()  # must not raise
