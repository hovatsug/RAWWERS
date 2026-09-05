from __future__ import annotations

import uuid
from datetime import datetime, time, timezone
from decimal import Decimal, ROUND_DOWN

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.reward import (
    AttributionType,
    DiscountRedemption,
    DiscountRedemptionStatus,
    RedemptionContextType,
    ReferralAttribution,
    ReferralCode,
    ReferralOwnerRole,
    RewardBalance,
    RewardEntryType,
    RewardLedgerEntry,
    RewardRule,
)
from app.models.gig import PaymentStatus, StripePayment
from app.services.authz import ensure_user_account

settings = get_settings()

DEFAULT_REWARD_RULES: dict[str, dict] = {
    "client_referral_signup": {"amount": 300, "daily_cap_per_user": 3000, "lifetime_cap_per_user": 30000},
    "client_first_booking_paid": {"amount": 500, "daily_cap_per_user": 5000, "lifetime_cap_per_user": 50000},
    "pro_referral_signup": {"amount": 700, "daily_cap_per_user": 7000, "lifetime_cap_per_user": 70000},
}


def ensure_default_reward_rules(db: Session) -> None:
    now = datetime.now(timezone.utc)
    for code, cfg in DEFAULT_REWARD_RULES.items():
        existing = db.execute(select(RewardRule).where(RewardRule.code == code)).scalar_one_or_none()
        if existing:
            continue
        db.add(
            RewardRule(
                code=code,
                is_enabled=True,
                amount=cfg["amount"],
                currency="RAWW_POINTS",
                daily_cap_per_user=cfg["daily_cap_per_user"],
                lifetime_cap_per_user=cfg["lifetime_cap_per_user"],
                meta={},
                created_at=now,
                updated_at=now,
            )
        )
    db.flush()


def get_or_create_referral_code(db: Session, user_id: uuid.UUID) -> ReferralCode:
    ensure_user_account(db, user_id)
    existing = db.execute(select(ReferralCode).where(ReferralCode.owner_user_id == user_id)).scalar_one_or_none()
    if existing:
        return existing

    roles = db.execute(select(UserRole.role).where(UserRole.user_id == user_id)).scalars().all()
    role = ReferralOwnerRole.client
    if UserRoleType.client in roles:
        role = ReferralOwnerRole.client
    elif UserRoleType.pro in roles:
        role = ReferralOwnerRole.pro

    for _ in range(10):
        code = uuid.uuid4().hex[:8].upper()
        used = db.execute(select(ReferralCode.id).where(ReferralCode.code == code)).scalar_one_or_none()
        if used:
            continue
        referral_code = ReferralCode(owner_user_id=user_id, code=code, role=role)
        db.add(referral_code)
        db.flush()
        return referral_code
    raise APIError(code="internal_error", message="Could not generate referral code", status_code=500)


def claim_referral_code(db: Session, referred_user_id: uuid.UUID, code: str) -> ReferralAttribution:
    ensure_user_account(db, referred_user_id)

    existing = db.execute(
        select(ReferralAttribution).where(ReferralAttribution.referred_user_id == referred_user_id)
    ).scalar_one_or_none()
    if existing:
        raise APIError(code="already_exists", message="Referral was already claimed", status_code=409)

    referral_code = db.execute(select(ReferralCode).where(ReferralCode.code == code.strip().upper())).scalar_one_or_none()
    if not referral_code:
        raise APIError(code="not_found", message="Referral code not found", status_code=404)
    if referral_code.owner_user_id == referred_user_id:
        raise APIError(code="validation_error", message="Cannot claim your own referral code", status_code=422)

    circular = db.execute(
        select(ReferralAttribution).where(
            ReferralAttribution.referred_user_id == referral_code.owner_user_id,
            ReferralAttribution.referrer_user_id == referred_user_id,
        )
    ).scalar_one_or_none()
    if circular:
        raise APIError(code="validation_error", message="Circular referrals are not allowed", status_code=422)

    attribution = ReferralAttribution(
        referred_user_id=referred_user_id,
        referrer_user_id=referral_code.owner_user_id,
        referral_code=referral_code.code,
        attribution_type=AttributionType.signup,
    )
    db.add(attribution)
    db.flush()
    return attribution


