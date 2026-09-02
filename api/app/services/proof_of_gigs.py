from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_DOWN

from sqlalchemy import and_, func, or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import Dispute, DisputeStatus, RefundCase, RefundCaseStatus
from app.models.client_rewards_pricing import ExtraImagePurchase, ExtraImagePurchaseStatus
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment
from app.models.niche import ProNicheSkill, SkillTier
from app.models.ops import AbuseSeverity, AbuseSignal, AbuseSignalStatus
from app.models.proof_of_gigs import (
    RawwClawback,
    RawwIssuanceCap,
    RawwIssuanceCapScope,
    RawwIssuanceEventType,
    RawwIssuanceRule,
    RawwMintEvent,
    RawwMintEventStatus,
    RawwMultiplierPolicy,
)
from app.models.review import ProReputation, Review, ReviewStatus
from app.models.reward import RewardEntryType
from app.models.studioverse import ContentPack, ContentPackOrder, ContentPackOrderStatus
from app.services.analytics import log_event
from app.services.feature_flags import is_feature_enabled
from app.services.metrics import observe_business_event, observe_raww_mint
from app.services.outbox import enqueue_outbox_event
from app.services.rewards import add_reward_entry

settings = get_settings()


DEFAULT_ISSUANCE_RULES: dict[RawwIssuanceEventType, dict[str, Decimal | int | None]] = {
    RawwIssuanceEventType.gig_completed: {"base_raww": 120, "min_eur_value": Decimal("20.00"), "max_raww_per_event": 500},
    RawwIssuanceEventType.gig_delivery_confirmed: {"base_raww": 90, "min_eur_value": Decimal("20.00"), "max_raww_per_event": 400},
    RawwIssuanceEventType.review_posted: {"base_raww": 60, "min_eur_value": Decimal("20.00"), "max_raww_per_event": 250},
    RawwIssuanceEventType.gig_extras_purchased: {"base_raww": 80, "min_eur_value": Decimal("5.00"), "max_raww_per_event": 600},
    RawwIssuanceEventType.studioverse_pack_sold: {"base_raww": 100, "min_eur_value": Decimal("2.00"), "max_raww_per_event": 700},
    RawwIssuanceEventType.studioverse_milestone_reached: {"base_raww": 300, "min_eur_value": Decimal("0.00"), "max_raww_per_event": 2000},
}

DEFAULT_CAPS: dict[RawwIssuanceCapScope, int] = {
    RawwIssuanceCapScope.pro_daily: 3000,
    RawwIssuanceCapScope.pro_weekly: 12000,
    RawwIssuanceCapScope.pro_monthly: 40000,
    RawwIssuanceCapScope.global_daily: 300000,
}

DEFAULT_MILESTONES = (10, 50, 200)


@dataclass
class _MintContext:
    event_type: RawwIssuanceEventType
    pro_user_id: uuid.UUID
    reference_type: str
    reference_id: uuid.UUID
    eur_value: Decimal
    gig_id: uuid.UUID | None
    client_user_id: uuid.UUID | None
    niche_id: uuid.UUID | None


