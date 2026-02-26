from __future__ import annotations

import logging
import uuid
from typing import Callable

from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

from app.core.config import get_settings
from app.core.request_context import clear_request_context, set_request_context
from app.services.metrics import monotonic_seconds, observe_http

logger = logging.getLogger(__name__)
settings = get_settings()


class RequestContextMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
        user_id = request.headers.get("x-user-id")
        tenant_id = request.headers.get("x-tenant-id")

        request.state.request_id = request_id
        set_request_context(request_id=request_id, user_id=user_id, tenant_id=tenant_id)

        start = monotonic_seconds()
        route_template = request.url.path
        status_code = 500

        try:
            response = await call_next(request)
            status_code = response.status_code
            response.headers["X-Request-Id"] = request_id
            return response
        finally:
            duration_seconds = monotonic_seconds() - start
            latency_ms = int(duration_seconds * 1000)
            if request.scope.get("route") is not None:
                route_path = getattr(request.scope["route"], "path", None)
                if route_path:
                    route_template = route_path

            observe_http(route=route_template, method=request.method, status_code=status_code, duration_seconds=duration_seconds)
            logger.info(
                "request_completed",
                extra={
                    "request_id": request_id,
                    "user_id": user_id,
                    "tenant_id": tenant_id,
                    "route": route_template,
                    "method": request.method,
                    "status_code": status_code,
                    "latency_ms": latency_ms,
                },
            )
            clear_request_context()


class JsonBodyLimitMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        content_type = (request.headers.get("content-type") or "").lower()
        if "application/json" in content_type:
            body = await request.body()
            if len(body) > settings.max_json_body_bytes:
                request_id = getattr(request.state, "request_id", None)
                return JSONResponse(
                    status_code=413,
                    content={
                        "error": {
                            "code": "payload_too_large",
                            "message": "Request payload too large",
                            "details": {"request_id": request_id, "max_bytes": settings.max_json_body_bytes},
                        }
                    },
                )
        return await call_next(request)
