from __future__ import annotations

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


@celery_app.task(name="app.tasks.outbox_tasks.dispatch_outbox_events")
def dispatch_outbox_events_task(limit: int | None = None) -> int:
    db = SessionLocal()
    try:
        batch_limit = limit or settings.outbox_batch_size
        rows = claim_pending_outbox_events(db, limit=batch_limit)
        processed = 0
        for row in rows:
            try:
                _dispatch_event(db, row.topic, row.payload)
                mark_outbox_delivered(db, row)
            except Exception:
                mark_outbox_failed(db, row, max_attempts=settings.outbox_max_attempts)
            processed += 1
        escalate_due_disputes(db, limit=batch_limit)
        process_due_scheduled_notifications(db, limit=batch_limit)
        db.commit()
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
    if topic == "refund.initiate":
        import uuid
        from app.services.disputes import initiate_refund_case

        initiate_refund_case(db, uuid.UUID(payload["refund_case_id"]))
        return
    if topic == "dispute.escalation.scan":
        from app.services.disputes import escalate_due_disputes

        escalate_due_disputes(db, limit=int(payload.get("limit", 200)))
        return
