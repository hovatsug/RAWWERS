"""The Shelf, for admins: settings, terms, items, orders and RAWW.

Every change is audit-logged with the admin and the time.
"""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.core.errors import APIError
from app.models.shelf import ShelfItem, ShelfSettings
from app.schemas.media import CurrentUser
from app.schemas.shelf import (
    AdminShelfItemRequest,
    AdminShelfItemsResponse,
    AdminShelfItemView,
    ShelfPriceHelper,
    ShelfPriceHelperRequest,
    ShelfSettingsUpdateRequest,
    ShelfSettingsView,
    ShelfTermsApproveRequest,
    ShelfTermsRequest,
)
from app.services import shelf_items as si
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


def _item_view(db: Session, item: ShelfItem, camera_models: list[str]) -> AdminShelfItemView:
    return AdminShelfItemView(
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
    return AdminShelfItemsResponse(items=[_item_view(db, i, compat[i.id]) for i in items])


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
