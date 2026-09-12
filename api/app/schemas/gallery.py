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
    difference_required: bool = False
    difference_amount: Decimal | None = None
    difference_payment_intent_id: str | None = None
    difference_payment_intent_client_secret: str | None = None


class UpsellCreateIntentResponse(BaseModel):
    purchase_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str
    status: UpsellPurchaseStatus
    discount_amount: Decimal | None = None
    points_spent: int | None = None


class UpsellCreateIntentRequest(BaseModel):
    points_to_spend: int | None = Field(default=None, ge=1)
    share_link_id: uuid.UUID | None = None


class DownloadsResponse(BaseModel):
    gallery_id: uuid.UUID
    urls: dict[str, str]


class SelectionQuoteResponse(BaseModel):
    """What a selection of this size costs, computed by the same code that
    charges for it. Every money field is a Decimal and serialises as a string
    - a float here would round someone's bill."""

    selected_count: int
    included_photos: int
    minimum_photos: int
    currency: str

    # The whole selection, including what was collected at booking.
    amount_total: Decimal
    amount_paid: Decimal
    # What submitting now would charge. Never negative.
    amount_due: Decimal
    # What one more photo would add to amount_due - the change in the charge,
    # not the curve's price for that photo, so it is zero while the running
    # total is still under what was already paid. Null when the gallery holds
    # no more photos to add.
    next_photo_price: Decimal | None = None

    extras_count: int
    can_submit: bool
    photos_still_needed: int
