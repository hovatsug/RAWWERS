"""The Shelf, for admins: settings, terms, items, orders and RAWWS.

Every change is audit-logged with the admin and the time.
"""
from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.models.shelf import ShelfSettings
from app.schemas.media import CurrentUser
from app.schemas.shelf import ShelfSettingsUpdateRequest, ShelfSettingsView, ShelfTermsApproveRequest, ShelfTermsRequest
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
