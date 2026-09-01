from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class SearchProsItem(BaseModel):
    id: str
    display_name: str | None = None
    headline: str | None = None
    cover_media_asset_id: str | None = None
    city: str | None = None
    country: str | None = None
    niche_slugs: list[str] = Field(default_factory=list)
    top_niche: str | None = None
    price_min: float | None = None
    price_max: float | None = None
    avg_rating: float | None = None
    review_count: int = 0
    completed_gigs_total: int = 0
    last_active_at: str | None = None


class SearchCoursesItem(BaseModel):
    id: str
    title: str
    summary: str | None = None
    niche_slug: str | None = None
    level: str
    is_mandatory: bool
    price: float | None = None
    currency: str | None = None
    instructor_name: str | None = None
    updated_at: str | None = None


class SearchProductsItem(BaseModel):
    id: str
    title: str
    description: str | None = None
    category: str | None = None
    brand: str | None = None
    price: float
    is_available: bool
    stock_status: str
    shipping_estimate_days: int | None = None
    partner_name: str | None = None
    updated_at: str | None = None


class SearchRepairPartnersItem(BaseModel):
    id: str
    name: str
    country: str
    city: str
    categories_supported: list[str] = Field(default_factory=list)
    brands_supported: list[str] = Field(default_factory=list)
    loaner_supported: bool
    loaner_categories: list[str] = Field(default_factory=list)
    sla_quote_hours: int | None = None
    sla_turnaround_days: int | None = None
    score_summary: dict = Field(default_factory=dict)
    updated_at: str | None = None


class SearchResponse(BaseModel):
    total: int
    items: list[dict]
    used_fallback: bool = False


class AdminSearchStatusResponse(BaseModel):
    provider: str
    enabled: bool
    search_index_prefix: str
    indexes: list[dict]
    last_sync_at: str | None = None
    feature_search_enabled: bool
    feature_force_db_fallback: bool


class AdminSearchRebuildRequest(BaseModel):
    index: str = "all"


class AdminSearchRebuildResponse(BaseModel):
    queued_events: int
    indexes: list[str]


class AdminSearchPurgeResponse(BaseModel):
    purged: list[str]
