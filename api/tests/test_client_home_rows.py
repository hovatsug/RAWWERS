"""The browsing home screen: several differently-sorted cuts of one catalogue.

What is worth testing here is not that rows render. It is the fairness rules,
because those are the ones that fail silently and in the platform's favour:

  - "New photographers" exists so someone with no completed work is not
    permanently invisible under every popularity sort. If a fairness boost
    were folded into "most experienced" instead, that row's name would become
    a lie and nobody would see it happen.
  - A row with nothing honest to show must be absent, not empty. An empty
    shelf reads as a failed load.
  - A row must never surface a photographer the ordinary Discover list would
    hide, or the gates mean nothing.
"""
import uuid
from decimal import Decimal

import pytest
from app.models.admin import KYCStatus, ProProfile, UserAccount
from app.models.discovery import ProPublicIndex
from app.models.launch_ops import ProOnboarding, ProOnboardingStatus, RolloutCity
from app.models.niche import Niche
from app.services.niche_catalog import ensure_initial_niches
from sqlalchemy import select


def _city(db_session, *, city="Lisbon", country="PT"):
    row = db_session.execute(
        select(RolloutCity).where(RolloutCity.city == city, RolloutCity.country == country)
    ).scalar_one_or_none()
    if row is None:
        row = RolloutCity(city=city, country=country, meta={})
        db_session.add(row)
    row.is_pro_onboarding_enabled = True
    row.is_client_browsing_enabled = True
    db_session.commit()


def _pro(
    db_session,
    *,
    name: str,
    gigs: int,
    niche_slug: str = "weddings",
    city: str = "Lisbon",
    country: str = "PT",
    approved: bool = True,
    accepting: bool = True,
    completeness: int = 90,
    price: Decimal | None = Decimal("150.00"),
) -> uuid.UUID:
    ensure_initial_niches(db_session)
    niche = db_session.execute(select(Niche).where(Niche.slug == niche_slug)).scalar_one()

    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(ProProfile(user_id=user_id, display_name=name, city=city, country=country))

    onboarding = ProOnboarding(pro_user_id=user_id)
    onboarding.status = ProOnboardingStatus.approved_public if approved else ProOnboardingStatus.ready_for_review
    db_session.add(onboarding)

    db_session.add(
        ProPublicIndex(
            pro_user_id=user_id,
            city=city,
            country=country,
            primary_niche_id=niche.id,
            top_niches=[{"slug": niche_slug, "tier": "pro"}],
            kyc_status=KYCStatus.approved,
            is_accepting_bookings=accepting,
            completeness_score=completeness,
            min_package_price=price,
            currency="EUR",
            gigs_completed=gigs,
            portfolio_photo_count=10,
        )
    )
    db_session.commit()
    return user_id


def _home(client, user_id, *, city="Lisbon", country="PT"):
    resp = client.get(
        f"/v1/client/home?city={city}&country={country}", headers={"X-User-Id": str(user_id)}
    )
    assert resp.status_code == 200, resp.text
    return {row["key"]: row for row in resp.json()["rows"]}


@pytest.fixture(autouse=True)
def _clear_home_cache():
    """Redis outlives the per-test database wipe.

    The home response is cached under a key whose version only changes when
    recompute_pro_public_index runs. These tests insert index rows directly,
    so the version never moves and one test is served the previous test's
    answer - which showed up as six failures that each passed in isolation.
    Worth knowing beyond the tests: any path that edits the index without
    going through the recompute serves a stale home screen until the TTL
    expires.
    """
    from app.services.cache import get_redis_client

    def flush():
        try:
            client = get_redis_client()
            for pattern in ("client:home:*", "client:discover:*", "discover:pros:*"):
                keys = list(client.scan_iter(match=pattern))
                if keys:
                    client.delete(*keys)
        except Exception:  # noqa: BLE001 - no redis in some environments
            pass

    flush()
    yield
    flush()


@pytest.fixture
def viewer(db_session):
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.commit()
    return user_id


# ---------------------------------------------------------------------------
# The fairness rules.
# ---------------------------------------------------------------------------