def ensure_default_raww_config(db: Session) -> None:
    for event_type, cfg in DEFAULT_ISSUANCE_RULES.items():
        row = db.execute(select(RawwIssuanceRule).where(RawwIssuanceRule.event_type == event_type)).scalar_one_or_none()
        if row:
            continue
        db.add(
            RawwIssuanceRule(
                event_type=event_type,
                base_raww=int(cfg["base_raww"]),
                min_eur_value=Decimal(str(cfg["min_eur_value"])),
                max_raww_per_event=int(cfg["max_raww_per_event"]) if cfg["max_raww_per_event"] is not None else None,
                is_active=True,
            )
        )

    policy = db.execute(select(RawwMultiplierPolicy).where(RawwMultiplierPolicy.name == "default")).scalar_one_or_none()
    if not policy:
        db.add(
            RawwMultiplierPolicy(
                name="default",
                tier_multipliers={"rookie": 0.9, "skilled": 1.0, "pro": 1.1, "elite": 1.2, "master": 1.3},
                rating_curve={"4.0": 0.9, "4.5": 1.0, "4.8": 1.1},
                dispute_penalty={"open": 0.7, "lost_refund": 0.3},
                refund_penalty_multiplier=Decimal("0.500"),
                abuse_block_threshold={
                    "max_open_high_abuse_signals": 3,
                    "rating_min_reviews": 3,
                    "rating_newbie_multiplier": 1.0,
                    "pair_window_days": 30,
                    "pair_max_gigs": 4,
                    "pair_total_eur_threshold": 200,
                    "pair_multiplier": 0.5,
                },
            )
        )

    for scope, cap in DEFAULT_CAPS.items():
        row = db.execute(select(RawwIssuanceCap).where(RawwIssuanceCap.scope == scope)).scalar_one_or_none()
        if row:
            continue
        db.add(RawwIssuanceCap(scope=scope, cap_raww=int(cap)))
    db.flush()


def enqueue_raww_mint(
    db: Session,
    *,
    event_type: RawwIssuanceEventType,
    payload: dict,
    idempotency_key: str,
) -> None:
    enqueue_outbox_event(
        db,
        topic="raww.mint",
        payload={"event_type": event_type.value, **payload},
        idempotency_key=idempotency_key,
        idempotency_scope="raww_mint",
    )


def enqueue_raww_refund_reversal(db: Session, *, gig_id: uuid.UUID, refund_case_id: uuid.UUID | None = None) -> None:
    key = f"raww-reverse-refund:{gig_id}:{refund_case_id or 'none'}"
    enqueue_outbox_event(
        db,
        topic="raww.reverse_refund",
        payload={"gig_id": str(gig_id), "refund_case_id": str(refund_case_id) if refund_case_id else None},
        idempotency_key=key,
        idempotency_scope="raww_mint",
    )


def enqueue_studioverse_milestone_scan(db: Session, *, requested_by: uuid.UUID | None = None) -> None:
    suffix = requested_by or uuid.uuid4()
    enqueue_outbox_event(
        db,
        topic="raww.milestone.scan",
        payload={"requested_by": str(requested_by) if requested_by else None},
        idempotency_key=f"raww-milestone-scan:{suffix}",
        idempotency_scope="raww_milestones",
    )


