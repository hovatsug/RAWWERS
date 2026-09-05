from __future__ import annotations

import logging
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP

import stripe
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import (
    DeliverySlaSnapshot,
    Dispute,
    DisputeActorType,
    DisputeCategory,
    DisputeEvent,
    DisputeMessage,
    DisputeStatus,
    EntitlementHold,
    EntitlementHoldType,
    GigContractSnapshot,
    ProQualityPenalty,
    ProQualityPenaltySeverity,
    ProQualityPenaltyType,
    RefundCase,
    RefundCaseStatus,
    RefundEvent,
    RefundPaymentScope,
    RefundPolicy,
    RefundPolicyDefaultAction,
)
from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.gig import Gig, GigStatus
from app.models.media_rights import GigEntitlementType, GigMediaEntitlement
from app.models.ops import AbuseSeverity
from app.models.payouts import EarningsHoldReason, EarningsSourceType
from app.models.reward import RewardEntryType, RewardLedgerEntry
from app.services.abuse import create_abuse_signal
from app.services.analytics import log_event
from app.services.payment_intents import allocate_amount_oldest_first, list_succeeded_payments_for_gig
from app.services.media_rights import increment_entitlement_quantity
from app.services.notifications import enqueue_notification
from app.services.payouts import create_earnings_hold, release_earnings_holds_for_source, reverse_earnings_entries_for_source
from app.services.rewards import add_reward_entry
from app.services.proof_of_gigs import enqueue_raww_refund_reversal
from app.services.trust_safety import evaluate_dispute_rate_rule

settings = get_settings()
logger = logging.getLogger(__name__)


def ensure_default_refund_policies(db: Session) -> None:
    defaults = {
        DisputeCategory.no_show: (RefundPolicyDefaultAction.full_refund, 100, 72, True),
        DisputeCategory.late_cancellation: (RefundPolicyDefaultAction.admin_review, 100, 72, True),
        DisputeCategory.late_delivery: (RefundPolicyDefaultAction.partial_refund, 70, 72, True),
        DisputeCategory.deliverable_quality: (RefundPolicyDefaultAction.admin_review, 70, 72, True),
        DisputeCategory.billing: (RefundPolicyDefaultAction.admin_review, 100, 48, False),
        DisputeCategory.fraud: (RefundPolicyDefaultAction.admin_review, 100, 48, True),
        DisputeCategory.other: (RefundPolicyDefaultAction.admin_review, 50, 72, True),
        DisputeCategory.quality: (RefundPolicyDefaultAction.admin_review, 70, 72, True),
        DisputeCategory.payment: (RefundPolicyDefaultAction.admin_review, 100, 48, False),
        DisputeCategory.harassment: (RefundPolicyDefaultAction.no_refund, 0, 48, False),
    }
    for category, cfg in defaults.items():
        row = db.execute(select(RefundPolicy).where(RefundPolicy.category == category)).scalar_one_or_none()
        if row:
            continue
        db.add(
            RefundPolicy(
                category=category,
                default_action=cfg[0],
                max_refund_percent=cfg[1],
                response_window_hours=cfg[2],
                requires_evidence=cfg[3],
            )
        )
    db.flush()


def capture_gig_contract_snapshot(db: Session, gig: Gig) -> GigContractSnapshot:
    existing = db.get(GigContractSnapshot, gig.id)
    snapshot = {
        "gig_id": str(gig.id),
        "currency": gig.currency,
        "amount_minimum": str(gig.amount_minimum),
        "amount_final": str(gig.amount_final) if gig.amount_final is not None else None,
        "amount_platform_fee": str(gig.amount_platform_fee),
        "amount_pro_gross": str(gig.amount_pro_gross),
        "scheduled_start": gig.scheduled_start.isoformat() if gig.scheduled_start else None,
        "scheduled_end": gig.scheduled_end.isoformat() if gig.scheduled_end else None,
        "pricing_snapshot": (gig.meta or {}).get("pricing_snapshot") or {},
    }
    if existing:
        existing.snapshot = snapshot
        db.flush()
        return existing
    row = GigContractSnapshot(gig_id=gig.id, snapshot=snapshot)
    db.add(row)
    db.flush()
    return row


