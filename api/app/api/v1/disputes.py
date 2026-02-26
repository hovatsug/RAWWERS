from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.errors import APIError
from app.models.admin import (
    Dispute,
    DisputeActorType,
    DisputeCategory,
    DisputeEvent,
    DisputeMessage,
    DisputeStatus,
    EvidenceKind,
    ProProfile,
    UserRoleType,
)
from app.models.client_rewards_pricing import ExtraImagePurchase
from app.models.gig import Gig, GigStatus, GigTransition
from app.models.media import MediaAsset, MediaVisibility
from app.schemas.disputes import (
    DisputeCreateV1Request,
    DisputeDetailView,
    DisputeEventView,
    DisputeListResponse,
    DisputeMessageCreateRequest,
    DisputeMessageView,
)
from app.schemas.media import CurrentUser
from app.services.authz import ensure_user_account, get_user_roles
from app.services.discovery_index import recompute_pro_public_index
from app.services.analytics import log_event
from app.services.disputes import create_dispute, post_dispute_message
from app.services.gamification import queue_evaluate_user_milestones
from app.services.niche_skills import recompute_pro_niche_skills

router = APIRouter(prefix="/disputes", tags=["disputes"])


@router.post("", response_model=DisputeDetailView)
def create_dispute_endpoint(
    body: DisputeCreateV1Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeDetailView:
    ensure_user_account(db, user.user_id)

    gig = db.get(Gig, body.gig_id) if body.gig_id else None
    purchase = db.get(ExtraImagePurchase, body.extra_purchase_id) if body.extra_purchase_id else None

    if gig and gig.status not in {GigStatus.paid, GigStatus.disputed, GigStatus.refunded, GigStatus.completed, GigStatus.final_delivered}:
        raise APIError(code="invalid_state", message="Disputes can be opened only for paid or later gigs", status_code=409)

    reason = (body.reason or body.summary or "").strip()
    if not reason:
        raise APIError(code="validation_error", message="reason is required", status_code=422)

    dispute = create_dispute(
        db,
        opened_by_user_id=user.user_id,
        gig=gig,
        extra_purchase=purchase,
        category=body.category,
        reason=reason,
        requested_refund_amount=body.requested_refund_amount,
        currency=body.currency,
    )

    if gig and gig.status != GigStatus.disputed:
        db.add(
            GigTransition(
                gig_id=gig.id,
                from_status=gig.status,
                to_status=GigStatus.disputed,
                actor_user_id=user.user_id,
                reason="Dispute opened",
            )
        )
        gig.status = GigStatus.disputed
        recompute_pro_public_index(db, gig.pro_user_id)
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)

    if gig and user.user_id == gig.client_user_id:
        pro_profile = db.get(ProProfile, gig.pro_user_id)
        log_event(
            db,
            event_name="client.dispute_opened",
            user_id=user.user_id,
            properties={"dispute_id": str(dispute.id), "gig_id": str(gig.id), "country": pro_profile.country if pro_profile else None, "city": pro_profile.city if pro_profile else None},
        )

    db.commit()
    db.refresh(dispute)
    return _to_detail(db, dispute)


