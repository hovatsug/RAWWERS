# Deploy readiness audit: the first Hetzner test deploy (2026-11-21)

What the code and configuration actually do, compared with
[DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md), before the first deploy to the
Hetzner server (CPX12: 2 vCPU, 2 GB RAM, 40 GB disk) behind Cloudflare. The
step-by-step is [DEPLOY_RUNBOOK.md](DEPLOY_RUNBOOK.md); secrets are in
[DEPLOY_SECRETS.md](DEPLOY_SECRETS.md). "Fixed" means fixed on the-shelf-wip
the same day; "LATER" means a BETA_SCOPE row.

## 1. What was wrong or missing before this audit

| # | Finding | State |
|---|---|---|
| 1 | `deploy/compose.prod.yml` published the API (8000) and the web (3000) directly, had **no Caddy and no Caddyfile** in the repository, no health checks, no memory limits, no log rotation, used `latest` tags, a Meilisearch nobody needs, and worker concurrency 4 + 4 (out of memory on 2 GB). The web got the whole secrets file. | Fixed: rewritten (Caddy only published, pinned network, limits, health, log rotation, one-off migrate job, web gets four variables) |
| 2 | `api/` had **no `.dockerignore`**: `COPY . /app` copies `api/.env` from a developer's checkout (real keys) and the tests into the image. | Fixed: `api/.dockerignore`; `build-and-push.sh` builds from `git archive` of the commit, never the working folder; `check-image.sh` scans the built image |
| 3 | The API image **ran as root**. | Fixed: user 10001 in the shipped `runtime` stage (dev/test stage keeps root) |
| 4 | `.github/workflows/deploy.yml` **deployed by itself** on every push to main and every `v*` tag, and copied `deploy/.env.prod.example` over the server's real env file. | Fixed: manual image build only; deploy jobs removed |
| 5 | `api/Makefile` `make deploy` rsynced `api/` to a server, built there with the **development** compose file (default passwords, Postgres and Redis ports published), and **held a server address** in this public repository. | Fixed: targets refuse and point to the runbook; the address is removed from the file (it stays in git history: see question 1) |
| 6 | The API served `/docs`, `/redoc`, `/openapi.json`, `/metrics`, `/health/ready`, `/health/replica` publicly in production. | Fixed: docs off in production (`API_DOCS_ENABLED`, refused if on), `/metrics` 404 in production, Caddy answers 404 for all of them and for `/v1/admin/*` and `/v1/dev/*` on the API host |
| 7 | Production **started with** a short or default `AUTH_JWT_SECRET`, dev peppers (`dev-risk-ip-pepper`...), a default database password, debug logging, the console mail provider, a live Stripe key on a test deployment, `MUX_FAKE`, CORS `*` or no CORS (then localhost origins were allowed). | Fixed: `api/app/core/production_guard.py` refuses all of these at start of the API, workers and beat, listing every problem in plain words; missing Mux keys do not stop it |
| 8 | Behind Cloudflare every visitor would have had Cloudflare's address: one shared rate limit per edge, and the admin allowlist useless. The checklist's plan (Caddy `trusted_proxies` + `TRUSTED_PROXY_HOPS=2`) trusts any caller's `X-Forwarded-For` chain. | Fixed: `TRUST_CLOUDFLARE`: `CF-Connecting-IP` believed only when the hop that reached Caddy is in Cloudflare's published ranges (one file, `api/app/core/cloudflare_ips.txt`); Caddy trusts no proxy |
| 9 | A test deployment in production mode would have **emailed anyone** who signed up (the allowlist applied only outside production). | Fixed: `DEPLOYMENT_MODE=test` (the default) keeps `EMAIL_DEV_ALLOWLIST` in force in production |
| 10 | No bootstrap script for reference data (camera reference, price caps, tax rule). | Fixed: `api/scripts/bootstrap_reference_data.py` (adds only what is missing; twice = nothing) |
| 11 | No way to see from outside which commit runs. | Fixed: `/healthz` returns `release` (the image tag); `deploy/scripts/version.sh` |
| 12 | Celery beat would write its schedule into `/app`, which the non-root user cannot. | Fixed: `-s /tmp/celerybeat-schedule` |
| 13 | `deploy/docker-compose.prod.yml` and `.staging.yml` (stale copies) and `deploy/.env.prod.example` (`change-me` passwords, `sk_live_` placeholder). | Removed; `deploy/.env.production.example` replaces the example |
| 14 | The web admin's proxy did not pass `CF-Connecting-IP` to the API. | Fixed (`web/app/api/admin/[...path]/route.ts`) |
| 16 | The Caddyfile's catch-all `http://` site swallowed Caddy's own http-to-https redirects for api and admin (found in the rehearsal) | Fixed: explicit `http://` sites for the two names redirect |
| 17 | Smoke accounts could not be removed: a foreign key that exists only in the migrations blocked the delete (found in the rehearsal) | Fixed: `delete_smoke_accounts.py` retries blocked deletes |
| 15 | CI's empty-database job ran production with `postgres`/`postgres`, `test` keys and email off, and expected `/openapi.json` 200. | Fixed: well-formed values that pass the guards; expects 404 for the docs (not run here: CI runs on push) |

## 2. Corrections to DEPLOY_CHECKLIST.md (made there the same day)

