# Off-server backups and restores

Every night at 03:30 UTC the server dumps the database, encrypts it with
**age** to a **public** key, and copies it to a separate R2 bucket
(`rawwers-backups-test` now, `rawwers-backups` live). It then reads the copy
back and checks it. The private key that opens the backups is **only with
Gus**: in the password manager and on paper, never on the server, never in
chat. If a night is missed or fails, **Sentry emails Gus**.

A backup is only proven by a restore. The monthly drill restores the newest
one **on the Mac** and compares it with its manifest (about 10 minutes).

| Piece | Where |
|---|---|
| The nightly job | `deploy/scripts/backup-offsite.sh`, started by systemd (`deploy/systemd/`, installed by `deploy/scripts/install-backup-timer.sh`) |
| Its settings | `/opt/rawwers/backup.env` on the server, mode 600 (bucket, token, the public key, the Sentry monitor name) |
| The restore on the Mac | `deploy/scripts/restore-from-offsite.sh` |
| The tests | `NATIVE_DB_ROOT=1 tools/tests/native-db.sh deploy/tests` (no network, no real bucket) |

What is in each backup, under `<folder>/<year>/<month>/rawwers-<UTC time>`:

| File | What it holds |
|---|---|
| `.dump.age` | The whole database (a pg_dump), encrypted |
| `.secrets.age` | The 8 secrets that cannot be made again (`ADDRESS_ENCRYPTION_KEYS`, `UNSUBSCRIBE_SIGNING_KEYS`, `MEDIA_SHARE_TOKEN_PEPPER` and the five other peppers), encrypted. Nothing that a service can issue again (Stripe, Brevo, R2, Mux keys) |
| `.manifest.json` | Not encrypted, no secret: sizes and sha256 of both files, the time, migration, checkout commit, `IMAGE_TAG`, the **names** of the secrets kept, and the row count of every table, counted in the same database snapshot as the dump |

| Folder | Written by | Kept |
|---|---|---|
| `daily/` | the 03:30 UTC run | 35 days |
| `monthly/` | the first daily run of each month (a second copy) | 12 months |
| `predeploy/` | `backup-offsite.sh --label predeploy`, before every deploy or migration | 35 days |
| `intraday/` | only after switching to every 6 hours (09:30, 15:30, 21:30 UTC) | 3 days |
| `locktest/` | one test file, by hand, once (set-up step 9) | 1 day |

