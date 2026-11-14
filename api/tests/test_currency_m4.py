"""Multi-currency M4: caps, discovery, client credit and RAWW per currency
(docs/MULTI_CURRENCY.md 5, decisions M2, M3 and M5).

Hand-computed:
- Credit: 100 points are one unit of their currency. A client with £30.00
  of credit paying a £100.00 booking, at the 10% cap, gets £10.00 off and
  pays £90.00; their €12.00 is untouched.
- Caps: a pound package is checked against the pound cap only (£8.00 max:
  £7.50 passes, £8.50 is refused), never against the euro one (€5.00 max).
- RAWW: a £100.00 booking's 5% is £5.00; at £0.08 a RAWW that is 62.5,
  rounded half up to 63 RAWW. A €100.00 booking at €0.10: 50 RAWW.
"""
from __future__ import annotations

import uuid
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.core.errors import APIError
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.discovery import ProPublicIndex
from app.models.gig import Gig, GigStatus, PaymentStatus, StripePayment, StripePaymentKind
from app.models.niche import SkillTier
from app.models.package_pricing import NichePackagePriceCap
from app.models.reward import RedemptionContextType, RewardBalance, RewardLedgerEntry
from app.models.shelf import ProRawwLedgerEntry
from app.services import client_credit
from app.services.niche_catalog import ensure_initial_niches, get_active_niche_by_slug
from app.services.package_pricing import enforce_entry_price_cap
from app.services.price_filter import price_conditions, price_order, within_budget
from app.services.rewards import release_redemption_for_context, reserve_points_for_discount

from tests.test_booking_close import _ensure_account
from tests.test_client_booking_pay import _booking_with_gig
from tests.test_client_credit import _give, _h, fake_stripe  # noqa: F401 - fixture

D = Decimal
ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}


def _user(db, *, country: str | None = None, pro: bool = False) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db.flush()
    if pro:
        db.add(UserRole(user_id=uid, role=UserRoleType.pro))
        db.add(ProProfile(user_id=uid, display_name="Mo", country=country))
    db.commit()
    return uid


def _gig(db, *, currency: str, client=None, pro=None, price="100.00", status=GigStatus.completed) -> Gig:
    client = client or _user(db)
    pro = pro or _user(db, country="GB" if currency == "GBP" else "PT", pro=True)
    gig = Gig(client_user_id=client, pro_user_id=pro, status=status, currency=currency, amount_minimum=D(price),
              amount_final=D(price), amount_platform_fee=D("0.00"), amount_pro_gross=D("0.00"), meta={},
              retained_percent=15, pro_raww_percent=5, client_credit_percent=0)
    db.add(gig)
    db.commit()
    return gig


def _points(db, user, currency) -> int:
    row = db.get(RewardBalance, (user, currency))
    return int(row.balance) if row else 0


# --- client credit per currency ---------------------------------------------------------------


def test_credit_is_kept_per_currency_and_never_mixed(db_session):
    user = _user(db_session)
    _give(db_session, user, 1200, currency="EUR")
    _give(db_session, user, 3000, currency="GBP")

    assert (_points(db_session, user, "EUR"), _points(db_session, user, "GBP")) == (1200, 3000)
    assert client_credit.balances(db_session, user) == [
        {"currency": "EUR", "balance": D("12.00")},
        {"currency": "GBP", "balance": D("30.00")},
    ]


def test_pound_credit_pays_a_pound_booking_and_euro_credit_stays(client, db_session, fake_stripe):  # noqa: F811
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    gig.currency = "GBP"
    db_session.commit()
    _give(db_session, uuid.UUID(user_id), 3000, currency="GBP")
    _give(db_session, uuid.UUID(user_id), 1200, currency="EUR")

    preview = client.get(f"/v1/client/bookings/{booking.id}/credit", headers=_h(user_id)).json()
    assert (preview["balance"], preview["credit_currency"], preview["discount"], preview["total"]) == ("30.00", "GBP", "10.00", "90.00")

    resp = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()
    assert (resp["credit"], resp["amount"], resp["currency"]) == ("10.00", "90.00", "GBP")
    assert fake_stripe.creates[-1]["amount"] == 9000
    assert (_points(db_session, uuid.UUID(user_id), "GBP"), _points(db_session, uuid.UUID(user_id), "EUR")) == (2000, 1200)


