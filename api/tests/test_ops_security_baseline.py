import uuid

import pytest

from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.models.ops import AbuseSignal, FeatureFlag, FeatureFlagScope, WebhookSecurityLog
from app.services.feature_flags import is_feature_enabled
from app.services import rate_limit as rate_limit_service


def _ensure_user_role(db, user_id: str, role: UserRoleType) -> None:
    uid = uuid.UUID(user_id)
    if not db.get(UserAccount, uid):
        db.add(UserAccount(user_id=uid, email=f"{user_id[:8]}@example.com"))
        db.flush()
    existing = db.query(UserRole).filter_by(user_id=uid, role=role).one_or_none()
    if not existing:
        db.add(UserRole(user_id=uid, role=role))
        db.flush()


@pytest.mark.parametrize("bucket", ["public_read", "auth_mutation"])
def test_rate_limit_named_buckets_enforced(bucket):
    rate_limit_service._BUCKETS.clear()
    rate_limit_service.RATE_LIMIT_RULES[bucket] = (2, 3600)
    principal = "test-principal"

    rate_limit_service.enforce_named_rate_limit(bucket, principal=principal)
    rate_limit_service.enforce_named_rate_limit(bucket, principal=principal)
    with pytest.raises(APIError):
        rate_limit_service.enforce_named_rate_limit(bucket, principal=principal)


def test_feature_flag_global_and_allowlist(db_session):
    allowlisted_user = uuid.uuid4()
    blocked_user = uuid.uuid4()
    db_session.add(
        FeatureFlag(
            key="ecom_enabled",
            is_enabled=False,
            scope=FeatureFlagScope.global_scope,
            rules={"allowlist_user_ids": [str(allowlisted_user)]},
        )
    )
    db_session.commit()

    assert is_feature_enabled(db_session, "ecom_enabled", user_id=blocked_user) is False
    assert is_feature_enabled(db_session, "ecom_enabled", user_id=allowlisted_user) is True


def test_webhook_signature_failures_are_logged(client, db_session):
    resp = client.post("/v1/webhooks/stripe", data=b"{}", headers={"stripe-signature": "bad"})
    assert resp.status_code == 401

    rows = db_session.query(WebhookSecurityLog).all()
    assert len(rows) == 1
    assert rows[0].provider == "stripe"
    assert rows[0].signature_valid is False


def test_chat_spam_creates_abuse_signal(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    db_session.commit()

    create = client.post(f"/v1/pros/{pro_id}/chats", headers={"X-User-Id": client_id})
    assert create.status_code == 200
    thread_id = create.json()["thread_id"]

    body = {"content": "spam spam spam"}
    first = client.post(f"/v1/chats/{thread_id}/messages", json=body, headers={"X-User-Id": client_id})
    second = client.post(f"/v1/chats/{thread_id}/messages", json=body, headers={"X-User-Id": client_id})
    third = client.post(f"/v1/chats/{thread_id}/messages", json=body, headers={"X-User-Id": client_id})

    assert first.status_code == 200
    assert second.status_code == 200
    assert third.status_code == 429

    signals = db_session.query(AbuseSignal).filter_by(signal_type="spam_chat").all()
    assert len(signals) >= 1


def test_sensitive_errors_are_safe_and_include_request_id(client, monkeypatch):
    def _boom(_db):
        raise RuntimeError("boom")

    monkeypatch.setattr("app.api.v1.discovery.ensure_initial_niches", _boom)
    resp = client.get("/v1/discover/pros", headers={"X-Request-Id": "req-safe-1"})

    assert resp.status_code == 500
    payload = resp.json()
    assert payload["error"]["code"] == "internal_error"
    assert payload["error"]["message"] == "Internal server error"
    assert payload["error"]["details"]["request_id"] == "req-safe-1"
    assert "type" not in payload["error"]["details"]
    assert resp.headers.get("x-request-id") == "req-safe-1"
