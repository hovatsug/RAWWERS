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


class AvailabilityRuleView(BaseModel):
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


class PublicAvailabilityResponse(BaseModel):
    pro_user_id: uuid.UUID
    rules: list[AvailabilityRuleView]
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
