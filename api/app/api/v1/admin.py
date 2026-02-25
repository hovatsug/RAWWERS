from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal

import stripe
from fastapi import APIRouter, Depends, Query
from sqlalchemy import Text, and_, cast, func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.core.errors import APIError
from app.models.admin import (
    BanAction,
    BanActionType,
    DisputeCategory,
    Dispute,
    DisputeStatus,
    ProProfile,
    RefundCase,
    RefundCaseStatus,
    UserAccount,
    UserRole,
    UserRoleType,
)
from app.models.gig import Gig, GigStatus, GigTransition, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.models.media import MediaAsset
from app.schemas.admin import (
    AdminGigStatusUpdateRequest,
    AdminRefundCreateRequest,
    BanActionView,
    BanUpdateRequest,
    DisputeStatusUpdateRequest,
    DisputeView,
    KYCUpdateRequest,
    RefundCaseView,
    RoleUpdateRequest,
    UserDetailResponse,
    UserListItem,
    UserListResponse,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.discovery_index import recompute_pro_public_index
from app.services.analytics import log_event
from app.services.rewards import maybe_issue_pro_signup_referral_reward

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/users", response_model=UserListResponse)
def list_users(
    q: str | None = None,
    role: UserRoleType | None = None,
    kyc_status: str | None = None,
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> UserListResponse:
    stmt = select(UserAccount)
    if q:
        stmt = stmt.where(
            or_(
                UserAccount.email.ilike(f"%{q}%"),
                UserAccount.display_name.ilike(f"%{q}%"),
                cast(UserAccount.user_id, Text).ilike(f"%{q}%"),
            )
        )

    users = db.execute(stmt.order_by(UserAccount.created_at.desc()).offset(offset).limit(limit)).scalars().all()

    items: list[UserListItem] = []
    for user in users:
        roles = db.execute(select(UserRole.role).where(UserRole.user_id == user.user_id)).scalars().all()
        profile = db.get(ProProfile, user.user_id)
        latest_ban = db.execute(
            select(BanAction).where(BanAction.user_id == user.user_id).order_by(BanAction.created_at.desc())
        ).scalar_one_or_none()

        if role and role not in roles:
            continue
        if kyc_status and (not profile or profile.kyc_status.value != kyc_status):
            continue

        items.append(
            UserListItem(
                user_id=user.user_id,
                email=user.email,
                display_name=user.display_name,
                roles=list(roles),
                kyc_status=profile.kyc_status if profile else None,
                ban_action=latest_ban.action if latest_ban else None,
            )
        )

    return UserListResponse(total=len(items), items=items)


@router.get("/users/{user_id}", response_model=UserDetailResponse)
def get_user_detail(
    user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> UserDetailResponse:
    user = db.get(UserAccount, user_id)
    if not user:
        raise APIError(code="not_found", message="User not found", status_code=404)

    roles = db.execute(select(UserRole.role).where(UserRole.user_id == user_id)).scalars().all()
    profile = db.get(ProProfile, user_id)
    ban_history = db.execute(
        select(BanAction).where(BanAction.user_id == user_id).order_by(BanAction.created_at.desc()).limit(20)
    ).scalars().all()

    gigs_count = db.execute(
        select(func.count()).select_from(Gig).where(or_(Gig.client_user_id == user_id, Gig.pro_user_id == user_id))
    ).scalar_one()
    gigs_last_activity = db.execute(
        select(func.max(Gig.updated_at)).where(or_(Gig.client_user_id == user_id, Gig.pro_user_id == user_id))
    ).scalar_one()
    media_count = db.execute(select(func.count()).select_from(MediaAsset).where(MediaAsset.owner_user_id == user_id)).scalar_one()

    return UserDetailResponse(
        user_id=user.user_id,
        email=user.email,
        display_name=user.display_name,
        roles=list(roles),
        kyc_status=profile.kyc_status if profile else None,
        kyc_note=profile.kyc_note if profile else None,
        ban_history=[
            BanActionView(
                action=item.action,
                reason=item.reason,
                actor_user_id=item.actor_user_id,
                starts_at=item.starts_at,
                ends_at=item.ends_at,
                created_at=item.created_at,
            )
            for item in ban_history
        ],
        gigs_count=gigs_count,
        gigs_last_activity=gigs_last_activity,
        media_count=media_count,
    )


@router.post("/users/{user_id}/roles")
def update_user_roles(
    user_id: uuid.UUID,
    body: RoleUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    account = db.get(UserAccount, user_id)
    if not account:
        account = UserAccount(user_id=user_id)
        db.add(account)
        db.flush()

    for role in body.add:
        exists = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == role)).scalar_one_or_none()
        if not exists:
            db.add(UserRole(user_id=user_id, role=role))

    for role in body.remove:
        row = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == role)).scalar_one_or_none()
        if not row:
            continue
        if role == UserRoleType.admin:
            admin_count = db.execute(select(func.count()).select_from(UserRole).where(UserRole.role == UserRoleType.admin)).scalar_one()
            if admin_count <= 1:
                raise APIError(code="safety_check_failed", message="Cannot remove the last admin", status_code=409)
        db.delete(row)

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="user",
        target_id=str(user_id),
        action="update_roles",
        reason=body.reason,
        metadata={"add": [x.value for x in body.add], "remove": [x.value for x in body.remove]},
    )
    db.commit()

    roles = db.execute(select(UserRole.role).where(UserRole.user_id == user_id)).scalars().all()
    return {"user_id": str(user_id), "roles": [r.value for r in roles]}


