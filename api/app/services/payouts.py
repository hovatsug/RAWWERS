from __future__ import annotations

import logging
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from sqlalchemy import and_, func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import ProProfile
from app.models.payouts import (
    EarningsBalanceSnapshot,
    EarningsEntryStatus,
    EarningsHold,
    EarningsHoldReason,
    EarningsLedgerEntry,
    EarningsSourceType,
    PayoutAccount,
    PayoutAccountStatus,
    PayoutAllocation,
    PayoutEvent,
    PayoutMethod,
    PayoutRequest,
    PayoutRequestStatus,
    PlatformFeePolicy,
)
from app.services.analytics import log_event
from app.services.metrics import observe_business_event, observe_payout_volume, set_dispute_hold_amount, set_total_available_eur
from app.services.notifications import NotificationSeverity, enqueue_notification
from app.services.outbox import enqueue_outbox_event

settings = get_settings()
logger = logging.getLogger(__name__)
MIN_PAYOUT_EUR = Decimal("50.00")
PAYOUT_REQUEST_LIMIT_7D = 2


def ensure_default_platform_fee_policy(db: Session) -> PlatformFeePolicy:
    row = db.execute(select(PlatformFeePolicy).order_by(PlatformFeePolicy.updated_at.desc())).scalars().first()
    if row:
        return row
    row = PlatformFeePolicy(
        fee_percent_gigs=20,
        fee_percent_extras=20,
        fee_percent_studioverse=20,
        settlement_delay_days=7,
        dispute_hold_days=14,
    )
    db.add(row)
    db.flush()
    return row


def create_earnings_entry(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    source_type: EarningsSourceType,
    source_id: uuid.UUID,
    gross_eur: Decimal,
    metadata: dict | None = None,
) -> EarningsLedgerEntry | None:
    gross = _q2(gross_eur)
    if gross <= Decimal("0.00"):
        return None

    policy = ensure_default_platform_fee_policy(db)
    fee_percent = _fee_percent_for_source(policy, source_type)
    fee = _q2(gross * Decimal(fee_percent) / Decimal("100"))
    net = _q2(gross - fee)
    now = datetime.now(timezone.utc)
    available_at = now + timedelta(days=max(0, int(policy.settlement_delay_days)))

    existing = db.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.pro_user_id == pro_user_id,
            EarningsLedgerEntry.source_type == source_type,
            EarningsLedgerEntry.source_id == source_id,
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    status = EarningsEntryStatus.pending
    if _entry_should_be_held(db, pro_user_id=pro_user_id, source_type=source_type.value, source_id=source_id):
        status = EarningsEntryStatus.held

    savepoint = db.begin_nested()
    try:
        row = EarningsLedgerEntry(
            pro_user_id=pro_user_id,
            source_type=source_type,
            source_id=source_id,
            gross_eur=gross,
            platform_fee_eur=fee,
            net_eur=net,
            status=status,
            available_at=available_at,
            meta={
                "fee_percent": fee_percent,
                "fee_policy_id": str(policy.id),
                **(metadata or {}),
            },
        )
        db.add(row)
        db.flush()
        savepoint.commit()
    except IntegrityError:
        savepoint.rollback()
        return db.execute(
            select(EarningsLedgerEntry).where(
                EarningsLedgerEntry.pro_user_id == pro_user_id,
                EarningsLedgerEntry.source_type == source_type,
                EarningsLedgerEntry.source_id == source_id,
            )
        ).scalar_one_or_none()

    refresh_earnings_balance_snapshot(db, pro_user_id=pro_user_id)
    _refresh_finance_metrics(db)
    observe_business_event("earnings_entry_created")
    log_event(
        db,
        event_name="earnings.entry_created",
        user_id=pro_user_id,
        properties={
            "source_type": source_type.value,
            "source_id": str(source_id),
            "gross_eur": str(gross),
            "fee_eur": str(fee),
            "net_eur": str(net),
        },
    )
    return row


