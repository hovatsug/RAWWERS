from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.launch_ops import maybe_advance_to_ready_for_review
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.launch_ops_tasks.onboarding_ready_check")
def onboarding_ready_check_task(pro_user_id: str) -> str:
    db = SessionLocal()
    try:
        row = maybe_advance_to_ready_for_review(db, pro_user_id=uuid.UUID(pro_user_id))
        db.commit()
        return row.status.value
    finally:
        db.close()
