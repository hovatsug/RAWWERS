from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Any

from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import Dispute
from app.models.discovery import ProPublicIndex
from app.models.gamification import (
    CredentialMode,
    CycleEvent,
    CyclePoints,
    Milestone,
    MilestoneCompletion,
    MilestoneDifficulty,
    MilestoneProgress,
    MilestoneProgressStatus,
    MilestoneScope,
    PerformanceCycle,
    ProCredential,
)
from app.models.gig import Gig, GigStatus
from app.models.learning import Certificate
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.rewards import issue_reward

TIER_RANK: dict[SkillTier, int] = {
    SkillTier.rookie: 0,
    SkillTier.skilled: 1,
    SkillTier.pro: 2,
    SkillTier.elite: 3,
    SkillTier.master: 4,
}

DIFFICULTY_POINTS: dict[MilestoneDifficulty, int] = {
    MilestoneDifficulty.standard: 50,
    MilestoneDifficulty.advanced: 100,
    MilestoneDifficulty.elite: 200,
}


def queue_evaluate_user_milestones(user_id: uuid.UUID, niche_id: uuid.UUID | None = None) -> None:
    from app.tasks.gamification_tasks import evaluate_user_milestones_task

    try:
        evaluate_user_milestones_task.delay(str(user_id), str(niche_id) if niche_id else None)
    except Exception:
        return


def queue_recompute_credentials(user_id: uuid.UUID, niche_id: uuid.UUID | None = None) -> None:
    from app.tasks.gamification_tasks import recompute_credentials_task

    try:
        recompute_credentials_task.delay(str(user_id), str(niche_id) if niche_id else None)
    except Exception:
        return


def recompute_credentials(db: Session, pro_user_id: uuid.UUID, niche_id: uuid.UUID | None = None) -> int:
    stmt = select(ProNicheSkill, Niche).join(Niche, Niche.id == ProNicheSkill.niche_id).where(ProNicheSkill.pro_user_id == pro_user_id)
    if niche_id:
        stmt = stmt.where(ProNicheSkill.niche_id == niche_id)
    rows = db.execute(stmt).all()
    now = datetime.now(timezone.utc)
    awarded = 0

    for skill, niche in rows:
        display_name = f"{skill.tier.value.title()} {niche.name} Specialist"
        code = f"{niche.slug}.{skill.tier.value}"

        current_rows = db.execute(
            select(ProCredential).where(
                ProCredential.pro_user_id == pro_user_id,
                ProCredential.niche_id == niche.id,
                ProCredential.mode == CredentialMode.current,
            )
        ).scalars().all()
        existing_current = next((row for row in current_rows if row.tier == skill.tier), None)
        if not existing_current:
            for row in current_rows:
                db.delete(row)
            new_current = ProCredential(
                pro_user_id=pro_user_id,
                niche_id=niche.id,
                credential_code=code,
                display_name=display_name,
                tier=skill.tier,
                mode=CredentialMode.current,
                awarded_at=now,
                meta={"source": "pro_niche_skill"},
            )
            db.add(new_current)
            awarded += 1
            log_event(
                db,
                event_name="credential.awarded",
                user_id=pro_user_id,
                properties={"niche_id": str(niche.id), "tier": skill.tier.value, "mode": CredentialMode.current.value},
            )

        highest_rows = db.execute(
            select(ProCredential).where(
                ProCredential.pro_user_id == pro_user_id,
                ProCredential.niche_id == niche.id,
                ProCredential.mode == CredentialMode.highest_ever,
            )
        ).scalars().all()
        highest = max(highest_rows, key=lambda row: TIER_RANK.get(row.tier, -1), default=None)
        if not highest or TIER_RANK[skill.tier] > TIER_RANK[highest.tier]:
            for row in highest_rows:
                db.delete(row)
            db.add(
                ProCredential(
                    pro_user_id=pro_user_id,
                    niche_id=niche.id,
                    credential_code=code,
                    display_name=display_name,
                    tier=skill.tier,
                    mode=CredentialMode.highest_ever,
                    awarded_at=now,
                    meta={"source": "pro_niche_skill"},
                )
            )
            awarded += 1
            log_event(
                db,
                event_name="credential.awarded",
                user_id=pro_user_id,
                properties={"niche_id": str(niche.id), "tier": skill.tier.value, "mode": CredentialMode.highest_ever.value},
            )
    db.flush()
    return awarded


