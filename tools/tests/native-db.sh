#!/usr/bin/env bash
# Backend tests on the Mac without Docker: a throwaway Postgres 16 and a
# throwaway Valkey (Redis-compatible), started for this run and stopped
# afterwards, also when the run fails or is interrupted. Nothing is left
# running and nothing is kept: each run gets a new, empty database cluster in
# a temporary folder, deleted at the end.
#
#   tools/tests/native-db.sh setup                         # once: the Python environment
#   tools/tests/native-db.sh tests/test_x.py               # pytest arguments, run in api/
#   tools/tests/native-db.sh tests/test_x.py -k name -x
#   NATIVE_DB_ROOT=1 tools/tests/native-db.sh tools/server/tests   # run from the repository root
#   RAWWERS_REPO=<another checkout> tools/tests/native-db.sh tests/test_x.py
#
# Needs (Homebrew): postgresql@16, valkey, python@3.12. `setup` makes the
# API's Python environment in ~/Developer/RAWWERS-work/venv/api-py312 from
# api/poetry.lock (Poetry 1.8.4, as the image), with the dev dependencies.
#
# It never reads or passes api/.env or any other env file: the suite's
# conftest sets placeholder values for every service, and this script sets
# only the database, Redis and the placeholders the settings require.
# Full suites run in GitHub Actions ("Backend full suite (manual)"), not here.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "${RAWWERS_REPO:-$HERE/../..}" && pwd)"
WORK="${RAWWERS_WORK:-$HOME/Developer/RAWWERS-work}"
VENV="${NATIVE_DB_VENV:-$WORK/venv/api-py312}"
POETRY_VENV="$WORK/venv/poetry-1.8.4"
BREW="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null || echo /usr/local)}"
PG_BIN="${PG_BIN:-$BREW/opt/postgresql@16/bin}"
VALKEY="${VALKEY_SERVER:-$BREW/bin/valkey-server}"
PY312="${PYTHON312:-$BREW/opt/python@3.12/bin/python3.12}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,21p' "$0"; exit 0; fi

if [[ "${1:-}" == "setup" ]]; then
  [[ -x "$PY312" ]] || { echo "native-db: no Python 3.12 at $PY312 (brew install python@3.12)" >&2; exit 2; }
  mkdir -p "$WORK/venv"
  [[ -x "$POETRY_VENV/bin/poetry" ]] || { "$PY312" -m venv "$POETRY_VENV" && "$POETRY_VENV/bin/pip" install -q "poetry==1.8.4"; }
  [[ -x "$VENV/bin/python" ]] || "$PY312" -m venv "$VENV"
  (cd "$REPO/api" && VIRTUAL_ENV="$VENV" PATH="$VENV/bin:$PATH" POETRY_VIRTUALENVS_CREATE=false \
    "$POETRY_VENV/bin/poetry" install --no-interaction --no-ansi --with dev --no-root)
  "$VENV/bin/python" -c "import sys, pytest, sqlalchemy; print('native-db: ready,', sys.version.split()[0], 'pytest', pytest.__version__)"
  exit 0
fi

for tool in "$PG_BIN/initdb" "$PG_BIN/pg_ctl" "$PG_BIN/createdb" "$VALKEY" "$VENV/bin/python"; do
  [[ -x "$tool" ]] || { echo "native-db: missing $tool (Homebrew: postgresql@16, valkey; then: $0 setup)" >&2; exit 2; }