def process_raww_mint_event(db: Session, *, payload: dict) -> RawwMintEvent | None:
    ensure_default_raww_config(db)
    event_type_raw = str(payload.get("event_type") or "")
    try:
        event_type = RawwIssuanceEventType(event_type_raw)
    except ValueError:
        return None

    if not is_feature_enabled(db, "raww_minting_enabled"):
        return None

    if event_type == RawwIssuanceEventType.gig_completed and not is_feature_enabled(db, "raww_minting_event_gig_completed_enabled"):
        return None
    if event_type == RawwIssuanceEventType.studioverse_pack_sold and not is_feature_enabled(db, "raww_minting_event_pack_sold_enabled"):
        return None

    ctx = _resolve_context(db, event_type=event_type, payload=payload)
    if not ctx:
        return None

    existing = db.execute(
        select(RawwMintEvent).where(
            RawwMintEvent.event_type == event_type.value,
            RawwMintEvent.reference_type == ctx.reference_type,
            RawwMintEvent.reference_id == ctx.reference_id,
            RawwMintEvent.pro_user_id == ctx.pro_user_id,
        )
    ).scalar_one_or_none()
    if existing:
        return existing

    rule = db.execute(select(RawwIssuanceRule).where(RawwIssuanceRule.event_type == event_type)).scalar_one_or_none()
    if not rule or not rule.is_active:
        event = _insert_mint_event(
            db,
            event_type=event_type,
            pro_user_id=ctx.pro_user_id,
            reference_type=ctx.reference_type,
            reference_id=ctx.reference_id,
            raww_awarded=0,
            status=RawwMintEventStatus.blocked,
            snapshot={"reason": "rule_inactive"},
        )
        observe_raww_mint(event_type=event_type.value, status="blocked", reason="rule_inactive")
        return event

    if ctx.eur_value < rule.min_eur_value:
        event = _insert_mint_event(
            db,
            event_type=event_type,
            pro_user_id=ctx.pro_user_id,
            reference_type=ctx.reference_type,
            reference_id=ctx.reference_id,
            raww_awarded=0,
            status=RawwMintEventStatus.blocked,
            snapshot={"reason": "below_min_eur_value", "eur_value": str(ctx.eur_value), "min_eur_value": str(rule.min_eur_value)},
        )
        observe_raww_mint(event_type=event_type.value, status="blocked", reason="below_min_eur_value")
        return event

    policy = db.execute(select(RawwMultiplierPolicy).where(RawwMultiplierPolicy.name == "default")).scalar_one()

    blocked_reason = _blocking_reason(db, ctx=ctx, policy=policy)
    if blocked_reason:
        event = _insert_mint_event(
            db,
            event_type=event_type,
            pro_user_id=ctx.pro_user_id,
            reference_type=ctx.reference_type,
            reference_id=ctx.reference_id,
            raww_awarded=0,
            status=RawwMintEventStatus.blocked,
            snapshot={"reason": blocked_reason},
        )
        observe_business_event("raww_mint_blocked")
        observe_raww_mint(event_type=event_type.value, status="blocked", reason=blocked_reason)
        log_event(
            db,
            event_name="raww.mint_blocked",
            user_id=ctx.pro_user_id,
            properties={"event_type": event_type.value, "reference_type": ctx.reference_type, "reason": blocked_reason},
        )
        return event

    multipliers, raw_total = _compute_raw_award(db, ctx=ctx, rule=rule, policy=policy)
    raw_after_caps, cap_meta = _apply_caps(db, pro_user_id=ctx.pro_user_id, proposed=max(0, raw_total))

    if rule.max_raww_per_event is not None:
        raw_after_caps = min(raw_after_caps, int(rule.max_raww_per_event))
        cap_meta["max_raww_per_event"] = int(rule.max_raww_per_event)

    if raw_after_caps <= 0:
        event = _insert_mint_event(
            db,
            event_type=event_type,
            pro_user_id=ctx.pro_user_id,
            reference_type=ctx.reference_type,
            reference_id=ctx.reference_id,
            raww_awarded=0,
            status=RawwMintEventStatus.blocked,
            snapshot={"reason": "caps_exceeded", "caps": cap_meta, "multipliers": multipliers},
        )
        observe_business_event("raww_mint_blocked")
        observe_raww_mint(event_type=event_type.value, status="blocked", reason="caps_exceeded")
        log_event(
            db,
            event_name="raww.mint_blocked",
            user_id=ctx.pro_user_id,
            properties={"event_type": event_type.value, "reference_type": ctx.reference_type, "reason": "caps_exceeded"},
        )
        return event

    snapshot = {
        "base_raww": int(rule.base_raww),
        "eur_value": str(ctx.eur_value),
        "multipliers": multipliers,
        "caps": cap_meta,
    }
    event = _insert_mint_event(
        db,
        event_type=event_type,
        pro_user_id=ctx.pro_user_id,
        reference_type=ctx.reference_type,
        reference_id=ctx.reference_id,
        raww_awarded=int(raw_after_caps),
        status=RawwMintEventStatus.minted,
        snapshot=snapshot,
    )

    idempotency_key = f"mint:{event_type.value}:{ctx.reference_type}:{ctx.reference_id}:{ctx.pro_user_id}"
    add_reward_entry(
        db,
        user_id=ctx.pro_user_id,
        amount=int(raw_after_caps),
        entry_type=RewardEntryType.earn,
        rule_code="proof_of_gigs",
        reference_type="raww_mint",
        reference_id=idempotency_key,
        metadata={
            "mint_event_id": str(event.id),
            "event_type": event_type.value,
            "reference_type": ctx.reference_type,
            "reference_id": str(ctx.reference_id),
        },
    )

    observe_business_event("raww_mint_succeeded")
    observe_raww_mint(event_type=event_type.value, status="minted", amount=int(raw_after_caps))
    log_event(
        db,
        event_name="raww.mint_succeeded",
        user_id=ctx.pro_user_id,
        properties={
            "event_type": event_type.value,
            "reference_type": ctx.reference_type,
            "reference_id": str(ctx.reference_id),
            "awarded": int(raw_after_caps),
        },
    )
    return event