def upsert_milestone(db: Session, body: dict[str, Any], actor_user_id: uuid.UUID | None = None) -> Milestone:
    code = str(body.get("code", "")).strip()
    try:
        scope = MilestoneScope(body.get("scope"))
        difficulty = MilestoneDifficulty(body.get("difficulty"))
    except ValueError as exc:
        raise APIError(code="validation_error", message="Invalid scope or difficulty", status_code=422) from exc
    if not code:
        raise APIError(code="validation_error", message="Milestone code is required", status_code=422)
    if scope == MilestoneScope.niche and not body.get("niche_id"):
        raise APIError(code="validation_error", message="niche_id is required for niche scope", status_code=422)
    if body.get("end_at") and body.get("start_at") and body["end_at"] <= body["start_at"]:
        raise APIError(code="validation_error", message="end_at must be after start_at", status_code=422)
    _validate_criteria(body.get("criteria"))

    milestone = db.execute(select(Milestone).where(Milestone.code == code)).scalar_one_or_none()
    if not milestone:
        milestone = Milestone(code=code, name=code, description="", scope=MilestoneScope.global_scope, difficulty=MilestoneDifficulty.standard, criteria={})
        db.add(milestone)
        db.flush()

    milestone.name = body["name"]
    milestone.description = body["description"]
    milestone.scope = scope
    milestone.niche_id = body.get("niche_id")
    milestone.difficulty = difficulty
    milestone.is_repeatable = bool(body.get("is_repeatable", False))
    milestone.cooldown_days = body.get("cooldown_days")
    milestone.start_at = body.get("start_at")
    milestone.end_at = body.get("end_at")
    milestone.criteria = body["criteria"] or {}
    milestone.reward_rule_code = body.get("reward_rule_code")
    milestone.is_active = bool(body.get("is_active", True))
    milestone.updated_at = datetime.now(timezone.utc)
    db.flush()

    if actor_user_id:
        add_admin_audit_log(
            db,
            actor_user_id=actor_user_id,
            target_type="milestone",
            target_id=str(milestone.id),
            action="milestone_upsert",
            metadata={"code": milestone.code},
        )
    return milestone


def upsert_performance_cycle(db: Session, body: dict[str, Any], actor_user_id: uuid.UUID | None = None) -> PerformanceCycle:
    code = str(body.get("code", "")).strip()
    if not code:
        raise APIError(code="validation_error", message="Cycle code is required", status_code=422)
    if body["end_at"] <= body["start_at"]:
        raise APIError(code="validation_error", message="end_at must be after start_at", status_code=422)

    cycle = db.execute(select(PerformanceCycle).where(PerformanceCycle.code == code)).scalar_one_or_none()
    if not cycle:
        cycle = PerformanceCycle(code=code, name=code, start_at=body["start_at"], end_at=body["end_at"], meta={})
        db.add(cycle)
        db.flush()

    cycle.name = body["name"]
    cycle.start_at = body["start_at"]
    cycle.end_at = body["end_at"]
    cycle.is_active = bool(body.get("is_active", True))
    cycle.meta = body.get("metadata") or {}
    cycle.updated_at = datetime.now(timezone.utc)
    db.flush()

    if actor_user_id:
        add_admin_audit_log(
            db,
            actor_user_id=actor_user_id,
            target_type="performance_cycle",
            target_id=str(cycle.id),
            action="performance_cycle_upsert",
            metadata={"code": cycle.code},
        )
    return cycle


