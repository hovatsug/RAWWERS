from __future__ import annotations

import logging

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.services.outbox import (
    claim_pending_outbox_events,
    mark_outbox_delivered,
    mark_outbox_failed,
)
from app.services.search_indexing import process_index_event
from app.services.notifications import process_due_scheduled_notifications, process_outbox_notification
from app.services.disputes import escalate_due_disputes
from app.tasks.celery_app import celery_app

settings = get_settings()
logger = logging.getLogger(__name__)


@celery_app.task(name="app.tasks.outbox_tasks.dispatch_outbox_events")
def dispatch_outbox_events_task(limit: int | None = None) -> int:
    db = SessionLocal()
    try:
        batch_limit = limit or settings.outbox_batch_size
        rows = claim_pending_outbox_events(db, limit=batch_limit)
        processed = 0
        for row in rows:
            event_id = (row.payload or {}).get("id")
            try:
                _dispatch_event(db, row.topic, row.payload)
                mark_outbox_delivered(db, row)
                logger.info(
                    "outbox_event_applied",
                    extra={"outbox_id": str(row.id), "topic": row.topic,
                           "event_id": event_id, "attempts": row.attempts},
                )
            except Exception:
                # Was swallowed entirely: a handler that raised left the row
                # marked failed with no record of why, and any partial
                # mutations it had already made were committed below.
                logger.exception(
                    "outbox_event_failed",
                    extra={"outbox_id": str(row.id), "topic": row.topic,
                           "event_id": event_id, "attempts": row.attempts},
                )
                mark_outbox_failed(db, row, max_attempts=settings.outbox_max_attempts)
            processed += 1

        # Committed here, before the unrelated sweeps below. They used to run
        # inside the same transaction, so an exception in either one skipped
        # the commit and the `finally` closed the session - silently
        # discarding every delivery in the batch, marks and effects alike,
        # with nothing logged. Outbox delivery must not depend on whether a
        # dispute sweep happened to succeed.
        db.commit()

        for sweep in (escalate_due_disputes, process_due_scheduled_notifications):
            try:
                sweep(db, limit=batch_limit)
                db.commit()
            except Exception:
                logger.exception("outbox_sweep_failed", extra={"sweep": sweep.__name__})
                db.rollback()
        return processed
    finally:
        db.close()


