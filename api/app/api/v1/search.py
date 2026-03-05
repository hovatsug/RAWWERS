from __future__ import annotations

import logging
import uuid

from fastapi import APIRouter, Depends, Header, Query
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_session, require_admin
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile
from app.models.commerce import CommercePartner, Product, ProductStockStatus
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus
from app.models.learning import Course, CourseLevel
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.repair import GearCategory, RepairPartner, RepairPartnerScore
from app.schemas.media import CurrentUser
from app.schemas.search import (
    AdminSearchPurgeResponse,
    AdminSearchRebuildRequest,
    AdminSearchRebuildResponse,
    AdminSearchStatusResponse,
    SearchResponse,
)
from app.services.cache import cache_get_json, cache_set_json
from app.services.feature_flags import is_feature_enabled
from app.services.launch_ops import is_pro_publicly_discoverable
from app.services.metrics import monotonic_seconds, observe_search_request
from app.services.search_indexing import (
    enqueue_course_index_upsert,
    enqueue_product_index_upsert,
    enqueue_pro_index_upsert,
    enqueue_repair_partner_index_upsert,
    latest_index_sync_at,
    provider_status,
)
from app.services.search_provider import get_index_name, get_search_provider, search_provider_enabled
from app.services.store import list_store_products
from app.services.repair import match_repair_partners

logger = logging.getLogger(__name__)
settings = get_settings()

router = APIRouter(tags=["search"])


def _search_runtime_flags(db: Session) -> tuple[bool, bool]:
    search_flag = is_feature_enabled(db, "search_enabled")
    force_fallback = is_feature_enabled(db, "search_force_db_fallback")
    return (bool(settings.search_enabled and search_flag), bool(force_fallback))


@router.get("/search/pros", response_model=SearchResponse)
def search_pros(
    q: str | None = None,
    niche: str | None = None,
    city: str | None = None,
    country: str | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    tier_min: SkillTier | None = None,
    sort: str = "relevance",
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db_read_session),
) -> SearchResponse:
    return _search_with_fallback(
        db=db,
        index_kind="pros",
        q=q,
        filters=_pros_filter(q=q, niche=niche, city=city, country=country, min_price=min_price, max_price=max_price, tier_min=tier_min),
        sort=_pros_sort(sort, niche),
        limit=limit,
        offset=offset,
        fallback_loader=lambda: _pros_fallback(db, q=q, niche=niche, city=city, country=country, min_price=min_price, max_price=max_price, tier_min=tier_min, sort=sort, limit=limit, offset=offset),
    )


@router.get("/search/courses", response_model=SearchResponse)
def search_courses(
    q: str | None = None,
    niche: str | None = None,
    level: CourseLevel | None = None,
    free_only: bool = False,
    mandatory_only: bool = False,
    sort: str = "relevance",
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db_read_session),
) -> SearchResponse:
    return _search_with_fallback(
        db=db,
        index_kind="courses",
        q=q,
        filters=_courses_filter(niche=niche, level=level, free_only=free_only, mandatory_only=mandatory_only),
        sort=_courses_sort(sort),
        limit=limit,
        offset=offset,
        fallback_loader=lambda: _courses_fallback(db, q=q, niche=niche, level=level, free_only=free_only, mandatory_only=mandatory_only, sort=sort, limit=limit, offset=offset),
    )


@router.get("/search/products", response_model=SearchResponse)
def search_products(
    q: str | None = None,
    category: str | None = None,
    brand: str | None = None,
    min_price: float | None = None,
    max_price: float | None = None,
    in_stock_only: bool = False,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db_read_session),
) -> SearchResponse:
    return _search_with_fallback(
        db=db,
        index_kind="products",
        q=q,
        filters=_products_filter(category=category, brand=brand, min_price=min_price, max_price=max_price, in_stock_only=in_stock_only),
        sort=["updated_at:desc"],
        limit=limit,
        offset=offset,
        fallback_loader=lambda: _products_fallback(db, q=q, category=category, brand=brand, min_price=min_price, max_price=max_price, in_stock_only=in_stock_only, limit=limit, offset=offset),
    )