def create_raww_clawback(
    db: Session,
    *,
    pro_user_id: uuid.UUID,
    reference_type: str,
    reference_id: uuid.UUID,
    amount_raww: int,
    reason: str,
    created_by_admin_id: uuid.UUID | None,
) -> RawwClawback:
    if amount_raww <= 0:
        raise APIError(code="validation_error", message="amount_raww must be > 0", status_code=422)

    row = RawwClawback(
        pro_user_id=pro_user_id,
        reference_type=reference_type,
        reference_id=reference_id,
        amount_raww=int(amount_raww),
        reason=reason.strip(),
        created_by_admin_id=created_by_admin_id,
    )
    db.add(row)
    db.flush()

    entry = add_reward_entry(
        db,
        user_id=pro_user_id,
        amount=-int(amount_raww),
        entry_type=RewardEntryType.adjustment,
        reference_type="raww_clawback",
        reference_id=str(row.id),
        metadata={"reason": reason, "reference_type": reference_type, "reference_id": str(reference_id)},
        min_balance_floor=settings.reward_balance_floor,
    )
    if not entry:
        raise APIError(code="validation_error", message="Clawback would exceed balance floor", status_code=422)

    observe_business_event("raww_clawback")
    log_event(
        db,
        event_name="raww.clawback",
        user_id=pro_user_id,
        properties={"clawback_id": str(row.id), "amount_raww": amount_raww, "reason": reason},
    )
    return row


def reverse_raww_mints_for_refund(db: Session, *, gig_id: uuid.UUID, reason: str) -> int:
    review_ids = db.execute(select(Review.id).where(Review.gig_id == gig_id)).scalars().all()
    extra_ids = db.execute(select(ExtraImagePurchase.id).where(ExtraImagePurchase.gig_id == gig_id)).scalars().all()

    stmt = select(RawwMintEvent).where(
        RawwMintEvent.status == RawwMintEventStatus.minted,
        or_(
            and_(RawwMintEvent.reference_type == "gig", RawwMintEvent.reference_id == gig_id),
            and_(RawwMintEvent.reference_type == "review", RawwMintEvent.reference_id.in_(review_ids or [uuid.uuid4()])),
            and_(RawwMintEvent.reference_type == "extra_purchase", RawwMintEvent.reference_id.in_(extra_ids or [uuid.uuid4()])),
        ),
    )
    rows = db.execute(stmt).scalars().all()
    return _reverse_mint_rows(db, rows=rows, reason=reason, extra_meta={"gig_id": str(gig_id)})


def reverse_raww_mints_for_reference(db: Session, *, reference_type: str, reference_id: uuid.UUID, reason: str) -> int:
    rows = db.execute(
        select(RawwMintEvent).where(
            RawwMintEvent.status == RawwMintEventStatus.minted,
            RawwMintEvent.reference_type == reference_type,
            RawwMintEvent.reference_id == reference_id,
        )
    ).scalars().all()
    return _reverse_mint_rows(db, rows=rows, reason=reason, extra_meta={"reference_type": reference_type, "reference_id": str(reference_id)})


