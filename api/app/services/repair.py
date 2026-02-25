from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
from statistics import mean
from typing import Any

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile, UserRoleType
from app.models.media import MediaAsset
from app.models.niche import ProNicheSkill, SkillTier
from app.models.repair import (
    GearBenefitOverride,
    GearBenefitPolicy,
    GearCategory,
    GearItem,
    LoanerEvent,
    LoanerRequest,
    LoanerRequestStatus,
    RepairActorType,
    RepairEvent,
    RepairPartner,
    RepairPartnerScore,
    RepairTicket,
    RepairTicketStatus,
)
from app.services.analytics import log_event
from app.services.authz import enforce_not_banned, get_user_roles

TIER_RANK: dict[SkillTier, int] = {
    SkillTier.rookie: 0,
    SkillTier.skilled: 1,
    SkillTier.pro: 2,
    SkillTier.elite: 3,
    SkillTier.master: 4,
}

REPAIR_ALLOWED_TRANSITIONS: dict[RepairTicketStatus, set[RepairTicketStatus]] = {
    RepairTicketStatus.submitted: {RepairTicketStatus.partner_assigned, RepairTicketStatus.cancelled},
    RepairTicketStatus.partner_assigned: {RepairTicketStatus.awaiting_quote, RepairTicketStatus.cancelled},
    RepairTicketStatus.awaiting_quote: {RepairTicketStatus.quote_sent, RepairTicketStatus.cancelled},
    RepairTicketStatus.quote_sent: {RepairTicketStatus.quote_approved, RepairTicketStatus.quote_declined, RepairTicketStatus.cancelled},
    RepairTicketStatus.quote_approved: {RepairTicketStatus.in_repair},
    RepairTicketStatus.quote_declined: {RepairTicketStatus.closed, RepairTicketStatus.cancelled},
    RepairTicketStatus.in_repair: {RepairTicketStatus.ready_for_return},
    RepairTicketStatus.ready_for_return: {RepairTicketStatus.shipped_back},
    RepairTicketStatus.shipped_back: {RepairTicketStatus.closed},
    RepairTicketStatus.closed: set(),
    RepairTicketStatus.cancelled: set(),
}

LOANER_ALLOWED_TRANSITIONS: dict[LoanerRequestStatus, set[LoanerRequestStatus]] = {
    LoanerRequestStatus.requested: {LoanerRequestStatus.approved, LoanerRequestStatus.declined, LoanerRequestStatus.cancelled},
    LoanerRequestStatus.approved: {LoanerRequestStatus.ready_for_pickup, LoanerRequestStatus.shipped_to_pro, LoanerRequestStatus.cancelled},
    LoanerRequestStatus.ready_for_pickup: {LoanerRequestStatus.in_use, LoanerRequestStatus.cancelled},
    LoanerRequestStatus.shipped_to_pro: {LoanerRequestStatus.in_use, LoanerRequestStatus.cancelled},
    LoanerRequestStatus.in_use: {LoanerRequestStatus.return_due, LoanerRequestStatus.returned, LoanerRequestStatus.cancelled},
    LoanerRequestStatus.return_due: {LoanerRequestStatus.returned, LoanerRequestStatus.cancelled},
    LoanerRequestStatus.returned: {LoanerRequestStatus.closed},
    LoanerRequestStatus.declined: set(),
    LoanerRequestStatus.closed: set(),
    LoanerRequestStatus.cancelled: set(),
}


def get_or_create_gear_benefit_policy(db: Session) -> GearBenefitPolicy:
    policy = db.execute(select(GearBenefitPolicy).limit(1)).scalar_one_or_none()
    if policy:
        return policy
    policy = GearBenefitPolicy(
        require_kyc_approved=True,
        min_tier_any_niche=SkillTier.skilled,
        require_not_banned=True,
        meta={},
    )
    db.add(policy)
    db.flush()
    return policy