def upsert_delivery_sla_snapshot(
    db: Session,
    *,
    gig: Gig,
    proofs_published_at: datetime | None = None,
    finals_delivered_at: datetime | None = None,
) -> DeliverySlaSnapshot:
    row = db.execute(
        select(DeliverySlaSnapshot).where(DeliverySlaSnapshot.gig_id == gig.id).order_by(DeliverySlaSnapshot.created_at.desc())
    ).scalars().first()

    pricing = (gig.meta or {}).get("pricing_snapshot") or {}
    proofs_sla_days = int(pricing.get("proofs_sla_days", 3) or 3)
    finals_sla_days = int(pricing.get("finals_sla_days", 7) or 7)
    base_time = gig.scheduled_end or gig.created_at
    proofs_due_at = base_time + timedelta(days=max(0, proofs_sla_days)) if base_time else None
    finals_due_at = base_time + timedelta(days=max(0, finals_sla_days)) if base_time else None

    if not row:
        row = DeliverySlaSnapshot(
            gig_id=gig.id,
            proofs_due_at=proofs_due_at,
            finals_due_at=finals_due_at,
            proofs_published_at=proofs_published_at,
            finals_delivered_at=finals_delivered_at,
        )
        db.add(row)
        db.flush()
        return row

    row.proofs_due_at = row.proofs_due_at or proofs_due_at
    row.finals_due_at = row.finals_due_at or finals_due_at
    if proofs_published_at:
        row.proofs_published_at = proofs_published_at
    if finals_delivered_at:
        row.finals_delivered_at = finals_delivered_at
    db.flush()
    return row


def active_entitlement_hold(db: Session, *, gig_id: uuid.UUID, user_id: uuid.UUID, hold_type: EntitlementHoldType) -> EntitlementHold | None:
    return db.execute(
        select(EntitlementHold).where(
            EntitlementHold.gig_id == gig_id,
            EntitlementHold.user_id == user_id,
            EntitlementHold.hold_type == hold_type,
            EntitlementHold.released_at.is_(None),
        )
    ).scalar_one_or_none()


def apply_entitlement_hold(
    db: Session,
    *,
    gig_id: uuid.UUID,
    user_id: uuid.UUID,
    hold_type: EntitlementHoldType,
    reason: str | None,
) -> EntitlementHold:
    existing = active_entitlement_hold(db, gig_id=gig_id, user_id=user_id, hold_type=hold_type)
    if existing:
        return existing
    row = EntitlementHold(gig_id=gig_id, user_id=user_id, hold_type=hold_type, reason=reason)
    db.add(row)
    db.flush()
    return row


def release_entitlement_hold(db: Session, hold: EntitlementHold) -> None:
    if hold.released_at is None:
        hold.released_at = datetime.now(timezone.utc)
        db.flush()


