"""A booking refunded in full is over.

The minimum the platform cancellation standard builds on. Once every payment
captured for a booking has been refunded in full, whichever route the
refund came through, the booking is settled - once:

  - a paid or disputed gig becomes `refunded`, which frees the
    photographer's calendar (refunded is not an occupying status);
  - the client's finals and extras downloads are revoked;
  - the photographer's earnings for it are reversed.

A booking further along keeps its status for now: what a late refund makes
of it is the cancellation standard's decision. Its finals and earnings
still go - the money is back with the client.
"""
from __future__ import annotations

import logging
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.constants import SYSTEM_USER_ID
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment
from app.models.media_rights import GigEntitlementType, GigMediaEntitlement
from app.models.payouts import EarningsSourceType
from app.services.gig_state import transition_gig
from app.services.payouts import reverse_earnings_entries_for_source

logger = logging.getLogger(__name__)

REVOKED_ON_FULL_REFUND = (GigEntitlementType.download_finals, GigEntitlementType.download_extras)
SETTLES_TO_REFUNDED = (GigStatus.paid, GigStatus.disputed)


def is_fully_refunded(db: Session, gig: Gig) -> bool:
    """Every payment that captured money for this booking is refunded in
    full. A payment intent that never captured anything does not count."""
    payments = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalars().all()
    captured = [p for p in payments if p.status == PaymentStatus.refunded or (p.meta or {}).get("paid_at")]
    return bool(captured) and all(p.status == PaymentStatus.refunded for p in captured)


def revoke_finals(db: Session, gig: Gig, *, reason: str) -> None:
    """End the client's finals and extras downloads for this booking."""
    now = datetime.now(timezone.utc)
    for entitlement in db.execute(
        select(GigMediaEntitlement).where(
            GigMediaEntitlement.gig_id == gig.id,
            GigMediaEntitlement.user_id == gig.client_user_id,
            GigMediaEntitlement.entitlement_type.in_(REVOKED_ON_FULL_REFUND),
        )
    ).scalars():
        if entitlement.valid_until is None or entitlement.valid_until > now:
            entitlement.valid_until = now
            entitlement.meta = {**(entitlement.meta or {}), "revoked_reason": reason}


def settle_full_refund(db: Session, gig: Gig, *, reason: str) -> bool:
    """Settle the booking if it is now refunded in full. True only the
    first time - a repeated or late event changes nothing."""
    if (gig.meta or {}).get("full_refund_settled_at") or not is_fully_refunded(db, gig):
        return False
    now = datetime.now(timezone.utc)

    if gig.status in SETTLES_TO_REFUNDED:
        db.add(transition_gig(gig, GigStatus.refunded, SYSTEM_USER_ID, reason=reason))
    else:
        logger.warning("full_refund_gig_status_kept", extra={"gig_id": str(gig.id), "status": gig.status.value})

    revoke_finals(db, gig, reason="full_refund")

    reverse_earnings_entries_for_source(db, source_type=EarningsSourceType.gig_base, source_id=gig.id, reason="full_refund")

    gig.meta = {**(gig.meta or {}), "full_refund_settled_at": now.isoformat()}
    db.flush()
    return True
