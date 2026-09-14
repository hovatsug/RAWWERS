"""The per-gig invoice.

An invoice is a record of a transaction, not a recomputation of one. These
cover the two things that makes true: every line comes from the gig's own
row, and the lines sum back to what the client actually paid.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.gig import Gig, GigStatus
from app.models.niche import Niche
from app.services.invoices import build_invoice
from app.services.niche_catalog import ensure_initial_niches
from app.services.payouts import ensure_default_platform_fee_policy
from sqlalchemy import select


def _pro(db_session) -> uuid.UUID:
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(UserRole(user_id=user_id, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=user_id, display_name="Invoice Test"))
    db_session.flush()
    return user_id


def _gig(db_session, pro_id: uuid.UUID, *, gross: str, stamped: bool, credit: int = 0) -> Gig:
    ensure_initial_niches(db_session)
    niche = db_session.execute(select(Niche).where(Niche.slug == "portraits")).scalar_one()
    amount = Decimal(gross)
    gig = Gig(
        client_user_id=uuid.uuid4(),
        pro_user_id=pro_id,
        niche_id=niche.id,
        status=GigStatus.completed,
        currency="EUR",
        amount_minimum=amount,
        amount_platform_fee=(amount * Decimal("0.20")).quantize(Decimal("0.01")),
        amount_pro_gross=(amount * Decimal("0.80")).quantize(Decimal("0.01")),
        meta={},
    )
    if stamped:
        gig.fee_percent = 20
        gig.retained_percent = 15
        gig.pro_raww_percent = 5
        gig.client_credit_percent = credit
    db_session.add(gig)
    db_session.flush()
    return gig


@pytest.mark.parametrize("gross", ["1490.00", "48.00", "3.33", "99.99", "0.07"])
def test_every_line_sums_back_to_what_the_client_paid(db_session, gross):
    """No rounding drift left unexplained. The photographer's cash is a
    remainder rather than its own rounded percentage, so it absorbs the
    fraction instead of the invoice quietly losing a cent."""
    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gig = _gig(db_session, pro_id, gross=gross, stamped=True, credit=7)

    invoice = build_invoice(db_session, gig)
    assert invoice.reconciles(), (
        f"{invoice.platform_retained} + {invoice.pro_raww} + {invoice.client_raww} + "
        f"{invoice.pro_cash} against {invoice.client_total}"
    )


def test_the_invoice_matches_the_gig_row_it_came_from(db_session):
    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gig = _gig(db_session, pro_id, gross="1490.00", stamped=True, credit=0)

    invoice = build_invoice(db_session, gig)
    assert invoice.client_total == gig.amount_minimum
    # At zero client credit the photographer's cash is exactly the pro gross
    # the gig has always recorded, which is the check that the new split did
    # not quietly change what anybody is paid.
    assert invoice.pro_cash == gig.amount_pro_gross
    assert invoice.platform_retained + invoice.pro_raww == gig.amount_platform_fee


def test_the_invoice_uses_the_rates_stamped_on_the_gig_not_todays_policy(db_session):
    """The point of stamping. An invoice for last month must not change
    because the platform's rate changed this month."""
    policy = ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gig = _gig(db_session, pro_id, gross="1000.00", stamped=True, credit=10)

    policy.fee_percent_gigs = 40
    policy.retained_percent = 35
    db_session.flush()

    invoice = build_invoice(db_session, gig)
    assert invoice.platform_retained == Decimal("150.00"), "the invoice was rewritten by a later rate change"
    assert invoice.client_raww == Decimal("100.00")
    assert invoice.rates_were_stamped is True


def test_a_gig_with_no_stamped_rates_says_so(db_session):
    """Gigs predating the stamped rates reconstruct their split from the
    current policy. That is a reasonable fallback and a bad thing to present
    silently as a record."""
    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gig = _gig(db_session, pro_id, gross="1000.00", stamped=False)

    invoice = build_invoice(db_session, gig)
    assert invoice.rates_were_stamped is False
    assert invoice.reconciles()


def test_photos_delivered_is_unknown_rather_than_zero(db_session):
    """A completed gig with no recorded selection has an unknown photo count.
    Rendering zero would be the invoice claiming nothing was delivered - the
    same lie as a wallet reading EUR 0.00 for twenty finished jobs."""
    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gig = _gig(db_session, pro_id, gross="1000.00", stamped=True)

    invoice = build_invoice(db_session, gig)
    assert invoice.photos_delivered is None, "an unrecorded count was reported as zero"
