"""Marketing-use consent (closed beta): the client's routes.

The rules are services/marketing_consent.py's; these only check who is
asking and shape the answers. The photographer's and the admin's routes are
in their own modules.
"""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.errors import APIError
from app.models.gig import Gig
from app.models.marketing_consent import TERM_CREDIT_PERCENT, MarketingConsent
from app.schemas.marketing_consent import (
    GrantMarketingConsentRequest,
    GrantMarketingConsentResponse,
    MarketingConsentOfferResponse,
    MarketingConsentView,
    MarketingPhotoView,
    MarketingTermView,
    MyMarketingConsentsResponse,
    RenewMarketingConsentRequest,
    WithdrawMarketingConsentRequest,
    WithdrawMarketingConsentResponse,
)
from app.schemas.media import CurrentUser
from app.services import marketing_consent as mc
from app.services.analytics import log_event
from app.services.media_urls import resolve_image_urls

router = APIRouter(tags=["marketing_consent"])

THUMB_TTL = 900


def _client_gig(db: Session, gig_id: uuid.UUID, user: CurrentUser) -> Gig:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    if gig.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only the booking's client can be asked", status_code=403)
    return gig


def _views(db: Session, rows: list[MarketingConsent]) -> list[MarketingConsentView]:
    thumbs = resolve_image_urls(db, [r.media_asset_id for r in rows], expires_in=THUMB_TTL)
    return [
        MarketingConsentView(
            id=r.id, gig_id=r.gig_id, media_asset_id=r.media_asset_id, thumbnail_url=thumbs.get(r.media_asset_id),
            photographer_credit=r.photographer_credit, scope=r.scope, term_months=r.term_months, granted_at=r.granted_at,
            ends_at=r.ends_at, status=r.status, withdrawn_at=r.withdrawn_at, renews_consent_id=r.renews_consent_id,
        )
        for r in rows
    ]


@router.get("/gigs/{gig_id}/marketing-consent/offer", response_model=MarketingConsentOfferResponse)
def get_marketing_consent_offer(
    gig_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)
) -> MarketingConsentOfferResponse:
    """Whether to show "Let RAWWERS feature your photos? Earn credit." for
    this booking, and with what: the wording, the terms and their credit,
    and the photos the client may choose from."""
    gig = _client_gig(db, gig_id, user)
    offer = mc.offer_for(db, gig)
    db.commit()
    if not offer.offered:
        return MarketingConsentOfferResponse(offered=False, reason=offer.reason)
    thumbs = resolve_image_urls(db, list(offer.photo_ids), expires_in=THUMB_TTL)
    from app.services.client_credit import points_per_eur, to_eur

    per_eur = points_per_eur(db)
    block = mc.credit_block(db, gig, user.user_id, 12)
    return MarketingConsentOfferResponse(
        credit_available=block is None,
        credit_unavailable_reason=block,
        offered=True,
        wording_version=offer.wording.version,
        wording_text=offer.wording.text,
        terms=[
            MarketingTermView(months=m, credit=mc.credit_for_term(m), credit_eur=to_eur(mc.credit_for_term(m), per_eur))
            for m in sorted(TERM_CREDIT_PERCENT)
        ],
        photographer_credit=offer.photographer_credit,
        photos=[MarketingPhotoView(media_asset_id=pid, thumbnail_url=thumbs.get(pid)) for pid in offer.photo_ids],
    )


@router.post("/gigs/{gig_id}/marketing-consent", response_model=GrantMarketingConsentResponse)
def grant_marketing_consent(
    gig_id: uuid.UUID,
    body: GrantMarketingConsentRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GrantMarketingConsentResponse:
    gig = _client_gig(db, gig_id, user)
    try:
        rows, credit = mc.grant(
            db, gig, client_user_id=user.user_id, asset_ids=body.media_asset_ids, term_months=body.term_months,
            people_confirmed=body.people_confirmed,
        )
    except mc.MarketingConsentRefused as refused:
        raise APIError(code="validation_error" if refused.status_code == 422 else "invalid_state", message=refused.message, status_code=refused.status_code)
    log_event(db, event_name="client.marketing_consent_granted", user_id=user.user_id,
              properties={"gig_id": str(gig.id), "photos": len(rows), "term_months": body.term_months, "credit": credit})
    db.commit()
    from app.services.client_credit import points_per_eur, to_eur

    return GrantMarketingConsentResponse(items=_views(db, rows), credit=credit, credit_eur=to_eur(credit, points_per_eur(db)))


@router.get("/me/marketing-consents", response_model=MyMarketingConsentsResponse)
def list_my_marketing_consents(
    user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)
) -> MyMarketingConsentsResponse:
    """Settings > Marketing permissions: every photo given, with its end date."""
    return MyMarketingConsentsResponse(items=_views(db, mc.my_consents(db, user.user_id)))


@router.post("/me/marketing-consents/withdraw", response_model=WithdrawMarketingConsentResponse)
def withdraw_my_marketing_consents(
    body: WithdrawMarketingConsentRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> WithdrawMarketingConsentResponse:
    if not body.all and not body.consent_ids:
        raise APIError(code="validation_error", message="Say which photos, or all", status_code=422)
    count = mc.withdraw(db, user.user_id, None if body.all else body.consent_ids)
    log_event(db, event_name="client.marketing_consent_withdrawn", user_id=user.user_id, properties={"count": count, "all": body.all})
    db.commit()
    return WithdrawMarketingConsentResponse(withdrawn=count)


@router.post("/me/marketing-consents/renew", response_model=MyMarketingConsentsResponse)
def renew_my_marketing_consents(
    body: RenewMarketingConsentRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MyMarketingConsentsResponse:
    try:
        rows = mc.renew(db, user.user_id, body.consent_ids, body.term_months)
    except mc.MarketingConsentRefused as refused:
        raise APIError(code="validation_error" if refused.status_code == 422 else "invalid_state", message=refused.message, status_code=refused.status_code)
    db.commit()
    return MyMarketingConsentsResponse(items=_views(db, rows))
