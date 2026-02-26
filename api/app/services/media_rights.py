from __future__ import annotations

import hashlib
import secrets
import uuid
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, ProofGalleryItem, SelectionStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.gig import Gig
from app.models.media_rights import (
    GigConsentLevel,
    GigEntitlementType,
    GigMediaEntitlement,
    GigUsageConsent,
    GigUsageConsentEvent,
    MediaAccessAction,
    MediaAccessLog,
    ShareLink,
    ShareLinkScope,
)

settings = get_settings()


def default_gig_consent_level() -> GigConsentLevel:
    raw = (settings.default_gig_consent_level or "none").strip().lower()
    try:
        return GigConsentLevel(raw)
    except ValueError:
        return GigConsentLevel.none


def ensure_gig_consent_snapshot(db: Session, gig: Gig, *, actor_user_id: uuid.UUID) -> GigUsageConsent:
    existing = db.execute(select(GigUsageConsent).where(GigUsageConsent.gig_id == gig.id)).scalar_one_or_none()
    if existing:
        return existing

    level = default_gig_consent_level()
    consent = GigUsageConsent(
        gig_id=gig.id,
        client_user_id=gig.client_user_id,
        pro_user_id=gig.pro_user_id,
        consent_level=level,
        scope={},
        incentive={},
        snapshot_at_booking=True,
    )
    db.add(consent)
    db.flush()

    db.add(
        GigUsageConsentEvent(
            gig_id=gig.id,
            from_level=None,
            to_level=level.value,
            actor_user_id=actor_user_id,
            reason="booking_default",
        )
    )
    if level == GigConsentLevel.none:
        from app.services.notifications import enqueue_notification

        enqueue_notification(
            db,
            user_id=gig.client_user_id,
            notification_type="consent.reminder",
            payload={
                "title": "Set your media consent preferences",
                "body": "Choose how your gig photos can be used for marketing.",
                "action": {"label": "Review consent", "url": f"/gigs/{gig.id}/consent"},
            },
            reference_type="gig",
            reference_id=str(gig.id),
        )
    return consent


def set_gig_consent(
    db: Session,
    *,
    gig: Gig,
    actor_user_id: uuid.UUID,
    consent_level: GigConsentLevel,
    scope: dict,
    reason: str | None = None,
) -> GigUsageConsent:
    consent = db.execute(select(GigUsageConsent).where(GigUsageConsent.gig_id == gig.id)).scalar_one_or_none()
    if consent is None:
        consent = ensure_gig_consent_snapshot(db, gig, actor_user_id=actor_user_id)

    before = consent.consent_level.value
    consent.consent_level = consent_level
    consent.scope = scope or {}
    db.add(
        GigUsageConsentEvent(
            gig_id=gig.id,
            from_level=before,
            to_level=consent_level.value,
            actor_user_id=actor_user_id,
            reason=reason,
        )
    )
    db.flush()
    return consent


def can_use_for_marketing(db: Session, *, gig_id: uuid.UUID, actor: str, channel: str) -> bool:
    consent = db.execute(select(GigUsageConsent).where(GigUsageConsent.gig_id == gig_id)).scalar_one_or_none()
    if consent is None:
        return False

    allowed = False
    if actor == "pro":
        allowed = consent.consent_level in {GigConsentLevel.pro_marketing_only, GigConsentLevel.both_pro_and_rawwers}
    elif actor == "rawwers":
        allowed = consent.consent_level in {GigConsentLevel.rawwers_marketing_only, GigConsentLevel.both_pro_and_rawwers}
    if not allowed:
        return False

    channels = (consent.scope or {}).get("channels")
    if not channels:
        return True
    return channel in set(channels)


def upsert_gig_entitlement(
    db: Session,
    *,
    gig_id: uuid.UUID,
    user_id: uuid.UUID,
    entitlement_type: GigEntitlementType,
    quantity_limit: int | None = None,
    valid_until: datetime | None = None,
    metadata: dict | None = None,
) -> GigMediaEntitlement:
    row = db.execute(
        select(GigMediaEntitlement).where(
            GigMediaEntitlement.gig_id == gig_id,
            GigMediaEntitlement.user_id == user_id,
            GigMediaEntitlement.entitlement_type == entitlement_type,
        )
    ).scalar_one_or_none()
    if row is None:
        row = GigMediaEntitlement(
            gig_id=gig_id,
            user_id=user_id,
            entitlement_type=entitlement_type,
            quantity_limit=quantity_limit,
            valid_from=datetime.now(timezone.utc),
            valid_until=valid_until,
            meta=metadata or {},
        )
        db.add(row)
    else:
        row.quantity_limit = quantity_limit
        row.valid_until = valid_until
        if metadata is not None:
            row.meta = metadata
    db.flush()
    return row


def increment_entitlement_quantity(
    db: Session,
    *,
    gig_id: uuid.UUID,
    user_id: uuid.UUID,
    entitlement_type: GigEntitlementType,
    delta: int,
) -> GigMediaEntitlement:
    row = db.execute(
        select(GigMediaEntitlement).where(
            GigMediaEntitlement.gig_id == gig_id,
            GigMediaEntitlement.user_id == user_id,
            GigMediaEntitlement.entitlement_type == entitlement_type,
        )
    ).scalar_one_or_none()
    if row is None:
        row = GigMediaEntitlement(
            gig_id=gig_id,
            user_id=user_id,
            entitlement_type=entitlement_type,
            quantity_limit=max(0, delta),
            valid_from=datetime.now(timezone.utc),
            meta={},
        )
        db.add(row)
    else:
        row.quantity_limit = max(0, int(row.quantity_limit or 0) + delta)
    db.flush()
    return row