done
[[ $# -gt 0 ]] || { echo "usage: $0 <pytest arguments>   (a full suite runs in GitHub Actions)" >&2; exit 2; }

RUN="$(mktemp -d "${TMPDIR:-/tmp}/rawwers-native-db.XXXXXX")"
PGDATA="$RUN/pg"
free_port() { "$VENV/bin/python" -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()'; }
PG_PORT="$(free_port)"
REDIS_PORT="$(free_port)"
DB="rawwers_native_$(date +%Y%m%d%H%M%S)_test"

pg_started=0 valkey_started=0
cleanup() {
  local code=$?
  if [[ "$valkey_started" == 1 && -f "$RUN/valkey.pid" ]]; then
    local vpid
    vpid="$(cat "$RUN/valkey.pid" 2>/dev/null || true)"
    if [[ -n "$vpid" ]]; then
      kill "$vpid" 2>/dev/null || true
      for _ in 1 2 3 4 5 6 7 8 9 10; do kill -0 "$vpid" 2>/dev/null || break; sleep 0.5; done
      kill -9 "$vpid" 2>/dev/null || true
    fi
  fi
  if [[ "$pg_started" == 1 ]]; then
    "$PG_BIN/pg_ctl" -D "$PGDATA" -m fast -w stop >/dev/null 2>&1 || "$PG_BIN/pg_ctl" -D "$PGDATA" -m immediate stop >/dev/null 2>&1 || true
  fi
  rm -rf "$RUN"
  echo "native-db: stopped Postgres and Valkey, removed the run folder (exit $code)" >&2
  exit "$code"
}
child=""
stop_child() { [[ -n "$child" ]] && kill -TERM "$child" 2>/dev/null; [[ -n "$child" ]] && wait "$child" 2>/dev/null; return 0; }
trap cleanup EXIT
trap 'stop_child; exit 130' INT
trap 'stop_child; exit 143' TERM

# On macOS Postgres stops at start ("postmaster became multithreaded") unless
# LC_ALL names a valid locale (Homebrew's note says the same).
export LC_ALL="${NATIVE_DB_LOCALE:-en_US.UTF-8}"
"$PG_BIN/initdb" -D "$PGDATA" -U postgres --auth=trust -E UTF8 --no-locale >/dev/null
# Only this machine, only this port; a socket folder inside the run folder.
pg_started=1
if ! "$PG_BIN/pg_ctl" -D "$PGDATA" -w -l "$RUN/postgres.log" \
  -o "-p $PG_PORT -h 127.0.0.1 -k $RUN -c fsync=off -c synchronous_commit=off -c full_page_writes=off -c max_locks_per_transaction=256" start >/dev/null; then
  echo "native-db: Postgres did not start; its log:" >&2
  tail -n 15 "$RUN/postgres.log" >&2
  exit 2
fi
"$PG_BIN/createdb" -h 127.0.0.1 -p "$PG_PORT" -U postgres "$DB"

"$VALKEY" --port "$REDIS_PORT" --bind 127.0.0.1 --save "" --appendonly no --daemonize yes \
  --pidfile "$RUN/valkey.pid" --logfile "$RUN/valkey.log" --dir "$RUN"
valkey_started=1
for _ in $(seq 1 40); do [[ -f "$RUN/valkey.pid" ]] && break; sleep 0.25; done

echo "native-db: Postgres 127.0.0.1:$PG_PORT ($DB), Valkey 127.0.0.1:$REDIS_PORT, run folder $RUN; $REPO" >&2

RUN_DIR="$REPO/api"
[[ -n "${NATIVE_DB_ROOT:-}" ]] && RUN_DIR="$REPO"
set +e
(
  cd "$RUN_DIR"
  exec env -u DATABASE_URL \
    TEST_DATABASE_URL="postgresql+psycopg2://postgres@127.0.0.1:$PG_PORT/$DB" \
    REDIS_URL="redis://127.0.0.1:$REDIS_PORT/0" \
    PGOPTIONS="-c lock_timeout=300s" \
    R2_ENDPOINT_URL="https://example.r2.cloudflarestorage.com" R2_ACCESS_KEY_ID=test R2_SECRET_ACCESS_KEY=test \
    R2_BUCKET=bucket R2_REGION=auto \
    PYTHONPYCACHEPREFIX="$WORK/venv/pycache" \
    "$VENV/bin/python" -m pytest -p no:cacheprovider "$@"
) &
# In the background and waited for, so an interrupt reaches the traps at once.
child=$!
wait "$child"
code=$?
child=""
set -e
exit "$code"
