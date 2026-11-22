"""Tests for the test-server helpers tools/server/enable-city.py and
tools/server/set-settlement-delay.py.

Each script is run the way the runbook runs it: `python - [args] < script`,
from the API folder (the container's /app), against a throwaway database
migrated with the API's own migrations. RAWWERS_API_DIR chooses which API
code: by default this checkout's api/; to prove the scripts work with the
deployed image, point it at a checkout of the deploy tag.

    TEST_DATABASE_URL=postgresql+psycopg2://.../<name>_test \\
    RAWWERS_API_DIR=<checkout>/api \\
    python -m pytest tools/server/tests -q

The database name must end in _test; it is dropped and rebuilt here.
"""
from __future__ import annotations

import os
import subprocess
import sys
import uuid
from pathlib import Path

import pytest

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
ENABLE_CITY = HERE.parent / "enable-city.py"
SET_DELAY = HERE.parent / "set-settlement-delay.py"
API_DIR = Path(os.environ.get("RAWWERS_API_DIR", REPO / "api")).resolve()
DB_URL = os.environ.get("TEST_DATABASE_URL", "")

pytestmark = pytest.mark.skipif(not DB_URL.rsplit("/", 1)[-1].endswith("_test"), reason="needs TEST_DATABASE_URL naming a *_test database")

# The settings the API requires, as harmless placeholders (as api/tests/conftest.py
# does): no test here reaches R2 or needs Redis. On the server the container
# has the real ones.
PLACEHOLDERS = {
    "REDIS_URL": os.environ.get("REDIS_URL", "redis://localhost:6379/15"),
    "R2_ENDPOINT_URL": "https://example.r2.cloudflarestorage.com",
    "R2_ACCESS_KEY_ID": "test",
    "R2_SECRET_ACCESS_KEY": "test",
    "R2_BUCKET": "bucket",
    "R2_REGION": "auto",
    "STARTUP_WARMUP": "false",
}
os.environ.update(PLACEHOLDERS)
# The API's code, for checking what the scripts wrote.
os.environ["DATABASE_URL"] = DB_URL
sys.path.insert(0, str(API_DIR))


def _env(mode: str | None) -> dict[str, str]:
    env = {k: v for k, v in os.environ.items() if k not in ("DEPLOYMENT_MODE", "PYTHONPATH")}
    env.update(PLACEHOLDERS)
    env["DATABASE_URL"] = DB_URL
    if mode is not None:
        env["DEPLOYMENT_MODE"] = mode
    return env


def run(script: Path, *args: str, mode: str | None = "test") -> subprocess.CompletedProcess:
    with open(script, "rb") as source:
        return subprocess.run(
            [sys.executable, "-", *args], stdin=source, cwd=API_DIR, env=_env(mode),
            capture_output=True, text=True, timeout=300,
        )


@pytest.fixture(scope="session")
def migrated():
    from sqlalchemy import create_engine, text

    engine = create_engine(DB_URL)
    with engine.begin() as conn:
        conn.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public"))
    engine.dispose()
    done = subprocess.run(
        [sys.executable, "-m", "alembic", "upgrade", "head"], cwd=API_DIR, env=_env("test"),
        capture_output=True, text=True, timeout=900,
    )
    assert done.returncode == 0, done.stderr[-3000:]


@pytest.fixture()
def db(migrated):
    from sqlalchemy import text

    import app.db.base  # noqa: F401
    from app.db.session import SessionLocal

    session = SessionLocal()
    for table in ("admin_audit_log", "rollout_city", "platform_fee_policy", "user_role", "user_account"):
        session.execute(text(f"DELETE FROM {table}"))
    session.commit()
    yield session
    session.rollback()
    session.close()


def make_admin(db, email: str = "admin@example.test") -> uuid.UUID:
    from app.models.admin import UserAccount, UserRole, UserRoleType

    account = UserAccount(user_id=uuid.uuid4(), email=email)
    db.add(account)
    db.flush()
    db.add(UserRole(user_id=account.user_id, role=UserRoleType.admin))
    db.commit()
    return account.user_id


def cities(db) -> dict[tuple[str, str], tuple[bool, bool]]:
    from sqlalchemy import select

    from app.models.launch_ops import RolloutCity

    db.expire_all()
    return {(r.city, r.country): (r.is_pro_onboarding_enabled, r.is_client_browsing_enabled) for r in db.execute(select(RolloutCity)).scalars()}


def audits(db, action: str) -> list:
    from sqlalchemy import select

    from app.models.admin import AdminAuditLog

    db.expire_all()
    return db.execute(select(AdminAuditLog).where(AdminAuditLog.action == action)).scalars().all()


def delay(db):
    from sqlalchemy import select

    from app.models.payouts import PlatformFeePolicy

    db.expire_all()
    row = db.execute(select(PlatformFeePolicy).order_by(PlatformFeePolicy.updated_at.desc())).scalars().first()
    return None if row is None else row.settlement_delay_days


# ---- enable-city.py -------------------------------------------------------

@pytest.mark.parametrize("mode", ["live", "LIVE ", None, "", "production"])
def test_enable_city_refuses_unless_the_mode_is_test(db, mode):
    make_admin(db)
    done = run(ENABLE_CITY, "--apply", mode=mode)
    assert done.returncode == 2, done.stdout + done.stderr
    assert "REFUSED" in done.stderr
    assert cities(db) == {}
    assert audits(db, "rollout_city_upsert") == []


def test_enable_city_dry_run_shows_london_and_lisbon_and_writes_nothing(db):
    make_admin(db)
    done = run(ENABLE_CITY)
    assert done.returncode == 0, done.stderr
    assert "London, GB: not listed (off)" in done.stdout
    assert "Lisbon, PT: not listed (off)" in done.stdout
    assert "DRY RUN" in done.stdout
    assert cities(db) == {}


