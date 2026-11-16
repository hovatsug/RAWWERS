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
    #: The export this photo is part of, named by the plug-in: a later export
    #: goes after the earlier ones in the gallery, each in its own order.
    export_id: str | None = Field(default=None, min_length=1, max_length=64, pattern=r"^[A-Za-z0-9._-]+$")


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


# --- The portfolio (plug-in 1.1.0, docs/LIGHTROOM_PORTFOLIO.md) --------------------------------


class PortfolioNicheView(BaseModel):
    slug: str
    name: str
    #: The photographer's main niche: where the default collection publishes.
    primary: bool = False


class DeliveryPortfolioResponse(BaseModel):
    #: Where photos can go: the photographer's niches, the main one first.
    niches: list[PortfolioNicheView]
    #: Ready portfolio photos, and the minimum onboarding asks for.
    photo_count: int
    photo_minimum: int
    #: (1.2.3) Photos on the server per niche: processing or ready.
    niche_photo_counts: dict[str, int] = {}


class AvailableNicheView(BaseModel):
    slug: str
    name: str
    #: Already one of the photographer's niches.
    mine: bool = False
    primary: bool = False


class DeliveryNichesResponse(BaseModel):
    """Every active niche, marked with the photographer's own (plug-in 1.2.0)."""

    niches: list[AvailableNicheView]
    #: How many the photographer has, and the most they can have.
    count: int
    maximum: int


class AddNicheRequest(BaseModel):
    slug: str = Field(min_length=1, max_length=64)


class AddNicheResponse(DeliveryNichesResponse):
    #: The niche just added, and whether it became the main one.
    added: AvailableNicheView


class PortfolioUploadRequest(BaseModel):
    file_name: str = Field(min_length=1, max_length=255)
    #: JPEG only, as the plug-in exports.
    content_type: str = Field(pattern=r"^image/jpeg$")
    byte_size: int = Field(gt=0)
    sha256: str = Field(pattern=r"^[0-9a-fA-F]{64}$")
    niche_slug: str = Field(min_length=1, max_length=80, pattern=r"^[a-z0-9-]+$")
    #: (1.2.3) The plug-in's key for this Lightroom photo in this collection:
    #: the same on every publish of it, whatever the render.
    publish_key: str | None = Field(default=None, min_length=1, max_length=200, pattern=r"^[A-Za-z0-9:._-]+$")
    #: (1.2.3) SHA-256 of the picture without its metadata (the JPEG's APPn
    #: and comment segments left out): Lightroom writes the export time into
    #: every render, so the file's own hash differs each time.
    image_sha256: str | None = Field(default=None, pattern=r"^[0-9a-fA-F]{64}$")


class PortfolioUploadResponse(BaseModel):
    media_asset_id: uuid.UUID
    #: This photo is in that niche of the portfolio already: nothing to send.
    duplicate: bool = False
    upload: UploadPayload | None = None
    use_multipart: bool = False
    #: (1.2.3) An older version of the same Lightroom photo in this niche
    #: (it was edited): the plug-in removes it once this one is finished.
    replaces: uuid.UUID | None = None


class PortfolioRemoveResponse(BaseModel):
    ok: bool = True
    media_asset_id: uuid.UUID
