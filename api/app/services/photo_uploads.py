"""Starting a photo upload: the asset, its original object, and a presigned PUT.

The one way a photo gets into storage, whoever sends it: the app's uploads
and an admin's niche banners both go through here, straight from the device
to the bucket, never through the API.
"""
from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.models.media import (
    MediaAsset,
    MediaKind,
    MediaObject,
    MediaProvider,
    MediaPurpose,
    MediaStatus,
    MediaVariant,
    MediaVisibility,
    ObjectStatus,
)
from app.schemas.media import PhotoUploadCreateResponse, UploadPayload
from app.services.storage import create_presigned_put, generate_photo_storage_key

UPLOAD_URL_TTL_SECONDS = 900


def begin_photo_upload(
    db: Session,
    *,
    owner_user_id: uuid.UUID,
    purpose: MediaPurpose,
    visibility: MediaVisibility,
    content_type: str,
    file_name: str | None,
) -> tuple[MediaAsset, PhotoUploadCreateResponse]:
    """Flushes the asset; the caller commits."""
    storage_key = generate_photo_storage_key(str(owner_user_id), file_name)
    asset = MediaAsset(
        owner_user_id=owner_user_id,
        kind=MediaKind.photo,
        purpose=purpose,
        provider=MediaProvider.r2,
        status=MediaStatus.uploading,
        visibility=visibility,
        content_type=content_type,
        meta={"file_name": file_name} if file_name else {},
    )
    db.add(asset)
    db.flush()
    db.add(MediaObject(media_asset_id=asset.id, variant=MediaVariant.original, storage_key=storage_key, status=ObjectStatus.created))
    db.flush()
    return asset, PhotoUploadCreateResponse(
        media_asset_id=asset.id,
        upload=UploadPayload(
            method="PUT",
            url=create_presigned_put(storage_key=storage_key, content_type=content_type, expires_in=UPLOAD_URL_TTL_SECONDS),
            headers={"Content-Type": content_type},
            storage_key=storage_key,
            expires_in=UPLOAD_URL_TTL_SECONDS,
        ),
    )

