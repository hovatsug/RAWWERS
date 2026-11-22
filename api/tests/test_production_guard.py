"""Production refuses to start with unsafe settings (core/production_guard.py).

One clean production environment (tests/production_env.py) passes; each case
changes one value and must produce its own plain-words refusal. The API and a
Celery process are also started for real, in a subprocess, to prove the
refusal stops them and the clean boot does not.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys

import pytest

from app.core.config import Settings
from app.core.production_guard import ProductionSettingsError, enforce_production_settings, production_problems
from tests.production_env import GOOD_PRODUCTION

API_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


@pytest.fixture(autouse=True)
def _no_inherited_settings(monkeypatch):
    """Only what each test passes counts: the test container inherits a
    development .env (CORS_ALLOW_ORIGINS, EMAIL_SENDING_ENABLED, MUX_FAKE...),
    which would otherwise fill a value a test removed on purpose."""
    for key in (*GOOD_PRODUCTION, "API_DOCS_ENABLED", "TRUSTED_PROXY_HOPS"):
        monkeypatch.delenv(key, raising=False)


def _settings(**changes: str | None) -> Settings:
    env = {**GOOD_PRODUCTION}
    for key, value in changes.items():
        if value is None:
            env.pop(key, None)
        else:
            env[key] = value
    return Settings(_env_file=None, **env)


def test_the_clean_production_settings_pass():
    assert production_problems(_settings()) == []
    enforce_production_settings(_settings())


def test_nothing_is_checked_outside_production():
    enforce_production_settings(_settings(APP_ENV="development", AUTH_JWT_SECRET="short", MUX_FAKE="true"))


REFUSALS = [
    ("short JWT secret", {"AUTH_JWT_SECRET": "a1b2" * 7}, "AUTH_JWT_SECRET is shorter than 32 bytes"),
    ("dev JWT secret", {"AUTH_JWT_SECRET": "dev-insecure-auth-secret"}, "AUTH_JWT_SECRET is a development default"),
    ("empty JWT secret", {"AUTH_JWT_SECRET": ""}, "AUTH_JWT_SECRET is empty"),
    ("dev pepper", {"RISK_IP_HASH_PEPPER": "dev-risk-ip-pepper"}, "RISK_IP_HASH_PEPPER is a development default"),
    ("placeholder pepper", {"MEDIA_SHARE_TOKEN_PEPPER": "change-me"}, "MEDIA_SHARE_TOKEN_PEPPER is a development default"),
    ("e2e admin key", {"ADMIN_API_KEYS": "e2e-admin-key"}, "ADMIN_API_KEYS is a development default"),
    ("short admin key", {"ADMIN_API_KEYS": "9f" * 8}, "ADMIN_API_KEYS holds a key shorter than 32 bytes"),
    ("no address key", {"ADDRESS_ENCRYPTION_KEYS": ""}, "ADDRESS_ENCRYPTION_KEYS is empty"),
    ("bad address key", {"ADDRESS_ENCRYPTION_KEYS": "ab" * 20}, "ADDRESS_ENCRYPTION_KEYS is not a valid key"),
    ("dev unsubscribe key", {"UNSUBSCRIBE_SIGNING_KEYS": "k1:dev-unsubscribe"}, "UNSUBSCRIBE_SIGNING_KEYS is a development default"),
    ("no Stripe key", {"STRIPE_SECRET_KEY": ""}, "STRIPE_SECRET_KEY is empty"),
    ("placeholder Stripe key", {"STRIPE_SECRET_KEY": "sk_test_dummy"}, "STRIPE_SECRET_KEY is a development default"),
    ("no Stripe webhook secret", {"STRIPE_WEBHOOK_SECRET": ""}, "STRIPE_WEBHOOK_SECRET is empty"),
    ("R2 test key", {"R2_ACCESS_KEY_ID": "test"}, "R2_ACCESS_KEY_ID is a development default"),
    ("default database password", {"DATABASE_URL": "postgresql+psycopg2://postgres:postgres@postgres:5432/rawwers"}, "The database password"),
    ("no database password", {"DATABASE_URL": "postgresql+psycopg2://postgres@postgres:5432/rawwers"}, "The database password"),
    ("debug logging", {"LOG_LEVEL": "DEBUG"}, "LOG_LEVEL is DEBUG"),
    ("auth bypass", {"AUTH_DEV_BYPASS": "true"}, "AUTH_DEV_BYPASS is on"),
    ("unsigned Stripe events", {"STRIPE_WEBHOOK_ALLOW_UNVERIFIED": "true"}, "STRIPE_WEBHOOK_ALLOW_UNVERIFIED is on"),
    ("unverified pros", {"ALLOW_UNVERIFIED_PRO": "true"}, "ALLOW_UNVERIFIED_PRO is on"),
    ("email off (console)", {"EMAIL_SENDING_ENABLED": "false"}, "Email would go to the console"),
    ("email unset (console)", {"EMAIL_SENDING_ENABLED": None}, "Email would go to the console"),
    ("live Stripe in test mode", {"STRIPE_SECRET_KEY": "sk_live_" + "0d" * 16}, "STRIPE_SECRET_KEY is a LIVE key but DEPLOYMENT_MODE is test"),
    ("live restricted key in test mode", {"STRIPE_SECRET_KEY": "rk_live_" + "0d" * 16}, "LIVE key"),
    ("live Stripe, mode unset", {"DEPLOYMENT_MODE": None, "STRIPE_SECRET_KEY": "sk_live_" + "0d" * 16}, "LIVE key"),
    ("test Stripe in live mode", {"DEPLOYMENT_MODE": "live"}, "DEPLOYMENT_MODE is live but STRIPE_SECRET_KEY is a test key"),
    ("unknown mode", {"DEPLOYMENT_MODE": "staging"}, "DEPLOYMENT_MODE must be test or live"),
    ("fake Mux", {"MUX_FAKE": "true"}, "MUX_FAKE is on"),
    ("API docs", {"API_DOCS_ENABLED": "true"}, "API_DOCS_ENABLED is on"),
    ("CORS wildcard", {"CORS_ALLOW_ORIGINS": "*"}, "CORS_ALLOW_ORIGINS allows any origin"),
    ("CORS wildcard among others", {"CORS_ALLOW_ORIGINS": "https://admin.rawwers.com,*"}, "allows any origin"),
    ("CORS http", {"CORS_ALLOW_ORIGINS": "http://localhost:3000"}, "non-https origin"),
    ("CORS unset", {"CORS_ALLOW_ORIGINS": None}, "CORS_ALLOW_ORIGINS is not set"),
    ("http app URL", {"APP_PUBLIC_URL": "http://localhost:3000"}, "APP_PUBLIC_URL must be a public https address"),
    ("no trusted proxies", {"TRUSTED_PROXY_IPS": ""}, "TRUSTED_PROXY_IPS is empty"),
    ("Cloudflare ranges missing", {"CLOUDFLARE_IPS_FILE": "/nonexistent/cloudflare.txt"}, "TRUST_CLOUDFLARE is on but"),
]


@pytest.mark.parametrize("changes,expected", [(c, e) for _, c, e in REFUSALS], ids=[name for name, _, _ in REFUSALS])
def test_each_unsafe_setting_is_refused_in_plain_words(changes, expected):
    problems = production_problems(_settings(**changes))
    assert any(expected in p for p in problems), problems
    with pytest.raises(ProductionSettingsError) as refused:
        enforce_production_settings(_settings(**changes))
    assert "refuses to start in production" in str(refused.value)
    assert expected in str(refused.value)


def test_email_on_without_a_brevo_key_is_refused_even_earlier():
    # The settings themselves refuse it (config.py, _production_email_is_complete).
    with pytest.raises(ValueError, match="BREVO_API_KEY is not set"):
        _settings(BREVO_API_KEY="")


def test_missing_mux_keys_do_not_stop_production():
    s = _settings(MUX_TOKEN_ID="", MUX_TOKEN_SECRET="", MUX_WEBHOOK_SECRET="", MUX_SIGNING_KEY_ID="", MUX_SIGNING_KEY_PRIVATE="")
    assert production_problems(s) == []


def test_every_problem_is_listed_at_once():
    problems = production_problems(_settings(AUTH_JWT_SECRET="short", MUX_FAKE="true", CORS_ALLOW_ORIGINS="*"))
    assert len(problems) >= 3


def test_live_mode_with_a_live_key_passes():
    assert production_problems(_settings(DEPLOYMENT_MODE="live", STRIPE_SECRET_KEY="sk_live_" + "0d" * 16)) == []


# --- the real processes ------------------------------------------------------

_ROUTES = (
    "import json, app.main as m; "
    "print(json.dumps(sorted(getattr(r, 'path', '') for r in m.app.routes)))"
)


def _run(env_changes: dict[str, str], code: str) -> subprocess.CompletedProcess:
    env = {**os.environ, **GOOD_PRODUCTION, **env_changes}
    return subprocess.run([sys.executable, "-c", code], env=env, capture_output=True, text=True, cwd=API_DIR, timeout=900)


def test_the_api_starts_with_clean_production_settings_and_serves_no_docs():
    done = _run({}, _ROUTES)
    assert done.returncode == 0, done.stderr[-2000:]
    routes = set(json.loads(done.stdout.strip().splitlines()[-1]))
    assert "/healthz" in routes
    assert not {"/docs", "/redoc", "/openapi.json"} & routes


def test_the_api_refuses_to_start_and_says_why():
    done = _run({"AUTH_JWT_SECRET": "too-short-secret"}, _ROUTES)
    assert done.returncode != 0
    assert "RAWWERS api refuses to start in production" in done.stderr
    assert "AUTH_JWT_SECRET is shorter than 32 bytes" in done.stderr


def test_a_celery_worker_refuses_to_start_and_says_why():
    done = _run({"MUX_FAKE": "true"}, "import app.tasks.celery_app")
    assert done.returncode != 0
    assert "RAWWERS worker refuses to start in production" in done.stderr
    assert "MUX_FAKE is on" in done.stderr


def test_a_celery_worker_starts_with_clean_production_settings():
    done = _run({}, "import app.worker; print('ok')")
    assert done.returncode == 0, done.stderr[-2000:]


def test_metrics_are_not_served_in_production(monkeypatch, client):
    from app.core.config import get_settings

    assert client.get("/metrics").status_code == 200
    monkeypatch.setattr(get_settings(), "app_env", "production")
    assert client.get("/metrics").status_code == 404


def test_healthz_names_the_running_release(monkeypatch, client):
    from app.core.config import get_settings

    monkeypatch.setattr(get_settings(), "sentry_release", "abc1234")
    assert client.get("/healthz").json() == {"status": "ok", "release": "abc1234"}
