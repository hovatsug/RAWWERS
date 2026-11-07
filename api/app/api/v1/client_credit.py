"""The client's credit: balance and history (in euros), and what it would
take off a booking's payment (services/client_credit.py)."""
from __future__ import annotations

import uuid
from datetime import datetime
from decimal import Decimal

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.schemas.media import CurrentUser
from app.services import client_credit

router = APIRouter(tags=["client_credit"])


class CreditHistoryItem(BaseModel):
    id: uuid.UUID
    created_at: datetime
    #: marketing_permission, used_on_booking, returned, refunded_credit, reversed, earned, adjustment.
    kind: str
    #: Signed: positive earned or given back, negative used or reversed.
    amount_eur: Decimal
    #: For a marketing permission: the booking's photographer.
    photographer_first_name: str | None = None


class MyCreditResponse(BaseModel):
    balance_eur: Decimal
    #: Credit takes at most this much of a booking's payment.
    max_discount_percent: int
    items: list[CreditHistoryItem]


class BookingCreditPreview(BaseModel):
    balance_eur: Decimal
    discount_eur: Decimal
    price_eur: Decimal
    total_eur: Decimal
    max_discount_percent: int
    #: Already set aside for this payment.
    applied: bool
    currency: str


@router.get("/me/credit", response_model=MyCreditResponse)
def my_credit(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> MyCreditResponse:
    per_eur = client_credit.points_per_eur(db)
    view = MyCreditResponse(
        balance_eur=client_credit.to_eur(client_credit.balance_points(db, user.user_id), per_eur),
        max_discount_percent=client_credit.max_discount_percent(db),
        items=[CreditHistoryItem(**row) for row in client_credit.history(db, user.user_id)],
    )
    db.commit()
    return view


@router.get("/client/bookings/{booking_id}/credit", response_model=BookingCreditPreview)
def booking_credit(
    booking_id: uuid.UUID, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)
) -> BookingCreditPreview:
    """What credit would take off this booking's payment, before paying."""
    from app.api.v1.client_launch import _find_gig_by_booking_request
    from app.models.booking import BookingRequest

    booking = db.get(BookingRequest, booking_id)
    if booking is None or booking.client_user_id != user.user_id:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    gig = _find_gig_by_booking_request(db, booking_id=booking.id)
    if gig is None:
        raise APIError(code="invalid_state", message="Nothing to pay yet", status_code=409)
    view = BookingCreditPreview(**client_credit.checkout_preview(db, client_user_id=user.user_id, gig=gig))
    db.commit()
    return view


# --- admin ---------------------------------------------------------------------------------


class CreditSettingsView(BaseModel):
    max_discount_percent: int
    monthly_marketing_credit_budget_eur: Decimal


class CreditSettingsIn(BaseModel):
    max_discount_percent: int | None = None
    monthly_marketing_credit_budget_eur: Decimal | None = None


class MarketingBudgetView(BaseModel):
    month: str
    budget_eur: Decimal
    awarded_eur: Decimal
    used_eur: Decimal
    #: Credit given back this month because a booking it was used on was refunded.
    returned_on_refunds_eur: Decimal = Decimal("0.00")
    outstanding_eur: Decimal
    remaining_eur: Decimal
    max_discount_percent: int


@router.get("/admin/client-credit/budget", response_model=MarketingBudgetView)
def marketing_budget(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> MarketingBudgetView:
    """This month (Europe/London): budget, awarded, used at checkout,
    outstanding (every client's unspent credit) and remaining."""
    view = MarketingBudgetView(**client_credit.budget_view(db))
    db.commit()
    return view


@router.get("/admin/client-credit/settings", response_model=CreditSettingsView)
def credit_settings(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> CreditSettingsView:
    row = client_credit.settings(db)
    db.commit()
    return CreditSettingsView(max_discount_percent=row.max_discount_percent, monthly_marketing_credit_budget_eur=row.monthly_marketing_credit_budget_eur)


@router.put("/admin/client-credit/settings", response_model=CreditSettingsView)
def update_credit_settings(
    body: CreditSettingsIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> CreditSettingsView:
    from app.services.audit import add_admin_audit_log

    row = client_credit.settings(db, lock=True)
    changes = {}
    if body.max_discount_percent is not None:
        if not 0 <= body.max_discount_percent <= 100:
            raise APIError(code="validation_error", message="The cap is a percent, 0 to 100", status_code=422)
        changes["max_discount_percent"] = {"from": row.max_discount_percent, "to": body.max_discount_percent}
        row.max_discount_percent = body.max_discount_percent
    if body.monthly_marketing_credit_budget_eur is not None:
        if body.monthly_marketing_credit_budget_eur < 0:
            raise APIError(code="validation_error", message="The budget cannot be negative", status_code=422)
        changes["monthly_marketing_credit_budget_eur"] = {"from": str(row.monthly_marketing_credit_budget_eur), "to": str(body.monthly_marketing_credit_budget_eur)}
        row.monthly_marketing_credit_budget_eur = body.monthly_marketing_credit_budget_eur
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="client_credit_settings", target_id="1",
                        action="client_credit_settings_updated", reason=None, metadata=changes)
    db.commit()
    return CreditSettingsView(max_discount_percent=row.max_discount_percent, monthly_marketing_credit_budget_eur=row.monthly_marketing_credit_budget_eur)
