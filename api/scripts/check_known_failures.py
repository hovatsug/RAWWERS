#!/usr/bin/env python3
"""Compare a test run with docs/KNOWN_FAILURES.txt, by name.

    python3 scripts/check_known_failures.py <pytest output file> [<known failures file>]

A run is clean only when it failed exactly the known tests and errored on
none. An error - a test that could not even set up - says nothing about the
code it was meant to test, so it is never treated as a pass or as a known
failure: on 2026-10-14, five suites run at once exhausted the Postgres lock
table and 13 tests errored in setup while their failure lists still matched.
The run needs `-rfE` (make test-isolated's default) so both are listed.
Exit status 0 when clean, 1 otherwise.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

# pytest's short summary: "FAILED tests/x.py::test - reason", "ERROR tests/x.py::test - reason".
# Application log lines also begin "ERROR " but are followed by a logger name, not a test id.
_SUMMARY = re.compile(r"^(FAILED|ERROR) (tests/\S+?)(?: - .*)?$")


def read_known(path: Path) -> set[str]:
    return {line.strip() for line in path.read_text().splitlines() if line.strip() and not line.startswith("#")}


def parse_run(text: str) -> tuple[set[str], set[str]]:
    failed, errored = set(), set()
    for line in text.splitlines():
        match = _SUMMARY.match(line.rstrip())
        if match:
            (failed if match.group(1) == "FAILED" else errored).add(match.group(2))
    return failed, errored


def final_counts(text: str) -> dict[str, int]:
    """pytest's last line - "28 failed, 942 passed, 13 errors in ..." - as counts."""
    for line in reversed(text.splitlines()):
        if re.search(r"\b(passed|failed|errors?)\b.* in [\d.]+s", line):
            return {kind.rstrip("s"): int(n) for n, kind in re.findall(r"(\d+) (failed|passed|errors?)", line)}
    return {}


def verdict(run_text: str, known: set[str]) -> tuple[bool, list[str]]:
    failed, errored = parse_run(run_text)
    counts = final_counts(run_text)
    lines = [
        f"failed {len(failed)}, known {len(known)}, errored {len(errored)}",
        "new: " + " ".join(sorted(failed - known)),
        "fixed: " + " ".join(sorted(known - failed)),
        "errored: " + " ".join(sorted(errored)),
    ]
    # A run without -rfE lists failures but not errors; its last line still
    # counts both. Names and counts must agree, or the run is unreadable.
    unlisted = counts.get("error", 0) != len(errored) or counts.get("failed", 0) != len(failed)
    if not counts:
        lines.append("no pytest summary line - the run did not finish")
    elif unlisted:
        lines.append(f"summary counts {counts.get('failed', 0)} failed, {counts.get('error', 0)} errors, but lists {len(failed)} and {len(errored)} - run with -rfE")
    clean = bool(counts) and not unlisted and failed == known and not errored
    lines.append("CLEAN" if clean else "NOT CLEAN")
    return clean, lines


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    known_path = Path(argv[2]) if len(argv) > 2 else Path(__file__).resolve().parents[2] / "docs" / "KNOWN_FAILURES.txt"
    clean, lines = verdict(Path(argv[1]).read_text(), read_known(known_path))
    print("\n".join(lines))
    return 0 if clean else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
