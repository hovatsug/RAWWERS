from __future__ import annotations

from contextvars import ContextVar

_request_id_var: ContextVar[str | None] = ContextVar("request_id", default=None)
_user_id_var: ContextVar[str | None] = ContextVar("user_id", default=None)
_tenant_id_var: ContextVar[str | None] = ContextVar("tenant_id", default=None)


def set_request_context(*, request_id: str | None, user_id: str | None = None, tenant_id: str | None = None) -> None:
    _request_id_var.set(request_id)
    _user_id_var.set(user_id)
    _tenant_id_var.set(tenant_id)


def clear_request_context() -> None:
    set_request_context(request_id=None, user_id=None, tenant_id=None)


def get_request_id() -> str | None:
    return _request_id_var.get()


def get_user_id() -> str | None:
    return _user_id_var.get()


def get_tenant_id() -> str | None:
    return _tenant_id_var.get()
