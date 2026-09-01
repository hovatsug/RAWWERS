from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import BanAction, BanActionType, KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType

settings = get_settings()


def ensure_user_account(db: Session, user_id: uuid.UUID) -> UserAccount:
    account = db.get(UserAccount, user_id)
    if account is None:
        account = UserAccount(user_id=user_id)
        db.add(account)
        db.flush()

    _seed_admin_role_if_needed(db, user_id)
    return account


def user_has_role(db: Session, user_id: uuid.UUID, role: UserRoleType) -> bool:
    role_row = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == role)).scalar_one_or_none()
    return role_row is not None


def get_user_roles(db: Session, user_id: uuid.UUID) -> set[UserRoleType]:
    roles = db.execute(select(UserRole.role).where(UserRole.user_id == user_id)).scalars().all()
    return set(roles)


def get_latest_ban_action(db: Session, user_id: uuid.UUID) -> BanAction | None:
    return db.execute(
        select(BanAction).where(BanAction.user_id == user_id).order_by(BanAction.created_at.desc())
    ).scalar_one_or_none()


def enforce_not_banned(db: Session, user_id: uuid.UUID) -> None:
    ensure_user_account(db, user_id)

    action = get_latest_ban_action(db, user_id)
    if action is None:
        return

    now = datetime.now(timezone.utc)
    blocked = False
    if action.action == BanActionType.banned:
        blocked = True
    elif action.action == BanActionType.suspended and (action.ends_at is None or now < action.ends_at):
        blocked = True

    if blocked and settings.ban_enforcement_mode == "strict":
        raise APIError(code="forbidden", message="User is banned/suspended", status_code=403)


def require_kyc_approved_for_pro(db: Session, pro_user_id: uuid.UUID, allow_unverified: bool = False) -> None:
    if allow_unverified:
        return

    profile = db.get(ProProfile, pro_user_id)
    if not profile or profile.kyc_status != KYCStatus.approved:
        raise APIError(code="kyc_required", message="Pro KYC approval required", status_code=409)


def _seed_admin_role_if_needed(db: Session, user_id: uuid.UUID) -> None:
    if user_id not in settings.admin_user_id_set():
        return

    existing = db.execute(
        select(UserRole).where(UserRole.user_id == user_id, UserRole.role == UserRoleType.admin)
    ).scalar_one_or_none()
    if existing is None:
        db.add(UserRole(user_id=user_id, role=UserRoleType.admin))
        db.flush()
