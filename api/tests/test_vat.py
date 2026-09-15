"""UK VAT on an invoice.

Two rules everything here enforces. VAT comes out of the agreed price, never
on top of it - the client paid one total and the invoice separates it. And a
settled invoice reproduces the rate that applied when the booking was made,
because the UK standard rate has been 17.5%, 15% and 20% within twenty years.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche
from app.models.payouts import TaxProfile, VatStatus
from app.services.invoices import build_invoice
from app.services.niche_catalog import ensure_initial_niches
from app.services.payouts import ensure_default_platform_fee_policy
from app.services.tax import ensure_uk_tax_rule, vat_breakdown
from sqlalchemy import select


def _pro(db_session, *, status: VatStatus | None = None, number: str | None = None) -> uuid.UUID:
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(UserRole(user_id=user_id, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=user_id, display_name="VAT Test"))
    if status is not None:
        db_session.add(
            TaxProfile(pro_user_id=user_id, vat_status=status, vat_number=number, country="GB")
        )
    db_session.flush()
    return user_id


def _gig(db_session, pro_id, *, gross: str, vat_status: str, rate: int | None, number: str | None = None):
    ensure_initial_niches(db_session)
    niche = db_session.execute(select(Niche).where(Niche.slug == "portraits")).scalar_one()
    amount = Decimal(gross)
    gig = Gig(
        client_user_id=uuid.uuid4(),
        pro_user_id=pro_id,
        niche_id=niche.id,
        status=GigStatus.completed,
        currency="GBP",
        amount_minimum=amount,
        amount_platform_fee=(amount * Decimal("0.20")).quantize(Decimal("0.01")),
        amount_pro_gross=(amount * Decimal("0.80")).quantize(Decimal("0.01")),
        fee_percent=20,
        retained_percent=15,
        pro_raww_percent=5,
        client_credit_percent=0,
        vat_status=vat_status,
        vat_rate_percent=rate,
        vat_number=number,
        meta={},
    )
    db_session.add(gig)
    db_session.flush()
    return gig


# ---------------------------------------------------------------------------
# Registered.
# ---------------------------------------------------------------------------


def test_a_registered_photographer_sees_vat_taken_out_of_the_total(db_session):
    """Out of, not on top of. GBP 1,200 inclusive at 20% is 1,000 plus 200 -
    not 1,200 plus 240, which would change what the client owes after they
    have already paid."""
    ensure_default_platform_fee_policy(db_session)
    ensure_uk_tax_rule(db_session)
    pro_id = _pro(db_session, status=VatStatus.registered, number="GB123456789")
    gig = _gig(db_session, pro_id, gross="1200.00", vat_status="registered", rate=20, number="GB123456789")

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.applies
    assert invoice.vat.net_amount == Decimal("1000.00")
    assert invoice.vat.vat_amount == Decimal("200.00")
    assert invoice.vat.total == Decimal("1200.00")
    assert invoice.vat.net_amount + invoice.vat.vat_amount == invoice.client_total
    assert invoice.vat.vat_number == "GB123456789"


@pytest.mark.parametrize("gross", ["1200.00", "1490.00", "847.33", "0.07", "99.99"])
def test_the_two_parts_always_sum_back_to_what_was_paid(db_session, gross):
    ensure_default_platform_fee_policy(db_session)
    ensure_uk_tax_rule(db_session)
    pro_id = _pro(db_session, status=VatStatus.registered, number="GB123456789")
    gig = _gig(db_session, pro_id, gross=gross, vat_status="registered", rate=20)

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.net_amount + invoice.vat.vat_amount == Decimal(gross)


def test_the_invoice_uses_the_rate_stamped_not_todays(db_session):
    """The UK rate has changed three times this century. An invoice from
    before a change must keep showing what applied at the time."""
    ensure_default_platform_fee_policy(db_session)
    rule = ensure_uk_tax_rule(db_session)
    pro_id = _pro(db_session, status=VatStatus.registered, number="GB123456789")
    gig = _gig(db_session, pro_id, gross="1175.00", vat_status="registered", rate=175 // 10)

    rule.standard_rate_percent = 20
    db_session.flush()

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.rate_percent == 17, "the invoice was rewritten by a later rate change"


# ---------------------------------------------------------------------------
# Not registered, and never asked.
# ---------------------------------------------------------------------------


def test_an_unregistered_photographer_has_no_vat_parts_at_all(db_session):
    """Null, not zero. A photographer who is not registered charged no VAT,
    which is a different statement from VAT of nothing - and nulls stop a
    renderer printing a breakdown that does not exist."""
    ensure_default_platform_fee_policy(db_session)
    ensure_uk_tax_rule(db_session)
    pro_id = _pro(db_session, status=VatStatus.not_registered)
    gig = _gig(db_session, pro_id, gross="1200.00", vat_status="not_registered", rate=None)

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.applies is False
    assert invoice.vat.net_amount is None
    assert invoice.vat.vat_amount is None
    assert invoice.vat.rate_percent is None
    assert invoice.vat.total == Decimal("1200.00")
    assert invoice.vat.status == VatStatus.not_registered


def test_never_asked_is_not_the_same_as_not_registered(db_session):
    """The reason this is three states. An invoice for someone who has never
    been asked must not assert they are unregistered."""
    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gig = _gig(db_session, pro_id, gross="1200.00", vat_status="not_answered", rate=None)

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.status == VatStatus.not_answered
    assert invoice.vat.status != VatStatus.not_registered


def test_a_registered_photographer_with_no_country_rule_gets_no_rate(db_session):
    """Registered somewhere with no configured rule means no rate to apply.
    Falling back to the UK's 20% would put a number on an invoice no tax
    authority asked for."""
    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session, status=VatStatus.registered, number="XX1")
    gig = _gig(db_session, pro_id, gross="1200.00", vat_status="registered", rate=None)

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.applies is False
    assert invoice.vat.vat_amount is None


# ---------------------------------------------------------------------------
# The platform's own commission VAT, which must never be a number.
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "status,rate", [("registered", 20), ("not_registered", None), ("not_answered", None)]
)
def test_the_platforms_own_commission_vat_is_never_computed(db_session, status, rate):
    """It depends on where RAWWERS incorporates, which is undecided. A
    plausible-looking number here would be worse than a blank, so this fails
    the moment one appears - by any route, including somebody deciding the
    field should default to zero."""
    ensure_default_platform_fee_policy(db_session)
    ensure_uk_tax_rule(db_session)
    pro_id = _pro(db_session, status=VatStatus.registered, number="GB123456789")
    gig = _gig(db_session, pro_id, gross="1200.00", vat_status=status, rate=rate)

    invoice = build_invoice(db_session, gig)
    assert invoice.vat.platform_commission_vat is None
    assert not isinstance(invoice.vat.platform_commission_vat, (int, float, Decimal))


def test_vat_breakdown_refuses_to_invent_a_rate(db_session):
    """Registered but with no rate supplied is not an invitation to pick one."""
    result = vat_breakdown(total=Decimal("1200.00"), status=VatStatus.registered, rate_percent=None)
    assert result.vat_amount is None
    assert result.total == Decimal("1200.00")
