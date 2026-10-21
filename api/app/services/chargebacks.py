"""Chargebacks, reconciled with Stripe's dispute - the source of truth.

Every charge.dispute.* event only names the dispute; the dispute is fetched
from Stripe and our records brought in line with it, so the order and number
of events cannot change the outcome. A chargeback needs no dispute record of
ours: it is the cardholder's bank, not our dispute flow.

The ledger mirrors the dispute's balance transactions, each line once:
  - funds withdrawn ("dispute"):   chargeback_opened -amount, chargeback_fee -fee
  - funds reinstated ("dispute_reversal", when won): chargeback_won +amount
    (Stripe keeps the fee even then: the reinstatement carries no fee back)
  - lost:                          chargeback_lost 0.00, the closing line

While open, the gig is `disputed` (it keeps its calendar time) and an admin
item carries the evidence deadline. Won: back to its status before the
dispute. Lost: the booking ends as `refunded` - the client has their money
back, through their bank - and its finals are revoked.

Interim policy for the beta (who bears a lost chargeback): the platform
absorbs it, recorded as the ledger lines above and an admin item for the
amount plus fee. The photographer's earnings are untouched, unless an admin
has recorded a photographer-fault finding on that booking - then they are
reversed.
"""
from __future__ import annotations

import logging
from datetime import datetime, timezone
from decimal import Decimal

import stripe
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.constants import SYSTEM_USER_ID
from app.models.admin import MoneyAttentionItem, ProFaultEvent
from app.models.gig import Gig, GigStatus, GigTransition, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.models.payouts import EarningsSourceType
from app.services import stripe_service  # noqa: F401 - sets the API key and version
from app.services.dispute_hold import enter_dispute, leave_dispute_without_refund
from app.services.full_refund import revoke_finals
from app.services.payouts import reverse_earnings_entries_for_source

logger = logging.getLogger(__name__)

CHARGEBACK_EVENT_TYPES = frozenset(
    {
        "charge.dispute.created",
        "charge.dispute.updated",
        "charge.dispute.funds_withdrawn",
        "charge.dispute.funds_reinstated",
        "charge.dispute.closed",
    }
)
#: Where a lost chargeback leaves the booking. `refunded`: it is over, and
#: the client has their money back - the same thing the apps already show
#: for a refund, so no new status reaches them. The ledger and the admin item
#: say it was a chargeback.
LOST_GIG_STATUS = GigStatus.refunded
_CLOSED = ("won", "lost", "warning_closed")


def _amount(minor) -> Decimal:
    return (Decimal(int(minor or 0)) / 100).quantize(Decimal("0.01"))


def _line(db: Session, gig: Gig, entry_type: LedgerEntryType, ref: str, amount: Decimal, description: str, *, legacy_ref: str | None = None) -> None:
    exists = db.execute(
        select(LedgerEntry).where(LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == entry_type, LedgerEntry.reference_id == ref)
    ).scalars().first()
    if exists:
        return
    if legacy_ref:
        # Written before, keyed on the dispute id: take it over.
        legacy = db.execute(
            select(LedgerEntry).where(
                LedgerEntry.gig_id == gig.id, LedgerEntry.entry_type == entry_type,
                LedgerEntry.reference_id == legacy_ref, LedgerEntry.amount == amount,
            )
        ).scalars().first()
        if legacy is not None:
            legacy.reference_id = ref
            return
    db.add(LedgerEntry(gig_id=gig.id, entry_type=entry_type, amount=amount, currency=gig.currency,
                       description=description, reference_type="stripe_dispute", reference_id=ref))
    db.flush()


def _item(db: Session, *, kind: str, gig: Gig, dispute_id: str) -> MoneyAttentionItem | None:
    return db.execute(
        select(MoneyAttentionItem).where(MoneyAttentionItem.kind == kind, MoneyAttentionItem.stripe_dispute_id == dispute_id)
    ).scalar_one_or_none()


def _raise_item(db: Session, *, kind: str, gig: Gig, dispute_id: str, amount: Decimal, note: str, due_at: datetime | None = None) -> None:
    if _item(db, kind=kind, gig=gig, dispute_id=dispute_id) is not None:
        return
    db.add(MoneyAttentionItem(kind=kind, status="open", gig_id=gig.id, client_user_id=gig.client_user_id,
                              stripe_dispute_id=dispute_id, amount=amount, currency=gig.currency, note=note, due_at=due_at))
    db.flush()


def _close_item(db: Session, *, kind: str, gig: Gig, dispute_id: str, note: str) -> None:
    item = _item(db, kind=kind, gig=gig, dispute_id=dispute_id)
    if item is not None and item.status == "open":
        item.status = "resolved"
        item.resolved_at = datetime.now(timezone.utc)
        item.note = f"{item.note or ''}\nClosed: {note}".strip()


