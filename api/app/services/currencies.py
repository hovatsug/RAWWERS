"""Currencies (docs/MULTI_CURRENCY.md 2.1, 10.1, 10.3).

- A photographer has **one** currency: the currency of their Stripe
  account's country (GB means GBP, a eurozone country EUR), with no
  exceptions. Before the account exists it follows their profile's country,
  and with no country it is the platform default (`DEFAULT_CURRENCY`, GBP).
- Their packages, earnings, holds, balance and payouts are all in it.
- Which currencies may be used at all is an admin setting
  (`currency_settings`); with no row, GBP only. A currency that is not
  enabled cannot get a package or a Connect account. Rows that already
  exist in it keep working.
- A missing or unknown currency is an error, never a silent EUR.
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass
from decimal import Decimal

from sqlalchemy import exists, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import ProProfile
from app.models.currency import CurrencySettings

SUPPORTED: tuple[str, ...] = ("GBP", "EUR")

#: The euro area (2026). Ireland is EUR; the United Kingdom is GBP; any
#: other country has no supported currency.
EUROZONE = frozenset({
    "AT", "BE", "HR", "CY", "EE", "FI", "FR", "DE", "GR", "IE", "IT",
    "LV", "LT", "LU", "MT", "NL", "PT", "SK", "SI", "ES",
})

#: Used while `currency_settings` has no row.
CODE_DEFAULTS: dict = {
    "enabled_currencies": ("GBP",),
    "payout_minimums": {"GBP": Decimal("45.00"), "EUR": Decimal("50.00")},
}


@dataclass(frozen=True)
class CurrencySettingsView:
    enabled_currencies: tuple[str, ...]
    payout_minimums: dict[str, Decimal]
    from_defaults: bool


def normalise(currency: str | None) -> str:
    """`currency` as an upper-case supported code, or a 422."""
    if not currency or not str(currency).strip():
        raise APIError(code="currency_required", message="A currency is required", status_code=422)
    code = str(currency).strip().upper()
    if code not in SUPPORTED:
        raise APIError(code="unsupported_currency", message=f"{code} is not a supported currency", status_code=422)
    return code


def currency_for_country(country: str | None) -> str | None:
    code = (country or "").strip().upper()[:2]
    if code == "GB":
        return "GBP"
    if code in EUROZONE:
        return "EUR"
    return None


def default_currency() -> str:
    return normalise(get_settings().default_currency)


def currency_for_new_profile(country: str | None) -> str:
    return currency_for_country(country) or default_currency()


def get_currency_settings(db: Session) -> CurrencySettingsView:
    row = db.get(CurrencySettings, 1)
    if row is None:
        return CurrencySettingsView(
            enabled_currencies=tuple(CODE_DEFAULTS["enabled_currencies"]),
            payout_minimums={k: Decimal(str(v)) for k, v in CODE_DEFAULTS["payout_minimums"].items()},
            from_defaults=True,
        )
    return CurrencySettingsView(
        enabled_currencies=tuple(normalise(c) for c in row.enabled_currencies),
        payout_minimums={normalise(k): Decimal(str(v)) for k, v in (row.payout_minimums or {}).items()},
        from_defaults=False,
    )


def update_currency_settings(
    db: Session, *, enabled_currencies: list[str], payout_minimums: dict[str, Decimal], admin_user_id: uuid.UUID | None
) -> CurrencySettingsView:
    enabled = []
    for code in enabled_currencies:
        code = normalise(code)
        if code not in enabled:
            enabled.append(code)
    if not enabled:
        raise APIError(code="validation_error", message="At least one currency must be enabled", status_code=422)
    minimums: dict[str, str] = {}
    for code, value in payout_minimums.items():
        amount = Decimal(str(value)).quantize(Decimal("0.01"))
        if amount <= 0:
            raise APIError(code="validation_error", message="A payout minimum must be above zero", status_code=422)
        minimums[normalise(code)] = str(amount)
    missing = [c for c in enabled if c not in minimums]
    if missing:
        raise APIError(code="validation_error", message=f"No payout minimum for {', '.join(missing)}", status_code=422)
    row = db.get(CurrencySettings, 1)
    if row is None:
        row = CurrencySettings(id=1)
        db.add(row)
    row.enabled_currencies = enabled
    row.payout_minimums = minimums
    row.updated_by_admin_id = admin_user_id
    db.flush()
    return get_currency_settings(db)


def enabled_currencies(db: Session) -> tuple[str, ...]:
    return get_currency_settings(db).enabled_currencies


def require_enabled(db: Session, currency: str) -> str:
    code = normalise(currency)
    if code not in enabled_currencies(db):
        raise APIError(
            code="currency_not_enabled",
            message=f"{code} is not available yet",
            status_code=422,
            details={"currency": code},
        )
    return code


def payout_minimum(db: Session, currency: str) -> Decimal:
    code = normalise(currency)
    minimums = get_currency_settings(db).payout_minimums
    if code not in minimums:
        # A configured currency without a minimum is refused at update; the
        # code defaults cover both, so this is a bug.
        raise APIError(code="currency_not_enabled", message=f"No payout minimum for {code}", status_code=422)
    return minimums[code]


def pro_currency(db: Session, pro_user_id: uuid.UUID) -> str | None:
    """The photographer's currency, or None when they have no profile."""
    return db.execute(select(ProProfile.currency).where(ProProfile.user_id == pro_user_id)).scalar_one_or_none()


