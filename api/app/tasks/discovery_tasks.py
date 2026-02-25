from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.discovery_index import recompute_all_pro_public_indexes, recompute_pro_public_index
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.discovery_tasks.rebuild_pro_index")
def rebuild_pro_index(pro_user_id: str) -> None:
    db = SessionLocal()
    try:
        recompute_pro_public_index(db, uuid.UUID(pro_user_id))
        db.commit()
    finally:
        db.close()


@celery_app.task(name="app.tasks.discovery_tasks.rebuild_all_pro_indexes")
def rebuild_all_pro_indexes() -> int:
    db = SessionLocal()
    try:
        count = recompute_all_pro_public_indexes(db)
        db.commit()
        return count
    finally:
        db.close()
