"""Pairing a Lightroom plugin, and what a delivery token may read.

Every field here is new and additive: nothing an existing client reads
changes. What a token may learn about a client is exactly what is listed in
DeliveryGigView - a first name and initial, the shoot date, the package -
and nothing else (no email, phone, address, messages, payments or
earnings); tests/test_delivery_scope.py holds it to that.
"""
from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.schemas.media import UploadPayload

# --- the pro app -------------------------------------------------------------------


class PairingCodeResponse(BaseModel):
    #: ABCD-EFGH. Shown once; only its hash is kept.
    code: str
    expires_at: datetime
    valid_minutes: int


class DeliveryDeviceView(BaseModel):
    id: uuid.UUID
    device_name: str
    #: The token's first characters, to tell two devices apart.
    token_prefix: str
    plugin_version: str | None = None
    created_at: datetime
    last_used_at: datetime


class DeliveryDevicesResponse(BaseModel):
    items: list[DeliveryDeviceView]
    max_devices: int
    #: Where to download the plug-in (LIGHTROOM_PLUGIN_DOWNLOAD_URL); null
    #: while it is unset, and the app hides its button.
    plugin_download_url: str | None = None
    #: The newest plug-in (LIGHTROOM_PLUGIN_LATEST_VERSION).
    plugin_latest_version: str


# --- the plugin --------------------------------------------------------------------


class PairRequest(BaseModel):
    code: str = Field(min_length=1, max_length=32)
    #: How the plugin names the machine, e.g. "Ana's MacBook Pro".
    device_name: str = Field(min_length=1, max_length=120)
    plugin_version: str | None = Field(default=None, max_length=32)


class PairResponse(BaseModel):
    #: Shown to the plugin once; keep it in the system keychain.
    token: str
    device_id: uuid.UUID
    photographer_name: str
    update_available: bool | None = None
    latest_version: str


class DeliveryMeResponse(BaseModel):
    photographer_name: str
    device_id: uuid.UUID
    update_available: bool | None = None
    latest_version: str


# --- delivering ----------------------------------------------------------------------


class DeliveryGigView(BaseModel):
    """One gig that can take photos, as the plugin's client picker shows it.

    About the client: a first name and last initial, nothing more.
    """

    gig_id: uuid.UUID
    #: Null until the first photo starts: the gallery is made then.
    gallery_id: uuid.UUID | None = None
    #: "Ana S." - first name and last initial.
    client_name: str
    shoot_starts_at: datetime | None = None
    #: The same moment as seconds since 1970, for Lightroom's LrDate.
    shoot_starts_at_epoch: int | None = None
    package_title: str | None = None
    niche_name: str | None = None
    included_photos: int
    #: "waiting_for_photos" or "in_progress".
    delivery_state: str
    #: Photos already in the gallery, and photos still processing for it.
    photos_in_gallery: int
    photos_processing: int


class DeliveryGigsResponse(BaseModel):
    items: list[DeliveryGigView]


class DeliveryUploadRequest(BaseModel):
    file_name: str = Field(min_length=1, max_length=255)
    #: JPEG only: the plugin exports JPEG, and the client downloads this file.
    content_type: str = Field(pattern=r"^image/jpeg$")
    byte_size: int = Field(gt=0)
    sha256: str = Field(pattern=r"^[0-9a-fA-F]{64}$")
    #: The n-th photo of the export (from 1): the gallery is in this order,
    #: whatever order processing finishes in.
    position: int | None = Field(default=None, ge=1, le=1_000_000, strict=True)


class DeliveryUploadResponse(BaseModel):
    media_asset_id: uuid.UUID
    gallery_id: uuid.UUID
    #: This file is in the gallery already (same SHA-256): nothing to send.
    duplicate: bool = False
    #: A presigned PUT for the whole file; null when `duplicate`.
    upload: UploadPayload | None = None
    #: Send it in parts instead (POST .../multipart) - large files, so a
    #: dropped connection costs one part, not the whole file.
    use_multipart: bool = False


class DeliveryCompleteRequest(BaseModel):
    byte_size: int = Field(gt=0)
    #: Must be the hash declared when the upload started.
    sha256: str = Field(pattern=r"^[0-9a-fA-F]{64}$")


class DeliveryFailedPhoto(BaseModel):
    media_asset_id: uuid.UUID
    file_name: str | None = None
    reason: str | None = None


class DeliveryStatusResponse(BaseModel):
    gallery_id: uuid.UUID
    gig_id: uuid.UUID
    #: "draft" while the photographer is still delivering; anything else
    #: means it was sent from the app and takes no more photos from here.
    gallery_status: str
    photos_in_gallery: int
    uploading: int
    processing: int
    failed: list[DeliveryFailedPhoto]