@router.post("/pros/{user_id}/kyc")
def update_pro_kyc(
    user_id: uuid.UUID,
    body: KYCUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    has_pro_role = db.execute(
        select(UserRole).where(UserRole.user_id == user_id, UserRole.role == UserRoleType.pro)
    ).scalar_one_or_none()
    if not has_pro_role:
        raise APIError(code="validation_error", message="User is not a pro", status_code=400)

    profile = db.get(ProProfile, user_id)
    if not profile:
        profile = ProProfile(user_id=user_id)
        db.add(profile)

    previous_status = profile.kyc_status
    profile.kyc_status = body.kyc_status
    profile.kyc_note = body.note
    profile.kyc_updated_at = datetime.now(timezone.utc)

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="user",
        target_id=str(user_id),
        action=f"kyc_{body.kyc_status.value}",
        reason=body.note,
    )
    if previous_status != KYCStatus.approved and body.kyc_status == KYCStatus.approved:
        reward_entry = maybe_issue_pro_signup_referral_reward(db, user_id)
        if reward_entry:
            log_event(
                db,
                event_name="reward.earned",
                user_id=reward_entry.user_id,
                properties={"rule_code": reward_entry.rule_code, "amount": reward_entry.amount, "referred_user_id": str(user_id)},
            )
    db.commit()
    recompute_pro_public_index(db, user_id)
    db.commit()
    return {"user_id": str(user_id), "kyc_status": body.kyc_status.value}


@router.post("/users/{user_id}/ban")
def update_user_ban(
    user_id: uuid.UUID,
    body: BanUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    if body.action == BanActionType.suspended and not body.ends_at:
        raise APIError(code="validation_error", message="Suspension requires ends_at", status_code=422)

    action = BanAction(
        user_id=user_id,
        action=body.action,
        reason=body.reason,
        actor_user_id=actor.user_id,
        ends_at=body.ends_at,
    )
    db.add(action)

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="user",
        target_id=str(user_id),
        action="ban_update",
        reason=body.reason,
        metadata={"ban_action": body.action.value, "ends_at": body.ends_at.isoformat() if body.ends_at else None},
    )
    db.commit()
    return {"user_id": str(user_id), "action": body.action.value}


@router.get("/disputes", response_model=list[DisputeView])
def list_disputes(
    status: DisputeStatus | None = None,
    category: DisputeCategory | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[DisputeView]:
    stmt = select(Dispute)
    conditions = []
    if status:
        conditions.append(Dispute.status == status)
    if category:
        conditions.append(Dispute.category == category)
    if date_from:
        conditions.append(Dispute.created_at >= date_from)
    if date_to:
        conditions.append(Dispute.created_at <= date_to)
    if conditions:
        stmt = stmt.where(and_(*conditions))

    disputes = db.execute(stmt.order_by(Dispute.created_at.desc())).scalars().all()
    return [
        DisputeView(
            id=d.id,
            gig_id=d.gig_id,
            opened_by_user_id=d.opened_by_user_id,
            status=d.status,
            category=d.category,
            summary=d.summary,
            resolution_note=d.resolution_note,
            created_at=d.created_at,
            updated_at=d.updated_at,
        )
        for d in disputes
    ]


@router.post("/disputes/{dispute_id}/status", response_model=DisputeView)
def update_dispute_status(
    dispute_id: uuid.UUID,
    body: DisputeStatusUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> DisputeView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)

    dispute.status = body.status
    dispute.resolution_note = body.resolution_note

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="dispute",
        target_id=str(dispute.id),
        action="dispute_status_update",
        reason=body.reason,
        metadata={"status": body.status.value, "resolution_note": body.resolution_note},
    )
    gig = db.get(Gig, dispute.gig_id)
    if gig:
        recompute_pro_public_index(db, gig.pro_user_id)
    db.commit()
    db.refresh(dispute)

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


