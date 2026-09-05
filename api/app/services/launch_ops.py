from __future__ import annotations

import secrets
import uuid
from datetime import datetime, timezone

from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import BanAction, BanActionType, KYCStatus, ProProfile, UserRoleType
from app.models.booking import ProPackage
from app.models.client_rewards_pricing import ProExtraImagePrice
from app.models.launch_ops import (
    InviteAllowedRole,
    InviteCode,
    InviteCodeStatus,
    InviteWave,
    OnboardingRequirement,
    ProOnboarding,
    ProOnboardingActorType,
    ProOnboardingEvent,
    ProOnboardingStatus,
    RolloutCity,
    RolloutFlagOverride,
)
from app.models.media import MediaAsset, MediaPurpose, MediaStatus
from app.models.niche import ProNiche
from app.services.analytics import log_event
from app.services.feature_flags import is_feature_enabled
from app.services.notifications import enqueue_notification
from app.services.outbox import enqueue_outbox_event
from app.services.gamification import queue_evaluate_user_milestones


_TRANSITIONS: dict[ProOnboardingStatus, set[ProOnboardingStatus]] = {
    ProOnboardingStatus.started: {ProOnboardingStatus.profile_completed, ProOnboardingStatus.rejected},
    ProOnboardingStatus.profile_completed: {ProOnboardingStatus.portfolio_uploaded, ProOnboardingStatus.rejected},
    ProOnboardingStatus.portfolio_uploaded: {ProOnboardingStatus.packages_configured, ProOnboardingStatus.rejected},
    ProOnboardingStatus.packages_configured: {ProOnboardingStatus.niches_selected, ProOnboardingStatus.rejected},
    ProOnboardingStatus.niches_selected: {ProOnboardingStatus.kyc_submitted, ProOnboardingStatus.rejected},
    ProOnboardingStatus.kyc_submitted: {ProOnboardingStatus.kyc_approved, ProOnboardingStatus.rejected},
    ProOnboardingStatus.kyc_approved: {ProOnboardingStatus.ready_for_review, ProOnboardingStatus.rejected},
    ProOnboardingStatus.ready_for_review: {ProOnboardingStatus.approved_public, ProOnboardingStatus.rejected},
    ProOnboardingStatus.approved_public: set(),
    ProOnboardingStatus.rejected: {ProOnboardingStatus.started, ProOnboardingStatus.profile_completed},
}


def ensure_default_onboarding_requirements(db: Session) -> None:
    defaults = {
        "portfolio_min_items": {"count": 12},
        "packages_required": {"enabled": True},
        "niches_min": {"count": 1},
        "require_extra_image_price_config": {"enabled": True},
        "require_identity_verified": {"enabled": True},
    }
    for key, value in defaults.items():
        row = db.execute(select(OnboardingRequirement).where(OnboardingRequirement.key == key)).scalar_one_or_none()
        if row:
            continue
        db.add(OnboardingRequirement(key=key, value=value))
    db.flush()


def requirement_value(db: Session, key: str, default: dict) -> dict:
    row = db.execute(select(OnboardingRequirement).where(OnboardingRequirement.key == key)).scalar_one_or_none()
    return row.value if row else default


def normalize_city_country(*, city: str, country: str) -> tuple[str, str]:
    normalized_city = city.strip()
    normalized_country = country.strip().upper()
    if not normalized_city or not normalized_country:
        raise APIError(code="validation_error", message="city and country are required", status_code=422)
    return normalized_city, normalized_country


def get_rollout_city(db: Session, *, city: str, country: str) -> RolloutCity | None:
    return db.execute(
        select(RolloutCity).where(
            func.lower(RolloutCity.city) == city.strip().lower(),
            func.upper(RolloutCity.country) == country.strip().upper(),
        )
    ).scalar_one_or_none()


def get_active_rollout_override(db: Session, *, user_id: uuid.UUID) -> RolloutFlagOverride | None:
    row = db.execute(select(RolloutFlagOverride).where(RolloutFlagOverride.user_id == user_id)).scalar_one_or_none()
    if not row:
        return None
    if row.expires_at and row.expires_at < datetime.now(timezone.utc):
        return None
    return row