- Section 0 step 1: the settings production refuses are now the guard's list; step 4: `/openapi.json` is **404** in production.
- Section 2 "Client IP": the CDN instructions (`TRUSTED_PROXY_HOPS=2`, CDN ranges in Caddy and `TRUSTED_PROXY_IPS`) were unsafe; replaced by `TRUST_CLOUDFLARE`. The "check after deploy" used `/v1/admin/...` on the API host, which Caddy now hides; the check is through the admin host.
- Section 2: "the API does not refuse a short `AUTH_JWT_SECRET`" is no longer true.
- Section 2: "Build `api` and `worker` together" and the `make deploy` open question: production never builds; one image tag for every Python service; `make deploy` refuses.
- Section 2: the `deploy/docker-compose.*` warning: the files are gone.
- Section 3 "Niche banners": "the bucket's CORS rule (section 4)" pointed at the Mux section; the rule is in the runbook, step 18.
- Section 3 "Delivery uploads": the photo worker "needs 4 GB free"; the 2 GB test server runs it with concurrency 1 and a 1 GB limit, so a 60 MP proof may be killed: resize before real deliveries.
- Section 0 step 8 and section 3 M3: the fx command now runs inside the worker container (`deploy/scripts/dc exec worker ...`); both `-A` forms work (checked in the rehearsal).
- Section 4 (Mux): nothing said a cost alert comes before the first upload, that the WAF rule must let `/v1/webhooks/mux` through, or that the Pro app build must point at production.
- References to `deploy/.env.prod` and the old compose pair (also in `release_engineering.md`, `COMPANY_DETAILS_NEEDED.md`).

## 3. Settings: every variable

### 3a. The API, workers and beat (`api/app/core/config.py`, 179 settings)

All three read the same settings class, so the same table applies. "Secret":
treat as a secret. "Production": must set / leave default / set by the
compose file. "If missing or wrong": what happens. Everything not marked has a
safe default for the test deploy. Production values: `deploy/.env.production.example`.