def evaluate_user_milestones(
    db: Session,
    user_id: uuid.UUID,
    niche_id: uuid.UUID | None = None,
) -> int:
    now = datetime.now(timezone.utc)
    all_active = db.execute(
        select(Milestone).where(
            Milestone.is_active.is_(True),
            or_(Milestone.start_at.is_(None), Milestone.start_at <= now),
            or_(Milestone.end_at.is_(None), Milestone.end_at >= now),
        )
    ).scalars().all()
    milestones = [
        row
        for row in all_active
        if row.scope == MilestoneScope.global_scope or (row.scope == MilestoneScope.niche and (not niche_id or row.niche_id == niche_id))
    ]

    completed_count = 0
    for milestone in milestones:
        if niche_id and milestone.scope == MilestoneScope.niche and milestone.niche_id != niche_id:
            continue
        progress = db.execute(
            select(MilestoneProgress).where(MilestoneProgress.milestone_id == milestone.id, MilestoneProgress.user_id == user_id)
        ).scalar_one_or_none()
        if not progress:
            progress = MilestoneProgress(milestone_id=milestone.id, user_id=user_id, status=MilestoneProgressStatus.active, progress_meta={})
            db.add(progress)
            db.flush()

        evaluation = _evaluate_milestone_criteria(db, user_id, milestone)
        progress.progress_value = evaluation["progress_value"]
        progress.progress_meta = evaluation["progress_meta"]
        progress.last_evaluated_at = now
        if progress.status == MilestoneProgressStatus.expired:
            progress.status = MilestoneProgressStatus.active

        if evaluation["achieved"] and _is_completion_allowed(db, user_id, milestone, now):
            completion = MilestoneCompletion(
                milestone_id=milestone.id,
                user_id=user_id,
                completed_at=now,
                meta={"criteria": milestone.criteria},
            )
            db.add(completion)
            db.flush()

            progress.status = MilestoneProgressStatus.completed
            progress.completed_at = now
            completed_count += 1

            reward_entry = None
            if milestone.reward_rule_code:
                reward_entry = issue_reward(
                    db,
                    user_id=user_id,
                    rule_code=milestone.reward_rule_code,
                    reference_type="milestone_completion",
                    reference_id=str(completion.id),
                    metadata={"milestone_id": str(milestone.id), "milestone_code": milestone.code},
                )
                if reward_entry:
                    completion.reward_ledger_entry_id = reward_entry.id

            cycle_points = int((milestone.criteria or {}).get("cycle_points", DIFFICULTY_POINTS[milestone.difficulty]))
            if cycle_points > 0:
                add_cycle_points(
                    db,
                    user_id=user_id,
                    event_type="milestone_completed",
                    points_delta=cycle_points,
                    reference_type="milestone",
                    reference_id=str(completion.id),
                    event_time=now,
                )

            log_event(
                db,
                event_name="milestone.completed",
                user_id=user_id,
                properties={
                    "milestone_id": str(milestone.id),
                    "milestone_code": milestone.code,
                    "reward_issued": bool(completion.reward_ledger_entry_id),
                },
            )
        elif evaluation["achieved"]:
            progress.status = MilestoneProgressStatus.completed
            progress.completed_at = progress.completed_at or now
        else:
            progress.status = MilestoneProgressStatus.active
            if milestone.is_repeatable:
                progress.completed_at = None
    db.flush()
    return completed_count


def add_cycle_points(
    db: Session,
    user_id: uuid.UUID,
    event_type: str,
    points_delta: int,
    reference_type: str | None = None,
    reference_id: str | None = None,
    event_time: datetime | None = None,
) -> int:
    when = event_time or datetime.now(timezone.utc)
    if points_delta == 0:
        return 0
    cycles = db.execute(
        select(PerformanceCycle).where(
            PerformanceCycle.is_active.is_(True),
            PerformanceCycle.start_at <= when,
            PerformanceCycle.end_at >= when,
        )
    ).scalars().all()
    if not cycles:
        return 0

    total_added = 0
    for cycle in cycles:
        dedupe = db.execute(
            select(CycleEvent).where(
                CycleEvent.cycle_id == cycle.id,
                CycleEvent.user_id == user_id,
                CycleEvent.event_type == event_type,
                CycleEvent.reference_type == reference_type,
                CycleEvent.reference_id == reference_id,
            )
        ).scalar_one_or_none()
        if dedupe:
            continue

        row = db.execute(
            select(CyclePoints).where(CyclePoints.cycle_id == cycle.id, CyclePoints.user_id == user_id)
        ).scalar_one_or_none()
        if not row:
            row = CyclePoints(cycle_id=cycle.id, user_id=user_id, points=0)
            db.add(row)
            db.flush()
        row.points += points_delta
        row.updated_at = when
        db.add(
            CycleEvent(
                cycle_id=cycle.id,
                user_id=user_id,
                event_type=event_type,
                points_delta=points_delta,
                reference_type=reference_type,
                reference_id=reference_id,
                created_at=when,
            )
        )
        total_added += points_delta
        log_event(
            db,
            event_name="cycle.points_added",
            user_id=user_id,
            properties={"cycle_id": str(cycle.id), "event_type": event_type, "points_delta": points_delta},
        )
    db.flush()
    return total_added


