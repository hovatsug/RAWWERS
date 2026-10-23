"""A payment's refunds, reconciled with Stripe - the source of truth.

Every refund-related event Stripe sends only names the payment. The refunds
are then fetched from Stripe and our records brought into line with them,
so it does not matter which events arrive, in which order, or how often:

  - each refund has its own ledger line, referenced by the refund's id
    (charge.refunded carries no refund id on our API version; keying on the
    payment recorded only the first of several partial refunds);
  - our refund cases settle by refund id - admin ones never did, because
    nothing matched them;
  - a refund made outside our routes (the Stripe dashboard) is adopted as a
    refund case and flagged for an admin;
  - a refund that fails marks its case failed, lowers the payment's
    amount_refunded, reverses only that refund's ledger line, and raises a
    "client owed" item. It never brings back the booking or the earnings a
    refund ended: the money is still with us, and the client is owed it;
  - earnings are reduced by the share refunded; a booking refunded in full
    is settled once (full_refund.settle_full_refund).

reconcile_stuck_refund_cases is the safety net for cases no event settled.
"""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import stripe
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.constants import SYSTEM_USER_ID
from app.core.errors import APIError
from app.models.admin import MoneyAttentionItem, RefundCase, RefundCaseStatus, RefundPaymentScope
from app.models.gig import Gig, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.services import stripe_service  # noqa: F401 - sets the API key and version
from app.services.full_refund import is_fully_refunded, settle_full_refund
from app.services.payment_intents import hold_refund_slot
from app.services.photographer_money import record_gig_earnings

logger = logging.getLogger(__name__)

#: Every event Stripe sends about refunds. Each only tells us which payment
#: to reconcile; none is trusted for amounts or states.
REFUND_EVENT_TYPES = frozenset(
    {"charge.refunded", "charge.refund.updated", "refund.created", "refund.updated", "refund.failed"}
)
#: A case in flight this long with no settling event is fetched from Stripe.
STUCK_AFTER = timedelta(minutes=15)
EXTERNAL_SOURCE = "stripe_external"
_CENTS = Decimal("0.01")


def _amount(minor) -> Decimal:
    return (Decimal(int(minor or 0)) / 100).quantize(_CENTS)


def fetch_refunds(payment_intent_id: str) -> list:
    refunds = list(stripe.Refund.list(payment_intent=payment_intent_id, limit=100).auto_paging_iter())
    return sorted(refunds, key=lambda r: (r.get("created") or 0, r.get("id")))


def _case_for(db: Session, refund_id: str) -> RefundCase | None:
    return db.execute(
        select(RefundCase).where(RefundCase.meta["stripe_refund_id"].astext == refund_id)
    ).scalars().first()


def _ledger_line(db: Session, gig: Gig, entry_type: LedgerEntryType, refund_id: str) -> LedgerEntry | None:
    return db.execute(
        select(LedgerEntry).where(
            LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == entry_type, LedgerEntry.reference_id == refund_id
        )
    ).scalars().first()


def _adopt_legacy_line(db: Session, gig: Gig, payment: StripePayment, refund_id: str, amount: Decimal) -> bool:
    """Lines written before refunds had their own reference were keyed on
    the payment ("refund:<payment intent>"). One whose amount is this
    refund's becomes this refund's line, rather than a second one."""
    legacy = db.execute(
        select(LedgerEntry).where(
            LedgerEntry.gig_id == gig.id,
            LedgerEntry.entry_type == LedgerEntryType.refund_succeeded,
            LedgerEntry.reference_id == f"refund:{payment.stripe_payment_intent_id}",
            LedgerEntry.amount == -amount,
        )
    ).scalars().first()
    if legacy is None:
        return False
    legacy.reference_id = refund_id
    return True


def _add_line(db: Session, gig: Gig, entry_type: LedgerEntryType, refund_id: str, amount: Decimal, description: str) -> None:
    db.add(
        LedgerEntry(
            gig_id=gig.id,
            entry_type=entry_type,
            amount=amount,
            currency=gig.currency,
            description=description,
            reference_type="stripe_refund",
            reference_id=refund_id,
        )
    )
    db.flush()


def _attention(db: Session, *, kind: str, gig: Gig, case: RefundCase | None, refund_id: str, amount: Decimal, note: str) -> None:
    exists = db.execute(
        select(MoneyAttentionItem.id).where(MoneyAttentionItem.kind == kind, MoneyAttentionItem.stripe_refund_id == refund_id)
    ).first()
    if exists:
        return
    db.add(
        MoneyAttentionItem(
            kind=kind,
            status="open",
            gig_id=gig.id,
            client_user_id=gig.client_user_id,
            refund_case_id=case.id if case else None,
            stripe_refund_id=refund_id,
            amount=amount,
            currency=gig.currency,
            note=note,
        )
    )
    db.flush()


