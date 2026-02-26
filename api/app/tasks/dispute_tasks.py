from __future__ import annotations

import uuid

from app.db.session import SessionLocal
from app.services.disputes import escalate_due_disputes, initiate_refund_case
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.dispute_tasks.escalate_disputes")
def escalate_disputes_task(limit: int = 200) -> int:
    db = SessionLocal()
    try:
        count = escalate_due_disputes(db, limit=limit)
        db.commit()
        return count
    finally:
        db.close()


@celery_app.task(name="app.tasks.dispute_tasks.initiate_refund")
def initiate_refund_task(refund_case_id: str) -> str:
    db = SessionLocal()
    try:
        case = initiate_refund_case(db, uuid.UUID(refund_case_id))
        db.commit()
        return str(case.id)
    finally:
        db.close()