def test_enable_city_apply_switches_both_on_with_an_audit_record_each(db):
    admin = make_admin(db)
    done = run(ENABLE_CITY, "--apply")
    assert done.returncode == 0, done.stderr
    assert cities(db) == {("London", "GB"): (True, True), ("Lisbon", "PT"): (True, True)}
    rows = audits(db, "rollout_city_upsert")
    assert sorted(r.target_id for r in rows) == ["GB:London", "PT:Lisbon"]
    assert {r.actor_user_id for r in rows} == {admin}
    assert "after   London, GB: photographer sign-up on, client browsing on" in done.stdout


def test_enable_city_twice_changes_nothing_the_second_time(db):
    make_admin(db)
    assert run(ENABLE_CITY, "--apply").returncode == 0
    before = (cities(db), len(audits(db, "rollout_city_upsert")))
    again = run(ENABLE_CITY, "--apply")
    assert again.returncode == 0, again.stderr
    assert "already on: nothing to change" in again.stdout
    assert "Nothing to do." in again.stdout
    assert (cities(db), len(audits(db, "rollout_city_upsert"))) == before


def test_enable_city_one_city_and_a_half_on_row(db):
    from app.models.launch_ops import RolloutCity

    make_admin(db)
    db.add(RolloutCity(country="GB", city="Manchester", is_pro_onboarding_enabled=True, is_client_browsing_enabled=False, meta={"note": "kept"}))
    db.commit()
    done = run(ENABLE_CITY, "--city", "manchester", "--country", "gb", "--apply")
    assert done.returncode == 0, done.stderr
    assert "before  manchester, GB: photographer sign-up on, client browsing off" in done.stdout
    assert cities(db) == {("Manchester", "GB"): (True, True)}
    db.expire_all()
    assert db.query(RolloutCity).one().meta == {"note": "kept"}


def test_enable_city_needs_an_admin_and_says_which_when_there_are_two(db):
    none = run(ENABLE_CITY, "--apply")
    assert none.returncode == 2 and "no admin account yet" in none.stderr
    make_admin(db, "a@example.test")
    make_admin(db, "b@example.test")
    two = run(ENABLE_CITY, "--apply")
    assert two.returncode == 2 and "more than one admin" in two.stderr
    chosen = run(ENABLE_CITY, "--apply", "--admin-email", "B@example.test")
    assert chosen.returncode == 0, chosen.stderr
    assert len(audits(db, "rollout_city_upsert")) == 2
    assert cities(db) != {}


def test_enable_city_city_without_country_is_an_error(db):
    done = run(ENABLE_CITY, "--city", "London")
    assert done.returncode == 2 and "together" in done.stderr


# ---- set-settlement-delay.py ------------------------------------------------

@pytest.mark.parametrize("mode", ["live", None, "", "staging"])
def test_delay_refuses_unless_the_mode_is_test(db, mode):
    make_admin(db)
    done = run(SET_DELAY, "--apply", mode=mode)
    assert done.returncode == 2, done.stdout + done.stderr
    assert "REFUSED" in done.stderr
    assert "TEST ONLY" in done.stdout
    assert delay(db) is None
    assert audits(db, "platform_fee_policy_updated") == []


def test_delay_dry_run_writes_nothing(db):
    make_admin(db)
    done = run(SET_DELAY)
    assert done.returncode == 0, done.stderr
    assert "TEST ONLY" in done.stdout
    assert "would set settlement_delay_days 7 -> 0" in done.stdout
    assert "DRY RUN" in done.stdout
    assert delay(db) is None


def test_delay_apply_then_restore_with_audit_records_and_other_fields_kept(db):
    from app.models.payouts import PlatformFeePolicy

    admin = make_admin(db)
    db.add(PlatformFeePolicy(fee_percent_gigs=21, fee_percent_extras=22, fee_percent_studioverse=23, settlement_delay_days=7, dispute_hold_days=15))
    db.commit()

    done = run(SET_DELAY, "--apply")
    assert done.returncode == 0, done.stderr
    assert delay(db) == 0
    assert "was 7, now 0" in done.stdout and "TEST ONLY" in done.stdout
    row = db.query(PlatformFeePolicy).one()
    assert (row.fee_percent_gigs, row.fee_percent_extras, row.fee_percent_studioverse, row.dispute_hold_days) == (21, 22, 23, 15)

    again = run(SET_DELAY, "--apply")
    assert again.returncode == 0 and "already 0 day(s): nothing to change" in again.stdout
    assert len(audits(db, "platform_fee_policy_updated")) == 1

    back = run(SET_DELAY, "--restore", "--apply")
    assert back.returncode == 0, back.stderr
    assert "Restored: settlement_delay_days was 0, now 7" in back.stdout
    assert delay(db) == 7
    rows = audits(db, "platform_fee_policy_updated")
    assert len(rows) == 2 and {r.actor_user_id for r in rows} == {admin}

    twice = run(SET_DELAY, "--restore", "--apply")
    assert twice.returncode == 0 and "already 7 day(s): nothing to change" in twice.stdout
    assert len(audits(db, "platform_fee_policy_updated")) == 2


def test_delay_with_no_policy_row_starts_from_the_api_defaults(db):
    make_admin(db)
    done = run(SET_DELAY, "--apply")
    assert done.returncode == 0, done.stderr
    assert delay(db) == 0
    from app.models.payouts import PlatformFeePolicy

    db.expire_all()
    row = db.query(PlatformFeePolicy).one()
    assert (row.fee_percent_gigs, row.dispute_hold_days) == (20, 14)
    assert run(SET_DELAY, "--restore").stdout.count("would set settlement_delay_days 0 -> 7") == 1
