from __future__ import annotations

from app.db.session import SessionLocal
from app.services.trust_safety import purge_old_risk_signals, reconcile_all_risk_profiles
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.trust_safety_tasks.reconcile_risk_profiles")
def reconcile_risk_profiles_task(limit: int = 500) -> int:
    db = SessionLocal()
    try:
        updated = reconcile_all_risk_profiles(db, limit=limit)
        db.commit()
        return updated
    finally:
        db.close()


@celery_app.task(name="app.tasks.trust_safety_tasks.purge_risk_signals")
def purge_risk_signals_task() -> int:
    db = SessionLocal()
    try:
        deleted = purge_old_risk_signals(db)
        db.commit()
        return deleted
    finally:
        db.close()
