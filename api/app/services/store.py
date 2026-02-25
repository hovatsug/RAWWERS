from __future__ import annotations

import csv
import io
import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Any

import requests
import stripe
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile, UserRoleType
from app.models.commerce import (
    Cart,
    CartItem,
    CommerceOrder,
    CommercePartner,
    OrderItem,
    OrderPayment,
    PartnerAPIType,
    PriceRule,
    PriceRuleAppliesTo,
    PriceRuleDiscountType,
    Product,
    ProductStockStatus,
    StoreAccessOverride,
    StoreAccessPolicy,
    StoreOrderPaymentStatus,
    StoreOrderStatus,
)
from app.models.niche import ProNicheSkill, SkillTier
from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType
from app.services.analytics import log_event
from app.services.authz import enforce_not_banned, get_user_roles
from app.services.rewards import apply_redemption_for_context, release_redemption_for_context, reserve_points_for_discount
from app.services.stripe_service import to_cents

settings = get_settings()

TIER_RANK: dict[SkillTier, int] = {
    SkillTier.rookie: 0,
    SkillTier.skilled: 1,
    SkillTier.pro: 2,
    SkillTier.elite: 3,
    SkillTier.master: 4,
}


def get_or_create_store_policy(db: Session) -> StoreAccessPolicy:
    policy = db.execute(select(StoreAccessPolicy).limit(1)).scalar_one_or_none()
    if policy:
        return policy
    policy = StoreAccessPolicy(
        min_tier_any_niche=SkillTier.skilled,
        require_kyc_approved=True,
        require_not_banned=True,
        meta={},
    )
    db.add(policy)
    db.flush()
    return policy


def get_best_niche_tier(db: Session, user_id: uuid.UUID) -> SkillTier | None:
    rows = db.execute(select(ProNicheSkill.tier).where(ProNicheSkill.pro_user_id == user_id)).scalars().all()
    if not rows:
        return None
    return max(rows, key=lambda tier: TIER_RANK.get(tier, -1))


def can_access_pro_store(db: Session, user_id: uuid.UUID) -> dict[str, Any]:
    now = datetime.now(timezone.utc)
    override = db.execute(select(StoreAccessOverride).where(StoreAccessOverride.pro_user_id == user_id)).scalar_one_or_none()
    if override and (override.expires_at is None or override.expires_at > now):
        if override.is_allowed:
            max_tier = get_best_niche_tier(db, user_id)
            return {"allowed": True, "reason": "override_allowed", "max_tier": max_tier}
        return {"allowed": False, "reason": "override_blocked", "max_tier": None}

    roles = get_user_roles(db, user_id)
    if UserRoleType.pro not in roles:
        return {"allowed": False, "reason": "pro_role_required", "max_tier": None}

    policy = get_or_create_store_policy(db)
    if policy.require_not_banned:
        try:
            enforce_not_banned(db, user_id)
        except APIError:
            return {"allowed": False, "reason": "banned_or_suspended", "max_tier": None}
    if policy.require_kyc_approved:
        profile = db.get(ProProfile, user_id)
        if not profile or profile.kyc_status != KYCStatus.approved:
            return {"allowed": False, "reason": "kyc_required", "max_tier": None}

    max_tier = get_best_niche_tier(db, user_id)
    if not max_tier or TIER_RANK[max_tier] < TIER_RANK[policy.min_tier_any_niche]:
        return {"allowed": False, "reason": "tier_below_policy", "max_tier": max_tier}
    return {"allowed": True, "reason": "eligible", "max_tier": max_tier}


def get_or_create_cart(db: Session, user_id: uuid.UUID) -> Cart:
    cart = db.execute(select(Cart).where(Cart.user_id == user_id)).scalar_one_or_none()
    if cart:
        return cart
    cart = Cart(user_id=user_id, currency="EUR")
    db.add(cart)
    db.flush()
    return cart


def _clean_text(value: str | None) -> str | None:
    if value is None:
        return None
    cleaned = " ".join(value.strip().split())
    return cleaned or None


def sanitize_shipping_address(payload: dict[str, Any]) -> dict[str, Any]:
    cleaned: dict[str, Any] = {}
    for key in ["name", "line1", "line2", "city", "region", "postal_code", "country", "phone"]:
        if key in payload:
            cleaned[key] = _clean_text(str(payload[key])) if payload[key] is not None else None
    cleaned["country"] = (cleaned.get("country") or "").upper()
    return cleaned