def create_dispute(
    db: Session,
    *,
    opened_by_user_id: uuid.UUID,
    gig: Gig | None,
    extra_purchase: ExtraImagePurchase | None,
    category: DisputeCategory,
    reason: str,
    requested_refund_amount: Decimal | None,
    currency: str,
) -> Dispute:
    ensure_default_refund_policies(db)
    policy = db.execute(select(RefundPolicy).where(RefundPolicy.category == category)).scalar_one_or_none()

    if not gig and not extra_purchase:
        raise APIError(code="validation_error", message="gig_id or extra_purchase_id is required", status_code=422)

    if gig:
        participants = {gig.client_user_id, gig.pro_user_id}
        if opened_by_user_id not in participants:
            raise APIError(code="forbidden", message="Only gig participants can open dispute", status_code=403)
        against_user = gig.pro_user_id if opened_by_user_id == gig.client_user_id else gig.client_user_id
        reference_time = gig.updated_at
        gig_id = gig.id
        extra_purchase_id = None
    else:
        assert extra_purchase is not None
        participants = {extra_purchase.client_user_id, extra_purchase.pro_user_id}
        if opened_by_user_id not in participants:
            raise APIError(code="forbidden", message="Only purchase participants can open dispute", status_code=403)
        against_user = extra_purchase.pro_user_id if opened_by_user_id == extra_purchase.client_user_id else extra_purchase.client_user_id
        reference_time = extra_purchase.updated_at
        gig_id = extra_purchase.gig_id
        extra_purchase_id = extra_purchase.id

    window_days = int(getattr(settings, "dispute_window_days", 30))
    if reference_time < datetime.now(timezone.utc) - timedelta(days=window_days):
        raise APIError(code="validation_error", message="Dispute window expired", status_code=422)

    count_30d = db.execute(
        select(func.count()).select_from(Dispute).where(
            Dispute.opened_by_user_id == opened_by_user_id,
            Dispute.opened_at >= datetime.now(timezone.utc) - timedelta(days=30),
        )
    ).scalar_one()
    if count_30d >= int(getattr(settings, "dispute_open_limit_30d", 3)):
        raise APIError(code="rate_limited", message="Too many disputes opened in last 30 days", status_code=429)

    due_hours = int(policy.response_window_hours if policy else 72)
    due_response_at = datetime.now(timezone.utc) + timedelta(hours=due_hours)

    dispute = Dispute(
        gig_id=gig_id,
        extra_purchase_id=extra_purchase_id,
        opened_by_user_id=opened_by_user_id,
        against_user_id=against_user,
        category=category,
        status=DisputeStatus.open,
        requested_refund_amount=requested_refund_amount,
        currency=currency,
        reason=reason,
        summary=reason[:500],
        opened_at=datetime.now(timezone.utc),
        due_response_at=due_response_at,
        resolution={},
        meta={},
    )
    db.add(dispute)
    db.flush()

    db.add(
        DisputeEvent(
            dispute_id=dispute.id,
            from_status=None,
            to_status=DisputeStatus.open.value,
            actor_type=DisputeActorType.client if opened_by_user_id != against_user else DisputeActorType.pro,
            actor_user_id=opened_by_user_id,
            note="dispute_opened",
            payload={
                "requested_refund_amount": str(requested_refund_amount) if requested_refund_amount is not None else None,
                "currency": currency,
            },
        )
    )

    if gig and category in {DisputeCategory.fraud, DisputeCategory.billing, DisputeCategory.payment}:
        apply_entitlement_hold(db, gig_id=gig.id, user_id=gig.client_user_id, hold_type=EntitlementHoldType.downloads_frozen, reason="dispute_open")
    if gig and against_user == gig.pro_user_id:
        create_earnings_hold(
            db,
            pro_user_id=gig.pro_user_id,
            reason=EarningsHoldReason.dispute_open,
            amount_eur=None,
            source_type=EarningsSourceType.gig_base.value,
            source_id=gig.id,
            created_by_admin_id=None,
        )
    elif extra_purchase and against_user == extra_purchase.pro_user_id:
        create_earnings_hold(
            db,
            pro_user_id=extra_purchase.pro_user_id,
            reason=EarningsHoldReason.dispute_open,
            amount_eur=None,
            source_type=EarningsSourceType.extra_images.value,
            source_id=extra_purchase.id,
            created_by_admin_id=None,
        )

    log_event(
        db,
        event_name="dispute.opened",
        user_id=opened_by_user_id,
        properties={"dispute_id": str(dispute.id), "gig_id": str(gig_id) if gig_id else None, "category": category.value},
    )

    # abuse heuristics
    against_count_90d = db.execute(
        select(func.count()).select_from(Dispute).where(
            Dispute.against_user_id == against_user,
            Dispute.opened_at >= datetime.now(timezone.utc) - timedelta(days=90),
        )
    ).scalar_one()
    if against_count_90d >= 5:
        create_abuse_signal(
            db,
            signal_type="repeated_disputes_against_pro" if gig and against_user == gig.pro_user_id else "repeated_disputes_against_user",
            severity=AbuseSeverity.medium,
            user_id=against_user,
            evidence={"count_90d": int(against_count_90d), "dispute_id": str(dispute.id)},
        )

    opener_count_90d = db.execute(
        select(func.count()).select_from(Dispute).where(
            Dispute.opened_by_user_id == opened_by_user_id,
            Dispute.opened_at >= datetime.now(timezone.utc) - timedelta(days=90),
        )
    ).scalar_one()
    if opener_count_90d >= 5:
        create_abuse_signal(
            db,
            signal_type="repeated_disputes_by_user",
            severity=AbuseSeverity.low,
            user_id=opened_by_user_id,
            evidence={"count_90d": int(opener_count_90d), "dispute_id": str(dispute.id)},
        )

    enqueue_notification(
        db,
        user_id=against_user,
        notification_type="dispute.opened",
        payload={
            "title": "New dispute opened",
            "body": "A dispute was opened and is awaiting your response.",
            "action": {"label": "View dispute", "url": f"/disputes/{dispute.id}"},
        },
        reference_type="dispute",
        reference_id=str(dispute.id),
    )
    evaluate_dispute_rate_rule(db, user_id=opened_by_user_id)
    return dispute


