"""Exchange rates for display and reporting, never for money
(docs/MULTI_CURRENCY.md 4).

Batch M4 needs one thing from here: an amount's value in the base currency
(euros, the currency the ECB's reference rates are quoted from), for the
discovery budget filter and price sort across currencies. Euros convert
exactly. Another currency needs the day's rate, which batch M3 adds
(`fx_rate`, the ECB job); until a rate is known the answer is None, and
callers must treat the amount as not comparable, never as euros.
"""
from __future__ import annotations

from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy.orm import Session

BASE_CURRENCY = "EUR"


def rate_from_base(db: Session | None, currency: str) -> Decimal | None:
    """Units of `currency` per euro, or None when no usable rate is known."""
    if currency == BASE_CURRENCY:
        return Decimal("1")
    return None


def to_base_minor(db: Session | None, amount: Decimal | None, currency: str) -> int | None:
    """`amount` of `currency` in euro cents (half up), or None."""
    if amount is None:
        return None
    rate = rate_from_base(db, currency)
    if rate is None:
        return None
    return int((Decimal(amount) * Decimal(100) / rate).quantize(Decimal("1"), rounding=ROUND_HALF_UP))
