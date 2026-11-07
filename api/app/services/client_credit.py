"""Client credit: its money rules, its marketing budget, and what the client
sees of it (owner's decisions, 2026-11-07).

- Client credit is RAWWERS's marketing cost. It buys content for RAWWERS's
  own advertising and is funded from the platform's retained share. The
  photographer's cash and 5% RAWW credit are always computed on the
  pre-discount price (photographer_money counts credit used as money paid
  towards the price), and nothing is transferred to the photographer as RAWW.
- Today its only use is a discount on a booking, at most
  `max_discount_percent` of the payment (admin setting, default 10).
- It is shown in euros: points / points_per_eur (100). Never called RAWW.
- Awards for marketing permissions draw on a monthly budget
  (`monthly_marketing_credit_budget_eur`, default 300; 0 means none). It
  counts credit awarded in the calendar month in Europe/London, checked
  under a lock on the settings row, so concurrent grants can never exceed
  it. Admins are told at 80% and at 100%, once each a month. The per-client
  monthly cap (3) and the per-grant amounts are unchanged.
- Credit used on a booking that is refunded goes back to the client
  (owner's decision, 2026-11-07): all of it on a full refund; on a partial
  refund the same share as the cash refunded, rounded down to the cent, so
  cash back plus credit back is the refunded share of the booking's value.
  Each return is its own ledger line, "Refunded credit", referenced by the
  booking and the refund (reference_type REFUND_REFERENCE), spendable like
  any credit and never counted against the marketing budget.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import ROUND_DOWN, ROUND_HALF_UP, Decimal
from zoneinfo import ZoneInfo

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.reward import ClientCreditSettings, DiscountRedemption, DiscountRedemptionStatus, RewardBalance, RewardEntryType, RewardLedgerEntry

REPORTING_TZ = ZoneInfo("Europe/London")
#: The reward ledger's reference for a marketing-permission credit.
MARKETING_REFERENCE = "marketing_consent"
#: The reward ledger's reference for credit given back on a refund:
#: reference_id "<gig id>:<stripe refund id>".
REFUND_REFERENCE = "booking_refund"


def settings(db: Session, *, lock: bool = False) -> ClientCreditSettings:
    query = select(ClientCreditSettings).where(ClientCreditSettings.id == 1)
    if lock:
        query = query.with_for_update()
    row = db.execute(query).scalar_one_or_none()
    if row is None:
        # Created with its defaults on first use; two requests doing so at
        # once is one row (the other's insert is ignored), never an error.
        from sqlalchemy.dialects.postgresql import insert

        db.execute(insert(ClientCreditSettings).values(id=1).on_conflict_do_nothing(index_elements=["id"]))
        row = db.execute(query).scalar_one()
    return row


def points_per_eur(db: Session) -> int:
    from app.services.rewards import _get_discount_conversion_settings

    return _get_discount_conversion_settings(db)[0]


def to_eur(points: int, per_eur: int) -> Decimal:
    return (Decimal(int(points)) / Decimal(per_eur)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def month_bounds(now: datetime | None = None) -> tuple[str, datetime, datetime]:
    """("2026-11", start, end) of the calendar month in Europe/London, in UTC."""
    local = (now or datetime.now(timezone.utc)).astimezone(REPORTING_TZ)
    start = local.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    end = start.replace(year=start.year + 1, month=1) if start.month == 12 else start.replace(month=start.month + 1)
    return f"{start.year:04d}-{start.month:02d}", start.astimezone(timezone.utc), end.astimezone(timezone.utc)


def awarded_eur(db: Session, now: datetime | None = None) -> Decimal:
    """Marketing credit awarded this month, net of nothing: what was given."""
    _key, start, end = month_bounds(now)
    points = db.execute(
        select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
            RewardLedgerEntry.reference_type == MARKETING_REFERENCE,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
            RewardLedgerEntry.created_at >= start,
            RewardLedgerEntry.created_at < end,
        )
    ).scalar_one()
    return to_eur(points, points_per_eur(db))


def budget_view(db: Session, now: datetime | None = None) -> dict:
    """The admin's month: budget, awarded, used at checkout, outstanding
    (all clients' unspent credit) and remaining."""
    key, start, end = month_bounds(now)
    row = settings(db)
    awarded = awarded_eur(db, now)
    used = db.execute(
        select(func.coalesce(func.sum(DiscountRedemption.discount_amount), 0)).where(
            DiscountRedemption.status == DiscountRedemptionStatus.applied,
            DiscountRedemption.updated_at >= start,
            DiscountRedemption.updated_at < end,
        )
    ).scalar_one()
    outstanding_points = db.execute(select(func.coalesce(func.sum(RewardBalance.balance), 0)).where(RewardBalance.balance > 0)).scalar_one()
    returned_points = db.execute(
        select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
            RewardLedgerEntry.reference_type == REFUND_REFERENCE,
            RewardLedgerEntry.created_at >= start,
            RewardLedgerEntry.created_at < end,
        )
    ).scalar_one()
    budget = Decimal(row.monthly_marketing_credit_budget_eur)
    return {
        "month": key,
        "budget_eur": budget,
        "awarded_eur": awarded,
        "used_eur": Decimal(used).quantize(Decimal("0.01")),
        "returned_on_refunds_eur": to_eur(returned_points, points_per_eur(db)),
        "outstanding_eur": to_eur(outstanding_points, points_per_eur(db)),
        "remaining_eur": max(Decimal("0.00"), budget - awarded),
        "max_discount_percent": row.max_discount_percent,
    }


