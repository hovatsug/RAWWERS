#!/usr/bin/env bash
# restore-test.sh: prove a backup restores, without touching the live database.
#
#   deploy/scripts/restore-test.sh /var/backups/rawwers/rawwers-<time>.dump
#
# Restores the file into a new scratch database (rawwers_restore_test) inside
# the same Postgres, compares it with the live one (migration version, number
# of tables, number of users), then drops the scratch database.
# Exit 0: the backup restores and matches. Exit 1: it does not.
set -euo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -ne 1 ]]; then sed -n '2,9p' "$0"; [[ $# -eq 1 ]] && exit 0 || exit 2; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
DC="$HERE/dc"
FILE="$1"
SCRATCH=rawwers_restore_test
[[ -r "$FILE" ]] || { echo "restore-test: cannot read $FILE" >&2; exit 2; }

psql_in() { "$DC" exec -T postgres sh -c "psql -U \"\$POSTGRES_USER\" -d $1 -tAc \"$2\""; }
cleanup() { "$DC" exec -T postgres sh -c "dropdb -U \"\$POSTGRES_USER\" --if-exists $SCRATCH" >/dev/null 2>&1 || true; }
trap cleanup EXIT

cleanup
"$DC" exec -T postgres sh -c "createdb -U \"\$POSTGRES_USER\" $SCRATCH"
echo "Restoring $FILE into $SCRATCH ..."
"$DC" exec -T postgres sh -c "pg_restore -U \"\$POSTGRES_USER\" -d $SCRATCH --no-owner --exit-on-error" < "$FILE"

live_db=$("$DC" exec -T postgres sh -c 'echo $POSTGRES_DB' | tr -d '\r')
q_version="SELECT version_num FROM alembic_version"
q_tables="SELECT count(*) FROM information_schema.tables WHERE table_schema='public'"
q_users="SELECT count(*) FROM user_account"
fail=0
for q in "$q_version" "$q_tables" "$q_users"; do
  live=$(psql_in "$live_db" "$q" | tr -d '\r')
  restored=$(psql_in "$SCRATCH" "$q" | tr -d '\r')
  if [[ "$live" == "$restored" ]]; then
    echo "ok    $q -> $restored"
  else
    echo "DIFF  $q -> live $live, restored $restored (fine only if data changed since the backup)"
    fail=1
  fi
done
echo
[[ $fail -eq 0 ]] && echo "The backup restores and matches the live database." || echo "The backup restores, but differs from the live database now (see DIFF above)."
exit $fail