def require_pro_currency(db: Session, pro_user_id: uuid.UUID) -> str:
    code = pro_currency(db, pro_user_id)
    if code is None:
        raise APIError(code="not_found", message="Photographer profile not found", status_code=404)
    return normalise(code)


def pro_has_money_or_packages(db: Session, pro_user_id: uuid.UUID) -> bool:
    """Whether anything is already in the photographer's currency: a package,
    an earning or a payout. Then the currency cannot follow a new country."""
    from app.models.booking import ProPackage
    from app.models.payouts import EarningsLedgerEntry, PayoutRequest

    return bool(
        db.execute(select(exists().where(ProPackage.pro_user_id == pro_user_id))).scalar()
        or db.execute(select(exists().where(EarningsLedgerEntry.pro_user_id == pro_user_id))).scalar()
        or db.execute(select(exists().where(PayoutRequest.pro_user_id == pro_user_id))).scalar()
    )


def follow_profile_country(db: Session, profile: ProProfile) -> None:
    """Before anything exists in their currency, a photographer's currency
    follows the country on their profile (GB → GBP, eurozone → EUR). Once a
    package, earning or payout exists it is fixed (changing it is admin-only,
    MULTI_CURRENCY.md 2.1)."""
    wanted = currency_for_country(profile.country)
    if wanted is None or wanted == profile.currency:
        return
    if pro_has_money_or_packages(db, profile.user_id):
        return
    profile.currency = wanted


SYMBOLS = {"GBP": "£", "EUR": "€"}


def format_money(amount, currency: str) -> str:
    """"£45.00", "€1000.00": the server's plain text form (notifications,
    emails). The currency is required."""
    code = normalise(currency)
    value = Decimal(str(amount)).quantize(Decimal("0.01"))
    sign = "-" if value < 0 else ""
    return f"{sign}{SYMBOLS[code]}{abs(value)}"


def package_currency(db: Session, profile: ProProfile, requested: str | None) -> str:
    """The currency of a new or edited package: the photographer's, which must
    be enabled. A different one in the request is refused (2.1)."""
    own = normalise(profile.currency)
    if requested is not None and str(requested).strip():
        asked = normalise(requested)
        if asked != own:
            raise APIError(
                code="currency_mismatch",
                message=f"Your packages are in {own}: your payout account's currency",
                status_code=422,
                details={"currency": asked, "photographer_currency": own},
            )
    return require_enabled(db, own)
