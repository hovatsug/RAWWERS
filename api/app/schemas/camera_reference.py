from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field

from app.models.gear_verification import SensorSize


class CameraModelView(BaseModel):
    #: The lookup key: lowercased, separators dropped. What the upload check
    #: matches a file's model against.
    normalised_model: str
    make: str | None = None
    display_name: str
    sensor_size: SensorSize
    updated_at: datetime


class CameraModelListResponse(BaseModel):
    items: list[CameraModelView] = Field(default_factory=list)
    #: Across the whole table, not the filtered list: "is production seeded"
    #: should not depend on what is typed in the search box.
    total: int
    full_frame: int


class CameraModelCreateRequest(BaseModel):
    #: As the camera writes it in EXIF, e.g. "ILCE-7M4". Normalised for the key.
    model: str = Field(min_length=1, max_length=200)
    make: str | None = Field(default=None, max_length=100)
    display_name: str | None = Field(default=None, max_length=200)
    sensor_size: SensorSize


class CameraModelUpdateRequest(BaseModel):
    make: str | None = Field(default=None, max_length=100)
    display_name: str = Field(min_length=1, max_length=200)
    sensor_size: SensorSize
    #: Required when the sensor size changes.
    reason: str | None = Field(default=None, max_length=1000)


class CameraModelImportRequest(BaseModel):
    csv: str = Field(max_length=1_000_000)
    #: False checks the file and says what would change; true writes it.
    apply: bool = False
    #: Required when applying an import that changes a listed sensor size.
    reason: str | None = Field(default=None, max_length=1000)


class CameraModelImportLine(BaseModel):
    line: int
    model: str
    normalised_model: str
    make: str | None = None
    display_name: str
    sensor_size: str | None = None
    outcome: str
    error: str | None = None
    before: dict | None = None


class CameraModelImportResponse(BaseModel):
    lines: list[CameraModelImportLine]
    create: int
    update: int
    unchanged: int
    errors: int
    #: Whether this import would change a sensor size already in the list,
    #: which needs a reason to apply.
    changes_sensor_size: bool
    applied: bool
