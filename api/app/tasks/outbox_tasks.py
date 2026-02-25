from __future__ import annotations

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.services.outbox import (
    claim_pending_outbox_events,
    mark_outbox_delivered,
    mark_outbox_failed,
)
from app.tasks.celery_app import celery_app

settings = get_settings()


@celery_app.task(name="app.tasks.outbox_tasks.dispatch_outbox_events")
def dispatch_outbox_events_task(limit: int | None = None) -> int:
    db = SessionLocal()
    try:
        batch_limit = limit or settings.outbox_batch_size
        rows = claim_pending_outbox_events(db, limit=batch_limit)
        processed = 0
        for row in rows:
            try:
                _dispatch_event(db, row.topic, row.payload)
                mark_outbox_delivered(db, row)
            except Exception:
                mark_outbox_failed(db, row, max_attempts=settings.outbox_max_attempts)
            processed += 1
        db.commit()
        return processed
    finally:
        db.close()


def _dispatch_event(db, topic: str, payload: dict) -> None:
    from app.api.v1.webhooks import _apply_mux_event, _apply_stripe_event

    if topic == "stripe.event":
        event_type = payload.get("type", "unknown")
        obj = ((payload.get("data") or {}).get("object")) or {}
        _apply_stripe_event(db, event_type, obj)
        return
    if topic == "mux.event":
        event_type = payload.get("type", "unknown")
        data = payload.get("data", {})
        _apply_mux_event(db, event_type, data)
        return
    if topic == "reindex.pro":
        from app.services.discovery_index import recompute_pro_public_index
        import uuid

        recompute_pro_public_index(db, uuid.UUID(payload["pro_user_id"]))
        return
    if topic == "recompute.skills":
        from app.services.niche_skills import recompute_pro_niche_skills
        import uuid

        recompute_pro_niche_skills(db, uuid.UUID(payload["pro_user_id"]), uuid.UUID(payload["niche_id"]) if payload.get("niche_id") else None)
        return
