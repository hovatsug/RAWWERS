"""The business dashboard's API: /v1/admin/bi/*, admin only (docs/BI.md).

Every number comes from services/bi.py. Periods are capped (bi.MAX_READ_DAYS
to read, bi.MAX_RECOMPUTE_DAYS to recompute, bi_stripe.MAX_SYNC_DAYS to
mirror Stripe); lists are paginated. The two manual tables (costs, company
cash) are created, edited and deleted here, each change stamped on the row
(who, when) and written to the admin audit log with the values before and
after.
"""
from __future__ import annotations

import uuid
import datetime as dt
from datetime import date, datetime, timezone
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin_bi
from app.core.errors import APIError
from app.models.bi import COST_CATEGORIES, BiCompanyCash, BiCost
from app.schemas.media import CurrentUser
from app.services import bi, bi_stripe
from app.services.audit import add_admin_audit_log

router = APIRouter(prefix="/admin/bi", tags=["admin_bi"])

KPIS = (
    ("gmv", "GMV"),
    ("net_gmv", "Net GMV"),
    ("retained", "Retained fee"),
    ("stripe_fees", "Stripe fees"),
    ("contribution", "Contribution profit"),
    ("marketing_spend", "Marketing spend"),
    ("operating_profit", "Operating profit"),
    ("refund", "Refunds"),
    ("bookings", "Bookings"),
)


def _filters(niche: str | None, country: str | None, tier: str | None) -> bi.Filters:
    return bi.Filters(niche=niche or None, country=(country or "").upper() or None, tier=tier or None)


def _period(period: str | None, start: date | None, end: date | None) -> tuple[date, date]:
    return bi.period_bounds(period, start, end)


PeriodQ = Query(default=None, description="today, 7d, 30d, this_month, last_month or custom")


@router.get("/overview")
def overview(
    period: str | None = PeriodQ, start: date | None = None, end: date | None = None,
    niche: str | None = None, country: str | None = None, tier: str | None = None,
    _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session),
) -> dict:
    """The KPIs against the previous period of the same length, every
    number of docs/BI.md, and the waterfall."""
    a, b = _period(period, start, end)
    filters = _filters(niche, country, tier)
    current = bi.summarize(db, a, b, filters)
    pa, pb = bi.previous_period(a, b)
    previous = bi.summarize(db, pa, pb, filters)
    kpis = [
        {"key": key, "label": label, "value": current.values.get(key), "previous": previous.values.get(key),
         "change_bp": bi.change_bp(current.values.get(key), previous.values.get(key)), "reason": current.reasons.get(key)}
        for key, label in KPIS
    ]
    return {
        "period": current.meta, "previous": {"from": pa.isoformat(), "to": pb.isoformat()},
        "filters": {"niche": filters.niche, "country": filters.country, "tier": filters.tier},
        "kpis": kpis, "values": current.values, "reasons": current.reasons,
        "waterfall": bi.waterfall(current),
    }


@router.get("/series")
def series(
    period: str | None = PeriodQ, start: date | None = None, end: date | None = None, grain: str = "day",
    niche: str | None = None, country: str | None = None, tier: str | None = None,
    _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session),
) -> dict:
    a, b = _period(period, start, end)
    return {"grain": grain, "items": bi.series(db, a, b, grain, _filters(niche, country, tier))}


@router.get("/breakdown")
def breakdown(
    by: str, period: str | None = PeriodQ, start: date | None = None, end: date | None = None,
    niche: str | None = None, country: str | None = None, tier: str | None = None,
    _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session),
) -> dict:
    a, b = _period(period, start, end)
    return {"by": by, "low_sample_below": bi.LOW_SAMPLE, "items": bi.breakdown(db, a, b, by, _filters(niche, country, tier))}


@router.get("/bookings")
def bookings(
    period: str | None = PeriodQ, start: date | None = None, end: date | None = None,
    niche: str | None = None, country: str | None = None, tier: str | None = None, pro: uuid.UUID | None = None,
    offset: int = Query(default=0, ge=0), limit: int = Query(default=50, ge=1, le=100),
    _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session),
) -> dict:
    """The bookings behind a number (drill-down)."""
    a, b = _period(period, start, end)
    return bi.bookings(db, a, b, _filters(niche, country, tier), str(pro) if pro else None, offset, limit)


@router.get("/reconciliation")
def reconciliation(
    period: str | None = PeriodQ, start: date | None = None, end: date | None = None,
    _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session),
) -> dict:
    a, b = _period(period, start, end)
    summary = bi.summarize(db, a, b)
    return {"period": summary.meta, **bi.reconciliation(summary)}


