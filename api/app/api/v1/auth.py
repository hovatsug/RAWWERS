from __future__ import annotations

from fastapi import APIRouter, Depends, Request, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db_session, require_admin, require_not_banned
from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.schemas.auth import (
    ImpersonationStartRequest,
    ImpersonationStartResponse,
    LoginRequest,
    LocalePreferenceUpdateRequest,
    LocalePreferenceView,
    LogoutRequest,
    MeResponse,
    PasswordResetConfirmRequest,
    PasswordResetRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UpgradeToProResponse,
    VerifyEmailConfirmRequest,
    VerifyEmailRequest,
)
from app.schemas.media import CurrentUser
from app.services.audit import add_admin_audit_log
from app.services.analytics import log_event
from app.services.auth_events import add_auth_event
from app.services.auth_service import (
    confirm_email_verification,
    confirm_password_reset,
    end_impersonation,
    ensure_pro_role,
    get_roles,
    login_user,
    logout_with_refresh,
    refresh_tokens,
    register_user,
    revoke_family,
    request_password_reset,
    resend_email_verification,
    start_impersonation,
)
from app.services.growth_engine import (
    bind_session_attribution_to_user,
    ensure_referral_profile,
    link_referee_to_referrer,
)
from app.services.i18n import get_user_locale_preference, upsert_user_locale_preference
from app.services.rate_limit import enforce_named_rate_limit
from app.services.trust_safety import capture_request_signals, evaluate_login_failure_rule

router = APIRouter(tags=["auth"])


