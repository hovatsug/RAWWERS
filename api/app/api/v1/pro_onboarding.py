from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP

from fastapi import APIRouter, Depends
from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile, UserRoleType
from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    BookingRequestTransition,
    ProAvailabilityRule,
    ProBlackoutDate,
    ProPackage,
)
from app.models.gig import Gig, GigStatus
from app.schemas.media import CurrentUser
from app.schemas.onboarding import (
    AcceptBookingResponse,
    BlackoutCreateRequest,
    BlackoutView,
    BookingDecisionRequest,
    BookingRequestCreateRequest,
    BookingRequestView,
    ProActivateResponse,
    ProPackageCreateRequest,
    ProPackageUpdateRequest,
    ProPackageView,
    ProProfileUpdateRequest,
    ProProfileView,
    PublicAvailabilityResponse,
    ReplaceAvailabilityRulesRequest,
)
from app.services.audit import add_admin_audit_log
from app.services.analytics import log_event
from app.services.authz import ensure_user_account, get_user_roles
from app.services.discovery_index import recompute_pro_public_index
from app.services.payment_intents import create_or_get_gig_payment_intent

settings = get_settings()
router = APIRouter(tags=["pro_onboarding"])


@router.get("/pro/me/profile", response_model=ProProfileView)
def get_my_pro_profile(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProProfileView:
    _require_role(db, user.user_id, UserRoleType.pro)
    profile = _ensure_pro_profile(db, user.user_id)
    db.commit()
    return _profile_view(profile)


@router.put("/pro/me/profile", response_model=ProProfileView)
def update_my_pro_profile(
    body: ProProfileUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProProfileView:
    _require_role(db, user.user_id, UserRoleType.pro)
    profile = _ensure_pro_profile(db, user.user_id)

    for field in ["display_name", "headline", "bio", "city", "country", "languages", "styles", "gear"]:
        value = getattr(body, field)
        if value is not None:
            setattr(profile, field, value)

    profile.completeness_score = _compute_completeness(profile)
    recompute_pro_public_index(db, user.user_id)
    db.commit()
    db.refresh(profile)
    return _profile_view(profile)


@router.post("/pro/me/activate", response_model=ProActivateResponse)
def activate_pro(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProActivateResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    profile = _ensure_pro_profile(db, user.user_id)

    active_packages = db.execute(
        select(func.count()).select_from(ProPackage).where(ProPackage.pro_user_id == user.user_id, ProPackage.is_active.is_(True))
    ).scalar_one()

    is_dev_override = settings.app_env.lower() in {"dev", "development"} and settings.allow_unverified_pro
    if profile.kyc_status != KYCStatus.approved and not is_dev_override:
        raise APIError(code="kyc_required", message="KYC must be approved to activate", status_code=409)
    if active_packages < 1:
        raise APIError(code="validation_error", message="At least one active package required", status_code=409)
    if profile.completeness_score < 60:
        raise APIError(code="validation_error", message="Profile completeness must be >= 60", status_code=409)

    profile.is_accepting_bookings = True
    recompute_pro_public_index(db, user.user_id)
    db.commit()

    return ProActivateResponse(
        is_accepting_bookings=profile.is_accepting_bookings,
        completeness_score=profile.completeness_score,
        kyc_status=profile.kyc_status.value,
    )


@router.post("/pro/me/packages", response_model=ProPackageView)
def create_package(
    body: ProPackageCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProPackageView:
    _require_role(db, user.user_id, UserRoleType.pro)
    package = ProPackage(
        pro_user_id=user.user_id,
        title=body.title,
        description=body.description,
        duration_minutes=body.duration_minutes,
        price=body.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP),
        currency=body.currency.upper(),
        included_photos=body.included_photos,
        extra_photo_price=body.extra_photo_price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP),
        proofs_sla_days=body.proofs_sla_days,
        finals_sla_days=body.finals_sla_days,
        addons=body.addons,
        is_active=True,
    )
    db.add(package)
    recompute_pro_public_index(db, user.user_id)
    db.commit()
    db.refresh(package)
    return _package_view(package)


@router.get("/pro/{pro_user_id}/packages", response_model=list[ProPackageView])
def list_pro_packages(pro_user_id: uuid.UUID, db: Session = Depends(get_db_session)) -> list[ProPackageView]:
    packages = db.execute(
        select(ProPackage)
        .where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.created_at.desc())
    ).scalars().all()
    return [_package_view(item) for item in packages]


@router.put("/pro/me/packages/{package_id}", response_model=ProPackageView)
def update_package(
    package_id: uuid.UUID,
    body: ProPackageUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProPackageView:
    _require_role(db, user.user_id, UserRoleType.pro)
    package = db.get(ProPackage, package_id)
    if not package or package.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Package not found", status_code=404)

    for field in [
        "title",
        "description",
        "duration_minutes",
        "price",
        "currency",
        "included_photos",
        "extra_photo_price",
        "proofs_sla_days",
        "finals_sla_days",
        "addons",
        "is_active",
    ]:
        value = getattr(body, field)
        if value is not None:
            if field in {"price", "extra_photo_price"}:
                value = value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
            if field == "currency":
                value = value.upper()
            setattr(package, field, value)

    recompute_pro_public_index(db, user.user_id)
    db.commit()
    db.refresh(package)
    return _package_view(package)


@router.post("/pro/me/packages/{package_id}/disable", response_model=ProPackageView)
def disable_package(
    package_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProPackageView:
    _require_role(db, user.user_id, UserRoleType.pro)
    package = db.get(ProPackage, package_id)
    if not package or package.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Package not found", status_code=404)
    package.is_active = False
    recompute_pro_public_index(db, user.user_id)
    db.commit()
    db.refresh(package)
    return _package_view(package)


@router.post("/pro/me/availability/rules")
def replace_availability_rules(
    body: ReplaceAvailabilityRulesRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> dict:
    _require_role(db, user.user_id, UserRoleType.pro)
    for rule in body.rules:
        if rule.day_of_week < 0 or rule.day_of_week > 6:
            raise APIError(code="validation_error", message="day_of_week must be 0..6", status_code=422)
        if rule.end_time <= rule.start_time:
            raise APIError(code="validation_error", message="end_time must be after start_time", status_code=422)

    db.query(ProAvailabilityRule).filter(ProAvailabilityRule.pro_user_id == user.user_id).delete()
    for rule in body.rules:
        db.add(
            ProAvailabilityRule(
                pro_user_id=user.user_id,
                day_of_week=rule.day_of_week,
                start_time=rule.start_time,
                end_time=rule.end_time,
            )
        )
    db.commit()
    return {"ok": True, "count": len(body.rules)}


@router.post("/pro/me/availability/blackouts", response_model=BlackoutView)
def create_blackout(
    body: BlackoutCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BlackoutView:
    _require_role(db, user.user_id, UserRoleType.pro)
    if body.end_at <= body.start_at:
        raise APIError(code="validation_error", message="end_at must be after start_at", status_code=422)

    blackout = ProBlackoutDate(
        pro_user_id=user.user_id,
        start_at=body.start_at,
        end_at=body.end_at,
        reason=body.reason,
    )
    db.add(blackout)
    db.commit()
    db.refresh(blackout)
    return BlackoutView(id=blackout.id, start_at=blackout.start_at, end_at=blackout.end_at, reason=blackout.reason)


@router.get("/pro/{pro_user_id}/availability", response_model=PublicAvailabilityResponse)
def get_public_availability(pro_user_id: uuid.UUID, db: Session = Depends(get_db_session)) -> PublicAvailabilityResponse:
    rules = db.execute(
        select(ProAvailabilityRule).where(ProAvailabilityRule.pro_user_id == pro_user_id).order_by(ProAvailabilityRule.day_of_week.asc())
    ).scalars().all()
    blackouts = db.execute(
        select(ProBlackoutDate).where(ProBlackoutDate.pro_user_id == pro_user_id).order_by(ProBlackoutDate.start_at.asc())
    ).scalars().all()

    return PublicAvailabilityResponse(
        pro_user_id=pro_user_id,
        rules=[
            {"id": r.id, "day_of_week": r.day_of_week, "start_time": r.start_time, "end_time": r.end_time}
            for r in rules
        ],
        blackouts=[{"id": b.id, "start_at": b.start_at, "end_at": b.end_at, "reason": b.reason} for b in blackouts],
    )


@router.post("/pros/{pro_user_id}/booking-requests", response_model=BookingRequestView)
def create_booking_request(
    pro_user_id: uuid.UUID,
    body: BookingRequestCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingRequestView:
    _require_role(db, user.user_id, UserRoleType.client)
    if body.requested_end <= body.requested_start:
        raise APIError(code="validation_error", message="requested_end must be after requested_start", status_code=422)

    profile = _ensure_pro_profile(db, pro_user_id)
    is_dev_override = settings.app_env.lower() in {"dev", "development"} and settings.allow_unverified_pro
    if not profile.is_accepting_bookings and not is_dev_override:
        raise APIError(code="validation_error", message="Pro is not accepting bookings", status_code=409)

    package = db.get(ProPackage, body.package_id)
    if not package or package.pro_user_id != pro_user_id or not package.is_active:
        raise APIError(code="validation_error", message="Invalid package", status_code=422)

    _validate_availability(db, pro_user_id, body.requested_start, body.requested_end)

    request = BookingRequest(
        pro_user_id=pro_user_id,
        client_user_id=user.user_id,
        package_id=package.id,
        requested_start=body.requested_start,
        requested_end=body.requested_end,
        location_text=body.location_text,
        notes=body.notes,
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
    )
    db.add(request)
    db.flush()
    db.add(
        BookingRequestTransition(
            booking_request_id=request.id,
            from_status=BookingRequestStatus.pending,
            to_status=BookingRequestStatus.pending,
            actor_user_id=user.user_id,
            reason="Booking request created",
        )
    )
    log_event(
        db,
        event_name="booking.request_created",
        user_id=user.user_id,
        properties={"booking_request_id": str(request.id), "pro_user_id": str(pro_user_id), "package_id": str(package.id)},
    )
    db.commit()
    db.refresh(request)
    return _booking_request_view(request)


@router.get("/booking-requests/{request_id}", response_model=BookingRequestView)
def get_booking_request(
    request_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingRequestView:
    request = db.get(BookingRequest, request_id)
    if not request:
        raise APIError(code="not_found", message="Booking request not found", status_code=404)

    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    if not is_admin and user.user_id not in {request.pro_user_id, request.client_user_id}:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)
    return _booking_request_view(request)


@router.post("/booking-requests/{request_id}/accept", response_model=AcceptBookingResponse)
def accept_booking_request(
    request_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AcceptBookingResponse:
    request = db.get(BookingRequest, request_id)
    if not request:
        raise APIError(code="not_found", message="Booking request not found", status_code=404)
    if request.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only pro can accept", status_code=403)

    profile = _ensure_pro_profile(db, request.pro_user_id)
    is_dev_override = settings.app_env.lower() in {"dev", "development"} and settings.allow_unverified_pro
    if profile.kyc_status != KYCStatus.approved and not is_dev_override:
        raise APIError(code="kyc_required", message="Pro KYC must be approved", status_code=409)

    existing_gig = _find_gig_by_booking_request(db, request.id)

    if request.status == BookingRequestStatus.accepted and existing_gig:
        _, pi = create_or_get_gig_payment_intent(db, existing_gig)
        db.commit()
        return AcceptBookingResponse(
            booking_request=_booking_request_view(request),
            gig_id=existing_gig.id,
            payment_intent_id=pi.id,
            payment_intent_client_secret=pi.client_secret,
        )

    if request.status != BookingRequestStatus.pending:
        raise APIError(code="invalid_state", message="Only pending requests can be accepted", status_code=409)
    if request.expires_at < datetime.now(timezone.utc):
        raise APIError(code="invalid_state", message="Request has expired", status_code=409)

    package = db.get(ProPackage, request.package_id)
    if not package:
        raise APIError(code="validation_error", message="Package no longer exists", status_code=409)

    request.status = BookingRequestStatus.accepted
    db.add(
        BookingRequestTransition(
            booking_request_id=request.id,
            from_status=BookingRequestStatus.pending,
            to_status=BookingRequestStatus.accepted,
            actor_user_id=user.user_id,
            reason="Accepted by pro",
        )
    )

    amount_total = package.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    fee = (amount_total * Decimal(settings.platform_fee_bps) / Decimal(10000)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    pro_gross = (amount_total - fee).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    snapshot = {
        "package_id": str(package.id),
        "package_title": package.title,
        "duration_minutes": package.duration_minutes,
        "included_photos": package.included_photos,
        "extra_photo_price": str(package.extra_photo_price),
        "proofs_sla_days": package.proofs_sla_days,
        "finals_sla_days": package.finals_sla_days,
        "addons": package.addons,
        "booking_request_id": str(request.id),
    }

    gig = existing_gig or Gig(
        client_user_id=request.client_user_id,
        pro_user_id=request.pro_user_id,
        status=GigStatus.payment_pending,
        currency=package.currency,
        amount_total=amount_total,
        amount_platform_fee=fee,
        amount_pro_gross=pro_gross,
        scheduled_start=request.requested_start,
        scheduled_end=request.requested_end,
        location_text=request.location_text,
        meta={"pricing_snapshot": snapshot, "booking_request_id": str(request.id)},
    )

    if not existing_gig:
        db.add(gig)
        db.flush()

    _, pi = create_or_get_gig_payment_intent(db, gig)

    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="booking_request",
        target_id=str(request.id),
        action="booking_request_accepted",
        reason=None,
        metadata={"gig_id": str(gig.id), "payment_intent_id": pi.id},
    )
    log_event(
        db,
        event_name="booking.accepted",
        user_id=user.user_id,
        properties={"booking_request_id": str(request.id), "gig_id": str(gig.id), "payment_intent_id": pi.id},
    )
    recompute_pro_public_index(db, request.pro_user_id)

    db.commit()
    return AcceptBookingResponse(
        booking_request=_booking_request_view(request),
        gig_id=gig.id,
        payment_intent_id=pi.id,
        payment_intent_client_secret=pi.client_secret,
    )


@router.post("/booking-requests/{request_id}/decline", response_model=BookingRequestView)
def decline_booking_request(
    request_id: uuid.UUID,
    body: BookingDecisionRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingRequestView:
    request = db.get(BookingRequest, request_id)
    if not request:
        raise APIError(code="not_found", message="Booking request not found", status_code=404)
    if request.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only pro can decline", status_code=403)
    if request.status != BookingRequestStatus.pending:
        raise APIError(code="invalid_state", message="Only pending requests can be declined", status_code=409)

    request.status = BookingRequestStatus.declined
    db.add(
        BookingRequestTransition(
            booking_request_id=request.id,
            from_status=BookingRequestStatus.pending,
            to_status=BookingRequestStatus.declined,
            actor_user_id=user.user_id,
            reason=body.reason,
        )
    )
    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="booking_request",
        target_id=str(request.id),
        action="booking_request_declined",
        reason=body.reason,
    )
    recompute_pro_public_index(db, request.pro_user_id)
    db.commit()
    return _booking_request_view(request)


@router.post("/booking-requests/{request_id}/cancel", response_model=BookingRequestView)
def cancel_booking_request(
    request_id: uuid.UUID,
    body: BookingDecisionRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingRequestView:
    request = db.get(BookingRequest, request_id)
    if not request:
        raise APIError(code="not_found", message="Booking request not found", status_code=404)
    if request.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client can cancel", status_code=403)
    if request.status != BookingRequestStatus.pending:
        raise APIError(code="invalid_state", message="Only pending requests can be cancelled", status_code=409)

    request.status = BookingRequestStatus.cancelled
    db.add(
        BookingRequestTransition(
            booking_request_id=request.id,
            from_status=BookingRequestStatus.pending,
            to_status=BookingRequestStatus.cancelled,
            actor_user_id=user.user_id,
            reason=body.reason,
        )
    )
    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="booking_request",
        target_id=str(request.id),
        action="booking_request_cancelled",
        reason=body.reason,
    )
    db.commit()
    return _booking_request_view(request)


@router.post("/admin/jobs/expire-booking-requests")
def expire_booking_requests_job(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    now = datetime.now(timezone.utc)
    pending = db.execute(
        select(BookingRequest).where(BookingRequest.status == BookingRequestStatus.pending, BookingRequest.expires_at < now)
    ).scalars().all()

    for request in pending:
        request.status = BookingRequestStatus.expired
        db.add(
            BookingRequestTransition(
                booking_request_id=request.id,
                from_status=BookingRequestStatus.pending,
                to_status=BookingRequestStatus.expired,
                actor_user_id=request.pro_user_id,
                reason="Expired by job",
            )
        )

    db.commit()
    return {"expired_count": len(pending)}


def _require_role(db: Session, user_id: uuid.UUID, role: UserRoleType) -> None:
    roles = get_user_roles(db, user_id)
    if role not in roles:
        raise APIError(code="forbidden", message=f"Role {role.value} required", status_code=403)


def _ensure_pro_profile(db: Session, user_id: uuid.UUID) -> ProProfile:
    ensure_user_account(db, user_id)
    profile = db.get(ProProfile, user_id)
    if not profile:
        profile = ProProfile(user_id=user_id)
        db.add(profile)
        db.flush()
    return profile


def _compute_completeness(profile: ProProfile) -> int:
    score = 0
    if profile.display_name:
        score += 15
    if profile.headline:
        score += 10
    if profile.bio:
        score += 20
    if profile.city:
        score += 10
    if profile.country:
        score += 10
    if profile.languages:
        score += 10
    if profile.styles:
        score += 10
    if profile.gear:
        score += 15
    return min(score, 100)


def _validate_availability(db: Session, pro_user_id: uuid.UUID, start: datetime, end: datetime) -> None:
    rules = db.execute(select(ProAvailabilityRule).where(ProAvailabilityRule.pro_user_id == pro_user_id)).scalars().all()
    if not rules:
        raise APIError(code="validation_error", message="Pro has no availability configured", status_code=409)

    dow = start.weekday()
    time_start = start.timetz().replace(tzinfo=None)
    time_end = end.timetz().replace(tzinfo=None)

    within_rule = any(
        r.day_of_week == dow and r.start_time <= time_start and r.end_time >= time_end
        for r in rules
    )
    if not within_rule:
        raise APIError(code="validation_error", message="Requested time is outside pro availability", status_code=409)

    overlap = db.execute(
        select(ProBlackoutDate).where(
            ProBlackoutDate.pro_user_id == pro_user_id,
            ProBlackoutDate.start_at < end,
            ProBlackoutDate.end_at > start,
        )
    ).scalar_one_or_none()
    if overlap:
        raise APIError(code="validation_error", message="Requested time overlaps blackout", status_code=409)


def _booking_request_view(request: BookingRequest) -> BookingRequestView:
    return BookingRequestView(
        id=request.id,
        pro_user_id=request.pro_user_id,
        client_user_id=request.client_user_id,
        package_id=request.package_id,
        requested_start=request.requested_start,
        requested_end=request.requested_end,
        location_text=request.location_text,
        notes=request.notes,
        status=request.status,
        expires_at=request.expires_at,
    )


def _package_view(package: ProPackage) -> ProPackageView:
    return ProPackageView(
        id=package.id,
        pro_user_id=package.pro_user_id,
        title=package.title,
        description=package.description,
        duration_minutes=package.duration_minutes,
        price=package.price,
        currency=package.currency,
        included_photos=package.included_photos,
        extra_photo_price=package.extra_photo_price,
        proofs_sla_days=package.proofs_sla_days,
        finals_sla_days=package.finals_sla_days,
        addons=package.addons,
        is_active=package.is_active,
    )


def _profile_view(profile: ProProfile) -> ProProfileView:
    return ProProfileView(
        user_id=profile.user_id,
        display_name=profile.display_name,
        headline=profile.headline,
        bio=profile.bio,
        city=profile.city,
        country=profile.country,
        languages=profile.languages or [],
        styles=profile.styles or [],
        gear=profile.gear or {},
        is_accepting_bookings=profile.is_accepting_bookings,
        completeness_score=profile.completeness_score,
        kyc_status=profile.kyc_status.value,
    )


def _find_gig_by_booking_request(db: Session, booking_request_id: uuid.UUID) -> Gig | None:
    gigs = db.execute(select(Gig)).scalars().all()
    for gig in gigs:
        if (gig.meta or {}).get("booking_request_id") == str(booking_request_id):
            return gig
    return None
