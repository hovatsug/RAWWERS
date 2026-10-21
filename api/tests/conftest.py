import os
import uuid
from collections.abc import Generator
from urllib.parse import urlsplit

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

os.environ.setdefault("APP_ENV", "development")
# Every `with TestClient(app)` runs the app's startup; its warm-up is tested
# on its own (test_startup_warmup.py), not before each of a thousand tests.
os.environ["STARTUP_WARMUP"] = "false"
# Forced empty, not setdefault: when ADMIN_API_KEYS is configured,
# require_admin enforces the X-Admin-Api-Key header, and every admin test
# in this suite sends an empty one. Inheriting a real key from a developer's
# .env turns those into 403s that look like product failures - which is
# exactly what happened, and a code-only HEAD baseline could not see it
# because the environment was identical in both arms.
#
# Enforcement itself is covered directly by test_admin_api_key_enforcement.py
# rather than by making every admin test carry a header.
os.environ["ADMIN_API_KEYS"] = ""
os.environ.setdefault("LOG_LEVEL", "DEBUG")
# Deliberately not SQLite: production runs Postgres, and several models use
# Postgres-only types (e.g. JSONB) that SQLite can't compile at all.
#
# This is an override, not a setdefault. It used to be a setdefault, whose
# stated purpose was to stop a stray test run from drop_all()-ing a
# developer's real dev data - but setdefault only takes effect when
# DATABASE_URL is *unset*, and the environment where that protection
# actually matters is precisely the one where it is always set: inside the
# api container, or any shell with a dev .env loaded. The guard was a no-op
# exactly when it was needed, and running `pytest` inside the api container
# dropped every table in the local dev database.
#
# To point the suite at a different database, set TEST_DATABASE_URL. That
# is a separate variable on purpose: it cannot be set accidentally by
# sourcing an app env file, so the escape hatch can't reintroduce the bug.
os.environ["DATABASE_URL"] = os.environ.get(
    "TEST_DATABASE_URL",
    "postgresql+psycopg2://postgres:postgres@localhost:5432/rawwers_test",
)
# Everything below is an override, not a setdefault, for the reason spelled
# out above DATABASE_URL - and the lesson generalises further than it was
# applied. setdefault is a no-op whenever the variable already exists, and
# the environment that matters is exactly the one where it always does:
# inside the api container, where .env has already populated all of it.
#
# Measured there, 21 of these defaults never applied. Three mattered:
#
#   ADMIN_USER_IDS arrived as an empty string, so _seed_admin_role_if_needed
#   seeded no role and every admin endpoint answered 403 - 17 failures that
#   looked like broken tests and were nothing of the kind.
#
#   STRIPE_WEBHOOK_ALLOW_UNVERIFIED arrived false, so webhook tests 401'd.
#
#   R2_* pointed at the live rawwers-media bucket with real credentials,
#   which a test suite should not be able to reach at all. A script run in
#   that container overwrote six real objects before this was noticed.
#
# REDIS_URL, LOG_LEVEL and APP_ENV stay as defaults: those are
# infrastructure the surrounding environment legitimately owns, the same
# way TEST_DATABASE_URL is the deliberate escape hatch for the database.
os.environ.setdefault("REDIS_URL", "redis://localhost:6379/0")
os.environ["R2_ENDPOINT_URL"] = "https://example.r2.cloudflarestorage.com"
os.environ["R2_ACCESS_KEY_ID"] = "test"
os.environ["R2_SECRET_ACCESS_KEY"] = "test"
os.environ["R2_BUCKET"] = "bucket"
os.environ["R2_REGION"] = "auto"
os.environ["MUX_TOKEN_ID"] = "token-id"
os.environ["MUX_TOKEN_SECRET"] = "token-secret"
os.environ["MUX_WEBHOOK_SECRET"] = "test-webhook-secret"
os.environ["MUX_SIGNING_KEY_ID"] = "key-id"
os.environ["MUX_SIGNING_KEY_PRIVATE"] = "-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBAKSwN2zWi4KFOeFHrgb3R04QLbTjaCj1eO0MJdHj7FVFvXZHzVvz\nY9q24apqYh6gMPkTFogyXv3gZH/BqhGlywECAwEAAQJAQ0f+T5cxrFAxo0xO+ogz\n31xHn0SI7RyhokW2N7DbStO2Qd6hw2yYB9H9n1tFoZT3zh0+BTtPlqvGjYH6G+jD\nwQIhANBGSAdoo6gWQBaIj++ImQxGc1dQc5sKXc5teLoI0lpNAiEAxwoMvV7lidh+\nNangNh4tW7x1YgnPZXoqBYwygJyI072cCIDQXl3k5iADG7n2AFD+a83H8XTur2qx\n8pY/+bexdFv+AiEAjNFaUG2RglN6E466+vWXTjhBMWrMUR3pvN8MPmMXxMECIAxM\nN8MPmMXxMECIAxMN8MPmMXxMECIAxMN8MPmMXxMEC\n-----END RSA PRIVATE KEY-----"
os.environ["STRIPE_SECRET_KEY"] = "sk_test_123"
os.environ["STRIPE_WEBHOOK_SECRET"] = "whsec_test_123"
os.environ["STRIPE_WEBHOOK_ALLOW_UNVERIFIED"] = "true"
os.environ.pop("STRIPE_API_VERSION", None)  # the one in code (STRIPE_API_VERSION), as in production
os.environ["PLATFORM_FEE_BPS"] = "2000"
os.environ["APP_PUBLIC_URL"] = "http://localhost:3000"
os.environ["ADMIN_USER_IDS"] = "00000000-0000-0000-0000-0000000000aa"
os.environ["BAN_ENFORCEMENT_MODE"] = "strict"
os.environ["ALLOW_UNVERIFIED_PRO"] = "true"
os.environ["LLM_PROVIDER"] = "mock"
os.environ["OPENAI_MODEL"] = ""
os.environ["OPENAI_API_KEY"] = ""
os.environ["LLM_MAX_TOKENS_PER_THREAD"] = "4000"
os.environ["LLM_MAX_MESSAGES_PER_THREAD"] = "50"
os.environ["TELEPHONY_PROVIDER"] = "mock"
os.environ["TELEPHONY_FROM_E164"] = "+351300000000"
os.environ["TELEPHONY_WEBHOOK_SECRET"] = "telephony-secret"
os.environ["CALL_RATE_LIMIT_PER_USER_PER_DAY"] = "2"
os.environ["CALL_RATE_LIMIT_PER_PRO_PER_DAY"] = "20"
os.environ["SEARCH_PROVIDER"] = "none"
os.environ["SEARCH_ENABLED"] = "true"
os.environ["SEARCH_INDEX_PREFIX"] = "rawwers_test"
os.environ["MEILI_URL"] = "http://localhost:7700"
os.environ["MEILI_API_KEY"] = ""
os.environ["AUTH_JWT_SECRET"] = "test-auth-secret"
os.environ["AUTH_ACCESS_TOKEN_TTL_MINUTES"] = "15"
os.environ["AUTH_REFRESH_TOKEN_TTL_DAYS"] = "30"
os.environ["AUTH_EMAIL_VERIFICATION_TTL_MINUTES"] = "30"
os.environ["AUTH_PASSWORD_RESET_TTL_MINUTES"] = "30"
os.environ["AUTH_DEV_BYPASS"] = "true"

