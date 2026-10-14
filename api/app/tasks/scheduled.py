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
SWEEP_LOCK_KEYS = {"expire_booking_requests": 720_001, "expire_unpaid_gigs": 720_002}


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
