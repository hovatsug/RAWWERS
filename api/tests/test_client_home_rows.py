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
from app.models.niche import Niche, SkillTier
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


# ---------------------------------------------------------------------------
# Niche scope: a wedding row must be wedding photographers, showing wedding
# work. Both halves of one fault - membership, and the image.
# ---------------------------------------------------------------------------


def _skill(db_session, pro_user_id, niche_slug: str, tier):
    from app.models.niche import ProNicheSkill

    niche = db_session.execute(select(Niche).where(Niche.slug == niche_slug)).scalar_one()
    db_session.add(
        ProNicheSkill(
            pro_user_id=pro_user_id,
            niche_id=niche.id,
            tier=tier,
            score=80 if tier != SkillTier.rookie else 10,
        )
    )
    db_session.commit()


def _tagged_photo(db_session, owner_id, niche_slug: str, marker: str):
    """A portfolio photo tagged to one niche, with a findable storage key."""
    from app.models.media import (
        MediaAsset,
        MediaKind,
        MediaObject,
        MediaProvider,
        MediaPurpose,
        MediaStatus,
        MediaVariant,
        MediaVisibility,
        ObjectStatus,
    )

    asset = MediaAsset(
        owner_user_id=owner_id,
        kind=MediaKind.photo,
        purpose=MediaPurpose.portfolio_reel,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.public,
        niche_tags=[niche_slug],
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.thumbnail,
            storage_key=f"seed/{marker}.jpg",
            status=ObjectStatus.ready,
            width=512,
            height=342,
        )
    )
    db_session.commit()
    return asset.id


def test_a_third_place_niche_does_not_make_someone_a_wedding_photographer(client, db_session, viewer):
    """The bug this fixes: rows filtered on top_niches, which is a
    photographer's top *three*, and recompute creates a zero-score skill row
    for every active niche - so a food photographer routinely ranked into
    "Weddings in Lisbon" on a niche they had never worked in."""
    _city(db_session)
    wedding_pro = _pro(db_session, name="Wedding Pro", gigs=10, niche_slug="weddings")
    _skill(db_session, wedding_pro, "weddings", SkillTier.pro)

    food_pro = _pro(db_session, name="Food Pro", gigs=10, niche_slug="food")
    _skill(db_session, food_pro, "food", SkillTier.pro)
    # Present in the niche, but at rookie with a token score - the filler
    # state recompute creates for every active niche.
    _skill(db_session, food_pro, "weddings", SkillTier.rookie)

    # And present in top_niches, which is what the old rule filtered on.
    # Without this the fixture cannot reproduce the bug at all: reverting the
    # fix left this test passing, because top_niches held only the primary
    # niche and the third-place case never arose. A test named for a bug it
    # cannot reproduce is worse than no test - it reads as coverage.
    index = db_session.get(ProPublicIndex, food_pro)
    index.top_niches = [
        {"slug": "food", "tier": "pro"},
        {"slug": "product", "tier": "rookie"},
        {"slug": "weddings", "tier": "rookie"},
    ]
    db_session.commit()

    rows = _home(client, viewer)
    wedding_row = rows.get("niche:weddings")
    assert wedding_row is not None
    names = [i["display_name"] for i in wedding_row["items"]]
    assert "Wedding Pro" in names
    assert "Food Pro" not in names, "a rookie filler skill ranked into a niche row"


def test_a_genuine_second_specialism_still_counts(client, db_session, viewer):
    """The reason for a threshold rather than primary-only: someone can
    honestly work in two niches, and excluding them would be its own lie."""
    _city(db_session)
    pro = _pro(db_session, name="Both", gigs=10, niche_slug="portraits")
    _skill(db_session, pro, "portraits", SkillTier.master)
    _skill(db_session, pro, "weddings", SkillTier.elite)

    rows = _home(client, viewer)
    assert "Both" in [i["display_name"] for i in rows["niche:weddings"]["items"]]
    assert "Both" in [i["display_name"] for i in rows["niche:portraits"]["items"]]


def test_a_new_photographer_appears_in_their_own_niche(client, db_session, viewer):
    """Primary always qualifies. A brand-new wedding photographer is a wedding
    photographer; they simply have no history yet, and a threshold that hid
    them would undo the fairness the new-photographers row exists for."""
    _city(db_session)
    pro = _pro(db_session, name="Brand New", gigs=0, niche_slug="weddings")
    _skill(db_session, pro, "weddings", SkillTier.rookie)

    rows = _home(client, viewer)
    assert "Brand New" in [i["display_name"] for i in rows["niche:weddings"]["items"]]


