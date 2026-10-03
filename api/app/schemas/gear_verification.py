from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.gear_verification import ApertureType, SensorSize, VerificationStatus
from app.models.repair import GearCategory


class GearVerificationView(BaseModel):
    """One piece of gear, as its owner sees it."""

    id: uuid.UUID
    category: GearCategory
    status: VerificationStatus
    make: str | None = None
    model: str | None = None
    #: The last four characters, never the whole serial. Enough to recognise a
    #: camera by; not something to leak from a screenshot.
    serial_hint: str | None = None
    sensor_size: SensorSize | None = None
    aperture_type: ApertureType | None = None
    min_focal_mm: Decimal | None = None
    max_focal_mm: Decimal | None = None
    max_aperture: Decimal | None = None
    #: Why this is waiting on a person, or was rejected, in words to show as they are.
    review_reason: str | None = None
    verified_at: datetime | None = None
    created_at: datetime


class GearFloorView(BaseModel):
    """Where the photographer stands against the floor, and what is left."""

    meets_floor: bool
    has_full_frame_body: bool
    has_qualifying_lens: bool
    has_lighting: bool
    lighting_required: bool
    #: True when the lighting counted is the photographer's word. Shown as such.
    lighting_is_declared: bool
    #: Waiting on the platform rather than on the photographer.
    awaiting_review: int
    missing: list[str] = Field(default_factory=list)


class GearVerificationListResponse(BaseModel):
    items: list[GearVerificationView] = Field(default_factory=list)
    floor: GearFloorView


class GearFrameSubmitRequest(BaseModel):
    evidence_media_asset_id: uuid.UUID


class GearFrameSubmitResponse(BaseModel):
    items: list[GearVerificationView] = Field(default_factory=list)
    #: Not errors: a frame that carried no lens information, for one.
    notes: list[str] = Field(default_factory=list)
    floor: GearFloorView


class LightingDeclareRequest(BaseModel):
    make: str | None = None
    model: str
    notes: str | None = None


class AdminGearVerificationView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    pro_display_name: str | None = None
    category: GearCategory
    status: VerificationStatus
    make: str | None = None
    model: str | None = None
    #: Whole, unlike the photographer's view: this is the one thing a reviewer
    #: needs to compare against another claim.
    serial_number: str | None = None
    sensor_size: SensorSize | None = None
    aperture_type: ApertureType | None = None
    min_focal_mm: Decimal | None = None
    max_focal_mm: Decimal | None = None
    max_aperture: Decimal | None = None
    review_reason: str | None = None
    exif_snapshot: dict = Field(default_factory=dict)
    #: Short-lived link to the uploaded file, for a reviewer who wants to look.
    evidence_url: str | None = None
    created_at: datetime
    reviewed_at: datetime | None = None
    review_note: str | None = None


class AdminGearListResponse(BaseModel):
    items: list[AdminGearVerificationView] = Field(default_factory=list)


class GearApproveRequest(BaseModel):
    #: Required when the model is not in the reference table.
    sensor_size: SensorSize | None = None
    #: Required when a lens's aperture could not be read.
    aperture_type: ApertureType | None = None
    note: str | None = None
    #: Also add this model to the reference table, so the next photographer
    #: with the same camera needs no review.
    add_to_reference: bool = False


class GearRejectRequest(BaseModel):
    reason: str
