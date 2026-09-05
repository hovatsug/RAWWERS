from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, get_locale, require_admin, require_not_banned
from app.models.gamification import Milestone, MilestoneCompletion, MilestoneProgress, ProCredential
from app.schemas.gamification import (
    AdminCycleUpsertRequest,
    AdminMilestoneUpsertRequest,
    AdminRecomputeRequest,
    CredentialView,
    CurrentCycleResponse,
    CycleEventView,
    CyclePointsView,
    MilestoneProgressView,
    MilestoneView,
    MyMilestoneItem,
    MyMilestonesResponse,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.gamification import (
    evaluate_user_milestones,
    get_current_cycle_payload,
    recompute_credentials,
    upsert_milestone,
    upsert_performance_cycle,
)
from app.services.i18n import t

router = APIRouter(tags=["gamification"])


@router.get("/me/gamification/credentials", response_model=list[CredentialView])
def my_credentials(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[CredentialView]:
    rows = db.execute(
        select(ProCredential)
        .where(ProCredential.pro_user_id == user.user_id)
        .order_by(ProCredential.awarded_at.desc())
    ).scalars().all()
    db.commit()
    return [CredentialView.model_validate(row, from_attributes=True) for row in rows]


@router.get("/me/gamification/milestones", response_model=MyMilestonesResponse)
@router.get("/me/game/quests", response_model=MyMilestonesResponse)
def my_milestones(
    user: CurrentUser = Depends(require_not_banned),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_session),
) -> MyMilestonesResponse:
    evaluate_user_milestones(db, user.user_id)
    milestones = db.execute(select(Milestone).order_by(Milestone.created_at.desc())).scalars().all()
    items: list[MyMilestoneItem] = []
    for milestone in milestones:
        progress = db.execute(
            select(MilestoneProgress).where(MilestoneProgress.milestone_id == milestone.id, MilestoneProgress.user_id == user.user_id)
        ).scalar_one_or_none()
        if not progress:
            continue
        completion_info = db.execute(
            select(func.count(MilestoneCompletion.id), func.max(MilestoneCompletion.completed_at)).where(
                MilestoneCompletion.milestone_id == milestone.id,
                MilestoneCompletion.user_id == user.user_id,
            )
        ).one()
        items.append(
            MyMilestoneItem(
                milestone=_localized_milestone_view(db, milestone, locale=locale),
                progress=MilestoneProgressView(
                    milestone_id=progress.milestone_id,
                    status=progress.status,
                    progress_value=progress.progress_value,
                    progress_meta=progress.progress_meta or {},
                    started_at=progress.started_at,
                    completed_at=progress.completed_at,
                    last_evaluated_at=progress.last_evaluated_at,
                    completions_count=int(completion_info[0] or 0),
                    last_completed_at=completion_info[1],
                ),
            )
        )
    db.commit()
    return MyMilestonesResponse(total=len(items), items=items)


@router.get("/me/gamification/cycle/current", response_model=CurrentCycleResponse)
@router.get("/me/game/seasons/current", response_model=CurrentCycleResponse)
def my_current_cycle(
    user: CurrentUser = Depends(require_not_banned),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_session),
) -> CurrentCycleResponse:
    payload = get_current_cycle_payload(db, user.user_id)
    db.commit()
    return CurrentCycleResponse(
        cycle_id=payload["cycle_id"],
        code=payload["code"],
        name=_localized_cycle_name(db, payload["name"], payload.get("name_key"), locale=locale),
        name_key=payload.get("name_key"),
        start_at=payload["start_at"],
        end_at=payload["end_at"],
        my_points=payload["my_points"],
        leaderboard=[CyclePointsView.model_validate(item, from_attributes=True) for item in payload["leaderboard"]],
        recent_events=[CycleEventView.model_validate(item, from_attributes=True) for item in payload["recent_events"]],
    )


@router.post("/admin/gamification/milestones", response_model=MilestoneView)
@router.put("/admin/gamification/milestones", response_model=MilestoneView)
def admin_upsert_milestone(
    body: AdminMilestoneUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> MilestoneView:
    milestone = upsert_milestone(db, body.model_dump(), actor_user_id=actor.user_id)
    db.commit()
    db.refresh(milestone)
    return MilestoneView.model_validate(milestone, from_attributes=True)


@router.post("/admin/gamification/cycles", response_model=CurrentCycleResponse)
@router.put("/admin/gamification/cycles", response_model=CurrentCycleResponse)
def admin_upsert_cycle(
    body: AdminCycleUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CurrentCycleResponse:
    cycle = upsert_performance_cycle(db, body.model_dump(), actor_user_id=actor.user_id)
    db.commit()
    return CurrentCycleResponse(
        cycle_id=cycle.id,
        code=cycle.code,
        name=cycle.name,
        name_key=cycle.name_key,
        start_at=cycle.start_at,
        end_at=cycle.end_at,
        my_points=0,
        leaderboard=[],
        recent_events=[],
    )


def _localized_milestone_view(db: Session, milestone: Milestone, *, locale: str) -> MilestoneView:
    name = milestone.name
    description = milestone.description
    if milestone.name_key:
        translated = t(db, milestone.name_key, locale=locale, namespace="gamification")
        if translated != milestone.name_key:
            name = translated
    if milestone.description_key:
        translated = t(db, milestone.description_key, locale=locale, namespace="gamification")
        if translated != milestone.description_key:
            description = translated
    return MilestoneView(
        id=milestone.id,
        code=milestone.code,
        name=name,
        description=description,
        name_key=milestone.name_key,
        description_key=milestone.description_key,
        scope=milestone.scope,
        niche_id=milestone.niche_id,
        difficulty=milestone.difficulty,
        audience=milestone.audience,
        is_repeatable=milestone.is_repeatable,
        cooldown_days=milestone.cooldown_days,
        start_at=milestone.start_at,
        end_at=milestone.end_at,
        criteria=milestone.criteria or {},
        reward_rule_code=milestone.reward_rule_code,
        is_active=milestone.is_active,
        created_at=milestone.created_at,
        updated_at=milestone.updated_at,
    )


def _localized_cycle_name(db: Session, base_name: str | None, name_key: str | None, *, locale: str) -> str | None:
    if not name_key:
        return base_name
    translated = t(db, name_key, locale=locale, namespace="gamification")
    if translated == name_key:
        return base_name
    return translated


@router.post("/admin/gamification/recompute")
def admin_gamification_recompute(
    body: AdminRecomputeRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    credentials_awarded = 0
    milestones_completed = 0
    if body.recompute_credentials:
        credentials_awarded = recompute_credentials(db, body.pro_user_id, body.niche_id)
    if body.evaluate_milestones:
        milestones_completed = evaluate_user_milestones(db, body.pro_user_id, body.niche_id)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="gamification",
        target_id=str(body.pro_user_id),
        action="gamification_recompute",
        metadata={
            "niche_id": str(body.niche_id) if body.niche_id else None,
            "evaluate_milestones": body.evaluate_milestones,
            "recompute_credentials": body.recompute_credentials,
        },
    )
    db.commit()
    return {
        "ok": True,
        "pro_user_id": str(body.pro_user_id),
        "credentials_awarded": credentials_awarded,
        "milestones_completed": milestones_completed,
    }
