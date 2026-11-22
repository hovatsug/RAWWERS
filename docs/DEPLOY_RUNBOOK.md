# Deploy runbook: the first test deploy on Hetzner

For the founder, working alone. Follow the steps in order. Every step says
what to **do**, what you **should see**, what to do **if not**, and how to
**undo** it. Stop at the first step that does not look right: nothing later
depends on guessing.

**What this deploy is:** a TEST deployment. Empty database, Stripe in test
mode, no real users, email delivered only to your own addresses
(`DEPLOYMENT_MODE=test`). It is not the launch.

**What it is not:** no Mux yet (the video says "not available"), no
off-server backups yet (batch 4), no staging server.

Placeholders, never written into the repository with real values:
`<SERVER_IP>` the server's IPv4 address, `<GITHUB_USER>` your GitHub name,
`<YOUR_EMAIL>` your own address, `<YOUR_HOME_IP>` the address you connect
from (https://ifconfig.me shows it), `<TAG>` the commit tag agreed for this
deploy, `<COMMIT>` the 12-character commit build-and-push.sh prints.

Commands marked **Mac** run in the repository on your Mac. Commands marked
**server** run on the server after `ssh root@<SERVER_IP>`.

Other documents: [DEPLOY_SECRETS.md](DEPLOY_SECRETS.md) (every secret, and
rotating), [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md) (the checklist behind
this runbook, flags, the Mux steps), [DEPLOY_AUDIT.md](DEPLOY_AUDIT.md) (the
readiness audit of 2026-11-21: every setting, every service, resource budget).

---

## Before you start: what to have ready

1. **Hetzner:** the console login, your SSH public key added to the project (Security > SSH keys).
2. **Cloudflare:** the dashboard login for rawwers.com, with Zero Trust enabled (free plan) for the admin protection.
3. **GitHub:** a classic personal access token with `write:packages` (for the Mac) and a second one with `read:packages` only (for the server). Settings > Developer settings > Personal access tokens > Tokens (classic).
4. **Stripe:** the dashboard in **Test mode**: the test secret key (`sk_test_...`). The webhook endpoints are made in step 15.
5. **Brevo:** an API key for this server, and the sender address verified (Senders, Domains & Dedicated IPs). rawwers.com authenticated there (the brevo1/brevo2 DKIM records exist).
6. **R2:** a bucket for this deployment (for example `rawwers-media-test`) and an API token for it (step 18).
7. **Sentry (optional):** the two DSNs (`rawwers-api`, `rawwers-web`).
8. **On the Mac:** Docker Desktop running, this repository at the agreed tag, `python3`, `dig`.
9. An hour and a half without interruptions for steps 0 to 14; the rest can wait for another day.

---

## Step 0. Rebuild the server and read its baseline

**Do (Hetzner console):** Servers > the server > Rebuild > Ubuntu 24.04 > select your SSH key > Rebuild. This erases everything on it, including the old projects and `/opt/caddy`. That is intended.

**Do (Mac):** wait two minutes, then
```
ssh-keygen -R <SERVER_IP>        # forget the old server's fingerprint
ssh root@<SERVER_IP>             # answer "yes" to the new fingerprint
```
**Do (server):** copy the baseline script over and run it (it changes nothing):
```
# Mac:
scp deploy/scripts/server-baseline.sh root@<SERVER_IP>:/root/
# server:
bash /root/server-baseline.sh
```
**You should see:** `Ubuntu 24.04`, about 2 GB memory, 40 GB disk, port 80 and 443 `free`, `docker: not installed`, `/opt/caddy: not there (good)`.
**If not:** paste the whole output to the developer and stop.
**Undo:** nothing to undo.

### Safety line: only if you did NOT rebuild

If `/opt/caddy` still exists, the old Caddy would fight the new one over ports 80 and 443. Stop and remove it first (server):
```
cd /opt/caddy && docker compose down                         # stops and removes the old Caddy containers
docker ps --format '{{.Names}} {{.Ports}}' | grep -E ':(80|443)->' || echo "nothing on 80/443"
systemctl disable --now caddy 2>/dev/null || true            # in case Caddy was installed without Docker
ss -tlnp '( sport = :80 or sport = :443 )'                   # must list nothing
```
**You should see:** `nothing on 80/443`, and the last command prints only its header line.
**Undo:** `cd /opt/caddy && docker compose up -d`.

---

## Step 1. A snapshot of the clean server, and automatic backups

**Do (Hetzner console):** the server > Snapshots > Take snapshot, name `clean-ubuntu-<date>`. Then Backups > Enable backups (daily, kept 7 days, costs 20% of the server price).
**You should see:** the snapshot listed after a minute or two; Backups "enabled".
**If not:** try again; nothing depends on it yet.
**Undo:** delete the snapshot / disable backups in the same place.

---

## Step 2. The Hetzner firewall

The Cloud Firewall sits outside the server. It is the one that counts: Docker
bypasses a firewall inside the server (ufw) for published ports.

**Do (Mac):** print Cloudflare's ranges, comma-separated:
```
grep -v '^#' api/app/core/cloudflare_ips.txt | paste -sd, -
```
**Do (Hetzner console):** Firewalls > Create firewall `rawwers`. Inbound rules:

| Protocol | Port | Source |
|---|---|---|
| TCP | 443 | every range printed above (IPv4 and IPv6) |
| TCP | 80 | the same ranges |
| TCP | 22 | `<YOUR_HOME_IP>/32` if your address rarely changes; otherwise `0.0.0.0/0` and `::/0` (SSH keys only and fail2ban protect it, step 3) |
| ICMP | | any |

No outbound rules (everything outbound allowed: the server must reach Docker,
GitHub, Stripe, Brevo, R2, Sentry and ecb.europa.eu). Apply to: the server.

**You should see:** the firewall "applied to 1 server".
**If not / locked out:** the Hetzner console's own terminal (server > Console) always works; or remove the firewall from the server.
**Undo:** Firewalls > rawwers > Actions > remove from server.

When Cloudflare changes its ranges: run `deploy/scripts/refresh-cloudflare-ips.sh` on the Mac (monthly), then edit these two rules to the new list.

---

## Step 3. Server basics (SSH keys only, updates, brute-force protection, swap, time)

**Do (server):** paste as one block:
```
set -e
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades fail2ban ca-certificates curl git dnsutils openssl
# Security updates every day, by themselves.
printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n' > /etc/apt/apt.conf.d/20auto-upgrades
systemctl enable --now unattended-upgrades fail2ban
# SSH: keys only.
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin prohibit-password\n' > /etc/ssh/sshd_config.d/99-rawwers.conf
sshd -t && systemctl reload ssh
# 2 GB swap: a safety net for memory peaks, not extra memory.
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
echo 'vm.swappiness=10' > /etc/sysctl.d/99-swap.conf && sysctl -p /etc/sysctl.d/99-swap.conf
# UTC and synchronised time.
timedatectl set-timezone UTC && timedatectl set-ntp true
echo "basics done"
```
**You should see:** `basics done`. Then, **in a second terminal on the Mac, keeping the first one open**: `ssh root@<SERVER_IP> echo ok` prints `ok`.
**If not:** in the first terminal (still connected), `rm /etc/ssh/sshd_config.d/99-rawwers.conf && systemctl reload ssh`, and tell the developer.
**Check:** `bash /root/server-baseline.sh` now shows swap 2.0G, `clock synchronised: yes`, `passwordauthentication no`, fail2ban `active`.
**Undo:** the SSH file as above; `swapoff /swapfile && rm /swapfile` and remove the line from `/etc/fstab`.

---

## Step 4. Docker, with log rotation

**Do (server):**
```
set -e
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Every container's log: at most 3 files of 10 MB (the compose file says the same per service).
printf '{\n  "log-driver": "json-file",\n  "log-opts": {"max-size": "10m", "max-file": "3"}\n}\n' > /etc/docker/daemon.json
systemctl restart docker && systemctl enable docker
docker run --rm hello-world | grep -m1 "Hello from Docker"
```
**You should see:** `Hello from Docker!`
**If not:** paste the error to the developer.
**Undo:** `apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin`.

---

## Step 5. The repository and the folders on the server

**Do (server):**
```
mkdir -p /opt/rawwers/certs /var/backups/rawwers
chmod 700 /opt/rawwers/certs /var/backups/rawwers
git clone https://github.com/<GITHUB_USER>/RAWWERS.git /opt/rawwers/src
cd /opt/rawwers/src && git checkout <TAG> && git log -1 --oneline
```
**You should see:** the commit of `<TAG>`.
**If not:** check the tag exists on GitHub (`git ls-remote --tags origin` on the Mac).
**Undo:** `rm -rf /opt/rawwers/src`.

From now on, every server command runs in `/opt/rawwers/src`, and
`deploy/scripts/dc` means "docker compose with the right files".

---

## Step 6. Cloudflare: DNS, TLS, cache, WAF

### 6a. DNS records (dashboard: rawwers.com > DNS > Records)

1. **Add** `A api <SERVER_IP>` **Proxied** (orange cloud).
2. **Add** `A admin <SERVER_IP>` **Proxied**.
3. **Remove the old web records** that point at `<SERVER_IP>`: `app`, `dani`, `pact`, `recastwebs`, `ritagame`, `rocket`, and the root `rawwers.com` (and `www` if it points there). Only A/AAAA/CNAME records whose content is the server's address. **Never touch** MX, TXT, `zmail._domainkey`, `brevo1/brevo2._domainkey`, `_dmarc`, the Brevo verification record, or anything under `send.pact` and `resend._domainkey.pact` (another project).

**You should see:** `api` and `admin` with an orange cloud; no other record with content `<SERVER_IP>`.
**Undo:** re-add a record (write down each one you delete: name, type, content, proxied).

### 6b. TLS: Full (strict) with a Cloudflare origin certificate

Recommended approach: a **Cloudflare origin certificate** (free, 15 years, no
renewal, no API token on the server). Cloudflare shows visitors its own
certificate; the origin certificate is only trusted by Cloudflare, which is
exactly what "Full (strict)" needs.

1. SSL/TLS > Origin Server > **Create Certificate**: "Generate private key and CSR with Cloudflare", key type RSA (2048), hostnames `api.rawwers.com` and `admin.rawwers.com`, validity 15 years, format PEM > Create.
2. **Server:** paste each into a file (the key is shown only once):
   ```
   nano /opt/rawwers/certs/origin.pem     # paste the Origin Certificate, save (Ctrl+O, Enter, Ctrl+X)
   nano /opt/rawwers/certs/origin.key     # paste the Private Key, save
   chmod 600 /opt/rawwers/certs/origin.*
   openssl x509 -in /opt/rawwers/certs/origin.pem -noout -subject -enddate
   ```
   **You should see:** `subject=... CloudFlare Origin Certificate` and an end date 15 years ahead.
3. SSL/TLS > Overview > **Full (strict)**.
4. SSL/TLS > Edge Certificates: **Always Use HTTPS** on, **Minimum TLS Version** 1.2. Leave HSTS off here: Caddy sends it for api and admin only.

**If something is wrong later** (Cloudflare error 526 "Invalid SSL certificate"): the files do not match, or Caddy cannot read them: `deploy/scripts/dc logs caddy`.
**Undo:** SSL/TLS > Overview > back to the previous mode; revoke the certificate under Origin Server.

### 6c. Cache: never cache the API or the admin

Caching > Cache Rules > Create rule `no cache for api and admin`: when "Hostname is in" `api.rawwers.com`, `admin.rawwers.com` > **Bypass cache** > Deploy.

### 6d. Security: let webhooks and apps through

The apps, Stripe, Brevo and (later) Mux call the API from programs that cannot
solve a browser challenge.

1. Security > Bots: **Bot Fight Mode off** (on the free plan it cannot be skipped for webhooks).
2. Security > WAF > Custom rules > Create `api: no challenges`: when "Hostname equals `api.rawwers.com`" > action **Skip** > tick "All remaining custom rules", "Browser Integrity Check" and "Security Level" > Deploy.
   The paths that must always get through are `/v1/webhooks/stripe`, `/v1/webhooks/brevo`, `/v1/webhooks/mux` and `/v1/email/unsubscribe` (one-click unsubscribe from mail providers); the rule covers the whole API host, which is simpler and also keeps the apps safe.
3. Never switch on "I'm Under Attack" for rawwers.com while apps use it: it would block them.

**Why Caddy also hides things:** on `api.rawwers.com`, Caddy answers 404 to `/v1/admin/*`, `/v1/dev/*`, `/docs`, `/redoc`, `/openapi.json`, `/metrics` and `/health/*` (deploy/Caddyfile). The admin API is reachable only through the web admin, on the private network. A hostname that is not api or admin gets no answer at all.

---

## Step 7. Protect the admin: Cloudflare Access

Recommended over an IP allowlist (your address changes) and over building 2FA
(not needed: Access gives a second factor today).

1. Cloudflare dashboard > **Zero Trust** (free for up to 50 users) > Settings > Authentication: make sure **One-time PIN** is a login method.
2. Access > Applications > Add an application > **Self-hosted**: name `RAWWERS admin`, domain `admin.rawwers.com` (no path), session 24 hours.
3. Policy: name `owner`, action **Allow**, include **Emails** = `<YOUR_EMAIL>`. Save.

**You should see (after step 14):** in a private browser window, `https://admin.rawwers.com` shows Cloudflare's login page; a code arrives by email; then the RAWWERS admin login.
**If not:** check the application's domain is exactly `admin.rawwers.com`.
**Undo:** delete the application.

**Before real people get emails (not now):** the web admin also serves the
pages email links open (`/unsubscribe`, `/reset-password`, `/verify-email`,
`/share`, `/get-the-app`, `/waitlist`) and their files (`/_next/static`). Add a
second Access application on those paths with a **Bypass / Everyone** policy,
or move them to rawwers.com (a LATER row). On this test deployment only your
own addresses get mail, and you can pass Access.

---

## Step 8. The secrets file

**Do (server):**
```
cd /opt/rawwers/src
deploy/scripts/generate-secrets.sh                 # writes /opt/rawwers/.env.production, root only
grep -n '^[A-Z].*<FROM' /opt/rawwers/.env.production | cut -d= -f1    # what you still fill in (12 lines)
nano /opt/rawwers/.env.production
```
Fill every `<FROM ...>` line: the images (from step 9), Stripe **test** key, R2 (step 18 makes the bucket and token), Brevo, `EMAIL_DEV_ALLOWLIST` (your own addresses), and `STRIPE_WEBHOOK_SECRET`: make the two Stripe webhook destinations **now** (step 15, part 1: Stripe accepts them before the server answers) and put both signing secrets in. Leave every `MUX_*` empty. [DEPLOY_SECRETS.md](DEPLOY_SECRETS.md) says where each value comes from.
The API, workers and beat refuse to start while any required value is missing, and list them; that is the check that the file is complete.

**You should see:** `ls -l /opt/rawwers/.env.production` shows `-rw-------` (root only).
**If not:** `chmod 600 /opt/rawwers/.env.production`.
**Never:** paste the file or any value into chat, email, a ticket or the repository.
**Undo:** `rm /opt/rawwers/.env.production` and generate again (all generated values change).

---

## Step 9. Images: build on the Mac, push, pull on the server

Recommended registry: **GitHub Container Registry (ghcr.io), private
packages**. You already have the account; the server only needs a read-only
token. GitHub's free allowance for private packages is small (500 MB of
storage): one deploy is about 315 MB for the API image (measured in the
rehearsal) plus the web image, so expect a small monthly charge (GitHub bills
storage beyond the allowance per GB). Keep only the last two or three versions
(GitHub > your profile > Packages > the package > Manage versions).

