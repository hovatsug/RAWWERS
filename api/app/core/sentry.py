"""Error reporting to Sentry (EU region), off unless SENTRY_DSN is set.

`init_sentry` is called once per process: the API (app/main.py), and the
Celery worker and beat (app/tasks/celery_app.py). With no DSN nothing is
initialised and every `sentry_sdk.capture_*` call is a no-op, so dev and
tests send nothing.

What reaches Sentry is scrubbed first (`scrub_event`), whatever the
integration that produced it:
- no default PII (no IP, no cookies, no user email): `send_default_pii=False`;
- every value under a sensitive key (authorization, cookie, password, token,
  secret, api key, signature, code, ...) becomes "[Filtered]", at any depth:
  headers, query strings, bodies, log extras, local variables;
- email addresses and bearer tokens inside any string are masked;
- the user is reduced to its id.
Each event is tagged with the request id (the X-Request-Id the API returns
and logs) and the component (api, worker, beat).

docs/DEPLOY_CHECKLIST.md has the setup; docs/BREVO_SETUP.md what email
failures raise.
"""
from __future__ import annotations

import logging
import re
from typing import Any
from urllib.parse import parse_qsl, urlencode

from app.core.config import get_settings
from app.core.request_context import get_request_id

logger = logging.getLogger(__name__)

FILTERED = "[Filtered]"

#: A key containing any of these (case-insensitive) has its value filtered.
SENSITIVE_KEY_PARTS = (
    "authorization",
    "cookie",
    "password",
    "passwd",
    "secret",
    "token",
    "api_key",
    "apikey",
    "api-key",
    "x-admin-api-key",
    "signature",
    "stripe-signature",
    "dsn",
    "otp",
    "session",
    "csrf",
    "iban",
    "card",
)
#: Keys filtered only when they are the whole key: verify and reset codes
#: travel as "code" (outbox payloads, request bodies); unsubscribe and share
#: links sign with "s" and "k".
SENSITIVE_EXACT_KEYS = frozenset({"code", "s", "k", "sig", "key", "email", "to_email", "to", "phone", "phone_e164"})

EMAIL_RE = re.compile(r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}")
BEARER_RE = re.compile(r"(?i)\bbearer\s+[A-Za-z0-9._\-~+/=]+")
JWT_RE = re.compile(r"\beyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+")

_initialised = False


def _is_sensitive_key(key: Any) -> bool:
    if not isinstance(key, str):
        return False
    lowered = key.lower()
    if lowered in SENSITIVE_EXACT_KEYS:
        return True
    return any(part in lowered for part in SENSITIVE_KEY_PARTS)


def scrub_text(value: str) -> str:
    value = BEARER_RE.sub("Bearer [Filtered]", value)
    value = JWT_RE.sub("[jwt]", value)
    return EMAIL_RE.sub("[email]", value)


def _scrub_query_string(value: str) -> str:
    try:
        pairs = parse_qsl(value, keep_blank_values=True)
    except ValueError:
        return FILTERED
    return urlencode([(k, FILTERED if _is_sensitive_key(k) else scrub_text(v)) for k, v in pairs])


def scrub(value: Any, depth: int = 0) -> Any:
    """`value` with every sensitive key's value and every email or token
    in a string replaced. Lists, tuples and dicts are walked."""
    if depth > 20:
        return FILTERED
    if isinstance(value, dict):
        return {k: (FILTERED if _is_sensitive_key(k) else scrub(v, depth + 1)) for k, v in value.items()}
    if isinstance(value, list):
        # Header lists arrive as [name, value] pairs.
        if len(value) == 2 and isinstance(value[0], str) and _is_sensitive_key(value[0]):
            return [value[0], FILTERED]
        return [scrub(v, depth + 1) for v in value]
    if isinstance(value, tuple):
        return tuple(scrub(list(value), depth + 1))
    if isinstance(value, str):
        return scrub_text(value)
    return value


def scrub_event(event: dict, hint: dict | None = None) -> dict:
    """Sentry's before_send: the event as it may leave this process."""
    request = event.get("request")
    if isinstance(request, dict):
        if isinstance(request.get("query_string"), str):
            request["query_string"] = _scrub_query_string(request["query_string"])
        if isinstance(request.get("url"), str) and "?" in request["url"]:
            base, _, qs = request["url"].partition("?")
            request["url"] = f"{base}?{_scrub_query_string(qs)}"
        request.pop("cookies", None)
        if isinstance(request.get("data"), str):
            request["data"] = FILTERED
        request.pop("env", None)
    user = event.get("user")
    if isinstance(user, dict):
        event["user"] = {"id": user["id"]} if user.get("id") else {}
    scrubbed = scrub({k: v for k, v in event.items() if k not in ("tags",)})
    scrubbed["tags"] = event.get("tags") or {}
    request_id = get_request_id()
    if request_id and "request_id" not in scrubbed["tags"]:
        scrubbed["tags"]["request_id"] = request_id
    return scrubbed


def scrub_breadcrumb(crumb: dict, hint: dict | None = None) -> dict:
    return scrub(crumb)


def sentry_enabled() -> bool:
    return _initialised


def init_sentry(component: str) -> bool:
    """Start reporting for this process if SENTRY_DSN is set. Idempotent."""
    global _initialised
    settings = get_settings()
    if _initialised or not settings.sentry_dsn:
        return _initialised
    import sentry_sdk
    from sentry_sdk.integrations.celery import CeleryIntegration
    from sentry_sdk.integrations.logging import LoggingIntegration

    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        environment=settings.sentry_environment or settings.app_env,
        release=settings.sentry_release or None,
        send_default_pii=False,
        traces_sample_rate=settings.sentry_traces_sample_rate,
        max_request_body_size="never",
        include_local_variables=False,
        before_send=scrub_event,
        before_breadcrumb=scrub_breadcrumb,
        integrations=[
            CeleryIntegration(monitor_beat_tasks=False),
            # ERROR log lines become events (outbox failures, failed emails);
            # INFO and up are kept as breadcrumbs.
            LoggingIntegration(level=logging.INFO, event_level=logging.ERROR),
        ],
    )
    sentry_sdk.set_tag("component", component)
    _initialised = True
    logger.info("sentry_enabled", extra={"component": component})
    return True


def capture_message(message: str, *, level: str = "error", tags: dict[str, str] | None = None, extra: dict | None = None) -> None:
    """Send one event, when reporting is on. Never raises."""
    if not _initialised:
        return
    try:
        import sentry_sdk

        with sentry_sdk.new_scope() as scope:
            for key, value in (tags or {}).items():
                scope.set_tag(key, value)
            for key, value in (extra or {}).items():
                scope.set_extra(key, value)
            sentry_sdk.capture_message(message, level=level)
    except Exception:  # pragma: no cover - reporting must never break the caller
        logger.warning("sentry_capture_failed", exc_info=True)


def capture_exception(exc: BaseException, *, tags: dict[str, str] | None = None) -> None:
    """Report one exception, when reporting is on. Never raises."""
    if not _initialised:
        return
    try:
        import sentry_sdk

        with sentry_sdk.new_scope() as scope:
            for key, value in (tags or {}).items():
                scope.set_tag(key, value)
            sentry_sdk.capture_exception(exc)
    except Exception:  # pragma: no cover
        logger.warning("sentry_capture_failed", exc_info=True)
