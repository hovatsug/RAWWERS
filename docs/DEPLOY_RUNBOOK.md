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
`<SERVER_IP>` the server's **new** IPv4 address (step 0b), `<OLD_SERVER_IP>`
the address it had before, `<GITHUB_USER>` your GitHub name,
`<YOUR_EMAIL>` your own address, `<YOUR_HOME_IP>` the address you connect
from (https://ifconfig.me shows it), `<TAG>` the tag agreed for this
deploy (the first test deploy: **`deploy-test-1`**, see the decisions table), `<COMMIT>` the 12-character commit build-and-push.sh prints.

Commands marked **Mac** run in the repository on your Mac. Commands marked
**server** run on the server after `ssh root@<SERVER_IP>`.

Other documents: [DEPLOY_SECRETS.md](DEPLOY_SECRETS.md) (every secret, and
rotating), [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md) (the checklist behind
this runbook, flags, the Mux steps), [DEPLOY_AUDIT.md](DEPLOY_AUDIT.md) (the
readiness audit of 2026-11-21: every setting, every service, resource budget).

## Decisions for this deploy (owner, 2026-11-22)

| Decision | Chosen | Why |
|---|---|---|
| Image registry | GitHub Container Registry, **private** packages (step 9) | You already have the account; the server only needs a read-only token; nothing public |
| TLS | **Cloudflare origin certificate** (step 6b), SSL mode **Full (strict)** (step 13b) | Free, 15 years, no renewal job and no API token on the server; Cloudflare checks the certificate on every request |
| Admin protection | **Cloudflare Access with email one-time PIN**, on `admin.rawwers.com` only (step 7) | The app has no 2FA; your home address changes, so an IP allowlist would lock you out; Access adds a second factor in front of the login, with nothing to build |
| API docs | **Off** (`API_DOCS_ENABLED` unset; the API refuses to start if it is on) | The API is public; its full map helps attackers and nobody needs it on the server |
| Workers | **4 GB:** API 2, media worker 2, photo worker 1. **2 GB fallback:** API 1, media 2, photos 1 (the compose defaults) | Measured in the rehearsal (DEPLOY_AUDIT.md section 6) |
| Server size | **Resize to 4 GB before the first start** (step 1b); 2 GB is the fallback | The photo worker alone peaks near 900 MB on a large proof; on 2 GB that is the first thing to run out of memory |
| New primary IPv4 | **Yes** (step 0b) | The old address is in this public repository's history; a new one is not |
| `DEFAULT_CONNECT_COUNTRY` | **PT for the test deploy** (unchanged) | Decided again before a UK launch (MULTI_CURRENCY.md, M6) |
| The tag | **`deploy-test-1`**, an annotated tag on commit **`9f45c7fa5593`** (recorded in [UNGATED_COMMITS.md](UNGATED_COMMITS.md) in the commit after it, since a commit cannot name itself). Check: `git rev-parse --short=12 deploy-test-1^{commit}` prints `9f45c7fa5593` | The commit every step of this runbook was checked against |

---

## Before you start: what to have ready

1. **Hetzner:** the console login, your SSH public key added to the project (Security > SSH keys).
2. **Cloudflare:** the dashboard login for rawwers.com, with Zero Trust enabled (free plan) for the admin protection.
3. **GitHub:** a classic personal access token with `write:packages` (for the Mac) and a second one with `read:packages` only (for the server). Settings > Developer settings > Personal access tokens > Tokens (classic).
4. **Stripe:** the dashboard in **Test mode**: the test secret key (`sk_test_...`). The webhook endpoints are made in step 15.
5. **Brevo:** an API key for this server, and the sender address verified (Senders, Domains & Dedicated IPs). rawwers.com authenticated there (the brevo1/brevo2 DKIM records exist).
6. **R2:** a bucket for this deployment (for example `rawwers-media-test`) and an API token for it (step 18).
7. **Sentry (optional):** the two DSNs (`rawwers-api`, `rawwers-web`).
8. **On the Mac:** Docker Desktop, for the image build of step 9 only (the Mac no longer runs the dev stack: [MAC_DOCKER_OFF.md](MAC_DOCKER_OFF.md)); this repository at the agreed tag, `python3`, `dig`.
9. An hour and a half without interruptions for steps 0 to 14; the rest can wait for another day.

---

## Step 0. Rebuild the server and read its baseline

**Do (Hetzner console):** Servers > the server > Rebuild > Ubuntu 24.04 > select your SSH key > Rebuild. This erases everything on it, including the old projects and `/opt/caddy`. That is intended.

Then do **step 0b (the new address, below)** before logging in. In this runbook,
`<SERVER_IP>` always means the **new** address from step 0b; `<OLD_SERVER_IP>`
is the one the server has today.

**Do (Mac), after step 0b:** wait two minutes, then
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
**You should see:** `Ubuntu 24.04`, about 2 GB memory (4 GB after step 1b), 40 GB disk, port 80 and 443 `free`, `docker: not installed`, `/opt/caddy: not there (good)`. (The new address was already checked in step 0b, part 7.)
**If not:** paste the whole output to the developer and stop.
**Undo:** nothing to undo.

### 0b. A new primary IPv4 address

Why: the server's current address is in this public repository's git history
(an old Makefile). A new address costs about EUR 0.50 a month and makes that
leak useless. The steps follow Hetzner's documentation ("Primary IPs",
docs.hetzner.com/cloud/servers/primary-ips/overview and
.../getting-started/creating-primary-ips, read 2026-11-22). Hetzner's rule:
a server's primary IPs can only be added, removed or replaced **while the
server is powered off**.

