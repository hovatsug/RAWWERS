# Before anything else, even the other imports: production stops here, every
# problem named, when a secret is a default, debug is on, Stripe does not
# match DEPLOYMENT_MODE... (core/production_guard.py).
from app.core.config import get_settings
from app.core.production_guard import enforce_production_settings

settings = get_settings()
enforce_production_settings(settings, component="api")

from contextlib import asynccontextmanager  # noqa: E402

from fastapi import FastAPI  # noqa: E402
from fastapi.middleware.cors import CORSMiddleware  # noqa: E402
from fastapi.responses import Response  # noqa: E402
from sqlalchemy import text  # noqa: E402

from app.api.router import api_router  # noqa: E402
from app.core.errors import APIError, register_error_handlers  # noqa: E402
from app.core.logging import configure_logging  # noqa: E402
from app.core.sentry import init_sentry  # noqa: E402
from app.core.middleware import JsonBodyLimitMiddleware, RequestContextMiddleware  # noqa: E402
from app.db.session import ReplicaSessionLocal, SessionLocal, get_replica_lag_seconds  # noqa: E402
from app.services import warmup  # noqa: E402
from app.services.cache import get_redis_client  # noqa: E402
from app.services.metrics import render_metrics  # noqa: E402

configure_logging(settings.log_level)
init_sentry("api")

def _require_admin_api_key_configured() -> None:
    """Refuse to start with admin routes reachable and no admin API key.

    require_admin skips the header check entirely when no key is
    configured, so an unset ADMIN_API_KEYS does not weaken the check - it
    removes it, leaving every admin route open to any authenticated
    account with the admin role. That is one misconfigured deploy away
    from an open admin panel, and it fails silently, which is the worst
    combination.

    Local development is exempt by app_env, so nobody has to invent a key
    to run the stack; anything else must set one.
    """
    if settings.app_env.lower() in {"dev", "development", "test"}:
        return
    if settings.admin_api_key_set():
        return
    raise RuntimeError(
        "ADMIN_API_KEYS is not set. Admin routes are mounted and their API-key "
        "check is skipped when no key is configured, which would leave them open. "
        "Set ADMIN_API_KEYS, or unmount the admin router for this deployment."
    )


_require_admin_api_key_configured()

@asynccontextmanager
async def lifespan(app_: FastAPI):
    # Before the first request, not inside it (app/services/warmup.py).
    if get_settings().startup_warmup:
        await warmup.warm_up(app_)
    yield


# The interactive docs and the OpenAPI document are not served in production
# (API_DOCS_ENABLED; the apps' clients are generated from a dev API).
_docs = settings.api_docs_on
app = FastAPI(
    title="RAWWERS API",
    version="0.1.0",
    lifespan=lifespan,
    docs_url="/docs" if _docs else None,
    redoc_url="/redoc" if _docs else None,
    openapi_url="/openapi.json" if _docs else None,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origin_list(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(JsonBodyLimitMiddleware)
app.add_middleware(RequestContextMiddleware)
register_error_handlers(app)
app.include_router(api_router)


@app.get("/healthz")
def healthcheck() -> dict[str, str | None]:
    # The running commit (SENTRY_RELEASE, set from IMAGE_TAG by the compose
    # file), so a deploy can be checked from outside (deploy/scripts/smoke.py).
    return {"status": "ok", "release": get_settings().sentry_release or None}


@app.get("/health/ready")
def health_ready() -> dict:
    primary_ok = False
    redis_ok = False

    db = SessionLocal()
    try:
        try:
            db.execute(text("SELECT 1"))
            primary_ok = True
        except Exception:
            primary_ok = False
    finally:
        db.close()

    try:
        redis_ok = get_redis_client().ping()
    except Exception:
        redis_ok = False

    return {"ready": bool(primary_ok and redis_ok), "primary_db": primary_ok, "redis": bool(redis_ok)}


@app.get("/health/replica")
def health_replica() -> dict:
    if not ReplicaSessionLocal:
        return {"replica_configured": False, "healthy": True, "lag_seconds": None}
    db = ReplicaSessionLocal()
    try:
        db.execute(text("SELECT 1"))
        lag = get_replica_lag_seconds(db)
        return {
            "replica_configured": True,
            "healthy": True if lag is None else lag <= settings.max_replica_lag_seconds,
            "lag_seconds": lag,
            "max_allowed_lag_seconds": settings.max_replica_lag_seconds,
        }
    finally:
        db.close()


@app.get("/metrics", include_in_schema=False)
def metrics() -> Response:
    # Request counts per route and task failures: not for the public. Nothing
    # scrapes production yet, so it is not served there at all.
    if get_settings().is_production:
        raise APIError(code="not_found", message="Not found", status_code=404)
    payload, content_type = render_metrics()
    return Response(content=payload, media_type=content_type)
