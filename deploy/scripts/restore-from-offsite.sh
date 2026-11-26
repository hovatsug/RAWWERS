#!/usr/bin/env bash
# restore-from-offsite.sh: on the Mac, prove an off-server backup restores.
#
#   deploy/scripts/restore-from-offsite.sh --list
#   deploy/scripts/restore-from-offsite.sh --key ~/path/to/rawwers-backup-key.txt            # the newest
#   deploy/scripts/restore-from-offsite.sh --key <file> --name 20261126T033000Z [--prefix daily]
#   deploy/scripts/restore-from-offsite.sh --key <file> --keep-encrypted <folder>           # also keep the encrypted files
#   ... --from-dir <folder>      # a folder laid out like the bucket, instead of R2
#
# Downloads a backup (manifest, encrypted dump, encrypted secrets file) from
# the backup bucket, checks each file's sha256 and size against the manifest,
# decrypts with the private age key file given (it never leaves this Mac),
# restores the dump into a throwaway Postgres 16 that it starts on this Mac
# only, and compares the migration and the row count of every table with
# the manifest. It reads only the NAMES in the secrets file, never prints a
# value. Last line PASS (exit 0) or FAIL (exit 1); 2 = usage, settings or
# tools. Everything it made is removed at the end, also on failure or Ctrl-C.
#
# The bucket: BACKUP_R2_ENDPOINT, BACKUP_R2_ACCESS_KEY_ID,
# BACKUP_R2_SECRET_ACCESS_KEY, BACKUP_R2_BUCKET in the environment, or
# --credentials <file> with those lines (a read-only token: RESTORE_PLAYBOOK).
# Needs: Homebrew postgresql@16, age, and the Python of tools/tests/native-db.sh.
set -euo pipefail
usage() { sed -n '2,23p' "$0"; }
WORKROOT="${RAWWERS_WORK:-$HOME/Developer/RAWWERS-work}"
PY="${RESTORE_PYTHON:-$WORKROOT/venv/api-py312/bin/python}"
BREW="${HOMEBREW_PREFIX:-/usr/local}"
[[ -d "$BREW/opt/postgresql@16" ]] || BREW=/opt/homebrew
PG_BIN="${PG_BIN:-$BREW/opt/postgresql@16/bin}"
AGE="${AGE:-$(command -v age 2>/dev/null || echo "$WORKROOT/bin/age")}"

LIST=0 KEY="" NAME="" PREFIX="" FROM_DIR="" CREDS="" KEEP_ENC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) LIST=1; shift ;;
    --key) KEY="${2:-}"; shift 2 ;;
    --name) NAME="${2:-}"; shift 2 ;;
    --prefix) PREFIX="${2:-}"; shift 2 ;;
    --from-dir) FROM_DIR="${2:-}"; shift 2 ;;
    --credentials) CREDS="${2:-}"; shift 2 ;;
    --keep-encrypted) KEEP_ENC="${2:-}"; shift 2 ;;
    *) echo "restore-from-offsite: unknown argument $1" >&2; usage >&2; exit 2 ;;
  esac
done
die() { echo "restore-from-offsite: $*" >&2; exit 2; }
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
sha256_of() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1; else sha256sum "$1" | cut -d' ' -f1; fi; }

[[ $LIST == 1 || -n "$KEY" ]] || die "--key <private age key file> is needed to restore (or --list to see the backups)"
[[ -z "$KEY" || -r "$KEY" ]] || die "cannot read the key file $KEY"
[[ -x "$PY" ]] || die "no Python at $PY: run tools/tests/native-db.sh setup once (or set RESTORE_PYTHON)"
if [[ -n "$FROM_DIR" ]]; then
  [[ -d "$FROM_DIR" ]] || die "no folder $FROM_DIR"
