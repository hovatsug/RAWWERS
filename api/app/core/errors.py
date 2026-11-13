import logging
from typing import Any

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

logger = logging.getLogger(__name__)


class APIError(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400, details: dict[str, Any] | None = None):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(message)


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(APIError)
    async def handle_api_error(request: Request, exc: APIError) -> JSONResponse:
        request_id = getattr(request.state, "request_id", None)
        details = dict(exc.details or {})
        details.setdefault("request_id", request_id)
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": {
                    "code": exc.code,
                    "message": exc.message,
                    "details": details,
                }
            },
        )

    @app.exception_handler(Exception)
    async def handle_generic_error(request: Request, exc: Exception) -> JSONResponse:
        # Normally RequestContextMiddleware has already answered (see
        # internal_error_response); this is the last resort for an error
        # raised outside it.
        return internal_error_response(getattr(request.state, "request_id", None), exc)


def internal_error_response(request_id: str | None, exc: BaseException) -> JSONResponse:
    """The answer to an unhandled error: logged and reported with the
    request id, and a body that says nothing about the cause (no exception
    type, message, stack trace, file path or SQL).

    RequestContextMiddleware calls this while the request id is still set,
    so the Sentry event carries it; the tag is also passed explicitly."""
    logger.exception("unhandled_exception", extra={"request_id": request_id}, exc_info=exc)
    from app.core.sentry import capture_exception

    capture_exception(exc, tags={"request_id": request_id} if request_id else None)
    headers = {"X-Request-Id": request_id} if request_id else None
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": "internal_error",
                "message": "Internal server error",
                "details": {"request_id": request_id},
            }
        },
        headers=headers,
    )