def _at_fault(db: Session, gig: Gig) -> bool:
    return db.execute(
        select(ProFaultEvent.id).where(ProFaultEvent.pro_user_id == gig.pro_user_id, ProFaultEvent.gig_id == gig.id)
    ).first() is not None


def reconcile_chargeback(db: Session, dispute_id: str, *, trigger: str) -> bool:
    """Bring a chargeback's booking in line with Stripe's dispute. False when
    the disputed payment is not a booking payment of ours."""
    dispute = stripe.Dispute.retrieve(dispute_id, expand=["balance_transactions"])
    payment = db.execute(
        select(StripePayment).where(StripePayment.stripe_payment_intent_id == dispute.get("payment_intent"))
    ).scalar_one_or_none()
    if payment is None:
        return False
    gig = db.get(Gig, payment.gig_id)
    if gig is None:
        return False

    status = dispute.get("status")
    amount = _amount(dispute.get("amount"))
    settled = (gig.meta or {}).get("chargebacks_settled", {})

    if dispute_id not in settled:
        enter_dispute(db, gig, actor_user_id=SYSTEM_USER_ID, reason=f"Stripe chargeback opened ({dispute.get('reason') or 'no reason given'})")
        if payment.status in (PaymentStatus.succeeded, PaymentStatus.refunded):
            payment.status = PaymentStatus.disputed

    for txn in dispute.get("balance_transactions") or []:
        category = txn.get("reporting_category")
        if category == "dispute":
            _line(db, gig, LedgerEntryType.chargeback_opened, txn["id"], _amount(txn.get("amount")),
                  "Chargeback: funds withdrawn", legacy_ref=dispute_id)
            if txn.get("fee"):
                _line(db, gig, LedgerEntryType.chargeback_fee, f"{txn['id']}:fee", -_amount(txn["fee"]), "Chargeback: Stripe's dispute fee")
        elif category == "dispute_reversal":
            _line(db, gig, LedgerEntryType.chargeback_won, txn["id"], _amount(txn.get("amount")), "Chargeback won: funds reinstated")
            if txn.get("fee"):
                _line(db, gig, LedgerEntryType.chargeback_fee, f"{txn['id']}:fee", -_amount(txn["fee"]), "Chargeback won: fee movement")

    due_by = (dispute.get("evidence_details") or {}).get("due_by")
    due_at = datetime.fromtimestamp(due_by, timezone.utc) if due_by else None
    _raise_item(
        db, kind="chargeback_evidence_due", gig=gig, dispute_id=dispute_id, amount=amount, due_at=due_at,
        note=f"Chargeback ({dispute.get('reason') or 'no reason given'}): submit evidence in Stripe before the deadline, or it is lost by default.",
    )

    if status in _CLOSED and dispute_id not in settled:
        if status == "lost":
            fee = sum((_amount(t.get("fee")) for t in dispute.get("balance_transactions") or [] if t.get("reporting_category") == "dispute"), Decimal("0.00"))
            _line(db, gig, LedgerEntryType.chargeback_lost, dispute_id, Decimal("0.00"), "Chargeback lost: absorbed by the platform")
            if gig.status != LOST_GIG_STATUS:
                db.add(GigTransition(gig_id=gig.id, from_status=gig.status, to_status=LOST_GIG_STATUS, actor_user_id=SYSTEM_USER_ID,
                                     reason="Stripe chargeback lost: the client has their money back"))
                gig.status = LOST_GIG_STATUS
            revoke_finals(db, gig, reason="chargeback_lost")
            at_fault = _at_fault(db, gig)
            if at_fault:
                reverse_earnings_entries_for_source(db, source_type=EarningsSourceType.gig_base, source_id=gig.id, reason="chargeback_lost_at_fault")
            _raise_item(
                db, kind="chargeback_lost", gig=gig, dispute_id=dispute_id, amount=amount + fee,
                note=(
                    "Chargeback lost. The photographer was found at fault: their earnings for it are reversed."
                    if at_fault else
                    "Chargeback lost: absorbed by the platform (beta policy); the photographer's earnings are untouched."
                ),
            )
        else:  # won, or warning_closed - nothing taken for good
            leave_dispute_without_refund(db, gig, actor_user_id=SYSTEM_USER_ID, reason=f"Stripe chargeback {status}")
            if payment.status == PaymentStatus.disputed:
                payment.status = PaymentStatus.refunded if payment.amount_refunded >= payment.amount else PaymentStatus.succeeded
        _close_item(db, kind="chargeback_evidence_due", gig=gig, dispute_id=dispute_id, note=status)
        gig.meta = {**(gig.meta or {}), "chargebacks_settled": {**settled, dispute_id: status}}
    db.flush()
    return True