def test_a_photographer_with_no_work_is_not_invisible(client, db_session, viewer):
    _city(db_session)
    _pro(db_session, name="Newcomer", gigs=0)
    _pro(db_session, name="Veteran", gigs=40)

    rows = _home(client, viewer)
    names = [i["display_name"] for i in rows["new_photographers"]["items"]]
    assert "Newcomer" in names


def test_the_fairness_row_is_separate_and_never_blended(client, db_session, viewer):
    """A zero-gig photographer must not be quietly boosted into the
    experience row. That would make its name false in the service of
    fairness, which is the dishonesty this row exists to avoid."""
    _city(db_session)
    _pro(db_session, name="Newcomer", gigs=0)
    _pro(db_session, name="Veteran", gigs=40)

    rows = _home(client, viewer)
    experienced = [i["display_name"] for i in rows["most_experienced"]["items"]]
    assert "Veteran" in experienced
    assert "Newcomer" not in experienced, "a fairness boost was blended into a row named for experience"

    newcomers = [i["display_name"] for i in rows["new_photographers"]["items"]]
    assert "Veteran" not in newcomers
    assert set(newcomers).isdisjoint(experienced), "the two rows overlap"


def test_most_experienced_is_ordered_by_completed_work(client, db_session, viewer):
    _city(db_session)
    _pro(db_session, name="Few", gigs=3)
    _pro(db_session, name="Many", gigs=50)
    _pro(db_session, name="Some", gigs=20)

    items = _home(client, viewer)["most_experienced"]["items"]
    assert [i["display_name"] for i in items] == ["Many", "Some", "Few"]


# ---------------------------------------------------------------------------
# Absent, not empty.
# ---------------------------------------------------------------------------


def test_a_row_with_nothing_to_show_is_absent_rather_than_empty(client, db_session, viewer):
    """An empty shelf reads as a failure to load. If every photographer has
    completed work, there is no new-photographers row at all."""
    _city(db_session)
    _pro(db_session, name="Veteran", gigs=40)

    rows = _home(client, viewer)
    assert "new_photographers" not in rows
    assert all(row["items"] for row in rows.values()), "an empty row was returned"


def test_a_city_with_nobody_returns_no_rows(client, db_session, viewer):
    _city(db_session, city="Porto")
    resp = client.get("/v1/client/home?city=Porto&country=PT", headers={"X-User-Id": str(viewer)})
    assert resp.status_code == 200
    assert resp.json()["rows"] == []


# ---------------------------------------------------------------------------
# Rows cannot surface what Discover hides.
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "kwargs,reason",
    [
        ({"approved": False}, "onboarding not approved_public"),
        ({"accepting": False}, "not accepting bookings"),
        ({"completeness": 10}, "completeness below 60"),
        ({"price": None}, "no package price"),
    ],
)
def test_a_photographer_discover_would_hide_appears_in_no_row(client, db_session, viewer, kwargs, reason):
    _city(db_session)
    _pro(db_session, name="Visible", gigs=5)
    _pro(db_session, name="Hidden", gigs=5, **kwargs)

    rows = _home(client, viewer)
    everyone = [i["display_name"] for row in rows.values() for i in row["items"]]
    assert "Visible" in everyone
    assert "Hidden" not in everyone, f"a row surfaced a photographer hidden for: {reason}"


# ---------------------------------------------------------------------------
# Cost.
# ---------------------------------------------------------------------------


def test_the_response_cost_does_not_grow_with_the_catalogue(client, db_session, viewer):
    """The whole reason for one request instead of one per row. A photographer
    appears in several rows, and resolving their profile and presigning their
    cover once per appearance would be the same per-item failure the gallery
    endpoints already had."""
    from sqlalchemy import event

    _city(db_session)
    for index in range(3):
        _pro(db_session, name=f"Pro {index}", gigs=index)

    counter = [0]

    def _count(state):
        counter[0] += 1

    event.listen(db_session, "do_orm_execute", _count)
    try:
        counter[0] = 0
        _home(client, viewer)
        few = counter[0]

        for index in range(3, 15):
            _pro(db_session, name=f"Pro {index}", gigs=index)
        counter[0] = 0
        _home(client, viewer)
        many = counter[0]
    finally:
        event.remove(db_session, "do_orm_execute", _count)

    assert many - few <= 2, f"3 photographers cost {few} queries, 15 cost {many}: per-item"
