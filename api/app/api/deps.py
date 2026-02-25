import uuid

from fastapi import Depends, Header
from sqlalchemy.orm import Session

from app.core.errors import APIError
from app.models.admin import UserRoleType
from app.db.session import get_db_read, get_db_write
from app.schemas.media import CurrentUser
from app.services.authz import enforce_not_banned, ensure_user_account, get_user_roles, require_kyc_approved_for_pro


def get_current_user(x_user_id: str | None = Header(default=None, alias="X-User-Id")) -> CurrentUser:
    if not x_user_id:
        raise APIError(code="unauthorized", message="Missing X-User-Id header", status_code=401)
    try:
        user_id = uuid.UUID(x_user_id)
    except ValueError as exc:
        raise APIError(code="unauthorized", message="Invalid X-User-Id header", status_code=401) from exc
    return CurrentUser(user_id=user_id)


def get_optional_current_user(x_user_id: str | None = Header(default=None, alias="X-User-Id")) -> CurrentUser | None:
    if not x_user_id:
        return None
    try:
        return CurrentUser(user_id=uuid.UUID(x_user_id))
    except ValueError:
        return None


def get_db_write_session(db: Session = Depends(get_db_write)) -> Session:
    return db


def get_db_read_session(db: Session = Depends(get_db_read)) -> Session:
    return db


def get_db_session(db: Session = Depends(get_db_write_session)) -> Session:
    # Backward compatible alias.
    return db


def require_admin(
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_write_session),
) -> CurrentUser:
    ensure_user_account(db, user.user_id)
    roles = get_user_roles(db, user.user_id)
    db.commit()
    if UserRoleType.admin not in roles:
        raise APIError(code="forbidden", message="Admin access required", status_code=403)
    return user


def require_not_banned(
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_write_session),
) -> CurrentUser:
    enforce_not_banned(db, user.user_id)
    db.commit()
    return user


def require_pro_kyc_approved(
    pro_user_id: uuid.UUID,
    db: Session = Depends(get_db_write_session),
) -> uuid.UUID:
    require_kyc_approved_for_pro(db, pro_user_id)
    return pro_user_id
