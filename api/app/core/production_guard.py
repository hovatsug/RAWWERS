"""What production refuses to start with.

In production (`APP_ENV=production`) the API, the Celery workers and beat
check their settings before doing anything and stop, with every problem
listed in plain words, when one of these is true:

- a secret is empty, a development default, or a placeholder ("change-me");
- `AUTH_JWT_SECRET` is shorter than 32 bytes;
- a debug or bypass switch is on (DEBUG logging, `AUTH_DEV_BYPASS`,
  `STRIPE_WEBHOOK_ALLOW_UNVERIFIED`, `ALLOW_UNVERIFIED_PRO`);
- the database password is a default;
- email would go to the console instead of Brevo (sending off, or no key);
- Stripe has no key, or its key does not match `DEPLOYMENT_MODE` (a live key
  in a test deployment, or a test key in a live one);
- the development fake Mux (`MUX_FAKE`) is on;
- the interactive API docs are switched on (`API_DOCS_ENABLED`);
- CORS allows any origin, a plain-http origin, or is not set at all;
- the public URLs are not https;
- `TRUSTED_PROXY_IPS` is empty, so every visitor would share Caddy's address
  and its rate limits.

Missing Mux keys are NOT a problem: the video then answers "Video is not
available right now" (services/presentation_video.py).

Outside production nothing here runs. docs/DEPLOY_RUNBOOK.md says how to
generate each value.
"""
from __future__ import annotations

import sys
from urllib.parse import urlsplit

from app.core.config import Settings, get_settings

#: Values from this repository's dev, test and CI settings, and the usual
#: placeholders. Compared lower-cased.
KNOWN_DEV_VALUES = frozenset(
    {
        "dev-insecure-auth-secret",
        "dev-media-share-pepper",
        "dev-media-ip-pepper",
        "dev-share-fingerprint-pepper",
        "dev-risk-ip-pepper",
        "dev-risk-device-pepper",
        "dev-risk-session-pepper",
        "e2e-insecure-secret",
        "e2e-admin-key",
        "test",
        "dummy",
        "secret",
        "password",
        "changeme",
        "change-me",
        "change_me",
        "postgres",
        "rawwers",
        "admin",
    }
)
PLACEHOLDER_MARKS = ("change-me", "change_me", "changeme", "placeholder", "<", ">", "example", "dummy", "insecure")
DEV_PREFIXES = ("dev-", "e2e-", "test-")

#: Secrets that must be set, each with how to make one.
REQUIRED_SECRETS: tuple[tuple[str, str, str], ...] = (
    ("AUTH_JWT_SECRET", "auth_jwt_secret", "openssl rand -hex 32"),
    ("MEDIA_SHARE_TOKEN_PEPPER", "media_share_token_pepper", "openssl rand -hex 32"),
    ("MEDIA_ACCESS_IP_HASH_PEPPER", "media_access_ip_hash_pepper", "openssl rand -hex 32"),
    ("SHARE_VIEW_FINGERPRINT_PEPPER", "share_view_fingerprint_pepper", "openssl rand -hex 32"),
    ("RISK_IP_HASH_PEPPER", "risk_ip_hash_pepper", "openssl rand -hex 32"),
    ("RISK_DEVICE_HASH_PEPPER", "risk_device_hash_pepper", "openssl rand -hex 32"),
    ("RISK_SESSION_HASH_PEPPER", "risk_session_hash_pepper", "openssl rand -hex 32"),
    ("ADMIN_API_KEYS", "admin_api_keys", "openssl rand -hex 32"),
    ("ADDRESS_ENCRYPTION_KEYS", "address_encryption_keys", "deploy/scripts/generate-secrets.sh prints one"),
    ("UNSUBSCRIBE_SIGNING_KEYS", "unsubscribe_signing_keys", "k1:$(openssl rand -hex 32)"),
    ("STRIPE_SECRET_KEY", "stripe_secret_key", "Stripe dashboard > Developers > API keys"),
    ("STRIPE_WEBHOOK_SECRET", "stripe_webhook_secret", "Stripe dashboard > Developers > Webhooks > the endpoint > Signing secret"),
    ("R2_ACCESS_KEY_ID", "r2_access_key_id", "Cloudflare dashboard > R2 > Manage API tokens"),
    ("R2_SECRET_ACCESS_KEY", "r2_secret_access_key", "Cloudflare dashboard > R2 > Manage API tokens"),
    ("BREVO_API_KEY", "brevo_api_key", "Brevo > SMTP & API > API keys"),
)
MIN_SECRET_BYTES = 32
DEPLOYMENT_MODES = ("test", "live")


