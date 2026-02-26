from functools import lru_cache
from uuid import UUID

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = Field(default="development", alias="APP_ENV")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")

    database_url: str = Field(alias="DATABASE_URL")
    primary_database_url: str | None = Field(default=None, alias="PRIMARY_DATABASE_URL")
    replica_database_url: str | None = Field(default=None, alias="REPLICA_DATABASE_URL")
    max_replica_lag_seconds: int = Field(default=15, alias="MAX_REPLICA_LAG_SECONDS")
    redis_url: str = Field(alias="REDIS_URL")
    public_cache_enabled: bool = Field(default=True, alias="PUBLIC_CACHE_ENABLED")
    discover_cache_ttl_seconds: int = Field(default=60, alias="DISCOVER_CACHE_TTL_SECONDS")
    pro_public_cache_ttl_seconds: int = Field(default=60, alias="PRO_PUBLIC_CACHE_TTL_SECONDS")
    outbox_batch_size: int = Field(default=100, alias="OUTBOX_BATCH_SIZE")
    outbox_max_attempts: int = Field(default=10, alias="OUTBOX_MAX_ATTEMPTS")

    r2_endpoint_url: str = Field(alias="R2_ENDPOINT_URL")
    r2_access_key_id: str = Field(alias="R2_ACCESS_KEY_ID")
    r2_secret_access_key: str = Field(alias="R2_SECRET_ACCESS_KEY")
    r2_bucket: str = Field(alias="R2_BUCKET")
    r2_region: str = Field(alias="R2_REGION")

    mux_token_id: str = Field(alias="MUX_TOKEN_ID")
    mux_token_secret: str = Field(alias="MUX_TOKEN_SECRET")
    mux_webhook_secret: str = Field(default="", alias="MUX_WEBHOOK_SECRET")
    mux_signing_key_id: str = Field(default="", alias="MUX_SIGNING_KEY_ID")
    mux_signing_key_private: str = Field(default="", alias="MUX_SIGNING_KEY_PRIVATE")

    stripe_secret_key: str = Field(default="", alias="STRIPE_SECRET_KEY")
    stripe_webhook_secret: str = Field(default="", alias="STRIPE_WEBHOOK_SECRET")
    stripe_api_version: str | None = Field(default=None, alias="STRIPE_API_VERSION")
    stripe_webhook_allow_unverified: bool = Field(default=False, alias="STRIPE_WEBHOOK_ALLOW_UNVERIFIED")

    platform_fee_bps: int = Field(default=2000, alias="PLATFORM_FEE_BPS")
    app_public_url: str = Field(default="http://localhost:3000", alias="APP_PUBLIC_URL")
    admin_user_ids: str = Field(default="", alias="ADMIN_USER_IDS")
    ban_enforcement_mode: str = Field(default="strict", alias="BAN_ENFORCEMENT_MODE")
    allow_unverified_pro: bool = Field(default=False, alias="ALLOW_UNVERIFIED_PRO")
    reward_points_per_eur: int = Field(default=100, alias="REWARD_POINTS_PER_EUR")
    reward_max_discount_percent: int = Field(default=20, alias="REWARD_MAX_DISCOUNT_PERCENT")
    llm_provider: str = Field(default="mock", alias="LLM_PROVIDER")
    openai_api_key: str = Field(default="", alias="OPENAI_API_KEY")
    openai_model: str = Field(default="", alias="OPENAI_MODEL")
    llm_max_tokens_per_thread: int = Field(default=4000, alias="LLM_MAX_TOKENS_PER_THREAD")
    llm_max_messages_per_thread: int = Field(default=50, alias="LLM_MAX_MESSAGES_PER_THREAD")
    telephony_provider: str = Field(default="mock", alias="TELEPHONY_PROVIDER")
    telephony_from_e164: str = Field(default="", alias="TELEPHONY_FROM_E164")
    telephony_webhook_secret: str = Field(default="", alias="TELEPHONY_WEBHOOK_SECRET")
    call_rate_limit_per_user_per_day: int = Field(default=2, alias="CALL_RATE_LIMIT_PER_USER_PER_DAY")
    call_rate_limit_per_pro_per_day: int = Field(default=20, alias="CALL_RATE_LIMIT_PER_PRO_PER_DAY")
    max_json_body_bytes: int = Field(default=1_048_576, alias="MAX_JSON_BODY_BYTES")
    max_chat_message_length: int = Field(default=2000, alias="MAX_CHAT_MESSAGE_LENGTH")
    max_review_text_length: int = Field(default=2000, alias="MAX_REVIEW_TEXT_LENGTH")
    max_upload_bytes: int = Field(default=25_000_000, alias="MAX_UPLOAD_BYTES")
    allowed_upload_mime_types: str = Field(
        default="image/jpeg,image/png,image/webp,video/mp4",
        alias="ALLOWED_UPLOAD_MIME_TYPES",
    )
    rate_limit_public_read_per_min: int = Field(default=120, alias="RATE_LIMIT_PUBLIC_READ_PER_MIN")
    rate_limit_auth_mutation_per_min: int = Field(default=30, alias="RATE_LIMIT_AUTH_MUTATION_PER_MIN")
    rate_limit_chat_messages_per_min: int = Field(default=10, alias="RATE_LIMIT_CHAT_MESSAGES_PER_MIN")
    rate_limit_reviews_per_day: int = Field(default=5, alias="RATE_LIMIT_REVIEWS_PER_DAY")
    rate_limit_referral_claims_per_day: int = Field(default=3, alias="RATE_LIMIT_REFERRAL_CLAIMS_PER_DAY")
    rate_limit_payments_per_hour: int = Field(default=10, alias="RATE_LIMIT_PAYMENTS_PER_HOUR")
    rate_limit_uploads_per_hour: int = Field(default=30, alias="RATE_LIMIT_UPLOADS_PER_HOUR")
    rate_limit_admin_per_min: int = Field(default=60, alias="RATE_LIMIT_ADMIN_PER_MIN")
    admin_ip_allowlist: str = Field(default="", alias="ADMIN_IP_ALLOWLIST")
    admin_api_keys: str = Field(default="", alias="ADMIN_API_KEYS")
    search_provider: str = Field(default="none", alias="SEARCH_PROVIDER")
    search_enabled: bool = Field(default=False, alias="SEARCH_ENABLED")
    search_index_prefix: str = Field(default="rawwers_dev", alias="SEARCH_INDEX_PREFIX")
    meili_url: str = Field(default="http://localhost:7700", alias="MEILI_URL")
    meili_api_key: str = Field(default="", alias="MEILI_API_KEY")
    typesense_url: str = Field(default="", alias="TYPESENSE_URL")
    typesense_api_key: str = Field(default="", alias="TYPESENSE_API_KEY")
    search_fallback_cache_ttl_seconds: int = Field(default=30, alias="SEARCH_FALLBACK_CACHE_TTL_SECONDS")
    auth_jwt_secret: str = Field(default="dev-insecure-auth-secret", alias="AUTH_JWT_SECRET")
    auth_access_token_ttl_minutes: int = Field(default=15, alias="AUTH_ACCESS_TOKEN_TTL_MINUTES")
    auth_refresh_token_ttl_days: int = Field(default=30, alias="AUTH_REFRESH_TOKEN_TTL_DAYS")
    auth_email_verification_ttl_minutes: int = Field(default=30, alias="AUTH_EMAIL_VERIFICATION_TTL_MINUTES")
    auth_password_reset_ttl_minutes: int = Field(default=30, alias="AUTH_PASSWORD_RESET_TTL_MINUTES")
    auth_dev_bypass: bool = Field(default=False, alias="AUTH_DEV_BYPASS")
    notification_default_timezone: str = Field(default="Europe/Lisbon", alias="NOTIFICATION_DEFAULT_TIMEZONE")
    notification_critical_bypass_quiet_hours: bool = Field(default=True, alias="NOTIFICATION_CRITICAL_BYPASS_QUIET_HOURS")
    rate_limit_notifications_email_per_day: int = Field(default=20, alias="RATE_LIMIT_NOTIFICATIONS_EMAIL_PER_DAY")
    rate_limit_notifications_inapp_per_day: int = Field(default=60, alias="RATE_LIMIT_NOTIFICATIONS_INAPP_PER_DAY")
    rate_limit_notifications_burst_per_min: int = Field(default=30, alias="RATE_LIMIT_NOTIFICATIONS_BURST_PER_MIN")

    def admin_user_id_set(self) -> set[UUID]:
        values = [item.strip() for item in self.admin_user_ids.split(",") if item.strip()]
        result: set[UUID] = set()
        for value in values:
            result.add(UUID(value))
        return result

    def admin_ip_allowlist_set(self) -> set[str]:
        return {item.strip() for item in self.admin_ip_allowlist.split(",") if item.strip()}

    def admin_api_key_set(self) -> set[str]:
        return {item.strip() for item in self.admin_api_keys.split(",") if item.strip()}

    def allowed_upload_mime_type_set(self) -> set[str]:
        return {item.strip().lower() for item in self.allowed_upload_mime_types.split(",") if item.strip()}


@lru_cache
def get_settings() -> Settings:
    return Settings()
