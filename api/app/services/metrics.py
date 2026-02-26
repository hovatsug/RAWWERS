from __future__ import annotations

import time
from collections.abc import Callable

from app.services.cache import get_redis_client

try:
    from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest
except Exception:  # pragma: no cover
    CONTENT_TYPE_LATEST = "text/plain; version=0.0.4; charset=utf-8"
    Counter = Gauge = Histogram = None


_METRICS_ENABLED = Counter is not None

if _METRICS_ENABLED:
    HTTP_REQUESTS_TOTAL = Counter(
        "http_requests_total",
        "Total HTTP requests",
        ["route", "method", "status"],
    )
    HTTP_REQUEST_DURATION_SECONDS = Histogram(
        "http_request_duration_seconds",
        "HTTP request duration in seconds",
        ["route", "method"],
    )
    DB_QUERY_DURATION_SECONDS = Histogram(
        "db_query_duration_seconds",
        "Database query duration in seconds",
        ["operation"],
    )
    CELERY_TASK_DURATION_SECONDS = Histogram(
        "celery_task_duration_seconds",
        "Celery task duration in seconds",
        ["task"],
    )
    CELERY_TASK_FAILURES_TOTAL = Counter(
        "celery_task_failures_total",
        "Total Celery task failures",
        ["task"],
    )
    WEBHOOK_EVENTS_TOTAL = Counter(
        "webhook_events_total",
        "Webhook events by provider and type",
        ["provider", "event_type", "signature_valid"],
    )
    BUSINESS_COUNTER = Counter(
        "business_events_total",
        "Business conversion and product events",
        ["event"],
    )
    CELERY_QUEUE_DEPTH = Gauge(
        "celery_queue_depth",
        "Approximate queue depth by queue",
        ["queue"],
    )
    SEARCH_REQUESTS_TOTAL = Counter(
        "search_requests_total",
        "Search requests by index and outcome",
        ["index", "fallback", "success"],
    )
    SEARCH_LATENCY_SECONDS = Histogram(
        "search_latency_seconds",
        "Search latency in seconds",
        ["index", "fallback"],
    )
    INDEX_EVENTS_TOTAL = Counter(
        "index_events_total",
        "Indexing outbox events processed",
        ["topic"],
    )
    INDEX_EVENT_FAILURES_TOTAL = Counter(
        "index_event_failures_total",
        "Indexing outbox event failures",
        ["topic"],
    )
    NOTIFICATION_EVENTS_TOTAL = Counter(
        "notification_events_total",
        "Notification deliveries by channel and outcome",
        ["channel", "outcome"],
    )
    RAWW_MINT_EVENTS_TOTAL = Counter(
        "raww_mint_events_total",
        "Proof of gigs mint outcomes by event type and reason",
        ["event_type", "status", "reason"],
    )
    RAWW_MINTED_AMOUNT_TOTAL = Counter(
        "raww_minted_amount_total",
        "Total RAWW minted by event type",
        ["event_type"],
    )
    TOTAL_AVAILABLE_EUR = Gauge(
        "total_available_eur",
        "Total available earnings in EUR",
    )
    PAYOUT_VOLUME_DAILY = Counter(
        "payout_volume_daily_eur",
        "Total paid out volume in EUR",
    )
    DISPUTE_HOLD_AMOUNT = Gauge(
        "dispute_hold_amount_eur",
        "Total active dispute hold amount in EUR",
    )
else:  # pragma: no cover
    HTTP_REQUESTS_TOTAL = None
    HTTP_REQUEST_DURATION_SECONDS = None
    DB_QUERY_DURATION_SECONDS = None
    CELERY_TASK_DURATION_SECONDS = None
    CELERY_TASK_FAILURES_TOTAL = None
    WEBHOOK_EVENTS_TOTAL = None
    BUSINESS_COUNTER = None
    CELERY_QUEUE_DEPTH = None
    SEARCH_REQUESTS_TOTAL = None
    SEARCH_LATENCY_SECONDS = None
    INDEX_EVENTS_TOTAL = None
    INDEX_EVENT_FAILURES_TOTAL = None
    NOTIFICATION_EVENTS_TOTAL = None
    RAWW_MINT_EVENTS_TOTAL = None
    RAWW_MINTED_AMOUNT_TOTAL = None
    TOTAL_AVAILABLE_EUR = None
    PAYOUT_VOLUME_DAILY = None
    DISPUTE_HOLD_AMOUNT = None

BUSINESS_EVENT_MAP = {
    "booking.request_created": "booking_request_created",
    "booking.accepted": "booking_request_accepted",
    "payment.succeeded": "payment_succeeded",
    "proof_gallery.published": "proof_gallery_published",
    "proof.selection_submitted": "proof_selection_submitted",
    "store.order_paid": "upsell_purchase_succeeded",
    "referral.claimed": "referral_claimed",
    "reward.spent": "reward_spent",
    "chat.started": "chat_started",
}


