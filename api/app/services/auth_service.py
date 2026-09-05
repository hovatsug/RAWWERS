from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.errors import APIError
from app.models.admin import KYCStatus, ProProfile, UserAccount, UserAccountStatus, UserRole, UserRoleType
from app.models.auth import EmailVerification, ImpersonationSession, PasswordReset, SessionRefreshToken
from app.services.auth_events import add_auth_event
from app.models.communication import NotificationSeverity
from app.services.notifications import enqueue_notification
from app.services.auth_tokens import (
    create_access_token,
    decode_access_token,
    generate_one_time_code,
    generate_refresh_token,
    hash_one_time_code,
    hash_refresh_token,
)
from app.services.outbox import enqueue_outbox_event

settings = get_settings()
_password_hasher = PasswordHasher()


def _now() -> datetime:
    return datetime.now(timezone.utc)


def normalize_email(value: str) -> str:
    email = (value or "").strip().lower()
    if "@" not in email or len(email) > 320:
        raise APIError(code="validation_error", message="Invalid email", status_code=422)
    return email


def hash_password(password: str) -> str:
    if len(password) < 8:
        raise APIError(code="validation_error", message="Password must be at least 8 characters", status_code=422)
    return _password_hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _password_hasher.verify(password_hash, password)
    except VerifyMismatchError:
        return False


def get_roles(db: Session, user_id: uuid.UUID) -> list[UserRoleType]:
    return db.execute(select(UserRole.role).where(UserRole.user_id == user_id)).scalars().all()


def register_user(
    db: Session,
    *,
    email: str,
    password: str,
    ip: str | None,
    user_agent: str | None,
    display_name: str | None = None,
) -> UserAccount:
    email_norm = normalize_email(email)
    existing = db.execute(select(UserAccount).where(UserAccount.email == email_norm)).scalar_one_or_none()
    if existing:
        raise APIError(code="already_exists", message="Email already registered", status_code=409)

    # Blank is stored as absent rather than as an empty string: a name that is
    # present but empty renders as a gap everywhere it is used, and reads as a
    # bug rather than as missing data.
    name = display_name.strip() if display_name else None

    row = UserAccount(
        user_id=uuid.uuid4(),
        email=email_norm,
        password_hash=hash_password(password),
        display_name=name or None,
        status=UserAccountStatus.active,
        created_at=_now(),
        updated_at=_now(),
    )
    db.add(row)
    db.flush()
    db.add(UserRole(user_id=row.user_id, role=UserRoleType.client))
    _create_email_verification(db, row)
    add_auth_event(db, event_type="register", user_id=row.user_id, ip=ip, user_agent=user_agent, metadata={"email": email_norm})
    return row


def _create_email_verification(db: Session, user: UserAccount) -> str:
    code = generate_one_time_code()
    row = EmailVerification(
        user_id=user.user_id,
        code_hash=hash_one_time_code(code),
        sent_to_email=user.email or "",
        expires_at=_now() + timedelta(minutes=settings.auth_email_verification_ttl_minutes),
    )
    db.add(row)
    db.flush()
    enqueue_outbox_event(
        db,
        topic="email.verify.send",
        payload={"user_id": str(user.user_id), "email": user.email, "code": code},
        idempotency_key=f"email-verify:{row.id}",
        idempotency_scope="auth_email",
    )
    add_auth_event(db, event_type="verify_sent", user_id=user.user_id, ip=None, user_agent=None, metadata={"email": user.email})
    return code


def resend_email_verification(db: Session, *, email: str) -> None:
    email_norm = normalize_email(email)
    user = db.execute(select(UserAccount).where(UserAccount.email == email_norm)).scalar_one_or_none()
    if not user:
        return
    _create_email_verification(db, user)


def confirm_email_verification(db: Session, *, code: str, ip: str | None, user_agent: str | None) -> None:
    code_hash = hash_one_time_code(code)
    row = db.execute(select(EmailVerification).where(EmailVerification.code_hash == code_hash)).scalar_one_or_none()
    if not row or row.used_at is not None or row.expires_at < _now():
        raise APIError(code="invalid_code", message="Invalid or expired verification code", status_code=400)
    row.used_at = _now()
    user = db.get(UserAccount, row.user_id)
    if user:
        user.email_verified_at = _now()
        user.updated_at = _now()
    add_auth_event(db, event_type="verified", user_id=row.user_id, ip=ip, user_agent=user_agent)