def validate_invite_code_for_role(
    db: Session,
    *,
    code: str,
    role: UserRoleType,
    city: str | None = None,
    country: str | None = None,
) -> InviteCode:
    row = db.execute(select(InviteCode).where(InviteCode.code == code.strip())).scalar_one_or_none()
    if not row:
        raise APIError(code="not_found", message="Invite code not found", status_code=404)
    if row.status != InviteCodeStatus.issued:
        raise APIError(code="invalid_state", message="Invite code is not active", status_code=409)
    wave = db.get(InviteWave, row.wave_id)
    if not wave or not wave.is_active:
        raise APIError(code="invalid_state", message="Invite wave is inactive", status_code=409)
    if wave.expires_at and wave.expires_at < datetime.now(timezone.utc):
        row.status = InviteCodeStatus.expired
        db.flush()
        raise APIError(code="invalid_state", message="Invite code expired", status_code=409)

    if wave.allowed_role == InviteAllowedRole.pro and role != UserRoleType.pro:
        raise APIError(code="forbidden", message="Invite code not valid for role", status_code=403)
    if wave.allowed_role == InviteAllowedRole.client and role != UserRoleType.client:
        raise APIError(code="forbidden", message="Invite code not valid for role", status_code=403)

    allowed_cities = wave.allowed_cities or []
    if allowed_cities and city and country:
        city_ok = any(
            (item or {}).get("city", "").strip().lower() == city.strip().lower()
            and (item or {}).get("country", "").strip().upper() == country.strip().upper()
            for item in allowed_cities
        )
        if not city_ok:
            raise APIError(code="forbidden", message="Invite code not valid for this city", status_code=403)

    return row


def can_start_pro_onboarding(
    db: Session,
    *,
    user_id: uuid.UUID,
    city: str,
    country: str,
    invite: InviteCode | None,
) -> bool:
    if not is_feature_enabled(db, "pro_onboarding_enabled", user_id=user_id):
        return False
    override = get_active_rollout_override(db, user_id=user_id)
    if override and override.can_access_pro_onboarding:
        return True
    rollout = get_rollout_city(db, city=city, country=country)
    if rollout and rollout.is_pro_onboarding_enabled:
        return True
    return invite is not None


def get_or_create_pro_onboarding(db: Session, *, pro_user_id: uuid.UUID) -> ProOnboarding:
    row = db.get(ProOnboarding, pro_user_id)
    if row:
        return row
    row = ProOnboarding(pro_user_id=pro_user_id, status=ProOnboardingStatus.started, current_city=None, notes=None)
    db.add(row)
    db.flush()
    db.add(
        ProOnboardingEvent(
            pro_user_id=pro_user_id,
            from_status=None,
            to_status=ProOnboardingStatus.started.value,
            actor_type=ProOnboardingActorType.system,
            actor_user_id=None,
            note="initialized",
            payload={},
        )
    )
    db.flush()
    return row


def redeem_invite_code(db: Session, *, invite: InviteCode, user_id: uuid.UUID) -> None:
    if invite.redeemed_by_user_id and invite.redeemed_by_user_id != user_id:
        raise APIError(code="invalid_state", message="Invite already redeemed", status_code=409)
    if invite.status != InviteCodeStatus.issued:
        raise APIError(code="invalid_state", message="Invite code not redeemable", status_code=409)
    wave = db.get(InviteWave, invite.wave_id)
    if not wave:
        raise APIError(code="not_found", message="Invite wave not found", status_code=404)
    invite.redeemed_by_user_id = user_id
    invite.redeemed_at = datetime.now(timezone.utc)
    invite.status = InviteCodeStatus.redeemed
    db.flush()


def start_pro_onboarding(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    city: str,
    country: str,
    invite_code: str | None,
) -> ProOnboarding:
    ensure_default_onboarding_requirements(db)
    normalized_city, normalized_country = normalize_city_country(city=city, country=country)
    invite: InviteCode | None = None
    if invite_code:
        invite = validate_invite_code_for_role(
            db,
            code=invite_code,
            role=UserRoleType.pro,
            city=normalized_city,
            country=normalized_country,
        )
    if not can_start_pro_onboarding(db, user_id=pro_user_id, city=normalized_city, country=normalized_country, invite=invite):
        raise APIError(code="forbidden", message="Pro onboarding is not enabled for this city", status_code=403)

    row = get_or_create_pro_onboarding(db, pro_user_id=pro_user_id)
    row.current_city = {"city": normalized_city, "country": normalized_country}
    if invite:
        redeem_invite_code(db, invite=invite, user_id=pro_user_id)
        row.invite_code_id = invite.id
    db.add(
        ProOnboardingEvent(
            pro_user_id=pro_user_id,
            from_status=row.status.value if row.status else None,
            to_status=row.status.value,
            actor_type=ProOnboardingActorType.pro,
            actor_user_id=pro_user_id,
            note="onboarding_started",
            payload={"city": normalized_city, "country": normalized_country, "invite_code_id": str(row.invite_code_id) if row.invite_code_id else None},
        )
    )
    log_event(db, event_name="onboarding.started", user_id=pro_user_id, properties={"city": normalized_city, "country": normalized_country})
    db.flush()
    return row


