import os
import uuid
from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("LOG_LEVEL", "DEBUG")
os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///./test.db")
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

from app.api.deps import get_db_session
from app.db.base import Base
from app.main import app

engine = create_engine("sqlite+pysqlite:///./test.db", connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, class_=Session)


@pytest.fixture(autouse=True)
def setup_database() -> Generator[None, None, None]:
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
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
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def user_id() -> str:
    return str(uuid.uuid4())
