import uuid
from decimal import Decimal

from app.core.errors import APIError
from app.models.admin import UserAccount, UserRole, UserRoleType, ProProfile, KYCStatus
from app.models.gallery import (
    ClientSelection,
    ClientSelectionItem,
    ProofGallery,
    ProofGalleryItem,
    ProofGalleryStatus,
    SelectionStatus,
)
from app.models.gig import Gig, GigStatus
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
from app.models.niche import Niche, ProNicheSkill, SkillTier
from app.models.package_pricing import NichePackagePriceCap, PackageDecayCurve
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug
from app.services.package_pricing import (
    DEFAULT_DECAY_CURVE_TIERS_BY_SLUG,
    MINIMUM_PHOTOS,
    compute_minimum_amount,
    compute_package_total,
    compute_total_for_photo_count,
    enforce_entry_price_cap,
    enforce_minimum_selection_count,
    ensure_default_package_decay_curves,
    get_curve_tiers_for_niche,
)
from sqlalchemy import select

ADMIN_USER_ID = "00000000-0000-0000-0000-0000000000aa"


def _ensure_account(db_session, user_id: str):
    uid = uuid.UUID(user_id)
    if not db_session.get(UserAccount, uid):
        db_session.add(UserAccount(user_id=uid))
        db_session.commit()


def _ensure_role(db_session, user_id: str, role: UserRoleType):
    _ensure_account(db_session, user_id)
    uid = uuid.UUID(user_id)
    if not db_session.query(UserRole).filter_by(user_id=uid, role=role).first():
        db_session.add(UserRole(user_id=uid, role=role))
        db_session.commit()


def _seed_pro_profile(db_session, pro_id: str):
    pid = uuid.UUID(pro_id)
    profile = db_session.get(ProProfile, pid)
    if not profile:
        profile = ProProfile(user_id=pid)
        db_session.add(profile)
    profile.kyc_status = KYCStatus.unsubmitted
    profile.display_name = "Pro"
    profile.headline = "Portrait"
    profile.bio = "Long bio"
    profile.city = "Lisbon"
    profile.country = "PT"
    profile.languages = ["en"]
    profile.styles = ["editorial"]
    profile.gear = {"camera": "A7"}
    profile.completeness_score = 100
    db_session.commit()


# ---------------------------------------------------------------------------
# Curve math: marginal, not bracket - total must strictly increase with
# photo count and never cliff across a bracket boundary.
# ---------------------------------------------------------------------------


def test_flat_curve_is_linear():
    tiers = [{"upto": None, "multiplier": "1.00"}]
    entry = Decimal("3.00")
    assert compute_total_for_photo_count(entry, 1, tiers) == Decimal("3.00")
    assert compute_total_for_photo_count(entry, 40, tiers) == Decimal("120.00")


def test_marginal_curve_has_no_cliff_across_bracket_boundary():
    tiers = [
        {"upto": 10, "multiplier": "1.00"},
        {"upto": 20, "multiplier": "0.50"},
        {"upto": None, "multiplier": "0.25"},
    ]
    entry = Decimal("2.00")
    totals = [compute_total_for_photo_count(entry, n, tiers) for n in range(1, 31)]
    for earlier, later in zip(totals, totals[1:]):
        assert later > earlier, (earlier, later)

    # first bracket is a straight multiply at the entry rate
    assert compute_total_for_photo_count(entry, 10, tiers) == Decimal("20.00")
    # 11th photo priced at the second bracket's multiplier, not retroactively
    # discounting the first 10
    assert compute_total_for_photo_count(entry, 11, tiers) == Decimal("21.00")


def test_compute_total_for_zero_or_negative_photo_count_is_zero():
    tiers = [{"upto": None, "multiplier": "1.00"}]
    assert compute_total_for_photo_count(Decimal("5.00"), 0, tiers) == Decimal("0.00")


def test_unconfigured_niche_falls_back_to_flat_curve(db_session):
    tiers = get_curve_tiers_for_niche(db_session, uuid.uuid4())
    assert tiers == [{"upto": None, "multiplier": "1.00"}]


def test_compute_minimum_amount_is_10_photos_through_the_curve(db_session):
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    entry = Decimal("2.00")
    expected = compute_package_total(db_session, niche_id=weddings.id, entry_rate=entry, photo_count=MINIMUM_PHOTOS)
    assert compute_minimum_amount(db_session, niche_id=weddings.id, entry_rate=entry) == expected


