"""What one completed gig actually paid, line by line.

Every figure comes from the gig row and the rates stamped on it at the time
it was created. Nothing here recomputes from the policy that happens to be in
force today: an invoice is a record of a transaction, and a rate change next
month must not rewrite what an invoice for last month says.

Gigs created before those rates existed carry none, and for those the invoice
falls back to the policy - but says so, through `rates_were_stamped`, rather
than presenting a reconstruction as a record.
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, SelectionStatus
from app.models.gig import Gig
from app.services.commission import split_booking
from app.services.payouts import ensure_default_platform_fee_policy


def _q2(amount: Decimal) -> Decimal:
    return amount.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


@dataclass(frozen=True)
class Invoice:
    gig_id: uuid.UUID
    issued_at: datetime
    currency: str

    #: What the client paid, in total. VAT-inclusive where VAT applies - the
    #: client agreed one price and VAT is broken out of it, never added on.
    client_total: Decimal

    platform_retained: Decimal
    pro_raww: Decimal
    client_raww: Decimal
    pro_cash: Decimal

    retained_percent: int
    pro_raww_percent: int
    client_credit_percent: int

    #: How many photographs the client actually selected. None when no
    #: selection was ever submitted - which is not zero, and must not render
    #: as zero on a completed job.
    photos_delivered: int | None

    #: False when this gig predates the stamped rates and the split above was
    #: reconstructed from the current policy rather than read from the record.
    rates_were_stamped: bool

    def reconciles(self) -> bool:
        return (
            self.platform_retained + self.pro_raww + self.pro_cash + self.client_raww
            == self.client_total
        )


def photos_delivered_for(db: Session, gig: Gig) -> int | None:
    """How many photographs the client chose.

    None rather than zero when nothing was submitted. A completed gig showing
    "0 photos delivered" is the same lie as a wallet showing EUR 0.00 for
    twenty finished jobs: the screen is honest and the number is not.
    """
    gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
    if gallery is None:
        return None

    selection = db.execute(
        select(ClientSelection)
        .where(
            ClientSelection.gallery_id == gallery.id,
            ClientSelection.status == SelectionStatus.submitted,
        )
        .order_by(ClientSelection.version.desc())
    ).scalars().first()
    if selection is None:
        return None

    return int(
        db.execute(
            select(func.count())
            .select_from(ClientSelectionItem)
            .where(ClientSelectionItem.selection_id == selection.id)
        ).scalar_one()
    )


@dataclass(frozen=True)
class InvoiceAmounts:
    """The money on one invoice, without the things that cost a query.

    Split out so the Wallet summary can total hundreds of gigs without a
    gallery lookup each - and, more importantly, so it totals the same
    arithmetic the invoice screen shows rather than a second implementation
    that agrees until one of them is edited.
    """

    gross: Decimal
    platform_retained: Decimal
    pro_raww: Decimal
    client_raww: Decimal
    pro_cash: Decimal
    retained_percent: int
    pro_raww_percent: int
    client_credit_percent: int
    rates_were_stamped: bool


def invoice_amounts(db: Session, gig: Gig) -> InvoiceAmounts:
    """What one gig's money divides into, from its own stamped rates."""
    gross = _q2(gig.amount_final or gig.amount_minimum)
    stamped = gig.retained_percent is not None and gig.pro_raww_percent is not None

    if stamped:
        retained_percent = int(gig.retained_percent)
        pro_raww_percent = int(gig.pro_raww_percent)
        client_credit_percent = int(gig.client_credit_percent or 0)
        platform_retained = _q2(gross * Decimal(retained_percent) / Decimal(100))
        pro_raww = _q2(gross * Decimal(pro_raww_percent) / Decimal(100))
        client_raww = _q2(gross * Decimal(client_credit_percent) / Decimal(100))
        # A remainder, for the same reason it is one in split_booking: the
        # lines have to sum back to what the client paid, exactly.
        pro_cash = _q2(gross - platform_retained - pro_raww - client_raww)
    else:
        split = split_booking(
            gross=gross,
            policy=ensure_default_platform_fee_policy(db),
            client_credit_percent=0,
        )
        retained_percent = split.retained_percent
        pro_raww_percent = split.pro_raww_percent
        client_credit_percent = split.client_credit_percent
        platform_retained = split.platform_retained
        pro_raww = split.pro_raww
        client_raww = split.client_raww
        pro_cash = split.pro_cash

    return InvoiceAmounts(
        gross=gross,
        platform_retained=platform_retained,
        pro_raww=pro_raww,
        client_raww=client_raww,
        pro_cash=pro_cash,
        retained_percent=retained_percent,
        pro_raww_percent=pro_raww_percent,
        client_credit_percent=client_credit_percent,
        rates_were_stamped=stamped,
    )


