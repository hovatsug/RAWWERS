"""Photographer accountability for non-delivery.

Pay for what was delivered (price_reduction does that); hold people to what
they promised - fairly, visibly to them, never by guesswork:

- **Only an admin's recorded fault** makes a finding, and only on a booking
  whose price reduction carries a reason that may carry fault
  (photographer_non_delivery). The "fewer photos delivered" flag is a review
  item for the admin, never a finding. The system never decides fault.
- **Due process.** The photographer is told (in-app now; the same notice goes
  to email once email is delivered) and can respond. The window to respond
  starts when they first see the finding in the app, or after the policy's
  grace period if they never open it. An admin confirms or withdraws it;
  nothing takes effect before the window ends. A withdrawn finding leaves no
  strike.
- **The ladder**, every number in the policy row: the first confirmed
  finding in the rolling window is a warning, the second pauses new bookings
  (an admin-controlled flag the photographer cannot switch off), the third or
  more raises a suspension review for an admin. A finding marked severe, with
  a note, goes straight to suspension review.
- **No ranking.** A finding in effect is recorded as a pro_fault_event of
  kind non_delivery_at_fault, which disputes_count does not count; strikes,
  warnings and pauses are read by nothing that ranks or orders. A pause takes
  the photographer out of discovery through pro_standing, as a ban does.
- **Nothing retroactive**: strikes count findings made here, nothing older.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.accountability import AccountabilityPolicy, BookingPause, PhotographerFinding
from app.models.admin import MoneyAttentionItem, ProFaultEvent
from app.models.gig import Gig
from app.models.price_reduction import PriceReduction, PriceReductionReason
from app.services.audit import add_admin_audit_log
from app.services.notifications import enqueue_notification

FAULT_KIND = "non_delivery_at_fault"


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=timezone.utc)


def policy(db: Session) -> AccountabilityPolicy:
    row = db.get(AccountabilityPolicy, 1)
    if row is None:
        row = AccountabilityPolicy(id=1)
        db.add(row)
        db.flush()
    return row


def window_ends_at(finding: PhotographerFinding, rules: AccountabilityPolicy) -> datetime:
    """When the photographer's time to respond ends: the window starts when
    they first saw it, or after the grace period if that comes first."""
    unseen_start = _aware(finding.created_at) + timedelta(days=rules.unseen_grace_days)
    start = min(_aware(finding.first_seen_at), unseen_start) if finding.first_seen_at else unseen_start
    return start + timedelta(days=rules.contest_window_days)


def strikes(db: Session, pro_user_id: uuid.UUID, *, now: datetime | None = None) -> int:
    """Confirmed findings in effect inside the rolling window."""
    since = (now or _now()) - timedelta(days=30 * policy(db).rolling_window_months)
    return int(db.execute(
        select(func.count()).select_from(PhotographerFinding).where(
            PhotographerFinding.pro_user_id == pro_user_id,
            PhotographerFinding.status == "confirmed",
            PhotographerFinding.consequence.is_not(None),
            PhotographerFinding.effective_at >= since,
        )
    ).scalar_one())


def active_pause(db: Session, pro_user_id: uuid.UUID) -> BookingPause | None:
    return db.execute(
        select(BookingPause).where(BookingPause.pro_user_id == pro_user_id, BookingPause.lifted_at.is_(None))
        .order_by(BookingPause.created_at.desc())
    ).scalars().first()


# --- recording, seeing, responding, deciding -----------------------------------------------


def record_finding(
    db: Session, *, gig: Gig, admin_user_id: uuid.UUID, note: str, severe: bool = False, severe_note: str | None = None
) -> PhotographerFinding:
    if not (note or "").strip():
        raise APIError(code="validation_error", message="A finding needs a note saying what was found", status_code=422)
    if severe and not (severe_note or "").strip():
        raise APIError(code="validation_error", message="Marking a finding severe needs a note saying why", status_code=422)
    fault_codes = {r.code for r in db.execute(select(PriceReductionReason).where(PriceReductionReason.may_carry_fault.is_(True))).scalars()}
    reduction = next(
        (
            r for r in db.execute(
                select(PriceReduction).where(PriceReduction.gig_id == gig.id).order_by(PriceReduction.created_at.desc())
            ).scalars()
            if any(line["reason_code"] in fault_codes for line in r.lines)
        ),
        None,
    )
    if reduction is None:
        raise APIError(
            code="finding_needs_non_delivery",
            message="A finding can only be recorded on a booking whose price came down because photos were not delivered.",
            status_code=409,
        )
    reason = next(line["reason_code"] for line in reduction.lines if line["reason_code"] in fault_codes)
    finding = PhotographerFinding(
        pro_user_id=gig.pro_user_id, gig_id=gig.id, reduction_id=reduction.id, reason_code=reason,
        recorded_by_user_id=admin_user_id, note=note.strip(), severe=severe, severe_note=(severe_note or "").strip() or None,
    )
    db.add(finding)
    db.flush()
    enqueue_notification(
        db, user_id=gig.pro_user_id, notification_type="finding.recorded",
        payload={
            "title": "A finding about one of your bookings",
            "body": "An admin found that photos you sold were not delivered. You can respond before anything takes effect.",
            "action": {"label": "See it", "url": "/pro/findings"},
        },
        reference_type="photographer_finding", reference_id=str(finding.id),
    )
    _audit(db, admin_user_id, finding, "finding_recorded", note, {"severe": severe, "reduction_id": str(reduction.id)})
    return finding


def mark_seen(db: Session, *, finding: PhotographerFinding, pro_user_id: uuid.UUID) -> None:
    if finding.pro_user_id != pro_user_id:
        raise APIError(code="not_found", message="Finding not found", status_code=404)
    if finding.first_seen_at is None:
        finding.first_seen_at = _now()
        db.flush()


def respond(db: Session, *, finding: PhotographerFinding, pro_user_id: uuid.UUID, text: str) -> None:
    if finding.pro_user_id != pro_user_id:
        raise APIError(code="not_found", message="Finding not found", status_code=404)
    if finding.status != "pending":
        raise APIError(code="invalid_state", message="This finding has already been decided", status_code=409)
    if not (text or "").strip():
        raise APIError(code="validation_error", message="Say what happened", status_code=422)
    mark_seen(db, finding=finding, pro_user_id=pro_user_id)
    finding.response = text.strip()
    finding.responded_at = _now()
    _audit(db, pro_user_id, finding, "finding_response", None, {})
    db.flush()


def decide(db: Session, *, finding: PhotographerFinding, admin_user_id: uuid.UUID, decision: str, note: str) -> None:
    """Confirm or withdraw. A confirmation takes effect when the window to
    respond has ended - now, if it already has."""
    if finding.status != "pending":
        raise APIError(code="invalid_state", message="This finding has already been decided", status_code=409)
    if decision not in ("confirm", "withdraw"):
        raise APIError(code="validation_error", message="Decide confirm or withdraw", status_code=422)
    if not (note or "").strip():
        raise APIError(code="validation_error", message="A decision needs a note", status_code=422)
    finding.status = "confirmed" if decision == "confirm" else "withdrawn"
    finding.decided_by_user_id = admin_user_id
    finding.decided_at = _now()
    finding.decision_note = note.strip()
    _audit(db, admin_user_id, finding, f"finding_{finding.status}", note, {})
    db.flush()
    if finding.status == "confirmed":
        apply_due_findings(db, only=finding)


# --- taking effect ------------------------------------------------------------------------


def apply_due_findings(db: Session, *, now: datetime | None = None, only: PhotographerFinding | None = None) -> int:
    """Confirmed findings whose window has ended, put into effect: the strike
    counted, the ladder's consequence applied. Returns how many."""
    now = now or _now()
    rules = policy(db)
    candidates = [only] if only is not None else db.execute(
        select(PhotographerFinding).where(PhotographerFinding.status == "confirmed", PhotographerFinding.consequence.is_(None))
        .order_by(PhotographerFinding.decided_at)
    ).scalars().all()
    applied = 0
    for finding in candidates:
        if finding.status != "confirmed" or finding.consequence is not None or window_ends_at(finding, rules) > now:
            continue
        _apply(db, finding, rules, now)
        applied += 1
    db.flush()
    return applied


