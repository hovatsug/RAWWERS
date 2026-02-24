from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.api.deps import get_current_user, get_db_session, require_not_banned
from app.core.errors import APIError
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
from app.schemas.media import (
    CompletePhotoUploadRequest,
    CompletePhotoUploadResponse,
    CurrentUser,
    MediaAssetView,
    MediaObjectView,
    MuxPayload,
    MuxUploadCreateRequest,
    MuxUploadCreateResponse,
    PhotoUploadCreateRequest,
    PhotoUploadCreateResponse,
    PlaybackTokenRequest,
    PlaybackTokenResponse,
    UploadPayload,
)
from app.services.mux import MuxClient
from app.services.security import create_mux_playback_token
from app.services.storage import create_presigned_get, create_presigned_put, generate_photo_storage_key
from app.tasks.media_tasks import process_photo_variants

router = APIRouter(prefix="/media", tags=["media"])


@router.post("/photos/uploads", response_model=PhotoUploadCreateResponse)
def create_photo_upload(
    body: PhotoUploadCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PhotoUploadCreateResponse:
    if body.purpose not in {MediaPurpose.proof, MediaPurpose.other, MediaPurpose.portfolio_reel, MediaPurpose.video_review}:
        raise APIError(code="validation_error", message="Unsupported purpose", status_code=422)

    storage_key = generate_photo_storage_key(str(user.user_id), body.file_name)
    asset = MediaAsset(
        owner_user_id=user.user_id,
        kind=MediaKind.photo,
        purpose=body.purpose,
        provider=MediaProvider.r2,
        status=MediaStatus.uploading,
        visibility=MediaVisibility.owner_only,
        content_type=body.content_type,
        meta={"file_name": body.file_name} if body.file_name else {},
    )
    db.add(asset)
    db.flush()

    original = MediaObject(
        media_asset_id=asset.id,
        variant=MediaVariant.original,
        storage_key=storage_key,
        status=ObjectStatus.created,
    )
    db.add(original)
    db.commit()

    upload_url = create_presigned_put(storage_key=storage_key, content_type=body.content_type)
    return PhotoUploadCreateResponse(
        media_asset_id=asset.id,
        upload=UploadPayload(
            method="PUT",
            url=upload_url,
            headers={"Content-Type": body.content_type},
            storage_key=storage_key,
            expires_in=900,
        ),
    )


@router.post("/photos/{media_asset_id}/complete", response_model=CompletePhotoUploadResponse)
def complete_photo_upload(
    media_asset_id: uuid.UUID,
    body: CompletePhotoUploadRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CompletePhotoUploadResponse:
    asset = db.get(MediaAsset, media_asset_id)
    if not asset or asset.kind != MediaKind.photo:
        raise APIError(code="not_found", message="Photo media asset not found", status_code=404)
    _ensure_owner(user.user_id, asset.owner_user_id)

    if asset.status not in {MediaStatus.uploading, MediaStatus.created}:
        raise APIError(code="invalid_state", message="Photo upload cannot be completed from current state", status_code=409)

    asset.status = MediaStatus.processing
    if body.byte_size is not None:
        asset.byte_size = body.byte_size
    db.commit()

    process_photo_variants.delay(str(asset.id))

    return CompletePhotoUploadResponse(ok=True, current_status=asset.status.value)


@router.post("/videos/mux/uploads", response_model=MuxUploadCreateResponse)
def create_mux_upload(
    body: MuxUploadCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MuxUploadCreateResponse:
    if body.purpose not in {MediaPurpose.portfolio_reel, MediaPurpose.video_review}:
        raise APIError(code="validation_error", message="Video purpose must be portfolio_reel or video_review", status_code=422)

    visibility = body.visibility
    if visibility is None:
        visibility = MediaVisibility.public if body.purpose == MediaPurpose.portfolio_reel else MediaVisibility.owner_only

    mux = MuxClient()
    upload_data = mux.create_direct_upload()

    asset = MediaAsset(
        owner_user_id=user.user_id,
        kind=MediaKind.video,
        purpose=body.purpose,
        provider=MediaProvider.mux,
        provider_upload_id=upload_data["id"],
        status=MediaStatus.uploading,
        visibility=visibility,
        content_type="video/mp4",
        meta={"mux_upload": upload_data},
    )
    db.add(asset)
    db.commit()

    return MuxUploadCreateResponse(
        media_asset_id=asset.id,
        mux=MuxPayload(
            direct_upload_id=upload_data["id"],
            upload_url=upload_data["url"],
            expires_in=upload_data.get("timeout"),
        ),
    )


@router.post("/videos/{media_asset_id}/playback-token", response_model=PlaybackTokenResponse)
def create_playback_token(
    media_asset_id: uuid.UUID,
    body: PlaybackTokenRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> PlaybackTokenResponse:
    asset = db.get(MediaAsset, media_asset_id)
    if not asset or asset.kind != MediaKind.video:
        raise APIError(code="not_found", message="Video media asset not found", status_code=404)

    _ensure_read_access(asset, user.user_id)

    playback_id = body.playback_id or asset.meta.get("playback_id")
    if not playback_id:
        raise APIError(code="invalid_state", message="No playback id available", status_code=409)

    token = create_mux_playback_token(playback_id, expires_in_seconds=300)
    return PlaybackTokenResponse(token=token, playback_id=playback_id, expires_in=300)


@router.get("/{media_asset_id}", response_model=MediaAssetView)
def get_media_asset(
    media_asset_id: uuid.UUID,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> MediaAssetView:
    asset = db.execute(
        select(MediaAsset)
        .options(selectinload(MediaAsset.objects))
        .where(MediaAsset.id == media_asset_id)
    ).scalar_one_or_none()

    if not asset:
        raise APIError(code="not_found", message="Media asset not found", status_code=404)

    _ensure_read_access(asset, user.user_id)

    variants = []
    playback_id = asset.meta.get("playback_id")

    if asset.kind == MediaKind.photo:
        for obj in asset.objects:
            url = create_presigned_get(obj.storage_key, expires_in=900) if obj.status == ObjectStatus.ready else None
            variants.append(
                MediaObjectView(
                    variant=obj.variant.value,
                    status=obj.status.value,
                    width=obj.width,
                    height=obj.height,
                    url=url,
                )
            )

    return MediaAssetView(
        id=asset.id,
        owner_user_id=asset.owner_user_id,
        kind=asset.kind.value,
        purpose=asset.purpose.value,
        provider=asset.provider.value,
        status=asset.status.value,
        visibility=asset.visibility.value,
        content_type=asset.content_type,
        byte_size=asset.byte_size,
        meta=asset.meta,
        created_at=asset.created_at,
        updated_at=asset.updated_at,
        variants=variants,
        playback_id=playback_id,
        is_public=asset.visibility == MediaVisibility.public,
    )


def _ensure_owner(user_id: uuid.UUID, owner_user_id: uuid.UUID) -> None:
    if user_id != owner_user_id:
        raise APIError(code="forbidden", message="Not owner of media asset", status_code=403)


def _ensure_read_access(asset: MediaAsset, user_id: uuid.UUID) -> None:
    if asset.visibility == MediaVisibility.public:
        return
    if asset.visibility == MediaVisibility.owner_only and asset.owner_user_id != user_id:
        raise APIError(code="forbidden", message="Insufficient access for this media asset", status_code=403)
    if asset.visibility != MediaVisibility.owner_only and asset.owner_user_id != user_id:
        raise APIError(code="forbidden", message="Visibility not yet supported for non-owner access", status_code=403)
