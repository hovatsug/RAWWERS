from __future__ import annotations

import hashlib
import uuid

from sqlalchemy.orm import Session

from app.core.request_context import get_request_id
from app.models.auth import AuthEventLog


def hash_ip(ip: str | None) -> str | None:
    if not ip:
        return None
    return hashlib.sha256(ip.encode("utf-8")).hexdigest()


def add_auth_event(
    db: Session,
    *,
    event_type: str,
    user_id: uuid.UUID | None,
    ip: str | None,
    user_agent: str | None,
    metadata: dict | None = None,
) -> None:
    db.add(
        AuthEventLog(
            user_id=user_id,
            event_type=event_type,
            ip_hash=hash_ip(ip),
            user_agent=user_agent,
            request_id=get_request_id(),
            meta=metadata or {},
        )
    )
