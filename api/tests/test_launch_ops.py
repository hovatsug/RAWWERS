import uuid
from decimal import Decimal

from sqlalchemy import select

from app.models.admin import AdminAuditLog, KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProPackage
from app.models.launch_ops import InviteCodeStatus, ProOnboardingStatus
from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche, ProNiche
from app.models.outbox import OutboxEvent

ADMIN_USER_ID = "00000000-0000-0000-0000-0000000000aa"


def _seed_pro(db_session, pro_id: str) -> uuid.UUID:
    uid = uuid.UUID(pro_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{pro_id[:8]}@example.com"))
    if not db_session.query(UserRole).filter_by(user_id=uid, role=UserRoleType.pro).one_or_none():
        db_session.add(UserRole(user_id=uid, role=UserRoleType.pro))
    profile = db_session.get(ProProfile, uid)
    if not profile:
        profile = ProProfile(user_id=uid)
        db_session.add(profile)
    db_session.commit()
    return uid


def _seed_admin(db_session) -> None:
    aid = uuid.UUID(ADMIN_USER_ID)
    if not db_session.get(UserAccount, aid):
        db_session.add(UserAccount(user_id=aid, email="admin@example.com"))
    if not db_session.query(UserRole).filter_by(user_id=aid, role=UserRoleType.admin).one_or_none():
        db_session.add(UserRole(user_id=aid, role=UserRoleType.admin))
    db_session.commit()


def test_rollout_city_gate_blocks_onboarding_start_without_override_or_invite(client, db_session):
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)

    denied = client.post(
        "/v1/pro/onboarding/start",
        headers={"X-User-Id": pro_id},
        json={"city": "Lisbon", "country": "PT"},
    )
    assert denied.status_code == 403


def test_invite_code_redemption_rules(client, db_session):
    _seed_admin(db_session)
    pro_id = str(uuid.uuid4())
    other_pro = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    _seed_pro(db_session, other_pro)

    wave = client.post(
        "/v1/admin/invites/waves",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={
            "code_prefix": "LON-ALPHA",
            "name": "London Alpha",
            "max_invites": 1,
            "allowed_role": "pro",
            "allowed_cities": [{"city": "London", "country": "GB"}],
        },
    )
    assert wave.status_code == 200
    wave_id = wave.json()["id"]
    generated = client.post(
        f"/v1/admin/invites/waves/{wave_id}/generate",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={"count": 1},
    )
    code = generated.json()["items"][0]["code"]

    wrong_city = client.post(
        "/v1/pro/onboarding/start",
        headers={"X-User-Id": pro_id},
        json={"city": "Porto", "country": "PT", "invite_code": code},
    )
    assert wrong_city.status_code == 403

    ok = client.post(
        "/v1/pro/onboarding/start",
        headers={"X-User-Id": pro_id},
        json={"city": "London", "country": "GB", "invite_code": code},
    )
    assert ok.status_code == 200

    reused = client.post(
        "/v1/pro/onboarding/start",
        headers={"X-User-Id": other_pro},
        json={"city": "London", "country": "GB", "invite_code": code},
    )
    assert reused.status_code == 409

    listing = client.get(
        "/v1/admin/invites/codes",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
    )
    assert listing.status_code == 200
    assert any(item["status"] == InviteCodeStatus.redeemed.value for item in listing.json()["items"])


