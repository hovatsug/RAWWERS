#!/usr/bin/env python3
"""Merge the shards' pytest outputs of the manual full-suite workflow into
one, and compare it by name with docs/KNOWN_FAILURES.txt. Standard library
only.

    python3 tools/tests/merge_shards.py --shards 8 <folder with shard-<i>.txt files>

Every shard must be there and must have finished (its pytest summary line):
a missing or unfinished shard makes the whole run not clean, never a pass.
Writes <folder>/merged.txt (every FAILED and ERROR line, and one summary line
with the totals) and then runs api/scripts/check_known_failures.py on it,
whose exit status it returns (0 = clean: exactly the known failures, no
errors).
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
_SUMMARY_LINE = re.compile(r"\b(passed|failed|errors?)\b.* in [\d.]+s")
_COUNT = re.compile(r"(\d+) (failed|passed|errors?|skipped|xfailed|xpassed|deselected)")
_LISTED = re.compile(r"^(FAILED|ERROR) tests/\S+")


def summary(text: str) -> dict[str, int] | None:
    for line in reversed(text.splitlines()):
        if _SUMMARY_LINE.search(line):
            return {("error" if kind.startswith("error") else kind): int(n) for n, kind in _COUNT.findall(line)}
    return None


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--shards", type=int, required=True)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--known", type=Path, default=REPO / "docs" / "KNOWN_FAILURES.txt")
    args = parser.parse_args(argv)

    totals: dict[str, int] = {}
    listed: list[str] = []
    problems: list[str] = []
    for i in range(args.shards):
        path = args.folder / f"shard-{i}.txt"
        if not path.is_file():
            problems.append(f"shard {i}: no output (shard-{i}.txt missing)")
            continue
        text = path.read_text(errors="replace")
        counts = summary(text)
        if counts is None:
            problems.append(f"shard {i}: did not finish (no pytest summary line)")
            continue
        for kind, n in counts.items():
            totals[kind] = totals.get(kind, 0) + n
        listed += [line.rstrip() for line in text.splitlines() if _LISTED.match(line)]
        print(f"shard {i}: " + ", ".join(f"{n} {k}" for k, n in sorted(counts.items())))

    order = ["failed", "passed", "skipped", "xfailed", "xpassed", "error"]
    last = ", ".join(f"{totals[k]} {'errors' if k == 'error' else k}" for k in order if totals.get(k))
    merged = args.folder / "merged.txt"
    merged.write_text("\n".join(sorted(set(listed)) + [f"==== {last or 'no tests'} in 0.00s ===="]) + "\n")
    print(f"all shards: {last or 'no tests'}")
    if problems:
        print("NOT CLEAN:\n  " + "\n  ".join(problems))
        return 1
    done = subprocess.run([sys.executable, str(REPO / "api" / "scripts" / "check_known_failures.py"), str(merged), str(args.known)])
    return done.returncode


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
