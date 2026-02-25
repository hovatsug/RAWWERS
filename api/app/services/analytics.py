from __future__ import annotations

import uuid

from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.discovery import AnalyticsEvent

ALLOWED_PREFIXES = (
    "discover.",
    "pro.",
    "booking.",
    "payment.",
    "review.",
    "referral.",
    "reward.",
    "reminder.",
    "chat.",
    "followup.",
    "call.",
    "consent.",
    "notification.",
    "instructor.",
    "course.",
    "certificate.",
    "learning.",
)


def validate_event_name(event_name: str) -> None:
    if not any(event_name.startswith(prefix) for prefix in ALLOWED_PREFIXES):
        raise APIError(code="validation_error", message="Invalid analytics event_name", status_code=422)


def log_event(
    db: Session,
    event_name: str,
    user_id: uuid.UUID | None = None,
    session_id: str | None = None,
    properties: dict | None = None,
) -> AnalyticsEvent:
    validate_event_name(event_name)
    event = AnalyticsEvent(
        user_id=user_id,
        session_id=session_id,
        event_name=event_name,
        properties=properties or {},
    )
    db.add(event)
    return event
