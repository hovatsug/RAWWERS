#!/usr/bin/env bash
# The plug-in's tests, with plain Lua 5.1 in a container (see Dockerfile):
#   lightroom/tests/run.sh
# Every .lua file is also compiled with luac -p, which catches a syntax error
# before Lightroom does.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
docker build -q -t rawwers-lightroom-lua51 "$here/tests" >/dev/null
docker run --rm -v "$here:/plugin:ro" -w /plugin rawwers-lightroom-lua51 sh -c '
  set -e
  for f in rawwers.lrdevplugin/*.lua tests/*.lua; do luac5.1 -p "$f"; done
  echo "syntax: all files compile"
  status=0
  lua5.1 tests/test_logic.lua || status=1
  lua5.1 tests/test_export.lua || status=1
  exit $status
'
