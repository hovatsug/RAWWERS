from __future__ import annotations

import hashlib
import secrets
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select, update
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, ProofGalleryItem, SelectionStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.admin import MoneyAttentionItem
from app.models.gig import Gig
from app.services.package_pricing import is_curve_priced
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


def latest_submitted_selection(db: Session, *, gallery_id: uuid.UUID) -> ClientSelection | None:
    return db.execute(
        select(ClientSelection)
        .where(ClientSelection.gallery_id == gallery_id, ClientSelection.status.in_([SelectionStatus.submitted, SelectionStatus.locked]))
        .order_by(ClientSelection.version.desc())
    ).scalars().first()


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
    """The photographs this client may download at full resolution, right now.

    The single boundary for releasing finals: the downloads endpoint, the
    signed-URL path and share-link scoping all answer through it, so a rule
    added here cannot be missed by one of them.

    A curve-priced booking charges for every selected photograph, so it
    releases all of them or none, and "all" means the booking is fully paid.
    Submitting a selection is not paying for it: this used to return the whole
    selection the moment it was submitted, before the difference charge had
    been confirmed.
    """
    selection = latest_submitted_selection(db, gallery_id=gallery.id)
    if not selection:
        return []
    selected_ids = db.execute(
        select(ClientSelectionItem.media_asset_id).where(ClientSelectionItem.selection_id == selection.id)
    ).scalars().all()
    if not selected_ids:
        return []

    # Imported here: gallery_completion grants entitlements through this
    # module, so the reverse import at module level would be a cycle.
    from app.services.gallery_completion import is_selection_fully_paid
    from app.services.payment_intents import base_payment_succeeded

    gig = db.get(Gig, gallery.gig_id)
    if gig is None:
        return []

    if is_curve_priced(gig):
        return selected_ids if is_selection_fully_paid(db, gig=gig, gallery=gallery, selection=selection) else []

    # Flat-priced bookings: the photographs the deposit covers unlock at
    # submit; extras unlock when their own purchase succeeds. Either way the
    # deposit has to have been collected.
    if not base_payment_succeeded(db, gig):
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
            ip_address=ip if _is_gig_client(db, gig_id=gig_id, user_id=user_id) else None,
            user_agent=user_agent,
        )
    )


def _is_gig_client(db: Session, *, gig_id: uuid.UUID, user_id: uuid.UUID | None) -> bool:
    if user_id is None:
        return False
    gig = db.get(Gig, gig_id)
    return gig is not None and gig.client_user_id == user_id


def purge_raw_access_ips(db: Session, *, now: datetime | None = None) -> int:
    """Clear raw IPs older than the retention period; the hash stays. A
    booking with a chargeback whose evidence is still due keeps them until
    that is dealt with. Returns how many rows were cleared."""
    cutoff = (now or datetime.now(timezone.utc)) - timedelta(days=settings.media_access_raw_ip_retention_days)
    evidence_due = select(MoneyAttentionItem.gig_id).where(
        MoneyAttentionItem.kind == "chargeback_evidence_due", MoneyAttentionItem.status == "open", MoneyAttentionItem.gig_id.is_not(None)
    )
    result = db.execute(
        update(MediaAccessLog)
        .where(MediaAccessLog.ip_address.is_not(None), MediaAccessLog.created_at < cutoff, MediaAccessLog.gig_id.not_in(evidence_due))
        .values(ip_address=None)
        .execution_options(synchronize_session=False)
    )
    return int(result.rowcount or 0)


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
