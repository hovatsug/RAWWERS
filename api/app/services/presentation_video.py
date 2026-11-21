"""The "Meet the photographer" video (BETA_SCOPE #37, MUST 2026-11-21).

One short video per photographer, uploaded from the Pro app straight to Mux
(a direct upload) and shown on their profile to clients.

The rules, all here:
- **Available** only when PRESENTATION_VIDEO_ENABLED is on and Mux is set up
  (or the development fake, services/mux_fake.py). Otherwise every route
  answers in plain words - "Video is not available right now" - and clients
  simply see no video.
- **Limits:** 60 seconds and 200 MB, MP4 or MOV. Checked when the upload
  starts (what the app declares) and again when Mux reports the encoded
  duration: a longer video is refused, and its Mux asset deleted.
- **One shown at a time.** A new upload replaces the shown video only once it
  is ready; until then the old one stays. Only one upload is in progress: a
  new one retires the one before.
- **Recoverable.** Starting again with the same request id returns the same
  upload (never a second Mux upload); "uploaded" said twice is the same
  success; a failed video is replaced by uploading again.
- **Gone means gone.** Deleting hides the video from clients at once; the Mux
  asset is deleted then, and if Mux does not answer, the deletion is kept and
  retried by the mux-sync job until it succeeds (`MUX_DELETE_PENDING`).
- **Clients** see it only while the photographer is live (approved for the
  public, not banned or suspended) and the video is ready, and play it
  through a signed URL valid for five minutes.
"""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility

logger = logging.getLogger(__name__)

MAX_SECONDS = 60
#: 200 MB: a minute of 1080p from a phone (about 10-20 Mbit/s, 75-150 MB)
#: with room to spare; a 4K or high-frame-rate clip (300-700 MB a minute) is
#: refused with a way out. Mux stores and plays 1080p at most here anyway.
MAX_BYTES = 200_000_000
#: A container's duration can run a fraction over the recording's.
_DURATION_SLACK = 0.9
CONTENT_TYPES = {"video/mp4", "video/quicktime"}
PLAYBACK_TTL_SECONDS = 300
POSTER_TTL_SECONDS = 3600

NOT_AVAILABLE = "Video is not available right now."
TOO_LONG = f"Your video is longer than {MAX_SECONDS} seconds. Choose or record a shorter one."
TOO_BIG = (f"Your video is larger than {MAX_BYTES // 1_000_000} MB. Record it in 1080p "
           "(iPhone: Settings > Camera > Record Video) or choose a shorter clip.")
WRONG_TYPE = "Choose an MP4 or MOV video."

#: In a video's meta: the Mux asset still has to be deleted (retried).
MUX_DELETE_PENDING = "mux_delete_pending"
PENDING = (MediaStatus.created, MediaStatus.uploading, MediaStatus.processing)


def available() -> bool:
    from app.services.mux import mux_available

    return bool(get_settings().presentation_video_enabled) and mux_available()


def require_available() -> None:
    if not available():
        raise APIError(code="video_unavailable", message=NOT_AVAILABLE, status_code=503)


def _videos(db: Session, pro_user_id: uuid.UUID, statuses) -> list[MediaAsset]:
    return list(db.execute(
        select(MediaAsset).where(
            MediaAsset.owner_user_id == pro_user_id,
            MediaAsset.purpose == MediaPurpose.presentation_video,
            MediaAsset.status.in_(tuple(statuses)),
        ).order_by(MediaAsset.created_at.desc())
    ).scalars())


def shown_video(db: Session, pro_user_id: uuid.UUID) -> MediaAsset | None:
    """The ready video, newest first (there is at most one)."""
    ready = _videos(db, pro_user_id, (MediaStatus.ready,))
    return ready[0] if ready else None


def pending_video(db: Session, pro_user_id: uuid.UUID) -> MediaAsset | None:
    """The upload in progress, or the latest failed one (so the app can say
    what went wrong), if newer than the shown video."""
    rows = _videos(db, pro_user_id, (*PENDING, MediaStatus.failed))
    shown = shown_video(db, pro_user_id)
    if not rows or (shown is not None and rows[0].created_at <= shown.created_at):
        return None
    return rows[0]


