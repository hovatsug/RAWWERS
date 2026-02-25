from fastapi import FastAPI
from sqlalchemy import text

from app.api.router import api_router
from app.core.config import get_settings
from app.core.errors import register_error_handlers
from app.core.logging import configure_logging
from app.db.session import ReplicaSessionLocal, SessionLocal, get_replica_lag_seconds
from app.services.cache import get_redis_client

settings = get_settings()
configure_logging(settings.log_level)

app = FastAPI(title="RAWWERS API", version="0.1.0")
register_error_handlers(app)
app.include_router(api_router)


@app.get("/healthz")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


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
