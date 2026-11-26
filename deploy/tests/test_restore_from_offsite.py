"""restore-from-offsite.sh, on the Mac: a backup made by backup-offsite.sh
restores into a throwaway Postgres and matches its manifest - or it says FAIL.

The "bucket" is a local folder (--from-dir); the real one is reached the same
way with boto3, which these tests never do.
"""
from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

import pytest

from conftest import NO_NETWORK, SCRIPTS, age_bin
from test_backup_offsite import R2_SECRET, SECRET_VALUES, Offsite


@pytest.fixture()
def made(tmp_path, fake_bin, pg, small_db, age_key):
    offsite = Offsite(tmp_path, fake_bin, pg, small_db, age_key[1])
    for stamp in ("20261125T033000Z", "20261126T033000Z"):
        done = offsite.run("--label", "daily", BACKUP_STAMP=stamp)
        assert done.returncode == 0, done.stderr
    done = offsite.run("--label", "predeploy", BACKUP_STAMP="20261126T120000Z")
    assert done.returncode == 0, done.stderr
    work = tmp_path / "mac-tmp"
    work.mkdir()
    env = {**os.environ, **NO_NETWORK, "TMPDIR": str(work), "AGE": str(age_bin()), "PG_BIN": str(pg.bin)}
    for name in ("BACKUP_R2_ENDPOINT", "BACKUP_R2_ACCESS_KEY_ID", "BACKUP_R2_SECRET_ACCESS_KEY", "BACKUP_R2_BUCKET"):
        env.pop(name, None)
    return offsite, env, work


def _restore(env: dict, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["bash", str(SCRIPTS / "restore-from-offsite.sh"), *args], capture_output=True, text=True, env=env, timeout=300)


def _no_secrets(done: subprocess.CompletedProcess) -> None:
    for value in [*SECRET_VALUES.values(), R2_SECRET]:
        assert value not in done.stdout + done.stderr


def test_list_shows_every_backup_newest_first(made):
    offsite, env, _ = made
    done = _restore(env, "--list", "--from-dir", str(offsite.bucket))
    assert done.returncode == 0, done.stderr
    lines = [l for l in done.stdout.splitlines() if "rawwers-" in l]
    assert [l.split()[0] for l in lines] == [
        "predeploy/2026/11/rawwers-20261126T120000Z",
        "daily/2026/11/rawwers-20261126T033000Z",
        "daily/2026/11/rawwers-20261125T033000Z",
    ], done.stdout


def test_the_newest_restores_and_matches(made, age_key):
    offsite, env, work = made
    keep = offsite.tmp / "offline-copy"
    done = _restore(env, "--key", str(age_key[0]), "--from-dir", str(offsite.bucket), "--keep-encrypted", str(keep))
    assert done.returncode == 0, done.stdout + done.stderr
    out = done.stdout
    assert "predeploy/2026/11/rawwers-20261126T120000Z" in out
    assert "ok    migration 20261114_0098" in out
    assert "ok    rows: user_account 7" in out
    assert "ok    secrets file: 8 names" in out
    assert out.strip().splitlines()[-1].startswith("PASS")
    _no_secrets(done)
    # Everything it made is gone; only the encrypted copy asked for is kept.
    assert list(work.iterdir()) == []
    assert sorted(p.name for p in keep.iterdir()) == [
        "rawwers-20261126T120000Z.dump.age", "rawwers-20261126T120000Z.manifest.json", "rawwers-20261126T120000Z.secrets.age",
    ]


def test_a_named_backup_restores(made, age_key):
    offsite, env, _ = made
    done = _restore(env, "--key", str(age_key[0]), "--from-dir", str(offsite.bucket), "--name", "20261125T033000Z")
    assert done.returncode == 0, done.stdout + done.stderr
    assert "daily/2026/11/rawwers-20261125T033000Z" in done.stdout


def test_a_changed_file_fails_the_checksum(made, age_key):
    offsite, env, work = made
    target = offsite.bucket / "predeploy/2026/11/rawwers-20261126T120000Z.dump.age"
    target.write_bytes(target.read_bytes() + b"x")
    done = _restore(env, "--key", str(age_key[0]), "--from-dir", str(offsite.bucket))
    assert done.returncode == 1
    assert "FAIL" in done.stdout and "sha256" in done.stdout
    assert list(work.iterdir()) == []


def test_a_restore_that_differs_from_the_manifest_fails(made, age_key):
    offsite, env, work = made
    path = offsite.bucket / "predeploy/2026/11/rawwers-20261126T120000Z.manifest.json"
    manifest = json.loads(path.read_text())
    manifest["row_counts"]["user_account"] = 8
    path.write_text(json.dumps(manifest))
    done = _restore(env, "--key", str(age_key[0]), "--from-dir", str(offsite.bucket))
    assert done.returncode == 1
    assert "DIFF  rows: user_account restored 7, manifest 8" in done.stdout
    assert done.stdout.strip().splitlines()[-1].startswith("FAIL")
    assert list(work.iterdir()) == []


def test_the_wrong_key_fails(made, tmp_path):
    offsite, env, work = made
    other = tmp_path / "other-key.txt"
    subprocess.run([str(age_bin().parent / "age-keygen"), "-o", str(other)], check=True, capture_output=True)
    done = _restore(env, "--key", str(other), "--from-dir", str(offsite.bucket))
    assert done.returncode == 1 and "decrypt" in done.stdout.lower()
    assert list(work.iterdir()) == []


def test_without_a_bucket_it_names_the_missing_settings(made, age_key):
    _, env, _ = made
    done = _restore(env, "--key", str(age_key[0]))
    assert done.returncode == 2
    assert "BACKUP_R2_BUCKET" in done.stderr


def test_without_a_key_it_refuses(made):
    offsite, env, _ = made
    done = _restore(env, "--from-dir", str(offsite.bucket))
    assert done.returncode == 2 and "--key" in done.stderr
