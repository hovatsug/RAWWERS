"""A photographer's money: one source of truth.

**What a booking earns.** Its final price net of refunds - never the sum of
the payments. The final price is what the client owes for what they chose
(`amount_final`, or the deposit when nothing was chosen); payments can exceed
it (a selection cheaper than the deposit) and refunds can bring it down. The
smaller of the two is what the booking earned, split by the invoice method
(`commission.split_with_rates`): 15% retained and 5% $RAWW credit, each
rounded on its own, the photographer's cash the remainder. The split is
stamped on the booking (`Gig.final_*`) and the earnings entry carries the
same numbers; the invoice and the "All time" card read the stamp. The deposit
fields (`amount_minimum`, `amount_platform_fee`, `amount_pro_gross`) are
history and never change.

Earnings used to be 80% of the sum of payments, created at completion and
never revisited: a client who paid EUR 79.74 and chose EUR 52.43 of photos
left the photographer credited EUR 63.79 instead of EUR 41.95, and a partial
refund before completion was ignored.

**The buckets.** From the earnings entries and the payouts allocated to
them:

    pending   entries still in the settlement delay
    on_hold   entries held (a dispute, an admin hold)
    requested asked for in a payout request not yet decided - out of
              available the moment it is asked for, back if it is rejected
    reserved  allocated to a payout approved or processing - not yet paid
    paid_out  allocated to a payout that was paid
    available what is left, which may be negative

    available + requested + reserved + paid_out + pending + on_hold == lifetime

Negative `available` is money paid out that a later refund took back. It is
never clamped here: admins see it as it is, and only the photographer's
screen shows `withdrawable` 0 with the `adjustment_owed`.

Every reader asks this module: the Wallet, the payout request limit, payout
approval (and so the transfer, which sends the approved amount).
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import ROUND_HALF_UP, Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.payouts import (
    EarningsEntryStatus,
    EarningsLedgerEntry,
    EarningsSourceType,
    PayoutAllocation,
    PayoutRequest,
    PayoutRequestStatus,
)
from app.services.commission import BookingSplit, split_with_rates

ZERO = Decimal("0.00")
_BOOKING_KINDS = (StripePaymentKind.base, StripePaymentKind.difference)
#: Payments whose money reached us, whatever has been refunded off them since.
_MONEY_RECEIVED = (PaymentStatus.succeeded, PaymentStatus.refunded, PaymentStatus.disputed)


def _q2(value) -> Decimal:
    return Decimal(str(value or 0)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


# --- one booking ----------------------------------------------------------------------------


def final_price(gig: Gig) -> Decimal:
    """What the client owes for what they chose: the selection's price once
    set, the deposit until then."""
    return _q2(gig.amount_final if gig.amount_final is not None else gig.amount_minimum)


def points_paid(db: Session, gig: Gig) -> Decimal:
    """What the client paid with reward points: the discount RAWWERS funds,
    applied to the booking's payment. Money towards the price like any
    other - leaving it out paid the photographer less for a points-assisted
    booking than for the same booking paid by card."""
    from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType

    total = db.execute(
        select(func.coalesce(func.sum(DiscountRedemption.discount_amount), 0)).where(
            DiscountRedemption.context_type == RedemptionContextType.gig_payment,
            DiscountRedemption.context_id == gig.id,
            DiscountRedemption.status == DiscountRedemptionStatus.applied,
        )
    ).scalar_one()
    return _q2(total)


def net_paid(db: Session, gig: Gig) -> Decimal:
    """Booking money received (base and difference, and reward points
    applied to it), less what went back."""
    payments = db.execute(
        select(StripePayment).where(
            StripePayment.gig_id == gig.id,
            StripePayment.kind.in_(_BOOKING_KINDS),
            StripePayment.status.in_(_MONEY_RECEIVED),
        )
    ).scalars().all()
    return _q2(sum(((p.amount or ZERO) - (p.amount_refunded or ZERO) for p in payments), ZERO) + points_paid(db, gig))


def earned_gross(db: Session, gig: Gig) -> Decimal:
    """The final price, or less if refunds brought the money below it."""
    return max(ZERO, min(final_price(gig), net_paid(db, gig)))


def booking_split(db: Session, gig: Gig, gross: Decimal) -> BookingSplit:
    """`gross` divided at the rates stamped on this booking when it was made
    (the policy's, for bookings made before rates were stamped)."""
    if gig.retained_percent is not None and gig.pro_raww_percent is not None:
        return split_with_rates(
            gross,
            retained_percent=int(gig.retained_percent),
            pro_raww_percent=int(gig.pro_raww_percent),
            client_credit_percent=int(gig.client_credit_percent or 0),
        )
    from app.services.payouts import ensure_default_platform_fee_policy

    policy = ensure_default_platform_fee_policy(db)
    return split_with_rates(
        gross, retained_percent=int(policy.retained_percent), pro_raww_percent=int(policy.pro_raww_percent), client_credit_percent=0
    )


def stamp_final_split(db: Session, gig: Gig) -> BookingSplit:
    """Compute the booking's earned split and stamp it on the booking."""
    split = booking_split(db, gig, earned_gross(db, gig))
    gig.final_gross = split.gross
    gig.final_platform_retained = split.platform_retained
    gig.final_pro_raww = split.pro_raww
    gig.final_client_raww = split.client_raww
    gig.final_pro_cash = split.pro_cash
    gig.final_stamped_at = datetime.now(timezone.utc)
    return split


def record_gig_earnings(db: Session, gig: Gig, *, lower_only: bool = False) -> EarningsLedgerEntry | None:
    """Bring a completed booking's earnings in line with what it earned.

    The one place booking earnings are written: at completion (both the
    selection path and the admin status route) and after every refund.
    Idempotent. A booking not yet completed has no earnings; one that earned
    nothing has its entry reversed. Nothing here un-reverses an entry: a
    reversed entry's amounts may follow the booking, but it stays reversed
    and out of every balance.

    `lower_only` is refund reconciliation's: a refund that failed puts money
    back with us, but it is owed to the client ("client owed"), not earned -
    so reconciliation may only ever lower earnings, never raise them.
    """
    from app.services.payouts import create_earnings_entry, refresh_earnings_balance_snapshot, reverse_earnings_entries_for_source

    entry = db.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
            EarningsLedgerEntry.source_id == gig.id,
            EarningsLedgerEntry.pro_user_id == gig.pro_user_id,
        )
    ).scalar_one_or_none()
    # Earnings are created when a booking completes; once they exist (some
    # paths created them before completion), they follow every change.
    if entry is None and gig.status != GigStatus.completed:
        return None
    split = booking_split(db, gig, earned_gross(db, gig))

    if lower_only and entry is not None and split.pro_cash >= entry.net_eur:
        return entry
    stamp_final_split(db, gig)
    if split.pro_cash <= ZERO:
        if entry is not None and entry.status != EarningsEntryStatus.reversed:
            reverse_earnings_entries_for_source(db, source_type=EarningsSourceType.gig_base, source_id=gig.id, reason="nothing_earned")
        return None
    if entry is None:
        return create_earnings_entry(
            db,
            pro_user_id=gig.pro_user_id,
            source_type=EarningsSourceType.gig_base,
            source_id=gig.id,
            gross_eur=split.gross,
            split=split,
            metadata={"gig_id": str(gig.id)},
        )
    fee = _q2(split.gross - split.pro_cash)
    if (entry.gross_eur, entry.platform_fee_eur, entry.net_eur) != (split.gross, fee, split.pro_cash):
        entry.gross_eur, entry.platform_fee_eur, entry.net_eur = split.gross, fee, split.pro_cash
        entry.updated_at = datetime.now(timezone.utc)
        db.flush()
        refresh_earnings_balance_snapshot(db, pro_user_id=gig.pro_user_id)
    return entry