def highest_tier_for_pro(db: Session, pro_user_id: uuid.UUID) -> SkillTier | None:
    tiers = db.execute(select(ProNicheSkill.tier).where(ProNicheSkill.pro_user_id == pro_user_id)).scalars().all()
    if not tiers:
        return None
    return max(tiers, key=lambda tier: TIER_RANK.get(tier, -1))


def can_access_gear_benefits(db: Session, pro_user_id: uuid.UUID) -> dict[str, Any]:
    now = datetime.now(timezone.utc)
    override = db.execute(select(GearBenefitOverride).where(GearBenefitOverride.pro_user_id == pro_user_id)).scalar_one_or_none()
    if override and (override.expires_at is None or override.expires_at > now):
        return {
            "allowed": bool(override.is_allowed),
            "reason": "override_allowed" if override.is_allowed else "override_blocked",
            "max_tier": highest_tier_for_pro(db, pro_user_id),
        }

    roles = get_user_roles(db, pro_user_id)
    if UserRoleType.pro not in roles:
        return {"allowed": False, "reason": "pro_role_required", "max_tier": None}
    policy = get_or_create_gear_benefit_policy(db)
    if policy.require_not_banned:
        try:
            enforce_not_banned(db, pro_user_id)
        except APIError:
            return {"allowed": False, "reason": "banned_or_suspended", "max_tier": None}
    if policy.require_kyc_approved:
        profile = db.get(ProProfile, pro_user_id)
        if not profile or profile.kyc_status != KYCStatus.approved:
            return {"allowed": False, "reason": "kyc_required", "max_tier": None}
    tier = highest_tier_for_pro(db, pro_user_id)
    if not tier or TIER_RANK[tier] < TIER_RANK[policy.min_tier_any_niche]:
        return {"allowed": False, "reason": "tier_below_policy", "max_tier": tier}
    return {"allowed": True, "reason": "eligible", "max_tier": tier}


def validate_evidence_ownership(db: Session, pro_user_id: uuid.UUID, media_ids: list[uuid.UUID]) -> None:
    for media_id in media_ids:
        asset = db.get(MediaAsset, media_id)
        if not asset:
            raise APIError(code="validation_error", message=f"Media asset not found: {media_id}", status_code=422)
        if asset.owner_user_id != pro_user_id:
            raise APIError(code="forbidden", message="Evidence media must be owned by pro", status_code=403)


def create_repair_event(
    db: Session,
    *,
    ticket_id: uuid.UUID,
    from_status: RepairTicketStatus | None,
    to_status: RepairTicketStatus,
    actor_type: RepairActorType,
    actor_id: uuid.UUID | None,
    note: str | None = None,
    payload: dict | None = None,
) -> RepairEvent:
    event = RepairEvent(
        ticket_id=ticket_id,
        from_status=from_status.value if from_status else None,
        to_status=to_status.value,
        actor_type=actor_type,
        actor_id=actor_id,
        note=note,
        payload=payload or {},
    )
    db.add(event)
    db.flush()
    return event


def create_loaner_event(
    db: Session,
    *,
    loaner_request_id: uuid.UUID,
    from_status: LoanerRequestStatus | None,
    to_status: LoanerRequestStatus,
    actor_type: RepairActorType,
    actor_id: uuid.UUID | None,
    note: str | None = None,
    payload: dict | None = None,
) -> LoanerEvent:
    event = LoanerEvent(
        loaner_request_id=loaner_request_id,
        from_status=from_status.value if from_status else None,
        to_status=to_status.value,
        actor_type=actor_type,
        actor_id=actor_id,
        note=note,
        payload=payload or {},
    )
    db.add(event)
    db.flush()
    return event


