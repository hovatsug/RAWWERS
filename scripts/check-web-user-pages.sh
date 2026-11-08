#!/usr/bin/env bash
# No user-facing web page shows a client's ledger or point numbers
# (owner's decision, 2026-11-08: the web is the admin panel and the landing
# page; credit lives in the app, in euros).
#
# Fails when a non-admin page or component:
#   - calls the rewards ledger or balance endpoints (/rewards/..., /me/rewards/...);
#   - renders a ledger_summary (it must be left out of any JSON shown);
#   - says RAWW, RAWWs or points in its text.
# And when /rewards stops redirecting to /get-the-app.
#
# bash with an explicit array, for the reason in check-admin-isolation.sh.
set -euo pipefail

cd "$(dirname "$0")/../web"

ENDPOINTS='/(me/)?rewards/(balance|ledger|spend)'
WORDS='\b(RAWW|RAWWs|points?)\b'
# Comment lines may name them (this rule is written down in some).
COMMENT='^[0-9]+:[[:space:]]*(//|\*|/\*|\{/\*)'

user_files=()
while IFS= read -r line; do user_files+=("$line"); done < <(
  find app components -name '*.tsx' -o -name '*.ts' \
    | grep -v '^app/admin/' \
    | grep -v '^app/api/admin/' \
    | sort
)

violations=0
report() { echo "  VIOLATION  $1: $2"; violations=$((violations + 1)); }
for file in "${user_files[@]}"; do
  grep -nEq "$ENDPOINTS" "$file" && report "$file" "calls the rewards ledger or balance"
  # ledger_summary may appear only where it is being left out.
  if grep -n 'ledger_summary' "$file" | grep -vq 'key === "ledger_summary" ? undefined'; then
    report "$file" "shows a ledger_summary"
  fi
  if grep -nE "$WORDS" "$file" | grep -vEq "$COMMENT"; then report "$file" "says RAWW or points"; fi
done
for file in lib/api/clientApi.ts lib/api/auth.ts; do
  grep -nEq "$ENDPOINTS" "$file" && report "$file" "has a client for the rewards ledger or balance"
done

grep -q 'source: "/rewards", destination: "/get-the-app"' next.config.mjs || report next.config.mjs "no longer redirects /rewards to /get-the-app"
[ -e app/rewards ] && report app/rewards "is back: /rewards must only redirect to the app"
[ -f app/get-the-app/page.tsx ] || report app/get-the-app/page.tsx "is missing"

# The patterns must be able to fail: confirm each still sees the real thing.
probe_ok=1
echo 'get<any>("/me/rewards/balance")' | grep -Eq "$ENDPOINTS" || probe_ok=0
echo '<p>You have 500 points</p>' | grep -Eq "$WORDS" || probe_ok=0
echo '12: // RAWW is the pro credit' | grep -Eq "$COMMENT" || probe_ok=0
echo '<span>12 RAWW</span>' | grep -Eq "$WORDS" || probe_ok=0
if [ "$probe_ok" -eq 0 ]; then
  echo "FAIL: a pattern no longer matches its known example, so a pass here means nothing."
  exit 2
fi

if [ "$violations" -gt 0 ]; then
  echo "FAIL: $violations user-facing problem(s)."
  exit 1
fi
echo "OK: ${#user_files[@]} user-facing files checked: no ledger, no point numbers, /rewards sends people to the app."
