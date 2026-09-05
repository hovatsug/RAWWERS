import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProAvailabilityRule, ProPackage
from app.models.discovery import AnalyticsEvent, ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus, RolloutCity
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.ops import FeatureFlag, FeatureFlagScope

ADMIN_ID = "00000000-0000-0000-0000-0000000000aa"


def _seed_user(db_session, user_id: str, roles: list[UserRoleType] | None = None, email: str | None = None):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=email))
    for role in roles or []:
        existing = db_session.query(UserRole).filter_by(user_id=uid, role=role).one_or_none()
        if not existing:
            db_session.add(UserRole(user_id=uid, role=role))
    db_session.commit()


def _seed_pro(db_session, pro_id: str, *, city: str = "Lisbon", country: str = "PT", tier: SkillTier = SkillTier.pro) -> uuid.UUID:
    pro_uuid = uuid.UUID(pro_id)
    _seed_user(db_session, pro_id, [UserRoleType.pro], email=f"{pro_id}@example.com")
    profile = db_session.get(ProProfile, pro_uuid)
    if not profile:
        profile = ProProfile(user_id=pro_uuid)
        db_session.add(profile)
    profile.display_name = f"Pro {pro_id[:6]}"
    profile.headline = "Headline"
    profile.bio = "Bio text"
    profile.city = city
    profile.country = country
    profile.styles = ["editorial"]
    profile.is_accepting_bookings = True
    profile.completeness_score = 95
    profile.kyc_status = KYCStatus.approved

    onboarding = db_session.get(ProOnboarding, pro_uuid)
    if not onboarding:
        onboarding = ProOnboarding(pro_user_id=pro_uuid)
        db_session.add(onboarding)
    onboarding.status = ProOnboardingStatus.approved_public
    onboarding.current_city = {"city": city, "country": country}

    niche = db_session.query(Niche).filter_by(slug="portraits").first()
    existing_skill = db_session.query(ProNicheSkill).filter_by(pro_user_id=pro_uuid, niche_id=niche.id).one_or_none()
    if not existing_skill:
        existing_skill = ProNicheSkill(pro_user_id=pro_uuid, niche_id=niche.id)
        db_session.add(existing_skill)
    existing_skill.tier = tier
    existing_skill.capability_score = 80
    existing_skill.certification_score = 70
    existing_skill.confidence = Decimal("0.8")
    existing_skill.breakdown = {}
    db_session.flush()

    pkg = db_session.query(ProPackage).filter_by(pro_user_id=pro_uuid).first()
    if not pkg:
        pkg = ProPackage(
            pro_user_id=pro_uuid,
            niche_id=niche.id,
            title="Session",
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

    idx = db_session.get(ProPublicIndex, pro_uuid)
    if not idx:
        idx = ProPublicIndex(pro_user_id=pro_uuid)
        db_session.add(idx)
    idx.city = city
    idx.country = country
    idx.top_niches = [{"slug": "portraits"}]
    idx.min_package_price = Decimal("120.00")
    idx.max_package_price = Decimal("200.00")
    idx.currency = "EUR"
    idx.is_accepting_bookings = True
    idx.kyc_status = KYCStatus.approved
    idx.completeness_score = 95
    idx.avg_rating = Decimal("4.80")
    idx.review_count = 20
    idx.ranking_score = Decimal("200.0000")
    idx.portfolio_photo_count = 10
    idx.portfolio_video_count = 2
    idx.disputes_count = 0
    idx.gigs_completed = 20
    idx.gigs_cancelled = 1
    db_session.commit()
    return pro_uuid


def _enable_city_and_flags(db_session, *, city: str = "Lisbon", country: str = "PT"):
    rollout = db_session.query(RolloutCity).filter_by(country=country, city=city).one_or_none()
    if not rollout:
        rollout = RolloutCity(country=country, city=city)
        db_session.add(rollout)
    rollout.is_client_browsing_enabled = True

    for key, value in [
        ("client_browsing_enabled_global", True),
        ("client_booking_enabled", True),
        ("guest_discovery_enabled", True),
    ]:
        row = db_session.query(FeatureFlag).filter_by(key=key).one_or_none()
        if not row:
            row = FeatureFlag(key=key, scope=FeatureFlagScope.global_scope, rules={})
            db_session.add(row)
        row.is_enabled = value
        row.scope = FeatureFlagScope.global_scope
    db_session.commit()


def test_rollout_gate_enforced_per_city(client, db_session):
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id, city="Lisbon", country="PT")
    _enable_city_and_flags(db_session, city="Lisbon", country="PT")

    denied = client.get("/v1/client/access", params={"country": "PT", "city": "Porto"})
    assert denied.status_code == 200
    assert denied.json()["enabled"] is False

    discover_denied = client.get("/v1/client/discover", params={"country": "PT", "city": "Porto", "niche_slug": "portraits"})
    assert discover_denied.status_code == 403

    allowed = client.get("/v1/client/discover", params={"country": "PT", "city": "Lisbon", "niche_slug": "portraits"})
    assert allowed.status_code == 200
    assert isinstance(allowed.json()["items"], list)


