"""Consumption tax on an invoice. UK only, shaped for more.

Two rules govern everything here.

**VAT comes out of the price, never on top of it.** The client agreed one
total and paid it. Where the photographer is registered, that total already
contains VAT and the invoice separates it; where they are not, the total is
simply the total. Adding VAT to an agreed price would change what somebody
owes after they have paid it.

**A settled invoice reproduces the rate that applied.** The rate lives in
`country_tax_rule` so it can be changed, and a gig stamps it at booking time
so changing it never rewrites an old invoice. The UK standard rate has been
17.5%, 15% and 20% within twenty years, so this is not hypothetical.

RAWWERS' own VAT treatment of its commission is deliberately absent. It
depends on where the company ends up incorporated, which is undecided, and a
plausible-looking number in the meantime would be worse than a blank.
"""
from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.payouts import CountryTaxRule, TaxProfile, VatStatus

#: The one country this launches in. Everything reads the table; this is only
#: the default when a gig carries no country of its own.
DEFAULT_COUNTRY = "GB"

UK_STANDARD_RATE_PERCENT = 20
UK_REGISTRATION_THRESHOLD = Decimal("90000.00")


def _q2(amount: Decimal) -> Decimal:
    return amount.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def ensure_uk_tax_rule(db: Session) -> CountryTaxRule:
    """The UK row, created once.

    Threshold included as reference the UI can cite and nothing may act on:
    the platform sees a photographer's RAWWERS bookings, which may be a small
    part of their turnover, so it cannot tell whether anybody has crossed it.
    """
    rule = db.get(CountryTaxRule, DEFAULT_COUNTRY)
    if rule is None:
        rule = CountryTaxRule(
            country=DEFAULT_COUNTRY,
            tax_name="VAT",
            standard_rate_percent=UK_STANDARD_RATE_PERCENT,
            registration_threshold=UK_REGISTRATION_THRESHOLD,
            threshold_currency="GBP",
            vat_number_format="GB123456789",
        )
        db.add(rule)
        db.flush()
    return rule


def tax_rule_for(db: Session, country: str | None) -> CountryTaxRule | None:
    if not country:
        return None
    return db.get(CountryTaxRule, country.upper()[:2])


def tax_profile_for(db: Session, pro_user_id) -> TaxProfile | None:
    return db.execute(
        select(TaxProfile).where(TaxProfile.pro_user_id == pro_user_id)
    ).scalar_one_or_none()


@dataclass(frozen=True)
class VatBreakdown:
    """How one invoice's total divides for tax, and whether it divides at all."""

    status: VatStatus

    #: Null unless the photographer is registered. Not zero: a photographer
    #: who is not registered has no VAT on this invoice, which is different
    #: from VAT of nothing.
    rate_percent: int | None
    vat_number: str | None

    #: Both null when no VAT applies, so a renderer cannot print a breakdown
    #: that does not exist.
    net_amount: Decimal | None
    vat_amount: Decimal | None

    total: Decimal

    #: Always None, always. RAWWERS' treatment of its own commission is
    #: undecided, and this exists as a field so the invoice can say "pending"
    #: rather than say nothing - an absent field is indistinguishable from one
    #: somebody fills in by accident.
    platform_commission_vat: None = None

    @property
    def applies(self) -> bool:
        return self.status == VatStatus.registered and self.vat_amount is not None


def vat_breakdown(
    *,
    total: Decimal,
    status: VatStatus,
    rate_percent: int | None,
    vat_number: str | None = None,
) -> VatBreakdown:
    """Split a VAT-inclusive total into its net and tax parts.

    Only when the photographer is registered and a rate applied. Otherwise the
    total stands alone and both parts are null, so nothing downstream can
    render a breakdown of a tax that was never charged.
    """
    total = _q2(total)

    if status != VatStatus.registered or not rate_percent:
        return VatBreakdown(
            status=status,
            rate_percent=None,
            vat_number=None,
            net_amount=None,
            vat_amount=None,
            total=total,
        )

    # Out of the total, not added to it. net = total / (1 + rate), and the VAT
    # is the remainder so the two always sum back to what was actually paid.
    divisor = Decimal(100 + rate_percent) / Decimal(100)
    net = _q2(total / divisor)
    return VatBreakdown(
        status=status,
        rate_percent=rate_percent,
        vat_number=vat_number,
        net_amount=net,
        vat_amount=_q2(total - net),
        total=total,
    )
