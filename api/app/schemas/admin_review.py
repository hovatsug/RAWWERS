from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.review import ReviewStatus


class AdminReviewModeration(BaseModel):
    """The most recent moderation decision on a review, from the audit log."""

    action: str
    reason: str | None = None
    at: datetime
    actor_user_id: uuid.UUID


class AdminReviewRow(BaseModel):
    """A review as a moderator needs it: who wrote it about whom, and what
    has already been decided about it. Unlike the public view, it names the
    client - a moderator judging a review has to be able to see that it is,
    say, the same person leaving one-star reviews on every competitor."""

    id: uuid.UUID
    status: ReviewStatus
    rating: int
    text: str | None = None
    tags: list[str] = Field(default_factory=list)
    would_book_again: bool
    has_video: bool
    niche_name: str | None = None
    gig_id: uuid.UUID
    pro_user_id: uuid.UUID
    pro_display_name: str | None = None
    client_user_id: uuid.UUID
    client_email: str | None = None
    reply_text: str | None = None
    created_at: datetime
    last_moderation: AdminReviewModeration | None = None


class AdminReviewListResponse(BaseModel):
    items: list[AdminReviewRow] = Field(default_factory=list)
    #: Matching the filters, for paging.
    total: int
    #: Every review by status, whatever the filters - the tab counts.
    counts: dict[str, int]
