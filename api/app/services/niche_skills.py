from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.admin import Dispute
from app.models.gig import Gig, GigStatus
from app.models.media import MediaAsset, MediaPurpose, MediaStatus
from app.models.niche import CertificationRecord, Niche, ProNiche, ProNicheSkill, SkillTier
from app.models.review import Review, ReviewStatus

TIER_RANK = {
    SkillTier.rookie: 0,
    SkillTier.skilled: 1,
    SkillTier.pro: 2,
    SkillTier.elite: 3,
    SkillTier.master: 4,
}


def recompute_pro_niche_skills(db: Session, pro_user_id: uuid.UUID, niche_id: uuid.UUID | None = None) -> int:
    niche_ids: list[uuid.UUID]
    if niche_id:
        niche_ids = [niche_id]
    else:
        niche_ids = [item.id for item in db.execute(select(Niche).where(Niche.is_active.is_(True))).scalars().all()]

    for current_niche_id in niche_ids:
        recompute_pro_niche_skill(db, pro_user_id, current_niche_id)
    db.flush()
    return len(niche_ids)


def recompute_all_pro_niche_skills(db: Session) -> int:
    pro_user_ids = db.execute(select(ProNiche.pro_user_id).distinct()).scalars().all()
    if not pro_user_ids:
        pro_user_ids = db.execute(select(Gig.pro_user_id).distinct()).scalars().all()
    count = 0
    for pro_user_id in pro_user_ids:
        recompute_pro_niche_skills(db, pro_user_id)
        count += 1
    db.flush()
    return count


def recompute_pro_niche_skill(db: Session, pro_user_id: uuid.UUID, niche_id: uuid.UUID) -> ProNicheSkill:
    now = datetime.now(timezone.utc)
    niche = db.get(Niche, niche_id)
    if not niche:
        raise ValueError(f"Niche {niche_id} not found")

    evidence_gigs = db.execute(
        select(func.count())
        .select_from(Gig)
        .where(
            Gig.pro_user_id == pro_user_id,
            Gig.niche_id == niche_id,
            Gig.status == GigStatus.completed,
        )
    ).scalar_one()
    evidence_reviews = db.execute(
        select(func.count())
        .select_from(Review)
        .where(
            Review.pro_user_id == pro_user_id,
            Review.niche_id == niche_id,
            Review.status == ReviewStatus.published,
        )
    ).scalar_one()

    portfolio_assets = db.execute(
        select(MediaAsset.niche_tags)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
    ).all()
    evidence_portfolio = sum(1 for (tags,) in portfolio_assets if isinstance(tags, list) and niche.slug in tags)

    gigs_weight = min(evidence_gigs, 30) / 30.0
    reviews_weight = min(evidence_reviews, 20) / 20.0
    portfolio_weight = min(evidence_portfolio, 40) / 40.0
    confidence_raw = (0.1 * gigs_weight) + (0.6 * gigs_weight) + (0.2 * reviews_weight) + (0.2 * portfolio_weight)
    confidence = max(0.0, min(1.0, confidence_raw))
    confidence = float(Decimal(str(confidence)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))

    disputes_in_niche = db.execute(
        select(func.count())
        .select_from(Dispute)
        .join(Gig, Gig.id == Dispute.gig_id)
        .where(Gig.pro_user_id == pro_user_id, Gig.niche_id == niche_id)
    ).scalar_one()
    cancelled_gigs_in_niche = db.execute(
        select(func.count())
        .select_from(Gig)
        .where(
            Gig.pro_user_id == pro_user_id,
            Gig.niche_id == niche_id,
            Gig.status.in_([GigStatus.cancelled_by_client, GigStatus.cancelled_by_pro]),
        )
    ).scalar_one()
    avg_rating_value = db.execute(
        select(func.avg(Review.rating))
        .where(
            Review.pro_user_id == pro_user_id,
            Review.niche_id == niche_id,
            Review.status == ReviewStatus.published,
        )
    ).scalar_one()
    avg_rating_in_niche = float(avg_rating_value) if avg_rating_value is not None else None

    completed_gigs = db.execute(
        select(Gig.scheduled_end, Gig.updated_at, Gig.meta)
        .where(
            Gig.pro_user_id == pro_user_id,
            Gig.niche_id == niche_id,
            Gig.status == GigStatus.completed,
        )
    ).all()
    on_time_total = 0
    on_time_count = 0
    for scheduled_end, updated_at, meta in completed_gigs:
        if not scheduled_end:
            continue
        finals_sla_days = ((meta or {}).get("pricing_snapshot") or {}).get("finals_sla_days", 7)
        try:
            finals_sla_days_int = int(finals_sla_days)
        except (TypeError, ValueError):
            finals_sla_days_int = 7
        deadline = scheduled_end + timedelta(days=max(0, finals_sla_days_int))
        on_time_total += 1
        if updated_at <= deadline:
            on_time_count += 1
    on_time_delivery_rate_in_niche = (on_time_count / on_time_total) if on_time_total > 0 else 0.0

    base = 50
    completion_bonus = min(evidence_gigs, 20) * 1.5
    dispute_penalty = disputes_in_niche * 8
    cancellation_penalty = cancelled_gigs_in_niche * 4
    rating_bonus = ((avg_rating_in_niche - 4.0) * 12) if avg_rating_in_niche is not None else 0.0
    sla_bonus = on_time_delivery_rate_in_niche * 10
    capability_raw = base + completion_bonus + rating_bonus + sla_bonus - dispute_penalty - cancellation_penalty
    capability_score = max(0, min(100, round(capability_raw)))

    cert_score_value = db.execute(
        select(func.max(CertificationRecord.score))
        .where(
            CertificationRecord.pro_user_id == pro_user_id,
            CertificationRecord.niche_id == niche_id,
            CertificationRecord.completed_at.is_not(None),
            (CertificationRecord.expires_at.is_(None) | (CertificationRecord.expires_at > now)),
        )
    ).scalar_one()
    certification_score = max(0, min(100, int(cert_score_value or 0)))

    tier = _compute_tier(
        certification_score=certification_score,
        capability_score=capability_score,
        confidence=confidence,
        evidence_gigs=evidence_gigs,
    )
    breakdown: dict[str, Any] = {
        "confidence_components": {
            "gigs_weight": gigs_weight,
            "reviews_weight": reviews_weight,
            "portfolio_weight": portfolio_weight,
            "formula": "0.1*gigs + 0.6*gigs + 0.2*reviews + 0.2*portfolio",
            "raw": confidence_raw,
        },
        "capability_components": {
            "base": base,
            "completion_bonus": completion_bonus,
            "rating_bonus": rating_bonus,
            "sla_bonus": sla_bonus,
            "dispute_penalty": dispute_penalty,
            "cancellation_penalty": cancellation_penalty,
            "capability_raw": capability_raw,
        },
        "avg_rating_in_niche": avg_rating_in_niche,
        "on_time_delivery_rate_in_niche": on_time_delivery_rate_in_niche,
        "computed_tier": tier.value,
    }

    skill = db.execute(
        select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id)
    ).scalar_one_or_none()
    override_applied = False
    if skill and isinstance(skill.breakdown, dict):
        override_applied, capability_score, certification_score, tier = _apply_active_override(
            skill.breakdown,
            now,
            capability_score,
            certification_score,
            tier,
        )

    if override_applied:
        breakdown["override_applied"] = True

    previous_tier = skill.tier if skill else None
    if not skill:
        skill = ProNicheSkill(pro_user_id=pro_user_id, niche_id=niche_id)
        db.add(skill)

    skill.capability_score = capability_score
    skill.certification_score = certification_score
    skill.confidence = Decimal(str(confidence)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    skill.tier = tier
    skill.evidence_gigs = evidence_gigs
    skill.evidence_reviews = evidence_reviews
    skill.evidence_portfolio = evidence_portfolio
    if isinstance(skill.breakdown, dict) and "override" in skill.breakdown:
        breakdown["override"] = skill.breakdown["override"]
    skill.breakdown = breakdown
    skill.updated_at = now
    db.flush()

    from app.services.gamification import queue_evaluate_user_milestones, queue_recompute_credentials
    from app.services.search_indexing import enqueue_pro_index_upsert

    queue_recompute_credentials(pro_user_id, niche_id)
    if previous_tier != tier:
        queue_evaluate_user_milestones(pro_user_id, niche_id)
    enqueue_pro_index_upsert(db, pro_user_id, idempotency_suffix=skill.updated_at.isoformat() if skill.updated_at else "now")
    return skill


def get_top_niches_for_index(db: Session, pro_user_id: uuid.UUID, limit: int = 3) -> list[dict[str, Any]]:
    rows = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == pro_user_id)
    ).all()
    rows.sort(
        key=lambda item: (
            TIER_RANK.get(item[0].tier, 0),
            item[0].capability_score,
            float(item[0].confidence),
            item[0].evidence_gigs,
        ),
        reverse=True,
    )
    top = rows[:limit]
    return [
        {
            "slug": niche.slug,
            "tier": skill.tier.value,
            "capability": skill.capability_score,
            "confidence": float(skill.confidence),
        }
        for skill, niche in top
    ]


