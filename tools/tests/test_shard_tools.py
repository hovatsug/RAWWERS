"""Tests for shard_tests.py and merge_shards.py (the manual full-suite
workflow). Standard library and pytest only; no database.

    python -m pytest tools/tests/test_shard_tools.py -q
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SHARD = HERE / "shard_tests.py"
MERGE = HERE / "merge_shards.py"
REPO = HERE.parents[1]


def shard(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run([sys.executable, str(SHARD), *args], capture_output=True, text=True)


def test_every_test_file_is_in_exactly_one_shard():
    every = sorted(str(p.relative_to(REPO / "api")) for p in (REPO / "api" / "tests").rglob("test_*.py"))
    seen: list[str] = []
    for i in range(8):
        done = shard("--shards", "8", "--index", str(i))
        assert done.returncode == 0, done.stderr
        seen += done.stdout.split()
    assert sorted(seen) == every
    assert len(set(seen)) == len(seen)


def test_the_split_is_the_same_every_time_and_roughly_even():
    first = [shard("--shards", "5", "--index", str(i)).stdout for i in range(5)]
    again = [shard("--shards", "5", "--index", str(i)).stdout for i in range(5)]
    assert first == again
    sizes = [sum((REPO / "api" / line).stat().st_size for line in out.split()) for out in first]
    assert max(sizes) < 1.2 * min(sizes)


def test_bad_arguments_are_refused():
    assert shard("--shards", "0", "--index", "0").returncode == 2
    assert shard("--shards", "4", "--index", "4").returncode == 2
    assert shard("--shards", "4").returncode == 2


def _write(folder: Path, i: int, text: str) -> None:
    (folder / f"shard-{i}.txt").write_text(text)


def merge(folder: Path, shards: int, known: str) -> subprocess.CompletedProcess:
    (folder / "known.txt").write_text(known)
    return subprocess.run(
        [sys.executable, str(MERGE), "--shards", str(shards), str(folder), "--known", str(folder / "known.txt")],
        capture_output=True, text=True,
    )


def test_merge_is_clean_when_the_failures_are_exactly_the_known_ones(tmp_path):
    _write(tmp_path, 0, "....\nFAILED tests/test_a.py::test_x - boom\n==== 1 failed, 40 passed in 12.00s ====\n")
    _write(tmp_path, 1, "....\n==== 30 passed, 1 skipped in 9.00s ====\n")
    done = merge(tmp_path, 2, "# header\ntests/test_a.py::test_x\n")
    assert done.returncode == 0, done.stdout + done.stderr
    assert "CLEAN" in done.stdout and "NOT CLEAN" not in done.stdout
    assert "1 failed, 70 passed, 1 skipped" in (tmp_path / "merged.txt").read_text()


def test_merge_with_no_failures_and_an_empty_list_is_clean(tmp_path):
    _write(tmp_path, 0, "==== 3 passed in 1.00s ====\n")
    assert merge(tmp_path, 1, "# none\n").returncode == 0


def test_a_new_failure_is_not_clean(tmp_path):
    _write(tmp_path, 0, "FAILED tests/test_b.py::test_y - new\n==== 1 failed, 2 passed in 1.00s ====\n")
    done = merge(tmp_path, 1, "")
    assert done.returncode == 1 and "new: tests/test_b.py::test_y" in done.stdout


def test_an_error_is_never_clean(tmp_path):
    _write(tmp_path, 0, "ERROR tests/test_c.py::test_z - setup\n==== 2 passed, 1 error in 1.00s ====\n")
    done = merge(tmp_path, 1, "")
    assert done.returncode == 1 and "errored: tests/test_c.py::test_z" in done.stdout


def test_a_missing_shard_is_not_clean(tmp_path):
    _write(tmp_path, 0, "==== 3 passed in 1.00s ====\n")
    done = merge(tmp_path, 2, "")
    assert done.returncode == 1 and "shard 1: no output" in done.stdout


def test_an_unfinished_shard_is_not_clean(tmp_path):
    _write(tmp_path, 0, "==== 3 passed in 1.00s ====\n")
    _write(tmp_path, 1, "....\nKilled\n")
    done = merge(tmp_path, 2, "")
    assert done.returncode == 1 and "shard 1: did not finish" in done.stdout
