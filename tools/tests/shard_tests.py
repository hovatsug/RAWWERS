#!/usr/bin/env python3
"""Split the backend test files into shards, for the manual full-suite
workflow (.github/workflows/backend-full-suite.yml). Standard library only.

    python3 tools/tests/shard_tests.py --shards 8 --index 0     # the files of shard 0
    python3 tools/tests/shard_tests.py --shards 8 --summary     # every shard's size

Whole files, never single tests: each file's fixtures stay together. The
split is by file size (a rough stand-in for time, since every test pays the
same schema setup), largest first into the lightest shard, so the same files
and the same N always give the same shards. Paths are printed relative to
api/, one per line.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

API = Path(__file__).resolve().parents[2] / "api"


def test_files(api: Path = API) -> list[Path]:
    return sorted(p for p in (api / "tests").rglob("test_*.py") if p.is_file())


def split(files: list[Path], shards: int) -> list[list[Path]]:
    if shards < 1:
        raise ValueError("shards must be at least 1")
    buckets: list[list[Path]] = [[] for _ in range(shards)]
    weights = [0] * shards
    for path in sorted(files, key=lambda p: (-p.stat().st_size, str(p))):
        lightest = min(range(shards), key=lambda i: (weights[i], i))
        buckets[lightest].append(path)
        weights[lightest] += path.stat().st_size
    return [sorted(b) for b in buckets]


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--shards", type=int, required=True)
    parser.add_argument("--index", type=int)
    parser.add_argument("--summary", action="store_true")
    parser.add_argument("--api", type=Path, default=API, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    if args.shards < 1 or args.shards > 64:
        parser.error("--shards must be 1-64")
    files = test_files(args.api)
    if not files:
        print(f"no test files under {args.api / 'tests'}", file=sys.stderr)
        return 2
    buckets = split(files, args.shards)
    if args.summary:
        for i, bucket in enumerate(buckets):
            print(f"shard {i}: {len(bucket)} files, {sum(p.stat().st_size for p in bucket) // 1024} KB")
        return 0
    if args.index is None or not 0 <= args.index < args.shards:
        parser.error("--index must be 0 to shards-1")
    for path in buckets[args.index]:
        print(path.relative_to(args.api))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
