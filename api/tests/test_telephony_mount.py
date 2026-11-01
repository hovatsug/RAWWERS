"""The telephony webhook is not mounted in production unless a real provider is set up.

Owner's decision (2026-11-01): keep the phone-call follow-up code, but do not
mount `POST /v1/webhooks/telephony` in production unless a real provider is
configured. With the mock provider (the default) the webhook checks no
signature, so anyone who knew a call's id could set its status. A real
provider is any TELEPHONY_PROVIDER other than `mock`, together with the
TELEPHONY_WEBHOOK_SECRET its signature is checked against.

The route table is built when the app is imported, so production is checked
in a fresh interpreter rather than by changing settings in this one.
"""
import json
import os
import subprocess
import sys
from types import SimpleNamespace

import pytest

from app.services.telephony import telephony_webhook_mounted

WEBHOOK = "/v1/webhooks/telephony"


def _settings(app_env="production", provider="mock", secret=""):
    return SimpleNamespace(app_env=app_env, telephony_provider=provider, telephony_webhook_secret=secret)


@pytest.mark.parametrize(
    ("app_env", "provider", "secret", "mounted"),
    [
        ("production", "mock", "", False),
        ("prod", "mock", "", False),
        ("Production", " Mock ", "", False),
        ("production", " Mock ", "a-secret", False),
        ("production", "mock", "a-secret", False),
        ("production", "generic", "", False),
        ("production", "generic", "a-secret", True),
        ("development", "mock", "", True),
        ("test", "mock", "", True),
    ],
)
def test_mounted_outside_production_or_with_a_real_provider(app_env, provider, secret, mounted):
    assert telephony_webhook_mounted(_settings(app_env, provider, secret)) is mounted


def _routes_in(env: dict) -> set[str]:
    script = "import json; from app.main import app; print(json.dumps(sorted({getattr(r, 'path', '') for r in app.routes})))"
    done = subprocess.run(
        [sys.executable, "-c", script],
        env={**os.environ, **env},
        capture_output=True,
        text=True,
        cwd=os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        timeout=120,
    )
    assert done.returncode == 0, done.stderr[-2000:]
    return set(json.loads(done.stdout.strip().splitlines()[-1]))


PRODUCTION = {
    "APP_ENV": "production",
    "CONNECT_RETURN_URL": "https://api.example.test/v1/payouts/connect/return",
    "CONNECT_REFRESH_URL": "https://api.example.test/v1/payouts/connect/refresh",
    # Production refuses to start with the admin routes open; any value will
    # do for listing routes.
    "ADMIN_API_KEYS": "test-only-placeholder",
}


def test_production_with_the_mock_provider_has_no_webhook_route():
    routes = _routes_in({**PRODUCTION, "TELEPHONY_PROVIDER": "mock", "TELEPHONY_WEBHOOK_SECRET": ""})
    assert WEBHOOK not in routes
    # The rest of the phone-call channel stays.
    assert any(r.startswith("/v1/calls") for r in routes)


def test_production_with_a_real_provider_has_the_webhook_route():
    routes = _routes_in({**PRODUCTION, "TELEPHONY_PROVIDER": "generic", "TELEPHONY_WEBHOOK_SECRET": "a-secret"})
    assert WEBHOOK in routes


def test_development_keeps_the_webhook_for_the_mock_flow():
    # The app under test is development: the mock call flow still uses it.
    from app.main import app

    assert WEBHOOK in {getattr(r, "path", "") for r in app.routes}