# ---------------------------------------------------------------------------
# Default curve seeding: idempotent, one row per known niche, matching the
# platform's stated categorization (events-like long-gentle-decay,
# portrait-like short-tail, product-like flat).
# ---------------------------------------------------------------------------


def test_ensure_default_curves_seeds_every_known_niche_once_and_is_idempotent(db_session):
    ensure_initial_niches(db_session)  # already calls ensure_default_package_decay_curves internally
    ensure_default_package_decay_curves(db_session)  # explicit second call must not duplicate

    rows = db_session.execute(select(PackageDecayCurve)).scalars().all()
    assert len(rows) == len(DEFAULT_DECAY_CURVE_TIERS_BY_SLUG)

    niches_by_id = {n.id: n.slug for n in db_session.execute(select(Niche)).scalars().all()}
    for row in rows:
        slug = niches_by_id[row.niche_id]
        assert row.tiers == DEFAULT_DECAY_CURVE_TIERS_BY_SLUG[slug]


def test_events_niche_has_long_gentle_decay_and_portrait_niche_has_short_tail(db_session):
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    portraits = get_active_niche_by_slug(db_session, "portraits")
    entry = Decimal("2.00")

    # events-style: still meaningfully discounting out at 200 photos
    weddings_200 = compute_package_total(db_session, niche_id=weddings.id, entry_rate=entry, photo_count=200)
    weddings_per_photo_at_200 = weddings_200 / 200
    assert weddings_per_photo_at_200 < entry

    # portrait-style: decay is nearly exhausted by 50 photos already
    portraits_25 = compute_package_total(db_session, niche_id=portraits.id, entry_rate=entry, photo_count=25)
    portraits_50 = compute_package_total(db_session, niche_id=portraits.id, entry_rate=entry, photo_count=50)
    marginal_26_to_50 = portraits_50 - portraits_25
    assert marginal_26_to_50 / 25 <= entry / 2


def test_admin_curve_edit_is_preserved_by_a_later_ensure_call(db_session):
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    row = db_session.execute(
        select(PackageDecayCurve).where(PackageDecayCurve.niche_id == weddings.id)
    ).scalar_one()
    row.tiers = [{"upto": None, "multiplier": "0.10"}]
    db_session.commit()

    ensure_default_package_decay_curves(db_session)

    db_session.refresh(row)
    assert row.tiers == [{"upto": None, "multiplier": "0.10"}]


# ---------------------------------------------------------------------------
# Entry-price cap enforcement.
# ---------------------------------------------------------------------------


def test_enforce_entry_price_cap_allows_within_bounds_rejects_outside(db_session):
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    db_session.add(
        NichePackagePriceCap(
            niche_id=weddings.id,
            tier=SkillTier.rookie,
            entry_price_min=Decimal("1.00"),
            entry_price_max=Decimal("5.00"),
        )
    )
    db_session.commit()

    enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=Decimal("3.00"))

    try:
        enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=Decimal("0.50"))
        assert False, "expected APIError below min"
    except APIError as exc:
        assert exc.status_code == 422

    try:
        enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=Decimal("9.00"))
        assert False, "expected APIError above max"
    except APIError as exc:
        assert exc.status_code == 422


def test_enforce_entry_price_cap_is_noop_when_unconfigured(db_session):
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.master, entry_price=Decimal("999.00"))


def test_enforce_minimum_selection_count():
    try:
        enforce_minimum_selection_count(MINIMUM_PHOTOS - 1)
        assert False, "expected APIError below minimum"
    except APIError as exc:
        assert exc.status_code == 422
    enforce_minimum_selection_count(MINIMUM_PHOTOS)
    enforce_minimum_selection_count(MINIMUM_PHOTOS + 5)


# ---------------------------------------------------------------------------
# API integration: package create/update enforce the platform cap.
# ---------------------------------------------------------------------------


def test_create_package_rejects_price_above_tier_cap(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id)

    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    db_session.add(
        NichePackagePriceCap(
            niche_id=weddings.id,
            tier=SkillTier.rookie,
            entry_price_min=Decimal("1.00"),
            entry_price_max=Decimal("5.00"),
        )
    )
    db_session.commit()

    resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Wedding day",
            "niche_slug": "weddings",
            "duration_minutes": 480,
            "price": "50.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
        },
    )
    assert resp.status_code == 422


