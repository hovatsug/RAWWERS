from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select

from app.db.session import SessionLocal
from app.models.niche import CertificationRecord
from app.services.learning import issue_certificate_for_enrollment
from app.services.niche_skills import recompute_pro_niche_skills
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.learning_tasks.issue_certificate")
def issue_certificate_task(enrollment_id: str) -> None:
    db = SessionLocal()
    try:
        issue_certificate_for_enrollment(db, uuid.UUID(enrollment_id))
        db.commit()
    finally:
        db.close()


@celery_app.task(name="app.tasks.learning_tasks.periodic_recompute_certifications")
def periodic_recompute_certifications_task() -> int:
    db = SessionLocal()
    try:
        now = datetime.now(timezone.utc)
        rows = db.execute(
            select(CertificationRecord).where(
                CertificationRecord.expires_at.is_not(None),
                CertificationRecord.expires_at < now,
            )
        ).scalars().all()
        touched: set[tuple[uuid.UUID, uuid.UUID]] = set()
        for row in rows:
            touched.add((row.pro_user_id, row.niche_id))
        for pro_user_id, niche_id in touched:
            recompute_pro_niche_skills(db, pro_user_id, niche_id)
        db.commit()
        return len(touched)
    finally:
        db.close()
