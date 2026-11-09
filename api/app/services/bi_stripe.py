"""Stripe's side of the business dashboard (docs/BI.md).

- `sync_days`: Stripe's balance transactions for whole days (Europe/London)
  mirrored into `bi_stripe_txn`, and each day marked mirrored. The real fees
  come from here: we stored none before. A day not mirrored is "no data".
- `balance`: Stripe's balance now (available and pending), live.

Stripe is reached through a small gateway, so tests use a fake and never
the network.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import date, datetime, time, timedelta, timezone
from typing import Iterable, Protocol

from sqlalchemy import text
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session

from app.models.bi import BiStripeSyncDay, BiStripeTxn
from app.services.bi import LONDON, _check_range

logger = logging.getLogger(__name__)
#: The most days one request may mirror.
MAX_SYNC_DAYS = 31


class StripeGateway(Protocol):
    def balance_transactions(self, created_gte: int, created_lt: int) -> Iterable[dict]: ...

    def balance(self) -> dict: ...


class LiveStripe:
    def balance_transactions(self, created_gte: int, created_lt: int) -> Iterable[dict]:
        from app.services.stripe_service import stripe

        return stripe.BalanceTransaction.list(created={"gte": created_gte, "lt": created_lt}, limit=100).auto_paging_iter()

    def balance(self) -> dict:
        from app.services.stripe_service import stripe

        return stripe.Balance.retrieve()


def _day_bounds(day: date) -> tuple[int, int]:
    start = datetime.combine(day, time.min, tzinfo=LONDON)
    end = datetime.combine(day + timedelta(days=1), time.min, tzinfo=LONDON)
    return int(start.timestamp()), int(end.timestamp())


def _when(ts) -> datetime | None:
    return datetime.fromtimestamp(int(ts), tz=timezone.utc) if ts else None


@dataclass
class SyncResult:
    days: int
    transactions: int


def sync_days(db: Session, a: date, b: date, gateway: StripeGateway | None = None) -> SyncResult:
    """Mirror Stripe's balance transactions for each day in [a, b]. Re-running
    a day rewrites the same rows."""
    _check_range(a, b, MAX_SYNC_DAYS)
    gateway = gateway or LiveStripe()
    total = 0
    day = a
    while day <= b:
        gte, lt = _day_bounds(day)
        count = 0
        for txn in gateway.balance_transactions(gte, lt):
            row = {
                "id": txn["id"], "type": txn.get("type") or "unknown", "reporting_category": txn.get("reporting_category"),
                "currency": str(txn.get("currency") or "").upper(), "amount_cents": int(txn.get("amount") or 0),
                "fee_cents": int(txn.get("fee") or 0), "net_cents": int(txn.get("net") or 0),
                "created_at": _when(txn.get("created")), "available_on": _when(txn.get("available_on")),
                "source_id": txn.get("source") if isinstance(txn.get("source"), str) else (txn.get("source") or {}).get("id"),
                "status": txn.get("status"), "demo": False, "synced_at": datetime.now(timezone.utc),
            }
            stmt = insert(BiStripeTxn).values(**row)
            db.execute(stmt.on_conflict_do_update(index_elements=["id"], set_={k: stmt.excluded[k] for k in row if k != "id"}))
            count += 1
        stmt = insert(BiStripeSyncDay).values(day=day, txn_count=count, source="stripe", synced_at=datetime.now(timezone.utc))
        db.execute(stmt.on_conflict_do_update(index_elements=["day"], set_={"txn_count": count, "source": "stripe",
                                                                             "synced_at": stmt.excluded.synced_at}))
        total += count
        day += timedelta(days=1)
    db.flush()
    return SyncResult(days=(b - a).days + 1, transactions=total)


def balance(gateway: StripeGateway | None = None) -> dict:
    """Stripe's EUR balance now, in cents, or the reason it is not known."""
    try:
        data = (gateway or LiveStripe()).balance()
    except Exception as exc:  # the dashboard shows "no data", it does not fail
        logger.warning("bi_stripe_balance_failed", extra={"error": type(exc).__name__})
        return {"available_cents": None, "pending_cents": None, "reason": "Stripe balance unavailable"}

    def eur(entries) -> int | None:
        amounts = [int(e["amount"]) for e in entries or [] if str(e.get("currency", "")).lower() == "eur"]
        return sum(amounts) if amounts else 0

    return {"available_cents": eur(data.get("available")), "pending_cents": eur(data.get("pending")), "reason": None}


def stripe_configured() -> bool:
    from app.core.config import get_settings

    key = get_settings().stripe_secret_key or ""
    return key.startswith(("sk_live_", "sk_test_", "rk_live_", "rk_test_")) and "placeholder" not in key


def mirrored_days(db: Session, a: date, b: date) -> int:
    return int(db.execute(text("SELECT count(*) FROM bi_stripe_sync_day WHERE day BETWEEN :a AND :b"), {"a": a, "b": b}).scalar_one())
