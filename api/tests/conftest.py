import os
import uuid
from collections.abc import Generator
from urllib.parse import urlsplit

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

os.environ.setdefault("APP_ENV", "development")
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
os.environ.setdefault("REDIS_URL", "redis://localhost:6379/0")
os.environ.setdefault("R2_ENDPOINT_URL", "https://example.r2.cloudflarestorage.com")
os.environ.setdefault("R2_ACCESS_KEY_ID", "test")
os.environ.setdefault("R2_SECRET_ACCESS_KEY", "test")
os.environ.setdefault("R2_BUCKET", "bucket")
os.environ.setdefault("R2_REGION", "auto")
os.environ.setdefault("MUX_TOKEN_ID", "token-id")
os.environ.setdefault("MUX_TOKEN_SECRET", "token-secret")
os.environ.setdefault("MUX_WEBHOOK_SECRET", "test-webhook-secret")
os.environ.setdefault("MUX_SIGNING_KEY_ID", "key-id")
os.environ.setdefault("MUX_SIGNING_KEY_PRIVATE", "-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBAKSwN2zWi4KFOeFHrgb3R04QLbTjaCj1eO0MJdHj7FVFvXZHzVvz\nY9q24apqYh6gMPkTFogyXv3gZH/BqhGlywECAwEAAQJAQ0f+T5cxrFAxo0xO+ogz\n31xHn0SI7RyhokW2N7DbStO2Qd6hw2yYB9H9n1tFoZT3zh0+BTtPlqvGjYH6G+jD\nwQIhANBGSAdoo6gWQBaIj++ImQxGc1dQc5sKXc5teLoI0lpNAiEAxwoMvV7lidh+\nNangNh4tW7x1YgnPZXoqBYwygJyI072cCIDQXl3k5iADG7n2AFD+a83H8XTur2qx\n8pY/+bexdFv+AiEAjNFaUG2RglN6E466+vWXTjhBMWrMUR3pvN8MPmMXxMECIAxM\nN8MPmMXxMECIAxMN8MPmMXxMECIAxMN8MPmMXxMEC\n-----END RSA PRIVATE KEY-----")
os.environ.setdefault("STRIPE_SECRET_KEY", "sk_test_123")
os.environ.setdefault("STRIPE_WEBHOOK_SECRET", "whsec_test_123")
os.environ.setdefault("STRIPE_WEBHOOK_ALLOW_UNVERIFIED", "true")
os.environ.setdefault("STRIPE_API_VERSION", "2024-06-20")
os.environ.setdefault("PLATFORM_FEE_BPS", "2000")
os.environ.setdefault("APP_PUBLIC_URL", "http://localhost:3000")
os.environ.setdefault("ADMIN_USER_IDS", "00000000-0000-0000-0000-0000000000aa")
os.environ.setdefault("BAN_ENFORCEMENT_MODE", "strict")
os.environ.setdefault("ALLOW_UNVERIFIED_PRO", "true")
os.environ.setdefault("LLM_PROVIDER", "mock")
os.environ.setdefault("OPENAI_MODEL", "")
os.environ.setdefault("OPENAI_API_KEY", "")
os.environ.setdefault("LLM_MAX_TOKENS_PER_THREAD", "4000")
os.environ.setdefault("LLM_MAX_MESSAGES_PER_THREAD", "50")
os.environ.setdefault("TELEPHONY_PROVIDER", "mock")
os.environ.setdefault("TELEPHONY_FROM_E164", "+351300000000")
os.environ.setdefault("TELEPHONY_WEBHOOK_SECRET", "telephony-secret")
os.environ.setdefault("CALL_RATE_LIMIT_PER_USER_PER_DAY", "2")
os.environ.setdefault("CALL_RATE_LIMIT_PER_PRO_PER_DAY", "20")
os.environ.setdefault("SEARCH_PROVIDER", "none")
os.environ.setdefault("SEARCH_ENABLED", "true")
os.environ.setdefault("SEARCH_INDEX_PREFIX", "rawwers_test")
os.environ.setdefault("MEILI_URL", "http://localhost:7700")
os.environ.setdefault("MEILI_API_KEY", "")
os.environ.setdefault("AUTH_JWT_SECRET", "test-auth-secret")
os.environ.setdefault("AUTH_ACCESS_TOKEN_TTL_MINUTES", "15")
os.environ.setdefault("AUTH_REFRESH_TOKEN_TTL_DAYS", "30")
os.environ.setdefault("AUTH_EMAIL_VERIFICATION_TTL_MINUTES", "30")
os.environ.setdefault("AUTH_PASSWORD_RESET_TTL_MINUTES", "30")
os.environ.setdefault("AUTH_DEV_BYPASS", "true")

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
