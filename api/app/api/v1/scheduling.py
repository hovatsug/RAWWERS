from __future__ import annotations

import uuid
from datetime import date, datetime, time, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Depends, Query
from sqlalchemy import and_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.booking import (
    AvailabilityLocationMode,
    BookingRequest,
    BookingRequestStatus,
    BookingRequestTransition,
    BookingTimeRequest,
    CancellationPolicySnapshot,
    ConfirmedSlot,
    ConfirmedSlotStatus,
    ProAvailabilityException,
    ProAvailabilityRule,
    ProPackage,
)
from app.models.gig import Gig, GigStatus
from app.models.legacy_shoot import LegacyBooking, LegacyBookingStatus
from app.models.niche import Niche
from app.schemas.media import CurrentUser
from app.schemas.scheduling import (
    AdminSchedulingConflictResponse,
    AvailabilityExceptionsReplaceRequest,
    AvailabilityExceptionsResponse,
    AvailabilityExceptionsResponse,
    AvailabilityExceptionView,
    AvailabilityRuleView,
    AvailabilityRulesReplaceRequest,
    AvailabilityRulesResponse,
    BookingTimeWindowsRequest,
    BookingTimeWindowsResponse,
    CancelSlotRequest,
    ConfirmedSlotView,
    ConfirmSlotRequest,
    RescheduleRequest,
    SchedulingPolicyUpdateRequest,
    SchedulingPolicyView,
    SchedulingSlotsResponse,
    SchedulingSlotView,
)
from app.services.analytics import log_event
from app.services.authz import get_user_roles
from app.services.notifications import enqueue_notification
from app.services.package_pricing import compute_minimum_amount
from app.services.rate_limit import enforce_named_rate_limit
from app.services.scheduling import (
    create_booking_time_request,
    create_slot_reminders,
    generate_candidate_slots,
    get_or_create_scheduling_policy,
    latest_booking_time_request,
    validate_slot_available,
)

settings = get_settings()
router = APIRouter(tags=["scheduling"])


