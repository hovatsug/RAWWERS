from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.review import ReviewStatus


class CreateReviewRequest(BaseModel):
    rating: int = Field(ge=1, le=5)
    tags: list[str] = Field(default_factory=list)
    text: str | None = None
    would_book_again: bool = True
    video_media_asset_id: uuid.UUID | None = None


class ReviewReplyView(BaseModel):
    id: uuid.UUID
    review_id: uuid.UUID
    pro_user_id: uuid.UUID
    text: str
    created_at: datetime
    updated_at: datetime


class ReviewView(BaseModel):
    id: uuid.UUID
    gig_id: uuid.UUID
    pro_user_id: uuid.UUID
    client_user_id: uuid.UUID
    rating: int
    tags: list[str]
    text: str | None = None
    would_book_again: bool
    video_media_asset_id: uuid.UUID | None = None
    video_playback_id: str | None = None
    status: ReviewStatus
    created_at: datetime
    updated_at: datetime
    reply: ReviewReplyView | None = None


class ProReviewsResponse(BaseModel):
    total: int
    items: list[ReviewView]


class CreateReviewReplyRequest(BaseModel):
    text: str = Field(min_length=1, max_length=5000)


class ModerateReviewActionRequest(BaseModel):
    action: ReviewStatus
    reason: str | None = None
