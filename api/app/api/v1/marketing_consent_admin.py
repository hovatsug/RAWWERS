"""Marketing-use consent (closed beta): the admin content library.

Reads only the per-photo consent records - the only authority for RAWWERS's
own marketing use (the older four-level gig consent grants RAWWERS nothing).
Originals open through a short signed link for an active consent only, and
every opening is logged.
"""
from __future__ import annotations

import uuid
from datetime import timedelta

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.core.errors import APIError
from app.models.admin import UserAccount
from app.models.marketing_consent import (
    MarketingConsent,
    MarketingConsentStatus,
    MarketingContentUse,
    MarketingContentUseConsent,
    MarketingOriginalAccess,
)
from app.models.media import MediaObject, MediaVariant, ObjectStatus
from app.schemas.marketing_consent import (
    AdminMarketingConsentsResponse,
    AdminMarketingConsentView,
    MarketingOriginalLinkResponse,
    MarketingTakeDownResponse,
    MarketingTakeDownView,
    MarketingUseConsentView,
    MarketingUsesResponse,
    MarketingUseView,
    RecordMarketingUseRequest,
)
from app.schemas.media import CurrentUser
from app.services import marketing_consent as mc
from app.services.audit import add_admin_audit_log
from app.services.media_urls import resolve_image_urls
from app.services.storage import create_presigned_get

router = APIRouter(prefix="/admin/marketing", tags=["admin"])

ORIGINAL_LINK_SECONDS = 300


def _first_name(display_name: str | None) -> str:
    parts = (display_name or "").split()
    return parts[0][:40] if parts and "@" not in parts[0] else "Client"


