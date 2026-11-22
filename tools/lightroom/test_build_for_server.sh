#!/usr/bin/env bash
# Tests for build-for-server.sh, with a fake build.sh that prints what it was
# given (no Docker, no build). Runs in a throwaway copy of the layout.
#
#   tools/lightroom/test_build_for_server.sh
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/rawwers-lr-test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/tools/lightroom" "$WORK/lightroom/rawwers.lrdevplugin"
cp "$HERE/build-for-server.sh" "$WORK/tools/lightroom/"
cat > "$WORK/fake-build.sh" <<'F'
#!/usr/bin/env bash
echo "FAKE-BUILD url=$RAWWERS_LIGHTROOM_API_URL_PRODUCTION args=$*"
F
chmod +x "$WORK/fake-build.sh"
export RAWWERS_LIGHTROOM_BUILD_SH="$WORK/fake-build.sh"
RUN="$WORK/tools/lightroom/build-for-server.sh"

pass=0; fail=0
check() {  # name, expected exit, text the output must contain, command...
  local name="$1" want="$2" text="$3"; shift 3
  local out code
  out="$("$@" 2>&1)"; code=$?
  if [[ "$code" == "$want" && "$out" == *"$text"* ]]; then pass=$((pass+1)); echo "ok   $name"
  else fail=$((fail+1)); echo "FAIL $name (exit $code, want $want; output: $out)"; fi
}

check "no Info.lua" 2 "cannot read the version" "$RUN"
cp "$REPO/lightroom/rawwers.lrdevplugin/Info.lua" "$WORK/lightroom/rawwers.lrdevplugin/"
# The version build.sh gets is the one the source says, in both places it says it.
src_info="$(sed -nE 's/.*VERSION = \{ major = ([0-9]+), minor = ([0-9]+), revision = ([0-9]+).*/\1.\2.\3/p' "$REPO/lightroom/rawwers.lrdevplugin/Info.lua")"
src_config="$(sed -nE "s/^[[:space:]]*version = '([0-9.]+)',/\1/p" "$REPO/lightroom/rawwers.lrdevplugin/RawwersConfig.lua")"
if [[ -n "$src_info" && "$src_info" == "$src_config" ]]; then pass=$((pass+1)); echo "ok   Info.lua and RawwersConfig.lua agree ($src_info)"
else fail=$((fail+1)); echo "FAIL Info.lua says '$src_info', RawwersConfig.lua says '$src_config'"; fi
check "version from the source" 0 "FAKE-BUILD url=https://api.rawwers.com args=--version $src_info --target production" "$RUN"
check "version given" 0 "args=--version 9.8.7 --target production" "$RUN" --version 9.8.7
check "skip tests passed on" 0 "--target production --skip-tests" "$RUN" --skip-tests
check "--target refused" 2 "unknown option --target" "$RUN" --target dev
check "--version without value" 2 "--version needs a value" "$RUN" --version
echo 'VERSION = { major = 1 }' > "$WORK/lightroom/rawwers.lrdevplugin/Info.lua"
check "unreadable version" 2 "cannot read the version" "$RUN"

echo "$pass passed, $fail failed"
[[ "$fail" == 0 ]]
