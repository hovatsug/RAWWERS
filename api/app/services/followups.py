from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.communication import (
    CallDirection,
    CallOutcome,
    CallPurpose,
    CallSession,
    CallSessionStatus,
    FollowupChannel,
    FollowupJob,
    FollowupJobStatus,
    FollowupRule,
    Notification,
    NotificationStatus,
)
from app.services.analytics import log_event
from app.services.call_compliance import enforce_call_allowed
from app.services.telephony import get_telephony_provider
from app.tasks.call_tasks import execute_outbound_call_task

settings = get_settings()


DEFAULT_RULES: list[dict] = [
    {
        "code": "booking_request_pending_2h",
        "trigger": "booking_request.pending.client",
        "delay_minutes": 120,
        "channel": FollowupChannel.in_app,
        "max_attempts": 2,
        "meta": {"title": "Booking request pending", "body": "Your request is still pending. You can message the photographer."},
    },
    {
        "code": "pro_response_lag_60m",
        "trigger": "booking_request.pending.pro",
        "delay_minutes": 60,
        "channel": FollowupChannel.in_app,
        "max_attempts": 2,
        "meta": {"title": "Pending booking request", "body": "A client is waiting for your response."},
    },
    {
        "code": "payment_pending_1h",
        "trigger": "payment_pending.client",
        "delay_minutes": 60,
        "channel": FollowupChannel.in_app,
        "max_attempts": 2,
        "meta": {"title": "Complete payment", "body": "Your booking is waiting for payment."},
    },
    {
        "code": "payment_pending_24h",
        "trigger": "payment_pending.client",
        "delay_minutes": 1440,
        "channel": FollowupChannel.in_app,
        "max_attempts": 1,
        "meta": {"title": "Payment reminder", "body": "Your booking payment is still pending."},
    },
    {
        "code": "proof_selection_24h",
        "trigger": "proof_gallery.published.client",
        "delay_minutes": 1440,
        "channel": FollowupChannel.in_app,
        "max_attempts": 2,
        "meta": {"title": "Select your photos", "body": "Your proof gallery is ready for selection."},
    },
    {
        "code": "booking_confirmation_30m",
        "trigger": "booking_request.accepted.client",
        "delay_minutes": 30,
        "channel": FollowupChannel.in_app,
        "max_attempts": 1,
        "meta": {"title": "Booking accepted", "body": "Your booking request was accepted. Complete payment to confirm."},
    },
]


def seed_followup_rules(db: Session) -> int:
    created = 0
    for item in DEFAULT_RULES:
        existing = db.execute(select(FollowupRule).where(FollowupRule.code == item["code"])).scalar_one_or_none()
        if existing:
            continue
        db.add(
            FollowupRule(
                code=item["code"],
                is_enabled=True,
                trigger=item["trigger"],
                delay_minutes=item["delay_minutes"],
                channel=item["channel"],
                max_attempts=item["max_attempts"],
                meta=item["meta"],
            )
        )
        created += 1
    db.flush()
    return created


def schedule_followups(
    db: Session,
    *,
    trigger: str,
    user_id: uuid.UUID,
    target_type: str,
    target_id: uuid.UUID,
    now: datetime | None = None,
) -> list[FollowupJob]:
    now = now or datetime.now(timezone.utc)
    rules = db.execute(
        select(FollowupRule).where(FollowupRule.trigger == trigger, FollowupRule.is_enabled.is_(True))
    ).scalars().all()
    jobs: list[FollowupJob] = []
    for rule in rules:
        scheduled_for = now + timedelta(minutes=rule.delay_minutes)
        existing = db.execute(
            select(FollowupJob).where(
                FollowupJob.rule_code == rule.code,
                FollowupJob.user_id == user_id,
                FollowupJob.target_type == target_type,
                FollowupJob.target_id == target_id,
                FollowupJob.scheduled_for == scheduled_for,
            )
        ).scalar_one_or_none()
        if existing:
            continue
        job = FollowupJob(
            rule_code=rule.code,
            user_id=user_id,
            target_type=target_type,
            target_id=target_id,
            scheduled_for=scheduled_for,
            status=FollowupJobStatus.scheduled,
            attempt=0,
        )
        db.add(job)
        db.flush()
        jobs.append(job)
        log_event(
            db,
            event_name="followup.scheduled",
            user_id=user_id,
            properties={"rule_code": rule.code, "target_type": target_type, "target_id": str(target_id)},
        )
    return jobs