@router.get("/consents", response_model=AdminMarketingConsentsResponse)
def list_marketing_consents(
    status: str | None = Query(default=None, pattern="^(active|withdrawn|expired)$"),
    pro_user_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminMarketingConsentsResponse:
    stmt = select(MarketingConsent).order_by(MarketingConsent.ends_at.asc()).limit(1000)
    if status:
        stmt = stmt.where(MarketingConsent.status == status)
    if pro_user_id:
        stmt = stmt.where(MarketingConsent.pro_user_id == pro_user_id)
    rows = db.execute(stmt).scalars().all()
    thumbs = resolve_image_urls(db, [r.media_asset_id for r in rows], expires_in=900)
    names = dict(
        db.execute(select(UserAccount.user_id, UserAccount.display_name).where(UserAccount.user_id.in_({r.client_user_id for r in rows}))).all()
    )
    uses = dict(
        db.execute(
            select(MarketingContentUseConsent.consent_id, func.count())
            .where(MarketingContentUseConsent.consent_id.in_([r.id for r in rows]))
            .group_by(MarketingContentUseConsent.consent_id)
        ).all()
    )
    return AdminMarketingConsentsResponse(
        items=[
            AdminMarketingConsentView(
                id=r.id, media_asset_id=r.media_asset_id, thumbnail_url=thumbs.get(r.media_asset_id), gig_id=r.gig_id,
                client_first_name=_first_name(names.get(r.client_user_id)), pro_user_id=r.pro_user_id,
                photographer_credit=r.photographer_credit, scope=r.scope, term_months=r.term_months, granted_at=r.granted_at,
                ends_at=r.ends_at, status=r.status, withdrawn_at=r.withdrawn_at, expired_at=r.expired_at, uses=int(uses.get(r.id, 0)),
            )
            for r in rows
        ]
    )


@router.post("/consents/{consent_id}/original", response_model=MarketingOriginalLinkResponse)
def open_marketing_original(
    consent_id: uuid.UUID, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> MarketingOriginalLinkResponse:
    """A signed link to the original, for an ACTIVE consent only; every
    opening is recorded with the admin and the time."""
    consent = db.get(MarketingConsent, consent_id)
    if consent is None:
        raise APIError(code="not_found", message="Consent not found", status_code=404)
    if consent.status != MarketingConsentStatus.active.value:
        raise APIError(code="invalid_state", message="This permission has ended: the original can no longer be opened", status_code=409)
    original = db.execute(
        select(MediaObject).where(
            MediaObject.media_asset_id == consent.media_asset_id,
            MediaObject.variant == MediaVariant.original,
            MediaObject.status == ObjectStatus.ready,
        )
    ).scalar_one_or_none()
    if original is None:
        raise APIError(code="not_found", message="The original is not available", status_code=404)
    db.add(MarketingOriginalAccess(consent_id=consent.id, admin_user_id=actor.user_id))
    add_admin_audit_log(
        db, actor_user_id=actor.user_id, target_type="marketing_consent", target_id=str(consent.id),
        action="marketing_original_opened", reason=None, metadata={"media_asset_id": str(consent.media_asset_id)},
    )
    url = create_presigned_get(original.storage_key, expires_in=ORIGINAL_LINK_SECONDS)
    db.commit()
    return MarketingOriginalLinkResponse(url=url, expires_in_seconds=ORIGINAL_LINK_SECONDS)


def _use_view(db: Session, use: MarketingContentUse) -> MarketingUseView:
    consents = db.execute(
        select(MarketingConsent)
        .join(MarketingContentUseConsent, MarketingContentUseConsent.consent_id == MarketingConsent.id)
        .where(MarketingContentUseConsent.use_id == use.id)
    ).scalars().all()
    ends = [mc.effective_end(db, c) for c in consents]
    return MarketingUseView(
        id=use.id, content_name=use.content_name, used_on=use.used_on, owned_channel=use.owned_channel,
        retire_by=min(ends).date(),
        consents=[MarketingUseConsentView(id=c.id, status=c.status, ends_at=end) for c, end in zip(consents, ends)],
    )


@router.post("/uses", response_model=MarketingUseView)
def record_marketing_use(
    body: RecordMarketingUseRequest, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> MarketingUseView:
    """"Used in <content> on <date>", against the consents it shows."""
    ids = list(dict.fromkeys(body.consent_ids))
    consents = db.execute(select(MarketingConsent).where(MarketingConsent.id.in_(ids))).scalars().all()
    if len(consents) != len(ids):
        raise APIError(code="not_found", message="A consent was not found", status_code=404)
    if any(c.status != MarketingConsentStatus.active.value for c in consents):
        raise APIError(code="invalid_state", message="Only photos with an active permission can be used", status_code=409)
    use = MarketingContentUse(content_name=body.content_name.strip(), used_on=body.used_on, owned_channel=body.owned_channel, recorded_by_user_id=actor.user_id)
    db.add(use)
    db.flush()
    db.add_all([MarketingContentUseConsent(use_id=use.id, consent_id=c.id) for c in consents])
    add_admin_audit_log(
        db, actor_user_id=actor.user_id, target_type="marketing_content_use", target_id=str(use.id),
        action="marketing_use_recorded", reason=use.content_name, metadata={"consents": [str(c.id) for c in consents]},
    )
    db.commit()
    return _use_view(db, use)


@router.get("/uses", response_model=MarketingUsesResponse)
def list_marketing_uses(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> MarketingUsesResponse:
    uses = db.execute(select(MarketingContentUse).order_by(MarketingContentUse.used_on.desc())).scalars().all()
    return MarketingUsesResponse(items=[_use_view(db, u) for u in uses])


@router.get("/expiring", response_model=MarketingUsesResponse)
def list_expiring_marketing_uses(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> MarketingUsesResponse:
    """Content by the date it has to be retired, soonest first."""
    views = [_use_view(db, u) for u in db.execute(select(MarketingContentUse)).scalars().all()]
    return MarketingUsesResponse(items=sorted(views, key=lambda v: (v.retire_by, v.content_name)))


@router.get("/take-down", response_model=MarketingTakeDownResponse)
def list_marketing_take_downs(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> MarketingTakeDownResponse:
    """Withdrawn or expired consents that were used, and the date by which the
    content must come down: 30 days after the end, for channels RAWWERS owns.
    One renewed in time is not listed."""
    rows = db.execute(
        select(MarketingContentUse, MarketingConsent)
        .join(MarketingContentUseConsent, MarketingContentUseConsent.use_id == MarketingContentUse.id)
        .join(MarketingConsent, MarketingConsent.id == MarketingContentUseConsent.consent_id)
        .where(MarketingConsent.status.in_([MarketingConsentStatus.withdrawn.value, MarketingConsentStatus.expired.value]))
    ).all()
    items = []
    for use, consent in rows:
        if consent.status == MarketingConsentStatus.expired.value and mc.renewal_of(db, consent) is not None:
            continue
        ended_at = consent.withdrawn_at or consent.expired_at or consent.ends_at
        items.append(
            MarketingTakeDownView(
                use_id=use.id, content_name=use.content_name, used_on=use.used_on, consent_id=consent.id, reason=consent.status,
                ended_at=ended_at, take_down_by=(ended_at + timedelta(days=mc.TAKE_DOWN_DAYS_OWNED)).date(),
            )
        )
    return MarketingTakeDownResponse(items=sorted(items, key=lambda i: (i.take_down_by, i.content_name)))
