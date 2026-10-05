from __future__ import annotations

import uuid
from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.niche import SkillTier

from app.models.media_rights import GigConsentLevel
from app.schemas.review import ReviewView


class ClientAccessResponse(BaseModel):
    enabled: bool
    reason: str
    waitlist_available: bool = True


class ClientWaitlistCreateRequest(BaseModel):
    email: str
    country: str
    city: str
    niche_slug: str | None = None
    # "client" or "pro". Optional on the wire so the existing caller does
    # not break, but the marketing form always sends it - a waitlist that
    # cannot distinguish demand from supply cannot decide a launch market.
    role: str | None = None


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
    # Signed and short-lived. Null when the pro has no cover, or when the
    # cover is still being processed - both are ordinary states to render.
    cover_url: str | None = None
    city: str | None = None
    country: str | None = None
    min_price: Decimal | None = None
    max_price: Decimal | None = None
    # The per-photo rate of the package `min_price` comes from, and how many
    # photos that total covers. Null until the index row has been recomputed
    # since these columns landed, and a card falls back to the total alone -
    # which is what it showed before, rather than a guess.
    min_entry_rate: Decimal | None = None
    min_entry_photos: int | None = None
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
    # POST /v1/client/bookings/request requires niche_slug and rejects a
    # request whose slug does not match the package's niche. Without it here,
    # a client holding this response cannot name the niche and has to fetch
    # GET /v1/pro/{id}/packages and GET /v1/niches to do a join the server
    # already has in hand - two extra round trips on the highest-intent
    # action in the product.
    niche_slug: str
    title: str
    description: str | None = None
    duration_minutes: int
    # The per-photo entry rate. Named `price` for compatibility, which is
    # exactly how this went wrong: every client-facing screen rendered it as
    # the package price and a real package showed EUR 243 for work that
    # charges EUR 6,075. Prefer `entry_rate` below - it is the same number
    # with a name that cannot be misread.
    price: Decimal
    currency: str
    included_photos: int

    # What a photograph costs. The figure that should lead any price display,
    # because it is the one the whole pricing model is built from.
    entry_rate: Decimal
    # The smallest selection this package can be booked with.
    minimum_photos: int
    # What that smallest selection actually costs.
    #
    # Deliberately not entry_rate * minimum_photos. Photos past the tenth are
    # priced by the niche's decay curve, so multiplying is right only for flat
    # niches - it happens to match on real estate and food, and overstates a
    # portrait package by EUR 1,679. It comes from compute_minimum_amount(),
    # the same function the booking path charges from, so this card and the
    # invoice cannot disagree.
    starting_total: Decimal
    extra_photo_price: Decimal
    proofs_sla_days: int
    finals_sla_days: int


class ClientPortfolioItem(BaseModel):
    media_asset_id: uuid.UUID
    kind: str
    # Photos resolve to a signed thumbnail. Videos are served through Mux and
    # have no MediaObject rows, so `thumbnail_url` is null for them - see
    # docs/BACKEND_GAPS.md, "no video poster frames".
    thumbnail_url: str | None = None
    # Which niches this photo belongs to. Without it the client cannot split a
    # multi-niche portfolio at all: a wedding, a studio portrait and a festival
    # crowd shot arrive indistinguishable and render in one flat grid.
    niche_slugs: list[str] = Field(default_factory=list)


class ClientProfileNiche(BaseModel):
    """One niche a photographer actually has work in.

    Derived from the tags on their portfolio rather than from their skill
    rows. `recompute_pro_niche_skills` writes a row for every active niche, so
    skills say nothing about where someone works - a tab list built from them
    would offer twelve tabs, ten of them empty.
    """

    slug: str
    name: str
    tier: SkillTier
    photo_count: int
    # What the photographer wrote about this particular kind of work. Null
    # when they have not written one, and the client falls back to the general
    # bio rather than rendering an empty section.
    description: str | None = None


