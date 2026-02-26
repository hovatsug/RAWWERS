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
from app.models.niche import SkillTier
from app.models.client_rewards_pricing import ConsentRewardLevel, ShareRewardMetric
from app.models.proof_of_gigs import RawwIssuanceCapScope, RawwIssuanceEventType, RawwMintEventStatus


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
    gig_id: uuid.UUID | None = None
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


class ExtraImagePricingPolicyUpsertItem(BaseModel):
    niche_slug: str
    tier: SkillTier
    unit_price_min: Decimal
    unit_price_max: Decimal | None = None
    max_extra_images: int | None = None
    bulk_curve: dict = Field(default_factory=dict)
    currency: str = "EUR"
    is_active: bool = True


class ExtraImagePricingPolicyUpsertRequest(BaseModel):
    items: list[ExtraImagePricingPolicyUpsertItem] = Field(default_factory=list)


class ExtraImagePricingPolicyView(BaseModel):
    niche_id: uuid.UUID
    niche_slug: str
    tier: SkillTier
    unit_price_min: Decimal
    unit_price_max: Decimal | None = None
    max_extra_images: int | None = None
    bulk_curve: dict = Field(default_factory=dict)
    currency: str
    is_active: bool
    updated_at: datetime


class ProExtraImagePriceUpsertItem(BaseModel):
    niche_slug: str
    configured_unit_price: Decimal
    currency: str = "EUR"


class ProExtraImagePriceUpsertRequest(BaseModel):
    items: list[ProExtraImagePriceUpsertItem] = Field(default_factory=list)


class ProExtraImagePriceView(BaseModel):
    pro_user_id: uuid.UUID
    niche_id: uuid.UUID
    niche_slug: str
    configured_unit_price: Decimal
    currency: str
    updated_at: datetime


class ConsentRewardPolicyUpsertItem(BaseModel):
    consent_level: ConsentRewardLevel
    points_award: int = 0
    cooldown_hours: int = 48
    allow_clawback: bool = True
    max_awards_per_user_per_month: int = 10


class ConsentRewardPolicyUpsertRequest(BaseModel):
    items: list[ConsentRewardPolicyUpsertItem] = Field(default_factory=list)


class ConsentRewardPolicyView(BaseModel):
    consent_level: ConsentRewardLevel
    points_award: int
    cooldown_hours: int
    allow_clawback: bool
    max_awards_per_user_per_month: int
    updated_at: datetime


class ShareRewardThresholdUpsertItem(BaseModel):
    metric: ShareRewardMetric
    threshold_value: int
    points_award: int
    max_awards_per_share_link: int = 1
    is_active: bool = True


class ShareRewardThresholdUpsertRequest(BaseModel):
    items: list[ShareRewardThresholdUpsertItem] = Field(default_factory=list)


class ShareRewardThresholdView(BaseModel):
    metric: ShareRewardMetric
    threshold_value: int
    points_award: int
    max_awards_per_share_link: int
    is_active: bool
    updated_at: datetime


class ShareRewardGrantView(BaseModel):
    id: uuid.UUID
    share_link_id: uuid.UUID
    metric: str
    threshold_value: int
    user_id: uuid.UUID
    reward_ledger_entry_id: uuid.UUID | None = None
    granted_at: datetime


class ShareFraudSettingsUpsertRequest(BaseModel):
    min_seconds_viewed: int | None = None
    max_views_per_ip_per_day: int | None = None
    max_rewards_per_user_per_month: int | None = None


class ShareFraudSettingsView(BaseModel):
    min_seconds_viewed: int
    max_views_per_ip_per_day: int
    max_rewards_per_user_per_month: int


class RawwIssuanceRuleView(BaseModel):
    event_type: RawwIssuanceEventType
    base_raww: int
    min_eur_value: Decimal
    max_raww_per_event: int | None = None
    is_active: bool
    updated_at: datetime


class RawwIssuanceRuleUpdateItem(BaseModel):
    event_type: RawwIssuanceEventType
    base_raww: int
    min_eur_value: Decimal = Decimal("0.00")
    max_raww_per_event: int | None = None
    is_active: bool = True


class RawwIssuanceRulesUpdateRequest(BaseModel):
    items: list[RawwIssuanceRuleUpdateItem] = Field(default_factory=list)


class RawwMultiplierPolicyView(BaseModel):
    name: str
    tier_multipliers: dict = Field(default_factory=dict)
    rating_curve: dict = Field(default_factory=dict)
    dispute_penalty: dict = Field(default_factory=dict)
    refund_penalty_multiplier: Decimal
    abuse_block_threshold: dict = Field(default_factory=dict)
    updated_at: datetime


class RawwMultiplierPolicyUpdateRequest(BaseModel):
    tier_multipliers: dict = Field(default_factory=dict)
    rating_curve: dict = Field(default_factory=dict)
    dispute_penalty: dict = Field(default_factory=dict)
    refund_penalty_multiplier: Decimal = Decimal("0.500")
    abuse_block_threshold: dict = Field(default_factory=dict)


class RawwCapView(BaseModel):
    scope: RawwIssuanceCapScope
    cap_raww: int
    updated_at: datetime


class RawwCapUpdateItem(BaseModel):
    scope: RawwIssuanceCapScope
    cap_raww: int


class RawwCapsUpdateRequest(BaseModel):
    items: list[RawwCapUpdateItem] = Field(default_factory=list)


class RawwMintEventView(BaseModel):
    id: uuid.UUID
    event_type: str
    pro_user_id: uuid.UUID
    reference_type: str
    reference_id: uuid.UUID
    raww_awarded: int
    multiplier_snapshot: dict = Field(default_factory=dict)
    status: RawwMintEventStatus
    created_at: datetime


class RawwClawbackRequest(BaseModel):
    pro_user_id: uuid.UUID
    reference_type: str
    reference_id: uuid.UUID
    amount_raww: int
    reason: str


class RawwClawbackResponse(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    reference_type: str
    reference_id: uuid.UUID
    amount_raww: int
    reason: str
    created_by_admin_id: uuid.UUID | None = None
    created_at: datetime
