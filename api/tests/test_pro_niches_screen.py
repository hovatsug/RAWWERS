"""The Pro app's niches screen (BETA_SCOPE "Pro app: choose and manage niches",
owner's addition of 2026-11-17): PUT /v1/pro/me/niches by the shared rules
of app/services/pro_niches.py.

Add from the active list, remove, choose the main one; never more than
niches_max, never below niches_min, exactly one main niche; a niche with a
booking that is not finished, or a request still waiting, cannot be
removed. Removing a niche keeps the photos tagged with it and its packages.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import AdminAuditLog, ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import BookingRequest, BookingRequestStatus, ProPackage
from app.models.gig import Gig, GigStatus
from app.models.launch_ops import OnboardingRequirement
from app.models.media import MediaAsset, MediaKind, MediaPurpose, MediaStatus, MediaVisibility
from app.models.niche import Niche, ProNiche


@pytest.fixture
def slugs(db_session):
    found = [n.slug for n in db_session.execute(select(Niche).where(Niche.is_active.is_(True)).order_by(Niche.slug)).scalars()]
    assert len(found) >= 5
    return found


def _pro(db) -> uuid.UUID:
    pro = uuid.uuid4()
    db.add(UserAccount(user_id=pro))
    db.flush()
    db.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db.add(ProProfile(user_id=pro, display_name="Alex Lens"))
    db.commit()
    return pro


def _give(db, pro, *slugs, primary=None):
    found = {n.slug: n for n in db.execute(select(Niche).where(Niche.slug.in_(slugs))).scalars()}
    for slug in slugs:
        db.add(ProNiche(pro_user_id=pro, niche_id=found[slug].id, is_primary=slug == primary))
    db.commit()


def _niche(db, slug) -> Niche:
    return db.execute(select(Niche).where(Niche.slug == slug)).scalar_one()


def _rows(db, pro):
    db.expire_all()
    rows = db.execute(select(ProNiche, Niche.slug).join(Niche, Niche.id == ProNiche.niche_id).where(ProNiche.pro_user_id == pro)).all()
    return sorted((slug, row.is_primary) for row, slug in rows)


def _put(client, pro, slugs, primary=None, *, flag=True):
    """The screen's call: the whole list, the main one marked and named."""
    return client.put(
        "/v1/pro/me/niches",
        headers={"X-User-Id": str(pro)},
        json={"primary_niche_slug": primary, "niches": [{"slug": s, "is_primary": flag and s == primary} for s in slugs]},
    )


def _set_requirement(db, key, count):
    row = db.execute(select(OnboardingRequirement).where(OnboardingRequirement.key == key)).scalar_one_or_none()
    if row is None:
        db.add(OnboardingRequirement(key=key, value={"count": count}))
    else:
        row.value = {"count": count}
    db.commit()


def _package(db, pro, slug) -> ProPackage:
    package = ProPackage(pro_user_id=pro, niche_id=_niche(db, slug).id, title="Starter", duration_minutes=60,
                         price=Decimal("5.00"), currency="EUR", included_photos=10, extra_photo_price=Decimal("7.00"))
    db.add(package)
    db.commit()
    return package


def _gig(db, pro, slug, status) -> Gig:
    gig = Gig(client_user_id=uuid.uuid4(), pro_user_id=pro, niche_id=_niche(db, slug).id, status=status, currency="EUR",
              amount_minimum=Decimal("100.00"), amount_platform_fee=Decimal("20.00"), amount_pro_gross=Decimal("80.00"), meta={})
    db.add(gig)
    db.commit()
    return gig


def _error(answer):
    return answer.status_code, answer.json()["error"]["code"]


# --- reading -----------------------------------------------------------------------------------------


def test_the_list_carries_the_minimum_and_maximum(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], primary=slugs[0])
    body = client.get("/v1/pro/niches/mine", headers={"X-User-Id": str(pro)}).json()
    assert (body["minimum"], body["maximum"]) == (1, 3)
    assert body["primary_niche_slug"] == slugs[0]


# --- adding, removing, the main niche ----------------------------------------------------------------


def test_a_niche_is_added_from_the_active_list(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], primary=slugs[0])
    answer = _put(client, pro, [slugs[0], slugs[1]], primary=slugs[0])
    assert answer.status_code == 200, answer.text
    assert _rows(db_session, pro) == [(slugs[0], True), (slugs[1], False)]
    assert answer.json()["maximum"] == 3


def test_a_first_niche_can_be_chosen_by_a_new_photographer(client, db_session, slugs):
    pro = _pro(db_session)
    assert _put(client, pro, [slugs[2]], primary=slugs[2]).status_code == 200
    assert _rows(db_session, pro) == [(slugs[2], True)]


