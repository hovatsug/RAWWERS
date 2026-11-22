#!/usr/bin/env bash
# version.sh: what is running, after each deploy. Read-only; prints no secret.
#
#   deploy/scripts/version.sh
#
# Shows: the commit of the checkout and the image tag, the running containers
# with their images and health, the database migration (current and newest),
# the switches and feature flags, and how fresh the exchange rates are.
# What to look for is in docs/DEPLOY_RUNBOOK.md, "After every deploy".
set -uo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,9p' "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
DC="$HERE/dc"
ENV_FILE="${RAWWERS_ENV_FILE:-/opt/rawwers/.env.production}"

echo "== commit and images"
echo "checkout commit             $(git -C "$HERE/../.." rev-parse --short HEAD 2>/dev/null || echo '?')"
grep -E '^(IMAGE_TAG|API_IMAGE|WEB_IMAGE)=' "$ENV_FILE" | sed 's/^/secrets file                /'
echo
"$DC" ps --format 'table {{.Service}}\t{{.Image}}\t{{.Status}}'
echo
echo "== migrations"
echo "current: $("$DC" exec -T api alembic current 2>/dev/null | tail -1)"
echo "newest:  $("$DC" exec -T api alembic heads 2>/dev/null | tail -1)"
echo
"$DC" exec -T api python scripts/print_deploy_state.py
