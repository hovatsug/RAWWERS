"""The first client after a deploy no longer pays for the process waking up.

A fresh process answered its first Discover request in about 0.9 s against
50 ms warm: ORM mapper configuration, the first database and Redis
connections, the middleware stack and the home path's first queries all
happened inside that request. Startup now does them before the server takes
traffic. Never at the cost of starting: each step is fail-soft, the whole
is bounded by a time budget, and a step that fails or overruns is logged
and skipped.
"""
import asyncio
import time

import pytest
from app.core.config import get_settings
from app.db.base import Base
from app.services import warmup
from fastapi.testclient import TestClient
from sqlalchemy import func, select


def _rows(db_session) -> int:
    return sum(db_session.execute(select(func.count()).select_from(t)).scalar_one() for t in Base.metadata.sorted_tables)


def _run(**kwargs) -> dict:
    from app.main import app

    return asyncio.run(warmup.warm_up(app, **kwargs))


def test_it_opens_the_connections_and_answers_one_home_request(db_session):
    report = _run()

    assert report["mappers"] == "ok"
    assert report["primary_db"] == "ok"
    assert report["redis"] == "ok"
    assert report["replica_db"] in ("ok", "not configured")
    assert report["home"].startswith("http "), report
    assert int(report["home"].split()[1]) < 500, report


def test_it_writes_nothing(db_session):
    before = _rows(db_session)

    _run()

    db_session.expire_all()
    assert _rows(db_session) == before


def test_a_failing_step_never_stops_startup(db_session, monkeypatch):
    def down():
        raise ConnectionError("redis is down")

    monkeypatch.setattr(warmup, "get_redis_client", down)

    report = _run()

    assert report["redis"].startswith("failed"), report
    assert report["primary_db"] == "ok", "the other steps still ran"


def test_the_whole_is_bounded_by_a_budget(db_session, monkeypatch):
    monkeypatch.setattr(warmup, "_configure_mappers", lambda: time.sleep(3))

    started = time.monotonic()
    report = _run(budget_seconds=0.5)

    assert time.monotonic() - started < 2.5
    assert report["mappers"] == "timed out", report


@pytest.mark.parametrize("enabled", [True, False])
def test_the_app_runs_it_at_startup_only_when_enabled(monkeypatch, enabled):
    from app.main import app

    calls = []

    async def fake(app_, **_kwargs):
        calls.append(app_)
        return {}

    monkeypatch.setattr(warmup, "warm_up", fake)
    monkeypatch.setattr(get_settings(), "startup_warmup", enabled)

    with TestClient(app):
        pass

    assert calls == ([app] if enabled else [])


def test_the_primary_database_is_really_asked(db_session, monkeypatch):
    from app.db.session import SessionLocal

    asked = []

    def recording():
        session = SessionLocal()
        real = session.execute

        def execute(statement, *args, **kwargs):
            asked.append(str(statement))
            return real(statement, *args, **kwargs)

        session.execute = execute
        return session

    monkeypatch.setattr(warmup, "SessionLocal", recording)

    assert _run()["primary_db"] == "ok"
    assert asked == ["SELECT 1"]