def transition_repair_ticket(
    db: Session,
    *,
    ticket: RepairTicket,
    to_status: RepairTicketStatus,
    actor_type: RepairActorType,
    actor_id: uuid.UUID | None,
    note: str | None = None,
    payload: dict | None = None,
) -> RepairTicket:
    from_status = ticket.status
    if to_status not in REPAIR_ALLOWED_TRANSITIONS[from_status]:
        raise APIError(code="invalid_state_transition", message=f"Cannot transition {from_status.value} -> {to_status.value}", status_code=409)

    now = datetime.now(timezone.utc)
    ticket.status = to_status
    ticket.updated_at = now
    if to_status == RepairTicketStatus.quote_sent:
        ticket.quote_sent_at = now
        log_event(db, event_name="repair.quote_sent", user_id=ticket.pro_user_id, properties={"ticket_id": str(ticket.id)})
    elif to_status == RepairTicketStatus.quote_approved:
        ticket.quote_approved_at = now
        log_event(db, event_name="repair.quote_approved", user_id=ticket.pro_user_id, properties={"ticket_id": str(ticket.id)})
    elif to_status == RepairTicketStatus.in_repair:
        ticket.repair_started_at = ticket.repair_started_at or now
    elif to_status == RepairTicketStatus.ready_for_return:
        ticket.repair_completed_at = now
    elif to_status == RepairTicketStatus.shipped_back:
        ticket.return_shipped_at = now
    elif to_status == RepairTicketStatus.closed:
        ticket.closed_at = now
        log_event(db, event_name="repair.completed", user_id=ticket.pro_user_id, properties={"ticket_id": str(ticket.id)})
    create_repair_event(
        db,
        ticket_id=ticket.id,
        from_status=from_status,
        to_status=to_status,
        actor_type=actor_type,
        actor_id=actor_id,
        note=note,
        payload=payload,
    )
    return ticket


def transition_loaner_request(
    db: Session,
    *,
    loaner_request: LoanerRequest,
    to_status: LoanerRequestStatus,
    actor_type: RepairActorType,
    actor_id: uuid.UUID | None,
    note: str | None = None,
    payload: dict | None = None,
) -> LoanerRequest:
    from_status = loaner_request.status
    if to_status not in LOANER_ALLOWED_TRANSITIONS[from_status]:
        raise APIError(code="invalid_state_transition", message=f"Cannot transition {from_status.value} -> {to_status.value}", status_code=409)
    now = datetime.now(timezone.utc)
    loaner_request.status = to_status
    loaner_request.updated_at = now
    if to_status in {LoanerRequestStatus.ready_for_pickup, LoanerRequestStatus.shipped_to_pro, LoanerRequestStatus.in_use} and loaner_request.start_at is None:
        loaner_request.start_at = now
    if to_status == LoanerRequestStatus.return_due and loaner_request.due_at is None and loaner_request.max_days:
        loaner_request.due_at = now + timedelta(days=loaner_request.max_days)
    create_loaner_event(
        db,
        loaner_request_id=loaner_request.id,
        from_status=from_status,
        to_status=to_status,
        actor_type=actor_type,
        actor_id=actor_id,
        note=note,
        payload=payload,
    )
    if to_status == LoanerRequestStatus.approved:
        log_event(db, event_name="loaner.approved", user_id=loaner_request.pro_user_id, properties={"loaner_request_id": str(loaner_request.id)})
    elif to_status in {LoanerRequestStatus.returned, LoanerRequestStatus.closed}:
        log_event(db, event_name="loaner.returned", user_id=loaner_request.pro_user_id, properties={"loaner_request_id": str(loaner_request.id)})
    return loaner_request