def list_store_products(
    db: Session,
    *,
    category: str | None = None,
    brand: str | None = None,
    min_price: Decimal | None = None,
    max_price: Decimal | None = None,
    search: str | None = None,
    limit: int = 20,
    offset: int = 0,
) -> tuple[int, list[Product]]:
    stmt = select(Product).join(CommercePartner, CommercePartner.id == Product.partner_id).where(
        Product.is_available.is_(True),
        CommercePartner.is_active.is_(True),
    )
    if category:
        stmt = stmt.where(Product.category == category)
    if brand:
        stmt = stmt.where(Product.brand == brand)
    if min_price is not None:
        stmt = stmt.where(Product.partner_price >= min_price)
    if max_price is not None:
        stmt = stmt.where(Product.partner_price <= max_price)
    if search:
        pattern = f"%{search}%"
        stmt = stmt.where(or_(Product.title.ilike(pattern), Product.description.ilike(pattern), Product.brand.ilike(pattern)))

    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(stmt.order_by(Product.updated_at.desc()).offset(offset).limit(limit)).scalars().all()
    return total, rows


def compute_price_rule_discount(
    db: Session,
    product: Product,
    *,
    user_tier: SkillTier | None,
) -> Decimal:
    rules = db.execute(
        select(PriceRule).where(
            PriceRule.is_active.is_(True),
            or_(PriceRule.partner_id.is_(None), PriceRule.partner_id == product.partner_id),
        )
    ).scalars().all()
    applicable: list[Decimal] = []
    for rule in rules:
        tier = user_tier or SkillTier.rookie
        if TIER_RANK[tier] < TIER_RANK[rule.min_tier]:
            continue
        if rule.applies_to == PriceRuleAppliesTo.all:
            matched = True
        elif rule.applies_to == PriceRuleAppliesTo.category:
            matched = bool(product.category and rule.match_value and product.category == rule.match_value)
        elif rule.applies_to == PriceRuleAppliesTo.brand:
            matched = bool(product.brand and rule.match_value and product.brand == rule.match_value)
        else:
            matched = bool(rule.match_value and product.partner_sku == rule.match_value)
        if not matched:
            continue
        if rule.discount_type == PriceRuleDiscountType.percent:
            discount = (product.partner_price * rule.discount_value / Decimal("100")).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        else:
            discount = Decimal(rule.discount_value).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        applicable.append(max(Decimal("0.00"), min(discount, product.partner_price)))
    return max(applicable, default=Decimal("0.00"))


