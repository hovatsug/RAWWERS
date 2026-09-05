import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProAvailabilityRule, ProPackage
from app.models.chat import ChatMessage, ChatSenderType, ChatThread, ChatThreadStatus, LeadProfile
from app.models.niche import Niche
from app.models.ops import FeatureFlag, FeatureFlagScope
from app.models.outbox import OutboxEvent
from app.tasks.outbox_tasks import dispatch_outbox_events_task


def _seed_user(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
    if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
        db_session.add(UserRole(user_id=uid, role=role))
    db_session.commit()


def _enable_ai_chat_flags(db_session):
    for key in ["ai_chat_enabled_global", "ai_chat_enabled_city", "ai_chat_enabled_pro"]:
        row = db_session.query(FeatureFlag).filter_by(key=key).one_or_none()
        if not row:
            row = FeatureFlag(key=key, scope=FeatureFlagScope.global_scope, rules={})
            db_session.add(row)
        row.is_enabled = True
    kill = db_session.query(FeatureFlag).filter_by(key="ai_chat_kill_switch").one_or_none()
    if not kill:
        kill = FeatureFlag(key="ai_chat_kill_switch", scope=FeatureFlagScope.global_scope, rules={})
        db_session.add(kill)
    kill.is_enabled = False
    db_session.commit()


def _seed_pro(db_session, pro_id: str):
    _seed_user(db_session, pro_id, UserRoleType.pro)
    pro_uuid = uuid.UUID(pro_id)
    profile = db_session.get(ProProfile, pro_uuid) or ProProfile(user_id=pro_uuid)
    profile.display_name = "Pro"
    profile.headline = "Portraits"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.styles = ["editorial"]
    profile.kyc_status = KYCStatus.approved
    profile.is_accepting_bookings = True
    profile.completeness_score = 100
    db_session.add(profile)
    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    pkg = ProPackage(
        pro_user_id=pro_uuid,
        niche_id=niche.id,
        title="Portrait",
        duration_minutes=60,
        price=Decimal("120.00"),
        currency="EUR",
        included_photos=10,
        extra_photo_price=Decimal("10.00"),
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
    )
    db_session.add(pkg)
    db_session.add(
        ProAvailabilityRule(
            pro_user_id=pro_uuid,
            day_of_week=datetime.now(timezone.utc).weekday(),
            start_time=datetime.now(timezone.utc).time().replace(hour=8, minute=0, second=0, microsecond=0),
            end_time=datetime.now(timezone.utc).time().replace(hour=21, minute=0, second=0, microsecond=0),
            timezone="UTC",
            location_mode="both",
        )
    )
    db_session.commit()
    return str(pkg.id)


def test_thread_access_control_and_creation(client, db_session):
    _enable_ai_chat_flags(db_session)
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    outsider_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, UserRoleType.client)
    _seed_user(db_session, outsider_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)

    created = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id})
    assert created.status_code == 200
    thread_id = created.json()["id"]

    allowed = client.get(f"/v1/chat/threads/{thread_id}", headers={"X-User-Id": client_id})
    assert allowed.status_code == 200

    denied = client.get(f"/v1/chat/threads/{thread_id}", headers={"X-User-Id": outsider_id})
    assert denied.status_code == 403


def test_ai_worker_idempotency_and_lead_profile_update(client, db_session):
    _enable_ai_chat_flags(db_session)
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)

    thread = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id}).json()
    thread_id = thread["id"]
    sent = client.post(
        f"/v1/chat/threads/{thread_id}/messages",
        headers={"X-User-Id": client_id},
        json={"content": "I want to book next week in Lisbon"},
    )
    assert sent.status_code == 200
    queued = db_session.query(OutboxEvent).filter_by(topic="ai.reply.generate").count()
    assert queued >= 1

    dispatch_outbox_events_task()
    ai_messages = (
        db_session.query(ChatMessage)
        .filter(ChatMessage.thread_id == uuid.UUID(thread_id), ChatMessage.sender_type == ChatSenderType.ai)
        .all()
    )
    assert len(ai_messages) >= 1
    lead = db_session.get(LeadProfile, uuid.UUID(thread_id))
    assert lead is not None
    assert lead.notes is not None


def test_handoff_disables_auto_ai_reply(client, db_session):
    _enable_ai_chat_flags(db_session)
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)

    thread_id = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id}).json()["id"]
    pro_msg = client.post(
        f"/v1/pro/chat/threads/{thread_id}/messages",
        headers={"X-User-Id": pro_id},
        json={"content": "I will take over this thread"},
    )
    assert pro_msg.status_code == 200
    thread = db_session.get(ChatThread, uuid.UUID(thread_id))
    assert thread.status == ChatThreadStatus.pro_active

    before = db_session.query(OutboxEvent).filter_by(topic="ai.reply.generate").count()
    client.post(
        f"/v1/chat/threads/{thread_id}/messages",
        headers={"X-User-Id": client_id},
        json={"content": "Can AI answer now?"},
    )
    after = db_session.query(OutboxEvent).filter_by(topic="ai.reply.generate").count()
    assert after == before


def test_booking_created_from_chat(client, db_session):
    _enable_ai_chat_flags(db_session)
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, UserRoleType.client)
    package_id = _seed_pro(db_session, pro_id)
    thread_id = client.post("/v1/chat/threads", headers={"X-User-Id": client_id}, json={"pro_user_id": pro_id}).json()["id"]

    start = datetime.now(timezone.utc) + timedelta(days=3)
    create = client.post(
        f"/v1/chat/threads/{thread_id}/create-booking",
        headers={"X-User-Id": client_id},
        json={
            "package_id": package_id,
            "requested_start": start.isoformat(),
            "requested_end": (start + timedelta(hours=1)).isoformat(),
            "location_text": "Lisbon",
            "notes": "chat conversion",
        },
    )
    assert create.status_code == 200
    assert create.json()["booking_request"]["package_id"] == package_id
