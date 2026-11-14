"""The client's credit: balances and history (per currency: MULTI_CURRENCY.md
decision M3), and what it would take off a booking's payment
(services/client_credit.py)."""
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
    amount: Decimal
    #: The credit's currency (each line is in the currency of its booking).
    currency: str
    #: For a marketing permission: the booking's photographer.
    photographer_first_name: str | None = None


class CreditBalance(BaseModel):
    balance: Decimal
    currency: str


class MyCreditResponse(BaseModel):
    #: The client's credit in `currency`: the default currency's (until the
    #: display currency, batch M3), or the only one they hold.
    balance: Decimal
    currency: str
    #: Every currency they hold credit in. Credit pays only for bookings in
    #: its own currency; nothing is converted.
    balances: list[CreditBalance] = []
    #: Credit takes at most this much of a booking's payment.
    max_discount_percent: int
    items: list[CreditHistoryItem]


class BookingCreditPreview(BaseModel):
    #: The client's credit, in `credit_currency`.
    balance: Decimal
    credit_currency: str
    #: What credit takes off, the price and what is left to pay, in `currency`
    #: (the booking's). Only credit in the booking's currency is used.
    discount: Decimal
    price: Decimal
    total: Decimal
    max_discount_percent: int
    #: Already set aside for this payment.
    applied: bool
    currency: str


@router.get("/me/credit", response_model=MyCreditResponse)
def my_credit(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> MyCreditResponse:
    from app.services.currencies import default_currency

    held = client_credit.balances(db, user.user_id)
    currency = held[0]["currency"] if len(held) == 1 else default_currency()
    shown = next((b["balance"] for b in held if b["currency"] == currency), Decimal("0.00"))
    view = MyCreditResponse(
        balance=shown,
        currency=currency,
        balances=[CreditBalance(**b) for b in held],
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
    #: One monthly budget per currency (decision M3), each in its currency.
    monthly_marketing_credit_budget_eur: Decimal
    monthly_marketing_credit_budget_gbp: Decimal


class CreditSettingsIn(BaseModel):
    max_discount_percent: int | None = None
    monthly_marketing_credit_budget_eur: Decimal | None = None
    monthly_marketing_credit_budget_gbp: Decimal | None = None


class MarketingBudgetView(BaseModel):
    month: str
    #: Every amount below is in it: one budget per currency (decision M3).
    currency: str
    budget: Decimal
    awarded: Decimal
    used: Decimal
    #: Credit given back this month because a booking it was used on was refunded.
    returned_on_refunds: Decimal = Decimal("0.00")
    outstanding: Decimal
    remaining: Decimal
    max_discount_percent: int


@router.get("/admin/client-credit/budget", response_model=MarketingBudgetView)
def marketing_budget(
    currency: str | None = None, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)
) -> MarketingBudgetView:
    """This month (Europe/London), in one currency (the default when none is
    asked for): budget, awarded, used at checkout, outstanding (every
    client's unspent credit) and remaining."""
    from app.services.currencies import default_currency

    view = MarketingBudgetView(**client_credit.budget_view(db, currency or default_currency()))
    db.commit()
    return view


def _settings_view(row) -> CreditSettingsView:
    return CreditSettingsView(
        max_discount_percent=row.max_discount_percent,
        monthly_marketing_credit_budget_eur=row.monthly_marketing_credit_budget_eur,
        monthly_marketing_credit_budget_gbp=row.monthly_marketing_credit_budget_gbp,
    )


@router.get("/admin/client-credit/settings", response_model=CreditSettingsView)
def credit_settings(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> CreditSettingsView:
    row = client_credit.settings(db)
    db.commit()
    return _settings_view(row)


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
    for name in ("monthly_marketing_credit_budget_eur", "monthly_marketing_credit_budget_gbp"):
        value = getattr(body, name)
        if value is None:
            continue
        if value < 0:
            raise APIError(code="validation_error", message="The budget cannot be negative", status_code=422)
        changes[name] = {"from": str(getattr(row, name)), "to": str(value)}
        setattr(row, name, value)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="client_credit_settings", target_id="1",
                        action="client_credit_settings_updated", reason=None, metadata=changes)
    db.commit()
    return _settings_view(row)
