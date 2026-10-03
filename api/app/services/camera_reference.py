"""The camera reference table, as an admin maintains it.

`camera_model_reference` decides whether a body is verified on upload or
waits for a person: a model listed as full-frame verifies, one listed as crop
is refused with the reason, and one not listed goes to the review queue. So
an empty table does not break anything visibly - it sends every submission to
the queue - and that is exactly the state a fresh production database is in,
because the seed script refuses to run there.

Everything here keys rows the way the upload check looks them up
(`normalise_model`), so a model added by hand or by import is found by the
next file that names it, however its firmware spells it.

Writes are deliberately narrower than the seed script's:
  - Adding never overwrites. A model already in the list is edited, on
    purpose, with the old value in front of whoever changes it.
  - Changing a sensor size needs a reason. It changes who is verified without
    anyone looking, and the audit log should say why.
  - An import is checked whole before anything is written, and applies all of
    its rows or none.
"""
from __future__ import annotations

import csv
import io
from dataclasses import dataclass, field
from datetime import datetime, timezone

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.gear_verification import CameraModelReference, SensorSize
from app.services.gear_verify import normalise_model

#: The most rows one import may carry. The whole full-frame market is about a
#: hundred bodies; a file far bigger than that is the wrong file.
MAX_IMPORT_ROWS = 2000

_SENSOR_VALUES = ", ".join(s.value for s in SensorSize)


def list_models(db: Session, *, q: str | None = None, sensor_size: SensorSize | None = None) -> list[CameraModelReference]:
    query = select(CameraModelReference)
    if sensor_size is not None:
        query = query.where(CameraModelReference.sensor_size == sensor_size)
    text = (q or "").strip()
    if text:
        like = f"%{text}%"
        conditions = [CameraModelReference.display_name.ilike(like), CameraModelReference.make.ilike(like)]
        # "ilce 7m4" should find "ILCE-7M4": search the key the way it is built.
        key = normalise_model(text)
        if key:
            conditions.append(CameraModelReference.normalised_model.contains(key))
        query = query.where(or_(*conditions))
    return list(
        db.execute(query.order_by(CameraModelReference.make, CameraModelReference.display_name)).scalars().all()
    )


def _clean(value: str | None) -> str | None:
    value = (value or "").strip()
    return value or None


def add_model(
    db: Session, *, model: str, make: str | None, display_name: str | None, sensor_size: SensorSize
) -> CameraModelReference:
    key = normalise_model(model)
    if not key:
        raise APIError(code="validation_error", message="Give the model as the camera writes it, e.g. ILCE-7M4", status_code=422)
    existing = db.get(CameraModelReference, key)
    if existing is not None:
        raise APIError(
            code="conflict",
            message=f"Already listed as {existing.display_name} ({existing.sensor_size.value.replace('_', ' ')}). Edit that entry instead.",
            status_code=409,
        )
    row = CameraModelReference(
        normalised_model=key,
        make=_clean(make),
        display_name=_clean(display_name) or model.strip(),
        sensor_size=sensor_size,
        updated_at=datetime.now(timezone.utc),
    )
    db.add(row)
    db.flush()
    return row


def edit_model(
    db: Session,
    *,
    normalised_model: str,
    make: str | None,
    display_name: str,
    sensor_size: SensorSize,
    reason: str | None,
) -> tuple[CameraModelReference, dict]:
    """Returns the row and what it was before, for the audit log."""
    row = db.get(CameraModelReference, normalised_model)
    if row is None:
        raise APIError(code="not_found", message="That model is not in the list", status_code=404)
    name = _clean(display_name)
    if not name:
        raise APIError(code="validation_error", message="A model needs a name people recognise", status_code=422)
    if sensor_size != row.sensor_size and not _clean(reason):
        raise APIError(
            code="validation_error",
            message="Changing a sensor size changes who is verified automatically: give a reason",
            status_code=422,
        )
    before = {"make": row.make, "display_name": row.display_name, "sensor_size": row.sensor_size.value}
    row.make = _clean(make)
    row.display_name = name
    row.sensor_size = sensor_size
    row.updated_at = datetime.now(timezone.utc)
    db.flush()
    return row, before


