from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Any

from sqlalchemy import and_, delete, func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
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
from app.services.audit import add_admin_audit_log
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
    # No refund penalty: a dispute settled with a refund cost 10 points (up to
    # 30) here, and the tier this score sets feeds ranking and niche-row
    # order - so refunds, goodwill ones included, ranked photographers.
    # Photographer fault is recorded apart (pro_fault_event) and ranks no one.
    score_decimal = gigs_points + rating_points + verified_bonus
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

    # Hysteresis damps the evidence, and only the evidence: it compares what
    # the evidence says now with what it said last time, never with an
    # admin's override, and only an evidence change moves its clocks.
    previous_evidence = skill.evidence_tier or previous_tier
    evidence_tier, hysteresis_blocked = _apply_hysteresis(
        skill=skill,
        current=previous_evidence,
        target_tier=target_tier,
        now=now,
        bypass=bypass_hysteresis,
    )
    if TIER_RANK.get(evidence_tier, 0) > TIER_RANK.get(previous_evidence, 0):
        skill.last_promotion_at = now
    elif TIER_RANK.get(evidence_tier, 0) < TIER_RANK.get(previous_evidence, 0):
        skill.last_demotion_at = now
    evidence_score, evidence_verified = score, verified

    # An admin's override is the effective value until an admin removes it -
    # no expiry, and no hysteresis.
    override_applied = any(v is not None for v in (skill.override_tier, skill.override_score, skill.override_verified))
    target_tier = skill.override_tier or evidence_tier
    if skill.override_score is not None:
        score = skill.override_score
    if skill.override_verified is not None:
        verified = skill.override_verified

    event_type = ProNicheSkillEventType.recalculated
    if TIER_RANK.get(target_tier, 0) > TIER_RANK.get(previous_tier, 0):
        event_type = ProNicheSkillEventType.promoted
    elif TIER_RANK.get(target_tier, 0) < TIER_RANK.get(previous_tier, 0):
        event_type = ProNicheSkillEventType.demoted
    elif previous_verified != verified:
        event_type = ProNicheSkillEventType.verified_set

    reasons: dict[str, Any] = {
        "score_formula": {
            "gigs_points": float(gigs_points),
            "rating_points": float(rating_points),
            "verified_bonus": int(verified_bonus),
            "score": score,
        },
        "signals": {
            "gigs_completed": gigs_completed,
            "avg_rating": float(avg_rating),
            "review_count": review_count,
            "verified": verified,
            "evidence_portfolio": evidence_portfolio,
        },
        "thresholds": thresholds,
        "hysteresis_blocked": hysteresis_blocked,
        "override_applied": override_applied,
        "evidence": {"tier": evidence_tier.value, "score": evidence_score, "verified": evidence_verified},
    }
    if override_applied:
        # Shown to the photographer only as {"active": true} - see
        # pro_onboarding._sanitize_public_breakdown.
        reasons["override"] = _override_view(skill)

    skill.score = score
    skill.verified = verified
    skill.gigs_completed = gigs_completed
    skill.avg_rating = avg_rating
    skill.review_count = review_count
    skill.evidence_tier = evidence_tier
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


def _override_view(skill: ProNicheSkill) -> dict[str, Any]:
    return {
        "tier": skill.override_tier.value if skill.override_tier else None,
        "score": skill.override_score,
        "verified": skill.override_verified,
        "by": str(skill.override_by) if skill.override_by else None,
        "at": skill.override_at.isoformat() if skill.override_at else None,
        "reason": skill.override_reason,
    }


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
    """Set an admin's override. It is the effective value from now until an
    admin removes it (remove_niche_skill_override): recomputes keep it,
    and keep working out the evidence tier beside it."""
    skill = db.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id)).scalar_one_or_none()
    if not skill:
        skill = ProNicheSkill(pro_user_id=pro_user_id, niche_id=niche_id, evidence_tier=SkillTier.rookie)
        db.add(skill)
        db.flush()

    before_tier = skill.tier
    before_score = skill.score
    now = datetime.now(timezone.utc)

    if tier is not None:
        skill.override_tier = tier
        skill.tier = tier
    if score is not None:
        skill.override_score = max(0, min(100, int(score)))
        skill.score = skill.override_score
        skill.capability_score = skill.score
    if verified is not None:
        skill.override_verified = bool(verified)
        skill.verified = skill.override_verified
        skill.certification_score = 100 if skill.verified else 0
    skill.override_by = actor_user_id
    skill.override_at = now
    skill.override_reason = note

    breakdown = dict(skill.breakdown or {})
    breakdown.pop("admin_override", None)  # the old place, which no recompute read
    breakdown["override"] = _override_view(skill)
    skill.breakdown = breakdown
    skill.updated_at = now

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
        reasons={"note": note, "override": _override_view(skill)},
        actor_type=ProNicheSkillActorType.admin,
        actor_user_id=actor_user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor_user_id,
        target_type="pro_niche_skill",
        target_id=f"{pro_user_id}:{niche_id}",
        action="niche_skill_override_set",
        reason=note,
        metadata=_override_view(skill),
    )
    db.flush()
    enqueue_pro_index_upsert(db, pro_user_id, idempotency_suffix="admin_override")
    return skill