def enqueue_milestone_events(db: Session) -> int:
    emitted = 0
    packs = db.execute(select(ContentPack.id, ContentPack.creator_user_id)).all()
    for pack_id, creator_user_id in packs:
        paid_sales = db.execute(
            select(func.count()).select_from(ContentPackOrder).where(
                ContentPackOrder.content_pack_id == pack_id,
                ContentPackOrder.status == ContentPackOrderStatus.paid,
            )
        ).scalar_one()
        for threshold in DEFAULT_MILESTONES:
            if int(paid_sales) < threshold:
                continue
            milestone_ref = uuid.uuid5(uuid.NAMESPACE_DNS, f"raww-studioverse:{pack_id}:{threshold}")
            enqueue_raww_mint(
                db,
                event_type=RawwIssuanceEventType.studioverse_milestone_reached,
                payload={
                    "content_pack_id": str(pack_id),
                    "creator_user_id": str(creator_user_id),
                    "threshold": threshold,
                    "milestone_reference_id": str(milestone_ref),
                },
                idempotency_key=f"raww-milestone:{pack_id}:{threshold}",
            )
            emitted += 1
    return emitted


def list_raww_mints(
    db: Session,
    *,
    pro_user_id: uuid.UUID | None,
    event_type: str | None,
    from_at: datetime | None,
    to_at: datetime | None,
    limit: int,
) -> list[RawwMintEvent]:
    stmt = select(RawwMintEvent)
    if pro_user_id:
        stmt = stmt.where(RawwMintEvent.pro_user_id == pro_user_id)
    if event_type:
        stmt = stmt.where(RawwMintEvent.event_type == event_type)
    if from_at:
        stmt = stmt.where(RawwMintEvent.created_at >= from_at)
    if to_at:
        stmt = stmt.where(RawwMintEvent.created_at <= to_at)
    return db.execute(stmt.order_by(RawwMintEvent.created_at.desc()).limit(limit)).scalars().all()


def _resolve_context(db: Session, *, event_type: RawwIssuanceEventType, payload: dict) -> _MintContext | None:
    if event_type in {RawwIssuanceEventType.gig_completed, RawwIssuanceEventType.gig_delivery_confirmed}:
        gig_id = _uuid_from_payload(payload, "gig_id")
        gig = db.get(Gig, gig_id) if gig_id else None
        if not gig:
            return None
        return _MintContext(
            event_type=event_type,
            pro_user_id=gig.pro_user_id,
            reference_type="gig",
            reference_id=gig.id,
            eur_value=Decimal(str(gig.amount_minimum or 0)),
            gig_id=gig.id,
            client_user_id=gig.client_user_id,
            niche_id=gig.niche_id,
        )

    if event_type == RawwIssuanceEventType.review_posted:
        review_id = _uuid_from_payload(payload, "review_id")
        review = db.get(Review, review_id) if review_id else None
        if not review or review.status != ReviewStatus.published:
            return None
        gig = db.get(Gig, review.gig_id)
        if not gig:
            return None
        return _MintContext(
            event_type=event_type,
            pro_user_id=review.pro_user_id,
            reference_type="review",
            reference_id=review.id,
            eur_value=Decimal(str(gig.amount_minimum or 0)),
            gig_id=gig.id,
            client_user_id=review.client_user_id,
            niche_id=review.niche_id,
        )

    if event_type == RawwIssuanceEventType.gig_extras_purchased:
        extra_id = _uuid_from_payload(payload, "extra_purchase_id")
        extra = db.get(ExtraImagePurchase, extra_id) if extra_id else None
        if not extra or extra.status != ExtraImagePurchaseStatus.paid:
            return None
        return _MintContext(
            event_type=event_type,
            pro_user_id=extra.pro_user_id,
            reference_type="extra_purchase",
            reference_id=extra.id,
            eur_value=Decimal(str(extra.total or 0)),
            gig_id=extra.gig_id,
            client_user_id=extra.client_user_id,
            niche_id=extra.niche_id,
        )

    if event_type == RawwIssuanceEventType.studioverse_pack_sold:
        order_id = _uuid_from_payload(payload, "content_pack_order_id")
        order = db.get(ContentPackOrder, order_id) if order_id else None
        if not order or order.status != ContentPackOrderStatus.paid:
            return None
        pack = db.get(ContentPack, order.content_pack_id)
        if not pack:
            return None
        return _MintContext(
            event_type=event_type,
            pro_user_id=pack.creator_user_id,
            reference_type="content_pack_order",
            reference_id=order.id,
            eur_value=Decimal(str(order.price_eur_paid or 0)),
            gig_id=None,
            client_user_id=order.buyer_user_id,
            niche_id=None,
        )

    if event_type == RawwIssuanceEventType.studioverse_milestone_reached:
        pack_id = _uuid_from_payload(payload, "content_pack_id")
        ref_id = _uuid_from_payload(payload, "milestone_reference_id")
        creator_id = _uuid_from_payload(payload, "creator_user_id")
        if not pack_id or not ref_id or not creator_id:
            return None
        return _MintContext(
            event_type=event_type,
            pro_user_id=creator_id,
            reference_type="content_pack_milestone",
            reference_id=ref_id,
            eur_value=Decimal("0.00"),
            gig_id=None,
            client_user_id=None,
            niche_id=None,
        )

    return None


