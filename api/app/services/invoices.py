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


def build_invoice(db: Session, gig: Gig) -> Invoice:
    """The invoice for one gig, from its own record wherever possible."""
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

    return Invoice(
        gig_id=gig.id,
        # The shoot's own date where it has one. `created_at` is when the
        # booking was accepted, which is not when the work happened.
        issued_at=gig.scheduled_end or gig.scheduled_start or gig.created_at,
        currency=gig.currency or "EUR",
        client_total=gross,
        platform_retained=platform_retained,
        pro_raww=pro_raww,
        client_raww=client_raww,
        pro_cash=pro_cash,
        retained_percent=retained_percent,
        pro_raww_percent=pro_raww_percent,
        client_credit_percent=client_credit_percent,
        photos_delivered=photos_delivered_for(db, gig),
        rates_were_stamped=stamped,
    )
