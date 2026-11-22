#!/usr/bin/env bash
# generate-secrets.sh: make the server's secrets file. Run it ON THE SERVER.
#
#   sudo deploy/scripts/generate-secrets.sh                 # writes /opt/rawwers/.env.production
#   sudo deploy/scripts/generate-secrets.sh /path/to/file   # somewhere else
#
# Copies deploy/.env.production.example and fills every <GENERATED> value
# with a new random one (openssl). The values you get from a service (Stripe,
# Brevo, R2, Sentry, the registry) stay as <FROM ...> placeholders: put them
# in by hand with `sudo nano /opt/rawwers/.env.production`.
#
# The file is readable by root only (600). It refuses to overwrite an existing
# file, so a second run never replaces your secrets. Nothing is printed.
set -euo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,13p' "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
EXAMPLE="$HERE/../.env.production.example"
TARGET="${1:-/opt/rawwers/.env.production}"
if [[ -e "$TARGET" ]]; then
  echo "generate-secrets: $TARGET already exists; nothing changed. (To start again, move it away first.)" >&2
  exit 2
fi
command -v openssl >/dev/null || { echo "generate-secrets: openssl is needed (apt-get install openssl)" >&2; exit 2; }
umask 077
mkdir -p "$(dirname "$TARGET")"
tmp="$(mktemp "$(dirname "$TARGET")/.env.production.XXXXXX")"
while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    *"<GENERATED_HEX_32>"*)      line="${line//<GENERATED_HEX_32>/$(openssl rand -hex 32)}" ;;
    *"<GENERATED_HEX_24>"*)      line="${line//<GENERATED_HEX_24>/$(openssl rand -hex 24)}" ;;
    *"<GENERATED_FERNET_KEY>"*)  line="${line//<GENERATED_FERNET_KEY>/$(openssl rand -base64 32 | tr '+/' '-_')}" ;;
  esac
  printf '%s\n' "$line" >> "$tmp"
done < "$EXAMPLE"
chmod 600 "$tmp"
mv "$tmp" "$TARGET"
left=$(grep -v '^#' "$TARGET" | grep -c '<FROM' || true)
echo "Written: $TARGET (readable by root only)."
echo "Still to fill in by hand: $left value(s) marked <FROM ...>. List them with:"
echo "  sudo grep -n '^[A-Z].*<FROM' $TARGET"
