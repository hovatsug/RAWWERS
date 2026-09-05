#!/usr/bin/env bash
set -euo pipefail

current_ref="${GITHUB_REF_NAME:-$(git rev-parse --short HEAD)}"
last_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"

printf "# Release Notes\n\n"
printf "Generated: %s\n\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
printf "Version: %s\n\n" "$current_ref"

if [[ -n "$last_tag" ]]; then
  printf "Changes since %s:\n\n" "$last_tag"
  git log --pretty=format:'- %s (%h)' "$last_tag"..HEAD
else
  printf "Changes:\n\n"
  git log --pretty=format:'- %s (%h)' -n 50
fi
printf "\n"
