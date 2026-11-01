#!/usr/bin/env bash
# build.sh: the server address is a build-time setting, one for dev and one
# for production, never written in the repository (owner's decision 6).
#
#   lightroom/tests/test_build.sh
#
# Builds with --skip-tests into a temporary folder; needs bash, python3 and
# zip (as build.sh does), not Lightroom or Docker.
set -uo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
pass=0 fail=0
source_sum() { (cd "$here/rawwers.lrdevplugin" && find . -type f -exec shasum {} + | sort | shasum); }
before="$(source_sum)"
check() { if eval "$2"; then echo "ok    $1"; pass=$((pass + 1)); else echo "FAIL  $1"; fail=$((fail + 1)); fi; }

build() {  # build <out> <env...> -- <args...>
  local out="$1"; shift
  local envs=()
  while [ "$1" != "--" ]; do envs+=("$1"); shift; done; shift
  env -u RAWWERS_LIGHTROOM_API_URL_PRODUCTION -u RAWWERS_LIGHTROOM_API_URL_DEV \
    RAWWERS_LIGHTROOM_BUILD_DIR="$out" ${envs[@]+"${envs[@]}"} "$here/build.sh" --skip-tests "$@" >"$out.log" 2>&1
}
config() { cat "$1/rawwers.lrplugin/RawwersConfig.lua"; }

o="$tmp/p-unset"; build "$o" -- --version 1.2.3 --target production; rc=$?
check 'production without its address is refused, and nothing is built' \
  '[ $rc -ne 0 ] && grep -q "^set RAWWERS_LIGHTROOM_API_URL_PRODUCTION" "$o.log" && [ ! -e "$o/rawwers.lrplugin" ]'

for bad in http://api.example.test https://localhost:8000 https://127.0.0.1 https://studio.local "https://api.example.test'; os.exit()"; do
  o="$tmp/p-bad-$RANDOM"; build "$o" RAWWERS_LIGHTROOM_API_URL_PRODUCTION="$bad" -- --version 1.2.3 --target production; rc=$?
  check "production refuses $bad" '[ $rc -ne 0 ] && [ ! -e "$o/rawwers.lrplugin" ]'
done

o="$tmp/p-ok"; build "$o" RAWWERS_LIGHTROOM_API_URL_PRODUCTION=https://api.example.test -- --version 1.2.3 --target production; rc=$?
check 'production is built with its own address, version and target' \
  '[ $rc -eq 0 ] && config "$o" | grep -q "baseUrl = '"'"'https://api.example.test'"'"'" && config "$o" | grep -q "version = '"'"'1.2.3'"'"'" && config "$o" | grep -q "target = '"'"'production'"'"'"'
check 'the production zip has no -dev in its name' '[ -f "$o/rawwers-lightroom-1.2.3.zip" ]'
check 'Info.lua carries the version Lightroom shows' 'grep -q "major = 1, minor = 2, revision = 3" "$o/rawwers.lrplugin/Info.lua"'

o="$tmp/p-env-file"; mkdir -p "$o"
cp -R "$here" "$tmp/plugin-copy"
printf 'RAWWERS_LIGHTROOM_API_URL_PRODUCTION=https://from-file.example.test\n' > "$tmp/plugin-copy/build.env"
env -u RAWWERS_LIGHTROOM_API_URL_PRODUCTION RAWWERS_LIGHTROOM_BUILD_DIR="$o" "$tmp/plugin-copy/build.sh" --skip-tests --version 1.0.0 --target production >"$o.log" 2>&1; rc=$?
check 'the address can come from lightroom/build.env' '[ $rc -eq 0 ] && config "$o" | grep -q from-file.example.test'
o="$tmp/p-env-wins"
RAWWERS_LIGHTROOM_API_URL_PRODUCTION=https://from-env.example.test RAWWERS_LIGHTROOM_BUILD_DIR="$o" "$tmp/plugin-copy/build.sh" --skip-tests --version 1.0.0 --target production >"$o.log" 2>&1; rc=$?
check 'the environment wins over build.env' '[ $rc -eq 0 ] && config "$o" | grep -q from-env.example.test'

o="$tmp/d-default"; build "$o" -- --version 1.2.3 --target dev; rc=$?
dev_url="$(sed -n "s/^[[:space:]]*baseUrl = '\(.*\)',$/\1/p" "$here/rawwers.lrdevplugin/RawwersConfig.lua")"
check 'dev defaults to the dev plug-in'"'"'s own address' \
  '[ $rc -eq 0 ] && [ -n "$dev_url" ] && config "$o" | grep -q "baseUrl = '"'"'$dev_url'"'"'" && config "$o" | grep -q "target = '"'"'dev'"'"'"'
check 'the dev zip says -dev' '[ -f "$o/rawwers-lightroom-1.2.3-dev.zip" ]'

o="$tmp/d-set"; build "$o" RAWWERS_LIGHTROOM_API_URL_DEV=http://studio-mac.local:8000 RAWWERS_LIGHTROOM_API_URL_PRODUCTION=https://api.example.test -- --version 1.2.3 --target dev; rc=$?
check 'dev uses its own setting, never the production one' '[ $rc -eq 0 ] && config "$o" | grep -q studio-mac.local && ! config "$o" | grep -q api.example.test'

o="$tmp/no-target"; build "$o" RAWWERS_LIGHTROOM_API_URL_PRODUCTION=https://api.example.test -- --version 1.2.3; rc=$?
check 'a build must name its target' '[ $rc -ne 0 ] && [ ! -e "$o/rawwers.lrplugin" ]'

check 'no server address is written in build.sh (outside comments)' \
  '! grep -v "^[[:space:]]*#" "$here/build.sh" | grep -Eo "https://[A-Za-z0-9-]+\.[A-Za-z0-9.-]+" | grep -q .'
check 'the source plug-in is left as it was' '[ "$(source_sum)" = "$before" ]'
check 'build.env is never committed' 'git -C "$here" check-ignore -q build.env'

echo
echo "$((pass + fail)) tests, $fail failed"
[ $fail -eq 0 ]
