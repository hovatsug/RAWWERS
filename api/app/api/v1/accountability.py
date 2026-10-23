"""Findings: the photographer's own view, and the admin's.

Photographers see only their own findings - never anyone else's, never
public, never shown to clients. Admins record, decide, lift pauses, edit the
policy row and see how often each admin and each photographer appears.
"""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.accountability import AccountabilityPolicy, BookingPause, PhotographerFinding
from app.models.gig import Gig
from app.models.price_reduction import PriceReductionReason
from app.schemas.media import CurrentUser
from app.services import accountability as acc
from app.services.audit import add_admin_audit_log

router = APIRouter(tags=["accountability"])


class FindingView(BaseModel):
    id: str
    gig_id: str
    status: str
    reason: str
    note: str
    severe: bool
    created_at: str
    first_seen_at: str | None = None
    window_ends_at: str
    response: str | None = None
    decision_note: str | None = None
    consequence: str | None = None
    strike_number: int | None = None


class BookingPauseView(BaseModel):
    reason: str
    since: str


class MyFindingsResponse(BaseModel):
    strikes: int
    pause: BookingPauseView | None = None
    items: list[FindingView]


class ResponseIn(BaseModel):
    text: str = Field(min_length=1, max_length=4000)


class RecordIn(BaseModel):
    note: str
    severe: bool = False
    severe_note: str | None = None


class DecisionIn(BaseModel):
    decision: str
    note: str


class NoteIn(BaseModel):
    note: str


class PolicyIn(BaseModel):
    contest_window_days: int | None = Field(default=None, ge=1)
    unseen_grace_days: int | None = Field(default=None, ge=1)
    rolling_window_months: int | None = Field(default=None, ge=1)
    pause_at: int | None = Field(default=None, ge=1)
    suspension_review_at: int | None = Field(default=None, ge=1)


def _view(db: Session, finding: PhotographerFinding, rules: AccountabilityPolicy, *, admin: bool = False) -> dict:
    reason = db.get(PriceReductionReason, finding.reason_code)
    view = {
        "id": str(finding.id),
        "gig_id": str(finding.gig_id),
        "status": finding.status,
        "reason": reason.label if reason else finding.reason_code,
        "note": finding.note,
        "severe": finding.severe,
        "created_at": finding.created_at.isoformat(),
        "first_seen_at": finding.first_seen_at.isoformat() if finding.first_seen_at else None,
        "window_ends_at": acc.window_ends_at(finding, rules).isoformat(),
        "response": finding.response,
        "decision_note": finding.decision_note,
        "consequence": finding.consequence,
        "strike_number": finding.strike_number,
    }
    if admin:
        view.update({
            "pro_user_id": str(finding.pro_user_id), "recorded_by_user_id": str(finding.recorded_by_user_id),
            "severe_note": finding.severe_note, "decided_by_user_id": str(finding.decided_by_user_id) if finding.decided_by_user_id else None,
        })
    return view


def _pause_view(pause: BookingPause | None) -> dict | None:
    if pause is None:
        return None
    return {"reason": pause.reason, "since": pause.created_at.isoformat()}


def _own(db: Session, finding_id: uuid.UUID, user_id: uuid.UUID) -> PhotographerFinding:
    finding = db.get(PhotographerFinding, finding_id)
    if finding is None or finding.pro_user_id != user_id:
        raise APIError(code="not_found", message="Finding not found", status_code=404)
    return finding


# --- the photographer --------------------------------------------------------------------


