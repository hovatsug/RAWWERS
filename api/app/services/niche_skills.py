from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Any

from sqlalchemy import and_, delete, func, or_, select
from sqlalchemy.orm import Session

from app.models.admin import Dispute, DisputeStatus
from app.models.gig import Gig, GigStatus
from app.models.learning import Certificate, CertificateType
from app.models.media import MediaAsset, MediaPurpose, MediaStatus
from app.models.niche import (
    Badge,
    CertificationRecord,
    Niche,
    NicheTierPolicy,
    ProNiche,
    ProNicheSkill,
    ProNicheSkillActorType,
    ProNicheSkillEvent,
    ProNicheSkillEventType,
    SkillTier,
    UserBadge,
)
from app.models.review import Review, ReviewStatus
from app.services.analytics import log_event
from app.services.gamification import queue_evaluate_user_milestones, queue_recompute_credentials
from app.services.outbox import enqueue_outbox_event
from app.services.search_indexing import enqueue_pro_index_upsert

TIER_RANK = {
    SkillTier.rookie: 0,
    SkillTier.skilled: 1,
    SkillTier.pro: 2,
    SkillTier.elite: 3,
    SkillTier.master: 4,
}

HYSTERESIS_DAYS = 7


def default_tier_thresholds() -> dict[str, dict[str, Any]]:
    return {
        "rookie": {"min_score": 0, "min_gigs": 0, "min_rating": 0, "requires_verified": False},
        "skilled": {"min_score": 25, "min_gigs": 5, "min_rating": 4.2, "requires_verified": False},
        "pro": {"min_score": 50, "min_gigs": 20, "min_rating": 4.4, "requires_verified": True},
        "elite": {"min_score": 70, "min_gigs": 50, "min_rating": 4.6, "requires_verified": True},
        "master": {"min_score": 85, "min_gigs": 120, "min_rating": 4.7, "requires_verified": True},
    }


def enqueue_niche_skill_recalc(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID | None,
    reason: str,
) -> None:
    payload = {
        "pro_user_id": str(pro_user_id),
        "niche_id": str(niche_id) if niche_id else None,
        "reason": reason,
    }
    enqueue_outbox_event(
        db,
        topic="niche_skill.recalc",
        payload=payload,
        idempotency_key=f"niche_skill.recalc:{pro_user_id}:{niche_id or 'all'}:{reason}",
        idempotency_scope="niche_skill_recalc",
    )


def get_or_create_niche_tier_policy(db: Session, niche_id: uuid.UUID) -> NicheTierPolicy:
    row = db.execute(select(NicheTierPolicy).where(NicheTierPolicy.niche_id == niche_id)).scalar_one_or_none()
    if row:
        return row
    row = NicheTierPolicy(niche_id=niche_id, thresholds=default_tier_thresholds())
    db.add(row)
    db.flush()
    return row


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


