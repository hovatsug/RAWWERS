"""The extras curve starts after the package's own size.

Owner's decisions (2026-11-01):
1. A package of N photos costs N x the photographer's entry rate.
2. The client's minimum selection is the package's size (never below the
   platform's 10).
3. Every booking stores the anchor and the curve's shape when it is made;
   bookings made before that keep today's behaviour (anchor 10).
4. Extras decay from photo N+1, whatever N is.

The approved table for Alex (portraits, 4.80 a photo, a 20-photo package):
the package costs 96.00, and 10 extras 31.74. The numbers below are worked
out by hand from the exponential curve (k = 0.08, floor 15%), not read back
from the code under test.
"""
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal as D

import pytest
from sqlalchemy import select

from app.models.booking import BookingRequest, ProPackage
from app.models.gallery import ProofGallery, ProofGalleryStatus
from app.models.gig import GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.package_pricing import PackageCurveType, PackageDecayCurve
from app.services.gig_builder import build_gig_for_request
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug
from app.services.package_pricing import (
    MINIMUM_PHOTOS,
    compute_minimum_amount,
    compute_package_total,
    compute_total_for_photo_count,
    gig_total,
    package_anchor,
    price_at_photo,
)
from tests.test_booking_close import DummyStripePI, _ensure_account, _select_photos

PORTRAITS = dict(curve_type=PackageCurveType.exponential, shape_param=D("0.08"), floor_pct=D("0.15"))


def _package(db, pro_id, *, included=20, price="4.80", slug="portraits") -> ProPackage:
    ensure_initial_niches(db)
    niche = get_active_niche_by_slug(db, slug)
    package = ProPackage(
        pro_user_id=uuid.UUID(pro_id), niche_id=niche.id, title="Portraits Starter", duration_minutes=60,
        price=D(price), currency="EUR", included_photos=included, extra_photo_price=D("4.80"),
        proofs_sla_days=3, finals_sla_days=7, addons=[], is_active=True,
    )
    db.add(package)
    db.commit()
    return package


def _booked(db, *, included=20, price="4.80", photos=None, slug="portraits"):
    """A booking made the way accept and confirm-slot make one, paid, with its
    gallery sent and `photos` photos all selected by the client."""
    client_id, pro_id = str(uuid.uuid4()), str(uuid.uuid4())
    _ensure_account(db, client_id)
    _ensure_account(db, pro_id)
    package = _package(db, pro_id, included=included, price=price, slug=slug)
    start = datetime.now(timezone.utc) + timedelta(days=3)
    request = BookingRequest(
        pro_user_id=uuid.UUID(pro_id), client_user_id=uuid.UUID(client_id), package_id=package.id,
        requested_start=start, requested_end=start + timedelta(hours=1), expires_at=start,
    )
    db.add(request)
    db.flush()
    gig = build_gig_for_request(db, request)
    gig.status = GigStatus.paid
    db.add(gig)
    db.flush()
    db.add(StripePayment(
        gig_id=gig.id, kind=StripePaymentKind.base, client_user_id=uuid.UUID(client_id), status=PaymentStatus.succeeded,
        stripe_payment_intent_id=f"pi_base_{gig.id.hex}", amount=gig.amount_minimum, currency="EUR", meta={},
    ))
    gallery = ProofGallery(
        gig_id=gig.id, pro_user_id=gig.pro_user_id, client_user_id=gig.client_user_id, included_photos=included,
        extra_photo_price=D("4.80"), currency="EUR", status=ProofGalleryStatus.published,
    )
    db.add(gallery)
    db.commit()
    if photos:
        _select_photos(db, gallery, pro_id, client_id, count=photos)
    return gig, gallery, client_id


def _quote(client, gallery, client_id, count):
    resp = client.get(
        f"/v1/proof-galleries/{gallery.id}/selection-quote?selected_count={count}", headers={"X-User-Id": client_id}
    )
    assert resp.status_code == 200, resp.text
    return resp.json()


def _extras(entry, extras, anchor, package=20):
    """What `extras` photos past a `package`-photo package add, from `anchor`."""
    def total(n):
        return compute_total_for_photo_count(D(entry), n, anchor=anchor, **PORTRAITS)
    return total(package + extras) - total(package)


# --- anchor 10 is exactly today ------------------------------------------------------------