def test_create_package_within_cap_succeeds_and_update_re_enforces_it(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id)

    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    db_session.add(
        NichePackagePriceCap(
            niche_id=weddings.id,
            tier=SkillTier.rookie,
            entry_price_min=Decimal("1.00"),
            entry_price_max=Decimal("5.00"),
        )
    )
    db_session.commit()

    create_resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Wedding day",
            "niche_slug": "weddings",
            "duration_minutes": 480,
            "price": "3.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
        },
    )
    assert create_resp.status_code == 200
    package_id = create_resp.json()["id"]

    over_cap_update = client.put(
        f"/v1/pro/me/packages/{package_id}",
        headers={"X-User-Id": pro_id},
        json={"niche_slug": "weddings", "price": "50.00"},
    )
    assert over_cap_update.status_code == 422

    within_cap_update = client.put(
        f"/v1/pro/me/packages/{package_id}",
        headers={"X-User-Id": pro_id},
        json={"niche_slug": "weddings", "price": "4.50"},
    )
    assert within_cap_update.status_code == 200
    assert within_cap_update.json()["price"] == "4.50"


def test_update_package_without_changing_price_does_not_re_check_cap(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id)
    ensure_initial_niches(db_session)

    create_resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Wedding day",
            "niche_slug": "weddings",
            "duration_minutes": 480,
            "price": "50.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
        },
    )
    assert create_resp.status_code == 200
    package_id = create_resp.json()["id"]

    weddings = get_active_niche_by_slug(db_session, "weddings")
    db_session.add(
        NichePackagePriceCap(
            niche_id=weddings.id,
            tier=SkillTier.rookie,
            entry_price_min=Decimal("1.00"),
            entry_price_max=Decimal("5.00"),
        )
    )
    db_session.commit()

    resp = client.put(
        f"/v1/pro/me/packages/{package_id}",
        headers={"X-User-Id": pro_id},
        json={"niche_slug": "weddings", "title": "Wedding day (updated)"},
    )
    assert resp.status_code == 200


# ---------------------------------------------------------------------------
# API integration: pricing preview endpoint for screen C4.
# ---------------------------------------------------------------------------


def test_niche_pricing_preview_returns_price_at_each_requested_photo_count(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_role(db_session, pro_id, UserRoleType.pro)
    _seed_pro_profile(db_session, pro_id)
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")

    create_resp = client.post(
        "/v1/pro/me/packages",
        headers={"X-User-Id": pro_id},
        json={
            "title": "Wedding day",
            "niche_slug": "weddings",
            "duration_minutes": 480,
            "price": "2.00",
            "currency": "EUR",
            "included_photos": 10,
            "extra_photo_price": "8.00",
        },
    )
    assert create_resp.status_code == 200

    resp = client.get(f"/v1/pros/{pro_id}/niches/{weddings.id}/pricing-preview")
    assert resp.status_code == 200
    body = resp.json()
    assert len(body["packages"]) == 1
    price_at = body["packages"][0]["price_at_photo_count"]
    assert set(price_at.keys()) == {"10", "25", "50", "100", "200"}

    expected_10 = compute_package_total(db_session, niche_id=weddings.id, entry_rate=Decimal("2.00"), photo_count=10)
    assert Decimal(price_at["10"]) == expected_10

    counts = [10, 25, 50, 100, 200]
    values = [Decimal(price_at[str(c)]) for c in counts]
    for earlier, later in zip(values, values[1:]):
        assert later > earlier


def test_niche_pricing_preview_404s_when_pro_has_no_active_package_in_that_niche(client, db_session):
    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    resp = client.get(f"/v1/pros/{uuid.uuid4()}/niches/{weddings.id}/pricing-preview")
    assert resp.status_code == 404


# ---------------------------------------------------------------------------
# API integration: minimum-10 selection floor enforced server-side.
# ---------------------------------------------------------------------------


def _create_photo_asset(db_session, owner_user_id: str) -> MediaAsset:
    asset = MediaAsset(
        owner_user_id=uuid.UUID(owner_user_id),
        kind=MediaKind.photo,
        purpose=MediaPurpose.proof,
        provider=MediaProvider.r2,
        status=MediaStatus.ready,
        visibility=MediaVisibility.owner_only,
        content_type="image/jpeg",
        meta={},
    )
    db_session.add(asset)
    db_session.flush()
    db_session.add(
        MediaObject(
            media_asset_id=asset.id,
            variant=MediaVariant.original,
            storage_key=f"users/{owner_user_id}/photo/{asset.id}_orig.jpg",
            status=ObjectStatus.ready,
            width=2000,
            height=1200,
        )
    )
    db_session.commit()
    db_session.refresh(asset)
    return asset


def _create_gig_with_gallery(db_session, client_id: str, pro_id: str, selected: int) -> tuple[Gig, ProofGallery]:
    gig = Gig(
        client_user_id=uuid.UUID(client_id),
        pro_user_id=uuid.UUID(pro_id),
        status=GigStatus.paid,
        currency="EUR",
        amount_minimum=Decimal("100.00"),
        amount_platform_fee=Decimal("20.00"),
        amount_pro_gross=Decimal("80.00"),
        meta={},
    )
    db_session.add(gig)
    db_session.flush()

    gallery = ProofGallery(
        gig_id=gig.id,
        pro_user_id=gig.pro_user_id,
        client_user_id=gig.client_user_id,
        included_photos=selected,
        extra_photo_price=Decimal("10.00"),
        currency="EUR",
        status=ProofGalleryStatus.published,
    )
    db_session.add(gallery)
    db_session.flush()

    assets = [_create_photo_asset(db_session, pro_id) for _ in range(max(selected, 1))]
    for i, asset in enumerate(assets):
        db_session.add(ProofGalleryItem(gallery_id=gallery.id, media_asset_id=asset.id, sort_order=i + 1))
    db_session.flush()

    selection = ClientSelection(gallery_id=gallery.id, client_user_id=uuid.UUID(client_id), version=1, status=SelectionStatus.draft)
    db_session.add(selection)
    db_session.flush()
    for asset in assets[:selected]:
        db_session.add(ClientSelectionItem(selection_id=selection.id, media_asset_id=asset.id))

    db_session.commit()
    db_session.refresh(gig)
    db_session.refresh(gallery)
    return gig, gallery


def test_submit_selection_below_minimum_photos_is_rejected(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)

    gig, gallery = _create_gig_with_gallery(db_session, client_id, pro_id, selected=MINIMUM_PHOTOS - 1)

    resp = client.post(
        f"/v1/proof-galleries/{gallery.id}/selections/submit",
        headers={"X-User-Id": client_id},
    )
    assert resp.status_code == 422


def test_submit_selection_at_minimum_photos_succeeds(client, db_session):
    client_id = str(uuid.uuid4())
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, client_id)
    _ensure_account(db_session, pro_id)

    gig, gallery = _create_gig_with_gallery(db_session, client_id, pro_id, selected=MINIMUM_PHOTOS)

    resp = client.post(
        f"/v1/proof-galleries/{gallery.id}/selections/submit",
        headers={"X-User-Id": client_id},
    )
    assert resp.status_code == 200


