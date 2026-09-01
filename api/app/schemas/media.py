import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field

from app.models.media import MediaPurpose, MediaVisibility
from app.models.admin import UserRoleType


class CurrentUser(BaseModel):
    user_id: uuid.UUID
    roles: list[UserRoleType] = Field(default_factory=list)
    is_impersonating: bool = False
    impersonation_admin_user_id: uuid.UUID | None = None
    impersonation_session_id: uuid.UUID | None = None
    refresh_family_id: uuid.UUID | None = None


class PhotoUploadCreateRequest(BaseModel):
    purpose: MediaPurpose
    content_type: str
    file_name: str | None = None


class UploadPayload(BaseModel):
    method: str
    url: str
    headers: dict[str, str] = Field(default_factory=dict)
    storage_key: str
    expires_in: int


class PhotoUploadCreateResponse(BaseModel):
    media_asset_id: uuid.UUID
    upload: UploadPayload


class CompletePhotoUploadRequest(BaseModel):
    byte_size: int | None = None


class CompletePhotoUploadResponse(BaseModel):
    ok: bool
    current_status: str


class MuxUploadCreateRequest(BaseModel):
    purpose: MediaPurpose
    visibility: MediaVisibility | None = None


class MuxPayload(BaseModel):
    direct_upload_id: str
    upload_url: str
    expires_in: int | None = None


class MuxUploadCreateResponse(BaseModel):
    media_asset_id: uuid.UUID
    mux: MuxPayload


class PlaybackTokenRequest(BaseModel):
    playback_id: str | None = None


class PlaybackTokenResponse(BaseModel):
    token: str
    playback_id: str
    expires_in: int


class MediaObjectView(BaseModel):
    variant: str
    status: str
    width: int | None = None
    height: int | None = None
    url: str | None = None


class MediaAssetView(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: uuid.UUID
    owner_user_id: uuid.UUID
    kind: str
    purpose: str
    provider: str
    status: str
    visibility: str
    content_type: str | None = None
    byte_size: int | None = None
    metadata: dict[str, Any] = Field(default_factory=dict, alias="meta")
    created_at: datetime
    updated_at: datetime
    variants: list[MediaObjectView] = Field(default_factory=list)
    playback_id: str | None = None
    is_public: bool = False
    niche_tags: list[str] = Field(default_factory=list)