def own_video(db: Session, pro_user_id: uuid.UUID, media_asset_id: uuid.UUID) -> MediaAsset:
    """Their own video, not deleted; anything else is the same 404."""
    asset = db.get(MediaAsset, media_asset_id)
    if (asset is None or asset.owner_user_id != pro_user_id or asset.purpose != MediaPurpose.presentation_video
            or asset.status == MediaStatus.deleted):
        raise APIError(code="not_found", message="Video not found", status_code=404)
    return asset


def _lock_pro(db: Session, pro_user_id: uuid.UUID) -> None:
    """One request at a time per photographer: two "start" taps cannot both
    create an upload."""
    from app.models.admin import ProProfile

    db.execute(select(ProProfile.user_id).where(ProProfile.user_id == pro_user_id).with_for_update()).first()


def check_limits(*, byte_size: int | None, duration_seconds: float | None, content_type: str | None) -> None:
    if content_type and content_type.lower() not in CONTENT_TYPES:
        raise APIError(code="validation_error", message=WRONG_TYPE, status_code=422)
    if byte_size is None or byte_size <= 0:
        raise APIError(code="validation_error", message="The video's size is missing. Choose it again.", status_code=422)
    if byte_size > MAX_BYTES:
        raise APIError(code="video_too_large", message=TOO_BIG, status_code=422)
    if duration_seconds is not None and duration_seconds > MAX_SECONDS + _DURATION_SLACK:
        raise APIError(code="video_too_long", message=TOO_LONG, status_code=422)


def start_upload(db: Session, pro_user_id: uuid.UUID, *, byte_size: int, duration_seconds: float | None,
                 content_type: str | None, request_id: str, base_url: str | None = None) -> tuple[MediaAsset, str]:
    """(the video, its upload URL). The same request id again returns the same
    upload while it is still open: a retry never makes a second Mux upload."""
    from app.services.mux import get_mux_client

    require_available()
    check_limits(byte_size=byte_size, duration_seconds=duration_seconds, content_type=content_type)
    _lock_pro(db, pro_user_id)
    for video in _videos(db, pro_user_id, PENDING):
        if (video.meta or {}).get("request_id") == request_id and video.status in (MediaStatus.created, MediaStatus.uploading):
            return video, (video.meta or {}).get("upload_url", "")
    # A new upload: the one in progress before it is abandoned.
    for video in _videos(db, pro_user_id, PENDING):
        retire(db, video, reason="replaced by a newer upload")
    asset = MediaAsset(
        owner_user_id=pro_user_id, kind=MediaKind.video, purpose=MediaPurpose.presentation_video,
        provider=MediaProvider.mux, status=MediaStatus.created, visibility=MediaVisibility.owner_only,
        content_type=(content_type or "video/mp4").lower(), byte_size=byte_size,
        meta={"request_id": request_id, "declared_seconds": duration_seconds},
    )
    db.add(asset)
    db.flush()
    upload = get_mux_client().create_direct_upload(passthrough=str(asset.id), base_url=base_url)
    asset.provider_upload_id = upload["id"]
    asset.status = MediaStatus.uploading
    asset.meta = {**asset.meta, "upload_url": upload["url"]}
    return asset, upload["url"]


def mark_uploaded(db: Session, pro_user_id: uuid.UUID, media_asset_id: uuid.UUID) -> MediaAsset:
    """The app finished sending the file: processing. Said again, or after
    Mux already answered, it is the same success."""
    video = own_video(db, pro_user_id, media_asset_id)
    if video.status in (MediaStatus.created, MediaStatus.uploading):
        video.status = MediaStatus.processing
    return video


