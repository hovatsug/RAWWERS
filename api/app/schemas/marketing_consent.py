from __future__ import annotations

import uuid
from datetime import date, datetime

from decimal import Decimal

from pydantic import BaseModel, Field


class MarketingTermView(BaseModel):
    months: int
    #: RAW credit (reward points) a grant of this term earns, before the
    #: once-per-booking and monthly limits.
    credit: int
    #: The same in euros (points / 100), which is how the app shows it.
    credit_eur: Decimal = Decimal("0.00")


class MarketingPhotoView(BaseModel):
    media_asset_id: uuid.UUID
    thumbnail_url: str | None = None


class MarketingConsentOfferResponse(BaseModel):
    offered: bool
    #: Why not, when not: not_available, rate_first, photographer_not_opted_in,
    #: photographer_turned_it_off, includes_children, nothing_left.
    reason: str | None = None
    wording_version: str | None = None
    wording_text: str | None = None
    #: Organic use on RAWWERS's own channels; nothing else exists.
    scope: str = "rawwers_organic"
    terms: list[MarketingTermView] = Field(default_factory=list)
    default_term_months: int = 12
    photographer_credit: str | None = None
    photos: list[MarketingPhotoView] = Field(default_factory=list)
    #: Whether a grant now earns credit, said before the client confirms.
    #: When not: monthly_cap (3 credited permissions this month), budget (no
    #: credit is available this month) or already_credited (this booking).
    #: Permission can still be given without credit.
    credit_available: bool = True
    credit_unavailable_reason: str | None = None


class GrantMarketingConsentRequest(BaseModel):
    media_asset_ids: list[uuid.UUID] = Field(max_length=500)
    term_months: int = 12
    #: Everyone shown is an adult who agrees, or the client is their parent
    #: or guardian.
    people_confirmed: bool = False


class MarketingConsentView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    media_asset_id: uuid.UUID
    thumbnail_url: str | None = None
    photographer_credit: str
    scope: str
    term_months: int
    granted_at: datetime
    ends_at: datetime
    status: str
    withdrawn_at: datetime | None = None
    renews_consent_id: uuid.UUID | None = None


class GrantMarketingConsentResponse(BaseModel):
    items: list[MarketingConsentView]
    #: RAW credit given for this grant; 0 when none (already credited for the
    #: booking, the monthly limit reached, or the setting is 0).
    credit: int
    #: The credit given, in euros.
    credit_eur: Decimal = Decimal("0.00")


class MyMarketingConsentsResponse(BaseModel):
    items: list[MarketingConsentView]


class WithdrawMarketingConsentRequest(BaseModel):
    consent_ids: list[uuid.UUID] | None = None
    all: bool = False


class WithdrawMarketingConsentResponse(BaseModel):
    withdrawn: int


class RenewMarketingConsentRequest(BaseModel):
    consent_ids: list[uuid.UUID] = Field(min_length=1, max_length=500)
    term_months: int = 12


class ProMarketingAgreementView(BaseModel):
    opted_in: bool
    #: The clause shown, and the version a change is recorded under.
    wording_version: str
    wording_text: str
    #: When the photographer last changed it; null if never.
    recorded_at: datetime | None = None


class UpdateProMarketingAgreementRequest(BaseModel):
    opted_in: bool


class BookingMarketingSettingsView(BaseModel):
    allow_marketing: bool
    includes_children: bool
    #: A client has granted consent on this booking: no further changes.
    locked: bool
    #: The photographer's account-level opt-in.
    opted_in: bool


class UpdateBookingMarketingSettingsRequest(BaseModel):
    allow_marketing: bool | None = None
    includes_children: bool | None = None


class AdminMarketingConsentView(BaseModel):
    id: uuid.UUID
    media_asset_id: uuid.UUID
    thumbnail_url: str | None = None
    gig_id: uuid.UUID
    #: The client's first name only.
    client_first_name: str
    pro_user_id: uuid.UUID
    photographer_credit: str
    scope: str
    term_months: int
    granted_at: datetime
    ends_at: datetime
    status: str
    withdrawn_at: datetime | None = None
    expired_at: datetime | None = None
    #: How many recorded uses include it.
    uses: int = 0


class AdminMarketingConsentsResponse(BaseModel):
    items: list[AdminMarketingConsentView]


class MarketingOriginalLinkResponse(BaseModel):
    url: str
    expires_in_seconds: int


class RecordMarketingUseRequest(BaseModel):
    content_name: str = Field(min_length=1, max_length=300)
    used_on: date
    consent_ids: list[uuid.UUID] = Field(min_length=1, max_length=500)
    #: On a channel RAWWERS owns (its site, its social accounts): taken down
    #: within 30 days of a consent ending.
    owned_channel: bool = True


class MarketingUseConsentView(BaseModel):
    id: uuid.UUID
    status: str
    ends_at: datetime


class MarketingUseView(BaseModel):
    id: uuid.UUID
    content_name: str
    used_on: date
    owned_channel: bool
    #: The earliest end date of its consents, renewals followed.
    retire_by: date
    consents: list[MarketingUseConsentView]


class MarketingUsesResponse(BaseModel):
    items: list[MarketingUseView]


class MarketingTakeDownView(BaseModel):
    use_id: uuid.UUID
    content_name: str
    used_on: date
    consent_id: uuid.UUID
    #: withdrawn or expired.
    reason: str
    ended_at: datetime
    take_down_by: date


class MarketingTakeDownResponse(BaseModel):
    items: list[MarketingTakeDownView]


class MarketingWordingView(BaseModel):
    version: str
    audience: str
    language: str
    text: str
    #: draft (never reviewed), reviewed (published before, now replaced) or
    #: published (the one shown now).
    status: str
    #: Shown now, even if it is still the seeded draft.
    in_use: bool
    reviewed_by: str | None = None
    review_note: str | None = None
    created_at: datetime
    published_at: datetime | None = None


class MarketingWordingsResponse(BaseModel):
    items: list[MarketingWordingView]


class CreateMarketingWordingRequest(BaseModel):
    audience: str = Field(pattern="^(client|photographer)$")
    language: str = Field(pattern="^(en|pt)$")
    text: str = Field(min_length=1, max_length=20000)


class PublishMarketingWordingRequest(BaseModel):
    reviewed_by: str = Field(default="", max_length=300)
    note: str = Field(default="", max_length=2000)
