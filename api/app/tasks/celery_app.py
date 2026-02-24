from celery import Celery

from app.core.config import get_settings

settings = get_settings()

celery_app = Celery("rawwers_media", broker=settings.redis_url, backend=settings.redis_url)
celery_app.conf.task_default_queue = "media"
celery_app.conf.task_routes = {
    "app.tasks.media_tasks.process_photo_variants": {"queue": "media"},
}
