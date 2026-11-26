#!/usr/bin/env bash
# install-backup-timer.sh: run backup-offsite.sh every night from the host.
#
#   deploy/scripts/install-backup-timer.sh                  # install; nightly at 03:30 UTC
#   deploy/scripts/install-backup-timer.sh --intraday on    # also 09:30, 15:30, 21:30 UTC (every 6 hours)
#   deploy/scripts/install-backup-timer.sh --intraday off
#   deploy/scripts/install-backup-timer.sh --uninstall
#
# Copies the units in deploy/systemd/ to /etc/systemd/system and starts the
# nightly timer. Systemd runs it, not the app: backups go on while the app is
# down. Before installing it checks the settings file exists and only its
# owner can read it, and that age and rclone are installed; it reaches no
# network. Check afterwards: systemctl list-timers 'rawwers-backup*'
# Logs: journalctl -u 'rawwers-backup@*' --since today
set -euo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then sed -n '2,15p' "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
UNITS_SRC="$HERE/../systemd"
UNIT_DIR="${UNIT_DIR:-/etc/systemd/system}"
CONFIG="${BACKUP_CONFIG:-/opt/rawwers/backup.env}"
SYSTEMCTL="${SYSTEMCTL:-systemctl}"
UNITS=(rawwers-backup@.service rawwers-backup-daily.timer rawwers-backup-intraday.timer)
die() { local code="$1"; shift; echo "install-backup-timer: $*" >&2; exit "$code"; }

ACTION=install
case "${1:-}" in
  "") ;;
  --uninstall) ACTION=uninstall ;;
  --intraday)
    case "${2:-}" in
      on) ACTION=intraday-on ;;
      off) ACTION=intraday-off ;;
      *) die 2 "--intraday takes on or off" ;;
    esac ;;
  *) die 2 "unknown argument $1 (see --help)" ;;
esac
if [[ "$UNIT_DIR" == /etc/systemd/system && "$(id -u)" != 0 ]]; then die 2 "run as root"; fi

case "$ACTION" in
  uninstall)
    "$SYSTEMCTL" disable --now rawwers-backup-daily.timer rawwers-backup-intraday.timer || true
    for unit in "${UNITS[@]}"; do rm -f "$UNIT_DIR/$unit"; done
    "$SYSTEMCTL" daemon-reload
    echo "Removed. Backups no longer run on their own; the bucket keeps what it has."
    exit 0 ;;
  intraday-on)
    [[ -f "$UNIT_DIR/rawwers-backup-intraday.timer" ]] || die 2 "not installed yet: run this script without arguments first"
    "$SYSTEMCTL" enable --now rawwers-backup-intraday.timer
    echo "Every 6 hours now: 03:30 (daily/) and 09:30, 15:30, 21:30 UTC (intraday/)."
    echo "The bucket needs the intraday/ lock and lifecycle rule first (docs/RESTORE_PLAYBOOK.md, 'Every 6 hours')."
    exit 0 ;;
  intraday-off)
    "$SYSTEMCTL" disable --now rawwers-backup-intraday.timer
    echo "Nightly only again (03:30 UTC)."
    exit 0 ;;
esac

# install
[[ -f "$CONFIG" ]] || die 2 "no settings file $CONFIG yet (docs/RESTORE_PLAYBOOK.md, 'Set-up', makes /opt/rawwers/backup.env)"
mode="$(stat -c %a "$CONFIG" 2>/dev/null || stat -f %Lp "$CONFIG")"
[[ "$mode" == 600 || "$mode" == 400 ]] || die 2 "$CONFIG must be readable by its owner only: chmod 600 $CONFIG (it is $mode)"
missing=()
for tool in age rclone; do command -v "$tool" >/dev/null 2>&1 || missing+=("$tool"); done
[[ ${#missing[@]} -eq 0 ]] || die 2 "not installed: ${missing[*]}. First: apt-get update && apt-get install -y age rclone"
for unit in "${UNITS[@]}"; do [[ -f "$UNITS_SRC/$unit" ]] || die 2 "missing $UNITS_SRC/$unit (is this the repository checkout?)"; done

mkdir -p "$UNIT_DIR"
for unit in "${UNITS[@]}"; do
  install -m 644 "$UNITS_SRC/$unit" "$UNIT_DIR/$unit"
done
"$SYSTEMCTL" daemon-reload
"$SYSTEMCTL" enable --now rawwers-backup-daily.timer
echo "Installed. The nightly backup runs at 03:30 UTC."
echo "Check:   systemctl list-timers 'rawwers-backup*'"
echo "Run one now (the same as the night's): systemctl start rawwers-backup@daily && journalctl -u rawwers-backup@daily -n 30 --no-pager"
