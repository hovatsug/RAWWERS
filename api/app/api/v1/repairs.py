from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.repair import (
    GearBenefitOverride,
    GearCategory,
    GearItem,
    LoanerRequest,
    LoanerRequestStatus,
    RepairActorType,
    RepairPartner,
    RepairPartnerScore,
    RepairTicket,
    RepairTicketStatus,
)
from app.schemas.media import CurrentUser
from app.schemas.repair import (
    AssignPartnerRequest,
    GearBenefitOverrideRequest,
    GearBenefitOverrideView,
    GearBenefitPolicyRequest,
    GearBenefitPolicyView,
    GearBenefitsAccessResponse,
    GearItemCreateRequest,
    GearItemUpdateRequest,
    GearItemView,
    LoanerRequestCreateRequest,
    LoanerRequestView,
    QuoteSetRequest,
    RepairPartnerScoreView,
    RepairPartnerUpsertRequest,
    RepairPartnerView,
    RepairTicketCreateRequest,
    RepairTicketView,
    SetLoanerStatusRequest,
    SetRepairStatusRequest,
)
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.feature_flags import is_feature_enabled
from app.services.repair import (
    can_access_gear_benefits,
    create_repair_event,
    get_or_create_gear_benefit_policy,
    match_repair_partners,
    recompute_partner_score,
    transition_loaner_request,
    transition_repair_ticket,
    validate_evidence_ownership,
)
from app.services.search_indexing import enqueue_repair_partner_index_upsert
from app.tasks.repair_tasks import recompute_partner_score_task

router = APIRouter(tags=["repairs"])


