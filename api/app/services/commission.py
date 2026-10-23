"""How one booking's money divides.

The platform's take is 20% of gross and does not move. What this adds is the
structure inside that: the 20% splits into a retained share and $RAWW credit
for the photographer, and the photographer's 80% splits into cash and
whatever credit they choose to pass to the client.

    15%  platform, retained
     5%  photographer, as $RAWW credit
    80%  photographer, cash  -  minus the client credit below
     0-10%  client, as $RAWW credit, out of the photographer's own cash

At the 10% maximum the photographer's cash share is 70% and the platform's
20% is untouched. Client credit is a percentage of gross, not of the
photographer's share, so the four shares always sum to the gross exactly.

**One source for the rate.** It was defined three times - an environment
variable read at booking acceptance, a database row read when earnings were
created, and hardcoded twice more in the seed scripts. All four said 20%, by
coincidence rather than by construction: changing the admin-editable row
would have left bookings computing the old number while earnings computed the
new one. Every caller now reads the policy row.

**Rates are stamped, never re-read.** The refund path already understood
this: it reads the fee percentage from the earnings entry's own metadata, so
that changing the platform's rate tomorrow cannot retroactively rewrite money
that settled today. Everything here follows the same rule - a booking records
the percentages it was created under, and the invoice reproduces them rather
than recomputing from whatever the policy currently says.
"""
from __future__ import annotations

from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal

from app.core.errors import APIError
from app.models.payouts import PlatformFeePolicy

#: A photographer may pass at most this share of gross to their client. The
#: policy row carries the real cap; this is the fallback when none is set.
DEFAULT_MAX_CLIENT_CREDIT_PERCENT = 10


def _q2(amount: Decimal) -> Decimal:
    return amount.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _share(gross: Decimal, percent: int) -> Decimal:
    return _q2(gross * Decimal(percent) / Decimal(100))


@dataclass(frozen=True)
class BookingSplit:
    """Every share of one booking, in euros, plus the rates that produced it.

    The percentages travel with the amounts so a caller can stamp them onto
    the row it is writing. An invoice that shows amounts without the rates
    behind them cannot be audited a year later, when the rates have moved.
    """

    gross: Decimal

    #: The platform's whole take. Unchanged by any of the structure below,
    #: and the number `Gig.amount_platform_fee` has always held.
    platform_total: Decimal

    #: The part the platform keeps.
    platform_retained: Decimal

    #: The part of the platform's take that returns to the photographer as
    #: credit rather than cash.
    pro_raww: Decimal

    #: The photographer's whole share before any client credit - the number
    #: `Gig.amount_pro_gross` has always held.
    pro_total: Decimal

    #: What actually reaches the photographer's wallet as money.
    pro_cash: Decimal

    #: Credit to the client, out of the photographer's cash.
    client_raww: Decimal

    fee_percent: int
    retained_percent: int
    pro_raww_percent: int
    client_credit_percent: int

    def reconciles(self) -> bool:
        """Every share back to the gross, to the cent."""
        return (
            self.platform_retained + self.pro_raww + self.pro_cash + self.client_raww == self.gross
        )


def validate_client_credit_percent(value: int, *, maximum: int) -> int:
    """Whole percentage points only, 0 to the cap.

    Whole points because a photographer choosing between 7% and 7.5% is
    choosing between two numbers they cannot tell apart on an invoice, and
    fractional rates make every downstream total a rounding argument.
    """
    if isinstance(value, bool) or not isinstance(value, int):
        raise APIError(
            code="validation_error",
            message="Client credit must be a whole number of percent",
            status_code=422,
        )
    if value < 0 or value > maximum:
        raise APIError(
            code="validation_error",
            message=f"Client credit must be between 0 and {maximum} percent",
            status_code=422,
        )
    return value


def max_client_credit_percent(policy: PlatformFeePolicy | None) -> int:
    if policy is None or policy.max_client_credit_percent is None:
        return DEFAULT_MAX_CLIENT_CREDIT_PERCENT
    return int(policy.max_client_credit_percent)


