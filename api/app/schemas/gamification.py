from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.gamification import (
    CredentialMode,
    MilestoneDifficulty,
    MilestoneProgressStatus,
    MilestoneScope,
)
from app.models.niche import SkillTier


class CredentialView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    niche_id: uuid.UUID
    credential_code: str
    display_name: str
    tier: SkillTier
    mode: CredentialMode
    awarded_at: datetime
    meta: dict = Field(default_factory=dict)


class MilestoneView(BaseModel):
    id: uuid.UUID
    code: str
    name: str
    description: str
    scope: MilestoneScope
    niche_id: uuid.UUID | None = None
    difficulty: MilestoneDifficulty
    is_repeatable: bool
    cooldown_days: int | None = None
    start_at: datetime | None = None
    end_at: datetime | None = None
    criteria: dict = Field(default_factory=dict)
    reward_rule_code: str | None = None
    is_active: bool
    created_at: datetime
    updated_at: datetime


class MilestoneProgressView(BaseModel):
    milestone_id: uuid.UUID
    status: MilestoneProgressStatus
    progress_value: Decimal
    progress_meta: dict = Field(default_factory=dict)
    started_at: datetime
    completed_at: datetime | None = None
    last_evaluated_at: datetime | None = None
    completions_count: int = 0
    last_completed_at: datetime | None = None


class MyMilestoneItem(BaseModel):
    milestone: MilestoneView
    progress: MilestoneProgressView


class MyMilestonesResponse(BaseModel):
    total: int
    items: list[MyMilestoneItem]


class CycleEventView(BaseModel):
    id: uuid.UUID
    cycle_id: uuid.UUID
    user_id: uuid.UUID
    event_type: str
    points_delta: int
    reference_type: str | None = None
    reference_id: str | None = None
    created_at: datetime


class CyclePointsView(BaseModel):
    cycle_id: uuid.UUID
    user_id: uuid.UUID
    points: int
    updated_at: datetime


class CurrentCycleResponse(BaseModel):
    cycle_id: uuid.UUID | None = None
    code: str | None = None
    name: str | None = None
    start_at: datetime | None = None
    end_at: datetime | None = None
    my_points: int = 0
    leaderboard: list[CyclePointsView] = Field(default_factory=list)
    recent_events: list[CycleEventView] = Field(default_factory=list)


class AdminMilestoneUpsertRequest(BaseModel):
    code: str
    name: str
    description: str
    scope: MilestoneScope
    niche_id: uuid.UUID | None = None
    difficulty: MilestoneDifficulty
    is_repeatable: bool = False
    cooldown_days: int | None = Field(default=None, ge=0)
    start_at: datetime | None = None
    end_at: datetime | None = None
    criteria: dict
    reward_rule_code: str | None = None
    is_active: bool = True


class AdminCycleUpsertRequest(BaseModel):
    code: str
    name: str
    start_at: datetime
    end_at: datetime
    is_active: bool = True
    metadata: dict = Field(default_factory=dict)


class AdminRecomputeRequest(BaseModel):
    pro_user_id: uuid.UUID
    niche_id: uuid.UUID | None = None
    evaluate_milestones: bool = True
    recompute_credentials: bool = True
