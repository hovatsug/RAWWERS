"""Orders on The Shelf.

Placing an order is one transaction under the photographer's balance lock,
so the checks and the spend cannot be split by a second tap or a second
order: The Shelf is open; they may use it (KYC approved, not banned - the
route checks that - and no reward freeze); the item is shown, in stock,
within their level and fits their gear; they have the RAWW, spendable
(price and RAWW value copied onto the order); one item per order, at most
`max_orders_per_month` a month, not the same item within
`same_item_cooldown_days`; it ships to an allowed country; and the same
`client_request_id` twice is the same order.

Statuses: placed -> ordered (supplier ref) -> shipped (tracking) ->
delivered; or cancelled -> refunded. The photographer can cancel while
placed; an admin before shipped, with a reason, and out_of_stock also marks
the item out of stock. A cancel gives every RAWW back at once. After
shipped there is no cancel: a return is a manual admin adjustment. Every
change is logged (ShelfOrderEvent) and sends the photographer an in-app
notification.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile
from app.models.prints import ShippingAddress
from app.models.risk import RiskActionType
from app.models.shelf import (
    RawwEntryKind,
    ShelfItem,
    ShelfOrder,
    ShelfOrderEvent,
    ShelfOrderStatus,
    ShelfProAddress,
    ShelfStockStatus,
)
from app.services import addresses
from app.services import raww_ledger as ledger
from app.services.notifications import enqueue_notification
from app.services.shelf_browse import can_see
from app.services.shelf_settings import shelf_open, shelf_settings
from app.services.trust_safety import has_active_risk_action

#: Orders that still count against the monthly cap and the cooldown.
_LIVE = (ShelfOrderStatus.placed, ShelfOrderStatus.ordered, ShelfOrderStatus.shipped, ShelfOrderStatus.delivered)

#: Where each status may go next, and who may move it there.
_NEXT = {
    ShelfOrderStatus.placed: {ShelfOrderStatus.ordered, ShelfOrderStatus.cancelled},
    ShelfOrderStatus.ordered: {ShelfOrderStatus.shipped, ShelfOrderStatus.cancelled},
    ShelfOrderStatus.shipped: {ShelfOrderStatus.delivered},
}

#: Where an order notification opens in the pro app (an app path: links
#: that do not start with "/" are dropped from notifications).
MY_ORDERS_PATH = "/wallet/shelf/orders"

ADMIN_CANCEL_REASONS = ("out_of_stock", "supplier_problem", "address_problem", "photographer_asked", "other")

_MESSAGES = {
    ShelfOrderStatus.placed: ("Order placed", "{title}: we will order it for you and let you know when it ships."),
    ShelfOrderStatus.ordered: ("Ordered from the supplier", "{title} is on order."),
    ShelfOrderStatus.shipped: ("On its way", "{title} has shipped."),
    ShelfOrderStatus.delivered: ("Delivered", "{title} was delivered."),
    ShelfOrderStatus.cancelled: ("Order cancelled", "{title} was cancelled."),
    ShelfOrderStatus.refunded: ("RAWW back", "{price} RAWW for {title} are back in your balance."),
}


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _refuse(code: str, message: str, status: int = 409) -> APIError:
    return APIError(code=code, message=message, status_code=status)


# --- the saved address ---------------------------------------------------------------------


def saved_address(db: Session, pro_user_id: uuid.UUID) -> tuple[ShippingAddress, dict] | None:
    link = db.get(ShelfProAddress, pro_user_id)
    row = db.get(ShippingAddress, link.shipping_address_id) if link else None
    fields = addresses.decrypt(row.encrypted_fields) if row else None
    return (row, fields) if row is not None and fields else None


def save_address(db: Session, *, pro_user_id: uuid.UUID, fields: dict) -> dict:
    addresses.refuse_client_encrypted(fields)
    link = db.get(ShelfProAddress, pro_user_id)
    row = addresses.save(
        db,
        user_id=pro_user_id,
        fields=fields,
        allowed_countries=shelf_settings(db).allowed_countries,
        address_id=link.shipping_address_id if link else None,
    )
    if link is None:
        db.add(ShelfProAddress(pro_user_id=pro_user_id, shipping_address_id=row.id))
        db.flush()
    return addresses.decrypt(row.encrypted_fields) or {}


# --- placing --------------------------------------------------------------------------------


def _month_start(now: datetime) -> datetime:
    return now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)


def month_resets_at(now: datetime) -> datetime:
    """When the monthly cap starts again: the first of next month, 00:00 UTC
    (owner's decision, 2026-11-03: the month is the UTC calendar month)."""
    start = _month_start(now.astimezone(timezone.utc))
    return start.replace(year=start.year + 1, month=1) if start.month == 12 else start.replace(month=start.month + 1)


def orders_this_month(db: Session, pro_user_id: uuid.UUID, now: datetime | None = None) -> int:
    """The orders counting against this month's cap: cancelled ones do not."""
    return db.execute(
        select(func.count()).select_from(ShelfOrder).where(
            ShelfOrder.pro_user_id == pro_user_id,
            ShelfOrder.status.in_(_LIVE),
            ShelfOrder.placed_at >= _month_start((now or _now()).astimezone(timezone.utc)),
        )
    ).scalar_one()


def cost_snapshot(item: ShelfItem, settings) -> dict:
    """The item's cost and the euros per unit of its currency, to record on
    an order. No cost, or a currency without a rate: the cost is not set."""
    cost = item.supplier_cost if item.supplier_cost and item.supplier_cost > 0 else None
    currency = (item.supplier_currency or "").upper() or None
    rate = Decimal("1") if currency == "EUR" else settings.gbp_eur_rate if currency == "GBP" else None
    return {"supplier_cost": cost, "supplier_currency": currency, "cost_eur_rate": rate if cost is not None else None}


def place_order(db: Session, *, pro_user_id: uuid.UUID, item_id: uuid.UUID, client_request_id: str) -> ShelfOrder:
    request_id = (client_request_id or "").strip()
    if not request_id or len(request_id) > 100:
        raise APIError(code="validation_error", message="A request id is required", status_code=422)
    if not shelf_open(db):
        raise _refuse("shelf_closed", "The Shelf is not open yet.", 403)

    # Everything below under the photographer's lock.
    balance = ledger.balance_locked(db, pro_user_id)
    existing = db.execute(
        select(ShelfOrder).where(ShelfOrder.pro_user_id == pro_user_id, ShelfOrder.client_request_id == request_id)
    ).scalar_one_or_none()
    if existing:
        return existing

    profile = db.get(ProProfile, pro_user_id)
    if profile is None or profile.kyc_status != KYCStatus.approved:
        raise _refuse("kyc_required", "Finish verifying your identity before ordering from The Shelf.", 403)
    if has_active_risk_action(db, user_id=pro_user_id, action_type=RiskActionType.freeze_rewards):
        raise _refuse("raww_frozen", "Your RAWW are on hold. Contact RAWWERS support.", 403)

    item = db.get(ShelfItem, item_id)
    if item is None or not can_see(db, pro_user_id, item):
        raise _refuse("not_found", "Item not found", 404)
    if item.stock_status != ShelfStockStatus.in_stock:
        raise _refuse("out_of_stock", "That item is out of stock.")

    settings = shelf_settings(db)
    now = _now()
    if orders_this_month(db, pro_user_id, now) >= settings.max_orders_per_month:
        raise _refuse("monthly_limit", f"You can order {settings.max_orders_per_month} items a month. More next month.")
    if settings.same_item_cooldown_days:
        recent = db.execute(
            select(ShelfOrder.placed_at).where(
                ShelfOrder.pro_user_id == pro_user_id,
                ShelfOrder.item_id == item.id,
                ShelfOrder.status.in_(_LIVE),
                ShelfOrder.placed_at > now - timedelta(days=settings.same_item_cooldown_days),
            )
        ).scalars().first()
        if recent is not None:
            raise _refuse("same_item_cooldown", f"You ordered this in the last {settings.same_item_cooldown_days} days.")

    saved = saved_address(db, pro_user_id)
    if saved is None:
        raise _refuse("address_required", "Add the address to ship to first.", 422)
    _, fields = saved
    if fields["country"] not in settings.allowed_countries:
        raise _refuse("country_not_allowed", f"The Shelf ships to {', '.join(settings.allowed_countries)} only for now.", 422)

    if balance.spendable < item.price_raww:
        raise _refuse(
            "insufficient_raww",
            f"You have {max(balance.spendable, 0)} RAWW to spend; this needs {item.price_raww}.",
        )

    order = ShelfOrder(
        pro_user_id=pro_user_id,
        item_id=item.id,
        client_request_id=request_id,
        title=item.title,
        supplier_name=item.supplier_name,
        supplier_sku=item.supplier_sku,
        level=item.level,
        price_raww=item.price_raww,
        raww_eur_value=settings.raww_eur_value,
        # What it costs us, as it stands now (docs/BI.md, the Shelf margin).
        **cost_snapshot(item, settings),
        status=ShelfOrderStatus.placed,
        shipping_address=addresses.encrypt(fields),
        country=fields["country"],
        placed_at=now,
    )
    db.add(order)
    db.flush()
    ledger.spend(db, pro_user_id=pro_user_id, amount=item.price_raww, source_type="shelf_order", source_id=str(order.id), meta={"item_id": str(item.id)})
    _event(db, order, None, ShelfOrderStatus.placed, actor_type="pro", actor_user_id=pro_user_id)
    return order


# --- moving it along ------------------------------------------------------------------------


def _event(db: Session, order: ShelfOrder, before: ShelfOrderStatus | None, after: ShelfOrderStatus, *, actor_type: str, actor_user_id, note: str | None = None) -> None:
    db.add(
        ShelfOrderEvent(
            order_id=order.id,
            from_status=before.value if before else None,
            to_status=after.value,
            actor_type=actor_type,
            actor_user_id=actor_user_id,
            note=note,
            created_at=_now(),
        )
    )
    title, body = _MESSAGES[after]
    enqueue_notification(
        db,
        user_id=order.pro_user_id,
        notification_type=f"shelf.order_{after.value}",
        payload={
            "title": title,
            "body": body.format(title=order.title, price=order.price_raww),
            "action": {"label": "My orders", "url": MY_ORDERS_PATH},
            "item": order.title,
            **({"tracking_code": order.tracking_code, "tracking_url": order.tracking_url} if after == ShelfOrderStatus.shipped else {}),
        },
        reference_type="shelf_order",
        reference_id=str(order.id),
        dedupe_key=f"shelf-order:{order.id}:{after.value}",
    )
    db.flush()


def _move(db: Session, order: ShelfOrder, to: ShelfOrderStatus, *, actor_type: str, actor_user_id, note: str | None = None) -> None:
    if to not in _NEXT.get(order.status, set()):
        raise _refuse("invalid_state", f"A {order.status.value} order cannot be {to.value}.")
    before = order.status
    order.status = to
    setattr(order, f"{to.value}_at", _now())
    _event(db, order, before, to, actor_type=actor_type, actor_user_id=actor_user_id, note=note)


def _order_locked(db: Session, order_id: uuid.UUID) -> ShelfOrder:
    order = db.execute(select(ShelfOrder).where(ShelfOrder.id == order_id).with_for_update()).scalar_one_or_none()
    if order is None:
        raise _refuse("not_found", "Order not found", 404)
    return order


def _cancel_and_refund(db: Session, order: ShelfOrder, *, actor_type: str, actor_user_id, reason: str) -> None:
    _move(db, order, ShelfOrderStatus.cancelled, actor_type=actor_type, actor_user_id=actor_user_id, note=reason)
    order.cancel_reason = reason
    ledger.post_entry(
        db,
        pro_user_id=order.pro_user_id,
        kind=RawwEntryKind.refund_order,
        amount=order.price_raww,
        source_type="shelf_order",
        source_id=str(order.id),
        note=reason,
        actor_user_id=actor_user_id if actor_type == "admin" else None,
    )
    order.status = ShelfOrderStatus.refunded
    order.refunded_at = _now()
    _event(db, order, ShelfOrderStatus.cancelled, ShelfOrderStatus.refunded, actor_type="system", actor_user_id=None)


def cancel_by_pro(db: Session, *, pro_user_id: uuid.UUID, order_id: uuid.UUID) -> ShelfOrder:
    order = _order_locked(db, order_id)
    if order.pro_user_id != pro_user_id:
        raise _refuse("not_found", "Order not found", 404)
    if order.status != ShelfOrderStatus.placed:
        raise _refuse("invalid_state", "This order is already with the supplier. Ask RAWWERS support to cancel it.")
    _cancel_and_refund(db, order, actor_type="pro", actor_user_id=pro_user_id, reason="photographer_cancelled")
    return order


def admin_mark_ordered(db: Session, *, order_id: uuid.UUID, supplier_order_ref: str, admin_user_id: uuid.UUID) -> ShelfOrder:
    ref = (supplier_order_ref or "").strip()
    if not ref:
        raise APIError(code="validation_error", message="The supplier's order reference is required", status_code=422)
    order = _order_locked(db, order_id)
    _move(db, order, ShelfOrderStatus.ordered, actor_type="admin", actor_user_id=admin_user_id, note=ref)
    order.supplier_order_ref = ref
    return order


def _shipping(value: Decimal | None) -> Decimal | None:
    if value is None:
        return None
    value = Decimal(value).quantize(Decimal("0.01"))
    if value < 0 or value > Decimal("10000"):
        raise APIError(code="validation_error", message="Shipping is between 0 and 10000 euros", status_code=422)
    return value


def admin_mark_shipped(db: Session, *, order_id: uuid.UUID, tracking_code: str, tracking_url: str | None, admin_user_id: uuid.UUID,
                       shipping_cost_eur: Decimal | None = None) -> ShelfOrder:
    code = (tracking_code or "").strip()
    if not code:
        raise APIError(code="validation_error", message="The tracking code is required", status_code=422)
    shipping = _shipping(shipping_cost_eur)
    order = _order_locked(db, order_id)
    # Before the move, so its notification (and email) carries the tracking.
    order.tracking_code = code
    order.tracking_url = (tracking_url or "").strip() or None
    if shipping is not None:
        order.shipping_cost_eur = shipping
    _move(db, order, ShelfOrderStatus.shipped, actor_type="admin", actor_user_id=admin_user_id, note=code)
    return order


def admin_set_shipping(db: Session, *, order_id: uuid.UUID, shipping_cost_eur: Decimal | None) -> tuple[ShelfOrder, Decimal | None]:
    """What shipping this order cost us, in euros (null clears it). Any
    time: the invoice can come after the parcel. Returns the order and the
    value before."""
    shipping = _shipping(shipping_cost_eur)
    order = _order_locked(db, order_id)
    before = order.shipping_cost_eur
    order.shipping_cost_eur = shipping
    return order, before


def admin_mark_delivered(db: Session, *, order_id: uuid.UUID, admin_user_id: uuid.UUID) -> ShelfOrder:
    order = _order_locked(db, order_id)
    _move(db, order, ShelfOrderStatus.delivered, actor_type="admin", actor_user_id=admin_user_id)
    return order


def admin_cancel(db: Session, *, order_id: uuid.UUID, reason: str, note: str | None, admin_user_id: uuid.UUID) -> ShelfOrder:
    if reason not in ADMIN_CANCEL_REASONS:
        raise APIError(code="validation_error", message="Give a reason: " + ", ".join(ADMIN_CANCEL_REASONS), status_code=422)
    order = _order_locked(db, order_id)
    if order.status not in (ShelfOrderStatus.placed, ShelfOrderStatus.ordered):
        raise _refuse("invalid_state", "Shipped orders cannot be cancelled; a return is a RAWW adjustment.")
    detail = f"{reason}: {note.strip()}" if note and note.strip() else reason
    _cancel_and_refund(db, order, actor_type="admin", actor_user_id=admin_user_id, reason=detail)
    if reason == "out_of_stock":
        item = db.get(ShelfItem, order.item_id)
        if item is not None:
            item.stock_status = ShelfStockStatus.out_of_stock
    return order


def order_address(order: ShelfOrder) -> dict | None:
    return addresses.decrypt(order.shipping_address)