**Do (Mac), once:**
```
echo '<WRITE_PACKAGES_TOKEN>' | docker login ghcr.io -u <GITHUB_USER> --password-stdin
```
(type it in the terminal, not in chat; Docker keeps it in the macOS keychain.)

**Do (Mac), each deploy:**
```
git fetch && git checkout <TAG>
deploy/scripts/build-and-push.sh <TAG> ghcr.io/<GITHUB_USER>
```
It builds from a clean copy of the commit (never your working folder), for
the server's processor (linux/amd64, 10-20 minutes on the Mac), checks both
images (not root, no `.env`, no key, no secret-looking value) and pushes.
**You should see:** `ok` lines from check-image.sh, then `Pushed.` and three lines: `API_IMAGE=...`, `WEB_IMAGE=...`, `IMAGE_TAG=...`.
**If not:** a `FAIL` line names the file that must not be there; stop and tell the developer.

**First push only:** GitHub > your profile > Packages > `rawwers-api` and `rawwers-web` > Package settings > check **Visibility: Private**.

**Do (server):**
```
echo '<READ_PACKAGES_TOKEN>' | docker login ghcr.io -u <GITHUB_USER> --password-stdin
nano /opt/rawwers/.env.production      # set API_IMAGE, WEB_IMAGE, IMAGE_TAG to the three printed lines
cd /opt/rawwers/src && deploy/scripts/dc pull
```
**You should see:** every image `Pulled`.
**If not:** `denied` means the login or token is wrong; `manifest unknown` means IMAGE_TAG does not match what was pushed.
**Undo:** nothing to undo (images can be removed with `docker image prune -a`).

