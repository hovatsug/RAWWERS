from __future__ import annotations

import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.models.niche import DeclaredLevel, SkillTier


class NicheView(BaseModel):
    id: uuid.UUID | None = None
    slug: str
    name: str
    name_key: str | None = None
    is_active: bool = True


class ProNicheInput(BaseModel):
    slug: str
    declared_level: DeclaredLevel | None = None
    is_primary: bool = False


class UpdateMyNichesRequest(BaseModel):
    primary_niche_slug: str | None = None
    niches: list[ProNicheInput] = Field(default_factory=list)


class ProNicheView(BaseModel):
    slug: str
    name: str
    declared_level: DeclaredLevel | None = None
    is_primary: bool


class UpdateMyNichesResponse(BaseModel):
    primary_niche_slug: str | None = None
    niches: list[ProNicheView] = Field(default_factory=list)


class PortfolioNicheTagsRequest(BaseModel):
    niche_slugs: list[str] = Field(default_factory=list)


class PortfolioNicheTagsResponse(BaseModel):
    media_asset_id: uuid.UUID
    niche_slugs: list[str] = Field(default_factory=list)


class ProNicheSkillView(BaseModel):
    niche_slug: str
    niche_name: str
    tier: SkillTier
    score: int = 0
    verified: bool = False
    gigs_completed: int = 0
    avg_rating: float = 0.0
    review_count: int = 0
    capability_score: int
    certification_score: int
    confidence: float
    evidence_gigs: int
    evidence_reviews: int
    evidence_portfolio: int
    breakdown: dict[str, Any] = Field(default_factory=dict)
    badges: list[str] = Field(default_factory=list)
    last_promotion_at: datetime | None = None
    last_demotion_at: datetime | None = None
    updated_at: datetime


class ProNicheSkillListResponse(BaseModel):
    pro_user_id: uuid.UUID
    items: list[ProNicheSkillView] = Field(default_factory=list)


class AdminNicheSkillOverrideRequest(BaseModel):
    tier: SkillTier | None = None
    score: int | None = Field(default=None, ge=0, le=100)
    verified: bool | None = None
    capability_score: int | None = Field(default=None, ge=0, le=100)
    certification_score: int | None = Field(default=None, ge=0, le=100)
    reason: str
    expires_at: datetime | None = None


class NicheTierThresholdRule(BaseModel):
    min_score: int = 0
    min_gigs: int = 0
    min_rating: float = 0.0
    requires_verified: bool = False


class NicheTierPolicyView(BaseModel):
    niche_id: uuid.UUID
    thresholds: dict[str, NicheTierThresholdRule] = Field(default_factory=dict)
    updated_at: datetime | None = None


class NicheTierPolicyUpsertRequest(BaseModel):
    thresholds: dict[str, NicheTierThresholdRule] = Field(default_factory=dict)


class AdminNicheSkillOverrideV2Request(BaseModel):
    tier: SkillTier | None = None
    score: int | None = Field(default=None, ge=0, le=100)
    verified: bool | None = None
    note: str


class AdminNicheSkillRecalcRequest(BaseModel):
    pro_user_id: uuid.UUID | None = None
    niche_id: uuid.UUID | None = None
