from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_write_session, get_optional_current_user, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import ProProfile, UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, BookingRequestTransition, ProAvailabilityRule, ProPackage
from app.models.client_launch import ClientPreference, ClientWaitlist, MatchRequest as MatchRequestLog, MatchResult as MatchResultLog
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, StripePayment
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.media import MediaAsset, MediaKind, MediaPurpose, MediaStatus
from app.models.media_rights import GigConsentLevel
from app.models.niche import Niche
from app.schemas.client_launch import (
    ClientAccessResponse,
    ClientBookingPayRequest,
    ClientBookingPayResponse,
    ClientBookingRequestCreateRequest,
    ClientBookingRequestCreateResponse,
    ClientBookingStatusResponse,
    ClientDiscoverCard,
    ClientDiscoverResponse,
    ClientMatchCard,
    ClientMatchCreateRequest,
    ClientMatchResponse,
    ClientPreferenceUpdateRequest,
    ClientPreferenceView,
    ClientProfilePackage,
    ClientProProfileResponse,
    ClientWaitlistCreateRequest,
    ClientWaitlistCreateResponse,
)
from app.schemas.media import CurrentUser
from app.services.analytics import log_event
from app.services.authz import ensure_user_account, get_user_roles
from app.services.cache import cache_get_json, cache_set_json, get_public_index_version
from app.services.client_launch import MatchInput, ensure_client_role, evaluate_client_city_access, match_candidates
from app.services.feature_flags import is_feature_enabled
from app.services.notifications import enqueue_notification
from app.services.outbox import enqueue_outbox_event
from app.services.payment_intents import create_or_get_gig_payment_intent
from app.services.rate_limit import enforce_named_rate_limit, enforce_rate_limit
from app.models.risk import RiskActionType
from app.services.trust_safety import (
    enforce_require_verification_if_flagged,
    enforce_risk_action_not_active,
    evaluate_booking_spam_rule,
)
from app.services.search_provider import get_index_name, get_search_provider, search_provider_enabled

settings = get_settings()
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
    items = [_card_from_index(db, row) for row in rows]
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

    items: list[ClientMatchCard] = []
    show_breakdown = settings.app_env.lower() in {"dev", "development", "test"}
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
        items.append(
            ClientMatchCard(
                pro_user_id=row.pro_user_id,
                rank=idx,
                score=candidate.score,
                card=_card_from_index(db, row),
                score_breakdown=candidate.breakdown if show_breakdown else None,
            )
        )

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

    packages = db.execute(
        select(ProPackage)
        .where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.price.asc())
    ).scalars().all()
    photo_ids = db.execute(
        select(MediaAsset.id)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
            MediaAsset.kind.in_([MediaKind.photo, MediaKind.video]),
        )
        .order_by(MediaAsset.created_at.desc())
        .limit(8)
    ).scalars().all()

    response = ClientProProfileResponse(
        pro_user_id=pro_user_id,
        display_name=profile.display_name,
        headline=profile.headline,
        cover_media_asset_id=profile.cover_media_asset_id,
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
                title=item.title,
                description=item.description,
                duration_minutes=item.duration_minutes,
                price=item.price,
                currency=item.currency,
                included_photos=item.included_photos,
                extra_photo_price=item.extra_photo_price,
                proofs_sla_days=item.proofs_sla_days,
                finals_sla_days=item.finals_sla_days,
            )
            for item in packages
        ],
        portfolio_preview_asset_ids=photo_ids,
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

    has_availability = db.execute(select(ProAvailabilityRule.id).where(ProAvailabilityRule.pro_user_id == body.pro_user_id).limit(1)).scalar_one_or_none()
    if not has_availability:
        raise APIError(code="validation_error", message="Pro has no availability configured", status_code=409)

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
    payment = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one_or_none() if gig else None

    next_actions: list[str] = []
    if booking.status == BookingRequestStatus.pending:
        next_actions.append("await_pro_response")
    if booking.status == BookingRequestStatus.accepted and gig and gig.status.value == "payment_pending":
        next_actions.append("pay_now")
    if gig and gig.status.value in {"paid", "scheduled", "shoot_done"}:
        next_actions.append("await_delivery")

    return ClientBookingStatusResponse(
        booking_id=booking.id,
        booking_status=booking.status.value,
        gig_id=gig.id if gig else None,
        gig_status=gig.status.value if gig else None,
        payment_status=payment.status.value if payment else None,
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
    )


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
    if gig.status.value != "payment_pending":
        raise APIError(code="invalid_state", message="Gig is not awaiting payment", status_code=409)

    mode = "full" if body.payment_mode not in {"full", "deposit"} else body.payment_mode
    _, intent = create_or_get_gig_payment_intent(
        db,
        gig,
        payment_method_types=["card"],
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


def _card_from_index(db: Session, idx: ProPublicIndex) -> ClientDiscoverCard:
    profile = db.get(ProProfile, idx.pro_user_id)
    return ClientDiscoverCard(
        pro_user_id=idx.pro_user_id,
        display_name=profile.display_name if profile else None,
        headline=profile.headline if profile else None,
        cover_media_asset_id=profile.cover_media_asset_id if profile else None,
        city=idx.city,
        country=idx.country,
        min_price=idx.min_package_price,
        max_price=idx.max_package_price,
        currency=idx.currency,
        avg_rating=idx.avg_rating,
        review_count=idx.review_count,
        top_niches=idx.top_niches or [],
        portfolio_photo_count=idx.portfolio_photo_count,
        portfolio_video_count=idx.portfolio_video_count,
    )


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
