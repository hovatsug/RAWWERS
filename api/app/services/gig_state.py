from __future__ import annotations

import uuid

from app.core.errors import APIError
from app.models.gig import Gig, GigStatus, GigTransition

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