def test_onboarding_transitions_requirements_and_approve_triggers_events(client, db_session):
    _seed_admin(db_session)
    pro_id = str(uuid.uuid4())
    pro_uuid = _seed_pro(db_session, pro_id)
    niche_id = db_session.execute(select(Niche.id)).scalar_one()

    # allow city onboarding + browsing
    rollout = client.put(
        "/v1/admin/rollout/cities",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json=[{"country": "PT", "city": "Lisbon", "is_pro_onboarding_enabled": True, "is_client_browsing_enabled": True, "metadata": {}}],
    )
    assert rollout.status_code == 200

    started = client.post(
        "/v1/pro/onboarding/start",
        headers={"X-User-Id": pro_id},
        json={"city": "Lisbon", "country": "PT"},
    )
    assert started.status_code == 200

    # profile not complete yet
    fail_profile = client.post("/v1/pro/onboarding/complete-profile", headers={"X-User-Id": pro_id})
    assert fail_profile.status_code == 422

    profile = db_session.get(ProProfile, pro_uuid)
    profile.display_name = "Pro"
    profile.headline = "Head"
    profile.bio = "Bio"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.completeness_score = 80
    db_session.commit()

    ok_profile = client.post("/v1/pro/onboarding/complete-profile", headers={"X-User-Id": pro_id})
    assert ok_profile.status_code == 200

    # seed enough portfolio assets
    for _ in range(12):
        db_session.add(
            MediaAsset(
                owner_user_id=pro_uuid,
                kind=MediaKind.photo,
                purpose=MediaPurpose.portfolio_reel,
                provider=MediaProvider.r2,
                status=MediaStatus.ready,
                visibility=MediaVisibility.owner_only,
                content_type="image/jpeg",
                meta={},
            )
        )
    db_session.commit()
    assert client.post("/v1/pro/onboarding/upload-portfolio", headers={"X-User-Id": pro_id}).status_code == 200

    # package + extra price config requirement
    db_session.add(
        ProPackage(
            pro_user_id=pro_uuid,
            niche_id=niche_id,
            title="Base",
            description=None,
            duration_minutes=60,
            price=Decimal("120.00"),
            currency="EUR",
            included_photos=5,
            extra_photo_price=Decimal("10.00"),
            proofs_sla_days=3,
            finals_sla_days=7,
            addons=[],
            is_active=True,
        )
    )
    db_session.commit()
    fail_packages = client.post("/v1/pro/onboarding/configure-packages", headers={"X-User-Id": pro_id})
    assert fail_packages.status_code == 422

    client.put(
        f"/v1/admin/pricing/pro-extra-image-price/{pro_id}",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={"items": [{"niche_slug": db_session.get(Niche, niche_id).slug, "configured_unit_price": "10.00", "currency": "EUR"}]},
    )
    assert client.post("/v1/pro/onboarding/configure-packages", headers={"X-User-Id": pro_id}).status_code == 200

    db_session.add(ProNiche(pro_user_id=pro_uuid, niche_id=niche_id))
    db_session.commit()
    assert client.post("/v1/pro/onboarding/select-niches", headers={"X-User-Id": pro_id}).status_code == 200

    submit_kyc = client.post("/v1/pro/onboarding/submit-kyc", headers={"X-User-Id": pro_id})
    assert submit_kyc.status_code == 200
    assert submit_kyc.json()["status"] == ProOnboardingStatus.kyc_submitted.value

    kyc = client.post(
        f"/v1/admin/pros/{pro_id}/kyc",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={"kyc_status": KYCStatus.approved.value, "note": "approved"},
    )
    assert kyc.status_code == 200

    approve = client.post(
        f"/v1/admin/onboarding/pros/{pro_id}/approve",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
    )
    assert approve.status_code == 200
    assert approve.json()["status"] == ProOnboardingStatus.approved_public.value

    outbox = db_session.query(OutboxEvent).all()
    assert any(item.topic == "reindex.pro" for item in outbox)
    assert any(item.topic == "notify.create_inapp" and (item.payload or {}).get("type") == "onboarding.approved_public" for item in outbox)

    audits = db_session.query(AdminAuditLog).filter(AdminAuditLog.action.in_(["onboarding_approved_public", "kyc_approved"])).all()
    assert len(audits) >= 2


def test_admin_reject_writes_audit(client, db_session):
    _seed_admin(db_session)
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    client.put(
        "/v1/admin/rollout/cities",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json=[{"country": "PT", "city": "Porto", "is_pro_onboarding_enabled": True, "is_client_browsing_enabled": False, "metadata": {}}],
    )
    client.post(
        "/v1/pro/onboarding/start",
        headers={"X-User-Id": pro_id},
        json={"city": "Porto", "country": "PT"},
    )
    rejected = client.post(
        f"/v1/admin/onboarding/pros/{pro_id}/reject",
        headers={"X-User-Id": ADMIN_USER_ID, "X-Admin-Api-Key": ""},
        json={"status": "rejected", "note": "quality"},
    )
    assert rejected.status_code == 200
    log = db_session.query(AdminAuditLog).filter_by(action="onboarding_rejected").one_or_none()
    assert log is not None
