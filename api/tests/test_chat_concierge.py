import uuid
from datetime import datetime, timezone
from decimal import Decimal

from app.core.config import get_settings
from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProPackage
from app.models.niche import Niche


def _ensure_user_role(db_session, user_id: str, role: UserRoleType):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()
    exists = db_session.query(UserRole).filter_by(user_id=uid, role=role).first()
    if not exists:
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _seed_pro(db_session, pro_id: str):
    uid = uuid.UUID(pro_id)
    profile = db_session.get(ProProfile, uid)
    if not profile:
        profile = ProProfile(user_id=uid)
        db_session.add(profile)
    profile.display_name = "Test Pro"
    profile.headline = "Portraits"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.styles = ["portrait"]
    profile.languages = ["en"]
    profile.kyc_status = KYCStatus.approved
    profile.is_accepting_bookings = True
    profile.completeness_score = 100
    db_session.commit()


def _seed_package(db_session, pro_id: str, title: str = "Mini Session") -> str:
    niche_id = db_session.query(Niche).filter_by(slug="portraits").first().id
    pkg = ProPackage(
        pro_user_id=uuid.UUID(pro_id),
        niche_id=niche_id,
        title=title,
        duration_minutes=60,
        price=Decimal("120.00"),
        currency="EUR",
        included_photos=10,
        extra_photo_price=Decimal("8.00"),
        proofs_sla_days=3,
        finals_sla_days=7,
        addons=[],
        is_active=True,
    )
    db_session.add(pkg)
    db_session.commit()
    db_session.refresh(pkg)
    return str(pkg.id)


def test_ai_reply_is_grounded_to_snapshot_packages(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)
    _seed_package(db_session, pro_id, title="Portrait Basic")

    chat_resp = client.post(f"/v1/pros/{pro_id}/chats", headers={"X-User-Id": client_id})
    assert chat_resp.status_code == 200
    thread_id = chat_resp.json()["thread_id"]

    msg = client.post(
        f"/v1/chats/{thread_id}/messages",
        headers={"X-User-Id": client_id},
        json={"content": "Can you suggest options?"},
    )
    assert msg.status_code == 200
    appended = msg.json()["appended"]
    assert len(appended) == 2
    ai_text = appended[1]["content"]
    assert "Portrait Basic" in ai_text
    assert "Ultra Deluxe" not in ai_text


def test_pro_takeover_prevents_ai_replies(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)
    _seed_package(db_session, pro_id)

    thread_id = client.post(f"/v1/pros/{pro_id}/chats", headers={"X-User-Id": client_id}).json()["thread_id"]
    takeover = client.post(f"/v1/chats/{thread_id}/takeover", headers={"X-User-Id": pro_id}, json={"reason": "manual"})
    assert takeover.status_code == 200
    assert takeover.json()["status"] == "pro_takeover"

    msg = client.post(
        f"/v1/chats/{thread_id}/messages",
        headers={"X-User-Id": client_id},
        json={"content": "hello after takeover"},
    )
    assert msg.status_code == 200
    assert msg.json()["status"] == "pro_takeover"
    assert len(msg.json()["appended"]) == 1


def test_token_budget_limit_stops_ai_and_handoffs(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)
    _seed_package(db_session, pro_id)

    settings = get_settings()
    original = settings.llm_max_tokens_per_thread
    settings.llm_max_tokens_per_thread = 10
    try:
        thread_id = client.post(f"/v1/pros/{pro_id}/chats", headers={"X-User-Id": client_id}).json()["thread_id"]
        msg = client.post(
            f"/v1/chats/{thread_id}/messages",
            headers={"X-User-Id": client_id},
            json={"content": "I want to book"},
        )
        assert msg.status_code == 200
        assert msg.json()["status"] == "pro_takeover"
        assert "reached my assistant limit" in msg.json()["appended"][1]["content"]
    finally:
        settings.llm_max_tokens_per_thread = original


def test_create_booking_request_requires_draft_and_client_owner(client, db_session):
    pro_id = str(uuid.uuid4())
    client_id = str(uuid.uuid4())
    other_client_id = str(uuid.uuid4())
    _ensure_user_role(db_session, pro_id, UserRoleType.pro)
    _ensure_user_role(db_session, client_id, UserRoleType.client)
    _ensure_user_role(db_session, other_client_id, UserRoleType.client)
    _seed_pro(db_session, pro_id)
    package_id = _seed_package(db_session, pro_id)

    current_weekday = datetime.now(timezone.utc).weekday()
    rule_resp = client.post(
        "/v1/pro/me/availability/rules",
        headers={"X-User-Id": pro_id},
        json={"rules": [{"day_of_week": current_weekday, "start_time": "00:00:00", "end_time": "23:59:00"}]},
    )
    assert rule_resp.status_code == 200

    thread_id = client.post(f"/v1/pros/{pro_id}/chats", headers={"X-User-Id": client_id}).json()["thread_id"]

    # First message without booking intent: no draft.
    no_draft = client.post(
        f"/v1/chats/{thread_id}/messages",
        headers={"X-User-Id": client_id},
        json={"content": "Hi, just exploring."},
    )
    assert no_draft.status_code == 200
    create_without_draft = client.post(
        f"/v1/chats/{thread_id}/create-booking-request",
        headers={"X-User-Id": client_id},
    )
    assert create_without_draft.status_code == 409

    # Booking intent creates deterministic draft through mock provider.
    draft_resp = client.post(
        f"/v1/chats/{thread_id}/messages",
        headers={"X-User-Id": client_id},
        json={"content": f"Let's book package {package_id} now"},
    )
    assert draft_resp.status_code == 200

    outsider = client.post(
        f"/v1/chats/{thread_id}/create-booking-request",
        headers={"X-User-Id": other_client_id},
    )
    assert outsider.status_code == 403

    own = client.post(
        f"/v1/chats/{thread_id}/create-booking-request",
        headers={"X-User-Id": client_id},
    )
    assert own.status_code == 200
    assert own.json()["booking_request"]["package_id"] == package_id
