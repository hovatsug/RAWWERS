#!/usr/bin/env bash
# build-and-push.sh: build the two production images on the Mac and push them.
#
#   deploy/scripts/build-and-push.sh <commit or tag> <registry prefix>
#   deploy/scripts/build-and-push.sh deploy-test-1 ghcr.io/<GITHUB_USER>
#   deploy/scripts/build-and-push.sh deploy-test-1 ghcr.io/<GITHUB_USER> --no-push   # build and check only
#
# Builds from a clean copy of that commit (git archive), never from your
# working folder, so nothing that is not committed (api/.env, keys, local
# builds) can reach an image. Always builds for linux/amd64, the Hetzner
# server's processor, whatever the Mac is (an Apple-silicon Mac builds it
# under emulation: slower). Then checks those two exact images with
# check-image.sh (including that they are linux/amd64) and pushes:
#   <prefix>/rawwers-api:<short commit>
#   <prefix>/rawwers-web:<short commit>
# The web image has the API's public address built in (NEXT_PUBLIC_API_BASE_URL,
# default https://api.rawwers.com); set WEB_API_URL to change it.
# Log in first: docker login ghcr.io -u <GITHUB_USER>   (docs/DEPLOY_RUNBOOK.md, "Images")
set -euo pipefail
if [[ $# -lt 2 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,18p' "$0"; [[ $# -lt 2 && "${1:-}" != "-h" && "${1:-}" != "--help" ]] && exit 2 || exit 0; fi
REF="$1"; PREFIX="${2%/}"; PUSH=1; [[ "${3:-}" == "--no-push" ]] && PUSH=0
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$HERE" rev-parse --show-toplevel)"
SHA="$(git -C "$REPO" rev-parse --short=12 "$REF^{commit}")"
WEB_API_URL="${WEB_API_URL:-https://api.rawwers.com}"
PLATFORM="linux/amd64"   # the server; never taken from the environment
API_TAG="$PREFIX/rawwers-api:$SHA"
WEB_TAG="$PREFIX/rawwers-web:$SHA"
WORK="${BUILD_WORK_DIR:-$HOME/Developer/RAWWERS-work/scratch}/image-build-$SHA"

echo "commit $SHA ($REF), platform $PLATFORM"
echo "api -> $API_TAG"
echo "web -> $WEB_TAG (API address built in: $WEB_API_URL)"
rm -rf "$WORK"; mkdir -p "$WORK"
git -C "$REPO" archive "$SHA" api web | tar -x -C "$WORK"
trap 'rm -rf "$WORK"' EXIT

docker buildx build --platform "$PLATFORM" --target runtime -t "$API_TAG" --load "$WORK/api"
docker buildx build --platform "$PLATFORM" -t "$WEB_TAG" --load \
  --build-arg NEXT_PUBLIC_API_BASE_URL="$WEB_API_URL" \
  --build-arg NEXT_PUBLIC_SENTRY_DSN="${WEB_SENTRY_DSN_PUBLIC:-}" \
  --build-arg NEXT_PUBLIC_SENTRY_ENVIRONMENT="${WEB_SENTRY_ENVIRONMENT:-production}" \
  "$WORK/web"

EXPECT_PLATFORM="$PLATFORM" "$HERE/check-image.sh" "$API_TAG" "$WEB_TAG"

if [[ $PUSH -eq 1 ]]; then
  docker push "$API_TAG"
  docker push "$WEB_TAG"
  echo
  echo "Pushed. In the server's secrets file set:"
  echo "  API_IMAGE=$PREFIX/rawwers-api"
  echo "  WEB_IMAGE=$PREFIX/rawwers-web"
  echo "  IMAGE_TAG=$SHA"
else
  echo "Built and checked; not pushed (--no-push)."
fi
