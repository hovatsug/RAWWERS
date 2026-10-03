"""Gear verification: proving what a photographer shoots on.

The floor is one full-frame body and one qualifying lens (plus lighting for the
niches that need it). `verify_from_raw` decided a frame correctly but nothing
called it, so `activate_pro` refused every photographer and there was no way to
become verified. This is the way.

A photographer uploads one camera file. It goes through the ordinary media
upload flow with the `gear_evidence` purpose - no variants are made, because a
RAW cannot be decoded and nothing needs a picture of it - and is then read here:
only its first megabyte, which is all the metadata ever needs.

Kept under its own tag. Gear registration for repairs sits under `repairs` for
reasons of who consumed it first, and that taxonomy is already a recorded
mistake; verification is profile data and is filed as such.
"""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import ProProfile, UserRoleType
from app.models.gear_verification import GearVerification, VerificationStatus
from app.models.media import MediaAsset, MediaObject, MediaPurpose, MediaStatus, MediaVariant
from app.schemas.gear_verification import (
    AdminGearListResponse,
    AdminGearVerificationView,
    GearApproveRequest,
    GearFloorView,
    GearFrameSubmitRequest,
    GearFrameSubmitResponse,
    GearRejectRequest,
    GearVerificationListResponse,
    GearVerificationView,
    LightingDeclareRequest,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.authz import user_has_role
from app.services.gear_exif import HEADER_READ_BYTES
from app.services.gear_floor import evaluate_gear_floor, niche_slugs_for_pro
from app.services.gear_verify import (
    approve_verification,
    declare_lighting,
    mask_serial,
    reject_verification,
    release_verification,
    verify_frame,
)
from app.services.launch_ops import maybe_advance_to_ready_for_review
from app.services.notifications import enqueue_notification
from app.services.rate_limit import enforce_named_rate_limit
from app.services.storage import create_presigned_get, download_object_range

router = APIRouter(tags=["gear_verification"])
admin_router = APIRouter(prefix="/admin", tags=["admin"])


def _require_pro(db: Session, user_id: uuid.UUID) -> None:
    if not user_has_role(db, user_id, UserRoleType.pro):
        raise APIError(code="forbidden", message="Role pro required", status_code=403)


def _view(row: GearVerification) -> GearVerificationView:
    return GearVerificationView(
        id=row.id,
        category=row.category,
        status=row.status,
        make=row.make,
        model=row.model,
        serial_hint=mask_serial(row.serial_number),
        sensor_size=row.sensor_size,
        aperture_type=row.aperture_type,
        min_focal_mm=row.min_focal_mm,
        max_focal_mm=row.max_focal_mm,
        max_aperture=row.max_aperture,
        review_reason=row.review_reason,
        verified_at=row.verified_at,
        created_at=row.created_at,
    )


def _floor(db: Session, pro_user_id: uuid.UUID) -> GearFloorView:
    floor = evaluate_gear_floor(db, pro_user_id, niche_slugs=niche_slugs_for_pro(db, pro_user_id))
    return GearFloorView(
        meets_floor=floor.meets_floor,
        has_full_frame_body=floor.has_full_frame_body,
        has_qualifying_lens=floor.has_qualifying_lens,
        has_lighting=floor.has_lighting,
        lighting_required=floor.lighting_required,
        lighting_is_declared=floor.lighting_is_declared,
        awaiting_review=floor.awaiting_review,
        missing=floor.missing,
    )


def _mine(db: Session, pro_user_id: uuid.UUID) -> list[GearVerification]:
    return list(
        db.execute(
            select(GearVerification)
            .where(GearVerification.pro_user_id == pro_user_id)
            .order_by(GearVerification.created_at.asc())
        ).scalars()
    )


@router.get("/pro/me/gear-verifications", response_model=GearVerificationListResponse)
def list_my_gear_verifications(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GearVerificationListResponse:
    _require_pro(db, user.user_id)
    return GearVerificationListResponse(items=[_view(r) for r in _mine(db, user.user_id)], floor=_floor(db, user.user_id))


@router.post("/pro/me/gear-verifications", response_model=GearFrameSubmitResponse)
def submit_gear_frame(
    body: GearFrameSubmitRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GearFrameSubmitResponse:
    """Verify the body and lens in one uploaded camera file."""
    _require_pro(db, user.user_id)
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))

    asset = db.get(MediaAsset, body.evidence_media_asset_id)
    if asset is None:
        raise APIError(code="not_found", message="Upload not found", status_code=404)
    if asset.owner_user_id != user.user_id:
        raise APIError(code="forbidden", message="That upload is not yours", status_code=403)
    if asset.purpose != MediaPurpose.gear_evidence:
        raise APIError(code="validation_error", message="That upload was not sent as gear evidence", status_code=422)
    if asset.status != MediaStatus.ready:
        raise APIError(code="invalid_state", message="That upload has not finished", status_code=409)

    original = db.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant == MediaVariant.original)
    ).scalar_one_or_none()
    if original is None:
        raise APIError(code="not_found", message="Upload not found", status_code=404)

    data = download_object_range(original.storage_key, 0, HEADER_READ_BYTES)
    result = verify_frame(
        db, pro_user_id=user.user_id, data=data, evidence_media_asset_id=asset.id
    )
    # Verifying the last missing piece can be what makes someone ready for review.
    maybe_advance_to_ready_for_review(db, pro_user_id=user.user_id)
    db.commit()
    return GearFrameSubmitResponse(
        items=[_view(r) for r in result.rows], notes=result.notes, floor=_floor(db, user.user_id)
    )


