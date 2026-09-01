from __future__ import annotations

from app.db.session import SessionLocal
from app.services.reminders import process_due_reminders
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.reminder_tasks.process_due_reminders")
def process_due_reminders_task() -> int:
    db = SessionLocal()
    try:
        sent = process_due_reminders(db)
        db.commit()
        return sent
    finally:
        db.close()
