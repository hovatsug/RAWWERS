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

    def admin_user_id_set(self) -> set[UUID]:
        values = [item.strip() for item in self.admin_user_ids.split(",") if item.strip()]
        result: set[UUID] = set()
        for value in values:
            result.add(UUID(value))
        return result


@lru_cache
def get_settings() -> Settings:
    return Settings()
