from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.reward import DiscountRedemptionStatus, RedemptionContextType, RewardEntryType


class ReferralMeResponse(BaseModel):
    code: str
    link_stub: str


class ReferralClaimRequest(BaseModel):
    code: str


class RefLandingResponse(BaseModel):
    code: str
    valid: bool
    referrer_user_id: uuid.UUID | None = None
    session_id: str


class MeReferralCodeResponse(BaseModel):
    code: str
    share_url: str


class ReferralStatsResponse(BaseModel):
    code: str
    clicks: int
    registered: int
    converted: int
    total_points_earned: int


class AdminReferralPolicyItem(BaseModel):
    conversion_type: str
    referrer_points: int
    referee_points: int
    max_rewards_per_referrer_per_month: int
    min_conversion_value_eur: Decimal
    cooldown_days: int


class AdminReferralPolicyUpsertRequest(BaseModel):
    items: list[AdminReferralPolicyItem]


class AdminReferralReportResponse(BaseModel):
    total_conversions: int
    total_referrers: int
    total_referees: int
    total_points_awarded: int
    conversions_by_type: dict[str, int] = Field(default_factory=dict)


class AdminReferralBlacklistResponse(BaseModel):
    user_id: uuid.UUID
    reason: str
    active: bool


class RewardBalanceResponse(BaseModel):
    balance: int


class RewardLedgerItemView(BaseModel):
    id: uuid.UUID
    entry_type: RewardEntryType
    rule_code: str | None = None
    amount: int
    balance_after: int
    reference_type: str | None = None
    reference_id: str | None = None
    meta: dict = Field(default_factory=dict)
    created_at: datetime


class RewardLedgerResponse(BaseModel):
    total: int
    items: list[RewardLedgerItemView]


class RewardSpendRequest(BaseModel):
    context_type: RedemptionContextType
    context_id: uuid.UUID
    points: int = Field(gt=0)
    payment_amount: Decimal = Field(gt=Decimal("0"))
    currency: str = "EUR"


class DiscountRedemptionView(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    context_type: RedemptionContextType
    context_id: uuid.UUID
    points_spent: int
    discount_amount: Decimal
    currency: str
    status: DiscountRedemptionStatus
    created_at: datetime
    updated_at: datetime


class AdminRewardRuleView(BaseModel):
    code: str
    is_enabled: bool
    amount: int
    currency: str
    daily_cap_per_user: int | None = None
    lifetime_cap_per_user: int | None = None
    meta: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class AdminRewardRuleUpdateRequest(BaseModel):
    is_enabled: bool | None = None
    amount: int | None = None
    currency: str | None = None
    daily_cap_per_user: int | None = None
    lifetime_cap_per_user: int | None = None
    metadata: dict | None = None


class AdminRewardAdjustRequest(BaseModel):
    user_id: uuid.UUID
    amount: int
    reason: str


class AdminRewardAdjustResponse(BaseModel):
    user_id: uuid.UUID
    amount: int
    balance_after: int