def create_in_app_notification(db: Session, user_id: uuid.UUID, title: str, body: str, deep_link: str | None = None) -> Notification:
    note = Notification(
        user_id=user_id,
        title=title,
        body=body,
        deep_link=deep_link,
        status=NotificationStatus.unread,
    )
    db.add(note)
    db.flush()
    log_event(db, event_name="notification.created", user_id=user_id, properties={"notification_id": str(note.id)})
    return note


def process_due_followup_jobs(db: Session, now: datetime | None = None) -> dict[str, int]:
    now = now or datetime.now(timezone.utc)
    due_jobs = db.execute(
        select(FollowupJob)
        .where(FollowupJob.status == FollowupJobStatus.scheduled, FollowupJob.scheduled_for <= now)
        .order_by(FollowupJob.scheduled_for.asc())
        .limit(200)
    ).scalars().all()

    sent = 0
    skipped = 0
    failed = 0
    for job in due_jobs:
        rule = db.execute(select(FollowupRule).where(FollowupRule.code == job.rule_code)).scalar_one_or_none()
        if not rule or not rule.is_enabled:
            job.status = FollowupJobStatus.cancelled
            skipped += 1
            continue
        if job.attempt >= rule.max_attempts:
            job.status = FollowupJobStatus.skipped
            skipped += 1
            continue

        job.status = FollowupJobStatus.running
        job.attempt += 1
        db.flush()
        try:
            if rule.channel == FollowupChannel.in_app:
                title = (rule.meta or {}).get("title") or "Reminder"
                body = (rule.meta or {}).get("body") or "You have a pending update."
                deep_link = (rule.meta or {}).get("deep_link")
                create_in_app_notification(db, job.user_id, title=title, body=body, deep_link=deep_link)
                job.status = FollowupJobStatus.sent
                sent += 1
                log_event(db, event_name="followup.sent", user_id=job.user_id, properties={"rule_code": job.rule_code})
            elif rule.channel == FollowupChannel.phone_call:
                contact = enforce_call_allowed(db, job.user_id, None)
                if not contact.phone_e164:
                    raise ValueError("recipient phone missing")
                call = CallSession(
                    provider=settings.telephony_provider,
                    direction=CallDirection.outbound,
                    pro_user_id=None,
                    recipient_user_id=job.user_id,
                    recipient_phone_e164=contact.phone_e164,
                    purpose=_purpose_for_rule_code(job.rule_code),
                    status=CallSessionStatus.queued,
                    outcome=CallOutcome.unknown,
                    meta={"followup_job_id": str(job.id), "target_type": job.target_type, "target_id": str(job.target_id)},
                )
                db.add(call)
                db.flush()
                try:
                    execute_outbound_call_task.delay(str(call.id))
                except Exception:
                    execute_outbound_call_task(str(call.id))
                job.status = FollowupJobStatus.sent
                sent += 1
                log_event(db, event_name="followup.sent", user_id=job.user_id, properties={"rule_code": job.rule_code, "call_session_id": str(call.id)})
            else:
                job.status = FollowupJobStatus.skipped
                skipped += 1
                log_event(db, event_name="followup.skipped", user_id=job.user_id, properties={"rule_code": job.rule_code, "reason": "channel_not_implemented"})
        except Exception as exc:
            job.status = FollowupJobStatus.failed
            job.last_error = str(exc)
            failed += 1
            log_event(db, event_name="followup.skipped", user_id=job.user_id, properties={"rule_code": job.rule_code, "reason": "send_failed"})

    db.flush()
    return {"processed": len(due_jobs), "sent": sent, "skipped": skipped, "failed": failed}


def _purpose_for_rule_code(rule_code: str) -> CallPurpose:
    if "payment" in rule_code:
        return CallPurpose.payment_nudge
    if "request" in rule_code:
        return CallPurpose.request_nudge
    return CallPurpose.booking_confirmation
