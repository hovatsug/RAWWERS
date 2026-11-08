#!/usr/bin/env bash
# The web is the admin panel and the landing page (owner's decisions,
# 2026-11-08). Bookings, galleries, credit and every pro tool are in the
# apps. This check keeps it that way. It fails when:
#
#   - app/ holds a page outside the kept list (a removed page came back,
#     or a new user-facing page appeared without being added here);
#   - a removed route stops redirecting to /get-the-app (next.config.mjs,
#     REMOVED_PAGES must be exactly the list below);
#   - a user-facing page or component renders raw JSON (JSON.stringify
#     outside a request body or session storage);
#   - one calls the rewards ledger, balance or spend endpoints, or the
#     client helpers for them come back;
#   - one says RAWW, RAWWs or points outside a comment.
#
# bash with an explicit array, for the reason in check-admin-isolation.sh.
set -euo pipefail

cd "$(dirname "$0")/../web"

# What the web keeps: the landing (app/page.tsx), the admin, and these.
KEPT=(admin api get-the-app login register reset-password share unsubscribe verify-email waitlist)
# Every route removed on 2026-11-08, each with everything under it.
REMOVED=(/bookings /chat /client /discover /disputes /gigs /notifications /pro /pros /rewards /search /settings)

ENDPOINTS='/(me/)?rewards/(balance|ledger|spend)'
WORDS='\b(RAWW|RAWWs|points?)\b'
# Comment lines may name them (this rule is written down in some).
COMMENT='^[0-9]+:[[:space:]]*(//|\*|/\*|\{/\*)'
RAW_JSON='JSON\.stringify\('
# A request body or the session in storage is not something shown.
RAW_JSON_OK='body: JSON\.stringify\(|setItem\('

violations=0
report() { echo "  VIOLATION  $1: $2"; violations=$((violations + 1)); }

# 1. Pages: only the kept ones.
while IFS= read -r dir; do
  name="${dir#app/}"
  keep=0
  for k in "${KEPT[@]}"; do [ "$name" = "$k" ] && keep=1; done
  [ "$keep" -eq 1 ] || report "$dir" "is not a kept page (removed pages go to /get-the-app; a new one must be added to KEPT here)"
done < <(find app -mindepth 1 -maxdepth 1 -type d | sort)
for route in "${REMOVED[@]}"; do
  [ -e "app${route}" ] && report "app${route}" "a removed page is back"
done
# app/api holds only the admin proxy.
while IFS= read -r dir; do
  [ "$dir" = "app/api/admin" ] || report "$dir" "app/api holds only the admin proxy"
done < <(find app/api -mindepth 1 -maxdepth 1 -type d | sort)

# 2. Redirects: next.config.mjs's REMOVED_PAGES is exactly REMOVED, and each
# goes to /get-the-app with everything under it.
configured=$(awk '/^export const REMOVED_PAGES = \[/{on=1; next} on && /^\];/{on=0} on' next.config.mjs | tr -d ' ",' | grep -v '^$' | sort)
expected=$(printf '%s\n' "${REMOVED[@]}" | sort)
[ "$configured" = "$expected" ] || report next.config.mjs "REMOVED_PAGES is not the removed list: $(echo $configured)"
grep -q 'source: base, destination: "/get-the-app"' next.config.mjs || report next.config.mjs "the removed routes no longer redirect to /get-the-app"
grep -q 'source: `${base}/:path\*`, destination: "/get-the-app"' next.config.mjs || report next.config.mjs "pages under a removed route no longer redirect"
[ -f app/get-the-app/page.tsx ] || report app/get-the-app/page.tsx "is missing"

# 3. What user-facing pages and components show.
user_files=()
while IFS= read -r line; do user_files+=("$line"); done < <(
  find app components -name '*.tsx' -o -name '*.ts' \
    | grep -v '^app/admin/' \
    | grep -v '^app/api/admin/' \
    | sort
)
for file in "${user_files[@]}"; do
  grep -nEq "$ENDPOINTS" "$file" && report "$file" "calls the rewards ledger or balance"
  if grep -n 'ledger_summary' "$file" | grep -vq 'key === "ledger_summary" ? undefined'; then
    report "$file" "shows a ledger_summary"
  fi
  if grep -nE "$WORDS" "$file" | grep -vEq "$COMMENT"; then report "$file" "says RAWW or points"; fi
  if grep -nE "$RAW_JSON" "$file" | grep -vE "$RAW_JSON_OK" | grep -vEq "$COMMENT"; then report "$file" "renders raw JSON"; fi
done
for file in lib/api/clientApi.ts lib/api/auth.ts; do
  grep -nEq "$ENDPOINTS" "$file" && report "$file" "has a client for the rewards ledger or balance"
done

# The patterns must be able to fail: confirm each still sees the real thing.
probe_ok=1
echo 'get<any>("/me/rewards/balance")' | grep -Eq "$ENDPOINTS" || probe_ok=0
echo '<p>You have 500 points</p>' | grep -Eq "$WORDS" || probe_ok=0
echo '12: // RAWW is the pro credit' | grep -Eq "$COMMENT" || probe_ok=0
echo '<pre>{JSON.stringify(data, null, 2)}</pre>' | grep -E "$RAW_JSON" | grep -vEq "$RAW_JSON_OK" || probe_ok=0
[ -n "$configured" ] || probe_ok=0
if [ "$probe_ok" -eq 0 ]; then
  echo "FAIL: a pattern no longer matches its known example, so a pass here means nothing."
  exit 2
fi

if [ "$violations" -gt 0 ]; then
  echo "FAIL: $violations user-facing problem(s)."
  exit 1
fi
echo "OK: ${#KEPT[@]} kept pages, ${#REMOVED[@]} removed routes redirecting to /get-the-app, ${#user_files[@]} user-facing files with no raw JSON, ledger or point numbers."
