from __future__ import annotations

import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from fastapi import APIRouter, Depends, Query
from sqlalchemy import case, func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_read_session, get_db_session, require_not_banned
from app.core.config import Settings, get_settings
from app.core.errors import APIError
from app.models.gig import Gig, GigStatus, LedgerEntry, LedgerEntryType, PaymentStatus, StripePayment, StripePaymentKind
from app.models.reward import DiscountRedemption, DiscountRedemptionStatus, RedemptionContextType
from app.schemas.gig import (
    CreateGigRequest,
    CreatePaymentIntentRequest,
    CreatePaymentIntentResponse,
    CreateRefundRequest,
    CreateRefundResponse,
    GigDetailResponse,
    GigListResponse,
    GigResponse,
    LedgerSummary,
    PaymentSummary,
)
from app.schemas.media import CurrentUser
from app.services.authz import require_kyc_approved_for_pro
from app.services.analytics import log_event
from app.services.payment_intents import (
    allocate_amount_oldest_first,
    create_or_get_gig_payment_intent,
    list_succeeded_payments_for_gig,
)
from app.services.followups import schedule_followups
from app.services.feature_flags import is_feature_enabled
from app.services.pagination import DEFAULT_LIMIT, MAX_LIMIT, apply_keyset, build_page
from app.services.rate_limit import enforce_named_rate_limit
from app.services.rewards import reserve_points_for_discount
from app.services.stripe_service import is_within_hours
from app.services.media_rights import ensure_gig_consent_snapshot
from app.services.disputes import capture_gig_contract_snapshot

settings = get_settings()
router = APIRouter(prefix="/gigs", tags=["gigs"])


@router.post("", response_model=GigResponse)
def create_gig(
    body: CreateGigRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GigResponse:
    amount_minimum = body.amount_total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    if amount_minimum <= 0:
        raise APIError(code="validation_error", message="amount_total must be > 0", status_code=422)

    fee = (amount_minimum * Decimal(settings.platform_fee_bps) / Decimal(10000)).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )
    pro_gross = (amount_minimum - fee).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    gig = Gig(
        client_user_id=user.user_id,
        pro_user_id=body.pro_user_id,
        niche_id=body.niche_id,
        status=GigStatus.payment_pending,
        currency=body.currency.upper(),
        amount_minimum=amount_minimum,
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
    schedule_followups(
        db,
        trigger="payment_pending.client",
        user_id=gig.client_user_id,
        target_type="gig",
        target_id=gig.id,
    )
    ensure_gig_consent_snapshot(db, gig, actor_user_id=user.user_id)
    capture_gig_contract_snapshot(db, gig)
    db.commit()
    db.refresh(gig)
    return _gig_response(gig)


@router.get("", response_model=GigListResponse)
def list_gigs(
    status: GigStatus | None = Query(default=None),
    scheduled_from: datetime | None = Query(default=None),
    scheduled_to: datetime | None = Query(default=None),
    cursor: str | None = Query(default=None),
    limit: int = Query(default=DEFAULT_LIMIT, ge=1, le=MAX_LIMIT),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_read_session),
) -> GigListResponse:
    """Gigs the caller is party to, newest first.

    Scoped by participation rather than by role: a gig has exactly one pro
    and one client, so `pro_user_id == me OR client_user_id == me` returns
    each side its own gigs from one route, mirroring `_ensure_gig_access` on
    the detail route. No role lookup is needed and a user who is both a pro
    and a client (the common case - every pro registers as a client first)
    correctly sees both sides.

    The date range filters on `scheduled_start`, which is the field a
    calendar screen orders by, and is nullable: an unscheduled gig has no
    date, so passing either bound excludes gigs that aren't scheduled yet.
    Ordering stays on `created_at` regardless, so the keyset cursor remains
    total and stable across pages.
    """
    query = select(Gig).where(or_(Gig.pro_user_id == user.user_id, Gig.client_user_id == user.user_id))
    if status is not None:
        query = query.where(Gig.status == status)
    if scheduled_from is not None:
        query = query.where(Gig.scheduled_start.is_not(None), Gig.scheduled_start >= scheduled_from)
    if scheduled_to is not None:
        query = query.where(Gig.scheduled_start.is_not(None), Gig.scheduled_start <= scheduled_to)

    rows = db.execute(apply_keyset(query, Gig, cursor, limit)).scalars().all()
    page, next_cursor = build_page(list(rows), limit)
    return GigListResponse(items=[_gig_response(row) for row in page], next_cursor=next_cursor)


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

    payment = db.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.base)
    ).scalar_one_or_none()

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
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CreatePaymentIntentResponse:
    enforce_named_rate_limit("payments", principal=str(user.user_id))
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)

    if gig.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only the client can create payment intent", status_code=403)
    if gig.status != GigStatus.payment_pending:
        raise APIError(code="invalid_state", message="Gig must be payment_pending", status_code=409)

    _enforce_pro_kyc_for_payment(db, gig, settings)

    existing_payment = db.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.base)
    ).scalar_one_or_none()
    existing_redemption = db.execute(
        select(DiscountRedemption).where(
            DiscountRedemption.user_id == user.user_id,
            DiscountRedemption.context_type == RedemptionContextType.gig_payment,
            DiscountRedemption.context_id == gig.id,
            DiscountRedemption.status.in_([DiscountRedemptionStatus.reserved, DiscountRedemptionStatus.applied]),
        )
    ).scalar_one_or_none()

    points_redemption = None
    if body.points_to_spend:
        if not is_feature_enabled(db, "rewards_spend_enabled", user_id=user.user_id):
            raise APIError(code="feature_disabled", message="Rewards spend is temporarily disabled", status_code=503)
        if existing_payment and not existing_redemption:
            raise APIError(code="invalid_state", message="Cannot apply points after payment intent was created", status_code=409)
        points_redemption = reserve_points_for_discount(
            db,
            user_id=user.user_id,
            context_type=RedemptionContextType.gig_payment,
            context_id=gig.id,
            points=body.points_to_spend,
            payment_amount=gig.amount_minimum,
            currency=gig.currency,
            metadata={"source": "gig_create_intent"},
        )
        log_event(
            db,
            event_name="reward.spent",
            user_id=user.user_id,
            properties={
                "context_type": "gig_payment",
                "context_id": str(gig.id),
                "points_spent": points_redemption.points_spent,
                "discount_amount": str(points_redemption.discount_amount),
            },
        )
    elif existing_redemption:
        points_redemption = existing_redemption

    payable_amount = gig.amount_minimum
    if points_redemption and points_redemption.status == DiscountRedemptionStatus.reserved:
        payable_amount = max(Decimal("0.01"), gig.amount_minimum - points_redemption.discount_amount)

    _, pi = create_or_get_gig_payment_intent(
        db,
        gig,
        payment_method_types=body.payment_method_types or ["card"],
        return_url=body.return_url,
        amount_override=payable_amount,
    )
    db.commit()

    return CreatePaymentIntentResponse(
        payment_intent_client_secret=pi.client_secret,
        payment_intent_id=pi.id,
        status=pi.status,
        discount_amount=points_redemption.discount_amount if points_redemption else None,
        points_spent=points_redemption.points_spent if points_redemption else None,
    )