def budget_left_for(db: Session, amount_points: int, now: datetime | None = None) -> bool:
    """Whether an award of `amount_points` fits this month's budget now."""
    budget = Decimal(settings(db).monthly_marketing_credit_budget_eur)
    if budget <= 0:
        return False
    return awarded_eur(db, now) + to_eur(amount_points, points_per_eur(db)) <= budget


def award_marketing_credit(
    db: Session, *, client_user_id: uuid.UUID, amount_points: int, gig_id: uuid.UUID, metadata: dict, balance_floor: int
) -> RewardLedgerEntry | None:
    """Award a marketing-permission credit if the month's budget allows it.
    Under the settings row's lock: two grants at once are counted one after
    the other, so the budget is never exceeded. None when it does not fit."""
    from app.services.rewards import add_reward_entry

    row = settings(db, lock=True)
    if not budget_left_for(db, amount_points):
        return None
    entry = add_reward_entry(
        db,
        user_id=client_user_id,
        amount=amount_points,
        entry_type=RewardEntryType.earn,
        reference_type=MARKETING_REFERENCE,
        reference_id=str(gig_id),
        metadata=metadata,
        min_balance_floor=balance_floor,
    )
    if entry is None:
        return None
    _alert_admins_if_due(db, row)
    notify_credit_earned(db, entry)
    return entry


def _alert_admins_if_due(db: Session, row: ClientCreditSettings, now: datetime | None = None) -> None:
    from app.core.config import get_settings
    from app.services.notifications import enqueue_notification

    budget = Decimal(row.monthly_marketing_credit_budget_eur)
    if budget <= 0:
        return
    key, _start, _end = month_bounds(now)
    awarded = awarded_eur(db, now)
    for level, attr in ((100, "alerted_100_month"), (80, "alerted_80_month")):
        if awarded * 100 >= budget * level and getattr(row, attr) != key:
            setattr(row, attr, key)
            for admin_id in get_settings().admin_user_id_set():
                enqueue_notification(
                    db,
                    user_id=admin_id,
                    notification_type="admin.marketing_budget",
                    payload={
                        "title": f"Marketing credit budget at {level}%",
                        "body": f"€{awarded} of €{budget} awarded this month ({key})."
                        + (" No more credit is awarded until next month." if level == 100 else ""),
                    },
                    reference_type="marketing_budget",
                    reference_id=f"{key}:{level}",
                    dedupe_key=f"marketing-budget:{key}:{level}:{admin_id}",
                )
    db.flush()


def notify_credit_earned(db: Session, entry: RewardLedgerEntry) -> None:
    """"You earned €1.00 credit", once per award however often its event
    is delivered."""
    from app.services.notifications import enqueue_notification

    euros = to_eur(entry.amount, points_per_eur(db))
    enqueue_notification(
        db,
        user_id=entry.user_id,
        notification_type="reward.credit_earned",
        payload={
            "title": f"You earned €{euros} credit",
            "body": "Use it on your next booking.",
            "action": {"label": "See my credit", "url": "/account/credit"},
        },
        reference_type=entry.reference_type,
        reference_id=entry.reference_id,
        dedupe_key=f"credit-earned:{entry.reference_type}:{entry.reference_id}:{entry.user_id}",
    )


def max_discount_percent(db: Session) -> int:
    return int(settings(db).max_discount_percent)


# --- checkout ------------------------------------------------------------------------------


def open_redemption(db: Session, *, client_user_id: uuid.UUID, gig_id: uuid.UUID) -> DiscountRedemption | None:
    from app.models.reward import RedemptionContextType

    return db.execute(
        select(DiscountRedemption).where(
            DiscountRedemption.user_id == client_user_id,
            DiscountRedemption.context_type == RedemptionContextType.gig_payment,
            DiscountRedemption.context_id == gig_id,
            DiscountRedemption.status.in_([DiscountRedemptionStatus.reserved, DiscountRedemptionStatus.applied]),
        )
    ).scalar_one_or_none()