class _NoopTimer:
    def __enter__(self) -> "_NoopTimer":
        return self

    def __exit__(self, *_args) -> None:
        return


def time_db_query(operation: str):
    if not _METRICS_ENABLED or DB_QUERY_DURATION_SECONDS is None:
        return _NoopTimer()
    return DB_QUERY_DURATION_SECONDS.labels(operation=operation).time()


def observe_http(route: str, method: str, status_code: int, duration_seconds: float) -> None:
    if not _METRICS_ENABLED:
        return
    HTTP_REQUESTS_TOTAL.labels(route=route, method=method, status=str(status_code)).inc()
    HTTP_REQUEST_DURATION_SECONDS.labels(route=route, method=method).observe(duration_seconds)


def observe_webhook(provider: str, event_type: str, signature_valid: bool) -> None:
    if not _METRICS_ENABLED:
        return
    WEBHOOK_EVENTS_TOTAL.labels(provider=provider, event_type=event_type, signature_valid=str(signature_valid).lower()).inc()


def observe_business_event(name: str) -> None:
    if not _METRICS_ENABLED:
        return
    BUSINESS_COUNTER.labels(event=name).inc()


def observe_business_event_from_analytics(event_name: str) -> None:
    mapped = BUSINESS_EVENT_MAP.get(event_name)
    if mapped:
        observe_business_event(mapped)


def observe_task_duration(task_name: str, duration_seconds: float) -> None:
    if not _METRICS_ENABLED:
        return
    CELERY_TASK_DURATION_SECONDS.labels(task=task_name).observe(duration_seconds)


def increment_task_failures(task_name: str) -> None:
    if not _METRICS_ENABLED:
        return
    CELERY_TASK_FAILURES_TOTAL.labels(task=task_name).inc()


def observe_search_request(index_name: str, *, fallback: bool, success: bool, duration_seconds: float) -> None:
    if not _METRICS_ENABLED:
        return
    SEARCH_REQUESTS_TOTAL.labels(index=index_name, fallback=str(fallback).lower(), success=str(success).lower()).inc()
    SEARCH_LATENCY_SECONDS.labels(index=index_name, fallback=str(fallback).lower()).observe(duration_seconds)


def increment_index_event(topic: str) -> None:
    if not _METRICS_ENABLED:
        return
    INDEX_EVENTS_TOTAL.labels(topic=topic).inc()


def increment_index_event_failure(topic: str) -> None:
    if not _METRICS_ENABLED:
        return
    INDEX_EVENT_FAILURES_TOTAL.labels(topic=topic).inc()


def increment_notification_event(channel: str, outcome: str) -> None:
    if not _METRICS_ENABLED:
        return
    NOTIFICATION_EVENTS_TOTAL.labels(channel=channel, outcome=outcome).inc()


def observe_raww_mint(event_type: str, *, status: str, amount: int = 0, reason: str = "none") -> None:
    if not _METRICS_ENABLED:
        return
    RAWW_MINT_EVENTS_TOTAL.labels(event_type=event_type, status=status, reason=reason).inc()
    if status == "minted" and amount > 0:
        RAWW_MINTED_AMOUNT_TOTAL.labels(event_type=event_type).inc(amount)


def set_total_available_eur(amount: float) -> None:
    if not _METRICS_ENABLED or TOTAL_AVAILABLE_EUR is None:
        return
    TOTAL_AVAILABLE_EUR.set(amount)


def observe_payout_volume(amount: float) -> None:
    if not _METRICS_ENABLED or PAYOUT_VOLUME_DAILY is None:
        return
    PAYOUT_VOLUME_DAILY.inc(max(0.0, amount))


def set_dispute_hold_amount(amount: float) -> None:
    if not _METRICS_ENABLED or DISPUTE_HOLD_AMOUNT is None:
        return
    DISPUTE_HOLD_AMOUNT.set(amount)


def update_queue_depth(get_queues: Callable[[], list[str]] | None = None) -> None:
    if not _METRICS_ENABLED or CELERY_QUEUE_DEPTH is None:
        return
    queues = get_queues() if get_queues else ["media"]
    try:
        redis_client = get_redis_client()
        for queue in queues:
            depth = redis_client.llen(queue)
            CELERY_QUEUE_DEPTH.labels(queue=queue).set(depth)
    except Exception:
        return


def render_metrics() -> tuple[bytes, str]:
    if not _METRICS_ENABLED:
        return b"metrics_disabled 1\n", CONTENT_TYPE_LATEST
    update_queue_depth()
    return generate_latest(), CONTENT_TYPE_LATEST


def monotonic_seconds() -> float:
    return time.monotonic()
