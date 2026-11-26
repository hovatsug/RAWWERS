#!/usr/bin/env bash
# backup-now.sh: a database backup, now, written to a folder on the server.
#
#   deploy/scripts/backup-now.sh                 # writes /var/backups/rawwers/rawwers-<time>.dump
#   BACKUP_DIR=/somewhere/else deploy/scripts/backup-now.sh
#   deploy/scripts/backup-now.sh --path-only     # prints only the new file's path (backup-offsite.sh uses it)
#
# The file is a compressed pg_dump (custom format). Next to it,
# <file>.counts holds the row count of every table, taken in the same
# database snapshot as the dump, so a restore can be compared with the
# database as it was at that moment (restore-from-offsite.sh does).
# Both are written to a plain folder on the server, NOT inside a Docker
# volume: removing or recreating the containers or volumes does not touch
# them. They ARE lost if the whole server is rebuilt or deleted: the
# off-server copy is backup-offsite.sh (docs/RESTORE_PLAYBOOK.md).
#
# Keeps the newest KEEP files (default 14; 0 keeps every one).
# Restore test (safe, never touches the live database): deploy/scripts/restore-test.sh <file>
# Real restore (replaces the live data): docs/RESTORE_PLAYBOOK.md.
set -euo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,19p' "$0"; exit 0; fi
PATH_ONLY=0
if [[ "${1:-}" == "--path-only" ]]; then PATH_ONLY=1; shift; fi
[[ $# -eq 0 ]] || { echo "backup-now: unknown argument $1 (see --help)" >&2; exit 2; }
HERE="$(cd "$(dirname "$0")" && pwd)"
DC="${RAWWERS_DC:-$HERE/dc}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/rawwers}"
KEEP="${KEEP:-14}"
[[ "$KEEP" =~ ^[0-9]+$ ]] || { echo "backup-now: KEEP must be a number (0 keeps every file)" >&2; exit 2; }

# With --path-only every message goes to stderr, so stdout is the path alone.
say() { if [[ $PATH_ONLY == 1 ]]; then echo "$@" >&2; else echo "$@"; fi; }

resolved="$(realpath -m "$BACKUP_DIR" 2>/dev/null || python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$BACKUP_DIR")"
case "$resolved" in
  /var/lib/docker|/var/lib/docker/*|/private/var/lib/docker|/private/var/lib/docker/*)
    echo "backup-now: refuse to write inside /var/lib/docker ($BACKUP_DIR): that is where Docker keeps volumes, and removing them would remove the backups too. Use a plain folder such as /var/backups/rawwers." >&2
    exit 2 ;;
esac

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
stamp="${BACKUP_STAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
[[ "$stamp" =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || { echo "backup-now: BACKUP_STAMP must look like 20261126T033000Z" >&2; exit 2; }
file="$BACKUP_DIR/rawwers-$stamp.dump"
partial="$file.partial"
counts_partial="$file.counts.partial"
trap 'rm -f "$counts_partial"' EXIT

# Runs inside the postgres container ($1 = the stamp). One read-only
# transaction exports its snapshot; pg_dump dumps exactly that snapshot while
# the same transaction counts every table. The dump goes to stdout; the
# counts to a file inside the container, fetched just after.
SNAPSHOT_DUMP="$(cat <<'EOS'
set -eu
counts="${TMPDIR:-/tmp}/rawwers-counts-$1"
rm -f "$counts"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -X -q -At -v ON_ERROR_STOP=1 -v counts="$counts" <<'SQL'
BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY;
SELECT pg_export_snapshot() AS snap \gset
\setenv RAWWERS_SNAPSHOT :snap
\o :counts
SELECT 'alembic_version|' || coalesce((SELECT string_agg(version_num, ',' ORDER BY version_num) FROM alembic_version), '') WHERE to_regclass('public.alembic_version') IS NOT NULL;
SELECT 'table|' || c.relname || '|' || (xpath('/row/n/text()', query_to_xml(format('SELECT count(*) AS n FROM public.%I', c.relname), false, true, '')))[1]::text
  FROM pg_class c JOIN pg_namespace s ON s.oid = c.relnamespace
 WHERE s.nspname = 'public' AND c.relkind IN ('r', 'p') ORDER BY c.relname;
\o
\! pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --snapshot="$RAWWERS_SNAPSHOT" --format=custom --compress=6 --no-owner
COMMIT;
SQL
EOS
)"
FETCH_COUNTS='c="${TMPDIR:-/tmp}/rawwers-counts-$1"; cat "$c"; rm -f "$c"'

say "Backing up the database to $file ..."
if ! "$DC" exec -T postgres sh -c "$SNAPSHOT_DUMP" sh "$stamp" > "$partial"; then
  echo "backup-now: the dump failed. Kept as $partial for a look." >&2
  exit 1
fi
"$DC" exec -T postgres sh -c "$FETCH_COUNTS" sh "$stamp" > "$counts_partial"
size=$(stat -c %s "$partial" 2>/dev/null || stat -f %z "$partial")
if [[ "$size" -lt 1024 ]]; then
  echo "backup-now: the dump is only $size bytes; something is wrong. Kept as $partial for a look." >&2
  exit 1
fi
if ! grep -q '^table|' "$counts_partial"; then
  echo "backup-now: no row counts came back. Kept as $partial for a look." >&2
  exit 1
fi
# Readable from start to end? pg_restore lists its table of contents.
if ! "$DC" exec -T postgres pg_restore --list < "$partial" > /dev/null; then
  echo "backup-now: pg_restore cannot read the dump. Kept as $partial for a look." >&2
  exit 1
fi
mv "$partial" "$file"
mv "$counts_partial" "$file.counts"
chmod 600 "$file" "$file.counts"
say "OK: $file ($(du -h "$file" | cut -f1))"

# Keep the newest $KEEP by time in the name (0: all). A dump's counts go with it.
if [[ "$KEEP" -gt 0 ]]; then
  ls -1 "$BACKUP_DIR"/rawwers-*.dump 2>/dev/null | sort -r | tail -n +"$((KEEP + 1))" | while read -r old; do
    say "removing old backup $old"
    rm -f "$old" "$old.counts"
  done
fi

if [[ $PATH_ONLY == 1 ]]; then
  echo "$file"
else
  echo
  echo "Test that it restores (into a scratch database, the live one is not touched):"
  echo "  $HERE/restore-test.sh $file"
fi
