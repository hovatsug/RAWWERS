"""The routes a delivery token can call - the Lightroom plugin's whole API.

Pairing (`POST /delivery/pair`) is the one call without a token. Everything
else here takes `Authorization: Bearer rwd_...` and acts for that token's
photographer only. Every other route in the API refuses the token: they read
a signed access token, which this is not (tests/test_delivery_scope.py).

The plugin sends its version in `X-Rawwers-Plugin-Version`; every answer
carries `X-Rawwers-Update-Available` when a newer plugin exists (decision 10).
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass

from fastapi import APIRouter, Depends, Header, Request, Response
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session
from app.api.v1 import media as media_routes
from app.api.v1.proof_galleries import create_proof_gallery
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.gallery import ProofGallery, ProofGalleryItem, ProofGalleryStatus
from app.models.media import MediaAsset, MediaPurpose, MediaStatus, MediaVisibility
from app.schemas.delivery import (
    DeliveryCompleteRequest,
    DeliveryFailedPhoto,
    DeliveryGigsResponse,
    DeliveryMeResponse,
    DeliveryStatusResponse,
    DeliveryUploadRequest,
    DeliveryUploadResponse,
    PairRequest,
    PairResponse,
)
from app.schemas.gallery import CreateProofGalleryRequest
from app.schemas.media import (
    CompletePhotoUploadRequest,
    CompletePhotoUploadResponse,
    CurrentUser,
    MultipartPartsResponse,
    MultipartPartUrlsRequest,
    MultipartPartUrlsResponse,
    MultipartStartRequest,
    MultipartStartResponse,
    PhotoUploadCreateRequest,
    UploadPayload,
)
from app.services.delivery_access import authenticate, exchange_pairing_code, photographer_name, update_available
from app.services.delivery_gigs import deliverable_gigs, own_gig
from app.services.gig_state import require_gig_deliverable
from app.services.photo_uploads import max_photo_bytes
from app.services.rate_limit import enforce_named_rate_limit

router = APIRouter(prefix="/delivery", tags=["delivery"])

#: Files larger than this go in parts, as the pro app's do: a dropped
#: connection then costs one part, not the whole file.
MULTIPART_THRESHOLD_BYTES = 16 * 1024 * 1024

PLUGIN_VERSION_HEADER = "X-Rawwers-Plugin-Version"
UPDATE_HEADER = "X-Rawwers-Update-Available"


@dataclass(frozen=True)
class DeliveryDevice:
    """Who a delivery call is for: one photographer, through one device."""

    pro_user_id: uuid.UUID
    device_id: uuid.UUID
    plugin_version: str | None


def _say_if_outdated(response: Response, plugin_version: str | None) -> None:
    newer = update_available(plugin_version)
    if newer is not None:
        response.headers[UPDATE_HEADER] = "true" if newer else "false"


def require_delivery_device(
    response: Response,
    authorization: str | None = Header(default=None, alias="Authorization"),
    plugin_version: str | None = Header(default=None, alias=PLUGIN_VERSION_HEADER),
    db: Session = Depends(get_db_session),
) -> DeliveryDevice:
    raw = authorization.split(" ", 1)[1].strip() if authorization and authorization.lower().startswith("bearer ") else None
    token = authenticate(db, raw, plugin_version=plugin_version)
    _say_if_outdated(response, plugin_version)
    return DeliveryDevice(pro_user_id=token.pro_user_id, device_id=token.id, plugin_version=plugin_version)


def _request_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


@router.post("/pair", response_model=PairResponse)
def pair(body: PairRequest, request: Request, response: Response, db: Session = Depends(get_db_session)) -> PairResponse:
    """A pairing code from the pro app, for a delivery token."""
    enforce_named_rate_limit("delivery_pair_all", principal="all")
    enforce_named_rate_limit("delivery_pair_ip", principal=_request_ip(request))
    token, device = exchange_pairing_code(db, code=body.code, device_name=body.device_name, plugin_version=body.plugin_version)
    name = photographer_name(db, device.pro_user_id)
    db.commit()
    _say_if_outdated(response, body.plugin_version)
    return PairResponse(
        token=token,
        device_id=device.id,
        photographer_name=name,
        update_available=update_available(body.plugin_version),
        latest_version=get_settings().lightroom_plugin_latest_version,
    )


@router.get("/me", response_model=DeliveryMeResponse)
def me(device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)) -> DeliveryMeResponse:
    """Who the plugin is connected as: "Connected as <name>"."""
    return DeliveryMeResponse(
        photographer_name=photographer_name(db, device.pro_user_id),
        device_id=device.device_id,
        update_available=update_available(device.plugin_version),
        latest_version=get_settings().lightroom_plugin_latest_version,
    )


# --- delivering ----------------------------------------------------------------------
#
# The uploads below are the pro app's own (api/v1/media.py), called as the
# photographer: the same presigned URLs, multipart parts, size limit, delivery
# bucket and duplicate check by SHA-256 (step 1), and the same attach on the
# server when processing finishes (step 2). A delivery token adds its own
# daily cap (decision 1) and reaches only the photographer's own deliveries.


def _as_photographer(device: DeliveryDevice) -> CurrentUser:
    return CurrentUser(user_id=device.pro_user_id, roles=[UserRoleType.pro])


@router.get("/gigs", response_model=DeliveryGigsResponse)
def list_gigs(device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)) -> DeliveryGigsResponse:
    """The photographer's gigs that can receive photos, soonest shoot first."""
    return DeliveryGigsResponse(items=deliverable_gigs(db, device.pro_user_id))


