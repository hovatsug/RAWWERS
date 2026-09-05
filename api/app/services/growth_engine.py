from __future__ import annotations

import hashlib
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import UserRole, UserRoleType
from app.models.media_rights import ShareLink
from app.models.reward import (
    AttributionTouch,
    ConversionAttribution,
    ReferralAttribution,
    ReferralBlacklist,
    ReferralCode,
    ReferralConversionType,
    ReferralLink,
    ReferralLinkStatus,
    ReferralOwnerRole,
    ReferralProfile,
    ReferralRewardGrant,
    ReferralRewardPolicy,
    RewardEntryType,
    RewardLedgerEntry,
)
from app.services.authz import ensure_user_account
from app.services.outbox import enqueue_outbox_event

DEFAULT_REFERRAL_POLICIES: dict[str, dict] = {
    "booking_paid": {
        "referrer_points": 500,
        "referee_points": 200,
        "max_rewards_per_referrer_per_month": 20,
        "min_conversion_value_eur": Decimal("20.00"),
        "cooldown_days": 30,
    },
    "extras_paid": {
        "referrer_points": 150,
        "referee_points": 50,
        "max_rewards_per_referrer_per_month": 20,
        "min_conversion_value_eur": Decimal("5.00"),
        "cooldown_days": 30,
    },
    "studioverse_paid": {
        "referrer_points": 250,
        "referee_points": 100,
        "max_rewards_per_referrer_per_month": 20,
        "min_conversion_value_eur": Decimal("5.00"),
        "cooldown_days": 30,
    },
}


@dataclass(frozen=True)
class ReferralConversionResult:
    grant: ReferralRewardGrant | None
    reward_entry_ids: list[uuid.UUID]


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def hash_text(value: str | None) -> str | None:
    if not value:
        return None
    return hashlib.sha256(value.strip().lower().encode("utf-8")).hexdigest()


def normalize_referral_code(code: str) -> str:
    value = (code or "").strip().upper()
    if not value or len(value) < 4:
        raise APIError(code="validation_error", message="Invalid referral code", status_code=422)
    return value


def ensure_default_referral_reward_policies(db: Session) -> None:
    for conversion_type, cfg in DEFAULT_REFERRAL_POLICIES.items():
        row = db.execute(
            select(ReferralRewardPolicy).where(ReferralRewardPolicy.conversion_type == conversion_type)
        ).scalar_one_or_none()
        if row:
            continue
        db.add(
            ReferralRewardPolicy(
                conversion_type=conversion_type,
                referrer_points=int(cfg["referrer_points"]),
                referee_points=int(cfg["referee_points"]),
                max_rewards_per_referrer_per_month=int(cfg["max_rewards_per_referrer_per_month"]),
                min_conversion_value_eur=Decimal(cfg["min_conversion_value_eur"]),
                cooldown_days=int(cfg["cooldown_days"]),
            )
        )
    db.flush()


def _infer_referral_owner_role(db: Session, user_id: uuid.UUID) -> ReferralOwnerRole:
    roles = db.execute(select(UserRole.role).where(UserRole.user_id == user_id)).scalars().all()
    if UserRoleType.pro in roles and UserRoleType.client not in roles:
        return ReferralOwnerRole.pro
    return ReferralOwnerRole.client


def _generate_candidate_code() -> str:
    return uuid.uuid4().hex[:8].upper()


def _is_referral_code_used(db: Session, code: str) -> bool:
    profile_used = db.execute(
        select(ReferralProfile.user_id).where(ReferralProfile.referral_code == code)
    ).scalar_one_or_none()
    if profile_used:
        return True
    legacy_used = db.execute(select(ReferralCode.id).where(ReferralCode.code == code)).scalar_one_or_none()
    return legacy_used is not None


def ensure_referral_profile(db: Session, user_id: uuid.UUID) -> ReferralProfile:
    ensure_user_account(db, user_id)
    profile = db.get(ReferralProfile, user_id)
    if profile:
        _ensure_legacy_referral_code(db, user_id=user_id, code=profile.referral_code)
        return profile

    for _ in range(20):
        candidate = _generate_candidate_code()
        if _is_referral_code_used(db, candidate):
            continue
        profile = ReferralProfile(user_id=user_id, referral_code=candidate)
        db.add(profile)
        db.flush()
        _ensure_legacy_referral_code(db, user_id=user_id, code=candidate)
        return profile

    raise APIError(code="internal_error", message="Could not allocate referral code", status_code=500)


