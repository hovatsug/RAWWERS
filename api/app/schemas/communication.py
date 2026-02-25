import uuid
from datetime import datetime, time
from typing import Any

from pydantic import BaseModel, Field

from app.models.communication import (
    CallOutcome,
    CallPurpose,
    CallSessionStatus,
    ConsentChannel,
    ConsentScope,
    FollowupJobStatus,
    FollowupChannel,
)


class UserContactUpdateRequest(BaseModel):
    phone_e164: str | None = None
    timezone: str | None = None
    quiet_hours_start: time | None = None
    quiet_hours_end: time | None = None


class UserContactView(BaseModel):
    user_id: uuid.UUID
    phone_e164: str | None = None
    timezone: str
    quiet_hours_start: time
    quiet_hours_end: time


class ConsentUpdateRequest(BaseModel):
    channel: ConsentChannel
    scope: ConsentScope
    granted: bool
    source: str = "in_app_toggle"
    metadata: dict[str, Any] = Field(default_factory=dict)


class ConsentView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    channel: ConsentChannel
    scope: ConsentScope
    granted: bool
    granted_at: datetime
    revoked_at: datetime | None = None
    source: str
    metadata: dict[str, Any] = Field(default_factory=dict)


class CallRequestBody(BaseModel):
    recipient_user_id: uuid.UUID
    pro_user_id: uuid.UUID | None = None
    purpose: CallPurpose
    target_type: str | None = None
    target_id: uuid.UUID | None = None
    source: str = "in_app"
    metadata: dict[str, Any] = Field(default_factory=dict)


class CallSessionView(BaseModel):
    id: uuid.UUID
    provider: str
    pro_user_id: uuid.UUID | None = None
    recipient_user_id: uuid.UUID
    recipient_phone_e164: str
    purpose: CallPurpose
    status: CallSessionStatus
    provider_call_id: str | None = None
    outcome: CallOutcome
    transcript: str | None = None
    summary: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class TelephonyWebhookRequest(BaseModel):
    provider_call_id: str
    status: str
    outcome: str | None = None
    transcript: str | None = None
    payload: dict[str, Any] = Field(default_factory=dict)


class FollowupSeedResponse(BaseModel):
    created_count: int


class FollowupRebuildResponse(BaseModel):
    rebuilt_jobs: int


class FollowupJobView(BaseModel):
    id: uuid.UUID
    rule_code: str
    user_id: uuid.UUID
    target_type: str
    target_id: uuid.UUID
    scheduled_for: datetime
    status: FollowupJobStatus


class FollowupRuleView(BaseModel):
    code: str
    trigger: str
    channel: FollowupChannel
    delay_minutes: int
    is_enabled: bool


class CallSummaryResponse(BaseModel):
    id: uuid.UUID
    summary: str
    metadata: dict[str, Any]
