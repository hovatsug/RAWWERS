from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.schemas.media import CurrentUser
from app.schemas.risk import (
    AdminRiskClearActionRequest,
    AdminRiskSetScoreRequest,
    AdminRiskUserDetailResponse,
    AdminRiskUserListResponse,
    DeviceSignalView,
    IpSignalView,
    RiskActionView,
    RiskEventView,
    RiskProfileView,
    RiskRuleUpsertRequest,
    RiskRuleView,
    SessionSignalView,
)
from app.services.audit import add_admin_audit_log
from app.services.trust_safety import (
    clear_risk_action,
    get_risk_user_detail,
    list_risk_profiles,
    list_risk_rules,
    put_risk_rule,
    set_risk_score_manual,
)
from app.models.risk import RiskLevel

router = APIRouter(tags=["trust_safety"])


@router.get("/admin/risk/users", response_model=AdminRiskUserListResponse)
def admin_list_risk_users(
    level: RiskLevel | None = Query(default=None),
    score_min: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminRiskUserListResponse:
    rows = list_risk_profiles(db, level=level, score_min=score_min, limit=limit)
    db.commit()
    return AdminRiskUserListResponse(items=[RiskProfileView.model_validate(row, from_attributes=True) for row in rows])


@router.get("/admin/risk/users/{user_id}", response_model=AdminRiskUserDetailResponse)
def admin_get_risk_user(
    user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminRiskUserDetailResponse:
    payload = get_risk_user_detail(db, user_id=user_id)
    db.commit()
    return AdminRiskUserDetailResponse(
        profile=RiskProfileView.model_validate(payload["profile"], from_attributes=True),
        events=[RiskEventView.model_validate(item, from_attributes=True) for item in payload["events"]],
        actions=[RiskActionView.model_validate(item, from_attributes=True) for item in payload["actions"]],
        devices=[DeviceSignalView.model_validate(item, from_attributes=True) for item in payload["devices"]],
        sessions=[SessionSignalView.model_validate(item, from_attributes=True) for item in payload["sessions"]],
        ips=[IpSignalView.model_validate(item, from_attributes=True) for item in payload["ips"]],
    )


@router.post("/admin/risk/users/{user_id}/clear-action", response_model=AdminRiskUserDetailResponse)
def admin_clear_risk_action(
    user_id: uuid.UUID,
    body: AdminRiskClearActionRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminRiskUserDetailResponse:
    clear_risk_action(db, user_id=user_id, action_type=body.action_type)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="risk_action",
        target_id=f"{user_id}:{body.action_type.value}",
        action="risk_action_cleared",
        reason=body.note,
        metadata={"user_id": str(user_id), "action_type": body.action_type.value},
    )
    payload = get_risk_user_detail(db, user_id=user_id)
    db.commit()
    return AdminRiskUserDetailResponse(
        profile=RiskProfileView.model_validate(payload["profile"], from_attributes=True),
        events=[RiskEventView.model_validate(item, from_attributes=True) for item in payload["events"]],
        actions=[RiskActionView.model_validate(item, from_attributes=True) for item in payload["actions"]],
        devices=[DeviceSignalView.model_validate(item, from_attributes=True) for item in payload["devices"]],
        sessions=[SessionSignalView.model_validate(item, from_attributes=True) for item in payload["sessions"]],
        ips=[IpSignalView.model_validate(item, from_attributes=True) for item in payload["ips"]],
    )


@router.post("/admin/risk/users/{user_id}/set-score", response_model=RiskProfileView)
def admin_set_risk_score(
    user_id: uuid.UUID,
    body: AdminRiskSetScoreRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RiskProfileView:
    row = set_risk_score_manual(db, user_id=user_id, score=body.score, note=body.note)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="risk_profile",
        target_id=str(user_id),
        action="risk_score_set",
        reason=body.note,
        metadata={"score": int(body.score)},
    )
    db.commit()
    return RiskProfileView.model_validate(row, from_attributes=True)


@router.get("/admin/risk/rules", response_model=list[RiskRuleView])
def admin_list_risk_rules(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RiskRuleView]:
    rows = list_risk_rules(db)
    db.commit()
    return [RiskRuleView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/admin/risk/rules/{rule_id}", response_model=RiskRuleView)
def admin_put_risk_rule(
    rule_id: str,
    body: RiskRuleUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RiskRuleView:
    row = put_risk_rule(
        db,
        rule_id=rule_id,
        is_active=body.is_active,
        params=body.params,
        score_delta=body.score_delta,
        action_on_trigger=body.action_on_trigger,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="risk_rule",
        target_id=rule_id,
        action="risk_rule_upsert",
        metadata={
            "is_active": body.is_active,
            "score_delta": body.score_delta,
            "params": body.params,
            "action_on_trigger": body.action_on_trigger,
        },
    )
    db.commit()
    return RiskRuleView.model_validate(row, from_attributes=True)