@pytest.mark.parametrize("curve", [
    dict(curve_type=PackageCurveType.exponential, shape_param=D("0.08"), floor_pct=D("0.15")),
    dict(curve_type=PackageCurveType.power, shape_param=D("0.35"), floor_pct=D("0.20")),
    dict(curve_type=PackageCurveType.flat, shape_param=None, floor_pct=D("1.0000")),
])
def test_an_anchor_of_10_prices_every_photo_from_1_to_60_as_today(curve):
    # Today's formula, written out: full price to 10, then the curve from 10.
    import math

    def today(n, entry):
        if n <= 10 or curve["curve_type"] == PackageCurveType.flat:
            return D(str(entry))
        shape = float(curve["shape_param"])
        raw = entry * (n / 10.0) ** (-shape) if curve["curve_type"] == PackageCurveType.power else entry * math.exp(-shape * (n - 10))
        return max(D(str(entry)) * curve["floor_pct"], D(str(raw)))

    for entry in ("4.80", "13.46", "40.69"):
        for n in range(1, 61):
            expected = D(entry) if n <= 10 else today(n, float(entry))
            assert price_at_photo(n, D(entry), anchor=10, **curve) == expected, (entry, n)
            assert price_at_photo(n, D(entry), **curve) == expected, "a booking made before the anchor was stored"
            total = compute_total_for_photo_count(D(entry), n, anchor=10, **curve)
            assert total == compute_total_for_photo_count(D(entry), n, **curve)


def test_today_alex_pays_79_74_and_the_21st_photo_is_1_99():
    assert compute_total_for_photo_count(D("4.80"), 20, anchor=10, **PORTRAITS) == D("79.74")
    assert compute_total_for_photo_count(D("4.80"), 21, anchor=10, **PORTRAITS) - D("79.74") == D("1.99")
    assert _extras("4.80", 10, anchor=10) == D("14.26")
    assert _extras("4.80", 20, anchor=10) == D("21.78")


# --- the approved table --------------------------------------------------------------------


def test_alexs_package_costs_20_photos_at_full_price():
    assert compute_total_for_photo_count(D("4.80"), 20, anchor=20, **PORTRAITS) == D("96.00")


@pytest.mark.parametrize(("extras", "total"), [(1, "4.43"), (3, "12.30"), (5, "19.00"), (10, "31.74"), (20, "46.00")])
def test_alexs_extras_decay_from_the_21st_photo(extras, total):
    assert _extras("4.80", extras, anchor=20) == D(total)


@pytest.mark.parametrize(("entry", "old", "new"), [("13.46", "223.59", "269.20"), ("40.69", "675.93", "813.80")])
def test_mid_and_master_20_photo_packages(entry, old, new):
    assert compute_total_for_photo_count(D(entry), 20, anchor=10, **PORTRAITS) == D(old)
    assert compute_total_for_photo_count(D(entry), 20, anchor=20, **PORTRAITS) == D(new)


def test_the_power_curve_also_starts_at_the_anchor(client, db_session):
    # Weddings: power, a = 0.35. The 21st photo of a 20-photo package at
    # 10.00 is 10 x (21/20)^-0.35 = 9.83 (from photo 10 it would be 7.71).
    _gig, gallery, client_id = _booked(db_session, slug="weddings", price="10.00", photos=21)
    body = _quote(client, gallery, client_id, 20)
    assert (body["amount_total"], body["next_photo_price"]) == ("200.00", "9.83")


# --- a booking, end to end -----------------------------------------------------------------


def test_a_new_booking_charges_the_package_at_full_price_and_stores_its_curve(db_session):
    gig, _gallery, _ = _booked(db_session)

    assert gig.amount_minimum == D("96.00")
    snapshot = gig.meta["pricing_snapshot"]
    assert snapshot["curve"] == {"anchor": 20, "curve_type": "exponential", "shape_param": "0.0800", "floor_pct": "0.1500"}
    assert snapshot["minimum_selection"] == 20


def test_the_fee_split_is_the_same_percentages_of_the_new_price(db_session):
    gig, _gallery, _ = _booked(db_session)
    assert (gig.fee_percent, gig.retained_percent, gig.pro_raww_percent) == (20, 15, 5)
    assert gig.amount_platform_fee + gig.amount_pro_gross == D("96.00")
    assert gig.amount_pro_gross == D("76.80")


