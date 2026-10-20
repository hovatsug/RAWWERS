from __future__ import annotations

import logging

import uuid
from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session
from app.core.config import get_settings
from app.core.constants import SYSTEM_USER_ID
from app.core.errors import APIError
from app.models.gig import (
    Gig,
    GigStatus,
    LedgerEntry,
    LedgerEntryType,
    PaymentStatus,
    StripePayment,
    StripePaymentKind,
)
from app.models.gallery import ClientSelection, ProofGallery, SelectionStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.media import MediaAsset, MediaProvider, MediaStatus
from app.models.media_rights import GigEntitlementType
from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.admin import ProProfile
from app.models.proof_of_gigs import RawwIssuanceEventType
from app.schemas.webhooks import WebhookAckResponse
from app.services.audit import add_admin_audit_log
from app.services.analytics import log_event
from app.services.discovery_index import recompute_pro_public_index
from app.services.gamification import queue_evaluate_user_milestones
from app.services.gig_state import transition_gig
from app.services.niche_skills import recompute_pro_niche_skills
from app.services.outbox import enqueue_outbox_event
from app.services.rewards import (
    apply_redemption_for_context,
    release_redemption_for_context,
)
from app.services.growth_engine import maybe_issue_referral_conversion_reward
from app.services.store import finalize_order_payment_success, handle_order_payment_failure
from app.services.security import verify_mux_webhook_signature
from app.services.stripe_connect import status_from_account
from app.services.stripe_service import construct_stripe_event, to_cents
from app.models.reward import RedemptionContextType
from app.models.reward import ReferralConversionType
from app.models.ops import WebhookSecurityLog
from app.services.abuse import detect_payment_failures_anomaly
from app.services.metrics import observe_business_event, observe_payout_volume, observe_webhook
from app.services.media_rights import increment_entitlement_quantity
from app.services.client_rewards_pricing import increment_share_link_conversion
from app.services.refund_reconcile import REFUND_EVENT_TYPES, reconcile_payment_refunds
from app.services.gallery_completion import finalize_gallery_and_complete_gig, is_selection_fully_paid
from app.services.proof_of_gigs import enqueue_raww_mint
from app.services.payouts import (
    create_earnings_entry,
    reverse_earnings_entries_for_source,
)
from app.services.prints_fulfillment import on_print_payment_failed, on_print_payment_succeeded, on_print_refund_event
from app.models.payouts import EarningsSourceType, PayoutAccount, PayoutAccountStatus, PayoutEvent, PayoutRequest, PayoutRequestStatus
from app.tasks.store_tasks import submit_order_to_partner_task
from app.tasks.outbox_tasks import dispatch_outbox_events_task
from app.services.trust_safety import evaluate_payment_failure_rule


logger = logging.getLogger(__name__)

#: Every Stripe event this webhook acts on - each one Stripe really sends,
#: held against captured events by tests/test_stripe_event_contract.py. The
#: endpoints are registered with exactly these (scripts/register_stripe_webhook.py).
CONNECT_STRIPE_EVENTS = frozenset({"account.updated"})
HANDLED_STRIPE_EVENTS = frozenset(
    {
        "payment_intent.succeeded",
        "payment_intent.payment_failed",
        "payment_intent.canceled",
        *REFUND_EVENT_TYPES,
        "charge.dispute.created",
        "transfer.created",
        "transfer.reversed",
        *CONNECT_STRIPE_EVENTS,
    }
)

router = APIRouter(prefix="/webhooks", tags=["webhooks"])
settings = get_settings()


