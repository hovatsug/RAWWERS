#!/usr/bin/env bash
# Tests for native-db.sh: it leaves nothing running and nothing on disk after
# a passing run, a failing run and an interrupted run, and it never reads an
# env file. Needs what native-db.sh needs (Homebrew postgresql@16, valkey,
# and `native-db.sh setup`).
#
#   tools/tests/test_native_db.sh
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="${NATIVE_DB_SCRIPT:-$HERE/native-db.sh}"
pass=0; fail=0
ok() { pass=$((pass+1)); echo "ok   $1"; }
bad() { fail=$((fail+1)); echo "FAIL $1"; }

started_line() { grep -m1 '^native-db: Postgres' "$1"; }
nothing_left() {  # log file, name
  local line pg rd run
  line="$(started_line "$1")" || { bad "$2: never started"; return; }
  pg="$(sed -E 's/.*Postgres 127\.0\.0\.1:([0-9]+) .*/\1/' <<<"$line")"
  rd="$(sed -E 's/.*Valkey 127\.0\.0\.1:([0-9]+),.*/\1/' <<<"$line")"
  run="$(sed -E 's/.*run folder ([^;]+);.*/\1/' <<<"$line")"
  if nc -z 127.0.0.1 "$pg" 2>/dev/null || nc -z 127.0.0.1 "$rd" 2>/dev/null; then bad "$2: something still listens on $pg or $rd"
  elif pgrep -f "$run" >/dev/null; then bad "$2: a process still uses $run"
  elif [[ -e "$run" ]]; then bad "$2: the run folder is still there"
  else ok "$2: nothing left running or on disk"; fi
}

# 1. Never an env file.
if grep -v '^[[:space:]]*#' "$SCRIPT" | grep -nE '\.env\b|env-file|env_file|(^|[;&|[:space:]])source[[:space:]]|^[[:space:]]*\.[[:space:]]' >/dev/null; then bad "reads or passes an env file"
else ok "no env file read or passed"; fi

LOG="$(mktemp "${TMPDIR:-/tmp}/native-db-test.XXXXXX")"
trap 'rm -f "$LOG"' EXIT

# 2. A passing run (collect only: fast).
"$SCRIPT" --co -q tests/test_deploy_scripts.py >"$LOG" 2>&1; code=$?
[[ "$code" == 0 ]] && ok "passing run exits 0" || { bad "passing run exits $code"; tail -5 "$LOG"; }
nothing_left "$LOG" "after a passing run"

# 3. A failing run: pytest's exit status comes back, and everything stops.
"$SCRIPT" tests/test_no_such_file_here.py >"$LOG" 2>&1; code=$?
[[ "$code" != 0 ]] && ok "failing run exits $code" || bad "failing run exits 0"
nothing_left "$LOG" "after a failing run"

# 4. Interrupted while running: pytest stops too (a marker on its command line).
MARK="$(mktemp -d "${TMPDIR:-/tmp}/native-db-mark.XXXXXX")"
"$SCRIPT" tests/test_deploy_scripts.py --basetemp="$MARK/t" >"$LOG" 2>&1 &
pid=$!
for _ in $(seq 1 120); do started_line "$LOG" >/dev/null && break; sleep 0.5; done
sleep 2
kill -TERM "$pid" 2>/dev/null; wait "$pid"; code=$?
[[ "$code" != 0 ]] && ok "interrupted run exits $code" || bad "interrupted run exits 0"
sleep 2
nothing_left "$LOG" "after an interrupted run"
if pgrep -f "$MARK" >/dev/null; then bad "pytest still runs after the interrupt"; pkill -f "$MARK"; else ok "pytest stopped with the run"; fi
rm -rf "$MARK"

echo "$pass passed, $fail failed"
[[ "$fail" == 0 ]]