def _looks_like_dev_value(value: str) -> bool:
    low = value.strip().lower()
    if low in KNOWN_DEV_VALUES or low.startswith(DEV_PREFIXES):
        return True
    return any(mark in low for mark in PLACEHOLDER_MARKS)


def _secret_parts(name: str, value: str) -> list[str]:
    """The secret material in a setting: several comma-separated keys, and for
    the unsubscribe keys the part after "<key id>:"."""
    parts = [p.strip() for p in value.split(",") if p.strip()]
    if name == "UNSUBSCRIBE_SIGNING_KEYS":
        parts = [p.split(":", 1)[1] if ":" in p else p for p in parts]
    return parts


def _database_password(url: str) -> str | None:
    try:
        from sqlalchemy.engine import make_url

        return make_url(url).password
    except Exception:
        return None


def production_problems(s: Settings) -> list[str]:
    """Every reason production must not start with these settings, in plain
    words; empty when it may. Only for production: callers check that."""
    problems: list[str] = []

    # Secrets.
    for env_name, attr, how in REQUIRED_SECRETS:
        value = str(getattr(s, attr) or "")
        if not value.strip():
            problems.append(f"{env_name} is empty. Set it (how: {how}).")
            continue
        for part in _secret_parts(env_name, value):
            if _looks_like_dev_value(part):
                problems.append(f"{env_name} is a development default or a placeholder. Generate a real one (how: {how}).")
                break
    jwt = s.auth_jwt_secret or ""
    if jwt and len(jwt.encode()) < MIN_SECRET_BYTES:
        problems.append(f"AUTH_JWT_SECRET is shorter than {MIN_SECRET_BYTES} bytes. Generate one with: openssl rand -hex 32")
    for key in s.admin_api_key_set():
        if len(key.encode()) < MIN_SECRET_BYTES:
            problems.append(f"ADMIN_API_KEYS holds a key shorter than {MIN_SECRET_BYTES} bytes. Generate one with: openssl rand -hex 32")
            break
    if s.address_encryption_keys.strip():
        try:
            from cryptography.fernet import Fernet

            for key in _secret_parts("ADDRESS_ENCRYPTION_KEYS", s.address_encryption_keys):
                Fernet(key)
        except Exception:
            problems.append("ADDRESS_ENCRYPTION_KEYS is not a valid key. deploy/scripts/generate-secrets.sh prints one.")

    # The database.
    password = _database_password(s.database_url)
    if not password or _looks_like_dev_value(password) or len(password) < 16:
        problems.append(
            "The database password in DATABASE_URL is empty, a default or shorter than 16 characters. "
            "Use the POSTGRES_PASSWORD generated on the server (openssl rand -hex 24)."
        )

    # Debug and bypass switches.
    if s.log_level.strip().upper() == "DEBUG":
        problems.append("LOG_LEVEL is DEBUG, which writes request details to the logs. Use INFO.")
    if s.auth_dev_bypass:
        problems.append("AUTH_DEV_BYPASS is on: anyone could sign in as anyone with a header. Set it to false.")
    if s.stripe_webhook_allow_unverified:
        problems.append("STRIPE_WEBHOOK_ALLOW_UNVERIFIED is on: unsigned payment events would be believed. Set it to false.")
    if s.allow_unverified_pro:
        problems.append("ALLOW_UNVERIFIED_PRO is on. Set it to false.")

    # Mock providers.
    if not s.email_sending_on or not s.brevo_api_key or not s.brevo_sender_email:
        problems.append(
            "Email would go to the console, not to Brevo: set EMAIL_SENDING_ENABLED=true, BREVO_API_KEY and BREVO_SENDER_EMAIL."
        )
    if s.mux_fake:
        problems.append("MUX_FAKE is on. The fake Mux is for development only: remove the line.")

    # Stripe against the declared deployment mode.
    mode = (s.deployment_mode or "").strip().lower()
    key = (s.stripe_secret_key or "").strip()
    if mode not in DEPLOYMENT_MODES:
        problems.append(f"DEPLOYMENT_MODE must be test or live; got {s.deployment_mode!r}.")
    elif key:
        live_key = key.startswith(("sk_live_", "rk_live_"))
        test_key = key.startswith(("sk_test_", "rk_test_"))
        if not (live_key or test_key):
            problems.append("STRIPE_SECRET_KEY does not look like a Stripe secret key (sk_test_..., sk_live_..., rk_...).")
        elif mode == "test" and live_key:
            problems.append(
                "STRIPE_SECRET_KEY is a LIVE key but DEPLOYMENT_MODE is test. Use the test key (sk_test_...), "
                "or set DEPLOYMENT_MODE=live on purpose."
            )
        elif mode == "live" and test_key:
            problems.append("DEPLOYMENT_MODE is live but STRIPE_SECRET_KEY is a test key: no real payment would be taken.")

    # What the outside world can reach.
    if s.api_docs_on:
        problems.append("API_DOCS_ENABLED is on: the interactive docs and openapi.json would be public. Remove the line.")
    origins = [o.strip() for o in (s.cors_allow_origins or "").split(",") if o.strip()]
    if not origins:
        problems.append("CORS_ALLOW_ORIGINS is not set. Set it to the web's address, for example https://admin.rawwers.com.")
    for origin in origins:
        if "*" in origin:
            problems.append("CORS_ALLOW_ORIGINS allows any origin (*). List the real web addresses instead.")
            break
        if urlsplit(origin).scheme != "https":
            problems.append(f"CORS_ALLOW_ORIGINS has a non-https origin ({origin}). Production lists https addresses only.")
            break
    for name, value in (("APP_PUBLIC_URL", s.app_public_url), ("API_PUBLIC_URL", s.api_public_url)):
        parts = urlsplit(value or "")
        if parts.scheme != "https" or not parts.hostname or parts.hostname in {"localhost", "127.0.0.1"}:
            problems.append(f"{name} must be a public https address; got {value!r}.")
    if s.trust_cloudflare:
        try:
            from app.core.client_ip import DEFAULT_CLOUDFLARE_IPS_FILE, _cloudflare_networks

            if not _cloudflare_networks(s.cloudflare_ips_file or str(DEFAULT_CLOUDFLARE_IPS_FILE)):
                raise ValueError("no range")
        except Exception:
            problems.append(
                "TRUST_CLOUDFLARE is on but the Cloudflare ranges file cannot be read or holds no range "
                "(CLOUDFLARE_IPS_FILE, or app/core/cloudflare_ips.txt)."
            )
    if not (s.trusted_proxy_ips or "").strip():
        problems.append(
            "TRUSTED_PROXY_IPS is empty, so every visitor would look like Caddy and share one rate limit. "
            "Set it to the compose network (deploy/compose.prod.yml pins 172.30.0.0/24)."
        )
    return problems


class ProductionSettingsError(RuntimeError):
    pass


def enforce_production_settings(settings: Settings | None = None, *, component: str = "api") -> None:
    """Stop the process when production settings are unsafe; nothing outside
    production."""
    s = settings or get_settings()
    if not s.is_production:
        return
    problems = production_problems(s)
    if not problems:
        return
    lines = "\n".join(f"  - {p}" for p in problems)
    message = (
        f"RAWWERS {component} refuses to start in production ({len(problems)} problem(s)):\n{lines}\n"
        "Fix them in the server's secrets file (docs/DEPLOY_RUNBOOK.md, 'The secrets file'), then start again."
    )
    print(message, file=sys.stderr, flush=True)
    raise ProductionSettingsError(message)