| Setting | Default | Secret | Production | If missing or wrong |
|---|---|---|---|---|
| `APP_ENV` | `'development'` |  | set by compose.prod.yml (`production`) | the default applies |
| `DEPLOYMENT_MODE` | `'test'` |  | leave default | a wrong value: refuses to start (guard) |
| `API_DOCS_ENABLED` | `None` |  | leave default | a wrong value: refuses to start (guard) |
| `LOG_LEVEL` | `'INFO'` |  | leave default | a wrong value: refuses to start (guard) |
| `SENTRY_DSN` | `''` |  |  | the default applies |
| `SENTRY_ENVIRONMENT` | `''` |  |  | the default applies |
| `SENTRY_RELEASE` | `''` |  | set by compose.prod.yml (= IMAGE_TAG) | the default applies |
| `SENTRY_TRACES_SAMPLE_RATE` | `0.0` |  |  | the default applies |
| `DATABASE_URL` | `REQUIRED` | yes | built by compose.prod.yml from `POSTGRES_*` | does not start (`Field required`) |
| `PRIMARY_DATABASE_URL` | `None` |  |  | the default applies |
| `REPLICA_DATABASE_URL` | `None` |  |  | the default applies |
| `MAX_REPLICA_LAG_SECONDS` | `15` |  |  | the default applies |
| `REDIS_URL` | `REQUIRED` |  | set by compose.prod.yml | does not start (`Field required`) |
| `PUBLIC_CACHE_ENABLED` | `True` |  |  | the default applies |
| `STARTUP_WARMUP` | `True` |  |  | the default applies |
| `WARMUP_HOME_COUNTRY` | `'PT'` |  |  | the default applies |
| `WARMUP_HOME_CITY` | `'Lisbon'` |  |  | the default applies |
| `DISCOVER_CACHE_TTL_SECONDS` | `60` |  |  | the default applies |
| `PRO_PUBLIC_CACHE_TTL_SECONDS` | `60` |  |  | the default applies |
| `OUTBOX_BATCH_SIZE` | `100` |  |  | the default applies |
| `OUTBOX_MAX_ATTEMPTS` | `10` |  |  | the default applies |
| `R2_ENDPOINT_URL` | `REQUIRED` |  | must set | does not start (`Field required`) |
| `R2_ACCESS_KEY_ID` | `REQUIRED` |  | must set | does not start (`Field required`) |
| `R2_SECRET_ACCESS_KEY` | `REQUIRED` | yes | must set | does not start (`Field required`) |
| `R2_BUCKET` | `REQUIRED` |  | must set | does not start (`Field required`) |
| `R2_REGION` | `REQUIRED` |  | must set | does not start (`Field required`) |
| `MUX_TOKEN_ID` | `''` |  | empty until Mux prod | video says "not available"; webhooks 401 |
| `MUX_TOKEN_SECRET` | `''` | yes | empty until Mux prod | video says "not available"; webhooks 401 |
| `MUX_WEBHOOK_SECRET` | `''` | yes | empty until Mux prod | video says "not available"; webhooks 401 |
| `MUX_SIGNING_KEY_ID` | `''` |  | empty until Mux prod | video says "not available"; webhooks 401 |
| `MUX_SIGNING_KEY_PRIVATE` | `''` | yes | empty until Mux prod | video says "not available"; webhooks 401 |
| `STRIPE_SECRET_KEY` | `''` | yes | must set | refuses to start (guard names it) |
| `DEFAULT_CONNECT_COUNTRY` | `'PT'` |  |  | the default applies |
| `DEFAULT_CURRENCY` | `'GBP'` |  |  | the default applies |
| `CONNECT_RETURN_URL` | `'http://localhost:8000/v1/payouts/connect/ret...` |  | must set | refuses to start (guard names it) |
| `CONNECT_REFRESH_URL` | `'http://localhost:8000/v1/payouts/connect/ref...` |  | must set | refuses to start (guard names it) |
| `STRIPE_WEBHOOK_SECRET` | `''` | yes | must set | refuses to start (guard names it) |
| `STRIPE_API_VERSION` | `'2025-12-15.clover'` |  |  | the default applies |
| `STRIPE_WEBHOOK_ALLOW_UNVERIFIED` | `False` |  | leave default | a wrong value: refuses to start (guard) |
| `PLATFORM_FEE_BPS` | `2000` |  |  | the default applies |
| `APP_PUBLIC_URL` | `'http://localhost:3000'` |  | must set | refuses to start (guard names it) |
| `BREVO_API_KEY` | `''` | yes | must set | refuses to start (guard names it) |
| `BREVO_SENDER_EMAIL` | `''` |  | must set | refuses to start (guard names it) |
| `BREVO_SENDER_NAME` | `'RAWWERS'` |  |  | the default applies |
| `BREVO_REPLY_TO` | `''` |  |  | the default applies |
| `BREVO_WEBHOOK_TOKEN` | `''` | yes |  | the default applies |
| `EMAIL_SENDING_ENABLED` | `None` |  | must set | refuses to start (guard names it) |
| `EMAIL_DEV_ALLOWLIST` | `''` |  |  | the default applies |
| `API_PUBLIC_URL` | `'http://localhost:8000'` |  | must set | refuses to start (guard names it) |
| `UNSUBSCRIBE_SIGNING_KEYS` | `''` | yes | must set | refuses to start (guard names it) |
| `CORS_ALLOW_ORIGINS` | `''` |  | must set | refuses to start (guard names it) |
| `ADMIN_USER_IDS` | `''` |  |  | the default applies |
| `BAN_ENFORCEMENT_MODE` | `'strict'` |  |  | the default applies |
| `ALLOW_UNVERIFIED_PRO` | `False` |  | leave default | a wrong value: refuses to start (guard) |
| `REWARD_POINTS_PER_EUR` | `100` |  |  | the default applies |
| `REWARD_MAX_DISCOUNT_PERCENT` | `20` |  |  | the default applies |
| `LLM_PROVIDER` | `'mock'` |  |  | the default applies |
| `OPENAI_API_KEY` | `''` | yes |  | the default applies |
| `OPENAI_MODEL` | `''` |  |  | the default applies |
| `LLM_MAX_TOKENS_PER_THREAD` | `4000` |  |  | the default applies |
| `LLM_MAX_MESSAGES_PER_THREAD` | `50` |  |  | the default applies |
| `TELEPHONY_PROVIDER` | `'mock'` |  |  | the default applies |
| `TELEPHONY_FROM_E164` | `''` |  |  | the default applies |
| `TELEPHONY_WEBHOOK_SECRET` | `''` | yes |  | the default applies |
| `CALL_RATE_LIMIT_PER_USER_PER_DAY` | `2` |  |  | the default applies |
| `CALL_RATE_LIMIT_PER_PRO_PER_DAY` | `20` |  |  | the default applies |
| `MAX_JSON_BODY_BYTES` | `1048576` |  |  | the default applies |
| `MAX_CHAT_MESSAGE_LENGTH` | `2000` |  |  | the default applies |
| `CHAT_ASSISTANT_HOLD_SECONDS` | `120` |  |  | the default applies |
| `PRESENCE_WINDOW_SECONDS` | `300` |  |  | the default applies |
| `AVAILABLE_NOW_FRESH_SECONDS` | `120` |  |  | the default applies |
| `AVAILABLE_NOW_HOURS` | `4` |  |  | the default applies |
| `SHORT_NOTICE_ACCEPT_MINUTES` | `30` |  |  | the default applies |
| `SHORT_NOTICE_PAY_MINUTES` | `30` |  |  | the default applies |
| `PAYMENT_WINDOW_HOURS` | `24` |  |  | the default applies |
| `PAY_DEADLINE_MARGIN_MINUTES` | `30` |  |  | the default applies |
| `PRESENCE_HEARTBEAT_MIN_INTERVAL_SECONDS` | `50` |  |  | the default applies |
| `MAX_REVIEW_TEXT_LENGTH` | `2000` |  |  | the default applies |
| `MAX_UPLOAD_BYTES` | `25000000` |  |  | the default applies |
| `DELIVERY_MAX_UPLOAD_BYTES` | `50000000` |  |  | the default applies |
| `GEAR_EVIDENCE_MAX_BYTES` | `150000000` |  |  | the default applies |
| `GEAR_EVIDENCE_MIME_TYPES` | `'application/octet-stream,image/jpeg,image/he...` |  |  | the default applies |
| `GEAR_EVIDENCE_EXTENSIONS` | `'cr3,cr2,arw,nef,nrw,raf,rw2,orf,dng,pef,srw,...` |  |  | the default applies |
| `ALLOWED_UPLOAD_MIME_TYPES` | `'image/jpeg,image/png,image/webp,video/mp4'` |  |  | the default applies |
| `NICHE_BANNER_MIME_TYPES` | `'image/jpeg,image/png,image/webp'` |  |  | the default applies |
| `NICHE_BANNER_MAX_BYTES` | `15000000` |  |  | the default applies |
| `NICHE_BANNER_MIN_WIDTH` | `1600` |  |  | the default applies |
| `NICHE_BANNER_MIN_HEIGHT` | `900` |  |  | the default applies |
| `NICHE_BANNER_TILE_WIDTH` | `800` |  |  | the default applies |
| `NICHE_BANNER_HERO_WIDTH` | `2048` |  |  | the default applies |
| `NICHE_BANNER_PLACEHOLDER_WIDTH` | `24` |  |  | the default applies |
| `NICHE_BANNER_TAGLINE_MAX` | `60` |  |  | the default applies |
| `NICHE_BANNER_ALT_MAX` | `250` |  |  | the default applies |
| `NICHE_BANNER_MIN_CONTRAST` | `4.5` |  |  | the default applies |
| `NICHE_BANNER_SCRIM_FLOOR` | `0.25` |  |  | the default applies |
| `NICHE_BANNER_SCRIM_CEILING` | `0.85` |  |  | the default applies |
| `PRESENTATION_VIDEO_ENABLED` | `False` |  |  | the default applies |
| `MUX_FAKE` | `False` |  | leave default | a wrong value: refuses to start (guard) |
| `MUX_PLAYBACK_MAX_RESOLUTION` | `'720p'` |  |  | the default applies |
| `INTERVIEW_TEASER_MAX_CHARS` | `90` |  |  | the default applies |
| `RATE_LIMIT_PUBLIC_READ_PER_MIN` | `120` |  |  | the default applies |
| `RATE_LIMIT_AUTH_MUTATION_PER_MIN` | `30` |  |  | the default applies |
| `RATE_LIMIT_CHAT_MESSAGES_PER_MIN` | `10` |  |  | the default applies |
| `RATE_LIMIT_THREAD_CREATIONS_PER_DAY` | `5` |  |  | the default applies |
| `RATE_LIMIT_REVIEWS_PER_DAY` | `5` |  |  | the default applies |
| `RATE_LIMIT_REFERRAL_CLAIMS_PER_DAY` | `3` |  |  | the default applies |
| `RATE_LIMIT_PAYMENTS_PER_HOUR` | `10` |  |  | the default applies |
| `RATE_LIMIT_UPLOADS_PER_HOUR` | `30` |  |  | the default applies |
| `RATE_LIMIT_PLUGIN_PORTFOLIO_UPLOADS_PER_HOUR` | `100` |  |  | the default applies |
| `RATE_LIMIT_DELIVERY_UPLOADS_PER_HOUR` | `2000` |  |  | the default applies |
| `RATE_LIMIT_DELIVERY_TOKEN_UPLOADS_PER_DAY` | `5000` |  |  | the default applies |
| `LIGHTROOM_PLUGIN_LATEST_VERSION` | `'1.2.3'` |  |  | the default applies |
| `LIGHTROOM_PLUGIN_MIN_VERSION` | `'1.0.0'` |  |  | the default applies |
| `LIGHTROOM_PLUGIN_DOWNLOAD_URL` | `''` |  |  | the default applies |
| `UNFINISHED_UPLOAD_MAX_AGE_HOURS` | `24` |  |  | the default applies |
| `RATE_LIMIT_ADMIN_PER_MIN` | `60` |  |  | the default applies |
| `RATE_LIMIT_ADMIN_BI_PER_MIN` | `240` |  |  | the default applies |
| `ADMIN_IP_ALLOWLIST` | `''` |  |  | the default applies |
| `TRUSTED_PROXY_IPS` | `''` |  | set by compose.prod.yml (172.30.0.0/24) | refuses to start (guard names it) |
| `TRUSTED_PROXY_HOPS` | `1` |  | set by compose.prod.yml (1) | the default applies |
| `TRUST_CLOUDFLARE` | `False` |  |  | the default applies |
| `CLOUDFLARE_IPS_FILE` | `''` |  |  | the default applies |
| `ADMIN_API_KEYS` | `''` | yes | must set | refuses to start (guard names it) |
| `SEARCH_PROVIDER` | `'none'` |  |  | the default applies |
| `SEARCH_ENABLED` | `False` |  |  | the default applies |
| `SEARCH_INDEX_PREFIX` | `'rawwers_dev'` |  |  | the default applies |
| `MEILI_URL` | `'http://localhost:7700'` |  |  | the default applies |
| `MEILI_API_KEY` | `''` | yes |  | the default applies |
| `TYPESENSE_URL` | `''` |  |  | the default applies |
| `TYPESENSE_API_KEY` | `''` | yes |  | the default applies |
| `SEARCH_FALLBACK_CACHE_TTL_SECONDS` | `30` |  |  | the default applies |
| `AUTH_JWT_SECRET` | `'dev-insecure-auth-secret'` | yes | must set | refuses to start (guard names it) |
| `AUTH_ACCESS_TOKEN_TTL_MINUTES` | `15` |  |  | the default applies |
| `AUTH_REFRESH_TOKEN_TTL_DAYS` | `30` |  |  | the default applies |
| `AUTH_EMAIL_VERIFICATION_TTL_MINUTES` | `30` |  |  | the default applies |
| `AUTH_PASSWORD_RESET_TTL_MINUTES` | `30` | yes |  | the default applies |
| `AUTH_DEV_BYPASS` | `False` |  | leave default | a wrong value: refuses to start (guard) |
| `NOTIFICATION_DEFAULT_TIMEZONE` | `'Europe/London'` |  |  | the default applies |
| `NOTIFICATION_CRITICAL_BYPASS_QUIET_HOURS` | `True` |  |  | the default applies |
| `RATE_LIMIT_NOTIFICATIONS_EMAIL_PER_DAY` | `20` |  |  | the default applies |
| `RATE_LIMIT_NOTIFICATIONS_INAPP_PER_DAY` | `60` |  |  | the default applies |
| `RATE_LIMIT_NOTIFICATIONS_BURST_PER_MIN` | `30` |  |  | the default applies |
| `DEFAULT_GIG_CONSENT_LEVEL` | `'none'` |  |  | the default applies |
| `MEDIA_SIGNED_URL_TTL_SECONDS` | `120` |  |  | the default applies |
| `MEDIA_SHARE_TOKEN_PEPPER` | `'dev-media-share-pepper'` | yes | must set | refuses to start (guard names it) |
| `MEDIA_ACCESS_IP_HASH_PEPPER` | `'dev-media-ip-pepper'` | yes | must set | refuses to start (guard names it) |
| `MEDIA_ACCESS_RAW_IP_RETENTION_DAYS` | `120` |  |  | the default applies |
| `MEDIA_WATERMARK_TEXT_TEMPLATE` | `'RAWWERS'` |  |  | the default applies |
| `MEDIA_WATERMARK_INCLUDE_PRO_NAME` | `False` |  |  | the default applies |
| `SHARE_VIEW_FINGERPRINT_PEPPER` | `'dev-share-fingerprint-pepper'` | yes | must set | refuses to start (guard names it) |
| `REWARD_BALANCE_FLOOR` | `-5000` |  |  | the default applies |
| `ADDRESS_ENCRYPTION_KEYS` | `''` | yes | must set | refuses to start (guard names it) |
| `MARKETING_CONSENT_CREDIT_POINTS` | `100` |  |  | the default applies |
| `MARKETING_CONSENT_MONTHLY_CAP` | `3` |  |  | the default applies |
| `DISPUTE_WINDOW_DAYS` | `30` |  |  | the default applies |
| `DISPUTE_OPEN_LIMIT_30D` | `3` |  |  | the default applies |
| `DISPUTE_MESSAGES_PER_DAY` | `10` |  |  | the default applies |
| `RISK_IP_HASH_PEPPER` | `'dev-risk-ip-pepper'` | yes | must set | refuses to start (guard names it) |
| `RISK_DEVICE_HASH_PEPPER` | `'dev-risk-device-pepper'` | yes | must set | refuses to start (guard names it) |
| `RISK_SESSION_HASH_PEPPER` | `'dev-risk-session-pepper'` | yes | must set | refuses to start (guard names it) |
| `RISK_SIGNAL_RETENTION_DAYS` | `90` |  |  | the default applies |
| `BOOKING_RESPONSE_DEADLINE_HOURS` | `24` |  |  | the default applies |
| `OUTBOX_DISPATCH_INTERVAL_SECONDS` | `30` |  |  | the default applies |
| `FOLLOWUP_JOBS_INTERVAL_SECONDS` | `60` |  |  | the default applies |
| `REMINDERS_INTERVAL_SECONDS` | `60` |  |  | the default applies |
| `BOOKING_REQUEST_EXPIRY_SWEEP_INTERVAL_SECONDS` | `60` |  |  | the default applies |
| `STRIPE_RECONCILE_INTERVAL_SECONDS` | `900` |  |  | the default applies |
| `STRIPE_RECONCILE_LOOKBACK_HOURS` | `72` |  |  | the default applies |
| `STRIPE_RECONCILE_MIN_AGE_SECONDS` | `300` |  |  | the default applies |
| `STRIPE_RECONCILE_DRY_RUN` | `False` |  |  | the default applies |
| `MUX_SYNC_INTERVAL_SECONDS` | `300` |  |  | the default applies |
| `MUX_SYNC_STALE_MINUTES` | `10` |  |  | the default applies |
| `MUX_SYNC_MAX_AGE_HOURS` | `48` |  |  | the default applies |
| `PAYOUT_HOLD_RELEASE_SWEEP_INTERVAL_SECONDS` | `3600` |  |  | the default applies |
| `DISPUTE_ESCALATION_SWEEP_INTERVAL_SECONDS` | `3600` |  |  | the default applies |
| `STUCK_BOOKING_SWEEP_INTERVAL_SECONDS` | `3600` |  |  | the default applies |
| `REFUND_RECONCILE_INTERVAL_SECONDS` | `900` |  |  | the default applies |
| `STUCK_BOOKING_MAX_AGE_HOURS` | `720` |  |  | the default applies |
| `SCHEDULED_SWEEP_BATCH_SIZE` | `100` |  |  | the default applies |


