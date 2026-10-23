"""Lowering what a client owes after they paid - one function for every path.

`apply_price_reduction` does three things in one transaction:

1. sets the booking's final price (`Gig.amount_final`) - the number the
   pricing code computed, never arithmetic of its own;
2. brings the photographer's earnings and $RAWW in line with it
   (photographer_money.record_gig_earnings, and a proportional $RAWW
   reversal);
3. refunds the client everything they paid beyond the new price, through
   the reconciled refund path: refund cases held before Stripe is asked, one
   in flight per payment, the most recent payment first, settled by refund
   reconciliation (ledger line per refund id, `amount_refunded`).

Keyed by the event that caused it: the same reduction applied twice is
recorded, and refunded, once. A refund that cannot be issued never leaves a
silent state - the reduction stands and a "client owed" item says so.

Every reduction carries a breakdown by reason code (admin-editable data);
only a reason that `may_carry_fault` can later have a photographer-fault
finding recorded against it. A reduction never changes the booking's status
and never decides fault.

The paths:
- the client selects fewer photos than they paid for (submit_selection):
  split into what was not delivered (`photographer_non_delivery`) and what
  the client chose not to take (`client_selected_fewer`);
- an admin reduces the price by hand (`POST /v1/admin/gigs/{id}/price-reductions`).
"""
from __future__ import annotations

import logging
import uuid
from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal

import stripe
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.constants import SYSTEM_USER_ID
from app.core.errors import APIError
from app.models.admin import MoneyAttentionItem, RefundCase, RefundCaseStatus, RefundPaymentScope
from app.models.gig import Gig, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.models.price_reduction import DeliveryReviewPolicy, PriceReduction, PriceReductionReason
from app.services.payment_intents import hold_refund_slot, refundable_remaining
from app.services.photographer_money import earned_gross, final_price, net_paid, photographer_money, points_paid, record_gig_earnings

logger = logging.getLogger(__name__)
ZERO = Decimal("0.00")
_BOOKING_KINDS = (StripePaymentKind.base, StripePaymentKind.difference)

#: Seeded once; an admin edits the rows from then on.
DEFAULT_REASONS = (
    ("photographer_non_delivery", "Photos not delivered", "Fewer photos were delivered than your package included.", True, 10),
    ("client_selected_fewer", "Client selected fewer photos", "You chose fewer photos than your deposit covered.", False, 20),
    ("mutual_agreement", "Agreed lower price", "You and your photographer agreed a lower price.", False, 30),
    ("admin_goodwill", "Goodwill", "A goodwill reduction from RAWWERS.", False, 40),
    ("dispute_resolution", "Dispute resolution", "The price was lowered to resolve a dispute.", False, 50),
)