@router.post("/gigs/{gig_id}/status")
def update_gig_status(
    gig_id: uuid.UUID,
    body: AdminGigStatusUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if body.status == GigStatus.paid:
        raise APIError(code="invalid_state_transition", message="Gig cannot be set to paid by admin", status_code=409)

    allowed_operational_statuses = {
        GigStatus.disputed,
        GigStatus.cancelled_by_client,
        GigStatus.cancelled_by_pro,
        GigStatus.refunded,
        GigStatus.completed,
    }
    if body.status not in allowed_operational_statuses:
        raise APIError(code="invalid_state_transition", message="Target status is not admin-operational", status_code=409)

    previous = gig.status
    gig.status = body.status
    db.add(
        GigTransition(
            gig_id=gig.id,
            from_status=previous,
            to_status=body.status,
            actor_user_id=actor.user_id,
            reason=body.reason,
        )
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="gig",
        target_id=str(gig.id),
        action="gig_status_update",
        reason=body.reason,
        metadata={"from_status": previous.value, "to_status": body.status.value},
    )
    recompute_pro_public_index(db, gig.pro_user_id)
    db.commit()
    return {"gig_id": str(gig.id), "status": gig.status.value}


@router.post("/gigs/{gig_id}/refunds", response_model=RefundCaseView)
def create_admin_refund(
    gig_id: uuid.UUID,
    body: AdminRefundCreateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RefundCaseView:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if gig.status not in {GigStatus.paid, GigStatus.disputed}:
        raise APIError(code="invalid_state", message="Gig must be paid or disputed", status_code=409)

    existing = db.execute(
        select(RefundCase).where(
            RefundCase.gig_id == gig_id,
            RefundCase.status.in_([RefundCaseStatus.processing, RefundCaseStatus.succeeded]),
        )
    ).scalar_one_or_none()
    if existing:
        return _refund_case_view(existing)

    payment = db.execute(select(StripePayment).where(StripePayment.gig_id == gig_id)).scalar_one_or_none()
    if not payment:
        raise APIError(code="invalid_state", message="No stripe payment for gig", status_code=409)

    amount = body.amount or gig.amount_total
    if amount <= 0 or amount > gig.amount_total:
        raise APIError(code="validation_error", message="Invalid refund amount", status_code=422)

    refund = stripe.Refund.create(
        payment_intent=payment.stripe_payment_intent_id,
        amount=int((amount * Decimal("100")).quantize(Decimal("1"))),
        metadata={
            "gig_id": str(gig.id),
            "actor_user_id": str(actor.user_id),
            "dispute_id": str(body.dispute_id) if body.dispute_id else "",
        },
    )

    refund_case = RefundCase(
        gig_id=gig.id,
        dispute_id=body.dispute_id,
        requested_by_user_id=actor.user_id,
        status=RefundCaseStatus.processing,
        amount=amount,
        currency=gig.currency,
        reason=body.reason,
        admin_note=body.reason,
        meta={"stripe_refund_id": refund.id},
    )
    db.add(refund_case)

    db.add(
        LedgerEntry(
            gig_id=gig.id,
            entry_type=LedgerEntryType.refund_initiated,
            amount=Decimal("0.00"),
            currency=gig.currency,
            description=body.reason or "Admin refund initiated",
            reference_type="stripe_refund",
            reference_id=refund.id,
        )
    )

    if payment.status != PaymentStatus.disputed:
        payment.status = PaymentStatus.pending

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="gig",
        target_id=str(gig.id),
        action="refund_initiated",
        reason=body.reason,
        metadata={"amount": str(amount), "refund_id": refund.id, "dispute_id": str(body.dispute_id) if body.dispute_id else None},
    )
    recompute_pro_public_index(db, gig.pro_user_id)
    db.commit()
    db.refresh(refund_case)
    return _refund_case_view(refund_case)


@router.get("/refunds", response_model=list[RefundCaseView])
def list_refunds(
    status: RefundCaseStatus | None = None,
    gig_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RefundCaseView]:
    stmt = select(RefundCase)
    if status:
        stmt = stmt.where(RefundCase.status == status)
    if gig_id:
        stmt = stmt.where(RefundCase.gig_id == gig_id)

    cases = db.execute(stmt.order_by(RefundCase.created_at.desc())).scalars().all()
    return [_refund_case_view(item) for item in cases]


def _refund_case_view(item: RefundCase) -> RefundCaseView:
    return RefundCaseView(
        id=item.id,
        gig_id=item.gig_id,
        dispute_id=item.dispute_id,
        requested_by_user_id=item.requested_by_user_id,
        status=item.status,
        amount=item.amount,
        currency=item.currency,
        reason=item.reason,
        admin_note=item.admin_note,
        metadata=item.meta,
        created_at=item.created_at,
        updated_at=item.updated_at,
    )
