from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.risk import RiskActionStatus, RiskActionType, RiskLevel


class RiskProfileView(BaseModel):
    user_id: uuid.UUID
    risk_score: int
    risk_level: RiskLevel
    reasons: list[str] = Field(default_factory=list)
    flags: dict = Field(default_factory=dict)
    last_calculated_at: datetime


class RiskEventView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    rule_id: str
    delta: int
    payload: dict = Field(default_factory=dict)
    created_at: datetime


class RiskActionView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    action_type: RiskActionType
    status: RiskActionStatus
    reason: str | None = None
    created_at: datetime
    cleared_at: datetime | None = None


class DeviceSignalView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID | None = None
    fingerprint_hash: str
    first_seen_at: datetime
    last_seen_at: datetime
    metadata: dict = Field(default_factory=dict, alias="meta")


class SessionSignalView(BaseModel):
    id: uuid.UUID
    session_id_hash: str
    user_id: uuid.UUID | None = None
    device_fingerprint_id: uuid.UUID | None = None
    ip_hash: str | None = None
    created_at: datetime
    last_seen_at: datetime


class IpSignalView(BaseModel):
    id: uuid.UUID
    ip_hash: str
    first_seen_at: datetime
    last_seen_at: datetime
    metadata: dict = Field(default_factory=dict, alias="meta")


class AdminRiskUserListResponse(BaseModel):
    items: list[RiskProfileView] = Field(default_factory=list)


class AdminRiskUserDetailResponse(BaseModel):
    profile: RiskProfileView
    events: list[RiskEventView] = Field(default_factory=list)
    actions: list[RiskActionView] = Field(default_factory=list)
    devices: list[DeviceSignalView] = Field(default_factory=list)
    sessions: list[SessionSignalView] = Field(default_factory=list)
    ips: list[IpSignalView] = Field(default_factory=list)


class AdminRiskClearActionRequest(BaseModel):
    action_type: RiskActionType
    note: str | None = None


class AdminRiskSetScoreRequest(BaseModel):
    score: int
    note: str | None = None


class RiskRuleView(BaseModel):
    id: str
    is_active: bool
    params: dict = Field(default_factory=dict)
    score_delta: int
    action_on_trigger: dict = Field(default_factory=dict)
    updated_at: datetime


class RiskRuleUpsertRequest(BaseModel):
    is_active: bool
    params: dict = Field(default_factory=dict)
    score_delta: int
    action_on_trigger: dict = Field(default_factory=dict)
