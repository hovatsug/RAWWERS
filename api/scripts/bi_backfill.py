"""Rebuild the business dashboard's bi_daily for any range (docs/BI.md).

    python scripts/bi_backfill.py --from 2026-08-01 --to 2026-11-09
    python scripts/bi_backfill.py --from 2026-08-01 --to 2026-11-09 --stripe

--stripe first mirrors Stripe's balance transactions for the range (in
chunks of 31 days), so the Stripe fees and the reconciliation have data.
Re-running a range gives the same rows.
"""
from __future__ import annotations

import argparse
import sys
from datetime import date, timedelta
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.db.session import SessionLocal  # noqa: E402
from app.services import bi, bi_stripe  # noqa: E402


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--from", dest="start", type=date.fromisoformat, required=True)
    parser.add_argument("--to", dest="end", type=date.fromisoformat, default=None)
    parser.add_argument("--stripe", action="store_true", help="mirror Stripe's balance transactions first")
    args = parser.parse_args(argv)
    end = args.end or bi.london_today()
    if end < args.start:
        parser.error("--to is before --from")
    db = SessionLocal()
    try:
        if args.stripe:
            cursor, mirrored = args.start, 0
            while cursor <= end:
                chunk_end = min(end, cursor + timedelta(days=bi_stripe.MAX_SYNC_DAYS - 1))
                mirrored += bi_stripe.sync_days(db, cursor, chunk_end).transactions
                db.commit()
                cursor = chunk_end + timedelta(days=1)
            print(f"stripe: {mirrored} balance transactions mirrored")
        rows = bi.recompute_range(db, args.start, end)
        db.commit()
        print(f"bi_daily: {rows} rows for {args.start} to {end}")
        return 0
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
