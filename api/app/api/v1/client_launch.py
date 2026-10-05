from __future__ import annotations

import uuid
from collections import Counter
from collections.abc import Sequence
from datetime import date, datetime, time, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_write_session, get_optional_current_user, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.models.admin import KYCStatus, ProProfile, UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition, ProAvailabilityRule, ProPackage
from app.models.client_launch import ClientPreference, ClientWaitlist, MatchRequest as MatchRequestLog, MatchResult as MatchResultLog
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus, StripePayment, StripePaymentKind
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.media import MediaAsset, MediaKind, MediaPurpose, MediaStatus
from app.models.media_rights import GigConsentLevel
from app.models.niche import Niche, ProNiche, ProNicheSkill, SkillTier
from app.models.review import Review, ReviewReply
from app.schemas.client_launch import (
    ClientAccessResponse,
    ClientAvailabilityDay,
    ClientAvailabilityResponse,
    ClientAvailabilityStart,
    ClientBookingListItem,
    ClientBookingListResponse,
    ClientBookingPayRequest,
    ClientBookingPayResponse,
    ClientBookingRequestCreateRequest,
    ClientBookingRequestCreateResponse,
    ClientBookingStatusResponse,
    ClientDiscoverCard,
    ClientDiscoverResponse,
    ClientHomeNiche,
    ClientHomeResponse,
    ClientHomeRow,
    ClientMatchCard,
    ClientMatchCreateRequest,
    ClientMatchResponse,
    ClientPortfolioItem,
    ClientPreferenceUpdateRequest,
    ClientPreferenceView,
    ClientProfileNiche,
    ClientProfilePackage,
    ClientProProfileResponse,
    ClientWaitlistCreateRequest,
    ClientWaitlistCreateResponse,
    ProListingPreviewResponse,
)
from app.schemas.media import CurrentUser
from app.api.v1.reviews import build_review_view
from app.services.analytics import log_event
from app.services.availability_blocks import blocked_intervals
from app.services.bookable_time import (
    PAYMENT_WINDOW,
    bookable_windows,
    check_bookable,
    check_offered,
    gig_preset,
    shape_for_package,
)
from app.services.authz import ensure_user_account, get_user_roles
from app.services.cache import cache_get_json, cache_set_json, get_public_index_version
from app.services.discovery_index import recompute_pro_public_index
from app.services.client_launch import MatchInput, ensure_client_role, evaluate_client_city_access, match_candidates
from app.services.feature_flags import is_feature_enabled
from app.services.package_pricing import MINIMUM_PHOTOS, compute_minimum_amount
from app.services.media_urls import ORIGINAL_FIRST, THUMBNAIL_FIRST, resolve_image_urls, resolve_niche_cover_urls
from app.services.notifications import enqueue_notification
from app.services.outbox import enqueue_outbox_event
from app.services.payment_intents import create_or_get_gig_payment_intent
from app.services.pagination import DEFAULT_LIMIT, MAX_LIMIT, apply_keyset, build_page
from app.services.rate_limit import enforce_named_rate_limit, enforce_rate_limit
from app.models.risk import RiskActionType
from app.services.trust_safety import (
    enforce_require_verification_if_flagged,
    enforce_risk_action_not_active,
    evaluate_booking_spam_rule,
)
from app.services.search_provider import get_index_name, get_search_provider, search_provider_enabled

settings = get_settings()
# How many portfolio photos a public profile returns.
#
# 8 covered a single flat grid. Once the grid splits by niche the same 8 has
# to cover every tab, and a photographer working in three niches would show
# three photos each - the tabs would make the profile look emptier than the
# undivided grid they replace.
PROFILE_PORTFOLIO_LIMIT = 24


router = APIRouter(tags=["client_launch"])


@router.get("/client/access", response_model=ClientAccessResponse)
def get_client_access(
    country: str,
    city: str,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
) -> ClientAccessResponse:
    decision = evaluate_client_city_access(db, country=country, city=city, user_id=user.user_id if user else None)
    return ClientAccessResponse(enabled=decision.enabled, reason=decision.reason, waitlist_available=True)


@router.post("/client/waitlist", response_model=ClientWaitlistCreateResponse)
def create_waitlist_entry(
    body: ClientWaitlistCreateRequest,
    db: Session = Depends(get_db_write_session),
) -> ClientWaitlistCreateResponse:
    email = body.email.strip().lower()
    country = body.country.strip().upper()
    city = body.city.strip()
    if not email or "@" not in email:
        raise APIError(code="validation_error", message="Invalid email", status_code=422)
    if not country or not city:
        raise APIError(code="validation_error", message="country and city are required", status_code=422)

    # Rejected rather than coerced. Quietly filing an unrecognised role as
    # "client" would fabricate demand signal, and this list exists to
    # decide which market to open next - a wrong row is worse than a
    # missing one.
    normalised_role = (body.role or "").strip().lower() or None
    if normalised_role is not None and normalised_role not in {"client", "pro"}:
        raise APIError(
            code="validation_error",
            message="role must be 'client' or 'pro'",
            status_code=422,
        )

    existing = db.execute(
        select(ClientWaitlist).where(
            ClientWaitlist.email == email,
            ClientWaitlist.country == country,
            ClientWaitlist.city == city,
        )
    ).scalar_one_or_none()
    if not existing:
        db.add(
            ClientWaitlist(
                email=email,
                country=country,
                city=city,
                niche_slug=body.niche_slug.strip() if body.niche_slug else None,
                # Normalised here rather than trusted: a free-text role would
                # make the demand signal unaggregatable.
                role=normalised_role,
            )
        )
        enqueue_outbox_event(
            db,
            topic="client.waitlist.confirmation_email",
            payload={"email": email, "country": country, "city": city},
            idempotency_key=f"client-waitlist-confirm:{email}:{country}:{city}",
            idempotency_scope="client_waitlist_confirm",
        )
    db.commit()
    return ClientWaitlistCreateResponse(accepted=True)


@router.get("/client/discover", response_model=ClientDiscoverResponse)
def client_discover(
    country: str,
    city: str,
    niche_slug: str | None = None,
    q: str | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    sort: str = "rank",
    limit: int = Query(default=20, ge=1, le=40),
    offset: int = Query(default=0, ge=0),
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
    db_write: Session = Depends(get_db_write_session),
) -> ClientDiscoverResponse:
    _enforce_city_gate(db, country=country, city=city, user=user)
    _enforce_guest_mode(db, user=user)
    principal = str(user.user_id) if user else "guest"
    enforce_named_rate_limit("public_read", principal=principal)
    if not user and offset >= 20:
        raise APIError(code="forbidden", message="Sign in required for deeper browsing", status_code=403)

    cache_key = (
        f"client:discover:v{get_public_index_version()}:country={country.upper()}:city={city.lower()}:"
        f"niche={niche_slug or ''}:q={q or ''}:min={min_price or ''}:max={max_price or ''}:sort={sort}:limit={limit}:offset={offset}:guest={not bool(user)}"
    )
    cached = cache_get_json(cache_key)
    if cached:
        return ClientDiscoverResponse.model_validate(cached)

    rows = _discover_rows(
        db,
        q=q,
        country=country,
        city=city,
        niche_slug=niche_slug,
        min_price=min_price,
        max_price=max_price,
        sort=sort,
        limit=limit,
        offset=offset,
    )
    items = _cards_from_index(db, rows)
    response = ClientDiscoverResponse(total=len(items), items=items, guest_limited=user is None)
    cache_set_json(cache_key, response.model_dump(mode="json"), ttl_seconds=max(10, settings.discover_cache_ttl_seconds))

    log_event(
        db_write,
        event_name="client.discover_view",
        user_id=user.user_id if user else None,
        properties={"country": country.upper(), "city": city, "niche_slug": niche_slug, "count": len(items)},
    )
    db_write.commit()
    return response


