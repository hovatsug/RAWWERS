#!/usr/bin/env bash
# backup-offsite.sh: a database backup, encrypted, copied OFF the server to R2.
#
#   deploy/scripts/backup-offsite.sh --label daily       # the nightly run (the timer)
#   deploy/scripts/backup-offsite.sh --label predeploy   # before every deploy or migration
#   deploy/scripts/backup-offsite.sh --label intraday    # the 6-hourly runs, once switched on
#   deploy/scripts/backup-offsite.sh --label daily --dry-run   # everything but the upload
#   deploy/scripts/backup-offsite.sh --check-bucket      # can the server reach the bucket?
#   deploy/scripts/backup-offsite.sh --lock-test         # does the bucket refuse a delete? (locktest/)
#
# Steps: a dump with its row counts (backup-now.sh); a manifest; the dump and
# a small file of the secrets that cannot be made again, each encrypted with
# age to the PUBLIC key in the config (the private key never comes here);
# upload to <label>/<year>/<month>/ in the backup bucket; download each file
# again and check its sha256 and size; then keep only the newest 2 plain
# dumps on the server. The first daily of a month also goes to monthly/.
# A daily run tells Sentry it started and how it ended (a Cron monitor, made
# by the first check-in): a missed or failed night alerts the owner.
#
# Settings: /opt/rawwers/backup.env (mode 600; BACKUP_CONFIG elsewhere), read
# by name, never printed. Secrets kept: from /opt/rawwers/.env.production by
# name. docs/RESTORE_PLAYBOOK.md has the set-up and every restore.
#
# Exit: 0 done (or dry run done); 2 usage, settings or tools; 3 another run
# is going; 4 dump failed; 5 encryption failed; 6 upload or bucket failed;
# 7 what arrived in the bucket is not what was sent; 8 the lock test found
# no lock.
set -euo pipefail
usage() { sed -n '2,28p' "$0"; }
HERE="$(cd "$(dirname "$0")" && pwd)"
DC="${RAWWERS_DC:-$HERE/dc}"
BACKUP_NOW="${BACKUP_NOW:-$HERE/backup-now.sh}"
CONFIG="${BACKUP_CONFIG:-/opt/rawwers/backup.env}"
ENV_FILE="${RAWWERS_ENV_FILE:-/opt/rawwers/.env.production}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/rawwers}"
LOCK="${BACKUP_LOCK_DIR:-/run/rawwers-backup.lock}"
KEEP_LOCAL="${KEEP_LOCAL:-2}"
RCLONE="${RCLONE:-rclone}"
AGE="${AGE:-age}"
CURL="${CURL:-curl}"
#: The secrets that cannot be made again at a service (DEPLOY_SECRETS.md).
IRREPLACEABLE=(ADDRESS_ENCRYPTION_KEYS UNSUBSCRIBE_SIGNING_KEYS MEDIA_SHARE_TOKEN_PEPPER MEDIA_ACCESS_IP_HASH_PEPPER
  SHARE_VIEW_FINGERPRINT_PEPPER RISK_IP_HASH_PEPPER RISK_DEVICE_HASH_PEPPER RISK_SESSION_HASH_PEPPER)
#: The Sentry monitor, made or updated by the daily run's first check-in.
SENTRY_SCHEDULE="30 3 * * *"
SENTRY_MARGIN_MINUTES=120
SENTRY_MAX_RUNTIME_MINUTES=30

LABEL="" DRY_RUN=0 CHECK_BUCKET=0 LOCK_TEST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --label) LABEL="${2:-}"; shift 2 || { usage >&2; exit 2; } ;;
    --dry-run) DRY_RUN=1; shift ;;
    --check-bucket) CHECK_BUCKET=1; shift ;;
    --lock-test) LOCK_TEST=1; shift ;;
    *) echo "backup-offsite: unknown argument $1" >&2; usage >&2; exit 2 ;;
  esac