def test_a_released_redemption_goes_back_to_its_own_currency(db_session):
    user = _user(db_session)
    _give(db_session, user, 3000, currency="GBP")
    context = uuid.uuid4()
    redemption = reserve_points_for_discount(
        db_session, user_id=user, context_type=RedemptionContextType.gig_payment, context_id=context,
        points=3000, payment_amount=D("100.00"), currency="GBP",
    )
    assert (redemption.currency, redemption.discount_amount) == ("GBP", D("10.00"))
    assert _points(db_session, user, "GBP") == 2000

    release_redemption_for_context(db_session, RedemptionContextType.gig_payment, context, reason="test")

    assert (_points(db_session, user, "GBP"), _points(db_session, user, "EUR")) == (3000, 0)


def test_the_credit_page_lists_every_currency_and_each_line_says_its_own(client, db_session):
    user = _user(db_session)
    _give(db_session, user, 150, currency="GBP")
    _give(db_session, user, 250, currency="EUR")

    body = client.get("/v1/me/credit", headers=_h(user)).json()
    assert body["balances"] == [{"balance": "2.50", "currency": "EUR"}, {"balance": "1.50", "currency": "GBP"}]
    assert sorted(item["currency"] for item in body["items"]) == ["EUR", "GBP"]


def test_marketing_credit_is_in_the_bookings_currency_against_that_currencys_budget(db_session):
    gig = _gig(db_session, currency="GBP")
    settings = client_credit.settings(db_session)
    settings.monthly_marketing_credit_budget_gbp = D("1.00")
    settings.monthly_marketing_credit_budget_eur = D("300.00")
    db_session.commit()

    entry = client_credit.award_marketing_credit(
        db_session, client_user_id=gig.client_user_id, amount_points=100, gig_id=gig.id, metadata={}, balance_floor=0
    )
    assert (entry.currency, entry.amount) == ("GBP", 100)
    # The pound budget is spent; a second award in pounds does not fit, and
    # the euro budget is untouched.
    second = _gig(db_session, currency="GBP", client=gig.client_user_id)
    assert client_credit.award_marketing_credit(
        db_session, client_user_id=gig.client_user_id, amount_points=100, gig_id=second.id, metadata={}, balance_floor=0
    ) is None
    assert client_credit.budget_view(db_session, "GBP")["awarded"] == D("1.00")
    assert client_credit.budget_view(db_session, "EUR")["awarded"] == D("0.00")


def test_the_pound_budget_alerts_admins_on_its_own(db_session, monkeypatch):
    admin_id = uuid.uuid4()
    monkeypatch.setattr("app.core.config.Settings.admin_user_id_set", lambda self: {admin_id})
    sent = []
    monkeypatch.setattr("app.services.notifications.enqueue_notification", lambda db, **kw: sent.append(kw))
    gig = _gig(db_session, currency="GBP")
    client_credit.settings(db_session).monthly_marketing_credit_budget_gbp = D("1.00")
    db_session.commit()

    client_credit.award_marketing_credit(
        db_session, client_user_id=gig.client_user_id, amount_points=100, gig_id=gig.id, metadata={}, balance_floor=0
    )

    alerts = [n for n in sent if n["notification_type"] == "admin.marketing_budget"]
    assert {n["payload"]["title"] for n in alerts} == {"Marketing credit budget (GBP) at 100%", "Marketing credit budget (GBP) at 80%"}
    assert "£1.00 of £1.00" in alerts[0]["payload"]["body"]
    row = client_credit.settings(db_session)
    assert row.alerted_100_month_gbp is not None and row.alerted_100_month is None