def retire(db: Session, video: MediaAsset, *, reason: str) -> None:
    """Hidden from everyone now; its Mux asset (or open upload) cleared up
    now if Mux answers, later by the mux-sync job if not."""
    if video.status == MediaStatus.deleted:
        return
    video.status = MediaStatus.deleted
    video.meta = {**(video.meta or {}), "deleted_reason": reason, "deleted_at": datetime.now(timezone.utc).isoformat(),
                  MUX_DELETE_PENDING: True}
    db.flush()
    try_mux_cleanup(db, video)


def try_mux_cleanup(db: Session, video: MediaAsset) -> bool:
    """Delete the Mux asset of a deleted video (or cancel its open upload).
    True when nothing is left at Mux. A video whose asset Mux has not made yet
    keeps the deletion pending: when the asset appears, it is deleted then."""
    from app.services.mux import get_mux_client

    meta = video.meta or {}
    if not meta.get(MUX_DELETE_PENDING):
        return True
    client = get_mux_client()
    try:
        if video.provider_asset_id:
            client.delete_asset(video.provider_asset_id)
        elif video.provider_upload_id:
            client.cancel_upload(video.provider_upload_id)
            upload = client.get_upload(video.provider_upload_id)
            if upload and upload.get("asset_id"):
                video.provider_asset_id = upload["asset_id"]
                client.delete_asset(video.provider_asset_id)
            elif upload and upload.get("status") == "waiting":
                # Still open: try again later (it times out after an hour).
                video.meta = {**meta, "mux_delete_attempts": int(meta.get("mux_delete_attempts", 0)) + 1}
                return False
    except Exception:
        video.meta = {**meta, "mux_delete_attempts": int(meta.get("mux_delete_attempts", 0)) + 1}
        logger.warning("mux_delete_pending", extra={"media_asset_id": str(video.id)}, exc_info=True)
        return False
    video.meta = {**meta, MUX_DELETE_PENDING: False, "mux_deleted_at": datetime.now(timezone.utc).isoformat()}
    return True


def retry_pending_deletions(db: Session, *, limit: int = 100) -> int:
    """The mux-sync job's part: every deleted video whose Mux asset is not
    yet gone. Returns how many were cleared."""
    if not available() and not _mux_reachable():
        return 0
    cleared = 0
    rows = db.execute(
        select(MediaAsset).where(
            MediaAsset.provider == MediaProvider.mux,
            MediaAsset.status == MediaStatus.deleted,
            MediaAsset.meta[MUX_DELETE_PENDING].as_boolean().is_(True),
        ).limit(limit)
    ).scalars().all()
    for video in rows:
        if try_mux_cleanup(db, video):
            cleared += 1
    return cleared


def _mux_reachable() -> bool:
    from app.services.mux import mux_available

    return mux_available()


def delete_video(db: Session, pro_user_id: uuid.UUID, media_asset_id: uuid.UUID, *, reason: str = "deleted by the photographer") -> None:
    """Delete their video (shown, in progress or failed). Deleting one already
    gone is the same success."""
    asset = db.get(MediaAsset, media_asset_id)
    if asset is not None and asset.owner_user_id == pro_user_id and asset.purpose == MediaPurpose.presentation_video \
            and asset.status == MediaStatus.deleted:
        return
    retire(db, own_video(db, pro_user_id, media_asset_id), reason=reason)
    _refresh_profile_caches()


def remove_all_for(db: Session, pro_user_id: uuid.UUID, *, reason: str) -> int:
    """Every video of this photographer, for an admin removal or for the
    account's deletion (BETA_SCOPE #37 and batch 3): hidden now, Mux assets
    deleted now or by the retry."""
    videos = _videos(db, pro_user_id, (*PENDING, MediaStatus.ready, MediaStatus.failed))
    for video in videos:
        retire(db, video, reason=reason)
    _refresh_profile_caches()
    return len(videos)


def _refresh_profile_caches() -> None:
    from app.services.cache import bump_public_index_version

    bump_public_index_version()


# --- Mux events ---------------------------------------------------------------------------------


