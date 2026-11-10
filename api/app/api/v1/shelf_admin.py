"""The Shelf, for admins: settings, terms, items, orders and RAWW.

Every change is audit-logged with the admin and the time.
"""
from __future__ import annotations

import uuid

from decimal import ROUND_HALF_UP, Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.core.errors import APIError
from app.models.admin import ProProfile
from app.models.shelf import ProRawwLedgerEntry, RawwEntryKind, ShelfItem, ShelfOrder, ShelfOrderEvent, ShelfOrderStatus, ShelfSettings
from app.schemas.media import CurrentUser
from app.schemas.shelf import (
    AdminRawwAdjustRequest,
    AdminRawwLedgerEntry,
    AdminRawwLedgerResponse,
    AdminShelfCancelRequest,
    AdminShelfOrderedRequest,
    AdminShelfOrderEvent,
    AdminShelfOrdersResponse,
    AdminShelfShippingRequest,
    AdminShelfOrderView,
    AdminShelfShippedRequest,
    AdminShelfItemRequest,
    AdminShelfItemsResponse,
    AdminShelfItemView,
    ShelfImageOrder,
    ShelfImageUploadStart,
    ShelfImageUploadStarted,
    ShelfImageView,
    ShelfPriceHelper,
    ShelfPriceHelperRequest,
    ShelfSettingsUpdateRequest,
    ShelfSettingsView,
    ShelfTermsApproveRequest,
    ShelfTermsRequest,
)
from app.services import raww_ledger as ledger
from app.services import shelf_items as si
from app.services import shelf_orders as so
from app.services import shelf_settings as ss
from app.services.audit import add_admin_audit_log

router = APIRouter(prefix="/admin/shelf", tags=["admin"])


def _settings_view(db: Session, row: ShelfSettings) -> ShelfSettingsView:
    return ShelfSettingsView(
        **{key: getattr(row, key) for key in ss.EDITABLE},
        shelf_open=ss.shelf_open(db),
        terms_text=row.terms_text,
        terms_draft=ss.terms_are_draft(row),
        terms_reviewed_by=row.terms_reviewed_by,
        terms_review_note=row.terms_review_note,
        terms_approved_at=row.terms_approved_at,
        updated_at=row.updated_at,
    )


