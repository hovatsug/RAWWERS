from __future__ import annotations

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, Header, Request
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db_session, require_admin, require_not_banned
from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus
from app.models.communication import (
    CallEvent,
    CallOutcome,
    CallPurpose,
    CallSession,
    CallSessionStatus,
    ConsentChannel,
    ConsentScope,
    ContactConsent,
    FollowupRule,
    UserContact,
)
from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.models.gig import Gig, GigStatus
from app.schemas.communication import (
    CallRequestBody,
    CallSessionView,
    CallSummaryResponse,
    ConsentUpdateRequest,
    ConsentView,
    FollowupRebuildResponse,
    FollowupSeedResponse,
    TelephonyWebhookRequest,
    UserContactUpdateRequest,
    UserContactView,
)
from app.schemas.media import CurrentUser
from app.services.analytics import log_event
from app.services.audit import add_admin_audit_log
from app.services.authz import get_user_roles
from app.services.call_compliance import (
    enforce_call_allowed,
    get_or_create_user_contact,
    transcription_allowed,
)
from app.services.followups import schedule_followups, seed_followup_rules
from app.services.llm import get_llm_provider
from app.services.telephony import get_telephony_provider
from app.tasks.call_tasks import execute_outbound_call_task

settings = get_settings()
router = APIRouter(tags=["communications"])