def test_the_admin_sets_and_reads_each_currencys_budget(client, db_session):
    _ensure_account(db_session, ADMIN["X-User-Id"])
    resp = client.put("/v1/admin/client-credit/settings", json={"monthly_marketing_credit_budget_gbp": "250.00"}, headers=ADMIN)
    assert resp.status_code == 200, resp.text
    assert (resp.json()["monthly_marketing_credit_budget_gbp"], resp.json()["monthly_marketing_credit_budget_eur"]) == ("250.00", "300.00")
    view = client.get("/v1/admin/client-credit/budget?currency=GBP", headers=ADMIN).json()
    assert (view["currency"], view["budget"]) == ("GBP", "250.00")


def test_a_referral_credits_both_sides_in_the_bookings_currency(db_session):
    from app.models.reward import ReferralConversionType
    from app.services.growth_engine import ensure_referral_profile, link_referee_to_referrer, maybe_issue_referral_conversion_reward

    referrer, referee = _user(db_session), _user(db_session)
    code = ensure_referral_profile(db_session, referrer).referral_code
    link_referee_to_referrer(db_session, referee_user_id=referee, referral_code=code, referee_email=f"{referee}@example.com")
    db_session.commit()

    result = maybe_issue_referral_conversion_reward(
        db_session, referee_user_id=referee, conversion_type=ReferralConversionType.booking_paid,
        conversion_id=uuid.uuid4(), conversion_value=D("120.00"), currency="GBP",
    )
    db_session.commit()

    assert result.grant is not None
    rows = db_session.execute(select(RewardLedgerEntry).where(RewardLedgerEntry.reference_type == "referral_conversion",
                                                              RewardLedgerEntry.user_id.in_([referrer, referee]))).scalars().all()
    assert rows and {r.currency for r in rows} == {"GBP"}
    assert _points(db_session, referrer, "EUR") == 0


# --- price caps per currency -------------------------------------------------------------------


def _caps(db, **by_currency):
    ensure_initial_niches(db)
    weddings = get_active_niche_by_slug(db, "weddings")
    for currency, maximum in by_currency.items():
        db.add(NichePackagePriceCap(niche_id=weddings.id, tier=SkillTier.rookie, entry_price_min=D("1.00"),
                                    entry_price_max=D(maximum), currency=currency))
    db.commit()
    return weddings


def test_a_pound_price_is_checked_against_the_pound_cap_only(db_session):
    weddings = _caps(db_session, EUR="5.00", GBP="8.00")

    enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=D("7.50"), currency="GBP")
    with pytest.raises(APIError):
        enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=D("8.50"), currency="GBP")
    with pytest.raises(APIError):
        enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=D("7.50"), currency="EUR")


def test_a_currency_with_no_cap_where_another_has_one_is_refused(db_session):
    weddings = _caps(db_session, EUR="5.00")

    with pytest.raises(APIError) as err:
        enforce_entry_price_cap(db_session, niche_id=weddings.id, tier=SkillTier.rookie, entry_price=D("3.00"), currency="GBP")
    assert err.value.code == "no_price_cap_for_currency"
    assert err.value.details == {"currency": "GBP", "caps_in": ["EUR"]}


def test_no_caps_at_all_is_still_no_restriction(db_session):
    ensure_initial_niches(db_session)
    portraits = get_active_niche_by_slug(db_session, "portraits")
    enforce_entry_price_cap(db_session, niche_id=portraits.id, tier=SkillTier.rookie, entry_price=D("999.00"), currency="GBP")


def test_the_admin_keeps_a_pound_and_a_euro_cap_for_the_same_niche_and_tier(client, db_session):
    _ensure_account(db_session, ADMIN["X-User-Id"])
    url = "/v1/admin/pricing/niche-package-price-caps"
    item = {"niche_slug": "weddings", "tier": "rookie", "entry_price_min": "1.00"}
    assert client.put(url, json={"items": [{**item, "entry_price_max": "5.00", "currency": "EUR"}]}, headers=ADMIN).status_code == 200
    assert client.put(url, json={"items": [{**item, "entry_price_max": "8.00", "currency": "gbp"}]}, headers=ADMIN).status_code == 200

    rows = {(r["currency"], r["entry_price_max"]) for r in client.get(url, headers=ADMIN).json() if r["niche_slug"] == "weddings" and r["tier"] == "rookie"}
    assert rows == {("EUR", "5.00"), ("GBP", "8.00")}
    missing = client.put(url, json={"items": [{**item, "entry_price_max": "5.00"}]}, headers=ADMIN)
    assert missing.status_code == 422  # a cap without a currency is refused