### 3b. The compose file (read from the secrets file, not by the app)

`API_IMAGE`, `WEB_IMAGE`, `IMAGE_TAG` (required: compose stops with "required variable ... is missing"), `POSTGRES_DB`, `POSTGRES_USER` (default `rawwers`), `POSTGRES_PASSWORD` (required, secret), `API_WORKERS` (1), `WORKER_CONCURRENCY` (2), `PHOTO_WORKER_CONCURRENCY` (1), `API_HOST`/`ADMIN_HOST` (api/admin.rawwers.com), `CADDY_TLS` (the origin certificate files), `CADDY_CERTS_DIR` (`/opt/rawwers/certs`), `CADDY_HTTP_PORT`/`CADDY_HTTPS_PORT` (80/443), `WEB_SENTRY_DSN` (optional), `RAWWERS_ENV_FILE` (the secrets file's path).

### 3c. The web admin (`web/`)

| Variable | When | Required | Secret | If missing |
|---|---|---|---|---|
| `NEXT_PUBLIC_API_BASE_URL` | **build time** (inlined in the browser code) | yes | no | the browser calls `http://localhost:8000`: login fails. build-and-push.sh sets `https://api.rawwers.com` |
| `API_BASE_URL` | run time | yes (compose: `http://api:8000`) | no | the admin proxy calls the public API address instead of the private one |
| `ADMIN_API_KEY` | run time | yes | **yes** | every admin page answers 500 `admin_key_missing` |
| `SENTRY_DSN` / `NEXT_PUBLIC_SENTRY_DSN` | run / build time | no | no | no error reporting from the web |
| `NEXT_PUBLIC_SENTRY_ENVIRONMENT`, `NEXT_PUBLIC_SENTRY_RELEASE` | build time | no | no | events untagged |
| `NEXT_PUBLIC_ANALYTICS_ENDPOINT`, `NEXT_PUBLIC_TELEGRAM_BOT_URL`, `NEXT_PUBLIC_WEBAPP_URL` | build time | no | no | the feature is hidden |

## 4. Stack, health, migrations, jobs

- **Compose:** `deploy/compose.prod.yml`, project `rawwers`, network `172.30.0.0/24` (pinned; `TRUSTED_PROXY_IPS`). Services: postgres 16.6, redis 7.4, api, worker (`media`), worker-photos (`photos`), beat, web, caddy 2.8.4, and the one-off `migrate`. Tests: `api/tests/test_compose_prod.py`, `test_queue_consumers.py`.
- **Health checks:** postgres `pg_isready`; redis `PING`; api `GET /healthz`; workers answer a Celery ping (`scripts/celery_ping.py`, imports Celery only); beat's schedule file is younger than 10 minutes; web `GET /login`; caddy its admin endpoint.
- **Migrations from an empty database:** `dc run --rm migrate` (never at API start). Rehearsal: 97 migrations, head `20261114_0098`, about 3 minutes on a busy Mac.
- **Reference data:** `scripts/bootstrap_reference_data.py`: the niches already exist after the migrations (12 skipped); it adds the GB tax rule (1), 5 interview questions, 98 camera and 13 lens models, 40 EUR and 40 GBP price caps. A second run adds nothing.
- **Exchange rates:** beat runs `fx-refresh` hourly at minute 15 and needs outbound HTTPS to `www.ecb.europa.eu`; the runbook runs it once by hand.
- **Beat:** exactly one instance (`beat`); 21 periodic tasks, the outbox every 30 s, request expiry every 60 s.

## 5. External services, and what each does when not configured

| Service | How the app talks to it | Not configured |
|---|---|---|
| Cloudflare R2 | S3 API (boto3); apps and the admin upload **directly** with presigned URLs | API does not start (required settings); production refuses empty or test keys |
| R2 CORS | browser uploads from the web admin only | admin uploads (niche banners) fail in the browser; apps unaffected |
| Stripe (test) | API calls; webhooks at `/v1/webhooks/stripe` (two destinations: platform, connected accounts) | production refuses to start; outside production payments fail when called, webhooks 401 |
| Brevo | **HTTP API** (`POST https://api.brevo.com/v3/smtp/email`, `api-key` header), not SMTP; webhook `/v1/webhooks/brevo` (Bearer token) | production refuses (console mail); 401/403 from Brevo (key, sender or **IP not authorised**) is not retried and alerts Sentry `email_failure:config`; webhook route 404 without its token |
| Sentry (EU) | SDK, errors only | off |
| Mux | API + signed playback; webhook `/v1/webhooks/mux` | the video answers "Video is not available right now"; Mux webhooks 401; nothing stops start |
| LLM | `LLM_PROVIDER=mock` | the assistant is off by flags anyway |
| Telephony | mock | its webhook is not mounted in production |
| Search | `SEARCH_PROVIDER=none` | Discover reads the database (no Meilisearch on the server) |
| ECB rates | HTTPS fetch | no approximations in other currencies; Sentry after 4 days |

## 6. Resource budget (2 GB RAM, 40 GB disk)

Measured in the local rehearsal (production images and settings, empty
database, idle, Docker on the Mac, 2026-11-22); "small beta" is an estimate
from the code (a few photographers, a few dozen clients).

| Container | Idle (measured) | Small beta (estimate) | Limit set |
|---|---|---|---|
| api (1 Uvicorn worker) | 230 MB | 300-350 MB | 640 MB |
| worker (`media`, concurrency 2: one parent, two children) | 343 MB | 400-450 MB | 512 MB |
| worker-photos (concurrency 1) | 171 MB | 300 MB, **up to 900 MB** while a large proof is processed (760 MB measured for 60 MP on 2026-10-31) | 1024 MB |
| beat | 153 MB | 160 MB | 256 MB |
| postgres (shared_buffers 128 MB) | 73 MB | 150-250 MB | 384 MB |
| redis | 5 MB | 20-50 MB | 128 MB (maxmemory 96 MB) |
| web (Next.js) | 50 MB | 150-200 MB | 384 MB |
| caddy | 14 MB | 30 MB | 128 MB |
| **Containers** | **about 1.1 GB** | **about 1.6-2.4 GB** | |
| Ubuntu + Docker | about 300 MB | about 300 MB | |

**Is 2 GB enough?** Idle, yes: about 1.4 GB (1.1 GB of containers plus the
system) of 2 GB, with 2 GB of swap as a safety net. Under work, **no**: one
large photo delivery pushes the total past 2 GB (the photo worker alone
peaks near 900 MB), and the kernel then kills a container or the server
swaps until it is too slow. That can happen on the test deploy too, the
first time you try a real delivery. The memory limits are caps, not reservations:
their sum (3.4 GB) is deliberately above 2 GB, so one busy container can
borrow what the idle ones do not use.

**Recommended (owner's choice, 2026-11-22; the owner may skip it):** the
test deploy is meant to run on **4 GB**, resized right after the clean
baseline snapshot and before the first start (runbook step 1b; CPU and RAM
only, reversible), with `API_WORKERS=2`. **2 GB is the fallback**: it boots
and passes the smoke test, but a large proof can push it out of memory, so on
2 GB do not test large deliveries and resize before the first real
photographer (runbook "Resize the server"). 8 GB only when deliveries of
60 MP files happen in parallel (then `PHOTO_WORKER_CONCURRENCY=2`).

**Workers and concurrency for 2 GB:** API 1 Uvicorn worker, `media` worker
concurrency 2, photo worker concurrency 1 (the compose defaults). At 4 GB: API
2, media 2, photos 1. Postgres: `shared_buffers=128MB`,
`effective_cache_size=512MB`, `work_mem=4MB`, `maintenance_work_mem=64MB`,
`max_connections=100` (at 4 GB: 256 MB, 1.5 GB, 8 MB, 128 MB).

**Disk (40 GB):** Ubuntu about 3 GB; 2 GB swap file; images about 3 GB per
version on disk (API 1.15 GB, Postgres 0.6 GB, Redis 0.2 GB, web and Caddy),
so about 6 GB with the previous version kept for rollback (`docker image
prune` removes older ones); the database 77 MB empty (280 tables), under 1 GB
for the beta; container logs capped at 30 MB each (about 300 MB in all);
backups about 0.7 MB each now, 14 kept. Total under 15 GB: 40 GB is enough.
Uploads are in R2, never on the server.

## 7. Behind Cloudflare

**Client address:** every place that keys on an address goes through
`app/core/client_ip.client_ip`: rate limits (registration, login, refresh,
pairing, public reads), the admin allowlist, auth events, download evidence,
risk signals, webhook security logs. With `TRUST_CLOUDFLARE` the real visitor
address is used; a spoofed `CF-Connecting-IP` from anywhere but Cloudflare is
ignored (`api/tests/test_client_ip.py`). The Hetzner firewall also admits 80
and 443 only from Cloudflare.

**Webhooks:** Stripe (signature), Mux (signature), Brevo (token) and
unsubscribe never check the source address, so the proxy changes nothing for
them; Cloudflare must not challenge them (runbook 6d). The telephony webhook
is not mounted.

**HTTPS and cookies:** the API never builds links from the request (it uses
`API_PUBLIC_URL`/`APP_PUBLIC_URL`), except the development fake Mux. Uvicorn
runs with `--no-proxy-headers`. The API uses bearer tokens, not cookies; three
small cookies on public share/referral routes (`rw_sid`, `rw_ref`,
`rw_tracking_consent`) are set without `Secure` (finding, LATER: set it in
production). The web admin keeps its session in `sessionStorage`.

**Request bodies through the API (Cloudflare caps them at 100 MB):** none
carries a file in production. Photos (25 MB), proofs (50 MB), gear evidence
(150 MB), niche banners (15 MB) go straight to R2 with presigned URLs (the R2
endpoint is not behind the rawwers.com zone), the video (100 MB) straight to
Mux. The largest body the API accepts is JSON, 1 MB (`MAX_JSON_BODY_BYTES`);
Caddy caps bodies at 5 MB. The only route that reads a raw file body is the
development fake Mux upload, which does not exist in production.

**WebSockets and streaming:** none (no WebSocket, no server-sent events, no
streamed responses), in the API or the web admin. Nothing special is needed.

**Slow requests:** Cloudflare waits 100 seconds for an answer on the free
plan. API requests are short by design: the heavy work (index rebuilds,
photo processing, reconciliation, the business dashboard's backfill) runs in
Celery or in one-off scripts. Not measured on the server: no request timing
exists from production yet; the first `/v1/client/home` after a start is the
slowest seen locally and is warmed up before traffic. Caddy gives up reading
a body after 30 s.

## 8. Brevo

- The code uses Brevo's **transactional HTTP API**, never SMTP.
- **Authorised IPs:** if the Brevo account has IP blocking on (Brevo > Security > Authorised IPs), add the **server's IPv4 address** `<SERVER_IP>`: containers send mail out through it (Docker's default network is IPv4 only). Without it every email answers 401 "unrecognised IP address" and Sentry gets `email_failure:config`.
- The webhook takes its token as a Bearer header or `?token=`; prefer the header (URLs reach logs).
- In a test deployment only `EMAIL_DEV_ALLOWLIST` is mailed.

## 9. Production exposure

| Check | Result |
|---|---|
| API docs, `openapi.json` | OK after fix: off in production, refused if switched on, 404 at Caddy too |
| `/metrics`, `/health/ready`, `/health/replica` | OK after fix: `/metrics` 404 in production; Caddy 404s all three publicly (`/healthz` stays) |
| Dev routes (`/v1/dev/*`), fake Mux | OK: 404 outside development before authentication; also 404 at Caddy |
| Seed and demo scripts | OK: refuse any `APP_ENV` but development/test (`_seed_common.assert_environment_is_seedable`); migrations create no account |
| Mock providers | OK after fix: console mail refused; `MUX_FAKE` refused; LLM mock is intended (assistant off); telephony mock with no webhook |
| Dev auth bypass (`X-User-Id`) | OK: ignored in production; now also refused if switched on |
| First admin | OK: no default account or password; the owner registers, then `ADMIN_USER_IDS`. **No 2FA in the app** (finding): Cloudflare Access gives the second factor |
| Admin API | OK after fix: only reachable through the web admin (Caddy hides `/v1/admin/*` on the API host); needs a token, the admin role and `X-Admin-Api-Key` |
| CORS | OK after fix: production requires explicit https origins; `*` refused; the old fallback allowed localhost |
| Trusted hosts | OK: Caddy answers only api and admin; any other host gets no certificate or a closed connection. No TrustedHostMiddleware in the API (not needed behind Caddy) |
| Cookies, sessions | Finding (LATER): the three public cookies lack `Secure`. Bearer tokens otherwise |
| Logs | OK: no token, password, card or payout detail is logged; email addresses are reduced to their domain; Sentry scrubs IPs, cookies, emails, tokens. Finding (minor): the request log copies a client-sent `X-User-Id` header as `user_id` |
| Card data | OK: cards never reach the server (Stripe Payment Sheet) |

## 10. Images

| Image | Base | User | Size (measured) | Contents |
|---|---|---|---|---|
| API (`runtime`) | python:3.12-slim | 10001 (`rawwers`) | 315 MB compressed (what is pulled), 1.15 GB on disk | the app, alembic, scripts, data; no tests, no `.env`, no docs |
| Web | node:20-alpine | `nextjs` | 201 MB | `.next`, `node_modules`, `public`, `package.json`; no `.env` |

The API image still carries `build-essential` and Poetry (about 200 MB that a
multi-stage build would drop: LATER). `deploy/scripts/check-image.sh` (run by
build-and-push.sh) fails on root, `.env` files, keys and secret-looking values.

## 11. The empty-secrets boot

The production image with **an empty secrets file** stops at once with
`7 validation errors for Settings` (`DATABASE_URL`, `REDIS_URL` and the five
`R2_*` are required). With only those set it stops on
`CONNECT_RETURN_URL must use https://` ; with that fixed, the guard lists **22
problems** and exits (`RAWWERS api refuses to start in production`). The
defaults that apply in production when no flag row exists:

Settings with an empty secrets file: `DEPLOYMENT_MODE` test, API docs off, email sending off (and refused), allowlist-only on, Stripe key missing (refused), Mux not configured (allowed: the video says "not available"), `PRESENTATION_VIDEO_ENABLED` off, `MUX_FAKE` off, `MUX_PLAYBACK_MAX_RESOLUTION` 720p, `LLM_PROVIDER` mock, Sentry off, `TRUST_CLOUDFLARE` off (the secrets file sets it on). The Shelf: off (its settings row is created off on first read; the rehearsal database showed `off`).

| Flag | Default in production |
|---|---|
| `ai_calls_enabled` | off |
| `ai_chat_enabled_city` | on |
| `ai_chat_enabled_global` | off |
| `ai_chat_enabled_pro` | on |
| `ai_chat_kill_switch` | on |
| `client_booking_enabled` | on |
| `client_browsing_enabled` | on |
| `client_browsing_enabled_global` | on |
| `downloads_enabled` | on |
| `ecom_enabled` | off |
| `guest_discovery_enabled` | off |
| `loaners_enabled` | off |
| `pro_onboarding_enabled` | on |
| `public_share_enabled` | on |
| `raww_minting_enabled` | off |
| `raww_minting_event_gig_completed_enabled` | on |
| `raww_minting_event_pack_sold_enabled` | on |
| `rewards_spend_enabled` | off |
| `search_enabled` | on |
| `search_force_db_fallback` | off |
| `studioverse_enabled` | off |
| `video_uploads_enabled` | on |

`ai_chat_enabled_city` and `ai_chat_enabled_pro` read on, but nothing reads them (DEPLOY_CHECKLIST, the assistant item); `raww_minting_event_*` are on but sit under `raww_minting_enabled`, which is off. Every value matches the beta flag table.


## 12. The local rehearsal (2026-11-22)

On the Mac, separate compose project (`rawwers-rehearsal`), ports 18080/18443,
its own volumes; the production images built from the working tree (native
arm64, not amd64); a throwaway secrets file made by `generate-secrets.sh`
with fake service values; Stripe, Brevo and Mux hostnames pointed at
nothing so no container could reach them; a self-signed stand-in for the
Cloudflare origin certificate, loaded the production way (`CADDY_TLS` files).

**Proved, in the runbook's order:** `generate-secrets.sh` (and that a second
run refuses); `migrate` (97 migrations to `20261114_0098`); the bootstrap,
twice (197 rows, then none); the first exchange-rate run (GBP 0.83735 from the
ECB); `smoke.py --write` through Caddy: `Everything passed` (health and
release, docs/metrics/admin/dev/health routes 404, 12 niches, rates, CORS for
the admin origin and not another, admin pages, sign-up, sign-in, print store
and Studioverse off, sign-out, http to https); `delete_smoke_accounts.py`;
`version.sh`; `backup-now.sh` and `restore-test.sh` (280 tables, migration
and user counts equal); killing the main process of all eight containers:
each restarted by itself and was healthy again. An unknown hostname gets no
TLS handshake and a closed connection on port 80. Torn down afterwards with
its volumes and secrets file; dev untouched and healthy (healthz 200).

**What broke and was fixed:** the http-to-https redirect (Caddyfile); the
smoke-account cleanup (foreign key order); the workers' health check timed out
at 20 s on the overloaded Mac (now 30 s); bootstrap output and the image
sizes corrected in the runbook.

**Not proved here:** real TLS and Cloudflare (proxy, Full (strict), Access,
WAF, the real `CF-Connecting-IP` path: covered only by tests); the amd64
images and the real 2 GB server (timings on the Mac were with three test runs
in parallel and are not representative); Stripe, Brevo, R2, Sentry and Mux
(fake values, unreachable on purpose); email delivery and DNS; the Hetzner
firewall, snapshots and backups; the registry push and pull.

## 13. Decisions (owner, 2026-11-22)

| Decision | Chosen | Reason |
|---|---|---|
| Registry | GHCR, private packages | Existing account; read-only token on the server; nothing public (runbook step 9) |
| TLS | Cloudflare origin certificate, Full (strict) | 15 years, no renewal job, no Cloudflare token on the server; Cloudflare verifies the origin (step 6b) |
| Admin protection | Cloudflare Access, email one-time PIN, on `admin.rawwers.com` only | No 2FA in the app; a changing home address rules out an IP allowlist; nothing to build (step 7). Not on `api.`: apps and webhooks cannot log in |
| API docs | Off | Public API; the guard refuses `API_DOCS_ENABLED` in production; Caddy also answers 404 |
| Workers | 4 GB: API 2, media 2, photos 1. 2 GB: API 1, media 2, photos 1 | Section 6 (measured) |
| Server size | Resize to 4 GB before the first start (runbook step 1b); 2 GB the fallback | Section 6: the photo worker peak |
| New primary IPv4 | Yes, at the rebuild (runbook step 0b); the old one released only after the deploy works | The old address is in the repository's git history (finding 5) |
| `DEFAULT_CONNECT_COUNTRY` | PT for the test deploy, no code change | Decided again before a UK launch (MULTI_CURRENCY.md, M6 item 6) |
| Tag | `deploy-test-1`, annotated, on 9f45c7fa5593 (2026-11-22) | The commit every check of this audit was run against |