@router.post("/client/match", response_model=ClientMatchResponse)
def client_match(
    body: ClientMatchCreateRequest,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_write_session),
) -> ClientMatchResponse:
    _enforce_city_gate(db, country=body.country, city=body.city, user=user)
    _enforce_guest_mode(db, user=user)
    principal = str(user.user_id) if user else "guest"
    enforce_named_rate_limit("public_read", principal=principal)

    req = MatchRequestLog(
        user_id=user.user_id if user else None,
        country=body.country.strip().upper(),
        city=body.city.strip(),
        niche_slug=body.niche_slug.strip(),
        budget_min=body.budget_min,
        budget_max=body.budget_max,
        style_tags=body.style_tags or [],
    )
    db.add(req)
    db.flush()

    try:
        _, scored = match_candidates(
            db,
            req=MatchInput(
                country=req.country,
                city=req.city,
                niche_slug=req.niche_slug,
                budget_min=req.budget_min,
                budget_max=req.budget_max,
                style_tags=req.style_tags or [],
            ),
            limit=20,
        )
    except ValueError as exc:
        raise APIError(code="validation_error", message=str(exc), status_code=422) from exc

    show_breakdown = settings.app_env.lower() in {"dev", "development", "test"}
    ranked: list[tuple[int, ProPublicIndex, object]] = []
    for idx, candidate in enumerate(scored, start=1):
        row = db.get(ProPublicIndex, candidate.pro_user_id)
        if not row:
            continue
        db.add(
            MatchResultLog(
                match_request_id=req.id,
                pro_user_id=row.pro_user_id,
                rank=idx,
                score=candidate.score,
                score_breakdown=candidate.breakdown,
            )
        )
        ranked.append((idx, row, candidate))

    # Cards are built once for the whole result set rather than inside the loop
    # above, so a twenty-match response resolves cover images in one pass.
    cards = {
        card.pro_user_id: card
        for card in _cards_from_index(db, [row for _, row, _ in ranked])
    }
    items = [
        ClientMatchCard(
            pro_user_id=row.pro_user_id,
            rank=rank,
            score=candidate.score,
            card=cards[row.pro_user_id],
            score_breakdown=candidate.breakdown if show_breakdown else None,
        )
        for rank, row, candidate in ranked
    ]

    log_event(
        db,
        event_name="client.match_created",
        user_id=user.user_id if user else None,
        properties={"country": req.country, "city": req.city, "niche_slug": req.niche_slug, "count": len(items)},
    )
    db.commit()
    return ClientMatchResponse(match_request_id=req.id, items=items)


@router.get("/client/pros/{pro_user_id}", response_model=ClientProProfileResponse)
def client_pro_profile(
    pro_user_id: uuid.UUID,
    country: str,
    city: str,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
    db_write: Session = Depends(get_db_write_session),
) -> ClientProProfileResponse:
    _enforce_city_gate(db, country=country, city=city, user=user)
    if user is None:
        raise APIError(code="unauthorized", message="Authentication required for profile details", status_code=401)
    principal = str(user.user_id) if user else "guest"
    enforce_named_rate_limit("public_read", principal=principal)

    idx = db.get(ProPublicIndex, pro_user_id)
    profile = db.get(ProProfile, pro_user_id)
    onboarding = db.get(ProOnboarding, pro_user_id)
    if not idx or not profile or not onboarding or onboarding.status != ProOnboardingStatus.approved_public:
        raise APIError(code="not_found", message="Pro not found", status_code=404)

    # Joined rather than looked up per package: the slug is what makes a
    # package bookable, and an inner join is safe because ProPackage.niche_id
    # is non-nullable with a foreign key. A package whose niche vanished could
    # not be booked anyway, so dropping it beats offering a dead button.
    package_rows = db.execute(
        select(ProPackage, Niche.slug)
        .join(Niche, Niche.id == ProPackage.niche_id)
        .where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.price.asc())
    ).all()
    # 8 was enough for one flat grid. Splitting the same 8 across a
    # photographer's niches leaves three or four photos per tab, which is
    # thinner than the grid it replaces - the tabs would make the profile look
    # emptier, not better organised.
    portfolio_rows = db.execute(
        select(MediaAsset.id, MediaAsset.kind, MediaAsset.niche_tags)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
            MediaAsset.kind.in_([MediaKind.photo, MediaKind.video]),
        )
        .order_by(MediaAsset.created_at.desc())
        .limit(PROFILE_PORTFOLIO_LIMIT)
    ).all()

    # Which niches this photographer actually has work in, and how much.
    # Counted from the photos being returned rather than from their skill
    # rows: recompute_pro_niche_skills writes a row for every active niche, so
    # skills would offer a tab for all twelve and leave ten of them empty.
    photos_per_niche: Counter[str] = Counter()
    for _asset_id, kind, tags in portfolio_rows:
        if kind != MediaKind.photo:
            continue
        for slug in tags or []:
            photos_per_niche[slug] += 1

    profile_niches: list[ClientProfileNiche] = []
    if photos_per_niche:
        niche_rows = db.execute(
            select(Niche, ProNicheSkill)
            .outerjoin(
                ProNicheSkill,
                (ProNicheSkill.niche_id == Niche.id) & (ProNicheSkill.pro_user_id == pro_user_id),
            )
            .where(Niche.slug.in_(photos_per_niche.keys()))
        ).all()
        declared = {
            row.niche_id: row
            for row in db.execute(select(ProNiche).where(ProNiche.pro_user_id == pro_user_id)).scalars().all()
        }
        profile_niches = sorted(
            (
                ClientProfileNiche(
                    slug=niche.slug,
                    name=niche.name,
                    # No skill row means rookie, the same default the price cap
                    # resolves to, rather than omitting the niche entirely.
                    tier=skill.tier if skill else SkillTier.rookie,
                    photo_count=photos_per_niche[niche.slug],
                    description=(declared[niche.id].description if niche.id in declared else None),
                )
                for niche, skill in niche_rows
            ),
            key=lambda item: (-item.photo_count, item.slug),
        )

    # This response is not cached, so the base lifetime is the whole story.
    portfolio_urls = resolve_image_urls(
        db,
        [asset_id for asset_id, _, _ in portfolio_rows],
        prefer=THUMBNAIL_FIRST,
        expires_in=MEDIA_URL_BASE_TTL_SECONDS,
    )
    cover_urls = resolve_image_urls(
        db,
        [profile.cover_media_asset_id],
        prefer=ORIGINAL_FIRST,
        expires_in=MEDIA_URL_BASE_TTL_SECONDS,
    )

    response = ClientProProfileResponse(
        pro_user_id=pro_user_id,
        display_name=profile.display_name,
        headline=profile.headline,
        cover_media_asset_id=profile.cover_media_asset_id,
        cover_url=cover_urls.get(profile.cover_media_asset_id) if profile.cover_media_asset_id else None,
        bio=profile.bio,
        city=profile.city,
        country=profile.country,
        styles=profile.styles or [],
        avg_rating=idx.avg_rating,
        review_count=idx.review_count,
        portfolio_photo_count=idx.portfolio_photo_count,
        portfolio_video_count=idx.portfolio_video_count,
        packages=[
            ClientProfilePackage(
                id=item.id,
                niche_slug=niche_slug,
                title=item.title,
                description=item.description,
                duration_minutes=item.duration_minutes,
                price=item.price,
                currency=item.currency,
                included_photos=item.included_photos,
                entry_rate=item.price,
                minimum_photos=max(MINIMUM_PHOTOS, item.included_photos),
                starting_total=compute_minimum_amount(
                    db,
                    niche_id=item.niche_id,
                    entry_rate=item.price,
                    included_photos=item.included_photos,
                ),
                extra_photo_price=item.extra_photo_price,
                proofs_sla_days=item.proofs_sla_days,
                finals_sla_days=item.finals_sla_days,
            )
            for item, niche_slug in package_rows
        ],
        portfolio_preview_asset_ids=[asset_id for asset_id, _, _ in portfolio_rows],
        portfolio_preview=[
            ClientPortfolioItem(
                media_asset_id=asset_id,
                kind=kind.value,
                thumbnail_url=portfolio_urls.get(asset_id),
                niche_slugs=list(tags or []),
            )
            for asset_id, kind, tags in portfolio_rows
        ],
        # Every niche this photographer has work in, always - including when
        # there is only one.
        #
        # This used to send an empty list for a single-niche photographer as a
        # signal not to draw a selector. That conflated "do not show a
        # selector" with "do not send the data", and the tier rides on this
        # list: 32 of 42 photographers had no tier on their profile at all,
        # and the other 10 showed one only after a tab was tapped. The server
        # states what is true; whether one niche is worth a selector is the
        # client's decision.
        niches=profile_niches,
        is_guest_view=False,
    )
    log_event(
        db_write,
        event_name="client.pro_profile_view",
        user_id=user.user_id if user else None,
        properties={"country": country.upper(), "city": city, "pro_user_id": str(pro_user_id)},
    )
    db_write.commit()
    return response


