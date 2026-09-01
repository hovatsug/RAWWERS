from __future__ import annotations

from app.db.session import SessionLocal
from app.services.outbox import enqueue_outbox_event
from app.services.payouts import settle_due_earnings_entries
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.payouts_tasks.enqueue_settlement_scan")
def enqueue_settlement_scan_task() -> int:
    db = SessionLocal()
    try:
        enqueue_outbox_event(
            db,
            topic="earnings.settlement.scan",
            payload={},
            idempotency_key="earnings-settlement-scan",
            idempotency_scope="earnings_settlement",
        )
        db.commit()
        return 1
    finally:
        db.close()


@celery_app.task(name="app.tasks.payouts_tasks.run_settlement_scan")
def run_settlement_scan_task(limit: int = 500) -> int:
    db = SessionLocal()
    try:
        changed = settle_due_earnings_entries(db, limit=limit)
        db.commit()
        return changed
    finally:
        db.close()
