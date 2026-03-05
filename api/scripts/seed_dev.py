#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.db.session import SessionLocal
from _seed_common import seed_environment


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Seed RAWWERS dev/test data")
    parser.add_argument("--city", default="New York")
    parser.add_argument("--country", default="US")
    parser.add_argument("--deterministic", action="store_true", help="No-op flag kept for CI clarity")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    db = SessionLocal()
    try:
        seed_environment(db, city=args.city, country=args.country, include_sample_booking=True)
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()

    print(f"Seeded dev data for {args.city}, {args.country}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