# --- one photographer -----------------------------------------------------------------------


@dataclass(frozen=True)
class PhotographerMoney:
    lifetime: Decimal
    pending: Decimal
    on_hold: Decimal
    requested: Decimal
    reserved: Decimal
    paid_out: Decimal
    #: May be negative. Never clamped here.
    available: Decimal

    @property
    def withdrawable(self) -> Decimal:
        return max(ZERO, self.available)

    @property
    def adjustment_owed(self) -> Decimal:
        return max(ZERO, -self.available)


def photographer_money(db: Session, pro_user_id: uuid.UUID) -> PhotographerMoney:
    by_status = dict(
        db.execute(
            select(EarningsLedgerEntry.status, func.coalesce(func.sum(EarningsLedgerEntry.net_eur), 0))
            .where(EarningsLedgerEntry.pro_user_id == pro_user_id, EarningsLedgerEntry.status != EarningsEntryStatus.reversed)
            .group_by(EarningsLedgerEntry.status)
        ).all()
    )
    by_payout = dict(
        db.execute(
            select(PayoutRequest.status, func.coalesce(func.sum(PayoutAllocation.amount_eur), 0))
            .join(PayoutRequest, PayoutRequest.id == PayoutAllocation.payout_request_id)
            .where(PayoutRequest.pro_user_id == pro_user_id)
            .group_by(PayoutRequest.status)
        ).all()
    )
    requested = _q2(
        db.execute(
            select(func.coalesce(func.sum(PayoutRequest.amount_eur), 0)).where(
                PayoutRequest.pro_user_id == pro_user_id, PayoutRequest.status == PayoutRequestStatus.requested
            )
        ).scalar_one()
    )
    lifetime = _q2(sum((Decimal(str(v)) for v in by_status.values()), ZERO))
    pending = _q2(by_status.get(EarningsEntryStatus.pending, 0))
    on_hold = _q2(by_status.get(EarningsEntryStatus.held, 0))
    reserved = _q2(by_payout.get(PayoutRequestStatus.approved, 0)) + _q2(by_payout.get(PayoutRequestStatus.processing, 0))
    paid_out = _q2(by_payout.get(PayoutRequestStatus.paid, 0))
    return PhotographerMoney(
        lifetime=lifetime,
        pending=pending,
        on_hold=on_hold,
        requested=requested,
        reserved=_q2(reserved),
        paid_out=paid_out,
        available=_q2(lifetime - pending - on_hold - requested - reserved - paid_out),
    )
