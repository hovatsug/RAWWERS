"""Price filters and price sort on the discovery index, across currencies
(docs/MULTI_CURRENCY.md 5, "Discovery and search").

A client's budget is in one currency (the default currency until the
display currency, batch M3). A photographer priced in that currency is
compared exactly, on `min_package_price`. One priced in another currency is
compared approximately, on `min_package_price_base_minor` (euro cents) with
the budget converted the same way - and left out while either has no rate.
A pound price is never compared with a euro budget as if it were euros.
"""
from __future__ import annotations

from decimal import Decimal

from sqlalchemy import and_, or_
from sqlalchemy.orm import Session

from app.models.discovery import ProPublicIndex
from app.services import fx


def budget_currency(currency: str | None, db: Session | None = None, user_id=None) -> str:
    """The currency a budget is in: the one the request names, else the
    signed-in user's display currency, else the default."""
    from app.services.currencies import default_currency, display_currency, normalise

    if currency:
        return normalise(currency)
    if db is not None and user_id is not None:
        return display_currency(db, user_id)
    return default_currency()


def price_conditions(db: Session | None, *, min_price, max_price, currency: str) -> list:
    """Conditions for "the cheapest package is within [min_price, max_price]
    in `currency`"."""
    conditions = []
    for bound, op in ((min_price, "ge"), (max_price, "le")):
        if bound is None:
            continue
        amount = Decimal(str(bound))
        same = ProPublicIndex.currency == currency
        exact = ProPublicIndex.min_package_price >= amount if op == "ge" else ProPublicIndex.min_package_price <= amount
        base = fx.to_base_minor(db, amount, currency)
        if base is None:
            conditions.append(and_(same, exact))
            continue
        approx = (
            ProPublicIndex.min_package_price_base_minor >= base
            if op == "ge"
            else ProPublicIndex.min_package_price_base_minor <= base
        )
        conditions.append(or_(and_(same, exact), and_(ProPublicIndex.currency != currency, approx)))
    return conditions


def price_order(*, descending: bool) -> list:
    """Cheapest (or dearest) first across currencies, by the euro value;
    rows with no rate yet after the others, by their own price."""
    base = ProPublicIndex.min_package_price_base_minor
    own = ProPublicIndex.min_package_price
    if descending:
        return [base.desc().nulls_last(), own.desc()]
    return [base.asc().nulls_last(), own.asc()]


def within_budget(db: Session | None, row: ProPublicIndex, budget, currency: str) -> bool:
    """The same rule as price_conditions(max_price=budget), for one row."""
    if budget is None or row.min_package_price is None:
        return False
    if row.currency == currency:
        return Decimal(row.min_package_price) <= Decimal(str(budget))
    base = fx.to_base_minor(db, Decimal(str(budget)), currency)
    return base is not None and row.min_package_price_base_minor is not None and row.min_package_price_base_minor <= base