def recompute_pro_niche_skill(
    db: Session,
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID,
    *,
    actor_type: ProNicheSkillActorType = ProNicheSkillActorType.system,
    actor_user_id: uuid.UUID | None = None,
    bypass_hysteresis: bool = False,
) -> ProNicheSkill:
    now = datetime.now(timezone.utc)
    niche = db.get(Niche, niche_id)
    if not niche:
        raise ValueError(f"Niche {niche_id} not found")

    policy = get_or_create_niche_tier_policy(db, niche_id)
    thresholds = policy.thresholds or default_tier_thresholds()

    gigs_completed = int(
        db.execute(
            select(func.count())
            .select_from(Gig)
            .where(
                Gig.pro_user_id == pro_user_id,
                Gig.niche_id == niche_id,
                Gig.status == GigStatus.completed,
            )
        ).scalar_one()
        or 0
    )

    review_count = int(
        db.execute(
            select(func.count())
            .select_from(Review)
            .where(
                Review.pro_user_id == pro_user_id,
                Review.niche_id == niche_id,
                Review.status == ReviewStatus.published,
            )
        ).scalar_one()
        or 0
    )
    avg_rating_raw = db.execute(
        select(func.avg(Review.rating)).where(
            Review.pro_user_id == pro_user_id,
            Review.niche_id == niche_id,
            Review.status == ReviewStatus.published,
        )
    ).scalar_one()
    avg_rating = Decimal(str(float(avg_rating_raw) if avg_rating_raw is not None else 0.0)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    disputes_lost_90d = int(
        db.execute(
            select(func.count())
            .select_from(Dispute)
            .join(Gig, Gig.id == Dispute.gig_id)
            .where(
                Gig.pro_user_id == pro_user_id,
                Gig.niche_id == niche_id,
                Dispute.status.in_([DisputeStatus.resolved_refund, DisputeStatus.resolved_partial_refund]),
                Dispute.updated_at >= now - timedelta(days=90),
            )
        ).scalar_one()
        or 0
    )

    cert_verified = db.execute(
        select(Certificate.id).where(
            Certificate.user_id == pro_user_id,
            Certificate.certificate_type == CertificateType.curriculum,
            Certificate.niche_slug == niche.slug,
            Certificate.revoked_at.is_(None),
        )
    ).scalar_one_or_none()
    legacy_verified = db.execute(
        select(CertificationRecord.id).where(
            CertificationRecord.pro_user_id == pro_user_id,
            CertificationRecord.niche_id == niche_id,
            CertificationRecord.completed_at.is_not(None),
            or_(CertificationRecord.expires_at.is_(None), CertificationRecord.expires_at > now),
        )
    ).scalar_one_or_none()
    verified = bool(cert_verified or legacy_verified)

    gigs_points = min(gigs_completed, 120) * Decimal("0.5")
    rating_multiplier = Decimal("25") if review_count >= 10 else Decimal("15")
    rating_points_raw = (avg_rating - Decimal("4.0")) * rating_multiplier
    rating_points = max(Decimal("0"), min(rating_points_raw, Decimal("25") if review_count >= 10 else Decimal("15")))
    verified_bonus = Decimal("10") if verified else Decimal("0")
    penalty = Decimal(str(min(disputes_lost_90d * 10, 30)))
    score_decimal = gigs_points + rating_points + verified_bonus - penalty
    score = int(max(0, min(100, round(float(score_decimal)))))

    portfolio_assets = db.execute(
        select(MediaAsset.niche_tags)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
    ).all()
    evidence_portfolio = sum(1 for (tags,) in portfolio_assets if isinstance(tags, list) and niche.slug in tags)

    confidence_raw = min(1.0, (min(gigs_completed, 120) / 120.0) * 0.5 + (min(review_count, 20) / 20.0) * 0.3 + (0.2 if verified else 0.0))
    confidence = Decimal(str(confidence_raw)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    target_tier = _tier_from_thresholds(
        thresholds=thresholds,
        score=score,
        gigs_completed=gigs_completed,
        avg_rating=float(avg_rating),
        verified=verified,
    )

    skill = db.execute(
        select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id)
    ).scalar_one_or_none()
    previous_tier = skill.tier if skill else SkillTier.rookie
    previous_score = skill.score if skill else 0
    previous_verified = skill.verified if skill else False

    if not skill:
        skill = ProNicheSkill(pro_user_id=pro_user_id, niche_id=niche_id)
        db.add(skill)
        db.flush()

    target_tier, hysteresis_blocked = _apply_hysteresis(
        skill=skill,
        target_tier=target_tier,
        now=now,
        bypass=bypass_hysteresis,
    )

    override_applied, score, target_tier, verified = _apply_active_override(skill.breakdown or {}, now, score, target_tier, verified)

    event_type = ProNicheSkillEventType.recalculated
    if TIER_RANK.get(target_tier, 0) > TIER_RANK.get(previous_tier, 0):
        event_type = ProNicheSkillEventType.promoted
        skill.last_promotion_at = now
    elif TIER_RANK.get(target_tier, 0) < TIER_RANK.get(previous_tier, 0):
        event_type = ProNicheSkillEventType.demoted
        skill.last_demotion_at = now
    elif previous_verified != verified:
        event_type = ProNicheSkillEventType.verified_set

    reasons: dict[str, Any] = {
        "score_formula": {
            "gigs_points": float(gigs_points),
            "rating_points": float(rating_points),
            "verified_bonus": int(verified_bonus),
            "penalty": int(penalty),
            "score": score,
        },
        "signals": {
            "gigs_completed": gigs_completed,
            "avg_rating": float(avg_rating),
            "review_count": review_count,
            "disputes_lost_90d": disputes_lost_90d,
            "verified": verified,
            "evidence_portfolio": evidence_portfolio,
        },
        "thresholds": thresholds,
        "hysteresis_blocked": hysteresis_blocked,
        "override_applied": override_applied,
    }

    skill.score = score
    skill.verified = verified
    skill.gigs_completed = gigs_completed
    skill.avg_rating = avg_rating
    skill.review_count = review_count
    skill.tier = target_tier
    skill.capability_score = score
    skill.certification_score = 100 if verified else skill.certification_score
    skill.confidence = confidence
    skill.evidence_gigs = gigs_completed
    skill.evidence_reviews = review_count
    skill.evidence_portfolio = evidence_portfolio
    skill.breakdown = reasons
    skill.updated_at = now
    db.flush()

    _sync_niche_badges(db, user_id=pro_user_id, niche_slug=niche.slug, tier=skill.tier, verified=skill.verified)
    _create_skill_event(
        db,
        pro_user_id=pro_user_id,
        niche_id=niche_id,
        event_type=event_type,
        from_tier=previous_tier.value if previous_tier else None,
        to_tier=skill.tier.value,
        score_before=previous_score,
        score_after=skill.score,
        reasons=reasons,
        actor_type=actor_type,
        actor_user_id=actor_user_id,
    )

    queue_recompute_credentials(pro_user_id, niche_id)
    if previous_tier != skill.tier:
        queue_evaluate_user_milestones(pro_user_id, niche_id)
    enqueue_pro_index_upsert(db, pro_user_id, idempotency_suffix=skill.updated_at.isoformat() if skill.updated_at else "now")
    log_event(
        db,
        event_name="pro.niche_skill.recalculated",
        user_id=pro_user_id,
        properties={"niche_id": str(niche_id), "tier": skill.tier.value, "score": skill.score},
    )
    return skill


def admin_override_niche_skill(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID,
    tier: SkillTier | None,
    score: int | None,
    verified: bool | None,
    note: str,
    actor_user_id: uuid.UUID,
) -> ProNicheSkill:
    skill = db.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id)).scalar_one_or_none()
    if not skill:
        skill = ProNicheSkill(pro_user_id=pro_user_id, niche_id=niche_id)
        db.add(skill)
        db.flush()

    before_tier = skill.tier
    before_score = skill.score

    if tier is not None:
        skill.tier = tier
    if score is not None:
        skill.score = max(0, min(100, int(score)))
        skill.capability_score = skill.score
    if verified is not None:
        skill.verified = bool(verified)
        skill.certification_score = 100 if skill.verified else 0

    breakdown = dict(skill.breakdown or {})
    breakdown["admin_override"] = {
        "tier": skill.tier.value,
        "score": skill.score,
        "verified": skill.verified,
        "note": note,
        "actor_user_id": str(actor_user_id),
        "at": datetime.now(timezone.utc).isoformat(),
    }
    skill.breakdown = breakdown
    skill.updated_at = datetime.now(timezone.utc)

    niche = db.get(Niche, niche_id)
    if niche:
        _sync_niche_badges(db, user_id=pro_user_id, niche_slug=niche.slug, tier=skill.tier, verified=skill.verified)

    _create_skill_event(
        db,
        pro_user_id=pro_user_id,
        niche_id=niche_id,
        event_type=ProNicheSkillEventType.admin_override,
        from_tier=before_tier.value,
        to_tier=skill.tier.value,
        score_before=before_score,
        score_after=skill.score,
        reasons={"note": note},
        actor_type=ProNicheSkillActorType.admin,
        actor_user_id=actor_user_id,
    )
    db.flush()
    enqueue_pro_index_upsert(db, pro_user_id, idempotency_suffix="admin_override")
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
            int(item[0].score or 0),
            float(item[0].avg_rating or 0),
            int(item[0].gigs_completed or 0),
        ),
        reverse=True,
    )
    top = rows[:limit]
    return [
        {
            "slug": niche.slug,
            "tier": skill.tier.value,
            "score": int(skill.score),
            "verified": bool(skill.verified),
            "capability": skill.capability_score,
            "confidence": float(skill.confidence),
        }
        for skill, niche in top
    ]


