#!/usr/bin/env bash
# check-email-dns.sh: are the email DNS records of a domain in place? Read-only.
#
#   deploy/scripts/check-email-dns.sh                  # rawwers.com
#   deploy/scripts/check-email-dns.sh rawwers.com
#
# Asks public DNS (dig) for: MX, SPF (and every include inside it), DKIM for
# Zoho (selector zmail) and Brevo (brevo1, brevo2), and DMARC. Then says in
# plain words what is missing or wrong. Needs `dig` (macOS has it; Ubuntu:
# apt-get install dnsutils). Exit 0: nothing wrong found. Exit 1: problems.
set -uo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,10p' "$0"; exit 0; fi
DOMAIN="${1:-rawwers.com}"
DIG="${DIG:-dig}"
RESOLVER="${RESOLVER:-1.1.1.1}"
problems=()
q() { $DIG +short "@$RESOLVER" "$1" "$2" 2>/dev/null; }
txt() { q "$1" TXT | sed 's/" "//g; s/^"//; s/"$//'; }

echo "== MX ($DOMAIN)"
mx=$(q "$DOMAIN" MX)
echo "${mx:-<none>}"
[[ -z "$mx" ]] && problems+=("No MX record: nobody can email support@$DOMAIN.")
echo "$mx" | grep -qi zoho || problems+=("MX does not point to Zoho (expected for the support mailbox).")

echo; echo "== SPF ($DOMAIN)"
spf=$(txt "$DOMAIN" | grep -i '^v=spf1' || true)
echo "${spf:-<none>}"
count=$(printf '%s\n' "$spf" | grep -ci '^v=spf1' || true)
[[ "$count" -eq 0 ]] && problems+=("No SPF record (v=spf1) on $DOMAIN.")
[[ "$count" -gt 1 ]] && problems+=("$count SPF records on $DOMAIN: there must be exactly one, or SPF fails for everyone.")
lookups=0
follow() {  # print nested includes, count DNS lookups (the limit is 10)
  local name="$1" depth="$2" rec inc
  rec=$(txt "$name" | grep -i '^v=spf1' | head -1)
  printf '%*s%s: %s\n' $((depth * 2)) '' "$name" "${rec:-<no SPF record>}"
  [[ -z "$rec" ]] && { problems+=("The SPF include $name has no SPF record of its own."); return; }
  for inc in $(echo "$rec" | grep -oiE '(include:|redirect=)[^ ]+' | sed -E 's/^(include:|redirect=)//I'); do
    lookups=$((lookups + 1))
    [[ $depth -lt 4 ]] && follow "$inc" $((depth + 1))
  done
  lookups=$((lookups + $(echo "$rec" | grep -oiE '(^| )(a|mx|ptr|exists:)[^ ]*' | wc -l)))
}
if [[ -n "$spf" ]]; then
  echo "includes, followed:"
  follow "$DOMAIN" 1
  echo "DNS lookups counted: $lookups (SPF allows 10)"
  [[ $lookups -gt 10 ]] && problems+=("SPF needs $lookups DNS lookups; over 10 makes SPF fail (permerror).")
  all_includes=$(for n in $(echo "$spf" | grep -oiE 'include:[^ ]+' | cut -d: -f2); do txt "$n"; done)
  echo "$spf $all_includes" | grep -qi 'zoho' || problems+=("SPF does not (visibly) include Zoho (include:zohomail.eu). Zoho mail then passes DMARC by DKIM only.")
  echo "$spf $all_includes" | grep -qiE 'brevo|sendinblue|spf\.brevo\.com' || problems+=("SPF does not include Brevo (include:spf.brevo.com). Brevo mail then passes DMARC by DKIM only - fine if DKIM passes.")
fi

echo; echo "== DKIM"
for sel in zmail brevo1 brevo2; do
  name="$sel._domainkey.$DOMAIN"
  cname=$(q "$name" CNAME)
  rec=$(txt "$name")
  printf '%-28s %s\n' "$sel" "${cname:+CNAME $cname }${rec:0:60}${rec:+...}"
  [[ -z "$cname$rec" ]] && problems+=("No DKIM record at $name.")
  if [[ -n "$rec" && "$rec" != *"p="* ]]; then problems+=("The DKIM record at $name has no public key (p=).") ; fi
done

echo; echo "== DMARC"
dmarc=$(txt "_dmarc.$DOMAIN")
echo "${dmarc:-<none>}"
if [[ -z "$dmarc" ]]; then
  problems+=("No DMARC record at _dmarc.$DOMAIN.")
else
  echo "$dmarc" | grep -qiE 'p=(quarantine|reject)' || problems+=("DMARC policy is none (p=none): it reports but protects nothing. Fine while testing.")
  rua=$(echo "$dmarc" | grep -oiE 'rua=[^;]+' || true)
  [[ -z "$rua" ]] && echo "(no rua: no aggregate reports are sent anywhere)"
  [[ -n "$rua" ]] && echo "reports go to: ${rua#rua=}  <- make sure someone reads this mailbox (LATER row)"
fi

echo
if [[ ${#problems[@]} -eq 0 ]]; then
  echo "Nothing wrong found. Prove it with a real email (runbook: 'Mail test')."
  exit 0
fi
echo "Found ${#problems[@]} thing(s) to look at:"
for p in "${problems[@]}"; do echo "  - $p"; done
echo "DNS lookups only show what is published; a real email to Gmail ('Show original') is the proof."
exit 1
