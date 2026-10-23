from __future__ import annotations

import uuid
from datetime import datetime
import enum

from pydantic import BaseModel, Field

from app.schemas.media import PhotoUploadCreateResponse


class NicheBannerStyle(str, enum.Enum):
    image = "image"
    text = "text"


class NicheBannerImageView(BaseModel):
    media_asset_id: uuid.UUID
    # The Discover tile's copy and the niche page's, each under its own key.
    tile_url: str
    hero_url: str
    # A tiny blurred copy as a data URI, drawn while the real one loads.
    placeholder: str
    alt_text: str
    # What must stay visible, as fractions of width and height: every crop is
    # placed around it.
    focal_x: float
    focal_y: float
    # How dark the title scrim must be on this image for white text to stay
    # legible, measured when it was uploaded.
    scrim_opacity: float
    width: int
    height: int


class NicheBannerView(BaseModel):
    """A niche's banner as every screen draws it.

    `style` "text" is a deliberate typographic banner - name and tagline, no
    image, and none is sent. "image" with no `image` is a niche whose image
    has not been uploaded: the app draws the neutral ground.
    """

    style: NicheBannerStyle
    name: str
    tagline: str | None = None
    image: NicheBannerImageView | None = None


# --- Admin ------------------------------------------------------------------------------


class BannerUploadStart(BaseModel):
    content_type: str
    file_name: str | None = None


class BannerUploadStarted(PhotoUploadCreateResponse):
    pass


class BannerUploadCompleted(BaseModel):
    media_asset_id: uuid.UUID
    width: int
    height: int
    # Measured on this image, so the preview shows the scrim it will get.
    scrim_opacity: float
    placeholder: str
    # Things to look at, not refusals: a portrait image, for one.
    warnings: list[str] = Field(default_factory=list)


class BannerSet(BaseModel):
    media_asset_id: uuid.UUID
    alt_text: str = ""
    focal_x: float = 0.5
    focal_y: float = 0.5
    source: str = "owner"
    credit: str | None = None
    licence: str | None = None
    source_url: str | None = None


class BannerEdit(BaseModel):
    alt_text: str | None = None
    focal_x: float | None = None
    focal_y: float | None = None
    source: str | None = None
    credit: str | None = None
    licence: str | None = None
    source_url: str | None = None


class NicheEdit(BaseModel):
    banner_style: str | None = None
    banner_tagline: str | None = None


class AdminBannerRecord(BaseModel):
    banner_id: uuid.UUID
    media_asset_id: uuid.UUID
    state: str
    alt_text: str
    focal_x: float
    focal_y: float
    source: str
    credit: str | None = None
    licence: str | None = None
    source_url: str | None = None
    width: int
    height: int
    scrim_opacity: float
    created_at: datetime
    created_by_user_id: uuid.UUID
    tile_url: str | None = None
    hero_url: str | None = None
    placeholder: str


class AdminNicheBannerRow(BaseModel):
    slug: str
    name: str
    is_active: bool
    banner_style: str
    banner_tagline: str | None = None
    # "image_set", "image_missing" (an image niche with nothing uploaded - the
    # one to fix) or "text_only".
    status: str
    current: AdminBannerRecord | None = None
    has_previous: bool = False


class AdminBannerLimits(BaseModel):
    mime_types: list[str]
    max_bytes: int
    min_width: int
    min_height: int
    tagline_max: int
    alt_max: int
    min_contrast: float


class AdminNicheBannerList(BaseModel):
    items: list[AdminNicheBannerRow]
    limits: AdminBannerLimits


class AdminNicheBannerDetail(AdminNicheBannerRow):
    previous: AdminBannerRecord | None = None
    history: list[AdminBannerRecord] = Field(default_factory=list)
    limits: AdminBannerLimits
