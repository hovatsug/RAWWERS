from functools import lru_cache
from uuid import UUID

from urllib.parse import urlsplit

from pydantic import Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict



#: The one Stripe API version: what our calls send, what the webhook endpoints
#: are pinned to (scripts/register_stripe_webhook.py), and what the captured
#: test fixtures are rendered in. The account's default when it was chosen,
#: so events Stripe renders by default are in it too. Change all three
#: together - tests/test_stripe_api_version.py fails otherwise.
STRIPE_API_VERSION = "2025-12-15.clover"

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = Field(default="development", alias="APP_ENV")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")
    # Error reporting (core/sentry.py). Empty DSN: nothing is sent. Create the
    # Sentry organisation in the EU region; its DSNs end in .de.sentry.io.
    sentry_dsn: str = Field(default="", alias="SENTRY_DSN")
    sentry_environment: str = Field(default="", alias="SENTRY_ENVIRONMENT")
    sentry_release: str = Field(default="", alias="SENTRY_RELEASE")
    sentry_traces_sample_rate: float = Field(default=0.0, ge=0.0, le=1.0, alias="SENTRY_TRACES_SAMPLE_RATE")

    database_url: str = Field(alias="DATABASE_URL")
    primary_database_url: str | None = Field(default=None, alias="PRIMARY_DATABASE_URL")
    replica_database_url: str | None = Field(default=None, alias="REPLICA_DATABASE_URL")
    max_replica_lag_seconds: int = Field(default=15, alias="MAX_REPLICA_LAG_SECONDS")
    redis_url: str = Field(alias="REDIS_URL")
    public_cache_enabled: bool = Field(default=True, alias="PUBLIC_CACHE_ENABLED")
    # Wake the process before it takes traffic (app/services/warmup.py).
    startup_warmup: bool = Field(default=True, alias="STARTUP_WARMUP")
    warmup_home_country: str = Field(default="PT", alias="WARMUP_HOME_COUNTRY")
    warmup_home_city: str = Field(default="Lisbon", alias="WARMUP_HOME_CITY")
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
    # Express accounts take a country at creation that cannot be changed
    # later; used only when a photographer's own country is unknown.
    default_connect_country: str = Field(default="PT", alias="DEFAULT_CONNECT_COUNTRY")
    # The currency of a new user or photographer whose country gives none
    # (UK first, 2026-11-13: GBP). Which currencies may be used at all is the
    # admin setting in `currency_settings` (app/services/currencies.py).
    default_currency: str = Field(default="GBP", alias="DEFAULT_CURRENCY")
    # Where Stripe returns the photographer after hosted onboarding: the API's
    # own static pages (app/services/connect_return.py), which hand over to
    # the pro app. Stripe refuses a custom scheme, so these are http(s) -
    # https in production (see _connect_urls_are_web_addresses). Dev points
    # them at an address the simulator can reach.
    connect_return_url: str = Field(default="http://localhost:8000/v1/payouts/connect/return", alias="CONNECT_RETURN_URL")
    connect_refresh_url: str = Field(default="http://localhost:8000/v1/payouts/connect/refresh", alias="CONNECT_REFRESH_URL")
    stripe_webhook_secret: str = Field(default="", alias="STRIPE_WEBHOOK_SECRET")
    stripe_api_version: str = Field(default=STRIPE_API_VERSION, alias="STRIPE_API_VERSION")
    stripe_webhook_allow_unverified: bool = Field(default=False, alias="STRIPE_WEBHOOK_ALLOW_UNVERIFIED")

    platform_fee_bps: int = Field(default=2000, alias="PLATFORM_FEE_BPS")
    app_public_url: str = Field(default="http://localhost:3000", alias="APP_PUBLIC_URL")
    # Email through Brevo (services/mail.py, docs/BREVO_SETUP.md). Nothing is
    # delivered without BREVO_API_KEY and BREVO_SENDER_EMAIL; without them, or
    # with sending off, email goes to the console provider (logged only).
    brevo_api_key: str = Field(default="", alias="BREVO_API_KEY")
    brevo_sender_email: str = Field(default="", alias="BREVO_SENDER_EMAIL")
    brevo_sender_name: str = Field(default="RAWWERS", alias="BREVO_SENDER_NAME")
    brevo_reply_to: str = Field(default="", alias="BREVO_REPLY_TO")
    # The token Brevo's delivery-event webhook must carry. Empty: the route
    # answers 404 (dev, where Brevo cannot reach it).
    brevo_webhook_token: str = Field(default="", alias="BREVO_WEBHOOK_TOKEN")
    # Unset: off in production, on elsewhere. Production sends only once this
    # is set true (with the key, the sender and UNSUBSCRIBE_SIGNING_KEYS).
    email_sending_enabled: bool | None = Field(default=None, alias="EMAIL_SENDING_ENABLED")
    # Outside production, the only addresses ever delivered to, comma-separated
    # and exact (no domains). Empty: nothing is delivered, only logged.
    email_dev_allowlist: str = Field(default="", alias="EMAIL_DEV_ALLOWLIST")
    # Where this API is reached from outside: the one-click unsubscribe URL
    # in email headers points here.
    api_public_url: str = Field(default="http://localhost:8000", alias="API_PUBLIC_URL")
    # Unsubscribe link signing keys, "<key id>:<secret>" comma-separated,
    # newest first (services/unsubscribe.py). Required in production.
    unsubscribe_signing_keys: str = Field(default="", alias="UNSUBSCRIBE_SIGNING_KEYS")
    cors_allow_origins: str = Field(default="", alias="CORS_ALLOW_ORIGINS")
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
    # While the photographer is online, how long the assistant waits for them
    # to answer before it does (app/services/chat_assistant.py).
    chat_assistant_hold_seconds: int = Field(default=120, alias="CHAT_ASSISTANT_HOLD_SECONDS")
    # How long a heartbeat keeps a photographer online: the presence key's
    # expiry, and so the longest a closed app can still show a dot
    # (app/services/presence.py).
    presence_window_seconds: int = Field(default=300, alias="PRESENCE_WINDOW_SECONDS")
    # "Available now" (app/services/available_now.py, deadlines.py): how
    # fresh the heartbeat must be, how long the toggle lasts, and the short
    # clock a short-notice booking runs on.
    available_now_fresh_seconds: int = Field(default=120, alias="AVAILABLE_NOW_FRESH_SECONDS")
    available_now_hours: int = Field(default=4, alias="AVAILABLE_NOW_HOURS")
    short_notice_accept_minutes: int = Field(default=30, alias="SHORT_NOTICE_ACCEPT_MINUTES")
    short_notice_pay_minutes: int = Field(default=30, alias="SHORT_NOTICE_PAY_MINUTES")
    payment_window_hours: int = Field(default=24, alias="PAYMENT_WINDOW_HOURS")
    # Payment must land at least this long before the shoot starts - the
    # photographer needs to know before they set off.
    pay_deadline_margin_minutes: int = Field(default=30, alias="PAY_DEADLINE_MARGIN_MINUTES")
    # Heartbeats closer together than this are acknowledged and not written.
    presence_heartbeat_min_interval_seconds: int = Field(default=50, alias="PRESENCE_HEARTBEAT_MIN_INTERVAL_SECONDS")
    max_review_text_length: int = Field(default=2000, alias="MAX_REVIEW_TEXT_LENGTH")
    max_upload_bytes: int = Field(default=25_000_000, alias="MAX_UPLOAD_BYTES")
    # A delivered proof is the client's final download, a full-size export:
    # a 60 MP JPEG at high quality runs past 25 MB. Measured 2026-10-31 on a
    # 60 MP frame: about 7 s and 760 MB of worker memory, whatever its file
    # size, since the decoded pixels dominate.
    delivery_max_upload_bytes: int = Field(default=50_000_000, alias="DELIVERY_MAX_UPLOAD_BYTES")
    # Gear evidence is a camera file, not a photo. Real ones are 16-58 MB, so the
    # 25 MB photo cap would refuse a Sony A7 III's (25.6 MB) outright.
    gear_evidence_max_bytes: int = Field(default=150_000_000, alias="GEAR_EVIDENCE_MAX_BYTES")
    gear_evidence_mime_types: str = Field(
        default="application/octet-stream,image/jpeg,image/heic,image/tiff",
        alias="GEAR_EVIDENCE_MIME_TYPES",
    )
    # Checked on the file name as well as the MIME type: RAW files have no
    # agreed type, and most arrive as application/octet-stream.
    gear_evidence_extensions: str = Field(
        default="cr3,cr2,arw,nef,nrw,raf,rw2,orf,dng,pef,srw,3fr,jpg,jpeg,heic,tif,tiff",
        alias="GEAR_EVIDENCE_EXTENSIONS",
    )
    allowed_upload_mime_types: str = Field(
        default="image/jpeg,image/png,image/webp,video/mp4",
        alias="ALLOWED_UPLOAD_MIME_TYPES",
    )
    # Niche banners, set by an admin. Formats and the size cap are checked when
    # the upload starts and again on the object itself; the minimum size is
    # what a full-width banner needs on a 3x phone.
    niche_banner_mime_types: str = Field(default="image/jpeg,image/png,image/webp", alias="NICHE_BANNER_MIME_TYPES")
    niche_banner_max_bytes: int = Field(default=15_000_000, alias="NICHE_BANNER_MAX_BYTES")
    niche_banner_min_width: int = Field(default=1600, alias="NICHE_BANNER_MIN_WIDTH")
    niche_banner_min_height: int = Field(default=900, alias="NICHE_BANNER_MIN_HEIGHT")
    niche_banner_tile_width: int = Field(default=800, alias="NICHE_BANNER_TILE_WIDTH")
    niche_banner_hero_width: int = Field(default=2048, alias="NICHE_BANNER_HERO_WIDTH")
    niche_banner_placeholder_width: int = Field(default=24, alias="NICHE_BANNER_PLACEHOLDER_WIDTH")
    niche_banner_tagline_max: int = Field(default=60, alias="NICHE_BANNER_TAGLINE_MAX")
    niche_banner_alt_max: int = Field(default=250, alias="NICHE_BANNER_ALT_MAX")
    # White title over the scrimmed image must reach at least this contrast
    # (WCAG AA for normal text); the scrim is never lighter than the floor.
    niche_banner_min_contrast: float = Field(default=4.5, alias="NICHE_BANNER_MIN_CONTRAST")
    niche_banner_scrim_floor: float = Field(default=0.25, alias="NICHE_BANNER_SCRIM_FLOOR")
    niche_banner_scrim_ceiling: float = Field(default=0.85, alias="NICHE_BANNER_SCRIM_CEILING")
    # "Meet the photographer". The presentation video's slot stays empty until
    # this is on and videos exist; nothing produces one yet.
    presentation_video_enabled: bool = Field(default=False, alias="PRESENTATION_VIDEO_ENABLED")
    # The one line of a photographer's interview a Discover card may show.
    interview_teaser_max_chars: int = Field(default=90, alias="INTERVIEW_TEASER_MAX_CHARS")
    rate_limit_public_read_per_min: int = Field(default=120, alias="RATE_LIMIT_PUBLIC_READ_PER_MIN")
    rate_limit_auth_mutation_per_min: int = Field(default=30, alias="RATE_LIMIT_AUTH_MUTATION_PER_MIN")
    rate_limit_chat_messages_per_min: int = Field(default=10, alias="RATE_LIMIT_CHAT_MESSAGES_PER_MIN")
    rate_limit_thread_creations_per_day: int = Field(default=5, alias="RATE_LIMIT_THREAD_CREATIONS_PER_DAY")
    rate_limit_reviews_per_day: int = Field(default=5, alias="RATE_LIMIT_REVIEWS_PER_DAY")
    rate_limit_referral_claims_per_day: int = Field(default=3, alias="RATE_LIMIT_REFERRAL_CLAIMS_PER_DAY")
    rate_limit_payments_per_hour: int = Field(default=10, alias="RATE_LIMIT_PAYMENTS_PER_HOUR")
    rate_limit_uploads_per_hour: int = Field(default=30, alias="RATE_LIMIT_UPLOADS_PER_HOUR")
    # Proofs only: a wedding is 400-1000 photos, so a delivery cannot share
    # the 30 an hour every other upload counts against.
    rate_limit_delivery_uploads_per_hour: int = Field(default=2000, alias="RATE_LIMIT_DELIVERY_UPLOADS_PER_HOUR")
    # Per delivery token (a paired Lightroom), on top of the hourly bucket: a
    # token that leaks can add at most this many photos a day before it is
    # revoked (owner's decision 1).
    rate_limit_delivery_token_uploads_per_day: int = Field(default=5000, alias="RATE_LIMIT_DELIVERY_TOKEN_UPLOADS_PER_DAY")
    # The newest Lightroom plugin, raised on every released build; an older
    # one is told an update is available (owner's decision 7).
    lightroom_plugin_latest_version: str = Field(default="1.0.0", alias="LIGHTROOM_PLUGIN_LATEST_VERSION")
    # The oldest plugin still supported, raised only for a breaking change; an
    # older one is refused (426) until it is updated. Never above the newest.
    lightroom_plugin_min_version: str = Field(default="1.0.0", alias="LIGHTROOM_PLUGIN_MIN_VERSION")
    # Where the pro app's Connect Lightroom screen downloads the plugin; empty
    # hides its button (owner's decision 5). https only.
    lightroom_plugin_download_url: str = Field(default="", alias="LIGHTROOM_PLUGIN_DOWNLOAD_URL")
    # Uploads started and untouched this long are removed (owner's decision 4).
    unfinished_upload_max_age_hours: int = Field(default=24, alias="UNFINISHED_UPLOAD_MAX_AGE_HOURS")
    rate_limit_admin_per_min: int = Field(default=60, alias="RATE_LIMIT_ADMIN_PER_MIN")
    rate_limit_admin_bi_per_min: int = Field(default=240, alias="RATE_LIMIT_ADMIN_BI_PER_MIN")
    admin_ip_allowlist: str = Field(default="", alias="ADMIN_IP_ALLOWLIST")
    # The proxies in front of the API (Caddy; the web server for admin calls),
    # as IPs or CIDRs, comma-separated. X-Forwarded-For is read only on a
    # request whose connection comes from one of them (core/client_ip.py).
    # Empty: the header is never read and the connection address is used.
    trusted_proxy_ips: str = Field(default="", alias="TRUSTED_PROXY_IPS")
    # At most this many trusted proxies are stepped back through.
    trusted_proxy_hops: int = Field(default=1, ge=1, le=5, alias="TRUSTED_PROXY_HOPS")
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
    default_gig_consent_level: str = Field(default="none", alias="DEFAULT_GIG_CONSENT_LEVEL")
    media_signed_url_ttl_seconds: int = Field(default=120, alias="MEDIA_SIGNED_URL_TTL_SECONDS")
    media_share_token_pepper: str = Field(default="dev-media-share-pepper", alias="MEDIA_SHARE_TOKEN_PEPPER")
    media_access_ip_hash_pepper: str = Field(default="dev-media-ip-pepper", alias="MEDIA_ACCESS_IP_HASH_PEPPER")
    # How long the client's raw IP is kept on their download log, for
    # chargeback evidence. 120 days: card networks generally let a cardholder
    # dispute for 120 days, and downloads come after the shoot.
    media_access_raw_ip_retention_days: int = Field(default=120, alias="MEDIA_ACCESS_RAW_IP_RETENTION_DAYS")
    media_watermark_text_template: str = Field(default="RAWWERS", alias="MEDIA_WATERMARK_TEXT_TEMPLATE")
    media_watermark_include_pro_name: bool = Field(default=False, alias="MEDIA_WATERMARK_INCLUDE_PRO_NAME")
    share_view_fingerprint_pepper: str = Field(default="dev-share-fingerprint-pepper", alias="SHARE_VIEW_FINGERPRINT_PEPPER")
    reward_balance_floor: int = Field(default=-5000, alias="REWARD_BALANCE_FLOOR")
    #: Fernet keys for shipping addresses, comma-separated, newest first (the
    #: first encrypts; all decrypt, for rotation). Required in production;
    #: elsewhere a fixed development key is used (services/addresses.py).
    address_encryption_keys: str = Field(default="", alias="ADDRESS_ENCRYPTION_KEYS")
    #: Marketing-use consent (closed beta): the RAW credit (reward points) a
    #: client earns for a 12-month grant; 6 months earns half, 24 one and a
    #: half. Once per booking, at most this many grants a month per client.
    marketing_consent_credit_points: int = Field(default=100, alias="MARKETING_CONSENT_CREDIT_POINTS")
    marketing_consent_monthly_cap: int = Field(default=3, alias="MARKETING_CONSENT_MONTHLY_CAP")
    dispute_window_days: int = Field(default=30, alias="DISPUTE_WINDOW_DAYS")
    dispute_open_limit_30d: int = Field(default=3, alias="DISPUTE_OPEN_LIMIT_30D")
    dispute_messages_per_day: int = Field(default=10, alias="DISPUTE_MESSAGES_PER_DAY")
    risk_ip_hash_pepper: str = Field(default="dev-risk-ip-pepper", alias="RISK_IP_HASH_PEPPER")
    risk_device_hash_pepper: str = Field(default="dev-risk-device-pepper", alias="RISK_DEVICE_HASH_PEPPER")
    risk_session_hash_pepper: str = Field(default="dev-risk-session-pepper", alias="RISK_SESSION_HASH_PEPPER")
    risk_signal_retention_days: int = Field(default=90, alias="RISK_SIGNAL_RETENTION_DAYS")

    booking_response_deadline_hours: int = Field(default=24, alias="BOOKING_RESPONSE_DEADLINE_HOURS")
    # The outbox is the delivery path for every email and every in-app
    # notification, so this interval is the floor on how long a user waits
    # to hear anything. Kept short (30s) rather than matched to the other
    # sweeps, which are minutes-to-hours because they reconcile state
    # nobody is waiting on.
    outbox_dispatch_interval_seconds: int = Field(default=30, alias="OUTBOX_DISPATCH_INTERVAL_SECONDS")
    # Follow-ups and reminders are user-facing nudges with delays measured in
    # minutes (the earliest fires at 60), so the sweep interval only needs to
    # be well under that granularity, not seconds-fresh like the outbox.
    followup_jobs_interval_seconds: int = Field(default=60, alias="FOLLOWUP_JOBS_INTERVAL_SECONDS")
    reminders_interval_seconds: int = Field(default=60, alias="REMINDERS_INTERVAL_SECONDS")
    booking_request_expiry_sweep_interval_seconds: int = Field(default=60, alias="BOOKING_REQUEST_EXPIRY_SWEEP_INTERVAL_SECONDS")
    # The Stripe reconcile job (services/stripe_reconcile): how often it runs,
    # how far back it looks, how old a payment must be before it is checked
    # (its webhook may still be on its way), and a dry run that only reports.
    stripe_reconcile_interval_seconds: int = Field(default=900, alias="STRIPE_RECONCILE_INTERVAL_SECONDS")
    stripe_reconcile_lookback_hours: int = Field(default=72, alias="STRIPE_RECONCILE_LOOKBACK_HOURS")
    stripe_reconcile_min_age_seconds: int = Field(default=300, alias="STRIPE_RECONCILE_MIN_AGE_SECONDS")
    stripe_reconcile_dry_run: bool = Field(default=False, alias="STRIPE_RECONCILE_DRY_RUN")
    # Mux videos whose webhook never came (services/mux_sync): how often the
    # job runs, how long a video must sit uploading or processing before it
    # asks Mux, and the age past which it stops asking.
    mux_sync_interval_seconds: int = Field(default=300, alias="MUX_SYNC_INTERVAL_SECONDS")
    mux_sync_stale_minutes: int = Field(default=10, alias="MUX_SYNC_STALE_MINUTES")
    mux_sync_max_age_hours: int = Field(default=48, alias="MUX_SYNC_MAX_AGE_HOURS")
    payout_hold_release_sweep_interval_seconds: int = Field(default=3600, alias="PAYOUT_HOLD_RELEASE_SWEEP_INTERVAL_SECONDS")
    dispute_escalation_sweep_interval_seconds: int = Field(default=3600, alias="DISPUTE_ESCALATION_SWEEP_INTERVAL_SECONDS")
    stuck_booking_sweep_interval_seconds: int = Field(default=3600, alias="STUCK_BOOKING_SWEEP_INTERVAL_SECONDS")
    refund_reconcile_interval_seconds: int = Field(default=900, alias="REFUND_RECONCILE_INTERVAL_SECONDS")
    stuck_booking_max_age_hours: int = Field(default=720, alias="STUCK_BOOKING_MAX_AGE_HOURS")
    scheduled_sweep_batch_size: int = Field(default=100, alias="SCHEDULED_SWEEP_BATCH_SIZE")

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

    def gear_evidence_mime_type_set(self) -> set[str]:
        return {item.strip().lower() for item in self.gear_evidence_mime_types.split(",") if item.strip()}

    def gear_evidence_extension_set(self) -> set[str]:
        return {item.strip().lower().lstrip(".") for item in self.gear_evidence_extensions.split(",") if item.strip()}

    def allowed_upload_mime_type_set(self) -> set[str]:
        return {item.strip().lower() for item in self.allowed_upload_mime_types.split(",") if item.strip()}

    def niche_banner_mime_type_set(self) -> set[str]:
        return {item.strip().lower() for item in self.niche_banner_mime_types.split(",") if item.strip()}

    def cors_allow_origin_list(self) -> list[str]:
        configured = [item.strip() for item in self.cors_allow_origins.split(",") if item.strip()]
        if configured:
            return configured
        return [self.app_public_url, "http://localhost:3000", "http://127.0.0.1:3000"]

    @property
    def is_production(self) -> bool:
        return self.app_env.lower() in {"prod", "production"}

    @property
    def email_sending_on(self) -> bool:
        if self.email_sending_enabled is None:
            return not self.is_production
        return self.email_sending_enabled

    @property
    def email_dev_allowlist_set(self) -> frozenset[str]:
        return frozenset(a.strip().lower() for a in self.email_dev_allowlist.split(",") if a.strip())

    @model_validator(mode="after")
    def _production_email_is_complete(self) -> "Settings":
        """Production with sending on must be able to send real, unsubscribable mail."""
        if self.is_production and self.email_sending_on:
            missing = [
                name for name, value in (
                    ("BREVO_API_KEY", self.brevo_api_key),
                    ("BREVO_SENDER_EMAIL", self.brevo_sender_email),
                    ("UNSUBSCRIBE_SIGNING_KEYS", self.unsubscribe_signing_keys),
                ) if not value
            ]
            if missing:
                raise ValueError(f"EMAIL_SENDING_ENABLED is on in production but {', '.join(missing)} is not set")
        return self

    @model_validator(mode="after")
    def _connect_urls_are_web_addresses(self) -> "Settings":
        """Refuse, at startup, a Connect return URL Stripe or a phone cannot use.

        Stripe rejects anything but http(s) ("Not a valid URL") - the old
        rawwerspro:// default meant no onboarding link could be created at
        all, and only showed up as a 502 when a photographer tapped. In
        production a photographer's browser must also land on https.
        """
        production = self.app_env.lower() in {"prod", "production"}
        for name, value in (("CONNECT_RETURN_URL", self.connect_return_url), ("CONNECT_REFRESH_URL", self.connect_refresh_url)):
            parts = urlsplit(value or "")
            if parts.scheme not in {"http", "https"} or not parts.hostname:
                raise ValueError(
                    f"{name} must be an http:// or https:// address with a host (Stripe refuses anything else); got {value!r}"
                )
            if production and parts.scheme != "https":
                raise ValueError(f"{name} must use https:// when APP_ENV is production; got {value!r}")
        return self



@lru_cache
def get_settings() -> Settings:
    return Settings()