def test_the_quote_for_30_photos_is_the_package_plus_10_extras(client, db_session):
    gig, gallery, client_id = _booked(db_session, photos=30)

    at_20 = _quote(client, gallery, client_id, 20)
    at_21 = _quote(client, gallery, client_id, 21)
    at_30 = _quote(client, gallery, client_id, 30)

    assert (at_20["amount_total"], at_20["amount_due"], at_20["next_photo_price"]) == ("96.00", "0.00", "4.43")
    assert at_21["amount_due"] == "4.43"
    assert (at_30["amount_total"], at_30["amount_due"]) == ("127.74", "31.74")


def test_the_charge_is_the_quote(client, db_session, monkeypatch):
    gig, gallery, client_id = _booked(db_session, photos=30)
    monkeypatch.setattr("stripe.PaymentIntent.create", lambda **kw: DummyStripePI("pi_d", "sec_d"))

    resp = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})

    assert resp.status_code == 200, resp.text
    charge = db_session.execute(
        select(StripePayment).where(StripePayment.gig_id == gig.id, StripePayment.kind == StripePaymentKind.difference)
    ).scalar_one()
    assert charge.amount == D("31.74")
    db_session.refresh(gig)
    assert gig.amount_final == D("127.74")


def test_editing_the_niches_curve_changes_no_booking_already_made(client, db_session):
    gig, gallery, client_id = _booked(db_session, photos=30)
    row = db_session.execute(select(PackageDecayCurve).where(PackageDecayCurve.niche_id == gig.niche_id)).scalar_one()
    row.shape_param = D("0.30")
    row.floor_pct = D("0.50")
    db_session.commit()

    assert _quote(client, gallery, client_id, 30)["amount_due"] == "31.74"
    # The niche's curve now prices a new booking differently.
    assert compute_package_total(db_session, niche_id=gig.niche_id, entry_rate=D("4.80"), photo_count=30, anchor=20) != D("127.74")


def test_a_booking_made_before_the_curve_was_stored_keeps_todays_behaviour(client, db_session):
    gig, gallery, client_id = _booked(db_session, photos=30)
    snapshot = dict(gig.meta["pricing_snapshot"])
    del snapshot["curve"], snapshot["minimum_selection"]
    gig.meta = {**gig.meta, "pricing_snapshot": snapshot}
    gig.amount_minimum = D("79.74")
    db_session.commit()

    assert gig_total(db_session, gig, 20) == D("79.74")
    body = _quote(client, gallery, client_id, 21)
    assert (body["minimum_photos"], body["amount_due"]) == (10, "1.99")


# --- the minimum selection -----------------------------------------------------------------


def test_the_quote_says_the_package_is_the_minimum(client, db_session):
    _gig, gallery, client_id = _booked(db_session, photos=25)
    body = _quote(client, gallery, client_id, 19)
    assert (body["minimum_photos"], body["can_submit"], body["photos_still_needed"]) == (20, False, 1)
    assert body["refund_amount"] == "0.00", "below the minimum nothing can be submitted, so nothing is refunded"


def test_choosing_fewer_than_the_package_is_refused(client, db_session):
    _gig, gallery, client_id = _booked(db_session, photos=25)
    # Leave 15 of the 25 chosen.
    from app.models.gallery import ClientSelection, ClientSelectionItem

    selection = db_session.execute(select(ClientSelection).where(ClientSelection.gallery_id == gallery.id)).scalar_one()
    for item in db_session.execute(select(ClientSelectionItem).where(ClientSelectionItem.selection_id == selection.id)).scalars().all()[15:]:
        db_session.delete(item)
    db_session.commit()

    assert _quote(client, gallery, client_id, 15)["minimum_photos"] == 20
    resp = client.post(f"/v1/proof-galleries/{gallery.id}/selections/submit", headers={"X-User-Id": client_id})
    assert resp.status_code == 422
    assert "20 photos" in resp.json()["error"]["message"]


def test_a_gallery_holding_fewer_than_the_package_lowers_the_minimum_to_what_it_holds(client, db_session):
    _gig, gallery, client_id = _booked(db_session, photos=15)
    assert _quote(client, gallery, client_id, 15)["minimum_photos"] == 15
    # Never below the platform's 10.
    _gig2, gallery2, client2 = _booked(db_session, photos=7)
    assert _quote(client, gallery2, client2, 7)["minimum_photos"] == MINIMUM_PHOTOS


