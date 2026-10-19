"""Wake the process before it takes traffic.

A fresh process answered its first Discover request in about 0.9 s against
50 ms warm: ORM mapper configuration, the first database and Redis
connections, the middleware stack and the home path's first queries all
happened inside that request. Run once at startup, these steps do it
instead.

Never at the cost of starting. Every step is fail-soft - a failure is
logged and the next step runs - and the whole is bounded by a budget: a
step still running when it is spent is left behind, marked "timed out".
The home request comes from a fixed warm-up viewer with no account, and
writes nothing. It counts once against that viewer's read limit.
"""
from __future__ import annotations

import asyncio
import logging
import threading
import time
import uuid
from collections.abc import Callable

import httpx
from sqlalchemy import text
from sqlalchemy.orm import configure_mappers

from app.core.config import get_settings
from app.db.session import ReplicaSessionLocal, SessionLocal
from app.services.cache import get_redis_client

logger = logging.getLogger(__name__)

DEFAULT_BUDGET_SECONDS = 10.0
#: Who the warm-up's home request comes from. No account has this id; the
#: request reads, and the tests hold that it writes nothing.
WARMUP_VIEWER_ID = uuid.UUID("00000000-0000-0000-0000-000000000002")


def _configure_mappers() -> None:
    configure_mappers()


def _select_one(session_factory) -> None:
    db = session_factory()
    try:
        db.execute(text("SELECT 1"))
    finally:
        db.close()


def _primary_db() -> None:
    _select_one(SessionLocal)


def _replica_db() -> str | None:
    if ReplicaSessionLocal is None:
        return "not configured"
    _select_one(ReplicaSessionLocal)
    return None


def _redis() -> None:
    get_redis_client().ping()


async def _in_thread(step: Callable):
    """Run a blocking step on a daemon thread of its own. Not the loop's
    executor: one that overruns is left behind, and nothing - shutting the
    loop down included - waits for it."""
    loop = asyncio.get_running_loop()
    done: asyncio.Future = loop.create_future()

    def settle(outcome, error):
        if done.done():
            return
        if error is not None:
            done.set_exception(error)
        else:
            done.set_result(outcome)

    def run():
        try:
            result = (step(), None)
        except Exception as exc:
            result = (None, exc)
        try:
            loop.call_soon_threadsafe(settle, *result)
        except RuntimeError:  # the loop is gone: nobody is waiting any more
            pass

    threading.Thread(target=run, name="startup-warmup", daemon=True).start()
    return await done


async def warm_up(app, *, budget_seconds: float = DEFAULT_BUDGET_SECONDS) -> dict[str, str]:
    """Run each step in turn within the budget. Returns what each did:
    "ok", a note, "failed: ...", "timed out" or "skipped" (budget spent)."""
    settings = get_settings()
    deadline = time.monotonic() + budget_seconds
    report: dict[str, str] = {}

    async def home() -> str:
        # As the warm-up's own viewer, not a guest: where guests may not
        # browse, a guest's request is refused before any row is read and
        # warms nothing. Safe to set on the app: nothing else is served
        # during startup, and the previous value is put back.
        from app.api.deps import get_optional_current_user
        from app.models.admin import UserRoleType
        from app.schemas.media import CurrentUser

        previous = app.dependency_overrides.get(get_optional_current_user)
        app.dependency_overrides[get_optional_current_user] = lambda: CurrentUser(
            user_id=WARMUP_VIEWER_ID, roles=[UserRoleType.client]
        )
        try:
            transport = httpx.ASGITransport(app=app)
            async with httpx.AsyncClient(transport=transport, base_url="http://warmup") as client:
                resp = await client.get(
                    "/v1/client/home",
                    params={"country": settings.warmup_home_country, "city": settings.warmup_home_city},
                    headers={"User-Agent": "rawwers-startup-warmup"},
                )
        finally:
            if previous is None:
                app.dependency_overrides.pop(get_optional_current_user, None)
            else:
                app.dependency_overrides[get_optional_current_user] = previous
        return f"http {resp.status_code}"

    steps: list[tuple[str, Callable]] = [
        ("mappers", _configure_mappers),
        ("primary_db", _primary_db),
        ("replica_db", _replica_db),
        ("redis", _redis),
    ]
    started = time.monotonic()
    for name, step in [*steps, ("home", None)]:
        left = deadline - time.monotonic()
        if left <= 0:
            report[name] = "skipped"
            continue
        step_started = time.monotonic()
        try:
            if name == "home":
                note = await asyncio.wait_for(home(), timeout=left)
            else:
                note = await asyncio.wait_for(_in_thread(step), timeout=left)
            report[name] = note or "ok"
        except asyncio.TimeoutError:
            report[name] = "timed out"
        except Exception as exc:  # fail-soft: startup goes on
            report[name] = f"failed: {type(exc).__name__}: {exc}"[:200]
        report[f"{name}_ms"] = str(round((time.monotonic() - step_started) * 1000))
    report["total_ms"] = str(round((time.monotonic() - started) * 1000))
    logger.info("startup_warmup", extra={"warmup": report})
    return report
