from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from fastapi import APIRouter, Depends
from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_not_banned
from app.core.config import Settings, get_settings
from app.core.errors import APIError
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment
from app.schemas.gig import (
    CreateGigRequest,
    CreatePaymentIntentRequest,
    CreatePaymentIntentResponse,
    CreateRefundRequest,
    CreateRefundResponse,
    GigDetailResponse,
    GigResponse,
    LedgerSummary,
    PaymentSummary,
)
from app.schemas.media import CurrentUser
from app.services.authz import require_kyc_approved_for_pro
from app.services.stripe_service import is_within_hours, map_intent_status, to_cents

settings = get_settings()
router = APIRouter(prefix="/gigs", tags=["gigs"])


@router.post("", response_model=GigResponse)
def create_gig(
    body: CreateGigRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigResponse:
    amount_total = body.amount_total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    if amount_total <= 0:
        raise APIError(code="validation_error", message="amount_total must be > 0", status_code=422)

    fee = (amount_total * Decimal(settings.platform_fee_bps) / Decimal(10000)).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )
    pro_gross = (amount_total - fee).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    gig = Gig(
        client_user_id=user.user_id,
        pro_user_id=body.pro_user_id,
        status=GigStatus.payment_pending,
        currency=body.currency.upper(),
        amount_total=amount_total,
        amount_platform_fee=fee,
        amount_pro_gross=pro_gross,
        location_text=body.location_text,
        scheduled_start=body.scheduled_start,
        scheduled_end=body.scheduled_end,
        meta={},
    )
    db.add(gig)
    db.flush()

    db.add(
        transition_gig_seed(
            gig_id=gig.id,
            actor_user_id=user.user_id,
            to_status=GigStatus.payment_pending,
            reason="Gig created and moved to payment pending",
        )
    )
    db.commit()
    db.refresh(gig)
    return _gig_response(gig)


@router.get("/{gig_id}", response_model=GigDetailResponse)
def get_gig(
    gig_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigDetailResponse:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)

    _ensure_gig_access(gig, user.user_id)

    payment = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one_or_none()

    sums = db.execute(
        select(
            func.coalesce(func.sum(case((LedgerEntry.amount > 0, LedgerEntry.amount), else_=0)), 0),
            func.coalesce(func.sum(case((LedgerEntry.amount < 0, LedgerEntry.amount), else_=0)), 0),
            func.coalesce(func.sum(LedgerEntry.amount), 0),
        ).where(LedgerEntry.gig_id == gig.id)
    ).one()

    payment_summary = None
    if payment:
        payment_summary = PaymentSummary(
            status=payment.status,
            stripe_payment_intent_id=payment.stripe_payment_intent_id,
            amount=payment.amount,
            currency=payment.currency,
            last_error=payment.last_error,
        )

    return GigDetailResponse(
        gig=_gig_response(gig),
        payment=payment_summary,
        ledger_summary=LedgerSummary(total_inflow=sums[0], total_outflow=sums[1], net=sums[2]),
    )


@router.post("/{gig_id}/payments/stripe/create-intent", response_model=CreatePaymentIntentResponse)
def create_payment_intent(
    gig_id: uuid.UUID,
    body: CreatePaymentIntentRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> CreatePaymentIntentResponse:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)

    if gig.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only the client can create payment intent", status_code=403)
    if gig.status != GigStatus.payment_pending:
        raise APIError(code="invalid_state", message="Gig must be payment_pending", status_code=409)

    _enforce_pro_kyc_for_payment(db, gig, settings)

    existing = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one_or_none()
    if existing:
        pi = stripe.PaymentIntent.retrieve(existing.stripe_payment_intent_id)
        return CreatePaymentIntentResponse(
            payment_intent_client_secret=pi.client_secret,
            payment_intent_id=pi.id,
            status=pi.status,
        )

    return_url = body.return_url or f"{settings.app_public_url.rstrip('/')}/pay/return"
    pi = stripe.PaymentIntent.create(
        amount=to_cents(gig.amount_total),
        currency=gig.currency.lower(),
        payment_method_types=body.payment_method_types or ["card"],
        metadata={
            "gig_id": str(gig.id),
            "client_user_id": str(gig.client_user_id),
            "pro_user_id": str(gig.pro_user_id),
            "return_url": return_url,
        },
        automatic_payment_methods={"enabled": True},
        idempotency_key=f"gig:{gig.id}:pi",
    )

    mapped_status = PaymentStatus(map_intent_status(pi.status))
    payment = StripePayment(
        gig_id=gig.id,
        client_user_id=gig.client_user_id,
        status=mapped_status,
        stripe_payment_intent_id=pi.id,
        stripe_customer_id=getattr(pi, "customer", None),
        amount=gig.amount_total,
        currency=gig.currency,
        last_error=None,
        meta={"created_from": "create_intent", "created_at": datetime.now(timezone.utc).isoformat()},
    )
    db.add(payment)
    db.add(
        LedgerEntry(
            gig_id=gig.id,
            entry_type=LedgerEntryType.payment_authorized,
            amount=Decimal("0.00"),
            currency=gig.currency,
            description="Stripe PaymentIntent created",
            reference_type="stripe_payment_intent",
            reference_id=pi.id,
        )
    )
    db.commit()

    return CreatePaymentIntentResponse(
        payment_intent_client_secret=pi.client_secret,
        payment_intent_id=pi.id,
        status=pi.status,
    )


