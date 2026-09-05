from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.gamification import evaluate_user_milestones, recompute_credentials
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.gamification_tasks.evaluate_user_milestones")
def evaluate_user_milestones_task(user_id: str, niche_id: str | None = None) -> int:
    db = SessionLocal()
    try:
        parsed_niche_id = uuid.UUID(niche_id) if niche_id else None
        completed = evaluate_user_milestones(db, uuid.UUID(user_id), parsed_niche_id)
        db.commit()
        return completed
    finally:
        db.close()


@celery_app.task(name="app.tasks.gamification_tasks.recompute_credentials")
def recompute_credentials_task(pro_user_id: str, niche_id: str | None = None) -> int:
    db = SessionLocal()
    try:
        parsed_niche_id = uuid.UUID(niche_id) if niche_id else None
        count = recompute_credentials(db, uuid.UUID(pro_user_id), parsed_niche_id)
        db.commit()
        return count
    finally:
        db.close()
