"""TEST ONLY: run the settlement sweep now, instead of waiting for the
hourly one, so an earning whose wait is over becomes available at once.

It runs exactly what the hourly task runs (run_settlement_scan_task:
settle_due_earnings_entries, then commit). It edits no data directly and
changes no setting: an earning still waiting for its settlement delay
stays waiting, and a held one stays held. To shorten the wait itself, see
set-settlement-delay.py (docs/TEST_WORLD.md 9a).

It runs inside the API container that is already running, sent from the
Mac over SSH (the server's checkout is the deploy tag, which does not have
this file). From the repository on the Mac:

    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python -' < tools/server/settle-now.py
        shows how many earnings are due now; writes nothing
    ssh root@<SERVER_IP> 'cd /opt/rawwers/src && deploy/scripts/dc exec -T api python - --apply' < tools/server/settle-now.py
        runs the sweep and says how many it settled

It refuses to run unless DEPLOYMENT_MODE, read from the container's
environment, is exactly "test". It prints counts only, never names,
emails or amounts.

Only what the API image of tag deploy-test-1 contains is imported.
"""
from __future__ import annotations

import argparse
import os
import sys

BANNER = "TEST ONLY: this runs the settlement sweep on a TEST server now. Never on a live deployment."


def refuse(message: str) -> None:
    print(f"REFUSED: {message}", file=sys.stderr)
    raise SystemExit(2)


def check_deployment_mode() -> None:
    mode = os.environ.get("DEPLOYMENT_MODE")
    if mode is None or not mode.strip():
        refuse("cannot read DEPLOYMENT_MODE from the environment; this runs only on a test deployment.")
    if mode != "test":
        refuse("DEPLOYMENT_MODE is not exactly 'test'; stopping to be safe.")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(prog="settle-now.py", description="TEST ONLY. Run the settlement sweep now.")
    parser.add_argument("--apply", action="store_true", help="run it (without it, only count)")
    args = parser.parse_args(argv)
    print(BANNER)
    check_deployment_mode()

    sys.path.insert(0, os.getcwd())
    from datetime import datetime, timezone

    from sqlalchemy import func, select

    import app.db.base  # noqa: F401  every model registered
    from app.db.session import SessionLocal
    from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry

    def count(db, *, due: bool) -> int:
        # The sweep's own selection (settle_due_earnings_entries): pending or
        # held, not reversed; due when its available_at has passed.
        query = select(func.count()).select_from(EarningsLedgerEntry).where(
            EarningsLedgerEntry.status.in_([EarningsEntryStatus.pending, EarningsEntryStatus.held]),
            EarningsLedgerEntry.reversed_at.is_(None),
        )
        now = datetime.now(timezone.utc)
        query = query.where(EarningsLedgerEntry.available_at <= now if due else EarningsLedgerEntry.available_at > now)
        return int(db.execute(query).scalar_one())

    db = SessionLocal()
    try:
        due, waiting = count(db, due=True), count(db, due=False)
    finally:
        db.rollback()
        db.close()
    print(f"due now: {due} earning(s); still in their settlement delay: {waiting}")
    if not args.apply:
        print("DRY RUN: nothing run. Add --apply to run the sweep.")
        return 0
    if due == 0:
        print("Nothing is due: the sweep would change nothing.")
        return 0

    from app.tasks.payouts_tasks import run_settlement_scan_task

    settled = run_settlement_scan_task()
    print(f"Swept: {settled} earning(s) settled (a held earning stays held). Still waiting: {waiting}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