def _blocking_reason(db: Session, *, ctx: _MintContext, policy: RawwMultiplierPolicy) -> str | None:
    if ctx.client_user_id and ctx.client_user_id == ctx.pro_user_id:
        return "self_dealing"

    abuse_cfg = policy.abuse_block_threshold or {}
    max_high = int(abuse_cfg.get("max_open_high_abuse_signals", -1))
    if max_high >= 0:
        open_high = db.execute(
            select(func.count()).select_from(AbuseSignal).where(
                AbuseSignal.user_id == ctx.pro_user_id,
                AbuseSignal.status == AbuseSignalStatus.open,
                AbuseSignal.severity == AbuseSeverity.high,
            )
        ).scalar_one()
        if int(open_high) > max_high:
            return "abuse_threshold"
    return None


def _compute_raw_award(db: Session, *, ctx: _MintContext, rule: RawwIssuanceRule, policy: RawwMultiplierPolicy) -> tuple[dict, int]:
    tier_multiplier = _tier_multiplier(db, pro_user_id=ctx.pro_user_id, niche_id=ctx.niche_id, policy=policy)
    rating_multiplier = _rating_multiplier(db, pro_user_id=ctx.pro_user_id, policy=policy)
    dispute_multiplier = _dispute_multiplier(db, ctx=ctx, policy=policy)
    refund_multiplier = _refund_multiplier(db, ctx=ctx, policy=policy)
    pair_multiplier = _pair_multiplier(db, ctx=ctx, policy=policy)

    total_multiplier = Decimal(str(tier_multiplier))
    total_multiplier *= Decimal(str(rating_multiplier))
    total_multiplier *= Decimal(str(dispute_multiplier))
    total_multiplier *= Decimal(str(refund_multiplier))
    total_multiplier *= Decimal(str(pair_multiplier))

    raw = (Decimal(rule.base_raww) * total_multiplier).quantize(Decimal("1"), rounding=ROUND_DOWN)
    return {
        "tier_multiplier": float(tier_multiplier),
        "rating_multiplier": float(rating_multiplier),
        "dispute_multiplier": float(dispute_multiplier),
        "refund_multiplier": float(refund_multiplier),
        "pair_multiplier": float(pair_multiplier),
        "total_multiplier": float(total_multiplier),
    }, int(max(0, raw))


def _tier_multiplier(db: Session, *, pro_user_id: uuid.UUID, niche_id: uuid.UUID | None, policy: RawwMultiplierPolicy) -> float:
    mapping = policy.tier_multipliers or {}
    if not niche_id:
        return float(mapping.get(SkillTier.skilled.value, 1.0))
    skill = db.execute(
        select(ProNicheSkill).where(ProNicheSkill.pro_user_id == pro_user_id, ProNicheSkill.niche_id == niche_id)
    ).scalar_one_or_none()
    tier_name = skill.tier.value if skill else SkillTier.skilled.value
    return float(mapping.get(tier_name, 1.0))