done
if [[ $CHECK_BUCKET == 0 && $LOCK_TEST == 0 ]]; then
  case "$LABEL" in
    daily|intraday|predeploy) ;;
    *) echo "backup-offsite: --label must be daily, intraday or predeploy" >&2; exit 2 ;;
  esac
fi

die() { local code="$1"; shift; echo "backup-offsite: $*" >&2; exit "$code"; }
warn() { echo "backup-offsite: $*" >&2; }
# The value of NAME in FILE (the last NAME= line, quotes removed). Only the
# name is ever on a command line; the value stays inside this process.
value_of() {
  local line
  line="$(grep -E "^$1=" "$2" 2>/dev/null | tail -n 1 || true)"
  line="${line#*=}"
  line="${line%$'\r'}"
  if [[ ${#line} -ge 2 && ( ( $line == \"*\" && $line == *\" ) || ( $line == \'*\' && $line == *\' ) ) ]]; then
    line="${line:1:${#line}-2}"
  fi
  printf '%s' "$line"
}
file_mode() { stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1"; }
sha256_of() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }
size_of() { wc -c < "$1" | tr -d ' '; }

# ---- settings ---------------------------------------------------------------
[[ -f "$CONFIG" ]] || die 2 "no settings file $CONFIG (make it as docs/RESTORE_PLAYBOOK.md, 'Set-up', says)"
mode="$(file_mode "$CONFIG")"
[[ "$mode" == 600 || "$mode" == 400 ]] || die 2 "$CONFIG must be readable by its owner only: chmod 600 $CONFIG (it is $mode)"
missing=()
for name in BACKUP_R2_ENDPOINT BACKUP_R2_ACCESS_KEY_ID BACKUP_R2_SECRET_ACCESS_KEY BACKUP_R2_BUCKET BACKUP_AGE_RECIPIENT; do
  [[ -n "$(value_of "$name" "$CONFIG")" ]] || missing+=("$name")
done
[[ ${#missing[@]} -eq 0 ]] || die 2 "missing in $CONFIG: ${missing[*]}"
BUCKET="$(value_of BACKUP_R2_BUCKET "$CONFIG")"
RECIPIENT="$(value_of BACKUP_AGE_RECIPIENT "$CONFIG")"
[[ "$RECIPIENT" =~ ^age1[0-9a-z]{50,}$ ]] || die 2 "BACKUP_AGE_RECIPIENT is not an age public key (it starts with age1). Never put the private key on the server."
PROVIDER="$(value_of BACKUP_RCLONE_PROVIDER "$CONFIG")"
PROVIDER="${PROVIDER:-Cloudflare}"
[[ "$PROVIDER" == Cloudflare || "$PROVIDER" == Other ]] || die 2 "BACKUP_RCLONE_PROVIDER must be Cloudflare or Other"
MONITOR="$(value_of BACKUP_SENTRY_MONITOR "$CONFIG")"
command -v "$RCLONE" >/dev/null 2>&1 || die 2 "rclone is missing: apt-get install -y rclone"

# rclone gets the bucket through its environment, in a subshell: the keys are
# never on a command line and never in a file.
rc() {
  (
    export RCLONE_CONFIG_RAWWERSBK_TYPE=s3
    export RCLONE_CONFIG_RAWWERSBK_PROVIDER="$PROVIDER"
    RCLONE_CONFIG_RAWWERSBK_ENDPOINT="$(value_of BACKUP_R2_ENDPOINT "$CONFIG")"; export RCLONE_CONFIG_RAWWERSBK_ENDPOINT
    RCLONE_CONFIG_RAWWERSBK_ACCESS_KEY_ID="$(value_of BACKUP_R2_ACCESS_KEY_ID "$CONFIG")"; export RCLONE_CONFIG_RAWWERSBK_ACCESS_KEY_ID
    RCLONE_CONFIG_RAWWERSBK_SECRET_ACCESS_KEY="$(value_of BACKUP_R2_SECRET_ACCESS_KEY "$CONFIG")"; export RCLONE_CONFIG_RAWWERSBK_SECRET_ACCESS_KEY
    export RCLONE_CONFIG_RAWWERSBK_REGION=auto
    export RCLONE_CONFIG_RAWWERSBK_ACL=private
    export RCLONE_CONFIG_RAWWERSBK_NO_CHECK_BUCKET=true
    exec "$RCLONE" --log-level=ERROR "$@"
  )
}

if [[ $CHECK_BUCKET == 1 ]]; then
  echo "rclone:   $("$RCLONE" version 2>/dev/null | head -n 1)"
  echo "provider: $PROVIDER"
  echo "bucket:   $BUCKET"
  if listing="$(rc lsf "rawwersbk:$BUCKET" --max-depth=1)"; then
    echo "OK: bucket reachable ($(printf '%s' "$listing" | grep -c . || true) entries at the top) with provider $PROVIDER"
    exit 0
  fi
  warn "cannot list the bucket with provider $PROVIDER. Check the endpoint, key and bucket name in $CONFIG; then try BACKUP_RCLONE_PROVIDER=$([[ $PROVIDER == Cloudflare ]] && echo Other || echo Cloudflare) in it."
  exit 6
fi

if [[ $LOCK_TEST == 1 ]]; then
  stamp="${BACKUP_STAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
  key="locktest/lock-test-$stamp.txt"
  probe="$(mktemp)"
  trap 'rm -f "$probe"' EXIT
  echo "RAWWERS lock test $stamp: this file should not be deletable for a day." > "$probe"
  rc copyto "$probe" "rawwersbk:$BUCKET/$key" || die 6 "cannot upload $key"
  if rc deletefile "rawwersbk:$BUCKET/$key" 2> "$probe.err"; then
    rm -f "$probe.err"
    die 8 "PROBLEM: the bucket deleted $key. locktest/ has no lock rule, so check every lock rule (docs/RESTORE_PLAYBOOK.md, set-up step 3)"
  fi
  reason="$(grep -o 'ObjectLockedByBucketPolicy\|409\|[Ll]ocked[^ ]*' "$probe.err" | head -n 1 || true)"
  rm -f "$probe.err"
  echo "OK: the bucket refused to delete $key${reason:+ ($reason)}: the server's token cannot remove locked backups."
  exit 0
fi

command -v "$AGE" >/dev/null 2>&1 || die 2 "age is missing: apt-get install -y age"
command -v python3 >/dev/null 2>&1 || die 2 "python3 is missing"
[[ -r "$ENV_FILE" ]] || die 2 "cannot read the secrets file $ENV_FILE (run as root)"
stamp="${BACKUP_STAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
[[ "$stamp" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || die 2 "BACKUP_STAMP must look like 20261126T033000Z"
year="${stamp:0:4}" month="${stamp:4:2}" day="${stamp:6:2}"
base="rawwers-$stamp"
prefixes=("$LABEL/$year/$month")
[[ "$LABEL" == daily && "$day" == 01 ]] && prefixes+=("monthly/$year/$month")

# ---- one run at a time ------------------------------------------------------
if mkdir "$LOCK" 2>/dev/null; then
  echo $$ > "$LOCK/pid"
else
  holder="$(cat "$LOCK/pid" 2>/dev/null || true)"
  if [[ -n "$holder" ]] && kill -0 "$holder" 2>/dev/null; then
    die 3 "another backup is already running (pid $holder); try again when it ends"
  fi
  warn "taking over a lock left by a run that is gone (pid ${holder:-unknown})"
  echo $$ > "$LOCK/pid"
fi

# ---- the alarm (daily runs only) ---------------------------------------------
SENTRY_URL="" CHECK_IN_ID="" SENTRY_STARTED=0
if [[ "$LABEL" == daily && $DRY_RUN == 0 ]]; then
  dsn="$(value_of SENTRY_DSN "$ENV_FILE")"
  if [[ -z "$MONITOR" ]]; then
    warn "no alarm: BACKUP_SENTRY_MONITOR is not set in $CONFIG, so nobody hears of a missed backup"
  elif [[ ! "$dsn" =~ ^https://([^@/]+)@([^/]+)/([0-9]+)$ ]]; then
    warn "no alarm: SENTRY_DSN in $ENV_FILE is missing or not a Sentry DSN"
  else
    SENTRY_URL="https://${BASH_REMATCH[2]}/api/${BASH_REMATCH[3]}/cron/$MONITOR/${BASH_REMATCH[1]}/"
    CHECK_IN_ID="$(python3 -c 'import uuid; print(uuid.uuid4())')"
  fi
fi
checkin() {
  # $1: in_progress, ok or error. A failed check-in never fails the backup.
  [[ -n "$SENTRY_URL" ]] || return 0
  if [[ "$1" == in_progress ]]; then
    local body
    body="$(printf '{"status": "in_progress", "monitor_config": {"schedule": {"type": "crontab", "value": "%s"}, "checkin_margin": %d, "max_runtime": %d, "timezone": "UTC", "failure_issue_threshold": 1, "recovery_threshold": 1}}' \
      "$SENTRY_SCHEDULE" "$SENTRY_MARGIN_MINUTES" "$SENTRY_MAX_RUNTIME_MINUTES")"
    "$CURL" -fsS -m 10 -X POST -H 'Content-Type: application/json' --data-raw "$body" "${SENTRY_URL}?check_in_id=$CHECK_IN_ID" >/dev/null \
      || warn "the Sentry check-in (start) failed; the backup goes on"
  else
    "$CURL" -fsS -m 10 "${SENTRY_URL}?check_in_id=$CHECK_IN_ID&status=$1" >/dev/null \
      || warn "the Sentry check-in ($1) failed"
  fi
}

DUMP_DIR="$BACKUP_DIR"
[[ $DRY_RUN == 1 ]] && DUMP_DIR="$BACKUP_DIR/dry-run-$stamp"
WORK="$BACKUP_DIR/.upload-$stamp"
finish() {
  local code=$?
  rm -rf "$WORK"
  [[ $DRY_RUN == 1 ]] && rm -rf "$DUMP_DIR"
  if [[ $SENTRY_STARTED == 1 ]]; then
    if [[ $code == 0 ]]; then checkin ok; else checkin error; fi
  fi
  [[ "$(cat "$LOCK/pid" 2>/dev/null || true)" == "$$" ]] && rm -rf "$LOCK"
  exit "$code"
}
trap finish EXIT
checkin in_progress
[[ -n "$SENTRY_URL" ]] && SENTRY_STARTED=1

# ---- 1. the dump and its counts ----------------------------------------------
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
dump="$(BACKUP_DIR="$DUMP_DIR" KEEP=0 BACKUP_STAMP="$stamp" RAWWERS_DC="$DC" bash "$BACKUP_NOW" --path-only)" \
  || die 4 "the dump failed (see above)"
[[ -f "$dump" && -f "$dump.counts" ]] || die 4 "backup-now.sh did not leave $dump and its counts"
(umask 077; mkdir -p "$WORK")

# ---- 2. the secrets that cannot be made again, straight into age --------------
kept=() absent=()
for name in "${IRREPLACEABLE[@]}"; do
  if [[ -n "$(value_of "$name" "$ENV_FILE")" ]]; then kept+=("$name"); else absent+=("$name"); fi
done
[[ ${#absent[@]} -eq 0 ]] || warn "not in $ENV_FILE, so not in this backup: ${absent[*]}"
for name in "${kept[@]+"${kept[@]}"}"; do
  printf '%s=%s\n' "$name" "$(value_of "$name" "$ENV_FILE")"
done | "$AGE" -r "$RECIPIENT" -o "$WORK/$base.secrets.age" || die 5 "encrypting the secrets file failed"

# ---- 3. the dump, encrypted -------------------------------------------------
"$AGE" -r "$RECIPIENT" -o "$WORK/$base.dump.age" "$dump" || die 5 "encrypting the dump failed"
chmod 600 "$WORK"/*

# ---- 4. the manifest (no secret in it: names, sizes, checksums, counts) -------
commit="$(git -C "$HERE/../.." rev-parse HEAD 2>/dev/null || echo unknown)"
python3 - "$LABEL" "$stamp" "$commit" "$(value_of IMAGE_TAG "$ENV_FILE")" "$dump" "$WORK/$base.dump.age" \
  "$WORK/$base.secrets.age" "$(IFS=,; echo "${kept[*]+"${kept[*]}"}")" "$(IFS=,; echo "${absent[*]+"${absent[*]}"}")" \
  > "$WORK/$base.manifest.json" <<'PY' || die 5 "writing the manifest failed"
import hashlib, json, os, sys
label, stamp, commit, image_tag, dump, dump_age, secrets_age, kept, absent = sys.argv[1:10]
def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()
alembic, rows = "", {}
with open(dump + ".counts") as f:
    for line in f:
        parts = line.rstrip("\n").split("|")
        if parts[0] == "alembic_version":
            alembic = parts[1]
        elif parts[0] == "table" and len(parts) == 3:
            rows[parts[1]] = int(parts[2])
name = os.path.basename(dump_age)[: -len(".dump.age")]
json.dump({
    "format": 1,
    "label": label,
    "stamp": stamp,
    "created_utc": f"{stamp[0:4]}-{stamp[4:6]}-{stamp[6:8]}T{stamp[9:11]}:{stamp[11:13]}:{stamp[13:15]}Z",
    "checkout_commit": commit,
    "image_tag": image_tag,
    "alembic_version": alembic,
    "dump": {"file": f"{name}.dump.age", "bytes": os.path.getsize(dump_age), "sha256": sha(dump_age),
             "plain_bytes": os.path.getsize(dump), "plain_sha256": sha(dump)},
    "secrets": {"file": f"{name}.secrets.age", "bytes": os.path.getsize(secrets_age), "sha256": sha(secrets_age),
                "names": [n for n in kept.split(",") if n], "missing": [n for n in absent.split(",") if n]},
    "tables": len(rows),
    "row_counts": rows,
}, sys.stdout, indent=1, sort_keys=True)
print()
PY

files=("$base.dump.age" "$base.secrets.age" "$base.manifest.json")  # the manifest last: it marks a complete set
if [[ $DRY_RUN == 1 ]]; then
  echo "DRY RUN: nothing uploaded. It would upload to $BUCKET:"
  for prefix in "${prefixes[@]}"; do
    for f in "${files[@]}"; do echo "  $prefix/$f ($(size_of "$WORK/$f") bytes)"; done
  done
  exit 0
fi

# ---- 5. upload, then 6. download again and compare -----------------------------
for prefix in "${prefixes[@]}"; do
  for f in "${files[@]}"; do
    rc copyto "$WORK/$f" "rawwersbk:$BUCKET/$prefix/$f" || die 6 "upload of $prefix/$f failed"
  done
done
for prefix in "${prefixes[@]}"; do
  for f in "${files[@]}"; do
    rm -f "$WORK/check"
    rc cat "rawwersbk:$BUCKET/$prefix/$f" > "$WORK/check" || die 7 "verify: cannot read back $prefix/$f"
    if [[ "$(sha256_of "$WORK/check")" != "$(sha256_of "$WORK/$f")" || "$(size_of "$WORK/check")" != "$(size_of "$WORK/$f")" ]]; then
      die 7 "verify failed: $prefix/$f in the bucket is not what was sent (sha256 or size differ)"
    fi
  done
done

# ---- 7. on the server: only the newest plain dumps stay ---------------------------
ls -1 "$BACKUP_DIR"/rawwers-*.dump 2>/dev/null | sort -r | tail -n +"$((KEEP_LOCAL + 1))" | while read -r old; do
  rm -f "$old" "$old.counts"
done

for prefix in "${prefixes[@]}"; do
  echo "OK: $prefix/$base: uploaded and verified ($(size_of "$WORK/$base.dump.age") bytes encrypted, $(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["tables"])' "$WORK/$base.manifest.json") tables)"
done
