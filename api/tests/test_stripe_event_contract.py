"""Every Stripe event the webhook handles is one Stripe really sends.

The handler acted on "refund.succeeded" and "transfer.failed". Neither
exists - Stripe's own list of webhook events has neither - so the code
behind them never ran, while the tests that fed them passed. This holds the
handler to events captured from Stripe (tests/fixtures/stripe): a name not
in the capture fails here until a real event of that type is captured.

The endpoint is registered pinned to our API version, so what Stripe sends
matches what our calls ask for; an event in any other version is logged.
"""
import inspect
import json
import logging
import re
from pathlib import Path

from app.api.v1 import webhooks
from app.core.config import get_settings

CAPTURE = json.loads((Path(__file__).parent / "fixtures" / "stripe" / "captured_events.json").read_text())
NEVER_SENT = {"refund.succeeded", "transfer.failed"}


def _names_the_handler_compares() -> set[str]:
    source = inspect.getsource(webhooks._apply_stripe_event)
    names: set[str] = set()
    for line in source.splitlines():
        if "event_type" in line and ("==" in line or " in " in line):
            names |= set(re.findall(r'"([a-z_]+(?:\.[a-z_]+)+)"', line))
    return names


def test_every_event_the_handler_names_is_declared():
    assert _names_the_handler_compares() <= webhooks.HANDLED_STRIPE_EVENTS


def test_every_declared_event_was_captured_from_stripe():
    missing = webhooks.HANDLED_STRIPE_EVENTS - set(CAPTURE["event_types"])
    assert not missing, f"handled but never captured from Stripe: {sorted(missing)}"


def test_events_stripe_never_sends_are_not_handled():
    assert not (NEVER_SENT & webhooks.HANDLED_STRIPE_EVENTS)
    assert not (NEVER_SENT & _names_the_handler_compares())


def test_every_refund_event_routes_to_the_reconciler():
    from app.services.refund_reconcile import REFUND_EVENT_TYPES

    assert REFUND_EVENT_TYPES <= webhooks.HANDLED_STRIPE_EVENTS
    assert REFUND_EVENT_TYPES <= set(CAPTURE["event_types"])


def test_the_endpoint_is_registered_pinned_to_our_api_version():
    from scripts.register_stripe_webhook import endpoint_params

    platform = endpoint_params("https://api.example.test/v1/webhooks/stripe", connect=False)
    connect = endpoint_params("https://api.example.test/v1/webhooks/stripe", connect=True)

    assert platform["api_version"] == connect["api_version"] == get_settings().stripe_api_version
    assert set(platform["enabled_events"]) | set(connect["enabled_events"]) == webhooks.HANDLED_STRIPE_EVENTS
    assert connect["connect"] is True and set(connect["enabled_events"]) == webhooks.CONNECT_STRIPE_EVENTS


def test_an_event_in_another_api_version_is_logged(client, monkeypatch, caplog):
    sample = json.loads(json.dumps(CAPTURE["samples"]["payment_intent.created"]))
    sample["api_version"] = "2099-01-01"
    monkeypatch.setattr("app.api.v1.webhooks.construct_stripe_event", lambda raw, sig: sample)

    with caplog.at_level(logging.WARNING):
        resp = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "sig"})

    assert resp.status_code == 200
    assert any("stripe_event_api_version_mismatch" in r.getMessage() for r in caplog.records)


def _signed(body: bytes, secret: str) -> str:
    import hashlib
    import hmac
    import time

    ts = int(time.time())
    mac = hmac.new(secret.encode(), f"{ts}.".encode() + body, hashlib.sha256).hexdigest()
    return f"t={ts},v1={mac}"


def test_each_endpoint_has_its_own_secret_and_both_verify(monkeypatch):
    """The platform and Connect endpoints sign with different secrets; one
    configured secret would refuse every Connect event."""
    from app.core.errors import APIError
    from app.services import stripe_service

    monkeypatch.setattr(stripe_service.settings, "stripe_webhook_secret", "whsec_platform, whsec_connect")
    body = json.dumps(CAPTURE["samples"]["account.updated"]).encode()

    assert stripe_service.construct_stripe_event(body, _signed(body, "whsec_connect"))["type"] == "account.updated"
    assert stripe_service.construct_stripe_event(body, _signed(body, "whsec_platform"))["type"] == "account.updated"
    try:
        stripe_service.construct_stripe_event(body, _signed(body, "whsec_someone_else"))
    except APIError as exc:
        assert exc.code == "invalid_signature"
    else:
        raise AssertionError("an unknown secret must be refused")
