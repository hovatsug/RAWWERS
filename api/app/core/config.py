from functools import lru_cache
from uuid import UUID

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = Field(default="development", alias="APP_ENV")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")

    database_url: str = Field(alias="DATABASE_URL")
    redis_url: str = Field(alias="REDIS_URL")

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

    def admin_user_id_set(self) -> set[UUID]:
        values = [item.strip() for item in self.admin_user_ids.split(",") if item.strip()]
        result: set[UUID] = set()
        for value in values:
            result.add(UUID(value))
        return result


@lru_cache
def get_settings() -> Settings:
    return Settings()