@router.post("/{gig_id}/refunds/stripe", response_model=CreateRefundResponse)
def create_refund(
    gig_id: uuid.UUID,
    body: CreateRefundRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CreateRefundResponse:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if gig.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client may request refund", status_code=403)
    if gig.status != GigStatus.paid:
        raise APIError(code="invalid_state", message="Gig must be paid to request refund", status_code=409)

    payments = list_succeeded_payments_for_gig(db, gig.id)
    if not payments:
        raise APIError(code="invalid_state", message="No Stripe payment found", status_code=409)

    oldest = payments[0]
    paid_at_raw = oldest.meta.get("paid_at")
    if not paid_at_raw:
        raise APIError(code="invalid_state", message="Payment paid timestamp missing", status_code=409)

    paid_at = datetime.fromisoformat(paid_at_raw)
    if not is_within_hours(paid_at, 24):
        raise APIError(code="refund_not_allowed", message="Refund window is closed", status_code=409)

    if gig.status == GigStatus.shoot_done:
        raise APIError(code="refund_not_allowed", message="Refund not allowed after shoot_done", status_code=409)

    refund_ids: list[str] = []
    last_refund = None
    for payment in payments:
        refund = stripe.Refund.create(
            payment_intent=payment.stripe_payment_intent_id,
            reason="requested_by_customer",
            metadata={
                "gig_id": str(gig.id),
                "reason": body.reason or "client_requested",
            },
            idempotency_key=f"gig:{gig.id}:client-refund:{payment.id}",
        )
        refund_ids.append(refund.id)
        last_refund = refund

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

    return CreateRefundResponse(refund_id=refund_ids[0], status=last_refund.status, refund_ids=refund_ids)


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
        niche_id=gig.niche_id,
        status=gig.status,
        currency=gig.currency,
        amount_minimum=gig.amount_minimum,
        amount_final=gig.amount_final,
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
