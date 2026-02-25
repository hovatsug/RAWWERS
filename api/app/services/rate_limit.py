from __future__ import annotations

from collections import defaultdict, deque
from datetime import datetime, timedelta, timezone

from app.core.errors import APIError

_BUCKETS: dict[str, deque[datetime]] = defaultdict(deque)


def enforce_rate_limit(key: str, max_requests: int, window_seconds: int) -> None:
    now = datetime.now(timezone.utc)
    window_start = now - timedelta(seconds=window_seconds)
    bucket = _BUCKETS[key]

    while bucket and bucket[0] < window_start:
        bucket.popleft()

    if len(bucket) >= max_requests:
        raise APIError(code="rate_limited", message="Too many requests", status_code=429)

    bucket.append(now)
