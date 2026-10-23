#!/usr/bin/env python3
"""Recompute every completed booking's earnings through photographer_money.

Earnings used to be 80% of the sum of a booking's payments, rounded as one
20% fee. They are now the booking's final price net of refunds, split by the
invoice method and stamped on the booking. Bookings completed before that
change keep their old entry until this runs.

Dry run by default: prints each booking whose earnings would change (old net,
new net, difference) and every photographer whose balance moves, and writes
nothing. `--apply` writes, one booking at a time.

Never raises a reversed entry, and never touches a payout: where earnings
already paid out come down, the photographer's balance goes negative and the
Wallet shows the adjustment owed - visible, not hidden.

    docker compose run --rm -v "$PWD/..:/repo" -w /repo/api api python scripts/recompute_earnings.py
    ... scripts/recompute_earnings.py --apply
    ... scripts/recompute_earnings.py --gig 605304bd-bb7b-4ec3-8ef3-b1d0614f96dc --apply
"""
from __future__ import annotations

import argparse
import sys
import uuid
from decimal import Decimal
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import select  # noqa: E402

from app.db.session import SessionLocal  # noqa: E402
from app.models.gig import Gig, GigStatus  # noqa: E402
from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType  # noqa: E402
from app.services.photographer_money import booking_split, earned_gross, net_paid, photographer_money, record_gig_earnings  # noqa: E402

ZERO = Decimal("0.00")


def plan(db, gig_ids: list[uuid.UUID] | None = None, unpaid: list | None = None) -> list[tuple[Gig, Decimal, Decimal]]:
    """(gig, current net, recomputed net) for every completed booking whose
    earnings would change. Bookings with earnings but no payment on record
    are left alone and appended to `unpaid`."""
    unpaid = unpaid if unpaid is not None else []
    stmt = select(Gig).where(Gig.status == GigStatus.completed)
    if gig_ids:
        stmt = stmt.where(Gig.id.in_(gig_ids))
    changes = []
    for gig in db.execute(stmt.order_by(Gig.created_at)).scalars():
        entry = db.execute(
            select(EarningsLedgerEntry).where(
                EarningsLedgerEntry.source_type == EarningsSourceType.gig_base,
                EarningsLedgerEntry.source_id == gig.id,
            )
        ).scalar_one_or_none()
        if entry is not None and entry.status == EarningsEntryStatus.reversed:
            continue
        current = entry.net_eur if entry is not None else ZERO
        if net_paid(db, gig) <= ZERO and current > ZERO:
            # No payment on record at all (seed fixtures; anything else is a
            # finding): never wipe earnings for lack of data - listed instead.
            unpaid.append((gig, current))
            continue
        target = booking_split(db, gig, earned_gross(db, gig)).pro_cash
        if current != target or gig.final_stamped_at is None:
            changes.append((gig, current, target))
    return changes


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--gig", action="append", type=uuid.UUID)
    args = parser.parse_args()
    with SessionLocal() as db:
        unpaid: list = []
        changes = plan(db, args.gig, unpaid)
        if unpaid:
            print(f"left alone - earnings but no payment on record ({len(unpaid)}):")
            for gig, current in unpaid[:20]:
                print(f"  gig {gig.id}  net {current}  {'(seed fixture)' if (gig.meta or {}).get('seeded') else ''}")
        pros = sorted({g.pro_user_id for g, _, _ in changes}, key=str)
        before = {p: photographer_money(db, p) for p in pros}
        for gig, current, target in changes:
            print(f"gig {gig.id}  net {current} -> {target}  ({target - current:+})")
            if args.apply:
                record_gig_earnings(db, gig)
        if args.apply:
            db.commit()
            for p in pros:
                after = photographer_money(db, p)
                print(f"pro {p}  available {before[p].available} -> {after.available}  lifetime {before[p].lifetime} -> {after.lifetime}")
        else:
            db.rollback()
            print(f"dry run: {len(changes)} booking(s) would change for {len(pros)} photographer(s); nothing written")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
