from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.media_rights import GigConsentLevel


class ClientAccessResponse(BaseModel):
    enabled: bool
    reason: str
    waitlist_available: bool = True


class ClientWaitlistCreateRequest(BaseModel):
    email: str
    country: str
    city: str
    niche_slug: str | None = None


class ClientWaitlistCreateResponse(BaseModel):
    accepted: bool = True


class ClientPreferenceView(BaseModel):
    preferred_niches: list[str] = Field(default_factory=list)
    budget_min: Decimal | None = None
    budget_max: Decimal | None = None
    style_tags: list[str] = Field(default_factory=list)
    location: dict = Field(default_factory=dict)
    consent_default: GigConsentLevel
    updated_at: datetime


class ClientPreferenceUpdateRequest(BaseModel):
    preferred_niches: list[str] = Field(default_factory=list)
    budget_min: Decimal | None = None
    budget_max: Decimal | None = None
    style_tags: list[str] = Field(default_factory=list)
    location: dict = Field(default_factory=dict)
    consent_default: GigConsentLevel = GigConsentLevel.none


class ClientDiscoverCard(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    headline: str | None = None
    cover_media_asset_id: uuid.UUID | None = None
    city: str | None = None
    country: str | None = None
    min_price: Decimal | None = None
    max_price: Decimal | None = None
    currency: str
    avg_rating: Decimal
    review_count: int
    top_niches: list[dict] = Field(default_factory=list)
    portfolio_photo_count: int
    portfolio_video_count: int


class ClientDiscoverResponse(BaseModel):
    total: int
    items: list[ClientDiscoverCard] = Field(default_factory=list)
    guest_limited: bool = False


class ClientMatchCreateRequest(BaseModel):
    country: str
    city: str
    niche_slug: str
    budget_min: Decimal | None = None
    budget_max: Decimal | None = None
    style_tags: list[str] = Field(default_factory=list)


class ClientMatchCard(BaseModel):
    pro_user_id: uuid.UUID
    rank: int
    score: Decimal
    card: ClientDiscoverCard
    score_breakdown: dict | None = None


class ClientMatchResponse(BaseModel):
    match_request_id: uuid.UUID
    items: list[ClientMatchCard] = Field(default_factory=list)


class ClientProfilePackage(BaseModel):
    id: uuid.UUID
    title: str
    description: str | None = None
    duration_minutes: int
    price: Decimal
    currency: str
    included_photos: int
    extra_photo_price: Decimal
    proofs_sla_days: int
    finals_sla_days: int


class ClientProProfileResponse(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    headline: str | None = None
    cover_media_asset_id: uuid.UUID | None = None
    bio: str | None = None
    city: str | None = None
    country: str | None = None
    styles: list[str] = Field(default_factory=list)
    avg_rating: Decimal
    review_count: int
    portfolio_photo_count: int
    portfolio_video_count: int
    packages: list[ClientProfilePackage] = Field(default_factory=list)
    portfolio_preview_asset_ids: list[uuid.UUID] = Field(default_factory=list)
    is_guest_view: bool = False


class BookingDateWindow(BaseModel):
    start_at: datetime
    end_at: datetime


class ClientBookingRequestCreateRequest(BaseModel):
    pro_user_id: uuid.UUID
    niche_slug: str
    date_window: BookingDateWindow
    location: str | None = None
    package_id: uuid.UUID
    notes: str | None = None
    consent_level: GigConsentLevel | None = None


class ClientBookingRequestCreateResponse(BaseModel):
    booking_id: uuid.UUID
    status: str


class ClientBookingStatusResponse(BaseModel):
    booking_id: uuid.UUID
    booking_status: str
    gig_id: uuid.UUID | None = None
    gig_status: str | None = None
    payment_status: str | None = None
    timeline: list[dict] = Field(default_factory=list)
    next_actions: list[str] = Field(default_factory=list)


class ClientBookingListItem(BaseModel):
    """Summary row for the client's bookings list.

    Carries the same booking/gig/payment status triple the detail route
    leads with, so a list row and a detail header agree, but omits
    `timeline` and `next_actions`: both are computed per booking (the
    timeline is a second query for transitions) and neither is rendered in
    a list. The detail route remains the way to get them.
    """

    booking_id: uuid.UUID
    booking_status: str
    gig_id: uuid.UUID | None = None
    gig_status: str | None = None
    payment_status: str | None = None
    requested_start: datetime
    requested_end: datetime
    location_text: str | None = None
    expires_at: datetime
    created_at: datetime


class ClientBookingListResponse(BaseModel):
    items: list[ClientBookingListItem] = Field(default_factory=list)
    next_cursor: str | None = None


class ClientBookingPayRequest(BaseModel):
    payment_mode: str = Field(pattern="^(full|deposit)$")
    points_to_spend: int | None = Field(default=None, ge=1)


class ClientBookingPayResponse(BaseModel):
    booking_id: uuid.UUID
    gig_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str
    mode: str


class ClientFunnelCityMetrics(BaseModel):
    country: str
    city: str
    discover_views: int
    pro_profile_views: int
    booking_requests: int
    payments_succeeded: int
    proofs_published: int
    extras_purchased: int
    disputes_opened: int
    discover_to_profile_rate: float
    profile_to_booking_rate: float
    booking_to_payment_rate: float
    cohorts: list[dict] = Field(default_factory=list)


class ClientFunnelReportResponse(BaseModel):
    start_at: datetime
    end_at: datetime
    items: list[ClientFunnelCityMetrics] = Field(default_factory=list)
