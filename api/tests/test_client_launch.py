import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProAvailabilityRule, ProPackage
from app.models.discovery import AnalyticsEvent, ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus, RolloutCity
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.ops import FeatureFlag, FeatureFlagScope

def _ahead(weekday: int, hour: int) -> datetime:
    """That weekday and hour a few weeks from now, in UTC.

    These used fixed dates in March 2026, which only worked while no booking
    path compared a requested time with "now". Every path now refuses a time
    inside the photographer's notice period, and a past time is inside it.
    """
    base = datetime.now(timezone.utc).date() + timedelta(weeks=3)
    day = base + timedelta(days=(weekday - base.weekday()) % 7)
    return datetime(day.year, day.month, day.day, hour, 0, tzinfo=timezone.utc)


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

    # Two hours apart, 09:00 to 17:00: a pending request now holds its hour
    # and its buffers, so back-to-back hours would clash before the rate
    # limit was ever reached - and this test is about the rate limit.
    base = _ahead(0, 9)
    for idx in range(5):
        resp = client.post(
            "/v1/client/bookings/request",
            headers={"X-User-Id": client_id},
            json={
                "pro_user_id": pro_id,
                "niche_slug": "portraits",
                "date_window": {"start_at": (base + timedelta(hours=2 * idx)).isoformat(), "end_at": (base + timedelta(hours=2 * idx + 1)).isoformat()},
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


def _profile(client, pro_id: str, client_id: str) -> dict:
    """Fetch a public profile, refusing to hand back anything but a 200.

    The first version of these tests read `body["niches"]` straight off the
    response and failed with a KeyError. The cause was a 403 - the rollout
    city was not enabled in the test database - so five tests reported a
    missing field when the request had never reached the endpoint.
    """
    resp = client.get(
        f"/v1/client/pros/{pro_id}",
        params={"country": "PT", "city": "Lisbon"},
        headers={"X-User-Id": client_id},
    )
    assert resp.status_code == 200, f"profile request failed: {resp.status_code} {resp.text}"
    return resp.json()


# ---------------------------------------------------------------------------
# A multi-niche portfolio has to be separable by the client.
# ---------------------------------------------------------------------------


def _seed_portfolio_photo(db_session, pro_uuid: uuid.UUID, *, tags: list[str], index: int) -> uuid.UUID:
    from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus, MediaVisibility

    asset_id = uuid.uuid5(uuid.NAMESPACE_URL, f"test-portfolio:{pro_uuid}:{index}")
    db_session.add(
        MediaAsset(
            id=asset_id,
            owner_user_id=pro_uuid,
            kind=MediaKind.photo,
            purpose=MediaPurpose.portfolio_reel,
            provider=MediaProvider.r2,
            status=MediaStatus.ready,
            visibility=MediaVisibility.public,
            content_type="image/jpeg",
            byte_size=1000,
            checksum=f"test-{index}",
            niche_tags=tags,
            meta={},
        )
    )
    db_session.flush()
    return asset_id


def test_a_multi_niche_portfolio_says_which_niche_each_photo_belongs_to(client, db_session):
    """Without the tags the client cannot split the grid at all - a wedding, a
    studio portrait and a festival crowd shot arrive indistinguishable."""
    pro_id = "00000000-0000-0000-0000-0000000009a1"
    pro_uuid = _seed_pro(db_session, pro_id)
    client_id = "00000000-0000-0000-0000-0000000009b1"
    _seed_user(db_session, client_id, [UserRoleType.client])
    for i in range(3):
        _seed_portfolio_photo(db_session, pro_uuid, tags=["weddings"], index=i)
    _seed_portfolio_photo(db_session, pro_uuid, tags=["portraits"], index=9)
    _enable_city_and_flags(db_session)
    db_session.commit()

    body = _profile(client, pro_id, client_id)

    tags = [item["niche_slugs"] for item in body["portfolio_preview"]]
    assert any("weddings" in t for t in tags), "no photo carries its niche, so the grid cannot be split"
    assert any("portraits" in t for t in tags)


def test_the_niche_list_is_ordered_by_how_much_work_is_in_each(client, db_session):
    """A tab bar led by the niche with one photo in it misrepresents what the
    photographer mostly does."""
    pro_id = "00000000-0000-0000-0000-0000000009a2"
    pro_uuid = _seed_pro(db_session, pro_id)
    client_id = "00000000-0000-0000-0000-0000000009b2"
    _seed_user(db_session, client_id, [UserRoleType.client])
    for i in range(4):
        _seed_portfolio_photo(db_session, pro_uuid, tags=["weddings"], index=i)
    _seed_portfolio_photo(db_session, pro_uuid, tags=["portraits"], index=9)
    _enable_city_and_flags(db_session)
    db_session.commit()

    body = _profile(client, pro_id, client_id)

    niches = body["niches"]
    assert [n["slug"] for n in niches] == ["weddings", "portraits"], "niches are not ordered by volume of work"
    assert [n["photo_count"] for n in niches] == [4, 1]


def test_a_single_niche_photographer_still_gets_their_niche_and_tier(client, db_session):
    """The niche list carries the tier, so withholding it for a single-niche
    photographer hid the tier on 32 of 42 profiles.

    Whether one niche is worth a selector is a presentation question and
    belongs to the client - see the widget test that asserts no selector is
    drawn. The server states what is true."""
    pro_id = "00000000-0000-0000-0000-0000000009a3"
    pro_uuid = _seed_pro(db_session, pro_id)
    client_id = "00000000-0000-0000-0000-0000000009b3"
    _seed_user(db_session, client_id, [UserRoleType.client])
    for i in range(3):
        _seed_portfolio_photo(db_session, pro_uuid, tags=["portraits"], index=i)
    _enable_city_and_flags(db_session)
    db_session.commit()

    body = _profile(client, pro_id, client_id)
    assert [n["slug"] for n in body["niches"]] == ["portraits"]
    assert body["niches"][0]["tier"] == "pro", "the tier is missing, so the profile cannot show it"


def test_the_niche_list_carries_the_tier_held_in_that_niche(client, db_session):
    """Tier is per-niche. A badge showing the same tier on every tab is the
    flat presentation the per-niche model exists to replace."""
    pro_id = "00000000-0000-0000-0000-0000000009a4"
    pro_uuid = _seed_pro(db_session, pro_id, tier=SkillTier.master)
    client_id = "00000000-0000-0000-0000-0000000009b4"
    _seed_user(db_session, client_id, [UserRoleType.client])

    weddings = db_session.query(Niche).filter_by(slug="weddings").first()
    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_uuid,
            niche_id=weddings.id,
            tier=SkillTier.rookie,
            capability_score=5,
            certification_score=5,
            confidence=Decimal("0.1"),
            breakdown={},
        )
    )
    for i in range(3):
        _seed_portfolio_photo(db_session, pro_uuid, tags=["weddings"], index=i)
    _seed_portfolio_photo(db_session, pro_uuid, tags=["portraits"], index=9)
    _enable_city_and_flags(db_session)
    db_session.commit()

    body = _profile(client, pro_id, client_id)
    by_slug = {n["slug"]: n["tier"] for n in body["niches"]}
    assert by_slug["weddings"] == "rookie"
    assert by_slug["portraits"] == "master", "the tier is not read per niche"


