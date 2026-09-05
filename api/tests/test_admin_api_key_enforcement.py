"""The admin API key is enforced when configured.

The rest of the suite runs with ADMIN_API_KEYS empty (see conftest), so
this is the one place that asserts the guard actually bites. Without it,
pinning the variable for tests would quietly leave the guard uncovered.
"""
import uuid

import pytest

from app.core.config import get_settings


@pytest.fixture
def with_admin_key():
    settings = get_settings()
    original = settings.admin_api_keys
    settings.admin_api_keys = "test-admin-key"
    yield "test-admin-key"
    settings.admin_api_keys = original


def _seed_admin(db_session, user_id: str) -> None:
    from app.models.admin import UserAccount, UserRole, UserRoleType

    uid = uuid.UUID(user_id)
    db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
    db_session.commit()
    db_session.add(UserRole(user_id=uid, role=UserRoleType.admin))
    db_session.commit()


def test_a_wrong_key_is_refused(client, db_session, with_admin_key):
    admin_id = str(uuid.uuid4())
    _seed_admin(db_session, admin_id)

    resp = client.get(
        "/v1/admin/pros/review-queue",
        headers={"X-User-Id": admin_id, "X-Admin-Api-Key": "not-the-key"},
    )
    assert resp.status_code == 403


def test_a_missing_key_is_refused(client, db_session, with_admin_key):
    # The failure mode this guards: an unset key made require_admin skip
    # the check entirely rather than fail closed.
    admin_id = str(uuid.uuid4())
    _seed_admin(db_session, admin_id)

    resp = client.get("/v1/admin/pros/review-queue", headers={"X-User-Id": admin_id})
    assert resp.status_code == 403


def test_the_right_key_is_accepted(client, db_session, with_admin_key):
    admin_id = str(uuid.uuid4())
    _seed_admin(db_session, admin_id)

    resp = client.get(
        "/v1/admin/pros/review-queue",
        headers={"X-User-Id": admin_id, "X-Admin-Api-Key": with_admin_key},
    )
    assert resp.status_code == 200
