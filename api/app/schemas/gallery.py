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
    #: After the selection closed: until when photos may still be added
    #: (null before it closes, or on a booking from before add-ons), whether
    #: that is still open, and what the client has already taken (greyed,
    #: not selectable, not removable). Empty for the photographer.
    addon_window_ends_at: datetime | None = None
    addon_open: bool = False
    chosen_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)


class AddonQuoteResponse(BaseModel):
    """What adding `adding` photos costs now: total(chosen + adding) -
    total(chosen), on the booking's own curve."""

    already_chosen: int
    adding: int
    amount: Decimal
    currency: str
    window_ends_at: datetime | None = None


class StartAddonRequest(BaseModel):
    media_asset_ids: list[uuid.UUID]
    #: One id per attempt: a second tap is the same add-on.
    client_request_id: str


class StartAddonResponse(BaseModel):
    addon_id: uuid.UUID
    amount: Decimal
    currency: str
    #: Null when nothing is owed (the photos were added at once) or when the
    #: add-on is already paid.
    payment_intent_client_secret: str | None = None
    status: str


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
    #: The gallery's (the booking's) currency; `difference_amount` is in it.
    currency: str
    difference_payment_intent_id: str | None = None
    difference_payment_intent_client_secret: str | None = None


class UpsellCreateIntentResponse(BaseModel):
    purchase_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str
    status: UpsellPurchaseStatus
    discount_amount: Decimal | None = None
    points_spent: int | None = None
    currency: str


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
    # How many days after finishing the client may still add photos (the
    # finish dialog says so).
    addon_days: int = 7
    # What submitting now would refund: the client paid for more than they
    # chose, and the difference comes back (price_reduction). Zero otherwise.
    refund_amount: Decimal = Decimal("0.00")
    # What one more photo would add to amount_due - the change in the charge,
    # not the curve's price for that photo, so it is zero while the running
    # total is still under what was already paid. Null when the gallery holds
    # no more photos to add.
    next_photo_price: Decimal | None = None

    extras_count: int
    can_submit: bool
    photos_still_needed: int