def build_invoice(db: Session, gig: Gig) -> Invoice:
    """One gig's invoice: its money, plus what it cost a query to know."""
    amounts = invoice_amounts(db, gig)
    return Invoice(
        gig_id=gig.id,
        # The shoot's own date where it has one. `created_at` is when the
        # booking was accepted, which is not when the work happened.
        issued_at=gig.scheduled_end or gig.scheduled_start or gig.created_at,
        currency=gig.currency or "EUR",
        client_total=amounts.gross,
        platform_retained=amounts.platform_retained,
        pro_raww=amounts.pro_raww,
        client_raww=amounts.client_raww,
        pro_cash=amounts.pro_cash,
        retained_percent=amounts.retained_percent,
        pro_raww_percent=amounts.pro_raww_percent,
        client_credit_percent=amounts.client_credit_percent,
        photos_delivered=photos_delivered_for(db, gig),
        rates_were_stamped=amounts.rates_were_stamped,
    )


@dataclass(frozen=True)
class InvoiceSummary:
    """Every completed gig a photographer has been paid for, totalled.

    Built by adding up the same `invoice_amounts` each invoice screen shows,
    rather than by a SQL aggregate over the gig table. An aggregate would be
    faster and would be a second implementation of the split - the two would
    agree until somebody edited one, and the disagreement would appear as a
    Wallet total that does not match the invoices behind it.
    """

    bookings: int
    gross: Decimal
    platform_fees: Decimal
    pro_raww: Decimal
    client_raww: Decimal
    pro_cash: Decimal

    #: None rather than zero when there are no bookings. A photographer with
    #: no completed work has no average, and rendering 0.00 would state one.
    average_gross: Decimal | None

    #: How many of these were reconstructed rather than read from stamped
    #: rates, so a total built mostly from reconstructions can say so.
    reconstructed: int


def summarise_invoices(db: Session, pro_user_id: uuid.UUID) -> InvoiceSummary:
    from app.models.gig import GigStatus

    gigs = db.execute(
        select(Gig).where(Gig.pro_user_id == pro_user_id, Gig.status == GigStatus.completed)
    ).scalars().all()

    zero = Decimal("0.00")
    totals = {"gross": zero, "platform_fees": zero, "pro_raww": zero, "client_raww": zero, "pro_cash": zero}
    reconstructed = 0

    for gig in gigs:
        amounts = invoice_amounts(db, gig)
        totals["gross"] += amounts.gross
        # The platform's whole take, which is what a photographer means by
        # "fees paid" - not just the part the platform keeps.
        totals["platform_fees"] += amounts.platform_retained + amounts.pro_raww
        totals["pro_raww"] += amounts.pro_raww
        totals["client_raww"] += amounts.client_raww
        totals["pro_cash"] += amounts.pro_cash
        if not amounts.rates_were_stamped:
            reconstructed += 1

    return InvoiceSummary(
        bookings=len(gigs),
        gross=_q2(totals["gross"]),
        platform_fees=_q2(totals["platform_fees"]),
        pro_raww=_q2(totals["pro_raww"]),
        client_raww=_q2(totals["client_raww"]),
        pro_cash=_q2(totals["pro_cash"]),
        average_gross=_q2(totals["gross"] / len(gigs)) if gigs else None,
        reconstructed=reconstructed,
    )
