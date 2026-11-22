#!/usr/bin/env bash
# Tests for run-against-server.sh. No Flutter needed: a fake `flutter` prints
# the arguments it was given. Runs in a throwaway copy of the layout, so it
# never reads or writes the real app/env/*.server.json.
#
#   tools/app/test_run_against_server.sh
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/rawwers-run-test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/tools/app" "$WORK/app/env" "$WORK/bin"
cp "$HERE"/run-against-server.sh "$HERE"/run-client-server.sh "$HERE"/run-pro-server.sh "$WORK/tools/app/"
cat > "$WORK/bin/flutter" <<'F'
#!/usr/bin/env bash
echo "FAKE-FLUTTER cwd=$(basename "$PWD") $*"
F
chmod +x "$WORK/bin/flutter"
export FLUTTER="$WORK/bin/flutter"

# A made-up value that must never appear in any output.
SECRETISH="pk_test_DoNotPrintThis0123456789abcdef"
pass=0; fail=0
check() {  # name, expected exit, text the output must contain, command...
  local name="$1" want="$2" text="$3"; shift 3
  local out code
  out="$("$@" 2>&1)"; code=$?
  if [[ "$code" == "$want" && "$out" == *"$text"* && "$out" != *"$SECRETISH"* && "$out" != *"evil.example"* ]]; then
    pass=$((pass+1)); echo "ok   $name"
  else
    fail=$((fail+1)); echo "FAIL $name (exit $code, want $want; output: $out)"
  fi
}
client() { printf '%s' "$1" > "$WORK/app/env/client.server.json"; }
pro() { printf '%s' "$1" > "$WORK/app/env/pro.server.json"; }
RUN_C="$WORK/tools/app/run-client-server.sh"
RUN_P="$WORK/tools/app/run-pro-server.sh"

check "no app name" 2 "usage:" "$WORK/tools/app/run-against-server.sh"
check "missing client file" 2 "client.server.json is missing" "$RUN_C"
client 'not json'
check "not json" 1 "not valid JSON" "$RUN_C"
client '{"API_BASE_URL": "http://evil.example", "STRIPE_PUBLISHABLE_KEY": "'"$SECRETISH"'"}'
check "http refused" 1 "must be an https address" "$RUN_C"
client '{"API_BASE_URL": "https://localhost:8000", "STRIPE_PUBLISHABLE_KEY": "'"$SECRETISH"'"}'
check "this Mac refused" 1 "points at this Mac" "$RUN_C"
client '{"API_BASE_URL": "https://api.rawwers.com", "STRIPE_PUBLISHABLE_KEY": "pk_test_REPLACE_WITH_YOUR_STRIPE_TEST_PUBLISHABLE_KEY"}'
check "placeholder key refused" 1 "still the example's placeholder" "$RUN_C"
client '{"API_BASE_URL": "https://api.rawwers.com", "STRIPE_PUBLISHABLE_KEY": "pk_live_DoNotPrintThis0123456789abcdef"}'
check "live key refused" 1 "TEST publishable key" "$RUN_C"
client '{"API_BASE_URL": "https://api.rawwers.com", "STRIPE_PUBLISHABLE_KEY": "'"$SECRETISH"'", "X": "sk_test_DoNotPrintThis0123456789abcdef"}'
check "secret key refused" 1 "live or secret key" "$RUN_C"
client '{"API_BASE_URL": "https://api.rawwers.com", "STRIPE_PUBLISHABLE_KEY": "'"$SECRETISH"'"}'
check "client runs" 0 "FAKE-FLUTTER cwd=app run --flavor client -t lib/main_client.dart --dart-define-from-file=env/client.server.json -d x" "$RUN_C" -d x
check "missing pro file" 2 "pro.server.json is missing" "$RUN_P"
pro '{"API_BASE_URL": "http://10.0.2.2:8000"}'
check "pro http refused" 1 "must be an https address" "$RUN_P"
pro '{"API_BASE_URL": "https://api.rawwers.com"}'
check "pro runs" 0 "FAKE-FLUTTER cwd=app run --flavor pro -t lib/main_pro.dart --dart-define-from-file=env/pro.server.json" "$RUN_P"

echo "$pass passed, $fail failed"
[[ "$fail" == 0 ]]
