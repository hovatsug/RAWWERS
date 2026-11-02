from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class MarketingTermView(BaseModel):
    months: int
    #: RAW credit (reward points) a grant of this term earns, before the
    #: once-per-booking and monthly limits.
    credit: int


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
