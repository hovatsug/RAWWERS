"""RAWW expiry: the daily job.

Owner's decision (2026-11-03). A photographer's spendable RAWW expire, all
of them, after `inactivity_months` with no earning and no spending (any earn
or spend restarts the clock and clears the warning). `warning_days` before
that, an in-app notification says when; the Wallet always shows the date.
Pending RAWW do not expire: they are not spendable yet.

Nothing expires while The Shelf is closed - there is nothing to spend them
on - and the warning waits too.
"""
from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.shelf import ProRawwBalance
from app.services import raww_ledger as ledger
from app.services.notifications import enqueue_notification
from app.services.shelf_settings import shelf_open, shelf_settings


def run_daily(db: Session, *, now: datetime | None = None) -> dict:
    now = now or datetime.now(timezone.utc)
    if not shelf_open(db):
        return {"expired": 0, "warned": 0, "skipped": "shelf_closed"}
    settings = shelf_settings(db)
    # Only balances that could expire or be warned within the warning period.
    horizon = ledger.months_after(now + timedelta(days=settings.warning_days), -settings.inactivity_months)
    candidates = db.execute(
        select(ProRawwBalance.pro_user_id).where(
            ProRawwBalance.spendable > 0,
            ProRawwBalance.last_activity_at.is_not(None),
            ProRawwBalance.last_activity_at <= horizon,
        )
    ).scalars().all()
    expired = warned = 0
    for pro_user_id in candidates:
        with db.begin_nested():
            balance = ledger.balance_locked(db, pro_user_id)
            expiry = ledger.expires_at(balance, settings.inactivity_months)
            if expiry is None:
                continue
            if now >= expiry:
                amount = balance.spendable
                if ledger.expire_spendable(db, pro_user_id=pro_user_id):
                    expired += 1
                    enqueue_notification(
                        db,
                        user_id=pro_user_id,
                        notification_type="shelf.raww_expired",
                        payload={
                            "title": "Your RAWW expired",
                            "body": f"{amount} RAWW expired after {settings.inactivity_months} months without earning or spending.",
                        },
                        reference_type="pro_raww",
                        reference_id=str(pro_user_id),
                        dedupe_key=f"raww-expired:{pro_user_id}:{balance.last_activity_at.isoformat()}",
                    )
            elif balance.expiry_warned_at is None and ledger.in_warning_period(expiry, settings.warning_days, now):
                balance.expiry_warned_at = now
                warned += 1
                enqueue_notification(
                    db,
                    user_id=pro_user_id,
                    notification_type="shelf.raww_expiring",
                    payload={
                        "title": "Your RAWW expire soon",
                        "body": f"{balance.spendable} RAWW expire on {expiry:%d %b %Y}. Earn or spend before then to keep them.",
                        "action": {"label": "The Shelf", "url": "rawwerspro://wallet/shelf"},
                    },
                    reference_type="pro_raww",
                    reference_id=str(pro_user_id),
                    dedupe_key=f"raww-expiring:{pro_user_id}:{balance.last_activity_at.isoformat()}",
                )
    db.flush()
    return {"expired": expired, "warned": warned}