def test_a_retired_niche_cannot_be_added(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], primary=slugs[0])
    retired = _niche(db_session, slugs[4])
    retired.is_active = False
    db_session.commit()
    try:
        answer = _put(client, pro, [slugs[0], slugs[4]], primary=slugs[0])
        assert answer.status_code == 422
        assert _rows(db_session, pro) == [(slugs[0], True)]
    finally:
        retired.is_active = True
        db_session.commit()


def test_a_niche_is_removed_and_its_photos_and_packages_are_kept(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    photo = MediaAsset(owner_user_id=pro, kind=MediaKind.photo, purpose=MediaPurpose.portfolio_reel, provider="r2",
                       status=MediaStatus.ready, visibility=MediaVisibility.public, content_type="image/jpeg",
                       niche_tags=[slugs[1]], meta={})
    db_session.add(photo)
    db_session.commit()
    package = _package(db_session, pro, slugs[1])

    answer = _put(client, pro, [slugs[0]], primary=slugs[0])
    assert answer.status_code == 200, answer.text
    assert _rows(db_session, pro) == [(slugs[0], True)]
    assert db_session.get(MediaAsset, photo.id).niche_tags == [slugs[1]], "the photo lost its tag"
    assert db_session.get(MediaAsset, photo.id).status == MediaStatus.ready
    assert db_session.get(ProPackage, package.id).is_active, "the package was changed"
    audit = db_session.execute(
        select(AdminAuditLog).where(AdminAuditLog.target_id == str(pro), AdminAuditLog.action == "niches_changed")
    ).scalars().all()
    assert [a.meta["removed"] for a in audit] == [[slugs[1]]] and audit[0].meta["source"] == "app"


def test_the_main_niche_can_be_changed(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    assert _put(client, pro, [slugs[0], slugs[1]], primary=slugs[1]).status_code == 200
    assert _rows(db_session, pro) == [(slugs[0], False), (slugs[1], True)]


# --- the rules that refuse ---------------------------------------------------------------------------


def test_the_list_cannot_go_below_the_minimum(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], primary=slugs[0])
    answer = _put(client, pro, [])
    assert _error(answer) == (422, "niche_minimum")
    assert "Add another niche first" in answer.json()["error"]["message"]
    assert _rows(db_session, pro) == [(slugs[0], True)]


def test_the_minimum_is_the_admin_setting(client, db_session, slugs):
    _set_requirement(db_session, "niches_min", 2)
    try:
        pro = _pro(db_session)
        _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
        assert _error(_put(client, pro, [slugs[0]], primary=slugs[0])) == (422, "niche_minimum")
        # Swapping one for another keeps the count: allowed.
        assert _put(client, pro, [slugs[0], slugs[2]], primary=slugs[0]).status_code == 200
        # Below it already (from before): may still add.
        newcomer = _pro(db_session)
        assert _put(client, newcomer, [slugs[3]], primary=slugs[3]).status_code == 200
    finally:
        _set_requirement(db_session, "niches_min", 1)


def test_the_list_cannot_go_above_the_maximum(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, *slugs[:3], primary=slugs[0])
    answer = _put(client, pro, slugs[:4], primary=slugs[0])
    assert _error(answer) == (422, "niche_limit_reached")
    assert len(_rows(db_session, pro)) == 3


def test_a_list_without_a_main_niche_is_refused(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    answer = _put(client, pro, [slugs[0], slugs[1]], primary=None)
    assert _error(answer) == (422, "main_niche_required")
    assert _rows(db_session, pro) == [(slugs[0], True), (slugs[1], False)]


def test_two_main_niches_are_refused(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    both = client.put(
        "/v1/pro/me/niches",
        headers={"X-User-Id": str(pro)},
        json={"niches": [{"slug": slugs[0], "is_primary": True}, {"slug": slugs[1], "is_primary": True}]},
    )
    assert _error(both) == (422, "one_main_niche")
    disagree = client.put(
        "/v1/pro/me/niches",
        headers={"X-User-Id": str(pro)},
        json={"primary_niche_slug": slugs[1], "niches": [{"slug": slugs[0], "is_primary": True}, {"slug": slugs[1]}]},
    )
    assert _error(disagree) == (422, "one_main_niche")
    assert _rows(db_session, pro) == [(slugs[0], True), (slugs[1], False)]


@pytest.mark.parametrize(
    "status",
    [GigStatus.requested, GigStatus.paid, GigStatus.scheduled, GigStatus.proofs_delivered, GigStatus.final_delivered, GigStatus.disputed],
)
def test_a_niche_with_a_booking_not_finished_cannot_be_removed(client, db_session, slugs, status):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    _gig(db_session, pro, slugs[1], status)
    answer = _put(client, pro, [slugs[0]], primary=slugs[0])
    assert _error(answer) == (409, "niche_in_use")
    assert "booking" in answer.json()["error"]["message"]
    assert _rows(db_session, pro) == [(slugs[0], True), (slugs[1], False)]


@pytest.mark.parametrize("status", [GigStatus.completed, GigStatus.cancelled_by_client, GigStatus.cancelled_by_pro, GigStatus.refunded])
def test_a_niche_whose_bookings_are_finished_can_be_removed(client, db_session, slugs, status):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    _gig(db_session, pro, slugs[1], status)
    assert _put(client, pro, [slugs[0]], primary=slugs[0]).status_code == 200


def test_another_niches_booking_does_not_stop_a_removal(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    _gig(db_session, pro, slugs[0], GigStatus.paid)
    assert _put(client, pro, [slugs[0]], primary=slugs[0]).status_code == 200


def test_a_niche_with_a_waiting_booking_request_cannot_be_removed(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    package = _package(db_session, pro, slugs[1])
    start = datetime.now(timezone.utc) + timedelta(days=3)
    request = BookingRequest(pro_user_id=pro, client_user_id=uuid.uuid4(), package_id=package.id,
                             requested_start=start, requested_end=start + timedelta(hours=1), expires_at=start)
    db_session.add(request)
    db_session.commit()
    answer = _put(client, pro, [slugs[0]], primary=slugs[0])
    assert _error(answer) == (409, "niche_in_use")
    assert "waiting for your answer" in answer.json()["error"]["message"]
    request.status = BookingRequestStatus.declined
    db_session.commit()
    assert _put(client, pro, [slugs[0]], primary=slugs[0]).status_code == 200


def test_the_main_niche_cannot_be_removed_without_choosing_another(client, db_session, slugs):
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    answer = _put(client, pro, [slugs[1]], primary=None)
    assert _error(answer) == (422, "main_niche_required")
    assert _put(client, pro, [slugs[1]], primary=slugs[1]).status_code == 200
    assert _rows(db_session, pro) == [(slugs[1], True)]


# --- only one's own ------------------------------------------------------------------------------------


def test_a_photographer_changes_only_their_own_niches(client, db_session, slugs):
    me, other = _pro(db_session), _pro(db_session)
    _give(db_session, me, slugs[0], primary=slugs[0])
    _give(db_session, other, slugs[0], slugs[1], primary=slugs[1])
    assert _put(client, me, [slugs[0], slugs[2]], primary=slugs[2]).status_code == 200
    assert _rows(db_session, other) == [(slugs[0], False), (slugs[1], True)]
    assert _rows(db_session, me) == [(slugs[0], False), (slugs[2], True)]


def test_a_client_cannot_set_niches(client, db_session, slugs):
    someone = uuid.uuid4()
    db_session.add(UserAccount(user_id=someone))
    db_session.flush()
    db_session.add(UserRole(user_id=someone, role=UserRoleType.client))
    db_session.commit()
    assert _put(client, someone, [slugs[0]], primary=slugs[0]).status_code == 403
    assert _rows(db_session, someone) == []


# --- the Lightroom plug-in after a niche is removed in the app ----------------------------------------


def test_the_plugin_cannot_publish_into_a_niche_removed_in_the_app(client, db_session, slugs, monkeypatch):
    import hashlib

    from app.services import rate_limit
    from tests.test_delivery_gigs import _token

    for name in ("uploads", "delivery_pair_ip", "delivery_pair_all", "delivery_pairing_issue", "delivery_token_daily"):
        monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, name, (100_000, 3600))
    monkeypatch.setattr("app.services.photo_uploads.create_presigned_put", lambda storage_key, content_type, expires_in=900: f"https://r2.invalid/{storage_key}")
    monkeypatch.setattr("app.api.v1.media.create_presigned_put", lambda storage_key, content_type, expires_in=900: f"https://r2.invalid/{storage_key}")
    pro = _pro(db_session)
    _give(db_session, pro, slugs[0], slugs[1], primary=slugs[0])
    token = _token(client, pro)
    headers = {"Authorization": f"Bearer {token}", "X-Rawwers-Plugin-Version": "1.2.5"}

    def start(slug):
        return client.post("/v1/delivery/portfolio/uploads", headers=headers, json={
            "niche_slug": slug, "file_name": "P_1.jpg", "content_type": "image/jpeg", "byte_size": 6_000_000,
            "sha256": hashlib.sha256(slug.encode()).hexdigest()})

    assert start(slugs[1]).status_code == 200
    assert _put(client, pro, [slugs[0]], primary=slugs[0]).status_code == 200
    refused = start(slugs[1])
    assert refused.status_code == 422
    assert "niches are removed in the RAWWERS Pro app" in refused.json()["error"]["message"]
    listing = client.get("/v1/delivery/portfolio", headers=headers).json()
    assert [n["slug"] for n in listing["niches"]] == [slugs[0]]