@router.get("/pro/findings", response_model=MyFindingsResponse)
def my_findings(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> dict:
    rules = acc.policy(db)
    rows = db.execute(
        select(PhotographerFinding).where(PhotographerFinding.pro_user_id == user.user_id).order_by(PhotographerFinding.created_at.desc())
    ).scalars().all()
    body = {
        "strikes": acc.strikes(db, user.user_id),
        "pause": _pause_view(acc.active_pause(db, user.user_id)),
        "items": [_view(db, f, rules) for f in rows],
    }
    db.commit()
    return body


@router.post("/pro/findings/{finding_id}/seen", response_model=FindingView)
def mark_finding_seen(finding_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> dict:
    finding = _own(db, finding_id, user.user_id)
    acc.mark_seen(db, finding=finding, pro_user_id=user.user_id)
    db.commit()
    return _view(db, finding, acc.policy(db))


@router.post("/pro/findings/{finding_id}/response", response_model=FindingView)
def respond_to_finding(finding_id: uuid.UUID, body: ResponseIn, user: CurrentUser = Depends(require_not_banned),
                       db: Session = Depends(get_db_session)) -> dict:
    finding = _own(db, finding_id, user.user_id)
    acc.respond(db, finding=finding, pro_user_id=user.user_id, text=body.text)
    db.commit()
    return _view(db, finding, acc.policy(db))


# --- the admin ---------------------------------------------------------------------------


@router.post("/admin/gigs/{gig_id}/findings")
def record_finding(gig_id: uuid.UUID, body: RecordIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    gig = db.get(Gig, gig_id)
    if gig is None:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    finding = acc.record_finding(db, gig=gig, admin_user_id=actor.user_id, note=body.note, severe=body.severe, severe_note=body.severe_note)
    db.commit()
    return _view(db, finding, acc.policy(db), admin=True)


@router.get("/admin/pros/{pro_user_id}/findings")
def pro_findings(pro_user_id: uuid.UUID, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    rules = acc.policy(db)
    rows = db.execute(
        select(PhotographerFinding).where(PhotographerFinding.pro_user_id == pro_user_id).order_by(PhotographerFinding.created_at.desc())
    ).scalars().all()
    body = {
        "strikes": acc.strikes(db, pro_user_id),
        "pause": _pause_view(acc.active_pause(db, pro_user_id)),
        "items": [_view(db, f, rules, admin=True) for f in rows],
    }
    db.commit()
    return body


@router.post("/admin/findings/{finding_id}/decision")
def decide_finding(finding_id: uuid.UUID, body: DecisionIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    finding = db.get(PhotographerFinding, finding_id)
    if finding is None:
        raise APIError(code="not_found", message="Finding not found", status_code=404)
    acc.decide(db, finding=finding, admin_user_id=actor.user_id, decision=body.decision, note=body.note)
    db.commit()
    return _view(db, finding, acc.policy(db), admin=True)


@router.post("/admin/pros/{pro_user_id}/booking-pause/lift")
def lift_booking_pause(pro_user_id: uuid.UUID, body: NoteIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    acc.lift_pause(db, pro_user_id=pro_user_id, admin_user_id=actor.user_id, note=body.note)
    db.commit()
    return {"pro_user_id": str(pro_user_id), "paused": False}


@router.get("/admin/findings/stats")
def findings_stats(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    """How often each admin records findings, and each photographer appears -
    so a pattern of abuse is visible."""
    by_admin = db.execute(
        select(PhotographerFinding.recorded_by_user_id, func.count(), func.count().filter(PhotographerFinding.status == "withdrawn"))
        .group_by(PhotographerFinding.recorded_by_user_id).order_by(func.count().desc())
    ).all()
    by_pro = db.execute(
        select(PhotographerFinding.pro_user_id, func.count(), func.count().filter(PhotographerFinding.status == "confirmed"))
        .group_by(PhotographerFinding.pro_user_id).order_by(func.count().desc())
    ).all()
    return {
        "by_admin": [{"admin_user_id": str(a), "findings": n, "withdrawn": w} for a, n, w in by_admin],
        "by_photographer": [{"pro_user_id": str(p), "findings": n, "confirmed": c} for p, n, c in by_pro],
    }


def _policy_view(row: AccountabilityPolicy) -> dict:
    return {
        "contest_window_days": row.contest_window_days, "unseen_grace_days": row.unseen_grace_days,
        "rolling_window_months": row.rolling_window_months, "pause_at": row.pause_at, "suspension_review_at": row.suspension_review_at,
    }


@router.get("/admin/policies/accountability")
def get_policy(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    row = acc.policy(db)
    db.commit()
    return _policy_view(row)


@router.put("/admin/policies/accountability")
def put_policy(body: PolicyIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    row = acc.policy(db)
    before = _policy_view(row)
    changes = body.model_dump(exclude_none=True)
    for field, value in changes.items():
        setattr(row, field, value)
    if row.pause_at > row.suspension_review_at:
        raise APIError(code="validation_error", message="The pause must come before the suspension review", status_code=422)
    row.updated_by_user_id = actor.user_id
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="accountability_policy", target_id="1",
                        action="accountability_policy_updated", reason=None,
                        metadata={k: {"from": before[k], "to": v} for k, v in changes.items()})
    db.commit()
    return _policy_view(row)
