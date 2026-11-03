"""The Stripe reconcile job: payments Stripe took that never reached us.

A payment is recorded here when Stripe's `payment_intent.succeeded`
webhook arrives. When it does not (an outage, a lost delivery, the dev
forwarder down), the client has been charged and the booking still reads
as unpaid until someone taps Pay again. This job closes that gap on its
own, every `stripe_reconcile_interval_seconds` (15 minutes):

1. Ours against Stripe. Every booking payment (`stripe_payment`) and
   extras purchase (`upsell_purchase`) not yet recorded as paid, created
   between `stripe_reconcile_lookback_hours` ago and
   `stripe_reconcile_min_age_seconds` ago (younger ones may still have
   their webhook on the way), is fetched from Stripe. A `succeeded` one is
   recorded through `payment_intents.apply_missed_success`: the webhook's
   own handler, idempotent, so the real event arriving later changes
   nothing. Anything else is left alone.
2. Stripe against ours. Every intent Stripe reports `succeeded` in the
   same window that no table of ours knows is money taken for nothing we
   can name.

What it cannot settle becomes a Money attention item, once per kind and
payment: `stripe_payment_unknown` (paid in Stripe, unknown to us),
`stripe_payment_unmatched` (ours, and Stripe has no such payment),
`stripe_success_not_recorded` (Stripe says paid, and the handler left our
row unpaid), `stripe_reconcile_error` (the attempt raised). A failure on
one payment does not stop the rest.

`stripe_reconcile_dry_run` only reports: the run is recorded with what it
would have done, and nothing else is written. Every run is recorded
(StripeReconcileRun) for the "last run" line on Money attention.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Iterable, Protocol

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.admin import MoneyAttentionItem, StripeReconcileRun
from app.models.gig import PaymentStatus, StripePayment
from app.services.payment_intents import apply_missed_success

settings = get_settings()
logger = logging.getLogger(__name__)

#: Our rows that are still waiting to be recorded as paid.
_UNPAID = (PaymentStatus.pending, PaymentStatus.requires_action)


class NoSuchPaymentIntent(Exception):
    """Stripe has no payment intent with this id."""


class StripeGateway(Protocol):
    def retrieve(self, payment_intent_id: str): ...

    def list_succeeded(self, since: datetime) -> Iterable: ...


class LiveStripe:
    """The real Stripe API."""

    def retrieve(self, payment_intent_id: str):
        import stripe

        try:
            return stripe.PaymentIntent.retrieve(payment_intent_id)
        except stripe.error.InvalidRequestError as exc:
            if getattr(exc, "code", None) == "resource_missing":
                raise NoSuchPaymentIntent(payment_intent_id) from exc
            raise

    def list_succeeded(self, since: datetime) -> Iterable:
        import stripe

        page = stripe.PaymentIntent.list(created={"gte": int(since.timestamp())}, limit=100)
        return (pi for pi in page.auto_paging_iter() if getattr(pi, "status", None) == "succeeded")


@dataclass
class _Unpaid:
    """One of our payments not yet recorded as paid."""

    payment_intent_id: str
    gig_id: object
    amount: Decimal
    currency: str
    is_paid: callable


def _our_unpaid(db: Session, since: datetime, until: datetime) -> list[_Unpaid]:
    from app.models.gallery import ProofGallery, UpsellPurchase, UpsellPurchaseStatus

    rows: list[_Unpaid] = []
    for p in db.execute(
        select(StripePayment).where(
            StripePayment.status.in_(_UNPAID), StripePayment.created_at >= since, StripePayment.created_at <= until
        )
    ).scalars():
        rows.append(_Unpaid(p.stripe_payment_intent_id, p.gig_id, p.amount, p.currency, lambda db, p=p: _refreshed(db, p).status == PaymentStatus.succeeded))
    for u, gig_id in db.execute(
        select(UpsellPurchase, ProofGallery.gig_id)
        .join(ProofGallery, ProofGallery.id == UpsellPurchase.gallery_id)
        .where(
            UpsellPurchase.status == UpsellPurchaseStatus.pending,
            UpsellPurchase.stripe_payment_intent_id.is_not(None),
            UpsellPurchase.created_at >= since,
            UpsellPurchase.created_at <= until,
        )
    ).all():
        rows.append(_Unpaid(u.stripe_payment_intent_id, gig_id, u.amount, u.currency, lambda db, u=u: _refreshed(db, u).status == UpsellPurchaseStatus.succeeded))
    return rows


def _refreshed(db: Session, row):
    db.refresh(row)
    return row


def _known(db: Session, payment_intent_id: str) -> bool:
    """Whether any table of ours holds this payment intent."""
    from app.models.client_rewards_pricing import ExtraImagePurchase
    from app.models.commerce import OrderPayment
    from app.models.gallery import UpsellPurchase
    from app.models.prints import PrintOrder

    for model in (StripePayment, UpsellPurchase, ExtraImagePurchase, OrderPayment, PrintOrder):
        if db.execute(select(model.id).where(model.stripe_payment_intent_id == payment_intent_id).limit(1)).first():
            return True
    return False


def _flag(db: Session, *, kind: str, payment_intent_id: str, amount: Decimal, currency: str, gig_id=None, note: str) -> bool:
    """One open item per kind and payment. Returns whether it is new."""
    existing = db.execute(
        select(MoneyAttentionItem.id).where(
            MoneyAttentionItem.kind == kind, MoneyAttentionItem.stripe_payment_intent_id == payment_intent_id
        )
    ).first()
    if existing:
        return False
    db.add(
        MoneyAttentionItem(
            kind=kind, status="open", gig_id=gig_id, stripe_payment_intent_id=payment_intent_id,
            amount=amount, currency=(currency or "EUR").upper(), note=note,
        )
    )
    db.flush()
    return True


def _cents(value) -> Decimal:
    return (Decimal(int(value or 0)) / Decimal("100")).quantize(Decimal("0.01"))


def _settle_one(db: Session, gateway: StripeGateway, row: _Unpaid, dry_run: bool) -> tuple[str, str]:
    """What Stripe says of one of our unpaid payments, recorded unless this
    is a dry run: (outcome, note for an attention item)."""
    try:
        pi = gateway.retrieve(row.payment_intent_id)
    except NoSuchPaymentIntent:
        return "unmatched", "Recorded here as a payment, but Stripe has no such payment intent."
    if getattr(pi, "status", None) != "succeeded":
        return "unchanged", ""
    if dry_run:
        return "recorded", ""
    apply_missed_success(db, pi)
    if not row.is_paid(db):
        return "not_recorded", "Stripe says this payment succeeded; recording it left it unpaid here."
    logger.warning("stripe_reconcile_recorded", extra={"payment_intent_id": row.payment_intent_id})
    return "recorded", ""


def run(db: Session, *, gateway: StripeGateway | None = None, now: datetime | None = None, dry_run: bool | None = None) -> StripeReconcileRun:
    now = now or datetime.now(timezone.utc)
    dry_run = settings.stripe_reconcile_dry_run if dry_run is None else dry_run
    record = StripeReconcileRun(started_at=now, dry_run=dry_run, checked=0, recorded=0, flagged=0, details=[])
    db.add(record)
    db.flush()
    if gateway is None:
        if not settings.stripe_secret_key:
            record.error = "stripe_not_configured"
            record.finished_at = datetime.now(timezone.utc)
            db.flush()
            return record
        gateway = LiveStripe()

    since = now - timedelta(hours=settings.stripe_reconcile_lookback_hours)
    until = now - timedelta(seconds=settings.stripe_reconcile_min_age_seconds)
    details: list[dict] = []

    def note(action: str, payment_intent_id: str, **extra) -> None:
        details.append({"action": action, "payment_intent_id": payment_intent_id, **extra})

    def flag(kind: str, row_pi: str, amount: Decimal, currency: str, gig_id, text: str) -> None:
        if dry_run:
            note(f"would_flag_{kind.removeprefix('stripe_payment_').removeprefix('stripe_')}", row_pi)
            record.flagged += 1
            return
        if _flag(db, kind=kind, payment_intent_id=row_pi, amount=amount, currency=currency, gig_id=gig_id, note=text):
            note(f"flagged_{kind}", row_pi)
            record.flagged += 1

    try:
        # 1. Ours against Stripe. Each payment in its own savepoint, so one
        # that fails is rolled back alone and the rest go on.
        for row in _our_unpaid(db, since, until):
            record.checked += 1
            savepoint = db.begin_nested()
            try:
                outcome = _settle_one(db, gateway, row, dry_run)
                savepoint.commit()
            except Exception as exc:
                savepoint.rollback()
                logger.exception("stripe_reconcile_payment_failed", extra={"payment_intent_id": row.payment_intent_id})
                outcome = ("error", f"Checking this payment against Stripe failed: {type(exc).__name__}.")
            kind, text = outcome
            if kind == "recorded":
                note("would_record" if dry_run else "recorded", row.payment_intent_id)
                record.recorded += 1
            elif kind == "unmatched":
                flag("stripe_payment_unmatched", row.payment_intent_id, row.amount, row.currency, row.gig_id, text)
            elif kind == "not_recorded":
                flag("stripe_success_not_recorded", row.payment_intent_id, row.amount, row.currency, row.gig_id, text)
            elif kind == "error":
                flag("stripe_reconcile_error", row.payment_intent_id, row.amount, row.currency, row.gig_id, text)

        # 2. Stripe against ours.
        for pi in gateway.list_succeeded(since):
            if _known(db, pi.id):
                continue
            flag("stripe_payment_unknown", pi.id, _cents(getattr(pi, "amount_received", None) or getattr(pi, "amount", 0)),
                 getattr(pi, "currency", "eur"), None, "Stripe took this payment; nothing here knows it.")
    except Exception as exc:
        logger.exception("stripe_reconcile_failed")
        record.error = f"{type(exc).__name__}: {exc}"[:500]

    record.details = details
    record.finished_at = datetime.now(timezone.utc)
    db.flush()
    return record


def last_run(db: Session) -> StripeReconcileRun | None:
    return db.execute(select(StripeReconcileRun).order_by(StripeReconcileRun.started_at.desc()).limit(1)).scalar_one_or_none()
