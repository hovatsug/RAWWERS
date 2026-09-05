from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.models.reward import ReminderJob, ReminderKind, ReminderStatus
from app.services.analytics import log_event


def schedule_proof_selection_reminders(
    db: Session,
    user_id: uuid.UUID,
    gallery_id: uuid.UUID,
    now: datetime | None = None,
) -> list[ReminderJob]:
    now = now or datetime.now(timezone.utc)
    schedule_times = [now + timedelta(hours=24), now + timedelta(hours=72)]
    jobs: list[ReminderJob] = []

    for scheduled_for in schedule_times:
        existing = db.execute(
            select(ReminderJob).where(
                ReminderJob.user_id == user_id,
                ReminderJob.kind == ReminderKind.proof_selection_reminder,
                ReminderJob.reference_id == gallery_id,
                ReminderJob.scheduled_for == scheduled_for,
            )
        ).scalar_one_or_none()
        if existing:
            continue

        job = ReminderJob(
            user_id=user_id,
            kind=ReminderKind.proof_selection_reminder,
            reference_id=gallery_id,
            scheduled_for=scheduled_for,
            status=ReminderStatus.scheduled,
            meta={},
        )
        db.add(job)
        db.flush()
        jobs.append(job)
        log_event(
            db,
            event_name="reminder.scheduled",
            user_id=user_id,
            properties={"kind": job.kind.value, "reference_id": str(gallery_id), "scheduled_for": scheduled_for.isoformat()},
        )
    return jobs


def cancel_proof_selection_reminders(db: Session, user_id: uuid.UUID, gallery_id: uuid.UUID) -> int:
    jobs = db.execute(
        select(ReminderJob).where(
            ReminderJob.user_id == user_id,
            ReminderJob.kind == ReminderKind.proof_selection_reminder,
            ReminderJob.reference_id == gallery_id,
            ReminderJob.status == ReminderStatus.scheduled,
        )
    ).scalars().all()
    for job in jobs:
        job.status = ReminderStatus.cancelled
        job.updated_at = datetime.now(timezone.utc)
    db.flush()
    return len(jobs)


def process_due_reminders(db: Session, now: datetime | None = None) -> int:
    now = now or datetime.now(timezone.utc)
    jobs = db.execute(
        select(ReminderJob).where(
            ReminderJob.status == ReminderStatus.scheduled,
            ReminderJob.scheduled_for <= now,
        )
    ).scalars().all()

    sent_count = 0
    for job in jobs:
        if job.kind != ReminderKind.proof_selection_reminder:
            job.status = ReminderStatus.cancelled
            continue

        gallery = db.get(ProofGallery, job.reference_id)
        if not gallery or gallery.status != ProofGalleryStatus.published:
            job.status = ReminderStatus.cancelled
            job.updated_at = now
            continue

        # Placeholder send: mark sent and log analytics. Future slices can integrate email/push.
        job.status = ReminderStatus.sent
        job.updated_at = now
        sent_count += 1
        log_event(
            db,
            event_name="reminder.sent",
            user_id=job.user_id,
            properties={"kind": job.kind.value, "reference_id": str(job.reference_id)},
        )

    db.flush()
    return sent_count
