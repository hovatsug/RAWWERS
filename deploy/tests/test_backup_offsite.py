"""backup-offsite.sh: dump, manifest, encrypt, upload, verify, tidy, alarm.

Everything a real run does, against a fake bucket (a local folder), a fake
`curl` for Sentry and the throwaway Postgres; with the real `age`.
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
from pathlib import Path

import pytest

from conftest import IRREPLACEABLE, NO_NETWORK, SCRIPTS, age_bin, mode_of

#: Made-up values; the test checks none of them is ever printed.
SECRET_VALUES = {name: f"test-{name.lower()}-value-{i:02d}" for i, name in enumerate(IRREPLACEABLE)}
R2_SECRET = "test-r2-secret-access-key-not-real"
DSN = "https://publickey0000@o1.ingest.de.sentry.io/4242"


class Offsite:
    def __init__(self, tmp_path: Path, fake_bin: Path, pg, db: str, public_key: str) -> None:
        self.tmp = tmp_path
        self.logs = tmp_path / "logs"
        self.logs.mkdir(exist_ok=True)
        self.bucket_root = tmp_path / "r2"
        self.bucket = self.bucket_root / "rawwers-backups-test"
        self.bucket.mkdir(parents=True)
        self.backups = tmp_path / "backups"
        self.config = tmp_path / "backup.env"
        self.write_config(public_key)
        self.secrets_file = tmp_path / "env.production"
        lines = [f"{k}={v}" for k, v in SECRET_VALUES.items()]
        lines += [f"SENTRY_DSN={DSN}", "IMAGE_TAG=9f45c7fa5593", "STRIPE_SECRET_KEY=sk_test_not_in_the_backup"]
        self.secrets_file.write_text("\n".join(lines) + "\n")
        self.secrets_file.chmod(0o600)
        self.env = {
            **os.environ, **NO_NETWORK, **pg.env(db),
            "PATH": f"{fake_bin}:{pg.bin}:{os.environ['PATH']}",
            "RAWWERS_DC": str(fake_bin / "dc"),
            "FAKE_LOG_DIR": str(self.logs),
            "FAKE_BUCKET_ROOT": str(self.bucket_root),
            "BACKUP_DIR": str(self.backups),
            "BACKUP_CONFIG": str(self.config),
            "RAWWERS_ENV_FILE": str(self.secrets_file),
            "BACKUP_LOCK_DIR": str(tmp_path / "lock"),
            "AGE": str(age_bin()),
        }

    def write_config(self, public_key: str, mode: int = 0o600, **override) -> None:
        values = {
            "BACKUP_R2_ENDPOINT": "https://accountid.eu.r2.cloudflarestorage.com",
            "BACKUP_R2_ACCESS_KEY_ID": "test-access-key-id",
            "BACKUP_R2_SECRET_ACCESS_KEY": R2_SECRET,
            "BACKUP_R2_BUCKET": "rawwers-backups-test",
            "BACKUP_AGE_RECIPIENT": public_key,
            "BACKUP_SENTRY_MONITOR": "rawwers-backup-test",
            **override,
        }
        self.config.write_text("".join(f"{k}={v}\n" for k, v in values.items() if v is not None))
        self.config.chmod(mode)

    def run(self, *args: str, **extra) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["bash", str(SCRIPTS / "backup-offsite.sh"), *args],
            capture_output=True, text=True, env={**self.env, **extra}, timeout=180,
        )

    def uploaded(self) -> list[str]:
        return sorted(str(p.relative_to(self.bucket)) for p in self.bucket.rglob("*") if p.is_file())

    def log(self, name: str) -> str:
        path = self.logs / name
        return path.read_text() if path.exists() else ""


@pytest.fixture()
def offsite(tmp_path, fake_bin, pg, small_db, age_key) -> Offsite:
    return Offsite(tmp_path, fake_bin, pg, small_db, age_key[1])


def _decrypt(path: Path, key: Path) -> bytes:
    return subprocess.run([str(age_bin()), "-d", "-i", str(key), str(path)], check=True, capture_output=True).stdout


def _assert_no_secret_printed(done: subprocess.CompletedProcess, offsite: Offsite) -> None:
    seen = done.stdout + done.stderr + offsite.log("rclone.log") + offsite.log("curl.log") + offsite.log("dc.log")
    for value in [*SECRET_VALUES.values(), R2_SECRET, "sk_test_not_in_the_backup"]:
        assert value not in seen


def test_a_daily_run_uploads_verifies_and_tidies(offsite, age_key, pg, small_db):
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 0, done.stdout + done.stderr
    base = "daily/2026/11/rawwers-20261126T033000Z"
    assert offsite.uploaded() == [f"{base}.dump.age", f"{base}.manifest.json", f"{base}.secrets.age"]
    assert "uploaded and verified" in done.stdout

    manifest = json.loads((offsite.bucket / f"{base}.manifest.json").read_text())
    assert manifest["label"] == "daily" and manifest["stamp"] == "20261126T033000Z"
    assert manifest["alembic_version"] == "20261114_0098"
    assert manifest["image_tag"] == "9f45c7fa5593"
    assert len(manifest["checkout_commit"]) == 40
    assert manifest["row_counts"]["user_account"] == 7 and manifest["row_counts"]["stripe_payment"] == 3
    assert manifest["tables"] == len(manifest["row_counts"])
    # The secrets file: names in the manifest, values only inside the encrypted file.
    assert manifest["secrets"]["names"] == IRREPLACEABLE and manifest["secrets"]["missing"] == []
    assert not any(v in json.dumps(manifest) for v in SECRET_VALUES.values())
    secrets = _decrypt(offsite.bucket / f"{base}.secrets.age", age_key[0]).decode()
    assert secrets.splitlines() == [f"{k}={v}" for k, v in SECRET_VALUES.items()]
    assert "STRIPE_SECRET_KEY" not in secrets and "SENTRY_DSN" not in secrets

    # The encrypted dump is what the manifest says, and restores.
    dump = _decrypt(offsite.bucket / f"{base}.dump.age", age_key[0])
    assert len(dump) == manifest["dump"]["plain_bytes"]
    assert hashlib.sha256(dump).hexdigest() == manifest["dump"]["plain_sha256"]
    enc = (offsite.bucket / f"{base}.dump.age").read_bytes()
    assert hashlib.sha256(enc).hexdigest() == manifest["dump"]["sha256"] and len(enc) == manifest["dump"]["bytes"]
    assert dump.startswith(b"PGDMP"), "the decrypted file is a pg_dump archive"
    assert not enc.startswith(b"PGDMP"), "the uploaded dump is encrypted"

    # On the server: the plain dump and its counts stay, nothing encrypted is left behind.
    left = sorted(p.name for p in offsite.backups.iterdir())
    assert left == ["rawwers-20261126T033000Z.dump", "rawwers-20261126T033000Z.dump.counts"], left

    # rclone was given the bucket through its environment, never on its command line.
    rlog = offsite.log("rclone.log")
    assert "provider=Cloudflare" in rlog and "nocheck=true" in rlog and "keyset=yes" in rlog
    _assert_no_secret_printed(done, offsite)


def test_the_sentry_check_in_creates_the_monitor_and_reports_ok(offsite):
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 0, done.stderr
    calls = offsite.log("curl.log").splitlines()
    assert len(calls) == 2, calls
    first, last = calls
    assert "https://o1.ingest.de.sentry.io/api/4242/cron/rawwers-backup-test/publickey0000/" in first
    assert '"status": "in_progress"' in first and '"monitor_config"' in first
    for part in ('"value": "30 3 * * *"', '"checkin_margin": 120', '"max_runtime": 30', '"timezone": "UTC"'):
        assert part in first, part
    assert "status=ok" in last
    check_in_id = first.split("check_in_id=")[1].split("&")[0].split()[0]
    assert f"check_in_id={check_in_id}" in last


@pytest.mark.parametrize("label", ["intraday", "predeploy"])
def test_other_labels_use_their_own_folder_and_no_alarm(offsite, label):
    done = offsite.run("--label", label, BACKUP_STAMP="20261126T153000Z")
    assert done.returncode == 0, done.stderr
    assert all(name.startswith(f"{label}/2026/11/") for name in offsite.uploaded())
    assert len(offsite.uploaded()) == 3
    assert offsite.log("curl.log") == ""


def test_the_first_daily_of_a_month_is_also_kept_as_the_monthly(offsite):
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261201T033000Z")
    assert done.returncode == 0, done.stderr
    names = offsite.uploaded()
    assert len(names) == 6
    for ext in ("dump.age", "secrets.age", "manifest.json"):
        assert f"daily/2026/12/rawwers-20261201T033000Z.{ext}" in names
        assert f"monthly/2026/12/rawwers-20261201T033000Z.{ext}" in names


def test_only_the_newest_two_plain_dumps_stay(offsite):
    for day in ("23", "24", "25", "26"):
        done = offsite.run("--label", "daily", BACKUP_STAMP=f"202611{day}T033000Z")
        assert done.returncode == 0, done.stderr
    left = sorted(p.name for p in offsite.backups.glob("*.dump"))
    assert left == ["rawwers-20261125T033000Z.dump", "rawwers-20261126T033000Z.dump"], left


def test_a_copy_that_arrives_different_fails_and_keeps_the_local_dumps(offsite):
    for day in ("24", "25"):
        assert offsite.run("--label", "daily", BACKUP_STAMP=f"202611{day}T033000Z").returncode == 0
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z", FAKE_RCLONE_CORRUPT="1")
    assert done.returncode == 7, done.stdout + done.stderr
    assert "verify" in done.stderr.lower()
    # Nothing pruned after a failed verification: three plain dumps remain.
    assert len(list(offsite.backups.glob("*.dump"))) == 3
    assert "status=error" in offsite.log("curl.log").splitlines()[-1]


def test_an_upload_failure_fails_and_alarms(offsite):
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z", FAKE_RCLONE_FAIL_UPLOAD="1")
    assert done.returncode == 6, done.stdout + done.stderr
    assert "status=error" in offsite.log("curl.log").splitlines()[-1]
    assert not list(offsite.backups.glob("*.age"))


def test_a_dry_run_uploads_nothing_and_leaves_nothing(offsite):
    done = offsite.run("--label", "daily", "--dry-run", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 0, done.stdout + done.stderr
    assert "DRY RUN" in done.stdout
    assert "daily/2026/11/rawwers-20261126T033000Z.dump.age" in done.stdout
    assert offsite.uploaded() == []
    assert offsite.log("curl.log") == ""
    assert not offsite.backups.exists() or not any(offsite.backups.iterdir())
    _assert_no_secret_printed(done, offsite)


def test_check_bucket_reaches_the_bucket_with_either_provider(offsite, age_key):
    (offsite.bucket / "daily").mkdir()
    done = offsite.run("--check-bucket")
    assert done.returncode == 0, done.stderr
    assert "bucket reachable" in done.stdout and "Cloudflare" in done.stdout
    offsite.write_config(age_key[1], BACKUP_RCLONE_PROVIDER="Other")
    done = offsite.run("--check-bucket")
    assert done.returncode == 0, done.stderr
    assert "provider=Other endpoint=https://accountid.eu.r2.cloudflarestorage.com" in offsite.log("rclone.log")
    assert offsite.log("curl.log") == ""


def test_the_config_file_must_be_private_and_complete(offsite, age_key):
    offsite.write_config(age_key[1], mode=0o644)
    done = offsite.run("--label", "daily")
    assert done.returncode == 2 and "600" in done.stderr
    offsite.write_config(age_key[1], BACKUP_R2_BUCKET=None)
    done = offsite.run("--label", "daily")
    assert done.returncode == 2 and "BACKUP_R2_BUCKET" in done.stderr
    offsite.write_config(age_key[1], BACKUP_AGE_RECIPIENT="AGE-SECRET-KEY-1NOTAPUBLICKEY")
    done = offsite.run("--label", "daily")
    assert done.returncode == 2 and "public key" in done.stderr
    assert "AGE-SECRET-KEY-1NOTAPUBLICKEY" not in done.stderr
    assert offsite.uploaded() == []


def test_a_wrong_label_is_refused(offsite):
    done = offsite.run("--label", "weekly")
    assert done.returncode == 2


def test_a_second_run_while_one_is_going_waits_its_turn(offsite):
    lock = Path(offsite.env["BACKUP_LOCK_DIR"])
    lock.mkdir()
    (lock / "pid").write_text(str(os.getpid()))  # a live process holds it
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 3 and "already running" in done.stderr
    (lock / "pid").write_text("999999")  # a dead one: taken over
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 0, done.stderr


def test_without_a_sentry_monitor_it_still_backs_up_but_says_so(offsite, age_key):
    offsite.write_config(age_key[1], BACKUP_SENTRY_MONITOR=None)
    done = offsite.run("--label", "daily", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 0, done.stderr
    assert "no alarm" in done.stderr.lower()
    assert offsite.log("curl.log") == ""


def test_a_missing_irreplaceable_secret_is_named_not_fatal(offsite):
    text = offsite.secrets_file.read_text().replace("RISK_SESSION_HASH_PEPPER=", "#RISK_SESSION_HASH_PEPPER=")
    offsite.secrets_file.write_text(text)
    done = offsite.run("--label", "predeploy", BACKUP_STAMP="20261126T033000Z")
    assert done.returncode == 0, done.stderr
    assert "RISK_SESSION_HASH_PEPPER" in done.stderr
    manifest = json.loads(next(offsite.bucket.rglob("*.manifest.json")).read_text())
    assert manifest["secrets"]["missing"] == ["RISK_SESSION_HASH_PEPPER"]
    assert "RISK_SESSION_HASH_PEPPER" not in manifest["secrets"]["names"]
    assert mode_of(offsite.config) == 0o600
