from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.niche_skills import recompute_all_pro_niche_skills, recompute_pro_niche_skills
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.niche_tasks.recompute_pro_niche_skills")
def recompute_pro_niche_skills_task(pro_user_id: str, niche_id: str | None = None) -> int:
    db = SessionLocal()
    try:
        parsed_niche_id = uuid.UUID(niche_id) if niche_id else None
        count = recompute_pro_niche_skills(db, uuid.UUID(pro_user_id), parsed_niche_id)
        db.commit()
        return count
    finally:
        db.close()


@celery_app.task(name="app.tasks.niche_tasks.recompute_all_pro_niche_skills")
def recompute_all_pro_niche_skills_task() -> int:
    db = SessionLocal()
    try:
        count = recompute_all_pro_niche_skills(db)
        db.commit()
        return count
    finally:
        db.close()