def post_dispute_message(
    db: Session,
    *,
    dispute: Dispute,
    sender_user_id: uuid.UUID,
    message: str,
    evidence_media_asset_ids: list[uuid.UUID],
    sender_role: DisputeActorType,
) -> DisputeMessage:
    today = datetime.now(timezone.utc)
    per_day = db.execute(
        select(func.count()).select_from(DisputeMessage).where(
            DisputeMessage.dispute_id == dispute.id,
            DisputeMessage.sender_user_id == sender_user_id,
            DisputeMessage.created_at >= datetime(today.year, today.month, today.day, tzinfo=timezone.utc),
        )
    ).scalar_one()
    if per_day >= int(getattr(settings, "dispute_messages_per_day", 10)):
        raise APIError(code="rate_limited", message="Too many dispute messages today", status_code=429)

    row = DisputeMessage(
        dispute_id=dispute.id,
        sender_user_id=sender_user_id,
        message=message,
        evidence_media_asset_ids=[str(item) for item in evidence_media_asset_ids],
    )
    db.add(row)

    previous = dispute.status
    if dispute.status == DisputeStatus.open:
        dispute.status = DisputeStatus.awaiting_response
    elif dispute.status in {DisputeStatus.awaiting_response, DisputeStatus.in_review}:
        dispute.status = DisputeStatus.in_review

    db.add(
        DisputeEvent(
            dispute_id=dispute.id,
            from_status=previous.value if previous else None,
            to_status=dispute.status.value,
            actor_type=sender_role,
            actor_user_id=sender_user_id,
            note="message_added",
            payload={"message_id": str(row.id)},
        )
    )
    db.flush()
    return row


def estimate_late_delivery_refund_percent(db: Session, dispute: Dispute) -> int:
    if dispute.category not in {DisputeCategory.late_delivery}:
        return 0
    if not dispute.gig_id:
        return 0
    sla = db.execute(
        select(DeliverySlaSnapshot).where(DeliverySlaSnapshot.gig_id == dispute.gig_id).order_by(DeliverySlaSnapshot.created_at.desc())
    ).scalars().first()
    if not sla or not sla.finals_due_at:
        return 0
    now = datetime.now(timezone.utc)
    days_late = max(0, (now - sla.finals_due_at).days)
    if days_late < 2:
        return 0
    if days_late > 7:
        return 50
    # 2..7 days => 10..30
    return int(round(10 + ((days_late - 2) / 5) * 20))


