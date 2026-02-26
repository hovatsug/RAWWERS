from __future__ import annotations

from app.db.session import SessionLocal
from app.services.proof_of_gigs import enqueue_studioverse_milestone_scan
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.proof_of_gigs_tasks.scan_studioverse_milestones")
def scan_studioverse_milestones_task() -> int:
    db = SessionLocal()
    try:
        enqueue_studioverse_milestone_scan(db)
        db.commit()
        return 1
    finally:
        db.close()
