from __future__ import annotations

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.reward import RewardRule
from app.schemas.media import CurrentUser
from app.schemas.reward import (
    AdminRewardAdjustRequest,
    AdminRewardAdjustResponse,
    AdminRewardRuleUpdateRequest,
    AdminRewardRuleView,
    DiscountRedemptionView,
    ReferralClaimRequest,
    ReferralMeResponse,
    RewardBalanceResponse,
    RewardLedgerItemView,
    RewardLedgerResponse,
    RewardSpendRequest,
)
from app.services.abuse import detect_referral_abuse
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.feature_flags import is_feature_enabled
from app.services.rate_limit import enforce_named_rate_limit
from app.services.rewards import (
    claim_referral_code,
    create_manual_adjustment,
    ensure_default_reward_rules,
    get_or_create_referral_code,
    get_reward_balance,
    list_reward_ledger,
    maybe_issue_client_signup_referral_reward,
    reserve_points_for_discount,
)

router = APIRouter(tags=["referrals_rewards"])


@router.get("/referrals/me", response_model=ReferralMeResponse)
def my_referral_code(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ReferralMeResponse:
    referral = get_or_create_referral_code(db, user.user_id)
    db.commit()
    return ReferralMeResponse(code=referral.code, link_stub=f"/r/{referral.code}")


@router.post("/referrals/claim")
def claim_referral(
    body: ReferralClaimRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
    request: Request | None = None,
) -> dict:
    enforce_named_rate_limit("referral_claims", principal=str(user.user_id))
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    attribution = claim_referral_code(db, user.user_id, body.code)
    detect_referral_abuse(
        db,
        referred_user_id=user.user_id,
        referrer_user_id=attribution.referrer_user_id,
        ip=_request_ip(request),
    )
    reward_entry = maybe_issue_client_signup_referral_reward(db, user.user_id)
    log_event(
        db,
        event_name="referral.claimed",
        user_id=user.user_id,
        properties={"referral_code": attribution.referral_code, "referrer_user_id": str(attribution.referrer_user_id)},
    )
    if reward_entry:
        log_event(
            db,
            event_name="reward.earned",
            user_id=reward_entry.user_id,
            properties={"rule_code": reward_entry.rule_code, "amount": reward_entry.amount},
        )
    db.commit()
    return {"ok": True, "referrer_user_id": str(attribution.referrer_user_id)}


@router.get("/rewards/balance", response_model=RewardBalanceResponse)
def rewards_balance(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RewardBalanceResponse:
    balance = get_reward_balance(db, user.user_id)
    db.commit()
    return RewardBalanceResponse(balance=balance.balance)


@router.get("/rewards/ledger", response_model=RewardLedgerResponse)
def rewards_ledger(
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RewardLedgerResponse:
    total, rows = list_reward_ledger(db, user.user_id, limit=limit, offset=offset)
    db.commit()
    return RewardLedgerResponse(
        total=total,
        items=[RewardLedgerItemView.model_validate(row, from_attributes=True) for row in rows],
    )


@router.post("/rewards/spend", response_model=DiscountRedemptionView)
def reserve_reward_spend(
    body: RewardSpendRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DiscountRedemptionView:
    enforce_named_rate_limit("payments", principal=str(user.user_id))
    if not is_feature_enabled(db, "rewards_spend_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Rewards spend is temporarily disabled", status_code=503)
    redemption = reserve_points_for_discount(
        db,
        user_id=user.user_id,
        context_type=body.context_type,
        context_id=body.context_id,
        points=body.points,
        payment_amount=body.payment_amount,
        currency=body.currency,
        metadata={"source": "rewards_spend_endpoint"},
    )
    log_event(
        db,
        event_name="reward.spent",
        user_id=user.user_id,
        properties={
            "context_type": body.context_type.value,
            "context_id": str(body.context_id),
            "points_spent": redemption.points_spent,
            "discount_amount": str(redemption.discount_amount),
        },
    )
    db.commit()
    return DiscountRedemptionView.model_validate(redemption, from_attributes=True)


def _request_ip(request: Request | None) -> str | None:
    if not request:
        return None
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


@router.get("/admin/rewards/rules", response_model=list[AdminRewardRuleView])
def admin_list_reward_rules(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[AdminRewardRuleView]:
    ensure_default_reward_rules(db)
    rules = db.execute(select(RewardRule).order_by(RewardRule.code.asc())).scalars().all()
    db.commit()
    return [AdminRewardRuleView.model_validate(rule, from_attributes=True) for rule in rules]


@router.post("/admin/rewards/rules/{code}", response_model=AdminRewardRuleView)
def admin_upsert_reward_rule(
    code: str,
    body: AdminRewardRuleUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminRewardRuleView:
    if not code.strip():
        raise APIError(code="validation_error", message="Rule code is required", status_code=422)

    rule = db.execute(select(RewardRule).where(RewardRule.code == code.strip())).scalar_one_or_none()
    if not rule:
        rule = RewardRule(code=code.strip(), is_enabled=True, amount=0, currency="RAWW_POINTS", meta={})
        db.add(rule)
        db.flush()

    if body.is_enabled is not None:
        rule.is_enabled = body.is_enabled
    if body.amount is not None:
        rule.amount = body.amount
    if body.currency is not None:
        rule.currency = body.currency
    if body.daily_cap_per_user is not None:
        rule.daily_cap_per_user = body.daily_cap_per_user
    if body.lifetime_cap_per_user is not None:
        rule.lifetime_cap_per_user = body.lifetime_cap_per_user
    if body.metadata is not None:
        rule.meta = body.metadata

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="reward_rule",
        target_id=rule.code,
        action="reward_rule_upsert",
        reason=None,
        metadata={
            "is_enabled": rule.is_enabled,
            "amount": rule.amount,
            "currency": rule.currency,
            "daily_cap_per_user": rule.daily_cap_per_user,
            "lifetime_cap_per_user": rule.lifetime_cap_per_user,
        },
    )
    db.commit()
    db.refresh(rule)
    return AdminRewardRuleView.model_validate(rule, from_attributes=True)


@router.post("/admin/rewards/adjust", response_model=AdminRewardAdjustResponse)
def admin_adjust_rewards(
    body: AdminRewardAdjustRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminRewardAdjustResponse:
    entry = create_manual_adjustment(db, body.user_id, body.amount, body.reason, metadata={"actor_user_id": str(actor.user_id)})
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="reward_balance",
        target_id=str(body.user_id),
        action="reward_adjustment",
        reason=body.reason,
        metadata={"amount": body.amount, "balance_after": entry.balance_after},
    )
    db.commit()
    return AdminRewardAdjustResponse(user_id=body.user_id, amount=body.amount, balance_after=entry.balance_after)
