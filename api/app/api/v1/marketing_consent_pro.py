"""Marketing-use consent (closed beta): the photographer's routes - the
account-level clause, and each booking's "Allow marketing use" and
"Includes children". The rules are services/marketing_consent.py's."""
from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.gig import Gig
from app.models.marketing_consent import MarketingWordingAudience, ProMarketingAgreement
from app.schemas.marketing_consent import (
    BookingMarketingSettingsView,
    ProMarketingAgreementView,
    UpdateBookingMarketingSettingsRequest,
    UpdateProMarketingAgreementRequest,
)
from app.schemas.media import CurrentUser
from app.services import marketing_consent as mc
from app.services.authz import get_user_roles

router = APIRouter(tags=["marketing_consent"])


def _require_pro(db: Session, user: CurrentUser) -> None:
    if UserRoleType.pro not in get_user_roles(db, user.user_id):
        raise APIError(code="forbidden", message="Photographers only", status_code=403)


def _agreement_view(db: Session, pro_user_id) -> ProMarketingAgreementView:
    wording = mc.active_wording(db, MarketingWordingAudience.photographer)
    latest = db.execute(
        select(ProMarketingAgreement)
        .where(ProMarketingAgreement.pro_user_id == pro_user_id)
        .order_by(ProMarketingAgreement.recorded_at.desc(), ProMarketingAgreement.id.desc())
    ).scalars().first()
    return ProMarketingAgreementView(
        opted_in=bool(latest and latest.opted_in),
        wording_version=wording.version,
        wording_text=wording.text,
        recorded_at=latest.recorded_at if latest else None,
    )


@router.get("/pro/me/marketing-agreement", response_model=ProMarketingAgreementView)
def get_my_marketing_agreement(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> ProMarketingAgreementView:
    _require_pro(db, user)
    view = _agreement_view(db, user.user_id)
    db.commit()
    return view


@router.put("/pro/me/marketing-agreement", response_model=ProMarketingAgreementView)
def set_my_marketing_agreement(
    body: UpdateProMarketingAgreementRequest, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)
) -> ProMarketingAgreementView:
    """Turning it off stops new offers on every booking; consents clients have
    already granted stay as they are."""
    _require_pro(db, user)
    mc.record_pro_agreement(db, user.user_id, opted_in=body.opted_in)
    db.commit()
    return _agreement_view(db, user.user_id)


def _own_gig(db: Session, gig_id: uuid.UUID, user: CurrentUser) -> Gig:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    if gig.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only the booking's photographer", status_code=403)
    return gig


def _settings_view(db: Session, gig: Gig) -> BookingMarketingSettingsView:
    switches = mc.booking_switches(db, gig)
    return BookingMarketingSettingsView(
        allow_marketing=switches.allow_marketing,
        includes_children=switches.includes_children,
        locked=switches.locked,
        opted_in=mc.pro_opted_in(db, gig.pro_user_id),
    )


@router.get("/pro/gigs/{gig_id}/marketing-settings", response_model=BookingMarketingSettingsView)
def get_booking_marketing_settings(
    gig_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)
) -> BookingMarketingSettingsView:
    return _settings_view(db, _own_gig(db, gig_id, user))


@router.put("/pro/gigs/{gig_id}/marketing-settings", response_model=BookingMarketingSettingsView)
def set_booking_marketing_settings(
    gig_id: uuid.UUID,
    body: UpdateBookingMarketingSettingsRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingMarketingSettingsView:
    gig = _own_gig(db, gig_id, user)
    try:
        mc.set_booking_setting(db, gig, actor_user_id=user.user_id, allow_marketing=body.allow_marketing, includes_children=body.includes_children)
    except mc.MarketingConsentLocked:
        raise APIError(
            code="invalid_state",
            message="The client has already given permission for this booking, so these can no longer change.",
            status_code=409,
        )
    db.commit()
    return _settings_view(db, gig)
