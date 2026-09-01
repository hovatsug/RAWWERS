import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.models.chat import ChatSenderType, ChatThreadStatus
from app.schemas.onboarding import BookingRequestView


class ChatThreadCreateResponse(BaseModel):
    thread_id: uuid.UUID
    status: ChatThreadStatus


class ChatMessageCreateRequest(BaseModel):
    content: str = Field(min_length=1, max_length=4000)


class ChatMessageView(BaseModel):
    id: uuid.UUID
    thread_id: uuid.UUID
    sender_type: ChatSenderType
    sender_user_id: uuid.UUID | None = None
    content: str
    metadata: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime


class ChatThreadView(BaseModel):
    id: uuid.UUID
    pro_user_id: uuid.UUID
    client_user_id: uuid.UUID
    status: ChatThreadStatus
    context_snapshot: dict[str, Any]
    token_budget_used: int
    created_at: datetime
    updated_at: datetime
    messages: list[ChatMessageView] = Field(default_factory=list)


class ChatMessagesAppendResponse(BaseModel):
    thread_id: uuid.UUID
    status: ChatThreadStatus
    appended: list[ChatMessageView]


class ChatHandoffRequest(BaseModel):
    reason: str | None = None


class ChatCloseRequest(BaseModel):
    reason: str | None = None


class ChatCreateBookingRequestResponse(BaseModel):
    booking_request: BookingRequestView