def remove_niche_skill_override(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID,
    reason: str,
    actor_user_id: uuid.UUID,
) -> ProNicheSkill:
    """Remove an admin's override. The evidence takes over at once - removing
    a decision is not a tier change hysteresis should hold back."""
    skill = db.execute(select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id)).scalar_one_or_none()
    if skill is None or not any(v is not None for v in (skill.override_tier, skill.override_score, skill.override_verified)):
        raise APIError(code="not_found", message="No override to remove", status_code=404)
    removed = _override_view(skill)
    before_tier, before_score = skill.tier, skill.score
    for column in ("override_tier", "override_score", "override_verified", "override_by", "override_at", "override_reason"):
        setattr(skill, column, None)
    db.flush()
    skill = recompute_pro_niche_skill(
        db, pro_user_id, niche_id, actor_type=ProNicheSkillActorType.admin, actor_user_id=actor_user_id
    )
    _create_skill_event(
        db,
        pro_user_id=pro_user_id,
        niche_id=niche_id,
        event_type=ProNicheSkillEventType.override_removed,
        from_tier=before_tier.value,
        to_tier=skill.tier.value,
        score_before=before_score,
        score_after=skill.score,
        reasons={"note": reason, "removed": removed},
        actor_type=ProNicheSkillActorType.admin,
        actor_user_id=actor_user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor_user_id,
        target_type="pro_niche_skill",
        target_id=f"{pro_user_id}:{niche_id}",
        action="niche_skill_override_removed",
        reason=reason,
        metadata={"removed": removed, "tier_now": skill.tier.value},
    )
    db.flush()
    return skill


def order_niches(rows, primary_niche_ids) -> list:
    """(skill, niche) pairs, strongest first; ties to the photographer's own
    primary niche, then by niche id - never left to the order the database
    returned them in."""
    return sorted(
        rows,
        key=lambda item: (
            -TIER_RANK.get(item[0].tier, 0),
            -int(item[0].score or 0),
            -float(item[0].avg_rating or 0),
            -int(item[0].gigs_completed or 0),
            item[1].id not in primary_niche_ids,
            str(item[1].id),
        ),
    )


def get_top_niches_for_index(db: Session, pro_user_id: uuid.UUID, limit: int = 3) -> list[dict[str, Any]]:
    rows = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == pro_user_id)
    ).all()
    # Ties - common: a photographer's unworked niches all score zero - go
    # to the niche they chose as their primary, then by niche id. Without
    # this the order was the database's physical row order, which moves
    # whenever a row is rewritten, so the primary niche (and the niche row a
    # photographer is guaranteed a place in) could change on any recompute.
    primary = set(
        db.execute(select(ProNiche.niche_id).where(ProNiche.pro_user_id == pro_user_id, ProNiche.is_primary.is_(True))).scalars()
    )
    top = order_niches(rows, primary)[:limit]
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
    current: SkillTier,
    target_tier: SkillTier,
    now: datetime,
    bypass: bool,
) -> tuple[SkillTier, bool]:
    """The evidence tier, held where it was if it last changed - either way -
    within HYSTERESIS_DAYS: one review or one dispute must not flip a tier
    back and forth."""
    if bypass or TIER_RANK.get(target_tier, 0) == TIER_RANK.get(current, 0):
        return target_tier, False
    changes = [t for t in (skill.last_promotion_at, skill.last_demotion_at) if t is not None]
    if changes and now - max(changes) < timedelta(days=HYSTERESIS_DAYS):
        return current, True
    return target_tier, False


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
