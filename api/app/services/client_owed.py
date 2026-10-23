"""Clients owed money, found rather than assumed.

Every path that lowers a price refunds the difference (price_reduction), and
a refund that fails raises "client owed" (refund reconciliation). This is
the net under both: any booking whose client has kept more than its current
price - paid, less what has gone back or is on its way - with no refund
covering the difference is raised on "Money to act on", so it can never sit
silently. The owner's test booking was exactly this: EUR 79.74 kept for a
EUR 52.43 price, and nothing anywhere said so.

Run every hour on beat, and once by hand after a release to catch bookings
from before it.
"""
from __future__ import annotations

from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.admin import MoneyAttentionItem
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.services.payment_intents import refundable_remaining
from app.services.photographer_money import final_price, points_paid

ZERO = Decimal("0.00")
KIND = "client_owed"
_BOOKING_KINDS = (StripePaymentKind.base, StripePaymentKind.difference)


def overpaid_by(db: Session, gig: Gig) -> Decimal:
    """What the client has kept paid beyond the booking's current price,
    counting refunds made and under way."""
    payments = db.execute(
        select(StripePayment).where(
            StripePayment.gig_id == gig.id, StripePayment.kind.in_(_BOOKING_KINDS), StripePayment.status == PaymentStatus.succeeded
        )
    ).scalars().all()
    kept = sum((refundable_remaining(db, p) for p in payments), ZERO) + points_paid(db, gig)
    return max(ZERO, (kept - final_price(gig)).quantize(Decimal("0.01")))


def raise_clients_owed(db: Session) -> int:
    """One open item per booking still owing its client. Returns how many
    were raised now."""
    candidates = db.execute(
        select(Gig).where(Gig.status.not_in((GigStatus.refunded, GigStatus.payment_pending, GigStatus.draft)))
    ).scalars().all()
    raised = 0
    for gig in candidates:
        owed = overpaid_by(db, gig)
        if owed <= ZERO:
            continue
        open_item = db.execute(
            select(MoneyAttentionItem.id).where(
                MoneyAttentionItem.kind == KIND, MoneyAttentionItem.gig_id == gig.id, MoneyAttentionItem.status == "open",
                MoneyAttentionItem.stripe_refund_id.is_(None),
            )
        ).first()
        if open_item:
            continue
        db.add(MoneyAttentionItem(
            kind=KIND, status="open", gig_id=gig.id, client_user_id=gig.client_user_id, amount=owed, currency=gig.currency,
            note=(f"The client has paid {owed} {gig.currency} more than this booking's price ({final_price(gig)}) "
                  "and no refund covers it. Refund it, or record why not."),
        ))
        raised += 1
    db.flush()
    return raised