def onboarding_checks(db: Session, *, pro_user_id: uuid.UUID) -> dict:
    ensure_default_onboarding_requirements(db)
    profile = db.get(ProProfile, pro_user_id)
    if not profile:
        raise APIError(code="not_found", message="Pro profile not found", status_code=404)

    portfolio_min = int(requirement_value(db, "portfolio_min_items", {"count": 12}).get("count", 12))
    niches_min = int(requirement_value(db, "niches_min", {"count": 1}).get("count", 1))
    require_packages = bool(requirement_value(db, "packages_required", {"enabled": True}).get("enabled", True))
    require_extra_price = bool(requirement_value(db, "require_extra_image_price_config", {"enabled": True}).get("enabled", True))
    require_identity = bool(requirement_value(db, "require_identity_verified", {"enabled": True}).get("enabled", True))

    profile_completed = bool(profile.display_name and profile.bio and profile.city and profile.country and profile.completeness_score >= 60)
    portfolio_count = db.execute(
        select(func.count()).select_from(MediaAsset).where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
    ).scalar_one()
    portfolio_uploaded = portfolio_count >= portfolio_min

    active_packages = db.execute(
        select(ProPackage).where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
    ).scalars().all()
    package_niche_ids = {item.niche_id for item in active_packages}
    packages_configured = (not require_packages) or len(active_packages) > 0
    if packages_configured and require_extra_price and package_niche_ids:
        configured_niche_ids = set(
            db.execute(
                select(ProExtraImagePrice.niche_id).where(
                    ProExtraImagePrice.pro_user_id == pro_user_id,
                    ProExtraImagePrice.niche_id.in_(package_niche_ids),
                )
            ).scalars().all()
        )
        packages_configured = package_niche_ids.issubset(configured_niche_ids)

    niches_count = db.execute(select(func.count()).select_from(ProNiche).where(ProNiche.pro_user_id == pro_user_id)).scalar_one()
    niches_selected = niches_count >= niches_min

    kyc_submitted = profile.kyc_status in {KYCStatus.pending, KYCStatus.approved}
    kyc_approved = (not require_identity) or profile.kyc_status == KYCStatus.approved

    ready_for_review = profile_completed and portfolio_uploaded and packages_configured and niches_selected and kyc_approved
    return {
        "profile_completed": profile_completed,
        "portfolio_uploaded": portfolio_uploaded,
        "packages_configured": packages_configured,
        "niches_selected": niches_selected,
        "kyc_submitted": kyc_submitted,
        "kyc_approved": kyc_approved,
        "ready_for_review": ready_for_review,
        "portfolio_count": int(portfolio_count),
        "portfolio_min_required": portfolio_min,
        "active_packages_count": len(active_packages),
        "niches_count": int(niches_count),
    }


def set_pro_onboarding_status(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    to_status: ProOnboardingStatus,
    actor_type: ProOnboardingActorType,
    actor_user_id: uuid.UUID | None,
    note: str | None = None,
    payload: dict | None = None,
    validate_transition: bool = True,
) -> ProOnboarding:
    row = get_or_create_pro_onboarding(db, pro_user_id=pro_user_id)
    from_status = row.status
    if from_status == to_status:
        return row
    if validate_transition and to_status not in _TRANSITIONS.get(from_status, set()):
        raise APIError(
            code="invalid_state_transition",
            message=f"Cannot transition from {from_status.value} to {to_status.value}",
            status_code=409,
        )
    row.status = to_status
    db.add(
        ProOnboardingEvent(
            pro_user_id=pro_user_id,
            from_status=from_status.value if from_status else None,
            to_status=to_status.value,
            actor_type=actor_type,
            actor_user_id=actor_user_id,
            note=note,
            payload=payload or {},
        )
    )
    log_event(
        db,
        event_name="onboarding.stage_completed" if to_status not in {ProOnboardingStatus.approved_public, ProOnboardingStatus.rejected} else (
            "onboarding.approved" if to_status == ProOnboardingStatus.approved_public else "onboarding.rejected"
        ),
        user_id=pro_user_id,
        properties={"from_status": from_status.value if from_status else None, "to_status": to_status.value},
    )

    if to_status == ProOnboardingStatus.approved_public:
        enqueue_outbox_event(
            db,
            topic="reindex.pro",
            payload={"pro_user_id": str(pro_user_id)},
            idempotency_key=f"onboarding-approved-reindex:{pro_user_id}",
            idempotency_scope="onboarding_approved_reindex",
        )
        enqueue_notification(
            db,
            user_id=pro_user_id,
            notification_type="onboarding.approved_public",
            payload={
                "title": "Your profile is live",
                "body": "You are approved for public discovery.",
                "action": {"label": "View profile", "url": f"/pros/{pro_user_id}/public"},
            },
            reference_type="pro_onboarding",
            reference_id=str(pro_user_id),
        )
        queue_evaluate_user_milestones(pro_user_id)
    db.flush()
    return row


