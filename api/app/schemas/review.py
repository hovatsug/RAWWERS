from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from app.models.review import ReviewStatus


class CreateReviewRequest(BaseModel):
    rating: int = Field(ge=1, le=5)
    tags: list[str] = Field(default_factory=list)
    text: str | None = None
    would_book_again: bool = True
    video_media_asset_id: uuid.UUID | None = None

    @field_validator("tags", mode="before")
    @classmethod
    def _no_tags_is_an_empty_list(cls, value):
        # The client app sends `"tags": null` when no tag was picked, and every
        # review it posted was refused with a 422 (Stage 1 loop, 2026-10-30).
        # Null, omitted and [] all mean "no tags".
        return [] if value is None else value


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
    niche_id: uuid.UUID
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


class ReviewNicheView(BaseModel):
    slug: str
    name: str


class PublicReviewView(BaseModel):
    """A review as anyone may see it, signed in or not.

    Deliberately without client_user_id and gig_id. Those let any visitor link
    a client's account to a booking with a named photographer, which no client
    agreed to. What proves the review is real is that it came from a booking;
    the niche and date say which kind and when. Whether a reviewer's name
    should ever appear is a separate privacy decision, not made here.
    """

    id: uuid.UUID
    rating: int
    text: str | None = None
    would_book_again: bool
    niche: ReviewNicheView
    video_playback_id: str | None = None
    created_at: datetime
    reply: ReviewReplyView | None = None


class ProReviewsResponse(BaseModel):
    total: int
    items: list[PublicReviewView]


class CreateReviewReplyRequest(BaseModel):
    text: str = Field(min_length=1, max_length=5000)


class ModerateReviewActionRequest(BaseModel):
    action: ReviewStatus
    reason: str | None = None