def _open_gallery(db: Session, device: DeliveryDevice, gig_id: uuid.UUID) -> ProofGallery:
    """The gig's gallery, made now if this is its first photo. Only one still
    being put together: once sent from the app it takes no more from here."""
    gig = own_gig(db, device.pro_user_id, gig_id)
    gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
    if gallery is None:
        require_gig_deliverable(gig)
        snapshot = (gig.meta or {}).get("pricing_snapshot")
        snapshot = snapshot if isinstance(snapshot, dict) else {}
        # The booking's own terms win inside create_proof_gallery; these
        # only stand in when it has none, as the pro app's do.
        created = create_proof_gallery(
            gig_id=gig.id,
            body=CreateProofGalleryRequest(
                included_photos=snapshot.get("included_photos") if isinstance(snapshot.get("included_photos"), int) else 10,
                extra_photo_price=str(snapshot.get("extra_photo_price") or "0.00"),
            ),
            user=_as_photographer(device),
            db=db,
        )
        gallery = db.get(ProofGallery, created.id)
    if gallery.status != ProofGalleryStatus.draft:
        raise APIError(
            code="gallery_sent",
            message="These photos were already sent to the client. Add any more from the RAWWERS Pro app.",
            status_code=409,
        )
    return gallery


@router.post("/gigs/{gig_id}/uploads", response_model=DeliveryUploadResponse)
def start_upload(
    gig_id: uuid.UUID,
    body: DeliveryUploadRequest,
    device: DeliveryDevice = Depends(require_delivery_device),
    db: Session = Depends(get_db_session),
) -> DeliveryUploadResponse:
    """Start one photo, or learn it is there already (same SHA-256)."""
    if body.byte_size > max_photo_bytes(MediaPurpose.proof):
        raise APIError(
            code="validation_error",
            message=f"{body.file_name} is larger than {max_photo_bytes(MediaPurpose.proof) // 1_000_000} MB. Export it smaller.",
            status_code=422,
        )
    gallery = _open_gallery(db, device, gig_id)
    # Per device, on top of the photographer's hourly bucket: what a leaked
    # token can add in a day before it is revoked.
    enforce_named_rate_limit("delivery_token_daily", principal=str(device.device_id))
    started = media_routes.create_photo_upload(
        body=PhotoUploadCreateRequest(
            purpose=MediaPurpose.proof,
            content_type=body.content_type,
            file_name=body.file_name,
            visibility=MediaVisibility.client_only,
            gallery_id=gallery.id,
            sha256=body.sha256,
        ),
        user=_as_photographer(device),
        db=db,
    )
    large = body.byte_size > MULTIPART_THRESHOLD_BYTES
    return DeliveryUploadResponse(
        media_asset_id=started.media_asset_id,
        gallery_id=gallery.id,
        duplicate=started.duplicate,
        upload=None if (started.duplicate or large) else started.upload,
        use_multipart=large and not started.duplicate,
    )


def _own_delivery(db: Session, device: DeliveryDevice, media_asset_id: uuid.UUID) -> MediaAsset:
    """A photo this photographer started as a delivery; anything else is the
    same 404."""
    asset = db.get(MediaAsset, media_asset_id)
    if asset is None or asset.owner_user_id != device.pro_user_id or asset.delivery_gallery_id is None:
        raise APIError(code="not_found", message="Upload not found", status_code=404)
    return asset


@router.post("/uploads/{media_asset_id}/url", response_model=UploadPayload)
def fresh_upload_url(
    media_asset_id: uuid.UUID, device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)
) -> UploadPayload:
    """A new presigned PUT for the same photo, to retry a failed one."""
    _own_delivery(db, device, media_asset_id)
    return media_routes.refresh_photo_upload_url(media_asset_id=media_asset_id, user=_as_photographer(device), db=db)


