from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.legacy_shoot import (
    LegacyBookingStatus,
    LegacyPaymentMode,
    LegacyPrivacyLevel,
    LegacyReviewResponse,
    LegacyReviewStage,
    LegacyTone,
    VaultItemStatus,
    VaultItemType,
)


class LegacyCheckoutRequest(BaseModel):
    payment_mode: LegacyPaymentMode = LegacyPaymentMode.full


class LegacyCheckoutResponse(BaseModel):
    legacy_booking_id: uuid.UUID
    gig_id: uuid.UUID
    payment_intent_id: str
    payment_intent_client_secret: str | None = None
    payment_mode: LegacyPaymentMode
    due_now_eur: Decimal


class LegacyBriefPutRequest(BaseModel):
    answers: dict
    tone: LegacyTone | None = None
    privacy_level: LegacyPrivacyLevel = LegacyPrivacyLevel.private


class LegacyBookingView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    client_user_id: uuid.UUID
    assigned_pro_user_id: uuid.UUID | None = None
    status: LegacyBookingStatus
    price_eur: Decimal
    payment_mode: LegacyPaymentMode
    created_at: datetime
    updated_at: datetime


class LegacyBriefView(BaseModel):
    legacy_booking_id: uuid.UUID
    answers: dict = Field(default_factory=dict)
    tone: LegacyTone | None = None
    privacy_level: LegacyPrivacyLevel
    created_at: datetime
    updated_at: datetime


class LegacyBookingDetailResponse(BaseModel):
    booking: LegacyBookingView
    brief: LegacyBriefView | None = None
    marketing_consent: bool = False
    marketing_channels: list[str] = Field(default_factory=list)


class LegacyVaultItemView(BaseModel):
    id: uuid.UUID
    legacy_booking_id: uuid.UUID
    type: VaultItemType
    content_type: str | None = None
    bytes: int | None = None
    version: int
    status: VaultItemStatus
    created_by: uuid.UUID | None = None
    created_at: datetime
    updated_at: datetime


class LegacyVaultListResponse(BaseModel):
    items: list[LegacyVaultItemView] = Field(default_factory=list)


class LegacyVaultDownloadResponse(BaseModel):
    url: str


class LegacyReviewSubmitRequest(BaseModel):
    stage: LegacyReviewStage
    vault_item_ids: list[uuid.UUID] = Field(default_factory=list)


class LegacyReviewRespondRequest(BaseModel):
    response: LegacyReviewResponse
    notes: str | None = None


class LegacyReviewView(BaseModel):
    id: uuid.UUID
    legacy_booking_id: uuid.UUID
    stage: LegacyReviewStage
    submitted_by: uuid.UUID
    client_response: LegacyReviewResponse
    client_notes: str | None = None
    item_ids: list[str] = Field(default_factory=list)
    created_at: datetime
    updated_at: datetime


class LegacyMarketingConsentRequest(BaseModel):
    consent: bool
    channels: list[str] = Field(default_factory=list)


class LegacyMarketingConsentView(BaseModel):
    consent: bool
    channels: list[str] = Field(default_factory=list)
    updated_at: datetime


class LegacyAssignProRequest(BaseModel):
    pro_user_id: uuid.UUID
    admin_override: bool = False


class LegacySetStatusRequest(BaseModel):
    status: LegacyBookingStatus


class LegacyVaultUploadRequest(BaseModel):
    type: VaultItemType
    content_type: str
    bytes: int | None = None


class LegacyVaultUploadResponse(BaseModel):
    vault_item_id: uuid.UUID
    upload_url: str


class LegacyAdminAuditResponse(BaseModel):
    access_logs: list[dict] = Field(default_factory=list)
    reviews: list[LegacyReviewView] = Field(default_factory=list)
