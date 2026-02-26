from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import EntitlementHoldType, UserRoleType
from app.models.gallery import ProofGallery
from app.models.gig import Gig
from app.models.media import MediaAsset, MediaKind, MediaObject, MediaProvider, MediaVariant, ObjectStatus
from app.models.media_rights import (
    GigEntitlementType,
    GigUsageConsent,
    GigUsageConsentEvent,
    MediaAccessAction,
    MediaDerivative,
    MediaDerivativeKind,
    ShareLink,
    ShareLinkScope,
)
from app.schemas.media import CurrentUser
from app.schemas.media_rights import (
    AdminConsentEventsResponse,
    GigConsentEventView,
    GigConsentView,
    GigMediaAssetView,
    GigMediaListResponse,
    MediaDerivativeView,
    ShareLinkCreateRequest,
    ShareLinkCreateResponse,
    SharePingRequest,
    SharePingResponse,
    ShareLinkRevokeResponse,
    ShareLinkViewResponse,
    SharedMediaItemView,
    SignedUrlResponse,
    UpdateGigConsentRequest,
)
from app.services.audit import add_admin_audit_log
from app.services.authz import get_user_roles
from app.services.feature_flags import is_feature_enabled
from app.services.media_rights import (
    can_manage_share_links,
    ensure_gig_consent_snapshot,
    gallery_media_asset_ids,
    get_share_link_for_token,
    has_valid_entitlement,
    hash_share_token,
    is_share_link_active,
    log_media_access,
    set_gig_consent,
    share_link_asset_ids,
    unlocked_final_asset_ids,
)
from app.services.client_rewards_pricing import (
    maybe_emit_consent_toggle_abuse,
    ping_share_link_view,
    record_share_link_view,
    refresh_share_link_engagement,
)
from app.services.outbox import enqueue_outbox_event
from app.services.notifications import enqueue_notification
from app.services.rate_limit import enforce_named_rate_limit
from app.services.security import create_mux_playback_token
from app.services.storage import create_presigned_get
from app.services.disputes import active_entitlement_hold

settings = get_settings()
router = APIRouter(tags=["media_rights"])


