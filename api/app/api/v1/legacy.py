from __future__ import annotations

import uuid
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.legacy_shoot import (
    LegacyBooking,
    LegacyBookingStatus,
    LegacyBrief,
    LegacyMarketingConsent,
    LegacyPaymentMode,
    LegacyReview,
    LegacyReviewResponse,
    VaultAccessLog,
    VaultAccessAction,
    VaultItem,
)
from app.schemas.legacy_shoot import (
    LegacyAdminAuditResponse,
    LegacyAssignProRequest,
    LegacyBookingDetailResponse,
    LegacyBookingView,
    LegacyBriefPutRequest,
    LegacyBriefView,
    LegacyCheckoutRequest,
    LegacyCheckoutResponse,
    LegacyMarketingConsentRequest,
    LegacyMarketingConsentView,
    LegacyReviewRespondRequest,
    LegacyReviewSubmitRequest,
    LegacyReviewView,
    LegacySetStatusRequest,
    LegacyVaultDownloadResponse,
    LegacyVaultListResponse,
    LegacyVaultUploadRequest,
    LegacyVaultUploadResponse,
    LegacyVaultItemView,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.legacy_shoot import (
    assign_legacy_pro,
    checkout_legacy_shoot,
    enforce_legacy_access,
    get_legacy_booking_or_404,
    issue_vault_download,
    issue_vault_upload,
    log_vault_access,
    now_utc,
    respond_legacy_review,
    set_legacy_status,
    submit_legacy_review,
    upsert_legacy_brief,
    upsert_marketing_consent,
)

router = APIRouter(tags=["legacy_shoot"])


@router.post("/legacy/checkout", response_model=LegacyCheckoutResponse)
def legacy_checkout(
    body: LegacyCheckoutRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyCheckoutResponse:
    booking, intent = checkout_legacy_shoot(db, client_user_id=user.user_id, payment_mode=body.payment_mode)
    db.commit()
    return LegacyCheckoutResponse(
        legacy_booking_id=booking.id,
        gig_id=booking.gig_id,
        payment_intent_id=intent.id,
        payment_intent_client_secret=getattr(intent, "client_secret", None),
        payment_mode=body.payment_mode,
        due_now_eur=Decimal(intent.amount) / Decimal(100),
    )


@router.get("/legacy/{legacy_booking_id}", response_model=LegacyBookingDetailResponse)
def legacy_get(
    legacy_booking_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyBookingDetailResponse:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    enforce_legacy_access(db, booking=booking, user_id=user.user_id)
    brief = db.get(LegacyBrief, booking.id)
    consent = db.get(LegacyMarketingConsent, booking.id)
    db.commit()
    return LegacyBookingDetailResponse(
        booking=LegacyBookingView.model_validate(booking, from_attributes=True),
        brief=LegacyBriefView.model_validate(brief, from_attributes=True) if brief else None,
        marketing_consent=bool(consent.consent) if consent else False,
        marketing_channels=list(consent.channels or []) if consent else [],
    )


@router.put("/legacy/{legacy_booking_id}/brief", response_model=LegacyBriefView)
def legacy_put_brief(
    legacy_booking_id: uuid.UUID,
    body: LegacyBriefPutRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyBriefView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    row = upsert_legacy_brief(
        db,
        booking=booking,
        answers=body.answers,
        tone=body.tone,
        privacy_level=body.privacy_level,
        actor_user_id=user.user_id,
    )
    db.commit()
    return LegacyBriefView.model_validate(row, from_attributes=True)


@router.get("/legacy/{legacy_booking_id}/vault", response_model=LegacyVaultListResponse)
def legacy_vault_list(
    legacy_booking_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyVaultListResponse:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    enforce_legacy_access(db, booking=booking, user_id=user.user_id)
    rows = db.execute(
        select(VaultItem)
        .where(VaultItem.legacy_booking_id == booking.id)
        .order_by(VaultItem.created_at.desc())
    ).scalars().all()
    log_vault_access(db, booking_id=booking.id, user_id=user.user_id, action=VaultAccessAction.view, vault_item_id=None)
    db.commit()
    return LegacyVaultListResponse(items=[LegacyVaultItemView.model_validate(item, from_attributes=True) for item in rows])


@router.post("/legacy/{legacy_booking_id}/vault/{vault_item_id}/download", response_model=LegacyVaultDownloadResponse)
def legacy_vault_download(
    legacy_booking_id: uuid.UUID,
    vault_item_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyVaultDownloadResponse:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    item = db.get(VaultItem, vault_item_id)
    if not item:
        raise APIError(code="not_found", message="Vault item not found", status_code=404)
    url = issue_vault_download(db, booking=booking, item=item, actor_user_id=user.user_id)
    db.commit()
    return LegacyVaultDownloadResponse(url=url)


@router.post("/legacy/{legacy_booking_id}/reviews/{review_id}/respond", response_model=LegacyReviewView)
def legacy_review_respond(
    legacy_booking_id: uuid.UUID,
    review_id: uuid.UUID,
    body: LegacyReviewRespondRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyReviewView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    review = db.get(LegacyReview, review_id)
    if not review:
        raise APIError(code="not_found", message="Review not found", status_code=404)
    row = respond_legacy_review(
        db,
        booking=booking,
        review=review,
        actor_user_id=user.user_id,
        response=body.response,
        notes=body.notes,
    )
    db.commit()
    return LegacyReviewView.model_validate(row, from_attributes=True)


@router.put("/legacy/{legacy_booking_id}/marketing-consent", response_model=LegacyMarketingConsentView)
def legacy_marketing_consent_put(
    legacy_booking_id: uuid.UUID,
    body: LegacyMarketingConsentRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyMarketingConsentView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    row = upsert_marketing_consent(
        db,
        booking=booking,
        actor_user_id=user.user_id,
        consent=body.consent,
        channels=body.channels,
    )
    db.commit()
    return LegacyMarketingConsentView.model_validate(row, from_attributes=True)


@router.get("/pro/legacy/assigned", response_model=list[LegacyBookingView])
def pro_legacy_assigned(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[LegacyBookingView]:
    roles = {role.value for role in user.roles}
    if UserRoleType.pro.value not in roles and UserRoleType.admin.value not in roles:
        raise APIError(code="forbidden", message="Pro access required", status_code=403)
    rows = db.execute(
        select(LegacyBooking)
        .where(LegacyBooking.assigned_pro_user_id == user.user_id)
        .order_by(LegacyBooking.created_at.desc())
    ).scalars().all()
    db.commit()
    return [LegacyBookingView.model_validate(item, from_attributes=True) for item in rows]


@router.post("/pro/legacy/{legacy_booking_id}/mark-shoot-done", response_model=LegacyBookingView)
def pro_mark_shoot_done(
    legacy_booking_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyBookingView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    if user.user_id != booking.assigned_pro_user_id and UserRoleType.admin not in user.roles:
        raise APIError(code="forbidden", message="Only assigned pro or admin", status_code=403)
    set_legacy_status(db, booking=booking, status=LegacyBookingStatus.shoot_done)
    set_legacy_status(db, booking=booking, status=LegacyBookingStatus.edit_in_progress)
    db.commit()
    return LegacyBookingView.model_validate(booking, from_attributes=True)


@router.post("/pro/legacy/{legacy_booking_id}/vault/upload", response_model=LegacyVaultUploadResponse)
def pro_vault_upload(
    legacy_booking_id: uuid.UUID,
    body: LegacyVaultUploadRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyVaultUploadResponse:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    item, upload_url = issue_vault_upload(
        db,
        booking=booking,
        actor_user_id=user.user_id,
        item_type=body.type,
        content_type=body.content_type,
        bytes_size=body.bytes,
    )
    db.commit()
    return LegacyVaultUploadResponse(vault_item_id=item.id, upload_url=upload_url)


@router.post("/pro/legacy/{legacy_booking_id}/reviews/submit", response_model=LegacyReviewView)
def pro_review_submit(
    legacy_booking_id: uuid.UUID,
    body: LegacyReviewSubmitRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LegacyReviewView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    row = submit_legacy_review(
        db,
        booking=booking,
        actor_user_id=user.user_id,
        stage=body.stage,
        vault_item_ids=body.vault_item_ids,
    )
    db.commit()
    return LegacyReviewView.model_validate(row, from_attributes=True)


@router.get("/admin/legacy/orders", response_model=list[LegacyBookingView])
def admin_legacy_orders(
    status: LegacyBookingStatus | None = Query(default=None),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[LegacyBookingView]:
    stmt = select(LegacyBooking).order_by(LegacyBooking.created_at.desc())
    if status:
        stmt = stmt.where(LegacyBooking.status == status)
    rows = db.execute(stmt.limit(500)).scalars().all()
    db.commit()
    return [LegacyBookingView.model_validate(item, from_attributes=True) for item in rows]


@router.post("/admin/legacy/{legacy_booking_id}/assign-pro", response_model=LegacyBookingView)
def admin_legacy_assign_pro(
    legacy_booking_id: uuid.UUID,
    body: LegacyAssignProRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> LegacyBookingView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    row = assign_legacy_pro(
        db,
        booking=booking,
        pro_user_id=body.pro_user_id,
        admin_override=body.admin_override,
        actor_user_id=actor.user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="legacy_booking",
        target_id=str(booking.id),
        action="legacy_assign_pro",
        metadata={"pro_user_id": str(body.pro_user_id), "override": body.admin_override},
    )
    db.commit()
    return LegacyBookingView.model_validate(row, from_attributes=True)


@router.post("/admin/legacy/{legacy_booking_id}/set-status", response_model=LegacyBookingView)
def admin_legacy_set_status(
    legacy_booking_id: uuid.UUID,
    body: LegacySetStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> LegacyBookingView:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    row = set_legacy_status(db, booking=booking, status=body.status)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="legacy_booking",
        target_id=str(booking.id),
        action="legacy_set_status",
        metadata={"status": body.status.value, "at": now_utc().isoformat()},
    )
    db.commit()
    return LegacyBookingView.model_validate(row, from_attributes=True)


@router.get("/admin/legacy/{legacy_booking_id}/audit", response_model=LegacyAdminAuditResponse)
def admin_legacy_audit(
    legacy_booking_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> LegacyAdminAuditResponse:
    booking = get_legacy_booking_or_404(db, legacy_booking_id)
    logs = db.execute(
        select(VaultAccessLog)
        .where(VaultAccessLog.legacy_booking_id == booking.id)
        .order_by(VaultAccessLog.created_at.desc())
        .limit(500)
    ).scalars().all()
    reviews = db.execute(
        select(LegacyReview)
        .where(LegacyReview.legacy_booking_id == booking.id)
        .order_by(LegacyReview.created_at.desc())
        .limit(200)
    ).scalars().all()
    db.commit()
    return LegacyAdminAuditResponse(
        access_logs=[
            {
                "id": str(row.id),
                "legacy_booking_id": str(row.legacy_booking_id),
                "user_id": str(row.user_id) if row.user_id else None,
                "action": row.action.value,
                "vault_item_id": str(row.vault_item_id) if row.vault_item_id else None,
                "created_at": row.created_at.isoformat(),
            }
            for row in logs
        ],
        reviews=[LegacyReviewView.model_validate(row, from_attributes=True) for row in reviews],
    )
