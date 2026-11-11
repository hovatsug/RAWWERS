"""Error reporting (core/sentry.py): off without a DSN, and nothing personal
or secret leaves in an event."""
from app.core import sentry
from app.core.config import get_settings
from app.core.request_context import clear_request_context, set_request_context


def test_without_a_dsn_nothing_is_initialised(monkeypatch):
    monkeypatch.setattr(get_settings(), "sentry_dsn", "")
    monkeypatch.setattr(sentry, "_initialised", False)
    assert sentry.init_sentry("api") is False
    assert sentry.sentry_enabled() is False
    # The capture helpers are no-ops, never errors.
    sentry.capture_message("x")
    sentry.capture_exception(RuntimeError("x"))


def test_an_event_is_scrubbed_and_tagged_with_the_request_id():
    set_request_context(request_id="req-123")
    try:
        event = {
            "message": "failed for ana@example.com with Bearer eyJhbGciOi.eyJzdWIiOi.c2lnbmF0dXJl",
            "request": {
                "url": "https://api.rawwers.com/v1/email/unsubscribe?u=1&t=all&k=k1&s=abcdef",
                "query_string": "u=1&t=all&k=k1&s=abcdef",
                "headers": {
                    "Authorization": "Bearer abc.def.ghi",
                    "Cookie": "rw_sid=1",
                    "X-Admin-Api-Key": "admin-key",
                    "Stripe-Signature": "t=1,v1=xyz",
                    "User-Agent": "RAWWERS/1.0",
                },
                "cookies": {"rw_sid": "1"},
                "data": {"email": "ana@example.com", "password": "hunter2", "code": "482913", "display_name": "Ana"},
            },
            "user": {"id": "u-1", "email": "ana@example.com", "ip_address": "203.0.113.9"},
            "extra": {"payload": {"email": "ana@example.com", "code": "771204"}, "outbox_id": "o-1"},
            "breadcrumbs": {"values": [{"message": "sent to bob@example.com", "data": {"token": "t"}}]},
            "tags": {"component": "api"},
        }
        out = sentry.scrub_event(event)
    finally:
        clear_request_context()

    text = repr(out)
    for secret in ("ana@example.com", "bob@example.com", "hunter2", "482913", "771204", "admin-key", "abc.def.ghi", "abcdef", "203.0.113.9", "v1=xyz", "rw_sid"):
        assert secret not in text, secret
    assert out["user"] == {"id": "u-1"}
    assert out["request"]["headers"]["User-Agent"] == "RAWWERS/1.0"
    assert out["request"]["data"]["display_name"] == "Ana"
    assert out["extra"]["outbox_id"] == "o-1"
    assert "u=1" in out["request"]["query_string"]
    assert out["tags"] == {"component": "api", "request_id": "req-123"}


def test_a_raw_body_is_dropped_whole():
    out = sentry.scrub_event({"request": {"data": '{"password": "x"}'}})
    assert out["request"]["data"] == sentry.FILTERED


def test_with_a_dsn_events_are_scrubbed_and_tagged_end_to_end(monkeypatch):
    """A real client, with its transport replaced: what would be sent."""
    import sentry_sdk

    sent = []
    real_init = sentry_sdk.init

    def init_with_capture(**kwargs):
        kwargs["transport"] = sent.append  # each event, as it would leave
        return real_init(**kwargs)

    monkeypatch.setattr(get_settings(), "sentry_dsn", "https://public@o0.ingest.de.sentry.io/0")
    monkeypatch.setattr(sentry, "_initialised", False)
    monkeypatch.setattr(sentry_sdk, "init", init_with_capture)
    try:
        assert sentry.init_sentry("worker") is True
        set_request_context(request_id="req-456")
        try:
            raise RuntimeError("could not mail ana@example.com")
        except RuntimeError as exc:
            sentry.capture_exception(exc)
        sentry_sdk.flush()
    finally:
        clear_request_context()
        sentry_sdk.get_client().close()
        monkeypatch.setattr(sentry, "_initialised", False)

    assert len(sent) == 1
    event = sent[0]
    assert event["tags"]["component"] == "worker" and event["tags"]["request_id"] == "req-456"
    assert "ana@example.com" not in repr(event)
    assert event["exception"]["values"][0]["value"] == "could not mail [email]"