def balance_points(db: Session, user_id: uuid.UUID) -> int:
    row = db.get(RewardBalance, user_id)
    return int(row.balance) if row else 0


def checkout_preview(db: Session, *, client_user_id: uuid.UUID, gig) -> dict:
    """What credit would take off this booking's payment: the smaller of the
    client's credit and the cap. Changes nothing."""
    per_eur = points_per_eur(db)
    price = Decimal(gig.amount_minimum)
    existing = open_redemption(db, client_user_id=client_user_id, gig_id=gig.id)
    cap = (price * Decimal(max_discount_percent(db)) / Decimal("100")).quantize(Decimal("0.01"))
    balance = to_eur(balance_points(db, client_user_id), per_eur)
    discount = Decimal(existing.discount_amount) if existing else min(balance, cap, price)
    discount = max(Decimal("0.00"), discount)
    return {
        "balance_eur": balance,
        "discount_eur": discount,
        "price_eur": price,
        "total_eur": price - discount,
        "max_discount_percent": max_discount_percent(db),
        "applied": existing is not None,
        "currency": gig.currency,
    }


def set_for_payment(db: Session, *, client_user_id: uuid.UUID, gig, use_credit: bool | None) -> tuple[Decimal, bool]:
    """Use the client's credit on this booking's payment, or stop using it,
    and return what is left to pay, and whether credit is involved at all.
    None leaves it as it is. Reserved now,
    applied when the payment succeeds, given back if it is cancelled or the
    booking lapses unpaid (services/rewards)."""
    from app.core.errors import APIError
    from app.models.reward import RedemptionContextType
    from app.services.rewards import release_redemption_for_context, reserve_points_for_discount

    price = Decimal(gig.amount_minimum)
    existing = open_redemption(db, client_user_id=client_user_id, gig_id=gig.id)
    if use_credit is True and existing is None:
        points = balance_points(db, client_user_id)
        if points > 0:
            try:
                existing = reserve_points_for_discount(
                    db, user_id=client_user_id, context_type=RedemptionContextType.gig_payment, context_id=gig.id,
                    points=points, payment_amount=price, currency=gig.currency, metadata={"source": "client_booking_pay"},
                )
            except APIError:
                existing = None  # too little credit for a cent off: pay in full
    elif use_credit is False and existing is not None and existing.status == DiscountRedemptionStatus.reserved:
        release_redemption_for_context(db, RedemptionContextType.gig_payment, gig.id, reason="not_used_at_checkout")
        existing = None
    discount = Decimal(existing.discount_amount) if existing else Decimal("0.00")
    # Whether credit is in play: only then is the charge brought to the
    # discounted amount; otherwise the intent is left exactly as before.
    involved = use_credit is not None or existing is not None
    return max(Decimal("0.01"), price - discount), involved


# --- refunds -------------------------------------------------------------------------------


def returned_on_refunds_points(db: Session, gig_id: uuid.UUID) -> int:
    """Credit already given back for this booking's refunds."""
    return int(
        db.execute(
            select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
                RewardLedgerEntry.reference_type == REFUND_REFERENCE,
                RewardLedgerEntry.reference_id.like(f"{gig_id}:%"),
            )
        ).scalar_one()
    )