---

## Step 10. Start the database and Redis

**Do (server):**
```
cd /opt/rawwers/src
deploy/scripts/dc up -d postgres redis
deploy/scripts/dc ps
```
**You should see:** `postgres` and `redis` `Up ... (healthy)` within 30 seconds.
**If not:** `deploy/scripts/dc logs postgres`. "POSTGRES_PASSWORD is missing" means the secrets file is not filled.
**Undo:** `deploy/scripts/dc down` (keeps the data). To throw the data away as well (only now, while it is empty): `deploy/scripts/dc down -v`.

---

## Step 11. Migrations, as a one-off job

The API never migrates when it starts. Migrations run once, on purpose:
```
deploy/scripts/dc run --rm migrate
deploy/scripts/dc run --rm migrate alembic current
```
**You should see:** a list of `Running upgrade ...` lines, then `alembic current` ending in `(head)`.
**If not:** the first error line says which migration; stop and paste it to the developer. Nothing else is started yet.
**Undo (this first deploy only, the database is empty):** `deploy/scripts/dc down -v` and start again from step 10. On a database with data, never run `alembic downgrade` without the developer: see "Rollback".

---

## Step 12. Reference data (safe to run twice)

```
deploy/scripts/dc run --rm api python scripts/bootstrap_reference_data.py
deploy/scripts/dc run --rm api python scripts/bootstrap_reference_data.py   # again: everything "skipped"
```
**You should see:** the first run: niches `skipped 12` (the migrations made them), then `created` tax rule GB 1, interview questions 5, camera models 98, lens models 13, price caps EUR 40 and GBP 40; then `Done: 197 row(s) added.` The second run: `created 0` everywhere and `Nothing to add`.
**If not:** `FAILED, nothing written:` and the reason; nothing was changed.
**Undo:** not needed (reference rows only). The pound price caps are still a proposal (docs/PRICE_CAPS.md); an admin can change them in the web admin.

