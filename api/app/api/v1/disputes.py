from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db_session, require_not_banned
from app.core.errors import APIError
from app.models.admin import Dispute, DisputeEvidence, DisputeStatus, EvidenceKind, UserRoleType
from app.models.gig import Gig, GigStatus, GigTransition
from app.models.media import MediaAsset, MediaVisibility
from app.schemas.admin import (
    DisputeCreateRequest,
    DisputeEvidenceCreateRequest,
    DisputeEvidenceView,
    DisputeView,
)
from app.schemas.media import CurrentUser
from app.services.authz import ensure_user_account, get_user_roles
from app.services.discovery_index import recompute_pro_public_index
from app.services.niche_skills import recompute_pro_niche_skills

router = APIRouter(prefix="/disputes", tags=["disputes"])


@router.post("", response_model=DisputeView)
def create_dispute(
    body: DisputeCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeView:
    ensure_user_account(db, user.user_id)

    gig = db.get(Gig, body.gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if user.user_id not in {gig.client_user_id, gig.pro_user_id}:
        raise APIError(code="forbidden", message="Only gig participants can open disputes", status_code=403)

    if gig.status not in {GigStatus.paid, GigStatus.disputed, GigStatus.refunded, GigStatus.completed, GigStatus.final_delivered}:
        raise APIError(code="invalid_state", message="Disputes can be opened only for paid or later gigs", status_code=409)

    dispute = Dispute(
        gig_id=gig.id,
        opened_by_user_id=user.user_id,
        status=DisputeStatus.open,
        category=body.category,
        summary=body.summary,
    )
    db.add(dispute)

    if gig.status != GigStatus.disputed:
        transition = GigTransition(
            gig_id=gig.id,
            from_status=gig.status,
            to_status=GigStatus.disputed,
            actor_user_id=user.user_id,
            reason="Dispute opened",
        )
        gig.status = GigStatus.disputed
        db.add(transition)

    recompute_pro_public_index(db, gig.pro_user_id)
    if gig.niche_id:
        recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
    db.commit()
    db.refresh(dispute)
    return _dispute_to_view(dispute)


@router.post("/{dispute_id}/evidence", response_model=DisputeEvidenceView)
def add_dispute_evidence(
    dispute_id: uuid.UUID,
    body: DisputeEvidenceCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeEvidenceView:
    ensure_user_account(db, user.user_id)

    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)

    gig = db.get(Gig, dispute.gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)

    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    if not is_admin and user.user_id not in {gig.client_user_id, gig.pro_user_id}:
        raise APIError(code="forbidden", message="Only participants or admin can submit evidence", status_code=403)

    if body.kind == EvidenceKind.text:
        if not body.text:
            raise APIError(code="validation_error", message="Text evidence requires text", status_code=422)
    elif body.kind == EvidenceKind.media:
        if not body.media_asset_id:
            raise APIError(code="validation_error", message="Media evidence requires media_asset_id", status_code=422)
        asset = db.get(MediaAsset, body.media_asset_id)
        if not asset:
            raise APIError(code="not_found", message="Media asset not found", status_code=404)
        if asset.visibility != MediaVisibility.owner_only:
            raise APIError(code="validation_error", message="Only owner_only media can be attached as evidence", status_code=422)
        if not is_admin and asset.owner_user_id != user.user_id:
            raise APIError(code="forbidden", message="Cannot attach media owned by another user", status_code=403)
    else:
        raise APIError(code="validation_error", message="Unsupported evidence kind", status_code=422)

    evidence = DisputeEvidence(
        dispute_id=dispute.id,
        submitted_by_user_id=user.user_id,
        kind=body.kind,
        text=body.text,
        media_asset_id=body.media_asset_id,
    )
    db.add(evidence)
    db.commit()
    db.refresh(evidence)

    return DisputeEvidenceView(
        id=evidence.id,
        dispute_id=evidence.dispute_id,
        submitted_by_user_id=evidence.submitted_by_user_id,
        kind=evidence.kind,
        text=evidence.text,
        media_asset_id=evidence.media_asset_id,
        created_at=evidence.created_at,
    )


def _dispute_to_view(dispute: Dispute) -> DisputeView:
    return DisputeView(
        id=dispute.id,
        gig_id=dispute.gig_id,
        opened_by_user_id=dispute.opened_by_user_id,
        status=dispute.status,
        category=dispute.category,
        summary=dispute.summary,
        resolution_note=dispute.resolution_note,
        created_at=dispute.created_at,
        updated_at=dispute.updated_at,
    )
