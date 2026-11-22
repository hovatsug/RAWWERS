#!/usr/bin/env bash
# check-image.sh: is a built image safe to push? Read-only.
#
#   deploy/scripts/check-image.sh <image:tag> [<image:tag> ...]
#
# For each image: it must be built for the server's processor (linux/amd64;
# EXPECT_PLATFORM changes that); it must not run as root; it must hold no .env file, no
# private key and nothing that looks like a live secret (Stripe, Brevo,
# private-key blocks); and it prints its size. build-and-push.sh runs it
# before every push. Exit 0: all clean. Exit 1: something found (listed).
set -uo pipefail
if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,10p' "$0"; [[ $# -eq 0 ]] && exit 2 || exit 0; fi
status=0
for image in "$@"; do
  echo "== $image"
  user=$(docker image inspect -f '{{.Config.User}}' "$image" 2>/dev/null) || { echo "FAIL  no such image"; status=1; continue; }
  platform=$(docker image inspect -f '{{.Os}}/{{.Architecture}}' "$image")
  if [[ "$platform" != "${EXPECT_PLATFORM:-linux/amd64}" ]]; then
    echo "FAIL  built for $platform, the server needs ${EXPECT_PLATFORM:-linux/amd64} (it would stop with 'exec format error')"; status=1
  else
    echo "ok    built for $platform"
  fi
  if [[ -z "$user" || "$user" == "root" || "$user" == "0" || "$user" == 0:* ]]; then
    echo "FAIL  runs as root (Config.User='${user}')"; status=1
  else
    echo "ok    runs as user $user"
  fi
  size=$(docker image inspect -f '{{.Size}}' "$image")
  echo "      size $((size / 1024 / 1024)) MB"
  # Files that must never be there. Library CA bundles (certifi, /etc/ssl)
  # and node_modules test fixtures are not secrets and are skipped.
  found=$(docker run --rm --user 0 --entrypoint sh "$image" -c '
    find / -xdev \( -path /proc -o -path /sys -o -path /usr/share -o -path /etc/ssl -o -path "*/site-packages" -o -path "*/node_modules" -o -path /usr/lib -o -path /usr/local/lib \) -prune -o \
      -type f \( -name ".env" -o -name ".env.*" -o -name "*.pem" -o -name "*.key" -o -name "*.p12" -o -name "id_rsa*" -o -name "id_ed25519*" \) -print 2>/dev/null
  ' 2>/dev/null | grep -v '\.env\.example$')
  if [[ -n "$found" ]]; then
    echo "FAIL  secret-looking files:"; echo "$found" | sed 's/^/        /'; status=1
  else
    echo "ok    no .env, key or certificate files"
  fi
  # Contents that look like real secrets, in the app's own folder.
  hits=$(docker run --rm --user 0 --entrypoint sh "$image" -c '
    grep -rIlE "sk_live_[0-9A-Za-z]{10,}|rk_live_[0-9A-Za-z]{10,}|xkeysib-[0-9a-f]{20,}|whsec_[0-9A-Za-z]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----" /app --exclude-dir=node_modules 2>/dev/null
  ' 2>/dev/null)
  if [[ -n "$hits" ]]; then
    echo "FAIL  files under /app that contain secret-looking values:"; echo "$hits" | sed 's/^/        /'; status=1
  else
    echo "ok    no secret-looking values under /app"
  fi
done
exit $status