def create_or_get_refund_case_for_dispute(
    db: Session,
    *,
    dispute: Dispute,
    decision: str,
    amount: Decimal | None,
) -> list[RefundCase]:
    """Returns one RefundCase per underlying payment needed to cover the
    resolved amount, oldest payment first. Usually a list of one - only
    a gig with a difference charge (or a purchase, which stays 1:1)
    produces more than one."""
    if decision == "no_refund":
        return []

    existing = db.execute(select(RefundCase).where(RefundCase.dispute_id == dispute.id)).scalars().all()
    if existing:
        return list(existing)

    currency = dispute.currency or "EUR"

    if dispute.extra_purchase_id:
        purchase = db.get(ExtraImagePurchase, dispute.extra_purchase_id)
        if not purchase:
            raise APIError(code="not_found", message="Extra purchase not found", status_code=404)
        payment_scope = RefundPaymentScope.extra_image_purchase
        reference_id = purchase.id
        amount_authorized = purchase.total
        currency = purchase.currency if hasattr(purchase, "currency") else currency
        gig_id = purchase.gig_id
        requested_by = dispute.opened_by_user_id
        payment_allocations = [(purchase.stripe_payment_intent_id, None, amount_authorized)]
    else:
        if not dispute.gig_id:
            raise APIError(code="validation_error", message="Dispute has no payment reference", status_code=422)
        payments = list_succeeded_payments_for_gig(db, dispute.gig_id)
        if not payments:
            raise APIError(code="not_found", message="Stripe payment not found", status_code=404)
        payment_scope = RefundPaymentScope.booking_payment
        reference_id = dispute.gig_id
        amount_authorized = sum((p.amount for p in payments), Decimal("0.00"))
        currency = payments[0].currency
        gig_id = dispute.gig_id
        requested_by = dispute.opened_by_user_id
        payment_allocations = None  # computed below, once refund_amount is known

    refund_amount = amount
    if refund_amount is None:
        if decision == "full_refund":
            refund_amount = amount_authorized
        elif decision == "partial_refund":
            percent = estimate_late_delivery_refund_percent(db, dispute)
            if percent <= 0:
                policy = db.execute(select(RefundPolicy).where(RefundPolicy.category == dispute.category)).scalar_one_or_none()
                percent = int(policy.max_refund_percent or 30) if policy else 30
            refund_amount = (amount_authorized * Decimal(percent) / Decimal(100)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        else:
            refund_amount = Decimal("0.00")

    refund_amount = max(Decimal("0.00"), min(amount_authorized, refund_amount)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    if payment_allocations is None:
        allocation = allocate_amount_oldest_first(payments, refund_amount)
        payment_allocations = [(p.stripe_payment_intent_id, p.id, take) for p, take in allocation]

    rows: list[RefundCase] = []
    for stripe_payment_intent_id, stripe_payment_id, take in payment_allocations:
        row = RefundCase(
            gig_id=gig_id,
            dispute_id=dispute.id,
            requested_by_user_id=requested_by,
            payment_scope=payment_scope,
            reference_id=reference_id,
            stripe_payment_intent_id=stripe_payment_intent_id,
            amount_authorized=amount_authorized,
            amount_refunded=Decimal("0.00"),
            status=RefundCaseStatus.pending,
            amount=take,
            currency=currency,
            reason=dispute.reason,
            admin_note=None,
            meta={"stripe_payment_id": str(stripe_payment_id)} if stripe_payment_id else {},
        )
        db.add(row)
        rows.append(row)
    db.flush()
    return rows


def apply_pro_quality_penalty(db: Session, *, dispute: Dispute, severity: ProQualityPenaltySeverity) -> ProQualityPenalty | None:
    if not dispute.against_user_id:
        return None
    penalty_type = ProQualityPenaltyType.warning
    recent = db.execute(
        select(func.count()).select_from(Dispute).where(
            Dispute.against_user_id == dispute.against_user_id,
            Dispute.status.in_([
                DisputeStatus.resolved_refund,
                DisputeStatus.resolved_partial_refund,
            ]),
            Dispute.resolved_at >= datetime.now(timezone.utc) - timedelta(days=90),
        )
    ).scalar_one()
    if recent >= 3:
        penalty_type = ProQualityPenaltyType.visibility_downrank
    if recent >= 5:
        penalty_type = ProQualityPenaltyType.temporary_suspension

    row = ProQualityPenalty(
        pro_user_id=dispute.against_user_id,
        dispute_id=dispute.id,
        type=penalty_type,
        severity=severity,
        expires_at=(datetime.now(timezone.utc) + timedelta(days=14)) if penalty_type != ProQualityPenaltyType.warning else None,
        meta={"recent_refund_disputes_90d": int(recent)},
    )
    db.add(row)
    db.flush()
    return row


def clawback_gig_rewards_for_fraud(db: Session, *, gig_id: uuid.UUID, user_id: uuid.UUID) -> int:
    reward_refs = db.execute(
        select(RewardLedgerEntry).where(
            RewardLedgerEntry.user_id == user_id,
            RewardLedgerEntry.entry_type == RewardEntryType.earn,
            or_(
                and_(RewardLedgerEntry.reference_type == "consent_reward", RewardLedgerEntry.reference_id.ilike(f"{gig_id}:%")),
                RewardLedgerEntry.reference_type == "share_reward",
            ),
        )
    ).scalars().all()
    total = sum(max(0, int(item.amount)) for item in reward_refs)
    if total <= 0:
        return 0
    adjustment = add_reward_entry(
        db,
        user_id=user_id,
        amount=-total,
        entry_type=RewardEntryType.adjustment,
        reference_type="fraud_clawback",
        reference_id=str(gig_id),
        metadata={"gig_id": str(gig_id)},
        min_balance_floor=settings.reward_balance_floor,
    )
    return abs(int(adjustment.amount)) if adjustment else 0


def initiate_refund_case(db: Session, refund_case_id: uuid.UUID) -> RefundCase:
    row = db.get(RefundCase, refund_case_id)
    if not row:
        raise APIError(code="not_found", message="Refund case not found", status_code=404)

    if row.status in {RefundCaseStatus.refunded, RefundCaseStatus.succeeded}:
        return row
    existing_refund_id = (row.meta or {}).get("stripe_refund_id")
    if row.status == RefundCaseStatus.refund_initiated and existing_refund_id:
        return row
    if not row.stripe_payment_intent_id:
        raise APIError(code="invalid_state", message="Missing payment intent for refund", status_code=409)

    row.status = RefundCaseStatus.refund_initiated
    amount_minor = int((row.amount * Decimal("100")).quantize(Decimal("1")))
    refund = stripe.Refund.create(
        payment_intent=row.stripe_payment_intent_id,
        amount=amount_minor,
        metadata={
            "refund_case_id": str(row.id),
            "dispute_id": str(row.dispute_id) if row.dispute_id else "",
        },
        idempotency_key=f"refund-case:{row.id}",
    )

    row.meta = {**(row.meta or {}), "stripe_refund_id": refund.id}
    db.add(
        RefundEvent(
            refund_case_id=row.id,
            type="refund_initiated",
            payload={"stripe_refund_id": refund.id, "status": getattr(refund, "status", None)},
        )
    )
    log_event(db, event_name="refund.initiated", user_id=row.requested_by_user_id, properties={"refund_case_id": str(row.id)})
    db.flush()
    return row


def finalize_refund_case_success(db: Session, *, stripe_refund_id: str) -> RefundCase | None:
    rows = db.execute(select(RefundCase).where(RefundCase.meta["stripe_refund_id"].astext == stripe_refund_id)).scalars().all()
    if not rows:
        return None
    row = rows[0]
    row.status = RefundCaseStatus.refunded
    row.amount_refunded = row.amount
    db.add(RefundEvent(refund_case_id=row.id, type="refund_succeeded", payload={"stripe_refund_id": stripe_refund_id}))
    if row.dispute_id:
        dispute = db.get(Dispute, row.dispute_id)
        if dispute:
            dispute.status = DisputeStatus.resolved_partial_refund if row.amount < (row.amount_authorized or row.amount) else DisputeStatus.resolved_refund
            dispute.resolved_at = datetime.now(timezone.utc)
            db.add(
                DisputeEvent(
                    dispute_id=dispute.id,
                    from_status=None,
                    to_status=dispute.status.value,
                    actor_type=DisputeActorType.system,
                    actor_user_id=None,
                    note="refund_succeeded",
                    payload={"refund_case_id": str(row.id)},
                )
            )
            if dispute.gig_id and dispute.against_user_id:
                hold = active_entitlement_hold(db, gig_id=dispute.gig_id, user_id=dispute.opened_by_user_id, hold_type=EntitlementHoldType.downloads_frozen)
                if hold:
                    release_entitlement_hold(db, hold)
                apply_pro_quality_penalty(db, dispute=dispute, severity=ProQualityPenaltySeverity.medium)
                release_earnings_holds_for_source(
                    db,
                    pro_user_id=dispute.against_user_id,
                    source_type=EarningsSourceType.gig_base.value,
                    source_id=dispute.gig_id,
                )
                reverse_earnings_entries_for_source(
                    db,
                    source_type=EarningsSourceType.gig_base,
                    source_id=dispute.gig_id,
                    reason=f"dispute_refund:{row.id}",
                )

            # extra purchase entitlement revocation policy
            if dispute.extra_purchase_id and dispute.gig_id:
                purchase = db.get(ExtraImagePurchase, dispute.extra_purchase_id)
                if purchase:
                    purchase.status = ExtraImagePurchaseStatus.refunded
                    if dispute.against_user_id:
                        release_earnings_holds_for_source(
                            db,
                            pro_user_id=dispute.against_user_id,
                            source_type=EarningsSourceType.extra_images.value,
                            source_id=dispute.extra_purchase_id,
                        )
                    reverse_earnings_entries_for_source(
                        db,
                        source_type=EarningsSourceType.extra_images,
                        source_id=dispute.extra_purchase_id,
                        reason=f"dispute_refund:{row.id}",
                    )
                    increment_entitlement_quantity(
                        db,
                        gig_id=dispute.gig_id,
                        user_id=purchase.client_user_id,
                        entitlement_type=GigEntitlementType.download_extras,
                        delta=-(purchase.extra_images or 0),
                    )

    log_event(db, event_name="refund.succeeded", user_id=row.requested_by_user_id, properties={"refund_case_id": str(row.id)})
    if row.gig_id:
        enqueue_raww_refund_reversal(db, gig_id=row.gig_id, refund_case_id=row.id)
    db.flush()
    return row


def finalize_refund_case_failed(db: Session, *, stripe_refund_id: str, reason: str | None = None) -> RefundCase | None:
    rows = db.execute(select(RefundCase).where(RefundCase.meta["stripe_refund_id"].astext == stripe_refund_id)).scalars().all()
    if not rows:
        return None
    row = rows[0]
    row.status = RefundCaseStatus.failed
    row.meta = {**(row.meta or {}), "failure_reason": reason}
    db.add(RefundEvent(refund_case_id=row.id, type="refund_failed", payload={"stripe_refund_id": stripe_refund_id, "reason": reason}))
    log_event(db, event_name="refund.failed", user_id=row.requested_by_user_id, properties={"refund_case_id": str(row.id)})
    db.flush()
    return row


def escalate_due_disputes(db: Session, *, now: datetime | None = None, limit: int = 200) -> int:
    current = now or datetime.now(timezone.utc)
    rows = db.execute(
        select(Dispute).where(
            Dispute.status.in_([DisputeStatus.open, DisputeStatus.awaiting_response, DisputeStatus.in_review]),
            Dispute.due_response_at.is_not(None),
            Dispute.due_response_at < current,
        ).order_by(Dispute.due_response_at.asc()).limit(limit)
    ).scalars().all()
    count = 0
    failed = 0
    for dispute in rows:
        try:
            with db.begin_nested():
                previous = dispute.status
                dispute.status = DisputeStatus.awaiting_admin
                db.add(
                    DisputeEvent(
                        dispute_id=dispute.id,
                        from_status=previous.value,
                        to_status=dispute.status.value,
                        actor_type=DisputeActorType.system,
                        actor_user_id=None,
                        note="auto_escalated_due_response_timeout",
                        payload={"due_response_at": dispute.due_response_at.isoformat() if dispute.due_response_at else None},
                    )
                )
                if dispute.against_user_id:
                    enqueue_notification(
                        db,
                        user_id=dispute.against_user_id,
                        notification_type="dispute.escalated",
                        payload={
                            "title": "Dispute escalated",
                            "body": "A dispute was escalated to admin review due to response timeout.",
                            "action": {"label": "View dispute", "url": f"/disputes/{dispute.id}"},
                        },
                        reference_type="dispute",
                        reference_id=str(dispute.id),
                    )
                log_event(
                    db,
                    event_name="dispute.escalated",
                    user_id=dispute.opened_by_user_id,
                    properties={"dispute_id": str(dispute.id)},
                )
            count += 1
        except Exception:
            failed += 1
            logger.exception("escalate_dispute_failed", extra={"dispute_id": str(dispute.id)})
    db.flush()
    logger.info("escalate_due_disputes_sweep", extra={"scanned": len(rows), "escalated": count, "failed": failed})
    return count
