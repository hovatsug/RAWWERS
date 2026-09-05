from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
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
    # Was missing: update_pro_kyc referenced KYCStatus and raised NameError
    # on every approval, so the only gate between a photographer and going
    # live returned a 500.
    KYCStatus,
    DisputeEvent,
    DisputeActorType,
    Dispute,
    DisputeStatus,
    EntitlementHold,
    EntitlementHoldType,
    ProProfile,
    ProQualityPenaltySeverity,
    ProQualityPenalty,
    RefundCase,
    RefundEvent,
    RefundCaseStatus,
    UserAccount,
    UserRole,
    UserRoleType,
)
from app.models.gig import Gig, GigStatus, GigTransition, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.models.learning import (
    Course,
    CourseLevel,
    InstructorProfile,
    InstructorStatus,
)
from app.models.booking import ProPackage
from app.models.media import MediaAsset, MediaKind, MediaPurpose, MediaStatus
from app.models.niche import Niche, NicheTierPolicy, ProNicheSkill, ProNicheSkillEvent, SkillTier
from app.models.discovery import AnalyticsEvent, ProPublicIndex
from app.models.ops import AbuseSeverity, AbuseSignal, AbuseSignalStatus, FeatureFlag, WebhookSecurityLog
from app.models.package_pricing import NichePackagePriceCap, PackageDecayCurve
from app.models.payouts import EarningsSourceType, PayoutAccount, PayoutAccountStatus
from app.models.proof_of_gigs import RawwIssuanceEventType
from app.models.proof_of_gigs import RawwIssuanceCap, RawwIssuanceRule, RawwMintEvent, RawwMultiplierPolicy
from app.models.client_rewards_pricing import (
    ConsentRewardPolicy,
    ExtraImagePricingPolicy,
    ProExtraImagePrice,
    ShareRewardGrant,
    ShareRewardThreshold,
)
from app.models.launch_ops import (
    InviteCode,
    InviteCodeStatus,
    InviteWave,
    ProOnboarding,
    ProOnboardingActorType,
    ProOnboardingStatus,
    RolloutCity,
    RolloutFlagOverride,
)
from app.schemas.admin import (
    AdminProApprovalRequest,
    AdminProApprovalResponse,
    AdminProReviewDetail,
    AdminProReviewQueueResponse,
    AdminProReviewRow,
    AbuseSignalView,
    AdminGigStatusUpdateRequest,
    AdminRefundCreateRequest,
    BanActionView,
    BanUpdateRequest,
    DisputeStatusUpdateRequest,
    DisputeView,
    FeatureFlagUpsertRequest,
    FeatureFlagView,
    KYCUpdateRequest,
    OpsMetricsSummaryResponse,
    ResolveAbuseSignalRequest,
    ConsentRewardPolicyUpsertRequest,
    ConsentRewardPolicyView,
    ExtraImagePricingPolicyUpsertRequest,
    ExtraImagePricingPolicyView,
    NichePackagePriceCapUpsertRequest,
    NichePackagePriceCapView,
    PackageDecayCurveUpsertRequest,
    PackageDecayCurveView,
    RefundCaseView,
    RoleUpdateRequest,
    ProExtraImagePriceUpsertRequest,
    ProExtraImagePriceView,
    ShareFraudSettingsUpsertRequest,
    ShareFraudSettingsView,
    ShareRewardGrantView,
    ShareRewardThresholdUpsertRequest,
    ShareRewardThresholdView,
    RawwCapView,
    RawwCapsUpdateRequest,
    RawwClawbackRequest,
    RawwClawbackResponse,
    RawwIssuanceRulesUpdateRequest,
    RawwIssuanceRuleView,
    RawwMintEventView,
    RawwMultiplierPolicyUpdateRequest,
    RawwMultiplierPolicyView,
    UserDetailResponse,
    UserListItem,
    UserListResponse,
)
from app.schemas.client_launch import ClientFunnelCityMetrics, ClientFunnelReportResponse
from app.schemas.disputes import (
    AdminDisputeResolveRequest,
    AdminDisputeSetStatusRequest,
    DisputeDetailView,
    DisputeEventView,
    DisputeMessageView,
    EntitlementHoldView,
    ProQualityPenaltyView,
    RefundCaseDetailView,
)
from app.schemas.niche import (
    AdminNicheSkillOverrideRequest,
    AdminNicheSkillOverrideV2Request,
    AdminNicheSkillRecalcRequest,
    NicheTierPolicyUpsertRequest,
    NicheTierPolicyView,
    NicheView,
    ProNicheSkillListResponse,
    ProNicheSkillView,
)
from app.schemas.learning import (
    AdminCourseListResponse,
    AdminNicheRequirementsUpsertRequest,
    AdminNicheRequirementsUpsertResponse,
    AdminSetInstructorStatusRequest,
    CourseListItem,
    InstructorProfileView,
)
from app.schemas.media import CurrentUser
from app.schemas.launch_ops import (
    AdminProOnboardingListResponse,
    AdminSetProOnboardingStatusRequest,
    InviteCodeListResponse,
    InviteCodeView,
    InviteWaveCreateRequest,
    InviteWaveGenerateRequest,
    InviteWaveResponse,
    ProOnboardingStatusResponse,
    RolloutCityBulkEnableRequest,
    RolloutCityListResponse,
    RolloutCityUpsertItem,
    RolloutOverrideResponse,
    RolloutOverrideUpsertRequest,
)
from app.services.audit import add_admin_audit_log
from app.services.payment_intents import allocate_amount_oldest_first, list_succeeded_payments_for_gig, total_succeeded_amount_for_gig
from app.services.discovery_index import recompute_pro_public_index
from app.services.media_urls import resolve_image_urls
from app.services.launch_ops import onboarding_checks
from app.services.payouts import get_or_create_payout_account
from app.services.gig_state import transition_gig
from app.services.analytics import log_event
from app.services.niche_catalog import ensure_initial_niches
from app.services.gamification import queue_evaluate_user_milestones, queue_recompute_credentials
from app.services.niche_skills import (
    admin_override_niche_skill,
    default_tier_thresholds,
    enqueue_niche_skill_recalc,
    get_or_create_niche_tier_policy,
    list_user_badge_codes,
    recompute_pro_niche_skills,
)
from app.services.learning import replace_niche_program_requirements
from app.tasks.niche_tasks import recompute_all_pro_niche_skills_task, recompute_pro_niche_skills_task
from app.services.rewards import maybe_issue_pro_signup_referral_reward
from app.services.cache import get_redis_client
from app.services.feature_flags import upsert_feature_flag
from app.services.auth_events import add_auth_event
from app.services.client_rewards_pricing import (
    ensure_default_consent_reward_policies,
    ensure_default_share_thresholds,
    get_share_fraud_settings,
    upsert_share_fraud_settings,
)
from app.services.disputes import (
    apply_pro_quality_penalty,
    create_or_get_refund_case_for_dispute,
    finalize_refund_case_failed,
    finalize_refund_case_success,
    initiate_refund_case,
    release_entitlement_hold,
)
from app.services.outbox import enqueue_outbox_event
from app.services.payouts import create_earnings_entry, release_earnings_holds_for_source
from app.services.launch_ops import (
    create_invite_wave,
    generate_invite_codes,
    get_or_create_pro_onboarding,
    maybe_advance_to_ready_for_review,
    set_pro_onboarding_status,
)
from app.services.proof_of_gigs import enqueue_raww_mint, create_raww_clawback, ensure_default_raww_config, list_raww_mints

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/funnel/clients", response_model=ClientFunnelReportResponse)
def admin_client_funnel(
    start_at: datetime | None = None,
    end_at: datetime | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ClientFunnelReportResponse:
    now = datetime.now(timezone.utc)
    window_end = end_at or now
    window_start = start_at or (window_end - timedelta(days=30))

    events = db.execute(
        select(AnalyticsEvent).where(
            AnalyticsEvent.created_at >= window_start,
            AnalyticsEvent.created_at <= window_end,
            or_(AnalyticsEvent.event_name.like("client.%"), AnalyticsEvent.event_name == "payment.succeeded"),
        )
    ).scalars().all()

    grouped: dict[tuple[str, str], dict[str, int]] = {}
    cohorts: dict[tuple[str, str], dict[str, int]] = {}
    for event in events:
        props = event.properties or {}
        country = str(props.get("country") or "").upper()
        city = str(props.get("city") or "")
        if not country or not city:
            continue
        key = (country, city)
        metrics = grouped.setdefault(
            key,
            {
                "discover_views": 0,
                "pro_profile_views": 0,
                "booking_requests": 0,
                "payments_succeeded": 0,
                "proofs_published": 0,
                "extras_purchased": 0,
                "disputes_opened": 0,
            },
        )
        if event.event_name == "client.discover_view":
            metrics["discover_views"] += 1
        elif event.event_name == "client.pro_profile_view":
            metrics["pro_profile_views"] += 1
        elif event.event_name == "client.booking_request_created":
            metrics["booking_requests"] += 1
        elif event.event_name in {"client.payment_succeeded", "payment.succeeded"}:
            metrics["payments_succeeded"] += 1
        elif event.event_name == "client.proofs_viewed":
            metrics["proofs_published"] += 1
        elif event.event_name == "client.extras_purchased":
            metrics["extras_purchased"] += 1
        elif event.event_name == "client.dispute_opened":
            metrics["disputes_opened"] += 1

        cohort_bucket = event.created_at.strftime("%Y-%m-%d")
        cohort_counts = cohorts.setdefault(key, {})
        cohort_counts[cohort_bucket] = cohort_counts.get(cohort_bucket, 0) + 1

    items: list[ClientFunnelCityMetrics] = []
    for (country, city), metrics in sorted(grouped.items()):
        discover = metrics["discover_views"]
        profile = metrics["pro_profile_views"]
        booking = metrics["booking_requests"]
        paid = metrics["payments_succeeded"]
        items.append(
            ClientFunnelCityMetrics(
                country=country,
                city=city,
                discover_views=discover,
                pro_profile_views=profile,
                booking_requests=booking,
                payments_succeeded=paid,
                proofs_published=metrics["proofs_published"],
                extras_purchased=metrics["extras_purchased"],
                disputes_opened=metrics["disputes_opened"],
                discover_to_profile_rate=round(profile / discover, 4) if discover else 0.0,
                profile_to_booking_rate=round(booking / profile, 4) if profile else 0.0,
                booking_to_payment_rate=round(paid / booking, 4) if booking else 0.0,
                cohorts=[{"day": day, "events": count} for day, count in sorted((cohorts.get((country, city)) or {}).items())],
            )
        )

    return ClientFunnelReportResponse(start_at=window_start, end_at=window_end, items=items)


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
    add_auth_event(
        db,
        event_type="role_changed",
        user_id=user_id,
        ip=None,
        user_agent=None,
        metadata={"actor_user_id": str(actor.user_id), "add": [x.value for x in body.add], "remove": [x.value for x in body.remove]},
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
        recompute_pro_niche_skills(db, user_id)
        queue_recompute_credentials(user_id)
        queue_evaluate_user_milestones(user_id)
        onboarding = get_or_create_pro_onboarding(db, pro_user_id=user_id)
        if onboarding.status == ProOnboardingStatus.kyc_submitted:
            set_pro_onboarding_status(
                db,
                pro_user_id=user_id,
                to_status=ProOnboardingStatus.kyc_approved,
                actor_type=ProOnboardingActorType.admin,
                actor_user_id=actor.user_id,
                note="kyc_approved",
            )
            maybe_advance_to_ready_for_review(db, pro_user_id=user_id)
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


@router.get("/onboarding/pros", response_model=AdminProOnboardingListResponse)
def list_pro_onboarding(
    status: ProOnboardingStatus | None = None,
    city: str | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminProOnboardingListResponse:
    stmt = select(ProOnboarding).order_by(ProOnboarding.updated_at.desc())
    if status:
        stmt = stmt.where(ProOnboarding.status == status)
    rows = db.execute(stmt.limit(500)).scalars().all()
    items = []
    for row in rows:
        if city and (row.current_city or {}).get("city", "").strip().lower() != city.strip().lower():
            continue
        items.append(ProOnboardingStatusResponse.model_validate(row, from_attributes=True))
    return AdminProOnboardingListResponse(items=items)


@router.post("/onboarding/pros/{pro_user_id}/approve", response_model=ProOnboardingStatusResponse)
def approve_pro_onboarding(
    pro_user_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    row = set_pro_onboarding_status(
        db,
        pro_user_id=pro_user_id,
        to_status=ProOnboardingStatus.approved_public,
        actor_type=ProOnboardingActorType.admin,
        actor_user_id=actor.user_id,
        note="approved_by_admin",
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="pro_onboarding",
        target_id=str(pro_user_id),
        action="onboarding_approved_public",
        metadata={},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


def _review_row(db: Session, onboarding: ProOnboarding) -> AdminProReviewRow:
    pro_user_id = onboarding.pro_user_id
    profile = db.get(ProProfile, pro_user_id)
    checks = onboarding_checks(db, pro_user_id=pro_user_id)
    index = db.get(ProPublicIndex, pro_user_id)
    account = db.get(PayoutAccount, pro_user_id)

    cover_url = None
    if profile and profile.cover_media_asset_id:
        cover_url = resolve_image_urls(db, [profile.cover_media_asset_id]).get(profile.cover_media_asset_id)

    # The four the reviewer can do nothing about themselves; KYC is what
    # they are here to decide, so it is not listed as "missing".
    missing = [
        key for key in ("profile_completed", "portfolio_uploaded", "packages_configured", "niches_selected")
        if not checks.get(key)
    ]

    return AdminProReviewRow(
        pro_user_id=pro_user_id,
        display_name=profile.display_name if profile else None,
        headline=profile.headline if profile else None,
        city=(onboarding.current_city or {}).get("city") if onboarding.current_city else (profile.city if profile else None),
        country=(onboarding.current_city or {}).get("country") if onboarding.current_city else (profile.country if profile else None),
        onboarding_status=onboarding.status,
        kyc_status=profile.kyc_status.value if profile else "unsubmitted",
        portfolio_photo_count=int(checks.get("portfolio_count") or 0),
        portfolio_minimum=int(checks.get("portfolio_min_required") or 12),
        active_packages=int(checks.get("active_packages_count") or 0),
        min_price=index.min_package_price if index else None,
        currency=index.currency if index else "EUR",
        cover_url=cover_url,
        ready_to_approve=not missing,
        missing=missing,
        payout_blocked=(account is None or account.status != PayoutAccountStatus.active),
        submitted_at=onboarding.updated_at,
    )


@router.get("/pros/review-queue", response_model=AdminProReviewQueueResponse)
def pro_review_queue(
    status: ProOnboardingStatus | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminProReviewQueueResponse:
    """Photographers waiting on a decision, with enough per row to make it.

    Defaults to the ones actually awaiting review rather than every
    onboarding row ever created - the queue should be work to do, not a
    log.
    """
    stmt = select(ProOnboarding).order_by(ProOnboarding.updated_at.asc())
    if status:
        stmt = stmt.where(ProOnboarding.status == status)
    else:
        stmt = stmt.where(
            ProOnboarding.status.in_(
                [
                    ProOnboardingStatus.ready_for_review,
                    ProOnboardingStatus.kyc_submitted,
                    ProOnboardingStatus.kyc_approved,
                ]
            )
        )
    rows = db.execute(stmt.limit(200)).scalars().all()
    items = [_review_row(db, row) for row in rows]
    db.commit()
    return AdminProReviewQueueResponse(items=items)


@router.get("/pros/{pro_user_id}/review", response_model=AdminProReviewDetail)
def pro_review_detail(
    pro_user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminProReviewDetail:
    onboarding = db.get(ProOnboarding, pro_user_id)
    if not onboarding:
        raise APIError(code="not_found", message="No onboarding record for this user", status_code=404)
    profile = db.get(ProProfile, pro_user_id)
    if not profile:
        raise APIError(code="not_found", message="Pro profile not found", status_code=404)

    assets = db.execute(
        select(MediaAsset)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.status == MediaStatus.ready,
        )
        .order_by(MediaAsset.created_at.desc())
        .limit(24)
    ).scalars().all()
    urls = resolve_image_urls(db, [a.id for a in assets])

    packages = db.execute(
        select(ProPackage, Niche.slug)
        .join(Niche, Niche.id == ProPackage.niche_id)
        .where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.price.asc())
    ).all()
    account = get_or_create_payout_account(db, pro_user_id=pro_user_id)
    row = _review_row(db, onboarding)
    db.commit()

    return AdminProReviewDetail(
        row=row,
        bio=profile.bio,
        languages=list(profile.languages or []),
        styles=list(profile.styles or []),
        travel_radius_km=profile.travel_radius_km,
        checks=onboarding_checks(db, pro_user_id=pro_user_id),
        portfolio_urls=[urls[a.id] for a in assets if a.id in urls],
        packages=[
            {
                "title": pkg.title,
                "niche_slug": slug,
                "price": str(pkg.price),
                "currency": pkg.currency,
                "included_photos": pkg.included_photos,
                "duration_minutes": pkg.duration_minutes,
            }
            for pkg, slug in packages
        ],
        payout_account_status=account.status.value,
    )


@router.post("/pros/{pro_user_id}/approve", response_model=AdminProApprovalResponse)
def approve_pro(
    pro_user_id: uuid.UUID,
    body: AdminProApprovalRequest | None = None,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminProApprovalResponse:
    """Approve a photographer: identity check and public listing, together.

    These are two separate gates - KYC on the profile, approved_public on
    the onboarding row - and Discover requires both. Done as two calls, a
    failure between them leaves a photographer approved but invisible,
    which nobody notices until they ask why no requests arrive. One
    transaction, so it is both or neither.

    Deliberately does *not* touch the payout account: that is the
    photographer's own bank detail to enter, and an admin filling it in on
    their behalf would make whoever runs this panel the compliance surface
    for other people's financial data. It is reported as a blocker instead.
    """
    note = (body.note if body else None) or "approved_by_admin"

    has_pro_role = db.execute(
        select(UserRole).where(UserRole.user_id == pro_user_id, UserRole.role == UserRoleType.pro)
    ).scalar_one_or_none()
    if not has_pro_role:
        raise APIError(code="validation_error", message="User is not a pro", status_code=400)

    profile = db.get(ProProfile, pro_user_id)
    if not profile:
        raise APIError(code="not_found", message="Pro profile not found", status_code=404)

    checks = onboarding_checks(db, pro_user_id=pro_user_id)
    blocking = [
        key
        for key in ("profile_completed", "portfolio_uploaded", "packages_configured", "niches_selected")
        if not checks.get(key)
    ]
    if blocking:
        raise APIError(
            code="validation_error",
            message=f"Not ready to approve; still missing: {', '.join(blocking)}",
            status_code=409,
        )

    previously_approved = profile.kyc_status == KYCStatus.approved
    profile.kyc_status = KYCStatus.approved
    profile.kyc_note = note
    profile.kyc_updated_at = datetime.now(timezone.utc)

    row = set_pro_onboarding_status(
        db,
        pro_user_id=pro_user_id,
        to_status=ProOnboardingStatus.approved_public,
        actor_type=ProOnboardingActorType.admin,
        actor_user_id=actor.user_id,
        note=note,
    )

    # The listing only reaches Discover through the index, which is filtered
    # on kyc_status - recomputed here so approval takes effect immediately
    # rather than on whatever writes to the profile next.
    recompute_pro_public_index(db, pro_user_id)

    if not previously_approved:
        reward_entry = maybe_issue_pro_signup_referral_reward(db, pro_user_id)
        if reward_entry:
            log_event(
                db,
                event_name="reward.earned",
                user_id=reward_entry.user_id,
                properties={
                    "rule_code": reward_entry.rule_code,
                    "amount": reward_entry.amount,
                    "referred_user_id": str(pro_user_id),
                },
            )

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="pro",
        target_id=str(pro_user_id),
        action="pro_approved",
        reason=note,
        metadata={"kyc": "approved", "onboarding": ProOnboardingStatus.approved_public.value},
    )
    db.commit()
    db.refresh(profile)
    db.refresh(row)

    account = get_or_create_payout_account(db, pro_user_id=pro_user_id)
    db.commit()

    return AdminProApprovalResponse(
        pro_user_id=pro_user_id,
        kyc_status=profile.kyc_status.value,
        onboarding_status=row.status,
        is_accepting_bookings=profile.is_accepting_bookings,
        # Surfaced, not fixed: a photographer with no payout method can be
        # booked and paid into a balance they cannot withdraw.
        payout_account_status=account.status.value,
        payout_blocked=account.status != PayoutAccountStatus.active,
    )


@router.post("/onboarding/pros/{pro_user_id}/reject", response_model=ProOnboardingStatusResponse)
def reject_pro_onboarding(
    pro_user_id: uuid.UUID,
    body: AdminSetProOnboardingStatusRequest | None = None,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    row = set_pro_onboarding_status(
        db,
        pro_user_id=pro_user_id,
        to_status=ProOnboardingStatus.rejected,
        actor_type=ProOnboardingActorType.admin,
        actor_user_id=actor.user_id,
        note=body.note if body else None,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="pro_onboarding",
        target_id=str(pro_user_id),
        action="onboarding_rejected",
        reason=body.note if body else None,
        metadata={},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.post("/onboarding/pros/{pro_user_id}/set-status", response_model=ProOnboardingStatusResponse)
def set_pro_onboarding_status_admin(
    pro_user_id: uuid.UUID,
    body: AdminSetProOnboardingStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ProOnboardingStatusResponse:
    row = set_pro_onboarding_status(
        db,
        pro_user_id=pro_user_id,
        to_status=body.status,
        actor_type=ProOnboardingActorType.admin,
        actor_user_id=actor.user_id,
        note=body.note,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="pro_onboarding",
        target_id=str(pro_user_id),
        action="onboarding_set_status",
        reason=body.note,
        metadata={"status": body.status.value},
    )
    db.commit()
    db.refresh(row)
    return ProOnboardingStatusResponse.model_validate(row, from_attributes=True)


@router.get("/rollout/cities", response_model=RolloutCityListResponse)
def list_rollout_cities(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RolloutCityListResponse:
    rows = db.execute(select(RolloutCity).order_by(RolloutCity.country.asc(), RolloutCity.city.asc())).scalars().all()
    return RolloutCityListResponse(
        items=[
            {
                "id": item.id,
                "country": item.country,
                "city": item.city,
                "is_pro_onboarding_enabled": item.is_pro_onboarding_enabled,
                "is_client_browsing_enabled": item.is_client_browsing_enabled,
                "metadata": item.meta or {},
                "updated_at": item.updated_at,
            }
            for item in rows
        ]
    )


@router.put("/rollout/cities", response_model=RolloutCityListResponse)
def upsert_rollout_cities(
    body: list[RolloutCityUpsertItem],
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RolloutCityListResponse:
    for item in body:
        row = db.execute(
            select(RolloutCity).where(
                func.upper(RolloutCity.country) == item.country.strip().upper(),
                func.lower(RolloutCity.city) == item.city.strip().lower(),
            )
        ).scalar_one_or_none()
        if not row:
            row = RolloutCity(country=item.country.strip().upper(), city=item.city.strip(), meta={})
            db.add(row)
        row.is_pro_onboarding_enabled = item.is_pro_onboarding_enabled
        row.is_client_browsing_enabled = item.is_client_browsing_enabled
        row.meta = item.metadata or {}
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="rollout_city",
            target_id=f"{row.country}:{row.city}",
            action="rollout_city_upsert",
            metadata={
                "is_pro_onboarding_enabled": row.is_pro_onboarding_enabled,
                "is_client_browsing_enabled": row.is_client_browsing_enabled,
            },
        )
    db.commit()
    return list_rollout_cities(actor, db)  # type: ignore[arg-type]


@router.post("/rollout/cities/bulk-enable", response_model=RolloutCityListResponse)
def bulk_enable_rollout_cities(
    body: RolloutCityBulkEnableRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RolloutCityListResponse:
    for item in body.cities:
        country = str((item or {}).get("country", "")).strip().upper()
        city = str((item or {}).get("city", "")).strip()
        if not country or not city:
            continue
        row = db.execute(
            select(RolloutCity).where(func.upper(RolloutCity.country) == country, func.lower(RolloutCity.city) == city.lower())
        ).scalar_one_or_none()
        if not row:
            row = RolloutCity(country=country, city=city, meta={})
            db.add(row)
        row.is_pro_onboarding_enabled = body.enable_pro_onboarding
        row.is_client_browsing_enabled = body.enable_client_browsing
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="rollout_city",
            target_id=f"{country}:{city}",
            action="rollout_city_bulk_enable",
            metadata={
                "is_pro_onboarding_enabled": row.is_pro_onboarding_enabled,
                "is_client_browsing_enabled": row.is_client_browsing_enabled,
            },
        )
    db.commit()
    return list_rollout_cities(actor, db)  # type: ignore[arg-type]


@router.get("/rollout/overrides/{user_id}", response_model=RolloutOverrideResponse)
def get_rollout_override(
    user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RolloutOverrideResponse:
    row = db.execute(select(RolloutFlagOverride).where(RolloutFlagOverride.user_id == user_id)).scalar_one_or_none()
    if not row:
        row = RolloutFlagOverride(user_id=user_id, can_access_pro_onboarding=False, can_access_client_app=False)
        db.add(row)
        db.commit()
        db.refresh(row)
    return RolloutOverrideResponse.model_validate(row, from_attributes=True)


@router.put("/rollout/overrides/{user_id}", response_model=RolloutOverrideResponse)
def put_rollout_override(
    user_id: uuid.UUID,
    body: RolloutOverrideUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RolloutOverrideResponse:
    row = db.execute(select(RolloutFlagOverride).where(RolloutFlagOverride.user_id == user_id)).scalar_one_or_none()
    if not row:
        row = RolloutFlagOverride(user_id=user_id)
        db.add(row)
    row.can_access_pro_onboarding = body.can_access_pro_onboarding
    row.can_access_client_app = body.can_access_client_app
    row.reason = body.reason
    row.expires_at = body.expires_at
    row.granted_by = actor.user_id
    row.granted_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="rollout_override",
        target_id=str(user_id),
        action="rollout_override_upsert",
        reason=body.reason,
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return RolloutOverrideResponse.model_validate(row, from_attributes=True)


@router.post("/invites/waves", response_model=InviteWaveResponse)
def create_wave(
    body: InviteWaveCreateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> InviteWaveResponse:
    row = create_invite_wave(
        db,
        code_prefix=body.code_prefix,
        name=body.name,
        max_invites=body.max_invites,
        allowed_role=body.allowed_role,
        allowed_cities=body.allowed_cities,
        expires_at=body.expires_at,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="invite_wave",
        target_id=str(row.id),
        action="invite_wave_created",
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return InviteWaveResponse.model_validate(row, from_attributes=True)


@router.post("/invites/waves/{wave_id}/generate", response_model=InviteCodeListResponse)
def generate_wave_codes(
    wave_id: uuid.UUID,
    body: InviteWaveGenerateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> InviteCodeListResponse:
    rows = generate_invite_codes(
        db,
        wave_id=wave_id,
        count=body.count,
        issued_by_admin_id=actor.user_id,
        issued_to_emails=body.issued_to_emails or None,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="invite_wave",
        target_id=str(wave_id),
        action="invite_codes_generated",
        metadata={"count": len(rows)},
    )
    db.commit()
    return InviteCodeListResponse(items=[InviteCodeView.model_validate(item, from_attributes=True) for item in rows])


@router.post("/invites/codes/{code}/revoke")
def revoke_invite_code(
    code: str,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    row = db.execute(select(InviteCode).where(InviteCode.code == code.strip())).scalar_one_or_none()
    if not row:
        raise APIError(code="not_found", message="Invite code not found", status_code=404)
    row.status = InviteCodeStatus.revoked
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="invite_code",
        target_id=str(row.id),
        action="invite_code_revoked",
        metadata={"code": row.code},
    )
    db.commit()
    return {"ok": True, "id": str(row.id), "status": row.status.value}


@router.get("/invites/waves", response_model=list[InviteWaveResponse])
def list_invite_waves(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[InviteWaveResponse]:
    rows = db.execute(select(InviteWave).order_by(InviteWave.created_at.desc())).scalars().all()
    return [InviteWaveResponse.model_validate(item, from_attributes=True) for item in rows]


@router.get("/invites/codes", response_model=InviteCodeListResponse)
def list_invite_codes(
    wave_id: uuid.UUID | None = None,
    status: InviteCodeStatus | None = None,
    limit: int = Query(default=200, ge=1, le=1000),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> InviteCodeListResponse:
    stmt = select(InviteCode).order_by(InviteCode.created_at.desc())
    if wave_id:
        stmt = stmt.where(InviteCode.wave_id == wave_id)
    if status:
        stmt = stmt.where(InviteCode.status == status)
    rows = db.execute(stmt.limit(limit)).scalars().all()
    return InviteCodeListResponse(items=[InviteCodeView.model_validate(item, from_attributes=True) for item in rows])


@router.get("/disputes", response_model=list[DisputeView])
def list_disputes(
    status: DisputeStatus | None = None,
    category: DisputeCategory | None = None,
    pro_user_id: uuid.UUID | None = None,
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
    if pro_user_id:
        conditions.append(Dispute.against_user_id == pro_user_id)
    if date_from:
        conditions.append(Dispute.opened_at >= date_from)
    if date_to:
        conditions.append(Dispute.opened_at <= date_to)
    if conditions:
        stmt = stmt.where(and_(*conditions))

    disputes = db.execute(stmt.order_by(Dispute.opened_at.desc(), Dispute.created_at.desc())).scalars().all()
    return [
        DisputeView(
            id=d.id,
            gig_id=d.gig_id,
            opened_by_user_id=d.opened_by_user_id,
            status=d.status,
            category=d.category,
            summary=d.summary or d.reason or "",
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
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        recompute_pro_public_index(db, gig.pro_user_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)
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


@router.get("/disputes/{dispute_id}", response_model=DisputeDetailView)
def get_dispute_detail_admin(
    dispute_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> DisputeDetailView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    return _dispute_detail_view(db, dispute)


@router.post("/disputes/{dispute_id}/set-status", response_model=DisputeDetailView)
def admin_set_dispute_status(
    dispute_id: uuid.UUID,
    body: AdminDisputeSetStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> DisputeDetailView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    previous = dispute.status
    dispute.status = body.status
    if body.status in {
        DisputeStatus.resolved_no_refund,
        DisputeStatus.resolved_partial_refund,
        DisputeStatus.resolved_refund,
        DisputeStatus.cancelled,
        DisputeStatus.closed,
    }:
        dispute.resolved_at = datetime.now(timezone.utc)
    db.add(
        DisputeEvent(
            dispute_id=dispute.id,
            from_status=previous.value,
            to_status=body.status.value,
            actor_type=DisputeActorType.admin,
            actor_user_id=actor.user_id,
            note=body.note,
            payload={},
        )
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="dispute",
        target_id=str(dispute.id),
        action="dispute_set_status",
        reason=body.note,
        metadata={"from_status": previous.value, "to_status": body.status.value},
    )
    db.commit()
    db.refresh(dispute)
    return _dispute_detail_view(db, dispute)


@router.post("/disputes/{dispute_id}/resolve", response_model=DisputeDetailView)
def admin_resolve_dispute(
    dispute_id: uuid.UUID,
    body: AdminDisputeResolveRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> DisputeDetailView:
    dispute = db.get(Dispute, dispute_id)
    if not dispute:
        raise APIError(code="not_found", message="Dispute not found", status_code=404)
    decision = body.decision.strip().lower()
    if decision not in {"full_refund", "partial_refund", "no_refund"}:
        raise APIError(code="validation_error", message="decision must be full_refund|partial_refund|no_refund", status_code=422)

    refund_cases = create_or_get_refund_case_for_dispute(
        db,
        dispute=dispute,
        decision=decision,
        amount=body.amount,
    )
    refund_case = refund_cases[0] if refund_cases else None
    previous = dispute.status
    if decision == "full_refund":
        dispute.status = DisputeStatus.resolved_refund
    elif decision == "partial_refund":
        dispute.status = DisputeStatus.resolved_partial_refund
    else:
        dispute.status = DisputeStatus.resolved_no_refund
    dispute.resolution = {
        "decision": decision,
        "rationale": body.rationale,
        "amount": str(body.amount) if body.amount is not None else None,
        "actions": body.actions or {},
        "refund_case_id": str(refund_case.id) if refund_case else None,
    }
    dispute.resolution_note = body.rationale
    dispute.resolved_at = datetime.now(timezone.utc)
    db.add(
        DisputeEvent(
            dispute_id=dispute.id,
            from_status=previous.value,
            to_status=dispute.status.value,
            actor_type=DisputeActorType.admin,
            actor_user_id=actor.user_id,
            note="resolved",
            payload=dispute.resolution or {},
        )
    )
    if decision == "no_refund":
        for hold in db.execute(
            select(EntitlementHold).where(
                EntitlementHold.gig_id == dispute.gig_id,
                EntitlementHold.user_id == dispute.opened_by_user_id,
                EntitlementHold.released_at.is_(None),
            )
        ).scalars():
            release_entitlement_hold(db, hold)
        if dispute.against_user_id and dispute.gig_id:
            release_earnings_holds_for_source(
                db,
                pro_user_id=dispute.against_user_id,
                source_type=EarningsSourceType.gig_base.value,
                source_id=dispute.gig_id,
            )
        if dispute.against_user_id and dispute.extra_purchase_id:
            release_earnings_holds_for_source(
                db,
                pro_user_id=dispute.against_user_id,
                source_type=EarningsSourceType.extra_images.value,
                source_id=dispute.extra_purchase_id,
            )
    else:
        for case in refund_cases:
            enqueue_outbox_event(
                db,
                topic="refund.initiate",
                payload={"refund_case_id": str(case.id)},
                idempotency_key=f"refund-initiate:{case.id}",
                idempotency_scope="refund_initiate",
            )
    if decision in {"full_refund", "partial_refund"}:
        severity_value = (body.actions or {}).get("penalty_severity", "medium")
        severity = AbuseSeverity.medium
        if severity_value == "low":
            severity = AbuseSeverity.low
        elif severity_value == "high":
            severity = AbuseSeverity.high

        apply_pro_quality_penalty(
            db,
            dispute=dispute,
            severity=ProQualityPenaltySeverity(severity.value),
        )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="dispute",
        target_id=str(dispute.id),
        action="dispute_resolved",
        reason=body.rationale,
        metadata={
            "decision": decision,
            "amount": str(body.amount) if body.amount is not None else None,
            "refund_case_id": str(refund_case.id) if refund_case else None,
        },
    )
    log_event(
        db,
        event_name="dispute.resolved",
        user_id=actor.user_id,
        properties={"dispute_id": str(dispute.id), "decision": decision, "refund_case_id": str(refund_case.id) if refund_case else None},
    )
    db.commit()
    db.refresh(dispute)
    return _dispute_detail_view(db, dispute)


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
    if body.status == GigStatus.completed:
        db.add(transition_gig(gig, GigStatus.completed, actor.user_id, reason=body.reason))
    else:
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
    if gig.niche_id:
        recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
    queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)
    if body.status == GigStatus.completed:
        enqueue_raww_mint(
            db,
            event_type=RawwIssuanceEventType.gig_completed,
            payload={"gig_id": str(gig.id)},
            idempotency_key=f"raww:gig_completed:{gig.id}",
        )
        succeeded_payments = list_succeeded_payments_for_gig(
            db, gig.id, kinds=[StripePaymentKind.base, StripePaymentKind.difference]
        )
        if succeeded_payments:
            gross_eur = sum((p.amount for p in succeeded_payments), Decimal("0.00"))
            create_earnings_entry(
                db,
                pro_user_id=gig.pro_user_id,
                source_type=EarningsSourceType.gig_base,
                source_id=gig.id,
                gross_eur=Decimal(str(gross_eur)),
                metadata={
                    "gig_id": str(gig.id),
                    "payment_intent_ids": [p.stripe_payment_intent_id for p in succeeded_payments],
                },
            )
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
    ).scalars().first()
    if existing:
        return _refund_case_view(existing)

    payments = list_succeeded_payments_for_gig(db, gig_id)
    if not payments:
        raise APIError(code="invalid_state", message="No stripe payment for gig", status_code=409)

    total_paid = total_succeeded_amount_for_gig(db, gig_id)
    amount = body.amount or total_paid
    if amount <= 0 or amount > total_paid:
        raise APIError(code="validation_error", message="Invalid refund amount", status_code=422)

    allocation = allocate_amount_oldest_first(payments, amount)

    refund_cases: list[RefundCase] = []
    for payment, take in allocation:
        refund = stripe.Refund.create(
            payment_intent=payment.stripe_payment_intent_id,
            amount=int((take * Decimal("100")).quantize(Decimal("1"))),
            metadata={
                "gig_id": str(gig.id),
                "actor_user_id": str(actor.user_id),
                "dispute_id": str(body.dispute_id) if body.dispute_id else "",
            },
            idempotency_key=f"gig:{gig.id}:admin-refund:{payment.id}",
        )

        refund_case = RefundCase(
            gig_id=gig.id,
            dispute_id=body.dispute_id,
            requested_by_user_id=actor.user_id,
            status=RefundCaseStatus.processing,
            amount=take,
            currency=gig.currency,
            reason=body.reason,
            admin_note=body.reason,
            meta={"stripe_refund_id": refund.id, "stripe_payment_id": str(payment.id)},
        )
        db.add(refund_case)
        refund_cases.append(refund_case)

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
        metadata={
            "amount": str(amount),
            "refund_ids": [rc.meta["stripe_refund_id"] for rc in refund_cases],
            "dispute_id": str(body.dispute_id) if body.dispute_id else None,
        },
    )
    recompute_pro_public_index(db, gig.pro_user_id)
    if gig.niche_id:
        recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
    db.commit()
    db.refresh(refund_cases[0])
    return _refund_case_view(refund_cases[0])


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


@router.post("/refunds/{refund_case_id}/retry", response_model=RefundCaseDetailView)
def retry_refund_case(
    refund_case_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RefundCaseDetailView:
    case = db.get(RefundCase, refund_case_id)
    if not case:
        raise APIError(code="not_found", message="Refund case not found", status_code=404)
    if case.status not in {RefundCaseStatus.failed, RefundCaseStatus.pending, RefundCaseStatus.refund_initiated}:
        raise APIError(code="invalid_state", message="Refund case cannot be retried in current status", status_code=409)

    enqueue_outbox_event(
        db,
        topic="refund.initiate",
        payload={"refund_case_id": str(case.id)},
        idempotency_key=f"refund-retry:{case.id}:{datetime.now(timezone.utc).strftime('%Y%m%d%H%M')}",
        idempotency_scope="refund_retry",
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="refund_case",
        target_id=str(case.id),
        action="refund_retry_enqueued",
        reason=None,
        metadata={"status": case.status.value},
    )
    db.commit()
    db.refresh(case)
    return _refund_case_detail_view(case)


@router.post("/entitlement-holds/{hold_id}/release", response_model=EntitlementHoldView)
def release_entitlement_hold_admin(
    hold_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> EntitlementHoldView:
    hold = db.get(EntitlementHold, hold_id)
    if not hold:
        raise APIError(code="not_found", message="Entitlement hold not found", status_code=404)

    release_entitlement_hold(db, hold)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="entitlement_hold",
        target_id=str(hold.id),
        action="entitlement_hold_released",
        reason=None,
        metadata={"gig_id": str(hold.gig_id), "user_id": str(hold.user_id), "hold_type": hold.hold_type.value},
    )
    db.commit()
    db.refresh(hold)
    return EntitlementHoldView(
        id=hold.id,
        gig_id=hold.gig_id,
        user_id=hold.user_id,
        hold_type=hold.hold_type,
        reason=hold.reason,
        created_at=hold.created_at,
        released_at=hold.released_at,
    )


@router.post("/instructors/{user_id}/approve", response_model=InstructorProfileView)
def approve_instructor(
    user_id: uuid.UUID,
    body: AdminSetInstructorStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> InstructorProfileView:
    profile = db.get(InstructorProfile, user_id)
    if not profile:
        profile = InstructorProfile(user_id=user_id, status=InstructorStatus.pending, expertise=[])
        db.add(profile)
    profile.status = InstructorStatus.approved
    profile.bio = body.bio if body.bio is not None else profile.bio
    profile.expertise = body.expertise or profile.expertise or []
    profile.approved_by = actor.user_id
    profile.approved_at = datetime.now(timezone.utc)
    profile.rejected_reason = None
    profile.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="instructor_profile",
        target_id=str(user_id),
        action="instructor_approved",
        reason=body.reason,
        metadata={"expertise": profile.expertise},
    )
    db.commit()
    db.refresh(profile)
    return InstructorProfileView.model_validate(profile, from_attributes=True)


@router.post("/instructors/{user_id}/reject", response_model=InstructorProfileView)
def reject_instructor(
    user_id: uuid.UUID,
    body: AdminSetInstructorStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> InstructorProfileView:
    profile = db.get(InstructorProfile, user_id)
    if not profile:
        profile = InstructorProfile(user_id=user_id, status=InstructorStatus.pending, expertise=[])
        db.add(profile)
    profile.status = InstructorStatus.rejected
    profile.rejected_reason = body.reason or "Rejected by admin"
    profile.approved_by = None
    profile.approved_at = None
    if body.bio is not None:
        profile.bio = body.bio
    if body.expertise:
        profile.expertise = body.expertise
    profile.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="instructor_profile",
        target_id=str(user_id),
        action="instructor_rejected",
        reason=body.reason,
        metadata={"expertise": profile.expertise},
    )
    db.commit()
    db.refresh(profile)
    return InstructorProfileView.model_validate(profile, from_attributes=True)


@router.get("/courses", response_model=AdminCourseListResponse)
def admin_list_courses(
    instructor_user_id: uuid.UUID | None = None,
    niche_slug: str | None = None,
    published: bool | None = None,
    level: CourseLevel | None = None,
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminCourseListResponse:
    ensure_initial_niches(db)
    stmt = select(Course)
    if instructor_user_id:
        stmt = stmt.where(Course.instructor_user_id == instructor_user_id)
    if published is not None:
        stmt = stmt.where(Course.is_published.is_(published))
    if level is not None:
        stmt = stmt.where(Course.level == level)
    if niche_slug:
        niche = db.execute(select(Niche).where(Niche.slug == niche_slug)).scalar_one_or_none()
        if not niche:
            raise APIError(code="validation_error", message="Unknown niche", status_code=422)
        stmt = stmt.where(Course.niche_id == niche.id)

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(stmt.order_by(Course.updated_at.desc()).offset(offset).limit(limit)).scalars().all()
    niche_map = {row.id: row.slug for row in db.execute(select(Niche).where(Niche.id.in_([c.niche_id for c in rows]))).scalars().all()} if rows else {}
    return AdminCourseListResponse(
        total=total,
        items=[_course_list_item(row, niche_map.get(row.niche_id, "")) for row in rows],
    )


@router.post("/courses/{course_id}/unpublish", response_model=CourseListItem)
def admin_unpublish_course(
    course_id: uuid.UUID,
    reason: str | None = None,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CourseListItem:
    course = db.get(Course, course_id)
    if not course:
        raise APIError(code="not_found", message="Course not found", status_code=404)
    course.is_published = False
    course.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="course",
        target_id=str(course.id),
        action="course_unpublished",
        reason=reason,
    )
    db.commit()
    db.refresh(course)
    niche = db.get(Niche, course.niche_id)
    return _course_list_item(course, niche.slug if niche else "")


@router.get("/niches", response_model=list[NicheView])
def admin_list_niches(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[NicheView]:
    ensure_initial_niches(db)
    rows = db.execute(select(Niche).order_by(Niche.slug.asc())).scalars().all()
    db.commit()
    return [NicheView(id=row.id, slug=row.slug, name=row.name, name_key=row.name_key, is_active=row.is_active) for row in rows]


@router.put("/niches", response_model=NicheView)
def admin_upsert_niche(
    body: NicheView,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> NicheView:
    row = db.get(Niche, body.id) if body.id else None
    if row is None:
        by_slug = db.execute(select(Niche).where(Niche.slug == body.slug)).scalar_one_or_none()
        row = by_slug if by_slug else Niche(slug=body.slug, name=body.name, name_key=body.name_key, is_active=body.is_active)
        if by_slug is None:
            db.add(row)
    row.slug = body.slug
    row.name = body.name
    row.name_key = body.name_key
    row.is_active = body.is_active
    row.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="niche",
        target_id=str(row.id),
        action="niche_upsert",
        metadata={"slug": row.slug, "is_active": row.is_active},
    )
    db.commit()
    return NicheView(id=row.id, slug=row.slug, name=row.name, name_key=row.name_key, is_active=row.is_active)


@router.get("/niches/{niche_id}/tier-policy", response_model=NicheTierPolicyView)
def admin_get_niche_tier_policy(
    niche_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> NicheTierPolicyView:
    niche = db.get(Niche, niche_id)
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    row = get_or_create_niche_tier_policy(db, niche_id)
    db.commit()
    return NicheTierPolicyView(niche_id=row.niche_id, thresholds=row.thresholds or default_tier_thresholds(), updated_at=row.updated_at)


@router.put("/niches/{niche_id}/tier-policy", response_model=NicheTierPolicyView)
def admin_put_niche_tier_policy(
    niche_id: uuid.UUID,
    body: NicheTierPolicyUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> NicheTierPolicyView:
    niche = db.get(Niche, niche_id)
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    row = get_or_create_niche_tier_policy(db, niche_id)
    row.thresholds = {k: v.model_dump() for k, v in (body.thresholds or {}).items()} if body.thresholds else default_tier_thresholds()
    row.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="niche_tier_policy",
        target_id=str(niche_id),
        action="niche_tier_policy_upsert",
        metadata={"thresholds": row.thresholds},
    )
    db.commit()
    return NicheTierPolicyView(niche_id=row.niche_id, thresholds=row.thresholds or default_tier_thresholds(), updated_at=row.updated_at)


@router.get("/pros/{pro_user_id}/niche-skill", response_model=ProNicheSkillListResponse)
def admin_get_pro_niche_skill(
    pro_user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ProNicheSkillListResponse:
    rows = db.execute(
        select(ProNicheSkill, Niche)
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .where(ProNicheSkill.pro_user_id == pro_user_id)
        .order_by(ProNicheSkill.score.desc(), ProNicheSkill.updated_at.desc())
    ).all()
    badge_codes = set(list_user_badge_codes(db, pro_user_id))
    items = []
    for skill, niche in rows:
        recent_events = db.execute(
            select(ProNicheSkillEvent)
            .where(ProNicheSkillEvent.pro_user_id == pro_user_id, ProNicheSkillEvent.niche_id == niche.id)
            .order_by(ProNicheSkillEvent.created_at.desc())
            .limit(10)
        ).scalars().all()
        items.append(
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
                confidence=float(skill.confidence or 0),
                evidence_gigs=skill.evidence_gigs,
                evidence_reviews=skill.evidence_reviews,
                evidence_portfolio=skill.evidence_portfolio,
                breakdown={
                    **(skill.breakdown or {}),
                    "recent_events": [
                        {
                            "event_type": e.event_type.value,
                            "from_tier": e.from_tier,
                            "to_tier": e.to_tier,
                            "score_before": e.score_before,
                            "score_after": e.score_after,
                            "created_at": e.created_at.isoformat(),
                        }
                        for e in recent_events
                    ],
                },
                badges=sorted([code for code in badge_codes if code.startswith(f"tier_{niche.slug}_") or code == f"verified_{niche.slug}"]),
                last_promotion_at=skill.last_promotion_at,
                last_demotion_at=skill.last_demotion_at,
                updated_at=skill.updated_at,
            )
        )
    db.commit()
    return ProNicheSkillListResponse(pro_user_id=pro_user_id, items=items)


@router.post("/pros/{pro_user_id}/niche-skill/{niche_id}/override")
def admin_override_niche_skill_v2(
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID,
    body: AdminNicheSkillOverrideV2Request,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    niche = db.get(Niche, niche_id)
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    if body.tier is None and body.score is None and body.verified is None:
        raise APIError(code="validation_error", message="At least one override field is required", status_code=422)
    row = admin_override_niche_skill(
        db,
        pro_user_id=pro_user_id,
        niche_id=niche_id,
        tier=body.tier,
        score=body.score,
        verified=body.verified,
        note=body.note,
        actor_user_id=actor.user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="pro_niche_skill",
        target_id=f"{pro_user_id}:{niche_id}",
        action="pro_niche_skill_override_v2",
        reason=body.note,
        metadata={"tier": row.tier.value, "score": row.score, "verified": row.verified},
    )
    recompute_pro_public_index(db, pro_user_id)
    db.commit()
    return {"pro_user_id": str(pro_user_id), "niche_id": str(niche_id), "tier": row.tier.value, "score": row.score, "verified": row.verified}


@router.post("/niche-skill/recalc")
def admin_niche_skill_recalc(
    body: AdminNicheSkillRecalcRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    if body.pro_user_id:
        enqueue_niche_skill_recalc(db, pro_user_id=body.pro_user_id, niche_id=body.niche_id, reason="admin_recalc")
        db.commit()
        return {"queued": True, "scope": "targeted", "pro_user_id": str(body.pro_user_id), "niche_id": str(body.niche_id) if body.niche_id else None}
    pro_ids = db.execute(select(ProNicheSkill.pro_user_id).distinct()).scalars().all()
    for pro_id in pro_ids:
        enqueue_niche_skill_recalc(db, pro_user_id=pro_id, niche_id=body.niche_id, reason="admin_recalc_bulk")
    db.commit()
    return {"queued": True, "scope": "bulk", "count": len(pro_ids), "niche_id": str(body.niche_id) if body.niche_id else None}


@router.post("/niches/{niche_slug}/requirements", response_model=AdminNicheRequirementsUpsertResponse)
def admin_set_niche_requirements(
    niche_slug: str,
    body: AdminNicheRequirementsUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminNicheRequirementsUpsertResponse:
    ensure_initial_niches(db)
    niche = db.execute(select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    count = replace_niche_program_requirements(db, niche.id, body.tier_target, body.course_ids, body.is_mandatory)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="niche_program_requirement",
        target_id=f"{niche_slug}:{body.tier_target.value}",
        action="niche_requirements_upserted",
        metadata={"course_ids": [str(item) for item in body.course_ids], "is_mandatory": body.is_mandatory},
    )
    db.commit()
    return AdminNicheRequirementsUpsertResponse(niche_slug=niche_slug, tier_target=body.tier_target, count=count)


@router.post("/pros/{pro_user_id}/niches/{niche_slug}/recompute")
def admin_recompute_pro_niche_skill(
    pro_user_id: uuid.UUID,
    niche_slug: str,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    ensure_initial_niches(db)
    niche = db.execute(select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    recompute_pro_niche_skills(db, pro_user_id, niche.id)
    recompute_pro_public_index(db, pro_user_id)
    db.commit()
    return {"ok": True, "pro_user_id": str(pro_user_id), "niche_slug": niche_slug}


@router.post("/jobs/recompute-niche-skills")
def recompute_niche_skills_job(
    pro_user_id: uuid.UUID | None = None,
    niche_slug: str | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    if niche_slug and not pro_user_id:
        raise APIError(code="validation_error", message="pro_user_id is required when niche_slug is provided", status_code=422)
    ensure_initial_niches(db)
    if pro_user_id:
        niche_id = None
        if niche_slug:
            niche = db.execute(select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
            if not niche:
                raise APIError(code="not_found", message="Niche not found", status_code=404)
            niche_id = niche.id
        queued = recompute_pro_niche_skills_task.delay(str(pro_user_id), str(niche_id) if niche_id else None)
        return {"queued": True, "task_id": queued.id}
    queued = recompute_all_pro_niche_skills_task.delay()
    return {"queued": True, "task_id": queued.id}


@router.post("/pros/{pro_user_id}/skills/{niche_slug}/override")
def override_pro_niche_skill(
    pro_user_id: uuid.UUID,
    niche_slug: str,
    body: AdminNicheSkillOverrideRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    ensure_initial_niches(db)
    niche = db.execute(select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))).scalar_one_or_none()
    if not niche:
        raise APIError(code="not_found", message="Niche not found", status_code=404)
    if body.tier is None and body.capability_score is None and body.certification_score is None and body.score is None and body.verified is None:
        raise APIError(code="validation_error", message="At least one override field is required", status_code=422)

    score = body.score
    if score is None and body.capability_score is not None:
        score = body.capability_score
    verified = body.verified
    if verified is None and body.certification_score is not None:
        verified = body.certification_score >= 70
    skill = admin_override_niche_skill(
        db,
        pro_user_id=pro_user_id,
        niche_id=niche.id,
        tier=body.tier,
        score=score,
        verified=verified,
        note=body.reason,
        actor_user_id=actor.user_id,
    )
    override_payload = {"tier": body.tier.value if body.tier else None, "score": score, "verified": verified, "reason": body.reason}

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="pro_niche_skill",
        target_id=f"{pro_user_id}:{niche_slug}",
        action="pro_niche_skill_override",
        reason=body.reason,
        metadata=override_payload,
    )
    recompute_pro_public_index(db, pro_user_id)
    db.commit()
    return {
        "pro_user_id": str(pro_user_id),
        "niche_slug": niche_slug,
        "tier": skill.tier.value,
        "score": skill.score,
        "verified": skill.verified,
    }


@router.get("/ops/metrics-summary", response_model=OpsMetricsSummaryResponse)
def ops_metrics_summary(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> OpsMetricsSummaryResponse:
    since = datetime.now(timezone.utc) - timedelta(hours=24)
    open_signals = db.execute(
        select(func.count()).select_from(AbuseSignal).where(AbuseSignal.status == AbuseSignalStatus.open)
    ).scalar_one()
    webhook_failures = db.execute(
        select(func.count()).select_from(WebhookSecurityLog).where(
            WebhookSecurityLog.signature_valid.is_(False),
            WebhookSecurityLog.received_at >= since,
        )
    ).scalar_one()
    payment_failures = db.execute(
        select(func.count()).select_from(StripePayment).where(
            StripePayment.status == PaymentStatus.failed,
            StripePayment.updated_at >= since,
        )
    ).scalar_one()
    discover_events = db.execute(
        select(func.count()).select_from(AnalyticsEvent).where(
            AnalyticsEvent.event_name.like("discover.%"),
            AnalyticsEvent.created_at >= since,
        )
    ).scalar_one()
    queue_depth_media = 0
    try:
        queue_depth_media = int(get_redis_client().llen("media"))
    except Exception:
        queue_depth_media = 0
    return OpsMetricsSummaryResponse(
        open_abuse_signals=open_signals,
        webhook_signature_failures_24h=webhook_failures,
        payment_failures_24h=payment_failures,
        discover_events_24h=discover_events,
        queue_depth_media=queue_depth_media,
    )


@router.get("/abuse/signals", response_model=list[AbuseSignalView])
def list_abuse_signals(
    signal_type: str | None = None,
    severity: AbuseSeverity | None = None,
    status: AbuseSignalStatus | None = None,
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[AbuseSignalView]:
    stmt = select(AbuseSignal)
    if signal_type:
        stmt = stmt.where(AbuseSignal.signal_type == signal_type)
    if severity:
        stmt = stmt.where(AbuseSignal.severity == severity)
    if status:
        stmt = stmt.where(AbuseSignal.status == status)
    rows = db.execute(stmt.order_by(AbuseSignal.created_at.desc()).limit(limit)).scalars().all()
    return [AbuseSignalView.model_validate(item, from_attributes=True) for item in rows]


@router.post("/abuse/signals/{signal_id}/resolve", response_model=AbuseSignalView)
def resolve_abuse_signal(
    signal_id: uuid.UUID,
    body: ResolveAbuseSignalRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AbuseSignalView:
    row = db.get(AbuseSignal, signal_id)
    if not row:
        raise APIError(code="not_found", message="Abuse signal not found", status_code=404)
    row.status = body.status
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="abuse_signal",
        target_id=str(row.id),
        action="abuse_signal_status_update",
        reason=body.reason,
        metadata={"status": body.status.value},
    )
    db.commit()
    db.refresh(row)
    return AbuseSignalView.model_validate(row, from_attributes=True)


@router.get("/feature-flags", response_model=list[FeatureFlagView])
def list_feature_flags(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[FeatureFlagView]:
    rows = db.execute(select(FeatureFlag).order_by(FeatureFlag.key.asc())).scalars().all()
    return [FeatureFlagView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/feature-flags/{key}", response_model=FeatureFlagView)
def put_feature_flag(
    key: str,
    body: FeatureFlagUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> FeatureFlagView:
    row = upsert_feature_flag(db, key=key, is_enabled=body.is_enabled, scope=body.scope, rules=body.rules)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="feature_flag",
        target_id=key,
        action="feature_flag_upsert",
        reason=None,
        metadata={"is_enabled": body.is_enabled, "scope": body.scope.value, "rules": body.rules},
    )
    db.commit()
    db.refresh(row)
    return FeatureFlagView.model_validate(row, from_attributes=True)


@router.get("/pricing/extra-image-policies", response_model=list[ExtraImagePricingPolicyView])
def list_extra_image_pricing_policies(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ExtraImagePricingPolicyView]:
    rows = db.execute(select(ExtraImagePricingPolicy).order_by(ExtraImagePricingPolicy.updated_at.desc())).scalars().all()
    niche_ids = {row.niche_id for row in rows}
    niche_rows = db.execute(select(Niche).where(Niche.id.in_(niche_ids))).scalars().all() if niche_ids else []
    slug_by_id = {row.id: row.slug for row in niche_rows}
    return [
        ExtraImagePricingPolicyView(
            niche_id=row.niche_id,
            niche_slug=slug_by_id.get(row.niche_id, ""),
            tier=row.tier,
            unit_price_min=row.unit_price_min,
            unit_price_max=row.unit_price_max,
            max_extra_images=row.max_extra_images,
            bulk_curve=row.bulk_curve or {},
            currency=row.currency,
            is_active=row.is_active,
            updated_at=row.updated_at,
        )
        for row in rows
    ]


@router.put("/pricing/extra-image-policies", response_model=list[ExtraImagePricingPolicyView])
def upsert_extra_image_pricing_policies(
    body: ExtraImagePricingPolicyUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ExtraImagePricingPolicyView]:
    ensure_initial_niches(db)
    slugs = [item.niche_slug for item in body.items]
    niches = db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars().all() if slugs else []
    by_slug = {row.slug: row for row in niches}

    for item in body.items:
        niche = by_slug.get(item.niche_slug)
        if not niche:
            raise APIError(code="validation_error", message=f"Unknown niche slug: {item.niche_slug}", status_code=422)
        row = db.execute(
            select(ExtraImagePricingPolicy).where(
                ExtraImagePricingPolicy.niche_id == niche.id,
                ExtraImagePricingPolicy.tier == item.tier,
            )
        ).scalar_one_or_none()
        if not row:
            row = ExtraImagePricingPolicy(niche_id=niche.id, tier=item.tier)
            db.add(row)
        row.unit_price_min = item.unit_price_min
        row.unit_price_max = item.unit_price_max
        row.max_extra_images = item.max_extra_images
        row.bulk_curve = item.bulk_curve
        row.currency = item.currency.upper()
        row.is_active = item.is_active
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="extra_image_pricing_policy",
            target_id=f"{niche.id}:{item.tier.value}",
            action="extra_image_pricing_policy_upsert",
            metadata=item.model_dump(mode="json"),
        )

    db.commit()
    return list_extra_image_pricing_policies(actor, db)  # type: ignore[arg-type]


@router.get("/pricing/package-decay-curves", response_model=list[PackageDecayCurveView])
def list_package_decay_curves(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[PackageDecayCurveView]:
    ensure_initial_niches(db)
    rows = db.execute(select(PackageDecayCurve).order_by(PackageDecayCurve.updated_at.desc())).scalars().all()
    niche_ids = {row.niche_id for row in rows}
    niche_rows = db.execute(select(Niche).where(Niche.id.in_(niche_ids))).scalars().all() if niche_ids else []
    slug_by_id = {row.id: row.slug for row in niche_rows}
    return [
        PackageDecayCurveView(
            niche_id=row.niche_id,
            niche_slug=slug_by_id.get(row.niche_id, ""),
            curve_type=row.curve_type,
            shape_param=row.shape_param,
            floor_pct=row.floor_pct,
            updated_at=row.updated_at,
        )
        for row in rows
    ]


@router.put("/pricing/package-decay-curves", response_model=list[PackageDecayCurveView])
def upsert_package_decay_curves(
    body: PackageDecayCurveUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[PackageDecayCurveView]:
    ensure_initial_niches(db)
    slugs = [item.niche_slug for item in body.items]
    niches = db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars().all() if slugs else []
    by_slug = {row.slug: row for row in niches}

    for item in body.items:
        niche = by_slug.get(item.niche_slug)
        if not niche:
            raise APIError(code="validation_error", message=f"Unknown niche slug: {item.niche_slug}", status_code=422)
        row = db.execute(
            select(PackageDecayCurve).where(PackageDecayCurve.niche_id == niche.id)
        ).scalar_one_or_none()
        if not row:
            row = PackageDecayCurve(niche_id=niche.id)
            db.add(row)
        row.curve_type = item.curve_type
        row.shape_param = item.shape_param
        row.floor_pct = item.floor_pct
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="package_decay_curve",
            target_id=str(niche.id),
            action="package_decay_curve_upsert",
            metadata=item.model_dump(mode="json"),
        )

    db.commit()
    return list_package_decay_curves(actor, db)  # type: ignore[arg-type]


@router.get("/pricing/niche-package-price-caps", response_model=list[NichePackagePriceCapView])
def list_niche_package_price_caps(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[NichePackagePriceCapView]:
    ensure_initial_niches(db)
    rows = db.execute(select(NichePackagePriceCap).order_by(NichePackagePriceCap.updated_at.desc())).scalars().all()
    niche_ids = {row.niche_id for row in rows}
    niche_rows = db.execute(select(Niche).where(Niche.id.in_(niche_ids))).scalars().all() if niche_ids else []
    slug_by_id = {row.id: row.slug for row in niche_rows}
    return [
        NichePackagePriceCapView(
            niche_id=row.niche_id,
            niche_slug=slug_by_id.get(row.niche_id, ""),
            tier=row.tier,
            entry_price_min=row.entry_price_min,
            entry_price_max=row.entry_price_max,
            currency=row.currency,
            updated_at=row.updated_at,
        )
        for row in rows
    ]


@router.put("/pricing/niche-package-price-caps", response_model=list[NichePackagePriceCapView])
def upsert_niche_package_price_caps(
    body: NichePackagePriceCapUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[NichePackagePriceCapView]:
    ensure_initial_niches(db)
    slugs = [item.niche_slug for item in body.items]
    niches = db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars().all() if slugs else []
    by_slug = {row.slug: row for row in niches}

    for item in body.items:
        niche = by_slug.get(item.niche_slug)
        if not niche:
            raise APIError(code="validation_error", message=f"Unknown niche slug: {item.niche_slug}", status_code=422)
        row = db.execute(
            select(NichePackagePriceCap).where(
                NichePackagePriceCap.niche_id == niche.id,
                NichePackagePriceCap.tier == item.tier,
            )
        ).scalar_one_or_none()
        if not row:
            row = NichePackagePriceCap(niche_id=niche.id, tier=item.tier)
            db.add(row)
        row.entry_price_min = item.entry_price_min
        row.entry_price_max = item.entry_price_max
        row.currency = item.currency.upper()
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="niche_package_price_cap",
            target_id=f"{niche.id}:{item.tier.value}",
            action="niche_package_price_cap_upsert",
            metadata=item.model_dump(mode="json"),
        )

    db.commit()
    return list_niche_package_price_caps(actor, db)  # type: ignore[arg-type]


@router.get("/pricing/pro-extra-image-price/{pro_user_id}", response_model=list[ProExtraImagePriceView])
def list_pro_extra_image_prices(
    pro_user_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ProExtraImagePriceView]:
    rows = db.execute(select(ProExtraImagePrice).where(ProExtraImagePrice.pro_user_id == pro_user_id)).scalars().all()
    niche_ids = {row.niche_id for row in rows}
    niches = db.execute(select(Niche).where(Niche.id.in_(niche_ids))).scalars().all() if niche_ids else []
    slug_by_id = {row.id: row.slug for row in niches}
    return [
        ProExtraImagePriceView(
            pro_user_id=row.pro_user_id,
            niche_id=row.niche_id,
            niche_slug=slug_by_id.get(row.niche_id, ""),
            configured_unit_price=row.configured_unit_price,
            currency=row.currency,
            updated_at=row.updated_at,
        )
        for row in rows
    ]


@router.put("/pricing/pro-extra-image-price/{pro_user_id}", response_model=list[ProExtraImagePriceView])
def upsert_pro_extra_image_prices(
    pro_user_id: uuid.UUID,
    body: ProExtraImagePriceUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ProExtraImagePriceView]:
    ensure_initial_niches(db)
    slugs = [item.niche_slug for item in body.items]
    niches = db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars().all() if slugs else []
    by_slug = {row.slug: row for row in niches}
    for item in body.items:
        niche = by_slug.get(item.niche_slug)
        if not niche:
            raise APIError(code="validation_error", message=f"Unknown niche slug: {item.niche_slug}", status_code=422)
        row = db.execute(
            select(ProExtraImagePrice).where(
                ProExtraImagePrice.pro_user_id == pro_user_id,
                ProExtraImagePrice.niche_id == niche.id,
            )
        ).scalar_one_or_none()
        if not row:
            row = ProExtraImagePrice(pro_user_id=pro_user_id, niche_id=niche.id, configured_unit_price=item.configured_unit_price)
            db.add(row)
        row.configured_unit_price = item.configured_unit_price
        row.currency = item.currency.upper()
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="pro_extra_image_price",
            target_id=f"{pro_user_id}:{niche.id}",
            action="pro_extra_image_price_upsert",
            metadata=item.model_dump(mode="json"),
        )
    db.commit()
    return list_pro_extra_image_prices(pro_user_id, actor, db)  # type: ignore[arg-type]


@router.get("/rewards/consent-policies", response_model=list[ConsentRewardPolicyView])
def list_consent_reward_policies(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ConsentRewardPolicyView]:
    ensure_default_consent_reward_policies(db)
    rows = db.execute(select(ConsentRewardPolicy).order_by(ConsentRewardPolicy.updated_at.desc())).scalars().all()
    return [ConsentRewardPolicyView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/rewards/consent-policies", response_model=list[ConsentRewardPolicyView])
def upsert_consent_reward_policies(
    body: ConsentRewardPolicyUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ConsentRewardPolicyView]:
    ensure_default_consent_reward_policies(db)
    for item in body.items:
        row = db.execute(select(ConsentRewardPolicy).where(ConsentRewardPolicy.consent_level == item.consent_level)).scalar_one_or_none()
        if not row:
            row = ConsentRewardPolicy(consent_level=item.consent_level)
            db.add(row)
        row.points_award = item.points_award
        row.cooldown_hours = item.cooldown_hours
        row.allow_clawback = item.allow_clawback
        row.max_awards_per_user_per_month = item.max_awards_per_user_per_month
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="consent_reward_policy",
            target_id=item.consent_level.value,
            action="consent_reward_policy_upsert",
            metadata=item.model_dump(mode="json"),
        )
    db.commit()
    return list_consent_reward_policies(actor, db)  # type: ignore[arg-type]


@router.get("/rewards/share-thresholds", response_model=list[ShareRewardThresholdView])
def list_share_thresholds(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ShareRewardThresholdView]:
    ensure_default_share_thresholds(db)
    rows = db.execute(select(ShareRewardThreshold).order_by(ShareRewardThreshold.threshold_value.asc())).scalars().all()
    return [ShareRewardThresholdView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/rewards/share-thresholds", response_model=list[ShareRewardThresholdView])
def upsert_share_thresholds(
    body: ShareRewardThresholdUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ShareRewardThresholdView]:
    ensure_default_share_thresholds(db)
    for item in body.items:
        row = db.execute(
            select(ShareRewardThreshold).where(
                ShareRewardThreshold.metric == item.metric,
                ShareRewardThreshold.threshold_value == item.threshold_value,
            )
        ).scalar_one_or_none()
        if not row:
            row = ShareRewardThreshold(metric=item.metric, threshold_value=item.threshold_value, points_award=item.points_award)
            db.add(row)
        row.points_award = item.points_award
        row.max_awards_per_share_link = item.max_awards_per_share_link
        row.is_active = item.is_active
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="share_reward_threshold",
            target_id=f"{item.metric.value}:{item.threshold_value}",
            action="share_reward_threshold_upsert",
            metadata=item.model_dump(mode="json"),
        )
    db.commit()
    return list_share_thresholds(actor, db)  # type: ignore[arg-type]


@router.get("/rewards/share-grants", response_model=list[ShareRewardGrantView])
def list_share_reward_grants(
    user_id: uuid.UUID | None = None,
    share_link_id: uuid.UUID | None = None,
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[ShareRewardGrantView]:
    stmt = select(ShareRewardGrant).order_by(ShareRewardGrant.granted_at.desc())
    if user_id:
        stmt = stmt.where(ShareRewardGrant.user_id == user_id)
    if share_link_id:
        stmt = stmt.where(ShareRewardGrant.share_link_id == share_link_id)
    rows = db.execute(stmt.limit(limit)).scalars().all()
    return [ShareRewardGrantView.model_validate(row, from_attributes=True) for row in rows]


@router.get("/rewards/share-fraud-settings", response_model=ShareFraudSettingsView)
def get_share_fraud_settings_admin(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ShareFraudSettingsView:
    values = get_share_fraud_settings(db)
    return ShareFraudSettingsView(**values)


@router.put("/rewards/share-fraud-settings", response_model=ShareFraudSettingsView)
def put_share_fraud_settings_admin(
    body: ShareFraudSettingsUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ShareFraudSettingsView:
    incoming = {k: v for k, v in body.model_dump().items() if v is not None}
    values = upsert_share_fraud_settings(db, incoming)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="share_fraud_settings",
        target_id="global",
        action="share_fraud_settings_upsert",
        metadata=incoming,
    )
    db.commit()
    return ShareFraudSettingsView(**values)


@router.get("/raww/issuance-rules", response_model=list[RawwIssuanceRuleView])
def list_raww_issuance_rules(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RawwIssuanceRuleView]:
    ensure_default_raww_config(db)
    rows = db.execute(select(RawwIssuanceRule).order_by(RawwIssuanceRule.event_type.asc())).scalars().all()
    return [RawwIssuanceRuleView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/raww/issuance-rules", response_model=list[RawwIssuanceRuleView])
def put_raww_issuance_rules(
    body: RawwIssuanceRulesUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RawwIssuanceRuleView]:
    ensure_default_raww_config(db)
    for item in body.items:
        row = db.execute(select(RawwIssuanceRule).where(RawwIssuanceRule.event_type == item.event_type)).scalar_one_or_none()
        if not row:
            row = RawwIssuanceRule(event_type=item.event_type, base_raww=item.base_raww, min_eur_value=item.min_eur_value)
            db.add(row)
        row.base_raww = int(item.base_raww)
        row.min_eur_value = item.min_eur_value
        row.max_raww_per_event = item.max_raww_per_event
        row.is_active = item.is_active
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="raww_issuance_rule",
            target_id=item.event_type.value,
            action="raww_issuance_rule_upsert",
            metadata=item.model_dump(mode="json"),
        )
    db.commit()
    return list_raww_issuance_rules(actor, db)  # type: ignore[arg-type]


@router.get("/raww/multiplier-policy", response_model=RawwMultiplierPolicyView)
def get_raww_multiplier_policy(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RawwMultiplierPolicyView:
    ensure_default_raww_config(db)
    row = db.execute(select(RawwMultiplierPolicy).where(RawwMultiplierPolicy.name == "default")).scalar_one()
    return RawwMultiplierPolicyView.model_validate(row, from_attributes=True)


@router.put("/raww/multiplier-policy", response_model=RawwMultiplierPolicyView)
def put_raww_multiplier_policy(
    body: RawwMultiplierPolicyUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RawwMultiplierPolicyView:
    ensure_default_raww_config(db)
    row = db.execute(select(RawwMultiplierPolicy).where(RawwMultiplierPolicy.name == "default")).scalar_one()
    row.tier_multipliers = body.tier_multipliers or {}
    row.rating_curve = body.rating_curve or {}
    row.dispute_penalty = body.dispute_penalty or {}
    row.refund_penalty_multiplier = body.refund_penalty_multiplier
    row.abuse_block_threshold = body.abuse_block_threshold or {}
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="raww_multiplier_policy",
        target_id=row.name,
        action="raww_multiplier_policy_upsert",
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return RawwMultiplierPolicyView.model_validate(row, from_attributes=True)


@router.get("/raww/caps", response_model=list[RawwCapView])
def list_raww_caps(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RawwCapView]:
    ensure_default_raww_config(db)
    rows = db.execute(select(RawwIssuanceCap).order_by(RawwIssuanceCap.scope.asc())).scalars().all()
    return [RawwCapView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/raww/caps", response_model=list[RawwCapView])
def put_raww_caps(
    body: RawwCapsUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RawwCapView]:
    ensure_default_raww_config(db)
    for item in body.items:
        row = db.execute(select(RawwIssuanceCap).where(RawwIssuanceCap.scope == item.scope)).scalar_one_or_none()
        if not row:
            row = RawwIssuanceCap(scope=item.scope, cap_raww=item.cap_raww)
            db.add(row)
        row.cap_raww = int(item.cap_raww)
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="raww_cap",
            target_id=item.scope.value,
            action="raww_cap_upsert",
            metadata=item.model_dump(mode="json"),
        )
    db.commit()
    return list_raww_caps(actor, db)  # type: ignore[arg-type]


@router.get("/raww/mints", response_model=list[RawwMintEventView])
def get_raww_mints(
    pro_user_id: uuid.UUID | None = None,
    event_type: str | None = None,
    from_at: datetime | None = Query(default=None, alias="from"),
    to_at: datetime | None = Query(default=None, alias="to"),
    limit: int = Query(default=100, ge=1, le=500),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RawwMintEventView]:
    rows = list_raww_mints(
        db,
        pro_user_id=pro_user_id,
        event_type=event_type,
        from_at=from_at,
        to_at=to_at,
        limit=limit,
    )
    return [RawwMintEventView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/raww/clawback", response_model=RawwClawbackResponse)
def post_raww_clawback(
    body: RawwClawbackRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RawwClawbackResponse:
    row = create_raww_clawback(
        db,
        pro_user_id=body.pro_user_id,
        reference_type=body.reference_type,
        reference_id=body.reference_id,
        amount_raww=body.amount_raww,
        reason=body.reason,
        created_by_admin_id=actor.user_id,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="raww_clawback",
        target_id=str(row.id),
        action="raww_clawback_created",
        reason=body.reason,
        metadata=body.model_dump(mode="json"),
    )
    db.commit()
    db.refresh(row)
    return RawwClawbackResponse.model_validate(row, from_attributes=True)


def _course_list_item(course: Course, niche_slug: str) -> CourseListItem:
    return CourseListItem(
        id=course.id,
        instructor_user_id=course.instructor_user_id,
        title=course.title,
        summary=course.summary,
        niche_slug=niche_slug,
        level=course.level,
        is_mandatory=course.is_mandatory,
        is_published=course.is_published,
        price=course.price,
        currency=course.currency,
        estimated_minutes=course.estimated_minutes,
        thumbnail_media_asset_id=course.thumbnail_media_asset_id,
        intro_video_media_asset_id=course.intro_video_media_asset_id,
    )


def _dispute_detail_view(db: Session, dispute: Dispute) -> DisputeDetailView:
    from app.models.admin import DisputeMessage

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
        summary=dispute.summary or "",
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


def _refund_case_detail_view(item: RefundCase) -> RefundCaseDetailView:
    return RefundCaseDetailView(
        id=item.id,
        dispute_id=item.dispute_id,
        payment_scope=item.payment_scope.value if item.payment_scope else None,
        reference_id=item.reference_id,
        stripe_payment_intent_id=item.stripe_payment_intent_id,
        amount_authorized=item.amount_authorized,
        amount_refunded=item.amount_refunded,
        amount=item.amount,
        currency=item.currency,
        status=item.status,
        metadata=item.meta or {},
        created_at=item.created_at,
        updated_at=item.updated_at,
    )


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