def _rating_multiplier(db: Session, *, pro_user_id: uuid.UUID, policy: RawwMultiplierPolicy) -> float:
    rep = db.get(ProReputation, pro_user_id)
    if not rep:
        return 1.0
    cfg = policy.abuse_block_threshold or {}
    min_reviews = int(cfg.get("rating_min_reviews", 3))
    if int(rep.review_count or 0) < min_reviews:
        return float(cfg.get("rating_newbie_multiplier", 1.0))

    rating_curve = policy.rating_curve or {}
    current = float(rep.avg_rating or 0)
    picked = 1.0
    thresholds = sorted((float(k), float(v)) for k, v in rating_curve.items())
    for threshold, mult in thresholds:
        if current >= threshold:
            picked = mult
    return picked


def _dispute_multiplier(db: Session, *, ctx: _MintContext, policy: RawwMultiplierPolicy) -> float:
    if not ctx.gig_id:
        return 1.0
    penalties = policy.dispute_penalty or {}
    value = 1.0
    open_exists = db.execute(
        select(Dispute.id).where(
            Dispute.gig_id == ctx.gig_id,
            Dispute.status.in_(
                [
                    DisputeStatus.open,
                    DisputeStatus.awaiting_response,
                    DisputeStatus.in_review,
                    DisputeStatus.awaiting_admin,
                    DisputeStatus.under_review,
                ]
            ),
        )
    ).first()
    if open_exists:
        value *= float(penalties.get("open", 1.0))

    lost_refund = db.execute(
        select(Dispute.id).where(
            Dispute.gig_id == ctx.gig_id,
            Dispute.status.in_([DisputeStatus.resolved_refund, DisputeStatus.resolved_partial_refund]),
        )
    ).first()
    if lost_refund:
        value *= float(penalties.get("lost_refund", 1.0))
    return value


def _refund_multiplier(db: Session, *, ctx: _MintContext, policy: RawwMultiplierPolicy) -> float:
    if ctx.gig_id:
        gig = db.get(Gig, ctx.gig_id)
        if gig and gig.status == GigStatus.refunded:
            return float(policy.refund_penalty_multiplier)
        any_refunded_payment = db.execute(
            select(StripePayment.id).where(StripePayment.gig_id == ctx.gig_id, StripePayment.status == PaymentStatus.refunded)
        ).first()
        if any_refunded_payment:
            return float(policy.refund_penalty_multiplier)
        refund_case = db.execute(
            select(RefundCase.id).where(
                RefundCase.gig_id == ctx.gig_id,
                RefundCase.status.in_([RefundCaseStatus.refunded, RefundCaseStatus.succeeded]),
            )
        ).first()
        if refund_case:
            return float(policy.refund_penalty_multiplier)
    return 1.0


def _pair_multiplier(db: Session, *, ctx: _MintContext, policy: RawwMultiplierPolicy) -> float:
    if not ctx.client_user_id:
        return 1.0
    cfg = policy.abuse_block_threshold or {}
    window_days = int(cfg.get("pair_window_days", 30))
    max_gigs = int(cfg.get("pair_max_gigs", 4))
    eur_threshold = Decimal(str(cfg.get("pair_total_eur_threshold", "200")))
    pair_multiplier = float(cfg.get("pair_multiplier", 0.5))

    since = datetime.now(timezone.utc) - timedelta(days=window_days)
    count, total = db.execute(
        select(func.count(), func.coalesce(func.sum(Gig.amount_minimum), 0))
        .select_from(Gig)
        .where(
            Gig.client_user_id == ctx.client_user_id,
            Gig.pro_user_id == ctx.pro_user_id,
            Gig.created_at >= since,
        )
    ).one()
    if int(count) > max_gigs and Decimal(str(total or 0)) < eur_threshold:
        return pair_multiplier
    return 1.0