---

## Step 13. Start everything

```
deploy/scripts/dc up -d
deploy/scripts/dc ps
```
**You should see, within 2 minutes:** `postgres`, `redis`, `api`, `web`, `caddy` `(healthy)`; `worker`, `worker-photos` `(healthy)` after about a minute; `beat` `(healthy)` after about 2 minutes. (`health: starting` is normal for the first minute.)
**If not:** `deploy/scripts/dc logs --tail 50 <service>`. "refuses to start in production" lists exactly what to fix in the secrets file; then `deploy/scripts/dc up -d` again.
**Undo:** `deploy/scripts/dc down` (keeps data and volumes).

**The first exchange-rate run** (instead of waiting for minute 15 of the hour; the server needs outbound HTTPS to ecb.europa.eu):
```
deploy/scripts/dc exec worker celery -A app.tasks.celery_app.celery_app call app.tasks.scheduled.fx_refresh
sleep 20; deploy/scripts/dc exec api curl -s http://localhost:8000/v1/fx/rates
```
**You should see:** a task id, then `"rates":{"GBP":"0.8..."}` with today's or the last working day's date.
**If not:** `deploy/scripts/dc logs --tail 30 worker | grep -i fx`.

---

## Step 14. The smoke test, from the Mac

```
python3 deploy/scripts/smoke.py --api https://api.rawwers.com --admin https://admin.rawwers.com --expect-release <COMMIT>
```
With Cloudflare Access on (step 7) the two admin lines say "protected by
Cloudflare Access (login page)": correct. Open `https://admin.rawwers.com/login`
yourself in a browser to see the page behind it. Every line must say `ok`.
Then the write check, which signs up a throwaway account (no money, no email:
it is not on the allowlist):
```
python3 deploy/scripts/smoke.py --api https://api.rawwers.com --admin https://admin.rawwers.com --write api.rawwers.com
# server, afterwards: remove the throwaway account
deploy/scripts/dc exec api python scripts/delete_smoke_accounts.py           # shows it
deploy/scripts/dc exec api python scripts/delete_smoke_accounts.py --apply   # removes it
```
**You should see:** `Everything passed.`
**If not:** each `FAIL` line says what; the most common: 52x errors from Cloudflare (Caddy or certificate: `dc logs caddy`), CORS (`CORS_ALLOW_ORIGINS`), docs reachable (should never happen: tell the developer).