def match_repair_partners(
    db: Session,
    *,
    country: str | None = None,
    city: str | None = None,
    category: GearCategory | None = None,
    brand: str | None = None,
    loaner_only: bool = False,
) -> list[RepairPartner]:
    stmt = select(RepairPartner).where(RepairPartner.is_active.is_(True))
    if country:
        stmt = stmt.where(RepairPartner.country == country)
    if loaner_only:
        stmt = stmt.where(RepairPartner.loaner_supported.is_(True))
    rows = db.execute(stmt).scalars().all()

    filtered: list[RepairPartner] = []
    for partner in rows:
        categories = set(partner.categories_supported or [])
        brands = set(partner.brands_supported or [])
        if category and category.value not in categories:
            continue
        if brand and brands and brand not in brands:
            continue
        if loaner_only and not partner.loaner_supported:
            continue
        filtered.append(partner)

    score_rows = db.execute(select(RepairPartnerScore)).scalars().all()
    score_by_partner = {row.partner_id: row for row in score_rows}

    def sort_key(partner: RepairPartner):
        city_rank = 0 if city and partner.city == city else 1
        score = score_by_partner.get(partner.id)
        turnaround = float(score.avg_turnaround_days) if score and score.avg_turnaround_days is not None else 9999.0
        loaner_rank = 0 if partner.loaner_supported else 1
        return (city_rank, turnaround, loaner_rank, partner.name.lower())

    filtered.sort(key=sort_key)
    return filtered


def recompute_partner_score(db: Session, partner_id: uuid.UUID) -> RepairPartnerScore:
    tickets = db.execute(select(RepairTicket).where(RepairTicket.partner_id == partner_id)).scalars().all()
    quote_hours: list[float] = []
    turnaround_days: list[float] = []
    reopened_count = 0

    ticket_by_id = {row.id: row for row in tickets}
    for ticket in tickets:
        if ticket.quote_sent_at:
            quote_hours.append((ticket.quote_sent_at - ticket.created_at).total_seconds() / 3600.0)
        if ticket.closed_at and ticket.repair_started_at:
            turnaround_days.append((ticket.closed_at - ticket.repair_started_at).total_seconds() / 86400.0)

    followups = db.execute(
        select(RepairTicket).where(RepairTicket.reopened_from_ticket_id.is_not(None), RepairTicket.partner_id == partner_id)
    ).scalars().all()
    for row in followups:
        base = ticket_by_id.get(row.reopened_from_ticket_id)
        if base and base.closed_at and row.created_at <= base.closed_at + timedelta(days=30):
            reopened_count += 1

    loaner_requested = db.execute(
        select(func.count()).select_from(LoanerRequest).where(LoanerRequest.partner_id == partner_id)
    ).scalar_one()
    loaner_approved = db.execute(
        select(func.count()).select_from(LoanerRequest).where(LoanerRequest.partner_id == partner_id, LoanerRequest.status.in_([LoanerRequestStatus.approved, LoanerRequestStatus.ready_for_pickup, LoanerRequestStatus.shipped_to_pro, LoanerRequestStatus.in_use, LoanerRequestStatus.return_due, LoanerRequestStatus.returned, LoanerRequestStatus.closed]))
    ).scalar_one()

    score = db.get(RepairPartnerScore, partner_id)
    if not score:
        score = RepairPartnerScore(partner_id=partner_id, tickets_count=0)
        db.add(score)

    def _to_decimal(value: float | None, places: str) -> Decimal | None:
        if value is None:
            return None
        return Decimal(str(value)).quantize(Decimal(places), rounding=ROUND_HALF_UP)

    tickets_count = len(tickets)
    score.tickets_count = tickets_count
    score.avg_quote_hours = _to_decimal(mean(quote_hours), "0.01") if quote_hours else None
    score.avg_turnaround_days = _to_decimal(mean(turnaround_days), "0.01") if turnaround_days else None
    score.reopen_rate = _to_decimal((reopened_count * 100.0 / tickets_count), "0.01") if tickets_count else None
    score.dispute_rate = Decimal("0.00")
    score.loaner_fulfillment_rate = _to_decimal((loaner_approved * 100.0 / loaner_requested), "0.01") if loaner_requested else None
    score.updated_at = datetime.now(timezone.utc)
    db.flush()
    return score
