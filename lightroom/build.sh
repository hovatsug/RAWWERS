#!/usr/bin/env bash
# Builds the Lightroom Classic plug-in for a private download link:
#
#   lightroom/build.sh --version 1.0.0 --api-url https://api.example.com
#
# Writes lightroom/build/rawwers.lrplugin (the folder Lightroom's Plug-in
# Manager adds) and lightroom/build/rawwers-lightroom-1.0.0.zip. The source
# folder (rawwers.lrdevplugin, pointing at a dev API on this Mac) is copied,
# never changed; only the copy gets the version and the server address.
# Nothing is published or uploaded: where the zip lives is the owner's call.
#
# The tests run first (tests/run.sh); a build with a failing test is refused.
# Set LIGHTROOM_PLUGIN_LATEST_VERSION on the API to the same version when
# this build is released, so older plug-ins are told to update.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
version="" api_url="" skip_tests=0
while [ $# -gt 0 ]; do
  case "$1" in
    --version) version="$2"; shift 2 ;;
    --api-url) api_url="$2"; shift 2 ;;
    --skip-tests) skip_tests=1; shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done
[[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || { echo "--version must be like 1.0.0" >&2; exit 2; }
major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}" revision="${BASH_REMATCH[3]}"
# The token goes in every request: https only, except a dev API on this Mac
# or the local network (the plug-in refuses anything else too).
if ! [[ "$api_url" =~ ^https://[A-Za-z0-9.-]+ || "$api_url" =~ ^http://(localhost|127\.0\.0\.1|[A-Za-z0-9.-]+\.local)(:[0-9]+)?$ ]]; then
  echo "--api-url must be https:// (or a dev API on localhost / .local)" >&2; exit 2
fi

[ "$skip_tests" = 1 ] || "$here/tests/run.sh" >/dev/null || { echo "tests failed: not building" >&2; exit 1; }

out="$here/build"
rm -rf "$out/rawwers.lrplugin"
mkdir -p "$out"
cp -R "$here/rawwers.lrdevplugin" "$out/rawwers.lrplugin"
cat > "$out/rawwers.lrplugin/RawwersConfig.lua" <<LUA
-- Written by build.sh for version $version. Do not edit the built copy.
return {
	version = '$version',
	baseUrl = '$api_url',
}
LUA
python3 - "$out/rawwers.lrplugin/Info.lua" "$major" "$minor" "$revision" <<'PY'
import re, sys
path, major, minor, revision = sys.argv[1:]
text = open(path).read()
new, n = re.subn(r"VERSION = \{[^}]*\}", f"VERSION = {{ major = {major}, minor = {minor}, revision = {revision}, build = 0 }}", text)
assert n == 1, "VERSION not found in Info.lua"
open(path, "w").write(new)
PY
zip_path="$out/rawwers-lightroom-$version.zip"
rm -f "$zip_path"
( cd "$out" && zip -qr -X "$zip_path" rawwers.lrplugin )
echo "built $out/rawwers.lrplugin"
echo "      $zip_path ($(du -h "$zip_path" | cut -f1 | tr -d ' '))"
echo "server: $api_url   version: $version"
