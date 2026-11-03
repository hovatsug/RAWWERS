"""The Shelf: request and response shapes."""
from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel


class ShelfSettingsView(BaseModel):
    raww_eur_value: Decimal
    gbp_eur_rate: Decimal
    shelf_discount_percent: int
    inactivity_months: int
    warning_days: int
    level_band_raww: list[int]
    tier_max_level: dict[str, int]
    wishlist_max: int
    max_orders_per_month: int
    same_item_cooldown_days: int
    allowed_countries: list[str]
    free_shipping: bool
    shelf_enabled: bool
    #: Whether photographers can use it now (in production also needs
    #: approved terms).
    shelf_open: bool
    terms_text: str
    terms_draft: bool
    terms_reviewed_by: str | None = None
    terms_review_note: str | None = None
    terms_approved_at: datetime | None = None
    updated_at: datetime


class ShelfSettingsUpdateRequest(BaseModel):
    raww_eur_value: Decimal | None = None
    gbp_eur_rate: Decimal | None = None
    shelf_discount_percent: int | None = None
    inactivity_months: int | None = None
    warning_days: int | None = None
    level_band_raww: list[int] | None = None
    tier_max_level: dict[str, int] | None = None
    wishlist_max: int | None = None
    max_orders_per_month: int | None = None
    same_item_cooldown_days: int | None = None
    allowed_countries: list[str] | None = None
    free_shipping: bool | None = None
    shelf_enabled: bool | None = None


class ShelfTermsRequest(BaseModel):
    text: str


class ShelfTermsApproveRequest(BaseModel):
    reviewed_by: str
    note: str


class RawwPendingBooking(BaseModel):
    gig_id: uuid.UUID
    amount: int
    #: Held (a hold, or not yet settled for another reason): no date to give.
    held: bool
    #: When its earning settles, if nothing holds it.
    expected_at: datetime | None = None


class ProRawwView(BaseModel):
    shelf_open: bool
    spendable: int
    pending: int
    raww_eur_value: Decimal
    pending_bookings: list[RawwPendingBooking]
    #: When the spendable balance expires with no earning or spending first.
    expires_at: datetime | None = None
    #: Within the warning period before that.
    expiry_warning: bool
    inactivity_months: int


class RawwEntryView(BaseModel):
    id: uuid.UUID
    kind: str
    amount: int
    status: str
    gig_id: uuid.UUID | None = None
    source_type: str
    note: str | None = None
    created_at: datetime


class RawwHistoryResponse(BaseModel):
    total: int
    items: list[RawwEntryView]


class ShelfPriceHelper(BaseModel):
    suggested_price_raww: int
    street_price_eur: Decimal
    supplier_cost_eur: Decimal
    band_low_raww: int
    band_high_raww: int | None = None
    #: What the typed RAWW price is worth, and the margin over the cost.
    price_eur: Decimal | None = None
    margin_eur: Decimal | None = None
    #: Set when the price is outside its level's band. Advice, not a refusal.
    band_warning: str | None = None


class ShelfPriceHelperRequest(BaseModel):
    level: int
    price_raww: int | None = None
    street_price: Decimal
    street_currency: str = "GBP"
    supplier_cost: Decimal
    supplier_currency: str = "GBP"


class AdminShelfItemRequest(BaseModel):
    title: str
    brand: str | None = None
    category: str
    description: str | None = None
    image_url: str | None = None
    level: int
    price_raww: int
    street_price: Decimal
    street_currency: str = "GBP"
    supplier_cost: Decimal
    supplier_currency: str = "GBP"
    supplier_name: str
    supplier_sku: str | None = None
    supplier_url: str | None = None
    stock_status: str = "in_stock"
    active: bool = True
    #: Cameras it fits (catalogue keys). Empty: it fits everyone.
    camera_models: list[str] = []


class AdminShelfItemView(BaseModel):
    id: uuid.UUID
    title: str
    brand: str | None = None
    category: str
    description: str | None = None
    image_url: str | None = None
    level: int
    price_raww: int
    street_price: Decimal
    street_currency: str
    supplier_cost: Decimal
    supplier_currency: str
    supplier_name: str
    supplier_sku: str | None = None
    supplier_url: str | None = None
    stock_status: str
    active: bool
    camera_models: list[str]
    helper: ShelfPriceHelper
    updated_at: datetime


class AdminShelfItemsResponse(BaseModel):
    items: list[AdminShelfItemView]