def test_the_pricing_preview_shows_the_photographers_currency_and_cap(client, db_session):
    weddings = _caps(db_session, EUR="5.00", GBP="8.00")
    pro = _user(db_session, country="GB", pro=True)

    body = client.get(f"/v1/pro/me/pricing/niches/{weddings.id}?entry_price=7.50&currency=EUR", headers={"X-User-Id": str(pro)}).json()
    assert (body["currency"], body["entry_price_max"], body["within_cap"]) == ("GBP", "8.00", True)


# --- discovery: a pound price is never compared as euros ---------------------------------------


def _index(db, *, currency: str, price: str, base: int | None):
    pro = uuid.uuid4()
    db.add(ProPublicIndex(pro_user_id=pro, currency=currency, min_package_price=D(price), min_package_price_base_minor=base))
    db.commit()
    return pro


def _matching(db, pros, **kw):
    stmt = select(ProPublicIndex.pro_user_id).where(ProPublicIndex.pro_user_id.in_(pros), *price_conditions(db, **kw))
    return set(db.execute(stmt).scalars().all())


def test_a_pound_budget_compares_pound_prices_exactly_and_leaves_euros_out_without_a_rate(db_session):
    gbp_500 = _index(db_session, currency="GBP", price="500.00", base=None)
    gbp_700 = _index(db_session, currency="GBP", price="700.00", base=None)
    eur_500 = _index(db_session, currency="EUR", price="500.00", base=50000)
    pros = [gbp_500, gbp_700, eur_500]

    assert _matching(db_session, pros, min_price=None, max_price=600, currency="GBP") == {gbp_500}
    # A euro budget: the euro price exactly; pound prices have no euro value yet.
    assert _matching(db_session, pros, min_price=None, max_price=600, currency="EUR") == {eur_500}


def test_a_euro_budget_compares_another_currency_by_its_euro_value_when_known(db_session):
    gbp_known = _index(db_session, currency="GBP", price="425.00", base=50000)  # £425 stamped at €500.00
    assert _matching(db_session, [gbp_known], min_price=None, max_price=600, currency="EUR") == {gbp_known}
    assert _matching(db_session, [gbp_known], min_price=None, max_price=400, currency="EUR") == set()


def test_price_sort_uses_the_euro_value_and_puts_unknown_ones_last(db_session):
    a = _index(db_session, currency="EUR", price="300.00", base=30000)
    b = _index(db_session, currency="EUR", price="200.00", base=20000)
    c = _index(db_session, currency="GBP", price="100.00", base=None)
    ordered = db_session.execute(
        select(ProPublicIndex.pro_user_id).where(ProPublicIndex.pro_user_id.in_([a, b, c])).order_by(*price_order(descending=False))
    ).scalars().all()
    assert ordered == [b, a, c]


def test_within_budget_follows_the_same_rule(db_session):
    row = ProPublicIndex(pro_user_id=uuid.uuid4(), currency="GBP", min_package_price=D("500.00"), min_package_price_base_minor=None)
    assert within_budget(db_session, row, D("600"), "GBP") is True
    assert within_budget(db_session, row, D("600"), "EUR") is False


def test_the_index_has_the_euro_value_of_euro_prices_and_none_for_pounds_without_a_rate(client, db_session):
    from tests.test_currency_money import _package_body

    eur_pro = _user(db_session, country="PT", pro=True)
    gbp_pro = _user(db_session, country="GB", pro=True)
    for pro in (eur_pro, gbp_pro):
        assert client.post("/v1/pro/me/packages", json=_package_body(), headers={"X-User-Id": str(pro)}).status_code == 200
    db_session.expire_all()
    eur_row, gbp_row = db_session.get(ProPublicIndex, eur_pro), db_session.get(ProPublicIndex, gbp_pro)

    assert eur_row.currency == "EUR" and eur_row.min_package_price_base_minor == int(eur_row.min_package_price * 100)
    assert gbp_row.currency == "GBP" and gbp_row.min_package_price_base_minor is None


