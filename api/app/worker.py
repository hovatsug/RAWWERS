from app.tasks.celery_app import celery_app
from app.tasks import niche_tasks as _niche_tasks  # noqa: F401
from app.tasks import learning_tasks as _learning_tasks  # noqa: F401

__all__ = ["celery_app"]
