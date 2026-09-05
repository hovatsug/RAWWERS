from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy import and_, func, select
from sqlalchemy import case
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_write_session, get_optional_current_user, require_admin
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile
from app.models.booking import ProPackage
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaPurpose, MediaStatus, MediaVariant, ObjectStatus
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.schemas.discovery import (
    AnalyticsCreateRequest,
    DiscoverProsResponse,
    MatchCandidate,
    MatchRequest,
    MatchResponse,
    NichePricingPreviewResponse,
    PackagePricingPreview,
    ProCard,
    ProPublicProfileResponse,
    PublicPortfolioPhoto,
    PublicPortfolioVideo,
    PublicProPackageView,
)
from app.schemas.media import CurrentUser
from app.services.analytics import log_event
from app.services.abuse import detect_scraping_activity
from app.services.authz import enforce_not_banned
from app.services.cache import cache_get_json, cache_set_json, get_public_index_version, get_redis_client
from app.services.niche_catalog import ensure_initial_niches
from app.services.package_pricing import PRICING_PREVIEW_PHOTO_COUNTS, compute_package_total
from app.services.rate_limit import enforce_named_rate_limit, enforce_rate_limit
from app.services.storage import create_presigned_get
from app.services.launch_ops import is_pro_publicly_discoverable
from app.tasks.discovery_tasks import rebuild_all_pro_indexes, rebuild_pro_index


router = APIRouter(tags=["discovery"])
settings = get_settings()


