from __future__ import annotations

from datetime import datetime, timezone
from decimal import ROUND_HALF_UP, Decimal

import stripe
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

import uuid

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import RefundCase, RefundCaseStatus
from app.models.gig import Gig, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.services.stripe_service import map_intent_status, to_cents

settings = get_settings()


_CENTS = Decimal("0.01")

#: A difference payment that has been created but not settled either way.
#: `failed` is here on purpose: a declined card leaves the PaymentIntent in
#: `requires_payment_method`, which is exactly the state a retry reuses.
_OPEN_PAYMENT_STATUSES = (PaymentStatus.pending, PaymentStatus.requires_action, PaymentStatus.failed)


def difference_owed(gig: Gig) -> Decimal:
    """What the curve says this booking owes beyond the deposit.

    Zero until a selection has been submitted, since `amount_final` is only
    set then, and zero when the selection is cheaper than the deposit - that
    does not refund, it just owes nothing.
    """
    if gig.amount_final is None:
        return Decimal("0.00")
    return max(Decimal("0.00"), (gig.amount_final - gig.amount_minimum).quantize(_CENTS, rounding=ROUND_HALF_UP))


def difference_paid(db: Session, gig: Gig) -> Decimal:
    """What has actually been collected against that, from settled payments.

    A sum, not an existence check. "A difference payment succeeded" and "the
    difference was paid" are different statements, and treating them as one
    is how a payment for 25 photographs came to unlock 30.
    """
    return sum(
        (p.amount for p in list_succeeded_payments_for_gig(db, gig.id, kinds=[StripePaymentKind.difference])),
        Decimal("0.00"),
    )


def base_payment_succeeded(db: Session, gig: Gig) -> bool:
    """Whether the deposit was actually collected.

    The selection quote's `amount_paid` is the gig's minimum, which assumes
    it was. Anything that releases work has to check rather than assume.
    """
    return bool(
        db.execute(
            select(StripePayment.id).where(
                StripePayment.gig_id == gig.id,
                StripePayment.kind == StripePaymentKind.base,
                StripePayment.status == PaymentStatus.succeeded,
            )
        ).first()
    )



def list_succeeded_payments_for_gig(
    db: Session, gig_id: uuid.UUID, kinds: list[StripePaymentKind] | None = None
) -> list[StripePayment]:
    """Oldest first - the order refunds should be applied in against a gig's payments.

    `kinds` restricts to specific StripePaymentKind values (e.g. base +
    difference, excluding extras which already get their own earnings
    entry from the upsell webhook path). Omit for all kinds - the
    default used by refund allocation, which legitimately spans all
    of them."""
    stmt = select(StripePayment).where(StripePayment.gig_id == gig_id, StripePayment.status == PaymentStatus.succeeded)
    if kinds is not None:
        stmt = stmt.where(StripePayment.kind.in_(kinds))
    return db.execute(stmt.order_by(StripePayment.created_at.asc())).scalars().all()


def total_succeeded_amount_for_gig(db: Session, gig_id: uuid.UUID) -> Decimal:
    return sum((p.amount for p in list_succeeded_payments_for_gig(db, gig_id)), Decimal("0.00"))


#: Refund cases whose money never moved and never will: their amount is
#: still refundable. Every other status is a refund made or under way.
REFUND_CASE_STATUSES_NOT_REFUNDING = (RefundCaseStatus.failed, RefundCaseStatus.cancelled, RefundCaseStatus.rejected)


def refunded_or_refunding(
    db: Session, payment_intent_id: str, *, payment_id: uuid.UUID | None = None, excluding: uuid.UUID | None = None
) -> Decimal:
    """Every refund made or under way against this payment intent. Admin
    refunds recorded before refund cases named their payment intent carry
    only the payment row's id in their metadata; give it, and they count."""
    matches = [RefundCase.stripe_payment_intent_id == payment_intent_id]
    if payment_id is not None:
        matches.append(RefundCase.meta["stripe_payment_id"].astext == str(payment_id))
    stmt = select(func.coalesce(func.sum(RefundCase.amount), 0)).where(
        or_(*matches), RefundCase.status.not_in(REFUND_CASE_STATUSES_NOT_REFUNDING)
    )
    if excluding is not None:
        stmt = stmt.where(RefundCase.id != excluding)
    return Decimal(db.execute(stmt).scalar_one()).quantize(_CENTS)