@router.get("/settings", response_model=ShelfSettingsView)
def get_shelf_settings(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> ShelfSettingsView:
    row = ss.shelf_settings(db)
    db.commit()
    return _settings_view(db, row)


@router.put("/settings", response_model=ShelfSettingsView)
def put_shelf_settings(
    body: ShelfSettingsUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ShelfSettingsView:
    row, changes = ss.update_settings(db, values=body.model_dump(exclude_none=True), actor_user_id=actor.user_id)
    if changes:
        add_admin_audit_log(
            db, actor_user_id=actor.user_id, target_type="shelf_settings", target_id="1",
            action="shelf_settings_updated", metadata={"changes": changes},
        )
    db.commit()
    db.refresh(row)
    return _settings_view(db, row)


@router.put("/settings/terms", response_model=ShelfSettingsView)
def put_shelf_terms(
    body: ShelfTermsRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ShelfSettingsView:
    row = ss.set_terms(db, text=body.text, actor_user_id=actor.user_id)
    add_admin_audit_log(
        db, actor_user_id=actor.user_id, target_type="shelf_settings", target_id="1",
        action="shelf_terms_replaced", metadata={"length": len(row.terms_text)},
    )
    db.commit()
    db.refresh(row)
    return _settings_view(db, row)


@router.post("/settings/terms/approve", response_model=ShelfSettingsView)
def approve_shelf_terms(
    body: ShelfTermsApproveRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ShelfSettingsView:
    row = ss.approve_terms(db, reviewed_by=body.reviewed_by, note=body.note, actor_user_id=actor.user_id)
    add_admin_audit_log(
        db, actor_user_id=actor.user_id, target_type="shelf_settings", target_id="1",
        action="shelf_terms_approved", reason=row.terms_review_note, metadata={"reviewed_by": row.terms_reviewed_by},
    )
    db.commit()
    db.refresh(row)
    return _settings_view(db, row)


def _image_views(db: Session, item_ids: list[uuid.UUID]) -> dict[uuid.UUID, list[ShelfImageView]]:
    from app.services.shelf_images import urls_for

    return {
        item_id: [ShelfImageView(id=i.id, status=i.status, small_url=i.small, medium_url=i.medium, large_url=i.large) for i in rows]
        for item_id, rows in urls_for(db, item_ids, ready_only=False).items()
    }


def _item_view(db: Session, item: ShelfItem, camera_models: list[str], images: list[ShelfImageView] | None = None) -> AdminShelfItemView:
    if images is None:
        images = _image_views(db, [item.id]).get(item.id, [])
    return AdminShelfItemView(
        images=images,
        **{key: getattr(item, key) for key in si.FIELDS if key != "stock_status"},
        id=item.id,
        stock_status=item.stock_status.value,
        camera_models=camera_models,
        helper=ShelfPriceHelper(
            **si.price_helper(
                db, level=item.level, price_raww=item.price_raww, street_price=item.street_price,
                street_currency=item.street_currency, supplier_cost=item.supplier_cost, supplier_currency=item.supplier_currency,
            )
        ),
        updated_at=item.updated_at,
    )


@router.get("/items", response_model=AdminShelfItemsResponse)
def list_shelf_items(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminShelfItemsResponse:
    items = db.execute(select(ShelfItem).order_by(ShelfItem.level, ShelfItem.price_raww, ShelfItem.title)).scalars().all()
    compat = si.compat_for(db, [i.id for i in items])
    images = _image_views(db, [i.id for i in items])
    return AdminShelfItemsResponse(items=[_item_view(db, i, compat[i.id], images.get(i.id, [])) for i in items])


@router.post("/items/price-helper", response_model=ShelfPriceHelper)
def shelf_price_helper(body: ShelfPriceHelperRequest, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> ShelfPriceHelper:
    """The helper for a form not yet saved: the same numbers the list shows."""
    if not 1 <= body.level <= ss.LEVELS:
        raise APIError(code="validation_error", message=f"Level is 1 to {ss.LEVELS}", status_code=422)
    return ShelfPriceHelper(**si.price_helper(db, **body.model_dump()))


@router.post("/items", response_model=AdminShelfItemView)
def create_shelf_item(
    body: AdminShelfItemRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminShelfItemView:
    values = body.model_dump(exclude={"camera_models"})
    item = si.create_item(db, values=values, camera_models=body.camera_models, actor_user_id=actor.user_id)
    add_admin_audit_log(
        db, actor_user_id=actor.user_id, target_type="shelf_item", target_id=str(item.id),
        action="shelf_item_created", metadata={**body.model_dump(mode="json")},
    )
    db.commit()
    db.refresh(item)
    return _item_view(db, item, si.compat_for(db, [item.id])[item.id])


@router.put("/items/{item_id}", response_model=AdminShelfItemView)
def update_shelf_item(
    item_id: uuid.UUID,
    body: AdminShelfItemRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminShelfItemView:
    item, changes = si.update_item(db, item_id=item_id, values=body.model_dump(exclude={"camera_models"}), camera_models=body.camera_models)
    if changes:
        add_admin_audit_log(
            db, actor_user_id=actor.user_id, target_type="shelf_item", target_id=str(item.id),
            action="shelf_item_updated", metadata={"changes": changes},
        )
    db.commit()
    db.refresh(item)
    return _item_view(db, item, si.compat_for(db, [item.id])[item.id])


# --- photos ---------------------------------------------------------------------------------


@router.post("/items/{item_id}/images", response_model=ShelfImageUploadStarted)
def start_shelf_image(
    item_id: uuid.UUID, body: ShelfImageUploadStart, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> ShelfImageUploadStarted:
    """Upload one more photo (JPEG, PNG or WebP, up to 10 MB, at least
    800 px on its long edge): PUT the file to `upload_url`, then complete."""
    from app.services import shelf_images

    image, started = shelf_images.start(db, item_id=item_id, admin_user_id=actor.user_id, content_type=body.content_type, file_name=body.file_name)
    db.commit()
    return ShelfImageUploadStarted(image_id=image.id, upload_url=started.upload.url, method=started.upload.method, headers=started.upload.headers)


@router.post("/items/{item_id}/images/{image_id}/complete", response_model=AdminShelfItemView)
def complete_shelf_image(
    item_id: uuid.UUID, image_id: uuid.UUID, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> AdminShelfItemView:
    """Check the photo; the worker makes its sizes."""
    from app.services import shelf_images

    shelf_images.complete(db, item_id=item_id, image_id=image_id)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="shelf_item", target_id=str(item_id), action="shelf_item_photo_added", metadata={"image_id": str(image_id)})
    db.commit()
    item = db.get(ShelfItem, item_id)
    return _item_view(db, item, si.compat_for(db, [item.id])[item.id])


@router.put("/items/{item_id}/images/order", response_model=AdminShelfItemView)
def order_shelf_images(
    item_id: uuid.UUID, body: ShelfImageOrder, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> AdminShelfItemView:
    """The photos in this order; the first is the cover."""
    from app.services import shelf_images

    shelf_images.reorder(db, item_id=item_id, image_ids=body.image_ids)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="shelf_item", target_id=str(item_id), action="shelf_item_photos_reordered", metadata={"order": [str(i) for i in body.image_ids]})
    db.commit()
    item = db.get(ShelfItem, item_id)
    return _item_view(db, item, si.compat_for(db, [item.id])[item.id])


@router.delete("/items/{item_id}/images/{image_id}", response_model=AdminShelfItemView)
def delete_shelf_image(
    item_id: uuid.UUID, image_id: uuid.UUID, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> AdminShelfItemView:
    from app.services import shelf_images

    shelf_images.remove(db, item_id=item_id, image_id=image_id)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="shelf_item", target_id=str(item_id), action="shelf_item_photo_deleted", metadata={"image_id": str(image_id)})
    db.commit()
    item = db.get(ShelfItem, item_id)
    return _item_view(db, item, si.compat_for(db, [item.id])[item.id])


# --- orders ---------------------------------------------------------------------------------


def _order_view(db: Session, order: ShelfOrder) -> AdminShelfOrderView:
    profile = db.get(ProProfile, order.pro_user_id)
    events = db.execute(select(ShelfOrderEvent).where(ShelfOrderEvent.order_id == order.id).order_by(ShelfOrderEvent.created_at)).scalars().all()
    return AdminShelfOrderView(
        id=order.id, pro_user_id=order.pro_user_id, pro_name=profile.display_name if profile else None, item_id=order.item_id,
        title=order.title, supplier_name=order.supplier_name, supplier_sku=order.supplier_sku, price_raww=order.price_raww,
        raww_eur_value=order.raww_eur_value,
        price_eur=(Decimal(order.price_raww) * order.raww_eur_value).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP),
        status=order.status.value, country=order.country, address=so.order_address(order),
        supplier_order_ref=order.supplier_order_ref, tracking_code=order.tracking_code, tracking_url=order.tracking_url,
        cancel_reason=order.cancel_reason, placed_at=order.placed_at,
        supplier_cost=order.supplier_cost, supplier_currency=order.supplier_currency, cost_eur_rate=order.cost_eur_rate,
        cost_estimated=order.cost_estimated, shipping_cost_eur=order.shipping_cost_eur,
        events=[AdminShelfOrderEvent.model_validate(e, from_attributes=True) for e in events],
    )


@router.get("/orders", response_model=AdminShelfOrdersResponse)
def list_shelf_orders(
    status: ShelfOrderStatus | None = Query(default=None),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminShelfOrdersResponse:
    query = select(ShelfOrder).order_by(ShelfOrder.placed_at.asc() if status == ShelfOrderStatus.placed else ShelfOrder.placed_at.desc()).limit(200)
    if status is not None:
        query = query.where(ShelfOrder.status == status)
    return AdminShelfOrdersResponse(items=[_order_view(db, o) for o in db.execute(query).scalars()])


def _logged(db: Session, actor: CurrentUser, order: ShelfOrder, action: str, **meta) -> AdminShelfOrderView:
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="shelf_order", target_id=str(order.id), action=action, metadata=meta)
    db.commit()
    db.refresh(order)
    return _order_view(db, order)


@router.post("/orders/{order_id}/ordered", response_model=AdminShelfOrderView)
def shelf_order_ordered(order_id: uuid.UUID, body: AdminShelfOrderedRequest, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminShelfOrderView:
    order = so.admin_mark_ordered(db, order_id=order_id, supplier_order_ref=body.supplier_order_ref, admin_user_id=actor.user_id)
    return _logged(db, actor, order, "shelf_order_ordered", supplier_order_ref=order.supplier_order_ref)


@router.post("/orders/{order_id}/shipped", response_model=AdminShelfOrderView)
def shelf_order_shipped(order_id: uuid.UUID, body: AdminShelfShippedRequest, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminShelfOrderView:
    order = so.admin_mark_shipped(db, order_id=order_id, tracking_code=body.tracking_code, tracking_url=body.tracking_url,
                                  admin_user_id=actor.user_id, shipping_cost_eur=body.shipping_cost_eur)
    return _logged(db, actor, order, "shelf_order_shipped", tracking_code=order.tracking_code,
                   shipping_cost_eur=str(order.shipping_cost_eur) if order.shipping_cost_eur is not None else None)


@router.put("/orders/{order_id}/shipping-cost", response_model=AdminShelfOrderView)
def shelf_order_shipping_cost(order_id: uuid.UUID, body: AdminShelfShippingRequest, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminShelfOrderView:
    """What shipping this order cost us (the Shelf margin reads it)."""
    order, before = so.admin_set_shipping(db, order_id=order_id, shipping_cost_eur=body.shipping_cost_eur)
    return _logged(db, actor, order, "shelf_order_shipping_cost",
                   before=str(before) if before is not None else None,
                   after=str(order.shipping_cost_eur) if order.shipping_cost_eur is not None else None)


@router.post("/orders/{order_id}/delivered", response_model=AdminShelfOrderView)
def shelf_order_delivered(order_id: uuid.UUID, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminShelfOrderView:
    order = so.admin_mark_delivered(db, order_id=order_id, admin_user_id=actor.user_id)
    return _logged(db, actor, order, "shelf_order_delivered")


@router.post("/orders/{order_id}/cancel", response_model=AdminShelfOrderView)
def shelf_order_cancel(order_id: uuid.UUID, body: AdminShelfCancelRequest, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminShelfOrderView:
    order = so.admin_cancel(db, order_id=order_id, reason=body.reason, note=body.note, admin_user_id=actor.user_id)
    return _logged(db, actor, order, "shelf_order_cancelled", reason=body.reason, note=body.note, refunded_raww=order.price_raww)


# --- one photographer's RAWW ----------------------------------------------------------------


@router.get("/raww/{pro_user_id}", response_model=AdminRawwLedgerResponse)
def raww_ledger_for(pro_user_id: uuid.UUID, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminRawwLedgerResponse:
    balance = ledger.get_balance(db, pro_user_id)
    rows = db.execute(
        select(ProRawwLedgerEntry).where(ProRawwLedgerEntry.pro_user_id == pro_user_id).order_by(ProRawwLedgerEntry.created_at.desc()).limit(500)
    ).scalars().all()
    return AdminRawwLedgerResponse(
        spendable=balance.spendable if balance else 0,
        pending=balance.pending if balance else 0,
        items=[
            AdminRawwLedgerEntry(
                id=r.id, kind=r.kind.value, amount=r.amount, status=r.status.value, gig_id=r.gig_id,
                source_type=r.source_type, note=r.note, actor_user_id=r.actor_user_id, created_at=r.created_at,
            )
            for r in rows
        ],
    )


@router.post("/raww/{pro_user_id}/adjust", response_model=AdminRawwLedgerEntry)
def raww_adjust(pro_user_id: uuid.UUID, body: AdminRawwAdjustRequest, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> AdminRawwLedgerEntry:
    resubmitted = body.request_id is not None and ledger.find_entry(
        db, pro_user_id=pro_user_id, kind=RawwEntryKind.admin_adjust, source_type="admin", source_id=body.request_id
    ) is not None
    entry = ledger.admin_adjust(db, pro_user_id=pro_user_id, amount=body.amount, note=body.note, actor_user_id=actor.user_id, request_id=body.request_id)
    if not resubmitted:
        add_admin_audit_log(
            db, actor_user_id=actor.user_id, target_type="pro_raww", target_id=str(pro_user_id), action="raww_adjusted",
            reason=entry.note, metadata={"amount": entry.amount, "entry_id": str(entry.id)},
        )
    db.commit()
    return AdminRawwLedgerEntry(
        id=entry.id, kind=entry.kind.value, amount=entry.amount, status=entry.status.value, gig_id=entry.gig_id,
        source_type=entry.source_type, note=entry.note, actor_user_id=entry.actor_user_id, created_at=entry.created_at,
    )
