"""Admin: a booking's money, and lowering its price after payment.

Everything here goes through app/services/price_reduction.py - the one
function that sets the final price, refunds the client the difference and
brings the photographer's earnings down. The routes only validate, preview
and record who did it. Reason codes and the delivery review threshold are
admin-editable data, read and changed here, every change audited.
"""
from __future__ import annotations

import uuid
from decimal import Decimal, InvalidOperation

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin
from app.core.errors import APIError
from app.models.gig import Gig, StripePayment
from app.models.price_reduction import PriceReduction, PriceReductionReason
from app.services.audit import add_admin_audit_log
from app.services.photographer_money import final_price, photographer_money
from app.services.price_reduction import (
    ReductionLine,
    apply_price_reduction,
    delivery_review_policy,
    ensure_default_reasons,
    preview_price_reduction,
)
from app.schemas.media import CurrentUser

router = APIRouter(prefix="/admin", tags=["admin"])


class LineIn(BaseModel):
    reason_code: str
    amount: str


class PreviewIn(BaseModel):
    lines: list[LineIn] = Field(min_length=1)


class ReduceIn(PreviewIn):
    note: str
    idempotency_key: str = Field(min_length=1, max_length=200)


class ReasonUpdateIn(BaseModel):
    label: str | None = None
    client_wording: str | None = None
    may_carry_fault: bool | None = None
    is_active: bool | None = None
    sort_order: int | None = None


class DeliveryPolicyIn(BaseModel):
    shortfall_min_photos: int = Field(ge=1)


def _gig(db: Session, gig_id: uuid.UUID) -> Gig:
    gig = db.get(Gig, gig_id)
    if gig is None:
        raise APIError(code="not_found", message="Booking not found", status_code=404)
    return gig


def _lines(body: PreviewIn) -> list[ReductionLine]:
    try:
        return [ReductionLine(line.reason_code, Decimal(line.amount)) for line in body.lines]
    except InvalidOperation:
        raise APIError(code="validation_error", message="Every amount must be a number", status_code=422) from None


def _reason_view(row: PriceReductionReason) -> dict:
    return {
        "code": row.code, "label": row.label, "client_wording": row.client_wording,
        "may_carry_fault": row.may_carry_fault, "is_active": row.is_active, "sort_order": row.sort_order,
    }


def _labels(db: Session) -> dict[str, str]:
    return {r.code: r.label for r in db.execute(select(PriceReductionReason)).scalars()}


@router.get("/gigs/{gig_id}/money")
def booking_money(gig_id: uuid.UUID, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    gig = _gig(db, gig_id)
    ensure_default_reasons(db)
    labels = _labels(db)
    money = photographer_money(db, gig.pro_user_id)
    payments = db.execute(select(StripePayment).where(StripePayment.gig_id == gig.id).order_by(StripePayment.created_at)).scalars().all()
    reductions = db.execute(select(PriceReduction).where(PriceReduction.gig_id == gig.id).order_by(PriceReduction.created_at)).scalars().all()
    db.commit()
    return {
        "gig_id": str(gig.id),
        "status": gig.status.value,
        "currency": gig.currency,
        "deposit": {"amount": str(gig.amount_minimum), "platform_fee": str(gig.amount_platform_fee), "pro_gross": str(gig.amount_pro_gross)},
        "final_price": str(final_price(gig)),
        "final_split": None if gig.final_stamped_at is None else {
            "gross": str(gig.final_gross), "platform_retained": str(gig.final_platform_retained), "pro_raww": str(gig.final_pro_raww),
            "client_raww": str(gig.final_client_raww), "pro_cash": str(gig.final_pro_cash), "stamped_at": gig.final_stamped_at.isoformat(),
        },
        "payments": [
            {"kind": p.kind.value, "amount": str(p.amount), "amount_refunded": str(p.amount_refunded), "status": p.status.value,
             "payment_intent": p.stripe_payment_intent_id}
            for p in payments
        ],
        "reductions": [
            {"id": str(r.id), "created_at": r.created_at.isoformat(), "source": r.source, "from_amount": str(r.from_amount),
             "to_amount": str(r.to_amount), "refund_amount": str(r.refund_amount), "note": r.note,
             "lines": [{**line, "label": labels.get(line["reason_code"], line["reason_code"])} for line in r.lines]}
            for r in reductions
        ],
        "reasons": [_reason_view(r) for r in db.execute(select(PriceReductionReason).order_by(PriceReductionReason.sort_order)).scalars()],
        "photographer": {
            "pro_user_id": str(gig.pro_user_id), "available": str(money.available), "withdrawable": str(money.withdrawable),
            "adjustment_owed": str(money.adjustment_owed),
        },
    }


@router.post("/gigs/{gig_id}/price-reductions/preview")
def preview_reduction(gig_id: uuid.UUID, body: PreviewIn, _: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    gig = _gig(db, gig_id)
    total = sum((line.amount for line in _lines(body)), Decimal("0.00"))
    preview = preview_price_reduction(db, gig, new_final=final_price(gig) - total)
    db.rollback()
    return {k: (str(v) if isinstance(v, Decimal) else v) for k, v in preview.items()}


@router.post("/gigs/{gig_id}/price-reductions")
def reduce_price(gig_id: uuid.UUID, body: ReduceIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    gig = _gig(db, gig_id)
    lines = _lines(body)
    total = sum((line.amount for line in lines), Decimal("0.00"))
    reduction = apply_price_reduction(
        db, gig, new_final=final_price(gig) - total, lines=lines, note=body.note, source="admin",
        key=f"admin:{gig.id}:{body.idempotency_key}", actor_user_id=actor.user_id,
    )
    db.commit()
    return {
        "id": str(reduction.id), "from_amount": str(reduction.from_amount), "to_amount": str(reduction.to_amount),
        "refund_amount": str(reduction.refund_amount), "lines": reduction.lines,
    }


@router.get("/price-reduction-reasons")
def list_reasons(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    ensure_default_reasons(db)
    rows = db.execute(select(PriceReductionReason).order_by(PriceReductionReason.sort_order)).scalars().all()
    db.commit()
    return {"items": [_reason_view(r) for r in rows]}


@router.put("/price-reduction-reasons/{code}")
def update_reason(code: str, body: ReasonUpdateIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    ensure_default_reasons(db)
    row = db.get(PriceReductionReason, code)
    if row is None:
        raise APIError(code="not_found", message="Unknown reason code", status_code=404)
    changes = body.model_dump(exclude_none=True)
    for field, value in changes.items():
        setattr(row, field, value)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="price_reduction_reason", target_id=code,
                        action="price_reduction_reason_updated", reason=None, metadata=changes)
    db.commit()
    return _reason_view(row)


@router.get("/policies/delivery-review")
def get_delivery_policy(_: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    row = delivery_review_policy(db)
    db.commit()
    return {"shortfall_min_photos": row.shortfall_min_photos}


@router.put("/policies/delivery-review")
def put_delivery_policy(body: DeliveryPolicyIn, actor: CurrentUser = Depends(require_admin), db: Session = Depends(get_db_session)) -> dict:
    row = delivery_review_policy(db)
    before = row.shortfall_min_photos
    row.shortfall_min_photos = body.shortfall_min_photos
    row.updated_by_user_id = actor.user_id
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="delivery_review_policy", target_id="1",
                        action="delivery_review_policy_updated", reason=None,
                        metadata={"shortfall_min_photos": {"from": before, "to": body.shortfall_min_photos}})
    db.commit()
    return {"shortfall_min_photos": row.shortfall_min_photos}