@router.get("/search/repair-partners", response_model=SearchResponse)
def search_repair_partners(
    q: str | None = None,
    country: str | None = None,
    city: str | None = None,
    category: GearCategory | None = None,
    brand: str | None = None,
    loaner_only: bool = False,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db_read_session),
) -> SearchResponse:
    return _search_with_fallback(
        db=db,
        index_kind="repair_partners",
        q=q,
        filters=_repair_filter(country=country, city=city, category=category, brand=brand, loaner_only=loaner_only),
        sort=["updated_at:desc"],
        limit=limit,
        offset=offset,
        fallback_loader=lambda: _repair_fallback(db, q=q, country=country, city=city, category=category, brand=brand, loaner_only=loaner_only, limit=limit, offset=offset),
    )


@router.get("/admin/search/status", response_model=AdminSearchStatusResponse)
def admin_search_status(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminSearchStatusResponse:
    stat = provider_status()
    enabled, force = _search_runtime_flags(db)
    return AdminSearchStatusResponse(
        provider=stat["provider"],
        enabled=stat["enabled"],
        search_index_prefix=stat["search_index_prefix"],
        indexes=stat["indexes"],
        last_sync_at=latest_index_sync_at(db),
        feature_search_enabled=enabled,
        feature_force_db_fallback=force,
    )


@router.post("/admin/search/rebuild", response_model=AdminSearchRebuildResponse)
def admin_search_rebuild(
    body: AdminSearchRebuildRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminSearchRebuildResponse:
    indexes = _normalize_rebuild_indexes(body.index)
    queued = 0

    if "pros" in indexes:
        ids = db.execute(select(ProPublicIndex.pro_user_id)).scalars().all()
        for item in ids:
            if enqueue_pro_index_upsert(db, item, idempotency_suffix="rebuild"):
                queued += 1

    if "courses" in indexes:
        ids = db.execute(select(Course.id)).scalars().all()
        for item in ids:
            if enqueue_course_index_upsert(db, item, idempotency_suffix="rebuild"):
                queued += 1

    if "products" in indexes:
        ids = db.execute(select(Product.id)).scalars().all()
        for item in ids:
            if enqueue_product_index_upsert(db, item, idempotency_suffix="rebuild"):
                queued += 1

    if "repair_partners" in indexes:
        ids = db.execute(select(RepairPartner.id)).scalars().all()
        for item in ids:
            if enqueue_repair_partner_index_upsert(db, item, idempotency_suffix="rebuild"):
                queued += 1

    from app.services.audit import add_admin_audit_log

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="search",
        target_id="rebuild",
        action="search_rebuild",
        metadata={"indexes": indexes, "queued": queued},
    )
    db.commit()
    return AdminSearchRebuildResponse(queued_events=queued, indexes=indexes)


@router.post("/admin/search/purge", response_model=AdminSearchPurgeResponse)
def admin_search_purge(
    body: AdminSearchRebuildRequest,
    x_confirm: str = Header(default="", alias="X-Confirm"),
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminSearchPurgeResponse:
    if x_confirm != "YES":
        raise APIError(code="validation_error", message="X-Confirm: YES required", status_code=400)
    provider = get_search_provider()
    indexes = _normalize_rebuild_indexes(body.index)
    purged: list[str] = []
    for key in indexes:
        provider.purge_index(get_index_name(key))
        purged.append(key)

    from app.services.audit import add_admin_audit_log

    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="search",
        target_id="purge",
        action="search_purge",
        metadata={"indexes": indexes},
    )
    db.commit()
    return AdminSearchPurgeResponse(purged=purged)


def _search_with_fallback(
    *,
    db: Session,
    index_kind: str,
    q: str | None,
    filters: str | None,
    sort: list[str] | None,
    limit: int,
    offset: int,
    fallback_loader,
) -> SearchResponse:
    enabled, force_fallback = _search_runtime_flags(db)
    cache_key = f"search-fallback:{index_kind}:{q}:{filters}:{sort}:{limit}:{offset}"

    start = monotonic_seconds()
    used_fallback = True
    success = True

    if enabled and not force_fallback and search_provider_enabled():
        try:
            provider = get_search_provider()
            result = provider.search(
                get_index_name(index_kind),
                query=q or "",
                filters=filters,
                sort=sort,
                limit=limit,
                offset=offset,
            )
            used_fallback = False
            duration = monotonic_seconds() - start
            observe_search_request(index_kind, fallback=False, success=True, duration_seconds=duration)
            return SearchResponse(total=result.total, items=result.items, used_fallback=False)
        except Exception as exc:
            logger.exception(
                "search_provider_failure",
                extra={"index_name": index_kind, "query_len": len(q or ""), "filters": str(filters)[:300]},
            )
            success = False

    cached = cache_get_json(cache_key)
    if cached:
        duration = monotonic_seconds() - start
        observe_search_request(index_kind, fallback=True, success=True, duration_seconds=duration)
        return SearchResponse.model_validate(cached)

    total, items = fallback_loader()
    response = SearchResponse(total=total, items=items, used_fallback=True)
    cache_set_json(cache_key, response.model_dump(mode="json"), ttl_seconds=settings.search_fallback_cache_ttl_seconds)

    duration = monotonic_seconds() - start
    observe_search_request(index_kind, fallback=True, success=success, duration_seconds=duration)
    return response


def _pros_filter(
    *,
    q: str | None,
    niche: str | None,
    city: str | None,
    country: str | None,
    min_price: float | None,
    max_price: float | None,
    tier_min: SkillTier | None,
) -> str | None:
    clauses = ["is_kyc_approved = true", "is_available = true"]
    if niche:
        clauses.append(f'niche_slugs = "{niche}"')
    if city:
        clauses.append(f'city = "{city}"')
    if country:
        clauses.append(f'country = "{country}"')
    if min_price is not None:
        clauses.append(f"price_min >= {float(min_price)}")
    if max_price is not None:
        clauses.append(f"price_min <= {float(max_price)}")
    return " AND ".join(clauses)


def _courses_filter(*, niche: str | None, level: CourseLevel | None, free_only: bool, mandatory_only: bool) -> str | None:
    clauses = ["is_published = true"]
    if niche:
        clauses.append(f'niche_slug = "{niche}"')
    if level:
        clauses.append(f'level = "{level.value}"')
    if free_only:
        clauses.append("price IS NULL")
    if mandatory_only:
        clauses.append("is_mandatory = true")
    return " AND ".join(clauses)


def _products_filter(*, category: str | None, brand: str | None, min_price: float | None, max_price: float | None, in_stock_only: bool) -> str | None:
    clauses = ["is_available = true"]
    if category:
        clauses.append(f'category = "{category}"')
    if brand:
        clauses.append(f'brand = "{brand}"')
    if min_price is not None:
        clauses.append(f"price >= {float(min_price)}")
    if max_price is not None:
        clauses.append(f"price <= {float(max_price)}")
    if in_stock_only:
        clauses.append('stock_status = "in_stock"')
    return " AND ".join(clauses)


def _repair_filter(*, country: str | None, city: str | None, category: GearCategory | None, brand: str | None, loaner_only: bool) -> str | None:
    clauses = ["is_active = true"]
    if country:
        clauses.append(f'country = "{country}"')
    if city:
        clauses.append(f'city = "{city}"')
    if category:
        clauses.append(f'categories_supported = "{category.value}"')
    if brand:
        clauses.append(f'brands_supported = "{brand}"')
    if loaner_only:
        clauses.append("loaner_supported = true")
    return " AND ".join(clauses)


def _pros_sort(sort: str, niche: str | None) -> list[str] | None:
    if sort == "rating":
        return ["avg_rating:desc"]
    if sort == "price":
        return ["price_min:asc"]
    if sort == "recent":
        return ["last_active_at:desc"]
    if sort == "relevance":
        return [f"niche_capability.{niche}:desc"] if niche else None
    return None


def _courses_sort(sort: str) -> list[str] | None:
    if sort == "recent":
        return ["updated_at:desc"]
    if sort == "price":
        return ["price:asc"]
    return None


def _pros_fallback(
    db: Session,
    *,
    q: str | None,
    niche: str | None,
    city: str | None,
    country: str | None,
    min_price: float | None,
    max_price: float | None,
    tier_min: SkillTier | None,
    sort: str,
    limit: int,
    offset: int,
) -> tuple[int, list[dict]]:
    stmt = (
        select(ProPublicIndex, ProProfile)
        .join(ProProfile, ProProfile.user_id == ProPublicIndex.pro_user_id)
        .join(
            ProOnboarding,
            and_(
                ProOnboarding.pro_user_id == ProPublicIndex.pro_user_id,
                ProOnboarding.status == ProOnboardingStatus.approved_public,
            ),
        )
    )
    stmt = stmt.where(
        ProPublicIndex.kyc_status == KYCStatus.approved,
        ProPublicIndex.is_accepting_bookings.is_(True),
    )
    if q:
        stmt = stmt.where(ProProfile.display_name.ilike(f"%{q}%"))
    if niche:
        stmt = stmt.where(ProPublicIndex.top_niches.contains([{"slug": niche}]))
    if city:
        stmt = stmt.where(ProPublicIndex.city == city)
    if country:
        stmt = stmt.where(ProPublicIndex.country == country)
    if min_price is not None:
        stmt = stmt.where(ProPublicIndex.min_package_price >= min_price)
    if max_price is not None:
        stmt = stmt.where(ProPublicIndex.min_package_price <= max_price)

    if tier_min and niche:
        stmt = stmt.join(ProNicheSkill, and_(ProNicheSkill.pro_user_id == ProPublicIndex.pro_user_id))
        stmt = stmt.join(Niche, Niche.id == ProNicheSkill.niche_id)
        stmt = stmt.where(Niche.slug == niche, ProNicheSkill.tier.in_(_tier_or_higher(tier_min)))

    if sort == "rating":
        stmt = stmt.order_by(ProPublicIndex.avg_rating.desc(), ProPublicIndex.review_count.desc())
    elif sort == "price":
        stmt = stmt.order_by(ProPublicIndex.min_package_price.asc())
    elif sort == "recent":
        stmt = stmt.order_by(ProPublicIndex.updated_at.desc())
    else:
        stmt = stmt.order_by(ProPublicIndex.ranking_score.desc())

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(stmt.offset(offset).limit(limit)).all()
    items = []
    for idx, profile in rows:
        if not is_pro_publicly_discoverable(db, pro_user_id=idx.pro_user_id):
            continue
        items.append(
            {
                "id": str(idx.pro_user_id),
                "display_name": profile.display_name,
                "headline": profile.headline,
                "cover_media_asset_id": str(profile.cover_media_asset_id) if profile.cover_media_asset_id else None,
                "city": idx.city,
                "country": idx.country,
                "niche_slugs": [item.get("slug") for item in (idx.top_niches or []) if item.get("slug")],
                "top_niche": (idx.top_niches or [{}])[0].get("slug") if idx.top_niches else None,
                "price_min": float(idx.min_package_price) if idx.min_package_price is not None else None,
                "price_max": float(idx.max_package_price) if idx.max_package_price is not None else None,
                "avg_rating": float(idx.avg_rating),
                "review_count": idx.review_count,
                "completed_gigs_total": idx.gigs_completed,
                "last_active_at": idx.updated_at.isoformat() if idx.updated_at else None,
            }
        )
    total = len(items)
    return total, items


def _courses_fallback(
    db: Session,
    *,
    q: str | None,
    niche: str | None,
    level: CourseLevel | None,
    free_only: bool,
    mandatory_only: bool,
    sort: str,
    limit: int,
    offset: int,
) -> tuple[int, list[dict]]:
    stmt = select(Course, Niche, ProProfile).join(Niche, Niche.id == Course.niche_id).join(
        ProProfile,
        ProProfile.user_id == Course.instructor_user_id,
        isouter=True,
    )
    stmt = stmt.where(Course.is_published.is_(True))
    if q:
        stmt = stmt.where(or_(Course.title.ilike(f"%{q}%"), Course.summary.ilike(f"%{q}%")))
    if niche:
        stmt = stmt.where(Niche.slug == niche)
    if level:
        stmt = stmt.where(Course.level == level)
    if free_only:
        stmt = stmt.where(Course.price.is_(None))
    if mandatory_only:
        stmt = stmt.where(Course.is_mandatory.is_(True))
    if sort == "price":
        stmt = stmt.order_by(Course.price.asc().nullsfirst(), Course.updated_at.desc())
    else:
        stmt = stmt.order_by(Course.updated_at.desc())

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(stmt.offset(offset).limit(limit)).all()
    items = [
        {
            "id": str(course.id),
            "title": course.title,
            "summary": course.summary,
            "niche_slug": niche_row.slug,
            "level": course.level.value,
            "is_mandatory": course.is_mandatory,
            "price": float(course.price) if course.price is not None else None,
            "currency": course.currency,
            "instructor_name": profile.display_name if profile else None,
            "updated_at": course.updated_at.isoformat() if course.updated_at else None,
        }
        for course, niche_row, profile in rows
    ]
    return total, items


def _products_fallback(
    db: Session,
    *,
    q: str | None,
    category: str | None,
    brand: str | None,
    min_price: float | None,
    max_price: float | None,
    in_stock_only: bool,
    limit: int,
    offset: int,
) -> tuple[int, list[dict]]:
    total, rows = list_store_products(
        db,
        category=category,
        brand=brand,
        min_price=min_price,
        max_price=max_price,
        search=q,
        limit=limit,
        offset=offset,
    )
    if in_stock_only:
        rows = [r for r in rows if r.stock_status == ProductStockStatus.in_stock]
        total = len(rows)
    partner_ids = {item.partner_id for item in rows}
    partners = db.execute(select(CommercePartner).where(CommercePartner.id.in_(partner_ids))).scalars().all() if partner_ids else []
    partner_map = {item.id: item.name for item in partners}

    items = [
        {
            "id": str(row.id),
            "title": row.title,
            "description": row.description,
            "category": row.category,
            "brand": row.brand,
            "price": float(row.partner_price),
            "is_available": row.is_available,
            "stock_status": row.stock_status.value,
            "shipping_estimate_days": row.shipping_estimate_days,
            "partner_name": partner_map.get(row.partner_id),
            "updated_at": row.updated_at.isoformat() if row.updated_at else None,
        }
        for row in rows
    ]
    return total, items


def _repair_fallback(
    db: Session,
    *,
    q: str | None,
    country: str | None,
    city: str | None,
    category: GearCategory | None,
    brand: str | None,
    loaner_only: bool,
    limit: int,
    offset: int,
) -> tuple[int, list[dict]]:
    rows = match_repair_partners(db, country=country, city=city, category=category, brand=brand, loaner_only=loaner_only)
    if q:
        ql = q.lower().strip()
        rows = [item for item in rows if ql in item.name.lower()]

    total = len(rows)
    page = rows[offset: offset + limit]
    partner_ids = [item.id for item in page]
    scores = db.execute(select(RepairPartnerScore).where(RepairPartnerScore.partner_id.in_(partner_ids))).scalars().all() if partner_ids else []
    score_map = {item.partner_id: item for item in scores}

    items = []
    for row in page:
        score = score_map.get(row.id)
        items.append(
            {
                "id": str(row.id),
                "name": row.name,
                "country": row.country,
                "city": row.city,
                "categories_supported": row.categories_supported or [],
                "brands_supported": row.brands_supported or [],
                "loaner_supported": row.loaner_supported,
                "loaner_categories": row.loaner_categories or [],
                "sla_quote_hours": row.sla_quote_hours,
                "sla_turnaround_days": row.sla_turnaround_days,
                "score_summary": {
                    "avg_quote_hours": float(score.avg_quote_hours) if score and score.avg_quote_hours is not None else None,
                    "avg_turnaround_days": float(score.avg_turnaround_days) if score and score.avg_turnaround_days is not None else None,
                },
                "updated_at": row.updated_at.isoformat() if row.updated_at else None,
            }
        )
    return total, items


def _tier_or_higher(tier: SkillTier) -> list[SkillTier]:
    ordered = [SkillTier.rookie, SkillTier.skilled, SkillTier.pro, SkillTier.elite, SkillTier.master]
    if tier not in ordered:
        return ordered
    i = ordered.index(tier)
    return ordered[i:]


def _normalize_rebuild_indexes(index: str) -> list[str]:
    index = (index or "all").strip().lower()
    allowed = ["pros", "courses", "products", "repair_partners"]
    if index == "all":
        return allowed
    if index not in allowed:
        raise APIError(code="validation_error", message="Invalid index", status_code=422)
    return [index]