def issue_reward(
    db: Session,
    user_id: uuid.UUID,
    rule_code: str,
    reference_type: str | None = None,
    reference_id: str | None = None,
    metadata: dict | None = None,
) -> RewardLedgerEntry | None:
    from app.models.risk import RiskActionType
    from app.services.trust_safety import has_active_risk_action

    if has_active_risk_action(db, user_id=user_id, action_type=RiskActionType.freeze_rewards):
        return None
    ensure_default_reward_rules(db)
    rule = db.execute(select(RewardRule).where(RewardRule.code == rule_code)).scalar_one_or_none()
    if not rule or not rule.is_enabled or rule.amount <= 0:
        return None

    if reference_type and reference_id:
        dedupe = db.execute(
            select(RewardLedgerEntry).where(
                RewardLedgerEntry.user_id == user_id,
                RewardLedgerEntry.rule_code == rule_code,
                RewardLedgerEntry.reference_type == reference_type,
                RewardLedgerEntry.reference_id == reference_id,
                RewardLedgerEntry.entry_type == RewardEntryType.earn,
            )
        ).scalar_one_or_none()
        if dedupe:
            return None

    if not _is_within_caps(db, user_id, rule):
        return None

    balance = _get_or_create_reward_balance_locked(db, user_id)
    new_balance = balance.balance + rule.amount
    balance.balance = new_balance
    balance.updated_at = datetime.now(timezone.utc)

    entry = RewardLedgerEntry(
        user_id=user_id,
        entry_type=RewardEntryType.earn,
        rule_code=rule.code,
        amount=rule.amount,
        balance_after=new_balance,
        reference_type=reference_type,
        reference_id=reference_id,
        meta=metadata or {},
    )
    db.add(entry)
    db.flush()
    return entry