**Then, on the server:** `deploy/scripts/version.sh` — read "After every deploy" below.

---

## Step 15. Stripe (test mode): the webhook

**Part 1 (do it during step 8, before anything starts).** In the Stripe dashboard, **Test mode on**, Developers > Webhooks > Add destination, twice. Both: endpoint URL `https://api.rawwers.com/v1/webhooks/stripe`, API version `2025-12-15.clover`.

1. **"Your account"** events (15): `payment_intent.succeeded`, `payment_intent.payment_failed`, `payment_intent.canceled`, `charge.refunded`, `charge.refund.updated`, `refund.created`, `refund.updated`, `refund.failed`, `charge.dispute.created`, `charge.dispute.updated`, `charge.dispute.funds_withdrawn`, `charge.dispute.funds_reinstated`, `charge.dispute.closed`, `transfer.created`, `transfer.reversed`. Description: `RAWWERS platform webhook (pinned)`.
2. **"Connected accounts"** events (1): `account.updated`. Description: `RAWWERS connect webhook (pinned)`.

Copy each destination's **signing secret** (`whsec_...`). In the secrets file:
`STRIPE_WEBHOOK_SECRET=<platform whsec>,<connect whsec>` (both, comma, no spaces).

**Part 2 (now that the API runs): check them.**
```
deploy/scripts/dc run --rm api python scripts/register_stripe_webhook.py --url https://api.rawwers.com/v1/webhooks/stripe --mode test
```
**You should see:** `platform: we_... is as it should be` and `connect: we_... is as it should be` (this only reads; without `--apply` it changes nothing).
**Then:** in Stripe, the platform destination > Send test event `payment_intent.succeeded`. **You should see** delivery status 200 (the API accepts and ignores an unknown payment).
**If not:** 401 = the secret in the file is not this endpoint's; 404/52x = the URL or Cloudflare.
**Undo:** delete the destinations in Stripe.

