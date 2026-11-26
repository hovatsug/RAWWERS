"""install-backup-timer.sh and the systemd units: nightly at 03:30 UTC, the
6-hourly runs ready but off, and refusals before anything is installed."""
from __future__ import annotations

import os
import subprocess
from pathlib import Path

import pytest

from conftest import NO_NETWORK, SCRIPTS, SYSTEMD, executable

UNITS = ["rawwers-backup@.service", "rawwers-backup-daily.timer", "rawwers-backup-intraday.timer"]


@pytest.fixture()
def setup(tmp_path, fake_bin):
    logs = tmp_path / "logs"
    logs.mkdir()
    unit_dir = tmp_path / "units"
    config = tmp_path / "backup.env"
    config.write_text("BACKUP_R2_BUCKET=rawwers-backups-test\n")
    config.chmod(0o600)
    executable(fake_bin / "age", "#!/usr/bin/env bash\necho v1.1.1\n")
    env = {
        **os.environ, **NO_NETWORK,
        "PATH": f"{fake_bin}:{os.environ['PATH']}",
        "FAKE_LOG_DIR": str(logs),
        "UNIT_DIR": str(unit_dir),
        "BACKUP_CONFIG": str(config),
        "SYSTEMCTL": str(fake_bin / "systemctl"),
    }
    return env, unit_dir, config, logs


def _run(env: dict, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["bash", str(SCRIPTS / "install-backup-timer.sh"), *args], capture_output=True, text=True, env=env, timeout=60)


def _calls(logs: Path) -> list[str]:
    path = logs / "systemctl.log"
    return path.read_text().splitlines() if path.exists() else []


def test_the_units_say_what_the_owner_decided():
    service = (SYSTEMD / "rawwers-backup@.service").read_text()
    assert "ExecStart=/opt/rawwers/src/deploy/scripts/backup-offsite.sh --label %i" in service
    assert "Type=oneshot" in service
    daily = (SYSTEMD / "rawwers-backup-daily.timer").read_text()
    assert "OnCalendar=*-*-* 03:30:00 UTC" in daily and "Unit=rawwers-backup@daily.service" in daily
    assert "Persistent=true" in daily
    intraday = (SYSTEMD / "rawwers-backup-intraday.timer").read_text()
    assert "OnCalendar=*-*-* 09,15,21:30:00 UTC" in intraday and "Unit=rawwers-backup@intraday.service" in intraday


def test_install_puts_the_units_in_place_and_starts_only_the_nightly(setup):
    env, unit_dir, _, logs = setup
    done = _run(env)
    assert done.returncode == 0, done.stderr
    assert sorted(p.name for p in unit_dir.iterdir()) == sorted(UNITS)
    calls = _calls(logs)
    assert "systemctl daemon-reload" in calls
    assert "systemctl enable --now rawwers-backup-daily.timer" in calls
    assert not any("intraday" in c for c in calls)


def test_intraday_on_and_off(setup):
    env, _, _, logs = setup
    assert _run(env).returncode == 0
    assert _run(env, "--intraday", "on").returncode == 0
    assert "systemctl enable --now rawwers-backup-intraday.timer" in _calls(logs)
    assert _run(env, "--intraday", "off").returncode == 0
    assert "systemctl disable --now rawwers-backup-intraday.timer" in _calls(logs)


def test_uninstall_stops_and_removes(setup):
    env, unit_dir, _, logs = setup
    assert _run(env).returncode == 0
    done = _run(env, "--uninstall")
    assert done.returncode == 0, done.stderr
    assert "systemctl disable --now rawwers-backup-daily.timer rawwers-backup-intraday.timer" in _calls(logs)
    assert _calls(logs)[-1] == "systemctl daemon-reload"
    assert list(unit_dir.iterdir()) == []


def test_refuses_a_config_others_can_read(setup):
    env, unit_dir, config, logs = setup
    config.chmod(0o644)
    done = _run(env)
    assert done.returncode == 2 and "600" in done.stderr
    assert not unit_dir.exists() and _calls(logs) == []


def test_refuses_without_the_config_or_the_tools(setup, fake_bin):
    env, unit_dir, config, logs = setup
    config.unlink()
    done = _run(env)
    assert done.returncode == 2 and "backup.env" in done.stderr
    config.write_text("x=1\n")
    config.chmod(0o600)
    (fake_bin / "rclone").unlink()
    done = _run(env)
    assert done.returncode == 2 and "rclone" in done.stderr and "apt-get install" in done.stderr
    assert _calls(logs) == []


def test_a_wrong_option_is_refused(setup):
    env, *_ = setup
    assert _run(env, "--intraday", "maybe").returncode == 2
    assert _run(env, "--sometimes").returncode == 2
