from __future__ import annotations

from collections import defaultdict, deque
from datetime import datetime, timedelta, timezone

from app.core.config import get_settings
from app.core.errors import APIError
from app.services.cache import get_redis_client

settings = get_settings()

_BUCKETS: dict[str, deque[datetime]] = defaultdict(deque)


RATE_LIMIT_RULES: dict[str, tuple[int, int]] = {
    "public_read": (settings.rate_limit_public_read_per_min, 60),
    "auth_mutation": (settings.rate_limit_auth_mutation_per_min, 60),
    "chat_messages": (settings.rate_limit_chat_messages_per_min, 60),
    "reviews": (settings.rate_limit_reviews_per_day, 86400),
    "referral_claims": (settings.rate_limit_referral_claims_per_day, 86400),
    "payments": (settings.rate_limit_payments_per_hour, 3600),
    "uploads": (settings.rate_limit_uploads_per_hour, 3600),
    "admin": (settings.rate_limit_admin_per_min, 60),
    "notifications_email": (settings.rate_limit_notifications_email_per_day, 86400),
    "notifications_inapp": (settings.rate_limit_notifications_inapp_per_day, 86400),
    "notifications_burst": (settings.rate_limit_notifications_burst_per_min, 60),
}


def enforce_rate_limit(key: str, max_requests: int, window_seconds: int) -> None:
    redis_key = f"ratelimit:{key}:{window_seconds}"
    try:
        client = get_redis_client()
        current = client.incr(redis_key)
        if current == 1:
            client.expire(redis_key, window_seconds)
        if current > max_requests:
            raise APIError(
                code="rate_limited",
                message="Too many requests",
                status_code=429,
                details={"bucket": key, "limit": max_requests, "window_seconds": window_seconds},
            )
        return
    except APIError:
        raise
    except Exception:
        _enforce_rate_limit_in_memory(key=redis_key, max_requests=max_requests, window_seconds=window_seconds)


def enforce_named_rate_limit(bucket: str, principal: str) -> None:
    rule = RATE_LIMIT_RULES.get(bucket)
    if not rule:
        raise APIError(code="validation_error", message="Unknown rate limit bucket", status_code=500)
    max_requests, window_seconds = rule
    enforce_rate_limit(f"{bucket}:{principal}", max_requests=max_requests, window_seconds=window_seconds)


def _enforce_rate_limit_in_memory(key: str, max_requests: int, window_seconds: int) -> None:
    now = datetime.now(timezone.utc)
    window_start = now - timedelta(seconds=window_seconds)
    bucket = _BUCKETS[key]

    while bucket and bucket[0] < window_start:
        bucket.popleft()

    if len(bucket) >= max_requests:
        raise APIError(
            code="rate_limited",
            message="Too many requests",
            status_code=429,
            details={"bucket": key, "limit": max_requests, "window_seconds": window_seconds},
        )

    bucket.append(now)
