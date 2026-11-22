#!/usr/bin/env bash
# Build the Lightroom plug-in for the test server, https://api.rawwers.com.
#
#   tools/lightroom/build-for-server.sh                 # version from the source
#   tools/lightroom/build-for-server.sh --version 1.2.5
#   tools/lightroom/build-for-server.sh --skip-tests    # only if the tests passed on this commit
#
# It calls lightroom/build.sh unchanged, with --target production and the
# server's address; build.sh keeps all its own checks (https only, not this
# Mac, tests first). The version, unless given, is the one in the plug-in's
# source (rawwers.lrdevplugin/Info.lua, VERSION).
#
# Writes lightroom/build/rawwers.lrplugin (Plug-in Manager > Add) and
# lightroom/build/rawwers-lightroom-<version>.zip.
#
# build.sh runs the plug-in's tests first, in a small Lua 5.1 Docker
# container (lightroom/tests/run.sh): Docker Desktop must be running for the
# build. Quit it afterwards.
#
# Install, pair and the server's version setting:
# docs/LIGHTROOM_CHECKLIST.md, "Against the test server".
set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD_SH="${RAWWERS_LIGHTROOM_BUILD_SH:-$REPO/lightroom/build.sh}"
SERVER_URL="https://api.rawwers.com"

version="" pass=()
while [ $# -gt 0 ]; do
  case "$1" in
    --version) [ $# -ge 2 ] || { echo "--version needs a value" >&2; exit 2; }; version="$2"; shift 2 ;;
    --skip-tests) pass+=(--skip-tests); shift ;;
    -h|--help) sed -n '2,21p' "$0"; exit 0 ;;
    *) echo "unknown option $1 (this script takes --version and --skip-tests)" >&2; exit 2 ;;
  esac
done

if [ -z "$version" ]; then
  info="$REPO/lightroom/rawwers.lrdevplugin/Info.lua"
  line="$(grep -E '^[[:space:]]*VERSION[[:space:]]*=' "$info" 2>/dev/null || true)"
  if [[ "$line" =~ major[[:space:]]*=[[:space:]]*([0-9]+).*minor[[:space:]]*=[[:space:]]*([0-9]+).*revision[[:space:]]*=[[:space:]]*([0-9]+) ]]; then
    version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  else
    echo "cannot read the version from lightroom/rawwers.lrdevplugin/Info.lua; give --version" >&2
    exit 2
  fi
fi

echo "Building the plug-in $version for $SERVER_URL" >&2
RAWWERS_LIGHTROOM_API_URL_PRODUCTION="$SERVER_URL" exec "$BUILD_SH" --version "$version" --target production ${pass[@]+"${pass[@]}"}
