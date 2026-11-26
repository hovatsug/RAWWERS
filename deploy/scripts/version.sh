#!/usr/bin/env bash
# version.sh: what is running, after each deploy. Read-only; prints no secret.
#
#   deploy/scripts/version.sh
#
# Shows: the commit of the checkout and the image tag (and whether the
# checkout needs new images: a tag with only scripts and docs does not), the
# running containers
# with their images and health, the database migration (current and newest),
# the switches and feature flags, and how fresh the exchange rates are.
# What to look for is in docs/DEPLOY_RUNBOOK.md, "After every deploy".
set -uo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,11p' "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
DC="${RAWWERS_DC:-$HERE/dc}"
REPO="$HERE/../.."
ENV_FILE="${RAWWERS_ENV_FILE:-/opt/rawwers/.env.production}"

echo "== commit and images"
echo "checkout commit             $(git -C "$HERE/../.." rev-parse --short HEAD 2>/dev/null || echo '?')"
grep -E '^(IMAGE_TAG|API_IMAGE|WEB_IMAGE)=' "$ENV_FILE" | sed 's/^/secrets file                /'
# The images are built from api/ and web/ only (DEPLOY_RUNBOOK step 9): a
# checkout ahead of IMAGE_TAG with neither changed runs on the same images.
images_check() {
  local tag full head n label="images                      "
  tag="$(grep -E '^IMAGE_TAG=' "$ENV_FILE" 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d "\"'\r")"
  if [[ -z "$tag" ]]; then echo "${label}no IMAGE_TAG in the secrets file"; return; fi
  head="$(git -C "$REPO" rev-parse HEAD 2>/dev/null)" || { echo "${label}cannot read the checkout"; return; }
  if ! full="$(git -C "$REPO" rev-parse --verify -q "$tag^{commit}" 2>/dev/null)"; then
    echo "${label}IMAGE_TAG $tag is not a commit in this checkout (git fetch --tags, or a typing mistake)"; return
  fi
  if [[ "$full" == "$head" ]]; then
    echo "${label}same commit as the checkout"
  elif git -C "$REPO" merge-base --is-ancestor "$head" "$full"; then
    echo "${label}checkout is BEHIND IMAGE_TAG: check out the tag you meant"
  else
    n="$(git -C "$REPO" rev-list --count "$full..$head")"
    if git -C "$REPO" diff --quiet "$full" "$head" -- api web; then
      echo "${label}checkout is $n commits after IMAGE_TAG; api/ and web/ unchanged since: no rebuild needed"
    else
      echo "${label}checkout is $n commits after IMAGE_TAG; api/ or web/ CHANGED since IMAGE_TAG: build and push new images (DEPLOY_RUNBOOK step 9)"
    fi
  fi
}
images_check
echo
"$DC" ps --format 'table {{.Service}}\t{{.Image}}\t{{.Status}}'
echo
echo "== migrations"
echo "current: $("$DC" exec -T api alembic current 2>/dev/null | tail -1)"
echo "newest:  $("$DC" exec -T api alembic heads 2>/dev/null | tail -1)"
echo
"$DC" exec -T api python scripts/print_deploy_state.py
