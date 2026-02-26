from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.launch_ops import (
    InviteAllowedRole,
    InviteCodeStatus,
    ProOnboardingStatus,
)


class ProOnboardingStartRequest(BaseModel):
    city: str
    country: str
    invite_code: str | None = None


class ProOnboardingStatusResponse(BaseModel):
    pro_user_id: uuid.UUID
    status: ProOnboardingStatus
    current_city: dict | None = None
    invite_code_id: uuid.UUID | None = None
    notes: str | None = None
    started_at: datetime
    updated_at: datetime


class ProOnboardingChecksResponse(BaseModel):
    status: ProOnboardingStatus
    checks: dict = Field(default_factory=dict)
    missing: list[str] = Field(default_factory=list)


class AdminProOnboardingListResponse(BaseModel):
    items: list[ProOnboardingStatusResponse] = Field(default_factory=list)


class AdminSetProOnboardingStatusRequest(BaseModel):
    status: ProOnboardingStatus
    note: str | None = None


class RolloutCityUpsertItem(BaseModel):
    country: str
    city: str
    is_pro_onboarding_enabled: bool = False
    is_client_browsing_enabled: bool = False
    metadata: dict = Field(default_factory=dict)


class RolloutCityListResponse(BaseModel):
    items: list[dict] = Field(default_factory=list)


class RolloutCityBulkEnableRequest(BaseModel):
    cities: list[dict] = Field(default_factory=list)
    enable_pro_onboarding: bool = True
    enable_client_browsing: bool = False


class RolloutOverrideUpsertRequest(BaseModel):
    can_access_pro_onboarding: bool = False
    can_access_client_app: bool = False
    reason: str | None = None
    expires_at: datetime | None = None


class RolloutOverrideResponse(BaseModel):
    user_id: uuid.UUID
    can_access_pro_onboarding: bool
    can_access_client_app: bool
    reason: str | None = None
    expires_at: datetime | None = None
    granted_by: uuid.UUID | None = None
    granted_at: datetime


class InviteWaveCreateRequest(BaseModel):
    code_prefix: str
    name: str
    max_invites: int
    expires_at: datetime | None = None
    allowed_role: InviteAllowedRole = InviteAllowedRole.pro
    allowed_cities: list[dict] = Field(default_factory=list)


class InviteWaveResponse(BaseModel):
    id: uuid.UUID
    code_prefix: str
    name: str
    max_invites: int
    used_invites: int
    expires_at: datetime | None = None
    allowed_role: InviteAllowedRole
    allowed_cities: list = Field(default_factory=list)
    is_active: bool
    created_at: datetime
    updated_at: datetime


class InviteWaveGenerateRequest(BaseModel):
    count: int
    issued_to_emails: list[str] = Field(default_factory=list)


class InviteCodeView(BaseModel):
    id: uuid.UUID
    wave_id: uuid.UUID
    code: str
    issued_to_email: str | None = None
    issued_by_admin_id: uuid.UUID | None = None
    redeemed_by_user_id: uuid.UUID | None = None
    redeemed_at: datetime | None = None
    status: InviteCodeStatus
    created_at: datetime
    updated_at: datetime


class InviteCodeListResponse(BaseModel):
    items: list[InviteCodeView] = Field(default_factory=list)
