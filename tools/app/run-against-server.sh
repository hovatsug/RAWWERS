#!/usr/bin/env bash
# Run one of the Flutter apps on the Mac (simulator or a phone) against the
# test server, https://api.rawwers.com. Hot reload works as usual.
#
#   tools/app/run-against-server.sh client [flutter run options]
#   tools/app/run-against-server.sh pro    [flutter run options]
#
# (tools/app/run-client-server.sh and run-pro-server.sh call this.)
#
# It reads app/env/<app>.server.json, which git ignores. Make it once:
#   cp app/env/client.server.example.json app/env/client.server.json
#   cp app/env/pro.server.example.json    app/env/pro.server.json
# and put your Stripe TEST publishable key (pk_test_...) in the client one.
#
# Before starting it checks the file and refuses: a missing file, an address
# that is not https or is this Mac, the example's placeholder key, or a live
# key. It names the setting that is wrong, never its value.
set -euo pipefail

FLAVOR="${1:-}"
case "$FLAVOR" in
  client|pro) shift ;;
  *) echo "usage: $0 client|pro [flutter run options]" >&2; exit 2 ;;
esac

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
APP="$REPO/app"
FILE="env/$FLAVOR.server.json"

if [[ ! -f "$APP/$FILE" ]]; then
  echo "run-against-server: app/$FILE is missing. Make it once:" >&2
  echo "  cp app/env/$FLAVOR.server.example.json app/$FILE" >&2
  [[ "$FLAVOR" == client ]] && echo "  then put your Stripe TEST publishable key (pk_test_...) in it." >&2
  exit 2
fi

# The check prints only the names of settings, never a value.
python3 -I - "$APP/$FILE" "$FLAVOR" <<'PY'
import json, sys
from urllib.parse import urlparse

path, flavor = sys.argv[1], sys.argv[2]
name = f"app/env/{flavor}.server.json"
try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, ValueError):
    sys.exit(f"run-against-server: {name} is not valid JSON.")
if not isinstance(data, dict):
    sys.exit(f"run-against-server: {name} must be one JSON object.")
url = data.get("API_BASE_URL")
host = (urlparse(url).hostname or "") if isinstance(url, str) else ""
if not isinstance(url, str) or not url.startswith("https://") or not host:
    sys.exit(f"run-against-server: API_BASE_URL in {name} must be an https address (the server).")
if host in ("localhost", "127.0.0.1", "10.0.2.2") or host.endswith(".local"):
    sys.exit(f"run-against-server: API_BASE_URL in {name} points at this Mac, not the server.")
if flavor == "client":
    key = data.get("STRIPE_PUBLISHABLE_KEY")
    if not isinstance(key, str) or not key.startswith("pk_test_"):
        sys.exit(f"run-against-server: STRIPE_PUBLISHABLE_KEY in {name} must be a Stripe TEST publishable key (pk_test_...).")
    if "REPLACE" in key:
        sys.exit(f"run-against-server: STRIPE_PUBLISHABLE_KEY in {name} is still the example's placeholder.")
for k, v in data.items():
    if isinstance(v, str) and (v.startswith("pk_live_") or v.startswith("sk_")):
        sys.exit(f"run-against-server: {k} in {name} is a live or secret key; the apps take only the test publishable key.")
PY

cd "$APP"
exec "${FLUTTER:-flutter}" run --flavor "$FLAVOR" -t "lib/main_$FLAVOR.dart" --dart-define-from-file="$FILE" "$@"