def maybe_advance_to_ready_for_review(db: Session, *, pro_user_id: uuid.UUID) -> ProOnboarding:
    checks = onboarding_checks(db, pro_user_id=pro_user_id)
    row = get_or_create_pro_onboarding(db, pro_user_id=pro_user_id)
    if checks["ready_for_review"] and row.status == ProOnboardingStatus.kyc_approved:
        return set_pro_onboarding_status(
            db,
            pro_user_id=pro_user_id,
            to_status=ProOnboardingStatus.ready_for_review,
            actor_type=ProOnboardingActorType.system,
            actor_user_id=None,
            note="automatic_ready_check_passed",
            payload={"checks": checks},
        )
    return row


def is_pro_publicly_discoverable(db: Session, *, pro_user_id: uuid.UUID) -> bool:
    latest_ban = db.execute(
        select(BanAction).where(BanAction.user_id == pro_user_id).order_by(BanAction.created_at.desc())
    ).scalar_one_or_none()
    if latest_ban and latest_ban.action in {BanActionType.banned, BanActionType.suspended}:
        return False
    onboarding = db.get(ProOnboarding, pro_user_id)
    if not onboarding or onboarding.status != ProOnboardingStatus.approved_public:
        return False
    if is_feature_enabled(db, "client_browsing_enabled_global", user_id=None) or is_feature_enabled(db, "client_browsing_enabled", user_id=None):
        return True
    city_info = onboarding.current_city or {}
    city = city_info.get("city")
    country = city_info.get("country")
    if not city or not country:
        return False
    rollout = get_rollout_city(db, city=city, country=country)
    return bool(rollout and rollout.is_client_browsing_enabled)


def create_invite_wave(
    db: Session,
    *,
    code_prefix: str,
    name: str,
    max_invites: int,
    allowed_role: InviteAllowedRole,
    allowed_cities: list[dict],
    expires_at: datetime | None,
) -> InviteWave:
    if max_invites <= 0:
        raise APIError(code="validation_error", message="max_invites must be > 0", status_code=422)
    row = InviteWave(
        code_prefix=code_prefix.strip().upper(),
        name=name.strip(),
        max_invites=max_invites,
        used_invites=0,
        expires_at=expires_at,
        allowed_role=allowed_role,
        allowed_cities=allowed_cities or [],
        is_active=True,
    )
    db.add(row)
    db.flush()
    return row


def generate_invite_codes(
    db: Session,
    *,
    wave_id: uuid.UUID,
    count: int,
    issued_by_admin_id: uuid.UUID,
    issued_to_emails: list[str] | None,
) -> list[InviteCode]:
    wave = db.execute(select(InviteWave).where(InviteWave.id == wave_id).with_for_update()).scalar_one_or_none()
    if not wave:
        raise APIError(code="not_found", message="Invite wave not found", status_code=404)
    if not wave.is_active:
        raise APIError(code="invalid_state", message="Invite wave inactive", status_code=409)
    if wave.expires_at and wave.expires_at < datetime.now(timezone.utc):
        raise APIError(code="invalid_state", message="Invite wave expired", status_code=409)
    if count <= 0:
        raise APIError(code="validation_error", message="count must be > 0", status_code=422)
    available = max(0, wave.max_invites - wave.used_invites)
    if count > available:
        raise APIError(code="validation_error", message="Invite wave capacity exceeded", status_code=422)

    emails = issued_to_emails or []
    if emails and len(emails) != count:
        raise APIError(code="validation_error", message="issued_to_emails length must match count", status_code=422)

    rows: list[InviteCode] = []
    for idx in range(count):
        token = secrets.token_hex(4).upper()
        code = f"{wave.code_prefix}-{token}"
        row = InviteCode(
            wave_id=wave.id,
            code=code,
            issued_to_email=emails[idx] if emails else None,
            issued_by_admin_id=issued_by_admin_id,
            status=InviteCodeStatus.issued,
        )
        db.add(row)
        rows.append(row)
    wave.used_invites += count
    db.flush()

    for row in rows:
        if row.issued_to_email:
            enqueue_outbox_event(
                db,
                topic="launch.invite.email",
                payload={"email": row.issued_to_email, "code": row.code, "wave_name": wave.name},
                idempotency_key=f"invite-email:{row.id}",
                idempotency_scope="invite_email",
            )
    return rows
