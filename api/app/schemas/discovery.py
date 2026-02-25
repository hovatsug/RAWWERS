import uuid
from decimal import Decimal

from pydantic import BaseModel, Field


class ProCard(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    city: str | None = None
    styles: list[str] = Field(default_factory=list)
    min_price: Decimal | None = None
    currency: str
    portfolio_photo_count: int
    portfolio_video_count: int
    avg_rating: Decimal
    review_count: int
    ranking_score: Decimal
    primary_niche_id: uuid.UUID | None = None
    top_niches: list[dict] = Field(default_factory=list)


class DiscoverProsResponse(BaseModel):
    total: int
    items: list[ProCard]


class PublicProPackageView(BaseModel):
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
    addons: list[dict]


class PublicPortfolioPhoto(BaseModel):
    media_asset_id: uuid.UUID
    thumbnail_url: str | None = None
    watermark_preview_url: str | None = None


class PublicPortfolioVideo(BaseModel):
    media_asset_id: uuid.UUID
    playback_id: str | None = None


class ProPublicProfileResponse(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    headline: str | None = None
    bio: str | None = None
    city: str | None = None
    country: str | None = None
    styles: list[str] = Field(default_factory=list)
    packages: list[PublicProPackageView]
    portfolio_photos: list[PublicPortfolioPhoto]
    portfolio_videos: list[PublicPortfolioVideo]
    gigs_completed: int
    gigs_cancelled: int
    disputes_count: int
    avg_response_minutes: int | None = None
    avg_rating: Decimal
    review_count: int
    ranking_score: Decimal


class MatchRequest(BaseModel):
    city: str | None = None
    styles: list[str] = Field(default_factory=list)
    budget: Decimal | None = None
    date_range: dict | None = None
    purpose: str | None = None
    limit: int = 10


class MatchCandidate(BaseModel):
    pro_user_id: uuid.UUID
    ranking_score: Decimal
    reasons: list[str]


class MatchResponse(BaseModel):
    items: list[MatchCandidate]


class AnalyticsCreateRequest(BaseModel):
    event_name: str
    properties: dict = Field(default_factory=dict)
    session_id: str | None = None
