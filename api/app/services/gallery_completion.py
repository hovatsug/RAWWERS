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
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.constants import SYSTEM_USER_ID
from app.models.gallery import ClientSelection, ClientSelectionItem, ProofGallery, ProofGalleryStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.payouts import EarningsSourceType
from app.models.proof_of_gigs import RawwIssuanceEventType
from app.services.disputes import upsert_delivery_sla_snapshot
from app.services.discovery_index import recompute_pro_public_index
from app.services.gamification import queue_evaluate_user_milestones
from app.services.gig_state import transition_gig
from app.services.niche_skills import recompute_pro_niche_skills
from app.services.payment_intents import list_succeeded_payments_for_gig
from app.services.payouts import create_earnings_entry
from app.services.proof_of_gigs import enqueue_raww_mint
from app.services.reminders import cancel_proof_selection_reminders


def is_selection_fully_paid(db: Session, *, gig: Gig, gallery: ProofGallery, selection: ClientSelection) -> bool:
    """True once every payment required to unlock this selection has succeeded."""
    selected_count = db.execute(
        select(func.count()).select_from(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)
    ).scalar_one()

    if selected_count > gallery.included_photos:
        latest_upsell = db.execute(
            select(UpsellPurchase)
            .where(UpsellPurchase.selection_id == selection.id)
            .order_by(UpsellPurchase.created_at.desc())
        ).scalars().first()
        if not latest_upsell or latest_upsell.status != UpsellPurchaseStatus.succeeded:
            return False

    if gig.amount_final is not None and gig.amount_final > gig.amount_minimum:
        has_succeeded_difference = db.execute(
            select(StripePayment.id).where(
                StripePayment.gig_id == gig.id,
                StripePayment.kind == StripePaymentKind.difference,
                StripePayment.status == PaymentStatus.succeeded,
            )
        ).first()
        if not has_succeeded_difference:
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

    succeeded = list_succeeded_payments_for_gig(db, gig.id, kinds=[StripePaymentKind.base, StripePaymentKind.difference])
    if succeeded:
        gross_eur = sum((p.amount for p in succeeded), Decimal("0.00"))
        create_earnings_entry(
            db,
            pro_user_id=gig.pro_user_id,
            source_type=EarningsSourceType.gig_base,
            source_id=gig.id,
            gross_eur=Decimal(str(gross_eur)),
            metadata={"gig_id": str(gig.id), "payment_intent_ids": [p.stripe_payment_intent_id for p in succeeded]},
        )

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
