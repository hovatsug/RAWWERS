"""Client credit: its money rules, its marketing budget, and what the client
sees of it (owner's decisions, 2026-11-07).

- Client credit is RAWWERS's marketing cost. It buys content for RAWWERS's
  own advertising and is funded from the platform's retained share. The
  photographer's cash and 5% RAWW credit are always computed on the
  pre-discount price (photographer_money counts credit used as money paid
  towards the price), and nothing is transferred to the photographer as RAWW.
- Today its only use is a discount on a booking, at most
  `max_discount_percent` of the payment (admin setting, default 10).
- It is per currency (MULTI_CURRENCY.md decision M3, batch M4): credit
  earned on a booking is in that booking's currency, and pays only for
  bookings in that currency; a client may hold credit in euros and in
  pounds, never mixed or converted. Shown as points / points_per_eur (100)
  units of its currency (the setting's name predates currencies: 100 points
  are €1 or £1). Never called RAWW.
- Awards for marketing permissions draw on a monthly budget per currency
  (`monthly_marketing_credit_budget_eur` and `_gbp`, default 300 each; 0
  means none). It counts credit awarded in the calendar month in
  Europe/London, checked under a lock on the settings row, so concurrent
  grants can never exceed it. Admins are told at 80% and at 100%, once each
  a month and currency. The per-client monthly cap (3) and the per-grant
  amounts are unchanged.
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


def to_money(points: int, per_unit: int) -> Decimal:
    """Points as an amount of their currency (100 points = 1.00)."""
    return (Decimal(int(points)) / Decimal(per_unit)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


#: The settings that hold each currency's monthly budget and alert months.
_BUDGET = {
    "EUR": ("monthly_marketing_credit_budget_eur", "alerted_80_month", "alerted_100_month"),
    "GBP": ("monthly_marketing_credit_budget_gbp", "alerted_80_month_gbp", "alerted_100_month_gbp"),
}


def monthly_budget(row: ClientCreditSettings, currency: str) -> Decimal:
    return Decimal(getattr(row, _BUDGET[currency][0]))


def month_bounds(now: datetime | None = None) -> tuple[str, datetime, datetime]:
    """("2026-11", start, end) of the calendar month in Europe/London, in UTC."""
    local = (now or datetime.now(timezone.utc)).astimezone(REPORTING_TZ)
    start = local.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    end = start.replace(year=start.year + 1, month=1) if start.month == 12 else start.replace(month=start.month + 1)
    return f"{start.year:04d}-{start.month:02d}", start.astimezone(timezone.utc), end.astimezone(timezone.utc)


def awarded(db: Session, currency: str, now: datetime | None = None) -> Decimal:
    """Marketing credit in `currency` awarded this month, net of nothing:
    what was given."""
    _key, start, end = month_bounds(now)
    points = db.execute(
        select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
            RewardLedgerEntry.reference_type == MARKETING_REFERENCE,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
            RewardLedgerEntry.currency == currency,
            RewardLedgerEntry.created_at >= start,
            RewardLedgerEntry.created_at < end,
        )
    ).scalar_one()
    return to_money(points, points_per_eur(db))


def budget_view(db: Session, currency: str, now: datetime | None = None) -> dict:
    """The admin's month in one currency: budget, awarded, used at checkout,
    outstanding (all clients' unspent credit) and remaining."""
    from app.services.currencies import normalise

    currency = normalise(currency)
    key, start, end = month_bounds(now)
    row = settings(db)
    given = awarded(db, currency, now)
    used = db.execute(
        select(func.coalesce(func.sum(DiscountRedemption.discount_amount), 0)).where(
            DiscountRedemption.status == DiscountRedemptionStatus.applied,
            DiscountRedemption.currency == currency,
            DiscountRedemption.updated_at >= start,
            DiscountRedemption.updated_at < end,
        )
    ).scalar_one()
    outstanding_points = db.execute(
        select(func.coalesce(func.sum(RewardBalance.balance), 0)).where(RewardBalance.balance > 0, RewardBalance.currency == currency)
    ).scalar_one()
    returned_points = db.execute(
        select(func.coalesce(func.sum(RewardLedgerEntry.amount), 0)).where(
            RewardLedgerEntry.reference_type == REFUND_REFERENCE,
            RewardLedgerEntry.currency == currency,
            RewardLedgerEntry.created_at >= start,
            RewardLedgerEntry.created_at < end,
        )
    ).scalar_one()
    budget = monthly_budget(row, currency)
    return {
        "month": key,
        "currency": currency,
        "budget": budget,
        "awarded": given,
        "used": Decimal(used).quantize(Decimal("0.01")),
        "returned_on_refunds": to_money(returned_points, points_per_eur(db)),
        "outstanding": to_money(outstanding_points, points_per_eur(db)),
        "remaining": max(Decimal("0.00"), budget - given),
        "max_discount_percent": row.max_discount_percent,
    }


def budget_left_for(db: Session, amount_points: int, currency: str, now: datetime | None = None) -> bool:
    """Whether an award of `amount_points` in `currency` fits this month's
    budget in that currency now."""
    budget = monthly_budget(settings(db), currency)
    if budget <= 0:
        return False
    return awarded(db, currency, now) + to_money(amount_points, points_per_eur(db)) <= budget


def award_marketing_credit(
    db: Session, *, client_user_id: uuid.UUID, amount_points: int, gig_id: uuid.UUID, metadata: dict, balance_floor: int
) -> RewardLedgerEntry | None:
    """Award a marketing-permission credit, in the booking's currency, if
    that currency's budget for the month allows it. Under the settings
    row's lock: two grants at once are counted one after the other, so the
    budget is never exceeded. None when it does not fit."""
    from app.models.gig import Gig
    from app.services.rewards import add_reward_entry

    currency = db.get(Gig, gig_id).currency
    row = settings(db, lock=True)
    if not budget_left_for(db, amount_points, currency):
        return None
    entry = add_reward_entry(
        db,
        user_id=client_user_id,
        amount=amount_points,
        entry_type=RewardEntryType.earn,
        reference_type=MARKETING_REFERENCE,
        reference_id=str(gig_id),
        currency=currency,
        metadata=metadata,
        min_balance_floor=balance_floor,
    )
    if entry is None:
        return None
    _alert_admins_if_due(db, row, currency)
    notify_credit_earned(db, entry)
    return entry


def _alert_admins_if_due(db: Session, row: ClientCreditSettings, currency: str, now: datetime | None = None) -> None:
    from app.core.config import get_settings
    from app.services.currencies import format_money
    from app.services.notifications import enqueue_notification

    budget = monthly_budget(row, currency)
    if budget <= 0:
        return
    key, _start, _end = month_bounds(now)
    given = awarded(db, currency, now)
    _budget_attr, attr_80, attr_100 = _BUDGET[currency]
    # The euro budget keeps its references from before budgets were per currency.
    suffix = "" if currency == "EUR" else f":{currency}"
    for level, attr in ((100, attr_100), (80, attr_80)):
        if given * 100 >= budget * level and getattr(row, attr) != key:
            setattr(row, attr, key)
            for admin_id in get_settings().admin_user_id_set():
                enqueue_notification(
                    db,
                    user_id=admin_id,
                    notification_type="admin.marketing_budget",
                    payload={
                        "title": f"Marketing credit budget ({currency}) at {level}%",
                        "body": f"{format_money(given, currency)} of {format_money(budget, currency)} awarded this month ({key})."
                        + (f" No more credit in {currency} is awarded until next month." if level == 100 else ""),
                    },
                    reference_type="marketing_budget",
                    reference_id=f"{key}:{level}{suffix}",
                    dedupe_key=f"marketing-budget:{key}:{level}{suffix}:{admin_id}",
                )
    db.flush()


def notify_credit_earned(db: Session, entry: RewardLedgerEntry) -> None:
    """"You earned £1.00 credit", in the credit's currency, once per award
    however often its event is delivered."""
    from app.services.currencies import format_money
    from app.services.notifications import enqueue_notification

    amount = format_money(to_money(entry.amount, points_per_eur(db)), entry.currency)
    enqueue_notification(
        db,
        user_id=entry.user_id,
        notification_type="reward.credit_earned",
        payload={
            "title": f"You earned {amount} credit",
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


def balance_points(db: Session, user_id: uuid.UUID, currency: str) -> int:
    """The user's credit in one currency, in points."""
    row = db.get(RewardBalance, (user_id, currency))
    return int(row.balance) if row else 0


def balances(db: Session, user_id: uuid.UUID) -> list[dict]:
    """Every currency the user holds credit in (non-zero), as money."""
    per_unit = points_per_eur(db)
    rows = db.execute(
        select(RewardBalance).where(RewardBalance.user_id == user_id, RewardBalance.balance != 0).order_by(RewardBalance.currency)
    ).scalars().all()
    return [{"currency": r.currency, "balance": to_money(r.balance, per_unit)} for r in rows]


def checkout_preview(db: Session, *, client_user_id: uuid.UUID, gig) -> dict:
    """What credit would take off this booking's payment: the smaller of the
    client's credit in the booking's currency and the cap. Changes nothing."""
    per_eur = points_per_eur(db)
    price = Decimal(gig.amount_minimum)
    existing = open_redemption(db, client_user_id=client_user_id, gig_id=gig.id)
    cap = (price * Decimal(max_discount_percent(db)) / Decimal("100")).quantize(Decimal("0.01"))
    # Credit in the booking's currency only (decision M3).
    balance = to_money(balance_points(db, client_user_id, gig.currency), per_eur)
    if existing:
        discount = Decimal(existing.discount_amount)
    else:
        discount = min(balance, cap, price)
    discount = max(Decimal("0.00"), discount)
    return {
        "balance": balance,
        "credit_currency": gig.currency,
        "discount": discount,
        "price": price,
        "total": price - discount,
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
        # The client's credit in the booking's currency; credit in another
        # currency is never used (decision M3).
        points = balance_points(db, client_user_id, gig.currency)
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
    # Back into the credit it was spent from: the redemption's currency.
    balance = _get_or_create_reward_balance_locked(db, redemption.user_id, redemption.currency)
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
            user_id=redemption.user_id, entry_type=RewardEntryType.adjustment, rule_code=None,
            currency=redemption.currency, amount=give,
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
            "id": row.id, "created_at": row.created_at, "kind": kind, "amount": to_money(row.amount, per_eur), "currency": row.currency,
            "photographer_first_name": first_name,
        })
    return out
