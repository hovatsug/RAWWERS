"""Display rates and the user's display currency
(docs/MULTI_CURRENCY.md 2.2, 4.1, 6.2; batch M3).

The display currency changes only the approximation shown beside an
amount. Every amount charged, stored or paid out stays in its own currency."""
from __future__ import annotations

from datetime import date

from fastapi import APIRouter, Depends, Response
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.schemas.media import CurrentUser
from app.services import currencies, fx

router = APIRouter(tags=["fx"])

#: The rate changes once a working day; an hour's cache costs nothing.
RATES_CACHE_SECONDS = 3600


class FxRatesResponse(BaseModel):
    #: Rates are units of each currency per one `base` (EUR).
    base: str
    #: Only rates at most 4 days old; empty when none is: show the charged
    #: amount alone, with "Charged in <currency>".
    rates: dict[str, str]
    as_of: date | None = None


class DisplayCurrencyView(BaseModel):
    #: What approximations are shown in: the user's choice, else the default.
    display_currency: str
    #: Whether the user chose it (false: the default applies).
    chosen: bool
    #: What may be chosen (the currencies switched on).
    available: list[str]


class DisplayCurrencyUpdateRequest(BaseModel):
    #: A currency switched on; null goes back to the default.
    display_currency: str | None = None


@router.get("/fx/rates", response_model=FxRatesResponse)
def fx_rates(response: Response, db: Session = Depends(get_db_session)) -> FxRatesResponse:
    """The display rates the apps convert with: the same the server uses."""
    view = FxRatesResponse(**fx.rates_view(db))
    db.commit()
    response.headers["Cache-Control"] = f"public, max-age={RATES_CACHE_SECONDS}"
    return view


def _view(db: Session, user_id) -> DisplayCurrencyView:
    from app.models.admin import UserAccount

    account = db.get(UserAccount, user_id)
    chosen = bool(account and account.display_currency)
    return DisplayCurrencyView(
        display_currency=currencies.display_currency(db, user_id),
        chosen=chosen,
        available=list(currencies.enabled_currencies(db)),
    )


@router.get("/me/display-currency", response_model=DisplayCurrencyView)
def get_display_currency(user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)) -> DisplayCurrencyView:
    view = _view(db, user.user_id)
    db.commit()
    return view


@router.put("/me/display-currency", response_model=DisplayCurrencyView)
def put_display_currency(
    body: DisplayCurrencyUpdateRequest, user: CurrentUser = Depends(require_not_banned), db: Session = Depends(get_db_session)
) -> DisplayCurrencyView:
    """Account > Display currency (clients and photographers). Only a
    currency switched on may be chosen (`currency_not_enabled`)."""
    currencies.set_display_currency(db, user.user_id, body.display_currency)
    view = _view(db, user.user_id)
    db.commit()
    return view