def settle_due_earnings_entries(db: Session, *, limit: int = 500) -> int:
    now = datetime.now(timezone.utc)
    rows = db.execute(
        select(EarningsLedgerEntry)
        .where(
            EarningsLedgerEntry.status.in_([EarningsEntryStatus.pending, EarningsEntryStatus.held]),
            EarningsLedgerEntry.available_at <= now,
            EarningsLedgerEntry.reversed_at.is_(None),
        )
        .order_by(EarningsLedgerEntry.available_at.asc())
        .limit(limit)
    ).scalars().all()
    changed = 0
    failed = 0
    touched: set[uuid.UUID] = set()
    for row in rows:
        try:
            with db.begin_nested():
                should_hold = _entry_should_be_held(
                    db,
                    pro_user_id=row.pro_user_id,
                    source_type=row.source_type.value,
                    source_id=row.source_id,
                )
                target_status = EarningsEntryStatus.held if should_hold else EarningsEntryStatus.available
                if row.status == target_status:
                    continue
                row.status = target_status
                row.updated_at = now
                if target_status == EarningsEntryStatus.available:
                    observe_business_event("earnings_entry_available")
                    log_event(
                        db,
                        event_name="earnings.entry_available",
                        user_id=row.pro_user_id,
                        properties={"entry_id": str(row.id), "source_type": row.source_type.value, "source_id": str(row.source_id)},
                    )
                changed += 1
                touched.add(row.pro_user_id)
        except Exception:
            failed += 1
            logger.exception("settle_earnings_entry_failed", extra={"entry_id": str(row.id)})
    for pro_user_id in touched:
        refresh_earnings_balance_snapshot(db, pro_user_id=pro_user_id)
    if changed:
        _refresh_finance_metrics(db)
    logger.info("settle_due_earnings_entries_sweep", extra={"scanned": len(rows), "settled": changed, "failed": failed})
    return changed


def create_earnings_hold(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    reason: EarningsHoldReason,
    amount_eur: Decimal | None,
    source_type: str | None,
    source_id: uuid.UUID | None,
    created_by_admin_id: uuid.UUID | None,
) -> EarningsHold:
    row = EarningsHold(
        pro_user_id=pro_user_id,
        reason=reason,
        amount_eur=_q2(amount_eur) if amount_eur is not None else None,
        source_type=source_type,
        source_id=source_id,
        created_by_admin_id=created_by_admin_id,
    )
    db.add(row)
    db.flush()
    _apply_hold_to_existing_entries(db, hold=row)
    refresh_earnings_balance_snapshot(db, pro_user_id=pro_user_id)
    _refresh_finance_metrics(db)
    return row


def release_earnings_hold(db: Session, hold: EarningsHold) -> EarningsHold:
    if hold.released_at is None:
        hold.released_at = datetime.now(timezone.utc)
        db.flush()
        settle_due_earnings_entries(db, limit=1000)
        refresh_earnings_balance_snapshot(db, pro_user_id=hold.pro_user_id)
        _refresh_finance_metrics(db)
    return hold


def release_earnings_holds_for_source(db: Session, *, pro_user_id: uuid.UUID, source_type: str, source_id: uuid.UUID) -> int:
    rows = db.execute(
        select(EarningsHold).where(
            EarningsHold.pro_user_id == pro_user_id,
            EarningsHold.source_type == source_type,
            EarningsHold.source_id == source_id,
            EarningsHold.released_at.is_(None),
        )
    ).scalars().all()
    count = 0
    for row in rows:
        row.released_at = datetime.now(timezone.utc)
        count += 1
    if count:
        settle_due_earnings_entries(db, limit=1000)
        refresh_earnings_balance_snapshot(db, pro_user_id=pro_user_id)
        _refresh_finance_metrics(db)
    return count


def reverse_earnings_entries_for_source(
    db: Session,
    *,
    source_type: EarningsSourceType,
    source_id: uuid.UUID,
    reason: str,
) -> int:
    rows = db.execute(
        select(EarningsLedgerEntry).where(
            EarningsLedgerEntry.source_type == source_type,
            EarningsLedgerEntry.source_id == source_id,
            EarningsLedgerEntry.status != EarningsEntryStatus.reversed,
        )
    ).scalars().all()
    now = datetime.now(timezone.utc)
    count = 0
    touched: set[uuid.UUID] = set()
    for row in rows:
        row.status = EarningsEntryStatus.reversed
        row.reversed_at = now
        row.updated_at = now
        row.meta = {**(row.meta or {}), "reversal_reason": reason}
        touched.add(row.pro_user_id)
        count += 1
    for pro_user_id in touched:
        refresh_earnings_balance_snapshot(db, pro_user_id=pro_user_id)
    if count:
        _refresh_finance_metrics(db)
    return count