def _q2(value) -> Decimal:
    return Decimal(str(value or 0)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def ensure_default_reasons(db: Session) -> None:
    for code, label, wording, fault, order in DEFAULT_REASONS:
        if db.get(PriceReductionReason, code) is None:
            db.add(PriceReductionReason(code=code, label=label, client_wording=wording, may_carry_fault=fault, sort_order=order))
    db.flush()


def delivery_review_policy(db: Session) -> DeliveryReviewPolicy:
    row = db.get(DeliveryReviewPolicy, 1)
    if row is None:
        row = DeliveryReviewPolicy(id=1)
        db.add(row)
        db.flush()
    return row


@dataclass(frozen=True)
class ReductionLine:
    reason_code: str
    amount: Decimal


# --- the selection path ---------------------------------------------------------------------


def selection_reduction_lines(db: Session, gig: Gig, *, charged: Decimal, delivered: int, included: int, new_total: Decimal) -> list[ReductionLine]:
    """What came off `charged` (what the client paid for: the deposit and any
    difference), by reason. The part between the price of what was included
    and the price of what was delivered was not delivered; the rest, down to
    the selection's price, the client chose not to take. Prices from the same
    curve the selection quote charges by."""
    from app.services.package_pricing import MINIMUM_PHOTOS, compute_package_total

    lines: list[ReductionLine] = []
    floor = new_total
    if delivered < included:
        delivered_price = max(
            new_total,
            _q2(compute_package_total(db, niche_id=gig.niche_id, entry_rate=gig.entry_rate, photo_count=max(delivered, MINIMUM_PHOTOS))),
        )
        if charged > delivered_price:
            lines.append(ReductionLine("photographer_non_delivery", _q2(charged - delivered_price)))
            charged = delivered_price
    if charged > floor:
        lines.append(ReductionLine("client_selected_fewer", _q2(charged - floor)))
    return lines


def flag_short_delivery(db: Session, gig: Gig, *, delivered: int, included: int, amount: Decimal) -> bool:
    """An admin review item when the gallery held fewer photos than were
    included, by at least the policy's threshold. A flag for a person - never
    a finding or a strike. Once per booking."""
    if included - delivered < delivery_review_policy(db).shortfall_min_photos:
        return False
    exists = db.execute(
        select(MoneyAttentionItem.id).where(MoneyAttentionItem.kind == "photographer_short_delivery", MoneyAttentionItem.gig_id == gig.id)
    ).first()
    if exists:
        return False
    db.add(MoneyAttentionItem(
        kind="photographer_short_delivery", status="open", gig_id=gig.id, client_user_id=gig.client_user_id,
        amount=amount, currency=gig.currency,
        note=(f"Delivered {delivered} of {included} included photos; the client was refunded for the difference. "
              "Review it: record a fault finding only if the photographer was at fault."),
    ))
    db.flush()
    return True


# --- the one function -----------------------------------------------------------------------


def _chargeback_open(db: Session, gig: Gig) -> bool:
    disputed = db.execute(
        select(StripePayment.id).where(StripePayment.gig_id == gig.id, StripePayment.status == PaymentStatus.disputed)
    ).first()
    evidence_due = db.execute(
        select(MoneyAttentionItem.id).where(
            MoneyAttentionItem.gig_id == gig.id, MoneyAttentionItem.kind == "chargeback_evidence_due", MoneyAttentionItem.status == "open"
        )
    ).first()
    return bool(disputed or evidence_due)


def refund_owed(db: Session, gig: Gig, new_final: Decimal) -> Decimal:
    """What the client has paid, less what has gone back or is on its way,
    beyond `new_final`."""
    payments = db.execute(
        select(StripePayment).where(
            StripePayment.gig_id == gig.id, StripePayment.kind.in_(_BOOKING_KINDS), StripePayment.status == PaymentStatus.succeeded
        )
    ).scalars().all()
    # Points paid count towards the price but cannot be refunded to a card:
    # the refund is what the card payments hold beyond the new price.
    kept = sum((refundable_remaining(db, p) for p in payments), ZERO)
    return max(ZERO, min(_q2(kept), _q2(kept + points_paid(db, gig) - new_final)))


def preview_price_reduction(db: Session, gig: Gig, *, new_final: Decimal) -> dict:
    """What a reduction to `new_final` would do, without doing it."""
    from app.services.photographer_money import booking_split

    new_final = _q2(new_final)
    refund = refund_owed(db, gig, new_final)
    current = booking_split(db, gig, earned_gross(db, gig))
    # After the refund the money kept is the new price, or less if refunds
    # already took it below.
    after = booking_split(db, gig, max(ZERO, min(new_final, net_paid(db, gig))))
    return {
        "from_amount": final_price(gig),
        "to_amount": new_final,
        "client_refund": refund,
        "photographer_cash_before": current.pro_cash,
        "photographer_cash_after": after.pro_cash,
        "currency": gig.currency,
    }


def apply_price_reduction(
    db: Session,
    gig: Gig,
    *,
    new_final: Decimal,
    lines: list[ReductionLine],
    note: str,
    source: str,
    key: str,
    actor_user_id: uuid.UUID | None,
    from_amount: Decimal | None = None,
) -> PriceReduction:
    existing = db.execute(select(PriceReduction).where(PriceReduction.idempotency_key == key)).scalar_one_or_none()
    if existing is not None:
        return existing

    ensure_default_reasons(db)
    new_final = _q2(new_final)
    from_amount = _q2(from_amount if from_amount is not None else final_price(gig))
    if not (note or "").strip():
        raise APIError(code="validation_error", message="A reduction needs a note saying why", status_code=422)
    if not lines:
        raise APIError(code="validation_error", message="A reduction needs at least one reason", status_code=422)
    for line in lines:
        reason = db.get(PriceReductionReason, line.reason_code)
        if reason is None or not reason.is_active:
            raise APIError(code="validation_error", message=f"Unknown reason code: {line.reason_code}", status_code=422)
        if _q2(line.amount) <= ZERO:
            raise APIError(code="validation_error", message="Every reason line needs an amount above zero", status_code=422)
    if new_final < ZERO or new_final >= from_amount:
        raise APIError(code="validation_error", message="A reduction must lower the price, and not below zero", status_code=422)
    if _q2(sum((_q2(line.amount) for line in lines), ZERO)) != _q2(from_amount - new_final):
        raise APIError(code="validation_error", message=f"The reasons must add up to the reduction, {_q2(from_amount - new_final)}", status_code=422)
    if _chargeback_open(db, gig):
        raise APIError(
            code="chargeback_open",
            message="This booking has an open chargeback: the bank is deciding the money. Reduce the price once it closes.",
            status_code=409,
        )

    gig.amount_final = new_final
    reduction = PriceReduction(
        gig_id=gig.id, idempotency_key=key, source=source, from_amount=from_amount, to_amount=new_final,
        lines=[{"reason_code": line.reason_code, "amount": str(_q2(line.amount))} for line in lines],
        currency=gig.currency, note=note.strip(), actor_user_id=actor_user_id,
    )
    db.add(reduction)
    db.flush()

    reduction.refund_amount = _refund_beyond(db, gig, reduction)
    record_gig_earnings(db, gig)
    adjust_raww_to_value(db, gig)
    _flag_adjustment_owed(db, gig, reduction)

    from app.services.audit import add_admin_audit_log

    add_admin_audit_log(
        db,
        actor_user_id=actor_user_id or SYSTEM_USER_ID,
        target_type="gig",
        target_id=str(gig.id),
        action="price_reduced",
        reason=reduction.note,
        metadata={
            "reduction_id": str(reduction.id),
            "source": source,
            "from": str(from_amount),
            "to": str(new_final),
            "lines": reduction.lines,
            "client_refund": str(reduction.refund_amount),
        },
    )
    db.flush()
    return reduction


def _refund_beyond(db: Session, gig: Gig, reduction: PriceReduction) -> Decimal:
    """Refund what the client paid beyond the new price, most recent payment
    first. Returns what was asked of Stripe; anything that could not be is a
    "client owed" item, never silence."""
    owed = refund_owed(db, gig, reduction.to_amount)
    if owed <= ZERO:
        return ZERO
    payments = db.execute(
        select(StripePayment)
        .where(StripePayment.gig_id == gig.id, StripePayment.kind.in_(_BOOKING_KINDS), StripePayment.status == PaymentStatus.succeeded)
        .order_by(StripePayment.created_at.desc())
    ).scalars().all()
    reasons = ", ".join(line["reason_code"] for line in reduction.lines)
    remaining, asked, order = owed, ZERO, []
    for payment in payments:
        take = min(remaining, refundable_remaining(db, payment))
        if take <= ZERO:
            continue
        remaining = _q2(remaining - take)
        order.append({"payment_intent": payment.stripe_payment_intent_id, "amount": str(take)})
        case = RefundCase(
            gig_id=gig.id, requested_by_user_id=reduction.actor_user_id or SYSTEM_USER_ID,
            payment_scope=RefundPaymentScope.booking_payment, reference_id=gig.id,
            stripe_payment_intent_id=payment.stripe_payment_intent_id, amount_authorized=payment.amount,
            status=RefundCaseStatus.processing, amount=take, currency=gig.currency,
            reason=f"price_reduction: {reasons}", admin_note=reduction.note,
            meta={"source": "price_reduction", "reduction_id": str(reduction.id), "stripe_payment_id": str(payment.id),
                  "lines": reduction.lines},
        )
        try:
            hold_refund_slot(db, case)
        except APIError:
            _client_owed(db, gig, reduction, take, "another refund on this payment is still under way")
            continue
        try:
            refund = stripe.Refund.create(
                payment_intent=payment.stripe_payment_intent_id,
                amount=int((take * 100).quantize(Decimal("1"))),
                metadata={"gig_id": str(gig.id), "reduction_id": str(reduction.id), "reasons": reasons},
                idempotency_key=f"price-reduction:{reduction.id}:{payment.id}",
            )
        except Exception as exc:  # noqa: BLE001 - any failure leaves the client owed, visibly
            logger.warning("price_reduction_refund_failed", extra={"gig_id": str(gig.id), "reduction_id": str(reduction.id)})
            case.status = RefundCaseStatus.failed
            _client_owed(db, gig, reduction, take, f"Stripe refused the refund ({str(exc)[:120]})")
            continue
        case.meta = {**case.meta, "stripe_refund_id": refund.id}
        db.add(LedgerEntry(
            gig_id=gig.id, entry_type=LedgerEntryType.refund_initiated, amount=ZERO, currency=gig.currency,
            description=f"Price reduced ({reasons}): refund initiated", reference_type="stripe_refund", reference_id=refund.id,
        ))
        asked = _q2(asked + take)
    if remaining > ZERO:
        _client_owed(db, gig, reduction, remaining, "nothing was left to refund on the booking's payments")
    meta_order = {"refund_order": "most recent payment first", "refunds": order}
    from app.services.audit import add_admin_audit_log

    add_admin_audit_log(
        db, actor_user_id=reduction.actor_user_id or SYSTEM_USER_ID, target_type="gig", target_id=str(gig.id),
        action="price_reduction_refund", reason=reduction.note, metadata={"reduction_id": str(reduction.id), **meta_order},
    )
    db.flush()
    return asked


def _client_owed(db: Session, gig: Gig, reduction: PriceReduction, amount: Decimal, why: str) -> None:
    db.add(MoneyAttentionItem(
        kind="client_owed", status="open", gig_id=gig.id, client_user_id=gig.client_user_id, amount=_q2(amount),
        currency=gig.currency,
        note=f"Price reduced ({', '.join(line['reason_code'] for line in reduction.lines)}) but the refund could not be issued: {why}.",
    ))
    db.flush()


def _flag_adjustment_owed(db: Session, gig: Gig, reduction: PriceReduction) -> None:
    """Earnings already paid out that the reduction took back: the
    photographer's balance goes negative (a receivable against future
    earnings) and an admin is told. Nothing is collected here."""
    money = photographer_money(db, gig.pro_user_id)
    if money.available >= ZERO:
        return
    db.add(MoneyAttentionItem(
        kind="photographer_adjustment_owed", status="open", gig_id=gig.id, amount=money.adjustment_owed, currency=gig.currency,
        note=(f"Price reduced after the photographer was paid out: they now owe {money.adjustment_owed}, "
              f"taken from their next earnings (reduction {reduction.id})."),
    ))
    db.flush()


# --- $RAWW ----------------------------------------------------------------------------------


def adjust_raww_to_value(db: Session, gig: Gig) -> int:
    """Each $RAWW mint for this booking brought down to the share of its
    value the booking still has (its final price net of refunds), reversing
    only the difference. Never mints more. Returns $RAWW reversed."""
    from app.models.proof_of_gigs import RawwMintEvent, RawwMintEventStatus
    from app.services.proof_of_gigs import raww_partially_reversed

    value = earned_gross(db, gig)
    reversed_now = 0
    from sqlalchemy import and_, or_

    from app.models.review import Review

    review_ids = db.execute(select(Review.id).where(Review.gig_id == gig.id)).scalars().all()
    mints = db.execute(
        select(RawwMintEvent).where(
            RawwMintEvent.status == RawwMintEventStatus.minted,
            or_(
                and_(RawwMintEvent.reference_type == "gig", RawwMintEvent.reference_id == gig.id),
                and_(RawwMintEvent.reference_type == "review", RawwMintEvent.reference_id.in_(review_ids or [uuid.uuid4()])),
            ),
        )
    ).scalars().all()
    for mint in mints:
        minted_on = _q2((mint.multiplier_snapshot or {}).get("eur_value") or 0)
        if minted_on <= ZERO or value >= minted_on or mint.raww_awarded <= 0:
            continue
        keep = int((Decimal(mint.raww_awarded) * value / minted_on).to_integral_value(rounding="ROUND_FLOOR"))
        due = mint.raww_awarded - keep - raww_partially_reversed(db, mint)
        if due <= 0:
            continue
        from app.core.config import get_settings
        from app.models.reward import RewardEntryType
        from app.services.rewards import add_reward_entry

        entry = add_reward_entry(
            db, user_id=mint.pro_user_id, amount=-due, entry_type=RewardEntryType.adjustment,
            reference_type="raww_mint_partial_reversal", reference_id=f"{mint.id}:{value}",
            metadata={"gig_id": str(gig.id), "minted_on_eur": str(minted_on), "value_now_eur": str(value)},
            min_balance_floor=get_settings().reward_balance_floor,
        )
        if entry is not None:
            reversed_now += due
    db.flush()
    return reversed_now
