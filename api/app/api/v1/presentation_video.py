"""The "Meet the photographer" video: the photographer's routes, the client's
playback, and the admin's removal (services/presentation_video.py)."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.media import MediaAsset, MediaStatus
from app.schemas.media import CurrentUser
from app.schemas.presentation_video import (
    AdminPresentationVideoRemoved,
    MyPresentationVideo,
    MyPresentationVideoState,
    PresentationVideoPlayback,
    PresentationVideoUploadRequest,
    PresentationVideoUploadResponse,
)
from app.services import presentation_video as pv
from app.services.audit import add_admin_audit_log
from app.services.authz import get_user_roles
from app.services.rate_limit import enforce_named_rate_limit

router = APIRouter(tags=["presentation_video"])


def _base_url(request: Request) -> str:
    return str(request.base_url)


def _pro(db: Session, user: CurrentUser) -> uuid.UUID:
    if UserRoleType.pro not in get_user_roles(db, user.user_id):
        raise APIError(code="forbidden", message="Only photographers have a video", status_code=403)
    return user.user_id


def _mine(db: Session, video: MediaAsset, base_url: str) -> MyPresentationVideo:
    from app.services.mux import get_mux_client

    meta = video.meta or {}
    playback_id = meta.get("playback_id") if video.status == MediaStatus.ready else None
    poster = playback = None
    if playback_id and pv.available():
        client = get_mux_client()
        poster = client.poster_url(playback_id, expires_in=pv.POSTER_TTL_SECONDS, base_url=base_url)
        playback = client.playback_url(playback_id, expires_in=pv.PLAYBACK_TTL_SECONDS, base_url=base_url)
    duration = meta.get("duration_seconds")
    status = video.status.value
    return MyPresentationVideo(
        media_asset_id=video.id,
        status="uploading" if status == "created" else status,
        poster_url=poster,
        playback_url=playback,
        duration_seconds=round(float(duration)) if duration is not None else None,
        message=pv.failure_message(video) if video.status == MediaStatus.failed else None,
    )


def _state(db: Session, pro_user_id: uuid.UUID, base_url: str) -> MyPresentationVideoState:
    available = pv.available()
    shown = pv.shown_video(db, pro_user_id) if available else None
    pending = pv.pending_video(db, pro_user_id) if available else None
    return MyPresentationVideoState(
        available=available,
        message=None if available else pv.NOT_AVAILABLE,
        max_seconds=pv.MAX_SECONDS,
        max_bytes=pv.MAX_BYTES,
        shown=_mine(db, shown, base_url) if shown else None,
        pending=_mine(db, pending, base_url) if pending else None,
    )


@router.get("/pro/me/presentation-video", response_model=MyPresentationVideoState)
def my_presentation_video(request: Request, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)):
    return _state(db, _pro(db, user), _base_url(request))


@router.post("/pro/me/presentation-video/uploads", response_model=PresentationVideoUploadResponse)
def start_presentation_video_upload(
    body: PresentationVideoUploadRequest,
    request: Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> PresentationVideoUploadResponse:
    pro = _pro(db, user)
    pv.require_available()
    enforce_named_rate_limit("presentation_video", principal=str(pro))
    video, url = pv.start_upload(
        db, pro, byte_size=body.byte_size, duration_seconds=body.duration_seconds, content_type=body.content_type,
        request_id=body.request_id, base_url=_base_url(request),
    )
    db.commit()
    return PresentationVideoUploadResponse(media_asset_id=video.id, upload_url=url, status="uploading")


@router.post("/pro/me/presentation-video/{media_asset_id}/uploaded", response_model=MyPresentationVideoState)
def presentation_video_uploaded(media_asset_id: uuid.UUID, request: Request, user: CurrentUser = Depends(require_not_banned),
                                db: Session = Depends(get_db_session)):
    pro = _pro(db, user)
    pv.mark_uploaded(db, pro, media_asset_id)
    db.commit()
    return _state(db, pro, _base_url(request))


@router.delete("/pro/me/presentation-video/{media_asset_id}", response_model=MyPresentationVideoState)
def delete_presentation_video(media_asset_id: uuid.UUID, request: Request, user: CurrentUser = Depends(require_not_banned),
                              db: Session = Depends(get_db_session)):
    pro = _pro(db, user)
    enforce_named_rate_limit("presentation_video", principal=str(pro))
    pv.delete_video(db, pro, media_asset_id)
    db.commit()
    return _state(db, pro, _base_url(request))


@router.post("/client/pros/{pro_user_id}/presentation-video/playback", response_model=PresentationVideoPlayback)
def play_presentation_video(pro_user_id: uuid.UUID, request: Request, user: CurrentUser = Depends(require_not_banned),
                            db: Session = Depends(get_db_session)) -> PresentationVideoPlayback:
    enforce_named_rate_limit("public_read", principal=str(user.user_id))
    url, ttl = pv.playback(db, pro_user_id, base_url=_base_url(request))
    return PresentationVideoPlayback(playback_url=url, expires_in=ttl)


@router.delete("/admin/pros/{pro_user_id}/presentation-video", response_model=AdminPresentationVideoRemoved)
def admin_remove_presentation_video(pro_user_id: uuid.UUID, actor: CurrentUser = Depends(require_admin),
                                    db: Session = Depends(get_db_session)) -> AdminPresentationVideoRemoved:
    removed = pv.remove_all_for(db, pro_user_id, reason="removed by an admin")
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="pro_user", target_id=str(pro_user_id),
                        action="presentation_video_removed", metadata={"removed": removed})
    db.commit()
    return AdminPresentationVideoRemoved(removed=removed)