def refresh_earnings_balance_snapshot(db: Session, *, pro_user_id: uuid.UUID) -> EarningsBalanceSnapshot:
    totals = db.execute(
        select(
            func.coalesce(func.sum(EarningsLedgerEntry.net_eur).filter(EarningsLedgerEntry.status == EarningsEntryStatus.pending), 0),
            func.coalesce(func.sum(EarningsLedgerEntry.net_eur).filter(EarningsLedgerEntry.status == EarningsEntryStatus.available), 0),
            func.coalesce(func.sum(EarningsLedgerEntry.net_eur).filter(EarningsLedgerEntry.status == EarningsEntryStatus.held), 0),
        ).where(EarningsLedgerEntry.pro_user_id == pro_user_id)
    ).one()
    row = db.get(EarningsBalanceSnapshot, pro_user_id)
    if not row:
        row = EarningsBalanceSnapshot(pro_user_id=pro_user_id)
        db.add(row)
    row.pending_eur = _q2(Decimal(str(totals[0] or 0)))
    row.available_eur = _q2(Decimal(str(totals[1] or 0)))
    row.held_eur = _q2(Decimal(str(totals[2] or 0)))
    row.updated_at = datetime.now(timezone.utc)
    db.flush()
    return row


def get_or_create_payout_account(db: Session, *, pro_user_id: uuid.UUID) -> PayoutAccount:
    row = db.get(PayoutAccount, pro_user_id)
    if row:
        return row
    row = PayoutAccount(
        pro_user_id=pro_user_id,
        payout_method=PayoutMethod.bank_manual,
        status=PayoutAccountStatus.not_set,
    )
    db.add(row)
    db.flush()
    return row


def upsert_payout_account(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    payout_method: PayoutMethod,
    stripe_connect_account_id: str | None,
    bank_details_encrypted: dict | None,
    status: PayoutAccountStatus,
) -> PayoutAccount:
    row = get_or_create_payout_account(db, pro_user_id=pro_user_id)
    row.payout_method = payout_method
    row.stripe_connect_account_id = stripe_connect_account_id
    row.bank_details_encrypted = bank_details_encrypted
    row.status = status
    db.flush()
    return row


def payout_balance_view(db: Session, *, pro_user_id: uuid.UUID) -> dict:
    snapshot = refresh_earnings_balance_snapshot(db, pro_user_id=pro_user_id)
    reserved = reserved_amount_for_pro(db, pro_user_id=pro_user_id)
    withdrawable = max(Decimal("0.00"), _q2(snapshot.available_eur - reserved))
    return {
        "pending_eur": _q2(snapshot.pending_eur),
        "available_eur": _q2(snapshot.available_eur),
        "held_eur": _q2(snapshot.held_eur),
        "reserved_eur": _q2(reserved),
        "withdrawable_eur": withdrawable,
    }


def create_payout_request(db: Session, *, pro_user_id: uuid.UUID, amount_eur: Decimal) -> PayoutRequest:
    from app.models.risk import RiskActionType
    from app.services.trust_safety import enforce_risk_action_not_active, evaluate_payout_anomaly_rule

    evaluate_payout_anomaly_rule(db, pro_user_id=pro_user_id)
    enforce_risk_action_not_active(
        db,
        user_id=pro_user_id,
        action_type=RiskActionType.freeze_payouts,
        message="Payouts are temporarily frozen for this account",
    )

    amount = _q2(amount_eur)
    if amount < MIN_PAYOUT_EUR:
        raise APIError(code="validation_error", message=f"Minimum payout is {MIN_PAYOUT_EUR}", status_code=422)

    since = datetime.now(timezone.utc) - timedelta(days=7)
    recent_count = db.execute(
        select(func.count()).select_from(PayoutRequest).where(
            PayoutRequest.pro_user_id == pro_user_id,
            PayoutRequest.created_at >= since,
        )
    ).scalar_one()
    if int(recent_count) >= PAYOUT_REQUEST_LIMIT_7D:
        raise APIError(code="rate_limited", message="Payout request limit reached for this week", status_code=429)

    balance = payout_balance_view(db, pro_user_id=pro_user_id)
    if amount > balance["withdrawable_eur"]:
        raise APIError(code="validation_error", message="Requested amount exceeds withdrawable balance", status_code=422)

    row = PayoutRequest(
        pro_user_id=pro_user_id,
        amount_eur=amount,
        status=PayoutRequestStatus.requested,
        reference={},
    )
    db.add(row)
    db.flush()
    _add_payout_event(db, payout_request_id=row.id, event_type="requested", payload={"amount_eur": str(amount)})

    for admin_user_id in settings.admin_user_id_set():
        enqueue_notification(
            db,
            user_id=admin_user_id,
            notification_type="payout.requested",
            payload={"title": "Payout request", "body": "A pro submitted a payout request."},
            reference_type="payout_request",
            reference_id=str(row.id),
            severity=NotificationSeverity.info,
            dedupe_key=f"payout-request-admin:{row.id}:{admin_user_id}",
        )
    log_event(
        db,
        event_name="payout.requested",
        user_id=pro_user_id,
        properties={"payout_request_id": str(row.id), "amount_eur": str(amount)},
    )
    return row