def get_niche_tier_map_for_index(db: Session, pro_user_id: uuid.UUID) -> dict[str, str]:
    rows = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == pro_user_id)
    ).all()
    return {niche.slug: skill.tier.value for skill, niche in rows}


def get_verified_niches_for_index(db: Session, pro_user_id: uuid.UUID) -> list[str]:
    rows = db.execute(
        select(Niche.slug)
        .join(ProNicheSkill, ProNicheSkill.niche_id == Niche.id)
        .where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.verified.is_(True))
    ).scalars().all()
    return sorted(set(rows))


def list_user_badge_codes(db: Session, user_id: uuid.UUID) -> list[str]:
    rows = db.execute(
        select(Badge.code)
        .join(UserBadge, UserBadge.badge_id == Badge.id)
        .where(UserBadge.user_id == user_id)
    ).scalars().all()
    return sorted(set(rows))


def _tier_from_thresholds(
    *,
    thresholds: dict[str, dict[str, Any]],
    score: int,
    gigs_completed: int,
    avg_rating: float,
    verified: bool,
) -> SkillTier:
    ordered = [SkillTier.rookie, SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master]
    chosen = SkillTier.rookie
    for tier in ordered:
        rule = thresholds.get(tier.value) or {}
        min_score = int(rule.get("min_score", 0))
        min_gigs = int(rule.get("min_gigs", 0))
        min_rating = float(rule.get("min_rating", 0.0))
        requires_verified = bool(rule.get("requires_verified", False))
        if score < min_score:
            continue
        if gigs_completed < min_gigs:
            continue
        if avg_rating < min_rating:
            continue
        if requires_verified and not verified:
            continue
        chosen = tier
    return chosen


