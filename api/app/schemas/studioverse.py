from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.media_rights import GigConsentLevel
from app.models.studioverse import (
    ContentPackCategory,
    ContentPackOrderStatus,
    ContentPackPaymentMethod,
    ContentPackReviewDecision,
    ContentPackStatus,
    PackSourceType,
)


class PackSourceReferenceInput(BaseModel):
    source_type: PackSourceType
    gig_id: uuid.UUID | None = None
    evidence: dict = Field(default_factory=dict)
    requires_consent_level: GigConsentLevel = GigConsentLevel.both_pro_and_rawwers


class StudioversePackCreateRequest(BaseModel):
    title: str
    description: str
    category: ContentPackCategory
    niche_slugs: list[str] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    price_eur: Decimal | None = Field(default=None, ge=Decimal("0.00"))
    price_raww: int | None = Field(default=None, ge=0)
    currency: str = "EUR"
    cover_media_asset_id: uuid.UUID | None = None
    preview_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)
    pack_file_storage_key: str
    pack_file_bytes: int | None = Field(default=None, ge=0)
    license_code: str
    sources: list[PackSourceReferenceInput] = Field(default_factory=list)


class StudioversePackUpdateRequest(BaseModel):
    title: str | None = None
    description: str | None = None
    category: ContentPackCategory | None = None
    niche_slugs: list[str] | None = None
    tags: list[str] | None = None
    price_eur: Decimal | None = Field(default=None, ge=Decimal("0.00"))
    price_raww: int | None = Field(default=None, ge=0)
    currency: str | None = None
    cover_media_asset_id: uuid.UUID | None = None
    preview_media_asset_ids: list[uuid.UUID] | None = None
    pack_file_storage_key: str | None = None
    pack_file_bytes: int | None = Field(default=None, ge=0)
    license_code: str | None = None
    sources: list[PackSourceReferenceInput] | None = None


class StudioversePackSubmitResponse(BaseModel):
    id: uuid.UUID
    status: ContentPackStatus


class StudioverseCreatorPackView(BaseModel):
    id: uuid.UUID
    title: str
    description: str
    localized_fields: dict = Field(default_factory=dict)
    category: ContentPackCategory
    niche_slugs: list[str] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    price_eur: Decimal | None = None
    price_raww: int | None = None
    currency: str
    cover_media_asset_id: uuid.UUID | None = None
    preview_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)
    license_code: str
    status: ContentPackStatus
    created_at: datetime
    updated_at: datetime
    approved_at: datetime | None = None


class StudioversePackListResponse(BaseModel):
    total: int
    items: list[StudioverseCreatorPackView] = Field(default_factory=list)


class StudioverseMarketplacePackView(BaseModel):
    id: uuid.UUID
    creator_user_id: uuid.UUID
    creator_name: str | None = None
    title: str
    description: str
    localized_fields: dict = Field(default_factory=dict)
    category: ContentPackCategory
    niche_slugs: list[str] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    price_eur: Decimal | None = None
    price_raww: int | None = None
    currency: str
    cover_media_asset_id: uuid.UUID | None = None
    preview_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)
    license_code: str
    status: ContentPackStatus
    updated_at: datetime


class StudioverseMarketplaceListResponse(BaseModel):
    total: int
    items: list[StudioverseMarketplacePackView] = Field(default_factory=list)


class StudioverseCheckoutRequest(BaseModel):
    payment_method: ContentPackPaymentMethod


class StudioverseOrderView(BaseModel):
    id: uuid.UUID
    buyer_user_id: uuid.UUID
    content_pack_id: uuid.UUID
    price_eur_paid: Decimal
    price_raww_paid: int
    payment_method: ContentPackPaymentMethod
    stripe_payment_intent_id: str | None = None
    status: ContentPackOrderStatus
    created_at: datetime
    updated_at: datetime


class StudioverseCheckoutResponse(BaseModel):
    order: StudioverseOrderView
    payment_intent_client_secret: str | None = None


class StudioverseOrdersResponse(BaseModel):
    total: int
    items: list[StudioverseOrderView] = Field(default_factory=list)


class StudioverseDownloadResponse(BaseModel):
    order_id: uuid.UUID
    download_url: str
    downloads_used: int
    download_limit: int


class StudioverseAdminReviewRequest(BaseModel):
    decision: ContentPackReviewDecision
    notes: str | None = None


class StudioverseAdminTakedownRequest(BaseModel):
    reason: str


class StudioverseAdminPackListResponse(BaseModel):
    total: int
    items: list[StudioverseCreatorPackView] = Field(default_factory=list)
