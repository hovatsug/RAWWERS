from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.commerce import (
    CartItem,
    CommerceOrder,
    CommercePartner,
    PriceRule,
    Product,
    StoreAccessOverride,
    StoreOrderStatus,
)
from app.schemas.media import CurrentUser
from app.schemas.store import (
    AdminOrderStatusUpdateRequest,
    AdminPartnerRequest,
    AdminPartnerView,
    AdminPriceRuleRequest,
    AdminPriceRuleView,
    AdminProductRequest,
    CartAddItemRequest,
    StoreAccessResponse,
    StoreCartItemView,
    StoreCartView,
    StoreCheckoutRequest,
    StoreCheckoutResponse,
    OrderItemView,
    OrderPaymentView,
    StoreOrderView,
    StoreOrdersResponse,
    StoreOverrideRequest,
    StoreOverrideView,
    StorePolicyRequest,
    StorePolicyView,
    StoreProductListResponse,
    StoreProductView,
)
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.store import (
    can_access_pro_store,
    create_order_from_cart,
    get_or_create_cart,
    get_or_create_store_policy,
    list_store_products,
    order_view_payload,
)
from app.tasks.store_tasks import sync_partner_products_task

router = APIRouter(tags=["store"])


@router.get("/store/access", response_model=StoreAccessResponse)
def store_access(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreAccessResponse:
    result = can_access_pro_store(db, user.user_id)
    log_event(
        db,
        event_name="store.access_checked",
        user_id=user.user_id,
        properties={"allowed": result["allowed"], "reason": result["reason"], "max_tier": result["max_tier"].value if result["max_tier"] else None},
    )
    db.commit()
    return StoreAccessResponse(allowed=result["allowed"], reason=result["reason"], max_tier=result["max_tier"])


@router.get("/store/products", response_model=StoreProductListResponse)
def store_products(
    category: str | None = None,
    brand: str | None = None,
    min_price: Decimal | None = Query(default=None, ge=Decimal("0")),
    max_price: Decimal | None = Query(default=None, ge=Decimal("0")),
    search: str | None = None,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreProductListResponse:
    access = can_access_pro_store(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    total, rows = list_store_products(
        db,
        category=category,
        brand=brand,
        min_price=min_price,
        max_price=max_price,
        search=search,
        limit=limit,
        offset=offset,
    )
    db.commit()
    return StoreProductListResponse(total=total, items=[StoreProductView.model_validate(row, from_attributes=True) for row in rows])


@router.get("/store/products/{product_id}", response_model=StoreProductView)
def store_product_detail(
    product_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreProductView:
    access = can_access_pro_store(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    product = db.get(Product, product_id)
    if not product or not product.is_available:
        raise APIError(code="not_found", message="Product not found", status_code=404)
    log_event(db, event_name="store.product_view", user_id=user.user_id, properties={"product_id": str(product.id)})
    db.commit()
    return StoreProductView.model_validate(product, from_attributes=True)


@router.post("/store/cart/items", response_model=StoreCartView)
def store_cart_add_item(
    body: CartAddItemRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreCartView:
    access = can_access_pro_store(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    product = db.get(Product, body.product_id)
    if not product or not product.is_available:
        raise APIError(code="not_found", message="Product not found", status_code=404)

    cart = get_or_create_cart(db, user.user_id)
    existing_rows = db.execute(
        select(CartItem, Product)
        .join(Product, Product.id == CartItem.product_id)
        .where(CartItem.cart_id == cart.id)
    ).all()
    existing_partner_ids = {row[1].partner_id for row in existing_rows}
    if existing_partner_ids and product.partner_id not in existing_partner_ids:
        raise APIError(code="validation_error", message="Cart cannot contain products from different partners", status_code=422)

    item = db.execute(
        select(CartItem).where(CartItem.cart_id == cart.id, CartItem.product_id == product.id)
    ).scalar_one_or_none()
    if not item:
        item = CartItem(cart_id=cart.id, product_id=product.id, quantity=body.quantity)
        db.add(item)
    else:
        item.quantity = body.quantity
    cart.updated_at = datetime.now(timezone.utc)
    log_event(db, event_name="store.cart_add", user_id=user.user_id, properties={"product_id": str(product.id), "quantity": body.quantity})
    db.commit()
    return _cart_response(db, cart)


@router.get("/store/cart", response_model=StoreCartView)
def store_cart(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreCartView:
    access = can_access_pro_store(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    cart = get_or_create_cart(db, user.user_id)
    db.commit()
    return _cart_response(db, cart)


@router.delete("/store/cart/items/{item_id}", response_model=StoreCartView)
def store_cart_delete_item(
    item_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreCartView:
    access = can_access_pro_store(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    cart = get_or_create_cart(db, user.user_id)
    item = db.execute(select(CartItem).where(CartItem.id == item_id, CartItem.cart_id == cart.id)).scalar_one_or_none()
    if not item:
        raise APIError(code="not_found", message="Cart item not found", status_code=404)
    db.delete(item)
    cart.updated_at = datetime.now(timezone.utc)
    db.commit()
    return _cart_response(db, cart)


@router.post("/store/checkout", response_model=StoreCheckoutResponse)
def store_checkout(
    body: StoreCheckoutRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreCheckoutResponse:
    order, payment, payment_intent_client_secret = create_order_from_cart(
        db,
        user_id=user.user_id,
        shipping_address=body.shipping_address.model_dump(),
        points_to_spend=body.points_to_spend,
    )
    db.commit()
    payload = order_view_payload(db, order)
    return StoreCheckoutResponse(
        order=_order_response(payload),
        payment_intent_client_secret=payment_intent_client_secret,
        payment_intent_id=payment.stripe_payment_intent_id,
    )


@router.get("/store/orders", response_model=StoreOrdersResponse)
def my_store_orders(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreOrdersResponse:
    access = can_access_pro_store(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    rows = db.execute(
        select(CommerceOrder).where(CommerceOrder.user_id == user.user_id).order_by(CommerceOrder.created_at.desc())
    ).scalars().all()
    items = [_order_response(order_view_payload(db, row)) for row in rows]
    db.commit()
    return StoreOrdersResponse(total=len(items), items=items)


@router.get("/store/orders/{order_id}", response_model=StoreOrderView)
def my_store_order_detail(
    order_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> StoreOrderView:
    order = db.get(CommerceOrder, order_id)
    if not order or order.user_id != user.user_id:
        raise APIError(code="not_found", message="Order not found", status_code=404)
    db.commit()
    return _order_response(order_view_payload(db, order))


@router.get("/admin/store/partners", response_model=list[AdminPartnerView])
def admin_store_partners(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[AdminPartnerView]:
    rows = db.execute(select(CommercePartner).order_by(CommercePartner.created_at.desc())).scalars().all()
    db.commit()
    return [AdminPartnerView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/admin/store/partners", response_model=AdminPartnerView)
def admin_store_partner_create(
    body: AdminPartnerRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminPartnerView:
    row = CommercePartner(
        name=body.name,
        country=body.country,
        api_type=body.api_type,
        api_config=body.api_config,
        is_active=body.is_active,
    )
    db.add(row)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="store_partner", target_id=str(row.id), action="create_store_partner", metadata={})
    db.commit()
    db.refresh(row)
    return AdminPartnerView.model_validate(row, from_attributes=True)


@router.put("/admin/store/partners/{partner_id}", response_model=AdminPartnerView)
def admin_store_partner_update(
    partner_id: uuid.UUID,
    body: AdminPartnerRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminPartnerView:
    row = db.get(CommercePartner, partner_id)
    if not row:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    row.name = body.name
    row.country = body.country
    row.api_type = body.api_type
    row.api_config = body.api_config
    row.is_active = body.is_active
    row.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="store_partner", target_id=str(row.id), action="update_store_partner", metadata={})
    db.commit()
    db.refresh(row)
    return AdminPartnerView.model_validate(row, from_attributes=True)


@router.post("/admin/store/partners/{partner_id}/sync")
def admin_store_partner_sync(
    partner_id: uuid.UUID,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> dict:
    row = db.get(CommercePartner, partner_id)
    if not row:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    sync_partner_products_task.delay(str(partner_id))
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="store_partner", target_id=str(partner_id), action="sync_store_partner_products", metadata={})
    db.commit()
    return {"ok": True}


@router.get("/admin/store/products", response_model=StoreProductListResponse)
def admin_store_products(
    partner_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StoreProductListResponse:
    stmt = select(Product)
    if partner_id:
        stmt = stmt.where(Product.partner_id == partner_id)
    rows = db.execute(stmt.order_by(Product.updated_at.desc())).scalars().all()
    db.commit()
    return StoreProductListResponse(total=len(rows), items=[StoreProductView.model_validate(row, from_attributes=True) for row in rows])


@router.post("/admin/store/products", response_model=StoreProductView)
def admin_store_product_create(
    body: AdminProductRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StoreProductView:
    if not db.get(CommercePartner, body.partner_id):
        raise APIError(code="validation_error", message="Partner not found", status_code=422)
    row = Product(
        partner_id=body.partner_id,
        partner_sku=body.partner_sku,
        title=body.title,
        description=body.description,
        category=body.category,
        brand=body.brand,
        images_media_asset_ids=[str(item) for item in body.images_media_asset_ids],
        attributes=body.attributes,
        currency=body.currency.upper(),
        msrp_price=body.msrp_price,
        partner_price=body.partner_price,
        is_available=body.is_available,
        stock_status=body.stock_status,
        shipping_estimate_days=body.shipping_estimate_days,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return StoreProductView.model_validate(row, from_attributes=True)


@router.put("/admin/store/products/{product_id}", response_model=StoreProductView)
def admin_store_product_update(
    product_id: uuid.UUID,
    body: AdminProductRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StoreProductView:
    row = db.get(Product, product_id)
    if not row:
        raise APIError(code="not_found", message="Product not found", status_code=404)
    row.partner_id = body.partner_id
    row.partner_sku = body.partner_sku
    row.title = body.title
    row.description = body.description
    row.category = body.category
    row.brand = body.brand
    row.images_media_asset_ids = [str(item) for item in body.images_media_asset_ids]
    row.attributes = body.attributes
    row.currency = body.currency.upper()
    row.msrp_price = body.msrp_price
    row.partner_price = body.partner_price
    row.is_available = body.is_available
    row.stock_status = body.stock_status
    row.shipping_estimate_days = body.shipping_estimate_days
    row.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(row)
    return StoreProductView.model_validate(row, from_attributes=True)


@router.get("/admin/store/price-rules", response_model=list[AdminPriceRuleView])
def admin_store_price_rules(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[AdminPriceRuleView]:
    rows = db.execute(select(PriceRule).order_by(PriceRule.created_at.desc())).scalars().all()
    db.commit()
    return [AdminPriceRuleView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/admin/store/price-rules", response_model=AdminPriceRuleView)
def admin_store_price_rule_create(
    body: AdminPriceRuleRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminPriceRuleView:
    row = PriceRule(**body.model_dump())
    db.add(row)
    db.commit()
    db.refresh(row)
    return AdminPriceRuleView.model_validate(row, from_attributes=True)


@router.put("/admin/store/price-rules/{rule_id}", response_model=AdminPriceRuleView)
def admin_store_price_rule_update(
    rule_id: uuid.UUID,
    body: AdminPriceRuleRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminPriceRuleView:
    row = db.get(PriceRule, rule_id)
    if not row:
        raise APIError(code="not_found", message="Rule not found", status_code=404)
    for field, value in body.model_dump().items():
        setattr(row, field, value)
    row.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(row)
    return AdminPriceRuleView.model_validate(row, from_attributes=True)


@router.put("/admin/store/policy", response_model=StorePolicyView)
def admin_store_policy_update(
    body: StorePolicyRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StorePolicyView:
    row = get_or_create_store_policy(db)
    row.min_tier_any_niche = body.min_tier_any_niche
    row.require_kyc_approved = body.require_kyc_approved
    row.require_not_banned = body.require_not_banned
    row.meta = body.metadata
    row.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(row)
    return StorePolicyView.model_validate(row, from_attributes=True)


@router.get("/admin/store/policy", response_model=StorePolicyView)
def admin_store_policy_get(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StorePolicyView:
    row = get_or_create_store_policy(db)
    db.commit()
    return StorePolicyView.model_validate(row, from_attributes=True)


@router.post("/admin/store/overrides/{pro_user_id}", response_model=StoreOverrideView)
def admin_store_override(
    pro_user_id: uuid.UUID,
    body: StoreOverrideRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StoreOverrideView:
    row = db.execute(select(StoreAccessOverride).where(StoreAccessOverride.pro_user_id == pro_user_id)).scalar_one_or_none()
    if not row:
        row = StoreAccessOverride(pro_user_id=pro_user_id, is_allowed=body.is_allowed, granted_by=actor.user_id)
        db.add(row)
        db.flush()
    row.is_allowed = body.is_allowed
    row.reason = body.reason
    row.expires_at = body.expires_at
    row.granted_by = actor.user_id
    row.granted_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="store_access_override",
        target_id=str(pro_user_id),
        action="store_access_override_upsert",
        reason=body.reason,
        metadata={"is_allowed": body.is_allowed, "expires_at": body.expires_at.isoformat() if body.expires_at else None},
    )
    db.commit()
    db.refresh(row)
    return StoreOverrideView.model_validate(row, from_attributes=True)


@router.post("/admin/store/orders/{order_id}/update-status", response_model=StoreOrderView)
def admin_store_order_update_status(
    order_id: uuid.UUID,
    body: AdminOrderStatusUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> StoreOrderView:
    if body.status not in {StoreOrderStatus.shipped, StoreOrderStatus.delivered, StoreOrderStatus.cancelled, StoreOrderStatus.refunded}:
        raise APIError(code="validation_error", message="Unsupported status", status_code=422)
    order = db.get(CommerceOrder, order_id)
    if not order:
        raise APIError(code="not_found", message="Order not found", status_code=404)
    old = order.status
    order.status = body.status
    if body.tracking:
        order.tracking = body.tracking
    order.updated_at = datetime.now(timezone.utc)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="store_order",
        target_id=str(order.id),
        action="store_order_status_update",
        reason=body.reason,
        metadata={"from_status": old.value, "to_status": order.status.value, "tracking": body.tracking},
    )
    if order.status == StoreOrderStatus.shipped:
        log_event(db, event_name="store.order_shipped", user_id=order.user_id, properties={"order_id": str(order.id)})
    elif order.status == StoreOrderStatus.delivered:
        log_event(db, event_name="store.order_delivered", user_id=order.user_id, properties={"order_id": str(order.id)})
    db.commit()
    return _order_response(order_view_payload(db, order))


def _cart_response(db: Session, cart) -> StoreCartView:
    rows = db.execute(
        select(CartItem, Product)
        .join(Product, Product.id == CartItem.product_id)
        .where(CartItem.cart_id == cart.id)
        .order_by(CartItem.created_at.asc())
    ).all()
    items: list[StoreCartItemView] = []
    subtotal = Decimal("0.00")
    partner_id = None
    for item, product in rows:
        line_subtotal = (Decimal(product.partner_price) * item.quantity).quantize(Decimal("0.01"))
        subtotal += line_subtotal
        partner_id = partner_id or product.partner_id
        items.append(
            StoreCartItemView(
                id=item.id,
                product_id=item.product_id,
                quantity=item.quantity,
                product=StoreProductView.model_validate(product, from_attributes=True),
                line_subtotal=line_subtotal,
            )
        )
    return StoreCartView(
        cart_id=cart.id,
        currency=cart.currency,
        partner_id=partner_id,
        subtotal=subtotal.quantize(Decimal("0.01")),
        items=items,
        updated_at=cart.updated_at,
    )


def _order_response(payload: dict) -> StoreOrderView:
    order = payload["order"]
    items = [OrderItemView.model_validate(item, from_attributes=True) for item in payload["items"]]
    payment = OrderPaymentView.model_validate(payload["payment"], from_attributes=True) if payload["payment"] else None
    return StoreOrderView(
        id=order.id,
        user_id=order.user_id,
        partner_id=order.partner_id,
        status=order.status,
        currency=order.currency,
        subtotal=order.subtotal,
        discounts_total=order.discounts_total,
        points_spent=order.points_spent,
        total=order.total,
        shipping_address=order.shipping_address,
        partner_order_id=order.partner_order_id,
        tracking=order.tracking or {},
        created_at=order.created_at,
        updated_at=order.updated_at,
        items=items,
        payment=payment,
    )
