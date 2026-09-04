import uuid
from datetime import datetime, time
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.booking import BookingRequestStatus


class ProProfileView(BaseModel):
    user_id: uuid.UUID
    display_name: str | None = None
    headline: str | None = None
    cover_media_asset_id: uuid.UUID | None = None
    bio: str | None = None
    city: str | None = None
    country: str | None = None
    languages: list[str] = Field(default_factory=list)
    styles: list[str] = Field(default_factory=list)
    gear: dict = Field(default_factory=dict)
    # How far the pro will travel for a shoot. Null means not answered yet,
    # which is not the same as zero - a client filtering on distance has to
    # be able to tell "will not travel" from "has not said".
    travel_radius_km: int | None = None
    is_accepting_bookings: bool
    completeness_score: int
    kyc_status: str


class ProProfileUpdateRequest(BaseModel):
    display_name: str | None = None
    headline: str | None = None
    cover_media_asset_id: uuid.UUID | None = None
    bio: str | None = None
    city: str | None = None
    country: str | None = None
    languages: list[str] | None = None
    styles: list[str] | None = None
    gear: dict | None = None
    travel_radius_km: int | None = Field(default=None, ge=0, le=2000)


class ProActivateResponse(BaseModel):
    is_accepting_bookings: bool
    completeness_score: int
    kyc_status: str


class ProPackageCreateRequest(BaseModel):
    title: str
    niche_id: uuid.UUID | None = None
    niche_slug: str | None = None
    description: str | None = None
    duration_minutes: int
    price: Decimal
    currency: str = "EUR"
    included_photos: int
    extra_photo_price: Decimal
    proofs_sla_days: int = 3
    finals_sla_days: int = 7
    addons: list[dict] = Field(default_factory=list)


class ProPackageUpdateRequest(BaseModel):
    title: str | None = None
    niche_id: uuid.UUID | None = None
    niche_slug: str | None = None
    description: str | None = None
    duration_minutes: int | None = None
    price: Decimal | None = None
    currency: str | None = None
    included_photos: int | None = None
    extra_photo_price: Decimal | None = None
    proofs_sla_days: int | None = None
    finals_sla_days: int | None = None
    addons: list[dict] | None = None
    is_active: bool | None = None


class ProPackageView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    niche_id: uuid.UUID
    title: str
    description: str | None = None
    duration_minutes: int
    price: Decimal
    currency: str
    included_photos: int
    extra_photo_price: Decimal
    proofs_sla_days: int
    finals_sla_days: int
    addons: list[dict]
    is_active: bool


class AvailabilityRuleInput(BaseModel):
    day_of_week: int
    start_time: time
    end_time: time


class ReplaceAvailabilityRulesRequest(BaseModel):
    rules: list[AvailabilityRuleInput]


class PublicAvailabilityRuleView(BaseModel):
    """A weekly rule as the public profile endpoint exposes it.

    Named apart from scheduling.AvailabilityRuleView deliberately. The two
    shared a name, and FastAPI's collision handling qualifies the schema
    keys but leaves both titles identical - which collapsed them into one
    class in the generated Dart client, silently keeping this shape for the
    scheduling endpoint that returns the other one.
    """

    id: uuid.UUID
    day_of_week: int
    start_time: time
    end_time: time


class BlackoutCreateRequest(BaseModel):
    start_at: datetime
    end_at: datetime
    reason: str | None = None


class BlackoutView(BaseModel):
    id: uuid.UUID
    start_at: datetime
    end_at: datetime
    reason: str | None = None
    # Populated by the deprecated create route, so a caller that reads only
    # the body still learns the route is going away. Null everywhere else.
    deprecation_notice: str | None = None


class PublicAvailabilityResponse(BaseModel):
    pro_user_id: uuid.UUID
    rules: list[PublicAvailabilityRuleView]
    blackouts: list[BlackoutView]


class BookingRequestCreateRequest(BaseModel):
    package_id: uuid.UUID
    requested_start: datetime
    requested_end: datetime
    location_text: str | None = None
    notes: str | None = None


class BookingRequestView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    client_user_id: uuid.UUID
    package_id: uuid.UUID
    requested_start: datetime
    requested_end: datetime
    location_text: str | None = None
    notes: str | None = None
    status: BookingRequestStatus
    expires_at: datetime


class BookingRequestListItem(BookingRequestView):
    """A list row is the detail view plus the two fields a queue screen needs.

    `expires_at` is inherited from BookingRequestView and is the response
    deadline: a pending request auto-declines when it passes (see
    `app.tasks.scheduled.expire_booking_requests`). `seconds_until_expiry`
    is derived here rather than left to the client because every client
    would otherwise re-derive it against its own clock, and a phone with a
    skewed clock would show a photographer the wrong time remaining on the
    one decision the product gives them a deadline for. It is negative once
    the deadline has passed, and null for any request no longer pending -
    a declined request has no countdown.
    """

    created_at: datetime
    seconds_until_expiry: int | None = None


class BookingRequestListResponse(BaseModel):
    items: list[BookingRequestListItem] = Field(default_factory=list)
    next_cursor: str | None = None


class BookingDecisionRequest(BaseModel):
    reason: str | None = None


class AcceptBookingResponse(BaseModel):
    booking_request: BookingRequestView
    gig_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str


class ProPortfolioItem(BaseModel):
    media_asset_id: uuid.UUID
    kind: str
    # Signed and short-lived; null while the asset is still processing, or
    # for a video, whose poster frame is a separate gap (BACKEND_GAPS.md).
    thumbnail_url: str | None = None
    niche_slugs: list[str] = Field(default_factory=list)
    is_cover: bool = False
    created_at: datetime


class ProPortfolioResponse(BaseModel):
    items: list[ProPortfolioItem] = Field(default_factory=list)
    photo_count: int
    video_count: int
    # What GET /v1/pro/onboarding/checks requires before the portfolio step
    # passes, returned here so the gallery can show progress toward it
    # without a second call and without hardcoding the number client-side.
    photo_minimum: int


class ProExtraImagePriceItem(BaseModel):
    niche_slug: str
    unit_price: Decimal


class ProExtraImagePriceUpdateRequest(BaseModel):
    items: list[ProExtraImagePriceItem] = Field(default_factory=list)


class ProExtraImagePriceRow(BaseModel):
    niche_slug: str
    niche_name: str
    # What the pro asked for, and what clients will actually be charged
    # after the platform's per-tier bounds are applied. They differ when a
    # pro prices outside the policy, and showing only the second would make
    # the app look like it ignored the number they typed.
    configured_unit_price: Decimal
    applied_unit_price: Decimal
    policy_min: Decimal
    policy_max: Decimal | None = None
    currency: str


class ProExtraImagePriceResponse(BaseModel):
    items: list[ProExtraImagePriceRow] = Field(default_factory=list)


class ProPricingCurvePoint(BaseModel):
    photo_count: int
    total: Decimal
    # The average the client ends up paying per photo at this count. The
    # decay is the entire argument for the pricing model, and it is only
    # legible next to the per-photo number.
    per_photo: Decimal


class ProNichePricingPreviewResponse(BaseModel):
    niche_id: uuid.UUID
    niche_slug: str
    niche_name: str
    tier: str
    entry_price: Decimal
    currency: str
    # Null max means the platform sets no ceiling for this niche and tier.
    entry_price_min: Decimal
    entry_price_max: Decimal | None = None
    within_cap: bool
    curve: list[ProPricingCurvePoint] = Field(default_factory=list)
