from __future__ import annotations

import uuid
from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, Field

from app.models.chat import ChatSenderType, ChatThreadStatus, ProAITone
from app.schemas.onboarding import BookingRequestView


class ChatThreadCreateRequest(BaseModel):
    pro_user_id: uuid.UUID
    session_id: str | None = None


class ChatThreadSummary(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    client_user_id: uuid.UUID | None = None
    session_id: str | None = None
    status: ChatThreadStatus
    created_at: datetime
    updated_at: datetime

    # Both sides' names travel with the thread. Without them an inbox is a
    # list of UUIDs: the client app cannot title a conversation with anything
    # but "Photographer", and the pro's inbox has the same problem in reverse.
    # Nullable because a guest thread has no client account behind it, and
    # because a pro who has not set a display name is a real state.
    pro_display_name: str | None = None
    client_display_name: str | None = None


class ChatThreadListResponse(BaseModel):
    """Cursor-paginated thread list, matching the convention in
    `app.services.pagination` used by the other collection routes.

    Note the existing `GET /v1/pro/chat/threads` predates that convention and
    still returns a bare array capped at 200 with no cursor. It is left alone
    here rather than changed underneath the web app, which consumes it.
    """

    items: list[ChatThreadSummary] = Field(default_factory=list)
    next_cursor: str | None = None


class ChatMessageCreateV1Request(BaseModel):
    content: str = Field(min_length=1, max_length=4000)


class ChatMessageV1View(BaseModel):
    id: uuid.UUID
    thread_id: uuid.UUID
    sender_type: ChatSenderType
    sender_user_id: uuid.UUID | None = None
    content: str
    metadata: dict = Field(default_factory=dict)
    created_at: datetime


class ChatThreadDetailResponse(BaseModel):
    thread: ChatThreadSummary
    messages: list[ChatMessageV1View] = Field(default_factory=list)
    lead_profile: dict = Field(default_factory=dict)


class AIDraftRequest(BaseModel):
    context: str | None = None


class AIDraftResponse(BaseModel):
    content: str
    metadata: dict = Field(default_factory=dict)


class CreateBookingFromChatRequest(BaseModel):
    package_id: uuid.UUID
    requested_start: datetime
    requested_end: datetime
    location_text: str | None = None
    notes: str | None = None


class CreateBookingFromChatResponse(BaseModel):
    booking_request: BookingRequestView


class ProAIProfileUpdateRequest(BaseModel):
    is_enabled: bool = True
    tone: ProAITone = ProAITone.premium
    faq: list[dict] = Field(default_factory=list)
    do_not_say: list[str] = Field(default_factory=list)
    preferred_packages: list[str] = Field(default_factory=list)


class ProAIProfileView(BaseModel):
    pro_user_id: uuid.UUID
    is_enabled: bool
    tone: ProAITone
    faq: list[dict] = Field(default_factory=list)
    do_not_say: list[str] = Field(default_factory=list)
    preferred_packages: list[str] = Field(default_factory=list)
    updated_at: datetime


class AIInteractionLogView(BaseModel):
    id: uuid.UUID
    thread_id: uuid.UUID
    request_id: str
    model: str
    prompt_hash: str
    input_summary: dict = Field(default_factory=dict)
    output_summary: dict = Field(default_factory=dict)
    safety_flags: dict = Field(default_factory=dict)
    tokens_in: int | None = None
    tokens_out: int | None = None
    latency_ms: int | None = None
    created_at: datetime


class AIInteractionLogListResponse(BaseModel):
    items: list[AIInteractionLogView] = Field(default_factory=list)


class LeadProfileView(BaseModel):
    thread_id: uuid.UUID
    niche_slug: str | None = None
    desired_date: date | None = None
    date_flex_days: int | None = None
    location: dict = Field(default_factory=dict)
    budget_min: Decimal | None = None
    budget_max: Decimal | None = None
    style_tags: list[str] = Field(default_factory=list)
    notes: str | None = None
    updated_at: datetime