@router.put("/me/contact", response_model=UserContactView)
def upsert_my_contact(
    body: UserContactUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UserContactView:
    contact = get_or_create_user_contact(db, user.user_id)
    if body.phone_e164 is not None:
        contact.phone_e164 = body.phone_e164
    if body.timezone is not None:
        contact.timezone_name = body.timezone
    if body.quiet_hours_start is not None:
        contact.quiet_hours_start = body.quiet_hours_start
    if body.quiet_hours_end is not None:
        contact.quiet_hours_end = body.quiet_hours_end
    db.commit()
    return UserContactView(
        user_id=contact.user_id,
        phone_e164=contact.phone_e164,
        timezone=contact.timezone_name,
        quiet_hours_start=contact.quiet_hours_start,
        quiet_hours_end=contact.quiet_hours_end,
    )


@router.post("/me/consent", response_model=ConsentView)
def set_my_consent(
    body: ConsentUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> ConsentView:
    now = datetime.now(timezone.utc)
    if not body.granted:
        active = db.execute(
            select(ContactConsent).where(
                ContactConsent.user_id == user.user_id,
                ContactConsent.channel == body.channel,
                ContactConsent.scope == body.scope,
                ContactConsent.granted.is_(True),
                ContactConsent.revoked_at.is_(None),
            )
        ).scalars().all()
        for row in active:
            row.revoked_at = now
        consent = ContactConsent(
            user_id=user.user_id,
            channel=body.channel,
            scope=body.scope,
            granted=False,
            granted_at=now,
            revoked_at=now,
            source=body.source,
            meta=body.metadata,
        )
        db.add(consent)
        log_event(db, event_name="consent.revoked", user_id=user.user_id, properties={"channel": body.channel.value, "scope": body.scope.value})
    else:
        consent = ContactConsent(
            user_id=user.user_id,
            channel=body.channel,
            scope=body.scope,
            granted=True,
            granted_at=now,
            revoked_at=None,
            source=body.source,
            meta=body.metadata,
        )
        db.add(consent)
        log_event(db, event_name="consent.granted", user_id=user.user_id, properties={"channel": body.channel.value, "scope": body.scope.value})

    add_admin_audit_log(
        db,
        actor_user_id=user.user_id,
        target_type="contact_consent",
        target_id=str(user.user_id),
        action="consent_changed",
        reason=None,
        metadata={"channel": body.channel.value, "scope": body.scope.value, "granted": body.granted},
    )
    db.commit()
    db.refresh(consent)
    return ConsentView(
        id=consent.id,
        user_id=consent.user_id,
        channel=consent.channel,
        scope=consent.scope,
        granted=consent.granted,
        granted_at=consent.granted_at,
        revoked_at=consent.revoked_at,
        source=consent.source,
        metadata=consent.meta or {},
    )


@router.post("/admin/followups/rules/seed", response_model=FollowupSeedResponse)
def admin_seed_followup_rules(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> FollowupSeedResponse:
    created = seed_followup_rules(db)
    db.commit()
    return FollowupSeedResponse(created_count=created)


@router.post("/admin/followups/rebuild", response_model=FollowupRebuildResponse)
def admin_rebuild_followups(
    _: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> FollowupRebuildResponse:
    rebuilt = 0
    pending_requests = db.execute(
        select(BookingRequest).where(BookingRequest.status == BookingRequestStatus.pending)
    ).scalars().all()
    for request in pending_requests:
        rebuilt += len(
            schedule_followups(
                db,
                trigger="booking_request.pending.client",
                user_id=request.client_user_id,
                target_type="booking_request",
                target_id=request.id,
            )
        )
        rebuilt += len(
            schedule_followups(
                db,
                trigger="booking_request.pending.pro",
                user_id=request.pro_user_id,
                target_type="booking_request",
                target_id=request.id,
            )
        )

    payment_pending = db.execute(
        select(Gig).where(Gig.status == GigStatus.payment_pending)
    ).scalars().all()
    for gig in payment_pending:
        rebuilt += len(
            schedule_followups(
                db,
                trigger="payment_pending.client",
                user_id=gig.client_user_id,
                target_type="gig",
                target_id=gig.id,
            )
        )

    published_galleries = db.execute(
        select(ProofGallery).where(ProofGallery.status == ProofGalleryStatus.published)
    ).scalars().all()
    for gallery in published_galleries:
        rebuilt += len(
            schedule_followups(
                db,
                trigger="proof_gallery.published.client",
                user_id=gallery.client_user_id,
                target_type="gallery",
                target_id=gallery.id,
            )
        )

    db.commit()
    return FollowupRebuildResponse(rebuilt_jobs=rebuilt)


@router.post("/calls/request", response_model=CallSessionView)
def request_outbound_call(
    body: CallRequestBody,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CallSessionView:
    roles = get_user_roles(db, user.user_id)
    is_admin = UserRoleType.admin in roles
    is_pro = UserRoleType.pro in roles
    allow_one_time = body.source == "call_me_button" and user.user_id == body.recipient_user_id
    if not allow_one_time and user.user_id != body.recipient_user_id and not is_pro and not is_admin:
        raise APIError(code="forbidden", message="Not allowed to request this call", status_code=403)
    if body.pro_user_id and not is_admin and user.user_id != body.pro_user_id:
        raise APIError(code="forbidden", message="Not allowed to set pro_user_id", status_code=403)

    contact = enforce_call_allowed(
        db,
        recipient_user_id=body.recipient_user_id,
        pro_user_id=body.pro_user_id,
        allow_one_time_call_me=allow_one_time,
    )
    if not contact.phone_e164:
        raise APIError(code="validation_error", message="Recipient phone number is required", status_code=422)

    if allow_one_time:
        now = datetime.now(timezone.utc)
        db.add(
            ContactConsent(
                user_id=body.recipient_user_id,
                channel=ConsentChannel.phone_call,
                scope=ConsentScope.transactional,
                granted=True,
                granted_at=now,
                revoked_at=now,
                source="call_me_button",
                meta={"one_time": True},
            )
        )
        log_event(db, event_name="consent.granted", user_id=body.recipient_user_id, properties={"channel": "phone_call", "scope": "transactional", "source": "call_me_button"})

    call = CallSession(
        provider=settings.telephony_provider,
        pro_user_id=body.pro_user_id,
        recipient_user_id=body.recipient_user_id,
        recipient_phone_e164=contact.phone_e164,
        purpose=body.purpose,
        status=CallSessionStatus.queued,
        outcome=CallOutcome.unknown,
        meta={
            "target_type": body.target_type,
            "target_id": str(body.target_id) if body.target_id else None,
            "requested_by": str(user.user_id),
            "source": body.source,
            **(body.metadata or {}),
        },
    )
    db.add(call)
    db.flush()
    try:
        execute_outbound_call_task.delay(str(call.id))
    except Exception:
        execute_outbound_call_task(str(call.id))

    if is_admin:
        add_admin_audit_log(
            db,
            actor_user_id=user.user_id,
            target_type="call_session",
            target_id=str(call.id),
            action="admin_call_requested",
            metadata={"recipient_user_id": str(body.recipient_user_id), "purpose": body.purpose.value},
        )

    log_event(
        db,
        event_name="call.queued",
        user_id=user.user_id,
        properties={"call_session_id": str(call.id), "purpose": body.purpose.value},
    )
    db.commit()
    db.refresh(call)
    return _call_view(call)


@router.post("/webhooks/telephony")
async def telephony_webhook(
    request: Request,
    db: Session = Depends(get_db_session),
    x_telephony_signature: str | None = Header(default=None, alias="X-Telephony-Signature"),
) -> dict:
    payload_bytes = await request.body()
    provider = get_telephony_provider()
    if settings.telephony_provider != "mock" and not provider.verify_webhook_signature(payload_bytes, x_telephony_signature):
        raise APIError(code="invalid_signature", message="Invalid telephony webhook signature", status_code=401)
    body = TelephonyWebhookRequest.model_validate_json(payload_bytes)

    call = db.execute(select(CallSession).where(CallSession.provider_call_id == body.provider_call_id)).scalar_one_or_none()
    if not call:
        raise APIError(code="not_found", message="Call session not found", status_code=404)

    status_map = {
        "dialing": CallSessionStatus.dialing,
        "in_progress": CallSessionStatus.in_progress,
        "completed": CallSessionStatus.completed,
        "failed": CallSessionStatus.failed,
        "cancelled": CallSessionStatus.cancelled,
    }
    outcome_map = {
        "connected": CallOutcome.connected,
        "no_answer": CallOutcome.no_answer,
        "busy": CallOutcome.busy,
        "failed": CallOutcome.failed,
        "voicemail": CallOutcome.voicemail,
        "cancelled": CallOutcome.cancelled,
    }
    call.status = status_map.get(body.status, call.status)
    if body.outcome:
        call.outcome = outcome_map.get(body.outcome, CallOutcome.unknown)
    if call.status == CallSessionStatus.in_progress and not call.started_at:
        call.started_at = datetime.now(timezone.utc)
        log_event(db, event_name="call.connected", user_id=call.recipient_user_id, properties={"call_session_id": str(call.id)})
    if call.status in {CallSessionStatus.completed, CallSessionStatus.failed, CallSessionStatus.cancelled} and not call.ended_at:
        call.ended_at = datetime.now(timezone.utc)
        if call.status == CallSessionStatus.completed:
            log_event(db, event_name="call.completed", user_id=call.recipient_user_id, properties={"call_session_id": str(call.id), "outcome": call.outcome.value})
        else:
            log_event(db, event_name="call.failed", user_id=call.recipient_user_id, properties={"call_session_id": str(call.id), "status": call.status.value})

    if body.transcript and transcription_allowed(db, call.recipient_user_id):
        call.transcript = body.transcript
    db.add(CallEvent(call_session_id=call.id, event_type="provider.status", payload={"status": body.status, "outcome": body.outcome, **(body.payload or {})}))
    db.commit()
    return {"ok": True}


@router.post("/calls/{call_session_id}/ai/summary", response_model=CallSummaryResponse)
def summarize_call(
    call_session_id: uuid.UUID,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> CallSummaryResponse:
    call = db.get(CallSession, call_session_id)
    if not call:
        raise APIError(code="not_found", message="Call session not found", status_code=404)
    if user.user_id not in {call.recipient_user_id, call.pro_user_id}:
        roles = get_user_roles(db, user.user_id)
        if UserRoleType.admin not in roles:
            raise APIError(code="forbidden", message="Not allowed", status_code=403)
    if call.status not in {CallSessionStatus.completed, CallSessionStatus.failed, CallSessionStatus.cancelled}:
        raise APIError(code="invalid_state", message="Call has not ended", status_code=409)

    provider = get_llm_provider()
    prompt = (
        "You are an AI calling assistant. "
        "Do not claim to be human. "
        "Use only provided call facts. "
        "If missing info, say follow-up with photographer is required. "
        "Return concise text summary."
    )
    transcript = call.transcript or ""
    generation = provider.generate(
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": f"purpose={call.purpose.value}\noutcome={call.outcome.value}\ntranscript={transcript}\nmetadata={call.meta or {}}"},
        ],
        tools=[],
        params={},
    )

    summary = generation.content.strip() or "Call completed. Follow-up with photographer may be required."
    metadata = dict(call.meta or {})
    metadata["ai_outcomes"] = _extract_outcomes(summary, transcript)
    call.summary = summary
    call.meta = metadata
    db.add(CallEvent(call_session_id=call.id, event_type="ai.response", payload={"summary": summary}))
    log_event(db, event_name="call.completed", user_id=call.recipient_user_id, properties={"call_session_id": str(call.id), "summarized": True})
    db.commit()
    return CallSummaryResponse(id=call.id, summary=summary, metadata=call.meta or {})


def _extract_outcomes(summary: str, transcript: str) -> dict:
    content = f"{summary}\n{transcript}".lower()
    confirmed = any(token in content for token in ["confirmed", "yes", "agreed"])
    handoff_required = any(token in content for token in ["unknown", "question", "forward", "handoff"])
    return {
        "confirmed": confirmed,
        "best_time_to_call": "unknown",
        "notes": summary[:500],
        "handoff_required": handoff_required,
    }


def _call_view(call: CallSession) -> CallSessionView:
    return CallSessionView(
        id=call.id,
        provider=call.provider,
        pro_user_id=call.pro_user_id,
        recipient_user_id=call.recipient_user_id,
        recipient_phone_e164=call.recipient_phone_e164,
        purpose=call.purpose,
        status=call.status,
        provider_call_id=call.provider_call_id,
        outcome=call.outcome,
        transcript=call.transcript,
        summary=call.summary,
        metadata=call.meta or {},
        created_at=call.created_at,
        updated_at=call.updated_at,
    )