def _apply_hysteresis(
    *,
    skill: ProNicheSkill,
    target_tier: SkillTier,
    now: datetime,
    bypass: bool,
) -> tuple[SkillTier, bool]:
    if bypass:
        return target_tier, False
    current_rank = TIER_RANK.get(skill.tier, 0)
    target_rank = TIER_RANK.get(target_tier, 0)
    if target_rank == current_rank:
        return target_tier, False

    cooldown = timedelta(days=HYSTERESIS_DAYS)
    if target_rank > current_rank and skill.last_promotion_at and (now - skill.last_promotion_at) < cooldown:
        return skill.tier, True
    if target_rank < current_rank and skill.last_demotion_at and (now - skill.last_demotion_at) < cooldown:
        return skill.tier, True
    return target_tier, False


def _apply_active_override(
    breakdown: dict[str, Any],
    now: datetime,
    score: int,
    tier: SkillTier,
    verified: bool,
) -> tuple[bool, int, SkillTier, bool]:
    override = breakdown.get("override")
    if not isinstance(override, dict):
        return False, score, tier, verified

    expires_at_raw = override.get("expires_at")
    if expires_at_raw:
        try:
            expires_at = datetime.fromisoformat(str(expires_at_raw).replace("Z", "+00:00"))
            if expires_at.tzinfo is None:
                expires_at = expires_at.replace(tzinfo=timezone.utc)
            if now >= expires_at:
                return False, score, tier, verified
        except ValueError:
            pass

    override_score = override.get("score")
    override_tier = override.get("tier")
    override_verified = override.get("verified")

    if isinstance(override_score, int):
        score = max(0, min(100, override_score))
    if isinstance(override_tier, str):
        try:
            tier = SkillTier(override_tier)
        except ValueError:
            pass
    if isinstance(override_verified, bool):
        verified = override_verified
    return True, score, tier, verified


def _create_skill_event(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID,
    event_type: ProNicheSkillEventType,
    from_tier: str | None,
    to_tier: str | None,
    score_before: int | None,
    score_after: int | None,
    reasons: dict[str, Any],
    actor_type: ProNicheSkillActorType,
    actor_user_id: uuid.UUID | None,
) -> None:
    db.add(
        ProNicheSkillEvent(
            pro_user_id=pro_user_id,
            niche_id=niche_id,
            event_type=event_type,
            from_tier=from_tier,
            to_tier=to_tier,
            score_before=score_before,
            score_after=score_after,
            reasons=reasons,
            actor_type=actor_type,
            actor_user_id=actor_user_id,
        )
    )


def _ensure_badge(db: Session, code: str, *, name_key: str, description_key: str) -> Badge:
    row = db.execute(select(Badge).where(Badge.code == code)).scalar_one_or_none()
    if row:
        return row
    row = Badge(code=code, name_key=name_key, description_key=description_key, icon_ref=None)
    db.add(row)
    db.flush()
    return row


def _sync_niche_badges(db: Session, *, user_id: uuid.UUID, niche_slug: str, tier: SkillTier, verified: bool) -> None:
    existing = db.execute(
        select(UserBadge, Badge)
        .join(Badge, Badge.id == UserBadge.badge_id)
        .where(
            UserBadge.user_id == user_id,
            or_(Badge.code.like(f"tier_{niche_slug}_%"), Badge.code == f"verified_{niche_slug}"),
        )
    ).all()
    for user_badge, _badge in existing:
        db.delete(user_badge)
    db.flush()

    tier_code = f"tier_{niche_slug}_{tier.value}"
    tier_badge = _ensure_badge(
        db,
        tier_code,
        name_key=f"badges.{tier_code}.name",
        description_key=f"badges.{tier_code}.description",
    )
    db.add(UserBadge(user_id=user_id, badge_id=tier_badge.id, source="niche_skill"))

    if verified:
        ver_code = f"verified_{niche_slug}"
        ver_badge = _ensure_badge(
            db,
            ver_code,
            name_key=f"badges.{ver_code}.name",
            description_key=f"badges.{ver_code}.description",
        )
        db.add(UserBadge(user_id=user_id, badge_id=ver_badge.id, source="niche_skill"))
