from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.admin import UserRoleType


class RegisterRequest(BaseModel):
    email: str
    password: str
    # Optional on the wire, not because it is optional in the product, but
    # because the web app already calls this endpoint with email and password
    # alone and a required field would 422 it. Both Flutter apps require it in
    # their form. See docs/BACKEND_GAPS.md - the web path can still create a
    # nameless account.
    display_name: str | None = None


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutRequest(BaseModel):
    refresh_token: str | None = None
    revoke_family: bool = False


class VerifyEmailRequest(BaseModel):
    email: str


class VerifyEmailConfirmRequest(BaseModel):
    code: str


class PasswordResetRequest(BaseModel):
    email: str


class PasswordResetConfirmRequest(BaseModel):
    code: str
    new_password: str


class MeResponse(BaseModel):
    user_id: uuid.UUID
    email: str | None = None
    email_verified_at: datetime | None = None
    status: str
    roles: list[UserRoleType] = Field(default_factory=list)
    locale: str = "en-GB"
    is_impersonating: bool = False
    impersonation_admin_user_id: uuid.UUID | None = None


class UpgradeToProResponse(BaseModel):
    ok: bool
    role_added: bool


class ImpersonationStartRequest(BaseModel):
    target_user_id: uuid.UUID
    reason: str


class ImpersonationStartResponse(BaseModel):
    access_token: str
    expires_in: int
    impersonation_session_id: uuid.UUID


class RoleMutationRequest(BaseModel):
    add: list[UserRoleType] = Field(default_factory=list)
    remove: list[UserRoleType] = Field(default_factory=list)
    reason: str | None = None


class LocalePreferenceView(BaseModel):
    user_id: uuid.UUID
    locale: str


class LocalePreferenceUpdateRequest(BaseModel):
    locale: str
