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


def _gig(
    db_session,
    pro_id: uuid.UUID,
    *,
    gross: str,
    stamped: bool,
    credit: int = 0,
    retained: int = 15,
    pro_raww: int = 5,
) -> Gig:
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
        gig.fee_percent = retained + pro_raww
        gig.retained_percent = retained
        gig.pro_raww_percent = pro_raww
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


# ---------------------------------------------------------------------------
# The Wallet summary.
# ---------------------------------------------------------------------------


def test_the_summary_is_the_sum_of_the_invoices(db_session):
    """The property the summary exists to have.

    It could have been a SQL aggregate over the gig table, which would be
    faster and would be a second implementation of the split. The two would
    agree until somebody edited one, and the disagreement would surface as a
    Wallet total that does not match the invoices behind it.
    """
    from app.services.invoices import summarise_invoices

    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    gigs = [
        _gig(db_session, pro_id, gross="1490.00", stamped=True, credit=0),
        _gig(db_session, pro_id, gross="847.33", stamped=True, credit=10),
        _gig(db_session, pro_id, gross="3.33", stamped=True, credit=7),
        # Stamped at rates that are not the current policy's. Without this the
        # summed lines and a naive "20% of total gross" aggregate produce the
        # same number, and the assertion below cannot tell them apart - the
        # first version of this test passed against exactly that aggregate.
        _gig(db_session, pro_id, gross="2000.00", stamped=True, retained=25, pro_raww=5),
        _gig(db_session, pro_id, gross="1000.00", stamped=False),
    ]
    db_session.flush()

    invoices = [build_invoice(db_session, gig) for gig in gigs]
    summary = summarise_invoices(db_session, pro_id)

    assert summary.bookings == len(gigs)
    assert summary.gross == sum((i.client_total for i in invoices), Decimal("0.00"))
    assert summary.pro_cash == sum((i.pro_cash for i in invoices), Decimal("0.00"))
    assert summary.client_raww == sum((i.client_raww for i in invoices), Decimal("0.00"))
    assert summary.pro_raww == sum((i.pro_raww for i in invoices), Decimal("0.00"))
    assert summary.platform_fees == sum(
        (i.platform_retained + i.pro_raww for i in invoices), Decimal("0.00")
    )


def test_the_summary_totals_reconcile_to_the_gross(db_session):
    from app.services.invoices import summarise_invoices

    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    for gross, credit in [("1490.00", 0), ("847.33", 10), ("0.07", 3)]:
        _gig(db_session, pro_id, gross=gross, stamped=True, credit=credit)
    db_session.flush()

    s = summarise_invoices(db_session, pro_id)
    # platform_fees already contains pro_raww, so it is not added again.
    assert s.platform_fees + s.pro_cash + s.client_raww == s.gross


def test_a_photographer_with_no_completed_work_has_no_average(db_session):
    """Not zero. An average of 0.00 states that their bookings average
    nothing, which is a different claim from having none."""
    from app.services.invoices import summarise_invoices

    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)

    summary = summarise_invoices(db_session, pro_id)
    assert summary.bookings == 0
    assert summary.average_gross is None
    assert summary.gross == Decimal("0.00")


def test_the_summary_counts_how_many_totals_were_reconstructed(db_session):
    """A total built mostly from gigs predating the stamped rates should be
    able to say so, rather than presenting every figure as recorded."""
    from app.services.invoices import summarise_invoices

    ensure_default_platform_fee_policy(db_session)
    pro_id = _pro(db_session)
    _gig(db_session, pro_id, gross="1000.00", stamped=True)
    _gig(db_session, pro_id, gross="1000.00", stamped=False)
    _gig(db_session, pro_id, gross="1000.00", stamped=False)
    db_session.flush()

    assert summarise_invoices(db_session, pro_id).reconstructed == 2
