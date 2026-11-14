"""A payout's Stripe transfers: one per client payment that funds it, each
sent with that payment's charge as `source_transaction`
(docs/MULTI_CURRENCY.md 10.4, batch M7).

- The payout keeps its allocations (oldest available earnings first). At
  execution they are grouped by the payment behind each earning, and one
  transfer per payment is sent, so a transfer never fails for lack of
  balance in the platform's account: Stripe sends it from that charge.
- A booking's earning is funded by its booking payments (the base payment,
  then any difference payment); an add-on's by its own payment. An earning
  with no payment of ours behind it (a legacy upsell, Studioverse, an
  adjustment) is sent without `source_transaction`, only when the
  platform's available balance in that currency covers it; otherwise it
  waits (`waiting_funds`) and the admin is told.
- The invariant, before every transfer: what is sent from a charge never
  exceeds the charge's amount less what was refunded from it. The
  photographer's share is always below the charge, so a breach is a bug:
  it stops the payout before anything is sent.
- The payout is paid when all its transfers are. A transfer that failed is
  retried alone (`retry_payout_transfers`); one already paid is never sent
  again. While any part of a payout has gone, or waits for funds, the
  payout stays `processing`, so its money stays reserved and cannot be
  asked for twice.
"""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import stripe
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.gig import PaymentStatus, StripePayment, StripePaymentKind
from app.models.payouts import (
    EarningsLedgerEntry,
    EarningsSourceType,
    PayoutAllocation,
    PayoutRequest,
    PayoutTransfer,
    PayoutTransferStatus,
)

logger = logging.getLogger(__name__)

ZERO = Decimal("0.00")
#: Transfers that hold a charge's money: sent, being sent, or waiting.
_COUNTED = (PayoutTransferStatus.pending, PayoutTransferStatus.paid, PayoutTransferStatus.waiting_funds)
_BOOKING_KINDS = (StripePaymentKind.base, StripePaymentKind.difference)
_WENT_THROUGH = (PaymentStatus.succeeded, PaymentStatus.refunded, PaymentStatus.disputed)


class TransferInvariantBreach(Exception):
    """More would be sent from a charge than is left of it."""


def _q2(value) -> Decimal:
    return Decimal(str(value or 0)).quantize(Decimal("0.01"))


def _cents(amount: Decimal) -> int:
    return int((Decimal(amount) * Decimal("100")).quantize(Decimal("1")))


def funding_payments(db: Session, entry: EarningsLedgerEntry) -> list[StripePayment]:
    """The client payments an earning's money came from, in the order they
    are drawn on."""
    if entry.source_type == EarningsSourceType.gig_base:
        payments = db.execute(
            select(StripePayment)
            .where(
                StripePayment.gig_id == entry.source_id,
                StripePayment.kind.in_(_BOOKING_KINDS),
                StripePayment.status.in_(_WENT_THROUGH),
            )
            .order_by(StripePayment.created_at.asc(), StripePayment.id.asc())
        ).scalars().all()
        # The earning's own payment first, then the rest (a difference payment).
        return sorted(payments, key=lambda p: p.id != entry.stripe_payment_id)
    if entry.stripe_payment_id is not None:
        payment = db.get(StripePayment, entry.stripe_payment_id)
        return [payment] if payment is not None and payment.status in _WENT_THROUGH else []
    return []


def sent_from(db: Session, payment_id: uuid.UUID, *, exclude_payout: uuid.UUID | None = None) -> Decimal:
    """What transfers have taken, or are about to take, from a payment's charge."""
    stmt = select(func.coalesce(func.sum(PayoutTransfer.amount), 0)).where(
        PayoutTransfer.stripe_payment_id == payment_id, PayoutTransfer.status.in_(_COUNTED)
    )
    if exclude_payout is not None:
        stmt = stmt.where(PayoutTransfer.payout_request_id != exclude_payout)
    return _q2(db.execute(stmt).scalar_one())


def left_on_charge(payment: StripePayment) -> Decimal:
    return _q2(Decimal(payment.amount) - Decimal(payment.amount_refunded or 0))