def _apply_caps(db: Session, *, pro_user_id: uuid.UUID, proposed: int) -> tuple[int, dict]:
    now = datetime.now(timezone.utc)
    rows = db.execute(select(RawwIssuanceCap)).scalars().all()
    by_scope = {row.scope: int(row.cap_raww) for row in rows}

    remaining = proposed
    meta: dict[str, int] = {"requested": proposed}
    for scope in (RawwIssuanceCapScope.pro_daily, RawwIssuanceCapScope.pro_weekly, RawwIssuanceCapScope.pro_monthly):
        cap = by_scope.get(scope)
        if cap is None:
            continue
        current = _minted_sum(db, scope=scope, now=now, pro_user_id=pro_user_id)
        allowed = max(0, cap - current)
        meta[f"{scope.value}_remaining"] = allowed
        remaining = min(remaining, allowed)

    global_cap = by_scope.get(RawwIssuanceCapScope.global_daily)
    if global_cap is not None:
        current_global = _minted_sum(db, scope=RawwIssuanceCapScope.global_daily, now=now, pro_user_id=None)
        allowed_global = max(0, global_cap - current_global)
        meta["global_daily_remaining"] = allowed_global
        remaining = min(remaining, allowed_global)

    meta["awarded_after_caps"] = max(0, int(remaining))
    return max(0, int(remaining)), meta


def _minted_sum(db: Session, *, scope: RawwIssuanceCapScope, now: datetime, pro_user_id: uuid.UUID | None) -> int:
    if scope == RawwIssuanceCapScope.pro_daily or scope == RawwIssuanceCapScope.global_daily:
        start = datetime(now.year, now.month, now.day, tzinfo=timezone.utc)
    elif scope == RawwIssuanceCapScope.pro_weekly:
        day_start = datetime(now.year, now.month, now.day, tzinfo=timezone.utc)
        start = day_start - timedelta(days=day_start.weekday())
    else:
        start = datetime(now.year, now.month, 1, tzinfo=timezone.utc)

    stmt = select(func.coalesce(func.sum(RawwMintEvent.raww_awarded), 0)).where(
        RawwMintEvent.status == RawwMintEventStatus.minted,
        RawwMintEvent.created_at >= start,
    )
    if pro_user_id is not None:
        stmt = stmt.where(RawwMintEvent.pro_user_id == pro_user_id)
    total = db.execute(stmt).scalar_one()
    return int(total or 0)


def _insert_mint_event(
    db: Session,
    *,
    event_type: RawwIssuanceEventType,
    pro_user_id: uuid.UUID,
    reference_type: str,
    reference_id: uuid.UUID,
    raww_awarded: int,
    status: RawwMintEventStatus,
    snapshot: dict,
) -> RawwMintEvent:
    savepoint = db.begin_nested()
    try:
        row = RawwMintEvent(
            event_type=event_type.value,
            pro_user_id=pro_user_id,
            reference_type=reference_type,
            reference_id=reference_id,
            raww_awarded=int(raww_awarded),
            status=status,
            multiplier_snapshot=snapshot,
        )
        db.add(row)
        db.flush()
        savepoint.commit()
        return row
    except IntegrityError:
        savepoint.rollback()
        return db.execute(
            select(RawwMintEvent).where(
                RawwMintEvent.event_type == event_type.value,
                RawwMintEvent.reference_type == reference_type,
                RawwMintEvent.reference_id == reference_id,
                RawwMintEvent.pro_user_id == pro_user_id,
            )
        ).scalar_one()


def _uuid_from_payload(payload: dict, key: str) -> uuid.UUID | None:
    raw = payload.get(key)
    if not raw:
        return None
    try:
        return uuid.UUID(str(raw))
    except Exception:
        return None


def _reverse_mint_rows(db: Session, *, rows: list[RawwMintEvent], reason: str, extra_meta: dict) -> int:
    reversed_count = 0
    for row in rows:
        if row.raww_awarded <= 0:
            row.status = RawwMintEventStatus.reversed
            continue
        adjustment = add_reward_entry(
            db,
            user_id=row.pro_user_id,
            amount=-int(row.raww_awarded),
            entry_type=RewardEntryType.adjustment,
            reference_type="raww_mint_reversal",
            reference_id=str(row.id),
            metadata={"reason": reason, **extra_meta},
            min_balance_floor=settings.reward_balance_floor,
        )
        if adjustment:
            row.status = RawwMintEventStatus.reversed
            reversed_count += 1
    return reversed_count