def on_ready(db: Session, video: MediaAsset, data: dict, playback_id: str | None) -> None:
    """Mux says the video is encoded. Longer than the limit: refused, and its
    Mux asset deleted. Otherwise it is shown, and the one shown before is
    retired. A deleted video whose asset arrives late gets that asset deleted."""
    if video.status == MediaStatus.deleted:
        video.meta = {**(video.meta or {}), MUX_DELETE_PENDING: True}
        try_mux_cleanup(db, video)
        return
    if video.status in (MediaStatus.ready, MediaStatus.failed):
        return
    duration = data.get("duration")
    meta = {**(video.meta or {}), "duration_seconds": duration}
    if playback_id:
        meta["playback_id"] = playback_id
    meta.pop("mux_error", None)
    if duration is not None and float(duration) > MAX_SECONDS + _DURATION_SLACK:
        video.status = MediaStatus.failed
        video.meta = {**meta, "mux_error": TOO_LONG, MUX_DELETE_PENDING: True}
        db.flush()
        try_mux_cleanup(db, video)
        return
    if not playback_id:
        video.status = MediaStatus.failed
        video.meta = {**meta, "mux_error": "The video has no signed playback. Upload it again."}
        return
    video.status = MediaStatus.ready
    video.meta = meta
    db.flush()
    for older in _videos(db, video.owner_user_id, (MediaStatus.ready,)):
        if older.id != video.id:
            retire(db, older, reason="replaced by a newer video")
    _refresh_profile_caches()


def failure_message(video: MediaAsset) -> str:
    error = (video.meta or {}).get("mux_error")
    if isinstance(error, str) and error in (TOO_LONG,):
        return error
    return "This video could not be processed. Try another one, or record it again."


# --- What clients get ----------------------------------------------------------------------------


def pro_is_live(db: Session, pro_user_id: uuid.UUID) -> bool:
    from app.services.authz import get_latest_ban_action
    from app.services.lightroom_portfolio import is_live
    from app.services.pro_standing import is_shut_out

    return is_live(db, pro_user_id) and not is_shut_out(get_latest_ban_action(db, pro_user_id))


def client_video(db: Session, pro_user_id: uuid.UUID, *, base_url: str | None = None):
    """What a profile shows: the poster and the length, or None (no section).
    Playing it is a separate call (playback), so its token is always fresh."""
    from app.schemas.meet import PresentationVideoView
    from app.services.mux import get_mux_client

    if not available() or not pro_is_live(db, pro_user_id):
        return None
    video = shown_video(db, pro_user_id)
    playback_id = (video.meta or {}).get("playback_id") if video else None
    if not playback_id:
        return None
    duration = (video.meta or {}).get("duration_seconds")
    client = get_mux_client()
    return PresentationVideoView(
        media_asset_id=video.id,
        # Valid for five minutes; the app asks for a fresh one when tapped
        # (POST /v1/client/pros/{id}/presentation-video/playback).
        playback_url=client.playback_url(playback_id, expires_in=PLAYBACK_TTL_SECONDS, base_url=base_url),
        poster_url=client.poster_url(playback_id, expires_in=POSTER_TTL_SECONDS, base_url=base_url),
        duration_seconds=round(float(duration)) if duration is not None else None,
    )


def playback(db: Session, pro_user_id: uuid.UUID, *, base_url: str | None = None) -> tuple[str, int]:
    """(a signed URL to play the photographer's video, seconds it is valid).
    The same 404 for a photographer who is not live, a video not ready, or
    none at all."""
    from app.services.mux import get_mux_client

    require_available()
    video = shown_video(db, pro_user_id) if pro_is_live(db, pro_user_id) else None
    playback_id = (video.meta or {}).get("playback_id") if video else None
    if not playback_id:
        raise APIError(code="not_found", message="No video to play", status_code=404)
    return get_mux_client().playback_url(playback_id, expires_in=PLAYBACK_TTL_SECONDS, base_url=base_url), PLAYBACK_TTL_SECONDS