def get_current_cycle_payload(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    now = datetime.now(timezone.utc)
    cycle = db.execute(
        select(PerformanceCycle)
        .where(
            PerformanceCycle.is_active.is_(True),
            PerformanceCycle.start_at <= now,
            PerformanceCycle.end_at >= now,
        )
        .order_by(PerformanceCycle.start_at.desc())
    ).scalar_one_or_none()

    if not cycle:
        return {
            "cycle_id": None,
            "code": None,
            "name": None,
            "start_at": None,
            "end_at": None,
            "my_points": 0,
            "leaderboard": [],
            "recent_events": [],
        }

    my_points = db.execute(
        select(CyclePoints.points).where(CyclePoints.cycle_id == cycle.id, CyclePoints.user_id == user_id)
    ).scalar_one_or_none() or 0
    leaderboard = db.execute(
        select(CyclePoints).where(CyclePoints.cycle_id == cycle.id).order_by(CyclePoints.points.desc()).limit(20)
    ).scalars().all()
    recent_events = db.execute(
        select(CycleEvent)
        .where(CycleEvent.cycle_id == cycle.id, CycleEvent.user_id == user_id)
        .order_by(CycleEvent.created_at.desc())
        .limit(20)
    ).scalars().all()
    return {
        "cycle_id": cycle.id,
        "code": cycle.code,
        "name": cycle.name,
        "start_at": cycle.start_at,
        "end_at": cycle.end_at,
        "my_points": my_points,
        "leaderboard": leaderboard,
        "recent_events": recent_events,
    }


def _validate_criteria(criteria: dict | None) -> None:
    if not isinstance(criteria, dict):
        raise APIError(code="validation_error", message="criteria must be an object", status_code=422)
    criteria_type = criteria.get("type")
    allowed = {
        "gig_count_completed",
        "delivery_sla_streak",
        "dispute_free_streak",
        "response_time_avg",
        "course_completion",
        "tier_reached",
    }
    if criteria_type not in allowed:
        raise APIError(code="validation_error", message="Unsupported criteria type", status_code=422)


def _is_completion_allowed(db: Session, user_id: uuid.UUID, milestone: Milestone, now: datetime) -> bool:
    latest = db.execute(
        select(MilestoneCompletion)
        .where(MilestoneCompletion.milestone_id == milestone.id, MilestoneCompletion.user_id == user_id)
        .order_by(MilestoneCompletion.completed_at.desc())
    ).scalars().first()
    if not latest:
        return True
    if not milestone.is_repeatable:
        return False
    cooldown_days = int(milestone.cooldown_days or 0)
    if cooldown_days <= 0:
        return True
    return latest.completed_at + timedelta(days=cooldown_days) <= now


def _evaluate_milestone_criteria(db: Session, user_id: uuid.UUID, milestone: Milestone) -> dict[str, Any]:
    criteria = milestone.criteria or {}
    criteria_type = criteria.get("type")
    if criteria_type == "gig_count_completed":
        return _eval_gig_count_completed(db, user_id, milestone, criteria)
    if criteria_type == "delivery_sla_streak":
        return _eval_delivery_sla_streak(db, user_id, milestone, criteria)
    if criteria_type == "dispute_free_streak":
        return _eval_dispute_free_streak(db, user_id, milestone, criteria)
    if criteria_type == "response_time_avg":
        return _eval_response_time_avg(db, user_id, criteria)
    if criteria_type == "course_completion":
        return _eval_course_completion(db, user_id, milestone, criteria)
    if criteria_type == "tier_reached":
        return _eval_tier_reached(db, user_id, milestone, criteria)
    return {"achieved": False, "progress_value": Decimal("0"), "progress_meta": {"error": "unsupported"}}


def _base_gig_scope_query(user_id: uuid.UUID, milestone: Milestone):
    query = select(Gig).where(Gig.pro_user_id == user_id, Gig.status == GigStatus.completed)
    if milestone.scope == MilestoneScope.niche and milestone.niche_id:
        query = query.where(Gig.niche_id == milestone.niche_id)
    return query


def _eval_gig_count_completed(db: Session, user_id: uuid.UUID, milestone: Milestone, criteria: dict[str, Any]) -> dict[str, Any]:
    target = int(criteria.get("count", 1))
    count = db.execute(
        select(func.count()).select_from(_base_gig_scope_query(user_id, milestone).subquery())
    ).scalar_one()
    return {
        "achieved": count >= target,
        "progress_value": Decimal(str(count)),
        "progress_meta": {"target": target, "current": count},
    }


def _is_gig_on_time(gig: Gig) -> bool:
    if not gig.scheduled_end:
        return False
    finals_sla_days = ((gig.meta or {}).get("pricing_snapshot") or {}).get("finals_sla_days", 7)
    try:
        finals_sla_days_int = int(finals_sla_days)
    except (TypeError, ValueError):
        finals_sla_days_int = 7
    deadline = gig.scheduled_end + timedelta(days=max(0, finals_sla_days_int))
    return gig.updated_at <= deadline


def _eval_delivery_sla_streak(db: Session, user_id: uuid.UUID, milestone: Milestone, criteria: dict[str, Any]) -> dict[str, Any]:
    target = int(criteria.get("streak", 1))
    gigs = db.execute(_base_gig_scope_query(user_id, milestone).order_by(Gig.updated_at.desc()).limit(max(target * 4, 50))).scalars().all()
    streak = 0
    for gig in gigs:
        if _is_gig_on_time(gig):
            streak += 1
        else:
            break
    return {
        "achieved": streak >= target,
        "progress_value": Decimal(str(streak)),
        "progress_meta": {"target": target, "current": streak},
    }


def _eval_dispute_free_streak(db: Session, user_id: uuid.UUID, milestone: Milestone, criteria: dict[str, Any]) -> dict[str, Any]:
    target = int(criteria.get("streak", 1))
    gigs = db.execute(_base_gig_scope_query(user_id, milestone).order_by(Gig.updated_at.desc()).limit(max(target * 4, 50))).scalars().all()
    streak = 0
    for gig in gigs:
        has_dispute = db.execute(select(Dispute.id).where(Dispute.gig_id == gig.id)).scalar_one_or_none() is not None
        if has_dispute:
            break
        streak += 1
    return {
        "achieved": streak >= target,
        "progress_value": Decimal(str(streak)),
        "progress_meta": {"target": target, "current": streak},
    }


def _eval_response_time_avg(db: Session, user_id: uuid.UUID, criteria: dict[str, Any]) -> dict[str, Any]:
    max_minutes = int(criteria.get("max_minutes", 60))
    index = db.get(ProPublicIndex, user_id)
    current = index.avg_response_minutes if index and index.avg_response_minutes is not None else None
    achieved = current is not None and current <= max_minutes
    return {
        "achieved": achieved,
        "progress_value": Decimal(str(current if current is not None else 0)),
        "progress_meta": {"max_minutes": max_minutes, "current": current},
    }


def _eval_course_completion(db: Session, user_id: uuid.UUID, milestone: Milestone, criteria: dict[str, Any]) -> dict[str, Any]:
    target_count = int(criteria.get("min_count", 1))
    course_ids: list[uuid.UUID] = []
    for item in criteria.get("course_ids", []):
        if not item:
            continue
        if isinstance(item, uuid.UUID):
            course_ids.append(item)
        else:
            course_ids.append(uuid.UUID(str(item)))
    query = select(Certificate).where(Certificate.user_id == user_id)
    if milestone.scope == MilestoneScope.niche and milestone.niche_id:
        query = query.where(Certificate.niche_id == milestone.niche_id)
    if course_ids:
        query = query.where(Certificate.course_id.in_(course_ids))
    completed = db.execute(select(func.count()).select_from(query.subquery())).scalar_one()
    if course_ids:
        achieved = completed == len(set(course_ids))
        target_count = len(set(course_ids))
    else:
        achieved = completed >= target_count
    return {
        "achieved": achieved,
        "progress_value": Decimal(str(completed)),
        "progress_meta": {"target": target_count, "current": completed},
    }


def _eval_tier_reached(db: Session, user_id: uuid.UUID, milestone: Milestone, criteria: dict[str, Any]) -> dict[str, Any]:
    try:
        target_tier = SkillTier(criteria.get("tier", SkillTier.skilled.value))
    except ValueError as exc:
        raise APIError(code="validation_error", message="Invalid tier in criteria", status_code=422) from exc
    query = select(ProNicheSkill).where(ProNicheSkill.pro_user_id == user_id)
    if milestone.scope == MilestoneScope.niche and milestone.niche_id:
        query = query.where(ProNicheSkill.niche_id == milestone.niche_id)
    rows = db.execute(query).scalars().all()
    best_rank = max((TIER_RANK.get(row.tier, -1) for row in rows), default=-1)
    achieved = best_rank >= TIER_RANK[target_tier]
    return {
        "achieved": achieved,
        "progress_value": Decimal(str(max(best_rank, 0))),
        "progress_meta": {"target_tier": target_tier.value, "current_rank": best_rank},
    }