# --- RAWW valued in the booking's currency -----------------------------------------------------


def _completed_booking(db, currency: str) -> Gig:
    gig = _gig(db, currency=currency)
    db.add(StripePayment(gig_id=gig.id, kind=StripePaymentKind.base, client_user_id=gig.client_user_id, status=PaymentStatus.succeeded,
                         stripe_payment_intent_id=f"pi_{uuid.uuid4().hex}", amount=D("100.00"), currency=currency, meta={}))
    db.commit()
    from app.services.photographer_money import record_gig_earnings

    record_gig_earnings(db, gig)
    db.commit()
    return gig


def _raww(db, gig) -> list[ProRawwLedgerEntry]:
    return db.execute(select(ProRawwLedgerEntry).where(ProRawwLedgerEntry.gig_id == gig.id)).scalars().all()


def test_a_euro_booking_stamps_its_euro_value(db_session):
    gig = _completed_booking(db_session, "EUR")
    [entry] = _raww(db_session, gig)
    assert (entry.amount, entry.raww_value, entry.raww_value_currency, entry.raww_eur_value) == (50, D("0.1000"), "EUR", D("0.1000"))


def test_a_pound_booking_is_valued_at_the_pound_value(db_session):
    from app.services.shelf_settings import shelf_settings

    shelf_settings(db_session).raww_gbp_value = D("0.08")
    db_session.commit()
    gig = _completed_booking(db_session, "GBP")
    [entry] = _raww(db_session, gig)
    assert (entry.amount, entry.raww_value, entry.raww_value_currency, entry.raww_eur_value) == (63, D("0.0800"), "GBP", None)


def test_a_pound_booking_with_no_pound_value_and_no_rate_waits_never_valued_as_euros(db_session):
    gig = _completed_booking(db_session, "GBP")
    assert _raww(db_session, gig) == []


# --- the rest of credit and bounds -------------------------------------------------------------


def test_a_consent_reward_is_credit_in_the_bookings_currency(db_session):
    from app.services.client_rewards_pricing import maybe_award_consent_points

    gig = _gig(db_session, currency="GBP")
    entry = maybe_award_consent_points(db_session, gig_id=gig.id, client_user_id=gig.client_user_id, consent_level="pro_marketing_only")
    assert entry is not None and entry.currency == "GBP"
    assert _points(db_session, gig.client_user_id, "GBP") == entry.amount and _points(db_session, gig.client_user_id, "EUR") == 0


def test_extra_photo_bounds_are_read_in_the_bookings_currency(db_session):
    from types import SimpleNamespace

    from app.models.client_rewards_pricing import ExtraImagePricingPolicy
    from app.services.client_rewards_pricing import compute_extra_image_unit_price

    ensure_initial_niches(db_session)
    weddings = get_active_niche_by_slug(db_session, "weddings")
    db_session.add(ExtraImagePricingPolicy(niche_id=weddings.id, tier=SkillTier.rookie, unit_price_min=D("10.00"), unit_price_max=None,
                                           max_extra_images=None, bulk_curve={}, currency="EUR", is_active=True))
    db_session.commit()
    gig = _gig(db_session, currency="GBP")
    gig.niche_id = weddings.id
    db_session.commit()

    configured, applied, minimum, _maximum, _tier = compute_extra_image_unit_price(
        db_session, gig=gig, gallery=SimpleNamespace(extra_photo_price=D("4.00"))
    )
    # The euro minimum (10.00) is not applied to a booking in pounds.
    assert (configured, applied, minimum) == (D("4.00"), D("4.00"), D("0.00"))


