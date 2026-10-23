"""Booking close: gallery finalization plus gig completion, triggered once
every payment required to unlock a client's selection has succeeded (the
base package's difference charge, if the curve owes more than
amount_minimum, and the extras/upsell purchase, if the selection went
past included_photos). Shared by the synchronous submit_selection path
(neither payment was required) and the Stripe webhook (a required
payment just succeeded).
"""
from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.constants import SYSTEM_USER_ID
from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, ProofGalleryStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.gig import Gig, GigStatus
from app.models.media_rights import GigEntitlementType
from app.models.proof_of_gigs import RawwIssuanceEventType
from app.services.disputes import upsert_delivery_sla_snapshot
from app.services.discovery_index import recompute_pro_public_index
from app.services.gamification import queue_evaluate_user_milestones
from app.services.gig_state import transition_gig
from app.services.niche_skills import recompute_pro_niche_skills
from app.services.package_pricing import is_curve_priced
from app.services.media_rights import upsert_gig_entitlement
from app.services.payment_intents import (
    base_payment_succeeded,
    difference_owed,
    difference_paid,
)
from app.services.photographer_money import record_gig_earnings
from app.services.proof_of_gigs import enqueue_raww_mint
from app.services.reminders import cancel_proof_selection_reminders


def is_selection_fully_paid(db: Session, *, gig: Gig, gallery: ProofGallery, selection: ClientSelection) -> bool:
    """True once every payment required to unlock this selection has succeeded.

    The one definition of "paid" for a selection: the webhook closes the
    booking on it and the download paths release finals on it.

    Amounts, not existence. It used to ask whether *a* difference payment had
    succeeded, so a payment of any size - or one made for an earlier, smaller
    selection - satisfied it. It now compares what was collected with what the
    curve says is owed, and confirms the deposit itself was collected rather
    than assuming it, as the quote's `amount_paid` does.
    """
    if not base_payment_succeeded(db, gig):
        return False

    selected_count = db.execute(
        select(func.count()).select_from(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)
    ).scalar_one()

    if not is_curve_priced(gig) and selected_count > gallery.included_photos:
        latest_upsell = db.execute(
            select(UpsellPurchase)
            .where(UpsellPurchase.selection_id == selection.id)
            .order_by(UpsellPurchase.created_at.desc())
        ).scalars().first()
        if not latest_upsell or latest_upsell.status != UpsellPurchaseStatus.succeeded:
            return False

    owed = difference_owed(gig)
    if owed > 0 and difference_paid(db, gig) < owed:
        return False

    return True


def finalize_gallery_and_complete_gig(
    db: Session, *, gallery: ProofGallery, gig: Gig, selection: ClientSelection
) -> None:
    """Marks the gallery delivered and, if the gig is still in `paid`,
    closes the booking: transitions it to `completed`, records the
    pro's earnings for the base package, and mints/recomputes the same
    side effects the admin force-complete endpoint used to be the only
    way to trigger. Safe to call more than once (e.g. once from
    submit_selection and again from a webhook) - each step no-ops once
    already applied."""
    if gallery.status != ProofGalleryStatus.selection_submitted:
        gallery.status = ProofGalleryStatus.selection_submitted

    # A curve-priced booking charges for every selected photograph through
    # amount_final, so this is the moment it is known to have been paid for and
    # the moment the finals are released - not submit, which runs before the
    # difference charge has been confirmed. (A flat-priced booking's included
    # photographs were paid at booking, and are unlocked at submit as before.)
    if is_curve_priced(gig):
        selected = db.execute(
            select(func.count()).select_from(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)
        ).scalar_one()
        upsert_gig_entitlement(
            db,
            gig_id=gallery.gig_id,
            user_id=gallery.client_user_id,
            entitlement_type=GigEntitlementType.download_finals,
            quantity_limit=selected,
            metadata={"source": "booking_close", "selection_id": str(selection.id)},
        )
    upsert_delivery_sla_snapshot(db, gig=gig, finals_delivered_at=datetime.now(timezone.utc))
    enqueue_raww_mint(
        db,
        event_type=RawwIssuanceEventType.gig_delivery_confirmed,
        payload={"gig_id": str(gig.id)},
        idempotency_key=f"raww:gig_delivery_confirmed:{gig.id}",
    )
    cancel_proof_selection_reminders(db, gallery.client_user_id, gallery.id)

    if gig.status != GigStatus.paid:
        return

    transition = transition_gig(gig, GigStatus.completed, SYSTEM_USER_ID, reason="Booking closed: selection submitted and payment settled")
    db.add(transition)

    # The final price net of refunds - not the sum of the payments, which
    # credited a photographer the whole deposit for a cheaper selection.
    record_gig_earnings(db, gig)

    enqueue_raww_mint(
        db,
        event_type=RawwIssuanceEventType.gig_completed,
        payload={"gig_id": str(gig.id)},
        idempotency_key=f"raww:gig_completed:{gig.id}",
    )
    recompute_pro_public_index(db, gig.pro_user_id)
    if gig.niche_id:
        recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
    queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)
