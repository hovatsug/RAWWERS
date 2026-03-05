from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.media_rights import GigConsentLevel, ShareLinkScope


class MediaDerivativeView(BaseModel):
    kind: str


class GigMediaAssetView(BaseModel):
    media_asset_id: uuid.UUID
    kind: str
    purpose: str
    derivatives: list[MediaDerivativeView] = Field(default_factory=list)


class GigMediaListResponse(BaseModel):
    gig_id: uuid.UUID
    assets: list[GigMediaAssetView] = Field(default_factory=list)


class SignedUrlResponse(BaseModel):
    url: str
    expires_in_seconds: int


class ShareLinkCreateRequest(BaseModel):
    scope: ShareLinkScope
    expires_at: datetime | None = None
    max_views: int | None = Field(default=None, ge=1)
    media_asset_ids: list[uuid.UUID] = Field(default_factory=list)


class ShareLinkCreateResponse(BaseModel):
    id: uuid.UUID
    token: str
    share_url: str
    expires_at: datetime | None = None
    max_views: int | None = None


class SharedMediaItemView(BaseModel):
    media_asset_id: uuid.UUID
    preview_url: str


class ShareLinkViewResponse(BaseModel):
    gig_id: uuid.UUID
    scope: ShareLinkScope
    expires_at: datetime | None = None
    max_views: int | None = None
    view_count: int
    items: list[SharedMediaItemView] = Field(default_factory=list)
    powered_by_text: str | None = None
    create_gallery_cta_text: str | None = None
    create_gallery_cta_url: str | None = None


class SharePingRequest(BaseModel):
    seconds_viewed: int = Field(default=1, ge=1, le=300)


class SharePingResponse(BaseModel):
    ok: bool
    accumulated_seconds: int


class GigConsentView(BaseModel):
    gig_id: uuid.UUID
    client_user_id: uuid.UUID
    pro_user_id: uuid.UUID
    consent_level: GigConsentLevel
    scope: dict = Field(default_factory=dict)
    incentive: dict = Field(default_factory=dict)
    snapshot_at_booking: bool
    created_at: datetime
    updated_at: datetime


class UpdateGigConsentRequest(BaseModel):
    consent_level: GigConsentLevel
    scope: dict = Field(default_factory=dict)
    reason: str | None = None


class GigConsentEventView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    from_level: str | None = None
    to_level: str
    actor_user_id: uuid.UUID
    reason: str | None = None
    created_at: datetime


class AdminConsentEventsResponse(BaseModel):
    items: list[GigConsentEventView] = Field(default_factory=list)


class ShareLinkRevokeResponse(BaseModel):
    ok: bool
    id: uuid.UUID
    is_revoked: bool