def _apply(db: Session, finding: PhotographerFinding, rules: AccountabilityPolicy, now: datetime) -> None:
    from app.services.discovery_index import recompute_pro_public_index
    from app.services.pro_standing import list_open_bookings_for_review

    finding.effective_at = now
    number = strikes(db, finding.pro_user_id, now=now) + 1
    if finding.severe or number >= rules.suspension_review_at:
        consequence = "suspension_review"
    elif number >= rules.pause_at:
        consequence = "booking_pause"
    else:
        consequence = "warning"
    finding.strike_number = number
    finding.consequence = consequence
    # The fault, for review and for a lost chargeback's earnings decision -
    # of a kind disputes_count does not count, so it ranks no one.
    db.add(ProFaultEvent(pro_user_id=finding.pro_user_id, gig_id=finding.gig_id, dispute_id=None, kind=FAULT_KIND,
                         severity="high" if finding.severe else "medium", note=finding.note,
                         recorded_by_user_id=finding.decided_by_user_id))
    actor = finding.decided_by_user_id or finding.recorded_by_user_id

    if consequence == "booking_pause" and active_pause(db, finding.pro_user_id) is None:
        db.add(BookingPause(pro_user_id=finding.pro_user_id, finding_id=finding.id, created_by_user_id=actor,
                            reason="New bookings are paused after a second confirmed finding that photos you sold were not delivered. "
                                   "An admin will review it."))
        db.flush()
        list_open_bookings_for_review(db, finding.pro_user_id, why="Bookings paused")
        recompute_pro_public_index(db, finding.pro_user_id)
    elif consequence == "suspension_review":
        db.add(MoneyAttentionItem(
            kind="pro_suspension_review", status="open", gig_id=finding.gig_id, amount=0, currency="EUR",
            note=(f"Strike {number} confirmed for non-delivery{' (marked severe: ' + finding.severe_note + ')' if finding.severe else ''}. "
                  "Review whether to suspend this photographer (Users: ban or suspend)."),
        ))
    enqueue_notification(
        db, user_id=finding.pro_user_id, notification_type="finding.in_effect",
        payload={"title": _consequence_title(consequence), "body": _consequence_body(consequence),
                 "action": {"label": "See it", "url": "/pro/findings"}},
        reference_type="photographer_finding", reference_id=str(finding.id),
    )
    _audit(db, actor, finding, "finding_in_effect", None, {"strike": number, "consequence": consequence})


