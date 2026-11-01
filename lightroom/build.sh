# Builds the Lightroom Classic plug-in for a private download link:
#
#   lightroom/build.sh --version 1.0.0 --target production
#   lightroom/build.sh --version 1.0.0 --target dev
#
# The server address is a build-time setting, one per target, never written
# in this repository (owner's decision 6):
#
#   RAWWERS_LIGHTROOM_API_URL_PRODUCTION  required for --target production;
#                                         https only, not this Mac or the LAN
#   RAWWERS_LIGHTROOM_API_URL_DEV         optional; defaults to the dev
#                                         plug-in's own address
#                                         (rawwers.lrdevplugin/RawwersConfig.lua)
#
# Either comes from the environment or from lightroom/build.env (KEY=value
# lines, gitignored), the environment winning.
#
# Writes lightroom/build/rawwers.lrplugin (the folder Lightroom's Plug-in
# Manager adds) and lightroom/build/rawwers-lightroom-1.0.0.zip
# (rawwers-lightroom-1.0.0-dev.zip for dev). The source folder
# (rawwers.lrdevplugin) is copied, never changed; only the copy gets the
# version and the server address. Nothing is published or uploaded: the zip
# is hosted with the deploy plan (owner's decision 5).
#
# The tests run first (tests/run.sh); a build with a failing test is refused.
# On release, set LIGHTROOM_PLUGIN_LATEST_VERSION on the API to this version
# (docs/DEPLOY_CHECKLIST.md, "Lightroom plug-in release").
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
version="" target="" skip_tests=0
out="${RAWWERS_LIGHTROOM_BUILD_DIR:-$here/build}"
while [ $# -gt 0 ]; do
  case "$1" in
    --version) version="$2"; shift 2 ;;
    --target) target="$2"; shift 2 ;;
    --skip-tests) skip_tests=1; shift ;;
    *) echo "unknown option $1" >&2; exit 2 ;;
  esac
done
[[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || { echo "--version must be like 1.0.0" >&2; exit 2; }
major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}" revision="${BASH_REMATCH[3]}"

# build.env fills in only what the environment does not set.
setting() {
  local name="$1" value="${!1:-}"
  if [ -z "$value" ] && [ -f "$here/build.env" ]; then
    value="$(sed -n "s/^$name=//p" "$here/build.env" | tail -1)"
  fi
  printf '%s' "$value"
}
case "$target" in
  production)
    api_url="$(setting RAWWERS_LIGHTROOM_API_URL_PRODUCTION)"
    [ -n "$api_url" ] || { echo "set RAWWERS_LIGHTROOM_API_URL_PRODUCTION (environment or lightroom/build.env) to build for production" >&2; exit 2; }
    # The token goes in every request: https, and a real server.
    if ! [[ "$api_url" =~ ^https://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._/-]*)?$ ]] \
      || [[ "$api_url" =~ ^https://(localhost|127\.0\.0\.1|[A-Za-z0-9.-]+\.local)([:/]|$) ]]; then
      echo "RAWWERS_LIGHTROOM_API_URL_PRODUCTION must be an https:// server address" >&2; exit 2
    fi
    suffix="" ;;
  dev)
    api_url="$(setting RAWWERS_LIGHTROOM_API_URL_DEV)"
    [ -n "$api_url" ] || api_url="$(sed -n "s/^[[:space:]]*baseUrl = '\(.*\)',$/\1/p" "$here/rawwers.lrdevplugin/RawwersConfig.lua")"
    # https, or a dev API on this Mac or the local network (the plug-in
    # refuses anything else too).
    if ! [[ "$api_url" =~ ^https://[A-Za-z0-9.-]+ || "$api_url" =~ ^http://(localhost|127\.0\.0\.1|[A-Za-z0-9.-]+\.local)(:[0-9]+)?$ ]]; then
      echo "RAWWERS_LIGHTROOM_API_URL_DEV must be https:// or a dev API on localhost / .local" >&2; exit 2
    fi
    suffix="-dev" ;;
  *) echo "--target must be dev or production" >&2; exit 2 ;;
esac

[ "$skip_tests" = 1 ] || "$here/tests/run.sh" >/dev/null || { echo "tests failed: not building" >&2; exit 1; }

rm -rf "$out/rawwers.lrplugin"
mkdir -p "$out"
cp -R "$here/rawwers.lrdevplugin" "$out/rawwers.lrplugin"
cat > "$out/rawwers.lrplugin/RawwersConfig.lua" <<LUA
-- Written by build.sh for version $version ($target). Do not edit the built copy.
return {
	version = '$version',
	target = '$target',
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
zip_path="$out/rawwers-lightroom-$version$suffix.zip"
rm -f "$zip_path"
( cd "$out" && zip -qr -X "$zip_path" rawwers.lrplugin )
echo "built $out/rawwers.lrplugin"
echo "      $zip_path ($(du -h "$zip_path" | cut -f1 | tr -d ' '))"
echo "target: $target   server: $api_url   version: $version"