1. **Write down the old address:** Hetzner console > the server > Overview: the IPv4 shown is `<OLD_SERVER_IP>`. Keep it in your notes (not in the repository) until step 6.
2. **Create the new one:** left menu **IPs** > upper menu **Primary IPs** > **Create Primary IP**. Name `rawwers-ipv4`, **Location: the same as the server (Nuremberg)** (an IP can only go to a server in its own location), protocol **IPv4** > **Add & buy now**.
   **You should see:** `rawwers-ipv4` in the list, unassigned, with a new address. That is `<SERVER_IP>` from now on.
3. **Protect it:** open `rawwers-ipv4` and switch on **Protection** (a lock icon then shows in the list). A protected IP cannot be deleted by accident, and a server holding one cannot be deleted either.
4. **Power the server off:** the server > **Power** > **Power off**. Wait until it shows off.
5. **Swap the address:** in **IPs > Primary IPs**, on the **old** IPv4 open its actions menu (the "⋯" at the end of its row) and **unassign** it from the server. Then on `rawwers-ipv4` open the same menu and **assign** it to the server. (Hetzner's pages describe the rule but not these two button names; if your screen words them differently, the menu is the same place. If you cannot find them, stop and ask.)
   Leave the server's IPv6 as it is.
6. **Power on:** the server > **Power** > **Power on**.
   **You should see:** the server's Overview lists the **new** IPv4. Hetzner: "Changing/assigning the Primary IPv4 does not require any manual configurations" inside the server.
7. **Check from the Mac:**
   ```
   ssh-keygen -R <OLD_SERVER_IP>; ssh-keygen -R <SERVER_IP>
   ssh root@<SERVER_IP> 'ip -br -4 addr show scope global; curl -4 -s https://ifconfig.me; echo'
   ```
   **You should see:** the new address twice (on `eth0`, and from ifconfig.me).
   **If not:** the Hetzner console's own terminal (server > Console) still works; power off, check the assignment in Primary IPs, power on.
8. **Everywhere the address is used**, use the new one: Cloudflare DNS `api` and `admin` (step 6a), Brevo authorised IPs (step 16), your SSH commands. The Hetzner firewall (step 2) is attached to the **server**, not to an address, and its rules name only Cloudflare's ranges and your home address: nothing to change there.
9. **Release the old address, only after step 22 is all ticked:**
   1. **Before deleting:** in Cloudflare DNS, search for `<OLD_SERVER_IP>`: no record may still name it.
   2. IPs > Primary IPs > the old IPv4 > switch **Protection off** first. Hetzner will not delete a protected IP: with the lock on, Delete is refused or greyed out.
   3. Then **Delete** it.
   **Why not leave it:** the old IP keeps costing money every month until it is deleted, assigned or not (unassigning is not enough).
   **You should see:** it is gone from IPs > Primary IPs; only `rawwers-ipv4` is left, with its lock.

**Undo (before step 9 only):** power off, unassign `rawwers-ipv4`, assign the old IPv4 back, power on. After step 9 the old address is gone for good.

### 0c. Remove the old deploy secrets from GitHub

The old automatic deploy (removed in this release) used repository secrets
that name the old server and hold an SSH key that could log in to it. The
rebuild already made that key useless on the server; remove the copies too.

**Do (GitHub, the repository):**
1. **Settings > Secrets and variables > Actions > Repository secrets.** Delete each of these that exists: `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`, `DEPLOY_REPO_URL`, `PROD_DEPLOY_HOST`, `PROD_DEPLOY_USER`, `PROD_DEPLOY_SSH_KEY`, `PROD_DEPLOY_REPO_URL`, `PROD_HEALTH_URL`, `PROD_READY_URL`, `PROD_PROMETHEUS_URL`, `PROD_PROMETHEUS_TOKEN`, `STAGING_HEALTH_URL`, `STAGING_READY_URL`, `STAGING_PROMETHEUS_URL`, `STAGING_PROMETHEUS_TOKEN`. Also look at the **Variables** tab for any of these names, and delete them there.
2. **Settings > Environments:** open `production` and `staging` (if they exist) and delete their secrets and variables, then the environments themselves (nothing uses them now).
3. **Settings > Deploy keys:** delete any key made for the old server.
4. **Your Mac:** if `~/.ssh` holds a key made only for that GitHub deploy, delete it.

**You should see:** no repository or environment secret that names a server, a deploy or Prometheus. `GITHUB_TOKEN` is not one of yours (GitHub makes it per run) and is not listed.
**Undo:** none needed; nothing uses these any more (`.github/workflows/deploy.yml` builds images by hand only).

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

## Step 1b. Resize to 4 GB before the first start (recommended)

The test deploy is meant to run on **4 GB**. 2 GB still works for an empty
test, but it is the risky fallback: the photo worker alone needs up to about
900 MB while it processes one large proof, and on 2 GB that pushes the server
into swap or makes the kernel kill a container in the middle of a delivery
(DEPLOY_AUDIT.md section 6). Doing it now, while nothing runs, costs no
downtime for anyone.

**Do (Hetzner console):** after the snapshot of step 1:
1. The server > **Rescale**. Choose the next size that shows **4 GB** of RAM in the same family (the screen lists RAM and the monthly price for each).
2. Choose **"CPU and RAM only"** (keeps the 40 GB disk, so you can go back down later). Rescale. The server powers off, resizes and starts: 2-5 minutes.
3. **Mac:** `ssh root@<SERVER_IP> free -h`
**You should see:** `Mem: total` about `3.7Gi`-`3.8Gi`.
**If not:** the Rescale screen shows an error, or the old size is still listed: try again; nothing is installed yet.
**Undo:** Rescale back to the 2 GB size (possible only because the disk was not grown). Then in step 8 leave `API_WORKERS` at 1.

**If you skip it (2 GB):** keep the compose defaults (API 1 worker, media 2, photos 1), do not deliver large photo sets, and resize before the first real photographer ("Resize the server", near the end).

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
# SSH: keys only. 00- so it is read first: sshd keeps the first value it reads.
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin prohibit-password\n' > /etc/ssh/sshd_config.d/00-rawwers.conf
sshd -t && systemctl reload ssh
# 2 GB swap: a safety net for memory peaks, not extra memory.
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
echo 'vm.swappiness=10' > /etc/sysctl.d/99-swap.conf && sysctl -p /etc/sysctl.d/99-swap.conf
# UTC and synchronised time.
timedatectl set-timezone UTC && timedatectl set-ntp true
echo "basics done"
```
**Why `00-rawwers.conf`:** for each setting, sshd uses the **first** value it reads, and it reads the files in `/etc/ssh/sshd_config.d/` in name order. A cloud image may already carry a file there that says `PasswordAuthentication yes` (for example `50-cloud-init.conf`); a file named `99-` would be read after it and ignored. `00-` is read first.
**You should see:** `basics done`. Then, **in a second terminal on the Mac, keeping the first one open**: `ssh root@<SERVER_IP> echo ok` prints `ok`.
**If not:** in the first terminal (still connected), `rm /etc/ssh/sshd_config.d/00-rawwers.conf && systemctl reload ssh`, and tell the developer.
**Check:** `bash /root/server-baseline.sh` now shows swap 2.0G, `clock synchronised: yes`, **`passwordauthentication no`** (if it says `yes`, an earlier file still wins: `ls /etc/ssh/sshd_config.d/` and tell the developer), fail2ban `active`.
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
**You should see:** the commit of `<TAG>` (for `deploy-test-1`: `9f45c7f`).
**If not:** check the tag exists on GitHub (`git ls-remote --tags origin` on the Mac).
**Undo:** `rm -rf /opt/rawwers/src`.

From now on, every server command runs in `/opt/rawwers/src`, and
`deploy/scripts/dc` means "docker compose with the right files".

---

## Step 6. Cloudflare: DNS, TLS, cache, WAF

### 6a. DNS records (dashboard: rawwers.com > DNS > Records)

1. **Add** `A api <SERVER_IP>` **Proxied** (orange cloud).
2. **Add** `A admin <SERVER_IP>` **Proxied**.
3. **Remove the old web records** that point at `<OLD_SERVER_IP>` (the address before step 0b): `app`, `dani`, `pact`, `recastwebs`, `ritagame`, `rocket`, and the root `rawwers.com` (and `www` if it points there). Only A/AAAA/CNAME records whose content is the server's old IPv4 or its IPv6.
4. **AAAA records:** filter the list by type **AAAA**. Delete any AAAA record whose content is the server's IPv6 (Hetzner console > the server > Overview shows it). `api` and `admin` get **no** AAAA record: Cloudflare already answers visitors over IPv6 for proxied names. **Never touch** MX, TXT, `zmail._domainkey`, `brevo1/brevo2._domainkey`, `_dmarc`, the Brevo verification record, or anything under `send.pact` and `resend._domainkey.pact` (another project).

**You should see:** `api` and `admin`, type A, content `<SERVER_IP>` (the new address), orange cloud. Searching the records for `<OLD_SERVER_IP>` finds nothing; no AAAA record names the server's IPv6.
**Undo:** re-add a record (write down each one you delete: name, type, content, proxied).

### 6b. TLS: the Cloudflare origin certificate (Full (strict) comes in step 13b)

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
3. **Not yet: the SSL mode.** Leave SSL/TLS > Overview as it is. "Full (strict)" is switched on in **step 13b**, after Caddy serves this certificate (step 13).
4. SSL/TLS > Edge Certificates: **Always Use HTTPS** on, **Minimum TLS Version** 1.2. Leave HSTS off here: Caddy sends it for api and admin only.

**Undo:** revoke the certificate under Origin Server and delete the two files.

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

Decided 2026-11-22: Cloudflare Access with an email one-time PIN, on
**`admin.rawwers.com` only**. Never on `api.rawwers.com`: the apps and the
webhooks could not pass it. Menu names follow Cloudflare's documentation as
of 2026-11 ("Zero Trust > Access controls"); older screens call the same
place "Access > Applications".

1. **One-time PIN on:** Cloudflare dashboard > **Zero Trust** (free for up to 50 users; the first visit asks for a team name and the Free plan) > **Integrations** > **Identity providers**. Under **Your identity providers**: if **One-time PIN** is not listed, **Add new identity provider** > **One-time PIN**.
2. **The policy:** **Zero Trust** > **Access controls** > **Policies** > **Add a policy**.
   - Policy name `owner`, Action **Allow**, Session duration **24 hours**.
   - Rules > **Include** > selector **Emails** > value `<YOUR_EMAIL>` (add a second address of your own if you want one). Save.
   - **Never** use the selector **Everyone**, or **Login Methods = One-time PIN**, in Include: either lets anyone with an email address in.
3. **The application:** **Zero Trust** > **Access controls** > **Applications** > **Create new application** > **Self-hosted and private**.
   - Name `RAWWERS admin`. **Add public hostname**: subdomain `admin`, domain `rawwers.com`, path empty.
   - Access policies: select `owner`.
   - Identity providers: **One-time PIN**. Leave "Apply instant authentication" off.
   - Session Duration **24 hours**. **Create**.
   Cloudflare's own warning applies: "All Access applications are deny by default"; only your address gets through.

**You should see (after step 14):** in a private browser window, `https://admin.rawwers.com` shows Cloudflare's login page. Enter your address > **Send login code**; the code arrives from `noreply@notify.cloudflare.com` and lasts 10 minutes; paste it > **Sign in**; then the RAWWERS admin login.
**Check that strangers are kept out:** enter an address that is not in the policy: the page still says "A code has been emailed to you", but no mail arrives (that is how Cloudflare hides who is allowed). Also: Access controls > Applications > `RAWWERS admin` > Edit > Policies > **Policy tester** with your address (it works once you have logged in once).
**If not:** check the public hostname is exactly `admin.rawwers.com` and the policy is attached to the application. No code arriving: look in spam for `notify.cloudflare.com`.
**Undo:** delete the application (the admin is then protected only by its own login).

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
Fill every `<FROM ...>` line: the images (from step 9), Stripe **test** key, R2 (step 18 makes the bucket and token), Brevo, `EMAIL_DEV_ALLOWLIST` (your own addresses), and `STRIPE_WEBHOOK_SECRET`: make the two Stripe webhook destinations **now** (step 15, part 1: Stripe accepts them before the server answers) and put both signing secrets in. Leave every `MUX_*` empty. **On 4 GB (step 1b) also set `API_WORKERS=2`**; on 2 GB leave it out (1). [DEPLOY_SECRETS.md](DEPLOY_SECRETS.md) says where each value comes from.
The API, workers and beat refuse to start while any required value is missing, and list them; that is the check that the file is complete.

**`EMAIL_DEV_ALLOWLIST`: list about 12 addresses in full from the start.** On this test deployment the server emails only the addresses on this list. Each entry must be the whole address: there is no wildcard, no whole domain and no plus-address matching, and **every change** needs the services recreated (`deploy/scripts/dc up -d --force-recreate api worker worker-photos`). So put them all in now: your own address, `<you>+admin@...`, `<you>+pro1@...` to `<you>+pro4@...`, `<you>+client1@...` to `<you>+client4@...`, and any real second address of yours. Gmail delivers every `+` address to your own inbox. More in [WORKING_AGAINST_THE_SERVER.md](WORKING_AGAINST_THE_SERVER.md).

**For `deploy-test-1` only, add one line by hand:** `LIGHTROOM_PLUGIN_LATEST_VERSION=1.2.5`. The template in the tag does not have it (the next tag's does), and without it the API says the newest plug-in is 1.2.3.

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

**Docker Desktop is for this build only.** Start it, and if the old dev containers are still there, stop them first so the build has the Mac to itself (stop, never `down`: [MAC_DOCKER_OFF.md](MAC_DOCKER_OFF.md) explains why):
```
cd ~/Developer/RAWWERS/api && docker compose stop && cd -
```
After the push below, quit Docker Desktop (Docker menu > Quit Docker Desktop).

**Never use the GitHub workflow `.github/workflows/deploy.yml` for these images.** Its header says DO NOT USE FOR DEPLOYS (since 628a997): it builds the wrong stage, as root, with `http://localhost:8000` inside the web image. It stays unused until it is fixed after the first deploy; `build-and-push.sh` is the only supported build.

**Do (Mac), each deploy: build from a checkout of the tag** (for this deploy `<TAG>` = `deploy-test-1`, commit 9f45c7f), so the images and the scripts that build them match the tag:
```
git status --short                       # must print nothing (a clean worktree)
git fetch --tags && git checkout <TAG>
git describe --tags --exact-match        # must print <TAG>
deploy/scripts/build-and-push.sh <TAG> ghcr.io/<GITHUB_USER>
```
**If `git status --short` prints anything:** commit or stash it first (`git stash`), never build over it. **If `git describe` prints an error:** you are not on the tag; run the checkout again.
**Afterwards:** `git switch -` takes you back to your branch, and quit Docker Desktop.
The image tag is the commit's 12 characters: for `deploy-test-1` it must say `9f45c7fa5593`.
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

## Step 9b. Check the images are for the server's processor

The server is x86 (`linux/amd64`). An image built for another processor
(for example `linux/arm64` on an Apple-silicon Mac without the script) pulls
fine but cannot start. build-and-push.sh always builds `linux/amd64` and
check-image.sh refuses anything else, so this is the last look before the
first start.

**Do (server):**
```
cd /opt/rawwers/src
uname -m
for i in $(deploy/scripts/dc config --images | sort -u); do docker image inspect -f '{{.Os}}/{{.Architecture}}  {{index .RepoTags 0}}' "$i"; done
```
**You should see:** `x86_64`, then `linux/amd64` on **every** line (rawwers-api, rawwers-web, postgres, redis, caddy).
**If not, or later the symptom:** a container keeps restarting and `deploy/scripts/dc logs --tail 5 <service>` shows `exec format error` (for example `exec /usr/local/bin/uvicorn: exec format error`). **Fix:** on the Mac run `deploy/scripts/build-and-push.sh <TAG> ghcr.io/<GITHUB_USER>` again (never a plain `docker build`), then on the server `deploy/scripts/dc pull` and run this check again.
**Undo:** nothing to undo.

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
**You should see:** the first run: niches `skipped 12` (the migrations made them), then `created` tax rule GB 1, interview questions 5, camera models 98, lens models 13, price caps EUR 40 and GBP 40; then `Done: 197 row(s) added.` The GBP line ends with `PROVISIONAL: not approved by the owner (docs/PRICE_CAPS.md)`: correct, they are a proposal until you approve them. The second run: `created 0` everywhere and `Nothing to add`.
**If not:** `FAILED, nothing written:` and the reason; nothing was changed.
**Undo:** not needed (reference rows only).
**If you do not want the provisional pound caps on the server yet:** run it with `--skip-price-caps` instead, and load the caps later through the web admin (below).

### Changing reference data later

Running the bootstrap again never changes a row that exists (by design: an
admin may have edited it). So a change is made one of these ways, never by
editing the CSV files and re-running, and never with SQL by hand:

| What | How to change it safely | Recorded |
|---|---|---|
| Price caps (per niche, tier, currency) | Web admin > **Settings > Price caps**: choose the currency, edit the cells (or **Import CSV…**), **Review** shows every change from-to, **Save caps** | yes, admin audit log |
| Camera models (which bodies are full-frame) | Web admin > **Settings > Camera reference**: add, edit, or import | yes |
| "Meet the photographer" interview questions | Web admin > **Settings > Interview questions** | yes |
| Niches (name, banner) | Web admin > **Settings > Niche banners**; other niche fields through the admin API (`PUT /v1/admin/niches`) | yes |
| Upload limits, video size, worker counts and other settings | The secrets file (`/opt/rawwers/.env.production`), then `deploy/scripts/dc up -d --force-recreate api worker worker-photos beat`; `version.sh` shows the switches | no (write the change in your notes) |
| The UK VAT row (rate, threshold) | **No safe way yet**: no admin screen, no script option. LATER #94 (BETA_SCOPE.md). Until then ask the developer; it would be a one-line migration | — |
| Lens models | **No screen**: same as the VAT row, LATER #94 | — |

Before any of these on a server with real data: `deploy/scripts/backup-now.sh`.

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

## Step 13b. Cloudflare: SSL mode Full (strict)

Now, not in step 6b: until step 13 nothing on the server served the origin
certificate, so Cloudflare could not check it. From here Cloudflare checks it
on every request.

**Do:** Cloudflare > rawwers.com > SSL/TLS > Overview > **Full (strict)**.
**You should see:** within a minute, `https://api.rawwers.com/healthz` in a browser answers (a small JSON), and `https://admin.rawwers.com` shows the Cloudflare Access page (step 7).
**If not:** Cloudflare error **526** "Invalid SSL certificate" right after switching means the certificate files or Caddy's access to them: the two files of step 6b do not belong together, a file is empty or not PEM, or Caddy cannot read `/opt/rawwers/certs`. `deploy/scripts/dc logs caddy` names the file. Fix it, then `deploy/scripts/dc restart caddy`. Error 521 or 522 is not the certificate: Caddy is down or the firewall (step 2).
**Undo:** SSL/TLS > Overview > back to the previous mode.

**If something is wrong later** (a 526 that appears after it worked): the certificate was revoked or replaced in Cloudflare, or the files on the server changed: same checks as above.

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

Parts 1-3 are done **during step 8** (the API needs the keys to start); part 4 is the check, now; part 5 any time before the first photo upload.

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
5. **The lifecycle rule for unfinished uploads** (once per bucket). A large photo goes up in parts; an upload abandoned half way (Lightroom quit, a laptop closed, an app killed) leaves its parts in the bucket, billed, until R2 aborts them, which by default is after 7 days. The bucket > Settings > **Object lifecycle rules** > Add rule: **"Abort incomplete multipart uploads"** after **1 day**, for the **whole bucket** (no prefix). A resumed upload within the day still picks up its parts. The API's hourly `remove-unfinished-uploads` job cleans its own records too; the bucket rule is still needed for the parts.
   **You should see:** the rule listed under Object lifecycle rules, "Abort incomplete multipart uploads", 1 day, the whole bucket.
   **Undo:** delete the rule.

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
- [ ] Cloudflare SSL/TLS > Overview shows **Full (strict)** (step 13b), and no 526 error.
- [ ] `smoke.py`: `Everything passed.` (the admin lines say "protected by Cloudflare Access"), and the `--write` run passed; smoke accounts deleted.
- [ ] `version.sh`: `DEPLOYMENT_MODE test`, `Stripe key test`, `email allowlist only on`, `API docs off`, `MUX_FAKE off`, `PRESENTATION_VIDEO_ENABLED off`, migration = newest, exchange rates fresh, flag rows 0, The Shelf off.
- [ ] Flags (version.sh, defaults outside development): ai chat off, kill switch on, ai calls off, LLM mock, studioverse off, ecom off, raww minting off, guest discovery off, loaners off, rewards spend off, video uploads on.
- [ ] Stripe test event delivered with 200 (both destinations listed by the check script).
- [ ] Mail from Zoho and from the API: SPF/DKIM/DMARC as in step 17.
- [ ] R2 check `exists True`, `deleted True`.
- [ ] R2 lifecycle rule listed: "Abort incomplete multipart uploads" after 1 day, whole bucket (step 18, part 5).
- [ ] `https://admin.rawwers.com` asks for the Cloudflare Access code in a private window.
- [ ] `https://api.rawwers.com/docs` and `/openapi.json` answer 404; `http://api.rawwers.com` redirects to https.
- [ ] A backup exists in `/var/backups/rawwers`, and restore-test passed.
- [ ] A Hetzner snapshot after the deploy: `rawwers-test-deploy-<date>`.
- [ ] The server's Overview shows the new IPv4; then (step 0b, part 9) the old primary IPv4 is deleted and no DNS record names it.
- [ ] GitHub: no old deploy secrets, environments or deploy keys (step 0c).
- [ ] `free -h` shows about 3.8 GiB (step 1b), or you chose 2 GB on purpose.

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

## Before the first real photographer

Done on the test deploy as it is; required before a real photographer signs up:
1. **4 GB of memory** (step 1b, or "Resize the server for the beta" below).
2. **Raise the Postgres memory settings to the 4 GB values.** The test deploy keeps the 2 GB settings (owner, 2026-11-22). A developer changes them in `deploy/compose.prod.yml` (the `postgres` service), in a commit with a new tag: `shared_buffers=256MB`, `effective_cache_size=1536MB`, `work_mem=8MB`, `maintenance_work_mem=128MB`, and the container's `mem_limit` raised to fit (DEPLOY_AUDIT.md, "Resource budget"). Then build and deploy that tag (step 9) and `deploy/scripts/dc up -d postgres`.
   **You should see:** `deploy/scripts/dc exec postgres psql -U rawwers -c 'show shared_buffers'` prints `256MB`.
   **Undo:** deploy the previous tag again.
3. **The pound price caps reviewed with UK photographers** and then approved or corrected (PRICE_CAPS.md, "Before launch").

---

## Resize the server for the beta

Only if you stayed on 2 GB at step 1b. When: before the first real photographers (see DEPLOY_AUDIT.md, "Resource budget": 2 GB has no room for a large photo delivery).
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