# How far ahead a client can look, and how much at once. Ninety days covers
# how far ahead people book a shoot; one request is capped at about two months
# so a calendar page costs a few queries, not a year of slot arithmetic.
AVAILABILITY_HORIZON_DAYS = 90
AVAILABILITY_MAX_SPAN_DAYS = 62


@router.get("/client/pros/{pro_user_id}/availability", response_model=ClientAvailabilityResponse)
def client_pro_availability(
    pro_user_id: uuid.UUID,
    package_id: uuid.UUID,
    from_date: date = Query(alias="from"),
    to_date: date = Query(alias="to"),
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
) -> ClientAvailabilityResponse:
    """When a client could book this package with this photographer.

    The same rule every booking path enforces (bookable_time), so a start time
    offered here is one the booking request accepts. Gated like the profile:
    signed in, a live photographer, the photographer's city open to clients.
    """
    if user is None:
        raise APIError(code="unauthorized", message="Sign in to see when this photographer is available", status_code=401)
    enforce_named_rate_limit("public_read", principal=str(user.user_id))

    profile = db.get(ProProfile, pro_user_id)
    onboarding = db.get(ProOnboarding, pro_user_id)
    if not profile or not onboarding or onboarding.status != ProOnboardingStatus.approved_public:
        raise APIError(code="not_found", message="Pro not found", status_code=404)
    if profile.country and profile.city:
        _enforce_city_gate(db, country=profile.country, city=profile.city, user=user)

    package = db.get(ProPackage, package_id)
    if not package or package.pro_user_id != pro_user_id or not package.is_active:
        raise APIError(code="not_found", message="Package not found", status_code=404)

    today = datetime.now(timezone.utc).date()
    if to_date < from_date:
        raise APIError(code="validation_error", message="to must not be before from", status_code=422)
    if from_date < today:
        raise APIError(code="validation_error", message="from must not be in the past", status_code=422)
    if (to_date - from_date).days + 1 > AVAILABILITY_MAX_SPAN_DAYS:
        raise APIError(code="validation_error", message=f"Ask for at most {AVAILABILITY_MAX_SPAN_DAYS} days at once", status_code=422)
    if to_date > today + timedelta(days=AVAILABILITY_HORIZON_DAYS):
        raise APIError(code="validation_error", message=f"Availability is shown up to {AVAILABILITY_HORIZON_DAYS} days ahead", status_code=422)

    # The package's own layout - hourly, 4-hour, its named blocks, or the
    # whole day - through the same rule every booking path applies.
    shape = shape_for_package(db, package)
    cal, windows = bookable_windows(db, pro_user_id=pro_user_id, shape=shape, from_date=from_date, to_date=to_date)
    by_day: dict[date, list[ClientAvailabilityStart]] = {}
    for window in windows:
        local = window.start.astimezone(cal.tz)
        local_end = window.end.astimezone(cal.tz)
        by_day.setdefault(local.date(), []).append(
            ClientAvailabilityStart(
                start_at=local,
                local_time=local.strftime("%H:%M"),
                end_at=local_end,
                local_end_time=local_end.strftime("%H:%M"),
                label=window.label.value if window.label else None,
            )
        )

    days = []
    current = from_date
    while current <= to_date:
        times = by_day.get(current, [])
        days.append(ClientAvailabilityDay(date=current, open=bool(times), start_times=times))
        current += timedelta(days=1)

    return ClientAvailabilityResponse(
        timezone=cal.tz.key,
        has_schedule=cal.has_schedule,
        notice_hours=cal.policy.advance_notice_hours,
        scheduling_preset=shape.preset.value,
        days=days,
    )