@router.post("/mux", response_model=WebhookAckResponse)
async def mux_webhook(request: Request, db: Session = Depends(get_db_session)) -> WebhookAckResponse:
    raw_body = await request.body()
    sig_header = request.headers.get("mux-signature")
    try:
        payload = await request.json()
    except Exception:
        payload = {}
    event_id = payload.get("id")
    signature_ok = verify_mux_webhook_signature(raw_body, sig_header)
    observe_webhook("mux", payload.get("type", "unknown"), signature_ok)
    _log_webhook_security_event(
        db,
        provider="mux",
        event_id=event_id,
        signature_valid=signature_ok,
        ip=_request_ip(request),
        metadata={"header_present": bool(sig_header)},
    )
    if not signature_ok:
        db.commit()
        raise APIError(code="invalid_signature", message="Invalid Mux webhook signature", status_code=401)
    if not event_id:
        raise APIError(code="invalid_payload", message="Missing webhook event id", status_code=422)
    row = enqueue_outbox_event(
        db,
        topic="mux.event",
        payload=payload,
        idempotency_key=f"mux:{event_id}",
        idempotency_scope="mux_ingest",
    )
    db.commit()
    if row:
        try:
            dispatch_outbox_events_task.delay()
        except Exception:
            pass
    return WebhookAckResponse(ok=True)


@router.post("/stripe", response_model=WebhookAckResponse)
async def stripe_webhook(request: Request, db: Session = Depends(get_db_session)) -> WebhookAckResponse:
    raw_body = await request.body()
    signature = request.headers.get("stripe-signature")
    try:
        event = construct_stripe_event(raw_body, signature)
        signature_ok = True
    except APIError as exc:
        _log_webhook_security_event(
            db,
            provider="stripe",
            event_id=None,
            signature_valid=False,
            ip=_request_ip(request),
            metadata={"error": exc.code, "header_present": bool(signature)},
        )
        observe_webhook("stripe", "unknown", False)
        db.commit()
        raise

    event_id = event.get("id")
    # The endpoint is pinned to our API version, so payloads match what our
    # calls ask for. Another version means it was registered wrongly; the
    # refund path is safe either way (it fetches from Stripe), the rest reads
    # the payload, so say so loudly.
    pinned = get_settings().stripe_api_version
    if pinned and event.get("api_version") and event.get("api_version") != pinned:
        logger.warning(
            "stripe_event_api_version_mismatch",
            extra={"event_id": event_id, "event_api_version": event.get("api_version"), "pinned": pinned},
        )
    _log_webhook_security_event(
        db,
        provider="stripe",
        event_id=event_id,
        signature_valid=signature_ok,
        ip=_request_ip(request),
        metadata={"event_type": event.get("type", "unknown")},
    )
    observe_webhook("stripe", event.get("type", "unknown"), signature_ok)
    if not event_id:
        raise APIError(code="invalid_payload", message="Missing Stripe event id", status_code=400)
    row = enqueue_outbox_event(
        db,
        topic="stripe.event",
        payload=event,
        idempotency_key=f"stripe:{event_id}",
        idempotency_scope="stripe_ingest",
    )
    db.commit()
    if row:
        try:
            dispatch_outbox_events_task.delay()
        except Exception:
            pass
    return WebhookAckResponse(ok=True)


def _apply_mux_event(db: Session, event_type: str, data: dict) -> None:
    if event_type == "video.upload.asset_created":
        upload_id = data.get("id")
        asset_id = data.get("asset_id")
        if not upload_id or not asset_id:
            return
        asset = db.execute(
            select(MediaAsset).where(
                MediaAsset.provider == MediaProvider.mux,
                MediaAsset.provider_upload_id == upload_id,
            )
        ).scalar_one_or_none()
        if not asset:
            return
        asset.provider_asset_id = asset_id
        asset.meta = {**asset.meta, "mux_asset_id": asset_id}

    elif event_type == "video.asset.ready":
        mux_asset_id = data.get("id")
        playback_ids = data.get("playback_ids") or []
        playback_id = playback_ids[0].get("id") if playback_ids else None
        if not mux_asset_id:
            return
        asset = db.execute(
            select(MediaAsset).where(
                MediaAsset.provider == MediaProvider.mux,
                MediaAsset.provider_asset_id == mux_asset_id,
            )
        ).scalar_one_or_none()
        if not asset:
            return
        asset.status = MediaStatus.ready
        new_meta = {**asset.meta, "mux_asset_id": mux_asset_id}
        if playback_id:
            new_meta["playback_id"] = playback_id
        asset.meta = new_meta

    elif event_type == "video.asset.errored":
        mux_asset_id = data.get("id")
        if not mux_asset_id:
            return
        asset = db.execute(
            select(MediaAsset).where(
                MediaAsset.provider == MediaProvider.mux,
                MediaAsset.provider_asset_id == mux_asset_id,
            )
        ).scalar_one_or_none()
        if not asset:
            return
        asset.status = MediaStatus.failed
        error_message = data.get("errors") or data.get("error") or "Unknown Mux processing error"
        asset.meta = {**asset.meta, "mux_error": error_message}