def refundable_remaining(db: Session, payment: StripePayment, *, excluding: uuid.UUID | None = None) -> Decimal:
    """What can still be refunded on this payment - never more than this."""
    already = refunded_or_refunding(db, payment.stripe_payment_intent_id, payment_id=payment.id, excluding=excluding)
    return max(Decimal("0.00"), payment.amount - already)


def allocate_refund_oldest_first(db: Session, payments: list[StripePayment], amount: Decimal) -> list[tuple[StripePayment, Decimal]]:
    """Split a refund across `payments` (already oldest-first), each capped
    at what is still refundable on it. Allocates at most the total left;
    the caller decides whether asking for more is an error or a cap."""
    remaining = amount
    allocation: list[tuple[StripePayment, Decimal]] = []
    for payment in payments:
        if remaining <= 0:
            break
        take = min(remaining, refundable_remaining(db, payment))
        if take > 0:
            allocation.append((payment, take))
            remaining -= take
    return allocation


def allocate_amount_oldest_first(payments: list[StripePayment], amount: Decimal) -> list[tuple[StripePayment, Decimal]]:
    """Split `amount` across `payments` (already oldest-first), each capped at its own amount."""
    remaining = amount
    allocation: list[tuple[StripePayment, Decimal]] = []
    for payment in payments:
        if remaining <= 0:
            break
        take = min(remaining, payment.amount)
        allocation.append((payment, take))
        remaining -= take
    return allocation


def create_or_get_gig_payment_intent(
    db: Session,
    gig: Gig,
    return_url: str | None = None,
    amount_override: Decimal | None = None,
    extra_metadata: dict | None = None,
    kind: StripePaymentKind = StripePaymentKind.base,
):
    if kind == StripePaymentKind.difference:
        return _reconcile_difference_intent(
            db, gig, amount=amount_override, return_url=return_url, extra_metadata=extra_metadata
        )

    existing = db.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == kind)
    ).scalar_one_or_none()
    if existing:
        pi = stripe.PaymentIntent.retrieve(existing.stripe_payment_intent_id)
        return existing, pi

    return _create_intent(
        db, gig, kind=kind, payable_amount=amount_override if amount_override is not None else gig.amount_minimum,
        return_url=return_url, extra_metadata=extra_metadata, idempotency_key=f"gig:{gig.id}:pi:{kind.value}",
    )


def _create_intent(
    db: Session,
    gig: Gig,
    *,
    kind: StripePaymentKind,
    payable_amount: Decimal,
    return_url: str | None,
    extra_metadata: dict | None,
    idempotency_key: str,
):
    return_url_value = return_url or f"{settings.app_public_url.rstrip('/')}/pay/return"
    metadata = {
        "gig_id": str(gig.id),
        "client_user_id": str(gig.client_user_id),
        "pro_user_id": str(gig.pro_user_id),
        "return_url": return_url_value,
        "kind": kind.value,
    }
    if extra_metadata:
        metadata.update(extra_metadata)

    # automatic_payment_methods only, never alongside payment_method_types:
    # Stripe rejects the combination outright ("You cannot enable
    # `automatic_payment_methods` and specify `payment_method_types`"), which
    # made every PaymentIntent creation in the product a 500.
    #
    # Automatic is the deliberate choice rather than card-only. Launching in
    # Europe, a hardcoded ["card"] excludes iDEAL, Bancontact, SEPA debit and
    # Multibanco - and Multibanco is a mainstream way to pay in Portugal.
    # Letting Stripe surface the right methods per region also means new
    # markets need no per-market list maintained here.
    pi = stripe.PaymentIntent.create(
        amount=to_cents(payable_amount),
        currency=gig.currency.lower(),
        metadata=metadata,
        automatic_payment_methods={"enabled": True},
        idempotency_key=idempotency_key,
    )

    payment = StripePayment(
        gig_id=gig.id,
        kind=kind,
        client_user_id=gig.client_user_id,
        status=PaymentStatus(map_intent_status(pi.status)),
        stripe_payment_intent_id=pi.id,
        stripe_customer_id=getattr(pi, "customer", None),
        amount=payable_amount,
        currency=gig.currency,
        last_error=None,
        meta={"created_from": "create_intent", "created_at": datetime.now(timezone.utc).isoformat()},
    )
    db.add(payment)
    db.add(
        LedgerEntry(
            gig_id=gig.id,
            entry_type=LedgerEntryType.payment_authorized,
            amount=Decimal("0.00"),
            currency=gig.currency,
            description=f"Stripe PaymentIntent created ({kind.value})",
            reference_type="stripe_payment_intent",
            reference_id=pi.id,
        )
    )
    db.flush()
    return payment, pi


