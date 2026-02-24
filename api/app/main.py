from fastapi import FastAPI

from app.api.router import api_router
from app.core.config import get_settings
from app.core.errors import register_error_handlers
from app.core.logging import configure_logging

settings = get_settings()
configure_logging(settings.log_level)

app = FastAPI(title="RAWWERS API", version="0.1.0")
register_error_handlers(app)
app.include_router(api_router)


@app.get("/healthz")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}