def _adopt(db: Session, payment: StripePayment, gig: Gig, refund, *, trigger: str) -> RefundCase | None:
    """A refund Stripe has that none of our routes asked for."""
    status = refund.get("status")
    amount = _amount(refund.get("amount"))
    case = RefundCase(
        gig_id=gig.id,
        requested_by_user_id=SYSTEM_USER_ID,
        payment_scope=RefundPaymentScope.booking_payment,
        reference_id=gig.id,
        stripe_payment_intent_id=payment.stripe_payment_intent_id,
        amount_authorized=payment.amount,
        amount_refunded=amount if status == "succeeded" else Decimal("0.00"),
        status=(
            RefundCaseStatus.refunded if status == "succeeded"
            else RefundCaseStatus.failed if status in ("failed", "canceled")
            else RefundCaseStatus.refund_initiated
        ),
        amount=amount,
        currency=payment.currency,
        reason="Refund made outside RAWWERS",
        meta={"source": EXTERNAL_SOURCE, "stripe_refund_id": refund.get("id"), "adopted_on": trigger},
    )
    try:
        hold_refund_slot(db, case)
    except APIError:
        # Another refund of ours is still in flight on this payment; this one
        # is adopted once one of them settles (the job reconciles again).
        logger.warning("refund_adoption_deferred", extra={"stripe_refund_id": refund.get("id")})
        return None
    _attention(
        db, kind="refund_outside_rawwers", gig=gig, case=case, refund_id=refund.get("id"), amount=amount,
        note="A refund was made in Stripe, not through RAWWERS. Check it was intended.",
    )
    return case


def reconcile_payment_refunds(db: Session, payment_intent_id: str, *, trigger: str) -> bool:
    """Bring a booking payment's refunds in line with Stripe. False when the
    payment intent is not a booking payment (prints, extras: their own path)."""
    from app.services.disputes import finalize_refund_case_failed, finalize_refund_case_success

    payment = db.execute(
        select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
    ).scalar_one_or_none()
    if payment is None:
        return False
    gig = db.get(Gig, payment.gig_id)
    if gig is None:
        return False

    back = Decimal("0.00")
    for refund in fetch_refunds(payment_intent_id):
        refund_id = refund.get("id")
        status = refund.get("status")
        amount = _amount(refund.get("amount"))
        case = _case_for(db, refund_id) or _adopt(db, payment, gig, refund, trigger=trigger)

        if status == "succeeded":
            back += amount
            if not _ledger_line(db, gig, LedgerEntryType.refund_succeeded, refund_id) and not _adopt_legacy_line(db, gig, payment, refund_id, amount):
                _add_line(db, gig, LedgerEntryType.refund_succeeded, refund_id, -amount, f"Stripe refund {refund_id}")
            if case is not None and case.status not in (RefundCaseStatus.refunded, RefundCaseStatus.succeeded):
                finalize_refund_case_success(db, stripe_refund_id=refund_id)
        elif status in ("failed", "canceled"):
            if case is not None and case.status != RefundCaseStatus.failed:
                finalize_refund_case_failed(db, stripe_refund_id=refund_id, reason=refund.get("failure_reason") or status)
            # Reverse that refund's line - only if it was ever written, and once.
            if _ledger_line(db, gig, LedgerEntryType.refund_succeeded, refund_id) and not _ledger_line(db, gig, LedgerEntryType.refund_failed, refund_id):
                _add_line(db, gig, LedgerEntryType.refund_failed, refund_id, amount, f"Stripe refund {refund_id} {status}")
            _attention(
                db, kind="client_owed", gig=gig, case=case, refund_id=refund_id, amount=amount,
                note=f"Refund {status} ({refund.get('failure_reason') or 'no reason given'}): the client has not been paid back.",
            )
        # pending / requires_action: in flight - nothing to settle yet.

    payment.amount_refunded = min(back, payment.amount)
    if payment.amount_refunded >= payment.amount:
        payment.status = PaymentStatus.refunded
    elif payment.status == PaymentStatus.refunded:
        payment.status = PaymentStatus.succeeded  # a refund failed: the money is still with us
    db.flush()

    if is_fully_refunded(db, gig):
        settle_full_refund(db, gig, reason=f"Refunded in full ({trigger})")
    else:
        # Earnings follow the booking's final price net of refunds - the one
        # function every earnings change goes through. A booking not yet
        # completed has none; completion reads the refunds then.
        record_gig_earnings(db, gig, lower_only=True)
    if back > 0:
        from app.services.proof_of_gigs import enqueue_raww_refund_reversal

        enqueue_raww_refund_reversal(db, gig_id=gig.id)
    db.flush()
    return True


def reconcile_stuck_refund_cases(db: Session, *, now: datetime | None = None, limit: int = 200) -> int:
    """Cases still in flight STUCK_AFTER after their last change, fetched
    from Stripe - for the event that never arrived. Returns how many
    payments were reconciled."""
    cutoff = (now or datetime.now(timezone.utc)) - STUCK_AFTER
    intents = db.execute(
        select(RefundCase.stripe_payment_intent_id)
        .where(
            RefundCase.status.in_([RefundCaseStatus.processing, RefundCaseStatus.refund_initiated]),
            RefundCase.stripe_payment_intent_id.is_not(None),
            RefundCase.updated_at < cutoff,
        )
        .distinct()
        .limit(limit)
    ).scalars().all()
    done = 0
    for payment_intent_id in intents:
        try:
            if reconcile_payment_refunds(db, payment_intent_id, trigger="reconcile_job"):
                done += 1
            db.commit()
        except Exception:
            db.rollback()
            logger.exception("refund_reconcile_failed", extra={"payment_intent_id": payment_intent_id})
    return done