@router.post("/client/bookings/request", response_model=ClientBookingRequestCreateResponse)
def client_booking_request(
    body: ClientBookingRequestCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> ClientBookingRequestCreateResponse:
    enforce_require_verification_if_flagged(db, user_id=user.user_id)
    enforce_risk_action_not_active(
        db,
        user_id=user.user_id,
        action_type=RiskActionType.throttle_bookings,
        message="Booking requests are temporarily throttled for this account",
        code="rate_limited",
    )
    pro_profile = db.get(ProProfile, body.pro_user_id)
    if not pro_profile or not pro_profile.country or not pro_profile.city:
        raise APIError(code="validation_error", message="Pro location not available", status_code=422)
    _enforce_city_gate(db, country=pro_profile.country, city=pro_profile.city, user=user)
    if not is_feature_enabled(db, "client_booking_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Client booking is disabled", status_code=503)
    enforce_rate_limit(f"client-booking-request:{user.user_id}", max_requests=5, window_seconds=86400)
    ensure_user_account(db, user.user_id)
    ensure_client_role(db, user_id=user.user_id)
    if body.date_window.end_at <= body.date_window.start_at:
        raise APIError(code="validation_error", message="Invalid date window", status_code=422)

    package = db.get(ProPackage, body.package_id)
    if not package or package.pro_user_id != body.pro_user_id or not package.is_active:
        raise APIError(code="validation_error", message="Invalid package", status_code=422)
    niche = db.execute(select(Niche).where(Niche.id == package.niche_id)).scalar_one_or_none()
    if not niche or niche.slug != body.niche_slug:
        raise APIError(code="validation_error", message="niche_slug does not match package", status_code=422)

    # Told here rather than at accept: a request the pro can only decline
    # costs the client a day of waiting to learn what the server already
    # knew. The same rule the calendar offers times from (bookable_time), so
    # a time the calendar shows is accepted and one it does not is refused.
    #
    # This used to refuse only a window wholly inside blocked time, on the
    # premise that a request was a flexible window pinned down later. The app
    # has sent an exact package-length time for a long while, and that
    # leniency took 3am on a day the photographer does not work.
    shape = shape_for_package(db, package)
    check_bookable(
        db,
        pro_user_id=body.pro_user_id,
        start_at_utc=body.date_window.start_at,
        end_at_utc=body.date_window.end_at,
        preset=shape.preset,
    )
    # And it must be a window this package offers at all - free time is not
    # enough. Without this the package's preset would only shape what the
    # calendar shows, not what can be requested.
    check_offered(
        db,
        pro_user_id=body.pro_user_id,
        shape=shape,
        start_at_utc=body.date_window.start_at,
        end_at_utc=body.date_window.end_at,
    )

    booking = BookingRequest(
        pro_user_id=body.pro_user_id,
        client_user_id=user.user_id,
        package_id=body.package_id,
        requested_start=body.date_window.start_at,
        requested_end=body.date_window.end_at,
        location_text=body.location,
        notes=body.notes,
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
        scheduling_preset=shape.preset,
    )
    db.add(booking)
    db.flush()
    db.add(
        BookingRequestTransition(
            booking_request_id=booking.id,
            from_status=BookingRequestStatus.pending,
            to_status=BookingRequestStatus.pending,
            actor_user_id=user.user_id,
            reason="Created from client booking funnel",
        )
    )
    enqueue_notification(
        db,
        user_id=body.pro_user_id,
        notification_type="booking.request_received",
        payload={
            "title": "New booking request",
            "body": "A client requested a booking.",
            "action": {"label": "Review", "url": f"/booking-requests/{booking.id}"},
        },
        reference_type="booking_request",
        reference_id=str(booking.id),
    )
    log_event(
        db,
        event_name="client.booking_request_created",
        user_id=user.user_id,
        properties={
            "booking_id": str(booking.id),
            "pro_user_id": str(body.pro_user_id),
            "niche_slug": body.niche_slug,
            "country": pro_profile.country,
            "city": pro_profile.city,
        },
    )
    evaluate_booking_spam_rule(db, user_id=user.user_id)
    db.commit()
    return ClientBookingRequestCreateResponse(booking_id=booking.id, status=booking.status.value)


@router.get("/client/bookings", response_model=ClientBookingListResponse)
def list_client_bookings(
    status: BookingRequestStatus | None = Query(default=None),
    cursor: str | None = Query(default=None),
    limit: int = Query(default=DEFAULT_LIMIT, ge=1, le=MAX_LIMIT),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> ClientBookingListResponse:
    """The authenticated client's own bookings, newest first.

    Each row rolls up booking status with the gig and payment status the
    detail route leads with, because "where is my booking up to" is not
    answerable from the booking row alone - an accepted request that hasn't
    been paid for and one that's been shot look identical there.

    The gig and payment lookups are batched across the whole page rather
    than done per row. `_find_gig_by_booking_request` (used by the detail
    route, where it runs once) loads every gig in the table and scans it in
    Python; calling that per row would make one list request a full table
    scan per booking. Here the gig query is scoped to this client's own
    gigs and joined in memory by booking id.
    """
    query = select(BookingRequest).where(BookingRequest.client_user_id == user.user_id)
    if status is not None:
        query = query.where(BookingRequest.status == status)

    rows = list(db.execute(apply_keyset(query, BookingRequest, cursor, limit)).scalars().all())
    page, next_cursor = build_page(rows, limit)
    if not page:
        return ClientBookingListResponse(items=[], next_cursor=None)

    booking_ids = {str(row.id) for row in page}
    client_gigs = db.execute(select(Gig).where(Gig.client_user_id == user.user_id)).scalars().all()
    gig_by_booking = {
        (gig.meta or {}).get("booking_request_id"): gig
        for gig in client_gigs
        if (gig.meta or {}).get("booking_request_id") in booking_ids
    }

    payment_by_gig: dict[uuid.UUID, StripePayment] = {}
    gig_ids = [gig.id for gig in gig_by_booking.values()]
    if gig_ids:
        payments = db.execute(
            select(StripePayment).where(
                StripePayment.gig_id.in_(gig_ids),
                StripePayment.kind == StripePaymentKind.base,
            )
        ).scalars().all()
        payment_by_gig = {payment.gig_id: payment for payment in payments}

    items = []
    for row in page:
        gig = gig_by_booking.get(str(row.id))
        payment = payment_by_gig.get(gig.id) if gig else None
        items.append(
            ClientBookingListItem(
                booking_id=row.id,
                booking_status=row.status.value,
                gig_id=gig.id if gig else None,
                gig_status=gig.status.value if gig else None,
                payment_status=payment.status.value if payment else None,
                requested_start=row.requested_start,
                requested_end=row.requested_end,
                location_text=row.location_text,
                expires_at=row.expires_at,
                created_at=row.created_at,
            )
        )
    return ClientBookingListResponse(items=items, next_cursor=next_cursor)


@router.get("/client/bookings/{booking_id}", response_model=ClientBookingStatusResponse)
def client_booking_status(
    booking_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> ClientBookingStatusResponse:
    booking = db.get(BookingRequest, booking_id)
    if not booking:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    if user.user_id not in {booking.client_user_id, booking.pro_user_id}:
        roles = get_user_roles(db, user.user_id)
        if UserRoleType.admin not in roles:
            raise APIError(code="forbidden", message="Not allowed", status_code=403)

    transitions = db.execute(
        select(BookingRequestTransition)
        .where(BookingRequestTransition.booking_request_id == booking_id)
        .order_by(BookingRequestTransition.created_at.asc())
    ).scalars().all()
    gig = _find_gig_by_booking_request(db, booking_id=booking.id)
    payment = (
        db.execute(
            select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.base)
        ).scalar_one_or_none()
        if gig
        else None
    )

    # A draft gallery is one the photographer is still filling; it is not the
    # client's to see, and get_gallery refuses it for them anyway. Surfacing
    # it here would put a door on the screen that opens onto a 403.
    gallery = (
        db.execute(
            select(ProofGallery).where(
                ProofGallery.gig_id == gig.id,
                ProofGallery.status != ProofGalleryStatus.draft,
            )
        ).scalars().first()
        if gig
        else None
    )

    # The client's own record. The photographer is also allowed this
    # response, and gets no review through it.
    review_view = None
    if gig and user.user_id == booking.client_user_id:
        review = db.execute(select(Review).where(Review.gig_id == gig.id)).scalar_one_or_none()
        if review:
            reply = db.execute(select(ReviewReply).where(ReviewReply.review_id == review.id)).scalar_one_or_none()
            review_view = build_review_view(db, review, reply)

    next_actions: list[str] = []
    if booking.status == BookingRequestStatus.pending:
        next_actions.append("await_pro_response")
    if booking.status == BookingRequestStatus.accepted and gig and gig.status.value == "payment_pending":
        next_actions.append("pay_now")
    if gig and gig.status.value in {"paid", "scheduled", "shoot_done"}:
        # Once there are photos to act on, say so rather than leaving the
        # client waiting on a delivery that has already arrived.
        if gallery and gallery.status == ProofGalleryStatus.published:
            next_actions.append("choose_photos")
        elif gallery:
            next_actions.append("view_photos")
        else:
            next_actions.append("await_delivery")

    return ClientBookingStatusResponse(
        booking_id=booking.id,
        booking_status=booking.status.value,
        gig_id=gig.id if gig else None,
        gig_status=gig.status.value if gig else None,
        payment_status=payment.status.value if payment else None,
        proof_gallery_id=gallery.id if gallery else None,
        proof_gallery_status=gallery.status.value if gallery else None,
        timeline=[
            {
                "at": item.created_at.isoformat(),
                "from": item.from_status.value,
                "to": item.to_status.value,
                "reason": item.reason,
            }
            for item in transitions
        ],
        next_actions=next_actions,
        review=review_view,
    )


# Every status a gig reaches only by way of `payment_pending` succeeding.
# Cancelled and refunded gigs also fail the `payment_pending` check below but
# are not "already paid" - conflating them would tell a client whose booking
# fell through that everything is fine.
_GIG_STATUSES_AFTER_PAYMENT = {
    GigStatus.paid,
    GigStatus.scheduled,
    GigStatus.shoot_done,
    GigStatus.proofs_delivered,
    GigStatus.selection_pending,
    GigStatus.final_delivered,
    GigStatus.completed,
}


@router.post("/client/bookings/{booking_id}/pay", response_model=ClientBookingPayResponse)
def client_booking_pay(
    booking_id: uuid.UUID,
    body: ClientBookingPayRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> ClientBookingPayResponse:
    if not is_feature_enabled(db, "client_booking_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Client booking is disabled", status_code=503)
    enforce_named_rate_limit("payments", principal=str(user.user_id))

    booking = db.get(BookingRequest, booking_id)
    if not booking:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    if booking.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client can pay", status_code=403)
    if booking.status != BookingRequestStatus.accepted:
        raise APIError(code="invalid_state", message="Booking must be accepted before payment", status_code=409)

    gig = _find_gig_by_booking_request(db, booking_id=booking.id)
    if not gig:
        raise APIError(code="invalid_state", message="Gig not created yet", status_code=409)
    if gig.status != GigStatus.payment_pending:
        if gig.status in _GIG_STATUSES_AFTER_PAYMENT:
            # A client can land here after paying for reasons that have
            # nothing to do with trying to pay twice: reopening the booking
            # screen before the success webhook has updated local state, a
            # stale Pay button that survived a backgrounded app, a retried
            # request after a flaky connection. Telling this apart from a
            # genuinely invalid booking lets the client show reassurance and
            # refresh, instead of the same dead-end error a real failure gets.
            raise APIError(code="already_paid", message="This booking has already been paid for.", status_code=409)
        raise APIError(code="invalid_state", message="Gig is not awaiting payment", status_code=409)

    # The last check before money moves. The hour was free when it was
    # requested and when it was accepted; this is the moment that charges for
    # it, so it does not trust either earlier answer. Notice and working hours
    # are not re-judged (see refusal_for), only whether the hour is still
    # theirs.
    if gig.created_at <= datetime.now(timezone.utc) - PAYMENT_WINDOW:
        raise APIError(
            code="payment_window_closed",
            message="The time held for this booking has been released. Request a new time.",
            status_code=409,
        )
    if gig.scheduled_start and gig.scheduled_end:
        check_bookable(
            db,
            pro_user_id=gig.pro_user_id,
            start_at_utc=gig.scheduled_start,
            end_at_utc=gig.scheduled_end,
            ignore_gig_id=gig.id,
            at_payment=True,
            preset=gig_preset(gig),
        )

    mode = "full" if body.payment_mode not in {"full", "deposit"} else body.payment_mode
    _, intent = create_or_get_gig_payment_intent(
        db,
        gig,
        extra_metadata={"payment_mode": mode},
    )
    gig_pro_profile = db.get(ProProfile, gig.pro_user_id)
    log_event(
        db,
        event_name="client.payment_started",
        user_id=user.user_id,
        properties={
            "booking_id": str(booking.id),
            "gig_id": str(gig.id),
            "mode": mode,
            "country": gig_pro_profile.country if gig_pro_profile else None,
            "city": gig_pro_profile.city if gig_pro_profile else None,
        },
    )
    db.commit()
    return ClientBookingPayResponse(
        booking_id=booking.id,
        gig_id=gig.id,
        payment_intent_id=intent.id,
        payment_intent_client_secret=intent.client_secret,
        mode=mode,
    )


@router.get("/me/client-preference", response_model=ClientPreferenceView)
def get_client_preference(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> ClientPreferenceView:
    ensure_user_account(db, user.user_id)
    ensure_client_role(db, user_id=user.user_id)
    row = db.get(ClientPreference, user.user_id)
    if not row:
        row = ClientPreference(user_id=user.user_id, consent_default=GigConsentLevel.none)
        db.add(row)
        db.flush()
    db.commit()
    return _preference_view(row)


@router.put("/me/client-preference", response_model=ClientPreferenceView)
def put_client_preference(
    body: ClientPreferenceUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> ClientPreferenceView:
    ensure_user_account(db, user.user_id)
    ensure_client_role(db, user_id=user.user_id)
    row = db.get(ClientPreference, user.user_id)
    if not row:
        row = ClientPreference(user_id=user.user_id, consent_default=GigConsentLevel.none)
        db.add(row)
    row.preferred_niches = sorted(set(body.preferred_niches or []))
    row.budget_min = body.budget_min
    row.budget_max = body.budget_max
    row.style_tags = sorted(set(body.style_tags or []))
    row.location = body.location or {}
    row.consent_default = body.consent_default
    db.commit()
    db.refresh(row)
    return _preference_view(row)


# How many cards a row carries. A horizontal shelf that cannot be scrolled to
# the end in a few flicks stops being a curated row and becomes a list.
_ROW_SIZE = 12

# How many niche rows to offer. Every niche with photographers in the city
# would be eight shelves on one screen, which is the crowding the design
# brief's fourth signature exists to prevent.
_MAX_NICHE_ROWS = 4


def _row_base_query(country: str, city: str):
    """The five discovery gates, once, shared by every row.

    Identical to what _discover_rows enforces. Kept in one expression so a row
    cannot accidentally surface a photographer the ordinary Discover list
    would hide - which would be a fairness bug visible only by comparing two
    screens.
    """
    return (
        select(ProPublicIndex)
        .join(
            ProOnboarding,
            and_(
                ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id,
                ProOnboarding.status == ProOnboardingStatus.approved_public,
            ),
        )
        .where(
            ProPublicIndex.country == country.strip().upper(),
            ProPublicIndex.city == city.strip(),
            ProPublicIndex.kyc_status == KYCStatus.approved,
            ProPublicIndex.is_accepting_bookings.is_(True),
            ProPublicIndex.completeness_score >= 60,
            ProPublicIndex.min_package_price.is_not(None),
        )
    )


@router.get("/client/home", response_model=ClientHomeResponse)
def client_home(
    country: str,
    city: str,
    niche_slug: str | None = None,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
    db_write: Session = Depends(get_db_write_session),
) -> ClientHomeResponse:
    """The browsing home screen: several differently-sorted cuts of one catalogue.

    One request rather than one per row, for three reasons. The city gate,
    guest check and rate limit run once instead of five times - five parallel
    row requests would trip the public_read limiter on first paint. Row
    composition stays server-side, where the honesty rules can be enforced in
    one place. And a row with nothing to show can be omitted rather than sent
    empty, which the app cannot decide for itself without knowing why the row
    exists.

    Every row sorts on a column the index already has. No row here required a
    new ranking, and any row that would have needed one was dropped instead of
    inventing one - "top rated" is not here, because ranking_score is a
    composite of completeness, portfolio size, gigs, rating and tier, and a row
    named for rating that sorts by a composite is a row with a false name.

    With `niche_slug`, the same rows narrowed to one niche: its page, rather
    than a second endpoint with a second copy of these rules. Every row takes
    the niche's membership rule and shows that niche's work, and the ranked
    niche row the home screen shows becomes `niche_ranked` - a `niche:` key
    there would render as a tile linking to the page it is already on.
    """
    _enforce_city_gate(db, country=country, city=city, user=user)
    _enforce_guest_mode(db, user=user)
    enforce_named_rate_limit("public_read", principal=str(user.user_id) if user else "guest")

    scope: Niche | None = None
    if niche_slug is not None:
        scope = db.execute(
            select(Niche).where(Niche.slug == niche_slug, Niche.is_active.is_(True))
        ).scalar_one_or_none()
        if scope is None:
            raise APIError(code="not_found", message="Niche not found", status_code=404)

    cache_key = (
        f"client:home:v{get_public_index_version()}:country={country.upper()}:"
        f"city={city.lower()}:guest={not bool(user)}:niche={scope.slug if scope else ''}"
    )
    cached = cache_get_json(cache_key)
    if cached:
        return ClientHomeResponse.model_validate(cached)

    base = _row_base_query(country, city)
    if scope is not None:
        base = _in_niche(base, scope.id)
    # "New photographers" on the home screen, "New in Weddings" on its page.
    new_title = f"New in {scope.name}" if scope else "New photographers"
    experienced_title = f"Most experienced in {scope.name}" if scope else "Most experienced"
    plans: list[tuple[str, str, str | None, list[ProPublicIndex]]] = []

    # Deliberately its own row rather than a weighting hidden inside another
    # one. A photographer with no completed work is invisible under every
    # popularity sort there is, and the honest fix is a row that says what it
    # is - not a quiet boost inside "most experienced", which would make that
    # row's name a lie in the service of fairness.
    newcomers = db.execute(
        base.where(ProPublicIndex.gigs_completed == 0)
        .order_by(ProPublicIndex.updated_at.desc())
        .limit(_ROW_SIZE)
    ).scalars().all()
    plans.append(
        (
            "new_photographers",
            new_title,
            "Just joined, and looking for their first booking",
            list(newcomers),
        )
    )

    # Named for what it sorts by. "Top rated" would be the natural name and
    # the wrong one: this orders by completed work, which is experience rather
    # than rating.
    experienced = db.execute(
        base.where(ProPublicIndex.gigs_completed > 0)
        .order_by(ProPublicIndex.gigs_completed.desc(), ProPublicIndex.ranking_score.desc())
        .limit(_ROW_SIZE)
    ).scalars().all()
    plans.append(("most_experienced", experienced_title, "Photographers with the most completed shoots", list(experienced)))

    # Which niche's work each row shows, by row key.
    row_niche: dict[str, str] = {}
    if scope is not None:
        ranked = db.execute(
            base.order_by(ProPublicIndex.ranking_score.desc()).limit(_ROW_SIZE)
        ).scalars().all()
        plans.append(("niche_ranked", f"{scope.name} in {city.strip()}", None, list(ranked)))
        row_niche = {key: scope.slug for key, _title, _subtitle, _rows in plans}
    else:
        for slug, name in _niches_present(db, country=country, city=city):
            niche = db.execute(select(Niche).where(Niche.slug == slug)).scalar_one_or_none()
            if niche is None:
                continue
            rows = db.execute(
                _in_niche(base, niche.id)
                .order_by(ProPublicIndex.ranking_score.desc())
                .limit(_ROW_SIZE)
            ).scalars().all()
            row_niche[f"niche:{slug}"] = slug
            plans.append((f"niche:{slug}", f"{name} in {city.strip()}", None, list(rows)))

    # Cards are built once across every row rather than per row. The same
    # photographer appears in several rows, and building per row would resolve
    # their profile and presign their cover once per appearance.
    unique: dict[uuid.UUID, ProPublicIndex] = {}
    for _key, _title, _subtitle, rows in plans:
        for row in rows:
            unique.setdefault(row.pro_user_id, row)
    cards = {card.pro_user_id: card for card in _cards_from_index(db, list(unique.values()))}

    # In a niche row, show that niche's work. A profile cover is one image for
    # the whole photographer, so a wedding row built from covers shows a
    # portrait for anyone whose best overall frame is a portrait - the row
    # would be correctly populated and still visibly wrong. One batched
    # resolve per niche, not per card - on a niche page every row is that
    # niche, so its photographers are resolved once across all of them.
    pros_by_niche: dict[str, set[uuid.UUID]] = {}
    for key, _title, _subtitle, rows in plans:
        if key in row_niche:
            pros_by_niche.setdefault(row_niche[key], set()).update(row.pro_user_id for row in rows)
    niche_covers: dict[str, dict[uuid.UUID, str]] = {
        slug: resolve_niche_cover_urls(db, list(pro_ids), niche_slug=slug, expires_in=_media_url_ttl())
        for slug, pro_ids in pros_by_niche.items()
        if pro_ids
    }

    response = ClientHomeResponse(
        rows=[
            ClientHomeRow(
                key=key,
                title=title,
                subtitle=subtitle,
                items=[
                    _with_niche_cover(cards[row.pro_user_id], niche_covers.get(row_niche.get(key, "")))
                    for row in rows
                    if row.pro_user_id in cards
                ],
            )
            for key, title, subtitle, rows in plans
            # An empty shelf is worse than no shelf: it reads as a failure to
            # load rather than as an honest absence.
            if any(row.pro_user_id in cards for row in rows)
        ],
        guest_limited=user is None,
        niche=ClientHomeNiche(slug=scope.slug, name=scope.name) if scope else None,
    )

    cache_set_json(cache_key, response.model_dump(mode="json"), ttl_seconds=max(10, settings.discover_cache_ttl_seconds))
    log_event(
        db_write,
        event_name="client.home_view",
        user_id=user.user_id if user else None,
        properties={
            "country": country.upper(),
            "city": city,
            "niche_slug": scope.slug if scope else None,
            "rows": [r.key for r in response.rows],
        },
    )
    db_write.commit()
    return response


# Tiers that count as genuinely working in a niche that is not someone's
# primary. Rookie is excluded: recompute creates a rookie skill row for every
# active niche, so rookie means nothing beyond "exists".
_NICHE_MEMBER_TIERS = [SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master]


def _in_niche(query, niche_id: uuid.UUID):
    """Narrow a row query to one niche's photographers.

    Their own niche, or one they are genuinely skilled in.

    This used to filter on top_niches.contains(slug), and top_niches is a
    photographer's top *three* - so a food photographer with weddings in third
    place ranked into "Weddings in Lisbon". Worse, recompute_pro_niche_skills
    creates a skill row for every active niche, 619 of them at zero score, so
    third place was routinely filler nobody had ever worked in. A row that
    names its contents and is wrong about them is the same failure as a row
    named "top rated" that sorts by something else.

    Primary always qualifies, so a brand-new wedding photographer still
    appears in the wedding row - they are a wedding photographer, they simply
    have no history yet.

    One function for the home screen's niche rows and every row on a niche's
    own page, so the two cannot disagree about who is a wedding photographer.
    """
    return query.join(
        ProNicheSkill,
        and_(
            ProNicheSkill.pro_user_id == ProPublicIndex.pro_user_id,
            ProNicheSkill.niche_id == niche_id,
        ),
    ).where(
        or_(
            ProPublicIndex.primary_niche_id == niche_id,
            ProNicheSkill.tier.in_(_NICHE_MEMBER_TIERS),
        )
    )


def _with_niche_cover(card: ClientDiscoverCard, covers: dict[uuid.UUID, str] | None) -> ClientDiscoverCard:
    """The same card, showing this niche's work where we have it.

    Falls back to the profile cover rather than to nothing: a photographer in
    a wedding row who has not tagged any wedding photo still belongs there -
    membership is decided by their skill, not by their tagging - and a blank
    tile would punish them for a metadata gap.
    """
    if not covers:
        return card
    url = covers.get(card.pro_user_id)
    return card if url is None else card.model_copy(update={"cover_url": url})


def _niches_present(db: Session, *, country: str, city: str) -> list[tuple[str, str]]:
    """Niches that actually have photographers here, busiest first.

    Queried rather than hardcoded: a niche row for a category with nobody in
    this city is exactly the empty shelf the response omits, and offering it
    would mean building a row only to discard it.
    """
    # Counted by the same rule that decides who is *in* a row: primary, or
    # genuinely skilled in it. Joining on primary_niche_id alone would mean a
    # city whose wedding photographers all shoot weddings as a strong second
    # specialism gets no wedding row at all - the row would be populated if it
    # existed, and simply never be offered. Two rules for one question is how
    # they drift.
    rows = db.execute(
        select(Niche.slug, Niche.name, func.count(ProPublicIndex.pro_user_id).label("n"))
        .select_from(ProPublicIndex)
        .join(
            ProNicheSkill,
            ProNicheSkill.pro_user_id == ProPublicIndex.pro_user_id,
        )
        .join(Niche, Niche.id == ProNicheSkill.niche_id)
        .join(
            ProOnboarding,
            and_(
                ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id,
                ProOnboarding.status == ProOnboardingStatus.approved_public,
            ),
        )
        .where(
            ProPublicIndex.country == country.strip().upper(),
            ProPublicIndex.city == city.strip(),
            ProPublicIndex.kyc_status == KYCStatus.approved,
            ProPublicIndex.is_accepting_bookings.is_(True),
            or_(
                ProPublicIndex.primary_niche_id == ProNicheSkill.niche_id,
                ProNicheSkill.tier.in_(_NICHE_MEMBER_TIERS),
            ),
        )
        .group_by(Niche.slug, Niche.name)
        .order_by(func.count(ProPublicIndex.pro_user_id).desc())
        .limit(_MAX_NICHE_ROWS)
    ).all()
    return [(slug, name) for slug, name, _n in rows]


def _discover_rows(
    db: Session,
    *,
    q: str | None,
    country: str,
    city: str,
    niche_slug: str | None,
    min_price: float | None,
    max_price: float | None,
    sort: str,
    limit: int,
    offset: int,
) -> list[ProPublicIndex]:
    if search_provider_enabled():
        try:
            filters = [f'country = "{country.strip().upper()}"', f'city = "{city.strip()}"', "is_kyc_approved = true", "is_available = true"]
            if niche_slug:
                filters.append(f'niche_slugs = "{niche_slug}"')
            if min_price is not None:
                filters.append(f"price_min >= {float(min_price)}")
            if max_price is not None:
                filters.append(f"price_min <= {float(max_price)}")
            result = get_search_provider().search(
                get_index_name("pros"),
                query=q or "",
                filters=" AND ".join(filters),
                sort=["avg_rating:desc"] if sort == "rating" else None,
                limit=limit,
                offset=offset,
            )
            ids: list[uuid.UUID] = []
            for item in result.items:
                try:
                    ids.append(uuid.UUID(str(item.get("id"))))
                except Exception:
                    continue
            if ids:
                rows = db.execute(select(ProPublicIndex).where(ProPublicIndex.pro_user_id.in_(ids))).scalars().all()
                order = {item: idx for idx, item in enumerate(ids)}
                rows.sort(key=lambda row: order.get(row.pro_user_id, 9999))
                return rows
        except Exception:
            pass

    stmt = (
        select(ProPublicIndex)
        .join(
            ProOnboarding,
            and_(
                ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id,
                ProOnboarding.status == ProOnboardingStatus.approved_public,
            ),
        )
        .where(
            ProPublicIndex.country == country.strip().upper(),
            ProPublicIndex.city == city.strip(),
            ProPublicIndex.is_accepting_bookings.is_(True),
        )
    )
    if q:
        stmt = stmt.join(ProProfile, ProProfile.user_id == ProPublicIndex.pro_user_id).where(
            or_(ProProfile.display_name.ilike(f"%{q}%"), ProProfile.headline.ilike(f"%{q}%"))
        )
    if niche_slug:
        stmt = stmt.where(ProPublicIndex.top_niches.contains([{"slug": niche_slug}]))
    if min_price is not None:
        stmt = stmt.where(ProPublicIndex.min_package_price >= min_price)
    if max_price is not None:
        stmt = stmt.where(ProPublicIndex.min_package_price <= max_price)
    if sort == "price_asc":
        stmt = stmt.order_by(ProPublicIndex.min_package_price.asc(), ProPublicIndex.ranking_score.desc())
    elif sort == "price_desc":
        stmt = stmt.order_by(ProPublicIndex.min_package_price.desc(), ProPublicIndex.ranking_score.desc())
    elif sort == "rating":
        stmt = stmt.order_by(ProPublicIndex.avg_rating.desc(), ProPublicIndex.review_count.desc())
    else:
        stmt = stmt.order_by(ProPublicIndex.ranking_score.desc(), ProPublicIndex.updated_at.desc())
    return db.execute(stmt.offset(offset).limit(limit)).scalars().all()


# Signed media URLs live at least this long. Discover responses are cached, so
# a URL can be handed to a client at the very end of the cache window; the
# cache TTL is added on top so that even the stalest cached entry still serves
# a URL with the full base lifetime ahead of it.
@router.get("/pro/me/listing-preview", response_model=ProListingPreviewResponse)
def pro_listing_preview(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> ProListingPreviewResponse:
    """The pro's own listing, rendered exactly as a client would see it.

    Deliberately lives beside _cards_from_index rather than in the pro
    module: a preview built by a second code path is a preview that
    eventually lies. Works at any onboarding status - a pro who is not yet
    live is precisely the one who needs to see what they are building.
    """
    ensure_user_account(db, user.user_id)
    profile = db.get(ProProfile, user.user_id)
    if not profile:
        raise APIError(code="not_found", message="No pro profile", status_code=404)

    # Recompute first: the index is what Discover reads, so previewing off a
    # stale row would show the pro yesterday's card and hide the effect of
    # the edit they just made.
    index = recompute_pro_public_index(db, user.user_id)
    card = _cards_from_index(db, [index])[0]

    reasons: list[str] = []
    # Discover joins ProOnboarding and requires approved_public, so a pro who
    # has activated but not been published is invisible. Without this the
    # preview said "clients can find you" to someone nobody could find -
    # the one thing a preview must never do.
    onboarding = db.execute(
        select(ProOnboarding).where(ProOnboarding.pro_user_id == user.user_id)
    ).scalar_one_or_none()
    if onboarding is None or onboarding.status != ProOnboardingStatus.approved_public:
        reasons.append("not_published_yet")
    if index.kyc_status != KYCStatus.approved:
        reasons.append("kyc_not_approved")
    if not index.is_accepting_bookings:
        reasons.append("not_accepting_bookings")
    if index.completeness_score < 60:
        reasons.append("profile_incomplete")
    if index.min_package_price is None:
        reasons.append("no_active_package")

    has_rules = db.execute(
        select(ProAvailabilityRule.id).where(ProAvailabilityRule.pro_user_id == user.user_id).limit(1)
    ).scalar_one_or_none()
    available_days = _free_days_next_fortnight(db, user.user_id) if has_rules else None

    db.commit()
    return ProListingPreviewResponse(
        card=card,
        is_live=not reasons,
        blocking_reasons=reasons,
        available_days_next_14=available_days,
    )


FORTNIGHT_DAYS = 14


def _free_days_next_fortnight(db: Session, pro_user_id: uuid.UUID) -> int:
    """Days in the next fortnight not wholly covered by blocked time.

    A coarse number by design - the card says "available 9 of the next 14
    days", not which ones. Reads through the shared blocked-time helper so
    it counts blocks from both availability tables.
    """
    now = datetime.now(timezone.utc)
    start = datetime.combine(now.date(), time(0, 0), tzinfo=timezone.utc)
    end = start + timedelta(days=FORTNIGHT_DAYS)
    blocks = blocked_intervals(db, pro_user_id, start=start, end=end)

    free = 0
    for offset in range(FORTNIGHT_DAYS):
        day_start = start + timedelta(days=offset)
        day_end = day_start + timedelta(days=1)
        if not any(b_start <= day_start and b_end >= day_end for b_start, b_end in blocks):
            free += 1
    return free


MEDIA_URL_BASE_TTL_SECONDS = 900


def _media_url_ttl() -> int:
    return MEDIA_URL_BASE_TTL_SECONDS + max(0, settings.discover_cache_ttl_seconds)


def _cards_from_index(db: Session, rows: Sequence[ProPublicIndex]) -> list[ClientDiscoverCard]:
    """Build a whole page of cards with a fixed number of queries.

    Batched rather than per-row because both callers render up to twenty cards,
    and the per-row form cost one profile lookup each before it could even
    begin resolving cover images.
    """
    if not rows:
        return []

    profiles = {
        profile.user_id: profile
        for profile in db.execute(
            select(ProProfile).where(ProProfile.user_id.in_([idx.pro_user_id for idx in rows]))
        ).scalars().all()
    }
    cover_urls = resolve_image_urls(
        db,
        (profile.cover_media_asset_id for profile in profiles.values()),
        prefer=THUMBNAIL_FIRST,
        expires_in=_media_url_ttl(),
    )

    cards: list[ClientDiscoverCard] = []
    for idx in rows:
        profile = profiles.get(idx.pro_user_id)
        cover_id = profile.cover_media_asset_id if profile else None
        cards.append(
            ClientDiscoverCard(
                pro_user_id=idx.pro_user_id,
                display_name=profile.display_name if profile else None,
                headline=profile.headline if profile else None,
                cover_media_asset_id=cover_id,
                cover_url=cover_urls.get(cover_id) if cover_id else None,
                city=idx.city,
                country=idx.country,
                min_price=idx.min_package_price,
                max_price=idx.max_package_price,
                min_entry_rate=idx.min_entry_rate,
                min_entry_photos=idx.min_entry_photos,
                currency=idx.currency,
                avg_rating=idx.avg_rating,
                review_count=idx.review_count,
                top_niches=idx.top_niches or [],
                portfolio_photo_count=idx.portfolio_photo_count,
                portfolio_video_count=idx.portfolio_video_count,
            )
        )
    return cards


def _preference_view(row: ClientPreference) -> ClientPreferenceView:
    return ClientPreferenceView(
        preferred_niches=[str(item) for item in (row.preferred_niches or [])],
        budget_min=row.budget_min,
        budget_max=row.budget_max,
        style_tags=[str(item) for item in (row.style_tags or [])],
        location=row.location or {},
        consent_default=row.consent_default,
        updated_at=row.updated_at,
    )


def _enforce_guest_mode(db: Session, *, user: CurrentUser | None) -> None:
    if user:
        return
    if not is_feature_enabled(db, "guest_discovery_enabled"):
        raise APIError(code="unauthorized", message="Authentication required", status_code=401)


def _enforce_city_gate(db: Session, *, country: str, city: str, user: CurrentUser | None) -> None:
    decision = evaluate_client_city_access(db, country=country, city=city, user_id=user.user_id if user else None)
    if not decision.enabled:
        raise APIError(code="forbidden", message="Client app is not enabled for this city", status_code=403, details={"reason": decision.reason})


def _find_gig_by_booking_request(db: Session, *, booking_id: uuid.UUID) -> Gig | None:
    gigs = db.execute(select(Gig)).scalars().all()
    for gig in gigs:
        if (gig.meta or {}).get("booking_request_id") == str(booking_id):
            return gig
    return None