class ShelfCameraModelView(BaseModel):
    normalised_model: str
    make: str | None = None
    display_name: str


class ShelfCameraModelsResponse(BaseModel):
    items: list[ShelfCameraModelView]


class ShelfWishlistResponse(BaseModel):
    item_ids: list[uuid.UUID]
    limit: int


class ShelfBrowseItem(BaseModel):
    id: uuid.UUID
    title: str
    brand: str | None = None
    category: str
    description: str | None = None
    image_url: str | None = None
    level: int
    price_raww: int
    in_stock: bool
    #: Made for a camera they own (not a universal item).
    fits_your_gear: bool
    wished: bool
    affordable: bool
    #: On a level their tier does not unlock yet: a teaser, not orderable.
    locked: bool


class ShelfBrowseLevel(BaseModel):
    level: int
    band_raww: int
    locked: bool
    #: The tier that unlocks a locked level.
    unlocks_at_tier: str | None = None
    items: list[ShelfBrowseItem]


class ShelfBrowseResponse(BaseModel):
    tier: str
    max_level: int
    spendable: int
    #: False: show the prompt to add their camera, so compatible items show.
    has_camera: bool
    wishlist_max: int
    #: The monthly cap: orders counting against it (cancelled ones do not),
    #: the cap, and when it starts again (the first of next month, UTC).
    orders_this_month: int
    max_orders_per_month: int
    orders_reset_at: datetime
    terms_text: str
    terms_draft: bool
    levels: list[ShelfBrowseLevel]


class ShelfAddress(BaseModel):
    name: str | None = None
    line1: str | None = None
    line2: str | None = None
    city: str | None = None
    region: str | None = None
    postal_code: str | None = None
    country: str | None = None
    phone: str | None = None


class ShelfAddressResponse(BaseModel):
    address: ShelfAddress | None = None
    allowed_countries: list[str]


class PlaceShelfOrderRequest(BaseModel):
    item_id: uuid.UUID
    #: Made once by the app for this attempt: a second tap is the same order.
    client_request_id: str


class ShelfOrderView(BaseModel):
    id: uuid.UUID
    item_id: uuid.UUID
    title: str
    price_raww: int
    status: str
    placed_at: datetime
    ordered_at: datetime | None = None
    shipped_at: datetime | None = None
    delivered_at: datetime | None = None
    cancelled_at: datetime | None = None
    refunded_at: datetime | None = None
    tracking_code: str | None = None
    tracking_url: str | None = None
    cancel_reason: str | None = None
    #: The photographer may cancel it themselves (only while placed).
    can_cancel: bool


class ShelfOrdersResponse(BaseModel):
    items: list[ShelfOrderView]


class AdminShelfOrderEvent(BaseModel):
    from_status: str | None = None
    to_status: str
    actor_type: str
    actor_user_id: uuid.UUID | None = None
    note: str | None = None
    created_at: datetime


class AdminShelfOrderView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    pro_name: str | None = None
    item_id: uuid.UUID
    title: str
    supplier_name: str
    supplier_sku: str | None = None
    price_raww: int
    raww_eur_value: Decimal
    price_eur: Decimal
    status: str
    country: str
    #: Decrypted for the admin who fulfils it; null if it cannot be read.
    address: dict | None = None
    supplier_order_ref: str | None = None
    tracking_code: str | None = None
    tracking_url: str | None = None
    cancel_reason: str | None = None
    placed_at: datetime
    events: list[AdminShelfOrderEvent]


class AdminShelfOrdersResponse(BaseModel):
    items: list[AdminShelfOrderView]


class AdminShelfOrderedRequest(BaseModel):
    supplier_order_ref: str


class AdminShelfShippedRequest(BaseModel):
    tracking_code: str
    tracking_url: str | None = None


class AdminShelfCancelRequest(BaseModel):
    reason: str
    note: str | None = None


class AdminRawwLedgerEntry(BaseModel):
    id: uuid.UUID
    kind: str
    amount: int
    status: str
    gig_id: uuid.UUID | None = None
    source_type: str
    note: str | None = None
    actor_user_id: uuid.UUID | None = None
    created_at: datetime


class AdminRawwLedgerResponse(BaseModel):
    spendable: int
    pending: int
    items: list[AdminRawwLedgerEntry]


class AdminRawwAdjustRequest(BaseModel):
    amount: int
    note: str
    #: Made once by the form: a resubmit is the same adjustment.
    request_id: str | None = None