def _dispatch_event(db, topic: str, payload: dict) -> None:
    from app.api.v1.webhooks import _apply_mux_event, _apply_stripe_event
    from app.services.mail import get_mail_provider

    if topic == "stripe.event":
        event_type = payload.get("type", "unknown")
        obj = ((payload.get("data") or {}).get("object")) or {}
        _apply_stripe_event(db, event_type, obj)
        return
    if topic == "mux.event":
        event_type = payload.get("type", "unknown")
        data = payload.get("data", {})
        _apply_mux_event(db, event_type, data)
        return
    if topic == "reindex.pro":
        from app.services.discovery_index import recompute_pro_public_index
        import uuid

        recompute_pro_public_index(db, uuid.UUID(payload["pro_user_id"]))
        return
    if topic == "recompute.skills":
        from app.services.niche_skills import recompute_pro_niche_skills
        import uuid

        recompute_pro_niche_skills(db, uuid.UUID(payload["pro_user_id"]), uuid.UUID(payload["niche_id"]) if payload.get("niche_id") else None)
        return
    if topic == "niche_skill.recalc":
        from app.services.niche_skills import recompute_pro_niche_skills
        import uuid

        recompute_pro_niche_skills(db, uuid.UUID(payload["pro_user_id"]), uuid.UUID(payload["niche_id"]) if payload.get("niche_id") else None)
        return
    if topic.startswith("index."):
        process_index_event(db, topic, payload)
        return
    if topic == "email.verify.send":
        get_mail_provider().send_verification_email(email=payload["email"], code=payload["code"])
        return
    if topic == "email.reset.send":
        get_mail_provider().send_password_reset_email(email=payload["email"], code=payload["code"])
        return
    if topic == "launch.invite.email":
        code = payload["code"]
        wave_name = payload.get("wave_name", "RAWWERS Invite")
        get_mail_provider().send_template_email(
            email=payload["email"],
            template_key="launch_invite",
            subject=f"Your RAWWERS invite ({wave_name})",
            text_body=f"Your invite code is: {code}",
            unsubscribe_url=None,
        )
        return
    if topic == "client.waitlist.confirmation_email":
        get_mail_provider().send_template_email(
            email=payload["email"],
            template_key="client_waitlist_confirmation",
            subject="You are on the RAWWERS client waitlist",
            text_body=f"Thanks. We will notify you when {payload.get('city')}, {payload.get('country')} is enabled.",
            unsubscribe_url=None,
        )
        return
    if topic.startswith("notify."):
        process_outbox_notification(topic, payload, db)
        return
    if topic == "media.derivative.generate":
        from app.tasks.media_tasks import generate_media_derivative_task

        generate_media_derivative_task.delay(payload["media_asset_id"], payload["kind"])
        return
    if topic == "consent.reward.evaluate":
        import uuid
        from app.services.client_rewards_pricing import maybe_award_consent_points
        from app.services.gamification import queue_evaluate_user_milestones

        user_id = uuid.UUID(payload["client_user_id"])
        maybe_award_consent_points(
            db,
            gig_id=uuid.UUID(payload["gig_id"]),
            client_user_id=user_id,
            consent_level=payload["to_level"],
        )
        queue_evaluate_user_milestones(user_id)
        return
    if topic == "consent.clawback.evaluate":
        import uuid
        from app.services.client_rewards_pricing import maybe_clawback_consent_points

        maybe_clawback_consent_points(
            db,
            gig_id=uuid.UUID(payload["gig_id"]),
            client_user_id=uuid.UUID(payload["client_user_id"]),
            from_level=payload["from_level"],
            to_level=payload["to_level"],
        )
        return
    if topic == "share.reward.evaluate":
        import uuid
        from app.services.client_rewards_pricing import evaluate_share_reward_thresholds
        from app.services.gamification import queue_evaluate_user_milestones
        from app.models.media_rights import ShareLink

        share_link_id = uuid.UUID(payload["share_link_id"])
        evaluate_share_reward_thresholds(db, share_link_id=share_link_id)
        link = db.get(ShareLink, share_link_id)
        if link:
            queue_evaluate_user_milestones(link.created_by_user_id)
        return
    if topic == "referral.reward.granted":
        import uuid
        from app.models.communication import NotificationSeverity
        from app.services.notifications import enqueue_notification

        referrer_user_id = uuid.UUID(payload["referrer_user_id"])
        referee_user_id = uuid.UUID(payload["referee_user_id"])
        conversion_type = payload.get("conversion_type", "conversion")
        conversion_id = payload.get("conversion_id", "")
        enqueue_notification(
            db,
            user_id=referrer_user_id,
            notification_type="referral.reward.granted",
            payload={
                "title": "Referral reward granted",
                "body": f"Your referral converted via {conversion_type}.",
                "conversion_id": conversion_id,
            },
            reference_type="referral_reward_grant",
            reference_id=payload.get("grant_id"),
            severity=NotificationSeverity.important,
        )
        enqueue_notification(
            db,
            user_id=referee_user_id,
            notification_type="referral.reward.granted",
            payload={
                "title": "Welcome reward granted",
                "body": f"You unlocked a referral reward from {conversion_type}.",
                "conversion_id": conversion_id,
            },
            reference_type="referral_reward_grant",
            reference_id=payload.get("grant_id"),
            severity=NotificationSeverity.info,
        )
        return
    if topic == "refund.initiate":
        import uuid
        from app.services.disputes import initiate_refund_case

        initiate_refund_case(db, uuid.UUID(payload["refund_case_id"]))
        return
    if topic == "dispute.escalation.scan":
        from app.services.disputes import escalate_due_disputes

        escalate_due_disputes(db, limit=int(payload.get("limit", 200)))
        return
    if topic == "ai.reply.generate":
        import uuid
        from app.models.chat import ChatThread
        from app.services.ai_concierge import generate_ai_reply_for_thread
        from app.services.analytics import log_event

        thread = db.get(ChatThread, uuid.UUID(payload["thread_id"]))
        if not thread:
            return
        ai_message, _ = generate_ai_reply_for_thread(db, thread=thread, draft_only=False)
        if ai_message:
            log_event(
                db,
                event_name="ai.reply_generated",
                user_id=thread.client_user_id,
                properties={"thread_id": str(thread.id), "message_id": str(ai_message.id)},
            )
        return
    if topic == "raww.mint":
        from app.services.proof_of_gigs import process_raww_mint_event

        process_raww_mint_event(db, payload=payload or {})
        return
    if topic == "raww.reverse_refund":
        import uuid
        from app.services.proof_of_gigs import reverse_raww_mints_for_refund

        gig_id = payload.get("gig_id")
        if gig_id:
            reverse_raww_mints_for_refund(db, gig_id=uuid.UUID(gig_id), reason="refund_or_dispute")
        return
    if topic == "raww.milestone.scan":
        from app.services.proof_of_gigs import enqueue_milestone_events

        enqueue_milestone_events(db)
        return
    if topic == "earnings.settlement.scan":
        from app.services.payouts import settle_due_earnings_entries

        settle_due_earnings_entries(db, limit=int(payload.get("limit", 500)))
        return
    if topic == "payout.execute":
        import uuid
        from app.services.payouts import execute_payout_request

        payout_request_id = payload.get("payout_request_id")
        if payout_request_id:
            execute_payout_request(db, payout_request_id=uuid.UUID(payout_request_id))
        return
    if topic == "print.export.run":
        import uuid
        from app.services.prints_fulfillment import run_print_export_job

        job_id = payload.get("print_export_job_id")
        if job_id:
            run_print_export_job(db, print_export_job_id=uuid.UUID(job_id))
        return
