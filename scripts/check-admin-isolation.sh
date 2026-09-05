#!/usr/bin/env bash
# Public pages must not reach the admin surface.
#
# The admin API key lives only in the server-side proxy at
# web/app/api/admin/[...path]/route.ts. A public page importing the admin
# client, or fetching /api/admin/* directly, would put an admin-authorised
# path on a page served to anyone.
#
# Written in bash with an explicit array, not zsh with a bare variable.
# zsh does not word-split unquoted variables, so `for f in $FILES` iterates
# once over the whole string and greps a path that does not exist - which
# reports a confident zero and looks like a pass. That mistake was made
# three times before this script existed.
set -euo pipefail

cd "$(dirname "$0")/../web"

# Matches imports and fetch targets only. An earlier version matched any
# occurrence of "api/admin" and hit a source comment describing this very
# rule, reporting a violation that was prose.
PATTERN='^[[:space:]]*import .*(lib/api/admin|api/admin)|fetch\([[:space:]]*.?/api/admin'

public_files=()
while IFS= read -r line; do public_files+=("$line"); done < <(
  find app components -name '*.tsx' -o -name '*.ts' \
    | grep -v '^app/admin/' \
    | grep -v '^app/api/admin/' \
    | sort
)

violations=0
for file in "${public_files[@]}"; do
  if grep -nEq "$PATTERN" "$file"; then
    echo "  VIOLATION  $file references the admin surface"
    grep -nE "$PATTERN" "$file" | sed 's/^/             /'
    violations=$((violations + 1))
  fi
done

# The check must be able to fail, so confirm it still sees the real thing.
# A pattern that matches nothing anywhere passes vacuously.
admin_hits=0
for file in app/admin/page.tsx app/admin/payouts/page.tsx app/admin/disputes/page.tsx; do
  [ -f "$file" ] || continue
  if grep -nEq "$PATTERN" "$file"; then admin_hits=$((admin_hits + 1)); fi
done

if [ "$admin_hits" -eq 0 ]; then
  echo "FAIL: the pattern matched nothing even in the admin pages, so a pass here means nothing."
  exit 2
fi

if [ "$violations" -gt 0 ]; then
  echo "FAIL: $violations public file(s) reach the admin surface."
  exit 1
fi

echo "OK: ${#public_files[@]} public files checked, none reach the admin surface (pattern verified against $admin_hits admin files)."