def test_matching_is_deterministic_ranked(client, db_session):
    _enable_city_and_flags(db_session)
    pro_a = str(uuid.uuid4())
    pro_b = str(uuid.uuid4())
    _seed_pro(db_session, pro_a, tier=SkillTier.master)
    _seed_pro(db_session, pro_b, tier=SkillTier.skilled)
    db_session.add(
        ProAvailabilityRule(
            pro_user_id=uuid.UUID(pro_a),
            day_of_week=0,
            start_time=datetime(2026, 1, 1, 9, 0).time(),
            end_time=datetime(2026, 1, 1, 18, 0).time(),
        )
    )
    db_session.commit()

    user_id = str(uuid.uuid4())
    _seed_user(db_session, user_id, [UserRoleType.client])
    payload = {
        "country": "PT",
        "city": "Lisbon",
        "niche_slug": "portraits",
        "budget_min": "100.00",
        "budget_max": "300.00",
        "style_tags": ["editorial"],
    }
    first = client.post("/v1/client/match", headers={"X-User-Id": user_id}, json=payload)
    second = client.post("/v1/client/match", headers={"X-User-Id": user_id}, json=payload)
    assert first.status_code == 200
    assert second.status_code == 200
    first_ids = [item["pro_user_id"] for item in first.json()["items"]]
    second_ids = [item["pro_user_id"] for item in second.json()["items"]]
    assert first_ids == second_ids
    assert first_ids[0] == pro_a


def test_booking_request_rate_limit_enforced(client, db_session):
    _enable_city_and_flags(db_session)
    pro_id = str(uuid.uuid4())
    pro_uuid = _seed_pro(db_session, pro_id)
    db_session.add(
        ProAvailabilityRule(
            pro_user_id=pro_uuid,
            day_of_week=0,
            start_time=datetime(2026, 1, 1, 9, 0).time(),
            end_time=datetime(2026, 1, 1, 18, 0).time(),
        )
    )
    db_session.commit()
    pkg_id = str(db_session.query(ProPackage).filter_by(pro_user_id=pro_uuid).first().id)

    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, [UserRoleType.client])

    base = datetime(2026, 3, 2, 10, 0, tzinfo=timezone.utc)
    for idx in range(5):
        resp = client.post(
            "/v1/client/bookings/request",
            headers={"X-User-Id": client_id},
            json={
                "pro_user_id": pro_id,
                "niche_slug": "portraits",
                "date_window": {"start_at": (base + timedelta(hours=idx)).isoformat(), "end_at": (base + timedelta(hours=idx + 1)).isoformat()},
                "location": "Lisbon",
                "package_id": pkg_id,
                "notes": "test",
            },
        )
        assert resp.status_code == 200

    blocked = client.post(
        "/v1/client/bookings/request",
        headers={"X-User-Id": client_id},
        json={
            "pro_user_id": pro_id,
            "niche_slug": "portraits",
            "date_window": {"start_at": (base + timedelta(hours=8)).isoformat(), "end_at": (base + timedelta(hours=9)).isoformat()},
            "location": "Lisbon",
            "package_id": pkg_id,
            "notes": "over-limit",
        },
    )
    assert blocked.status_code == 429


def test_client_pro_profile_does_not_leak_pii(client, db_session):
    _enable_city_and_flags(db_session)
    pro_id = str(uuid.uuid4())
    pro_uuid = _seed_pro(db_session, pro_id)
    account = db_session.get(UserAccount, pro_uuid)
    account.email = "private@example.com"
    account.phone_e164 = "+351999999999"
    db_session.commit()

    client_id = str(uuid.uuid4())
    _seed_user(db_session, client_id, [UserRoleType.client])

    resp = client.get(f"/v1/client/pros/{pro_id}", params={"country": "PT", "city": "Lisbon"}, headers={"X-User-Id": client_id})
    assert resp.status_code == 200
    payload = resp.json()
    assert "email" not in payload
    assert "phone_e164" not in payload
    assert "phone" not in payload


def test_admin_client_funnel_metrics(client, db_session):
    _seed_user(db_session, ADMIN_ID, [UserRoleType.admin])
    now = datetime.now(timezone.utc)
    for event_name in [
        "client.discover_view",
        "client.pro_profile_view",
        "client.booking_request_created",
        "client.payment_succeeded",
        "client.proofs_viewed",
        "client.extras_purchased",
        "client.dispute_opened",
    ]:
        db_session.add(
            AnalyticsEvent(
                user_id=uuid.uuid4(),
                event_name=event_name,
                properties={"country": "PT", "city": "Lisbon"},
                created_at=now,
            )
        )
    db_session.commit()

    resp = client.get("/v1/admin/funnel/clients", headers={"X-User-Id": ADMIN_ID, "X-Admin-Api-Key": ""})
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) == 1
    row = items[0]
    assert row["discover_views"] == 1
    assert row["pro_profile_views"] == 1
    assert row["booking_requests"] == 1
    assert row["payments_succeeded"] == 1