@router.post("/pro/me/gear-verifications/lighting", response_model=GearVerificationView)
def declare_my_lighting(
    body: LightingDeclareRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GearVerificationView:
    _require_pro(db, user.user_id)
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    row = declare_lighting(db, pro_user_id=user.user_id, make=body.make, model=body.model, notes=body.notes)
    maybe_advance_to_ready_for_review(db, pro_user_id=user.user_id)
    db.commit()
    return _view(row)


@router.delete("/pro/me/gear-verifications/{verification_id}", status_code=204)
def release_my_gear(
    verification_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> Response:
    _require_pro(db, user.user_id)
    release_verification(db, pro_user_id=user.user_id, verification_id=verification_id)
    db.commit()
    return Response(status_code=204)


# ---------------------------------------------------------------------------
# The review queue.
# ---------------------------------------------------------------------------


def _admin_view(db: Session, row: GearVerification) -> AdminGearVerificationView:
    profile = db.get(ProProfile, row.pro_user_id)
    evidence_url = None
    if row.evidence_media_asset_id:
        original = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == row.evidence_media_asset_id, MediaObject.variant == MediaVariant.original
            )
        ).scalar_one_or_none()
        if original is not None:
            evidence_url = create_presigned_get(original.storage_key, expires_in=300)
    return AdminGearVerificationView(
        id=row.id,
        pro_user_id=row.pro_user_id,
        pro_display_name=profile.display_name if profile else None,
        category=row.category,
        status=row.status,
        make=row.make,
        model=row.model,
        serial_number=row.serial_number,
        sensor_size=row.sensor_size,
        aperture_type=row.aperture_type,
        min_focal_mm=row.min_focal_mm,
        max_focal_mm=row.max_focal_mm,
        max_aperture=row.max_aperture,
        review_reason=row.review_reason,
        exif_snapshot=row.exif_snapshot or {},
        evidence_url=evidence_url,
        created_at=row.created_at,
        reviewed_at=row.reviewed_at,
        review_note=row.review_note,
    )


@admin_router.get("/gear-verifications", response_model=AdminGearListResponse)
def list_gear_verifications(
    status: VerificationStatus = Query(default=VerificationStatus.pending_review),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminGearListResponse:
    """Oldest first: the queue is work to do, and the longest wait goes first."""
    rows = db.execute(
        select(GearVerification)
        .where(GearVerification.status == status)
        .order_by(GearVerification.created_at.asc())
        .limit(200)
    ).scalars().all()
    return AdminGearListResponse(items=[_admin_view(db, r) for r in rows])


@admin_router.post("/gear-verifications/{verification_id}/approve", response_model=AdminGearVerificationView)
def approve_gear(
    verification_id: uuid.UUID,
    body: GearApproveRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminGearVerificationView:
    row = approve_verification(
        db,
        verification_id=verification_id,
        admin_user_id=actor.user_id,
        sensor_size=body.sensor_size,
        aperture_type=body.aperture_type,
        note=body.note,
        add_to_reference=body.add_to_reference,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="gear_verification",
        target_id=str(row.id),
        action="gear_approved",
        reason=body.note,
        metadata={"pro_user_id": str(row.pro_user_id), "category": row.category.value, "added_to_reference": body.add_to_reference},
    )
    enqueue_notification(
        db,
        user_id=row.pro_user_id,
        notification_type="gear.verified",
        payload={"title": "Your gear is verified", "body": f"{row.model or 'Your equipment'} has been approved."},
        reference_type="gear_verification",
        reference_id=str(row.id),
    )
    maybe_advance_to_ready_for_review(db, pro_user_id=row.pro_user_id)
    db.commit()
    return _admin_view(db, row)


@admin_router.post("/gear-verifications/{verification_id}/reject", response_model=AdminGearVerificationView)
def reject_gear(
    verification_id: uuid.UUID,
    body: GearRejectRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminGearVerificationView:
    row = reject_verification(db, verification_id=verification_id, admin_user_id=actor.user_id, reason=body.reason)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="gear_verification",
        target_id=str(row.id),
        action="gear_rejected",
        reason=body.reason,
        metadata={"pro_user_id": str(row.pro_user_id), "category": row.category.value},
    )
    enqueue_notification(
        db,
        user_id=row.pro_user_id,
        notification_type="gear.rejected",
        payload={"title": "Your gear was not approved", "body": row.review_reason or "See the reason in your gear list."},
        reference_type="gear_verification",
        reference_id=str(row.id),
    )
    db.commit()
    return _admin_view(db, row)
