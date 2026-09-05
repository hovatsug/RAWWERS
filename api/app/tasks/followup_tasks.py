from __future__ import annotations

from app.db.session import SessionLocal
from app.services.followups import process_due_followup_jobs
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.followup_tasks.process_followup_jobs")
def process_followup_jobs_task() -> dict:
    db = SessionLocal()
    try:
        result = process_due_followup_jobs(db)
        db.commit()
        return result
    finally:
        db.close()