@router.post("/auth/register", status_code=status.HTTP_201_CREATED)
def register(
    body: RegisterRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> dict:
    enforce_named_rate_limit("auth_mutation", principal=f"register:{_request_ip(request) or 'unknown'}")
    user = register_user(
        db,
        email=body.email,
        password=body.password,
        display_name=body.display_name,
        ip=_request_ip(request),
        user_agent=request.headers.get("user-agent"),
    )
    capture_request_signals(db, request=request, user_id=user.user_id)
    ensure_referral_profile(db, user.user_id)
    session_id = request.cookies.get("rw_sid")
    if session_id and request.cookies.get("rw_tracking_consent") == "yes":
        bind_session_attribution_to_user(db, session_id=session_id, user_id=user.user_id)
    referral_code = request.cookies.get("rw_ref")
    if referral_code:
        try:
            link = link_referee_to_referrer(
                db,
                referee_user_id=user.user_id,
                referral_code=referral_code,
                referee_email=user.email,
                request_ip=_request_ip(request),
            )
            log_event(
                db,
                event_name="referral.registered",
                user_id=user.user_id,
                session_id=session_id,
                properties={"referral_code": referral_code, "referrer_user_id": str(link.referrer_user_id)},
            )
        except APIError:
            pass
    db.commit()
    return {"ok": True, "user_id": str(user.user_id)}


@router.post("/auth/login", response_model=TokenResponse)
def login(
    body: LoginRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> TokenResponse:
    principal = body.email.lower().strip() if body.email else (_request_ip(request) or "unknown")
    enforce_named_rate_limit("auth_mutation", principal=f"login:{principal}")
    try:
        access, refresh, expires_in = login_user(db, email=body.email, password=body.password, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    except APIError as exc:
        if exc.code == "unauthorized":
            user = db.execute(select(UserAccount).where(UserAccount.email == body.email.lower().strip())).scalar_one_or_none()
            capture_request_signals(db, request=request, user_id=user.user_id if user else None)
            if user:
                evaluate_login_failure_rule(db, user_id=user.user_id)
            db.commit()
        raise
    user = db.execute(select(UserAccount).where(UserAccount.email == body.email.lower().strip())).scalar_one_or_none()
    capture_request_signals(db, request=request, user_id=user.user_id if user else None)
    db.commit()
    return TokenResponse(access_token=access, refresh_token=refresh, expires_in=expires_in)


@router.post("/auth/refresh", response_model=TokenResponse)
def refresh(
    body: RefreshRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> TokenResponse:
    enforce_named_rate_limit("auth_mutation", principal=f"refresh:{_request_ip(request) or 'unknown'}")
    access, refresh_token, expires_in = refresh_tokens(db, refresh_token=body.refresh_token, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    db.commit()
    return TokenResponse(access_token=access, refresh_token=refresh_token, expires_in=expires_in)


@router.post("/auth/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(
    body: LogoutRequest,
    request: Request,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> Response:
    if body.refresh_token:
        logout_with_refresh(db, refresh_token=body.refresh_token, revoke_family=body.revoke_family, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    elif user.refresh_family_id:
        revoke_family(db, user.refresh_family_id)
        add_auth_event(db, event_type="logout", user_id=user.user_id, ip=_request_ip(request), user_agent=request.headers.get("user-agent"), metadata={"family_id": str(user.refresh_family_id)})
    else:
        add_auth_event(db, event_type="logout", user_id=user.user_id, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/auth/verify-email/request", status_code=status.HTTP_204_NO_CONTENT)
def verify_email_request(
    body: VerifyEmailRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> Response:
    enforce_named_rate_limit("auth_mutation", principal=f"verify:{body.email.lower().strip()}")
    resend_email_verification(db, email=body.email)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/auth/verify-email/confirm", status_code=status.HTTP_204_NO_CONTENT)
def verify_email_confirm(
    body: VerifyEmailConfirmRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> Response:
    confirm_email_verification(db, code=body.code, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/auth/password-reset/request", status_code=status.HTTP_204_NO_CONTENT)
def password_reset_request(
    body: PasswordResetRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> Response:
    enforce_named_rate_limit("auth_mutation", principal=f"pw-reset:{body.email.lower().strip()}")
    request_password_reset(db, email=body.email)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/auth/password-reset/confirm", status_code=status.HTTP_204_NO_CONTENT)
def password_reset_confirm(
    body: PasswordResetConfirmRequest,
    request: Request,
    db: Session = Depends(get_db_session),
) -> Response:
    confirm_password_reset(db, code=body.code, new_password=body.new_password, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/me", response_model=MeResponse)
def me(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> MeResponse:
    account = db.get(UserAccount, user.user_id)
    if not account:
        raise APIError(code="not_found", message="User not found", status_code=404)
    roles = get_roles(db, user.user_id)
    db.commit()
    return MeResponse(
        user_id=user.user_id,
        email=account.email,
        email_verified_at=account.email_verified_at,
        status=account.status.value,
        roles=roles,
        locale=get_user_locale_preference(db, user_id=user.user_id),
        is_impersonating=user.is_impersonating,
        impersonation_admin_user_id=user.impersonation_admin_user_id,
    )


@router.get("/me/locale", response_model=LocalePreferenceView)
def me_locale(
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LocalePreferenceView:
    locale = get_user_locale_preference(db, user_id=user.user_id)
    db.commit()
    return LocalePreferenceView(user_id=user.user_id, locale=locale)


@router.put("/me/locale", response_model=LocalePreferenceView)
def update_me_locale(
    body: LocalePreferenceUpdateRequest,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> LocalePreferenceView:
    row = upsert_user_locale_preference(db, user_id=user.user_id, locale=body.locale)
    db.commit()
    return LocalePreferenceView(user_id=row.user_id, locale=row.locale)


@router.post("/me/upgrade-to-pro", response_model=UpgradeToProResponse)
def upgrade_to_pro(
    request: Request,
    user: CurrentUser = Depends(require_not_banned),
    db: Session = Depends(get_db_session),
) -> UpgradeToProResponse:
    before = db.execute(select(UserRole).where(UserRole.user_id == user.user_id, UserRole.role == UserRoleType.pro)).scalar_one_or_none()
    ensure_pro_role(db, user.user_id, ip=_request_ip(request), user_agent=request.headers.get("user-agent"))
    db.commit()
    return UpgradeToProResponse(ok=True, role_added=before is None)


@router.post("/admin/impersonate/start", response_model=ImpersonationStartResponse)
def impersonate_start(
    body: ImpersonationStartRequest,
    request: Request,
    actor: CurrentUser = Depends(require_admin),
    db: Session = Depends(get_db_session),
) -> ImpersonationStartResponse:
    session, token, expires_in = start_impersonation(
        db,
        admin_user_id=actor.user_id,
        target_user_id=body.target_user_id,
        reason=body.reason,
        ip=_request_ip(request),
        user_agent=request.headers.get("user-agent"),
    )
    add_admin_audit_log(
        db,
        actor_user_id=actor.user_id,
        target_type="impersonation",
        target_id=str(session.id),
        action="impersonation_started",
        reason=body.reason,
        metadata={"target_user_id": str(body.target_user_id)},
    )
    db.commit()
    return ImpersonationStartResponse(access_token=token, expires_in=expires_in, impersonation_session_id=session.id)


@router.post("/admin/impersonate/end", status_code=status.HTTP_204_NO_CONTENT)
def impersonate_end(
    request: Request,
    user: CurrentUser = Depends(get_current_user),
    db: Session = Depends(get_db_session),
) -> Response:
    if not user.is_impersonating or not user.impersonation_session_id or not user.impersonation_admin_user_id:
        raise APIError(code="validation_error", message="Not currently impersonating", status_code=400)
    end_impersonation(
        db,
        session_id=user.impersonation_session_id,
        admin_user_id=user.impersonation_admin_user_id,
        ip=_request_ip(request),
        user_agent=request.headers.get("user-agent"),
    )
    add_admin_audit_log(
        db,
        actor_user_id=user.impersonation_admin_user_id,
        target_type="impersonation",
        target_id=str(user.impersonation_session_id),
        action="impersonation_ended",
        reason=None,
        metadata={"target_user_id": str(user.user_id)},
    )
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


def _request_ip(request: Request) -> str | None:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else None
