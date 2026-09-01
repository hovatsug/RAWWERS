from __future__ import annotations

import logging
import uuid

from fastapi import Depends, Header, Request
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.db.session import get_db_read, get_db_write
from app.models.admin import UserRoleType
from app.schemas.media import CurrentUser
from app.services.auth_events import add_auth_event
from app.services.auth_service import decode_access
from app.services.i18n import get_user_locale_preference
from app.services.authz import enforce_not_banned, ensure_user_account, get_user_roles, require_kyc_approved_for_pro
from app.services.rate_limit import enforce_named_rate_limit
from app.services.trust_safety import enforce_require_verification_if_flagged
from app.services.trust_safety import capture_request_signals

settings = get_settings()
logger = logging.getLogger(__name__)


def get_current_user(
    request: Request,
    authorization: str | None = Header(default=None, alias="Authorization"),
    x_user_id: str | None = Header(default=None, alias="X-User-Id"),
    db: Session = Depends(get_db_write),
) -> CurrentUser:
    if authorization and authorization.lower().startswith("bearer "):
        token = authorization.split(" ", 1)[1].strip()
        payload = decode_access(token)
        try:
            user_id = uuid.UUID(payload.get("sub"))
        except Exception as exc:
            raise APIError(code="unauthorized", message="Invalid access token", status_code=401) from exc
        roles_raw = payload.get("roles") or []
        roles: list[UserRoleType] = []
        for value in roles_raw:
            try:
                roles.append(UserRoleType(value))
            except Exception:
                continue
        preferred_locale = get_user_locale_preference(db, user_id=user_id, fallback_to_default=False)
        if preferred_locale:
            request.state.locale = preferred_locale
        capture_request_signals(db, request=request, user_id=user_id)
        return CurrentUser(
            user_id=user_id,
            roles=roles,
            is_impersonating=bool(payload.get("is_impersonating", False)),
            impersonation_admin_user_id=uuid.UUID(payload["imp_admin_id"]) if payload.get("imp_admin_id") else None,
            impersonation_session_id=uuid.UUID(payload["imp_session_id"]) if payload.get("imp_session_id") else None,
            refresh_family_id=uuid.UUID(payload["rfam"]) if payload.get("rfam") else None,
        )

    allow_dev_bypass = settings.auth_dev_bypass and settings.app_env.lower() not in {"prod", "production"}
    if allow_dev_bypass and x_user_id:
        try:
            user_id = uuid.UUID(x_user_id)
        except ValueError as exc:
            raise APIError(code="unauthorized", message="Invalid X-User-Id header", status_code=401) from exc
        logger.warning("auth_dev_bypass_used", extra={"user_id": str(user_id)})
        ensure_user_account(db, user_id)
        add_auth_event(
            db,
            event_type="auth_dev_bypass",
            user_id=user_id,
            ip=_request_ip(request),
            user_agent=request.headers.get("user-agent"),
            metadata={"path": request.url.path},
        )
        db.commit()
        preferred_locale = get_user_locale_preference(db, user_id=user_id, fallback_to_default=False)
        if preferred_locale:
            request.state.locale = preferred_locale
        capture_request_signals(db, request=request, user_id=user_id)
        return CurrentUser(user_id=user_id, roles=list(get_user_roles(db, user_id)))

    raise APIError(code="unauthorized", message="Missing bearer token", status_code=401)


def get_optional_current_user(
    request: Request,
    authorization: str | None = Header(default=None, alias="Authorization"),
    x_user_id: str | None = Header(default=None, alias="X-User-Id"),
    db: Session = Depends(get_db_write),
) -> CurrentUser | None:
    try:
        return get_current_user(request=request, authorization=authorization, x_user_id=x_user_id, db=db)
    except APIError:
        return None


def get_db_write_session(db: Session = Depends(get_db_write)) -> Session:
    return db


def get_db_read_session(db: Session = Depends(get_db_read)) -> Session:
    return db


def get_db_session(db: Session = Depends(get_db_write_session)) -> Session:
    return db


def require_admin(
    request: Request,
    user: CurrentUser = Depends(get_current_user),
    x_admin_api_key: str | None = Header(default=None, alias="X-Admin-Api-Key"),
    db: Session = Depends(get_db_write_session),
) -> CurrentUser:
    ip = request.client.host if request.client else None
    if ip and settings.admin_ip_allowlist_set() and ip not in settings.admin_ip_allowlist_set():
        raise APIError(code="forbidden", message="Admin endpoint not allowed from this IP", status_code=403)
    if settings.admin_api_key_set() and x_admin_api_key not in settings.admin_api_key_set():
        raise APIError(code="forbidden", message="Invalid admin API key", status_code=403)

    principal = f"{user.user_id}:{ip or 'unknown'}"
    enforce_named_rate_limit("admin", principal=principal)

    ensure_user_account(db, user.user_id)
    roles = get_user_roles(db, user.user_id)
    db.commit()
    if UserRoleType.admin not in roles:
        raise APIError(code="forbidden", message="Admin access required", status_code=403)
    user.roles = list(roles)
    return user


def require_not_banned(
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_write_session),
) -> CurrentUser:
    enforce_require_verification_if_flagged(db, user_id=user.user_id)
    enforce_not_banned(db, user.user_id)
    db.commit()
    return user


def require_role(role: UserRoleType):
    def _inner(user: CurrentUser = Depends(get_current_user), db: Session = Depends(get_db_write_session)) -> CurrentUser:
        roles = get_user_roles(db, user.user_id)
        db.commit()
        if role not in roles:
            raise APIError(code="forbidden", message=f"Role {role.value} required", status_code=403)
        user.roles = list(roles)
        return user

    return _inner


def require_pro_kyc_approved(
    pro_user_id: uuid.UUID,
    db: Session = Depends(get_db_write_session),
) -> uuid.UUID:
    require_kyc_approved_for_pro(db, pro_user_id)
    return pro_user_id


def _request_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None


def get_locale(request: Request) -> str:
    return str(getattr(request.state, "locale", "en-GB"))
