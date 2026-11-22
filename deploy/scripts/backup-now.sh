#!/usr/bin/env bash
# backup-now.sh: a database backup, now, written to a folder on the server.
#
#   deploy/scripts/backup-now.sh                 # writes /var/backups/rawwers/rawwers-<time>.dump
#   BACKUP_DIR=/somewhere/else deploy/scripts/backup-now.sh
#
# The file is a compressed pg_dump (custom format). It is written to a plain
# folder on the server, NOT inside a Docker volume: removing or recreating the
# containers or volumes does not touch it. It IS lost if the whole server is
# rebuilt or deleted - only the Hetzner backups and snapshots survive that.
# Off-server copies (to R2) are batch 4 (BETA_SCOPE, LATER).
#
# Keeps the newest 14 files and deletes older ones.
# Restore test (safe, never touches the live database): deploy/scripts/restore-test.sh <file>
# Real restore (replaces the live data): docs/DEPLOY_RUNBOOK.md, "Restore a backup".
set -euo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,15p' "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
DC="$HERE/dc"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/rawwers}"
KEEP="${KEEP:-14}"

resolved="$(realpath -m "$BACKUP_DIR" 2>/dev/null || python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$BACKUP_DIR")"
case "$resolved" in
  /var/lib/docker|/var/lib/docker/*|/private/var/lib/docker|/private/var/lib/docker/*)
    echo "backup-now: refuse to write inside /var/lib/docker ($BACKUP_DIR): that is where Docker keeps volumes, and removing them would remove the backups too. Use a plain folder such as /var/backups/rawwers." >&2
    exit 2 ;;
esac

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
file="$BACKUP_DIR/rawwers-$stamp.dump"
partial="$file.partial"

echo "Backing up the database to $file ..."
"$DC" exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom --compress=6 --no-owner' > "$partial"
size=$(stat -c %s "$partial" 2>/dev/null || stat -f %z "$partial")
if [[ "$size" -lt 1024 ]]; then
  echo "backup-now: the dump is only $size bytes; something is wrong. Kept as $partial for a look." >&2
  exit 1
fi
# Readable from start to end? pg_restore lists its table of contents.
if ! "$DC" exec -T postgres pg_restore --list < "$partial" > /dev/null; then
  echo "backup-now: pg_restore cannot read the dump. Kept as $partial for a look." >&2
  exit 1
fi
mv "$partial" "$file"
chmod 600 "$file"
echo "OK: $file ($(du -h "$file" | cut -f1))"

# Keep the newest $KEEP.
ls -1t "$BACKUP_DIR"/rawwers-*.dump 2>/dev/null | tail -n +"$((KEEP + 1))" | while read -r old; do
  echo "removing old backup $old"; rm -f "$old"
done

echo
echo "Test that it restores (into a scratch database, the live one is not touched):"
echo "  $HERE/restore-test.sh $file"