# ---------------------------------------------------------------------------
# API integration: admin CRUD for decay curves and price caps.
# ---------------------------------------------------------------------------


def test_admin_can_list_and_upsert_decay_curves(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)

    listing = client.get("/v1/admin/pricing/package-decay-curves", headers={"X-User-Id": ADMIN_USER_ID})
    assert listing.status_code == 200
    assert len(listing.json()) == len(DEFAULT_DECAY_CURVE_TIERS_BY_SLUG)

    upsert = client.put(
        "/v1/admin/pricing/package-decay-curves",
        headers={"X-User-Id": ADMIN_USER_ID},
        json={"items": [{"niche_slug": "weddings", "tiers": [{"upto": None, "multiplier": "0.75"}]}]},
    )
    assert upsert.status_code == 200
    weddings_row = next(row for row in upsert.json() if row["niche_slug"] == "weddings")
    assert weddings_row["tiers"] == [{"upto": None, "multiplier": "0.75"}]


def test_admin_can_list_and_upsert_price_caps(client, db_session):
    _ensure_account(db_session, ADMIN_USER_ID)

    upsert = client.put(
        "/v1/admin/pricing/niche-package-price-caps",
        headers={"X-User-Id": ADMIN_USER_ID},
        json={
            "items": [
                {
                    "niche_slug": "weddings",
                    "tier": "rookie",
                    "entry_price_min": "1.00",
                    "entry_price_max": "5.00",
                    "currency": "EUR",
                }
            ]
        },
    )
    assert upsert.status_code == 200
    row = upsert.json()[0]
    assert row["niche_slug"] == "weddings"
    assert row["tier"] == "rookie"
    assert row["entry_price_min"] == "1.00"
    assert row["entry_price_max"] == "5.00"

    listing = client.get("/v1/admin/pricing/niche-package-price-caps", headers={"X-User-Id": ADMIN_USER_ID})
    assert listing.status_code == 200
    assert len(listing.json()) == 1
