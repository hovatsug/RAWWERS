# Secrets: how each one is made, and how to change it later

One page. Every secret is **made on the server** and stays there, in
`/opt/rawwers/.env.production` (root only, `chmod 600`). Never paste one into
chat, the repository, an issue, or the Mac's terminal history.
The template is `deploy/.env.production.example`; `sudo deploy/scripts/generate-secrets.sh`
fills every generated value at once.

The API, workers and beat **refuse to start** in production while a value is
empty, a placeholder (`<FROM ...>`, `change-me`) or a development default, and
print which one (`api/app/core/production_guard.py`).

## Made on the server (generate-secrets.sh does all of these)

| Setting | Command (on the server) | Format |
|---|---|---|
| `POSTGRES_PASSWORD` | `openssl rand -hex 24` | 48 hex characters |
| `AUTH_JWT_SECRET` | `openssl rand -hex 32` | 64 hex characters (32 bytes minimum is enforced) |
| `MEDIA_SHARE_TOKEN_PEPPER`, `MEDIA_ACCESS_IP_HASH_PEPPER`, `SHARE_VIEW_FINGERPRINT_PEPPER`, `RISK_IP_HASH_PEPPER`, `RISK_DEVICE_HASH_PEPPER`, `RISK_SESSION_HASH_PEPPER` | `openssl rand -hex 32` each, all different | 64 hex characters |
| `ADMIN_API_KEYS` | `openssl rand -hex 32` | 64 hex characters, one key |
| `ADDRESS_ENCRYPTION_KEYS` | `openssl rand -base64 32 \| tr '+/' '-_'` | 44 characters ending in `=` (a Fernet key) |
| `UNSUBSCRIBE_SIGNING_KEYS` | `echo "k1:$(openssl rand -hex 32)"` | `<id>:<secret>`, newest first |
| `BREVO_WEBHOOK_TOKEN` | `openssl rand -hex 32` | 64 hex characters |

To make one by hand (for example to rotate it): run the command on the
server, then `sudo nano /opt/rawwers/.env.production` and paste it on the
right line. Nothing is printed by generate-secrets.sh itself.

## Copied from a service

| Setting | Where |
|---|---|
| `STRIPE_SECRET_KEY` | Stripe dashboard, **Test mode** on: Developers > API keys > Secret key (`sk_test_...`). A live key is refused while `DEPLOYMENT_MODE=test`. |
| `STRIPE_WEBHOOK_SECRET` | Stripe, Test mode: Developers > Webhooks > the endpoint for `https://api.rawwers.com/v1/webhooks/stripe` > Signing secret (`whsec_...`). |
| `R2_ENDPOINT_URL`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET` | Cloudflare dashboard > R2. The token: "Object Read & Write", this bucket only. |
| `BREVO_API_KEY` | Brevo > SMTP & API > API keys > Generate (one key for this server). |
| `SENTRY_DSN`, `WEB_SENTRY_DSN` | Sentry (EU) > project > Settings > Client Keys. Not really secret (a DSN only sends), but kept here anyway. |
| The Cloudflare origin certificate (`/opt/rawwers/certs/origin.pem`, `origin.key`) | Cloudflare > SSL/TLS > Origin Server > Create Certificate (runbook, "TLS"). The key is shown once. |
| The registry read token (for `docker login` on the server) | GitHub > Settings > Developer settings > Personal access tokens (classic) > scope `read:packages` only. |
| `MUX_*` | Not now. After this deploy: DEPLOY_CHECKLIST section 4a. |

## Rotating (changing one later), and what breaks

Always: edit the file, then restart what reads it:
`deploy/scripts/dc up -d --force-recreate api worker worker-photos beat web`.

| Setting | What happens when it changes | How |
|---|---|---|
| `AUTH_JWT_SECRET` | Everyone is signed out (apps and admin) and signs in again. Nothing is lost. | Replace, restart. |
| `ADMIN_API_KEYS` | The web admin answers 403 for the seconds between the API and web restarts. | Replace, restart `api` and `web` together. |
| `MEDIA_SHARE_TOKEN_PEPPER` | Every share link already sent stops working. | Replace only if it leaked. |
| `MEDIA_ACCESS_IP_HASH_PEPPER`, `SHARE_VIEW_FINGERPRINT_PEPPER`, `RISK_*_PEPPER` | Old hashes no longer match new ones: download evidence, view counts and risk history start again from zero for matching. Nothing breaks for users. | Replace only if it leaked. |
| `ADDRESS_ENCRYPTION_KEYS` | **Do not remove the old key**: addresses saved with it could not be read again. | Put the new key first, keep the old after a comma: `new,old`. |
| `UNSUBSCRIBE_SIGNING_KEYS` | Links in emails already sent stop working if the old key is removed. | Add the new one first: `k2:<new>,k1:<old>`; drop `k1` after a few months. |
| `POSTGRES_PASSWORD` | Everything that talks to the database stops until both sides match. | `deploy/scripts/dc exec postgres psql -U rawwers -c "ALTER USER rawwers PASSWORD '<new>'"`, then put the same value in the file, then restart everything except postgres. The password in the file is used only by the apps once the database exists. |
| `STRIPE_SECRET_KEY` | Payments fail between rolling it in Stripe and restarting. | Stripe > API keys > Roll key (set an expiry for the old one), replace, restart. |
| `STRIPE_WEBHOOK_SECRET` | Webhooks fail (401) while the two differ. The setting takes a comma-separated list. | Roll in Stripe with an overlap, put `new,old`, restart; remove `old` once the overlap ends. |
| `BREVO_API_KEY` | Email fails while the two differ. | Make a new key in Brevo, replace, restart, delete the old key in Brevo. |
| `BREVO_WEBHOOK_TOKEN` | Brevo's delivery events are refused (401) until both match. | Change it in the file and in the Brevo webhook (as its Bearer token) together. |
| R2 keys | Uploads and downloads fail while the two differ. | Make a new token, replace, restart, delete the old token. |
| Origin certificate | Cloudflare cannot reach the server if it is wrong. | It lasts 15 years; to replace: make a new one, copy both files, `dc restart caddy`. |

If a secret **leaked**: rotate it now, then check `deploy/scripts/dc logs --since 24h api | grep -i error` and Sentry.