def _compute_tier(
    certification_score: int,
    capability_score: int,
    confidence: float,
    evidence_gigs: int,
) -> SkillTier:
    if (
        certification_score >= 85
        and capability_score >= 85
        and confidence >= 0.70
        and evidence_gigs >= 15
    ):
        return SkillTier.master
    if certification_score >= 75 and capability_score >= 75 and confidence >= 0.55:
        return SkillTier.elite
    if certification_score >= 60 and capability_score >= 65 and confidence >= 0.35:
        return SkillTier.pro
    if certification_score >= 40 or (capability_score >= 55 and confidence >= 0.20):
        return SkillTier.skilled
    return SkillTier.rookie


def _apply_active_override(
    breakdown: dict[str, Any],
    now: datetime,
    capability_score: int,
    certification_score: int,
    tier: SkillTier,
) -> tuple[bool, int, int, SkillTier]:
    override = breakdown.get("override")
    if not isinstance(override, dict):
        return False, capability_score, certification_score, tier

    expires_at_raw = override.get("expires_at")
    if expires_at_raw:
        try:
            expires_at = datetime.fromisoformat(expires_at_raw.replace("Z", "+00:00"))
            if expires_at.tzinfo is None:
                expires_at = expires_at.replace(tzinfo=timezone.utc)
            if now >= expires_at:
                return False, capability_score, certification_score, tier
        except ValueError:
            pass

    override_capability = override.get("capability_score")
    if isinstance(override_capability, int):
        capability_score = max(0, min(100, override_capability))

    override_certification = override.get("certification_score")
    if isinstance(override_certification, int):
        certification_score = max(0, min(100, override_certification))

    override_tier = override.get("tier")
    if isinstance(override_tier, str):
        try:
            tier = SkillTier(override_tier)
        except ValueError:
            pass

    return True, capability_score, certification_score, tier