@router.get("/pro/me/gear-benefits/access", response_model=GearBenefitsAccessResponse)
def my_gear_benefit_access(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GearBenefitsAccessResponse:
    result = can_access_gear_benefits(db, user.user_id)
    db.commit()
    return GearBenefitsAccessResponse(**result)


@router.post("/pro/me/gear-items", response_model=GearItemView)
def create_gear_item(
    body: GearItemCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GearItemView:
    row = GearItem(
        pro_user_id=user.user_id,
        category=body.category,
        brand=body.brand,
        model=body.model,
        serial_number=body.serial_number,
        purchase_date=body.purchase_date,
        notes=body.notes,
        meta=body.metadata,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return GearItemView.model_validate(row, from_attributes=True)


@router.get("/pro/me/gear-items", response_model=list[GearItemView])
def list_my_gear_items(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[GearItemView]:
    rows = db.execute(select(GearItem).where(GearItem.pro_user_id == user.user_id).order_by(GearItem.created_at.desc())).scalars().all()
    db.commit()
    return [GearItemView.model_validate(row, from_attributes=True) for row in rows]


@router.put("/pro/me/gear-items/{gear_item_id}", response_model=GearItemView)
def update_gear_item(
    gear_item_id: uuid.UUID,
    body: GearItemUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> GearItemView:
    row = db.get(GearItem, gear_item_id)
    if not row or row.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Gear item not found", status_code=404)
    values = body.model_dump(exclude_unset=True)
    if "metadata" in values:
        values["meta"] = values.pop("metadata")
    for field, value in values.items():
        setattr(row, field, value)
    row.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(row)
    return GearItemView.model_validate(row, from_attributes=True)


@router.delete("/pro/me/gear-items/{gear_item_id}", status_code=204)
def delete_gear_item(
    gear_item_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> Response:
    row = db.get(GearItem, gear_item_id)
    if not row or row.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Gear item not found", status_code=404)

    # A repair ticket references the item it was raised about. Deleting the
    # item would either break that foreign key or, worse, orphan the ticket
    # into meaninglessness - the pro would keep a repair record that no
    # longer says what was repaired. Removing the body you sold is a
    # reasonable thing to want, so this refuses with the reason rather than
    # failing on a constraint the caller cannot see.
    ticket_count = db.execute(
        select(func.count()).select_from(RepairTicket).where(RepairTicket.gear_item_id == gear_item_id)
    ).scalar_one()
    if ticket_count:
        raise APIError(
            code="conflict",
            message="This item has repair tickets against it and cannot be removed.",
            status_code=409,
        )

    db.delete(row)
    db.commit()
    return Response(status_code=204)


@router.post("/repairs/tickets", response_model=RepairTicketView)
def create_repair_ticket(
    body: RepairTicketCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    if body.gear_item_id:
        gear_item = db.get(GearItem, body.gear_item_id)
        if not gear_item or gear_item.pro_user_id != user.user_id:
            raise APIError(code="validation_error", message="gear_item_id not found for pro", status_code=422)
    validate_evidence_ownership(db, user.user_id, body.evidence_media_asset_ids)
    ticket = RepairTicket(
        pro_user_id=user.user_id,
        gear_item_id=body.gear_item_id,
        status=RepairTicketStatus.submitted,
        urgency=body.urgency,
        issue_description=body.issue_description,
        evidence_media_asset_ids=[str(item) for item in body.evidence_media_asset_ids],
        meta={
            "category": body.category.value,
            "brand": body.brand,
            "model": body.model,
            "location_city": body.location_city,
            "location_country": body.location_country,
        },
    )
    db.add(ticket)
    db.flush()
    create_repair_event(
        db,
        ticket_id=ticket.id,
        from_status=None,
        to_status=RepairTicketStatus.submitted,
        actor_type=RepairActorType.pro,
        actor_id=user.user_id,
    )
    log_event(db, event_name="repair.ticket_created", user_id=user.user_id, properties={"ticket_id": str(ticket.id)})
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.get("/repairs/tickets/{ticket_id}", response_model=RepairTicketView)
def get_repair_ticket(
    ticket_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    if ticket.pro_user_id != user.user_id:
        roles = set()
        try:
            from app.services.authz import get_user_roles

            roles = get_user_roles(db, user.user_id)
        except Exception:
            roles = set()
        if UserRoleType.admin not in roles:
            raise APIError(code="forbidden", message="Not allowed", status_code=403)
    db.commit()
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.post("/repairs/tickets/{ticket_id}/request-loaner", response_model=LoanerRequestView)
def request_loaner(
    ticket_id: uuid.UUID,
    body: LoanerRequestCreateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LoanerRequestView:
    if not is_feature_enabled(db, "loaners_enabled", user_id=user.user_id):
        raise APIError(code="feature_disabled", message="Loaner requests are temporarily disabled", status_code=503)
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket or ticket.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    if ticket.status in {RepairTicketStatus.closed, RepairTicketStatus.cancelled}:
        raise APIError(code="invalid_state", message="Cannot request loaner for closed/cancelled ticket", status_code=409)
    access = can_access_gear_benefits(db, user.user_id)
    if not access["allowed"]:
        raise APIError(code="forbidden", message=f"Loaner benefit denied: {access['reason']}", status_code=403)

    row = LoanerRequest(
        ticket_id=ticket.id,
        pro_user_id=user.user_id,
        partner_id=ticket.partner_id,
        status=LoanerRequestStatus.requested,
        category=body.category,
        terms_snapshot={},
        deposit_required=False,
        deposit_amount=None,
        max_days=None,
        shipping={},
    )
    db.add(row)
    db.flush()
    from app.services.repair import create_loaner_event

    create_loaner_event(
        db,
        loaner_request_id=row.id,
        from_status=None,
        to_status=LoanerRequestStatus.requested,
        actor_type=RepairActorType.pro,
        actor_id=user.user_id,
        note=body.note,
    )
    log_event(db, event_name="loaner.requested", user_id=user.user_id, properties={"loaner_request_id": str(row.id), "ticket_id": str(ticket.id)})
    db.commit()
    db.refresh(row)
    return LoanerRequestView.model_validate(row, from_attributes=True)


@router.post("/repairs/tickets/{ticket_id}/approve-quote", response_model=RepairTicketView)
def approve_quote(
    ticket_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket or ticket.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    transition_repair_ticket(
        db,
        ticket=ticket,
        to_status=RepairTicketStatus.quote_approved,
        actor_type=RepairActorType.pro,
        actor_id=user.user_id,
    )
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.post("/repairs/tickets/{ticket_id}/decline-quote", response_model=RepairTicketView)
def decline_quote(
    ticket_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket or ticket.pro_user_id != user.user_id:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    transition_repair_ticket(
        db,
        ticket=ticket,
        to_status=RepairTicketStatus.quote_declined,
        actor_type=RepairActorType.pro,
        actor_id=user.user_id,
    )
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.post("/repairs/tickets/{ticket_id}/close", response_model=RepairTicketView)
def close_ticket(
    ticket_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    actor_type = RepairActorType.pro
    if ticket.pro_user_id != user.user_id:
        from app.services.authz import get_user_roles

        roles = get_user_roles(db, user.user_id)
        if UserRoleType.admin not in roles:
            raise APIError(code="forbidden", message="Not allowed", status_code=403)
        actor_type = RepairActorType.admin
    transition_repair_ticket(
        db,
        ticket=ticket,
        to_status=RepairTicketStatus.closed,
        actor_type=actor_type,
        actor_id=user.user_id,
    )
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.get("/repairs/partners", response_model=list[RepairPartnerView])
def list_repair_partners(
    country: str | None = None,
    city: str | None = None,
    category: GearCategory | None = None,
    brand: str | None = None,
    loaner_only: bool = False,
    _: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> list[RepairPartnerView]:
    rows = match_repair_partners(db, country=country, city=city, category=category, brand=brand, loaner_only=loaner_only)
    db.commit()
    return [RepairPartnerView.model_validate(row, from_attributes=True) for row in rows]


@router.get("/admin/repairs/partners", response_model=list[RepairPartnerView])
def admin_list_repair_partners(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RepairPartnerView]:
    rows = db.execute(select(RepairPartner).order_by(RepairPartner.created_at.desc())).scalars().all()
    db.commit()
    return [RepairPartnerView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/admin/repairs/partners", response_model=RepairPartnerView)
def admin_create_repair_partner(
    body: RepairPartnerUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairPartnerView:
    row = RepairPartner(
        name=body.name,
        country=body.country,
        city=body.city,
        address=body.address,
        service_radius_km=body.service_radius_km,
        shipping_supported=body.shipping_supported,
        pickup_supported=body.pickup_supported,
        brands_supported=body.brands_supported,
        categories_supported=[item.value for item in body.categories_supported],
        sla_quote_hours=body.sla_quote_hours,
        sla_turnaround_days=body.sla_turnaround_days,
        loaner_supported=body.loaner_supported,
        loaner_categories=[item.value for item in body.loaner_categories],
        is_active=body.is_active,
        contact=body.contact,
        partner_terms=body.partner_terms,
    )
    db.add(row)
    db.flush()
    enqueue_repair_partner_index_upsert(db, row.id, idempotency_suffix="create")
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="repair_partner", target_id=str(row.id), action="repair_partner_create", metadata={})
    db.commit()
    db.refresh(row)
    return RepairPartnerView.model_validate(row, from_attributes=True)


@router.put("/admin/repairs/partners/{partner_id}", response_model=RepairPartnerView)
def admin_update_repair_partner(
    partner_id: uuid.UUID,
    body: RepairPartnerUpsertRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairPartnerView:
    row = db.get(RepairPartner, partner_id)
    if not row:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    row.name = body.name
    row.country = body.country
    row.city = body.city
    row.address = body.address
    row.service_radius_km = body.service_radius_km
    row.shipping_supported = body.shipping_supported
    row.pickup_supported = body.pickup_supported
    row.brands_supported = body.brands_supported
    row.categories_supported = [item.value for item in body.categories_supported]
    row.sla_quote_hours = body.sla_quote_hours
    row.sla_turnaround_days = body.sla_turnaround_days
    row.loaner_supported = body.loaner_supported
    row.loaner_categories = [item.value for item in body.loaner_categories]
    row.is_active = body.is_active
    row.contact = body.contact
    row.partner_terms = body.partner_terms
    row.updated_at = datetime.now(timezone.utc)
    enqueue_repair_partner_index_upsert(db, row.id, idempotency_suffix=row.updated_at.isoformat())
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="repair_partner", target_id=str(row.id), action="repair_partner_update", metadata={})
    db.commit()
    db.refresh(row)
    return RepairPartnerView.model_validate(row, from_attributes=True)


@router.post("/admin/repairs/partners/{partner_id}/set-active", response_model=RepairPartnerView)
def admin_set_partner_active(
    partner_id: uuid.UUID,
    is_active: bool = True,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairPartnerView:
    row = db.get(RepairPartner, partner_id)
    if not row:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    row.is_active = is_active
    row.updated_at = datetime.now(timezone.utc)
    enqueue_repair_partner_index_upsert(db, row.id, idempotency_suffix=row.updated_at.isoformat())
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="repair_partner", target_id=str(row.id), action="repair_partner_set_active", metadata={"is_active": is_active})
    db.commit()
    db.refresh(row)
    return RepairPartnerView.model_validate(row, from_attributes=True)


@router.get("/admin/repairs/tickets", response_model=list[RepairTicketView])
def admin_list_repair_tickets(
    status: RepairTicketStatus | None = None,
    partner_id: uuid.UUID | None = None,
    country: str | None = None,
    city: str | None = None,
    urgency: str | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[RepairTicketView]:
    stmt = select(RepairTicket)
    if status:
        stmt = stmt.where(RepairTicket.status == status)
    if partner_id:
        stmt = stmt.where(RepairTicket.partner_id == partner_id)
    if urgency:
        stmt = stmt.where(RepairTicket.urgency == urgency)
    rows = db.execute(stmt.order_by(RepairTicket.created_at.desc())).scalars().all()
    if country or city:
        filtered = []
        for row in rows:
            partner = db.get(RepairPartner, row.partner_id) if row.partner_id else None
            if country and (not partner or partner.country != country):
                continue
            if city and (not partner or partner.city != city):
                continue
            filtered.append(row)
        rows = filtered
    db.commit()
    return [RepairTicketView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/admin/repairs/tickets/{ticket_id}/assign-partner", response_model=RepairTicketView)
def admin_assign_partner(
    ticket_id: uuid.UUID,
    body: AssignPartnerRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    partner = db.get(RepairPartner, body.partner_id)
    if not partner or not partner.is_active:
        raise APIError(code="validation_error", message="Partner not found/active", status_code=422)
    if ticket.status in {RepairTicketStatus.in_repair, RepairTicketStatus.ready_for_return, RepairTicketStatus.shipped_back, RepairTicketStatus.closed, RepairTicketStatus.cancelled}:
        raise APIError(code="invalid_state", message="Cannot reassign partner after repair has started/finished", status_code=409)

    ticket.partner_id = partner.id
    if ticket.status == RepairTicketStatus.submitted:
        transition_repair_ticket(
            db,
            ticket=ticket,
            to_status=RepairTicketStatus.partner_assigned,
            actor_type=RepairActorType.admin,
            actor_id=actor.user_id,
        )
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="repair_ticket", target_id=str(ticket.id), action="repair_ticket_assign_partner", metadata={"partner_id": str(partner.id)})
    log_event(db, event_name="repair.partner_assigned", user_id=ticket.pro_user_id, properties={"ticket_id": str(ticket.id), "partner_id": str(partner.id)})
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.post("/admin/repairs/tickets/{ticket_id}/set-status", response_model=RepairTicketView)
def admin_set_ticket_status(
    ticket_id: uuid.UUID,
    body: SetRepairStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    if ticket.status == RepairTicketStatus.closed and body.to_status == RepairTicketStatus.submitted:
        reopened = RepairTicket(
            pro_user_id=ticket.pro_user_id,
            gear_item_id=ticket.gear_item_id,
            partner_id=ticket.partner_id,
            status=RepairTicketStatus.submitted,
            urgency=ticket.urgency,
            issue_description=ticket.issue_description,
            evidence_media_asset_ids=ticket.evidence_media_asset_ids or [],
            quote_amount=None,
            currency=ticket.currency,
            quote_notes=None,
            shipping=ticket.shipping or {},
            outcome=ticket.outcome,
            reopened_from_ticket_id=ticket.id,
            meta=ticket.meta or {},
        )
        db.add(reopened)
        db.flush()
        create_repair_event(
            db,
            ticket_id=reopened.id,
            from_status=None,
            to_status=RepairTicketStatus.submitted,
            actor_type=RepairActorType.admin,
            actor_id=actor.user_id,
            note=body.note or "Reopened from closed ticket",
            payload={**body.payload, "reopened_from_ticket_id": str(ticket.id)},
        )
        add_admin_audit_log(
            db,
            actor_user_id=actor.user_id,
            target_type="repair_ticket",
            target_id=str(reopened.id),
            action="repair_ticket_reopen",
            reason=body.note,
            metadata={"source_ticket_id": str(ticket.id)},
        )
        db.commit()
        db.refresh(reopened)
        return RepairTicketView.model_validate(reopened, from_attributes=True)
    transition_repair_ticket(
        db,
        ticket=ticket,
        to_status=body.to_status,
        actor_type=RepairActorType.admin,
        actor_id=actor.user_id,
        note=body.note,
        payload=body.payload,
    )
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="repair_ticket", target_id=str(ticket.id), action="repair_ticket_set_status", reason=body.note, metadata={"to_status": body.to_status.value, "payload": body.payload})
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.post("/admin/repairs/tickets/{ticket_id}/set-quote", response_model=RepairTicketView)
def admin_set_quote(
    ticket_id: uuid.UUID,
    body: QuoteSetRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairTicketView:
    ticket = db.get(RepairTicket, ticket_id)
    if not ticket:
        raise APIError(code="not_found", message="Ticket not found", status_code=404)
    if ticket.status not in {RepairTicketStatus.awaiting_quote, RepairTicketStatus.partner_assigned}:
        raise APIError(code="invalid_state", message="Quote can only be set in awaiting_quote/partner_assigned", status_code=409)
    ticket.quote_amount = body.amount
    ticket.currency = body.currency.upper()
    ticket.quote_notes = body.notes
    if ticket.status == RepairTicketStatus.partner_assigned:
        transition_repair_ticket(
            db,
            ticket=ticket,
            to_status=RepairTicketStatus.awaiting_quote,
            actor_type=RepairActorType.admin,
            actor_id=actor.user_id,
            note="Auto-move to awaiting_quote before quote_sent",
        )
    transition_repair_ticket(
        db,
        ticket=ticket,
        to_status=RepairTicketStatus.quote_sent,
        actor_type=RepairActorType.admin,
        actor_id=actor.user_id,
        note=body.notes,
    )
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="repair_ticket", target_id=str(ticket.id), action="repair_ticket_set_quote", metadata={"amount": str(body.amount), "currency": body.currency, "notes": body.notes})
    db.commit()
    db.refresh(ticket)
    return RepairTicketView.model_validate(ticket, from_attributes=True)


@router.get("/admin/repairs/loaners", response_model=list[LoanerRequestView])
def admin_list_loaners(
    status: LoanerRequestStatus | None = None,
    partner_id: uuid.UUID | None = None,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> list[LoanerRequestView]:
    stmt = select(LoanerRequest)
    if status:
        stmt = stmt.where(LoanerRequest.status == status)
    if partner_id:
        stmt = stmt.where(LoanerRequest.partner_id == partner_id)
    rows = db.execute(stmt.order_by(LoanerRequest.created_at.desc())).scalars().all()
    db.commit()
    return [LoanerRequestView.model_validate(row, from_attributes=True) for row in rows]


@router.post("/admin/repairs/loaners/{loaner_request_id}/set-status", response_model=LoanerRequestView)
def admin_set_loaner_status(
    loaner_request_id: uuid.UUID,
    body: SetLoanerStatusRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> LoanerRequestView:
    row = db.get(LoanerRequest, loaner_request_id)
    if not row:
        raise APIError(code="not_found", message="Loaner request not found", status_code=404)
    if body.to_status == LoanerRequestStatus.approved:
        partner = db.get(RepairPartner, row.partner_id) if row.partner_id else None
        terms = partner.partner_terms if partner else {}
        row.terms_snapshot = terms or {}
        row.deposit_required = bool((terms or {}).get("deposit_required", False))
        deposit_amount = (terms or {}).get("deposit_amount")
        row.deposit_amount = deposit_amount
        row.max_days = (terms or {}).get("loaner_max_days")
        row.due_at = datetime.now(timezone.utc) + timedelta(days=int(row.max_days)) if row.max_days else None
    transition_loaner_request(
        db,
        loaner_request=row,
        to_status=body.to_status,
        actor_type=RepairActorType.admin,
        actor_id=actor.user_id,
        note=body.note,
        payload=body.payload,
    )
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="loaner_request", target_id=str(row.id), action="loaner_set_status", reason=body.note, metadata={"to_status": body.to_status.value, "payload": body.payload})
    db.commit()
    db.refresh(row)
    return LoanerRequestView.model_validate(row, from_attributes=True)


@router.put("/admin/repairs/policy", response_model=GearBenefitPolicyView)
def admin_update_gear_policy(
    body: GearBenefitPolicyRequest,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> GearBenefitPolicyView:
    policy = get_or_create_gear_benefit_policy(db)
    policy.require_kyc_approved = body.require_kyc_approved
    policy.require_not_banned = body.require_not_banned
    policy.min_tier_any_niche = body.min_tier_any_niche
    policy.meta = body.metadata
    policy.updated_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(policy)
    return GearBenefitPolicyView.model_validate(policy, from_attributes=True)


@router.get("/admin/repairs/policy", response_model=GearBenefitPolicyView)
def admin_get_gear_policy(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> GearBenefitPolicyView:
    policy = get_or_create_gear_benefit_policy(db)
    db.commit()
    return GearBenefitPolicyView.model_validate(policy, from_attributes=True)


@router.post("/admin/repairs/overrides/{pro_user_id}", response_model=GearBenefitOverrideView)
def admin_upsert_gear_override(
    pro_user_id: uuid.UUID,
    body: GearBenefitOverrideRequest,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> GearBenefitOverrideView:
    row = db.execute(select(GearBenefitOverride).where(GearBenefitOverride.pro_user_id == pro_user_id)).scalar_one_or_none()
    if not row:
        row = GearBenefitOverride(pro_user_id=pro_user_id, is_allowed=body.is_allowed)
        db.add(row)
        db.flush()
    row.is_allowed = body.is_allowed
    row.reason = body.reason
    row.expires_at = body.expires_at
    row.granted_by = actor.user_id
    row.granted_at = datetime.now(timezone.utc)
    add_admin_audit_log(db, actor_user_id=actor.user_id, target_type="gear_benefit_override", target_id=str(pro_user_id), action="gear_benefit_override_upsert", reason=body.reason, metadata={"is_allowed": body.is_allowed, "expires_at": body.expires_at.isoformat() if body.expires_at else None})
    db.commit()
    db.refresh(row)
    return GearBenefitOverrideView.model_validate(row, from_attributes=True)


@router.post("/admin/repairs/partners/{partner_id}/recompute-score", response_model=RepairPartnerScoreView)
def admin_recompute_partner_score(
    partner_id: uuid.UUID,
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> RepairPartnerScoreView:
    partner = db.get(RepairPartner, partner_id)
    if not partner:
        raise APIError(code="not_found", message="Partner not found", status_code=404)
    try:
        recompute_partner_score_task.delay(str(partner_id))
    except Exception:
        recompute_partner_score(db, partner_id)
    db.commit()
    score = db.get(RepairPartnerScore, partner_id)
    if not score:
        score = recompute_partner_score(db, partner_id)
        db.commit()
    return RepairPartnerScoreView.model_validate(score, from_attributes=True)
