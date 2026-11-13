"""An unhandled error: a 500 that carries the request id (header and body) and
says nothing about the cause, and one Sentry event tagged with the request id
(core/middleware.py RequestContextMiddleware, core/errors.py
internal_error_response)."""
import pytest

from app.core import sentry
from app.core.config import get_settings

# What an exception message can drag along: SQL, a file path, an address, a token.
LEAKY = (
    'SELECT * FROM user_account WHERE email = \'ana@example.com\' '
    'File "/repo/api/app/api/v1/discovery.py", line 96 '
    "Bearer eyJhbGciOi.eyJzdWIiOi.c2lnbmF0dXJl code=482913"
)


@pytest.fixture
def crashing_route(monkeypatch):
    def _boom(_db):
        raise RuntimeError(LEAKY)

    monkeypatch.setattr("app.api.v1.discovery.ensure_initial_niches", _boom)
    # A search cached by an earlier test would answer without reaching _boom.
    monkeypatch.setattr("app.api.v1.discovery.cache_get_json", lambda _key: None)
    return "/v1/discover/pros"


@pytest.fixture
def sentry_events(monkeypatch):
    """A real Sentry client whose transport collects the events instead of sending them."""
    import sentry_sdk

    sent = []
    real_init = sentry_sdk.init

    def init_with_capture(**kwargs):
        kwargs["transport"] = sent.append
        return real_init(**kwargs)

    monkeypatch.setattr(get_settings(), "sentry_dsn", "https://public@o0.ingest.de.sentry.io/0")
    monkeypatch.setattr(sentry, "_initialised", False)
    monkeypatch.setattr(sentry_sdk, "init", init_with_capture)
    assert sentry.init_sentry("api") is True
    try:
        yield sent
    finally:
        sentry_sdk.get_client().close()
        monkeypatch.setattr(sentry, "_initialised", False)


def test_a_500_carries_the_request_id_and_nothing_about_the_cause(client, crashing_route):
    resp = client.get(crashing_route, headers={"X-Request-Id": "req-500-1"})

    assert resp.status_code == 500
    assert resp.headers.get("x-request-id") == "req-500-1"
    assert resp.json() == {
        "error": {"code": "internal_error", "message": "Internal server error", "details": {"request_id": "req-500-1"}}
    }
    for leak in ("SELECT", "user_account", "ana@example.com", "/repo", ".py", "Traceback", "RuntimeError", "eyJ", "482913"):
        assert leak not in resp.text, leak


def test_a_500_without_a_request_id_gets_a_fresh_one_in_both_places(client, crashing_route):
    resp = client.get(crashing_route)
    assert resp.status_code == 500
    rid = resp.headers.get("x-request-id")
    assert rid and resp.json()["error"]["details"]["request_id"] == rid


def test_the_crash_event_is_tagged_with_the_request_id_and_scrubbed(client, crashing_route, sentry_events):
    import sentry_sdk

    resp = client.get(crashing_route, headers={"X-Request-Id": "req-500-2"})
    sentry_sdk.flush()

    assert resp.status_code == 500
    assert len(sentry_events) == 1, [e.get("message") or e.get("logentry") for e in sentry_events]
    event = sentry_events[0]
    assert event["tags"]["request_id"] == "req-500-2"
    assert event["tags"]["component"] == "api"
    text = repr(event)
    for secret in ("ana@example.com", "eyJhbGciOi.eyJzdWIiOi.c2lnbmF0dXJl"):
        assert secret not in text, secret
