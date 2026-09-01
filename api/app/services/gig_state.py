from __future__ import annotations

import logging
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.communication import NotificationSeverity
from app.models.gig import Gig, GigStatus, GigTransition
from app.services.notifications import enqueue_notification

logger = logging.getLogger(__name__)

TERMINAL_GIG_STATUSES: set[GigStatus] = {
    GigStatus.completed,
    GigStatus.cancelled_by_client,
    GigStatus.cancelled_by_pro,
    GigStatus.refunded,
}

ALLOWED_TRANSITIONS: dict[GigStatus, set[GigStatus]] = {
    GigStatus.payment_pending: {GigStatus.paid, GigStatus.cancelled_by_client, GigStatus.cancelled_by_pro},
    GigStatus.paid: {GigStatus.refunded, GigStatus.disputed},
    GigStatus.refunded: set(),
    GigStatus.disputed: set(),
}


def transition_gig(
    gig: Gig,
    to_status: GigStatus,
    actor_user_id: uuid.UUID,
    reason: str | None = None,
) -> GigTransition:
    if gig.status == to_status:
        return GigTransition(
            gig_id=gig.id,
            from_status=gig.status,
            to_status=to_status,
            actor_user_id=actor_user_id,
            reason=reason,
        )

    allowed = ALLOWED_TRANSITIONS.get(gig.status, set())
    if to_status not in allowed:
        raise APIError(
            code="invalid_state_transition",
            message=f"Transition {gig.status.value} -> {to_status.value} not allowed",
            status_code=409,
        )

    transition = GigTransition(
        gig_id=gig.id,
        from_status=gig.status,
        to_status=to_status,
        actor_user_id=actor_user_id,
        reason=reason,
    )
    gig.status = to_status
    return transition


def find_and_flag_stuck_gigs(
    db: Session,
    *,
    now: datetime | None = None,
    max_age_hours: int | None = None,
    limit: int = 100,
) -> int:
    """Observational sweep only: never transitions a gig's status.

    Flags gigs that have sat in a non-terminal state past a generous
    max age, via a structured log line (every run, so it shows up on
    dashboards until resolved) and a one-time admin notification
    (stable dedupe_key per gig, so admins aren't paged repeatedly for
    the same stuck record).
    """
    settings = get_settings()
    current = now or datetime.now(timezone.utc)
    threshold_hours = max_age_hours if max_age_hours is not None else settings.stuck_booking_max_age_hours
    cutoff = current - timedelta(hours=threshold_hours)

    rows = db.execute(
        select(Gig)
        .where(Gig.status.notin_(TERMINAL_GIG_STATUSES), Gig.updated_at < cutoff)
        .order_by(Gig.updated_at.asc())
        .limit(limit)
    ).scalars().all()

    flagged_count = 0
    failed_count = 0
    admin_ids = settings.admin_user_id_set()
    for gig in rows:
        try:
            age_hours = (current - gig.updated_at).total_seconds() / 3600
            logger.warning(
                "stuck_gig_flagged",
                extra={"gig_id": str(gig.id), "status": gig.status.value, "age_hours": round(age_hours, 1)},
            )
            with db.begin_nested():
                for admin_id in admin_ids:
                    enqueue_notification(
                        db,
                        user_id=admin_id,
                        notification_type="gig.stuck_sweep_flag",
                        payload={
                            "title": "Gig stuck in non-terminal state",
                            "body": f"Gig {gig.id} has been in {gig.status.value} for over {threshold_hours}h.",
                            "action": {"label": "View gig", "url": f"/admin/gigs/{gig.id}"},
                        },
                        reference_type="gig",
                        reference_id=str(gig.id),
                        severity=NotificationSeverity.important,
                        dedupe_key=f"gig-stuck-sweep:{gig.id}",
                    )
            flagged_count += 1
        except Exception:
            failed_count += 1
            logger.exception("stuck_gig_flag_failed", extra={"gig_id": str(gig.id)})

    logger.info(
        "sweep_stuck_bookings_sweep",
        extra={"scanned": len(rows), "flagged": flagged_count, "failed": failed_count},
    )
    return flagged_count