def return_credit_on_refunds(db: Session, *, gig) -> list[RewardLedgerEntry]:
    """Give back the credit used on this booking for its refunds.

    The share is the cash refunded over the cash paid, across the booking's
    payments; full when it is all refunded. A price reduction's refund is
    not counted: the price itself came down by that amount, all of it paid
    in cash, so cash back is already the whole reduction (the credit stays
    used on the lower price), and the reduction is taken off the cash paid.
    Each refund's return is the cumulative share owed so far less what was
    already given back, so repeated or reordered events never give twice;
    a refund that failed gives nothing. Not subject to a rewards freeze: it
    is the client's own credit coming back."""
    from app.models.admin import RefundCase
    from app.models.gig import LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
    from app.models.reward import RedemptionContextType
    from app.services.rewards import _get_or_create_reward_balance_locked

    redemption = db.execute(
        select(DiscountRedemption).where(
            DiscountRedemption.context_type == RedemptionContextType.gig_payment,
            DiscountRedemption.context_id == gig.id,
            DiscountRedemption.status == DiscountRedemptionStatus.applied,
        )
    ).scalar_one_or_none()
    if redemption is None or redemption.points_spent <= 0:
        return []
    cash_paid = db.execute(
        select(func.coalesce(func.sum(StripePayment.amount), 0)).where(
            StripePayment.gig_id == gig.id,
            StripePayment.kind.in_([StripePaymentKind.base, StripePaymentKind.difference]),
            StripePayment.status.in_([PaymentStatus.succeeded, PaymentStatus.refunded, PaymentStatus.disputed]),
        )
    ).scalar_one()
    lines = db.execute(
        select(LedgerEntry).where(LedgerEntry.gig_id == gig.id, LedgerEntry.reference_type == "stripe_refund")
        .order_by(LedgerEntry.created_at, LedgerEntry.id)
    ).scalars().all()
    failed = {line.reference_id for line in lines if line.entry_type == LedgerEntryType.refund_failed}
    succeeded = [(line.reference_id, -Decimal(line.amount)) for line in lines
                 if line.entry_type == LedgerEntryType.refund_succeeded and line.reference_id not in failed]
    reduction_ids = {
        (case.meta or {}).get("stripe_refund_id")
        for case in db.execute(select(RefundCase).where(RefundCase.gig_id == gig.id)).scalars()
        if (case.meta or {}).get("source") == "price_reduction"
    }
    base = Decimal(cash_paid) - sum((amount for rid, amount in succeeded if rid in reduction_ids), Decimal("0.00"))
    refunds = [(rid, amount) for rid, amount in succeeded if rid not in reduction_ids]
    if base <= 0 or not refunds:
        return []
    balance = _get_or_create_reward_balance_locked(db, redemption.user_id)
    per_eur = points_per_eur(db)
    returned = returned_on_refunds_points(db, gig.id)  # under the balance lock
    written: list[RewardLedgerEntry] = []
    refunded = Decimal("0.00")
    for refund_id, amount in refunds:
        refunded += amount
        reference = f"{gig.id}:{refund_id}"
        exists = db.execute(
            select(RewardLedgerEntry.id).where(
                RewardLedgerEntry.reference_type == REFUND_REFERENCE, RewardLedgerEntry.reference_id == reference
            )
        ).first()
        if exists:
            continue
        if refunded >= base:
            owed = int(redemption.points_spent)
        else:
            euros = (Decimal(redemption.discount_amount) * refunded / base).quantize(Decimal("0.01"), rounding=ROUND_DOWN)
            owed = min(int(redemption.points_spent), int(euros * per_eur))
        give = owed - returned
        if give <= 0:
            continue
        returned += give
        balance.balance = int(balance.balance) + give
        balance.updated_at = datetime.now(timezone.utc)
        entry = RewardLedgerEntry(
            user_id=redemption.user_id, entry_type=RewardEntryType.adjustment, rule_code=None, amount=give,
            balance_after=balance.balance, reference_type=REFUND_REFERENCE, reference_id=reference,
            meta={"kind": "refunded_credit", "gig_id": str(gig.id), "stripe_refund_id": refund_id,
                  "refunded_redemption_id": str(redemption.id)},
        )
        db.add(entry)
        db.flush()
        written.append(entry)
    return written


# --- what the client sees ------------------------------------------------------------------


def history(db: Session, client_user_id: uuid.UUID, *, limit: int = 100) -> list[dict]:
    """The client's credit, newest first, each entry with the kind the app
    words it by and, for a marketing permission, the photographer's first name."""
    from app.models.admin import ProProfile
    from app.models.gig import Gig

    per_eur = points_per_eur(db)
    rows = db.execute(
        select(RewardLedgerEntry)
        .where(RewardLedgerEntry.user_id == client_user_id)
        .order_by(RewardLedgerEntry.created_at.desc())
        .limit(limit)
    ).scalars().all()
    out = []
    for row in rows:
        first_name = None
        if row.reference_type == MARKETING_REFERENCE and row.amount > 0:
            kind = "marketing_permission"
            gig = db.get(Gig, uuid.UUID(row.reference_id)) if row.reference_id else None
            profile = db.get(ProProfile, gig.pro_user_id) if gig else None
            name = (profile.display_name or "").strip() if profile else ""
            first_name = name.split()[0] if name else None
        elif row.reference_type == REFUND_REFERENCE:
            kind = "refunded_credit"
        elif row.entry_type == RewardEntryType.spend:
            kind = "used_on_booking"
        elif row.entry_type == RewardEntryType.adjustment and (row.meta or {}).get("redemption_id"):
            kind = "returned"
        elif row.amount < 0:
            kind = "reversed"
        elif row.entry_type == RewardEntryType.earn:
            kind = "earned"
        else:
            kind = "adjustment"
        out.append({
            "id": row.id, "created_at": row.created_at, "kind": kind, "amount_eur": to_eur(row.amount, per_eur),
            "photographer_first_name": first_name,
        })
    return out
