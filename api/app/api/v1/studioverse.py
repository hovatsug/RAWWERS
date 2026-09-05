from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_write_session, get_locale, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import ProProfile, UserRoleType
from app.models.studioverse import (
    ContentPack,
    ContentPackEntitlement,
    ContentPackOrder,
    ContentPackPaymentMethod,
    ContentPackOrderStatus,
    ContentPackReview,
    ContentPackReviewDecision,
    ContentPackStatus,
    ContentPackTakedown,
)
from app.models.proof_of_gigs import RawwIssuanceEventType
from app.schemas.media import CurrentUser
from app.schemas.studioverse import (
    StudioverseAdminPackListResponse,
    StudioverseAdminReviewRequest,
    StudioverseAdminTakedownRequest,
    StudioverseCheckoutRequest,
    StudioverseCheckoutResponse,
    StudioverseCreatorPackView,
    StudioverseDownloadResponse,
    StudioverseMarketplaceListResponse,
    StudioverseMarketplacePackView,
    StudioverseOrderView,
    StudioverseOrdersResponse,
    StudioversePackCreateRequest,
    StudioversePackListResponse,
    StudioversePackSubmitResponse,
    StudioversePackUpdateRequest,
)
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.authz import ensure_user_account
from app.services.feature_flags import is_feature_enabled
from app.services.notifications import NotificationSeverity, enqueue_notification
from app.services.outbox import enqueue_outbox_event
from app.services.rate_limit import enforce_named_rate_limit
from app.services.search_provider import get_index_name, get_search_provider, search_provider_enabled
from app.services.studioverse import (
    append_pack_version_if_changed,
    can_access_pack_for_purchase,
    create_stripe_payment_intent_for_pack,
    ensure_creator_can_submit,
    list_marketplace_packs_db,
    mark_download_or_raise,
    normalize_search_filters,
    payment_succeeded_from_intent_status,
    process_raww_credit_split,
    query_admin_packs,
    query_buyer_orders,
    query_creator_packs,
    settle_paid_order,
    update_pack_sources,
    validate_checkout_method,
    validate_review_transition,
    validate_submission_sources,
)
from app.services.proof_of_gigs import enqueue_raww_mint
from app.services.payouts import create_earnings_entry
from app.models.payouts import EarningsSourceType
from app.services.i18n import get_localized_fields

router = APIRouter(tags=["studioverse"])