@router.post("/uploads/{media_asset_id}/multipart", response_model=MultipartStartResponse)
def start_parts(
    media_asset_id: uuid.UUID,
    body: MultipartStartRequest,
    device: DeliveryDevice = Depends(require_delivery_device),
    db: Session = Depends(get_db_session),
) -> MultipartStartResponse:
    _own_delivery(db, device, media_asset_id)
    return media_routes.start_multipart_upload(media_asset_id=media_asset_id, body=body, user=_as_photographer(device), db=db)


@router.get("/uploads/{media_asset_id}/multipart/parts", response_model=MultipartPartsResponse)
def parts_received(
    media_asset_id: uuid.UUID, device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)
) -> MultipartPartsResponse:
    """The parts storage holds already: what a resumed upload skips."""
    _own_delivery(db, device, media_asset_id)
    return media_routes.multipart_parts(media_asset_id=media_asset_id, user=_as_photographer(device), db=db)


@router.post("/uploads/{media_asset_id}/multipart/part-urls", response_model=MultipartPartUrlsResponse)
def part_urls(
    media_asset_id: uuid.UUID,
    body: MultipartPartUrlsRequest,
    device: DeliveryDevice = Depends(require_delivery_device),
    db: Session = Depends(get_db_session),
) -> MultipartPartUrlsResponse:
    _own_delivery(db, device, media_asset_id)
    return media_routes.multipart_part_urls(media_asset_id=media_asset_id, body=body, user=_as_photographer(device), db=db)


@router.post("/uploads/{media_asset_id}/multipart/complete", response_model=CompletePhotoUploadResponse)
def assemble_parts(
    media_asset_id: uuid.UUID, device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)
) -> CompletePhotoUploadResponse:
    """Join the parts into the original. Then finish it like any other."""
    _own_delivery(db, device, media_asset_id)
    return media_routes.complete_multipart(media_asset_id=media_asset_id, user=_as_photographer(device), db=db)


@router.post("/uploads/{media_asset_id}/complete", response_model=CompletePhotoUploadResponse)
def finish_upload(
    media_asset_id: uuid.UUID,
    body: DeliveryCompleteRequest,
    device: DeliveryDevice = Depends(require_delivery_device),
    db: Session = Depends(get_db_session),
) -> CompletePhotoUploadResponse:
    """The file is in storage: process it. The hash must be the one declared
    at the start; the worker then checks it against the bytes themselves."""
    asset = _own_delivery(db, device, media_asset_id)
    if (asset.checksum or "") != body.sha256.lower():
        raise APIError(
            code="checksum_mismatch",
            message="This file is not the one that was started. Export it again.",
            status_code=409,
        )
    return media_routes.complete_photo_upload(
        media_asset_id=media_asset_id,
        body=CompletePhotoUploadRequest(byte_size=body.byte_size),
        user=_as_photographer(device),
        db=db,
    )


@router.get("/galleries/{gallery_id}/status", response_model=DeliveryStatusResponse)
def delivery_status(
    gallery_id: uuid.UUID, device: DeliveryDevice = Depends(require_delivery_device), db: Session = Depends(get_db_session)
) -> DeliveryStatusResponse:
    """How far a delivery has got: in the gallery, still going, and what failed."""
    gallery = db.get(ProofGallery, gallery_id)
    if gallery is None or gallery.pro_user_id != device.pro_user_id:
        raise APIError(code="not_found", message="Gallery not found", status_code=404)
    in_gallery = len(db.execute(select(ProofGalleryItem.id).where(ProofGalleryItem.gallery_id == gallery.id)).all())
    assets = db.execute(select(MediaAsset).where(MediaAsset.delivery_gallery_id == gallery.id)).scalars().all()
    failed = [
        DeliveryFailedPhoto(
            media_asset_id=a.id,
            file_name=(a.meta or {}).get("file_name"),
            reason=(a.meta or {}).get("failure_reason"),
        )
        for a in assets
        if a.status == MediaStatus.failed
    ]
    return DeliveryStatusResponse(
        gallery_id=gallery.id,
        gig_id=gallery.gig_id,
        gallery_status=gallery.status.value,
        photos_in_gallery=in_gallery,
        uploading=sum(1 for a in assets if a.status in {MediaStatus.uploading, MediaStatus.created}),
        processing=sum(1 for a in assets if a.status == MediaStatus.processing),
        failed=failed[:200],
    )
