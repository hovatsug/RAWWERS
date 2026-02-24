import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.gallery import ProofGalleryStatus, SelectionStatus, UpsellPurchaseStatus


class CreateProofGalleryRequest(BaseModel):
    included_photos: int
    extra_photo_price: Decimal


class ProofGalleryResponse(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    pro_user_id: uuid.UUID
    client_user_id: uuid.UUID
    included_photos: int
    extra_photo_price: Decimal
    currency: str
    status: ProofGalleryStatus
    published_at: datetime | None = None
    created_at: datetime
    updated_at: datetime


class AddGalleryItemsRequest(BaseModel):
    media_asset_ids: list[uuid.UUID]
    sort_order_optional: int | None = None


class PublishGalleryResponse(BaseModel):
    ok: bool
    status: ProofGalleryStatus


class GalleryItemView(BaseModel):
    media_asset_id: uuid.UUID
    sort_order: int
    thumbnail_url: str | None = None
    watermark_preview_url: str | None = None


class GalleryDetailResponse(BaseModel):
    gallery: ProofGalleryResponse
    items: list[GalleryItemView]


class SaveSelectionRequest(BaseModel):
    media_asset_ids: list[uuid.UUID]


class SelectionResponse(BaseModel):
    selection_id: uuid.UUID
    version: int
    status: SelectionStatus
    selected_count: int


class SubmitSelectionResponse(BaseModel):
    selection_id: uuid.UUID
    selected_count: int
    included_photos: int
    extras_count: int
    gallery_status: ProofGalleryStatus
    upsell_required: bool
    payment_intent_id: str | None = None
    payment_intent_client_secret: str | None = None


class UpsellCreateIntentResponse(BaseModel):
    purchase_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str
    status: UpsellPurchaseStatus


class DownloadsResponse(BaseModel):
    gallery_id: uuid.UUID
    urls: dict[str, str]
