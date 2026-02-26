from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.payouts import (
    EarningsEntryStatus,
    EarningsHoldReason,
    EarningsSourceType,
    PayoutAccountStatus,
    PayoutMethod,
    PayoutRequestStatus,
)


class EarningsBalanceView(BaseModel):
    pending_eur: Decimal
    available_eur: Decimal
    held_eur: Decimal
    reserved_eur: Decimal
    withdrawable_eur: Decimal


class EarningsLedgerItemView(BaseModel):
    id: uuid.UUID
    source_type: EarningsSourceType
    source_id: uuid.UUID
    gross_eur: Decimal
    platform_fee_eur: Decimal
    net_eur: Decimal
    status: EarningsEntryStatus
    available_at: datetime
    reversed_at: datetime | None = None
    metadata: dict = Field(default_factory=dict, alias="meta")
    created_at: datetime


class EarningsLedgerResponse(BaseModel):
    items: list[EarningsLedgerItemView] = Field(default_factory=list)


class PayoutAccountUpsertRequest(BaseModel):
    payout_method: PayoutMethod
    stripe_connect_account_id: str | None = None
    bank_details_encrypted: dict | None = None
    status: PayoutAccountStatus = PayoutAccountStatus.pending_verification


class PayoutAccountView(BaseModel):
    pro_user_id: uuid.UUID
    payout_method: PayoutMethod
    stripe_connect_account_id: str | None = None
    bank_details_encrypted: dict | None = None
    status: PayoutAccountStatus
    updated_at: datetime


class PayoutRequestCreateRequest(BaseModel):
    amount_eur: Decimal


class PayoutRequestView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    amount_eur: Decimal
    status: PayoutRequestStatus
    requested_at: datetime
    approved_by_admin_id: uuid.UUID | None = None
    approved_at: datetime | None = None
    paid_at: datetime | None = None
    failure_reason: str | None = None
    reference: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class PayoutListResponse(BaseModel):
    items: list[PayoutRequestView] = Field(default_factory=list)


class AdminFinanceProItem(BaseModel):
    pro_user_id: uuid.UUID
    display_name: str | None = None
    city: str | None = None
    country: str | None = None
    pending_eur: Decimal
    available_eur: Decimal
    held_eur: Decimal
    reserved_eur: Decimal
    withdrawable_eur: Decimal


class AdminFinanceProsResponse(BaseModel):
    items: list[AdminFinanceProItem] = Field(default_factory=list)


class EarningsHoldCreateRequest(BaseModel):
    pro_user_id: uuid.UUID
    reason: EarningsHoldReason
    amount_eur: Decimal | None = None
    source_type: str | None = None
    source_id: uuid.UUID | None = None


class EarningsHoldView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    reason: EarningsHoldReason
    amount_eur: Decimal | None = None
    source_type: str | None = None
    source_id: uuid.UUID | None = None
    created_by_admin_id: uuid.UUID | None = None
    created_at: datetime
    released_at: datetime | None = None


class PlatformFeePolicyView(BaseModel):
    id: uuid.UUID
    fee_percent_gigs: int
    fee_percent_extras: int
    fee_percent_studioverse: int
    settlement_delay_days: int
    dispute_hold_days: int
    updated_at: datetime


class PlatformFeePolicyUpdateRequest(BaseModel):
    fee_percent_gigs: int
    fee_percent_extras: int
    fee_percent_studioverse: int
    settlement_delay_days: int
    dispute_hold_days: int


class AdminPayoutRejectRequest(BaseModel):
    reason: str | None = None


class AdminPayoutMarkPaidRequest(BaseModel):
    reference: dict = Field(default_factory=dict)


class AdminFinanceProDetailResponse(BaseModel):
    pro_user_id: uuid.UUID
    balance: EarningsBalanceView
    payout_account: PayoutAccountView
    holds: list[EarningsHoldView] = Field(default_factory=list)
    recent_disputes: list[dict] = Field(default_factory=list)
    recent_payouts: list[PayoutRequestView] = Field(default_factory=list)