from app.api.deps import get_db_read_session, get_db_session, get_db_write_session
from app.db.base import Base
from app.main import app
from app.services.niche_catalog import ensure_initial_niches

_database_url = os.environ["DATABASE_URL"]


def _assert_safe_to_drop(url: str) -> None:
    """Refuse to run at all unless the target database is clearly a test one.

    The `setup_database` fixture calls `Base.metadata.drop_all()` on every
    single test. That is unrecoverable against a real database, so it must
    not be gated on an environment variable being right - env vars are
    exactly what was wrong the last time this destroyed a dev database.
    This is a structural check on the resolved connection string, and it
    fails collection rather than skipping, because a suite that silently
    declines to run reads as a green build.
    """
    if url.startswith("sqlite"):
        return
    name = urlsplit(url).path.lstrip("/").split("?")[0]
    if not name.endswith("_test"):
        raise RuntimeError(
            f"Refusing to run: the test suite drops every table on each test, and the target "
            f"database {name!r} is not named '*_test'. Resolved from DATABASE_URL={url!r}. "
            f"Create a dedicated database (e.g. `createdb rawwers_test`) and point the suite at "
            f"it with TEST_DATABASE_URL, rather than running against a dev or production database."
        )


_assert_safe_to_drop(_database_url)


def _assert_storage_is_not_real(bucket: str, endpoint: str) -> None:
    """Refuse to run if the suite could reach the real media bucket.

    Forcing R2_* above fixes the common case, but a forced value is still
    just a value: anyone adding a new variable, or running a script in an
    environment that sets these another way, gets production storage back.
    A test that can silently write to the real bucket is worse than one
    that fails, because nothing announces it - six real objects were
    overwritten by a maintenance script before this was noticed.

    Structural, like the database check, and it fails collection rather
    than skipping.
    """
    if bucket != "bucket" and not bucket.endswith("-test"):
        raise RuntimeError(
            f"Refusing to run: R2_BUCKET is {bucket!r}, which is not a test bucket. "
            f"The suite writes objects, and this one may be real."
        )
    if "cloudflarestorage.com" in endpoint and "example" not in endpoint:
        raise RuntimeError(
            f"Refusing to run: R2_ENDPOINT_URL is {endpoint!r}, a real storage endpoint."
        )


