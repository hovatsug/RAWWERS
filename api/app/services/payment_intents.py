from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal

import stripe
from sqlalchemy import select
from sqlalchemy.orm import Session

import uuid

from app.core.config import get_settings
from app.models.gig import Gig, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.services.stripe_service import map_intent_status, to_cents

settings = get_settings()


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
    payment_method_types: list[str] | None = None,
    return_url: str | None = None,
    amount_override: Decimal | None = None,
    extra_metadata: dict | None = None,
    kind: StripePaymentKind = StripePaymentKind.base,
):
    existing = db.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == kind)
    ).scalar_one_or_none()
    if existing:
        pi = stripe.PaymentIntent.retrieve(existing.stripe_payment_intent_id)
        return existing, pi

    payable_amount = amount_override if amount_override is not None else gig.amount_minimum
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

    pi = stripe.PaymentIntent.create(
        amount=to_cents(payable_amount),
        currency=gig.currency.lower(),
        payment_method_types=payment_method_types or ["card"],
        metadata=metadata,
        automatic_payment_methods={"enabled": True},
        idempotency_key=f"gig:{gig.id}:pi:{kind.value}",
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