def _apply_stripe_event(db: Session, event_type: str, obj: dict) -> None:
    if event_type == "payment_intent.succeeded":
        payment_intent_id = obj.get("id")
        if not payment_intent_id:
            logger.warning("stripe_succeeded_without_id")
            return
        # This function has several early returns for other kinds of
        # payment (store orders, prints, upsells). Each one is now named,
        # so an event that applies to none of them says which it matched
        # rather than looking identical to one that applied cleanly.
        order = finalize_order_payment_success(db, payment_intent_id)
        if order:
            logger.info("stripe_succeeded_matched_store_order",
                        extra={"payment_intent_id": payment_intent_id, "order_id": str(order.id)})
            try:
                submit_order_to_partner_task.delay(str(order.id))
            except Exception:
                from app.services.store import submit_order_to_partner

                submit_order_to_partner(db, order.id)
            return
        print_order = on_print_payment_succeeded(db, payment_intent_id=payment_intent_id)
        if print_order:
            return

        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            gallery = db.get(ProofGallery, upsell.gallery_id)
            if not gallery:
                return
            gig = db.get(Gig, gallery.gig_id)
            if not gig:
                return

            upsell.status = UpsellPurchaseStatus.succeeded
            snapshot = db.execute(
                select(ExtraImagePurchase).where(ExtraImagePurchase.stripe_payment_intent_id == payment_intent_id)
            ).scalar_one_or_none()
            if snapshot:
                snapshot.status = ExtraImagePurchaseStatus.paid
                if snapshot.share_link_id:
                    increment_share_link_conversion(db, share_link_id=snapshot.share_link_id, count=1)
                create_earnings_entry(
                    db,
                    pro_user_id=snapshot.pro_user_id,
                    source_type=EarningsSourceType.extra_images,
                    source_id=snapshot.id,
                    gross_eur=Decimal(str(snapshot.total or 0)),
                    metadata={"gig_id": str(snapshot.gig_id)},
                )
                enqueue_raww_mint(
                    db,
                    event_type=RawwIssuanceEventType.gig_extras_purchased,
                    payload={"extra_purchase_id": str(snapshot.id)},
                    idempotency_key=f"raww:gig_extras:{snapshot.id}",
                )
                referral_result = maybe_issue_referral_conversion_reward(
                    db,
                    referee_user_id=snapshot.client_user_id,
                    conversion_type=ReferralConversionType.extras_paid,
                    conversion_id=snapshot.id,
                    conversion_value_eur=Decimal(str(snapshot.total or 0)),
                    share_link_id=snapshot.share_link_id,
                )
                if referral_result.grant:
                    log_event(
                        db,
                        event_name="referral.converted",
                        user_id=snapshot.client_user_id,
                        properties={"conversion_type": "extras_paid", "conversion_id": str(snapshot.id)},
                    )
            increment_entitlement_quantity(
                db,
                gig_id=gallery.gig_id,
                user_id=gallery.client_user_id,
                entitlement_type=GigEntitlementType.download_extras,
                delta=upsell.extra_count,
            )
            selection = db.get(ClientSelection, upsell.selection_id)
            if selection and is_selection_fully_paid(db, gig=gig, gallery=gallery, selection=selection):
                finalize_gallery_and_complete_gig(db, gallery=gallery, gig=gig, selection=selection)
            observe_business_event("upsell_purchase_succeeded")
            redemption = apply_redemption_for_context(db, RedemptionContextType.upsell_purchase, upsell.id)
            if redemption:
                log_event(
                    db,
                    event_name="reward.spent",
                    user_id=redemption.user_id,
                    properties={
                        "context_type": "upsell_purchase",
                        "context_id": str(upsell.id),
                        "status": "applied",
                        "points_spent": redemption.points_spent,
                        "discount_amount": str(redemption.discount_amount),
                    },
                )

            if not _ledger_reference_exists(db, gig.id, LedgerEntryType.upsell_captured, payment_intent_id):
                platform_fee = (upsell.amount * Decimal(settings.platform_fee_bps) / Decimal("10000")).quantize(Decimal("0.01"))
                payout_hold = (upsell.amount - platform_fee).quantize(Decimal("0.01"))
                db.add(
                    LedgerEntry(
                        gig_id=gig.id,
                        entry_type=LedgerEntryType.upsell_captured,
                        amount=upsell.amount,
                        currency=upsell.currency,
                        description="Upsell payment captured",
                        reference_type="upsell_payment_intent",
                        reference_id=payment_intent_id,
                    )
                )
                db.add(
                    LedgerEntry(
                        gig_id=gig.id,
                        entry_type=LedgerEntryType.upsell_platform_fee,
                        amount=platform_fee,
                        currency=upsell.currency,
                        description="Upsell platform fee recognized",
                        reference_type="upsell_payment_intent",
                        reference_id=payment_intent_id,
                    )
                )
                db.add(
                    LedgerEntry(
                        gig_id=gig.id,
                        entry_type=LedgerEntryType.upsell_payout_hold_created,
                        amount=Decimal("0.00"),
                        currency=upsell.currency,
                        description=f"Upsell payout hold created: {payout_hold}",
                        reference_type="upsell_payment_intent",
                        reference_id=payment_intent_id,
                    )
                )

            add_admin_audit_log(
                db,
                actor_user_id=SYSTEM_USER_ID,
                target_type="gallery",
                target_id=str(gallery.id),
                action="upsell_succeeded",
                reason=None,
                metadata={"upsell_purchase_id": str(upsell.id), "payment_intent_id": payment_intent_id},
            )
            queue_evaluate_user_milestones(gallery.client_user_id, gig.niche_id)
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            # Every early return on the money path is logged. A
            # payment_intent.succeeded that reaches the end of this function
            # without moving a gig is the failure that ends a photographer's
            # relationship with the platform - client charged, Stripe
            # reporting success, gig silently unpaid - and it must never
            # again be something we can only observe after the fact.
            logger.warning("stripe_succeeded_no_payment_row",
                           extra={"payment_intent_id": payment_intent_id})
            return

        gig = db.get(Gig, payment.gig_id)
        if not gig:
            logger.warning("stripe_succeeded_no_gig",
                           extra={"payment_intent_id": payment_intent_id,
                                  "gig_id": str(payment.gig_id)})
            return
        logger.info("stripe_succeeded_applying",
                    extra={"payment_intent_id": payment_intent_id, "gig_id": str(gig.id),
                           "payment_status_before": payment.status.value,
                           "gig_status_before": gig.status.value})

        payment.status = PaymentStatus.succeeded
        payment.last_error = None
        payment.meta = {**payment.meta, "paid_at": datetime.now(timezone.utc).isoformat()}

        # Trust what Stripe collected over what we meant to ask for. The row's
        # amount is our intention; `amount_received` is the fact, and the
        # ledger and every "is this paid" comparison read the row. They
        # diverged once already - a stale intent charged the old amount while
        # the row said the new one - and nothing noticed, because nothing ever
        # compared them. Absent on some event shapes, in which case there is
        # nothing to compare.
        received_cents = obj.get("amount_received")
        if received_cents is not None and int(received_cents) != to_cents(payment.amount):
            received_amount = (Decimal(int(received_cents)) / Decimal("100")).quantize(Decimal("0.01"))
            logger.warning(
                "stripe_amount_mismatch",
                extra={
                    "payment_intent_id": payment_intent_id,
                    "gig_id": str(gig.id),
                    "kind": payment.kind.value,
                    "expected": str(payment.amount),
                    "received": str(received_amount),
                },
            )
            payment.meta = {
                **payment.meta,
                "amount_mismatch": {"expected": str(payment.amount), "received": str(received_amount)},
            }
            add_admin_audit_log(
                db,
                actor_user_id=SYSTEM_USER_ID,
                target_type="gig",
                target_id=str(gig.id),
                action="stripe_amount_mismatch",
                reason=f"{payment.kind.value} payment {payment_intent_id}: expected {payment.amount}, Stripe received {received_amount}",
                metadata={"payment_intent_id": payment_intent_id, "expected": str(payment.amount), "received": str(received_amount)},
            )
            payment.amount = received_amount

        if gig.status != GigStatus.paid:
            transition = transition_gig(gig, GigStatus.paid, SYSTEM_USER_ID, reason="Stripe payment_intent.succeeded")
            db.add(transition)

        if not _ledger_reference_exists(db, gig.id, LedgerEntryType.payment_captured, payment_intent_id):
            platform_fee = min(gig.amount_platform_fee, payment.amount)
            payout_hold = max(Decimal("0.00"), payment.amount - platform_fee)
            db.add(
                LedgerEntry(
                    gig_id=gig.id,
                    entry_type=LedgerEntryType.payment_captured,
                    amount=payment.amount,
                    currency=gig.currency,
                    description="Stripe payment captured",
                    reference_type="stripe_payment_intent",
                    reference_id=payment_intent_id,
                )
            )
            db.add(
                LedgerEntry(
                    gig_id=gig.id,
                    entry_type=LedgerEntryType.platform_fee,
                    amount=platform_fee,
                    currency=gig.currency,
                    description="Platform fee recognized",
                    reference_type="stripe_payment_intent",
                    reference_id=payment_intent_id,
                )
            )
            db.add(
                LedgerEntry(
                    gig_id=gig.id,
                    entry_type=LedgerEntryType.payout_hold_created,
                    amount=Decimal("0.00"),
                    currency=gig.currency,
                    description=f"Payout hold created: {payout_hold}",
                    reference_type="stripe_payment_intent",
                    reference_id=payment_intent_id,
                )
            )

        log_event(
            db,
            event_name="payment.succeeded",
            user_id=gig.client_user_id,
            properties={"gig_id": str(gig.id), "payment_intent_id": payment_intent_id},
        )
        pro_profile = db.get(ProProfile, gig.pro_user_id)
        log_event(
            db,
            event_name="client.payment_succeeded",
            user_id=gig.client_user_id,
            properties={
                "gig_id": str(gig.id),
                "payment_intent_id": payment_intent_id,
                "country": pro_profile.country if pro_profile else None,
                "city": pro_profile.city if pro_profile else None,
            },
        )
        observe_business_event("payment_succeeded")
        redemption = apply_redemption_for_context(db, RedemptionContextType.gig_payment, gig.id)
        if redemption:
            log_event(
                db,
                event_name="reward.spent",
                user_id=redemption.user_id,
                properties={
                    "context_type": "gig_payment",
                    "context_id": str(gig.id),
                    "status": "applied",
                    "points_spent": redemption.points_spent,
                    "discount_amount": str(redemption.discount_amount),
                },
            )
        referral_result = maybe_issue_referral_conversion_reward(
            db,
            referee_user_id=gig.client_user_id,
            conversion_type=ReferralConversionType.booking_paid,
            conversion_id=gig.id,
            conversion_value_eur=Decimal(gig.amount_minimum),
            share_link_id=None,
        )
        if referral_result.grant:
            log_event(
                db,
                event_name="reward.earned",
                user_id=gig.client_user_id,
                properties={
                    "conversion_type": "booking_paid",
                    "conversion_id": str(gig.id),
                    "grant_id": str(referral_result.grant.id),
                    "reward_entry_ids": [str(item) for item in referral_result.reward_entry_ids],
                },
            )
            log_event(
                db,
                event_name="referral.converted",
                user_id=gig.client_user_id,
                properties={"conversion_type": "booking_paid", "conversion_id": str(gig.id)},
            )
        recompute_pro_public_index(db, gig.pro_user_id)
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)

        if payment.kind == StripePaymentKind.difference:
            gallery = db.execute(select(ProofGallery).where(ProofGallery.gig_id == gig.id)).scalar_one_or_none()
            selection = (
                db.execute(
                    select(ClientSelection)
                    .where(ClientSelection.gallery_id == gallery.id, ClientSelection.status == SelectionStatus.submitted)
                    .order_by(ClientSelection.version.desc())
                ).scalars().first()
                if gallery
                else None
            )
            if gallery and selection and is_selection_fully_paid(db, gig=gig, gallery=gallery, selection=selection):
                finalize_gallery_and_complete_gig(db, gallery=gallery, gig=gig, selection=selection)

    elif event_type == "payment_intent.payment_failed":
        payment_intent_id = obj.get("id")
        if not payment_intent_id:
            return
        order = handle_order_payment_failure(db, payment_intent_id, cancelled=False)
        if order:
            return
        print_order = on_print_payment_failed(
            db,
            payment_intent_id=payment_intent_id,
            reason=((obj.get("last_payment_error") or {}).get("message") if isinstance(obj.get("last_payment_error"), dict) else None),
        )
        if print_order:
            return

        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            upsell.status = UpsellPurchaseStatus.failed
            snapshot = db.execute(
                select(ExtraImagePurchase).where(ExtraImagePurchase.stripe_payment_intent_id == payment_intent_id)
            ).scalar_one_or_none()
            if snapshot:
                snapshot.status = ExtraImagePurchaseStatus.failed
            redemption = release_redemption_for_context(
                db,
                RedemptionContextType.upsell_purchase,
                upsell.id,
                reason="payment_intent_failed",
            )
            if redemption:
                log_event(
                    db,
                    event_name="reward.spent",
                    user_id=redemption.user_id,
                    properties={"context_type": "upsell_purchase", "context_id": str(upsell.id), "status": "released"},
                )
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            return

        payment.status = PaymentStatus.failed
        last_payment_error = obj.get("last_payment_error") or {}
        payment.last_error = last_payment_error.get("message", "Payment failed")
        detect_payment_failures_anomaly(db, client_user_id=payment.client_user_id, payment_intent_id=payment_intent_id)
        evaluate_payment_failure_rule(db, user_id=payment.client_user_id)
        gig = db.get(Gig, payment.gig_id)
        if gig:
            redemption = release_redemption_for_context(
                db,
                RedemptionContextType.gig_payment,
                gig.id,
                reason="payment_intent_failed",
            )
            if redemption:
                log_event(
                    db,
                    event_name="reward.spent",
                    user_id=redemption.user_id,
                    properties={"context_type": "gig_payment", "context_id": str(gig.id), "status": "released"},
                )

    elif event_type == "payment_intent.canceled":
        payment_intent_id = obj.get("id")
        if not payment_intent_id:
            return
        order = handle_order_payment_failure(db, payment_intent_id, cancelled=True)
        if order:
            return
        print_order = on_print_payment_failed(db, payment_intent_id=payment_intent_id, reason="payment_intent_cancelled")
        if print_order:
            return
        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            upsell.status = UpsellPurchaseStatus.failed
            snapshot = db.execute(
                select(ExtraImagePurchase).where(ExtraImagePurchase.stripe_payment_intent_id == payment_intent_id)
            ).scalar_one_or_none()
            if snapshot:
                snapshot.status = ExtraImagePurchaseStatus.failed
            release_redemption_for_context(
                db,
                RedemptionContextType.upsell_purchase,
                upsell.id,
                reason="payment_intent_cancelled",
            )
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            return
        payment.status = PaymentStatus.cancelled
        gig = db.get(Gig, payment.gig_id)
        if gig:
            release_redemption_for_context(
                db,
                RedemptionContextType.gig_payment,
                gig.id,
                reason="payment_intent_cancelled",
            )

    elif event_type in REFUND_EVENT_TYPES:
        # Every refund event only names the payment: Stripe is asked for the
        # payment's refunds and our records reconciled to them, whatever the
        # order or number of events (services/refund_reconcile).
        payment_intent_id = obj.get("payment_intent")
        if not payment_intent_id:
            return
        # Prints and extra-image purchases keep their own paths, which act on
        # the charge event.
        if event_type == "charge.refunded":
            if on_print_refund_event(db, payment_intent_id=payment_intent_id, refund_ref=None):
                return
            upsell = db.execute(
                select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
            ).scalar_one_or_none()
            if upsell:
                upsell.status = UpsellPurchaseStatus.refunded
                snapshot = db.execute(
                    select(ExtraImagePurchase).where(ExtraImagePurchase.stripe_payment_intent_id == payment_intent_id)
                ).scalar_one_or_none()
                if snapshot:
                    snapshot.status = ExtraImagePurchaseStatus.refunded
                    reverse_earnings_entries_for_source(
                        db,
                        source_type=EarningsSourceType.extra_images,
                        source_id=snapshot.id,
                        reason="stripe_refund",
                    )
                return

        if not reconcile_payment_refunds(db, payment_intent_id, trigger=event_type):
            return
        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one()
        gig = db.get(Gig, payment.gig_id)
        recompute_pro_public_index(db, gig.pro_user_id)
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)

    elif event_type == "charge.dispute.created":
        payment_intent_id = obj.get("payment_intent")
        dispute_id = obj.get("id")
        if not payment_intent_id:
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            return

        gig = db.get(Gig, payment.gig_id)
        if not gig:
            return

        payment.status = PaymentStatus.disputed
        if gig.status != GigStatus.disputed:
            transition = transition_gig(gig, GigStatus.disputed, SYSTEM_USER_ID, reason="Stripe dispute opened")
            db.add(transition)

        ref_id = dispute_id or f"dispute:{payment_intent_id}"
        if not _ledger_reference_exists(db, gig.id, LedgerEntryType.chargeback_opened, ref_id):
            db.add(
                LedgerEntry(
                    gig_id=gig.id,
                    entry_type=LedgerEntryType.chargeback_opened,
                    amount=-payment.amount,
                    currency=gig.currency,
                    description="Chargeback/dispute opened",
                    reference_type="stripe_dispute",
                    reference_id=ref_id,
                )
            )
        recompute_pro_public_index(db, gig.pro_user_id)
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)

    elif event_type == "transfer.created":
        # execute_payout_request already marks the PayoutRequest paid
        # synchronously when stripe.Transfer.create() returns - this is a
        # reconciliation confirmation, not the primary path. It matters if
        # the app crashed/timed out between the Stripe call succeeding and
        # that DB write committing.
        payout_request_id = (obj.get("metadata") or {}).get("payout_request_id")
        if not payout_request_id:
            return
        try:
            row = db.get(PayoutRequest, uuid.UUID(payout_request_id))
        except ValueError:
            return
        if not row:
            return

        if row.status != PayoutRequestStatus.paid:
            row.status = PayoutRequestStatus.paid
            row.paid_at = datetime.now(timezone.utc)
            row.reference = {**(row.reference or {}), "stripe_transfer_id": obj.get("id")}
            row.updated_at = datetime.now(timezone.utc)
            observe_payout_volume(float(row.amount_eur))

        if not _payout_event_recorded(db, row.id, "transfer_created"):
            db.add(PayoutEvent(payout_request_id=row.id, type="transfer_created", payload={"stripe_transfer_id": obj.get("id")}))
            log_event(
                db,
                event_name="payout.transfer_created",
                user_id=row.pro_user_id,
                properties={"payout_request_id": str(row.id), "stripe_transfer_id": obj.get("id")},
            )
            observe_business_event("payout_transfer_created")

    elif event_type == "transfer.reversed":
        # A transfer already reported as paid, taken back in full - e.g. the
        # destination account was closed or restricted after the Stripe API
        # call succeeded. Stripe has no "transfer.failed": this branch used
        # to wait for that name and never ran. A partial reversal leaves the
        # payout paid (an admin sees it in Stripe).
        if not obj.get("reversed"):
            return
        payout_request_id = (obj.get("metadata") or {}).get("payout_request_id")
        if not payout_request_id:
            return
        try:
            row = db.get(PayoutRequest, uuid.UUID(payout_request_id))
        except ValueError:
            return
        if not row:
            return
        if _payout_event_recorded(db, row.id, "transfer_reversed"):
            return

        row.status = PayoutRequestStatus.failed
        row.failure_reason = (obj.get("failure_message") or "Stripe transfer reversed")[:500]
        row.updated_at = datetime.now(timezone.utc)
        db.add(PayoutEvent(payout_request_id=row.id, type="transfer_reversed", payload={"stripe_transfer_id": obj.get("id"), "reason": row.failure_reason}))
        add_admin_audit_log(
            db,
            actor_user_id=SYSTEM_USER_ID,
            target_type="payout_request",
            target_id=str(row.id),
            action="transfer_reversed",
            reason=row.failure_reason,
            metadata={"stripe_transfer_id": obj.get("id")},
        )
        log_event(
            db,
            event_name="payout.transfer_reversed",
            user_id=row.pro_user_id,
            properties={"payout_request_id": str(row.id), "reason": row.failure_reason},
        )
        observe_business_event("payout_transfer_reversed")

    elif event_type == "account.updated":
        stripe_account_id = obj.get("id")
        if not stripe_account_id:
            return
        account = db.execute(
            select(PayoutAccount).where(PayoutAccount.stripe_connect_account_id == stripe_account_id)
        ).scalar_one_or_none()
        if not account:
            return

        charges_enabled = bool(obj.get("charges_enabled"))
        payouts_enabled = bool(obj.get("payouts_enabled"))
        details_submitted = bool(obj.get("details_submitted"))
        disabled_reason = (obj.get("requirements") or {}).get("disabled_reason")

        # Shared with the live status read rather than reimplemented here.
        # The two copies this replaces disagreed on a real account: this one
        # wrote "disabled" for a freshly created account, the other could not
        # write "disabled" at all.
        new_status = status_from_account(obj)

        if account.status != new_status:
            previous_status = account.status
            account.status = new_status
            account.updated_at = datetime.now(timezone.utc)
            add_admin_audit_log(
                db,
                actor_user_id=SYSTEM_USER_ID,
                target_type="payout_account",
                target_id=str(account.pro_user_id),
                action="payout_account_status_updated",
                reason="Stripe account.updated",
                metadata={
                    "stripe_account_id": stripe_account_id,
                    "from_status": previous_status.value,
                    "to_status": new_status.value,
                    "charges_enabled": charges_enabled,
                    "payouts_enabled": payouts_enabled,
                    "details_submitted": details_submitted,
                    "disabled_reason": disabled_reason,
                },
            )
            log_event(
                db,
                event_name="payout.account_updated",
                user_id=account.pro_user_id,
                properties={"stripe_account_id": stripe_account_id, "status": new_status.value},
            )
            observe_business_event("payout_account_updated")


def _payout_event_recorded(db: Session, payout_request_id, event_type: str) -> bool:
    return db.execute(
        select(PayoutEvent.id).where(PayoutEvent.payout_request_id == payout_request_id, PayoutEvent.type == event_type)
    ).first() is not None


def _ledger_reference_exists(db: Session, gig_id, entry_type: LedgerEntryType, reference_id: str) -> bool:
    existing = db.execute(
        select(LedgerEntry.id).where(
            LedgerEntry.gig_id == gig_id,
            LedgerEntry.entry_type == entry_type,
            LedgerEntry.reference_id == reference_id,
        )
    ).scalar_one_or_none()
    return existing is not None


def _request_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


def _log_webhook_security_event(
    db: Session,
    *,
    provider: str,
    event_id: str | None,
    signature_valid: bool,
    ip: str | None,
    metadata: dict | None,
) -> None:
    db.add(
        WebhookSecurityLog(
            provider=provider,
            event_id=event_id,
            signature_valid=signature_valid,
            ip=ip,
            meta=metadata or {},
        )
    )
