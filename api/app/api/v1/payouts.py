from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import Dispute
from app.models.payouts import EarningsHold, EarningsSourceType, PayoutRequestStatus, PlatformFeePolicy
from app.schemas.media import CurrentUser
from app.schemas.payouts import (
    AdminFinanceProDetailResponse,
    AdminFinanceProItem,
    AdminFinanceProsResponse,
    AdminPayoutMarkPaidRequest,
    AdminPayoutRejectRequest,
    EarningsBalanceView,
    EarningsHoldCreateRequest,
    EarningsHoldView,
    EarningsLedgerResponse,
    EarningsLedgerItemView,
    PlatformFeePolicyUpdateRequest,
    PlatformFeePolicyView,
    PayoutAccountUpsertRequest,
    PayoutAccountView,
    PayoutListResponse,
    PayoutRequestCreateRequest,
    PayoutRequestView,
)
from app.services.audit import add_admin_audit_log
from app.services.authz import get_user_roles
from app.models.admin import UserRoleType
from app.services.payouts import (
    approve_payout_request,
    create_earnings_hold,
    create_payout_request,
    ensure_default_platform_fee_policy,
    execute_payout_request,
    get_or_create_payout_account,
    list_finance_pros,
    list_payout_requests_admin,
    list_pro_earnings_entries,
    list_pro_payout_requests,
    mark_payout_paid_manual,
    payout_balance_view,
    reject_payout_request,
    release_earnings_hold,
    upsert_payout_account,
)

router = APIRouter(tags=["payouts"])


