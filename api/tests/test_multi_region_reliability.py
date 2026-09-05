import uuid
from decimal import Decimal

from app.api.deps import get_db_read_session, get_db_write_session
from app.main import app
from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.discovery import ProPublicIndex
from app.models.outbox import IdempotencyKey, OutboxEvent, OutboxEventStatus
from app.tasks.outbox_tasks import dispatch_outbox_events_task


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    row = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not row:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def test_read_write_routing_dependencies(client, db_session):
    counts = {"read": 0, "write": 0}

    def _read_override():
        counts["read"] += 1
        yield db_session

    def _write_override():
        counts["write"] += 1
        yield db_session

    app.dependency_overrides[get_db_read_session] = _read_override
    app.dependency_overrides[get_db_write_session] = _write_override

    user_id = str(uuid.uuid4())
    _ensure_user_role(db_session, user_id, UserRoleType.client)

    public_resp = client.get("/v1/courses")
    assert public_resp.status_code == 200
    write_resp = client.get("/v1/referrals/me", headers={"X-User-Id": user_id})
    assert write_resp.status_code == 200

    assert counts["read"] > 0
    assert counts["write"] > 0


def test_webhook_outbox_durable_and_idempotent(client, db_session, monkeypatch):
    from app.api.v1 import webhooks as webhooks_module

    event = {
        "id": "evt_outbox_1",
        "type": "payment_intent.unknown",
        "data": {"object": {"id": "pi_outbox_1"}},
    }
    monkeypatch.setattr(webhooks_module, "construct_stripe_event", lambda raw_body, signature: event)
    r1 = client.post("/v1/webhooks/stripe", json=event)
    assert r1.status_code == 200
    assert db_session.query(OutboxEvent).count() == 1
    assert db_session.query(IdempotencyKey).count() == 1

    processed = dispatch_outbox_events_task(limit=50)
    assert processed >= 1
    outbox_row = db_session.query(OutboxEvent).first()
    assert outbox_row is not None
    assert outbox_row.status == OutboxEventStatus.delivered

    r2 = client.post("/v1/webhooks/stripe", json=event)
    assert r2.status_code == 200
    assert db_session.query(OutboxEvent).count() == 1
    assert db_session.query(IdempotencyKey).count() == 1


def test_discover_cache_and_index_version_invalidation(client, db_session, monkeypatch):
    from app.api.v1 import discovery as discovery_module

    pro_user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro_user_id, display_name="Public Pro"))
    db_session.add(
        ProProfile(
            user_id=pro_user_id,
            display_name="Public Pro",
            city="Lisbon",
            country="PT",
            styles=["editorial"],
            kyc_status=KYCStatus.approved,
            completeness_score=90,
            is_accepting_bookings=True,
        )
    )
    db_session.add(
        ProPublicIndex(
            pro_user_id=pro_user_id,
            city="Lisbon",
            country="PT",
            styles=["editorial"],
            min_package_price=Decimal("120.00"),
            max_package_price=Decimal("200.00"),
            currency="EUR",
            is_accepting_bookings=True,
            kyc_status=KYCStatus.approved,
            completeness_score=90,
            ranking_score=Decimal("123.0000"),
            portfolio_photo_count=1,
            portfolio_video_count=0,
            gigs_completed=1,
            gigs_cancelled=0,
            disputes_count=0,
            avg_rating=Decimal("5.00"),
            review_count=1,
            top_niches=[],
        )
    )
    db_session.commit()

    storage: dict[str, dict] = {}
    set_calls: list[str] = []
    version = {"v": 0}

    monkeypatch.setattr(discovery_module, "cache_get_json", lambda key: storage.get(key))
    monkeypatch.setattr(discovery_module, "cache_set_json", lambda key, payload, ttl_seconds: (storage.__setitem__(key, payload), set_calls.append(key)))
    monkeypatch.setattr(discovery_module, "get_public_index_version", lambda: version["v"])

    first = client.get("/v1/discover/pros")
    assert first.status_code == 200
    assert len(set_calls) == 1

    second = client.get("/v1/discover/pros")
    assert second.status_code == 200
    assert len(set_calls) == 1

    version["v"] = 1
    third = client.get("/v1/discover/pros")
    assert third.status_code == 200
    assert len(set_calls) == 2