@router.post("/{gig_id}/refunds/stripe", response_model=CreateRefundResponse)
def create_refund(
    gig_id: uuid.UUID,
    body: CreateRefundRequest,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> CreateRefundResponse:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if gig.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client may request refund", status_code=403)
    if gig.status != GigStatus.paid:
        raise APIError(code="invalid_state", message="Gig must be paid to request refund", status_code=409)

    payment = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id)).scalar_one_or_none()
    if not payment:
        raise APIError(code="invalid_state", message="No Stripe payment found", status_code=409)

    paid_at_raw = payment.meta.get("paid_at")
    if not paid_at_raw:
        raise APIError(code="invalid_state", message="Payment paid timestamp missing", status_code=409)

    paid_at = datetime.fromisoformat(paid_at_raw)
    if not is_within_hours(paid_at, 24):
        raise APIError(code="refund_not_allowed", message="Refund window is closed", status_code=409)

    if gig.status == GigStatus.shoot_done:
        raise APIError(code="refund_not_allowed", message="Refund not allowed after shoot_done", status_code=409)

    refund = stripe.Refund.create(
        payment_intent=payment.stripe_payment_intent_id,
        reason="requested_by_customer",
        metadata={
            "gig_id": str(gig.id),
            "reason": body.reason or "client_requested",
        },
    )

    db.add(
        LedgerEntry(
            gig_id=gig.id,
            entry_type=LedgerEntryType.refund_initiated,
            amount=Decimal("0.00"),
            currency=gig.currency,
            description=body.reason or "Refund initiated",
            reference_type="stripe_refund",
            reference_id=refund.id,
        )
    )
    db.commit()

    return CreateRefundResponse(refund_id=refund.id, status=refund.status)


def transition_gig_seed(gig_id: uuid.UUID, actor_user_id: uuid.UUID, to_status: GigStatus, reason: str):
    from app.models.gig import GigTransition

    return GigTransition(
        gig_id=gig_id,
        from_status=GigStatus.draft,
        to_status=to_status,
        actor_user_id=actor_user_id,
        reason=reason,
    )


def _ensure_gig_access(gig: Gig, user_id: uuid.UUID) -> None:
    if user_id not in {gig.client_user_id, gig.pro_user_id}:
        raise APIError(code="forbidden", message="Insufficient access to gig", status_code=403)


def _gig_response(gig: Gig) -> GigResponse:
    return GigResponse(
        id=gig.id,
        client_user_id=gig.client_user_id,
        pro_user_id=gig.pro_user_id,
        status=gig.status,
        currency=gig.currency,
        amount_total=gig.amount_total,
        amount_platform_fee=gig.amount_platform_fee,
        amount_pro_gross=gig.amount_pro_gross,
        location_text=gig.location_text,
        scheduled_start=gig.scheduled_start,
        scheduled_end=gig.scheduled_end,
        metadata=gig.meta,
        created_at=gig.created_at,
        updated_at=gig.updated_at,
    )


def _enforce_pro_kyc_for_payment(db: Session, gig: Gig, cfg: Settings) -> None:
    allow_unverified = bool(gig.meta.get("allow_unverified_pro")) if gig.meta else False
    if cfg.app_env.lower() in {"dev", "development"} and allow_unverified:
        return
    require_kyc_approved_for_pro(db, gig.pro_user_id, allow_unverified=False)
