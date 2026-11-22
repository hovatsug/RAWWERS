#!/usr/bin/env bash
# server-baseline.sh: what the server looks like. Read-only: it changes nothing.
#
# Run it right after rebuilding the server (runbook step 0) and paste the
# whole output back to the developer. Nothing secret is printed (no keys, no
# environment, no file contents).
#
#   bash server-baseline.sh
set -uo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,8p' "$0"; exit 0; fi
section() { printf '\n== %s\n' "$1"; }

section "system"
. /etc/os-release 2>/dev/null && echo "os: $PRETTY_NAME"
echo "kernel: $(uname -r)  arch: $(uname -m)"
echo "cpus: $(nproc)"
echo "uptime: $(uptime -p 2>/dev/null || uptime)"
echo "timezone: $(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null)"
echo "clock synchronised: $(timedatectl show -p NTPSynchronized --value 2>/dev/null || echo '?')"

section "memory and swap"
free -h
swapon --show 2>/dev/null || true

section "disk"
df -h -x tmpfs -x devtmpfs -x overlay 2>/dev/null || df -h

section "listening ports (what answers on this server)"
ss -tulpn 2>/dev/null | sed 's/users:.*//' || netstat -tuln

section "ports 80 and 443"
for port in 80 443; do
  if ss -tln "( sport = :$port )" 2>/dev/null | grep -q LISTEN; then
    echo "port $port: something is LISTENING (it must be nothing before the first start)"
  else
    echo "port $port: free"
  fi
done

section "docker"
if command -v docker >/dev/null 2>&1; then
  docker --version
  docker compose version 2>/dev/null || echo "docker compose: missing"
  echo "containers: $(docker ps -aq 2>/dev/null | wc -l)  images: $(docker images -q 2>/dev/null | wc -l)  volumes: $(docker volume ls -q 2>/dev/null | wc -l)"
else
  echo "docker: not installed"
fi

section "old setup"
[[ -d /opt/caddy ]] && echo "/opt/caddy EXISTS (the old Caddy; runbook step 0 says what to do)" || echo "/opt/caddy: not there (good)"
ls -d /opt/* 2>/dev/null | sed 's/^/in \/opt: /' || true

section "ssh"
sshd -T 2>/dev/null | grep -Ei '^(passwordauthentication|permitrootlogin|pubkeyauthentication|port) ' || echo "(run as root to see the ssh settings)"

section "security updates and firewall"
systemctl is-enabled unattended-upgrades 2>/dev/null | sed 's/^/unattended-upgrades: /' || echo "unattended-upgrades: not installed"
systemctl is-active fail2ban 2>/dev/null | sed 's/^/fail2ban: /' || echo "fail2ban: not installed"
ufw status 2>/dev/null | head -1 || echo "ufw: not installed"
echo
echo "Done. Nothing was changed."