def test_a_niche_with_no_photos_is_not_offered_as_a_tab(client, db_session):
    """recompute_pro_niche_skills writes a row for every active niche, so a
    tab list built from skills would offer twelve tabs and leave ten empty."""
    pro_id = "00000000-0000-0000-0000-0000000009a5"
    pro_uuid = _seed_pro(db_session, pro_id)
    client_id = "00000000-0000-0000-0000-0000000009b5"
    _seed_user(db_session, client_id, [UserRoleType.client])

    for slug in ["food", "real_estate", "corporate"]:
        niche = db_session.query(Niche).filter_by(slug=slug).first()
        db_session.add(
            ProNicheSkill(
                pro_user_id=pro_uuid,
                niche_id=niche.id,
                tier=SkillTier.elite,
                capability_score=90,
                certification_score=90,
                confidence=Decimal("0.9"),
                breakdown={},
            )
        )
    for i in range(2):
        _seed_portfolio_photo(db_session, pro_uuid, tags=["weddings"], index=i)
    _seed_portfolio_photo(db_session, pro_uuid, tags=["portraits"], index=9)
    _enable_city_and_flags(db_session)
    db_session.commit()

    body = _profile(client, pro_id, client_id)
    slugs = {n["slug"] for n in body["niches"]}
    assert slugs == {"weddings", "portraits"}, f"niches with no photos were offered as tabs: {slugs}"


def test_a_niche_description_is_returned_when_written_and_null_when_not(client, db_session):
    """The client falls back to the general bio when this is null, so the two
    cases must stay distinguishable. A column that always came back null would
    make the written case dead code - which it was, for exactly as long as the
    seeder created no ProNiche rows at all."""
    from app.models.niche import ProNiche

    pro_id = "00000000-0000-0000-0000-0000000009a6"
    pro_uuid = _seed_pro(db_session, pro_id)
    client_id = "00000000-0000-0000-0000-0000000009b6"
    _seed_user(db_session, client_id, [UserRoleType.client])

    weddings = db_session.query(Niche).filter_by(slug="weddings").first()
    portraits = db_session.query(Niche).filter_by(slug="portraits").first()
    db_session.add(
        ProNiche(pro_user_id=pro_uuid, niche_id=weddings.id, description="Long days, shot quietly.")
    )
    # Declared, but nothing written about it.
    db_session.add(ProNiche(pro_user_id=pro_uuid, niche_id=portraits.id))
    for i in range(3):
        _seed_portfolio_photo(db_session, pro_uuid, tags=["weddings"], index=i)
    _seed_portfolio_photo(db_session, pro_uuid, tags=["portraits"], index=9)
    _enable_city_and_flags(db_session)
    db_session.commit()

    body = _profile(client, pro_id, client_id)
    by_slug = {n["slug"]: n["description"] for n in body["niches"]}
    assert by_slug["weddings"] == "Long days, shot quietly."
    assert by_slug["portraits"] is None, "an undescribed niche must stay null so the client can fall back"
