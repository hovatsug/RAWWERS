import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.admin import (
    BanActionType,
    DisputeCategory,
    DisputeStatus,
    EvidenceKind,
    KYCStatus,
    RefundCaseStatus,
    UserRoleType,
)
from app.models.gig import GigStatus
from app.models.ops import AbuseSeverity, AbuseSignalStatus, FeatureFlagScope


class UserListItem(BaseModel):
    user_id: uuid.UUID
    email: str | None = None
    display_name: str | None = None
    roles: list[UserRoleType] = Field(default_factory=list)
    kyc_status: KYCStatus | None = None
    ban_action: BanActionType | None = None


class UserListResponse(BaseModel):
    total: int
    items: list[UserListItem]


class BanActionView(BaseModel):
    action: BanActionType
    reason: str
    actor_user_id: uuid.UUID
    starts_at: datetime
    ends_at: datetime | None
    created_at: datetime


class UserDetailResponse(BaseModel):
    user_id: uuid.UUID
    email: str | None = None
    display_name: str | None = None
    roles: list[UserRoleType]
    kyc_status: KYCStatus | None = None
    kyc_note: str | None = None
    ban_history: list[BanActionView]
    gigs_count: int
    gigs_last_activity: datetime | None = None
    media_count: int


class RoleUpdateRequest(BaseModel):
    add: list[UserRoleType] = Field(default_factory=list)
    remove: list[UserRoleType] = Field(default_factory=list)
    reason: str | None = None


class KYCUpdateRequest(BaseModel):
    kyc_status: KYCStatus
    note: str | None = None


class BanUpdateRequest(BaseModel):
    action: BanActionType
    reason: str
    ends_at: datetime | None = None


class DisputeCreateRequest(BaseModel):
    gig_id: uuid.UUID
    category: DisputeCategory
    summary: str


class DisputeView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    opened_by_user_id: uuid.UUID
    status: DisputeStatus
    category: DisputeCategory
    summary: str
    resolution_note: str | None = None
    created_at: datetime
    updated_at: datetime


class DisputeEvidenceCreateRequest(BaseModel):
    kind: EvidenceKind
    text: str | None = None
    media_asset_id: uuid.UUID | None = None


class DisputeEvidenceView(BaseModel):
    id: uuid.UUID
    dispute_id: uuid.UUID
    submitted_by_user_id: uuid.UUID
    kind: EvidenceKind
    text: str | None = None
    media_asset_id: uuid.UUID | None = None
    created_at: datetime


class DisputeStatusUpdateRequest(BaseModel):
    status: DisputeStatus
    resolution_note: str | None = None
    reason: str | None = None


class AdminGigStatusUpdateRequest(BaseModel):
    status: GigStatus
    reason: str


class AdminRefundCreateRequest(BaseModel):
    amount: Decimal | None = None
    reason: str | None = None
    dispute_id: uuid.UUID | None = None


class RefundCaseView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    dispute_id: uuid.UUID | None = None
    requested_by_user_id: uuid.UUID
    status: RefundCaseStatus
    amount: Decimal
    currency: str
    reason: str | None = None
    admin_note: str | None = None
    metadata: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class OpsMetricsSummaryResponse(BaseModel):
    open_abuse_signals: int
    webhook_signature_failures_24h: int
    payment_failures_24h: int
    discover_events_24h: int
    queue_depth_media: int


class AbuseSignalView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID | None = None
    ip_hash: str | None = None
    signal_type: str
    severity: AbuseSeverity
    evidence: dict = Field(default_factory=dict)
    status: AbuseSignalStatus
    created_at: datetime
    updated_at: datetime


class ResolveAbuseSignalRequest(BaseModel):
    status: AbuseSignalStatus = AbuseSignalStatus.resolved
    reason: str | None = None


class FeatureFlagView(BaseModel):
    key: str
    is_enabled: bool
    scope: FeatureFlagScope
    rules: dict = Field(default_factory=dict)
    updated_at: datetime


class FeatureFlagUpsertRequest(BaseModel):
    is_enabled: bool
    scope: FeatureFlagScope = FeatureFlagScope.global_scope
    rules: dict = Field(default_factory=dict)
