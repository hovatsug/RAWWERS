from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.api.deps import get_current_user, get_db_session, require_not_banned
from app.core.config import get_settings
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
    MultipartPartsResponse,
    MultipartPartUrl,
    MultipartPartUrlsRequest,
    MultipartPartUrlsResponse,
    MultipartPartView,
    MultipartStartRequest,
    MultipartStartResponse,
    PhotoUploadCreateRequest,
    PhotoUploadCreateResponse,
    PlaybackTokenRequest,
    PlaybackTokenResponse,
    UploadPayload,
)
from app.services.discovery_index import recompute_pro_public_index
from app.services.feature_flags import is_feature_enabled
from app.services.mux import MuxClient
from app.services.rate_limit import enforce_named_rate_limit
from app.services.security import create_mux_playback_token
from app.services.storage import (
    MULTIPART_PART_SIZE,
    abort_multipart_upload,
    complete_multipart_upload,
    create_multipart_upload,
    create_presigned_get,
    create_presigned_put,
    create_presigned_upload_part,
    delete_object,
    list_uploaded_parts,
    object_size,
)
from app.services.photo_uploads import begin_photo_upload
from app.tasks.media_tasks import process_photo_variants

router = APIRouter(prefix="/media", tags=["media"])
settings = get_settings()


def _default_visibility(purpose: MediaPurpose, requested: MediaVisibility | None) -> MediaVisibility:
    """Portfolio work is public; everything else is the owner's alone.

    Photo uploads used to hardcode `owner_only` regardless of purpose, while
    the video path beside them already defaulted `portfolio_reel` to public.
    The result was that a pro's portfolio photos 403'd for every client who
    tried to fetch one - the portfolio being, by definition, the work a pro
    wants strangers to see.
    """
    if requested is not None:
        return requested
    return MediaVisibility.public if purpose == MediaPurpose.portfolio_reel else MediaVisibility.owner_only


def _check_gear_evidence_upload(content_type: str, file_name: str | None) -> None:
    """A camera file: any RAW extension, or a camera-original JPEG.

    RAW files have no agreed MIME type - most arrive as
    application/octet-stream - so the file name's extension carries as much of
    the decision as the content type does. Neither is proof of anything; what
    the file actually is gets decided when its header is read.
    """
    if content_type.lower() not in settings.gear_evidence_mime_type_set():
        raise APIError(code="validation_error", message="Unsupported content_type", status_code=422)
    extension = (file_name or "").rsplit(".", 1)[-1].lower() if file_name and "." in file_name else ""
    if extension not in settings.gear_evidence_extension_set():
        raise APIError(
            code="validation_error",
            message="That does not look like a camera file. Send the RAW file or the original JPEG from the camera.",
            status_code=422,
        )


def _complete_gear_evidence(db: Session, asset: MediaAsset) -> CompletePhotoUploadResponse:
    """Evidence has nothing to process: no thumbnail, no watermark, no variants.

    Its size is read from the object itself. The client-reported `byte_size` is
    whatever the client says, and a presigned PUT does not bound what is sent,
    so an oversized upload is deleted rather than kept.
    """
    original = db.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant == MediaVariant.original)
    ).scalar_one_or_none()
    size = object_size(original.storage_key) if original else None
    if size is None:
        raise APIError(code="validation_error", message="The file has not been uploaded", status_code=422)
    if size > settings.gear_evidence_max_bytes:
        delete_object(original.storage_key)
        asset.status = MediaStatus.failed
        asset.meta = {**asset.meta, "failure_reason": "Upload exceeds size limit"}
        db.commit()
        raise APIError(code="validation_error", message="Upload exceeds size limit", status_code=422)

    original.status = ObjectStatus.ready
    asset.byte_size = size
    asset.status = MediaStatus.ready
    db.commit()
    return CompletePhotoUploadResponse(ok=True, current_status=asset.status.value)


