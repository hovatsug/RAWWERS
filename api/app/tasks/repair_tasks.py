from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.repair import recompute_partner_score
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.repair_tasks.recompute_partner_score")
def recompute_partner_score_task(partner_id: str) -> None:
    db = SessionLocal()
    try:
        recompute_partner_score(db, uuid.UUID(partner_id))
        db.commit()
    finally:
        db.close()
