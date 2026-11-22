#!/usr/bin/env bash
# refresh-cloudflare-ips.sh: update the list of Cloudflare's address ranges.
#
#   deploy/scripts/refresh-cloudflare-ips.sh          # on the Mac, in the repository
#
# Downloads https://www.cloudflare.com/ips-v4 and /ips-v6 (public lists, no
# account), rewrites api/app/core/cloudflare_ips.txt and shows what changed.
# Run it once a month, or when Cloudflare announces a change. If something
# changed: commit, build and deploy a new API image, and update the Hetzner
# firewall rules to the same list (docs/DEPLOY_RUNBOOK.md, "Cloudflare ranges").
set -euo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,10p' "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
FILE="$HERE/../../api/app/core/cloudflare_ips.txt"
v4=$(curl -fsS https://www.cloudflare.com/ips-v4)
v6=$(curl -fsS https://www.cloudflare.com/ips-v6)
for range in $v4 $v6; do
  [[ "$range" =~ ^[0-9a-f:.]+/[0-9]+$ ]] || { echo "unexpected line from Cloudflare: $range - nothing changed" >&2; exit 1; }
done
header=$(sed -n '/^#/p' "$FILE" | sed "s/^# Last checked: .*/# Last checked: $(date -u +%Y-%m-%d) (deploy\/scripts\/refresh-cloudflare-ips.sh)./" | grep -v '^# (written from')
new=$(mktemp)
{ echo "$header"; echo "$v4"; echo "$v6"; } > "$new"
if diff <(grep -v '^#' "$FILE") <(grep -v '^#' "$new"); then
  echo "No change: the ranges are the same."
else
  echo "^ the ranges changed (< old, > new)."
fi
mv "$new" "$FILE"
echo "Written: $FILE"
echo "Comma-separated, for the Hetzner firewall:"
grep -v '^#' "$FILE" | paste -sd, -
