from __future__ import annotations

import uuid
from dataclasses import dataclass
from decimal import Decimal

from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from app.models.admin import UserRole, UserRoleType
from app.models.booking import ProAvailabilityRule
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus, RolloutCity
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.services.feature_flags import is_feature_enabled
from app.services.launch_ops import get_active_rollout_override


MATCH_SCORE_WEIGHTS: dict[str, Decimal] = {
    "niche_fit": Decimal("5.0"),
    "distance": Decimal("2.0"),
    "price_band": Decimal("2.5"),
    "quality": Decimal("3.0"),
    "dispute_penalty": Decimal("-4.0"),
    "availability": Decimal("1.2"),
}

_TIER_RANK = {
    SkillTier.rookie: Decimal("1"),
    SkillTier.skilled: Decimal("2"),
    SkillTier.pro: Decimal("3"),
    SkillTier.elite: Decimal("4"),
    SkillTier.master: Decimal("5"),
}


@dataclass(frozen=True)
class ClientGateDecision:
    enabled: bool
    reason: str


@dataclass(frozen=True)
class MatchInput:
    country: str
    city: str
    niche_slug: str
    budget_min: Decimal | None
    budget_max: Decimal | None
    style_tags: list[str]


@dataclass(frozen=True)
class ScoredCandidate:
    pro_user_id: uuid.UUID
    score: Decimal
    breakdown: dict


def normalize_country_city(*, country: str, city: str) -> tuple[str, str]:
    return country.strip().upper(), city.strip()


def evaluate_client_city_access(
    db: Session,
    *,
    country: str,
    city: str,
    user_id: uuid.UUID | None,
) -> ClientGateDecision:
    if not is_feature_enabled(db, "client_browsing_enabled_global", user_id=user_id):
        return ClientGateDecision(enabled=False, reason="global_flag_disabled")

    if user_id:
        override = get_active_rollout_override(db, user_id=user_id)
        if override and override.can_access_client_app:
            return ClientGateDecision(enabled=True, reason="user_override")

    gate_row = db.execute(
        select(RolloutCity).where(
            func.upper(RolloutCity.country) == country.strip().upper(),
            func.lower(RolloutCity.city) == city.strip().lower(),
        )
    ).scalar_one_or_none()
    if gate_row and gate_row.is_client_browsing_enabled:
        return ClientGateDecision(enabled=True, reason="city_enabled")
    return ClientGateDecision(enabled=False, reason="city_not_enabled")


def ensure_client_role(db: Session, *, user_id: uuid.UUID) -> None:
    row = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == UserRoleType.client)).scalar_one_or_none()
    if row:
        return
    db.add(UserRole(user_id=user_id, role=UserRoleType.client))
    db.flush()


def score_pro_for_match(
    db: Session,
    *,
    pro: ProPublicIndex,
    req: MatchInput,
    niche_id: uuid.UUID,
) -> ScoredCandidate:
    score = Decimal("0.0")
    breakdown: dict[str, float | str | int | bool] = {}

    skill = db.execute(
        select(ProNicheSkill).where(
            ProNicheSkill.pro_user_id == pro.pro_user_id,
            ProNicheSkill.niche_id == niche_id,
        )
    ).scalar_one_or_none()
    tier_rank = Decimal("0")
    if skill:
        tier_rank = _TIER_RANK.get(skill.tier, Decimal("1"))
        niche_score = MATCH_SCORE_WEIGHTS["niche_fit"] * tier_rank
        score += niche_score
        breakdown["niche_fit"] = float(niche_score)
        breakdown["tier"] = skill.tier.value
    else:
        breakdown["niche_fit"] = 0.0

    if (pro.city or "").strip().lower() == req.city.strip().lower() and (pro.country or "").strip().upper() == req.country.strip().upper():
        dist_score = MATCH_SCORE_WEIGHTS["distance"]
    elif (pro.country or "").strip().upper() == req.country.strip().upper():
        dist_score = MATCH_SCORE_WEIGHTS["distance"] / Decimal("2")
    else:
        dist_score = Decimal("0")
    score += dist_score
    breakdown["distance"] = float(dist_score)

    overlap = _budget_overlaps(
        req_min=req.budget_min,
        req_max=req.budget_max,
        pro_min=pro.min_package_price,
        pro_max=pro.max_package_price,
    )
    price_score = MATCH_SCORE_WEIGHTS["price_band"] if overlap else Decimal("0")
    score += price_score
    breakdown["price_band"] = float(price_score)
    breakdown["budget_overlap"] = overlap

    rating = min(Decimal(pro.avg_rating or 0), Decimal("5.0"))
    review_factor = min(Decimal(pro.review_count or 0), Decimal("50")) / Decimal("50")
    quality_score = MATCH_SCORE_WEIGHTS["quality"] * ((rating / Decimal("5")) + review_factor) / Decimal("2")
    score += quality_score
    breakdown["quality"] = float(quality_score)

    total_gigs = max(int(pro.gigs_completed or 0) + int(pro.gigs_cancelled or 0), 1)
    dispute_rate = Decimal(int(pro.disputes_count or 0)) / Decimal(total_gigs)
    dispute_penalty = MATCH_SCORE_WEIGHTS["dispute_penalty"] * min(dispute_rate, Decimal("1"))
    score += dispute_penalty
    breakdown["dispute_penalty"] = float(dispute_penalty)
    breakdown["dispute_rate"] = float(dispute_rate)

    has_availability = db.execute(select(ProAvailabilityRule.id).where(ProAvailabilityRule.pro_user_id == pro.pro_user_id).limit(1)).scalar_one_or_none() is not None
    availability_score = MATCH_SCORE_WEIGHTS["availability"] if has_availability else Decimal("0")
    score += availability_score
    breakdown["availability"] = float(availability_score)

    normalized = score.quantize(Decimal("0.0001"))
    return ScoredCandidate(pro_user_id=pro.pro_user_id, score=normalized, breakdown=breakdown)


def match_candidates(
    db: Session,
    *,
    req: MatchInput,
    limit: int,
) -> tuple[uuid.UUID, list[ScoredCandidate]]:
    niche = db.execute(select(Niche).where(Niche.slug == req.niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
    if not niche:
        raise ValueError("Unknown niche")

    stmt = (
        select(ProPublicIndex)
        .join(
            ProOnboarding,
            and_(
                ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id,
                ProOnboarding.status == ProOnboardingStatus.approved_public,
            ),
        )
        .where(
            ProPublicIndex.is_accepting_bookings.is_(True),
            ProPublicIndex.city.is_not(None),
            ProPublicIndex.country.is_not(None),
        )
    )
    rows = db.execute(stmt).scalars().all()
    scored = [score_pro_for_match(db, pro=row, req=req, niche_id=niche.id) for row in rows]
    scored.sort(key=lambda item: (item.score, str(item.pro_user_id)), reverse=True)
    return niche.id, scored[:max(limit, 1)]


def _budget_overlaps(
    *,
    req_min: Decimal | None,
    req_max: Decimal | None,
    pro_min: Decimal | None,
    pro_max: Decimal | None,
) -> bool:
    if req_min is None and req_max is None:
        return True
    if pro_min is None and pro_max is None:
        return False
    left = pro_min if pro_min is not None else Decimal("0")
    right = pro_max if pro_max is not None else left
    request_left = req_min if req_min is not None else Decimal("0")
    request_right = req_max if req_max is not None else Decimal("999999999")
    return left <= request_right and right >= request_left
