import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.models.gig import GigStatus, PaymentStatus


class CreateGigRequest(BaseModel):
    pro_user_id: uuid.UUID
    amount_total: Decimal
    currency: str = "EUR"
    location_text: str | None = None
    scheduled_start: datetime | None = None
    scheduled_end: datetime | None = None


class GigResponse(BaseModel):
    id: uuid.UUID
    client_user_id: uuid.UUID
    pro_user_id: uuid.UUID
    status: GigStatus
    currency: str
    amount_total: Decimal
    amount_platform_fee: Decimal
    amount_pro_gross: Decimal
    location_text: str | None
    scheduled_start: datetime | None
    scheduled_end: datetime | None
    metadata: dict = Field(default_factory=dict)
    created_at: datetime
    updated_at: datetime


class PaymentSummary(BaseModel):
    status: PaymentStatus
    stripe_payment_intent_id: str
    amount: Decimal
    currency: str
    last_error: str | None = None


class LedgerSummary(BaseModel):
    total_inflow: Decimal
    total_outflow: Decimal
    net: Decimal


class GigDetailResponse(BaseModel):
    gig: GigResponse
    payment: PaymentSummary | None = None
    ledger_summary: LedgerSummary


class CreatePaymentIntentRequest(BaseModel):
    payment_method_types: list[str] = Field(default_factory=lambda: ["card"])
    return_url: str | None = None


class CreatePaymentIntentResponse(BaseModel):
    payment_intent_client_secret: str
    payment_intent_id: str
    status: str


class CreateRefundRequest(BaseModel):
    reason: str | None = None


class CreateRefundResponse(BaseModel):
    refund_id: str
    status: str
