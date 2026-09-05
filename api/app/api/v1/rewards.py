from __future__ import annotations

import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.reward import RewardRule
from app.schemas.media import CurrentUser
from app.schemas.reward import (
    AdminReferralBlacklistResponse,
    AdminReferralPolicyItem,
    AdminReferralPolicyUpsertRequest,
    AdminReferralReportResponse,
    AdminRewardAdjustRequest,
    AdminRewardAdjustResponse,
    AdminRewardRuleUpdateRequest,
    AdminRewardRuleView,
    DiscountRedemptionView,
    MeReferralCodeResponse,
    RefLandingResponse,
    ReferralClaimRequest,
    ReferralMeResponse,
    ReferralStatsResponse,
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
from app.services.growth_engine import (
    bind_session_attribution_to_user,
    blacklist_referrer,
    create_referral_click,
    link_referee_to_referrer,
    ensure_referral_profile,
    get_referral_profile_by_code,
    get_referral_stats,
    list_referral_policies,
    record_attribution_touch,
    referral_report,
    regenerate_referral_code,
    remove_referrer_blacklist,
    upsert_referral_policy,
)
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


@router.get("/ref/{code}", response_model=RefLandingResponse)
def referral_landing(
    code: str,
    request: Request,
    source: str | None = Query(default="referral"),
    medium: str | None = Query(default=None),
    campaign: str | None = Query(default=None),
    content: str | None = Query(default=None),
    term: str | None = Query(default=None),
    consent: bool = Query(default=False),
    db: Session = Depends(get_db_session),
) -> RefLandingResponse:
    profile = get_referral_profile_by_code(db, code)
    session_id = request.cookies.get("rw_sid") or uuid.uuid4().hex

    if profile:
        create_referral_click(db, referral_code=code, request_ip=_request_ip(request))
        if consent:
            record_attribution_touch(
                db,
                user_id=None,
                session_id=session_id,
                source=source or "referral",
                medium=medium,
                campaign=campaign,
                content=content or profile.referral_code,
                term=term,
                referrer_url=request.headers.get("referer"),
            )
            log_event(
                db,
                event_name="attribution.touch_recorded",
                user_id=None,
                session_id=session_id,
                properties={"source": source or "referral", "campaign": campaign, "referral_code": profile.referral_code},
            )
        log_event(
            db,
            event_name="referral.clicked",
            user_id=profile.user_id,
            session_id=session_id,
            properties={"referral_code": profile.referral_code},
        )

    db.commit()
    response = RefLandingResponse(
        code=code.strip().upper(),
        valid=bool(profile),
        referrer_user_id=profile.user_id if profile else None,
        session_id=session_id,
    )
    # Server-side attribution session + referral hints.
    from fastapi.responses import JSONResponse

    wrapped = JSONResponse(content=response.model_dump(mode="json"))
    wrapped.set_cookie("rw_sid", session_id, max_age=60 * 60 * 24 * 30, httponly=True, samesite="lax")
    if profile:
        wrapped.set_cookie("rw_ref", profile.referral_code, max_age=60 * 60 * 24 * 30, httponly=False, samesite="lax")
    if consent:
        wrapped.set_cookie("rw_tracking_consent", "yes", max_age=60 * 60 * 24 * 365, httponly=False, samesite="lax")
    return wrapped  # type: ignore[return-value]


@router.get("/me/referral-code", response_model=MeReferralCodeResponse)
def my_referral_code_v2(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MeReferralCodeResponse:
    profile = ensure_referral_profile(db, user.user_id)
    db.commit()
    return MeReferralCodeResponse(code=profile.referral_code, share_url=f"/ref/{profile.referral_code}")


@router.post("/me/referral-code/regenerate", response_model=MeReferralCodeResponse)
def regenerate_my_referral_code(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MeReferralCodeResponse:
    enforce_named_rate_limit("auth_mutation", principal=f"ref-regenerate:{user.user_id}")
    profile = regenerate_referral_code(db, user.user_id)
    db.commit()
    return MeReferralCodeResponse(code=profile.referral_code, share_url=f"/ref/{profile.referral_code}")


@router.get("/me/referrals/stats", response_model=ReferralStatsResponse)
def my_referral_stats(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ReferralStatsResponse:
    stats = get_referral_stats(db, user_id=user.user_id)
    db.commit()
    return ReferralStatsResponse(**stats)


@router.get("/referrals/me", response_model=ReferralMeResponse)
def my_referral_code(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ReferralMeResponse:
    get_or_create_referral_code(db, user.user_id)
    profile = ensure_referral_profile(db, user.user_id)
    db.commit()
    return ReferralMeResponse(code=profile.referral_code, link_stub=f"/r/{profile.referral_code}")


@router.post("/referrals/claim")
def claim_referral(
    body: ReferralClaimRequest,
    request: Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> dict:
    enforce_named_rate_limit("referral_claims", principal=str(user.user_id))
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    attribution = claim_referral_code(db, user.user_id, body.code)
    link_referee_to_referrer(
        db,
        referee_user_id=user.user_id,
        referral_code=body.code,
        referee_email=None,
        request_ip=_request_ip(request),
    )
    session_id = request.cookies.get("rw_sid")
    if session_id and request.cookies.get("rw_tracking_consent") == "yes":
        bind_session_attribution_to_user(db, session_id=session_id, user_id=user.user_id)
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
    log_event(
        db,
        event_name="referral.registered",
        user_id=user.user_id,
        session_id=session_id,
        properties={"referral_code": attribution.referral_code},
    )
    db.commit()
    return {"ok": True, "referrer_user_id": str(attribution.referrer_user_id)}


@router.get("/rewards/balance", response_model=RewardBalanceResponse)
@router.get("/me/rewards/balance", response_model=RewardBalanceResponse)
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


@router.get("/admin/referrals/report", response_model=AdminReferralReportResponse)
def admin_referrals_report(
    from_dt: datetime | None = Query(default=None, alias="from"),
    to_dt: datetime | None = Query(default=None, alias="to"),
    city: str | None = Query(default=None),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminReferralReportResponse:
    report = referral_report(db, from_dt=from_dt, to_dt=to_dt)
    if city:
        # City filtering is deferred to a richer reporting index; surface accepted parameter for API stability.
        report["city_filter"] = city
    db.commit()
    return AdminReferralReportResponse(**{k: v for k, v in report.items() if k in AdminReferralReportResponse.model_fields})


@router.get("/admin/referrals/policy", response_model=list[AdminReferralPolicyItem])
def admin_get_referral_policy(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[AdminReferralPolicyItem]:
    rows = list_referral_policies(db)
    db.commit()
    return [
        AdminReferralPolicyItem(
            conversion_type=row.conversion_type,
            referrer_points=row.referrer_points,
            referee_points=row.referee_points,
            max_rewards_per_referrer_per_month=row.max_rewards_per_referrer_per_month,
            min_conversion_value_eur=row.min_conversion_value_eur,
            cooldown_days=row.cooldown_days,
        )
        for row in rows
    ]


@router.put("/admin/referrals/policy", response_model=list[AdminReferralPolicyItem])
def admin_put_referral_policy(
    body: AdminReferralPolicyUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[AdminReferralPolicyItem]:
    for item in body.items:
        upsert_referral_policy(
            db,
            conversion_type=item.conversion_type,
            referrer_points=item.referrer_points,
            referee_points=item.referee_points,
            max_rewards_per_referrer_per_month=item.max_rewards_per_referrer_per_month,
            min_conversion_value_eur=item.min_conversion_value_eur,
            cooldown_days=item.cooldown_days,
        )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="referral_reward_policy",
        target_id="bulk",
        action="referral_policy_upsert",
        reason=None,
        metadata={"items": [item.model_dump(mode="json") for item in body.items]},
    )
    rows = list_referral_policies(db)
    db.commit()
    return [
        AdminReferralPolicyItem(
            conversion_type=row.conversion_type,
            referrer_points=row.referrer_points,
            referee_points=row.referee_points,
            max_rewards_per_referrer_per_month=row.max_rewards_per_referrer_per_month,
            min_conversion_value_eur=row.min_conversion_value_eur,
            cooldown_days=row.cooldown_days,
        )
        for row in rows
    ]


@router.post("/admin/referrals/blacklist/{user_id}", response_model=AdminReferralBlacklistResponse)
def admin_blacklist_referrer(
    user_id: uuid.UUID,
    reason: str = Query(default="abuse"),
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminReferralBlacklistResponse:
    row = blacklist_referrer(db, user_id=user_id, reason=reason)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="referral_blacklist",
        target_id=str(user_id),
        action="referral_blacklist_add",
        reason=reason,
        metadata={},
    )
    db.commit()
    return AdminReferralBlacklistResponse(user_id=row.user_id, reason=row.reason, active=True)


@router.delete("/admin/referrals/blacklist/{user_id}", response_model=AdminReferralBlacklistResponse)
def admin_unblacklist_referrer(
    user_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminReferralBlacklistResponse:
    removed = remove_referrer_blacklist(db, user_id=user_id)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="referral_blacklist",
        target_id=str(user_id),
        action="referral_blacklist_remove",
        reason=None,
        metadata={"removed": removed},
    )
    db.commit()
    return AdminReferralBlacklistResponse(user_id=user_id, reason="", active=False)
