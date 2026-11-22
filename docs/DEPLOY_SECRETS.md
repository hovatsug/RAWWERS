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

## Before go-live: replace everything that was shared or temporary

The test deploy (`deploy-test-1`) used some values that are fine for testing
and wrong for real users: keys shared with dev, broad tokens, test-mode
settings. Before `DEPLOYMENT_MODE=live`, replace each of these. Every row
points at the steps that already exist; nothing here is new procedure.

| What | Why | How |
|---|---|---|
| `BREVO_API_KEY` | The test deploy reuses dev's key, so the Mac's copy can send as the live server | Brevo > SMTP & API > API keys > Generate a key for the live server only; put it in the file, restart; delete the shared key in Brevo (rotation table above). Then add the live server's IP in Brevo's Authorised IPs (runbook step 16) |
| `STRIPE_SECRET_KEY` (live), `DEPLOYMENT_MODE=live`, `STRIPE_WEBHOOK_SECRET` | Test mode moves no real money; the API refuses a live key while the mode is `test`, and a test key once it is `live` | Stripe in **live** mode: the live secret key; the two webhook destinations made again in live mode (runbook step 15, part 1, with live mode on); both new signing secrets in `STRIPE_WEBHOOK_SECRET`; then `DEPLOYMENT_MODE=live`. Check with `register_stripe_webhook.py --mode live` (without `--apply`) |
| Photographers' connected accounts | Connected accounts made in test mode do not exist in live mode | Each photographer sets up payouts again in the Pro app (Getting paid) once the live key is in; nothing carries over |
| R2 bucket and token | The test bucket holds test photos; a token scoped wider than one bucket can reach other buckets | A production bucket (EU jurisdiction if Cloudflare offers it), a new token with "Object Read & Write" on **that bucket only**, the bucket's CORS rule and lifecycle rule (runbook step 18, parts 3 and 5); then **revoke the old broad token** in R2 > Manage API tokens |
| The Cloudflare origin certificate | The test deploy's certificate and key were handled by hand | If the live server uses a new certificate: make it (runbook step 6b), copy both files, `dc restart caddy`, then revoke the old one under SSL/TLS > Origin Server. If the old one is still in use, make the new one first, then revoke the old |
| `AUTH_JWT_SECRET` and every generated value | The test server's values were made for testing and may have been seen in a test session | On the live server, `deploy/scripts/generate-secrets.sh` makes a new file with all of them (it never overwrites an existing file). What each change does to people who already have accounts is in the rotation table above: `AUTH_JWT_SECRET` signs everyone out; `MEDIA_SHARE_TOKEN_PEPPER` breaks share links already sent; the other peppers restart matching from zero; `UNSUBSCRIBE_SIGNING_KEYS` breaks unsubscribe links already sent; **`ADDRESS_ENCRYPTION_KEYS` makes saved addresses unreadable** unless the old key is kept after the new one. On a live server that starts with an empty database, none of this affects anyone |
| `MUX_*` | The test deploy uses the RAWWERS_DEV environment's token, signing key and webhook | A Mux **Production** environment: a new access token, a new signing key, a new webhook with its own secret (DEPLOY_CHECKLIST 4a); RAWWERS_DEV's values leave the server |
| Both GitHub tokens (`write:packages` on the Mac, `read:packages` on the server) | Made for the test deploy, possibly without an expiry | GitHub > Settings > Developer settings > Personal access tokens: revoke both, make new ones **with an expiry**; `docker login ghcr.io` again on the Mac and on the server |
| `EMAIL_DEV_ALLOWLIST` | In `live` mode the server emails everyone; the list is a test-mode limit | Remove the line, and check the DEPLOY_CHECKLIST go-live rows (Brevo sending, unsubscribe keys) |
| Cloudflare Access on the pages email links open | Access protects all of `admin.rawwers.com`, including `/unsubscribe`, `/reset-password`, `/verify-email` and the other pages emails link to; a real user cannot pass it | A second Access application on those paths with a **Bypass / Everyone** policy, or move them off the admin host (runbook step 7, "Before real people get emails") |
| Settlement delay | It may have been set to 0 on the test server for a same-day payout test | It must be the real value, **7 days**: `tools/server/set-settlement-delay.py --restore --apply` while still in test mode (DEPLOY_CHECKLIST go-live row) |
| The pound price caps | They are PROVISIONAL, approved for the test deploy only | Reviewed with UK photographers, then approved or corrected in the admin (PRICE_CAPS.md, "Before launch") |
