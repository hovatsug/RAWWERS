"""Admin: the camera reference table.

The only way to change `camera_model_reference` other than the seed script,
which refuses to run in production - so the only way production gets the list
at all. See `app/services/camera_reference.py` for what the table decides.
"""
from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.models.gear_verification import CameraModelReference, SensorSize
from app.schemas.camera_reference import (
    CameraModelCreateRequest,
    CameraModelImportLine,
    CameraModelImportRequest,
    CameraModelImportResponse,
    CameraModelListResponse,
    CameraModelUpdateRequest,
    CameraModelView,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.camera_reference import add_model, apply_import, edit_model, list_models, plan_import

router = APIRouter(prefix="/admin/camera-models", tags=["admin"])


def _view(row: CameraModelReference) -> CameraModelView:
    return CameraModelView(
        normalised_model=row.normalised_model,
        make=row.make,
        display_name=row.display_name,
        sensor_size=row.sensor_size,
        updated_at=row.updated_at,
    )


@router.get("", response_model=CameraModelListResponse)
def list_camera_models(
    q: str | None = Query(default=None, max_length=200),
    sensor_size: SensorSize | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CameraModelListResponse:
    total = db.execute(select(func.count()).select_from(CameraModelReference)).scalar_one()
    full_frame = db.execute(
        select(func.count()).select_from(CameraModelReference).where(CameraModelReference.sensor_size == SensorSize.full_frame)
    ).scalar_one()
    return CameraModelListResponse(
        items=[_view(row) for row in list_models(db, q=q, sensor_size=sensor_size)],
        total=total,
        full_frame=full_frame,
    )


@router.post("", response_model=CameraModelView)
def create_camera_model(
    body: CameraModelCreateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CameraModelView:
    row = add_model(db, model=body.model, make=body.make, display_name=body.display_name, sensor_size=body.sensor_size)
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="camera_model_reference",
        target_id=row.normalised_model,
        action="camera_model_added",
        metadata={"model": body.model, "make": row.make, "display_name": row.display_name, "sensor_size": row.sensor_size.value},
    )
    db.commit()
    return _view(row)


@router.put("/{normalised_model}", response_model=CameraModelView)
def update_camera_model(
    normalised_model: str,
    body: CameraModelUpdateRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CameraModelView:
    row, before = edit_model(
        db,
        normalised_model=normalised_model,
        make=body.make,
        display_name=body.display_name,
        sensor_size=body.sensor_size,
        reason=body.reason,
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="camera_model_reference",
        target_id=row.normalised_model,
        action="camera_model_edited",
        reason=(body.reason or "").strip() or None,
        metadata={
            "before": before,
            "after": {"make": row.make, "display_name": row.display_name, "sensor_size": row.sensor_size.value},
        },
    )
    db.commit()
    return _view(row)


@router.post("/import", response_model=CameraModelImportResponse)
def import_camera_models(
    body: CameraModelImportRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> CameraModelImportResponse:
    """Check a CSV, and with `apply`, write it - all rows or none."""
    plan = plan_import(db, body.csv)
    if body.apply:
        apply_import(db, plan, reason=body.reason)
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="camera_model_reference",
            target_id="import",
            action="camera_models_imported",
            reason=(body.reason or "").strip() or None,
            metadata={
                "created": [line.normalised_model for line in plan.lines if line.outcome == "create"],
                "updated": [
                    {"model": line.normalised_model, "before": line.before, "sensor_size": line.sensor_size}
                    for line in plan.lines
                    if line.outcome == "update"
                ],
                "unchanged": plan.count("unchanged"),
            },
        )
        db.commit()
    return CameraModelImportResponse(
        lines=[CameraModelImportLine(**line.__dict__) for line in plan.lines],
        create=plan.count("create"),
        update=plan.count("update"),
        unchanged=plan.count("unchanged"),
        errors=plan.count("error"),
        changes_sensor_size=plan.changes_sensor_size,
        applied=body.apply,
    )
