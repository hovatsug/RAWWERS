from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
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
    StripeWebhookEvent,
)
from app.models.admin import RefundCase, RefundCaseStatus
from app.models.gallery import ProofGallery, ProofGalleryStatus, UpsellPurchase, UpsellPurchaseStatus
from app.models.media import MediaAsset, MediaProvider, MediaStatus, WebhookEvent, WebhookProvider
from app.schemas.webhooks import WebhookAckResponse
from app.services.audit import add_admin_audit_log
from app.services.gig_state import transition_gig
from app.services.security import verify_mux_webhook_signature
from app.services.stripe_service import construct_stripe_event

router = APIRouter(prefix="/webhooks", tags=["webhooks"])
settings = get_settings()


@router.post("/mux", response_model=WebhookAckResponse)
async def mux_webhook(request: Request, db: Session = Depends(get_db_session)) -> WebhookAckResponse:
    raw_body = await request.body()
    sig_header = request.headers.get("mux-signature")
    if not verify_mux_webhook_signature(raw_body, sig_header):
        raise APIError(code="invalid_signature", message="Invalid Mux webhook signature", status_code=401)

    payload = await request.json()
    event_id = payload.get("id")
    event_type = payload.get("type", "unknown")
    data = payload.get("data", {})

    if not event_id:
        raise APIError(code="invalid_payload", message="Missing webhook event id", status_code=422)

    event = WebhookEvent(
        provider=WebhookProvider.mux,
        external_event_id=event_id,
        event_type=event_type,
        received_at=datetime.now(timezone.utc),
        payload=payload,
    )
    db.add(event)
    try:
        db.flush()
    except IntegrityError:
        db.rollback()
        return WebhookAckResponse(ok=True)

    _apply_mux_event(db, event_type, data)
    db.commit()
    return WebhookAckResponse(ok=True)


@router.post("/stripe", response_model=WebhookAckResponse)
async def stripe_webhook(request: Request, db: Session = Depends(get_db_session)) -> WebhookAckResponse:
    raw_body = await request.body()
    signature = request.headers.get("stripe-signature")
    event = construct_stripe_event(raw_body, signature)

    event_id = event.get("id")
    event_type = event.get("type", "unknown")
    payload = event.get("data", {}).get("object", {})

    if not event_id:
        raise APIError(code="invalid_payload", message="Missing Stripe event id", status_code=400)

    webhook_event = StripeWebhookEvent(
        external_event_id=event_id,
        event_type=event_type,
        payload=event,
        received_at=datetime.now(timezone.utc),
    )
    db.add(webhook_event)
    try:
        db.flush()
    except IntegrityError:
        db.rollback()
        return WebhookAckResponse(ok=True)

    _apply_stripe_event(db, event_type, payload)
    db.commit()
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
            db.add(
                LedgerEntry(
                    gig_id=gig.id,
                    entry_type=LedgerEntryType.payment_captured,
                    amount=gig.amount_total,
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
                    amount=gig.amount_platform_fee,
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
                    description=f"Payout hold created: {gig.amount_pro_gross}",
                    reference_type="stripe_payment_intent",
                    reference_id=payment_intent_id,
                )
            )

    elif event_type == "payment_intent.payment_failed":
        payment_intent_id = obj.get("id")
        if not payment_intent_id:
            return

        upsell = db.execute(
            select(UpsellPurchase).where(UpsellPurchase.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if upsell:
            upsell.status = UpsellPurchaseStatus.failed
            return

        payment = db.execute(
            select(StripePayment).where(StripePayment.stripe_payment_intent_id == payment_intent_id)
        ).scalar_one_or_none()
        if not payment:
            return

        payment.status = PaymentStatus.failed
        last_payment_error = obj.get("last_payment_error") or {}
        payment.last_error = last_payment_error.get("message", "Payment failed")

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
                    amount=-gig.amount_total,
                    currency=gig.currency,
                    description="Stripe refund succeeded",
                    reference_type="stripe_refund",
                    reference_id=ref_id,
                )
            )

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
                    amount=-gig.amount_total,
                    currency=gig.currency,
                    description="Chargeback/dispute opened",
                    reference_type="stripe_dispute",
                    reference_id=ref_id,
                )
            )


def _ledger_reference_exists(db: Session, gig_id, entry_type: LedgerEntryType, reference_id: str) -> bool:
    existing = db.execute(
        select(LedgerEntry.id).where(
            LedgerEntry.gig_id == gig_id,
            LedgerEntry.entry_type == entry_type,
            LedgerEntry.reference_id == reference_id,
        )
    ).scalar_one_or_none()
    return existing is not None