def plan_transfers(db: Session, payout: PayoutRequest) -> list[PayoutTransfer]:
    """The payout's transfers, made once from its allocations. Raises
    TransferInvariantBreach, writing nothing, if a payment's charge cannot
    cover what its earnings would send."""
    existing = transfers_of(db, payout.id)
    if existing:
        return existing

    allocations = db.execute(
        select(PayoutAllocation)
        .where(PayoutAllocation.payout_request_id == payout.id)
        .order_by(PayoutAllocation.created_at.asc(), PayoutAllocation.id.asc())
    ).scalars().all()
    by_payment: dict[uuid.UUID | None, Decimal] = {}
    room: dict[uuid.UUID, Decimal] = {}
    for alloc in allocations:
        entry = db.get(EarningsLedgerEntry, alloc.earnings_ledger_entry_id)
        remaining = _q2(alloc.amount)
        funders = funding_payments(db, entry) if entry is not None else []
        if not funders:
            by_payment[None] = _q2(by_payment.get(None, ZERO) + remaining)
            continue
        for payment in funders:
            if payment.id not in room:
                room[payment.id] = _q2(left_on_charge(payment) - sent_from(db, payment.id))
            take = min(room[payment.id], remaining)
            if take <= ZERO:
                continue
            room[payment.id] = _q2(room[payment.id] - take)
            by_payment[payment.id] = _q2(by_payment.get(payment.id, ZERO) + take)
            remaining = _q2(remaining - take)
            if remaining <= ZERO:
                break
        if remaining > ZERO:
            raise TransferInvariantBreach(
                f"earning {alloc.earnings_ledger_entry_id}: {remaining} {payout.currency} more than its payments' charges hold"
            )

    rows = []
    # Funded first; the unfunded part, if any, last.
    for payment_id, amount in sorted(by_payment.items(), key=lambda kv: (kv[0] is None, str(kv[0]))):
        if amount <= ZERO:
            continue
        row = PayoutTransfer(
            payout_request_id=payout.id,
            stripe_payment_id=payment_id,
            currency=payout.currency,
            amount=amount,
            status=PayoutTransferStatus.pending,
            attempts=0,
        )
        db.add(row)
        rows.append(row)
    db.flush()
    return rows


def transfers_of(db: Session, payout_id: uuid.UUID) -> list[PayoutTransfer]:
    rows = db.execute(select(PayoutTransfer).where(PayoutTransfer.payout_request_id == payout_id)).scalars().all()
    return sorted(rows, key=lambda r: (r.stripe_payment_id is None, str(r.stripe_payment_id), r.created_at))


def _charge_id(db: Session, payment: StripePayment) -> str:
    """The payment's charge: recorded by the payment webhook, else read once
    from Stripe (payments from before it was recorded) and kept."""
    if payment.stripe_charge_id:
        return payment.stripe_charge_id
    intent = stripe.PaymentIntent.retrieve(payment.stripe_payment_intent_id)
    charge = intent.get("latest_charge") if hasattr(intent, "get") else getattr(intent, "latest_charge", None)
    if isinstance(charge, dict) or (charge is not None and not isinstance(charge, str)):
        charge = charge.get("id") if hasattr(charge, "get") else getattr(charge, "id", None)
    if not charge:
        raise RuntimeError(f"no charge found for payment {payment.id}")
    payment.stripe_charge_id = str(charge)
    db.flush()
    return payment.stripe_charge_id


def _transfer_group(payout: PayoutRequest) -> str:
    return f"payout:{payout.id}"


def _already_sent(payout: PayoutRequest, row: PayoutTransfer) -> str | None:
    """On a retry: a transfer Stripe made although we recorded a failure (a
    timeout after it went). Never sent twice."""
    found = stripe.Transfer.list(transfer_group=_transfer_group(payout), limit=100)
    for transfer in getattr(found, "data", None) or (found.get("data", []) if hasattr(found, "get") else []):
        metadata = transfer.get("metadata") if hasattr(transfer, "get") else getattr(transfer, "metadata", None)
        if (metadata or {}).get("payout_transfer_id") == str(row.id) and not (
            transfer.get("reversed") if hasattr(transfer, "get") else getattr(transfer, "reversed", False)
        ):
            return transfer.get("id") if hasattr(transfer, "get") else getattr(transfer, "id", None)
    return None


def _available_balance_cents(currency: str) -> int:
    balance = stripe.Balance.retrieve()
    available = balance.get("available") if hasattr(balance, "get") else getattr(balance, "available", [])
    for item in available or []:
        cur = item.get("currency") if hasattr(item, "get") else getattr(item, "currency", None)
        if str(cur).lower() == currency.lower():
            return int(item.get("amount") if hasattr(item, "get") else getattr(item, "amount", 0))
    return 0