@router.get("/owed")
def owed(_: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    """Now: money owed, cash held, and the liquid view."""
    stripe_balance = (
        bi_stripe.balance() if bi_stripe.stripe_configured()
        else {"available_cents": None, "pending_cents": None, "reason": "Stripe is not configured"}
    )
    view = bi.owed(db, stripe_balance)
    db.commit()  # the client-credit settings row is created on first read
    return view


class RangeIn(BaseModel):
    start: dt.date
    end: dt.date


@router.post("/recompute")
def recompute(body: RangeIn, actor: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    rows = bi.recompute_days(db, body.start, body.end)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_daily", target_id=f"{body.start}:{body.end}",
                        action="recompute", metadata={"rows": rows})
    db.commit()
    return {"rows": rows}


@router.post("/stripe-sync")
def stripe_sync(body: RangeIn, actor: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    if not bi_stripe.stripe_configured():
        raise APIError(code="stripe_not_configured", message="Stripe is not configured", status_code=409)
    result = bi_stripe.sync_days(db, body.start, body.end)
    bi.recompute_range(db, body.start, body.end)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_stripe_txn", target_id=f"{body.start}:{body.end}",
                        action="sync", metadata={"days": result.days, "transactions": result.transactions})
    db.commit()
    return {"days": result.days, "transactions": result.transactions}


# --- manual entries ---------------------------------------------------------------------------


class CostIn(BaseModel):
    date: dt.date
    category: str
    amount: Decimal = Field(description="Euros, two decimals at most")
    currency: str = "EUR"
    note: str | None = Field(default=None, max_length=500)
    recurring: bool = False
    end_date: dt.date | None = None


class CostPatch(BaseModel):
    date: dt.date | None = None
    category: str | None = None
    amount: Decimal | None = None
    currency: str | None = None
    note: str | None = Field(default=None, max_length=500)
    recurring: bool | None = None
    end_date: dt.date | None = None


class CashIn(BaseModel):
    date: dt.date
    account: str = Field(min_length=1, max_length=120)
    amount: Decimal
    currency: str = "EUR"
    note: str | None = Field(default=None, max_length=500)


class CashPatch(BaseModel):
    date: dt.date | None = None
    account: str | None = Field(default=None, min_length=1, max_length=120)
    amount: Decimal | None = None
    currency: str | None = None
    note: str | None = Field(default=None, max_length=500)


def _currency(value: str) -> str:
    code = (value or "").strip().upper()
    if len(code) != 3 or not code.isalpha():
        raise APIError(code="validation_error", message="Currency is a three-letter code", status_code=422)
    return code


def _cost_view(row: BiCost) -> dict:
    return {"id": str(row.id), "date": row.date.isoformat(), "end_date": row.end_date.isoformat() if row.end_date else None,
            "category": row.category, "amount_cents": row.amount_cents, "currency": row.currency, "note": row.note,
            "recurring": row.recurring, "created_by": str(row.created_by), "created_at": row.created_at.isoformat(),
            "updated_by": str(row.updated_by) if row.updated_by else None,
            "updated_at": row.updated_at.isoformat() if row.updated_at else None}


def _cash_view(row: BiCompanyCash) -> dict:
    return {"id": str(row.id), "date": row.date.isoformat(), "account": row.account, "amount_cents": row.amount_cents,
            "currency": row.currency, "note": row.note, "created_by": str(row.created_by), "created_at": row.created_at.isoformat(),
            "updated_by": str(row.updated_by) if row.updated_by else None,
            "updated_at": row.updated_at.isoformat() if row.updated_at else None}


def _check_cost(row: BiCost) -> None:
    if row.category not in COST_CATEGORIES:
        raise APIError(code="validation_error", message=f"Category is one of {', '.join(COST_CATEGORIES)}", status_code=422)
    if row.amount_cents <= 0:
        raise APIError(code="validation_error", message="A cost is more than zero", status_code=422)
    if row.end_date is not None and (not row.recurring or row.end_date < row.date):
        raise APIError(code="validation_error", message="An end date is for a recurring cost, after its start", status_code=422)


def _page(query, offset: int, limit: int, db: Session, view) -> dict:
    rows = db.execute(query.offset(offset).limit(limit + 1)).scalars().all()
    return {"items": [view(r) for r in rows[:limit]], "offset": offset, "limit": limit,
            "next_offset": offset + limit if len(rows) > limit else None}


def _live(db: Session, model, row_id: uuid.UUID):
    row = db.get(model, row_id)
    if row is None or row.deleted_at is not None:
        raise APIError(code="not_found", message="Not found", status_code=404)
    return row


@router.get("/costs")
def list_costs(offset: int = Query(default=0, ge=0), limit: int = Query(default=50, ge=1, le=100),
               _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    query = select(BiCost).where(BiCost.deleted_at.is_(None)).order_by(BiCost.date.desc(), BiCost.created_at.desc(), BiCost.id)
    return {**_page(query, offset, limit, db, _cost_view), "categories": list(COST_CATEGORIES)}


@router.post("/costs", status_code=201)
def create_cost(body: CostIn, actor: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    row = BiCost(date=body.date, end_date=body.end_date, category=body.category, amount_cents=bi.euros_to_cents(body.amount),
                 currency=_currency(body.currency), note=body.note, recurring=body.recurring, created_by=actor.user_id)
    _check_cost(row)
    db.add(row)
    db.flush()
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_cost", target_id=str(row.id), action="create",
                        metadata={"after": _cost_view(row)})
    db.commit()
    return _cost_view(row)


@router.patch("/costs/{cost_id}")
def update_cost(cost_id: uuid.UUID, body: CostPatch, actor: CurrentUser = Depends(require_admin_bi),
                db: Session = Depends(get_db_session)) -> dict:
    row = _live(db, BiCost, cost_id)
    before = _cost_view(row)
    fields = body.model_dump(exclude_unset=True)
    if "amount" in fields:
        row.amount_cents = bi.euros_to_cents(fields.pop("amount"))
    if "currency" in fields:
        row.currency = _currency(fields.pop("currency"))
    for key, value in fields.items():
        setattr(row, key, value)
    _check_cost(row)
    row.updated_by, row.updated_at = actor.user_id, datetime.now(timezone.utc)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_cost", target_id=str(row.id), action="update",
                        metadata={"before": before, "after": _cost_view(row)})
    db.commit()
    return _cost_view(row)


@router.delete("/costs/{cost_id}")
def delete_cost(cost_id: uuid.UUID, actor: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    row = _live(db, BiCost, cost_id)
    row.deleted_by, row.deleted_at = actor.user_id, datetime.now(timezone.utc)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_cost", target_id=str(row.id), action="delete",
                        metadata={"before": _cost_view(row)})
    db.commit()
    return {"deleted": True}


@router.get("/cash")
def list_cash(offset: int = Query(default=0, ge=0), limit: int = Query(default=50, ge=1, le=100),
              _: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    query = (select(BiCompanyCash).where(BiCompanyCash.deleted_at.is_(None))
             .order_by(BiCompanyCash.date.desc(), BiCompanyCash.created_at.desc(), BiCompanyCash.id))
    return _page(query, offset, limit, db, _cash_view)


@router.post("/cash", status_code=201)
def create_cash(body: CashIn, actor: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    row = BiCompanyCash(date=body.date, account=body.account.strip(), amount_cents=bi.euros_to_cents(body.amount),
                        currency=_currency(body.currency), note=body.note, created_by=actor.user_id)
    db.add(row)
    db.flush()
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_company_cash", target_id=str(row.id), action="create",
                        metadata={"after": _cash_view(row)})
    db.commit()
    return _cash_view(row)


@router.patch("/cash/{cash_id}")
def update_cash(cash_id: uuid.UUID, body: CashPatch, actor: CurrentUser = Depends(require_admin_bi),
                db: Session = Depends(get_db_session)) -> dict:
    row = _live(db, BiCompanyCash, cash_id)
    before = _cash_view(row)
    fields = body.model_dump(exclude_unset=True)
    if "amount" in fields:
        row.amount_cents = bi.euros_to_cents(fields.pop("amount"))
    if "currency" in fields:
        row.currency = _currency(fields.pop("currency"))
    if "account" in fields:
        row.account = fields.pop("account").strip()
    for key, value in fields.items():
        setattr(row, key, value)
    row.updated_by, row.updated_at = actor.user_id, datetime.now(timezone.utc)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_company_cash", target_id=str(row.id), action="update",
                        metadata={"before": before, "after": _cash_view(row)})
    db.commit()
    return _cash_view(row)


@router.delete("/cash/{cash_id}")
def delete_cash(cash_id: uuid.UUID, actor: CurrentUser = Depends(require_admin_bi), db: Session = Depends(get_db_session)) -> dict:
    row = _live(db, BiCompanyCash, cash_id)
    row.deleted_by, row.deleted_at = actor.user_id, datetime.now(timezone.utc)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="bi_company_cash", target_id=str(row.id), action="delete",
                        metadata={"before": _cash_view(row)})
    db.commit()
    return {"deleted": True}