@router.get("/gigs/{gig_id}/media", response_model=GigMediaListResponse)
def list_gig_media(
    gig_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigMediaListResponse:
    gig = _get_gig_or_404(db, gig_id)
    _ensure_gig_participant_or_admin(db, gig, user.user_id)

    asset_ids = gallery_media_asset_ids(db, gig_id=gig_id)
    if not asset_ids:
        return GigMediaListResponse(gig_id=gig_id, assets=[])

    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    can_view_proofs = is_admin or user.user_id == gig.pro_user_id or has_valid_entitlement(
        db,
        gig_id=gig.id,
        user_id=user.user_id,
        entitlement_type=GigEntitlementType.view_proofs,
    )
    can_download = is_admin or user.user_id == gig.pro_user_id or has_valid_entitlement(
        db,
        gig_id=gig.id,
        user_id=user.user_id,
        entitlement_type=GigEntitlementType.download_finals,
    ) or has_valid_entitlement(
        db,
        gig_id=gig.id,
        user_id=user.user_id,
        entitlement_type=GigEntitlementType.download_extras,
    )

    assets_out: list[GigMediaAssetView] = []
    for asset_id in asset_ids:
        asset = db.get(MediaAsset, asset_id)
        if not asset:
            continue
        kinds = _available_derivative_kinds(db, asset.id)
        allowed: list[MediaDerivativeKind] = []
        for kind in kinds:
            if kind == MediaDerivativeKind.preview_watermarked and can_view_proofs:
                allowed.append(kind)
            elif kind in {MediaDerivativeKind.full_res, MediaDerivativeKind.web_res} and can_download:
                allowed.append(kind)
            elif kind == MediaDerivativeKind.thumbnail and can_view_proofs:
                allowed.append(kind)

        if not allowed and user.user_id == gig.pro_user_id:
            allowed = kinds

        if allowed:
            assets_out.append(
                GigMediaAssetView(
                    media_asset_id=asset.id,
                    kind=asset.kind.value,
                    purpose=asset.purpose.value,
                    derivatives=[MediaDerivativeView(kind=item.value) for item in allowed],
                )
            )

    return GigMediaListResponse(gig_id=gig.id, assets=assets_out)


@router.get("/gigs/{gig_id}/media/{media_asset_id}/signed-url", response_model=SignedUrlResponse)
def get_media_signed_url(
    gig_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    request: Request,
    kind: MediaDerivativeKind = Query(...),
    share_token: str | None = Query(default=None),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SignedUrlResponse:
    return _signed_url_response(
        db,
        request=request,
        gig_id=gig_id,
        media_asset_id=media_asset_id,
        kind=kind,
        user=user,
        share_token=share_token,
    )


@router.get("/gigs/{gig_id}/media/{media_asset_id}/download", response_model=SignedUrlResponse)
def download_media(
    gig_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    request: Request,
    kind: MediaDerivativeKind = Query(...),
    share_token: str | None = Query(default=None),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SignedUrlResponse:
    return _signed_url_response(
        db,
        request=request,
        gig_id=gig_id,
        media_asset_id=media_asset_id,
        kind=kind,
        user=user,
        share_token=share_token,
    )


@router.post("/gigs/{gig_id}/share-links", response_model=ShareLinkCreateResponse)
def create_share_link(
    gig_id: uuid.UUID,
    body: ShareLinkCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ShareLinkCreateResponse:
    if not is_feature_enabled(db, "public_share_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Public share links are temporarily disabled", status_code=503)

    gig = _get_gig_or_404(db, gig_id)
    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    if not is_admin and user.user_id not in {gig.client_user_id, gig.pro_user_id}:
        raise APIError(code="forbidden", message="Not allowed to create share link", status_code=403)
    if not is_admin and user.user_id != gig.pro_user_id and not can_manage_share_links(db, gig_id=gig.id, user_id=user.user_id):
        raise APIError(code="forbidden", message="Share-link entitlement required", status_code=403)
    if active_entitlement_hold(
        db,
        gig_id=gig.id,
        user_id=user.user_id,
        hold_type=EntitlementHoldType.share_disabled,
    ):
        raise APIError(code="forbidden", message="Share links are disabled while this dispute is under review", status_code=403)

    raw_token = __import__("secrets").token_urlsafe(32)
    token_hash = hash_share_token(raw_token)

    media_ids: list[str] = []
    if body.scope == ShareLinkScope.selected_only:
        selected = body.media_asset_ids
        if not selected:
            gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
            selected = unlocked_final_asset_ids(db, gallery=gallery) if gallery else []
        allowed_ids = set(gallery_media_asset_ids(db, gig_id=gig.id))
        if any(item not in allowed_ids for item in selected):
            raise APIError(code="validation_error", message="selected_only includes assets outside gig", status_code=422)
        media_ids = [str(item) for item in selected]

    link = ShareLink(
        gig_id=gig.id,
        created_by_user_id=user.user_id,
        scope=body.scope,
        token_hash=token_hash,
        expires_at=body.expires_at,
        max_views=body.max_views,
        view_count=0,
        is_revoked=False,
        meta={"media_asset_ids": media_ids},
    )
    db.add(link)
    db.commit()
    db.refresh(link)

    return ShareLinkCreateResponse(
        id=link.id,
        token=raw_token,
        share_url=f"{settings.app_public_url}/v1/share/{raw_token}",
        expires_at=link.expires_at,
        max_views=link.max_views,
    )


@router.get("/share/{token}", response_model=ShareLinkViewResponse)
def view_share_link(
    token: str,
    request: Request,
    db: Session = Depends(get_db_session),
) -> ShareLinkViewResponse:
    if not is_feature_enabled(db, "public_share_enabled"):
        raise APIError(code="feature_disabled", message="Public share links are temporarily disabled", status_code=503)

    ip = _request_ip(request)
    enforce_named_rate_limit("public_read", principal=ip or "unknown")

    link = get_share_link_for_token(db, token=token)
    if not link or not is_share_link_active(link):
        raise APIError(code="not_found", message="Share link not found or expired", status_code=404)
    if active_entitlement_hold(
        db,
        gig_id=link.gig_id,
        user_id=link.created_by_user_id,
        hold_type=EntitlementHoldType.share_disabled,
    ):
        raise APIError(code="not_found", message="Share link unavailable", status_code=404)

    link.view_count += 1
    record_share_link_view(db, link=link, ip=ip, user_agent=request.headers.get("user-agent"))
    refresh_share_link_engagement(db, share_link_id=link.id)
    enqueue_outbox_event(
        db,
        topic="share.reward.evaluate",
        payload={"share_link_id": str(link.id)},
        idempotency_key=f"share-reward-eval:{link.id}:{datetime.now(timezone.utc).strftime('%Y%m%d%H%M')}",
        idempotency_scope="share_reward_eval",
    )

    items: list[SharedMediaItemView] = []
    asset_ids = share_link_asset_ids(db, link=link)
    for asset_id in asset_ids:
        storage_key = _storage_key_for_kind(db, asset_id, MediaDerivativeKind.preview_watermarked)
        if not storage_key:
            continue
        url = create_presigned_get(storage_key, expires_in=_signed_ttl_seconds())
        items.append(SharedMediaItemView(media_asset_id=asset_id, preview_url=url))
        log_media_access(
            db,
            gig_id=link.gig_id,
            media_asset_id=asset_id,
            derivative_kind=MediaDerivativeKind.preview_watermarked.value,
            action=MediaAccessAction.view,
            user_id=None,
            share_link_id=link.id,
            ip=ip,
            user_agent=request.headers.get("user-agent"),
        )

    db.commit()
    return ShareLinkViewResponse(
        gig_id=link.gig_id,
        scope=link.scope,
        expires_at=link.expires_at,
        max_views=link.max_views,
        view_count=link.view_count,
        items=items,
    )


@router.post("/share/{token}/ping", response_model=SharePingResponse)
def ping_share_link(
    token: str,
    body: SharePingRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> SharePingResponse:
    ip = _request_ip(request)
    enforce_named_rate_limit("public_read", principal=ip or "unknown")

    link = get_share_link_for_token(db, token=token)
    if not link or not is_share_link_active(link):
        raise APIError(code="not_found", message="Share link not found or expired", status_code=404)

    row = ping_share_link_view(
        db,
        link=link,
        ip=ip,
        user_agent=request.headers.get("user-agent"),
        seconds_increment=body.seconds_viewed,
    )
    refresh_share_link_engagement(db, share_link_id=link.id)
    enqueue_outbox_event(
        db,
        topic="share.reward.evaluate",
        payload={"share_link_id": str(link.id)},
        idempotency_key=f"share-reward-eval:{link.id}:{datetime.now(timezone.utc).strftime('%Y%m%d%H%M')}",
        idempotency_scope="share_reward_eval",
    )
    db.commit()
    return SharePingResponse(ok=True, accumulated_seconds=row.seconds_viewed)


@router.get("/gigs/{gig_id}/consent", response_model=GigConsentView)
def get_gig_consent(
    gig_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigConsentView:
    gig = _get_gig_or_404(db, gig_id)
    _ensure_gig_participant_or_admin(db, gig, user.user_id)

    consent = db.execute(select(GigUsageConsent).where(GigUsageConsent.gig_id == gig.id)).scalar_one_or_none()
    if consent is None:
        consent = ensure_gig_consent_snapshot(db, gig, actor_user_id=user.user_id)
        db.commit()
        db.refresh(consent)

    return _consent_view(consent)


@router.put("/gigs/{gig_id}/consent", response_model=GigConsentView)
def put_gig_consent(
    gig_id: uuid.UUID,
    body: UpdateGigConsentRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigConsentView:
    gig = _get_gig_or_404(db, gig_id)
    if user.user_id != gig.client_user_id:
        raise APIError(code="forbidden", message="Only client can update consent", status_code=403)

    old_consent = db.execute(select(GigUsageConsent).where(GigUsageConsent.gig_id == gig.id)).scalar_one_or_none()
    previous_level = old_consent.consent_level.value if old_consent else None
    consent = set_gig_consent(
        db,
        gig=gig,
        actor_user_id=user.user_id,
        consent_level=body.consent_level,
        scope=body.scope,
        reason=body.reason,
    )

    enqueue_notification(
        db,
        user_id=gig.pro_user_id,
        notification_type="consent.updated",
        payload={
            "title": "Client usage consent updated",
            "body": "A client changed media usage consent for a gig.",
            "action": {"label": "Open gig", "url": f"/gigs/{gig.id}"},
            "consent_level": body.consent_level.value,
        },
        reference_type="gig",
        reference_id=str(gig.id),
    )

    enqueue_outbox_event(
        db,
        topic="consent.reward.evaluate",
        payload={
            "gig_id": str(gig.id),
            "client_user_id": str(gig.client_user_id),
            "to_level": body.consent_level.value,
        },
        idempotency_key=f"consent-reward:{gig.id}:{gig.client_user_id}:{body.consent_level.value}",
        idempotency_scope="consent_reward",
    )
    if previous_level and previous_level != body.consent_level.value:
        enqueue_outbox_event(
            db,
            topic="consent.clawback.evaluate",
            payload={
                "gig_id": str(gig.id),
                "client_user_id": str(gig.client_user_id),
                "from_level": previous_level,
                "to_level": body.consent_level.value,
            },
            idempotency_key=f"consent-clawback:{gig.id}:{gig.client_user_id}:{previous_level}:{body.consent_level.value}",
            idempotency_scope="consent_clawback",
        )
    maybe_emit_consent_toggle_abuse(db, gig_id=gig.id, actor_user_id=user.user_id)

    db.commit()
    db.refresh(consent)
    return _consent_view(consent)


@router.get("/admin/consent/events", response_model=AdminConsentEventsResponse)
def admin_list_consent_events(
    gig_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminConsentEventsResponse:
    stmt = select(GigUsageConsentEvent).order_by(GigUsageConsentEvent.created_at.desc())
    if gig_id:
        stmt = stmt.where(GigUsageConsentEvent.gig_id == gig_id)
    rows = db.execute(stmt.limit(500)).scalars().all()
    return AdminConsentEventsResponse(
        items=[
            GigConsentEventView(
                id=row.id,
                gig_id=row.gig_id,
                from_level=row.from_level,
                to_level=row.to_level,
                actor_user_id=row.actor_user_id,
                reason=row.reason,
                created_at=row.created_at,
            )
            for row in rows
        ]
    )


@router.post("/admin/share-links/{share_link_id}/revoke", response_model=ShareLinkRevokeResponse)
def admin_revoke_share_link(
    share_link_id: uuid.UUID,
    admin: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ShareLinkRevokeResponse:
    link = db.get(ShareLink, share_link_id)
    if not link:
        raise APIError(code="not_found", message="Share link not found", status_code=404)

    link.is_revoked = True
    add_admin_audit_log(
        db,
        actor_user_id=admin.user_id,
        target_type="share_link",
        target_id=str(link.id),
        action="share_link_revoked",
        reason=None,
        metadata={"gig_id": str(link.gig_id)},
    )
    db.commit()
    return ShareLinkRevokeResponse(ok=True, id=link.id, is_revoked=link.is_revoked)


def _signed_url_response(
    db: Session,
    *,
    request: Request,
    gig_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    kind: MediaDerivativeKind,
    user: CurrentUser,
    share_token: str | None,
) -> SignedUrlResponse:
    gig = _get_gig_or_404(db, gig_id)
    _ensure_gig_participant_or_admin(db, gig, user.user_id)

    if kind in {MediaDerivativeKind.full_res, MediaDerivativeKind.web_res} and not is_feature_enabled(db, "downloads_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Downloads are temporarily disabled", status_code=503)

    if media_asset_id not in set(gallery_media_asset_ids(db, gig_id=gig.id)):
        raise APIError(code="forbidden", message="Asset not part of gig media", status_code=403)

    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    if not is_admin and user.user_id != gig.pro_user_id:
        if kind in {MediaDerivativeKind.full_res, MediaDerivativeKind.web_res} and active_entitlement_hold(
            db,
            gig_id=gig.id,
            user_id=user.user_id,
            hold_type=EntitlementHoldType.downloads_frozen,
        ):
            raise APIError(code="forbidden", message="Downloads are frozen while dispute is under review", status_code=403)
        _enforce_client_access(db, gig, user.user_id, media_asset_id, kind, share_token)

    asset = db.get(MediaAsset, media_asset_id)
    if not asset:
        raise APIError(code="not_found", message="Media asset not found", status_code=404)

    ttl = _signed_ttl_seconds()
    if asset.kind == MediaKind.video and asset.provider == MediaProvider.mux:
        playback_id = (asset.meta or {}).get("playback_id")
        if not playback_id:
            raise APIError(code="invalid_state", message="Video playback unavailable", status_code=409)
        token = create_mux_playback_token(playback_id, expires_in_seconds=ttl)
        url = f"https://stream.mux.com/{playback_id}.m3u8?token={token}"
    else:
        storage_key = _storage_key_for_kind(db, asset.id, kind)
        if not storage_key:
            raise APIError(code="not_found", message="Requested derivative not available", status_code=404)
        url = create_presigned_get(storage_key, expires_in=ttl)

    action = MediaAccessAction.download if kind in {MediaDerivativeKind.full_res, MediaDerivativeKind.web_res} else MediaAccessAction.view
    link_id = None
    if share_token:
        link = get_share_link_for_token(db, token=share_token)
        link_id = link.id if link else None
    log_media_access(
        db,
        gig_id=gig.id,
        media_asset_id=asset.id,
        derivative_kind=kind.value,
        action=action,
        user_id=user.user_id,
        share_link_id=link_id,
        ip=_request_ip(request),
        user_agent=request.headers.get("user-agent"),
    )
    db.commit()
    return SignedUrlResponse(url=url, expires_in_seconds=ttl)


def _enforce_client_access(
    db: Session,
    gig: Gig,
    user_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    kind: MediaDerivativeKind,
    share_token: str | None,
) -> None:
    if user_id != gig.client_user_id:
        raise APIError(code="forbidden", message="Insufficient access", status_code=403)

    if share_token:
        link = get_share_link_for_token(db, token=share_token)
        if not link or not is_share_link_active(link):
            raise APIError(code="forbidden", message="Invalid share token", status_code=403)
        if link.gig_id != gig.id or media_asset_id not in set(share_link_asset_ids(db, link=link)):
            raise APIError(code="forbidden", message="Share token not valid for this media", status_code=403)
        return

    if kind in {MediaDerivativeKind.preview_watermarked, MediaDerivativeKind.thumbnail}:
        if not has_valid_entitlement(db, gig_id=gig.id, user_id=user_id, entitlement_type=GigEntitlementType.view_proofs):
            raise APIError(code="forbidden", message="Proof viewing entitlement required", status_code=403)
        return

    if kind in {MediaDerivativeKind.full_res, MediaDerivativeKind.web_res}:
        has_finals = has_valid_entitlement(db, gig_id=gig.id, user_id=user_id, entitlement_type=GigEntitlementType.download_finals)
        has_extras = has_valid_entitlement(db, gig_id=gig.id, user_id=user_id, entitlement_type=GigEntitlementType.download_extras)
        if not (has_finals or has_extras):
            raise APIError(code="forbidden", message="Download entitlement required", status_code=403)

        gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
        if gallery:
            unlocked = set(unlocked_final_asset_ids(db, gallery=gallery))
            if media_asset_id not in unlocked:
                raise APIError(code="forbidden", message="Asset is not unlocked for final delivery", status_code=403)


def _available_derivative_kinds(db: Session, media_asset_id: uuid.UUID) -> list[MediaDerivativeKind]:
    kinds = db.execute(select(MediaDerivative.kind).where(MediaDerivative.media_asset_id == media_asset_id)).scalars().all()
    present = set(kinds)

    objs = db.execute(select(MediaObject).where(MediaObject.media_asset_id == media_asset_id, MediaObject.status == ObjectStatus.ready)).scalars().all()
    for obj in objs:
        if obj.variant == MediaVariant.original:
            present.add(MediaDerivativeKind.full_res)
        elif obj.variant == MediaVariant.thumbnail:
            present.add(MediaDerivativeKind.thumbnail)
        elif obj.variant == MediaVariant.watermark_preview:
            present.add(MediaDerivativeKind.preview_watermarked)

    return sorted(list(present), key=lambda item: item.value)


def _storage_key_for_kind(db: Session, media_asset_id: uuid.UUID, kind: MediaDerivativeKind) -> str | None:
    derivative = db.execute(
        select(MediaDerivative).where(MediaDerivative.media_asset_id == media_asset_id, MediaDerivative.kind == kind)
    ).scalar_one_or_none()
    if derivative:
        return derivative.storage_key

    if kind == MediaDerivativeKind.full_res:
        obj_kind = MediaVariant.original
    elif kind == MediaDerivativeKind.thumbnail:
        obj_kind = MediaVariant.thumbnail
    elif kind == MediaDerivativeKind.preview_watermarked:
        obj_kind = MediaVariant.watermark_preview
    else:
        return None

    obj = db.execute(
        select(MediaObject).where(
            MediaObject.media_asset_id == media_asset_id,
            MediaObject.variant == obj_kind,
            MediaObject.status == ObjectStatus.ready,
        )
    ).scalar_one_or_none()
    return obj.storage_key if obj else None


def _signed_ttl_seconds() -> int:
    return max(60, min(300, int(settings.media_signed_url_ttl_seconds)))


def _get_gig_or_404(db: Session, gig_id: uuid.UUID) -> Gig:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    return gig


def _ensure_gig_participant_or_admin(db: Session, gig: Gig, user_id: uuid.UUID) -> None:
    roles = get_user_roles(db, user_id)
    if UserRoleType.admin in roles:
        return
    if user_id not in {gig.client_user_id, gig.pro_user_id}:
        raise APIError(code="forbidden", message="Insufficient access", status_code=403)


def _consent_view(consent: GigUsageConsent) -> GigConsentView:
    return GigConsentView(
        gig_id=consent.gig_id,
        client_user_id=consent.client_user_id,
        pro_user_id=consent.pro_user_id,
        consent_level=consent.consent_level,
        scope=consent.scope or {},
        incentive=consent.incentive or {},
        snapshot_at_booking=consent.snapshot_at_booking,
        created_at=consent.created_at,
        updated_at=consent.updated_at,
    )


def _request_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None