def split_booking(
    *,
    gross: Decimal,
    policy: PlatformFeePolicy,
    client_credit_percent: int = 0,
) -> BookingSplit:
    """Divide a booking's gross into every share it owes.

    The photographer's cash is what remains after the platform's take and the
    client's credit, rather than a percentage computed independently. That is
    deliberate: three rounded percentages of the same gross need not sum back
    to it, and the party whose share absorbs the rounding should be the one
    the arithmetic is describing rather than the platform helping itself to a
    stray cent.
    """
    fee_percent = int(policy.fee_percent_gigs)
    retained_percent = int(policy.retained_percent)
    pro_raww_percent = int(policy.pro_raww_percent)

    if retained_percent + pro_raww_percent != fee_percent:
        raise APIError(
            code="invalid_state",
            message=(
                f"Fee policy does not add up: {retained_percent}% retained plus "
                f"{pro_raww_percent}% credit is not the {fee_percent}% take"
            ),
            status_code=500,
        )

    client_credit_percent = validate_client_credit_percent(
        int(client_credit_percent), maximum=max_client_credit_percent(policy)
    )
    return split_with_rates(
        gross,
        retained_percent=retained_percent,
        pro_raww_percent=pro_raww_percent,
        client_credit_percent=client_credit_percent,
    )


def split_with_rates(
    gross: Decimal, *, retained_percent: int, pro_raww_percent: int, client_credit_percent: int = 0
) -> BookingSplit:
    """The one rounding rule for a booking's money (the invoice method).

    Retained, $RAWW credit and client credit are each a rounded percentage
    of gross; the photographer's cash is the remainder. So EUR 52.43 is
    7.86 + 2.62 + 41.95, and the platform's take is 10.48 - not a single 20%
    rounded to 10.49, which is how earnings used to be computed and why
    some wallets were a few cents off their invoices.
    """
    gross = _q2(gross)
    platform_retained = _share(gross, retained_percent)
    pro_raww = _share(gross, pro_raww_percent)
    client_raww = _share(gross, client_credit_percent)
    platform_total = _q2(platform_retained + pro_raww)

    # Remainders, not independent percentages, so the shares always reconcile.
    pro_total = _q2(gross - platform_total)
    pro_cash = _q2(gross - platform_retained - pro_raww - client_raww)

    return BookingSplit(
        gross=gross,
        platform_total=platform_total,
        platform_retained=platform_retained,
        pro_raww=pro_raww,
        pro_total=pro_total,
        pro_cash=pro_cash,
        client_raww=client_raww,
        fee_percent=retained_percent + pro_raww_percent,
        retained_percent=retained_percent,
        pro_raww_percent=pro_raww_percent,
        client_credit_percent=client_credit_percent,
    )


def split_for_pro(
    db,
    *,
    gross: Decimal,
    pro_user_id,
    client_credit_percent_override: int | None = None,
) -> BookingSplit:
    """The split for one photographer's booking, at the rates in force now.

    The single entry point for every booking path. They previously each
    computed the fee from `settings.platform_fee_bps` while earnings were
    computed from the policy row - two definitions of one number, agreeing
    only because nobody had changed either.

    The client credit is the photographer's own default unless this booking
    overrides it, so nobody is asked on every request but a photographer can
    still be more generous on a particular job.
    """
    from app.models.admin import ProProfile
    from app.services.payouts import ensure_default_platform_fee_policy

    policy = ensure_default_platform_fee_policy(db)
    if client_credit_percent_override is not None:
        credit = client_credit_percent_override
    else:
        profile = db.get(ProProfile, pro_user_id)
        credit = int(getattr(profile, "client_credit_percent", 0) or 0)

    return split_booking(gross=gross, policy=policy, client_credit_percent=credit)


def vat_stamp_for(db, *, pro_user_id, country: str | None = None) -> dict:
    """The VAT facts to record on a gig at the moment it is booked.

    Stamped for the same reason the commission rates are: a photographer who
    registers for VAT next year must not retroactively add VAT lines to this
    year's invoices, and a rate change must not rewrite them either.

    Defaults to not_answered with no rate, so a photographer who has never
    been asked produces an invoice with no VAT breakdown rather than one
    quietly asserting they are not registered.
    """
    from app.models.payouts import VatStatus
    from app.services.tax import DEFAULT_COUNTRY, tax_profile_for, tax_rule_for

    profile = tax_profile_for(db, pro_user_id)
    if profile is None or profile.vat_status != VatStatus.registered:
        return {
            "vat_status": (profile.vat_status.value if profile else VatStatus.not_answered.value),
            "vat_rate_percent": None,
            "vat_number": None,
        }

    rule = tax_rule_for(db, country or profile.country or DEFAULT_COUNTRY)
    return {
        "vat_status": VatStatus.registered.value,
        # No rule for their country means no rate to apply. Guessing one would
        # put a number on an invoice that no tax authority asked for.
        "vat_rate_percent": int(rule.standard_rate_percent) if rule else None,
        "vat_number": profile.vat_number,
    }