@dataclass
class ImportLine:
    line: int
    model: str
    normalised_model: str
    make: str | None
    display_name: str
    sensor_size: str | None
    outcome: str  # create | update | unchanged | error
    error: str | None = None
    before: dict | None = None


@dataclass
class ImportPlan:
    lines: list[ImportLine] = field(default_factory=list)

    def count(self, outcome: str) -> int:
        return sum(1 for line in self.lines if line.outcome == outcome)

    @property
    def changes_sensor_size(self) -> bool:
        return any(
            line.outcome == "update" and line.before and line.before["sensor_size"] != line.sensor_size
            for line in self.lines
        )


def plan_import(db: Session, text: str) -> ImportPlan:
    """What an import would do, row by row, without doing it.

    Columns: `model` and `sensor_size` are required; `make` and `display_name`
    are optional. The same columns the page's "Download CSV" writes, so a list
    exported from one database imports into another unchanged.
    """
    reader = csv.DictReader(io.StringIO(text.lstrip("﻿")))
    headers = {(h or "").strip().lower() for h in (reader.fieldnames or [])}
    missing = {"model", "sensor_size"} - headers
    if missing:
        raise APIError(
            code="validation_error",
            message=f"The file needs a header row with {', '.join(sorted(missing))} (and optionally make, display_name)",
            status_code=422,
        )

    plan = ImportPlan()
    seen: dict[str, int] = {}
    for number, raw in enumerate(reader, start=2):  # line 1 is the header
        if len(plan.lines) >= MAX_IMPORT_ROWS:
            raise APIError(
                code="validation_error", message=f"An import takes at most {MAX_IMPORT_ROWS} rows", status_code=422
            )
        row = {(k or "").strip().lower(): (v or "").strip() for k, v in raw.items() if k is not None}
        if not any(row.values()):
            continue  # a blank line, not an error
        model = row.get("model", "")
        key = normalise_model(model)
        sensor = row.get("sensor_size", "").lower().replace(" ", "_").replace("-", "_")
        line = ImportLine(
            line=number,
            model=model,
            normalised_model=key,
            make=_clean(row.get("make")),
            display_name=_clean(row.get("display_name")) or model,
            sensor_size=sensor or None,
            outcome="error",
        )
        plan.lines.append(line)

        if not key:
            line.error = "No model"
            continue
        if sensor not in {s.value for s in SensorSize}:
            line.error = f"Sensor size must be one of {_SENSOR_VALUES}"
            continue
        if key in seen:
            line.error = f"Same model as line {seen[key]}"
            continue
        seen[key] = number

        existing = db.get(CameraModelReference, key)
        if existing is None:
            line.outcome = "create"
            continue
        before = {"make": existing.make, "display_name": existing.display_name, "sensor_size": existing.sensor_size.value}
        after = {"make": line.make, "display_name": line.display_name, "sensor_size": sensor}
        line.outcome = "unchanged" if before == after else "update"
        line.before = before if line.outcome == "update" else None
    return plan


def apply_import(db: Session, plan: ImportPlan, *, reason: str | None) -> None:
    if not plan.lines:
        raise APIError(code="validation_error", message="The file has no rows", status_code=422)
    if plan.count("error"):
        raise APIError(
            code="validation_error",
            message=f"{plan.count('error')} row(s) have problems. Nothing was imported; fix them and try again.",
            status_code=422,
        )
    if plan.changes_sensor_size and not _clean(reason):
        raise APIError(
            code="validation_error",
            message="This import changes sensor sizes already in the list: give a reason",
            status_code=422,
        )
    now = datetime.now(timezone.utc)
    for line in plan.lines:
        if line.outcome == "create":
            db.add(
                CameraModelReference(
                    normalised_model=line.normalised_model,
                    make=line.make,
                    display_name=line.display_name,
                    sensor_size=SensorSize(line.sensor_size),
                    updated_at=now,
                )
            )
        elif line.outcome == "update":
            row = db.get(CameraModelReference, line.normalised_model)
            row.make = line.make
            row.display_name = line.display_name
            row.sensor_size = SensorSize(line.sensor_size)
            row.updated_at = now
    db.flush()
