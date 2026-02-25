from __future__ import annotations

import json

import redis

from app.core.config import get_settings

settings = get_settings()

_redis_client: redis.Redis | None = None


def get_redis_client() -> redis.Redis:
    global _redis_client
    if _redis_client is None:
        _redis_client = redis.Redis.from_url(settings.redis_url, decode_responses=True)
    return _redis_client


def cache_get_json(key: str) -> dict | list | None:
    if not settings.public_cache_enabled:
        return None
    try:
        raw = get_redis_client().get(key)
    except Exception:
        return None
    if not raw:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


def cache_set_json(key: str, payload: dict | list, ttl_seconds: int) -> None:
    if not settings.public_cache_enabled:
        return
    try:
        get_redis_client().setex(key, max(1, ttl_seconds), json.dumps(payload, default=str))
    except Exception:
        return


def cache_get_text(key: str) -> str | None:
    if not settings.public_cache_enabled:
        return None
    try:
        return get_redis_client().get(key)
    except Exception:
        return None


def cache_set_text(key: str, value: str, ttl_seconds: int | None = None) -> None:
    try:
        client = get_redis_client()
        if ttl_seconds is None:
            client.set(key, value)
        else:
            client.setex(key, max(1, ttl_seconds), value)
    except Exception:
        return


def bump_public_index_version() -> int:
    try:
        client = get_redis_client()
        return int(client.incr("public_index_version"))
    except Exception:
        return 0


def get_public_index_version() -> int:
    value = cache_get_text("public_index_version")
    if not value:
        return 0
    try:
        return int(value)
    except ValueError:
        return 0