def reserve_points_for_discount(
    db: Session,
    user_id: uuid.UUID,
    context_type: RedemptionContextType,
    context_id: uuid.UUID,
    points: int,
    payment_amount: Decimal,
    currency: str,
    metadata: dict | None = None,
) -> DiscountRedemption:
    if points <= 0:
        raise APIError(code="validation_error", message="points must be > 0", status_code=422)
    if payment_amount <= Decimal("0.00"):
        raise APIError(code="validation_error", message="payment amount must be > 0", status_code=422)

    existing = db.execute(
        select(DiscountRedemption).where(
            DiscountRedemption.user_id == user_id,
            DiscountRedemption.context_type == context_type,
            DiscountRedemption.context_id == context_id,
            DiscountRedemption.status.in_([DiscountRedemptionStatus.reserved, DiscountRedemptionStatus.applied]),
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    points_per_eur, max_discount_pct = _get_discount_conversion_settings(db)
    max_discount_amount = (payment_amount * Decimal(max_discount_pct) / Decimal("100")).quantize(Decimal("0.01"))
    raw_discount_amount = (Decimal(points) / Decimal(points_per_eur)).quantize(Decimal("0.01"), rounding=ROUND_DOWN)
    discount_amount = min(raw_discount_amount, max_discount_amount, payment_amount)
    if discount_amount <= Decimal("0.00"):
        raise APIError(code="validation_error", message="points too low for minimum discount", status_code=422)

    points_to_spend = int((discount_amount * Decimal(points_per_eur)).to_integral_value(rounding=ROUND_DOWN))
    if points_to_spend <= 0:
        raise APIError(code="validation_error", message="Invalid redemption points", status_code=422)

    balance = _get_or_create_reward_balance_locked(db, user_id)
    if balance.balance < points_to_spend:
        raise APIError(code="validation_error", message="Insufficient reward balance", status_code=422)

    new_balance = balance.balance - points_to_spend
    balance.balance = new_balance
    balance.updated_at = datetime.now(timezone.utc)

    redemption = DiscountRedemption(
        user_id=user_id,
        context_type=context_type,
        context_id=context_id,
        points_spent=points_to_spend,
        discount_amount=discount_amount,
        currency=currency.upper(),
        status=DiscountRedemptionStatus.reserved,
    )
    db.add(redemption)
    db.flush()

    db.add(
        RewardLedgerEntry(
            user_id=user_id,
            entry_type=RewardEntryType.spend,
            rule_code=None,
            amount=-points_to_spend,
            balance_after=new_balance,
            reference_type=context_type.value,
            reference_id=str(context_id),
            meta=metadata or {},
        )
    )
    db.flush()
    return redemption


def apply_redemption_for_context(
    db: Session,
    context_type: RedemptionContextType,
    context_id: uuid.UUID,
) -> DiscountRedemption | None:
    redemption = db.execute(
        select(DiscountRedemption).where(
            DiscountRedemption.context_type == context_type,
            DiscountRedemption.context_id == context_id,
            DiscountRedemption.status == DiscountRedemptionStatus.reserved,
        )
    ).scalar_one_or_none()
    if not redemption:
        return None
    redemption.status = DiscountRedemptionStatus.applied
    redemption.updated_at = datetime.now(timezone.utc)
    db.flush()
    return redemption


def release_redemption_for_context(
    db: Session,
    context_type: RedemptionContextType,
    context_id: uuid.UUID,
    reason: str,
) -> DiscountRedemption | None:
    redemption = db.execute(
        select(DiscountRedemption).where(
            DiscountRedemption.context_type == context_type,
            DiscountRedemption.context_id == context_id,
            DiscountRedemption.status == DiscountRedemptionStatus.reserved,
        )
    ).scalar_one_or_none()
    if not redemption:
        return None

    balance = _get_or_create_reward_balance_locked(db, redemption.user_id)
    new_balance = balance.balance + redemption.points_spent
    balance.balance = new_balance
    balance.updated_at = datetime.now(timezone.utc)

    redemption.status = DiscountRedemptionStatus.released
    redemption.updated_at = datetime.now(timezone.utc)

    db.add(
        RewardLedgerEntry(
            user_id=redemption.user_id,
            entry_type=RewardEntryType.adjustment,
            rule_code=None,
            amount=redemption.points_spent,
            balance_after=new_balance,
            reference_type=context_type.value,
            reference_id=str(context_id),
            meta={"reason": reason},
        )
    )
    db.flush()
    return redemption


def list_reward_ledger(db: Session, user_id: uuid.UUID, limit: int, offset: int) -> tuple[int, list[RewardLedgerEntry]]:
    total = db.execute(
        select(func.count()).select_from(select(RewardLedgerEntry).where(RewardLedgerEntry.user_id == user_id).subquery())
    ).scalar_one()
    rows = db.execute(
        select(RewardLedgerEntry)
        .where(RewardLedgerEntry.user_id == user_id)
        .order_by(RewardLedgerEntry.created_at.desc())
        .offset(offset)
        .limit(limit)
    ).scalars().all()
    return total, rows


def get_reward_balance(db: Session, user_id: uuid.UUID) -> RewardBalance:
    return _get_or_create_reward_balance_locked(db, user_id)


def create_manual_adjustment(
    db: Session,
    user_id: uuid.UUID,
    amount: int,
    reason: str,
    metadata: dict | None = None,
) -> RewardLedgerEntry:
    if amount == 0:
        raise APIError(code="validation_error", message="amount cannot be zero", status_code=422)

    balance = _get_or_create_reward_balance_locked(db, user_id)
    new_balance = balance.balance + amount
    if new_balance < 0:
        raise APIError(code="validation_error", message="Adjustment would make balance negative", status_code=422)

    balance.balance = new_balance
    balance.updated_at = datetime.now(timezone.utc)
    entry = RewardLedgerEntry(
        user_id=user_id,
        entry_type=RewardEntryType.adjustment,
        rule_code=None,
        amount=amount,
        balance_after=new_balance,
        reference_type="admin_adjustment",
        reference_id=str(uuid.uuid4()),
        meta={"reason": reason, **(metadata or {})},
    )
    db.add(entry)
    db.flush()
    return entry


def add_reward_entry(
    db: Session,
    *,
    user_id: uuid.UUID,
    amount: int,
    entry_type: RewardEntryType,
    reference_type: str,
    reference_id: str,
    metadata: dict | None = None,
    rule_code: str | None = None,
    min_balance_floor: int | None = None,
) -> RewardLedgerEntry | None:
    from app.models.risk import RiskActionType
    from app.services.trust_safety import has_active_risk_action

    if amount == 0:
        return None
    if has_active_risk_action(db, user_id=user_id, action_type=RiskActionType.freeze_rewards):
        return None

    existing = db.execute(
        select(RewardLedgerEntry).where(
            RewardLedgerEntry.user_id == user_id,
            RewardLedgerEntry.entry_type == entry_type,
            RewardLedgerEntry.reference_type == reference_type,
            RewardLedgerEntry.reference_id == reference_id,
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    balance = _get_or_create_reward_balance_locked(db, user_id)
    new_balance = balance.balance + int(amount)
    floor = min_balance_floor if min_balance_floor is not None else 0
    if new_balance < floor:
        return None

    balance.balance = new_balance
    balance.updated_at = datetime.now(timezone.utc)
    entry = RewardLedgerEntry(
        user_id=user_id,
        entry_type=entry_type,
        rule_code=rule_code,
        amount=int(amount),
        balance_after=new_balance,
        reference_type=reference_type,
        reference_id=reference_id,
        meta=metadata or {},
    )
    db.add(entry)
    db.flush()
    return entry


def _is_within_caps(db: Session, user_id: uuid.UUID, rule: RewardRule) -> bool:
    now = datetime.now(timezone.utc)
    day_start = datetime.combine(now.date(), time.min, tzinfo=timezone.utc)

    earned_today = db.execute(
        select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
            RewardLedgerEntry.user_id == user_id,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
            RewardLedgerEntry.rule_code == rule.code,
            RewardLedgerEntry.created_at >= day_start,
        )
    ).scalar_one()
    earned_lifetime = db.execute(
        select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
            RewardLedgerEntry.user_id == user_id,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
            RewardLedgerEntry.rule_code == rule.code,
        )
    ).scalar_one()

    if rule.daily_cap_per_user is not None and (earned_today + rule.amount) > rule.daily_cap_per_user:
        return False
    if rule.lifetime_cap_per_user is not None and (earned_lifetime + rule.amount) > rule.lifetime_cap_per_user:
        return False
    return True


def _get_or_create_reward_balance_locked(db: Session, user_id: uuid.UUID) -> RewardBalance:
    ensure_user_account(db, user_id)
    balance = db.execute(select(RewardBalance).where(RewardBalance.user_id == user_id).with_for_update()).scalar_one_or_none()
    if balance is None:
        balance = RewardBalance(user_id=user_id, balance=0)
        db.add(balance)
        db.flush()
    return balance


def _get_discount_conversion_settings(db: Session) -> tuple[int, int]:
    points_per_eur = settings.reward_points_per_eur
    max_discount_pct = settings.reward_max_discount_percent

    rule = db.execute(select(RewardRule).where(RewardRule.code == "discount_conversion")).scalar_one_or_none()
    if rule and isinstance(rule.meta, dict):
        points_per_eur = int(rule.meta.get("points_per_eur", points_per_eur))
        max_discount_pct = int(rule.meta.get("max_discount_percent", max_discount_pct))

    points_per_eur = max(points_per_eur, 1)
    max_discount_pct = max(1, min(max_discount_pct, 100))
    return points_per_eur, max_discount_pct


def maybe_issue_client_signup_referral_reward(db: Session, referred_user_id: uuid.UUID) -> RewardLedgerEntry | None:
    attribution = db.execute(
        select(ReferralAttribution).where(ReferralAttribution.referred_user_id == referred_user_id)
    ).scalar_one_or_none()
    if not attribution:
        return None

    has_client_role = db.execute(
        select(UserRole).where(UserRole.user_id == referred_user_id, UserRole.role == UserRoleType.client)
    ).scalar_one_or_none()
    account = db.get(UserAccount, referred_user_id)
    if not has_client_role or not account:
        return None

    return issue_reward(
        db,
        user_id=attribution.referrer_user_id,
        rule_code="client_referral_signup",
        reference_type="referral_attribution",
        reference_id=str(attribution.id),
        metadata={"referred_user_id": str(referred_user_id)},
    )


def maybe_issue_first_booking_referral_reward(db: Session, client_user_id: uuid.UUID, gig_id: uuid.UUID) -> RewardLedgerEntry | None:
    attribution = db.execute(
        select(ReferralAttribution).where(ReferralAttribution.referred_user_id == client_user_id)
    ).scalar_one_or_none()
    if not attribution:
        return None

    successful_gigs = db.execute(
        select(func.count())
        .select_from(StripePayment)
        .where(
            StripePayment.client_user_id == client_user_id,
            StripePayment.status == PaymentStatus.succeeded,
        )
    ).scalar_one()
    if successful_gigs != 1:
        return None

    return issue_reward(
        db,
        user_id=attribution.referrer_user_id,
        rule_code="client_first_booking_paid",
        reference_type="gig",
        reference_id=str(gig_id),
        metadata={"referred_user_id": str(client_user_id)},
    )


def maybe_issue_pro_signup_referral_reward(db: Session, referred_pro_user_id: uuid.UUID) -> RewardLedgerEntry | None:
    attribution = db.execute(
        select(ReferralAttribution).where(ReferralAttribution.referred_user_id == referred_pro_user_id)
    ).scalar_one_or_none()
    if not attribution:
        return None

    return issue_reward(
        db,
        user_id=attribution.referrer_user_id,
        rule_code="pro_referral_signup",
        reference_type="referred_pro",
        reference_id=str(referred_pro_user_id),
        metadata={"referred_user_id": str(referred_pro_user_id)},
    )
