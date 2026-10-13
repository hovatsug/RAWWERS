"""Whether a photographer is online - the one place anything asks.

The pro app sends a heartbeat at most once a minute while it is in the
foreground, and a clear when it goes to the background. The server keeps the
latest in one Redis key per photographer:

    presence:pro:<id>  =  {"ts": <heartbeat time>, "visible": <bool>}
                          expires after PRESENCE_WINDOW_SECONDS (300)

The expiry is the backstop. An app that is force-quit, crashes or loses its
signal sends no clear; it simply stops, and the key - and the dot - is gone
within the window. "Available now" will read the same timestamp with its own,
shorter window.

Two questions, one key:

  photographer_is_online  is this person around - for the assistant's hold
                          and "Available now". Ignores visibility: hiding
                          the dot is about what clients see, not about
                          being reachable.
  shown_online            should a client see a dot - also requires
                          visibility, and answers a whole screen of cards
                          with one MGET.

Visibility's source of truth is ProProfile.presence_visible. The key carries
a copy so that one lookup answers both, and a missing or unreadable copy
reads as hidden: the dot is the thing that must never be shown by mistake.

Nothing here ever reaches a client but online / not shown. No last-seen.
"""
from __future__ import annotations

import json
import logging
import time
import uuid
from collections.abc import Iterable

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.admin import ProProfile
from app.services.cache import get_redis_client

logger = logging.getLogger(__name__)


def _key(pro_user_id) -> str:
    return f"presence:pro:{pro_user_id}"


def _mget(keys: list[str]) -> list:
    """The one batched read - its own function so a test can count it, or
    break it."""
    return get_redis_client().mget(keys)


def _parse(raw) -> tuple[float, bool] | None:
    """(heartbeat time, visible) from a stored value, or None if it cannot
    be read. A visibility that is not literally true reads as hidden."""
    if raw is None:
        return None
    try:
        value = json.loads(raw)
        ts = float(value["ts"])
    except (ValueError, TypeError, KeyError):
        return None
    return ts, value.get("visible") is True


def _fresh(ts: float) -> bool:
    # Redis expires the key, but a window shortened after a key was written
    # must still apply, so the time is checked too.
    return time.time() - ts <= get_settings().presence_window_seconds


def record_heartbeat(db: Session, pro_user_id: uuid.UUID) -> bool:
    """Record that the photographer's app is open. False when throttled: a
    beat within the minimum interval of the last one is acknowledged and not
    written - the key is still alive, and the client's own once-a-minute
    pace is not something the server relies on."""
    settings = get_settings()
    redis = get_redis_client()
    previous = _parse(redis.get(_key(pro_user_id)))
    now = time.time()
    if previous is not None and now - previous[0] < settings.presence_heartbeat_min_interval_seconds:
        return False
    profile = db.get(ProProfile, pro_user_id)
    visible = bool(profile is not None and profile.presence_visible)
    redis.set(_key(pro_user_id), json.dumps({"ts": now, "visible": visible}), ex=settings.presence_window_seconds)
    return True


def clear(pro_user_id: uuid.UUID) -> None:
    """The app went to the background: offline now, not in five minutes."""
    get_redis_client().delete(_key(pro_user_id))


def copy_visibility_to_key(pro_user_id: uuid.UUID, visible: bool) -> None:
    """After ProProfile.presence_visible is committed - never before, so the
    copy cannot get ahead of the truth - put it into a live key at once,
    keeping the key's remaining time: hiding neither extends nor ends
    presence."""
    redis = get_redis_client()
    current = _parse(redis.get(_key(pro_user_id)))
    if current is not None:
        redis.set(_key(pro_user_id), json.dumps({"ts": current[0], "visible": visible}), keepttl=True)


def photographer_is_online(db: Session, pro_user_id: uuid.UUID) -> bool:
    """Around right now, whatever clients are shown. False if Redis cannot
    say - the assistant then answers at once rather than waiting for someone
    who may not be there."""
    try:
        current = _parse(get_redis_client().get(_key(pro_user_id)))
    except Exception:
        logger.warning("presence_lookup_failed", exc_info=True)
        return False
    return current is not None and _fresh(current[0])


def seen_within(pro_user_id: uuid.UUID, seconds: int) -> bool:
    """The app checked in within the last `seconds` - for "available now",
    which needs fresher presence than the dot. Visibility does not matter
    here. False if Redis cannot say."""
    try:
        current = _parse(get_redis_client().get(_key(pro_user_id)))
    except Exception:
        logger.warning("presence_lookup_failed", exc_info=True)
        return False
    return current is not None and time.time() - current[0] <= seconds


def shown_online(pro_user_ids: Iterable) -> set[str]:
    """Of these photographers, the ones a client should see a dot for: online
    and visible. One round trip for the whole screen. If the lookup fails,
    nobody - a missing dot is harmless, a wrong one is not, and a screen of
    cards must not fail for it."""
    ids = list(dict.fromkeys(str(i) for i in pro_user_ids))
    if not ids:
        return set()
    try:
        values = _mget([_key(i) for i in ids])
    except Exception:
        logger.warning("presence_lookup_failed", exc_info=True)
        return set()
    shown = set()
    for pro_id, raw in zip(ids, values):
        current = _parse(raw)
        if current is not None and current[1] and _fresh(current[0]):
            shown.add(pro_id)
    return shown
