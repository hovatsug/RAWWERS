"""Two routes for the app's integration tests, which run against a local
backend: which environment this is, and deleting the test's own account.

They exist only in development and test. In any other environment both answer
404, so the app's guard - which refuses to run unless the backend says it is
dev or test - fails closed against production, and the deletion cannot be
reached there at all. Even where it exists, it deletes only a throwaway
account (@rawwers.test) made in the last hour with no bookings or money
attached: the integration test's own, just made.
"""
import uuid
from datetime import datetime, timedelta, timezone

import pytest
from app.core.config import get_settings
from app.models.admin import UserAccount
from sqlalchemy import text

from tests.test_scheduled_tasks import _make_booking_request, _make_package, _seed_user


def _register(client, email=None) -> uuid.UUID:
    email = email or f"it-{uuid.uuid4().hex[:12]}@rawwers.test"
    resp = client.post("/v1/auth/register", json={"email": email, "password": "correct-horse-8", "display_name": "IT"})
    assert resp.status_code == 201, resp.text
    login = client.post("/v1/auth/login", json={"email": email, "password": "correct-horse-8"})
    assert login.status_code == 200, login.text
    return uuid.UUID(client.get("/v1/me", headers={"Authorization": f"Bearer {login.json()['access_token']}"}).json()["user_id"])


def _delete(client, user_id):
    return client.delete("/v1/dev/test-accounts/me", headers={"X-User-Id": str(user_id)})


def _rows_referencing(db_session, user_id) -> dict[str, int]:
    """Every row in any table whose UUID column holds this id."""
    columns = db_session.execute(
        text("SELECT table_name, column_name FROM information_schema.columns WHERE table_schema = 'public' AND data_type = 'uuid'")
    ).all()
    found = {}
    for table, column in columns:
        n = db_session.execute(text(f'SELECT count(*) FROM "{table}" WHERE "{column}" = :id'), {"id": user_id}).scalar()
        if n:
            found[f"{table}.{column}"] = n
    return found


def test_the_environment_is_named_in_development(client):
    resp = client.get("/v1/dev/environment")
    assert resp.status_code == 200
    assert resp.json() == {"environment": "development"}


@pytest.mark.parametrize("environment", ["production", "staging", "prod"])
def test_neither_route_exists_outside_development_and_test(client, db_session, monkeypatch, environment):
    user_id = _register(client)
    monkeypatch.setattr(get_settings(), "app_env", environment)

    assert client.get("/v1/dev/environment").status_code == 404
    assert _delete(client, user_id).status_code == 404
    assert db_session.get(UserAccount, user_id) is not None


def test_a_fresh_test_account_deletes_itself_and_everything_it_made(client, db_session):
    user_id = _register(client)
    assert client.post("/v1/me/upgrade-to-pro", headers={"X-User-Id": str(user_id)}).status_code == 200
    assert _rows_referencing(db_session, user_id), "the account made rows to delete"

    resp = _delete(client, user_id)

    assert resp.status_code == 204, resp.text
    db_session.expire_all()
    assert _rows_referencing(db_session, user_id) == {}


def test_a_real_address_is_never_deleted(client, db_session):
    user_id = _register(client, email=f"someone-{uuid.uuid4().hex[:8]}@rawwers.dev")

    resp = _delete(client, user_id)

    assert resp.status_code == 403, resp.text
    assert db_session.get(UserAccount, user_id) is not None


def test_an_account_older_than_an_hour_is_not_deleted(client, db_session):
    user_id = _register(client)
    account = db_session.get(UserAccount, user_id)
    account.created_at = datetime.now(timezone.utc) - timedelta(minutes=61)
    db_session.commit()

    assert _delete(client, user_id).status_code == 409
    assert db_session.get(UserAccount, user_id) is not None


def test_an_account_with_a_booking_is_not_deleted(client, db_session):
    user_id = _register(client)
    pro_id = _seed_user(db_session, str(uuid.uuid4()))
    package = _make_package(db_session, pro_id)
    _make_booking_request(db_session, pro_id=pro_id, client_id=user_id, package_id=package.id)
    db_session.commit()

    assert _delete(client, user_id).status_code == 409
    assert db_session.get(UserAccount, user_id) is not None


def test_deleting_needs_a_signed_in_account(client):
    assert client.delete("/v1/dev/test-accounts/me").status_code == 401


def test_neither_route_is_in_the_published_api(client):
    paths = client.get("/openapi.json").json()["paths"]
    assert not [p for p in paths if p.startswith("/v1/dev/")]