class ClientProProfileResponse(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    headline: str | None = None
    cover_media_asset_id: uuid.UUID | None = None
    cover_url: str | None = None
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
    portfolio_preview: list[ClientPortfolioItem] = Field(default_factory=list)
    # Empty for a single-niche photographer, which is the signal the client
    # uses to render no tab bar at all rather than one redundant tab.
    niches: list[ClientProfileNiche] = Field(default_factory=list)
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


class ClientAvailabilityStart(BaseModel):
    """One time a shoot could start.

    Both forms, because they answer different questions. `start_at` is the
    instant, with the photographer's offset - what a booking request sends.
    `local_time` is the wall-clock time where the photographer is, "10:00" -
    what the client reads. An app that parses the instant gets it in UTC and
    would show the time in the phone's zone, which is wrong for anyone
    browsing from somewhere else.
    """

    start_at: datetime
    local_time: str
    # Where the window ends. For an hourly or 4-hour package that is the
    # shoot's length later; for a block it is the block's end, and for a full
    # day, midnight - the window the client is asking for.
    end_at: datetime
    local_end_time: str
    # "morning" / "afternoon" / "evening" for a block package, else None.
    label: str | None = None


class ClientAvailabilityDay(BaseModel):
    """One day of a photographer's calendar, as a client may see it.

    Open or not, and when a shoot of the chosen package could start. Never
    why a day is closed: blocked time, other clients' bookings and a full day
    all read the same, because none of them is the client's business.
    """

    date: date
    open: bool
    # On the photographer's local date - the shoot happens where they are.
    start_times: list[ClientAvailabilityStart] = Field(default_factory=list)


class ClientAvailabilityResponse(BaseModel):
    timezone: str
    # False when the photographer has no working hours at all, so the app
    # can say "not taking bookings through the calendar yet" rather than show
    # a month of closed days that reads as fully booked.
    has_schedule: bool
    notice_hours: int
    # interval / blocks / full_day - how the app should present the windows.
    scheduling_preset: str = "interval"
    days: list[ClientAvailabilityDay] = Field(default_factory=list)


class ClientBookingStatusResponse(BaseModel):
    booking_id: uuid.UUID
    booking_status: str
    gig_id: uuid.UUID | None = None
    gig_status: str | None = None
    payment_status: str | None = None
    # The client's way into their own photographs. Every gallery route is
    # keyed by gallery id, and the only route that creates one is pro-only,
    # so without this there was no path from "my booking" to "my photos" at
    # all - a client who had paid could not reach what they paid for.
    proof_gallery_id: uuid.UUID | None = None
    # Which screen to open: `published` means there is a selection to make,
    # `selection_submitted` means the photos are chosen and the downloads
    # screen is the right destination. Carried here so the app does not have
    # to fetch the gallery to find out which one to show.
    proof_gallery_status: str | None = None
    timeline: list[dict] = Field(default_factory=list)
    next_actions: list[str] = Field(default_factory=list)
    # The client's own review of this booking, whatever its status - so the
    # app can say "you reviewed this" rather than offer a form the server
    # would refuse. Includes a review a moderator hid, which the public list
    # no longer shows. Null for no review yet, and always null for the
    # photographer, who reads reviews from the public list.
    review: ReviewView | None = None


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


class ProListingPreviewResponse(BaseModel):
    """What a client sees, returned to the pro who owns it.

    `card` is built by the same function that builds the Discover feed, so
    the preview cannot drift from the real thing - if editing a package
    changes the price range here, it changes it there.
    """

    card: ClientDiscoverCard
    # Whether this card is actually reachable in Discover right now, and if
    # not, the specific reasons. Discover filters on approved KYC, accepting
    # bookings, completeness >= 60 and a priced package; a pro looking at a
    # preview of a listing nobody can find deserves to be told which.
    is_live: bool
    blocking_reasons: list[str] = Field(default_factory=list)
    # Free days in the next fortnight, as the card's availability line. Null
    # when the pro has set no weekly rules at all, which reads differently
    # from "no free days".
    available_days_next_14: int | None = None


class ClientHomeRow(BaseModel):
    """One horizontal row on the client home screen.

    `key` is stable and machine-readable so the app can special-case
    presentation; `title` is what the client reads. Both are decided by the
    server rather than the app, because what belongs in a row is a fairness
    rule - "new photographers" must never quietly blend into "most
    experienced" - and a rule implemented in more than one place drifts. This
    project has already paid for that once, in pricing.
    """

    key: str
    title: str
    subtitle: str | None = None
    # Never empty. A row with nothing honest to show is omitted from the
    # response entirely rather than sent for the app to render as a blank
    # shelf.
    items: list[ClientDiscoverCard] = Field(default_factory=list)


class ClientHomeNiche(BaseModel):
    """The niche a home response is narrowed to."""

    slug: str
    name: str


class ClientHomeResponse(BaseModel):
    rows: list[ClientHomeRow] = Field(default_factory=list)
    # True when the caller is a guest, so the app can show the sign-in prompt
    # the deeper-browsing limit will eventually enforce.
    guest_limited: bool = False
    # Set when the request asked for one niche's page, even when `rows` is
    # empty: a real niche with nobody in this city is an honest absence, and
    # the app needs the name to say so rather than treat it as a dead link.
    niche: ClientHomeNiche | None = None