def send_transfers(db: Session, payout: PayoutRequest, *, destination: str) -> None:
    """Send every transfer of the payout not yet sent. Each row ends paid,
    failed or waiting_funds; nothing raises out of here except a breach,
    which the caller turns into a failed payout before anything is sent."""
    from app.core.sentry import capture_message

    for row in transfers_of(db, payout.id):
        if row.status in (PayoutTransferStatus.paid, PayoutTransferStatus.reversed):
            continue
        now = datetime.now(timezone.utc)
        try:
            if row.attempts > 0:
                found = _already_sent(payout, row)
                if found:
                    row.status, row.stripe_transfer_id, row.failure_reason, row.updated_at = (
                        PayoutTransferStatus.paid, found, None, now
                    )
                    continue
            kwargs = dict(
                amount=_cents(row.amount),
                currency=row.currency.lower(),
                destination=destination,
                transfer_group=_transfer_group(payout),
                metadata={
                    "payout_request_id": str(payout.id),
                    "pro_user_id": str(payout.pro_user_id),
                    "payout_transfer_id": str(row.id),
                    "stripe_payment_id": str(row.stripe_payment_id or ""),
                },
            )
            if row.stripe_payment_id is not None:
                payment = db.get(StripePayment, row.stripe_payment_id)
                if payment is None or payment.currency != row.currency:
                    raise TransferInvariantBreach(f"payment {row.stripe_payment_id} missing or in another currency")
                # The invariant, at the moment of sending: refunds since the
                # plan may have taken the charge's money.
                if _q2(sent_from(db, payment.id, exclude_payout=payout.id) + row.amount) > left_on_charge(payment):
                    raise TransferInvariantBreach(
                        f"payment {payment.id}: {row.amount} {row.currency} would exceed what is left of its charge"
                    )
                row.stripe_charge_id = _charge_id(db, payment)
                kwargs["source_transaction"] = row.stripe_charge_id
            elif _available_balance_cents(row.currency) < _cents(row.amount):
                row.status = PayoutTransferStatus.waiting_funds
                row.failure_reason = f"waiting for {row.currency} funds: no payment funds this part and the balance is short"
                row.updated_at = now
                logger.error("payout_transfer_waiting_funds", extra={"payout_request_id": str(payout.id), "currency": row.currency})
                capture_message(
                    "Payout waiting for funds",
                    tags={"payout_request_id": str(payout.id), "currency": row.currency},
                    extra={"amount": str(row.amount)},
                )
                continue
            row.attempts += 1
            transfer = stripe.Transfer.create(idempotency_key=_idempotency_key_for_send(payout, row), **kwargs)
            row.status = PayoutTransferStatus.paid
            row.stripe_transfer_id = getattr(transfer, "id", None) or (transfer.get("id") if hasattr(transfer, "get") else None)
            row.failure_reason = None
            row.updated_at = now
        except TransferInvariantBreach:
            raise
        except Exception as exc:  # a Stripe error: this transfer alone failed
            row.status = PayoutTransferStatus.failed
            row.failure_reason = str(exc)[:500]
            row.updated_at = now
    db.flush()


def _idempotency_key_for_send(payout: PayoutRequest, row: PayoutTransfer) -> str:
    """`payout-transfer:<payout>:<payment>` the first time. A retry after a
    recorded failure is a new request (Stripe keeps the first answer, an
    error included, for a day under one key); `_already_sent` has checked
    that the first did not in fact go. `attempts` was raised just before."""
    earlier = row.attempts - 1
    base = f"payout-transfer:{payout.id}:{row.stripe_payment_id or 'unfunded'}"
    return base if earlier == 0 else f"{base}:retry{earlier}"


def outcome(rows: list[PayoutTransfer]) -> str:
    """paid: every transfer went. failed: nothing went and nothing waits
    (the payout's money goes back to available, as before). processing:
    part went, or waits for funds (the money stays reserved)."""
    statuses = {r.status for r in rows}
    if rows and statuses == {PayoutTransferStatus.paid}:
        return "paid"
    if PayoutTransferStatus.paid in statuses or PayoutTransferStatus.waiting_funds in statuses:
        return "processing"
    return "failed"


def require_retryable(db: Session, payout: PayoutRequest) -> list[PayoutTransfer]:
    from app.models.payouts import PayoutRequestStatus

    rows = transfers_of(db, payout.id)
    if payout.status != PayoutRequestStatus.processing or not any(
        r.status in (PayoutTransferStatus.failed, PayoutTransferStatus.waiting_funds) for r in rows
    ):
        raise APIError(code="invalid_state", message="This payout has no failed or waiting transfer to retry", status_code=409)
    return rows