What a backup does **not** hold: photos and videos (they are in the media
bucket; BETA_SCOPE #97), Redis (queues and rate limits, safe to lose), the
origin certificate (make a new one), the secrets a service can issue again.

**Worst case today: 24 hours of data lost** (nightly). Every 6 hours: see
"Every 6 hours" at the end.

---

## Set-up (once per environment)

Values you copy (tokens, keys) go **straight from the Cloudflare page into
the file on the server or into the password manager**. Never into chat,
email, a ticket or the repository. You paste back only the command output
asked for, which never contains them.

### 1. Cloudflare two-factor sign-in (Mac, browser)

Cloudflare dashboard > your profile (top right) > **My Profile** >
**Authentication** > **Two-Factor Authentication**: set it up with an
authenticator app, and save the backup codes in the password manager.
Bucket locks protect against a stolen server token, **not** against someone
who signs in to the Cloudflare account as you.

### 2. The backup bucket (Mac, browser)

Cloudflare > **R2** > **Create bucket**: name `rawwers-backups-test` (live:
`rawwers-backups`), location **Automatic**; if a **Jurisdiction** choice is
offered, choose **European Union (EU)**. A bucket made in the EU
jurisdiction has its own endpoint (it contains `.eu.`): copy the **S3 API**
endpoint the bucket's Settings page shows.

### 3. Locks and lifecycle rules, by folder (Mac, browser)

The bucket > **Settings** > **Bucket lock rules** > **Add rule**, then
**Object lifecycle rules** > **Add rule**. Make exactly these:

| Prefix | Bucket lock (retention) | Lifecycle: delete objects after |
|---|---|---|
| `daily/` | 35 days | 35 days |
| `predeploy/` | 35 days | 35 days |
| `monthly/` | 365 days | 365 days |
| `locktest/` | 1 day | 1 day |

Also keep the default rule that aborts unfinished multipart uploads (if
there is none, add "Abort incomplete multipart uploads" after 1 day, whole
bucket). Do **not** add `intraday/` yet (see "Every 6 hours").

A lock wins over a lifecycle rule: nothing is deleted before its lock ends,
by anyone with a token. A bucket with lock rules cannot be emptied until the
rules are removed ([Cloudflare: bucket locks](https://developers.cloudflare.com/r2/buckets/bucket-locks/)).

### 4. Two tokens (Mac, browser)

R2 > **Manage API tokens** > **Create API token**, twice:

| Token | Permission | Buckets | Goes to |
|---|---|---|---|
| `rawwers-backup-server` | **Object Read & Write** | **only** the backup bucket | `/opt/rawwers/backup.env` on the server (step 6) |
| `rawwers-backup-mac` | **Object Read only** | **only** the backup bucket | the password manager; used for the restore drill |

Each shows an Access Key ID and a Secret Access Key **once**. Never give
either token "Admin Read & Write": that permission can remove the locks.

### 5. The age key pair (Mac, Terminal)

Install age first ("On the Mac, once", below). Then:
```
~/Developer/RAWWERS-work/bin/age-keygen -o ~/Desktop/rawwers-backup-key.txt
```
**You should see:** `Public key: age1...` (about 60 characters). That line is
public: it goes into `backup.env` (step 6). The **file** holds the private
key (a line starting `AGE-SECRET-KEY-1`).

1. Password manager: a new secure note "RAWWERS backup key", with the whole
   content of the file (open it with TextEdit, copy, paste).
2. Paper: print or write the `AGE-SECRET-KEY-1...` line; keep it where the
   company papers are. Check one character group against the screen.
3. Keep the file for the drills in a folder only you use, for example
   `~/Documents/rawwers-keys/` (`chmod 600` on it). Not in the repository,
   not in iCloud Drive or a shared folder.
4. Delete it from the Desktop.

**Losing this key makes every backup unreadable.** It is not on the server
and Cloudflare cannot recover it.

### 6. The settings file on the server (server)

```
apt-get update && apt-get install -y age rclone
age --version && rclone version | head -1
install -m 600 /dev/null /opt/rawwers/backup.env
nano /opt/rawwers/backup.env
```
Type these lines, with the values from steps 2, 4 and 5:
```
BACKUP_R2_ENDPOINT=<the bucket's S3 API endpoint>
BACKUP_R2_ACCESS_KEY_ID=<rawwers-backup-server Access Key ID>
BACKUP_R2_SECRET_ACCESS_KEY=<rawwers-backup-server Secret Access Key>
BACKUP_R2_BUCKET=rawwers-backups-test
BACKUP_AGE_RECIPIENT=<the age1... public key>
BACKUP_SENTRY_MONITOR=rawwers-backup-test
BACKUP_RCLONE_PROVIDER=Cloudflare
```
**You should see:** age `v1.1.1`, rclone `v1.60.1` (Ubuntu 24.04's packages).
Paste back the two version lines only.

### 7. Can the server reach the bucket? (server)

```
cd /opt/rawwers/src && deploy/scripts/backup-offsite.sh --check-bucket
```
**You should see:** `OK: bucket reachable (0 entries at the top) with provider Cloudflare`.
**If not:** change the last line of `backup.env` to
`BACKUP_RCLONE_PROVIDER=Other` and run it again. If both fail: the endpoint,
key or bucket name is wrong (check them, never paste them). If neither
works with Ubuntu's rclone 1.60.1, install the official package instead
([rclone.org/downloads](https://rclone.org/downloads/): the `.deb` for
Linux amd64, after checking its SHA256 against the `SHA256SUMS` file on the
same page), and run step 7 again.
Paste back the output (it contains no secret).

### 8. A first real backup, by hand (server)

```
deploy/scripts/backup-offsite.sh --label predeploy --dry-run
deploy/scripts/backup-offsite.sh --label predeploy
```
**You should see:** first `DRY RUN: nothing uploaded` with three file names,
then `OK: predeploy/<year>/<month>/rawwers-<time>: uploaded and verified (...)`.

### 9. Prove the lock (server)

```
deploy/scripts/backup-offsite.sh --lock-test
```
With the **server's** token it puts a small test file in `locktest/` and
tries to delete it. **You should see:** `OK: the bucket refused to delete
...` (Cloudflare answers 409 `ObjectLockedByBucketPolicy`). The file goes by
itself after a day. **If it says PROBLEM:** the `locktest/` lock is missing
(step 3), so the other locks may be missing too: check them all.

### 10. The timer (server)

```
deploy/scripts/install-backup-timer.sh
systemctl list-timers 'rawwers-backup*'
systemd-analyze calendar '*-*-* 03:30:00 UTC'
```
**You should see:** `Installed.`, the daily timer with its next run at 03:30
UTC, and `systemd-analyze` showing the next 03:30 UTC.

### 11. The alarm (Mac, browser, after the first daily run)

The first daily run (step 10's timer, or `systemctl start rawwers-backup@daily`)
sends Sentry a check-in that **creates the monitor itself** (an "upsert":
daily at 03:30 UTC, a margin of 2 hours, at most 30 minutes running;
[Sentry: Crons over HTTP](https://docs.sentry.io/product/crons/getting-started/http/)).
In Sentry: **Monitors** (Crons) should list `rawwers-backup-test` with one OK
check-in. If it is not there, make it by hand: Crons > **Add monitor**, name
`rawwers-backup-test` (the same slug), schedule crontab `30 3 * * *`,
timezone UTC, check-in margin 120 minutes, max runtime 30 minutes, then
run `systemctl start rawwers-backup@daily` again.

A monitor alerts **nobody** until an alert rule exists. **Monitors >
Alerts > Create Alert**: "Alert on specific monitors", **Connect Monitors**
> `rawwers-backup-test`; action **Notify** > **Member** > you (email).
Save. Sentry also emails the monitor's owner when it has been failing for
14 days; that is not the alarm, the rule is.

The alarm then rings when: a night's check-in has not arrived by 05:30 UTC
(about 26 hours after the last good backup), or a run reports an error.

---

## On the Mac, once

**age** (an official build, checked against the checksum GitHub publishes
for it; Homebrew would first build the Go compiler from source on this Mac):
```
mkdir -p ~/Developer/RAWWERS-work/bin && cd ~/Developer/RAWWERS-work
curl -fLO https://github.com/FiloSottile/age/releases/download/v1.3.2/age-v1.3.2-darwin-amd64.tar.gz
echo "1d1e4bc66e1427edad7739ae7616157de0e79db8b6d2a1497d7d9925fb06a539  age-v1.3.2-darwin-amd64.tar.gz" | shasum -a 256 -c -
tar -xzf age-v1.3.2-darwin-amd64.tar.gz && cp age/age age/age-keygen bin/ && rm -rf age age-v1.3.2-darwin-amd64.tar.gz
bin/age --version
```
**You should see:** `...tar.gz: OK`, then `v1.3.2`. About a minute.
(Checked 2026-11-26: the checksum is the one GitHub lists for that file; a
backup encrypted by age 1.1.1, the server's, decrypts with 1.3.2.)

**Postgres 16 and the Python** of the tests: already there if
`tools/tests/native-db.sh setup` has run (BACKEND_TESTS.md).

**The read-only token** (set-up step 4) in a file only you can read,
for example `~/Documents/rawwers-keys/backup-read.env`, mode 600:
```
BACKUP_R2_ENDPOINT=<the bucket's S3 API endpoint>
BACKUP_R2_ACCESS_KEY_ID=<rawwers-backup-mac Access Key ID>
BACKUP_R2_SECRET_ACCESS_KEY=<rawwers-backup-mac Secret Access Key>
BACKUP_R2_BUCKET=rawwers-backups-test
```

## The monthly drill (Mac, about 10 minutes)

From the repository:
```
deploy/scripts/restore-from-offsite.sh --list --credentials ~/Documents/rawwers-keys/backup-read.env | head
deploy/scripts/restore-from-offsite.sh --credentials ~/Documents/rawwers-keys/backup-read.env \
  --key ~/Documents/rawwers-keys/rawwers-backup-key.txt \
  --keep-encrypted ~/Documents/rawwers-offline-backups/$(date +%Y-%m)
```
**You should see:** `ok` lines (downloaded, decrypted, secrets file: 8
names, restored, migration, rows) and last `PASS: ...`. Paste back the
output: it holds no secret and no personal data (counts only).
**If FAIL:** paste the output; nothing on the server is touched by it.

`--keep-encrypted` keeps that month's encrypted files on the Mac (still
encrypted): the copy that survives losing the Cloudflare account. Copy the
folder to an external disk now and then; keep the last 3 months.

---

> ### AFTER ANY RESTORE, NO PAYOUT IS APPROVED
> until every payout and every transfer since the backup's time has been
> compared with **Stripe's transfer list** (Stripe > Connect > Transfers,
> from the backup's time). See "Payouts after a restore", below.

## Scenario: the server is lost (deleted, broken, or taken over)

> **AFTER ANY RESTORE, NO PAYOUT IS APPROVED** until every payout and
> transfer since the backup time has been compared with Stripe's transfer
> list.

About **3 hours**, most of it the runbook.

1. If it was taken over: **first** rotate every secret (DEPLOY_SECRETS.md,
   "If a secret leaked") and the backup token; delete the old server.
2. A new server: DEPLOY_RUNBOOK steps 0 to 10 (the secrets file: the
   irreplaceable ones come from the backup's `.secrets.age`, step 4 below).
3. On the Mac, the newest backup: `restore-from-offsite.sh ... --keep-encrypted <folder>`
   must say PASS (a drill on the very file you will restore).
4. On the Mac, the irreplaceable secrets, into the new server's secrets file
   (never through chat):
   `~/Developer/RAWWERS-work/bin/age -d -i <key file> <folder>/rawwers-<time>.secrets.age`
   shows 8 `NAME=value` lines; copy each value into the same line of
   `/opt/rawwers/.env.production` on the new server (nano). Then close the
   Terminal window.
5. Restore it: on the Mac, decrypt and send it straight into the new
   server's database (the private key never goes to the server):
   ```
   ~/Developer/RAWWERS-work/bin/age -d -i <key file> <folder>/rawwers-<time>.dump.age \
     | ssh root@<NEW_SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T postgres sh -c "pg_restore -U \"\$POSTGRES_USER\" -d \"\$POSTGRES_DB\" --no-owner --exit-on-error"'
   ```
   (The database must exist and be empty: DEPLOY_RUNBOOK step 10 makes it;
   skip step 11's migrations and step 12's reference data, the dump has both.)
6. DEPLOY_RUNBOOK steps 13 to 22, with the **payouts paused** (below).
7. "After a restore", below.

## Scenario: a bad migration

About **20 minutes**. Before every migration there is a `predeploy`
backup (DEPLOY_RUNBOOK step 21b), and its plain dump stays on the server.

1. Stop the app: `deploy/scripts/dc stop api worker worker-photos beat web`.
2. Restore the plain dump on the server (DEPLOY_RUNBOOK step 21, "Restore a
   backup for real") from `/var/backups/rawwers/rawwers-<time>.dump` of the
   predeploy run. If it is gone, the off-server one: as step 5 of "the server
   is lost", to the same server.
3. Set `IMAGE_TAG` back to the previous commit (DEPLOY_RUNBOOK, "Rollback"),
   `deploy/scripts/dc up -d`, `version.sh`.
4. "After a restore", below.

## Scenario: data deleted by mistake

> **AFTER ANY RESTORE, NO PAYOUT IS APPROVED** until every payout and
> transfer since the backup time has been compared with Stripe's transfer
> list.

Usually **restore beside, not over**: take what was lost from a copy and put
it back, and keep everything since. About **1 hour** with the developer.

1. On the Mac: the newest backup from before the mistake
   (`--list`, then `--name <time>`), restored and PASS.
2. With the developer: the throwaway restore stays up only for the run of the
   script; for a longer look, restore the same file into a scratch database
   on the server (`restore-test.sh` does that, then drops it) and copy the
   lost rows across with SQL written for that case.
3. Only if too much is lost: restore over the live database, as "a bad
   migration", accepting the loss of everything since the backup, then
   "After a restore".

## Scenario: the secrets are lost

| Lost | Do |
|---|---|
| The secrets file on the server, server fine | The 8 irreplaceable ones from the newest backup's `.secrets.age` (step 4 of "the server is lost"); every other one made again (DEPLOY_SECRETS.md, "Made on the server" and "Copied from a service") |
| The age private key, everything else fine | Old backups can never be read again. Make a new pair (set-up step 5), put the new public key in `backup.env`, run a predeploy backup and a drill. Keep the old key's loss in mind: the next 35 days of `daily/` are the only readable ones, then all are |
| `ADDRESS_ENCRYPTION_KEYS` and every backup of it | Stored shipping addresses cannot be read again. Nothing brings them back |

## Scenario: the R2 bucket or the Cloudflare account is compromised

| What | Effect | Do |
|---|---|---|
| The server's backup token leaked | It can read the encrypted files (useless without the key) and add files; it **cannot** delete or change any locked backup | Delete the token (R2 > Manage API tokens), make a new one, put it in `backup.env`, `--check-bucket` |
| The Mac's read-only token leaked | It can read the encrypted files | Delete it, make a new one |
| The Cloudflare account itself (someone signed in as you) | They can remove the locks and delete the bucket, and change DNS | Recover the account with Cloudflare support; meanwhile the copies kept by `--keep-encrypted` on the Mac and the external disk are the backups. A new bucket (maybe at another provider) and a new server token; the private key is unaffected |

---

## After a restore (every scenario)

### Payouts after a restore

**No payout is approved** until every payout and every transfer since the
backup's time has been compared with Stripe's transfer list. Why, from the
code (`api/app/api/v1/webhooks.py`, `transfer.created`;
`api/app/services/payout_transfers.py`), read 2026-11-26:

| A transfer Stripe made after the backup | What the restored database does |
|---|---|
| Its payout was **requested after** the backup (the payout row is gone) | A resent `transfer.created` names a payout that does not exist: the handler returns and **records nothing, raises nothing** (no Money attention item). The photographer's money reads as available again: a new payout request would **pay twice** |
| Its payout existed, but the per-payment transfer row is gone | The handler does not mark anything paid (the row id is unknown); it only records a `transfer_created` event on the payout. If an admin sends the payout again, new transfer rows are made and sent with the same Stripe idempotency key as the first time: Stripe returns the first transfer within its idempotency window (about 24 hours, per Stripe; not checked again here), and **sends a second one after it** |
| An old-style payout (no per-payment transfers) | The handler marks the payout paid: correct |

This is BETA_SCOPE #101 (a LATER finding; not changed). Until it is fixed,
the comparison is by hand:
1. Stripe > **Connect** > **Transfers**, filtered from the backup's time:
   each transfer has `payout_request_id` and `payout_transfer_id` in its
   metadata.
2. For each one, find that payout in the admin. Missing, or not paid: write
   it down. **Do not approve or retry** that photographer's payouts until the
   developer has recorded those transfers.

### Payments, refunds and disputes

Stripe can resend events up to **15 days** old from the dashboard (its
pages say up to 30 days with the Stripe CLI; they disagree, so plan on 15)
([Stripe: how events work](https://docs.stripe.com/events/how-events-work)).

| After the backup | Rebuilt? | How |
|---|---|---|
| A payment for a booking that exists in the backup | Yes | `stripe-reconcile` (every 15 minutes, looks back `STRIPE_RECONCILE_LOOKBACK_HOURS`, 72) records it. For a gap over 72 hours, set it higher for a day |
| A payment for a booking made after the backup | No: flagged | Money attention "Paid in Stripe, unknown to us". Refund it, or rebuild the booking by hand |
| Refunds and disputes on payments we know | Yes | Resend the events (Stripe > Developers > Events, from the backup's time), and the refund sweep |
| Photographers' connected accounts | Yes | Resend `account.updated` |
| Sign-ups, bookings, messages, reviews, delivery records, consents, Shelf orders, admin changes | **No** | Lost for the gap. Delivered files stay in R2 with no record |

### Carry out deletions again

The privacy promise (PRIVACY_NOTICE_INPUTS.md): a deletion made after the
backup is not in it, so it is carried out again, from a record kept
**outside** the database:
- Today account deletion is not built (BETA_SCOPE #9): a deletion is a
  request to support, so the **support mailbox** is the record. Go through
  the requests since the backup's time and do each again.
- When #9 is built it must leave such a record outside the database
  (BETA_SCOPE #102).

### Then

- `version.sh`, `smoke.py` (DEPLOY_RUNBOOK step 14), and a predeploy backup
  of the restored database.
- Tell the people who used the app in the gap, if any data of theirs was lost.

---

## Every 6 hours (when real payments start)

Required before the first real payment (DEPLOY_CHECKLIST, go-live). Worst
case then: 6 hours lost.
1. The bucket: **Bucket lock rules** > add `intraday/`, 3 days; **Object
   lifecycle rules** > add `intraday/`, delete after 3 days.
2. Server: `deploy/scripts/install-backup-timer.sh --intraday on`, then
   `systemctl list-timers 'rawwers-backup*'` shows both timers.
The 03:30 run stays the daily one (and the alarm); the others go to
`intraday/`. Off again: `--intraday off`.
