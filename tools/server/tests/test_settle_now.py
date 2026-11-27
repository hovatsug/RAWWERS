"""tools/server/settle-now.py: the settlement sweep, now, on a test server.

Run the way the runbook runs it (`python - [--apply] < settle-now.py` from
the API folder), against a throwaway migrated database; RAWWERS_API_DIR
chooses which API code (point it at a checkout of the deploy tag to prove
it works with the deployed image). See test_server_scripts.py.

    NATIVE_DB_ROOT=1 RAWWERS_API_DIR=<tag checkout>/api tools/tests/native-db.sh tools/server/tests/test_settle_now.py
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest

from test_server_scripts import HERE, migrated, run  # noqa: F401  (migrated is a fixture)

SETTLE_NOW = HERE.parent / "settle-now.py"


@pytest.fixture()
def db(migrated):  # noqa: F811
    from sqlalchemy import text

    import app.db.base  # noqa: F401
    from app.db.session import SessionLocal

    session = SessionLocal()
    for table in ("earnings_balance_snapshot", "earnings_ledger_entry", "pro_profile", "user_role", "user_account"):
        session.execute(text(f"DELETE FROM {table}"))
    session.commit()
    yield session
    session.rollback()
    session.close()


def _entries(db, *offsets_days: int) -> list[uuid.UUID]:
    """One photographer's earnings, each falling due `offset` days from now
    (negative: already due)."""
    from app.models.admin import UserAccount
    from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry, EarningsSourceType

    pro = UserAccount(user_id=uuid.uuid4(), email=f"{uuid.uuid4().hex[:8]}@example.test")
    db.add(pro)
    db.flush()
    ids = []
    for offset in offsets_days:
        row = EarningsLedgerEntry(
            pro_user_id=pro.user_id, source_type=EarningsSourceType.gig_base, source_id=uuid.uuid4(), currency="GBP",
            gross=Decimal("100.00"), platform_fee=Decimal("20.00"), net=Decimal("80.00"), status=EarningsEntryStatus.pending,
            available_at=datetime.now(timezone.utc) + timedelta(days=offset), meta={},
        )
        db.add(row)
        db.flush()
        ids.append(row.id)
    db.commit()
    return ids


def _statuses(db, ids) -> list[str]:
    from app.models.payouts import EarningsLedgerEntry

    db.expire_all()
    return [db.get(EarningsLedgerEntry, i).status.value for i in ids]


@pytest.mark.parametrize("mode", ["live", "Test", "test ", None, "", "staging"])
def test_refuses_unless_the_mode_is_exactly_test(db, mode):
    ids = _entries(db, -1)
    done = run(SETTLE_NOW, "--apply", mode=mode)
    assert done.returncode == 2 and "REFUSED" in done.stderr, done.stdout + done.stderr
    assert _statuses(db, ids) == ["pending"]


def test_dry_run_counts_and_changes_nothing(db):
    ids = _entries(db, -1, -2, 3)
    done = run(SETTLE_NOW)
    assert done.returncode == 0, done.stderr
    assert "due now: 2 earning(s); still in their settlement delay: 1" in done.stdout
    assert "DRY RUN" in done.stdout
    assert _statuses(db, ids) == ["pending", "pending", "pending"]


def test_apply_settles_only_what_is_due(db):
    ids = _entries(db, -1, -2, 3)
    done = run(SETTLE_NOW, "--apply")
    assert done.returncode == 0, done.stderr
    assert "Swept: 2 earning(s) settled" in done.stdout and "Still waiting: 1" in done.stdout
    assert _statuses(db, ids) == ["available", "available", "pending"]
    # It prints counts only.
    assert "@example.test" not in done.stdout and "80.00" not in done.stdout


def test_twice_is_safe(db):
    ids = _entries(db, -1)
    assert run(SETTLE_NOW, "--apply").returncode == 0
    again = run(SETTLE_NOW, "--apply")
    assert again.returncode == 0 and "Nothing is due" in again.stdout
    assert _statuses(db, ids) == ["available"]
