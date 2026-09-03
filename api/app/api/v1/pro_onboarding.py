from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_session, require_admin, require_not_banned
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
from app.models.media import MediaAsset, MediaKind, MediaPurpose
from app.models.niche import Niche, ProNiche, ProNicheSkill, SkillTier
from app.schemas.media import CurrentUser
from app.schemas.niche import (
    PortfolioNicheTagsRequest,
    PortfolioNicheTagsResponse,
    ProNicheSkillListResponse,
    ProNicheSkillView,
    ProNicheView,
    UpdateMyNichesRequest,
    UpdateMyNichesResponse,
)
from app.schemas.onboarding import (
    AcceptBookingResponse,
    BlackoutCreateRequest,
    BlackoutView,
    BookingDecisionRequest,
    BookingRequestCreateRequest,
    BookingRequestListItem,
    BookingRequestListResponse,
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
from app.schemas.launch_ops import (
    ProOnboardingChecksResponse,
    ProOnboardingStartRequest,
    ProOnboardingStatusResponse,
)
from app.services.audit import add_admin_audit_log
from app.services.analytics import log_event
from app.services.authz import ensure_user_account, get_user_roles
from app.services.discovery_index import recompute_pro_public_index
from app.services.followups import schedule_followups
from app.services.niche_catalog import ensure_initial_niches, get_niche_map_by_ids, get_niche_map_by_slugs
from app.services.niche_skills import list_user_badge_codes, recompute_pro_niche_skills
from app.services.package_pricing import compute_minimum_amount, enforce_entry_price_cap
from app.services.pagination import DEFAULT_LIMIT, MAX_LIMIT, apply_keyset, build_page
from app.services.rate_limit import enforce_named_rate_limit
from app.services.scheduling import expire_pending_booking_requests
from app.services.payment_intents import create_or_get_gig_payment_intent
from app.services.media_rights import ensure_gig_consent_snapshot
from app.services.disputes import capture_gig_contract_snapshot
from app.services.launch_ops import (
    get_or_create_pro_onboarding,
    maybe_advance_to_ready_for_review,
    onboarding_checks,
    set_pro_onboarding_status,
    start_pro_onboarding,
)
from app.models.launch_ops import ProOnboardingActorType, ProOnboardingStatus

settings = get_settings()
router = APIRouter(tags=["pro_onboarding"])


@router.get("/pro/onboarding", response_model=ProOnboardingStatusResponse)
def get_my_onboarding(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    row = get_or_create_pro_onboarding(db, pro_user_id=user.user_id)
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/pro/onboarding/start", response_model=ProOnboardingStatusResponse)
def start_my_onboarding(
    body: ProOnboardingStartRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    row = start_pro_onboarding(
        db,
        pro_user_id=user.user_id,
        city=body.city,
        country=body.country,
        invite_code=body.invite_code,
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/pro/onboarding/complete-profile", response_model=ProOnboardingStatusResponse)
def complete_profile_onboarding_stage(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    checks = onboarding_checks(db, pro_user_id=user.user_id)
    if not checks.get("profile_completed"):
        raise APIError(code="validation_error", message="Profile requirements not satisfied", status_code=422)
    row = set_pro_onboarding_status(
        db,
        pro_user_id=user.user_id,
        to_status=ProOnboardingStatus.profile_completed,
        actor_type=ProOnboardingActorType.pro,
        actor_user_id=user.user_id,
        note="profile_completed",
        payload={"checks": checks},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/pro/onboarding/upload-portfolio", response_model=ProOnboardingStatusResponse)
def complete_portfolio_onboarding_stage(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    checks = onboarding_checks(db, pro_user_id=user.user_id)
    if not checks.get("portfolio_uploaded"):
        raise APIError(code="validation_error", message="Portfolio minimum not satisfied", status_code=422)
    row = set_pro_onboarding_status(
        db,
        pro_user_id=user.user_id,
        to_status=ProOnboardingStatus.portfolio_uploaded,
        actor_type=ProOnboardingActorType.pro,
        actor_user_id=user.user_id,
        note="portfolio_uploaded",
        payload={"checks": checks},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/pro/onboarding/configure-packages", response_model=ProOnboardingStatusResponse)
def complete_packages_onboarding_stage(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    checks = onboarding_checks(db, pro_user_id=user.user_id)
    if not checks.get("packages_configured"):
        raise APIError(code="validation_error", message="Package requirements not satisfied", status_code=422)
    row = set_pro_onboarding_status(
        db,
        pro_user_id=user.user_id,
        to_status=ProOnboardingStatus.packages_configured,
        actor_type=ProOnboardingActorType.pro,
        actor_user_id=user.user_id,
        note="packages_configured",
        payload={"checks": checks},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/pro/onboarding/select-niches", response_model=ProOnboardingStatusResponse)
def complete_niches_onboarding_stage(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    checks = onboarding_checks(db, pro_user_id=user.user_id)
    if not checks.get("niches_selected"):
        raise APIError(code="validation_error", message="Niche minimum not satisfied", status_code=422)
    row = set_pro_onboarding_status(
        db,
        pro_user_id=user.user_id,
        to_status=ProOnboardingStatus.niches_selected,
        actor_type=ProOnboardingActorType.pro,
        actor_user_id=user.user_id,
        note="niches_selected",
        payload={"checks": checks},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/pro/onboarding/submit-kyc", response_model=ProOnboardingStatusResponse)
def submit_kyc_onboarding_stage(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    profile = _ensure_pro_profile(db, user.user_id)
    if profile.kyc_status == KYCStatus.unsubmitted:
        profile.kyc_status = KYCStatus.pending
        profile.kyc_updated_at = datetime.now(timezone.utc)
    checks = onboarding_checks(db, pro_user_id=user.user_id)
    if not checks.get("kyc_submitted"):
        raise APIError(code="validation_error", message="KYC must be submitted", status_code=422)
    row = set_pro_onboarding_status(
        db,
        pro_user_id=user.user_id,
        to_status=ProOnboardingStatus.kyc_submitted,
        actor_type=ProOnboardingActorType.pro,
        actor_user_id=user.user_id,
        note="kyc_submitted",
        payload={"checks": checks},
    )
    if profile.kyc_status == KYCStatus.approved:
        row = set_pro_onboarding_status(
            db,
            pro_user_id=user.user_id,
            to_status=ProOnboardingStatus.kyc_approved,
            actor_type=ProOnboardingActorType.system,
            actor_user_id=None,
            note="kyc_already_approved",
            payload={},
        )
        row = maybe_advance_to_ready_for_review(db, pro_user_id=user.user_id)
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.get("/pro/onboarding/checks", response_model=ProOnboardingChecksResponse)
def get_onboarding_checks(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProOnboardingChecksResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    row = get_or_create_pro_onboarding(db, pro_user_id=user.user_id)
    checks = onboarding_checks(db, pro_user_id=user.user_id)
    missing = [k for k in ["profile_completed", "portfolio_uploaded", "packages_configured", "niches_selected", "kyc_submitted", "kyc_approved"] if not checks.get(k)]
    db.commit()
    return ProOnboardingChecksResponse(status=row.status, checks=checks, missing=missing)


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

    for field in ["display_name", "headline", "cover_media_asset_id", "bio", "city", "country", "languages", "styles", "gear"]:
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
    niche = _resolve_package_niche(db, body.niche_id, body.niche_slug)
    entry_price = body.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    tier = _resolve_pro_tier_for_niche(db, user.user_id, niche.id)
    enforce_entry_price_cap(db, niche_id=niche.id, tier=tier, entry_price=entry_price)
    package = ProPackage(
        pro_user_id=user.user_id,
        niche_id=niche.id,
        title=body.title,
        description=body.description,
        duration_minutes=body.duration_minutes,
        price=entry_price,
        currency=body.currency.upper(),
        included_photos=body.included_photos,
        extra_photo_price=body.extra_photo_price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP),
        proofs_sla_days=body.proofs_sla_days,
        finals_sla_days=body.finals_sla_days,
        addons=body.addons,
        is_active=True,
    )
    db.add(package)
    recompute_pro_niche_skills(db, user.user_id, niche.id)
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

    if body.niche_id is None and body.niche_slug is None:
        raise APIError(code="validation_error", message="niche_id or niche_slug is required", status_code=400)
    niche = _resolve_package_niche(db, body.niche_id, body.niche_slug)
    package.niche_id = niche.id

    if body.price is not None:
        entry_price = body.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        tier = _resolve_pro_tier_for_niche(db, user.user_id, niche.id)
        enforce_entry_price_cap(db, niche_id=niche.id, tier=tier, entry_price=entry_price)

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
    recompute_pro_niche_skills(db, user.user_id, niche.id)
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
    recompute_pro_niche_skills(db, user.user_id, package.niche_id)
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


@router.get("/niches", response_model=list[dict[str, str]])
def list_niches(db: Session = Depends(get_db_session)) -> list[dict[str, str]]:
    ensure_initial_niches(db)
    rows = db.execute(select(Niche).where(Niche.is_active.is_(True)).order_by(Niche.name.asc())).scalars().all()
    db.commit()
    return [{"slug": row.slug, "name": row.name} for row in rows]


@router.get("/pro/niches/mine", response_model=UpdateMyNichesResponse)
def get_my_selected_niches(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UpdateMyNichesResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    rows = db.execute(select(ProNiche).where(ProNiche.pro_user_id == user.user_id)).scalars().all()
    view_niche_map = get_niche_map_by_ids(db, [row.niche_id for row in rows])
    primary_slug = None
    items: list[ProNicheView] = []
    for row in rows:
        niche = view_niche_map.get(row.niche_id)
        if not niche:
            continue
        if row.is_primary:
            primary_slug = niche.slug
        items.append(
            ProNicheView(
                slug=niche.slug,
                name=niche.name,
                declared_level=row.declared_level,
                is_primary=row.is_primary,
            )
        )
    db.commit()
    return UpdateMyNichesResponse(primary_niche_slug=primary_slug, niches=items)


@router.put("/pro/niches/mine", response_model=UpdateMyNichesResponse)
def put_my_selected_niches(
    body: UpdateMyNichesRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UpdateMyNichesResponse:
    return update_my_niches(body=body, user=user, db=db)


@router.put("/pro/me/niches", response_model=UpdateMyNichesResponse)
def update_my_niches(
    body: UpdateMyNichesRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UpdateMyNichesResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    ensure_initial_niches(db)

    requested_slugs = [item.slug for item in body.niches]
    if body.primary_niche_slug:
        requested_slugs.append(body.primary_niche_slug)
    niche_map = get_niche_map_by_slugs(db, requested_slugs)
    missing = sorted(set(requested_slugs) - set(niche_map.keys()))
    if missing:
        raise APIError(code="validation_error", message=f"Unknown niche slug(s): {', '.join(missing)}", status_code=422)

    incoming_by_niche_id = {niche_map[item.slug].id: item for item in body.niches}
    existing = db.execute(select(ProNiche).where(ProNiche.pro_user_id == user.user_id)).scalars().all()
    existing_by_niche_id = {row.niche_id: row for row in existing}

    for niche_id, payload in incoming_by_niche_id.items():
        row = existing_by_niche_id.get(niche_id)
        if not row:
            row = ProNiche(pro_user_id=user.user_id, niche_id=niche_id, created_at=datetime.now(timezone.utc))
            db.add(row)
        row.declared_level = payload.declared_level
        row.is_primary = payload.is_primary

    for row in existing:
        if row.niche_id not in incoming_by_niche_id:
            db.delete(row)

    explicit_primary_slug = body.primary_niche_slug
    if explicit_primary_slug:
        primary_niche_id = niche_map[explicit_primary_slug].id
        primary_row = db.execute(
            select(ProNiche).where(ProNiche.pro_user_id == user.user_id, ProNiche.niche_id == primary_niche_id)
        ).scalar_one_or_none()
        if not primary_row:
            primary_row = ProNiche(
                pro_user_id=user.user_id,
                niche_id=primary_niche_id,
                declared_level=None,
                is_primary=True,
                created_at=datetime.now(timezone.utc),
            )
            db.add(primary_row)
        current = db.execute(select(ProNiche).where(ProNiche.pro_user_id == user.user_id)).scalars().all()
        for row in current:
            row.is_primary = row.niche_id == primary_niche_id

    niche_ids_for_compute = list(incoming_by_niche_id.keys())
    if explicit_primary_slug:
        niche_ids_for_compute.append(niche_map[explicit_primary_slug].id)
    for niche_id in set(niche_ids_for_compute):
        recompute_pro_niche_skills(db, user.user_id, niche_id)
    recompute_pro_public_index(db, user.user_id)
    db.commit()

    rows = db.execute(select(ProNiche).where(ProNiche.pro_user_id == user.user_id)).scalars().all()
    view_niche_map = get_niche_map_by_ids(db, [row.niche_id for row in rows])
    primary_slug = None
    items: list[ProNicheView] = []
    for row in rows:
        niche = view_niche_map.get(row.niche_id)
        if not niche:
            continue
        if row.is_primary:
            primary_slug = niche.slug
        items.append(
            ProNicheView(
                slug=niche.slug,
                name=niche.name,
                declared_level=row.declared_level,
                is_primary=row.is_primary,
            )
        )
    return UpdateMyNichesResponse(primary_niche_slug=primary_slug, niches=items)


@router.post("/pro/me/portfolio/{media_asset_id}/niches", response_model=PortfolioNicheTagsResponse)
def tag_portfolio_media_niches(
    media_asset_id: uuid.UUID,
    body: PortfolioNicheTagsRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PortfolioNicheTagsResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    ensure_initial_niches(db)
    asset = db.get(MediaAsset, media_asset_id)
    if not asset:
        raise APIError(code="not_found", message="Media asset not found", status_code=404)
    if asset.owner_user_id != user.user_id:
        raise APIError(code="forbidden", message="Not owner of media asset", status_code=403)
    if asset.purpose != MediaPurpose.portfolio_reel or asset.kind not in {MediaKind.photo, MediaKind.video}:
        raise APIError(code="validation_error", message="Only portfolio photo/video assets can be tagged", status_code=422)

    niche_map = get_niche_map_by_slugs(db, body.niche_slugs)
    missing = sorted(set(body.niche_slugs) - set(niche_map.keys()))
    if missing:
        raise APIError(code="validation_error", message=f"Unknown niche slug(s): {', '.join(missing)}", status_code=422)

    previous_tags = set(asset.niche_tags or [])
    normalized = sorted(set(body.niche_slugs))
    asset.niche_tags = normalized
    changed_tags = previous_tags.union(set(normalized))

    for slug in changed_tags:
        niche = niche_map.get(slug) or db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
        if niche:
            recompute_pro_niche_skills(db, user.user_id, niche.id)
    recompute_pro_public_index(db, user.user_id)
    db.commit()
    return PortfolioNicheTagsResponse(media_asset_id=asset.id, niche_slugs=normalized)


@router.get("/pros/{pro_user_id}/skills", response_model=ProNicheSkillListResponse)
def get_pro_niche_skills(
    pro_user_id: uuid.UUID,
    db: Session = Depends(get_db_session),
) -> ProNicheSkillListResponse:
    ensure_initial_niches(db)
    rows = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == pro_user_id, Niche.is_active.is_(True))
        .order_by(ProNicheSkill.capability_score.desc(), ProNicheSkill.confidence.desc())
    ).all()
    badge_codes = set(list_user_badge_codes(db, pro_user_id))
    items = [
        ProNicheSkillView(
            niche_slug=niche.slug,
            niche_name=niche.name,
            tier=skill.tier,
            score=skill.score,
            verified=skill.verified,
            gigs_completed=skill.gigs_completed,
            avg_rating=float(skill.avg_rating or 0),
            review_count=skill.review_count,
            capability_score=skill.capability_score,
            certification_score=skill.certification_score,
            confidence=float(skill.confidence),
            evidence_gigs=skill.evidence_gigs,
            evidence_reviews=skill.evidence_reviews,
            evidence_portfolio=skill.evidence_portfolio,
            breakdown=_sanitize_public_breakdown(skill.breakdown),
            badges=sorted([code for code in badge_codes if code.startswith(f"tier_{niche.slug}_") or code == f"verified_{niche.slug}"]),
            last_promotion_at=skill.last_promotion_at,
            last_demotion_at=skill.last_demotion_at,
            updated_at=skill.updated_at,
        )
        for skill, niche in rows
    ]
    return ProNicheSkillListResponse(pro_user_id=pro_user_id, items=items)


@router.get("/pro/me/skills", response_model=ProNicheSkillListResponse)
def get_my_niche_skills(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ProNicheSkillListResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    recompute_pro_niche_skills(db, user.user_id)
    rows = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == user.user_id, Niche.is_active.is_(True))
        .order_by(ProNicheSkill.capability_score.desc(), ProNicheSkill.confidence.desc())
    ).all()
    db.commit()
    badge_codes = set(list_user_badge_codes(db, user.user_id))
    items = [
        ProNicheSkillView(
            niche_slug=niche.slug,
            niche_name=niche.name,
            tier=skill.tier,
            score=skill.score,
            verified=skill.verified,
            gigs_completed=skill.gigs_completed,
            avg_rating=float(skill.avg_rating or 0),
            review_count=skill.review_count,
            capability_score=skill.capability_score,
            certification_score=skill.certification_score,
            confidence=float(skill.confidence),
            evidence_gigs=skill.evidence_gigs,
            evidence_reviews=skill.evidence_reviews,
            evidence_portfolio=skill.evidence_portfolio,
            breakdown=skill.breakdown or {},
            badges=sorted([code for code in badge_codes if code.startswith(f"tier_{niche.slug}_") or code == f"verified_{niche.slug}"]),
            last_promotion_at=skill.last_promotion_at,
            last_demotion_at=skill.last_demotion_at,
            updated_at=skill.updated_at,
        )
        for skill, niche in rows
    ]
    return ProNicheSkillListResponse(pro_user_id=user.user_id, items=items)


@router.post("/pros/{pro_user_id}/booking-requests", response_model=BookingRequestView)
def create_booking_request(
    pro_user_id: uuid.UUID,
    body: BookingRequestCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingRequestView:
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
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
        expires_at=datetime.now(timezone.utc) + timedelta(hours=settings.booking_response_deadline_hours),
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
    schedule_followups(
        db,
        trigger="booking_request.pending.client",
        user_id=request.client_user_id,
        target_type="booking_request",
        target_id=request.id,
    )
    schedule_followups(
        db,
        trigger="booking_request.pending.pro",
        user_id=request.pro_user_id,
        target_type="booking_request",
        target_id=request.id,
    )
    db.commit()
    db.refresh(request)
    return _booking_request_view(request)


@router.get("/booking-requests", response_model=BookingRequestListResponse)
def list_booking_requests(
    status: BookingRequestStatus | None = Query(default=None),
    cursor: str | None = Query(default=None),
    limit: int = Query(default=DEFAULT_LIMIT, ge=1, le=MAX_LIMIT),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> BookingRequestListResponse:
    """The authenticated pro's own booking requests, newest first.

    Scoped to `pro_user_id` only. The client side of the same underlying
    rows is served by `GET /v1/client/bookings`, which returns a different
    shape (booking/gig/payment status rolled together) because the two
    audiences are answering different questions: a pro asks "what needs my
    decision", a client asks "where is my booking up to".
    """
    query = select(BookingRequest).where(BookingRequest.pro_user_id == user.user_id)
    if status is not None:
        query = query.where(BookingRequest.status == status)

    rows = db.execute(apply_keyset(query, BookingRequest, cursor, limit)).scalars().all()
    page, next_cursor = build_page(list(rows), limit)
    now = datetime.now(timezone.utc)
    return BookingRequestListResponse(
        items=[_booking_request_list_item(row, now=now) for row in page],
        next_cursor=next_cursor,
    )


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
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    enforce_named_rate_limit("payments", principal=str(user.user_id))
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
        ensure_gig_consent_snapshot(db, existing_gig, actor_user_id=user.user_id)
        capture_gig_contract_snapshot(db, existing_gig)
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

    entry_rate = package.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    amount_minimum = compute_minimum_amount(db, niche_id=package.niche_id, entry_rate=entry_rate)
    fee = (amount_minimum * Decimal(settings.platform_fee_bps) / Decimal(10000)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    pro_gross = (amount_minimum - fee).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    snapshot = {
        "package_id": str(package.id),
        "niche_slug": None,
        "niche_name": None,
        "package_title": package.title,
        "duration_minutes": package.duration_minutes,
        "included_photos": package.included_photos,
        "extra_photo_price": str(package.extra_photo_price),
        "proofs_sla_days": package.proofs_sla_days,
        "finals_sla_days": package.finals_sla_days,
        "addons": package.addons,
        "booking_request_id": str(request.id),
    }
    niche = db.get(Niche, package.niche_id)
    if niche:
        snapshot["niche_slug"] = niche.slug
        snapshot["niche_name"] = niche.name

    gig = existing_gig or Gig(
        client_user_id=request.client_user_id,
        pro_user_id=request.pro_user_id,
        status=GigStatus.payment_pending,
        niche_id=package.niche_id,
        currency=package.currency,
        amount_minimum=amount_minimum,
        entry_rate=entry_rate,
        amount_platform_fee=fee,
        amount_pro_gross=pro_gross,
        scheduled_start=request.requested_start,
        scheduled_end=request.requested_end,
        location_text=request.location_text,
        meta={
            "pricing_snapshot": snapshot,
            "booking_request_id": str(request.id),
            "niche_slug": snapshot["niche_slug"],
            "niche_name": snapshot["niche_name"],
        },
    )
    if existing_gig:
        gig.niche_id = package.niche_id
        existing_meta = gig.meta or {}
        pricing_snapshot = existing_meta.get("pricing_snapshot", {})
        pricing_snapshot["niche_slug"] = snapshot["niche_slug"]
        pricing_snapshot["niche_name"] = snapshot["niche_name"]
        existing_meta["pricing_snapshot"] = pricing_snapshot
        existing_meta["niche_slug"] = snapshot["niche_slug"]
        existing_meta["niche_name"] = snapshot["niche_name"]
        gig.meta = existing_meta

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
    schedule_followups(
        db,
        trigger="booking_request.accepted.client",
        user_id=request.client_user_id,
        target_type="booking_request",
        target_id=request.id,
    )
    schedule_followups(
        db,
        trigger="payment_pending.client",
        user_id=request.client_user_id,
        target_type="gig",
        target_id=gig.id,
    )
    ensure_gig_consent_snapshot(db, gig, actor_user_id=user.user_id)
    capture_gig_contract_snapshot(db, gig)
    recompute_pro_public_index(db, request.pro_user_id)
    recompute_pro_niche_skills(db, request.pro_user_id, package.niche_id)

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
    expired_count = expire_pending_booking_requests(db, limit=None)
    db.commit()
    return {"expired_count": expired_count}


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


def _booking_request_list_item(request: BookingRequest, *, now: datetime) -> BookingRequestListItem:
    # Only a pending request has a live countdown - once it's accepted,
    # declined, expired or cancelled the deadline is history, and sending a
    # number would invite a UI that counts down on a settled request.
    seconds_left: int | None = None
    if request.status == BookingRequestStatus.pending:
        expires_at = request.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=timezone.utc)
        seconds_left = int((expires_at - now).total_seconds())

    return BookingRequestListItem(
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
        created_at=request.created_at,
        seconds_until_expiry=seconds_left,
    )


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
        niche_id=package.niche_id,
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
        cover_media_asset_id=profile.cover_media_asset_id,
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


def _resolve_package_niche(db: Session, niche_id: uuid.UUID | None, niche_slug: str | None) -> Niche:
    ensure_initial_niches(db)
    if niche_id and niche_slug:
        by_slug = db.execute(select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
        if not by_slug or by_slug.id != niche_id:
            raise APIError(code="validation_error", message="niche_id and niche_slug do not match", status_code=422)
        return by_slug
    if niche_id:
        niche = db.execute(select(Niche).where(Niche.id == niche_id, Niche.is_active.is_(True))).scalar_one_or_none()
        if not niche:
            raise APIError(code="validation_error", message="Unknown niche_id", status_code=422)
        return niche
    if niche_slug:
        niche = db.execute(select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
        if not niche:
            raise APIError(code="validation_error", message="Unknown niche_slug", status_code=422)
        return niche
    raise APIError(code="validation_error", message="niche_id or niche_slug is required", status_code=400)


def _resolve_pro_tier_for_niche(db: Session, pro_user_id: uuid.UUID, niche_id: uuid.UUID) -> SkillTier:
    skill = db.execute(
        select(ProNicheSkill).where(
            ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id
        )
    ).scalar_one_or_none()
    return skill.tier if skill else SkillTier.rookie


def _sanitize_public_breakdown(breakdown: dict | None) -> dict:
    data = dict(breakdown or {})
    if "override" in data:
        data["override"] = {"active": True}
    return data