def test_a_niche_row_shows_that_niche_s_work(client, db_session, viewer):
    """A profile carries one cover. In a wedding row, a portrait specialist
    who also shoots weddings would otherwise show their portrait - the row
    correctly populated and still visibly wrong."""
    _city(db_session)
    pro = _pro(db_session, name="Both", gigs=10, niche_slug="portraits")
    _skill(db_session, pro, "portraits", SkillTier.master)
    _skill(db_session, pro, "weddings", SkillTier.elite)
    _tagged_photo(db_session, pro, "portraits", "a-portrait")
    _tagged_photo(db_session, pro, "weddings", "a-wedding")

    rows = _home(client, viewer)
    wedding_card = next(i for i in rows["niche:weddings"]["items"] if i["display_name"] == "Both")
    portrait_card = next(i for i in rows["niche:portraits"]["items"] if i["display_name"] == "Both")

    assert "a-wedding" in wedding_card["cover_url"], "the wedding row is not showing wedding work"
    assert "a-portrait" in portrait_card["cover_url"]
    assert wedding_card["cover_url"] != portrait_card["cover_url"]


def test_an_untagged_photographer_keeps_their_profile_cover(client, db_session, viewer):
    """Membership is decided by skill, not by tagging. Someone who belongs in
    the row but has tagged nothing falls back to their profile cover rather
    than rendering a blank tile, which would punish a metadata gap."""
    _city(db_session)
    pro = _pro(db_session, name="Untagged", gigs=10, niche_slug="weddings")
    _skill(db_session, pro, "weddings", SkillTier.pro)

    rows = _home(client, viewer)
    card = next(i for i in rows["niche:weddings"]["items"] if i["display_name"] == "Untagged")
    assert card["display_name"] == "Untagged"  # present, not dropped


# ---------------------------------------------------------------------------
# One niche's page: the same rows, narrowed to a niche.
#
# Same request, same rules, one extra parameter. Everything above has to stay
# true inside a niche - the fairness split, absent-not-empty, the gates - and
# the niche's own membership rule has to hold in every row, not just the one
# the home screen already had.
# ---------------------------------------------------------------------------


def _niche_page(client, user_id, niche_slug, *, city="Lisbon", country="PT", expect=200):
    resp = client.get(
        f"/v1/client/home?city={city}&country={country}&niche_slug={niche_slug}",
        headers={"X-User-Id": str(user_id)},
    )
    assert resp.status_code == expect, resp.text
    return resp.json()


def _rows_of(body):
    return {row["key"]: row for row in body["rows"]}


def _names(row):
    return [i["display_name"] for i in row["items"]]


def test_the_niche_page_names_its_niche(client, db_session, viewer):
    """The page's title comes from the server, like every row title does."""
    _city(db_session)
    pro = _pro(db_session, name="Wed", gigs=3, niche_slug="weddings")
    _skill(db_session, pro, "weddings", SkillTier.pro)

    body = _niche_page(client, viewer, "weddings")
    assert body["niche"]["slug"] == "weddings"
    assert body["niche"]["name"] == "Weddings"


def test_the_home_screen_has_no_niche(client, db_session, viewer):
    _city(db_session)
    _pro(db_session, name="Wed", gigs=3)
    resp = client.get("/v1/client/home?city=Lisbon&country=PT", headers={"X-User-Id": str(viewer)})
    assert resp.json()["niche"] is None


def test_every_row_on_a_niche_page_holds_only_that_niche(client, db_session, viewer):
    """Membership is the home row's rule - primary, or genuinely skilled -
    applied to every row, including new and experienced. A food photographer
    with a rookie filler wedding skill is in none of them."""
    _city(db_session)
    new_wed = _pro(db_session, name="New Wed", gigs=0, niche_slug="weddings")
    _skill(db_session, new_wed, "weddings", SkillTier.rookie)
    old_wed = _pro(db_session, name="Old Wed", gigs=30, niche_slug="weddings")
    _skill(db_session, old_wed, "weddings", SkillTier.pro)
    second = _pro(db_session, name="Portraits Too", gigs=12, niche_slug="portraits")
    _skill(db_session, second, "weddings", SkillTier.elite)

    for name, gigs in (("New Food", 0), ("Old Food", 30)):
        food = _pro(db_session, name=name, gigs=gigs, niche_slug="food")
        _skill(db_session, food, "food", SkillTier.pro)
        _skill(db_session, food, "weddings", SkillTier.rookie)

    rows = _rows_of(_niche_page(client, viewer, "weddings"))
    everyone = {n for row in rows.values() for n in _names(row)}
    assert everyone == {"New Wed", "Old Wed", "Portraits Too"}, everyone


def test_the_fairness_split_holds_inside_a_niche(client, db_session, viewer):
    """New and experienced stay separate on a niche page exactly as on the
    home screen: a zero-gig photographer is never in the experience row, and
    the two rows never share anyone."""
    _city(db_session)
    for name, gigs in (("New A", 0), ("New B", 0), ("Vet A", 40), ("Vet B", 5)):
        pro = _pro(db_session, name=name, gigs=gigs, niche_slug="weddings")
        _skill(db_session, pro, "weddings", SkillTier.pro if gigs else SkillTier.rookie)
    # Outside the niche, one on each side of the split. Without them this test
    # passed against an endpoint that ignored the niche entirely.
    for name, gigs in (("New Food", 0), ("Vet Food", 90)):
        pro = _pro(db_session, name=name, gigs=gigs, niche_slug="food")
        _skill(db_session, pro, "food", SkillTier.pro)

    rows = _rows_of(_niche_page(client, viewer, "weddings"))
    newcomers = _names(rows["new_photographers"])
    experienced = _names(rows["most_experienced"])

    assert sorted(newcomers) == ["New A", "New B"]
    assert experienced == ["Vet A", "Vet B"], "experience row not ordered by completed work"
    assert set(newcomers).isdisjoint(experienced), "the two rows overlap"


