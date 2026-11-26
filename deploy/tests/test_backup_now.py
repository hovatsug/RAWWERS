"""backup-now.sh: the dump, its row counts from the same moment, and what it keeps.

What the off-server backup needs from it (docs/RESTORE_PLAYBOOK.md):
- `--path-only` prints only the new file's path on stdout;
- the row count of every table, from the same snapshot as the dump, in
  `<file>.counts`, so a restore can be compared with the database as it was;
- KEEP sets how many dumps stay (0 keeps every one).
"""
from __future__ import annotations

import os
import subprocess
from pathlib import Path

from conftest import NO_NETWORK, SCRIPTS, mode_of


def _env(tmp_path: Path, fake_bin: Path, pg, db: str, **extra) -> dict:
    logs = tmp_path / "logs"
    logs.mkdir(exist_ok=True)
    return {
        **os.environ, **NO_NETWORK, **pg.env(db),
        "PATH": f"{fake_bin}:{pg.bin}:{os.environ['PATH']}",
        "RAWWERS_DC": str(fake_bin / "dc"),
        "FAKE_LOG_DIR": str(logs),
        "BACKUP_DIR": str(tmp_path / "backups"),
        **extra,
    }


def _run(env: dict, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["bash", str(SCRIPTS / "backup-now.sh"), *args], capture_output=True, text=True, env=env, timeout=120)


def test_path_only_prints_the_path_and_writes_the_counts(tmp_path, fake_bin, pg, small_db):
    done = _run(_env(tmp_path, fake_bin, pg, small_db), "--path-only")
    assert done.returncode == 0, done.stderr
    lines = done.stdout.splitlines()
    assert len(lines) == 1, done.stdout
    dump = Path(lines[0])
    assert dump.parent == tmp_path / "backups" and dump.name.startswith("rawwers-") and dump.suffix == ".dump"
    assert dump.stat().st_size > 1024 and mode_of(dump) == 0o600
    counts = Path(f"{dump}.counts")
    assert mode_of(counts) == 0o600
    text = counts.read_text().splitlines()
    assert "alembic_version|20261114_0098" in text
    assert "table|user_account|7" in text and "table|stripe_payment|3" in text and "table|payout_transfer|0" in text
    # The dump restores into an empty database.
    target = pg.new_database()
    restored = subprocess.run(
        [str(pg.bin / "pg_restore"), "--no-owner", "--exit-on-error", "-d", target, str(dump)],
        capture_output=True, text=True, env={**os.environ, **pg.env(target)},
    )
    assert restored.returncode == 0, restored.stderr
    assert pg.psql(target, "SELECT count(*) FROM user_account") == "7"


def test_without_path_only_it_talks_as_before(tmp_path, fake_bin, pg, small_db):
    done = _run(_env(tmp_path, fake_bin, pg, small_db))
    assert done.returncode == 0, done.stderr
    assert "OK: " in done.stdout and "restore-test.sh" in done.stdout


def test_keep_sets_how_many_stay_and_zero_keeps_all(tmp_path, fake_bin, pg, small_db):
    backups = tmp_path / "backups"
    for i in range(3):
        stamp = f"2026112{i}T033000Z"
        done = _run(_env(tmp_path, fake_bin, pg, small_db, KEEP="0", BACKUP_STAMP=stamp), "--path-only")
        assert done.returncode == 0, done.stderr
    assert len(list(backups.glob("rawwers-*.dump"))) == 3
    done = _run(_env(tmp_path, fake_bin, pg, small_db, KEEP="2", BACKUP_STAMP="20261124T033000Z"), "--path-only")
    assert done.returncode == 0, done.stderr
    left = sorted(p.name for p in backups.glob("rawwers-*.dump"))
    assert left == ["rawwers-20261122T033000Z.dump", "rawwers-20261124T033000Z.dump"], left
    # A removed dump's counts go with it.
    assert sorted(p.name for p in backups.glob("*.counts")) == [f"{n}.counts" for n in left]


def test_a_missing_database_fails_and_keeps_nothing_half_done(tmp_path, fake_bin, pg):
    done = _run(_env(tmp_path, fake_bin, pg, "no_such_database_here"), "--path-only")
    assert done.returncode != 0
    assert done.stdout == ""
    assert not list((tmp_path / "backups").glob("rawwers-*.dump"))
