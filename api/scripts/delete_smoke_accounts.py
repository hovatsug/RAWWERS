#!/usr/bin/env python3
"""Remove the throwaway accounts the smoke test made (deploy/scripts/smoke.py).

Only accounts whose email is exactly smoke-<digits>@rawwers.test, made in the
last 7 days, with no booking or money attached. Nothing else is ever touched.
Shows what it would remove unless --apply is given.

    docker compose --env-file /opt/rawwers/.env.production -f deploy/compose.prod.yml \
        exec api python scripts/delete_smoke_accounts.py            # show
    ... exec api python scripts/delete_smoke_accounts.py --apply    # remove
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import select  # noqa: E402

import app.db.base  # noqa: E402,F401  every model registered
from app.api.v1.dev_only import MONEY_TABLES, _uuid_columns  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.db.session import SessionLocal  # noqa: E402
from app.models.admin import UserAccount  # noqa: E402

SMOKE_EMAIL = re.compile(r"^smoke-\d+@rawwers\.test$")
MAX_AGE = timedelta(days=7)


def _delete_everything_naming(db, tables, user_id) -> None:
    """Every row whose uuid column names the account, children first. Some
    foreign keys exist only in the migrations, not in the models' order, so a
    delete a foreign key still blocks is retried on the next pass."""
    from sqlalchemy.exc import IntegrityError

    pending = [(t, c) for t in tables for c in _uuid_columns(t)]
    for _ in range(6):
        blocked = []
        for table, column in pending:
            savepoint = db.begin_nested()
            try:
                db.execute(table.delete().where(column == user_id))
                savepoint.commit()
            except IntegrityError:
                savepoint.rollback()
                blocked.append((table, column))
        if not blocked:
            return
        pending = blocked
    raise RuntimeError("rows still refer to the account: " + ", ".join(sorted({t.name for t, _ in pending})))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--apply", action="store_true", help="remove them (without it, only show)")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        since = datetime.now(timezone.utc) - MAX_AGE
        candidates = [
            a for a in db.execute(select(UserAccount).where(UserAccount.email.like("smoke-%@rawwers.test"))).scalars()
            if SMOKE_EMAIL.match(a.email or "") and a.created_at >= since
        ]
        tables = list(reversed(Base.metadata.sorted_tables))
        removed = 0
        for account in candidates:
            held = [
                t.name for t in tables if t.name in MONEY_TABLES
                for c in _uuid_columns(t)
                if db.execute(t.select().where(c == account.user_id).limit(1)).first()
            ]
            if held:
                print(f"keep    {account.email}: has rows in {', '.join(sorted(set(held)))}")
                continue
            print(f"{'remove' if args.apply else 'would remove'}  {account.email}")
            if args.apply:
                _delete_everything_naming(db, tables, account.user_id)
                removed += 1
        if args.apply:
            db.commit()
            print(f"\nRemoved {removed} smoke account(s).")
        else:
            db.rollback()
            print(f"\n{len(candidates)} smoke account(s) found. Nothing removed (add --apply).")
        return 0
    except Exception as exc:
        db.rollback()
        print(f"FAILED, nothing removed: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