@router.get("/pro/scheduling/policy", response_model=SchedulingPolicyView)
def get_my_scheduling_policy(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SchedulingPolicyView:
    _require_role(db, user.user_id, UserRoleType.pro)
    row = get_or_create_scheduling_policy(db, pro_user_id=user.user_id)
    db.commit()
    return SchedulingPolicyView.model_validate(row, from_attributes=True)


@router.put("/pro/scheduling/policy", response_model=SchedulingPolicyView)
def put_my_scheduling_policy(
    body: SchedulingPolicyUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SchedulingPolicyView:
    _require_role(db, user.user_id, UserRoleType.pro)
    row = get_or_create_scheduling_policy(db, pro_user_id=user.user_id)
    row.slot_length_minutes = body.slot_length_minutes
    row.buffer_before_minutes = body.buffer_before_minutes
    row.buffer_after_minutes = body.buffer_after_minutes
    row.advance_notice_hours = body.advance_notice_hours
    row.max_bookings_per_day = body.max_bookings_per_day
    log_event(db, event_name="scheduling.availability_updated", user_id=user.user_id, properties={"type": "policy"})
    db.commit()
    db.refresh(row)
    return SchedulingPolicyView.model_validate(row, from_attributes=True)


@router.get("/pro/scheduling/availability-rules", response_model=AvailabilityRulesResponse)
def get_my_availability_rules(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AvailabilityRulesResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    rows = db.execute(
        select(ProAvailabilityRule)
        .where(ProAvailabilityRule.pro_user_id == user.user_id)
        .order_by(ProAvailabilityRule.day_of_week.asc(), ProAvailabilityRule.start_time.asc())
    ).scalars().all()
    return AvailabilityRulesResponse(
        items=[
            AvailabilityRuleView(
                id=row.id,
                pro_user_id=row.pro_user_id,
                weekday=row.day_of_week,
                start_local=row.start_time,
                end_local=row.end_time,
                timezone=row.timezone,
                location_mode=row.location_mode,
                created_at=row.created_at,
                updated_at=row.updated_at,
            )
            for row in rows
        ]
    )


@router.put("/pro/scheduling/availability-rules", response_model=AvailabilityRulesResponse)
def put_my_availability_rules(
    body: AvailabilityRulesReplaceRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AvailabilityRulesResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    for item in body.rules:
        if item.end_local <= item.start_local:
            raise APIError(code="validation_error", message="start_local must be before end_local", status_code=422)
        try:
            ZoneInfo(item.timezone)
        except Exception as exc:
            raise APIError(code="validation_error", message=f"Invalid timezone '{item.timezone}'", status_code=422) from exc

    db.query(ProAvailabilityRule).filter(ProAvailabilityRule.pro_user_id == user.user_id).delete()
    for item in body.rules:
        db.add(
            ProAvailabilityRule(
                pro_user_id=user.user_id,
                day_of_week=item.weekday,
                start_time=item.start_local,
                end_time=item.end_local,
                timezone=item.timezone,
                location_mode=item.location_mode,
            )
        )
    log_event(db, event_name="scheduling.availability_updated", user_id=user.user_id, properties={"type": "rules", "count": len(body.rules)})
    db.commit()
    return get_my_availability_rules(user=user, db=db)


@router.get("/pro/scheduling/exceptions", response_model=AvailabilityExceptionsResponse)
def get_my_scheduling_exceptions(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AvailabilityExceptionsResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    rows = db.execute(
        select(ProAvailabilityException)
        .where(ProAvailabilityException.pro_user_id == user.user_id)
        .order_by(ProAvailabilityException.start_at_utc.asc())
    ).scalars().all()
    return AvailabilityExceptionsResponse(
        items=[
            AvailabilityExceptionView(
                id=row.id,
                pro_user_id=row.pro_user_id,
                start_at_utc=row.start_at_utc,
                end_at_utc=row.end_at_utc,
                reason=row.reason,
                created_at=row.created_at,
            )
            for row in rows
        ]
    )


@router.put("/pro/scheduling/exceptions", response_model=AvailabilityExceptionsResponse)
def put_my_scheduling_exceptions(
    body: AvailabilityExceptionsReplaceRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> AvailabilityExceptionsResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    for item in body.items:
        if item.end_at_utc <= item.start_at_utc:
            raise APIError(code="validation_error", message="start_at_utc must be before end_at_utc", status_code=422)

    db.query(ProAvailabilityException).filter(ProAvailabilityException.pro_user_id == user.user_id).delete()
    for item in body.items:
        db.add(
            ProAvailabilityException(
                pro_user_id=user.user_id,
                start_at_utc=item.start_at_utc,
                end_at_utc=item.end_at_utc,
                reason=item.reason,
            )
        )
    log_event(db, event_name="scheduling.availability_updated", user_id=user.user_id, properties={"type": "exceptions", "count": len(body.items)})
    db.commit()
    return get_my_scheduling_exceptions(user=user, db=db)


@router.get("/pro/scheduling/slots", response_model=SchedulingSlotsResponse)
def get_my_candidate_slots(
    from_date: date = Query(alias="from"),
    to_date: date = Query(alias="to"),
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> SchedulingSlotsResponse:
    _require_role(db, user.user_id, UserRoleType.pro)
    slots = generate_candidate_slots(db, pro_user_id=user.user_id, from_date=from_date, to_date=to_date)
    return SchedulingSlotsResponse(
        slots=[
            SchedulingSlotView(
                start_at_utc=start,
                end_at_utc=end,
                timezone=tz_name,
                start_local=start.astimezone(ZoneInfo(tz_name)).isoformat(),
                end_local=end.astimezone(ZoneInfo(tz_name)).isoformat(),
            )
            for start, end, tz_name in slots
        ]
    )


@router.post("/client/bookings/{booking_request_id}/time-windows", response_model=BookingTimeWindowsResponse)
def submit_booking_time_windows(
    booking_request_id: uuid.UUID,
    body: BookingTimeWindowsRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingTimeWindowsResponse:
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    booking = db.get(BookingRequest, booking_request_id)
    if not booking:
        raise APIError(code="not_found", message="Booking request not found", status_code=404)
    if booking.client_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only client can submit windows", status_code=403)
    if len(body.windows) == 0 or len(body.windows) > 8:
        raise APIError(code="validation_error", message="windows must contain 1..8 entries", status_code=422)

    normalized: list[dict] = []
    for window in body.windows:
        if window.end_at_utc <= window.start_at_utc:
            raise APIError(code="validation_error", message="Each window must have end > start", status_code=422)
        if (window.end_at_utc - window.start_at_utc) > timedelta(hours=8):
            raise APIError(code="validation_error", message="Each window must be <= 8h", status_code=422)
        normalized.append({"start_at_utc": window.start_at_utc.isoformat(), "end_at_utc": window.end_at_utc.isoformat()})

    row = create_booking_time_request(
        db,
        booking_request_id=booking_request_id,
        client_timezone=body.client_timezone,
        windows=normalized,
    )
    log_event(
        db,
        event_name="scheduling.time_windows_submitted",
        user_id=user.user_id,
        properties={"booking_request_id": str(booking_request_id), "count": len(normalized)},
    )
    db.commit()
    return BookingTimeWindowsResponse(
        booking_request_id=booking_request_id,
        id=row.id,
        client_timezone=row.client_timezone,
        windows=[{"start_at_utc": datetime.fromisoformat(item["start_at_utc"]), "end_at_utc": datetime.fromisoformat(item["end_at_utc"])} for item in row.windows],
    )


@router.post("/pro/bookings/{booking_request_id}/confirm-slot", response_model=ConfirmedSlotView)
def confirm_booking_slot(
    booking_request_id: uuid.UUID,
    body: ConfirmSlotRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ConfirmedSlotView:
    enforce_named_rate_limit("auth_mutation", principal=str(user.user_id))
    booking = db.get(BookingRequest, booking_request_id)
    if not booking:
        raise APIError(code="not_found", message="Booking request not found", status_code=404)
    if booking.pro_user_id != user.user_id:
        raise APIError(code="forbidden", message="Only pro can confirm slot", status_code=403)

    validate_slot_available(db, pro_user_id=booking.pro_user_id, start_at_utc=body.start_at_utc, end_at_utc=body.end_at_utc)
    _validate_within_client_windows(db, booking_request_id=booking_request_id, start_at_utc=body.start_at_utc, end_at_utc=body.end_at_utc)

    gig = _find_or_create_gig_from_booking(db, booking)
    gig.scheduled_start = body.start_at_utc
    gig.scheduled_end = body.end_at_utc

    try:
        slot = db.execute(select(ConfirmedSlot).where(ConfirmedSlot.gig_id == gig.id)).scalar_one_or_none()
        if not slot:
            slot = ConfirmedSlot(
                gig_id=gig.id,
                pro_user_id=gig.pro_user_id,
                client_user_id=gig.client_user_id,
                start_at_utc=body.start_at_utc,
                end_at_utc=body.end_at_utc,
                status=ConfirmedSlotStatus.confirmed,
            )
            db.add(slot)
        else:
            slot.start_at_utc = body.start_at_utc
            slot.end_at_utc = body.end_at_utc
            slot.status = ConfirmedSlotStatus.confirmed
            slot.cancellation_reason = None
        db.flush()
    except IntegrityError as exc:
        db.rollback()
        raise APIError(code="slot_conflict", message="Selected slot conflicts with another booking", status_code=409) from exc

    if booking.status == BookingRequestStatus.pending:
        booking.status = BookingRequestStatus.accepted
        db.add(
            BookingRequestTransition(
                booking_request_id=booking.id,
                from_status=BookingRequestStatus.pending,
                to_status=BookingRequestStatus.accepted,
                actor_user_id=user.user_id,
                reason="Slot confirmed by pro",
            )
        )

    snapshot = db.get(CancellationPolicySnapshot, gig.id)
    if not snapshot:
        snapshot = CancellationPolicySnapshot(
            gig_id=gig.id,
            snapshot={
                "cancel_before_hours_no_fee": 48,
                "cancel_before_hours_partial_fee": 24,
                "late_cancellation_policy": "handled_via_dispute_refund_rules",
                "captured_at": datetime.now(timezone.utc).isoformat(),
            },
        )
        db.add(snapshot)

    create_slot_reminders(db, slot=slot)
    legacy = db.execute(select(LegacyBooking).where(LegacyBooking.gig_id == gig.id)).scalar_one_or_none()
    if legacy and legacy.status in {
        LegacyBookingStatus.pro_assigned,
        LegacyBookingStatus.brief_submitted,
        LegacyBookingStatus.brief_pending,
    }:
        legacy.status = LegacyBookingStatus.scheduled
        legacy.updated_at = datetime.now(timezone.utc)
        enqueue_notification(
            db,
            user_id=legacy.client_user_id,
            notification_type="legacy.schedule.confirmed",
            payload={
                "title": "Legacy Shoot scheduled",
                "body": "Your legacy session slot has been confirmed.",
            },
            reference_type="legacy_booking",
            reference_id=str(legacy.id),
        )
    enqueue_notification(
        db,
        user_id=gig.client_user_id,
        notification_type="booking.request_accepted",
        payload={
            "title": "Slot confirmed",
            "body": "Your photographer confirmed a time slot.",
            "action": {"label": "View booking", "url": f"/client/bookings/{booking.id}"},
        },
        reference_type="booking_request",
        reference_id=str(booking.id),
    )
    log_event(
        db,
        event_name="scheduling.slot_confirmed",
        user_id=user.user_id,
        properties={"booking_request_id": str(booking.id), "gig_id": str(gig.id)},
    )
    db.commit()
    db.refresh(slot)
    return ConfirmedSlotView.model_validate(slot, from_attributes=True)


@router.post("/gigs/{gig_id}/cancel-slot", response_model=ConfirmedSlotView)
def cancel_slot(
    gig_id: uuid.UUID,
    body: CancelSlotRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ConfirmedSlotView:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if user.user_id not in {gig.client_user_id, gig.pro_user_id}:
        _require_role(db, user.user_id, UserRoleType.admin)

    slot = db.execute(select(ConfirmedSlot).where(ConfirmedSlot.gig_id == gig_id)).scalar_one_or_none()
    if not slot:
        raise APIError(code="not_found", message="Confirmed slot not found", status_code=404)
    slot.status = ConfirmedSlotStatus.cancelled
    slot.cancellation_reason = body.reason or "cancelled"

    log_event(
        db,
        event_name="scheduling.slot_cancelled",
        user_id=user.user_id,
        properties={"gig_id": str(gig_id), "reason": slot.cancellation_reason, "cancelled_at": datetime.now(timezone.utc).isoformat()},
    )
    db.commit()
    db.refresh(slot)
    return ConfirmedSlotView.model_validate(slot, from_attributes=True)


@router.post("/gigs/{gig_id}/reschedule-request", response_model=BookingTimeWindowsResponse)
def create_reschedule_request(
    gig_id: uuid.UUID,
    body: RescheduleRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> BookingTimeWindowsResponse:
    gig = db.get(Gig, gig_id)
    if not gig:
        raise APIError(code="not_found", message="Gig not found", status_code=404)
    if user.user_id not in {gig.client_user_id, gig.pro_user_id}:
        raise APIError(code="forbidden", message="Not allowed", status_code=403)

    slot = db.execute(select(ConfirmedSlot).where(ConfirmedSlot.gig_id == gig_id)).scalar_one_or_none()
    if slot:
        slot.status = ConfirmedSlotStatus.cancelled
        slot.cancellation_reason = "reschedule"

    booking = _find_booking_request_by_gig(db, gig_id)
    if not booking:
        raise APIError(code="not_found", message="Booking request not found for gig", status_code=404)

    windows = []
    for item in body.proposed_windows:
        if item.end_at_utc <= item.start_at_utc:
            raise APIError(code="validation_error", message="Each window must have end > start", status_code=422)
        windows.append({"start_at_utc": item.start_at_utc.isoformat(), "end_at_utc": item.end_at_utc.isoformat()})
    row = create_booking_time_request(
        db,
        booking_request_id=booking.id,
        client_timezone=body.client_timezone,
        windows=windows,
    )
    log_event(
        db,
        event_name="scheduling.reschedule_requested",
        user_id=user.user_id,
        properties={"gig_id": str(gig_id), "booking_request_id": str(booking.id), "count": len(windows)},
    )
    db.commit()
    return BookingTimeWindowsResponse(
        booking_request_id=booking.id,
        id=row.id,
        client_timezone=row.client_timezone,
        windows=[{"start_at_utc": datetime.fromisoformat(item["start_at_utc"]), "end_at_utc": datetime.fromisoformat(item["end_at_utc"])} for item in row.windows],
    )


@router.get("/admin/scheduling/conflicts", response_model=AdminSchedulingConflictResponse)
def admin_scheduling_conflicts(
    pro_user_id: uuid.UUID | None = None,
    from_at: datetime | None = Query(default=None, alias="from"),
    to_at: datetime | None = Query(default=None, alias="to"),
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> AdminSchedulingConflictResponse:
    stmt = select(ConfirmedSlot).where(ConfirmedSlot.status.in_([ConfirmedSlotStatus.reserved, ConfirmedSlotStatus.confirmed]))
    if pro_user_id:
        stmt = stmt.where(ConfirmedSlot.pro_user_id == pro_user_id)
    if from_at:
        stmt = stmt.where(ConfirmedSlot.end_at_utc >= from_at)
    if to_at:
        stmt = stmt.where(ConfirmedSlot.start_at_utc <= to_at)
    rows = db.execute(stmt.order_by(ConfirmedSlot.pro_user_id.asc(), ConfirmedSlot.start_at_utc.asc())).scalars().all()

    conflicts: list[dict] = []
    by_pro: dict[uuid.UUID, list[ConfirmedSlot]] = {}
    for row in rows:
        by_pro.setdefault(row.pro_user_id, []).append(row)
    for pro, slots in by_pro.items():
        for idx in range(1, len(slots)):
            previous = slots[idx - 1]
            current = slots[idx]
            if previous.end_at_utc > current.start_at_utc:
                conflicts.append(
                    {
                        "pro_user_id": str(pro),
                        "slot_a_id": str(previous.id),
                        "slot_b_id": str(current.id),
                        "slot_a": [previous.start_at_utc.isoformat(), previous.end_at_utc.isoformat()],
                        "slot_b": [current.start_at_utc.isoformat(), current.end_at_utc.isoformat()],
                    }
                )
    return AdminSchedulingConflictResponse(items=conflicts)


def _require_role(db: Session, user_id: uuid.UUID, role: UserRoleType) -> None:
    roles = get_user_roles(db, user_id)
    if role not in roles:
        raise APIError(code="forbidden", message=f"Role {role.value} required", status_code=403)


def _validate_within_client_windows(
    db: Session,
    *,
    booking_request_id: uuid.UUID,
    start_at_utc: datetime,
    end_at_utc: datetime,
) -> None:
    latest = latest_booking_time_request(db, booking_request_id=booking_request_id)
    if not latest:
        return
    for item in latest.windows or []:
        try:
            w_start = datetime.fromisoformat(item["start_at_utc"])
            w_end = datetime.fromisoformat(item["end_at_utc"])
        except Exception:
            continue
        if start_at_utc >= w_start and end_at_utc <= w_end:
            return
    raise APIError(code="validation_error", message="Confirmed slot must be inside submitted client windows", status_code=409)


def _find_or_create_gig_from_booking(db: Session, booking: BookingRequest) -> Gig:
    existing = _find_gig_by_booking_request(db, booking.id)
    if existing:
        return existing

    package = db.get(ProPackage, booking.package_id)
    if not package:
        raise APIError(code="validation_error", message="Package not found", status_code=409)
    entry_rate = package.price.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    amount_minimum = compute_minimum_amount(db, niche_id=package.niche_id, entry_rate=entry_rate)
    fee = (amount_minimum * Decimal(settings.platform_fee_bps) / Decimal(10000)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    pro_gross = (amount_minimum - fee).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    gig = Gig(
        client_user_id=booking.client_user_id,
        pro_user_id=booking.pro_user_id,
        niche_id=package.niche_id,
        status=GigStatus.payment_pending,
        currency=package.currency,
        amount_minimum=amount_minimum,
        entry_rate=entry_rate,
        amount_platform_fee=fee,
        amount_pro_gross=pro_gross,
        scheduled_start=booking.requested_start,
        scheduled_end=booking.requested_end,
        location_text=booking.location_text,
        meta={"booking_request_id": str(booking.id)},
    )
    db.add(gig)
    db.flush()
    return gig


def _find_gig_by_booking_request(db: Session, booking_request_id: uuid.UUID) -> Gig | None:
    gigs = db.execute(select(Gig)).scalars().all()
    for gig in gigs:
        if (gig.meta or {}).get("booking_request_id") == str(booking_request_id):
            return gig
    return None


def _find_booking_request_by_gig(db: Session, gig_id: uuid.UUID) -> BookingRequest | None:
    gig = db.get(Gig, gig_id)
    if not gig:
        return None
    booking_request_id = (gig.meta or {}).get("booking_request_id")
    if not booking_request_id:
        return None
    try:
        return db.get(BookingRequest, uuid.UUID(str(booking_request_id)))
    except Exception:
        return None