@router.post("/photos/uploads", response_model=PhotoUploadCreateResponse)
def create_photo_upload(
    body: PhotoUploadCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PhotoUploadCreateResponse:
    enforce_named_rate_limit("uploads", principal=str(user.user_id))
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    if body.purpose not in {
        MediaPurpose.proof,
        MediaPurpose.other,
        MediaPurpose.portfolio_reel,
        MediaPurpose.video_review,
        MediaPurpose.gear_evidence,
    }:
        raise APIError(code="validation_error", message="Unsupported purpose", status_code=422)
    if body.purpose == MediaPurpose.gear_evidence:
        _check_gear_evidence_upload(body.content_type, body.file_name)
    elif body.content_type.lower() not in settings.allowed_upload_mime_type_set():
        raise APIError(code="validation_error", message="Unsupported content_type", status_code=422)

    asset, started = begin_photo_upload(
        db,
        owner_user_id=user.user_id,
        purpose=body.purpose,
        visibility=_default_visibility(body.purpose, body.visibility),
        content_type=body.content_type,
        file_name=body.file_name,
    )
    if body.purpose == MediaPurpose.portfolio_reel:
        recompute_pro_public_index(db, user.user_id)
    db.commit()
    return started


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
    if asset.purpose == MediaPurpose.gear_evidence:
        return _complete_gear_evidence(db, asset)
    if body.byte_size and body.byte_size > settings.max_upload_bytes:
        raise APIError(code="validation_error", message="Upload exceeds size limit", status_code=422)

    asset.status = MediaStatus.processing
    if body.byte_size is not None:
        asset.byte_size = body.byte_size
    db.commit()

    process_photo_variants.delay(str(asset.id))

    return CompletePhotoUploadResponse(ok=True, current_status=asset.status.value)


def _uploading_original(db: Session, media_asset_id: uuid.UUID, user: CurrentUser) -> tuple[MediaAsset, MediaObject]:
    """The caller's own photo, still waiting for its bytes, and its original object."""
    asset = db.get(MediaAsset, media_asset_id)
    if not asset or asset.kind != MediaKind.photo:
        raise APIError(code="not_found", message="Photo media asset not found", status_code=404)
    _ensure_owner(user.user_id, asset.owner_user_id)
    if asset.status not in {MediaStatus.uploading, MediaStatus.created}:
        raise APIError(code="invalid_state", message="This upload has already been completed", status_code=409)
    original = db.execute(
        select(MediaObject).where(MediaObject.media_asset_id == asset.id, MediaObject.variant == MediaVariant.original)
    ).scalar_one()
    return asset, original


@router.post("/photos/{media_asset_id}/upload-url", response_model=UploadPayload)
def refresh_photo_upload_url(
    media_asset_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UploadPayload:
    """A fresh presigned PUT for the same asset, for a retry.

    A retry used to create a new asset every time, leaving each failed
    attempt behind as an orphan stuck in `uploading`. A presigned URL still
    must not be reused after a failed PUT, so this signs a new one - for the
    same key.
    """
    enforce_named_rate_limit("uploads", principal=str(user.user_id))
    asset, original = _uploading_original(db, media_asset_id, user)
    return UploadPayload(
        method="PUT",
        url=create_presigned_put(storage_key=original.storage_key, content_type=asset.content_type),
        headers={"Content-Type": asset.content_type},
        storage_key=original.storage_key,
        expires_in=900,
    )


def _max_bytes_for(asset: MediaAsset) -> int:
    return settings.gear_evidence_max_bytes if asset.purpose == MediaPurpose.gear_evidence else settings.max_upload_bytes


def _multipart_state(asset: MediaAsset) -> dict:
    state = (asset.meta or {}).get("multipart")
    if not state:
        raise APIError(code="invalid_state", message="No multipart upload in progress", status_code=409)
    return state


@router.post("/photos/{media_asset_id}/multipart", response_model=MultipartStartResponse)
def start_multipart_upload(
    media_asset_id: uuid.UUID,
    body: MultipartStartRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MultipartStartResponse:
    """Start - or, called again, resume - sending a large original in parts.

    Calling it again for an upload already in progress returns the same
    layout rather than starting over: that is how an interrupted upload picks
    up where it stopped.
    """
    enforce_named_rate_limit("uploads", principal=str(user.user_id))
    asset, original = _uploading_original(db, media_asset_id, user)
    if body.byte_size > _max_bytes_for(asset):
        raise APIError(code="validation_error", message="Upload exceeds size limit", status_code=422)
    existing = (asset.meta or {}).get("multipart")
    if existing and existing["byte_size"] == body.byte_size:
        return MultipartStartResponse(part_size=existing["part_size"], part_count=existing["part_count"])
    if existing:
        # The same asset with a different file behind it: the old parts are no use.
        abort_multipart_upload(original.storage_key, existing["upload_id"])
    upload_id = create_multipart_upload(original.storage_key, asset.content_type)
    part_count = -(-body.byte_size // MULTIPART_PART_SIZE)
    asset.meta = {
        **(asset.meta or {}),
        "multipart": {
            "upload_id": upload_id,
            "byte_size": body.byte_size,
            "part_size": MULTIPART_PART_SIZE,
            "part_count": part_count,
        },
    }
    db.commit()
    return MultipartStartResponse(part_size=MULTIPART_PART_SIZE, part_count=part_count)


@router.post("/photos/{media_asset_id}/multipart/part-urls", response_model=MultipartPartUrlsResponse)
def multipart_part_urls(
    media_asset_id: uuid.UUID,
    body: MultipartPartUrlsRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MultipartPartUrlsResponse:
    asset, original = _uploading_original(db, media_asset_id, user)
    state = _multipart_state(asset)
    if any(n < 1 or n > state["part_count"] for n in body.part_numbers):
        raise APIError(code="validation_error", message="Part number out of range", status_code=422)
    return MultipartPartUrlsResponse(
        parts=[
            MultipartPartUrl(
                part_number=n, url=create_presigned_upload_part(original.storage_key, state["upload_id"], n)
            )
            for n in sorted(set(body.part_numbers))
        ],
        expires_in=900,
    )


@router.get("/photos/{media_asset_id}/multipart/parts", response_model=MultipartPartsResponse)
def multipart_parts(
    media_asset_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MultipartPartsResponse:
    """The parts R2 already holds - what a resumed upload can skip."""
    asset, original = _uploading_original(db, media_asset_id, user)
    state = _multipart_state(asset)
    return MultipartPartsResponse(
        part_size=state["part_size"],
        part_count=state["part_count"],
        parts=[
            MultipartPartView(part_number=p["part_number"], size=p["size"])
            for p in list_uploaded_parts(original.storage_key, state["upload_id"])
        ],
    )


@router.post("/photos/{media_asset_id}/multipart/complete", response_model=CompletePhotoUploadResponse)
def complete_multipart(
    media_asset_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CompletePhotoUploadResponse:
    """Assemble the parts into the original. The client then calls
    `/complete` as for any upload, so every check that runs there still runs.

    What is assembled comes from R2's own list of parts, checked against the
    layout agreed at start - every part present, each the right size, adding
    up to the declared file - not from anything the client says it sent.
    """
    asset, original = _uploading_original(db, media_asset_id, user)
    state = _multipart_state(asset)
    held = {p["part_number"]: p for p in list_uploaded_parts(original.storage_key, state["upload_id"])}
    missing = [n for n in range(1, state["part_count"] + 1) if n not in held]
    if missing:
        raise APIError(
            code="validation_error",
            message=f"{len(missing)} part(s) have not arrived yet",
            status_code=422,
            details={"missing_parts": missing},
        )
    last = state["part_count"]
    expected_last = state["byte_size"] - state["part_size"] * (last - 1)
    wrong = [
        n for n, p in held.items()
        if n > last or p["size"] != (expected_last if n == last else state["part_size"])
    ]
    if wrong:
        raise APIError(
            code="validation_error",
            message="Some parts are not the size this upload was started with",
            status_code=422,
            details={"wrong_parts": sorted(wrong)},
        )
    complete_multipart_upload(original.storage_key, state["upload_id"], [(n, held[n]["etag"]) for n in range(1, last + 1)])
    asset.meta = {k: v for k, v in (asset.meta or {}).items() if k != "multipart"}
    db.commit()
    return CompletePhotoUploadResponse(ok=True, current_status=asset.status.value)


@router.post("/photos/{media_asset_id}/multipart/abort", response_model=CompletePhotoUploadResponse)
def abort_multipart(
    media_asset_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CompletePhotoUploadResponse:
    """Give up on the parts sent so far, so R2 does not keep them."""
    asset, original = _uploading_original(db, media_asset_id, user)
    state = _multipart_state(asset)
    abort_multipart_upload(original.storage_key, state["upload_id"])
    asset.meta = {k: v for k, v in (asset.meta or {}).items() if k != "multipart"}
    db.commit()
    return CompletePhotoUploadResponse(ok=True, current_status=asset.status.value)


@router.post("/videos/mux/uploads", response_model=MuxUploadCreateResponse)
def create_mux_upload(
    body: MuxUploadCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MuxUploadCreateResponse:
    enforce_named_rate_limit("uploads", principal=str(user.user_id))
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    if not is_feature_enabled(db, "video_uploads_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Video uploads are temporarily disabled", status_code=503)
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
    if body.purpose == MediaPurpose.portfolio_reel:
        recompute_pro_public_index(db, user.user_id)
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
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PlaybackTokenResponse:
    asset = db.get(MediaAsset, media_asset_id)
    if not asset or asset.kind != MediaKind.video:
        raise APIError(code="not_found", message="Video media asset not found", status_code=404)

    _ensure_read_access(asset, user.user_id)

    # Only this video's playback id. The caller's id was signed as sent, so
    # access to one video bought a token for any other whose id was known.
    playback_id = asset.meta.get("playback_id")
    if body.playback_id and body.playback_id != playback_id:
        raise APIError(code="forbidden", message="That playback id is not this video's", status_code=403)
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
        niche_tags=asset.niche_tags or [],
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