def _consequence_title(consequence: str) -> str:
    return {"warning": "A warning on your account", "booking_pause": "New bookings are paused",
            "suspension_review": "Your account is under review"}[consequence]


def _consequence_body(consequence: str) -> str:
    return {
        "warning": "Deliver every photo a client paid for. A second confirmed finding pauses new bookings.",
        "booking_pause": "You cannot take new bookings until an admin reviews this. Your existing bookings go ahead.",
        "suspension_review": "An admin is reviewing whether to suspend your account.",
    }[consequence]


def lift_pause(db: Session, *, pro_user_id: uuid.UUID, admin_user_id: uuid.UUID, note: str) -> BookingPause:
    from app.services.discovery_index import recompute_pro_public_index

    if not (note or "").strip():
        raise APIError(code="validation_error", message="Lifting a pause needs a note", status_code=422)
    pause = active_pause(db, pro_user_id)
    if pause is None:
        raise APIError(code="not_found", message="No pause to lift", status_code=404)
    pause.lifted_at = _now()
    pause.lifted_by_user_id = admin_user_id
    pause.lift_note = note.strip()
    add_admin_audit_log(db, actor_user_id=admin_user_id, target_type="booking_pause", target_id=str(pause.id),
                        action="booking_pause_lifted", reason=note.strip(), metadata={"pro_user_id": str(pro_user_id)})
    db.flush()
    recompute_pro_public_index(db, pro_user_id)
    return pause


def _audit(db: Session, actor: uuid.UUID, finding: PhotographerFinding, action: str, reason: str | None, meta: dict) -> None:
    add_admin_audit_log(db, actor_user_id=actor, target_type="photographer_finding", target_id=str(finding.id), action=action,
                        reason=reason, metadata={"pro_user_id": str(finding.pro_user_id), "gig_id": str(finding.gig_id), **meta})
