#!/usr/bin/env python3
"""Give seeded completed gigs the dates they were shot on.

`_ensure_gigs` wrote no `scheduled_start` or `scheduled_end`, so the pro
app's gig card rendered "Not scheduled yet" on a card that also called the
gig completed. A shoot that finished and was never scheduled is the same
contradiction as a wallet reading zero for twenty delivered jobs.

The derivation is imported from the seeder rather than repeated here, so the
dates a re-seed writes and the dates this backfill writes cannot drift
apart. It is the same reason the tier lookup moved next to the price cap.

Only touches rows that have no dates, so it is safe to re-run and will not
overwrite a gig that was scheduled for real.

    docker compose exec api python scripts/backfill_gig_schedules.py
    docker compose exec api python scripts/backfill_gig_schedules.py --apply
"""
from __future__ import annotations

import argparse
import sys
from datetime import UTC, datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from _seed_common import assert_environment_is_seedable  # noqa: E402
from seed_fake_photographers import _package_duration, gig_schedule  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.gig import Gig, GigStatus  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Write. Without it nothing is committed.")
    args = parser.parse_args()

    assert_environment_is_seedable()

    db = SessionLocal()
    try:
        now = datetime.now(UTC)
        gigs = db.execute(
            select(Gig).where(
                Gig.status == GigStatus.completed,
                Gig.scheduled_start.is_(None),
            )
        ).scalars().all()

        print(f"completed gigs with no schedule: {len(gigs)}")
        if not gigs:
            print("Nothing to do.")
            return 0

        durations: dict[tuple, int] = {}
        dated = unresolved = 0
        for gig in gigs:
            key = (gig.pro_user_id, gig.niche_id)
            if key not in durations:
                durations[key] = _package_duration(db, pro_user_id=gig.pro_user_id, niche_id=gig.niche_id)
            schedule = gig_schedule(gig, duration_minutes=durations[key], now=now)
            if schedule is None:
                unresolved += 1
                continue
            gig.scheduled_start, gig.scheduled_end = schedule
            dated += 1

        print(f"dated                          : {dated}")
        print(f"left alone (would land ahead)   : {unresolved}")

        sample = [g for g in gigs if g.scheduled_start is not None][:3]
        for gig in sample:
            print(f"  {gig.scheduled_start:%Y-%m-%d %H:%M} -> {gig.scheduled_end:%H:%M}")

        if not args.apply:
            db.rollback()
            print("\nDry run. Nothing written. Re-run with --apply.")
            return 0

        db.commit()

        remaining = db.execute(
            select(Gig).where(Gig.status == GigStatus.completed, Gig.scheduled_start.is_(None))
        ).scalars().all()
        ahead = db.execute(
            select(Gig).where(Gig.status == GigStatus.completed, Gig.scheduled_end > now)
        ).scalars().all()
        print(f"\nWritten. Still undated: {len(remaining)}. Completed but scheduled ahead: {len(ahead)}")
        return 0 if not ahead else 1
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