@router.get("/pro/earnings/balance", response_model=EarningsBalanceView)
def get_my_earnings_balance(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EarningsBalanceView:
    _ensure_pro_user(db, user.user_id)
    return EarningsBalanceView(**payout_balance_view(db, pro_user_id=user.user_id))


@router.get("/pro/earnings/ledger", response_model=EarningsLedgerResponse)
def get_my_earnings_ledger(
    source_type: EarningsSourceType | None = None,
    from_at: datetime | None = Query(default=None, alias="from"),
    to_at: datetime | None = Query(default=None, alias="to"),
    limit: int = Query(default=100, ge=1, le=500),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> EarningsLedgerResponse:
    _ensure_pro_user(db, user.user_id)
    rows = list_pro_earnings_entries(
        db,
        pro_user_id=user.user_id,
        source_type=source_type,
        from_at=from_at,
        to_at=to_at,
        limit=limit,
    )
    return EarningsLedgerResponse(items=[EarningsLedgerItemView.model_validate(row, from_attributes=True) for row in rows])


@router.get("/pro/payouts", response_model=PayoutListResponse)
def get_my_payouts(
    limit: int = Query(default=100, ge=1, le=500),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutListResponse:
    _ensure_pro_user(db, user.user_id)
    rows = list_pro_payout_requests(db, pro_user_id=user.user_id, limit=limit)
    return PayoutListResponse(items=[PayoutRequestView.model_validate(row, from_attributes=True) for row in rows])


@router.post("/pro/payouts/request", response_model=PayoutRequestView)
def request_my_payout(
    body: PayoutRequestCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    _ensure_pro_user(db, user.user_id)
    row = create_payout_request(db, pro_user_id=user.user_id, amount_eur=body.amount_eur)
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.get("/pro/payouts/account", response_model=PayoutAccountView)
def get_my_payout_account(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutAccountView:
    _ensure_pro_user(db, user.user_id)
    row = get_or_create_payout_account(db, pro_user_id=user.user_id)
    db.commit()
    db.refresh(row)
    return PayoutAccountView.model_validate(row, from_attributes=True)


@router.put("/pro/payouts/account", response_model=PayoutAccountView)
def put_my_payout_account(
    body: PayoutAccountUpsertRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PayoutAccountView:
    _ensure_pro_user(db, user.user_id)
    row = upsert_payout_account(
        db,
        pro_user_id=user.user_id,
        payout_method=body.payout_method,
        stripe_connect_account_id=body.stripe_connect_account_id,
        bank_details_encrypted=body.bank_details_encrypted,
        status=body.status,
    )
    db.commit()
    db.refresh(row)
    return PayoutAccountView.model_validate(row, from_attributes=True)


@router.get("/admin/finance/pros", response_model=AdminFinanceProsResponse)
def list_finance_pros_admin(
    city: str | None = None,
    min_available: Decimal | None = None,
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminFinanceProsResponse:
    rows = list_finance_pros(db, city=city, min_available=min_available, limit=limit)
    return AdminFinanceProsResponse(items=[AdminFinanceProItem(**item) for item in rows])


@router.get("/admin/finance/pros/{pro_user_id}", response_model=AdminFinanceProDetailResponse)
def get_finance_pro_detail_admin(
    pro_user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminFinanceProDetailResponse:
    balance = EarningsBalanceView(**payout_balance_view(db, pro_user_id=pro_user_id))
    account = PayoutAccountView.model_validate(get_or_create_payout_account(db, pro_user_id=pro_user_id), from_attributes=True)
    holds = db.execute(
        select(EarningsHold).where(EarningsHold.pro_user_id == pro_user_id).order_by(EarningsHold.created_at.desc()).limit(50)
    ).scalars().all()
    disputes = db.execute(
        select(Dispute).where(Dispute.against_user_id == pro_user_id).order_by(Dispute.created_at.desc()).limit(20)
    ).scalars().all()
    payouts = list_pro_payout_requests(db, pro_user_id=pro_user_id, limit=20)
    return AdminFinanceProDetailResponse(
        pro_user_id=pro_user_id,
        balance=balance,
        payout_account=account,
        holds=[EarningsHoldView.model_validate(item, from_attributes=True) for item in holds],
        recent_disputes=[
            {"id": str(item.id), "status": item.status.value, "category": item.category.value, "opened_at": item.opened_at.isoformat()}
            for item in disputes
        ],
        recent_payouts=[PayoutRequestView.model_validate(item, from_attributes=True) for item in payouts],
    )


@router.get("/admin/payouts", response_model=PayoutListResponse)
def list_payouts_admin(
    status: PayoutRequestStatus | None = None,
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutListResponse:
    rows = list_payout_requests_admin(db, status=status, limit=limit)
    return PayoutListResponse(items=[PayoutRequestView.model_validate(row, from_attributes=True) for row in rows])


@router.post("/admin/payouts/{payout_request_id}/approve", response_model=PayoutRequestView)
def approve_payout_admin(
    payout_request_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    row = approve_payout_request(db, payout_request_id=payout_request_id, admin_user_id=actor.user_id)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="payout_request",
        target_id=str(row.id),
        action="payout_approved",
        metadata={"pro_user_id": str(row.pro_user_id), "amount_eur": str(row.amount_eur)},
    )
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.post("/admin/payouts/{payout_request_id}/reject", response_model=PayoutRequestView)
def reject_payout_admin(
    payout_request_id: uuid.UUID,
    body: AdminPayoutRejectRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    row = reject_payout_request(db, payout_request_id=payout_request_id, admin_user_id=actor.user_id, reason=body.reason)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="payout_request",
        target_id=str(row.id),
        action="payout_rejected",
        reason=body.reason,
        metadata={},
    )
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.post("/admin/payouts/{payout_request_id}/mark-paid", response_model=PayoutRequestView)
def mark_paid_payout_admin(
    payout_request_id: uuid.UUID,
    body: AdminPayoutMarkPaidRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PayoutRequestView:
    row = mark_payout_paid_manual(
        db,
        payout_request_id=payout_request_id,
        admin_user_id=actor.user_id,
        reference=body.reference,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="payout_request",
        target_id=str(row.id),
        action="payout_mark_paid",
        metadata={"reference": body.reference},
    )
    db.commit()
    db.refresh(row)
    return PayoutRequestView.model_validate(row, from_attributes=True)


@router.post("/admin/holds/create", response_model=EarningsHoldView)
def create_hold_admin(
    body: EarningsHoldCreateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> EarningsHoldView:
    row = create_earnings_hold(
        db,
        pro_user_id=body.pro_user_id,
        reason=body.reason,
        amount_eur=body.amount_eur,
        source_type=body.source_type,
        source_id=body.source_id,
        created_by_admin_id=actor.user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="earnings_hold",
        target_id=str(row.id),
        action="earnings_hold_created",
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return EarningsHoldView.model_validate(row, from_attributes=True)


@router.post("/admin/holds/{hold_id}/release", response_model=EarningsHoldView)
def release_hold_admin(
    hold_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> EarningsHoldView:
    row = db.get(EarningsHold, hold_id)
    if not row:
        raise APIError(code="not_found", message="Hold not found", status_code=404)
    release_earnings_hold(db, row)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="earnings_hold",
        target_id=str(row.id),
        action="earnings_hold_released",
        metadata={},
    )
    db.commit()
    db.refresh(row)
    return EarningsHoldView.model_validate(row, from_attributes=True)


@router.get("/admin/finance/fee-policy", response_model=PlatformFeePolicyView)
def get_fee_policy_admin(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PlatformFeePolicyView:
    row = ensure_default_platform_fee_policy(db)
    return PlatformFeePolicyView.model_validate(row, from_attributes=True)


@router.put("/admin/finance/fee-policy", response_model=PlatformFeePolicyView)
def put_fee_policy_admin(
    body: PlatformFeePolicyUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PlatformFeePolicyView:
    row = ensure_default_platform_fee_policy(db)
    row.fee_percent_gigs = body.fee_percent_gigs
    row.fee_percent_extras = body.fee_percent_extras
    row.fee_percent_studioverse = body.fee_percent_studioverse
    row.settlement_delay_days = body.settlement_delay_days
    row.dispute_hold_days = body.dispute_hold_days
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="platform_fee_policy",
        target_id=str(row.id),
        action="platform_fee_policy_updated",
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return PlatformFeePolicyView.model_validate(row, from_attributes=True)


def _ensure_pro_user(db: Session, user_id: uuid.UUID) -> None:
    roles = get_user_roles(db, user_id)
    if UserRoleType.pro not in roles:
        raise APIError(code="forbidden", message="Pro role required", status_code=403)
