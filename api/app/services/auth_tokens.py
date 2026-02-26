from __future__ import annotations

import hashlib
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt

from app.core.config import get_settings

settings = get_settings()


def create_access_token(
    *,
    user_id: uuid.UUID,
    roles: list[str],
    is_impersonating: bool = False,
    imp_admin_id: uuid.UUID | None = None,
    imp_session_id: uuid.UUID | None = None,
    refresh_family_id: uuid.UUID | None = None,
    ttl_minutes: int | None = None,
) -> tuple[str, int]:
    ttl = ttl_minutes or settings.auth_access_token_ttl_minutes
    now = datetime.now(timezone.utc)
    exp = now + timedelta(minutes=ttl)
    payload = {
        "sub": str(user_id),
        "roles": roles,
        "typ": "access",
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
        "is_impersonating": is_impersonating,
    }
    if imp_admin_id:
        payload["imp_admin_id"] = str(imp_admin_id)
    if imp_session_id:
        payload["imp_session_id"] = str(imp_session_id)
    if refresh_family_id:
        payload["rfam"] = str(refresh_family_id)
    token = jwt.encode(payload, settings.auth_jwt_secret, algorithm="HS256")
    return token, ttl * 60


def decode_access_token(token: str) -> dict:
    return jwt.decode(token, settings.auth_jwt_secret, algorithms=["HS256"])


def generate_refresh_token() -> str:
    return secrets.token_urlsafe(48)


def hash_refresh_token(token: str) -> str:
    digest = hashlib.sha256()
    digest.update(settings.auth_jwt_secret.encode("utf-8"))
    digest.update(token.encode("utf-8"))
    return digest.hexdigest()


def generate_one_time_code() -> str:
    return secrets.token_urlsafe(24)


def hash_one_time_code(code: str) -> str:
    digest = hashlib.sha256()
    digest.update(settings.auth_jwt_secret.encode("utf-8"))
    digest.update(code.encode("utf-8"))
    return digest.hexdigest()