# --- packages under 10 ---------------------------------------------------------------------


def test_a_package_under_10_decays_after_its_own_size_and_keeps_the_minimum_of_10(client, db_session):
    gig, gallery, client_id = _booked(db_session, included=5, photos=12)

    # Booked for the 10 the client must choose: 5 x 4.80, then photos 6-10
    # decaying from the 5th - 24.00 + 19.00. Nothing more is owed for 10.
    assert gig.amount_minimum == D("43.00")
    assert gig.meta["pricing_snapshot"]["curve"]["anchor"] == 5
    body = _quote(client, gallery, client_id, 10)
    assert (body["minimum_photos"], body["amount_due"]) == (10, "0.00")
    # The 11th photo: 4.80 x e^(-0.08 x 6).
    assert body["next_photo_price"] == "2.97"


def test_the_anchor_is_the_package_size_and_never_below_1():
    assert [package_anchor(n) for n in (20, 10, 5, 1, 0, -3)] == [20, 10, 5, 1, 1, 1]


# --- where packages are shown --------------------------------------------------------------


def test_the_booking_price_shown_before_booking_is_the_package_at_full_price(db_session):
    ensure_initial_niches(db_session)
    niche = get_active_niche_by_slug(db_session, "portraits")
    assert compute_minimum_amount(db_session, niche_id=niche.id, entry_rate=D("4.80"), included_photos=20) == D("96.00")
    assert compute_minimum_amount(db_session, niche_id=niche.id, entry_rate=D("4.80"), included_photos=10) == D("48.00")


def test_the_client_profile_shows_the_package_price_and_minimum(client, db_session):
    from app.models.admin import UserRoleType
    from tests.test_client_launch import _enable_city_and_flags, _profile, _seed_pro, _seed_user

    _enable_city_and_flags(db_session)
    pro_id, client_id = str(uuid.uuid4()), str(uuid.uuid4())
    _seed_pro(db_session, pro_id)
    package = db_session.execute(select(ProPackage).where(ProPackage.pro_user_id == uuid.UUID(pro_id))).scalar_one()
    package.price, package.included_photos = D("4.80"), 20
    db_session.commit()
    _seed_user(db_session, client_id, [UserRoleType.client])

    (shown,) = [p for p in _profile(client, pro_id, client_id)["packages"] if p["id"] == str(package.id)]

    assert (shown["minimum_photos"], D(shown["starting_total"])) == (20, D("96.00"))


def test_the_public_preview_decays_after_each_packages_size(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, pro_id)
    package = _package(db_session, pro_id)

    resp = client.get(f"/v1/pros/{pro_id}/niches/{package.niche_id}/pricing-preview")

    assert resp.status_code == 200, resp.text
    (item,) = resp.json()["packages"]
    assert D(item["price_at_photo_count"]["10"]) == D("48.00")
    assert D(item["price_at_photo_count"]["25"]) == D("96.00") + _extras("4.80", 5, anchor=20)


def test_the_pros_own_preview_decays_after_the_size_they_type(client, db_session):
    pro_id = str(uuid.uuid4())
    _ensure_account(db_session, pro_id)
    package = _package(db_session, pro_id)
    from app.models.admin import UserRole, UserRoleType

    db_session.add(UserRole(user_id=uuid.UUID(pro_id), role=UserRoleType.pro))
    db_session.commit()
    url = f"/v1/pro/me/pricing/niches/{package.niche_id}?entry_price=4.80"

    with_size = client.get(url + "&included_photos=20", headers={"X-User-Id": pro_id})
    without = client.get(url, headers={"X-User-Id": pro_id})

    assert with_size.status_code == 200, with_size.text
    at_25 = {p["photo_count"]: D(p["total"]) for p in with_size.json()["curve"]}[25]
    assert at_25 == D("96.00") + _extras("4.80", 5, anchor=20)
    assert {p["photo_count"]: D(p["total"]) for p in without.json()["curve"]}[25] == compute_total_for_photo_count(
        D("4.80"), 25, anchor=10, **PORTRAITS
    )