def _ensure_legacy_referral_code(db: Session, *, user_id: uuid.UUID, code: str) -> None:
    row = db.execute(select(ReferralCode).where(ReferralCode.owner_user_id == user_id)).scalar_one_or_none()
    if row is None:
        db.add(
            ReferralCode(
                owner_user_id=user_id,
                code=code,
                role=_infer_referral_owner_role(db, user_id),
            )
        )
        db.flush()
        return
    row.code = code


def regenerate_referral_code(db: Session, user_id: uuid.UUID) -> ReferralProfile:
    profile = ensure_referral_profile(db, user_id)
    for _ in range(20):
        candidate = _generate_candidate_code()
        if _is_referral_code_used(db, candidate):
            continue
        profile.referral_code = candidate
        profile.updated_at = now_utc()
        db.flush()
        _ensure_legacy_referral_code(db, user_id=user_id, code=candidate)
        return profile
    raise APIError(code="internal_error", message="Could not regenerate referral code", status_code=500)


def get_referral_profile_by_code(db: Session, code: str) -> ReferralProfile | None:
    normalized = normalize_referral_code(code)
    profile = db.execute(
        select(ReferralProfile).where(ReferralProfile.referral_code == normalized)
    ).scalar_one_or_none()
    if profile:
        return profile
    legacy = db.execute(select(ReferralCode).where(ReferralCode.code == normalized)).scalar_one_or_none()
    if not legacy:
        return None
    profile = db.get(ReferralProfile, legacy.owner_user_id)
    if profile is None:
        profile = ReferralProfile(user_id=legacy.owner_user_id, referral_code=normalized)
        db.add(profile)
        db.flush()
    return profile


def record_attribution_touch(
    db: Session,
    *,
    user_id: uuid.UUID | None,
    session_id: str | None,
    source: str | None,
    medium: str | None,
    campaign: str | None,
    content: str | None,
    term: str | None,
    referrer_url: str | None,
) -> AttributionTouch:
    row = AttributionTouch(
        user_id=user_id,
        session_id=session_id,
        source=source,
        medium=medium,
        campaign=campaign,
        content=content,
        term=term,
        referrer_url_hash=hash_text(referrer_url),
    )
    db.add(row)
    db.flush()
    return row


def bind_session_attribution_to_user(db: Session, *, session_id: str, user_id: uuid.UUID) -> int:
    rows = db.execute(
        select(AttributionTouch).where(
            AttributionTouch.session_id == session_id,
            AttributionTouch.user_id.is_(None),
        )
    ).scalars().all()
    for row in rows:
        row.user_id = user_id
    db.flush()
    return len(rows)


def _get_registered_referral_link(db: Session, referee_user_id: uuid.UUID) -> ReferralLink | None:
    return db.execute(
        select(ReferralLink)
        .where(
            ReferralLink.referee_user_id == referee_user_id,
            ReferralLink.status.in_([ReferralLinkStatus.registered, ReferralLinkStatus.converted]),
        )
        .order_by(ReferralLink.created_at.asc())
    ).scalars().first()


