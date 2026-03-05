from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.prints import PrintEventActorType, PrintOrder, PrintOrderStatus
from app.schemas.media import CurrentUser
from app.schemas.prints import (
    AdminPrintOrderDetailResponse,
    AdminPrintOrderSetStatusRequest,
    AdminPrintOrderSetTrackingRequest,
    PrintEventView,
    PrintOrderCreateRequest,
    PrintOrderDetailResponse,
    PrintOrderPayResponse,
    PrintOrderItemView,
    PrintOrderUpdateRequest,
    PrintOrderView,
    PrintPartnerUpsertRequest,
    PrintPartnerView,
    PrintProductUpsertRequest,
    PrintProductView,
)
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.prints_fulfillment import (
    admin_set_print_order_status,
    admin_set_print_tracking,
    create_print_order,
    create_print_payment_intent,
    ensure_default_print_catalog,
    get_my_print_order,
    list_admin_print_orders,
    list_my_print_orders,
    list_print_catalog,
    list_print_events,
    list_print_order_items,
    list_print_partners,
    update_print_order,
    upsert_print_partner,
    upsert_print_product,
)

router = APIRouter(tags=["prints_fulfillment"])


@router.get("/prints/catalog", response_model=list[PrintProductView])
def prints_catalog(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[PrintProductView]:
    rows = list_print_catalog(db)
    log_event(db, event_name="prints.catalog_viewed", user_id=user.user_id, properties={"count": len(rows)})
    db.commit()
    return [PrintProductView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/gigs/{gig_id}/prints/orders", response_model=PrintOrderDetailResponse)
def create_gig_print_order(
    gig_id: uuid.UUID,
    body: PrintOrderCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PrintOrderDetailResponse:
    order = create_print_order(
        db,
        client_user_id=user.user_id,
        gig_id=gig_id,
        partner_id=body.partner_id,
        items=[item.model_dump() for item in body.items],
        shipping_address_payload=body.shipping_address.model_dump(),
    )
    items = list_print_order_items(db, order_id=order.id)
    db.commit()
    return PrintOrderDetailResponse(
        order=PrintOrderView.model_validate(order, from_attributes=True),
        items=[PrintOrderItemView.model_validate(item, from_attributes=True) for item in items],
    )


@router.put("/prints/orders/{order_id}", response_model=PrintOrderDetailResponse)
def update_order(
    order_id: uuid.UUID,
    body: PrintOrderUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PrintOrderDetailResponse:
    order = update_print_order(
        db,
        order_id=order_id,
        client_user_id=user.user_id,
        items=[item.model_dump() for item in body.items] if body.items is not None else None,
        shipping_address_payload=body.shipping_address.model_dump() if body.shipping_address else None,
    )
    items = list_print_order_items(db, order_id=order.id)
    db.commit()
    return PrintOrderDetailResponse(
        order=PrintOrderView.model_validate(order, from_attributes=True),
        items=[PrintOrderItemView.model_validate(item, from_attributes=True) for item in items],
    )


@router.post("/prints/orders/{order_id}/pay", response_model=PrintOrderPayResponse)
def pay_order(
    order_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PrintOrderPayResponse:
    order = get_my_print_order(db, client_user_id=user.user_id, order_id=order_id)
    order, intent = create_print_payment_intent(db, order=order)
    db.commit()
    return PrintOrderPayResponse(order_id=order.id, payment_intent_id=intent.id, payment_intent_client_secret=getattr(intent, "client_secret", None))


@router.get("/prints/orders/mine", response_model=list[PrintOrderView])
def my_orders(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[PrintOrderView]:
    rows = list_my_print_orders(db, client_user_id=user.user_id)
    db.commit()
    return [PrintOrderView.model_validate(row, from_attributes=True) for row in rows]


@router.get("/prints/orders/{order_id}", response_model=PrintOrderDetailResponse)
def my_order_detail(
    order_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PrintOrderDetailResponse:
    order = get_my_print_order(db, client_user_id=user.user_id, order_id=order_id)
    items = list_print_order_items(db, order_id=order.id)
    db.commit()
    return PrintOrderDetailResponse(
        order=PrintOrderView.model_validate(order, from_attributes=True),
        items=[PrintOrderItemView.model_validate(item, from_attributes=True) for item in items],
    )


@router.get("/admin/prints/orders", response_model=list[PrintOrderView])
def admin_orders(
    status: PrintOrderStatus | None = Query(default=None),
    partner: uuid.UUID | None = Query(default=None),
    limit: int = Query(default=200, ge=1, le=1000),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[PrintOrderView]:
    rows = list_admin_print_orders(db, status=status, partner_id=partner, limit=limit)
    db.commit()
    return [PrintOrderView.model_validate(row, from_attributes=True) for row in rows]


@router.get("/admin/prints/orders/{order_id}", response_model=AdminPrintOrderDetailResponse)
def admin_order_detail(
    order_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminPrintOrderDetailResponse:
    row = db.get(PrintOrder, order_id)
    if not row:
        raise APIError(code="not_found", message="Print order not found", status_code=404)
    items = list_print_order_items(db, order_id=row.id)
    events = list_print_events(db, order_id=row.id)
    db.commit()
    return AdminPrintOrderDetailResponse(
        order=PrintOrderView.model_validate(row, from_attributes=True),
        items=[PrintOrderItemView.model_validate(item, from_attributes=True) for item in items],
        events=[PrintEventView.model_validate(item, from_attributes=True) for item in events],
    )


@router.post("/admin/prints/orders/{order_id}/set-status", response_model=PrintOrderView)
def admin_set_status(
    order_id: uuid.UUID,
    body: AdminPrintOrderSetStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PrintOrderView:
    row = db.get(PrintOrder, order_id)
    if not row:
        raise APIError(code="not_found", message="Print order not found", status_code=404)
    admin_set_print_order_status(db, order=row, to_status=body.status, note=body.note, actor_type=PrintEventActorType.admin)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="print_order",
        target_id=str(row.id),
        action="print_order_set_status",
        reason=body.note,
        metadata={"status": body.status.value},
    )
    db.commit()
    return PrintOrderView.model_validate(row, from_attributes=True)


@router.post("/admin/prints/orders/{order_id}/set-tracking", response_model=PrintOrderView)
def admin_set_tracking(
    order_id: uuid.UUID,
    body: AdminPrintOrderSetTrackingRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PrintOrderView:
    row = db.get(PrintOrder, order_id)
    if not row:
        raise APIError(code="not_found", message="Print order not found", status_code=404)
    admin_set_print_tracking(db, order=row, tracking_code=body.tracking_code, note=body.note)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="print_order",
        target_id=str(row.id),
        action="print_order_set_tracking",
        reason=body.note,
        metadata={"tracking_code": body.tracking_code},
    )
    db.commit()
    return PrintOrderView.model_validate(row, from_attributes=True)


@router.get("/admin/prints/catalog/products", response_model=list[PrintProductView])
def admin_get_products(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[PrintProductView]:
    ensure_default_print_catalog(db)
    rows = list_print_catalog(db)
    db.commit()
    return [PrintProductView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/admin/prints/catalog/products", response_model=PrintProductView)
def admin_put_product(
    body: PrintProductUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PrintProductView:
    row = upsert_print_product(
        db,
        product_id=body.id,
        partner_id=body.partner_id,
        sku=body.sku,
        name_key=body.name_key,
        description_key=body.description_key,
        type=body.type,
        options=body.options,
        base_cost_eur=body.base_cost_eur,
        markup_percent=body.markup_percent,
        production_specs=body.production_specs,
        is_active=body.is_active,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="print_product",
        target_id=str(row.id),
        action="print_product_upsert",
        metadata={"sku": row.sku},
    )
    db.commit()
    return PrintProductView.model_validate(row, from_attributes=True)


@router.get("/admin/prints/partners", response_model=list[PrintPartnerView])
def admin_get_partners(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[PrintPartnerView]:
    rows = list_print_partners(db)
    db.commit()
    return [PrintPartnerView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/admin/prints/partners", response_model=PrintPartnerView)
def admin_put_partner(
    body: PrintPartnerUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> PrintPartnerView:
    row = upsert_print_partner(
        db,
        partner_id=body.id,
        name=body.name,
        mode=body.mode,
        api_base_url=body.api_base_url,
        api_key_ref=body.api_key_ref,
        is_active=body.is_active,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="print_partner",
        target_id=str(row.id),
        action="print_partner_upsert",
        metadata={"name": row.name},
    )
    db.commit()
    return PrintPartnerView.model_validate(row, from_attributes=True)