def has_valid_entitlement(db: Session, *, gig_id: uuid.UUID, user_id: uuid.UUID, entitlement_type: GigEntitlementType) -> bool:
    now = datetime.now(timezone.utc)
    row = db.execute(
        select(GigMediaEntitlement).where(
            GigMediaEntitlement.gig_id == gig_id,
            GigMediaEntitlement.user_id == user_id,
            GigMediaEntitlement.entitlement_type == entitlement_type,
            GigMediaEntitlement.valid_from <= now,
            (GigMediaEntitlement.valid_until.is_(None) | (GigMediaEntitlement.valid_until > now)),
        )
    ).scalar_one_or_none()
    return row is not None


def selected_asset_ids(db: Session, *, gallery_id: uuid.UUID, submitted_only: bool = True) -> list[uuid.UUID]:
    statuses = [SelectionStatus.submitted, SelectionStatus.locked] if submitted_only else [SelectionStatus.draft, SelectionStatus.submitted, SelectionStatus.locked]
    selection = db.execute(
        select(ClientSelection)
        .where(ClientSelection.gallery_id == gallery_id, ClientSelection.status.in_(statuses))
        .order_by(ClientSelection.version.desc())
    ).scalars().first()
    if not selection:
        return []
    return db.execute(select(ClientSelectionItem.media_asset_id).where(ClientSelectionItem.selection_id == selection.id)).scalars().all()


def unlocked_final_asset_ids(db: Session, *, gallery: ProofGallery) -> list[uuid.UUID]:
    selected_ids = selected_asset_ids(db, gallery_id=gallery.id, submitted_only=True)
    if not selected_ids:
        return []

    extras_needed = max(0, len(selected_ids) - gallery.included_photos)
    if extras_needed <= 0:
        return selected_ids

    purchase = db.execute(
        select(UpsellPurchase)
        .where(UpsellPurchase.gallery_id == gallery.id)
        .order_by(UpsellPurchase.created_at.desc())
    ).scalars().first()
    if not purchase or purchase.status != UpsellPurchaseStatus.succeeded:
        return selected_ids[: gallery.included_photos]

    return selected_ids


def gallery_media_asset_ids(db: Session, *, gig_id: uuid.UUID) -> list[uuid.UUID]:
    gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig_id)).scalar_one_or_none()
    if not gallery:
        return []
    return db.execute(
        select(ProofGalleryItem.media_asset_id)
        .where(ProofGalleryItem.gallery_id == gallery.id)
        .order_by(ProofGalleryItem.sort_order.asc(), ProofGalleryItem.created_at.asc())
    ).scalars().all()


def create_share_token() -> str:
    return secrets.token_urlsafe(32)


def hash_share_token(token: str) -> str:
    return hashlib.sha256(f"{token}{settings.media_share_token_pepper}".encode("utf-8")).hexdigest()


def hash_ip(ip: str | None) -> str | None:
    if not ip:
        return None
    return hashlib.sha256(f"{ip}{settings.media_access_ip_hash_pepper}".encode("utf-8")).hexdigest()


def get_share_link_for_token(db: Session, *, token: str) -> ShareLink | None:
    return db.execute(select(ShareLink).where(ShareLink.token_hash == hash_share_token(token))).scalar_one_or_none()


def share_link_asset_ids(db: Session, *, link: ShareLink) -> list[uuid.UUID]:
    gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == link.gig_id)).scalar_one_or_none()
    if not gallery:
        return []

    if link.scope == ShareLinkScope.proofs:
        return gallery_media_asset_ids(db, gig_id=link.gig_id)
    if link.scope == ShareLinkScope.finals:
        return unlocked_final_asset_ids(db, gallery=gallery)

    selected = (link.meta or {}).get("media_asset_ids") or []
    parsed: list[uuid.UUID] = []
    for raw in selected:
        try:
            parsed.append(uuid.UUID(str(raw)))
        except ValueError:
            continue
    return parsed


def is_share_link_active(link: ShareLink) -> bool:
    if link.is_revoked:
        return False
    now = datetime.now(timezone.utc)
    if link.expires_at and link.expires_at <= now:
        return False
    if link.max_views is not None and link.view_count >= link.max_views:
        return False
    return True


def log_media_access(
    db: Session,
    *,
    gig_id: uuid.UUID,
    media_asset_id: uuid.UUID,
    derivative_kind: str,
    action: MediaAccessAction,
    user_id: uuid.UUID | None,
    share_link_id: uuid.UUID | None,
    ip: str | None,
    user_agent: str | None,
) -> None:
    db.add(
        MediaAccessLog(
            user_id=user_id,
            share_link_id=share_link_id,
            gig_id=gig_id,
            media_asset_id=media_asset_id,
            derivative_kind=derivative_kind,
            action=action,
            ip_hash=hash_ip(ip),
            user_agent=user_agent,
        )
    )


def can_manage_share_links(db: Session, *, gig_id: uuid.UUID, user_id: uuid.UUID) -> bool:
    return has_valid_entitlement(
        db,
        gig_id=gig_id,
        user_id=user_id,
        entitlement_type=GigEntitlementType.share_link_manage,
    )


def count_media_access_logs(db: Session, *, gig_id: uuid.UUID, media_asset_id: uuid.UUID) -> int:
    return int(
        db.execute(
            select(func.count())
            .select_from(MediaAccessLog)
            .where(MediaAccessLog.gig_id == gig_id, MediaAccessLog.media_asset_id == media_asset_id)
        ).scalar_one()
    )
