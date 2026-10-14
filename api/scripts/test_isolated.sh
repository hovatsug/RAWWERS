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
# At most MAX_PARALLEL runs at once (default 3): each run's index is its slot,
# and a run that finds every slot taken waits for one rather than starting.
# Five suites at once exhausted the shared Postgres lock table - every test
# drops and recreates every table - and tests errored in setup with "out of
# shared memory" (2026-10-14). Three at once has run clean.
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
#   MAX_PARALLEL=2 make test-isolated           # fewer at once
#
# The default ARGS name every failed and errored test (-rfE). Compare a run
# with docs/KNOWN_FAILURES.txt using scripts/check_known_failures.py: a run
# with any error is not clean, whatever its failures.
#
# REPO must be a full checkout (repo root): some tests read the workflows and
# compose files beside api/.
set -euo pipefail

API_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(cd "${REPO:-$API_DIR/..}" && pwd)"
ARGS="${ARGS:-tests -q -rfE -p no:cacheprovider}"
MAX_PARALLEL="${MAX_PARALLEL:-3}"
COMPOSE="docker-compose -f $API_DIR/docker-compose.yml"

DB="rawwers_$(date +%Y%m%d%H%M%S)_$RANDOM$RANDOM""_test"
CLAIM_TTL=21600  # a crashed run frees its index after six hours

redis() { $COMPOSE exec -T redis redis-cli "$@"; }

# Without this, a Redis that cannot be reached looks like every index taken.
[ "$(redis -n 0 PING 2>/dev/null)" = "PONG" ] || { echo "test-isolated: cannot reach Redis - is the api stack up (docker compose up)?" >&2; exit 1; }
[ "$MAX_PARALLEL" -ge 1 ] && [ "$MAX_PARALLEL" -le 15 ] || { echo "test-isolated: MAX_PARALLEL must be 1-15" >&2; exit 1; }

INDEX=""
waited=0
while [ -z "$INDEX" ]; do
  for n in $(seq 1 "$MAX_PARALLEL"); do
    if [ "$(redis -n 0 SET "test-isolated:redis-index:$n" "$DB" NX EX $CLAIM_TTL)" = "OK" ]; then
      INDEX=$n
      break
    fi
  done
  if [ -z "$INDEX" ]; then
    [ "$waited" -eq 0 ] && echo "test-isolated: $MAX_PARALLEL runs already going - waiting for one to finish" >&2
    waited=1
    sleep 10
  fi
done

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
