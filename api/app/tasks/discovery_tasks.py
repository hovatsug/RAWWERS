from __future__ import annotations

import logging
import uuid

from app.db.session import SessionLocal
from app.services.discovery_index import recompute_all_pro_public_indexes, recompute_pro_public_index
from app.tasks.celery_app import celery_app

logger = logging.getLogger(__name__)


@celery_app.task(name="app.tasks.discovery_tasks.rebuild_pro_index")
def rebuild_pro_index(pro_user_id: str) -> None:
    db = SessionLocal()
    try:
        recompute_pro_public_index(db, uuid.UUID(pro_user_id))
        db.commit()
    finally:
        db.close()


@celery_app.task(name="app.tasks.discovery_tasks.rebuild_all_pro_indexes")
def rebuild_all_pro_indexes() -> dict:
    db = SessionLocal()
    try:
        result = recompute_all_pro_public_indexes(db)
        db.commit()
        logger.info(
            "rebuild_all_pro_indexes",
            extra={"rows": result.rows, "overrides_preserved": result.overrides_preserved},
        )
        return {"rows": result.rows, "overrides_preserved": result.overrides_preserved}
    finally:
        db.close()
