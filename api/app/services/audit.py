from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.models.admin import AdminAuditLog


def add_admin_audit_log(
    db: Session,
    actor_user_id: uuid.UUID,
    target_type: str,
    target_id: str,
    action: str,
    reason: str | None = None,
    metadata: dict | None = None,
) -> None:
    db.add(
        AdminAuditLog(
            actor_user_id=actor_user_id,
            target_type=target_type,
            target_id=target_id,
            action=action,
            reason=reason,
            meta=metadata or {},
        )
    )