@router.get("/discover/pros", response_model=DiscoverProsResponse)
def discover_pros(
    request: Request,
    city: str | None = None,
    country: str | None = None,
    styles: str | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    sort: str = "rank",
    niche: str | None = None,
    limit: int = Query(default=20, ge=1, le=50),
    offset: int = Query(default=0, ge=0),
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
    db_write: Session = Depends(get_db_write_session),
) -> DiscoverProsResponse:
    requester_ip = _request_ip(request)
    principal = str(user.user_id) if user else f"ip:{requester_ip or 'unknown'}"
    enforce_named_rate_limit("public_read", principal=principal)
    _observe_scraping(db_write, requester_ip)

    cache_key = _discover_cache_key(
        city=city,
        country=country,
        styles=styles,
        min_price=min_price,
        max_price=max_price,
        sort=sort,
        niche=niche,
        limit=limit,
        offset=offset,
    )
    cached = cache_get_json(cache_key)
    if cached:
        if user:
            log_event(
                db_write,
                event_name="discover.search",
                user_id=user.user_id,
                properties={"cache_hit": True, "city": city, "country": country, "styles": styles, "sort": sort, "niche": niche, "limit": limit, "offset": offset},
            )
            db_write.commit()
        return DiscoverProsResponse.model_validate(cached)

    ensure_initial_niches(db)
    conditions = [
        ProPublicIndex.kyc_status == KYCStatus.approved,
        ProPublicIndex.is_accepting_bookings.is_(True),
        ProPublicIndex.completeness_score >= 60,
        ProPublicIndex.min_package_price.is_not(None),
    ]

    if city:
        conditions.append(ProPublicIndex.city == city)
    if country:
        conditions.append(ProPublicIndex.country == country)
    if min_price is not None:
        conditions.append(ProPublicIndex.min_package_price >= min_price)
    if max_price is not None:
        conditions.append(ProPublicIndex.min_package_price <= max_price)
    if styles:
        style_tokens = [s.strip() for s in styles.split(",") if s.strip()]
        if style_tokens:
            conditions.append(and_(*[ProPublicIndex.styles.contains([token]) for token in style_tokens]))

    stmt = select(ProPublicIndex).join(
        ProOnboarding,
        and_(
            ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id,
            ProOnboarding.status == ProOnboardingStatus.approved_public,
        ),
    ).where(and_(*conditions))
    rows: list[ProPublicIndex]
    total: int

    if niche:
        niche_row = db.execute(select(Niche).where(Niche.slug == niche, Niche.is_active.is_(True))).scalar_one_or_none()
        if not niche_row:
            raise APIError(code="validation_error", message="Unknown niche", status_code=422)
        tier_rank = case(
            (ProNicheSkill.tier == SkillTier.master, 5),
            (ProNicheSkill.tier == SkillTier.elite, 4),
            (ProNicheSkill.tier == SkillTier.pro, 3),
            (ProNicheSkill.tier == SkillTier.skilled, 2),
            else_=1,
        )
        stmt = stmt.join(
            ProNicheSkill,
            and_(
                ProNicheSkill.pro_user_id == ProPublicIndex.pro_user_id,
                ProNicheSkill.niche_id == niche_row.id,
            ),
        )
        skilled_stmt = stmt.where(ProNicheSkill.tier.in_([SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master]))
        skilled_stmt = skilled_stmt.order_by(
            tier_rank.desc(),
            ProNicheSkill.capability_score.desc(),
            ProNicheSkill.confidence.desc(),
            ProPublicIndex.ranking_score.desc(),
            ProPublicIndex.updated_at.desc(),
        )
        rows = db.execute(skilled_stmt.offset(offset).limit(limit)).scalars().all()
        total = db.execute(select(func.count()).select_from(skilled_stmt.subquery())).scalar_one()

        if offset == 0 and len(rows) < limit:
            existing_ids = {item.pro_user_id for item in rows}
            rookie_stmt = stmt.where(ProNicheSkill.tier == SkillTier.rookie).order_by(
                tier_rank.desc(),
                ProNicheSkill.capability_score.desc(),
                ProNicheSkill.confidence.desc(),
                ProPublicIndex.ranking_score.desc(),
                ProPublicIndex.updated_at.desc(),
            )
            rookie_rows = db.execute(rookie_stmt.limit(limit)).scalars().all()
            for candidate in rookie_rows:
                if candidate.pro_user_id in existing_ids:
                    continue
                rows.append(candidate)
                if len(rows) >= limit:
                    break
            total += db.execute(select(func.count()).select_from(rookie_stmt.subquery())).scalar_one()
    elif sort == "price_asc":
        stmt = stmt.order_by(ProPublicIndex.min_package_price.asc(), ProPublicIndex.ranking_score.desc())
        rows = db.execute(stmt.offset(offset).limit(limit)).scalars().all()
        total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    elif sort == "price_desc":
        stmt = stmt.order_by(ProPublicIndex.min_package_price.desc(), ProPublicIndex.ranking_score.desc())
        rows = db.execute(stmt.offset(offset).limit(limit)).scalars().all()
        total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    elif sort == "newest":
        stmt = stmt.order_by(ProPublicIndex.updated_at.desc())
        rows = db.execute(stmt.offset(offset).limit(limit)).scalars().all()
        total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    else:
        stmt = stmt.order_by(ProPublicIndex.ranking_score.desc(), ProPublicIndex.updated_at.desc())
        rows = db.execute(stmt.offset(offset).limit(limit)).scalars().all()
        total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()

    items = []
    for row in rows:
        if not is_pro_publicly_discoverable(db, pro_user_id=row.pro_user_id):
            continue
        profile = db.get(ProProfile, row.pro_user_id)
        items.append(
            ProCard(
                pro_user_id=row.pro_user_id,
                display_name=profile.display_name if profile else None,
                city=row.city,
                styles=row.styles or [],
                min_price=row.min_package_price,
                currency=row.currency,
                portfolio_photo_count=row.portfolio_photo_count,
                portfolio_video_count=row.portfolio_video_count,
                avg_rating=row.avg_rating,
                review_count=row.review_count,
                ranking_score=row.ranking_score,
                primary_niche_id=row.primary_niche_id,
                top_niches=row.top_niches or [],
            )
        )

    response = DiscoverProsResponse(total=total, items=items)
    cache_set_json(cache_key, response.model_dump(mode="json"), ttl_seconds=settings.discover_cache_ttl_seconds)

    log_event(
        db_write,
        event_name="discover.search",
        user_id=user.user_id if user else None,
        properties={"city": city, "country": country, "styles": styles, "sort": sort, "niche": niche, "limit": limit, "offset": offset},
    )
    db_write.commit()
    return response


