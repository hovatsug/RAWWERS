from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.outbox import IdempotencyKey, OutboxEvent, OutboxEventStatus


def ensure_idempotency_key(
    db: Session,
    *,
    key: str,
    scope: str,
    metadata: dict | None = None,
) -> bool:
    row = IdempotencyKey(key=key, scope=scope, meta=metadata or {})
    db.add(row)
    try:
        db.flush()
        return True
    except IntegrityError:
        db.rollback()
        return False


def enqueue_outbox_event(
    db: Session,
    *,
    topic: str,
    payload: dict,
    idempotency_key: str | None = None,
    idempotency_scope: str | None = None,
) -> OutboxEvent | None:
    if idempotency_key and idempotency_scope:
        inserted = ensure_idempotency_key(
            db,
            key=idempotency_key,
            scope=idempotency_scope,
            metadata={"topic": topic},
        )
        if not inserted:
            return None

    row = OutboxEvent(
        topic=topic,
        payload=payload,
        status=OutboxEventStatus.pending,
        attempts=0,
        next_attempt_at=datetime.now(timezone.utc),
    )
    db.add(row)
    db.flush()
    return row


def claim_pending_outbox_events(db: Session, *, limit: int) -> list[OutboxEvent]:
    now = datetime.now(timezone.utc)
    rows = db.execute(
        select(OutboxEvent)
        .where(
            OutboxEvent.status.in_([OutboxEventStatus.pending, OutboxEventStatus.processing]),
            OutboxEvent.next_attempt_at <= now,
        )
        .order_by(OutboxEvent.created_at.asc())
        .with_for_update(skip_locked=True)
        .limit(limit)
    ).scalars().all()
    for row in rows:
        row.status = OutboxEventStatus.processing
        row.updated_at = now
    db.flush()
    return rows


def mark_outbox_delivered(db: Session, row: OutboxEvent) -> None:
    row.status = OutboxEventStatus.delivered
    row.updated_at = datetime.now(timezone.utc)
    db.flush()


def mark_outbox_failed(db: Session, row: OutboxEvent, *, max_attempts: int) -> None:
    row.attempts += 1
    now = datetime.now(timezone.utc)
    if row.attempts >= max_attempts:
        row.status = OutboxEventStatus.failed
        row.next_attempt_at = now + timedelta(hours=1)
    else:
        backoff_seconds = min(3600, 2 ** row.attempts)
        row.status = OutboxEventStatus.pending
        row.next_attempt_at = now + timedelta(seconds=backoff_seconds)
    row.updated_at = now
    db.flush()