@router.get("", response_model=DisputeListResponse)
def list_disputes(
    mine: bool = Query(default=True),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeListResponse:
    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    stmt = select(Dispute).order_by(Dispute.opened_at.desc(), Dispute.created_at.desc())
    if mine and not is_admin:
        stmt = stmt.where(or_(Dispute.opened_by_user_id == user.user_id, Dispute.against_user_id == user.user_id))
    rows = db.execute(stmt.limit(200)).scalars().all()
    return DisputeListResponse(items=[_to_detail(db, row) for row in rows])


@router.get("/{dispute_id}", response_model=DisputeDetailView)
def get_dispute(
    dispute_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeDetailView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    _ensure_dispute_access(db, dispute, user.user_id)
    return _to_detail(db, dispute)


@router.post("/{dispute_id}/messages", response_model=DisputeMessageView)
def add_dispute_message(
    dispute_id: uuid.UUID,
    body: DisputeMessageCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeMessageView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    _ensure_dispute_access(db, dispute, user.user_id)

    evidence_ids: list[uuid.UUID] = []
    for media_asset_id in body.evidence_media_asset_ids:
        asset = db.get(MediaAsset, media_asset_id)
        if not asset:
            raise APIError(code="not_found", message=f"Media asset {media_asset_id} not found", status_code=404)
        if asset.visibility != MediaVisibility.owner_only:
            raise APIError(code="validation_error", message="Evidence media must be owner_only", status_code=422)
        if asset.owner_user_id != user.user_id:
            raise APIError(code="forbidden", message="Cannot attach media owned by another user", status_code=403)
        evidence_ids.append(asset.id)

    roles = get_user_roles(db, user.user_id)
    actor_type = DisputeActorType.admin if UserRoleType.admin in roles else _actor_type_from_dispute(dispute, user.user_id)

    row = post_dispute_message(
        db,
        dispute=dispute,
        sender_user_id=user.user_id,
        message=body.message.strip(),
        evidence_media_asset_ids=evidence_ids,
        sender_role=actor_type,
    )
    db.commit()
    db.refresh(row)

    return DisputeMessageView(
        id=row.id,
        dispute_id=row.dispute_id,
        sender_user_id=row.sender_user_id,
        message=row.message,
        evidence_media_asset_ids=row.evidence_media_asset_ids or [],
        created_at=row.created_at,
    )


@router.post("/{dispute_id}/cancel", response_model=DisputeDetailView)
def cancel_dispute(
    dispute_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeDetailView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    if dispute.opened_by_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only opener can cancel dispute", status_code=403)
    if dispute.status in {
        DisputeStatus.resolved_no_refund,
        DisputeStatus.resolved_partial_refund,
        DisputeStatus.resolved_refund,
        DisputeStatus.closed,
        DisputeStatus.cancelled,
    }:
        raise APIError(code="invalid_state", message="Dispute cannot be cancelled", status_code=409)

    has_admin_action = db.execute(
        select(DisputeEvent.id).where(DisputeEvent.dispute_id == dispute.id, DisputeEvent.actor_type == DisputeActorType.admin)
    ).scalar_one_or_none()
    if has_admin_action:
        raise APIError(code="invalid_state", message="Dispute already has admin action", status_code=409)

    previous = dispute.status
    dispute.status = DisputeStatus.cancelled
    db.add(
        DisputeEvent(
            dispute_id=dispute.id,
            from_status=previous.value,
            to_status=dispute.status.value,
            actor_type=_actor_type_from_dispute(dispute, user.user_id),
            actor_user_id=user.user_id,
            note="cancelled_by_opener",
            payload={},
        )
    )
    db.commit()
    db.refresh(dispute)
    return _to_detail(db, dispute)


# Backward compatibility endpoint used by previous tests/clients.
@router.post("/{dispute_id}/evidence", response_model=DisputeMessageView)
def add_dispute_evidence_compat(
    dispute_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> DisputeMessageView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    _ensure_dispute_access(db, dispute, user.user_id)
    row = post_dispute_message(
        db,
        dispute=dispute,
        sender_user_id=user.user_id,
        message="Evidence submitted",
        evidence_media_asset_ids=[],
        sender_role=_actor_type_from_dispute(dispute, user.user_id),
    )
    db.commit()
    db.refresh(row)
    return DisputeMessageView(
        id=row.id,
        dispute_id=row.dispute_id,
        sender_user_id=row.sender_user_id,
        message=row.message,
        evidence_media_asset_ids=row.evidence_media_asset_ids or [],
        created_at=row.created_at,
    )


def _ensure_dispute_access(db: Session, dispute: Dispute, user_id: uuid.UUID) -> None:
    roles = get_user_roles(db, user_id)
    if UserRoleType.admin in roles:
        return
    if user_id not in {dispute.opened_by_user_id, dispute.against_user_id}:
        raise APIError(code="forbidden", message="Not allowed to access this dispute", status_code=403)


def _to_detail(db: Session, dispute: Dispute) -> DisputeDetailView:
    messages = db.execute(
        select(DisputeMessage).where(DisputeMessage.dispute_id == dispute.id).order_by(DisputeMessage.created_at.asc())
    ).scalars().all()
    events = db.execute(
        select(DisputeEvent).where(DisputeEvent.dispute_id == dispute.id).order_by(DisputeEvent.created_at.asc())
    ).scalars().all()
    return DisputeDetailView(
        id=dispute.id,
        gig_id=dispute.gig_id,
        extra_purchase_id=dispute.extra_purchase_id,
        opened_by_user_id=dispute.opened_by_user_id,
        against_user_id=dispute.against_user_id,
        category=dispute.category,
        status=dispute.status,
        reason=dispute.reason or dispute.summary,
        summary=dispute.summary,
        requested_refund_amount=dispute.requested_refund_amount,
        currency=dispute.currency,
        opened_at=dispute.opened_at,
        due_response_at=dispute.due_response_at,
        resolved_at=dispute.resolved_at,
        resolution=dispute.resolution or {},
        metadata=dispute.meta or {},
        created_at=dispute.created_at,
        updated_at=dispute.updated_at,
        messages=[
            DisputeMessageView(
                id=item.id,
                dispute_id=item.dispute_id,
                sender_user_id=item.sender_user_id,
                message=item.message,
                evidence_media_asset_ids=item.evidence_media_asset_ids or [],
                created_at=item.created_at,
            )
            for item in messages
        ],
        events=[
            DisputeEventView(
                id=item.id,
                dispute_id=item.dispute_id,
                from_status=item.from_status,
                to_status=item.to_status,
                actor_type=item.actor_type.value,
                actor_user_id=item.actor_user_id,
                note=item.note,
                payload=item.payload or {},
                created_at=item.created_at,
            )
            for item in events
        ],
    )


def _actor_type_from_dispute(dispute: Dispute, user_id: uuid.UUID) -> DisputeActorType:
    if user_id == dispute.opened_by_user_id:
        return DisputeActorType.client
    if dispute.against_user_id and user_id == dispute.against_user_id:
        return DisputeActorType.pro
    return DisputeActorType.system