def link_referee_to_referrer(
    db: Session,
    *,
    referee_user_id: uuid.UUID,
    referral_code: str,
    referee_email: str | None,
    request_ip: str | None = None,
) -> ReferralLink:
    profile = get_referral_profile_by_code(db, referral_code)
    if profile is None:
        raise APIError(code="not_found", message="Referral code not found", status_code=404)
    if profile.user_id == referee_user_id:
        raise APIError(code="validation_error", message="Cannot refer yourself", status_code=422)

    existing = db.execute(
        select(ReferralLink).where(
            ReferralLink.referrer_user_id == profile.user_id,
            ReferralLink.referee_user_id == referee_user_id,
        )
    ).scalar_one_or_none()
    if existing:
        if existing.status == ReferralLinkStatus.blocked:
            raise APIError(code="forbidden", message="Referral link is blocked", status_code=403)
        if existing.status in (ReferralLinkStatus.registered, ReferralLinkStatus.converted):
            return existing
        existing.status = ReferralLinkStatus.registered
        existing.referee_email_hash = hash_text(referee_email)
        existing.updated_at = now_utc()
        if request_ip:
            from app.services.trust_safety import evaluate_referral_farm_rule, risk_hash_ip

            evaluate_referral_farm_rule(db, referrer_user_id=profile.user_id, ip_hash=risk_hash_ip(request_ip))
        db.flush()
        _ensure_legacy_referral_attribution(db, referee_user_id=referee_user_id, referrer_user_id=profile.user_id, code=profile.referral_code)
        return existing

    link = ReferralLink(
        referrer_user_id=profile.user_id,
        referee_user_id=referee_user_id,
        referee_email_hash=hash_text(referee_email),
        status=ReferralLinkStatus.registered,
    )
    db.add(link)
    if request_ip:
        from app.services.trust_safety import evaluate_referral_farm_rule, risk_hash_ip

        evaluate_referral_farm_rule(db, referrer_user_id=profile.user_id, ip_hash=risk_hash_ip(request_ip))
    db.flush()
    _ensure_legacy_referral_attribution(db, referee_user_id=referee_user_id, referrer_user_id=profile.user_id, code=profile.referral_code)
    return link


def create_referral_click(
    db: Session,
    *,
    referral_code: str,
    referee_email: str | None = None,
    request_ip: str | None = None,
) -> ReferralLink:
    profile = get_referral_profile_by_code(db, referral_code)
    if profile is None:
        raise APIError(code="not_found", message="Referral code not found", status_code=404)
    link = ReferralLink(
        referrer_user_id=profile.user_id,
        referee_user_id=None,
        referee_email_hash=hash_text(referee_email),
        status=ReferralLinkStatus.clicked,
    )
    db.add(link)
    if request_ip:
        from app.services.trust_safety import evaluate_referral_farm_rule, risk_hash_ip

        evaluate_referral_farm_rule(db, referrer_user_id=profile.user_id, ip_hash=risk_hash_ip(request_ip))
    db.flush()
    return link


def _ensure_legacy_referral_attribution(
    db: Session,
    *,
    referee_user_id: uuid.UUID,
    referrer_user_id: uuid.UUID,
    code: str,
) -> None:
    existing = db.execute(
        select(ReferralAttribution).where(ReferralAttribution.referred_user_id == referee_user_id)
    ).scalar_one_or_none()
    if existing:
        return
    db.add(
        ReferralAttribution(
            referred_user_id=referee_user_id,
            referrer_user_id=referrer_user_id,
            referral_code=code,
        )
    )
    db.flush()