@router.post("/studioverse/packs", response_model=StudioverseCreatorPackView)
def create_content_pack_draft(
    body: StudioversePackCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> StudioverseCreatorPackView:
    ensure_creator_can_submit(db, creator_user_id=user.user_id)

    row = ContentPack(
        creator_user_id=user.user_id,
        title=body.title.strip(),
        description=body.description.strip(),
        category=body.category,
        niche_slugs=body.niche_slugs,
        tags=body.tags,
        price_eur=body.price_eur,
        price_raww=body.price_raww,
        currency=(body.currency or "EUR").upper(),
        cover_media_asset_id=body.cover_media_asset_id,
        preview_media_asset_ids=body.preview_media_asset_ids,
        pack_file_storage_key=body.pack_file_storage_key.strip(),
        pack_file_bytes=body.pack_file_bytes,
        license_code=body.license_code.strip(),
        status=ContentPackStatus.draft,
    )
    db.add(row)
    db.flush()

    append_pack_version_if_changed(db, pack=row, new_storage_key=row.pack_file_storage_key, release_notes="initial draft")
    update_pack_sources(db, content_pack_id=row.id, sources=[item.model_dump() for item in body.sources])
    db.commit()
    db.refresh(row)
    return _creator_pack_view(db, row, locale="en-GB")


@router.put("/studioverse/packs/{pack_id}", response_model=StudioverseCreatorPackView)
def update_content_pack_draft(
    pack_id: uuid.UUID,
    body: StudioversePackUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> StudioverseCreatorPackView:
    ensure_creator_can_submit(db, creator_user_id=user.user_id)
    pack = db.get(ContentPack, pack_id)
    if not pack or pack.creator_user_id != user.user_id:
        raise APIError(code="not_found", message="Pack not found", status_code=404)
    if pack.status not in {ContentPackStatus.draft, ContentPackStatus.rejected}:
        raise APIError(code="validation_error", message="Only draft/rejected packs can be edited", status_code=422)

    updates = body.model_dump(exclude_unset=True)
    for key in [
        "title",
        "description",
        "category",
        "niche_slugs",
        "tags",
        "price_eur",
        "price_raww",
        "currency",
        "cover_media_asset_id",
        "preview_media_asset_ids",
        "pack_file_storage_key",
        "pack_file_bytes",
        "license_code",
    ]:
        if key in updates:
            value = updates[key]
            if key in {"title", "description", "pack_file_storage_key", "license_code"} and isinstance(value, str):
                value = value.strip()
            if key == "currency" and isinstance(value, str):
                value = value.upper()
            setattr(pack, key, value)

    if "pack_file_storage_key" in updates:
        append_pack_version_if_changed(db, pack=pack, new_storage_key=pack.pack_file_storage_key, release_notes="creator update")

    if body.sources is not None:
        update_pack_sources(db, content_pack_id=pack.id, sources=[item.model_dump() for item in body.sources])

    pack.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(pack)
    return _creator_pack_view(db, pack, locale="en-GB")


@router.post("/studioverse/packs/{pack_id}/submit", response_model=StudioversePackSubmitResponse)
def submit_content_pack(
    pack_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> StudioversePackSubmitResponse:
    ensure_creator_can_submit(db, creator_user_id=user.user_id)
    pack = db.get(ContentPack, pack_id)
    if not pack or pack.creator_user_id != user.user_id:
        raise APIError(code="not_found", message="Pack not found", status_code=404)
    if pack.status not in {ContentPackStatus.draft, ContentPackStatus.rejected}:
        raise APIError(code="validation_error", message="Pack cannot be submitted", status_code=422)

    validate_submission_sources(db, pack=pack)

    pack.status = ContentPackStatus.submitted
    pack.updated_at = datetime.now(timezone.utc)

    enqueue_notification(
        db,
        user_id=user.user_id,
        notification_type="store.order_paid",
        payload={"title": "Studioverse pack submitted", "body": f"{pack.title} was submitted for review."},
        reference_type="content_pack",
        reference_id=str(pack.id),
        severity=NotificationSeverity.info,
    )
    log_event(db, event_name="studioverse.pack_submitted", user_id=user.user_id, properties={"pack_id": str(pack.id)})
    db.commit()
    return StudioversePackSubmitResponse(id=pack.id, status=pack.status)


@router.get("/studioverse/packs/mine", response_model=StudioversePackListResponse)
def list_my_content_packs(
    user: CurrentUser = Depends(require_not_banned),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_read_session),
) -> StudioversePackListResponse:
    ensure_user_account(db, user.user_id)
    rows = query_creator_packs(db, creator_user_id=user.user_id)
    return StudioversePackListResponse(total=len(rows), items=[_creator_pack_view(db, row, locale=locale) for row in rows])


@router.get("/studioverse/packs", response_model=StudioverseMarketplaceListResponse)
def list_marketplace_packs(
    search: str | None = Query(default=None),
    category: str | None = Query(default=None),
    niche: str | None = Query(default=None),
    limit: int = Query(default=20, ge=1, le=50),
    offset: int = Query(default=0, ge=0),
    user: CurrentUser = Depends(require_not_banned),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_read_session),
) -> StudioverseMarketplaceListResponse:
    if not is_feature_enabled(db, "client_browsing_enabled_global", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Marketplace temporarily unavailable", status_code=503)
    enforce_named_rate_limit("public_read", principal=str(user.user_id))
    parsed_category, parsed_niche = normalize_search_filters(category=category, niche=niche)

    items: list[StudioverseMarketplacePackView] = []
    total = 0
    if search_provider_enabled() and not is_feature_enabled(db, "search_force_db_fallback", user_id=user.user_id):
        filters: list[str] = ['status = "approved"']
        if parsed_category:
            filters.append(f'category = "{parsed_category.value}"')
        if parsed_niche:
            filters.append(f'niche_slugs = "{parsed_niche}"')
        result = get_search_provider().search(
            index_name=get_index_name("content_packs"),
            query=search or "",
            filters=" AND ".join(filters) if filters else None,
            sort=["updated_at:desc"],
            limit=limit,
            offset=offset,
        )
        total = result.total
        for hit in result.items:
            pack = db.get(ContentPack, uuid.UUID(hit["id"]))
            if not pack or pack.status != ContentPackStatus.approved:
                continue
            items.append(_marketplace_pack_view(db, pack, locale=locale))
    else:
        total, rows = list_marketplace_packs_db(
            db,
            search=search,
            category=parsed_category,
            niche=parsed_niche,
            limit=limit,
            offset=offset,
        )
        items = [_marketplace_pack_view(db, row, locale=locale) for row in rows]

    return StudioverseMarketplaceListResponse(total=total, items=items)


@router.get("/studioverse/packs/{pack_id}", response_model=StudioverseMarketplacePackView)
def marketplace_pack_detail(
    pack_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_read_session),
) -> StudioverseMarketplacePackView:
    enforce_named_rate_limit("public_read", principal=str(user.user_id))
    row = db.get(ContentPack, pack_id)
    if not row or row.status != ContentPackStatus.approved:
        raise APIError(code="not_found", message="Pack not found", status_code=404)
    return _marketplace_pack_view(db, row, locale=locale)


@router.post("/studioverse/packs/{pack_id}/checkout", response_model=StudioverseCheckoutResponse)
def checkout_content_pack(
    pack_id: uuid.UUID,
    body: StudioverseCheckoutRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> StudioverseCheckoutResponse:
    enforce_named_rate_limit("payments", principal=str(user.user_id))
    pack = db.get(ContentPack, pack_id)
    if not pack or not can_access_pack_for_purchase(pack):
        raise APIError(code="not_found", message="Pack not found", status_code=404)
    if pack.creator_user_id == user.user_id:
        raise APIError(code="validation_error", message="You cannot purchase your own pack", status_code=422)

    existing_paid = db.execute(
        select(ContentPackOrder)
        .where(
            ContentPackOrder.buyer_user_id == user.user_id,
            ContentPackOrder.content_pack_id == pack_id,
            ContentPackOrder.status == ContentPackOrderStatus.paid,
        )
        .order_by(ContentPackOrder.created_at.desc())
    ).scalar_one_or_none()
    if existing_paid:
        return StudioverseCheckoutResponse(order=_order_view(existing_paid), payment_intent_client_secret=None)

    eur_amount, raww_amount = validate_checkout_method(method=body.payment_method, pack=pack)
    order = ContentPackOrder(
        buyer_user_id=user.user_id,
        content_pack_id=pack.id,
        price_eur_paid=eur_amount if body.payment_method in {ContentPackPaymentMethod.stripe, ContentPackPaymentMethod.mixed} else 0,
        price_raww_paid=raww_amount if body.payment_method in {ContentPackPaymentMethod.raww_credits, ContentPackPaymentMethod.mixed} else 0,
        payment_method=body.payment_method,
        status=ContentPackOrderStatus.pending,
    )
    db.add(order)
    db.flush()

    payment_intent_client_secret = None
    stripe_status_succeeded = False

    if body.payment_method in {ContentPackPaymentMethod.stripe, ContentPackPaymentMethod.mixed}:
        intent = create_stripe_payment_intent_for_pack(
            order_id=order.id,
            buyer_user_id=user.user_id,
            pack=pack,
            amount=eur_amount,
        )
        order.stripe_payment_intent_id = intent.id
        payment_intent_client_secret = getattr(intent, "client_secret", None)
        stripe_status_succeeded = payment_succeeded_from_intent_status(getattr(intent, "status", ""))

    if body.payment_method in {ContentPackPaymentMethod.raww_credits, ContentPackPaymentMethod.mixed} and (
        body.payment_method == ContentPackPaymentMethod.raww_credits or stripe_status_succeeded
    ):
        process_raww_credit_split(db, order=order, pack=pack)

    if body.payment_method == ContentPackPaymentMethod.raww_credits or (
        body.payment_method in {ContentPackPaymentMethod.stripe, ContentPackPaymentMethod.mixed} and stripe_status_succeeded
    ):
        order.status = ContentPackOrderStatus.paid
        settle_paid_order(db, order=order)
        create_earnings_entry(
            db,
            pro_user_id=pack.creator_user_id,
            source_type=EarningsSourceType.studioverse_sale,
            source_id=order.id,
            gross_eur=order.price_eur_paid,
            metadata={"content_pack_id": str(pack.id), "payment_method": body.payment_method.value},
        )
        enqueue_raww_mint(
            db,
            event_type=RawwIssuanceEventType.studioverse_pack_sold,
            payload={"content_pack_order_id": str(order.id)},
            idempotency_key=f"raww:pack_sold:{order.id}",
        )
        log_event(
            db,
            event_name="studioverse.purchase_succeeded",
            user_id=user.user_id,
            properties={"order_id": str(order.id), "pack_id": str(pack.id), "payment_method": body.payment_method.value},
        )
    else:
        order.status = ContentPackOrderStatus.pending

    db.commit()
    db.refresh(order)
    return StudioverseCheckoutResponse(order=_order_view(order), payment_intent_client_secret=payment_intent_client_secret)


@router.get("/studioverse/orders/mine", response_model=StudioverseOrdersResponse)
def list_my_studioverse_orders(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> StudioverseOrdersResponse:
    rows = query_buyer_orders(db, buyer_user_id=user.user_id)
    return StudioverseOrdersResponse(total=len(rows), items=[_order_view(row) for row in rows])


@router.post("/studioverse/orders/{order_id}/download", response_model=StudioverseDownloadResponse)
def download_content_pack(
    order_id: uuid.UUID,
    request: Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_write_session),
) -> StudioverseDownloadResponse:
    enforce_named_rate_limit("public_read", principal=str(user.user_id))
    order = db.get(ContentPackOrder, order_id)
    if not order or order.buyer_user_id != user.user_id:
        raise APIError(code="not_found", message="Order not found", status_code=404)
    if order.status != ContentPackOrderStatus.paid:
        raise APIError(code="forbidden", message="Order is not paid", status_code=403)

    entitlement = db.execute(
        select(ContentPackEntitlement).where(ContentPackEntitlement.order_id == order.id)
    ).scalar_one_or_none()
    if not entitlement:
        raise APIError(code="forbidden", message="No entitlement found for this order", status_code=403)

    url = mark_download_or_raise(
        db,
        order=order,
        entitlement=entitlement,
        user_id=user.user_id,
        ip=_request_ip(request),
        user_agent=request.headers.get("user-agent"),
    )
    log_event(db, event_name="studioverse.download", user_id=user.user_id, properties={"order_id": str(order.id), "pack_id": str(order.content_pack_id)})
    db.commit()
    db.refresh(entitlement)
    return StudioverseDownloadResponse(
        order_id=order.id,
        download_url=url,
        downloads_used=entitlement.downloads_used,
        download_limit=entitlement.download_limit,
    )


@router.get("/admin/studioverse/packs", response_model=StudioverseAdminPackListResponse)
def admin_list_studioverse_packs(
    status: ContentPackStatus | None = Query(default=None),
    _: CurrentUser = Depends(require_admin),
    locale: str = Depends(get_locale),
    db: Session = Depends(get_db_read_session),
) -> StudioverseAdminPackListResponse:
    rows = query_admin_packs(db, status=status)
    return StudioverseAdminPackListResponse(total=len(rows), items=[_creator_pack_view(db, row, locale=locale) for row in rows])


@router.post("/admin/studioverse/packs/{pack_id}/review", response_model=StudioverseCreatorPackView)
def admin_review_studioverse_pack(
    pack_id: uuid.UUID,
    body: StudioverseAdminReviewRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_write_session),
) -> StudioverseCreatorPackView:
    pack = db.get(ContentPack, pack_id)
    if not pack:
        raise APIError(code="not_found", message="Pack not found", status_code=404)

    validate_review_transition(pack=pack, decision=body.decision)

    review = ContentPackReview(
        content_pack_id=pack.id,
        reviewer_admin_id=actor.user_id,
        decision=body.decision,
        notes=body.notes,
    )
    db.add(review)

    if body.decision == ContentPackReviewDecision.approved:
        pack.status = ContentPackStatus.approved
        pack.approved_at = datetime.now(timezone.utc)
        log_event(db, event_name="studioverse.pack_approved", user_id=pack.creator_user_id, properties={"pack_id": str(pack.id)})
        enqueue_outbox_event(
            db,
            topic="index.content_pack.upsert",
            payload={"content_pack_id": str(pack.id)},
            idempotency_key=f"index.content_pack.upsert:{pack.id}:{int(datetime.now(timezone.utc).timestamp())}",
            idempotency_scope="search_indexing",
        )
    else:
        pack.status = ContentPackStatus.rejected

    pack.updated_at = datetime.now(timezone.utc)
    enqueue_notification(
        db,
        user_id=pack.creator_user_id,
        notification_type="review.request",
        payload={
            "title": "Studioverse review update",
            "body": "Your content pack was approved." if body.decision == ContentPackReviewDecision.approved else "Your content pack was rejected.",
        },
        reference_type="content_pack",
        reference_id=str(pack.id),
        severity=NotificationSeverity.info,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="content_pack",
        target_id=str(pack.id),
        action="studioverse_pack_review",
        reason=body.notes,
        metadata={"decision": body.decision.value},
    )
    db.commit()
    db.refresh(pack)
    return _creator_pack_view(db, pack, locale="en-GB")


@router.post("/admin/studioverse/packs/{pack_id}/takedown", response_model=StudioverseCreatorPackView)
def admin_takedown_studioverse_pack(
    pack_id: uuid.UUID,
    body: StudioverseAdminTakedownRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_write_session),
) -> StudioverseCreatorPackView:
    pack = db.get(ContentPack, pack_id)
    if not pack:
        raise APIError(code="not_found", message="Pack not found", status_code=404)

    pack.status = ContentPackStatus.delisted
    pack.updated_at = datetime.now(timezone.utc)
    db.add(ContentPackTakedown(content_pack_id=pack.id, reason=body.reason.strip(), admin_user_id=actor.user_id))
    enqueue_outbox_event(
        db,
        topic="index.content_pack.delete",
        payload={"content_pack_id": str(pack.id)},
        idempotency_key=f"index.content_pack.delete:{pack.id}:{int(datetime.now(timezone.utc).timestamp())}",
        idempotency_scope="search_indexing",
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="content_pack",
        target_id=str(pack.id),
        action="studioverse_pack_takedown",
        reason=body.reason,
        metadata={},
    )
    db.commit()
    db.refresh(pack)
    return _creator_pack_view(db, pack, locale="en-GB")


