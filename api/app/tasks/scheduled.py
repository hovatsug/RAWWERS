from __future__ import annotations

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.services.gig_state import find_and_flag_stuck_gigs
from app.services.scheduling import expire_pending_booking_requests
from app.tasks.celery_app import celery_app

settings = get_settings()


@celery_app.task(name="app.tasks.scheduled.expire_booking_requests")
def expire_booking_requests_task(limit: int | None = None) -> int:
    db = SessionLocal()
    try:
        count = expire_pending_booking_requests(db, limit=limit or settings.scheduled_sweep_batch_size)
        db.commit()
        return count
    finally:
        db.close()


@celery_app.task(name="app.tasks.scheduled.sweep_stuck_bookings")
def sweep_stuck_bookings_task(limit: int | None = None) -> int:
    db = SessionLocal()
    try:
        count = find_and_flag_stuck_gigs(db, limit=limit or settings.scheduled_sweep_batch_size)
        db.commit()
        return count
    finally:
        db.close()
