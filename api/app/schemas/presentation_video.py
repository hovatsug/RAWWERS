from __future__ import annotations

import uuid

from pydantic import BaseModel, Field


class PresentationVideoUploadRequest(BaseModel):
    """What the Pro app knows about the chosen video before sending it."""

    byte_size: int = Field(ge=1)
    duration_seconds: float | None = Field(default=None, ge=0)
    content_type: str | None = Field(default=None, max_length=64)
    #: The app's id for this attempt: the same id again returns the same upload.
    request_id: str = Field(min_length=8, max_length=64, pattern=r"^[A-Za-z0-9._-]+$")


class PresentationVideoUploadResponse(BaseModel):
    media_asset_id: uuid.UUID
    #: Send the file here with an HTTP PUT of its bytes (Content-Type: the video's).
    upload_url: str
    status: str


class MyPresentationVideo(BaseModel):
    media_asset_id: uuid.UUID
    #: uploading, processing, ready or failed.
    status: str
    poster_url: str | None = None
    playback_url: str | None = None
    duration_seconds: int | None = None
    #: For a failed one: what happened and what to do, in plain words.
    message: str | None = None


class MyPresentationVideoState(BaseModel):
    """The Pro app's "Meet the photographer" video screen."""

    available: bool
    #: When not available: "Video is not available right now."
    message: str | None = None
    max_seconds: int
    max_bytes: int
    #: The video clients see (only once ready).
    shown: MyPresentationVideo | None = None
    #: An upload in progress, or the latest failed one, newer than `shown`.
    pending: MyPresentationVideo | None = None


class PresentationVideoPlayback(BaseModel):
    playback_url: str
    expires_in: int


class AdminPresentationVideoRemoved(BaseModel):
    removed: int
