from __future__ import annotations

import uuid
from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.niche import SkillTier
from app.models.repair import (
    GearCategory,
    LoanerRequestStatus,
    RepairActorType,
    RepairOutcome,
    RepairTicketStatus,
    RepairUrgency,
)


class GearBenefitsAccessResponse(BaseModel):
    allowed: bool
    reason: str
    max_tier: SkillTier | None = None


class GearItemCreateRequest(BaseModel):
    category: GearCategory
    brand: str | None = None
    model: str | None = None
    serial_number: str | None = None
    purchase_date: date | None = None
    notes: str | None = None
    metadata: dict = Field(default_factory=dict)


class GearItemUpdateRequest(BaseModel):
    category: GearCategory | None = None
    brand: str | None = None
    model: str | None = None
    serial_number: str | None = None
    purchase_date: date | None = None
    notes: str | None = None
    metadata: dict | None = None


class GearItemView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    category: GearCategory
    brand: str | None = None
    model: str | None = None
    serial_number: str | None = None
    purchase_date: date | None = None
    notes: str | None = None
    meta: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class RepairTicketCreateRequest(BaseModel):
    gear_item_id: uuid.UUID | None = None
    category: GearCategory
    brand: str | None = None
    model: str | None = None
    issue_description: str
    urgency: RepairUrgency = RepairUrgency.normal
    evidence_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)
    location_city: str | None = None
    location_country: str | None = None


class RepairTicketView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    gear_item_id: uuid.UUID | None = None
    partner_id: uuid.UUID | None = None
    status: RepairTicketStatus
    urgency: RepairUrgency
    issue_description: str
    evidence_media_asset_ids: list = Field(default_factory=list)
    quote_amount: Decimal | None = None
    currency: str
    quote_notes: str | None = None
    quote_sent_at: datetime | None = None
    quote_approved_at: datetime | None = None
    repair_started_at: datetime | None = None
    repair_completed_at: datetime | None = None
    return_shipped_at: datetime | None = None
    closed_at: datetime | None = None
    shipping: dict = Field(default_factory=dict)
    outcome: RepairOutcome
    reopened_from_ticket_id: uuid.UUID | None = None
    meta: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class RepairEventView(BaseModel):
    id: uuid.UUID
    ticket_id: uuid.UUID
    from_status: str | None = None
    to_status: str
    actor_type: RepairActorType
    actor_id: uuid.UUID | None = None
    note: str | None = None
    payload: dict = Field(default_factory=dict)
    created_at: datetime


class LoanerRequestCreateRequest(BaseModel):
    category: GearCategory
    note: str | None = None


class LoanerRequestView(BaseModel):
    id: uuid.UUID
    ticket_id: uuid.UUID
    pro_user_id: uuid.UUID
    partner_id: uuid.UUID | None = None
    status: LoanerRequestStatus
    category: GearCategory
    terms_snapshot: dict = Field(default_factory=dict)
    deposit_required: bool
    deposit_amount: Decimal | None = None
    currency: str
    deposit_reference: str | None = None
    max_days: int | None = None
    start_at: datetime | None = None
    due_at: datetime | None = None
    shipping: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class LoanerEventView(BaseModel):
    id: uuid.UUID
    loaner_request_id: uuid.UUID
    from_status: str | None = None
    to_status: str
    actor_type: RepairActorType
    actor_id: uuid.UUID | None = None
    note: str | None = None
    payload: dict = Field(default_factory=dict)
    created_at: datetime


class QuoteSetRequest(BaseModel):
    amount: Decimal
    currency: str = "EUR"
    notes: str | None = None


class SetRepairStatusRequest(BaseModel):
    to_status: RepairTicketStatus
    note: str | None = None
    payload: dict = Field(default_factory=dict)


class SetLoanerStatusRequest(BaseModel):
    to_status: LoanerRequestStatus
    note: str | None = None
    payload: dict = Field(default_factory=dict)


class AssignPartnerRequest(BaseModel):
    partner_id: uuid.UUID


class RepairPartnerUpsertRequest(BaseModel):
    name: str
    country: str
    city: str
    address: str | None = None
    service_radius_km: int | None = None
    shipping_supported: bool = False
    pickup_supported: bool = False
    brands_supported: list[str] = Field(default_factory=list)
    categories_supported: list[GearCategory] = Field(default_factory=list)
    sla_quote_hours: int | None = None
    sla_turnaround_days: int | None = None
    loaner_supported: bool = False
    loaner_categories: list[GearCategory] = Field(default_factory=list)
    is_active: bool = True
    contact: dict = Field(default_factory=dict)
    partner_terms: dict = Field(default_factory=dict)


class RepairPartnerView(BaseModel):
    id: uuid.UUID
    name: str
    country: str
    city: str
    address: str | None = None
    service_radius_km: int | None = None
    shipping_supported: bool
    pickup_supported: bool
    brands_supported: list = Field(default_factory=list)
    categories_supported: list = Field(default_factory=list)
    sla_quote_hours: int | None = None
    sla_turnaround_days: int | None = None
    loaner_supported: bool
    loaner_categories: list = Field(default_factory=list)
    is_active: bool
    contact: dict = Field(default_factory=dict)
    partner_terms: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class GearBenefitPolicyRequest(BaseModel):
    require_kyc_approved: bool = True
    min_tier_any_niche: SkillTier = SkillTier.skilled
    require_not_banned: bool = True
    metadata: dict = Field(default_factory=dict)


class GearBenefitPolicyView(BaseModel):
    id: uuid.UUID
    require_kyc_approved: bool
    min_tier_any_niche: SkillTier
    require_not_banned: bool
    meta: dict = Field(default_factory=dict)
    updated_at: datetime


class GearBenefitOverrideRequest(BaseModel):
    is_allowed: bool
    reason: str | None = None
    expires_at: datetime | None = None


class GearBenefitOverrideView(BaseModel):
    pro_user_id: uuid.UUID
    is_allowed: bool
    reason: str | None = None
    granted_by: uuid.UUID | None = None
    granted_at: datetime
    expires_at: datetime | None = None


class RepairPartnerScoreView(BaseModel):
    partner_id: uuid.UUID
    tickets_count: int
    avg_quote_hours: Decimal | None = None
    avg_turnaround_days: Decimal | None = None
    reopen_rate: Decimal | None = None
    dispute_rate: Decimal | None = None
    loaner_fulfillment_rate: Decimal | None = None
    updated_at: datetime
