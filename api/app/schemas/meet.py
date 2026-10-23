from __future__ import annotations

import uuid
from datetime import datetime
import enum

from pydantic import BaseModel, Field


class PresentationVideoView(BaseModel):
    """The slot for a photographer's presentation video. Nothing produces one
    yet: it is sent only once videos exist and PRESENTATION_VIDEO_ENABLED is on."""

    playback_url: str
    poster_url: str | None = None
    duration_seconds: int | None = None


class MeetInterviewItem(BaseModel):
    question_id: uuid.UUID
    # The heading the client reads.
    title: str
    answer: str


class MeetThePhotographerView(BaseModel):
    """A profile's "Meet the photographer" section. Absent (null) when there is
    nothing in it: no video and no published answer."""

    video: PresentationVideoView | None = None
    interview: list[MeetInterviewItem] = Field(default_factory=list)


class TeaserKind(str, enum.Enum):
    video = "video"
    interview = "interview"


class PhotographerTeaser(BaseModel):
    """What a Discover card shows of the section, only where one exists: a play
    badge for a video, or one line of the interview."""

    kind: TeaserKind
    line: str | None = None


# --- The photographer's own view ------------------------------------------------------------


class InterviewAnswerView(BaseModel):
    question_id: uuid.UUID
    # What they are asked, and what clients will read as the heading.
    prompt: str
    title: str
    hint: str | None = None
    min_chars: int
    max_chars: int
    draft: str | None = None
    published: str | None = None
    # Set when the draft looks like it holds contact details. A warning, never a block.
    warning: str | None = None


class MyInterviewView(BaseModel):
    items: list[InterviewAnswerView]
    is_published: bool
    published_at: datetime | None = None
    has_unpublished_changes: bool


class InterviewDraftIn(BaseModel):
    answers: dict[uuid.UUID, str | None]


# --- Admin ---------------------------------------------------------------------------------


class InterviewQuestionView(BaseModel):
    id: uuid.UUID
    key: str
    prompt: str
    title: str
    hint: str | None = None
    min_chars: int
    max_chars: int
    position: int
    is_active: bool


class InterviewQuestionIn(BaseModel):
    key: str | None = None
    prompt: str | None = None
    title: str | None = None
    hint: str | None = None
    min_chars: int | None = None
    max_chars: int | None = None
    position: int | None = None
    is_active: bool | None = None