def test_credit_used_on_a_pound_booking_comes_back_in_pounds_when_refunded(client, db_session, fake_stripe, monkeypatch):  # noqa: F811
    from app.api.v1.webhooks import _apply_stripe_event
    from app.services.refund_reconcile import reconcile_payment_refunds

    held: dict[str, list[dict]] = {}
    monkeypatch.setattr("app.services.refund_reconcile.fetch_refunds", lambda pi: list(held.get(pi, [])))
    user_id = str(uuid.uuid4())
    _ensure_account(db_session, user_id)
    booking, gig = _booking_with_gig(db_session, user_id, str(uuid.uuid4()), gig_status=GigStatus.payment_pending)
    gig.currency, gig.amount_minimum, gig.retained_percent, gig.pro_raww_percent = "GBP", D("150.00"), 15, 5
    db_session.commit()
    _give(db_session, uuid.UUID(user_id), 500, currency="GBP")
    paid = client.post(f"/v1/client/bookings/{booking.id}/pay", json={"payment_mode": "full", "use_credit": True}, headers=_h(user_id)).json()
    assert (paid["credit"], paid["amount"]) == ("5.00", "145.00")
    _apply_stripe_event(db_session, "payment_intent.succeeded", {"id": paid["payment_intent_id"], "amount_received": 14500})
    db_session.commit()
    assert _points(db_session, uuid.UUID(user_id), "GBP") == 0

    held[paid["payment_intent_id"]] = [{"id": "re_gbp", "status": "succeeded", "amount": 14500, "created": 0}]
    assert reconcile_payment_refunds(db_session, paid["payment_intent_id"], trigger="test")
    db_session.commit()

    assert (_points(db_session, uuid.UUID(user_id), "GBP"), _points(db_session, uuid.UUID(user_id), "EUR")) == (500, 0)


def test_the_search_index_filter_compares_only_the_budgets_currency():
    from app.api.v1.search import _pros_filter

    text = _pros_filter(q=None, niche=None, city=None, country=None, min_price=None, max_price=600, tier_min=None, currency="GBP")
    assert 'currency = "GBP"' in text and "price_min <= 600.0" in text
    assert "currency" not in _pros_filter(q=None, niche=None, city=None, country=None, min_price=None, max_price=None, tier_min=None, currency="GBP")


def test_a_match_budget_in_pounds_is_never_compared_with_a_euro_price_as_pounds(db_session):
    from app.services.client_launch import MatchInput, score_pro_for_match

    req = MatchInput(country="GB", city="London", niche_slug="weddings", budget_min=None, budget_max=D("600"), style_tags=[], currency="GBP")
    gbp = ProPublicIndex(pro_user_id=uuid.uuid4(), currency="GBP", min_package_price=D("500.00"), max_package_price=D("500.00"),
                         min_package_price_base_minor=None, avg_rating=D("0"), review_count=0)
    eur = ProPublicIndex(pro_user_id=uuid.uuid4(), currency="EUR", min_package_price=D("500.00"), max_package_price=D("500.00"),
                         min_package_price_base_minor=50000, avg_rating=D("0"), review_count=0)
    ensure_initial_niches(db_session)
    niche = get_active_niche_by_slug(db_session, "weddings")
    assert score_pro_for_match(db_session, pro=gbp, req=req, niche_id=niche.id).breakdown["budget_overlap"] is True
    assert score_pro_for_match(db_session, pro=eur, req=req, niche_id=niche.id).breakdown["budget_overlap"] is False


def test_the_marketing_offer_checks_the_budget_of_the_bookings_currency(db_session):
    from app.services import marketing_consent as mc

    gig = _gig(db_session, currency="GBP")
    settings = client_credit.settings(db_session)
    settings.monthly_marketing_credit_budget_eur, settings.monthly_marketing_credit_budget_gbp = D("0.00"), D("300.00")
    db_session.commit()
    assert mc.credit_block(db_session, gig, gig.client_user_id, 12) is None

    settings.monthly_marketing_credit_budget_eur, settings.monthly_marketing_credit_budget_gbp = D("300.00"), D("0.00")
    db_session.commit()
    assert mc.credit_block(db_session, gig, gig.client_user_id, 12) == "budget"