else
  if [[ -n "$CREDS" ]]; then
    [[ -r "$CREDS" ]] || die "cannot read $CREDS"
    for name in BACKUP_R2_ENDPOINT BACKUP_R2_ACCESS_KEY_ID BACKUP_R2_SECRET_ACCESS_KEY BACKUP_R2_BUCKET; do
      value="$(value_of "$name" "$CREDS")"
      [[ -n "$value" ]] && export "$name=$value"
    done
    unset value
  fi
  missing=()
  for name in BACKUP_R2_ENDPOINT BACKUP_R2_ACCESS_KEY_ID BACKUP_R2_SECRET_ACCESS_KEY BACKUP_R2_BUCKET; do
    [[ -n "${!name:-}" ]] || missing+=("$name")
  done
  [[ ${#missing[@]} -eq 0 ]] || die "no bucket settings: ${missing[*]} (in the environment or --credentials <file>), or --from-dir <folder>"
fi

# The bucket (boto3; the keys stay in the environment) or a local folder.
STORE_PY='
import os, shutil, sys
mode = sys.argv[1]
local = os.environ.get("RESTORE_FROM_DIR")
if local:
    if mode == "list":
        for root, _, files in os.walk(local):
            for f in files:
                if f.endswith(".manifest.json"):
                    print(os.path.relpath(os.path.join(root, f), local))
    else:
        shutil.copyfile(os.path.join(local, sys.argv[2]), sys.argv[3])
    sys.exit(0)
import boto3
from botocore.config import Config
s3 = boto3.client("s3", endpoint_url=os.environ["BACKUP_R2_ENDPOINT"], region_name="auto",
                  aws_access_key_id=os.environ["BACKUP_R2_ACCESS_KEY_ID"],
                  aws_secret_access_key=os.environ["BACKUP_R2_SECRET_ACCESS_KEY"],
                  config=Config(retries={"max_attempts": 5}))
bucket = os.environ["BACKUP_R2_BUCKET"]
if mode == "list":
    for page in s3.get_paginator("list_objects_v2").paginate(Bucket=bucket):
        for item in page.get("Contents", []):
            if item["Key"].endswith(".manifest.json"):
                print(item["Key"])
else:
    s3.download_file(bucket, sys.argv[2], sys.argv[3])
'
store() { RESTORE_FROM_DIR="$FROM_DIR" "$PY" -c "$STORE_PY" "$@"; }

# Every backup, newest first: "<prefix>/<year>/<month>/rawwers-<stamp>".
backups() {
  store list | sed 's/\.manifest\.json$//' | awk -F'rawwers-' '{print $NF "\t" $0}' | sort -r -k1,1 -s | cut -f2
}
if [[ $LIST == 1 ]]; then
  all="$(backups)" || { echo "restore-from-offsite: cannot list the bucket" >&2; exit 2; }
  [[ -n "$all" ]] || { echo "No backups found."; exit 0; }
  echo "$all"
  exit 0
fi

command -v "$AGE" >/dev/null 2>&1 || [[ -x "$AGE" ]] || die "age is missing (docs/RESTORE_PLAYBOOK.md, 'On the Mac, once')"
for tool in initdb pg_ctl createdb pg_restore psql; do [[ -x "$PG_BIN/$tool" ]] || die "missing $PG_BIN/$tool (brew install postgresql@16)"; done

chosen="$(backups | { if [[ -n "$PREFIX" ]]; then grep "^$PREFIX/" || true; else cat; fi; } \
  | { if [[ -n "$NAME" ]]; then grep "rawwers-$NAME\$" || true; else cat; fi; } | head -n 1)" \
  || die "cannot list the bucket"
[[ -n "$chosen" ]] || die "no backup found${NAME:+ named $NAME}${PREFIX:+ in $PREFIX/}"
base="${chosen##*/}"
started=$(date +%s)
echo "Backup:  $chosen"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/rawwers-restore.XXXXXX")"
chmod 700 "$WORK"
PGDATA="$WORK/pg" pg_started=0
cleanup() {
  local code=$?
  if [[ $pg_started == 1 ]]; then
    "$PG_BIN/pg_ctl" -D "$PGDATA" -m fast -w stop >/dev/null 2>&1 || "$PG_BIN/pg_ctl" -D "$PGDATA" -m immediate stop >/dev/null 2>&1 || true
  fi
  rm -rf "$WORK"
  exit "$code"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
fail() { echo "FAIL: $*"; exit 1; }

for ext in manifest.json dump.age secrets.age; do
  store get "$chosen.$ext" "$WORK/$base.$ext" || fail "cannot download $chosen.$ext"
done
manifest="$WORK/$base.manifest.json"
field() {
  "$PY" -c 'import json, sys
d = json.load(open(sys.argv[1]))
for key in sys.argv[2:]:
    d = d[key]
print(",".join(d) if isinstance(d, list) else d)' "$manifest" "$@"
}
for part in dump secrets; do
  file="$WORK/$base.$part.age"
  [[ "$(sha256_of "$file")" == "$(field "$part" sha256)" ]] || fail "$base.$part.age: sha256 differs from the manifest (damaged or changed)"
  [[ "$(wc -c < "$file" | tr -d ' ')" == "$(field "$part" bytes)" ]] || fail "$base.$part.age: size differs from the manifest"
done
echo "ok    downloaded; sha256 and size of both files match the manifest"
if [[ -n "$KEEP_ENC" ]]; then
  (umask 077; mkdir -p "$KEEP_ENC")
  cp "$WORK/$base.manifest.json" "$WORK/$base.dump.age" "$WORK/$base.secrets.age" "$KEEP_ENC/"
  echo "ok    encrypted copy kept in $KEEP_ENC"
fi

"$AGE" -d -i "$KEY" -o "$WORK/dump" "$WORK/$base.dump.age" 2>/dev/null || fail "cannot decrypt the dump: wrong key file?"
[[ "$(sha256_of "$WORK/dump")" == "$(field dump plain_sha256)" ]] || fail "the decrypted dump's sha256 differs from the manifest"
echo "ok    dump decrypted ($(field dump plain_bytes) bytes, sha256 as in the manifest)"
# Names only: each line's value goes no further than cut.
names="$("$AGE" -d -i "$KEY" "$WORK/$base.secrets.age" 2>/dev/null | cut -d= -f1 | paste -sd, -)" \
  || fail "cannot decrypt the secrets file: wrong key file?"
expected="$(field secrets names)"
count=0
[[ -z "$names" ]] || count="$(tr ',' '\n' <<< "$names" | wc -l | tr -d ' ')"
if [[ "$names" == "$expected" ]]; then
  echo "ok    secrets file: $count names ($names)"
else
  fail "the secrets file holds $names, the manifest says $expected"
fi

# A throwaway Postgres, this Mac only, in the work folder.
export LC_ALL="${RESTORE_LOCALE:-en_US.UTF-8}"
port="$("$PY" -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')"
"$PG_BIN/initdb" -D "$PGDATA" -U postgres --auth=trust -E UTF8 --no-locale >/dev/null
pg_started=1
"$PG_BIN/pg_ctl" -D "$PGDATA" -w -l "$WORK/postgres.log" -o "-p $port -h 127.0.0.1 -c unix_socket_directories='' -c fsync=off" start >/dev/null \
  || { tail -n 15 "$WORK/postgres.log"; fail "the throwaway Postgres did not start"; }
export PGHOST=127.0.0.1 PGPORT="$port" PGUSER=postgres
"$PG_BIN/createdb" restored
if ! "$PG_BIN/pg_restore" --no-owner --no-privileges --exit-on-error -d restored "$WORK/dump" 2> "$WORK/restore.log"; then
  tail -n 15 "$WORK/restore.log"
  fail "pg_restore stopped with an error (above)"
fi
echo "ok    restored into a throwaway Postgres $("$PG_BIN/postgres" --version | awk '{print $3}')"

"$PG_BIN/psql" -X -q -At -v ON_ERROR_STOP=1 -d restored > "$WORK/counts" <<'SQL'
SELECT 'alembic_version|' || coalesce((SELECT string_agg(version_num, ',' ORDER BY version_num) FROM alembic_version), '') WHERE to_regclass('public.alembic_version') IS NOT NULL;
SELECT 'table|' || c.relname || '|' || (xpath('/row/n/text()', query_to_xml(format('SELECT count(*) AS n FROM public.%I', c.relname), false, true, '')))[1]::text
  FROM pg_class c JOIN pg_namespace s ON s.oid = c.relnamespace
 WHERE s.nspname = 'public' AND c.relkind IN ('r', 'p') ORDER BY c.relname;
SQL

"$PY" - "$manifest" "$WORK/counts" "$chosen" "$(( $(date +%s) - started ))" <<'PY'
import json, sys
manifest = json.load(open(sys.argv[1]))
alembic, rows = "", {}
for line in open(sys.argv[2]):
    parts = line.rstrip("\n").split("|")
    if parts[0] == "alembic_version":
        alembic = parts[1]
    elif parts[0] == "table" and len(parts) == 3:
        rows[parts[1]] = int(parts[2])
bad = 0
if alembic == manifest["alembic_version"]:
    print(f"ok    migration {alembic}")
else:
    bad += 1
    print(f"DIFF  migration restored {alembic!r}, manifest {manifest['alembic_version']!r}")
expected = manifest["row_counts"]
for name in sorted(set(expected) | set(rows)):
    if rows.get(name) != expected.get(name):
        bad += 1
        print(f"DIFF  rows: {name} restored {rows.get(name, 'missing')}, manifest {expected.get(name, 'missing')}")
if len(rows) == manifest["tables"] and not bad:
    sample = f"user_account {rows['user_account']}, " if "user_account" in rows else ""
    print(f"ok    rows: {sample}every one of the {len(rows)} tables as in the manifest")
elif len(rows) != manifest["tables"]:
    bad += 1
    print(f"DIFF  tables restored {len(rows)}, manifest {manifest['tables']}")
print()
if bad:
    print(f"FAIL: {sys.argv[3]} restores, but {bad} difference(s) from its manifest (above)")
    sys.exit(1)
print(f"PASS: {sys.argv[3]} restores on this Mac and matches its manifest "
      f"({len(rows)} tables, migration {alembic}; {sys.argv[4]} s)")
PY