def _assert_stripe_is_not_real(key: str) -> None:
    """A live secret key means tests can create real charges.

    test_a_window_only_partly_blocked_can_still_be_accepted reaches
    stripe.PaymentIntent.create with no mock, and passed for as long as a
    real key was in the environment - it was creating real PaymentIntents
    on every run. The key is now fake, so that call fails loudly. This
    stops a real one being reintroduced.
    """
    if key and not key.startswith("sk_test_"):
        raise RuntimeError(f"Refusing to run: STRIPE_SECRET_KEY is not a test key ({key[:8]}...).")
    if key.startswith("sk_test_") and len(key) > 40:
        raise RuntimeError(
            "Refusing to run: STRIPE_SECRET_KEY looks like a real test-mode key from an account, "
            "not the suite's placeholder. Tests must not reach Stripe at all."
        )


_assert_storage_is_not_real(os.environ["R2_BUCKET"], os.environ["R2_ENDPOINT_URL"])
_assert_stripe_is_not_real(os.environ["STRIPE_SECRET_KEY"])

# Belt and braces: point the Stripe client at a domain that cannot resolve.
# A fake key already makes real charges impossible, but it still lets an
# unmocked call leave the machine and fail slowly against Stripe's servers.
# With this, an unmocked call fails immediately and locally, and the error
# names the test that made it rather than looking like a network blip.
# Tests that patch stripe.* never reach this at all.
import stripe as _stripe

_stripe.api_base = "http://stripe.invalid"
_stripe.upload_api_base = "http://stripe.invalid"

_connect_args = {"check_same_thread": False} if _database_url.startswith("sqlite") else {}
engine = create_engine(_database_url, connect_args=_connect_args)
TestingSessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, class_=Session)


@pytest.fixture(autouse=True)
def setup_database() -> Generator[None, None, None]:
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    seed_session = TestingSessionLocal()
    try:
        ensure_initial_niches(seed_session)
        seed_session.commit()
    finally:
        seed_session.close()
    yield


def pytest_configure(config) -> None:
    config.addinivalue_line(
        "markers",
        "real_clock: read call quiet hours against the real time of day instead of midday Lisbon",
    )


@pytest.fixture(autouse=True)
def _quiet_hours_at_midday(request) -> Generator[None, None, None]:
    """Call quiet hours are judged at midday Lisbon unless a test opts out.

    The default contact is quiet 22:00-08:00 local, and is_quiet_hours_now
    reads the real clock - so every call test that expects a call to go
    through failed when the suite ran at night, and passed by morning. A
    test about quiet hours themselves either sets a window that midday falls
    in, or passes `now_utc`, or marks itself `real_clock`.

    Patched and restored by hand, not through `monkeypatch`: an autouse
    fixture that requests `monkeypatch` sets it up before every other
    fixture, so it is torn down after them. A test that patched
    `db_session.close` then kept the no-op through db_session's own
    teardown, its transaction was never closed, and the next test's
    DROP TABLE waited on it for seven hours.
    """
    if request.node.get_closest_marker("real_clock"):
        yield
        return
    from datetime import datetime, timezone
    from zoneinfo import ZoneInfo

    from app.services import call_compliance

    midday = datetime.now(ZoneInfo("Europe/Lisbon")).replace(hour=12, minute=0, second=0, microsecond=0).astimezone(timezone.utc)
    real = call_compliance.is_quiet_hours_now
    call_compliance.is_quiet_hours_now = lambda contact, now_utc=None: real(contact, now_utc or midday)
    try:
        yield
    finally:
        call_compliance.is_quiet_hours_now = real


@pytest.fixture
def db_session() -> Generator[Session, None, None]:
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture
def client(db_session: Session) -> Generator[TestClient, None, None]:
    def override_get_db() -> Generator[Session, None, None]:
        yield db_session

    app.dependency_overrides[get_db_session] = override_get_db
    app.dependency_overrides[get_db_write_session] = override_get_db
    app.dependency_overrides[get_db_read_session] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def user_id() -> str:
    return str(uuid.uuid4())
