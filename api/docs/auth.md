# Auth + Identity + RBAC v1 (Foundation #19)

## Token lifecycle
- Access token: JWT (short-lived, default 15 minutes)
- Refresh token: opaque random token
- Refresh token rotation is enforced on every `/v1/auth/refresh`
- Refresh reuse detection revokes the whole token family

## Tables
- `user_account` (email/password/status/verification timestamps)
- `user_role`
- `session_refresh_token`
- `email_verification`
- `password_reset`
- `auth_event_log`
- `impersonation_session`

## Endpoints
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/refresh`
- `POST /v1/auth/logout`
- `POST /v1/auth/verify-email/request`
- `POST /v1/auth/verify-email/confirm`
- `POST /v1/auth/password-reset/request`
- `POST /v1/auth/password-reset/confirm`
- `GET /v1/me`
- `POST /v1/me/upgrade-to-pro`
- `POST /v1/admin/impersonate/start`
- `POST /v1/admin/impersonate/end`

## Env vars
- `AUTH_JWT_SECRET`
- `AUTH_ACCESS_TOKEN_TTL_MINUTES`
- `AUTH_REFRESH_TOKEN_TTL_DAYS`
- `AUTH_EMAIL_VERIFICATION_TTL_MINUTES`
- `AUTH_PASSWORD_RESET_TTL_MINUTES`
- `AUTH_DEV_BYPASS`

## Dev bypass rules
- `AUTH_DEV_BYPASS=true` is only honored when `APP_ENV` is not `prod`/`production`
- In bypass mode, `X-User-Id` can authenticate local/test requests
- Every bypass use writes an `auth_event_log` record (`auth_dev_bypass`)

## Threat model summary
- Password hashing: Argon2id
- Refresh tokens are stored hashed; plaintext refresh is never persisted
- Rotation + family revocation mitigates stolen refresh replay
- Brute-force mitigation via auth flow rate limits
- Security-sensitive events are recorded in `auth_event_log`
- Impersonation requires admin auth and produces both audit and auth event logs