def login_user(db: Session, *, email: str, password: str, ip: str | None, user_agent: str | None) -> tuple[str, str, int]:
    email_norm = normalize_email(email)
    user = db.execute(select(UserAccount).where(UserAccount.email == email_norm)).scalar_one_or_none()
    if not user or not user.password_hash or not verify_password(password, user.password_hash):
        add_auth_event(db, event_type="login_failure", user_id=user.user_id if user else None, ip=ip, user_agent=user_agent, metadata={"email": email_norm})
        raise APIError(code="unauthorized", message="Invalid credentials", status_code=401)
    if user.status != UserAccountStatus.active:
        raise APIError(code="forbidden", message="Account disabled", status_code=403)

    refresh_token, family_id = _issue_refresh_token(db, user.user_id, ip=ip, user_agent=user_agent)
    roles = [r.value for r in get_roles(db, user.user_id)]
    access_token, expires_in = create_access_token(user_id=user.user_id, roles=roles, refresh_family_id=family_id)
    user.last_login_at = _now()
    add_auth_event(db, event_type="login_success", user_id=user.user_id, ip=ip, user_agent=user_agent)
    enqueue_notification(
        db,
        user_id=user.user_id,
        notification_type="auth.new_login",
        payload={},
        reference_type="user_account",
        reference_id=str(uuid.uuid4()),
        severity=NotificationSeverity.important,
    )
    return access_token, refresh_token, expires_in


def _issue_refresh_token(db: Session, user_id: uuid.UUID, *, ip: str | None, user_agent: str | None, family_id: uuid.UUID | None = None) -> tuple[str, uuid.UUID]:
    token = generate_refresh_token()
    token_hash = hash_refresh_token(token)
    family = family_id or uuid.uuid4()
    row = SessionRefreshToken(
        user_id=user_id,
        token_hash=token_hash,
        family_id=family,
        issued_at=_now(),
        expires_at=_now() + timedelta(days=settings.auth_refresh_token_ttl_days),
        user_agent=user_agent,
        ip_hash=hash_one_time_code(ip or "") if ip else None,
    )
    db.add(row)
    db.flush()
    return token, family


def refresh_tokens(db: Session, *, refresh_token: str, ip: str | None, user_agent: str | None) -> tuple[str, str, int]:
    token_hash = hash_refresh_token(refresh_token)
    row = db.execute(select(SessionRefreshToken).where(SessionRefreshToken.token_hash == token_hash)).scalar_one_or_none()
    if not row:
        raise APIError(code="unauthorized", message="Invalid refresh token", status_code=401)

    if row.revoked_at is not None:
        _revoke_family(db, row.family_id)
        add_auth_event(db, event_type="refresh_reuse_detected", user_id=row.user_id, ip=ip, user_agent=user_agent)
        raise APIError(code="unauthorized", message="Refresh token reuse detected", status_code=401)

    if row.expires_at < _now():
        row.revoked_at = _now()
        add_auth_event(db, event_type="refresh_expired", user_id=row.user_id, ip=ip, user_agent=user_agent)
        raise APIError(code="unauthorized", message="Refresh token expired", status_code=401)

    user = db.get(UserAccount, row.user_id)
    if not user or user.status != UserAccountStatus.active:
        raise APIError(code="forbidden", message="Account disabled", status_code=403)

    row.revoked_at = _now()
    new_refresh, family_id = _issue_refresh_token(db, row.user_id, ip=ip, user_agent=user_agent, family_id=row.family_id)
    new_hash = hash_refresh_token(new_refresh)
    new_row = db.execute(select(SessionRefreshToken).where(SessionRefreshToken.token_hash == new_hash)).scalar_one()
    row.replaced_by_token_id = new_row.id

    roles = [r.value for r in get_roles(db, row.user_id)]
    access_token, expires_in = create_access_token(user_id=row.user_id, roles=roles, refresh_family_id=family_id)
    add_auth_event(db, event_type="refresh_success", user_id=row.user_id, ip=ip, user_agent=user_agent, metadata={"family_id": str(family_id)})
    return access_token, new_refresh, expires_in


def logout_with_refresh(db: Session, *, refresh_token: str, revoke_family: bool = False, ip: str | None = None, user_agent: str | None = None) -> None:
    token_hash = hash_refresh_token(refresh_token)
    row = db.execute(select(SessionRefreshToken).where(SessionRefreshToken.token_hash == token_hash)).scalar_one_or_none()
    if not row:
        return
    if revoke_family:
        _revoke_family(db, row.family_id)
    else:
        row.revoked_at = _now()
    add_auth_event(db, event_type="logout", user_id=row.user_id, ip=ip, user_agent=user_agent)


def _revoke_family(db: Session, family_id: uuid.UUID) -> None:
    rows = db.execute(select(SessionRefreshToken).where(SessionRefreshToken.family_id == family_id)).scalars().all()
    now = _now()
    for row in rows:
        if row.revoked_at is None:
            row.revoked_at = now


def revoke_family(db: Session, family_id: uuid.UUID) -> None:
    _revoke_family(db, family_id)


def request_password_reset(db: Session, *, email: str) -> None:
    email_norm = normalize_email(email)
    user = db.execute(select(UserAccount).where(UserAccount.email == email_norm)).scalar_one_or_none()
    if not user:
        return
    code = generate_one_time_code()
    row = PasswordReset(
        user_id=user.user_id,
        code_hash=hash_one_time_code(code),
        expires_at=_now() + timedelta(minutes=settings.auth_password_reset_ttl_minutes),
    )
    db.add(row)
    db.flush()
    enqueue_outbox_event(
        db,
        topic="email.reset.send",
        payload={"user_id": str(user.user_id), "email": user.email, "code": code},
        idempotency_key=f"email-reset:{row.id}",
        idempotency_scope="auth_email",
    )
    add_auth_event(db, event_type="reset_sent", user_id=user.user_id, ip=None, user_agent=None, metadata={"email": user.email})


