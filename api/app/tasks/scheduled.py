from __future__ import annotations

import logging

from sqlalchemy import text

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.services.bookable_time import expire_unpaid_gigs
from app.services.gig_state import find_and_flag_stuck_gigs
from app.services.scheduling import expire_pending_booking_requests
from app.tasks.celery_app import celery_app

settings = get_settings()
logger = logging.getLogger(__name__)

# Postgres advisory-lock keys, one per sweep. These two run every minute; a
# run that starts while the previous one is still going skips rather than
# working the same rows twice (a Stripe cancel twice, a transition twice).
SWEEP_LOCK_KEYS = {"expire_booking_requests": 720_001, "expire_unpaid_gigs": 720_002, "stripe_reconcile": 720_003, "mux_sync": 720_004}


def _run_exclusively(name: str, sweep, limit: int | None) -> int:
    """Run `sweep` in one transaction holding its advisory lock, or skip if
    another run holds it. The lock is the transaction's: released at commit,
    rollback, or a dropped connection - a crashed run cannot leave it held."""
    db = SessionLocal()
    try:
        if not db.execute(text("SELECT pg_try_advisory_xact_lock(:key)"), {"key": SWEEP_LOCK_KEYS[name]}).scalar():
            logger.info("sweep_skipped_overlap", extra={"sweep": name})
            db.rollback()
            return 0
        count = sweep(db, limit=limit or settings.scheduled_sweep_batch_size)
        db.commit()
        return count
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.expire_booking_requests")
def expire_booking_requests_task(limit: int | None = None) -> int:
    return _run_exclusively("expire_booking_requests", expire_pending_booking_requests, limit)


@celery_app.task(name="app.tasks.scheduled.expire_unpaid_gigs")
def expire_unpaid_gigs_task(limit: int | None = None) -> int:
    """Release the time held by accepted gigs not paid by their pay deadline."""
    return _run_exclusively("expire_unpaid_gigs", expire_unpaid_gigs, limit)


@celery_app.task(name="app.tasks.scheduled.sweep_stuck_bookings")
def sweep_stuck_bookings_task(limit: int | None = None) -> int:
    db = SessionLocal()
    try:
        count = find_and_flag_stuck_gigs(db, limit=limit or settings.scheduled_sweep_batch_size)
        db.commit()
        return count
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.reconcile_stuck_refunds")
def reconcile_stuck_refunds_task() -> int:
    """Refund cases no Stripe event settled, fetched from Stripe."""
    from app.services.refund_reconcile import reconcile_stuck_refund_cases

    db = SessionLocal()
    try:
        return reconcile_stuck_refund_cases(db)
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.relist_after_suspensions")
def relist_after_suspensions_task() -> int:
    """Photographers whose suspension has run out, back on Discover."""
    from app.services.pro_standing import relist_after_suspensions

    db = SessionLocal()
    try:
        relisted = relist_after_suspensions(db)
        db.commit()
        return relisted
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.raise_clients_owed")
def raise_clients_owed_task() -> int:
    """Bookings whose client has kept more than the price, on "Money to act on"."""
    from app.services.client_owed import raise_clients_owed

    db = SessionLocal()
    try:
        raised = raise_clients_owed(db)
        db.commit()
        return raised
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.apply_due_findings")
def apply_due_findings_task() -> int:
    """Confirmed findings whose window to respond has ended, put in effect."""
    from app.services.accountability import apply_due_findings

    db = SessionLocal()
    try:
        applied = apply_due_findings(db)
        db.commit()
        return applied
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.purge_raw_access_ips")
def purge_raw_access_ips_task() -> int:
    """Clients' raw IPs on download logs, past their retention period."""
    from app.services.media_rights import purge_raw_access_ips

    db = SessionLocal()
    try:
        cleared = purge_raw_access_ips(db)
        db.commit()
        return cleared
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.marketing_consent_daily")
def marketing_consent_daily_task() -> dict:
    """Marketing-use consent: mark the ended ones expired, and prompt clients
    whose permissions end within 30 days (owner's decision, 2026-11-01)."""
    from app.services.marketing_consent import expire_due, send_renewal_prompts

    db = SessionLocal()
    try:
        expired = expire_due(db)
        prompted = send_renewal_prompts(db)
        db.commit()
        return {"expired": expired, "prompted": prompted}
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.remove_unfinished_uploads")
def remove_unfinished_uploads_task() -> int:
    """Uploads started and never finished, after about a day (owner's decision 4)."""
    from app.services.unfinished_uploads import remove_unfinished_uploads

    db = SessionLocal()
    try:
        removed = remove_unfinished_uploads(db)
        db.commit()
        return removed
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.shelf_raww_daily")
def shelf_raww_daily_task() -> dict:
    """The Shelf: expire spendable RAWW after long inactivity, and warn
    beforehand (services/raww_expiry.py)."""
    from app.services.raww_expiry import run_daily

    db = SessionLocal()
    try:
        result = run_daily(db)
        db.commit()
        return result
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.stripe_reconcile")
def stripe_reconcile_task() -> dict:
    """Record Stripe successes that never reached us as a webhook, and flag
    what cannot be matched (services/stripe_reconcile.py). A run that
    starts while the previous one still holds the lock skips."""
    from app.services.stripe_reconcile import run

    db = SessionLocal()
    try:
        if not db.execute(text("SELECT pg_try_advisory_xact_lock(:key)"), {"key": SWEEP_LOCK_KEYS["stripe_reconcile"]}).scalar():
            logger.info("sweep_skipped_overlap", extra={"sweep": "stripe_reconcile"})
            db.rollback()
            return {"skipped": True}
        record = run(db)
        db.commit()
        return {"checked": record.checked, "recorded": record.recorded, "flagged": record.flagged, "dry_run": record.dry_run, "error": record.error}
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.mux_sync")
def mux_sync_task() -> dict:
    """Ask Mux about videos whose webhook never came (services/mux_sync.py)."""
    from app.services.mux_sync import sync_waiting_videos

    db = SessionLocal()
    try:
        if not db.execute(text("SELECT pg_try_advisory_xact_lock(:key)"), {"key": SWEEP_LOCK_KEYS["mux_sync"]}).scalar():
            logger.info("sweep_skipped_overlap", extra={"sweep": "mux_sync"})
            db.rollback()
            return {"skipped": True}
        result = sync_waiting_videos(db)
        db.commit()
        return {"checked": result.checked, "applied": len(result.applied), "errors": result.errors}
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.selection_addon_reminders")
def selection_addon_reminders_task() -> int:
    """Remind clients, once, within two days of their gallery closing, if
    photos are still there to add (services/selection_addons.py)."""
    from app.services.selection_addons import send_closing_reminders

    db = SessionLocal()
    try:
        sent = send_closing_reminders(db)
        db.commit()
        return sent
    finally:
        db.close()
