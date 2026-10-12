#!/usr/bin/env bash
# Run the backend suite on a database and Redis index nobody else is using.
#
# The suite drops and recreates every table on every test, so two runs on
# one database corrupt each other, and two runs on one Redis index share
# cache versions and rate-limit counters. This gives each run its own:
#
#   database  rawwers_<timestamp>_<random>_test, created here, dropped after
#   Redis     an index from 1-15 (0 is the dev stack's), claimed with an
#             atomic SET NX in index 0 so concurrent runs never pick the same
#             one, flushed and released after
#
# and a five-minute Postgres lock_timeout. Every test drops all tables first,
# so a test that leaks an open transaction blocks the next one's DROP TABLE
# indefinitely - one such run sat silent for seven hours. With the timeout
# it fails, naming the table, a few minutes in.
#
# Usage (from api/):
#   make test-isolated                          # this checkout, whole suite
#   make test-isolated REPO=/path/to/worktree   # another checkout
#   make test-isolated ARGS="tests/test_x.py -k y"
#
# REPO must be a full checkout (repo root): some tests read the workflows and
# compose files beside api/.
set -euo pipefail

API_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(cd "${REPO:-$API_DIR/..}" && pwd)"
ARGS="${ARGS:-tests -q -p no:cacheprovider}"
COMPOSE="docker-compose -f $API_DIR/docker-compose.yml"

DB="rawwers_$(date +%Y%m%d%H%M%S)_$RANDOM$RANDOM""_test"
CLAIM_TTL=21600  # a crashed run frees its index after six hours

redis() { $COMPOSE exec -T redis redis-cli "$@"; }

INDEX=""
for n in $(seq 1 15); do
  if [ "$(redis -n 0 SET "test-isolated:redis-index:$n" "$DB" NX EX $CLAIM_TTL)" = "OK" ]; then
    INDEX=$n
    break
  fi
done
[ -n "$INDEX" ] || { echo "test-isolated: all 15 Redis indexes are claimed by other runs" >&2; exit 1; }

cleanup() {
  $COMPOSE exec -T postgres dropdb -U postgres --if-exists "$DB" >/dev/null 2>&1 || true
  redis -n "$INDEX" FLUSHDB >/dev/null 2>&1 || true
  redis -n 0 DEL "test-isolated:redis-index:$INDEX" >/dev/null 2>&1 || true
}
trap cleanup EXIT

$COMPOSE exec -T postgres createdb -U postgres "$DB"
echo "test-isolated: $REPO on database $DB, Redis index $INDEX" >&2

# shellcheck disable=SC2086 # ARGS is a list of pytest arguments
$COMPOSE run --rm -T \
  -v "$REPO:/repo" -w /repo/api \
  -e TEST_DATABASE_URL="postgresql+psycopg2://postgres:postgres@postgres:5432/$DB" \
  -e REDIS_URL="redis://redis:6379/$INDEX" \
  -e PGOPTIONS="-c lock_timeout=300s" \
  api python -m pytest $ARGS </dev/null