@router.get("/pros/{pro_user_id}/public", response_model=ProPublicProfileResponse)
def get_public_pro_profile(
    pro_user_id: uuid.UUID,
    request: Request,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
    db_write: Session = Depends(get_db_write_session),
) -> ProPublicProfileResponse:
    requester_ip = _request_ip(request)
    principal = str(user.user_id) if user else f"ip:{requester_ip or 'unknown'}"
    enforce_named_rate_limit("public_read", principal=principal)
    _observe_scraping(db_write, requester_ip)

    cache_key = _pro_public_cache_key(pro_user_id)
    cached = cache_get_json(cache_key)
    if cached:
        if user:
            log_event(db_write, event_name="discover.profile_view", user_id=user.user_id, properties={"pro_user_id": str(pro_user_id), "cache_hit": True})
            db_write.commit()
        return ProPublicProfileResponse.model_validate(cached)

    index = db.get(ProPublicIndex, pro_user_id)
    profile = db.get(ProProfile, pro_user_id)
    onboarding = db.get(ProOnboarding, pro_user_id)
    if not index or not profile or not onboarding or onboarding.status != ProOnboardingStatus.approved_public:
        raise APIError(code="not_found", message="Pro not found", status_code=404)
    if not is_pro_publicly_discoverable(db, pro_user_id=pro_user_id):
        raise APIError(code="not_found", message="Pro not found", status_code=404)

    packages = db.execute(
        select(ProPackage)
        .where(ProPackage.pro_user_id == pro_user_id, ProPackage.is_active.is_(True))
        .order_by(ProPackage.price.asc())
    ).scalars().all()

    photo_assets = db.execute(
        select(MediaAsset)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.kind == MediaKind.photo,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
        .order_by(MediaAsset.created_at.desc())
        .limit(12)
    ).scalars().all()

    video_assets = db.execute(
        select(MediaAsset)
        .where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.kind == MediaKind.video,
            MediaAsset.purpose == MediaPurpose.portfolio_reel,
            MediaAsset.status == MediaStatus.ready,
        )
        .order_by(MediaAsset.created_at.desc())
        .limit(3)
    ).scalars().all()

    photos = []
    for asset in photo_assets:
        thumb = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == asset.id,
                MediaObject.variant == MediaVariant.thumbnail,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalar_one_or_none()
        wm = db.execute(
            select(MediaObject).where(
                MediaObject.media_asset_id == asset.id,
                MediaObject.variant == MediaVariant.watermark_preview,
                MediaObject.status == ObjectStatus.ready,
            )
        ).scalar_one_or_none()
        photos.append(
            PublicPortfolioPhoto(
                media_asset_id=asset.id,
                thumbnail_url=create_presigned_get(thumb.storage_key, expires_in=300) if thumb else None,
                watermark_preview_url=create_presigned_get(wm.storage_key, expires_in=300) if wm else None,
            )
        )

    videos = [
        PublicPortfolioVideo(media_asset_id=asset.id, playback_id=(asset.meta or {}).get("playback_id"))
        for asset in video_assets
    ]

    payload = ProPublicProfileResponse(
        pro_user_id=pro_user_id,
        display_name=profile.display_name,
        headline=profile.headline,
        cover_media_asset_id=profile.cover_media_asset_id,
        bio=profile.bio,
        city=profile.city,
        country=profile.country,
        styles=profile.styles or [],
        packages=[
            PublicProPackageView(
                id=p.id,
                title=p.title,
                description=p.description,
                duration_minutes=p.duration_minutes,
                price=p.price,
                currency=p.currency,
                included_photos=p.included_photos,
                extra_photo_price=p.extra_photo_price,
                proofs_sla_days=p.proofs_sla_days,
                finals_sla_days=p.finals_sla_days,
                addons=p.addons,
            )
            for p in packages
        ],
        portfolio_photos=photos,
        portfolio_videos=videos,
        gigs_completed=index.gigs_completed,
        gigs_cancelled=index.gigs_cancelled,
        disputes_count=index.disputes_count,
        avg_response_minutes=index.avg_response_minutes,
        avg_rating=index.avg_rating,
        review_count=index.review_count,
        ranking_score=index.ranking_score,
    )
    cache_set_json(cache_key, payload.model_dump(mode="json"), ttl_seconds=settings.pro_public_cache_ttl_seconds)
    log_event(db_write, event_name="discover.profile_view", user_id=user.user_id if user else None, properties={"pro_user_id": str(pro_user_id)})
    db_write.commit()
    return payload


@router.get("/pros/{pro_user_id}/niches/{niche_id}/pricing-preview", response_model=NichePricingPreviewResponse)
def get_niche_pricing_preview(
    pro_user_id: uuid.UUID,
    niche_id: uuid.UUID,
    db: Session = Depends(get_db_read_session),
) -> NichePricingPreviewResponse:
    packages = db.execute(
        select(ProPackage).where(
            ProPackage.pro_user_id == pro_user_id,
            ProPackage.niche_id == niche_id,
            ProPackage.is_active.is_(True),
        )
    ).scalars().all()
    if not packages:
        raise APIError(code="not_found", message="No active package for this pro in this niche", status_code=404)

    previews = [
        PackagePricingPreview(
            package_id=p.id,
            title=p.title,
            entry_price=p.price,
            currency=p.currency,
            price_at_photo_count={
                str(count): compute_package_total(db, niche_id=niche_id, entry_rate=p.price, photo_count=count)
                for count in PRICING_PREVIEW_PHOTO_COUNTS
            },
        )
        for p in packages
    ]
    return NichePricingPreviewResponse(pro_user_id=pro_user_id, niche_id=niche_id, packages=previews)


