from __future__ import annotations

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
)
from app.models.admin import RefundCase, RefundCaseStatus
from app.models.gallery import ProofGallery, ProofGalleryStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.media import MediaAsset, MediaProvider, MediaStatus
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
    maybe_issue_first_booking_referral_reward,
    release_redemption_for_context,
)
from app.services.store import finalize_order_payment_success, handle_order_payment_failure
from app.services.security import verify_mux_webhook_signature
from app.services.stripe_service import construct_stripe_event
from app.models.reward import RedemptionContextType
from app.models.ops import WebhookSecurityLog
from app.services.abuse import detect_payment_failures_anomaly
from app.services.metrics import observe_business_event, observe_webhook
from app.tasks.store_tasks import submit_order_to_partner_task
from app.tasks.outbox_tasks import dispatch_outbox_events_task

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
            return
        order = finalize_order_payment_success(db, payment_intent_id)
        if order:
            try:
                submit_order_to_partner_task.delay(str(order.id))
            except Exception:
                from app.services.store import submit_order_to_partner

                submit_order_to_partner(db, order.id)
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
            gallery.status = ProofGalleryStatus.selection_submitted
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
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            return

        gig = db.get(Gig, payment.gig_id)
        if not gig:
            return

        payment.status = PaymentStatus.succeeded
        payment.last_error = None
        payment.meta = {**payment.meta, "paid_at": datetime.now(timezone.utc).isoformat()}

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
        reward_entry = maybe_issue_first_booking_referral_reward(db, gig.client_user_id, gig.id)
        if reward_entry:
            log_event(
                db,
                event_name="reward.earned",
                user_id=reward_entry.user_id,
                properties={"rule_code": reward_entry.rule_code, "amount": reward_entry.amount, "gig_id": str(gig.id)},
            )
        recompute_pro_public_index(db, gig.pro_user_id)
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)

    elif event_type == "payment_intent.payment_failed":
        payment_intent_id = obj.get("id")
        if not payment_intent_id:
            return
        order = handle_order_payment_failure(db, payment_intent_id, cancelled=False)
        if order:
            return

        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            upsell.status = UpsellPurchaseStatus.failed
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
        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            upsell.status = UpsellPurchaseStatus.failed
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

    elif event_type in {"charge.refunded", "refund.succeeded"}:
        payment_intent_id = obj.get("payment_intent")
        refund_id = obj.get("id")
        if not payment_intent_id:
            return

        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            upsell.status = UpsellPurchaseStatus.refunded
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            return

        gig = db.get(Gig, payment.gig_id)
        if not gig:
            return

        payment.status = PaymentStatus.refunded
        if gig.status != GigStatus.refunded:
            transition = transition_gig(gig, GigStatus.refunded, SYSTEM_USER_ID, reason="Stripe refund succeeded")
            db.add(transition)

        ref_id = refund_id or f"refund:{payment_intent_id}"
        if not _ledger_reference_exists(db, gig.id, LedgerEntryType.refund_succeeded, ref_id):
            db.add(
                LedgerEntry(
                    gig_id=gig.id,
                    entry_type=LedgerEntryType.refund_succeeded,
                    amount=-payment.amount,
                    currency=gig.currency,
                    description="Stripe refund succeeded",
                    reference_type="stripe_refund",
                    reference_id=ref_id,
                )
            )
        recompute_pro_public_index(db, gig.pro_user_id)
        if gig.niche_id:
            recompute_pro_niche_skills(db, gig.pro_user_id, gig.niche_id)
        queue_evaluate_user_milestones(gig.pro_user_id, gig.niche_id)

        if refund_id:
            refund_cases = db.execute(
                select(RefundCase).where(
                    RefundCase.gig_id == gig.id,
                    RefundCase.status.in_([RefundCaseStatus.processing, RefundCaseStatus.approved]),
                )
            ).scalars().all()
            refund_case = next((item for item in refund_cases if item.meta.get("stripe_refund_id") == refund_id), None)
            if refund_case:
                refund_case.status = RefundCaseStatus.succeeded
                refund_case.meta = {**refund_case.meta, "finalized_by_event": event_type}

    elif event_type == "refund.failed":
        refund_id = obj.get("id")
        if not refund_id:
            return
        refund_cases = db.execute(
            select(RefundCase).where(
                RefundCase.status.in_([RefundCaseStatus.processing, RefundCaseStatus.approved]),
            )
        ).scalars().all()
        refund_case = next((item for item in refund_cases if item.meta.get("stripe_refund_id") == refund_id), None)
        if refund_case:
            refund_case.status = RefundCaseStatus.failed
            refund_case.meta = {**refund_case.meta, "finalized_by_event": event_type}

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