def create_order_from_cart(
    db: Session,
    *,
    user_id: uuid.UUID,
    shipping_address: dict[str, Any],
    points_to_spend: int | None = None,
) -> tuple[CommerceOrder, OrderPayment, str | None]:
    access = can_access_pro_store(db, user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Store access denied: {access['reason']}", status_code=403)
    user_tier = access["max_tier"]

    cart = get_or_create_cart(db, user_id)
    cart_rows = db.execute(
        select(CartItem, Product)
        .join(Product, Product.id == CartItem.product_id)
        .where(CartItem.cart_id == cart.id)
    ).all()
    if not cart_rows:
        raise APIError(code="validation_error", message="Cart is empty", status_code=422)

    partner_ids = {row[1].partner_id for row in cart_rows}
    if len(partner_ids) != 1:
        raise APIError(code="validation_error", message="Cart must contain products from a single partner", status_code=422)
    partner_id = next(iter(partner_ids))

    subtotal = Decimal("0.00")
    discounts_total = Decimal("0.00")
    item_payloads: list[dict[str, Any]] = []
    for cart_item, product in cart_rows:
        if not product.is_available:
            raise APIError(code="validation_error", message=f"Product unavailable: {product.title}", status_code=422)
        if product.stock_status == ProductStockStatus.out_of_stock:
            raise APIError(code="validation_error", message=f"Product out of stock: {product.title}", status_code=422)
        unit_price = Decimal(product.partner_price).quantize(Decimal("0.01"))
        per_unit_discount = compute_price_rule_discount(db, product, user_tier=user_tier)
        final_unit_price = max(Decimal("0.00"), unit_price - per_unit_discount).quantize(Decimal("0.01"))
        line_subtotal = (unit_price * cart_item.quantity).quantize(Decimal("0.01"))
        line_discount = (per_unit_discount * cart_item.quantity).quantize(Decimal("0.01"))
        subtotal += line_subtotal
        discounts_total += line_discount
        item_payloads.append(
            {
                "product_id": product.id,
                "title_snapshot": product.title,
                "sku_snapshot": product.partner_sku,
                "unit_price": unit_price,
                "discount_amount": per_unit_discount,
                "final_unit_price": final_unit_price,
                "quantity": cart_item.quantity,
            }
        )

    pre_points_total = max(Decimal("0.01"), (subtotal - discounts_total).quantize(Decimal("0.01")))
    order = CommerceOrder(
        user_id=user_id,
        partner_id=partner_id,
        status=StoreOrderStatus.created,
        currency="EUR",
        subtotal=subtotal,
        discounts_total=discounts_total,
        points_spent=0,
        total=pre_points_total,
        shipping_address=sanitize_shipping_address(shipping_address),
        tracking={},
    )
    db.add(order)
    db.flush()

    points_discount = Decimal("0.00")
    points_spent = 0
    if points_to_spend:
        redemption = reserve_points_for_discount(
            db,
            user_id=user_id,
            context_type=RedemptionContextType.commerce_order,
            context_id=order.id,
            points=points_to_spend,
            payment_amount=pre_points_total,
            currency="EUR",
            metadata={"source": "store_checkout"},
        )
        points_discount = redemption.discount_amount
        points_spent = redemption.points_spent

    total = max(Decimal("0.01"), (pre_points_total - points_discount).quantize(Decimal("0.01")))
    order.discounts_total = (discounts_total + points_discount).quantize(Decimal("0.01"))
    order.points_spent = points_spent
    order.total = total
    order.status = StoreOrderStatus.payment_pending

    for item in item_payloads:
        db.add(
            OrderItem(
                order_id=order.id,
                product_id=item["product_id"],
                title_snapshot=item["title_snapshot"],
                sku_snapshot=item["sku_snapshot"],
                unit_price=item["unit_price"],
                discount_amount=item["discount_amount"],
                final_unit_price=item["final_unit_price"],
                quantity=item["quantity"],
            )
        )

    for cart_item, _ in cart_rows:
        db.delete(cart_item)
    cart.updated_at = datetime.now(timezone.utc)
    db.flush()

    payment_intent_client_secret = None
    payment_intent_id = None
    payment = db.execute(select(OrderPayment).where(OrderPayment.order_id == order.id)).scalar_one_or_none()
    if not payment:
        pi = stripe.PaymentIntent.create(
            amount=to_cents(order.total),
            currency=order.currency.lower(),
            payment_method_types=["card"],
            metadata={"order_id": str(order.id), "user_id": str(order.user_id), "scope": "commerce_order"},
            automatic_payment_methods={"enabled": True},
            idempotency_key=f"store-order:{order.id}:pi",
        )
        payment = OrderPayment(
            order_id=order.id,
            stripe_payment_intent_id=pi.id,
            status=StoreOrderPaymentStatus.pending,
        )
        db.add(payment)
        payment_intent_client_secret = pi.client_secret
        payment_intent_id = pi.id
    db.flush()
    log_event(
        db,
        event_name="store.checkout_started",
        user_id=user_id,
        properties={"order_id": str(order.id), "partner_id": str(order.partner_id), "subtotal": str(order.subtotal), "total": str(order.total)},
    )
    return order, payment, payment_intent_client_secret or payment_intent_id


def order_view_payload(db: Session, order: CommerceOrder) -> dict[str, Any]:
    items = db.execute(select(OrderItem).where(OrderItem.order_id == order.id).order_by(OrderItem.created_at.asc())).scalars().all()
    payment = db.execute(select(OrderPayment).where(OrderPayment.order_id == order.id)).scalar_one_or_none()
    return {"order": order, "items": items, "payment": payment}


def sync_partner_products(db: Session, partner_id: uuid.UUID) -> int:
    partner = db.get(CommercePartner, partner_id)
    if not partner:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    if partner.api_type == PartnerAPIType.manual:
        return 0
    if partner.api_type == PartnerAPIType.api:
        return 0

    feed_url = (partner.api_config or {}).get("feed_url")
    if not feed_url:
        raise APIError(code="validation_error", message="feed_url missing in partner api_config", status_code=422)
    response = requests.get(feed_url, timeout=20)
    response.raise_for_status()
    content_type = (response.headers.get("content-type") or "").lower()

    entries: list[dict[str, Any]]
    if "json" in content_type or str(feed_url).lower().endswith(".json"):
        data = response.json()
        entries = data if isinstance(data, list) else data.get("items", [])
    else:
        reader = csv.DictReader(io.StringIO(response.text))
        entries = [dict(row) for row in reader]

    seen_skus: set[str] = set()
    upserted = 0
    for row in entries:
        sku = str(row.get("partner_sku") or "").strip()
        title = str(row.get("title") or "").strip()
        if not sku or not title:
            continue
        seen_skus.add(sku)
        product = db.execute(select(Product).where(Product.partner_id == partner_id, Product.partner_sku == sku)).scalar_one_or_none()
        if not product:
            product = Product(partner_id=partner_id, partner_sku=sku, title=title, partner_price=Decimal("0.00"))
            db.add(product)
            db.flush()

        product.title = title
        product.description = row.get("description")
        product.category = row.get("category")
        product.brand = row.get("brand")
        product.currency = str(row.get("currency") or "EUR").upper()
        product.partner_price = Decimal(str(row.get("partner_price") or "0")).quantize(Decimal("0.01"))
        msrp = row.get("msrp_price")
        product.msrp_price = Decimal(str(msrp)).quantize(Decimal("0.01")) if msrp not in {None, ""} else None
        stock_raw = str(row.get("stock_status") or ProductStockStatus.unknown.value)
        try:
            product.stock_status = ProductStockStatus(stock_raw)
        except ValueError:
            product.stock_status = ProductStockStatus.unknown
        product.shipping_estimate_days = int(row.get("shipping_estimate_days")) if row.get("shipping_estimate_days") not in {None, ""} else None
        images = row.get("images_media_asset_ids") or []
        product.images_media_asset_ids = images if isinstance(images, list) else []
        attrs = row.get("attributes") or {}
        product.attributes = attrs if isinstance(attrs, dict) else {}
        product.is_available = bool(row.get("is_available", True))
        product.updated_at = datetime.now(timezone.utc)
        upserted += 1

    if bool((partner.api_config or {}).get("disable_missing", False)):
        rows = db.execute(select(Product).where(Product.partner_id == partner_id)).scalars().all()
        for product in rows:
            if product.partner_sku not in seen_skus:
                product.is_available = False
                product.updated_at = datetime.now(timezone.utc)

    db.flush()
    return upserted


def finalize_order_payment_success(db: Session, payment_intent_id: str) -> CommerceOrder | None:
    payment = db.execute(select(OrderPayment).where(OrderPayment.stripe_payment_intent_id == payment_intent_id)).scalar_one_or_none()
    if not payment:
        return None
    order = db.get(CommerceOrder, payment.order_id)
    if not order:
        return None

    if payment.status != StoreOrderPaymentStatus.succeeded:
        payment.status = StoreOrderPaymentStatus.succeeded
        payment.updated_at = datetime.now(timezone.utc)
    if order.status not in {StoreOrderStatus.paid, StoreOrderStatus.submitted_to_partner, StoreOrderStatus.shipped, StoreOrderStatus.delivered}:
        order.status = StoreOrderStatus.paid
        order.updated_at = datetime.now(timezone.utc)
        apply_redemption_for_context(db, RedemptionContextType.commerce_order, order.id)
        log_event(db, event_name="store.order_paid", user_id=order.user_id, properties={"order_id": str(order.id)})
    db.flush()
    return order


def handle_order_payment_failure(db: Session, payment_intent_id: str, *, cancelled: bool) -> CommerceOrder | None:
    payment = db.execute(select(OrderPayment).where(OrderPayment.stripe_payment_intent_id == payment_intent_id)).scalar_one_or_none()
    if not payment:
        return None
    order = db.get(CommerceOrder, payment.order_id)
    if not order:
        return None
    payment.status = StoreOrderPaymentStatus.cancelled if cancelled else StoreOrderPaymentStatus.failed
    payment.updated_at = datetime.now(timezone.utc)
    release_redemption_for_context(
        db,
        RedemptionContextType.commerce_order,
        order.id,
        reason="payment_intent_cancelled" if cancelled else "payment_intent_failed",
    )
    db.flush()
    return order


def submit_order_to_partner(db: Session, order_id: uuid.UUID) -> CommerceOrder:
    order = db.get(CommerceOrder, order_id)
    if not order:
        raise APIError(code="not_found", message="Order not found", status_code=404)
    partner = db.get(CommercePartner, order.partner_id)
    if not partner:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    if order.status != StoreOrderStatus.paid:
        return order

    if partner.api_type in {PartnerAPIType.manual, PartnerAPIType.feed_url}:
        order.status = StoreOrderStatus.submitted_to_partner
        order.partner_order_id = order.partner_order_id or f"MANUAL-{order.id.hex[:12].upper()}"
    else:
        order.status = StoreOrderStatus.submitted_to_partner
        order.partner_order_id = order.partner_order_id or f"API-{order.id.hex[:12].upper()}"
    order.updated_at = datetime.now(timezone.utc)
    log_event(
        db,
        event_name="store.order_submitted",
        user_id=order.user_id,
        properties={"order_id": str(order.id), "partner_id": str(order.partner_id)},
    )
    db.flush()
    return order