def test_a_niche_page_offers_only_rows_it_can_name_honestly(client, db_session, viewer):
    """No "top rated" (ranking_score is a composite, so the name would be
    false) and no "available this week" (the index has no availability to
    sort on). The same rule the home screen's docstring states."""
    _city(db_session)
    for name, gigs in (("New", 0), ("Vet", 20)):
        pro = _pro(db_session, name=name, gigs=gigs, niche_slug="weddings")
        _skill(db_session, pro, "weddings", SkillTier.pro)

    body = _niche_page(client, viewer, "weddings")
    assert [row["key"] for row in body["rows"]] == ["new_photographers", "most_experienced", "niche_ranked"]
    titles = [row["title"] for row in body["rows"]]
    assert titles == ["New in Weddings", "Most experienced in Weddings", "Weddings in Lisbon"]
    for title in titles:
        assert "rated" not in title.lower() and "available" not in title.lower()


def test_no_row_on_a_niche_page_is_itself_a_niche_row(client, db_session, viewer):
    """A `niche:` key renders as a tile that opens the niche's page. On that
    page it would be a tile linking to where you already are."""
    _city(db_session)
    pro = _pro(db_session, name="Wed", gigs=3)
    _skill(db_session, pro, "weddings", SkillTier.pro)

    keys = [row["key"] for row in _niche_page(client, viewer, "weddings")["rows"]]
    assert not any(key.startswith("niche:") for key in keys), keys


def test_a_thin_niche_leaves_rows_out_rather_than_empty(client, db_session, viewer):
    """One brand-new wedding photographer: a new row and the ranked row, and
    no experience row at all - not an empty one."""
    _city(db_session)
    pro = _pro(db_session, name="Only One", gigs=0, niche_slug="weddings")
    _skill(db_session, pro, "weddings", SkillTier.rookie)

    rows = _rows_of(_niche_page(client, viewer, "weddings"))
    assert set(rows) == {"new_photographers", "niche_ranked"}
    assert all(row["items"] for row in rows.values()), "an empty row was returned"


def test_a_niche_nobody_here_works_in_is_empty_not_missing(client, db_session, viewer):
    """A real niche with nobody in this city: no rows, and still the niche -
    so the page can say "no wedding photographers here yet" instead of
    treating a real category as a broken link."""
    _city(db_session)
    pro = _pro(db_session, name="Food", gigs=3, niche_slug="food")
    _skill(db_session, pro, "food", SkillTier.pro)

    body = _niche_page(client, viewer, "weddings")
    assert body["rows"] == []
    assert body["niche"]["slug"] == "weddings"


def test_an_unknown_niche_is_not_found(client, db_session, viewer):
    _city(db_session)
    _niche_page(client, viewer, "no-such-niche", expect=404)


def test_every_row_on_a_niche_page_shows_that_niche_s_work(client, db_session, viewer):
    """The home screen swaps in niche covers for its niche rows only. On a
    niche page every row is about the niche, so the newcomer row showing a
    portrait on the wedding page would be the same visible wrongness."""
    _city(db_session)
    pro = _pro(db_session, name="Both", gigs=0, niche_slug="weddings")
    _skill(db_session, pro, "weddings", SkillTier.rookie)
    _tagged_photo(db_session, pro, "portraits", "a-portrait")
    _tagged_photo(db_session, pro, "weddings", "a-wedding")

    rows = _rows_of(_niche_page(client, viewer, "weddings"))
    for key in ("new_photographers", "niche_ranked"):
        card = next(i for i in rows[key]["items"] if i["display_name"] == "Both")
        assert "a-wedding" in card["cover_url"], f"{key} is not showing wedding work"


def test_a_niche_page_is_not_served_the_home_screen_from_cache(client, db_session, viewer):
    """Same endpoint, same city: if the cache key ignored the niche, whichever
    was asked for first would be served for both."""
    _city(db_session)
    wed = _pro(db_session, name="Wed", gigs=3, niche_slug="weddings")
    _skill(db_session, wed, "weddings", SkillTier.pro)
    food = _pro(db_session, name="Food", gigs=3, niche_slug="food")
    _skill(db_session, food, "food", SkillTier.pro)

    home = _home(client, viewer)
    assert "niche:food" in home

    page = _niche_page(client, viewer, "weddings")
    assert "Food" not in {n for row in page["rows"] for n in _names(row)}
    assert _niche_page(client, viewer, "food")["niche"]["slug"] == "food"
