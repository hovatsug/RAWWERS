from __future__ import annotations

import time
from datetime import timedelta

from celery import Celery
from celery.signals import (
    before_task_publish,
    setup_logging,
    task_failure,
    task_postrun,
    task_prerun,
)

from app.core.config import get_settings
from app.core.logging import configure_logging
from app.core.request_context import clear_request_context, get_request_id, set_request_context
from app.services.metrics import increment_task_failures, observe_task_duration

settings = get_settings()

celery_app = Celery("rawwers_media", broker=settings.redis_url, backend=settings.redis_url)


@setup_logging.connect
def _configure_worker_logging(**_kwargs) -> None:
    """Give the worker the application's logging config.

    Celery configures only its own loggers and otherwise takes over
    logging setup entirely, so `app.*` loggers had no handler in a worker
    process. Everything the application logged from inside a task was
    discarded - including the outbox and money-path instrumentation added
    for the unreproduced webhook anomaly, which runs *only* in the worker.
    The task lines were visible, so it looked like logging worked.

    Connecting to setup_logging tells Celery not to configure logging
    itself, which is what stops it clobbering this.
    """
    configure_logging(settings.log_level)
celery_app.conf.task_default_queue = "media"
celery_app.conf.beat_schedule = {
    # Drains the transactional outbox. Without this entry the only callers
    # of dispatch_outbox_events are the Stripe and Mux webhook handlers, so
    # every email and every in-app notification sat pending until an
    # unrelated payment webhook happened to flush the queue - which is why
    # verification emails and the notification feed were both silent.
    "dispatch-outbox-events": {
        "task": "app.tasks.outbox_tasks.dispatch_outbox_events",
        "schedule": timedelta(seconds=settings.outbox_dispatch_interval_seconds),
    },
    # Same omission as dispatch_outbox_events had: both of these were in
    # task_routes but never on a schedule, so nothing ever ran them. Every
    # follow-up in the product was dead as a result - including the payment
    # nudge and the "a client is waiting for your response" reminder that
    # backs the 48h booking window.
    "process-followup-jobs": {
        "task": "app.tasks.followup_tasks.process_followup_jobs",
        "schedule": timedelta(seconds=settings.followup_jobs_interval_seconds),
    },
    "process-due-reminders": {
        "task": "app.tasks.reminder_tasks.process_due_reminders",
        "schedule": timedelta(seconds=settings.reminders_interval_seconds),
    },
    "expire-booking-requests": {
        "task": "app.tasks.scheduled.expire_booking_requests",
        "schedule": timedelta(seconds=settings.booking_request_expiry_sweep_interval_seconds),
    },
    "release-payout-holds": {
        "task": "app.tasks.payouts_tasks.run_settlement_scan",
        "schedule": timedelta(seconds=settings.payout_hold_release_sweep_interval_seconds),
    },
    "escalate-stale-disputes": {
        "task": "app.tasks.dispute_tasks.escalate_disputes",
        "schedule": timedelta(seconds=settings.dispute_escalation_sweep_interval_seconds),
    },
    "sweep-stuck-bookings": {
        "task": "app.tasks.scheduled.sweep_stuck_bookings",
        "schedule": timedelta(seconds=settings.stuck_booking_sweep_interval_seconds),
    },
}
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
    "app.tasks.trust_safety_tasks.reconcile_risk_profiles": {"queue": "media"},
    "app.tasks.trust_safety_tasks.purge_risk_signals": {"queue": "media"},
    "app.tasks.scheduled.expire_booking_requests": {"queue": "media"},
    "app.tasks.scheduled.sweep_stuck_bookings": {"queue": "media"},
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
from app.tasks import call_tasks, discovery_tasks, dispute_tasks, followup_tasks, gamification_tasks, launch_ops_tasks, learning_tasks, media_tasks, outbox_tasks, payouts_tasks, proof_of_gigs_tasks, reminder_tasks, repair_tasks, scheduled, store_tasks, trust_safety_tasks  # noqa: E402,F401