---

## Step 16. Brevo: authorised IP and the webhook

1. Brevo > (your name, top right) > **Security > Authorised IPs**. If "IP blocking" is on, **add `<SERVER_IP>`** (the server's IPv4 address; the containers send mail out from it). Without it every email fails with 401 "unrecognised IP address", and Sentry gets `email_failure:config`.
2. Brevo > Transactional > Settings > Webhooks > Add: URL `https://api.rawwers.com/v1/webhooks/brevo`, events hard bounce, soft bounce, blocked, invalid, spam, unsubscribed; authentication **Bearer token** = the `BREVO_WEBHOOK_TOKEN` from the secrets file (`grep BREVO_WEBHOOK_TOKEN /opt/rawwers/.env.production`, copy it directly into the Brevo form). Prefer the Bearer header over `?token=` in the URL: URLs end up in logs.

**Undo:** remove the IP or the webhook in Brevo.

---

## Step 17. Email: DNS check and a real test

**Do (Mac):** `deploy/scripts/check-email-dns.sh rawwers.com`
**You should see:** MX to Zoho, one SPF record with its includes followed, DKIM for `zmail`, `brevo1`, `brevo2`, DMARC `p=quarantine`. Notes about SPF not listing Brevo are acceptable when DKIM passes (below).

**Real mail tests** (both to your Gmail address, which must be in `EMAIL_DEV_ALLOWLIST`):
1. From Zoho: send a mail from support@rawwers.com to your Gmail.
2. From the API: register your Gmail address in the Pro or Client app, or ask for a password reset for your admin account at `https://admin.rawwers.com/reset-password`. The code arrives within a minute.

In Gmail, open each > ⋮ > **Show original**. **You should see:** `SPF: PASS`, `DKIM: 'PASS' with domain rawwers.com`, `DMARC: 'PASS'`.
**If DKIM shows another domain** (for example `brevosend.com`) or `FAIL`: rawwers.com is not authenticated in Brevo (Senders, Domains & Dedicated IPs > Domains): DMARC then fails and quarantine sends it to spam. Fix it there, wait for DNS, test again.
**If SPF fails but DKIM and DMARC pass:** acceptable (DMARC passes on DKIM). The indirect SPF include is a LATER row.
**If no mail arrives from the API:** `deploy/scripts/dc logs --tail 50 worker | grep -i mail` (`not_on_dev_allowlist` = the address is not on the list; `brevo: 401` = step 16).

---

## Step 18. R2: bucket, token, CORS

Parts 1-3 are done **during step 8** (the API needs the keys to start); part 4 is the check, now.

1. Cloudflare > R2 > Create bucket `rawwers-media-test` (location: automatic / EU jurisdiction if offered).
2. R2 > Manage API tokens > Create: permission **Object Read & Write**, **this bucket only**. Copy the Access Key ID, Secret Access Key and the S3 endpoint into the secrets file (`R2_*`).
3. The bucket > Settings > **CORS policy** (for uploads from the web admin's browser; the apps do not need it):
   ```
   [{"AllowedOrigins": ["https://admin.rawwers.com"], "AllowedMethods": ["GET", "PUT", "HEAD"], "AllowedHeaders": ["content-type"], "MaxAgeSeconds": 3600}]
   ```
4. **Check from the server** (writes, reads and deletes one small test object):
   ```
   deploy/scripts/dc exec api python -c "
   from app.services import storage as s
   k='deploy-check/hello.txt'; s.upload_object_bytes(k, b'hello', content_type='text/plain'); print('exists', s.object_exists(k)); s.delete_object(k); print('deleted', not s.object_exists(k))"
   ```
   **You should see:** `exists True` and `deleted True`.
   **If not:** `AccessDenied` = the token's bucket or permission; `Could not connect` = the endpoint.

---

## Step 19. Sentry test event (optional, if SENTRY_DSN is set)

```
deploy/scripts/dc exec api python -c "from app.core.sentry import init_sentry, capture_message; init_sentry('api'); capture_message('deploy check'); import sentry_sdk; sentry_sdk.flush()"
```
**You should see:** "deploy check" in the `rawwers-api` project within a minute (environment `production-test`). Then set the alert rules (DEPLOY_CHECKLIST section 2).

---

## Step 20. The first admin

No account exists and there is no default password. You make yours:
1. Register at `https://admin.rawwers.com/register` (behind Access) with `<YOUR_EMAIL>` and a long password from your password manager.
2. **Server:** find its id: `deploy/scripts/dc exec postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT user_id FROM user_account WHERE email = '"'"'<YOUR_EMAIL>'"'"'"'`
3. Put it in the secrets file: `ADMIN_USER_IDS=<that id>`; `deploy/scripts/dc up -d --force-recreate api`.
4. Sign in at `https://admin.rawwers.com/login`. **You should see** the admin pages; Finance > currency settings shows GBP; The Shelf off.
**If not:** "Admin access required" = the id is not in `ADMIN_USER_IDS` or the API was not recreated.
The second factor is Cloudflare Access (step 7); the app has no 2FA of its own (LATER).

---

## Step 21. Backup now, and a restore test

```
deploy/scripts/backup-now.sh
deploy/scripts/restore-test.sh /var/backups/rawwers/rawwers-<time>.dump     # the file it printed
```
**You should see:** `OK: /var/backups/rawwers/rawwers-...dump`, then three `ok` lines and "The backup restores and matches the live database."
**If not:** paste the output to the developer.
Run `backup-now.sh` before every deploy and every migration. The file is lost if the server itself is lost: until batch 4, only the Hetzner backups (step 1) survive that.

**Restore a backup for real** (replaces everything in the database; only with the developer):
```
deploy/scripts/dc stop api worker worker-photos beat web
deploy/scripts/dc exec -T postgres sh -c 'dropdb -U "$POSTGRES_USER" "$POSTGRES_DB" && createdb -U "$POSTGRES_USER" "$POSTGRES_DB"'
deploy/scripts/dc exec -T postgres sh -c 'pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --no-owner --exit-on-error' < /var/backups/rawwers/rawwers-<time>.dump
deploy/scripts/dc up -d
```

---

## Step 22. Done? Everything here must be true

- [ ] `deploy/scripts/dc ps`: every service `(healthy)`.
- [ ] `smoke.py`: `Everything passed.` (the admin lines say "protected by Cloudflare Access"), and the `--write` run passed; smoke accounts deleted.
- [ ] `version.sh`: `DEPLOYMENT_MODE test`, `Stripe key test`, `email allowlist only on`, `API docs off`, `MUX_FAKE off`, `PRESENTATION_VIDEO_ENABLED off`, migration = newest, exchange rates fresh, flag rows 0, The Shelf off.
- [ ] Flags (version.sh, defaults outside development): ai chat off, kill switch on, ai calls off, LLM mock, studioverse off, ecom off, raww minting off, guest discovery off, loaners off, rewards spend off, video uploads on.
- [ ] Stripe test event delivered with 200 (both destinations listed by the check script).
- [ ] Mail from Zoho and from the API: SPF/DKIM/DMARC as in step 17.
- [ ] R2 check `exists True`, `deleted True`.
- [ ] `https://admin.rawwers.com` asks for the Cloudflare Access code in a private window.
- [ ] `https://api.rawwers.com/docs` and `/openapi.json` answer 404; `http://api.rawwers.com` redirects to https.
- [ ] A backup exists in `/var/backups/rawwers`, and restore-test passed.
- [ ] A Hetzner snapshot after the deploy: `rawwers-test-deploy-<date>`.

---

## After every deploy: read version.sh

`deploy/scripts/version.sh` (server). Check: the checkout commit and
`IMAGE_TAG` are the commit you meant; every container `(healthy)`; migration
`current` = `newest`; the switches as in step 22; exchange rates not "none
fresh" (they refresh hourly at minute 15).

---

## Rollback

**Code only (the usual case):** set `IMAGE_TAG` in the secrets file back to the previous commit (version.sh printed it last time), then
```
deploy/scripts/dc up -d
```
**You should see:** the containers recreated on the old images, `(healthy)`; `smoke.py --expect-release <old commit>` passes.

**If the deploy ran a migration:** take the backup first (always: step 21 before migrating). Rules:
- A migration that only **adds** tables or columns: leave the schema at head and roll back the code only; old code ignores what it does not know.
- **Never run `alembic downgrade` in production without the developer.** These lose data on the way down: `20261012_0058` (photographers' "hide my online dot" choice), `20261013_0059` (admin tier overrides), `20261013_0060` (short-notice settings and recorded terms), `20261014_0061` (preparation times; and code older than it cannot run against it), `20261019_0064` (amounts refunded), `20261110_0093`/`0094` (business-dashboard estimates; `bi_daily` is emptied). `20261113_0095`, `20261114_0096`, `20261114_0097` refuse to go down while any non-EUR money row or payout transfer exists.
- **On this test deployment** (no real data) the simplest full rollback is: restore the backup taken before the deploy (step 21, "Restore a backup for real"), then set the old `IMAGE_TAG`.

**Whole server:** Hetzner console > the server > Snapshots > the last good snapshot > Rebuild from it (erases everything since).

---

## Resize the server for the beta

When: before the first real photographers (see DEPLOY_AUDIT.md, "Resource budget": 2 GB has no room for a large photo delivery).
1. Take a snapshot (step 1).
2. Hetzner console > the server > **Rescale** > choose the next size with **4 GB** or more > **"CPU and RAM only"** (keeps the 40 GB disk, so you can go back down later) > Rescale. The server is switched off, resized and started: about 2-5 minutes of downtime.
3. Docker starts by itself; every container restarts (`restart: unless-stopped`). Check `deploy/scripts/dc ps`.
4. Then in the secrets file: `API_WORKERS=2`; with 8 GB also `PHOTO_WORKER_CONCURRENCY=2`. `deploy/scripts/dc up -d`.
**Undo:** Rescale back to the smaller size (only possible because the disk was not grown).

---

## When something is down: the first five commands (server)

1. `deploy/scripts/dc ps` — which service is not `Up (healthy)`. `Restarting` = it crashes at start; `unhealthy` = it runs but does not answer.
2. `deploy/scripts/dc logs --tail 80 <service>` — the last error. "refuses to start in production" lists what to fix in the secrets file.
3. `free -h && df -h /` — memory or disk full? Disk above 90%: `docker system prune` (removes stopped containers and unused images; never `-v` / volumes).
4. `dmesg -T | grep -iE "out of memory|killed process" | tail` — a container killed for memory. Then resize (above) or lower `WORKER_CONCURRENCY`.
5. `deploy/scripts/dc exec api curl -s http://localhost:8000/health/ready` — `{"ready":true,"primary_db":true,"redis":true}`; `false` names what the API cannot reach.

Then: `deploy/scripts/dc restart <service>`, or `deploy/scripts/dc up -d` to bring everything back as the file says. If the website is down but every container is healthy: Cloudflare (DNS records proxied? SSL mode Full (strict)? 52x error codes in the browser) or the Hetzner firewall.

---

## After the deploy

### Point the apps at the server (simulator test)

**Mac**, in `app/`: make two local files (git ignores `env/*.json`):
```
cp env/client.json env/client.server.json
cp env/pro.json env/pro.server.json
# in both: "API_BASE_URL": "https://api.rawwers.com", and the Stripe TEST publishable key (pk_test_...)
flutter run --flavor client -t lib/main_client.dart --dart-define-from-file=env/client.server.json
flutter run --flavor pro -t lib/main_pro.dart --dart-define-from-file=env/pro.server.json
```
Sign up with an address on `EMAIL_DEV_ALLOWLIST` to receive the codes. Not a release build.

### Then: the production Mux environment and the first real video

In this order (details in DEPLOY_CHECKLIST.md section 4):
1. Mux > create the **Production** environment (never reuse dev's keys).
2. Access token (Video read/write), signing key, webhook to `https://api.rawwers.com/v1/webhooks/mux` (4a steps 2-4); the four values into the secrets file; `MUX_FAKE` stays absent.
3. If Brevo-style IP allowlisting exists in Mux: not needed (Mux has none for API calls).
4. The Cloudflare WAF rule of step 6d already lets `/v1/webhooks/mux` through.
5. `deploy/scripts/dc up -d --force-recreate api worker worker-photos beat`; `version.sh` shows `Mux configured yes`.
6. The round trip (4b) with `PRESENTATION_VIDEO_ENABLED=true`; only when all 10 steps pass, keep it on.
Missing in DEPLOY_CHECKLIST section 4 and added there: a cost alert before step 1 of 4b, the WAF note, and that the Pro app build must point at production (env file above) — added 2026-11-21.

### What you risk until batch 4 (off-server backups)

The database holds only test data, so losing it costs time, not data. What
protects it now: the Hetzner daily backups and snapshots (whole server, kept
by Hetzner) and `backup-now.sh` files (on the same server: gone if the server
is). Uploaded photos are in R2, not on the server. Before real users: batch 4
(backups copied to R2 every night, and a tested restore).
