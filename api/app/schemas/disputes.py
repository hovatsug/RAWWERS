from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.admin import (
    DisputeCategory,
    DisputeStatus,
    EntitlementHoldType,
    ProQualityPenaltySeverity,
    ProQualityPenaltyType,
    RefundCaseStatus,
)


class DisputeCreateV1Request(BaseModel):
    gig_id: uuid.UUID | None = None
    extra_purchase_id: uuid.UUID | None = None
    category: DisputeCategory
    reason: str | None = None
    summary: str | None = None
    requested_refund_amount: Decimal | None = None
    currency: str = "EUR"


class DisputeMessageCreateRequest(BaseModel):
    message: str
    evidence_media_asset_ids: list[uuid.UUID] = Field(default_factory=list)


class DisputeMessageView(BaseModel):
    id: uuid.UUID
    dispute_id: uuid.UUID
    sender_user_id: uuid.UUID
    message: str
    evidence_media_asset_ids: list = Field(default_factory=list)
    created_at: datetime


class DisputeEventView(BaseModel):
    id: uuid.UUID
    dispute_id: uuid.UUID
    from_status: str | None = None
    to_status: str
    actor_type: str
    actor_user_id: uuid.UUID | None = None
    note: str | None = None
    payload: dict = Field(default_factory=dict)
    created_at: datetime


class DisputeDetailView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID | None = None
    extra_purchase_id: uuid.UUID | None = None
    opened_by_user_id: uuid.UUID
    against_user_id: uuid.UUID | None = None
    category: DisputeCategory
    status: DisputeStatus
    reason: str
    summary: str
    requested_refund_amount: Decimal | None = None
    currency: str
    opened_at: datetime
    due_response_at: datetime | None = None
    resolved_at: datetime | None = None
    resolution: dict = Field(default_factory=dict)
    metadata: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime
    messages: list[DisputeMessageView] = Field(default_factory=list)
    events: list[DisputeEventView] = Field(default_factory=list)


class DisputeListResponse(BaseModel):
    items: list[DisputeDetailView] = Field(default_factory=list)


class AdminDisputeSetStatusRequest(BaseModel):
    status: DisputeStatus
    note: str | None = None


class AdminDisputeResolveRequest(BaseModel):
    decision: str
    amount: Decimal | None = None
    rationale: str
    actions: dict = Field(default_factory=dict)


class RefundCaseDetailView(BaseModel):
    id: uuid.UUID
    dispute_id: uuid.UUID | None = None
    payment_scope: str | None = None
    reference_id: uuid.UUID | None = None
    stripe_payment_intent_id: str | None = None
    amount_authorized: Decimal | None = None
    amount_refunded: Decimal
    amount: Decimal
    currency: str
    status: RefundCaseStatus
    metadata: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class EntitlementHoldView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    user_id: uuid.UUID
    hold_type: EntitlementHoldType
    reason: str | None = None
    created_at: datetime
    released_at: datetime | None = None


class ProQualityPenaltyView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    dispute_id: uuid.UUID | None = None
    type: ProQualityPenaltyType
    severity: ProQualityPenaltySeverity
    applied_at: datetime
    expires_at: datetime | None = None
    metadata: dict = Field(default_factory=dict)
