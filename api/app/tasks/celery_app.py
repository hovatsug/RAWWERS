from __future__ import annotations

import time

from celery import Celery
from celery.signals import before_task_publish, task_failure, task_postrun, task_prerun

from app.core.config import get_settings
from app.core.request_context import clear_request_context, get_request_id, set_request_context
from app.services.metrics import increment_task_failures, observe_task_duration

settings = get_settings()

celery_app = Celery("rawwers_media", broker=settings.redis_url, backend=settings.redis_url)
celery_app.conf.task_default_queue = "media"
celery_app.conf.task_routes = {
    "app.tasks.media_tasks.process_photo_variants": {"queue": "media"},
    "app.tasks.discovery_tasks.rebuild_pro_index": {"queue": "media"},
    "app.tasks.discovery_tasks.rebuild_all_pro_indexes": {"queue": "media"},
    "app.tasks.niche_tasks.recompute_pro_niche_skills": {"queue": "media"},
    "app.tasks.niche_tasks.recompute_all_pro_niche_skills": {"queue": "media"},
    "app.tasks.learning_tasks.issue_certificate": {"queue": "media"},
    "app.tasks.learning_tasks.periodic_recompute_certifications": {"queue": "media"},
    "app.tasks.gamification_tasks.evaluate_user_milestones": {"queue": "media"},
    "app.tasks.gamification_tasks.recompute_credentials": {"queue": "media"},
    "app.tasks.reminder_tasks.process_due_reminders": {"queue": "media"},
    "app.tasks.followup_tasks.process_followup_jobs": {"queue": "media"},
    "app.tasks.call_tasks.execute_outbound_call": {"queue": "media"},
    "app.tasks.store_tasks.sync_partner_products": {"queue": "media"},
    "app.tasks.store_tasks.submit_order_to_partner": {"queue": "media"},
    "app.tasks.repair_tasks.recompute_partner_score": {"queue": "media"},
    "app.tasks.outbox_tasks.dispatch_outbox_events": {"queue": "media"},
    "app.tasks.dispute_tasks.escalate_disputes": {"queue": "media"},
    "app.tasks.dispute_tasks.initiate_refund": {"queue": "media"},
    "app.tasks.launch_ops_tasks.onboarding_ready_check": {"queue": "media"},
    "app.tasks.proof_of_gigs_tasks.scan_studioverse_milestones": {"queue": "media"},
    "app.tasks.payouts_tasks.enqueue_settlement_scan": {"queue": "media"},
    "app.tasks.payouts_tasks.run_settlement_scan": {"queue": "media"},
}

_TASK_START_TIMES: dict[str, float] = {}


@before_task_publish.connect
def add_request_id_header(headers=None, **_kwargs):  # pragma: no cover
    if headers is None:
        return
    current_request_id = get_request_id()
    if current_request_id and "x-request-id" not in headers:
        headers["x-request-id"] = current_request_id


@task_prerun.connect
def on_task_prerun(task_id=None, task=None, **_kwargs):  # pragma: no cover
    if task_id:
        _TASK_START_TIMES[task_id] = time.monotonic()
    headers = getattr(getattr(task, "request", None), "headers", None) or {}
    request_id = headers.get("x-request-id")
    set_request_context(request_id=request_id)


@task_postrun.connect
def on_task_postrun(task_id=None, task=None, **_kwargs):  # pragma: no cover
    if task_id and task:
        started = _TASK_START_TIMES.pop(task_id, None)
        if started is not None:
            observe_task_duration(task.name, max(0.0, time.monotonic() - started))
    clear_request_context()


@task_failure.connect
def on_task_failure(task_id=None, exception=None, sender=None, **_kwargs):  # pragma: no cover
    if sender:
        increment_task_failures(sender.name)

# Ensure task registration when worker boots.
from app.tasks import call_tasks, discovery_tasks, dispute_tasks, followup_tasks, gamification_tasks, launch_ops_tasks, learning_tasks, media_tasks, outbox_tasks, payouts_tasks, proof_of_gigs_tasks, reminder_tasks, repair_tasks, store_tasks  # noqa: E402,F401