def approve_payout_request(db: Session, *, payout_request_id: uuid.UUID, admin_user_id: uuid.UUID) -> PayoutRequest:
    row = db.get(PayoutRequest, payout_request_id)
    if not row:
        raise APIError(code="not_found", message="Payout request not found", status_code=404)
    if row.status != PayoutRequestStatus.requested:
        raise APIError(code="invalid_state", message="Payout request is not in requested status", status_code=409)

    _allocate_payout_amount(db, payout=row)
    row.status = PayoutRequestStatus.approved
    row.approved_by_admin_id = admin_user_id
    row.approved_at = datetime.now(timezone.utc)
    row.updated_at = datetime.now(timezone.utc)
    _add_payout_event(db, payout_request_id=row.id, event_type="approved", payload={"admin_user_id": str(admin_user_id)})

    enqueue_outbox_event(
        db,
        topic="payout.execute",
        payload={"payout_request_id": str(row.id)},
        idempotency_key=f"payout-execute:{row.id}",
        idempotency_scope="payout_execute",
    )
    log_event(
        db,
        event_name="payout.approved",
        user_id=admin_user_id,
        properties={"payout_request_id": str(row.id), "pro_user_id": str(row.pro_user_id)},
    )
    return row


def reject_payout_request(db: Session, *, payout_request_id: uuid.UUID, admin_user_id: uuid.UUID, reason: str | None) -> PayoutRequest:
    row = db.get(PayoutRequest, payout_request_id)
    if not row:
        raise APIError(code="not_found", message="Payout request not found", status_code=404)
    if row.status != PayoutRequestStatus.requested:
        raise APIError(code="invalid_state", message="Payout request cannot be rejected", status_code=409)
    row.status = PayoutRequestStatus.rejected
    row.failure_reason = reason
    row.updated_at = datetime.now(timezone.utc)
    _add_payout_event(db, payout_request_id=row.id, event_type="rejected", payload={"admin_user_id": str(admin_user_id), "reason": reason})
    return row


def execute_payout_request(db: Session, *, payout_request_id: uuid.UUID) -> PayoutRequest | None:
    row = db.get(PayoutRequest, payout_request_id)
    if not row:
        return None
    if row.status == PayoutRequestStatus.paid:
        return row
    if row.status not in {PayoutRequestStatus.approved, PayoutRequestStatus.processing}:
        return row

    account = get_or_create_payout_account(db, pro_user_id=row.pro_user_id)
    if account.payout_method == PayoutMethod.bank_manual or account.status != PayoutAccountStatus.active:
        if row.status != PayoutRequestStatus.processing:
            row.status = PayoutRequestStatus.processing
            row.updated_at = datetime.now(timezone.utc)
            _add_payout_event(db, payout_request_id=row.id, event_type="processing", payload={"mode": "manual"})
        return row

    # Stripe Connect path.
    try:
        transfer = stripe.Transfer.create(
            amount=int((row.amount_eur * Decimal("100")).quantize(Decimal("1"))),
            currency="eur",
            destination=account.stripe_connect_account_id,
            metadata={"payout_request_id": str(row.id), "pro_user_id": str(row.pro_user_id)},
            idempotency_key=f"payout-transfer:{row.id}",
        )
        row.status = PayoutRequestStatus.paid
        row.paid_at = datetime.now(timezone.utc)
        row.reference = {**(row.reference or {}), "stripe_transfer_id": getattr(transfer, "id", None)}
        row.updated_at = datetime.now(timezone.utc)
        _add_payout_event(db, payout_request_id=row.id, event_type="paid", payload={"mode": "stripe_connect", "reference": row.reference})
        log_event(
            db,
            event_name="payout.paid",
            user_id=row.pro_user_id,
            properties={"payout_request_id": str(row.id), "amount_eur": str(row.amount_eur)},
        )
        observe_payout_volume(float(row.amount_eur))
    except Exception as exc:
        row.status = PayoutRequestStatus.failed
        row.failure_reason = str(exc)[:500]
        row.updated_at = datetime.now(timezone.utc)
        _add_payout_event(db, payout_request_id=row.id, event_type="failed", payload={"reason": row.failure_reason})
        log_event(
            db,
            event_name="payout.failed",
            user_id=row.pro_user_id,
            properties={"payout_request_id": str(row.id), "reason": row.failure_reason},
        )
    return row