def _reconcile_difference_intent(
    db: Session,
    gig: Gig,
    *,
    amount: Decimal | None,
    return_url: str | None,
    extra_metadata: dict | None,
):
    """The difference intent for what is owed *now*, never a stale one.

    This used to return whatever difference payment already existed for the
    gig, without looking at its amount. A client who submitted 25 photographs,
    left, and came back to submit 30 was handed the 25-photograph intent: the
    app quoted one price and Stripe charged another, and the booking then
    closed on a payment of the wrong size.

    What Stripe allows decides what is done with an unsettled intent. The
    rules below were verified against test mode rather than assumed:

      - `requires_payment_method` (fresh, or after a decline): the amount can
        be changed in place, and the client secret survives, so an app already
        holding it keeps a valid one.
      - `requires_action` / `requires_confirmation`: an amount change moves
        the intent to `requires_confirmation`, a state the payment sheet is not
        known to handle. It is cancelled and replaced instead.
      - `processing` / `succeeded`: not changeable, and not replaceable either
        - the money is moving. Refused, rather than starting a second charge.

    A replacement needs its own idempotency key: Stripe rejects a reused key
    with different parameters outright.
    """
    payable = (amount if amount is not None else difference_owed(gig) - difference_paid(db, gig)).quantize(
        _CENTS, rounding=ROUND_HALF_UP
    )
    if payable <= 0:
        raise APIError(code="invalid_state", message="Nothing is owed on this selection", status_code=409)
    target_cents = to_cents(payable)

    rows = db.execute(
        select(StripePayment)
        .where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference)
        .order_by(StripePayment.created_at.desc())
    ).scalars().all()
    open_row = next((r for r in rows if r.status in _OPEN_PAYMENT_STATUSES), None)

    if open_row is not None:
        pi = stripe.PaymentIntent.retrieve(open_row.stripe_payment_intent_id)
        status = getattr(pi, "status", None)

        if status in ("processing", "succeeded"):
            raise APIError(
                code="invalid_state",
                message="A payment for this selection is already being processed. Wait for it to clear.",
                status_code=409,
            )

        if status != "canceled":
            if getattr(pi, "amount", None) == target_cents:
                return open_row, pi

            if status == "requires_payment_method":
                pi = stripe.PaymentIntent.modify(
                    pi.id, amount=target_cents, **({"metadata": extra_metadata} if extra_metadata else {})
                )
                open_row.amount = payable
                open_row.last_error = None
                open_row.meta = {**open_row.meta, "reconciled_at": datetime.now(timezone.utc).isoformat()}
                db.flush()
                return open_row, pi

            stripe.PaymentIntent.cancel(pi.id)

        open_row.status = PaymentStatus.cancelled
        db.flush()

    key = f"gig:{gig.id}:pi:{StripePaymentKind.difference.value}"
    attempt = len(rows)
    return _create_intent(
        db,
        gig,
        kind=StripePaymentKind.difference,
        payable_amount=payable,
        return_url=return_url,
        extra_metadata=extra_metadata,
        idempotency_key=key if attempt == 0 else f"{key}:{attempt}",
    )
