"""A production environment that passes every startup guard, for tests.

Values are well-formed and obviously not real (repeated hex digits); no
service is reached with them. Each guard test changes one value and expects
the matching refusal (tests/test_production_guard.py).
"""
from __future__ import annotations

import base64

GOOD_PRODUCTION: dict[str, str] = {
    "APP_ENV": "production",
    "DEPLOYMENT_MODE": "test",
    "LOG_LEVEL": "INFO",
    "DATABASE_URL": "postgresql+psycopg2://rawwers:" + "4d" * 12 + "@postgres:5432/rawwers",
    "REDIS_URL": "redis://redis:6379/0",
    "APP_PUBLIC_URL": "https://admin.rawwers.com",
    "API_PUBLIC_URL": "https://api.rawwers.com",
    "CORS_ALLOW_ORIGINS": "https://admin.rawwers.com",
    "CONNECT_RETURN_URL": "https://api.rawwers.com/v1/payouts/connect/return",
    "CONNECT_REFRESH_URL": "https://api.rawwers.com/v1/payouts/connect/refresh",
    "TRUSTED_PROXY_IPS": "172.30.0.0/24",
    "TRUST_CLOUDFLARE": "true",
    "CLOUDFLARE_IPS_FILE": "",
    "AUTH_JWT_SECRET": "1a" * 32,
    "MEDIA_SHARE_TOKEN_PEPPER": "2b" * 32,
    "MEDIA_ACCESS_IP_HASH_PEPPER": "3c" * 32,
    "SHARE_VIEW_FINGERPRINT_PEPPER": "4d" * 32,
    "RISK_IP_HASH_PEPPER": "5e" * 32,
    "RISK_DEVICE_HASH_PEPPER": "6f" * 32,
    "RISK_SESSION_HASH_PEPPER": "7a" * 32,
    "ADMIN_API_KEYS": "8b" * 32,
    "ADDRESS_ENCRYPTION_KEYS": base64.urlsafe_b64encode(b"\x01" * 32).decode(),
    "UNSUBSCRIBE_SIGNING_KEYS": "k1:" + "9c" * 32,
    "STRIPE_SECRET_KEY": "sk_test_" + "0d" * 16,
    "STRIPE_WEBHOOK_SECRET": "whsec_" + "1e" * 16,
    "R2_ENDPOINT_URL": "https://r2.invalid",
    "R2_ACCESS_KEY_ID": "2f" * 16,
    "R2_SECRET_ACCESS_KEY": "3a" * 32,
    "R2_BUCKET": "rawwers-media",
    "R2_REGION": "auto",
    "EMAIL_SENDING_ENABLED": "true",
    "BREVO_API_KEY": "xkeysib-" + "4b" * 32,
    "BREVO_SENDER_EMAIL": "hello@mail.rawwers.com",
    "AUTH_DEV_BYPASS": "false",
    "ALLOW_UNVERIFIED_PRO": "false",
    "STRIPE_WEBHOOK_ALLOW_UNVERIFIED": "false",
    "MUX_FAKE": "false",
    "STARTUP_WARMUP": "false",
}