def mark_payout_paid_manual(
    db: Session,
    *,
    payout_request_id: uuid.UUID,
    admin_user_id: uuid.UUID,
    reference: dict,
) -> PayoutRequest:
    row = db.get(PayoutRequest, payout_request_id)
    if not row:
        raise APIError(code="not_found", message="Payout request not found", status_code=404)
    if row.status not in {PayoutRequestStatus.approved, PayoutRequestStatus.processing}:
        raise APIError(code="invalid_state", message="Payout request is not payable", status_code=409)

    row.status = PayoutRequestStatus.paid
    row.paid_at = datetime.now(timezone.utc)
    row.reference = {**(row.reference or {}), **(reference or {})}
    row.updated_at = datetime.now(timezone.utc)
    _add_payout_event(db, payout_request_id=row.id, event_type="paid", payload={"mode": "manual", "admin_user_id": str(admin_user_id), "reference": reference or {}})
    log_event(
        db,
        event_name="payout.paid",
        user_id=row.pro_user_id,
        properties={"payout_request_id": str(row.id), "amount_eur": str(row.amount_eur)},
    )
    observe_payout_volume(float(row.amount_eur))
    return row


def reserved_amount_for_pro(db: Session, *, pro_user_id: uuid.UUID) -> Decimal:
    total = db.execute(
        select(func.coalesce(func.sum(PayoutAllocation.amount_eur), 0))
        .select_from(PayoutAllocation)
        .join(PayoutRequest, PayoutRequest.id == PayoutAllocation.payout_request_id)
        .where(
            PayoutRequest.pro_user_id == pro_user_id,
            PayoutRequest.status.in_([PayoutRequestStatus.approved, PayoutRequestStatus.processing, PayoutRequestStatus.paid]),
        )
    ).scalar_one()
    return _q2(Decimal(str(total or 0)))


def list_pro_earnings_entries(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    source_type: EarningsSourceType | None,
    from_at: datetime | None,
    to_at: datetime | None,
    limit: int,
) -> list[EarningsLedgerEntry]:
    stmt = select(EarningsLedgerEntry).where(EarningsLedgerEntry.pro_user_id == pro_user_id)
    if source_type:
        stmt = stmt.where(EarningsLedgerEntry.source_type == source_type)
    if from_at:
        stmt = stmt.where(EarningsLedgerEntry.created_at >= from_at)
    if to_at:
        stmt = stmt.where(EarningsLedgerEntry.created_at <= to_at)
    return db.execute(stmt.order_by(EarningsLedgerEntry.created_at.desc()).limit(limit)).scalars().all()


def list_pro_payout_requests(db: Session, *, pro_user_id: uuid.UUID, limit: int) -> list[PayoutRequest]:
    return db.execute(
        select(PayoutRequest)
        .where(PayoutRequest.pro_user_id == pro_user_id)
        .order_by(PayoutRequest.created_at.desc())
        .limit(limit)
    ).scalars().all()


def list_payout_requests_admin(db: Session, *, status: PayoutRequestStatus | None, limit: int) -> list[PayoutRequest]:
    stmt = select(PayoutRequest)
    if status:
        stmt = stmt.where(PayoutRequest.status == status)
    return db.execute(stmt.order_by(PayoutRequest.created_at.desc()).limit(limit)).scalars().all()


def list_finance_pros(db: Session, *, city: str | None, min_available: Decimal | None, limit: int) -> list[dict]:
    stmt = select(ProProfile)
    if city:
        stmt = stmt.where(func.lower(ProProfile.city) == city.lower())
    profiles = db.execute(stmt.order_by(ProProfile.updated_at.desc()).limit(limit)).scalars().all()
    rows: list[dict] = []
    for profile in profiles:
        bal = payout_balance_view(db, pro_user_id=profile.user_id)
        if min_available is not None and bal["withdrawable_eur"] < _q2(min_available):
            continue
        rows.append(
            {
                "pro_user_id": profile.user_id,
                "display_name": profile.display_name,
                "city": profile.city,
                "country": profile.country,
                **bal,
            }
        )
    return rows