def _creator_pack_view(db: Session, row: ContentPack, *, locale: str) -> StudioverseCreatorPackView:
    localized = get_localized_fields(
        db,
        entity_type="content_pack",
        entity_id=row.id,
        locale=locale,
        base_fields={"title": row.title, "description": row.description},
    )
    return StudioverseCreatorPackView(
        id=row.id,
        title=str(localized.get("title") or row.title),
        description=str(localized.get("description") or row.description),
        localized_fields={"title": localized.get("title"), "description": localized.get("description")},
        category=row.category,
        niche_slugs=row.niche_slugs or [],
        tags=row.tags or [],
        price_eur=row.price_eur,
        price_raww=row.price_raww,
        currency=row.currency,
        cover_media_asset_id=row.cover_media_asset_id,
        preview_media_asset_ids=row.preview_media_asset_ids or [],
        license_code=row.license_code,
        status=row.status,
        created_at=row.created_at,
        updated_at=row.updated_at,
        approved_at=row.approved_at,
    )


def _marketplace_pack_view(db: Session, row: ContentPack, *, locale: str) -> StudioverseMarketplacePackView:
    pro = db.get(ProProfile, row.creator_user_id)
    localized = get_localized_fields(
        db,
        entity_type="content_pack",
        entity_id=row.id,
        locale=locale,
        base_fields={"title": row.title, "description": row.description},
    )
    return StudioverseMarketplacePackView(
        id=row.id,
        creator_user_id=row.creator_user_id,
        creator_name=pro.display_name if pro else None,
        title=str(localized.get("title") or row.title),
        description=str(localized.get("description") or row.description),
        localized_fields={"title": localized.get("title"), "description": localized.get("description")},
        category=row.category,
        niche_slugs=row.niche_slugs or [],
        tags=row.tags or [],
        price_eur=row.price_eur,
        price_raww=row.price_raww,
        currency=row.currency,
        cover_media_asset_id=row.cover_media_asset_id,
        preview_media_asset_ids=row.preview_media_asset_ids or [],
        license_code=row.license_code,
        status=row.status,
        updated_at=row.updated_at,
    )


def _order_view(row: ContentPackOrder) -> StudioverseOrderView:
    return StudioverseOrderView(
        id=row.id,
        buyer_user_id=row.buyer_user_id,
        content_pack_id=row.content_pack_id,
        price_eur_paid=row.price_eur_paid,
        price_raww_paid=row.price_raww_paid,
        payment_method=row.payment_method,
        stripe_payment_intent_id=row.stripe_payment_intent_id,
        status=row.status,
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


def _request_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None