@router.post("/discover/match", response_model=MatchResponse)
def discover_match(
    body: MatchRequest,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_read_session),
    db_write: Session = Depends(get_db_write_session),
) -> MatchResponse:
    stmt = select(ProPublicIndex).where(
        ProPublicIndex.kyc_status == KYCStatus.approved,
        ProPublicIndex.is_accepting_bookings.is_(True),
        ProPublicIndex.completeness_score >= 60,
        ProPublicIndex.min_package_price.is_not(None),
    )

    if body.city:
        stmt = stmt.where(ProPublicIndex.city == body.city)
    if body.budget is not None:
        stmt = stmt.where(ProPublicIndex.min_package_price <= body.budget)

    candidates = db.execute(stmt.order_by(ProPublicIndex.ranking_score.desc()).limit(max(body.limit, 1))).scalars().all()

    results: list[MatchCandidate] = []
    for candidate in candidates:
        reasons: list[str] = []
        if body.styles:
            matched = [s for s in body.styles if s in (candidate.styles or [])]
            if matched:
                reasons.append("matched_styles")
        if body.budget is not None and candidate.min_package_price is not None and candidate.min_package_price <= body.budget:
            reasons.append("within_budget")
        if candidate.disputes_count == 0 and candidate.gigs_cancelled == 0:
            reasons.append("high_reliability")
        if candidate.avg_response_minutes is not None and candidate.avg_response_minutes < 180:
            reasons.append("fast_response")

        results.append(MatchCandidate(pro_user_id=candidate.pro_user_id, ranking_score=candidate.ranking_score, reasons=reasons))

    log_event(db_write, event_name="discover.search", user_id=user.user_id if user else None, properties={"mode": "match", "count": len(results)})
    db_write.commit()
    return MatchResponse(items=results)


@router.post("/analytics")
def create_analytics_event(
    body: AnalyticsCreateRequest,
    user: CurrentUser | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db_write_session),
) -> dict:
    if user:
        enforce_not_banned(db, user.user_id)
    event = log_event(
        db,
        event_name=body.event_name,
        user_id=user.user_id if user else None,
        session_id=body.session_id,
        properties=body.properties,
    )
    db.commit()
    return {"id": str(event.id), "event_name": event.event_name}


def _discover_cache_key(
    *,
    city: str | None,
    country: str | None,
    styles: str | None,
    min_price: float | None,
    max_price: float | None,
    sort: str,
    niche: str | None,
    limit: int,
    offset: int,
) -> str:
    version = get_public_index_version()
    return (
        "discover:pros:"
        f"v{version}:city={city or ''}:country={country or ''}:styles={styles or ''}:"
        f"min={min_price if min_price is not None else ''}:max={max_price if max_price is not None else ''}:"
        f"sort={sort}:niche={niche or ''}:limit={limit}:offset={offset}"
    )


def _pro_public_cache_key(pro_user_id: uuid.UUID) -> str:
    version = get_public_index_version()
    return f"discover:pro_public:v{version}:{pro_user_id}"


@router.post("/admin/index/pro/{pro_user_id}/rebuild")
def rebuild_single_pro_index(
    pro_user_id: uuid.UUID,
    user: CurrentUser = Depends(require_admin),
) -> dict:
    enforce_rate_limit(f"admin-reindex:{user.user_id}", max_requests=30, window_seconds=60)
    rebuild_pro_index.delay(str(pro_user_id))
    return {"queued": True, "pro_user_id": str(pro_user_id)}


@router.post("/admin/index/pro/rebuild-all")
def rebuild_all_index(
    user: CurrentUser = Depends(require_admin),
) -> dict:
    enforce_rate_limit(f"admin-reindex-all:{user.user_id}", max_requests=3, window_seconds=60)
    rebuild_all_pro_indexes.delay()
    return {"queued": True}


def _request_ip(request: Request | None) -> str | None:
    if not request:
        return None
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


def _observe_scraping(db: Session, ip: str | None) -> None:
    if not ip:
        return
    try:
        redis_client = get_redis_client()
        key = f"discover:ip:{ip}:hour"
        count = int(redis_client.incr(key))
        if count == 1:
            redis_client.expire(key, 3600)
    except Exception:
        return
    signal = detect_scraping_activity(db, ip=ip, hits_last_hour=count)
    if signal:
        db.commit()
