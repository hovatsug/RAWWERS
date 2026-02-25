from celery import Celery

from app.core.config import get_settings

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
}

# Ensure task registration when worker boots.
from app.tasks import call_tasks, discovery_tasks, followup_tasks, gamification_tasks, learning_tasks, media_tasks, outbox_tasks, reminder_tasks, repair_tasks, store_tasks  # noqa: E402,F401
