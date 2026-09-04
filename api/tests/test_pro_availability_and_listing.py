"""P-2: the pro-side gaps, and the blocked-time hole underneath them.

The bug these were written for: a photographer who blocks time off could
still be booked into it. Blocked time lives in two tables written by two
endpoints, and enforcement read one or the other depending on which route
created the booking - so on the client funnel, the one both apps actually
use, neither was checked.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

from app.models.admin import KYCStatus, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import (
    BookingRequest,
    BookingRequestStatus,
    ProAvailabilityException,
    ProAvailabilityRule,
    ProBlackoutDate,
)
from app.models.niche import Niche
from app.models.repair import GearCategory, GearItem, RepairTicket


def _ensure_user(db_session, user_id: str, role: UserRoleType) -> uuid.UUID:
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid, email=f"{user_id}@example.com"))
        db_session.commit()
    if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()
    return uid


def _seed_pro(db_session, pro_id: str, *, kyc: KYCStatus = KYCStatus.approved) -> uuid.UUID:
    uid = _ensure_user(db_session, pro_id, UserRoleType.pro)
    profile = db_session.get(ProProfile, uid)
    if not profile:
        profile = ProProfile(user_id=uid)
        db_session.add(profile)
    profile.kyc_status = kyc
    profile.display_name = "Alex Lens"
    profile.headline = "Portraits in daylight"
    profile.bio = "A long enough bio to count."
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.languages = ["en"]
    profile.styles = ["editorial"]
    profile.gear = {"camera": "A7"}
    profile.completeness_score = 100
    db_session.commit()
    return uid


def _add_weekly_rules(db_session, pro_uid: uuid.UUID) -> None:
    """Every day, all day - so a refusal in these tests can only come from
    blocked time, never from falling outside working hours."""
    from datetime import time as dtime

    for day in range(7):
        db_session.add(
            ProAvailabilityRule(
                pro_user_id=pro_uid,
                day_of_week=day,
                start_time=dtime(0, 0),
                end_time=dtime(23, 59),
            )
        )
    db_session.commit()


def _create_package(client, pro_id: str) -> str:
    resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Mini Session",
            "niche_slug": "portraits",
            "duration_minutes": 60,
            "price": "120.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
            "proofs_sla_days": 3,
            "finals_sla_days": 7,
            "addons": [],
        },
    )
    assert resp.status_code == 200, resp.text
    return resp.json()["id"]


def _honeymoon(days_out: int = 30, length_days: int = 14) -> tuple[datetime, datetime]:
    start = datetime.now(timezone.utc) + timedelta(days=days_out)
    return start, start + timedelta(days=length_days)


# --- the bug -----------------------------------------------------------


def test_blackout_blocks_accepting_a_booking_inside_it(client, db_session):
    """The honeymoon case, through the old blackout route.

    Accept is the moment the gig is created and the dates are written, and
    it used to check nothing at all.
    """
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    _ensure_user(db_session, client_id, UserRoleType.client)
    _add_weekly_rules(db_session, pro_uid)
    package_id = _create_package(client, pro_id)

    block_start, block_end = _honeymoon()
    db_session.add(
        ProBlackoutDate(pro_user_id=pro_uid, start_at=block_start, end_at=block_end, reason="honeymoon")
    )
    db_session.commit()

    booking = BookingRequest(
        pro_user_id=pro_uid,
        client_user_id=uuid.UUID(client_id),
        package_id=uuid.UUID(package_id),
        requested_start=block_start + timedelta(days=2),
        requested_end=block_start + timedelta(days=2, hours=3),
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
    )
    db_session.add(booking)
    db_session.commit()

    resp = client.post(f"/v1/booking-requests/{booking.id}/accept", headers={"X-User-Id": pro_id})
    assert resp.status_code == 409, resp.text
    assert "blocked off" in resp.json()["error"]["message"]


def test_scheduling_exception_blocks_accepting_a_booking_inside_it(client, db_session):
    """Same guarantee through the successor route - the one photographers
    are now steered to. Blocking time must not depend on which endpoint
    happened to record it."""
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    _ensure_user(db_session, client_id, UserRoleType.client)
    _add_weekly_rules(db_session, pro_uid)
    package_id = _create_package(client, pro_id)

    block_start, block_end = _honeymoon()
    db_session.add(
        ProAvailabilityException(
            pro_user_id=pro_uid, start_at_utc=block_start, end_at_utc=block_end, reason="honeymoon"
        )
    )
    db_session.commit()

    booking = BookingRequest(
        pro_user_id=pro_uid,
        client_user_id=uuid.UUID(client_id),
        package_id=uuid.UUID(package_id),
        requested_start=block_start + timedelta(days=2),
        requested_end=block_start + timedelta(days=2, hours=3),
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
    )
    db_session.add(booking)
    db_session.commit()

    resp = client.post(f"/v1/booking-requests/{booking.id}/accept", headers={"X-User-Id": pro_id})
    assert resp.status_code == 409, resp.text


def test_a_window_only_partly_blocked_can_still_be_accepted(client, db_session):
    """A client asking for "sometime next fortnight" who clips one blocked
    afternoon has still asked for something the pro can do. Refusing here
    would push clients toward narrow windows, which is the opposite of what
    a flexible request is for - the exact time is pinned at confirm-slot,
    which checks the precise slot."""
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    _ensure_user(db_session, client_id, UserRoleType.client)
    _add_weekly_rules(db_session, pro_uid)
    package_id = _create_package(client, pro_id)

    window_start = datetime.now(timezone.utc) + timedelta(days=30)
    window_end = window_start + timedelta(days=7)
    db_session.add(
        ProBlackoutDate(
            pro_user_id=pro_uid,
            start_at=window_start + timedelta(days=1),
            end_at=window_start + timedelta(days=1, hours=6),
            reason="dentist",
        )
    )
    db_session.commit()

    booking = BookingRequest(
        pro_user_id=pro_uid,
        client_user_id=uuid.UUID(client_id),
        package_id=uuid.UUID(package_id),
        requested_start=window_start,
        requested_end=window_end,
        status=BookingRequestStatus.pending,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=24),
    )
    db_session.add(booking)
    db_session.commit()

    resp = client.post(f"/v1/booking-requests/{booking.id}/accept", headers={"X-User-Id": pro_id})
    assert resp.status_code == 200, resp.text


def test_two_overlapping_blocks_refuse_rather_than_raise(client, db_session):
    """The previous query used scalar_one_or_none(), so two overlapping
    blocks produced a 500 instead of a refusal."""
    from app.services.availability_blocks import blocked_intervals, window_fully_blocked

    pro_uid = _seed_pro(db_session, str(uuid.uuid4()))
    start, end = _honeymoon()
    db_session.add(ProBlackoutDate(pro_user_id=pro_uid, start_at=start, end_at=end))
    db_session.add(
        ProBlackoutDate(pro_user_id=pro_uid, start_at=start + timedelta(days=1), end_at=end + timedelta(days=1))
    )
    db_session.commit()

    merged = blocked_intervals(db_session, pro_uid, start=start, end=end + timedelta(days=1))
    assert len(merged) == 1, "touching blocks should read as one continuous unavailability"
    assert window_fully_blocked(db_session, pro_uid, start=start + timedelta(days=2), end=start + timedelta(days=3))


# --- deprecation -------------------------------------------------------


def test_deprecated_blackout_route_says_so_in_the_response(client, db_session):
    """A route marked deprecated only in the docs is a route someone calls
    without ever reading them."""
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    start, end = _honeymoon()

    resp = client.post(
        "/v1/pro/me/availability/blackouts",
        headers={"X-User-Id": pro_id},
        json={"start_at": start.isoformat(), "end_at": end.isoformat(), "reason": "honeymoon"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.headers["Deprecation"] == "true"
    assert "/v1/pro/scheduling/exceptions" in resp.headers["Link"]
    assert "Warning" in resp.headers
    assert "/v1/pro/scheduling/exceptions" in resp.json()["deprecation_notice"]


def test_deprecated_rules_route_says_so_in_the_response(client, db_session):
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)

    resp = client.post(
        "/v1/pro/me/availability/rules",
        headers={"X-User-Id": pro_id},
        json={"rules": [{"day_of_week": 1, "start_time": "09:00:00", "end_time": "17:00:00"}]},
    )
    assert resp.status_code == 200, resp.text
    assert resp.headers["Deprecation"] == "true"
    assert "/v1/pro/scheduling/availability-rules" in resp.headers["Link"]
    assert "/v1/pro/scheduling/availability-rules" in resp.json()["deprecation_notice"]


def test_deprecated_blackouts_still_block_bookings(client, db_session):
    """Deprecating is only safe because the writes still count. If they
    stopped counting, deprecation would create exactly the silent data loss
    it was meant to end."""
    pro_id = str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    start, end = _honeymoon()

    client.post(
        "/v1/pro/me/availability/blackouts",
        headers={"X-User-Id": pro_id},
        json={"start_at": start.isoformat(), "end_at": end.isoformat()},
    )
    from app.services.availability_blocks import window_fully_blocked

    assert window_fully_blocked(
        db_session, pro_uid, start=start + timedelta(days=1), end=start + timedelta(days=2)
    )


# --- the six additions -------------------------------------------------


def test_travel_radius_round_trips(client, db_session):
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)

    resp = client.put(
        "/v1/pro/me/profile", headers={"X-User-Id": pro_id}, json={"travel_radius_km": 45}
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["travel_radius_km"] == 45

    fetched = client.get("/v1/pro/me/profile", headers={"X-User-Id": pro_id})
    assert fetched.json()["travel_radius_km"] == 45


def test_travel_radius_starts_null_not_zero(client, db_session):
    """"Has not said" is not "will not travel"."""
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    resp = client.get("/v1/pro/me/profile", headers={"X-User-Id": pro_id})
    assert resp.json()["travel_radius_km"] is None


def test_portfolio_lists_own_assets_with_the_required_minimum(client, db_session):
    from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus

    pro_id = str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    db_session.add(
        MediaAsset(
            owner_user_id=pro_uid,
            kind=MediaKind.photo,
            purpose=MediaPurpose.portfolio_reel,
            provider=MediaProvider.r2,
            status=MediaStatus.ready,
            niche_tags=["portraits"],
        )
    )
    db_session.commit()

    resp = client.get("/v1/pro/me/portfolio", headers={"X-User-Id": pro_id})
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["photo_count"] == 1
    assert body["photo_minimum"] == 12
    assert body["items"][0]["niche_slugs"] == ["portraits"]


def test_portfolio_does_not_leak_another_pros_assets(client, db_session):
    from app.models.media import MediaAsset, MediaKind, MediaProvider, MediaPurpose, MediaStatus

    mine, theirs = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_pro(db_session, mine)
    other_uid = _seed_pro(db_session, theirs)
    db_session.add(
        MediaAsset(
            owner_user_id=other_uid,
            kind=MediaKind.photo,
            purpose=MediaPurpose.portfolio_reel,
            provider=MediaProvider.r2,
            status=MediaStatus.ready,
        )
    )
    db_session.commit()

    resp = client.get("/v1/pro/me/portfolio", headers={"X-User-Id": mine})
    assert resp.json()["items"] == []


def test_pricing_preview_works_without_an_existing_package(client, db_session):
    """The public preview 404s for a pro who has not priced anything yet -
    exactly the person setting a price for the first time."""
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    niche = db_session.query(Niche).filter_by(slug="portraits").one()

    resp = client.get(
        f"/v1/pro/me/pricing/niches/{niche.id}",
        headers={"X-User-Id": pro_id},
        params={"entry_price": "12.00"},
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert [point["photo_count"] for point in body["curve"]] == [10, 25, 50, 100, 200]
    # 10 photos are always flat at the entry rate, whatever the curve.
    assert Decimal(body["curve"][0]["total"]) == Decimal("120.00")
    assert Decimal(body["curve"][0]["per_photo"]) == Decimal("12.00")


def test_pricing_preview_reports_the_cap_rather_than_rejecting(client, db_session):
    """Typing a number over the cap should show you that, not fail a save
    you have not made yet."""
    from app.models.niche import SkillTier
    from app.models.package_pricing import NichePackagePriceCap

    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    niche = db_session.query(Niche).filter_by(slug="portraits").one()
    db_session.add(
        NichePackagePriceCap(
            niche_id=niche.id,
            tier=SkillTier.rookie,
            entry_price_min=Decimal("5.00"),
            entry_price_max=Decimal("20.00"),
        )
    )
    db_session.commit()

    over = client.get(
        f"/v1/pro/me/pricing/niches/{niche.id}",
        headers={"X-User-Id": pro_id},
        params={"entry_price": "50.00"},
    )
    assert over.status_code == 200, over.text
    assert over.json()["within_cap"] is False
    assert Decimal(over.json()["entry_price_max"]) == Decimal("20.00")

    ok = client.get(
        f"/v1/pro/me/pricing/niches/{niche.id}",
        headers={"X-User-Id": pro_id},
        params={"entry_price": "15.00"},
    )
    assert ok.json()["within_cap"] is True


def test_extra_image_price_shows_configured_and_applied(client, db_session):
    """A pro priced outside the platform's bounds should see both what they
    asked for and what a client is actually charged."""
    from app.models.client_rewards_pricing import ExtraImagePricingPolicy
    from app.models.niche import SkillTier

    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    niche = db_session.query(Niche).filter_by(slug="portraits").one()
    db_session.add(
        ExtraImagePricingPolicy(
            niche_id=niche.id,
            tier=SkillTier.rookie,
            unit_price_min=Decimal("2.00"),
            unit_price_max=Decimal("10.00"),
            is_active=True,
        )
    )
    db_session.commit()

    resp = client.put(
        "/v1/pro/me/extra-image-price",
        headers={"X-User-Id": pro_id},
        json={"items": [{"niche_slug": "portraits", "unit_price": "25.00"}]},
    )
    assert resp.status_code == 200, resp.text
    row = resp.json()["items"][0]
    assert Decimal(row["configured_unit_price"]) == Decimal("25.00")
    assert Decimal(row["applied_unit_price"]) == Decimal("10.00")


def test_extra_image_price_rejects_unknown_niche(client, db_session):
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    resp = client.put(
        "/v1/pro/me/extra-image-price",
        headers={"X-User-Id": pro_id},
        json={"items": [{"niche_slug": "underwater-basketweaving", "unit_price": "5.00"}]},
    )
    assert resp.status_code == 422


def test_listing_preview_works_before_the_pro_is_live(client, db_session):
    """The whole point: see what you are building while you build it."""
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id, kyc=KYCStatus.unsubmitted)

    resp = client.get("/v1/pro/me/listing-preview", headers={"X-User-Id": pro_id})
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["is_live"] is False
    assert "kyc_not_approved" in body["blocking_reasons"]
    assert "no_active_package" in body["blocking_reasons"]
    assert body["card"]["display_name"] == "Alex Lens"
    # No weekly rules set, so availability is unanswered rather than zero.
    assert body["available_days_next_14"] is None


def test_listing_preview_reflects_a_pricing_edit(client, db_session):
    """P-7 requires that editing pricing visibly changes the card. It only
    does if the preview reads the same index Discover reads."""
    pro_id = str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    _create_package(client, pro_id)

    before = client.get("/v1/pro/me/listing-preview", headers={"X-User-Id": pro_id}).json()
    assert Decimal(before["card"]["min_price"]) == Decimal("120.00")

    package_id = _create_package(client, pro_id)
    client.put(
        f"/v1/pro/me/packages/{package_id}",
        headers={"X-User-Id": pro_id},
        json={"niche_slug": "portraits", "price": "60.00"},
    )

    after = client.get("/v1/pro/me/listing-preview", headers={"X-User-Id": pro_id}).json()
    assert Decimal(after["card"]["min_price"]) == Decimal("60.00")


def test_listing_preview_counts_blocked_days(client, db_session):
    pro_id = str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    _add_weekly_rules(db_session, pro_uid)

    day_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    db_session.add(
        ProBlackoutDate(
            pro_user_id=pro_uid,
            start_at=day_start + timedelta(days=1),
            end_at=day_start + timedelta(days=4),
        )
    )
    db_session.commit()

    body = client.get("/v1/pro/me/listing-preview", headers={"X-User-Id": pro_id}).json()
    assert body["available_days_next_14"] == 11


def test_gear_item_can_be_removed(client, db_session):
    pro_id = str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    item = GearItem(pro_user_id=pro_uid, category=GearCategory.camera_body, brand="Sony", model="A7 IV")
    db_session.add(item)
    db_session.commit()

    resp = client.delete(f"/v1/pro/me/gear-items/{item.id}", headers={"X-User-Id": pro_id})
    assert resp.status_code == 204, resp.text
    assert client.get("/v1/pro/me/gear-items", headers={"X-User-Id": pro_id}).json() == []


def test_gear_item_with_repair_history_refuses_with_a_reason(client, db_session):
    """Deleting would orphan the repair record into meaninglessness. Better
    to say why than to fail on a constraint the caller cannot see."""
    pro_id = str(uuid.uuid4())
    pro_uid = _seed_pro(db_session, pro_id)
    item = GearItem(pro_user_id=pro_uid, category=GearCategory.camera_body, brand="Sony", model="A7 IV")
    db_session.add(item)
    db_session.flush()
    db_session.add(RepairTicket(pro_user_id=pro_uid, gear_item_id=item.id, issue_description="Shutter stuck"))
    db_session.commit()

    resp = client.delete(f"/v1/pro/me/gear-items/{item.id}", headers={"X-User-Id": pro_id})
    assert resp.status_code == 409, resp.text


def test_gear_item_of_another_pro_is_not_deletable(client, db_session):
    mine, theirs = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_pro(db_session, mine)
    other_uid = _seed_pro(db_session, theirs)
    item = GearItem(pro_user_id=other_uid, category=GearCategory.camera_body, brand="Canon")
    db_session.add(item)
    db_session.commit()

    resp = client.delete(f"/v1/pro/me/gear-items/{item.id}", headers={"X-User-Id": mine})
    assert resp.status_code == 404