def ensure_conversion_attribution(
    db: Session,
    *,
    user_id: uuid.UUID,
    conversion_type: ReferralConversionType,
    conversion_id: uuid.UUID,
    share_link_id: uuid.UUID | None,
) -> ConversionAttribution:
    existing = db.execute(
        select(ConversionAttribution).where(
            ConversionAttribution.conversion_type == conversion_type,
            ConversionAttribution.conversion_id == conversion_id,
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    attributed_to = determine_primary_attribution(db, user_id=user_id, share_link_id=share_link_id)
    row = ConversionAttribution(
        user_id=user_id,
        conversion_type=conversion_type,
        conversion_id=conversion_id,
        attributed_to=attributed_to,
    )
    db.add(row)
    db.flush()
    return row


def determine_primary_attribution(
    db: Session,
    *,
    user_id: uuid.UUID,
    share_link_id: uuid.UUID | None,
) -> dict:
    referral_link = _get_registered_referral_link(db, user_id)
    latest_touch = db.execute(
        select(AttributionTouch)
        .where(AttributionTouch.user_id == user_id)
        .order_by(AttributionTouch.created_at.desc())
    ).scalars().first()

    payload: dict = {
        "primary": None,
        "utm": None,
    }

    if latest_touch:
        payload["utm"] = {
            "source": latest_touch.source,
            "medium": latest_touch.medium,
            "campaign": latest_touch.campaign,
            "content": latest_touch.content,
            "term": latest_touch.term,
            "session_id": latest_touch.session_id,
        }

    if referral_link:
        ref_profile = db.get(ReferralProfile, referral_link.referrer_user_id)
        payload["primary"] = "referral"
        payload["referral_code"] = ref_profile.referral_code if ref_profile else None
        payload["referrer_user_id"] = str(referral_link.referrer_user_id)
        if share_link_id:
            payload["share_link_id"] = str(share_link_id)
        return payload

    if share_link_id:
        payload["primary"] = "share_link"
        payload["share_link_id"] = str(share_link_id)
        return payload

    if latest_touch and latest_touch.source == "share_link" and latest_touch.content:
        payload["primary"] = "share_link"
        payload["share_link_id"] = latest_touch.content
        return payload

    if latest_touch:
        payload["primary"] = "utm"
        return payload

    payload["primary"] = "none"
    return payload


def maybe_issue_referral_conversion_reward(
    db: Session,
    *,
    referee_user_id: uuid.UUID,
    conversion_type: ReferralConversionType,
    conversion_id: uuid.UUID,
    conversion_value_eur: Decimal,
    share_link_id: uuid.UUID | None = None,
) -> ReferralConversionResult:
    ensure_default_referral_reward_policies(db)

    attribution = ensure_conversion_attribution(
        db,
        user_id=referee_user_id,
        conversion_type=conversion_type,
        conversion_id=conversion_id,
        share_link_id=share_link_id,
    )

    dedupe = db.execute(
        select(ReferralRewardGrant).where(
            ReferralRewardGrant.conversion_type == conversion_type.value,
            ReferralRewardGrant.conversion_id == conversion_id,
        )
    ).scalar_one_or_none()
    if dedupe:
        return ReferralConversionResult(grant=dedupe, reward_entry_ids=[uuid.UUID(item) for item in dedupe.reward_ledger_entry_ids if item])

    link = _get_registered_referral_link(db, referee_user_id)
    if link is None:
        return ReferralConversionResult(grant=None, reward_entry_ids=[])

    policy = db.execute(
        select(ReferralRewardPolicy).where(ReferralRewardPolicy.conversion_type == conversion_type.value)
    ).scalar_one_or_none()
    if policy is None:
        return ReferralConversionResult(grant=None, reward_entry_ids=[])

    if conversion_value_eur < (policy.min_conversion_value_eur or Decimal("0.00")):
        return ReferralConversionResult(grant=None, reward_entry_ids=[])

    is_blacklisted = db.execute(
        select(ReferralBlacklist).where(ReferralBlacklist.user_id == link.referrer_user_id)
    ).scalar_one_or_none()
    if is_blacklisted:
        link.status = ReferralLinkStatus.blocked
        link.updated_at = now_utc()
        return ReferralConversionResult(grant=None, reward_entry_ids=[])

    period_start = now_utc().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    monthly_rewards_count = db.execute(
        select(func.count())
        .select_from(ReferralRewardGrant)
        .where(
            ReferralRewardGrant.referrer_user_id == link.referrer_user_id,
            ReferralRewardGrant.granted_at >= period_start,
        )
    ).scalar_one()
    if monthly_rewards_count >= int(policy.max_rewards_per_referrer_per_month or 0):
        return ReferralConversionResult(grant=None, reward_entry_ids=[])

    cooldown_days = max(0, int(policy.cooldown_days or 0))
    if cooldown_days > 0:
        cooldown_cutoff = now_utc() - timedelta(days=cooldown_days)
        recent_pair_reward = db.execute(
            select(ReferralRewardGrant)
            .where(
                ReferralRewardGrant.referrer_user_id == link.referrer_user_id,
                ReferralRewardGrant.referee_user_id == referee_user_id,
                ReferralRewardGrant.granted_at >= cooldown_cutoff,
            )
            .order_by(ReferralRewardGrant.granted_at.desc())
        ).scalars().first()
        if recent_pair_reward is not None:
            return ReferralConversionResult(grant=None, reward_entry_ids=[])

    from app.services.rewards import add_reward_entry

    reward_entry_ids: list[str] = []
    referrer_entry = None
    referee_entry = None

    if int(policy.referrer_points) > 0:
        referrer_entry = add_reward_entry(
            db,
            user_id=link.referrer_user_id,
            amount=int(policy.referrer_points),
            entry_type=RewardEntryType.earn,
            reference_type="referral_conversion",
            reference_id=f"{conversion_type.value}:{conversion_id}:referrer",
            metadata={
                "conversion_type": conversion_type.value,
                "conversion_id": str(conversion_id),
                "referee_user_id": str(referee_user_id),
                "attribution": attribution.attributed_to,
            },
            rule_code=f"referral_{conversion_type.value}_referrer",
        )
    if int(policy.referee_points) > 0:
        referee_entry = add_reward_entry(
            db,
            user_id=referee_user_id,
            amount=int(policy.referee_points),
            entry_type=RewardEntryType.earn,
            reference_type="referral_conversion",
            reference_id=f"{conversion_type.value}:{conversion_id}:referee",
            metadata={
                "conversion_type": conversion_type.value,
                "conversion_id": str(conversion_id),
                "referrer_user_id": str(link.referrer_user_id),
                "attribution": attribution.attributed_to,
            },
            rule_code=f"referral_{conversion_type.value}_referee",
        )

    if referrer_entry:
        reward_entry_ids.append(str(referrer_entry.id))
    if referee_entry:
        reward_entry_ids.append(str(referee_entry.id))

    if not reward_entry_ids:
        return ReferralConversionResult(grant=None, reward_entry_ids=[])

    grant = ReferralRewardGrant(
        referrer_user_id=link.referrer_user_id,
        referee_user_id=referee_user_id,
        conversion_type=conversion_type.value,
        conversion_id=conversion_id,
        reward_ledger_entry_ids=reward_entry_ids,
    )
    db.add(grant)
    link.status = ReferralLinkStatus.converted
    link.updated_at = now_utc()
    enqueue_outbox_event(
        db,
        topic="referral.reward.granted",
        payload={
            "grant_id": str(grant.id),
            "referrer_user_id": str(link.referrer_user_id),
            "referee_user_id": str(referee_user_id),
            "conversion_type": conversion_type.value,
            "conversion_id": str(conversion_id),
            "reward_ledger_entry_ids": reward_entry_ids,
        },
        idempotency_key=f"referral-reward-grant:{conversion_type.value}:{conversion_id}",
        idempotency_scope="referral_reward_grant",
    )
    db.flush()
    return ReferralConversionResult(grant=grant, reward_entry_ids=[uuid.UUID(item) for item in reward_entry_ids])


def get_referral_stats(db: Session, *, user_id: uuid.UUID) -> dict:
    profile = ensure_referral_profile(db, user_id)
    clicks = db.execute(
        select(func.count()).select_from(ReferralLink).where(
            ReferralLink.referrer_user_id == user_id,
            ReferralLink.status == ReferralLinkStatus.clicked,
        )
    ).scalar_one()
    registered = db.execute(
        select(func.count()).select_from(ReferralLink).where(
            ReferralLink.referrer_user_id == user_id,
            ReferralLink.status.in_([ReferralLinkStatus.registered, ReferralLinkStatus.converted]),
        )
    ).scalar_one()
    converted = db.execute(
        select(func.count()).select_from(ReferralLink).where(
            ReferralLink.referrer_user_id == user_id,
            ReferralLink.status == ReferralLinkStatus.converted,
        )
    ).scalar_one()
    grants = db.execute(
        select(ReferralRewardGrant).where(ReferralRewardGrant.referrer_user_id == user_id)
    ).scalars().all()

    total_points_earned = 0
    if grants:
        reward_ids: list[uuid.UUID] = []
        for grant in grants:
            reward_ids.extend(uuid.UUID(item) for item in grant.reward_ledger_entry_ids if item)
        if reward_ids:
            rows = db.execute(
                select(RewardLedgerEntry.amount).where(RewardLedgerEntry.id.in_(reward_ids))
            ).all()
            total_points_earned = int(sum(max(0, int(amount)) for amount, in rows))

    return {
        "code": profile.referral_code,
        "clicks": int(clicks),
        "registered": int(registered),
        "converted": int(converted),
        "total_points_earned": total_points_earned,
    }


def list_referral_policies(db: Session) -> list[ReferralRewardPolicy]:
    ensure_default_referral_reward_policies(db)
    return db.execute(
        select(ReferralRewardPolicy).order_by(ReferralRewardPolicy.conversion_type.asc())
    ).scalars().all()


def upsert_referral_policy(
    db: Session,
    *,
    conversion_type: str,
    referrer_points: int,
    referee_points: int,
    max_rewards_per_referrer_per_month: int,
    min_conversion_value_eur: Decimal,
    cooldown_days: int,
) -> ReferralRewardPolicy:
    row = db.execute(
        select(ReferralRewardPolicy).where(ReferralRewardPolicy.conversion_type == conversion_type)
    ).scalar_one_or_none()
    if row is None:
        row = ReferralRewardPolicy(
            conversion_type=conversion_type,
            referrer_points=referrer_points,
            referee_points=referee_points,
            max_rewards_per_referrer_per_month=max_rewards_per_referrer_per_month,
            min_conversion_value_eur=min_conversion_value_eur,
            cooldown_days=cooldown_days,
        )
        db.add(row)
        db.flush()
        return row

    row.referrer_points = referrer_points
    row.referee_points = referee_points
    row.max_rewards_per_referrer_per_month = max_rewards_per_referrer_per_month
    row.min_conversion_value_eur = min_conversion_value_eur
    row.cooldown_days = cooldown_days
    row.updated_at = now_utc()
    db.flush()
    return row


def blacklist_referrer(db: Session, *, user_id: uuid.UUID, reason: str) -> ReferralBlacklist:
    row = db.execute(select(ReferralBlacklist).where(ReferralBlacklist.user_id == user_id)).scalar_one_or_none()
    if row:
        row.reason = reason
        return row
    row = ReferralBlacklist(user_id=user_id, reason=reason)
    db.add(row)
    db.flush()
    return row


def remove_referrer_blacklist(db: Session, *, user_id: uuid.UUID) -> bool:
    row = db.execute(select(ReferralBlacklist).where(ReferralBlacklist.user_id == user_id)).scalar_one_or_none()
    if not row:
        return False
    db.delete(row)
    db.flush()
    return True


def referral_report(
    db: Session,
    *,
    from_dt: datetime | None,
    to_dt: datetime | None,
) -> dict:
    stmt = select(ReferralRewardGrant)
    if from_dt:
        stmt = stmt.where(ReferralRewardGrant.granted_at >= from_dt)
    if to_dt:
        stmt = stmt.where(ReferralRewardGrant.granted_at <= to_dt)
    grants = db.execute(stmt).scalars().all()

    total_conversions = len(grants)
    total_referrers = len({item.referrer_user_id for item in grants})
    total_referees = len({item.referee_user_id for item in grants})

    total_points = 0
    reward_ids: list[uuid.UUID] = []
    for grant in grants:
        reward_ids.extend(uuid.UUID(item) for item in grant.reward_ledger_entry_ids if item)
    if reward_ids:
        amounts = db.execute(select(RewardLedgerEntry.amount).where(RewardLedgerEntry.id.in_(reward_ids))).all()
        total_points = int(sum(max(0, int(amount)) for amount, in amounts))

    by_type: dict[str, int] = {}
    for grant in grants:
        by_type[grant.conversion_type] = by_type.get(grant.conversion_type, 0) + 1

    return {
        "total_conversions": total_conversions,
        "total_referrers": total_referrers,
        "total_referees": total_referees,
        "total_points_awarded": total_points,
        "conversions_by_type": by_type,
    }


def get_share_link_owner_referral_code(db: Session, *, share_link_id: uuid.UUID) -> str | None:
    link = db.get(ShareLink, share_link_id)
    if not link:
        return None
    profile = ensure_referral_profile(db, link.created_by_user_id)
    return profile.referral_code
