from __future__ import annotations

import uuid
from datetime import datetime, timezone

from app.db.session import SessionLocal
from app.core.config import get_settings
from app.models.communication import CallEvent, CallOutcome, CallSession, CallSessionStatus
from app.services.call_compliance import enforce_call_allowed, transcription_allowed
from app.services.telephony import get_telephony_provider
from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.call_tasks.execute_outbound_call")
def execute_outbound_call_task(call_session_id: str) -> dict:
    db = SessionLocal()
    try:
        session = db.get(CallSession, uuid.UUID(call_session_id))
        if not session:
            return {"ok": False, "reason": "not_found"}
        if session.status != CallSessionStatus.queued:
            return {"ok": False, "reason": "invalid_state"}

        allow_one_time = (session.meta or {}).get("source") == "call_me_button"
        enforce_call_allowed(db, session.recipient_user_id, session.pro_user_id, allow_one_time_call_me=allow_one_time)
        provider = get_telephony_provider()
        webhook_url = f"{settings.app_public_url.rstrip('/')}/v1/webhooks/telephony"
        result = provider.create_outbound_call(
            to_e164=session.recipient_phone_e164,
            from_e164=settings.telephony_from_e164,
            webhook_url=webhook_url,
            metadata={"call_session_id": str(session.id), "purpose": session.purpose.value},
        )
        session.provider_call_id = result.provider_call_id
        session.status = CallSessionStatus.dialing
        session.started_at = datetime.now(timezone.utc)
        db.add(CallEvent(call_session_id=session.id, event_type="provider.status", payload={"status": "dialing"}))
        db.flush()

        if result.status == "completed":
            session.status = CallSessionStatus.completed
            session.ended_at = datetime.now(timezone.utc)
            session.outcome = CallOutcome(result.outcome or "connected")
            if provider.supports_transcription and transcription_allowed(db, session.recipient_user_id):
                session.transcript = "Mock transcript: recipient confirmed details."
            db.add(CallEvent(call_session_id=session.id, event_type="provider.status", payload={"status": "completed", "outcome": session.outcome.value}))

        db.commit()
        return {"ok": True, "call_session_id": str(session.id), "provider_call_id": session.provider_call_id}
    except Exception as exc:
        db.rollback()
        session_obj = db.get(CallSession, uuid.UUID(call_session_id))
        if session_obj:
            session_obj.status = CallSessionStatus.failed
            session_obj.outcome = CallOutcome.failed
            session_obj.ended_at = datetime.now(timezone.utc)
            db.add(CallEvent(call_session_id=session_obj.id, event_type="provider.status", payload={"status": "failed", "error": str(exc)}))
            db.commit()
        return {"ok": False, "reason": "exception"}
    finally:
        db.close()
settings = get_settings()