def confirm_password_reset(db: Session, *, code: str, new_password: str, ip: str | None, user_agent: str | None) -> None:
    code_hash = hash_one_time_code(code)
    row = db.execute(select(PasswordReset).where(PasswordReset.code_hash == code_hash)).scalar_one_or_none()
    if not row or row.used_at is not None or row.expires_at < _now():
        raise APIError(code="invalid_code", message="Invalid or expired reset code", status_code=400)

    user = db.get(UserAccount, row.user_id)
    if not user:
        raise APIError(code="not_found", message="User not found", status_code=404)
    user.password_hash = hash_password(new_password)
    user.updated_at = _now()
    row.used_at = _now()
    revoke_all_user_sessions(db, user.user_id)
    add_auth_event(db, event_type="reset_used", user_id=user.user_id, ip=ip, user_agent=user_agent)
    enqueue_notification(
        db,
        user_id=user.user_id,
        notification_type="password.reset",
        payload={},
        reference_type="user_account",
        reference_id=str(uuid.uuid4()),
        severity=NotificationSeverity.critical,
    )


def revoke_all_user_sessions(db: Session, user_id: uuid.UUID) -> None:
    rows = db.execute(select(SessionRefreshToken).where(SessionRefreshToken.user_id == user_id)).scalars().all()
    now = _now()
    for row in rows:
        if row.revoked_at is None:
            row.revoked_at = now


def decode_access(token: str) -> dict:
    try:
        return decode_access_token(token)
    except Exception as exc:  # pragma: no cover
        raise APIError(code="unauthorized", message="Invalid access token", status_code=401) from exc


def ensure_pro_role(db: Session, user_id: uuid.UUID, *, ip: str | None, user_agent: str | None) -> None:
    existing = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == UserRoleType.pro)).scalar_one_or_none()
    if not existing:
        db.add(UserRole(user_id=user_id, role=UserRoleType.pro))
    profile = db.get(ProProfile, user_id)
    if not profile:
        db.add(
            ProProfile(
                user_id=user_id,
                is_accepting_bookings=False,
                completeness_score=0,
                kyc_status=KYCStatus.unsubmitted,
            )
        )
    add_auth_event(db, event_type="role_changed", user_id=user_id, ip=ip, user_agent=user_agent, metadata={"add": ["pro"]})


def admin_update_roles(db: Session, *, user_id: uuid.UUID, add: list[UserRoleType], remove: list[UserRoleType], ip: str | None, user_agent: str | None) -> None:
    for role in add:
        exists = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == role)).scalar_one_or_none()
        if not exists:
            db.add(UserRole(user_id=user_id, role=role))
    for role in remove:
        row = db.execute(select(UserRole).where(UserRole.user_id == user_id, UserRole.role == role)).scalar_one_or_none()
        if row:
            db.delete(row)
    add_auth_event(db, event_type="role_changed", user_id=user_id, ip=ip, user_agent=user_agent, metadata={"add": [r.value for r in add], "remove": [r.value for r in remove]})


def start_impersonation(
    db: Session,
    *,
    admin_user_id: uuid.UUID,
    target_user_id: uuid.UUID,
    reason: str,
    ip: str | None,
    user_agent: str | None,
) -> tuple[ImpersonationSession, str, int]:
    session = ImpersonationSession(admin_user_id=admin_user_id, target_user_id=target_user_id, reason=reason)
    db.add(session)
    db.flush()

    roles = [r.value for r in get_roles(db, target_user_id)]
    token, expires_in = create_access_token(
        user_id=target_user_id,
        roles=roles,
        is_impersonating=True,
        imp_admin_id=admin_user_id,
        imp_session_id=session.id,
    )
    add_auth_event(db, event_type="impersonation_started", user_id=target_user_id, ip=ip, user_agent=user_agent, metadata={"admin_user_id": str(admin_user_id), "reason": reason, "session_id": str(session.id)})
    return session, token, expires_in


def end_impersonation(db: Session, *, session_id: uuid.UUID, admin_user_id: uuid.UUID, ip: str | None, user_agent: str | None) -> None:
    row = db.get(ImpersonationSession, session_id)
    if not row:
        raise APIError(code="not_found", message="Impersonation session not found", status_code=404)
    if row.admin_user_id != admin_user_id:
        raise APIError(code="forbidden", message="Invalid impersonation session owner", status_code=403)
    if row.ended_at is None:
        row.ended_at = _now()
    add_auth_event(db, event_type="impersonation_ended", user_id=row.target_user_id, ip=ip, user_agent=user_agent, metadata={"admin_user_id": str(admin_user_id), "session_id": str(row.id)})