def _allocate_payout_amount(db: Session, *, payout: PayoutRequest) -> None:
    target = _q2(payout.amount_eur)
    remaining = target

    entries = db.execute(
        select(EarningsLedgerEntry)
        .where(EarningsLedgerEntry.pro_user_id == payout.pro_user_id, EarningsLedgerEntry.status == EarningsEntryStatus.available)
        .order_by(EarningsLedgerEntry.created_at.asc())
    ).scalars().all()

    for entry in entries:
        used = db.execute(
            select(func.coalesce(func.sum(PayoutAllocation.amount_eur), 0))
            .select_from(PayoutAllocation)
            .join(PayoutRequest, PayoutRequest.id == PayoutAllocation.payout_request_id)
            .where(
                PayoutAllocation.earnings_ledger_entry_id == entry.id,
                PayoutRequest.status.in_([PayoutRequestStatus.approved, PayoutRequestStatus.processing, PayoutRequestStatus.paid]),
            )
        ).scalar_one()
        free_amount = _q2(entry.net_eur - Decimal(str(used or 0)))
        if free_amount <= Decimal("0.00"):
            continue
        alloc = min(free_amount, remaining)
        db.add(PayoutAllocation(payout_request_id=payout.id, earnings_ledger_entry_id=entry.id, amount_eur=_q2(alloc)))
        remaining = _q2(remaining - alloc)
        if remaining <= Decimal("0.00"):
            break

    if remaining > Decimal("0.00"):
        raise APIError(code="validation_error", message="Insufficient available earnings for payout allocation", status_code=422)

    db.flush()


def _entry_should_be_held(db: Session, *, pro_user_id: uuid.UUID, source_type: str, source_id: uuid.UUID) -> bool:
    hold = db.execute(
        select(EarningsHold.id).where(
            EarningsHold.pro_user_id == pro_user_id,
            EarningsHold.released_at.is_(None),
            or_(
                and_(EarningsHold.source_type.is_(None), EarningsHold.source_id.is_(None)),
                and_(EarningsHold.source_type == source_type, EarningsHold.source_id == source_id),
            ),
        )
    ).first()
    return hold is not None


def _apply_hold_to_existing_entries(db: Session, *, hold: EarningsHold) -> None:
    stmt = select(EarningsLedgerEntry).where(
        EarningsLedgerEntry.pro_user_id == hold.pro_user_id,
        EarningsLedgerEntry.status.in_([EarningsEntryStatus.pending, EarningsEntryStatus.available]),
        EarningsLedgerEntry.reversed_at.is_(None),
    )
    if hold.source_type and hold.source_id:
        try:
            source_type = EarningsSourceType(hold.source_type)
            stmt = stmt.where(EarningsLedgerEntry.source_type == source_type, EarningsLedgerEntry.source_id == hold.source_id)
        except Exception:
            return
    rows = db.execute(stmt).scalars().all()
    for row in rows:
        row.status = EarningsEntryStatus.held
        row.updated_at = datetime.now(timezone.utc)


def _add_payout_event(db: Session, *, payout_request_id: uuid.UUID, event_type: str, payload: dict) -> PayoutEvent:
    row = PayoutEvent(payout_request_id=payout_request_id, type=event_type, payload=payload or {})
    db.add(row)
    db.flush()
    return row


def _fee_percent_for_source(policy: PlatformFeePolicy, source_type: EarningsSourceType) -> int:
    if source_type == EarningsSourceType.gig_base:
        return int(policy.fee_percent_gigs)
    if source_type == EarningsSourceType.extra_images:
        return int(policy.fee_percent_extras)
    return int(policy.fee_percent_studioverse)


def _q2(value: Decimal | None) -> Decimal:
    return (value or Decimal("0.00")).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _refresh_finance_metrics(db: Session) -> None:
    total_available = db.execute(
        select(func.coalesce(func.sum(EarningsBalanceSnapshot.available_eur), 0)).select_from(EarningsBalanceSnapshot)
    ).scalar_one()
    dispute_hold_total = db.execute(
        select(func.coalesce(func.sum(EarningsHold.amount_eur), 0)).where(
            EarningsHold.reason == EarningsHoldReason.dispute_open,
            EarningsHold.released_at.is_(None),
            EarningsHold.amount_eur.is_not(None),
        )
    ).scalar_one()
    set_total_available_eur(float(total_available or 0))
    set_dispute_hold_amount(float(dispute_hold_total or 0))
