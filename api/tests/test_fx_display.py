"""Multi-currency M3: display rates and the display currency
(docs/MULTI_CURRENCY.md 2.2, 2.4, 4.1, 4.3; services/fx.py).

Hand-computed, at 1 EUR = 0.85123 GBP (the design's fixture, 7.2):
- €1,000.00 is 100000 × 0.85123 = 85123 pence: about £851.
- €12.34 is 1234 × 0.85123 = 1050.42, so 1050 pence: about £10.50.
- £850.00 is 85000 / 0.85123 = 99855.503, so 99856 cents: about €999. (The
  design's 7.2 says 99855.27 and 99855: an arithmetic slip; the shown
  "about €999" is the same.)
- At the half: 10 cents × 0.85 = 8.5, rounded up to 9.
- £425.00 at 0.85 is 42500 / 0.85 = 50000 euro cents.
- RAWW for a £100.00 booking with no pound value: €0.10 × 0.85 = £0.085 a
  RAWW, so £5.00 / 0.085 = 58.82, 59 RAWW.
"""
from __future__ import annotations

import uuid
from datetime import timedelta
from decimal import Decimal

import pytest
from sqlalchemy import select

from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.currency import CurrencySettings
from app.models.discovery import ProPublicIndex
from app.models.fx import FxRate
from app.services import fx
from app.services.bi import london_today

D = Decimal
ECB_XML = """<?xml version="1.0" encoding="UTF-8"?>
<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
  <gesmes:subject>Reference rates</gesmes:subject>
  <Cube>
    <Cube time="{day}">
      <Cube currency="USD" rate="1.0815"/>
      <Cube currency="GBP" rate="0.85123"/>
      <Cube currency="CHF" rate="0.9402"/>
    </Cube>
  </Cube>
</gesmes:Envelope>"""


def _rate(db, rate: str, days_old: int = 0, currency: str = "GBP") -> None:
    db.add(FxRate(base="EUR", quote=currency, rate=D(rate), as_of=london_today() - timedelta(days=days_old), source="ecb"))
    db.commit()


def _user(db) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db.commit()
    return uid


# --- the ECB file and the stored rates ---------------------------------------------------------


def test_the_ecb_file_is_read_and_only_supported_currencies_are_kept(db_session):
    day = london_today()
    as_of, rates = fx.parse_ecb_daily(ECB_XML.format(day=day.isoformat()))
    assert as_of == day and rates["GBP"] == D("0.85123") and rates["USD"] == D("1.0815")

    assert fx.store_rates(db_session, as_of, rates) == 1
    assert fx.store_rates(db_session, as_of, rates) == 0  # one row per day, never edited
    [row] = db_session.execute(select(FxRate)).scalars().all()
    assert (row.base, row.quote, row.rate, row.source) == ("EUR", "GBP", D("0.85123000"), "ecb")

    with pytest.raises(ValueError):  # a zero or negative rate is a broken file, not a rate
        fx.parse_ecb_daily(ECB_XML.format(day=day.isoformat()).replace("0.85123", "0"))


def test_a_rate_up_to_four_days_old_is_used_and_an_older_one_is_not(db_session):
    _rate(db_session, "0.85123", days_old=4)
    assert fx.rate_from_base(db_session, "GBP") == D("0.85123")
    db_session.query(FxRate).delete()
    _rate(db_session, "0.85123", days_old=5)
    assert fx.rate_from_base(db_session, "GBP") is None
    assert fx.rate_from_base(db_session, "EUR") == D("1")


def test_no_rate_at_all_is_no_rate(db_session):
    assert fx.rate_from_base(db_session, "GBP") is None
    assert fx.to_base_minor(db_session, D("425.00"), "GBP") is None


# --- display conversion (4.3) ------------------------------------------------------------------


@pytest.mark.parametrize(
    "amount_minor, from_currency, to_currency, rate, expected",
    [
        (100000, "EUR", "GBP", "0.85123", 85123),
        (1234, "EUR", "GBP", "0.85123", 1050),
        (85000, "GBP", "EUR", "0.85123", 99856),
        (10, "EUR", "GBP", "0.85", 9),  # 8.5 rounds half up
        (5000, "GBP", "GBP", "0.85", 5000),
    ],
)
def test_display_conversion_rounds_half_up_once(amount_minor, from_currency, to_currency, rate, expected):
    assert fx.convert_minor(amount_minor, from_currency, to_currency, rate_to_quote=D(rate)) == expected


def test_the_euro_value_of_a_pound_price(db_session):
    _rate(db_session, "0.85")
    assert fx.to_base_minor(db_session, D("425.00"), "GBP") == 50000


# --- the API -----------------------------------------------------------------------------------


def test_the_rates_route_sends_fresh_rates_only(client, db_session):
    _rate(db_session, "0.85123", days_old=1)
    body = client.get("/v1/fx/rates").json()
    assert body == {"base": "EUR", "rates": {"GBP": "0.85123000"}, "as_of": (london_today() - timedelta(days=1)).isoformat()}

    db_session.query(FxRate).delete()
    _rate(db_session, "0.85123", days_old=5)
    assert client.get("/v1/fx/rates").json() == {"base": "EUR", "rates": {}, "as_of": None}


@pytest.mark.uk_defaults
def test_the_display_currency_defaults_to_gbp_and_only_an_enabled_one_may_be_chosen(client, db_session):
    user = _user(db_session)
    headers = {"X-User-Id": str(user)}
    assert client.get("/v1/me/display-currency", headers=headers).json() == {"display_currency": "GBP", "chosen": False, "available": ["GBP"]}

    refused = client.put("/v1/me/display-currency", json={"display_currency": "EUR"}, headers=headers)
    assert refused.status_code == 422 and refused.json()["error"]["code"] == "currency_not_enabled"

    db_session.add(CurrencySettings(id=1, enabled_currencies=["GBP", "EUR"], payout_minimums={"GBP": "45.00", "EUR": "50.00"}))
    db_session.commit()
    chosen = client.put("/v1/me/display-currency", json={"display_currency": "eur"}, headers=headers).json()
    assert (chosen["display_currency"], chosen["chosen"]) == ("EUR", True)
    assert client.get("/v1/me", headers=headers).json()["display_currency"] == "EUR"

    back = client.put("/v1/me/display-currency", json={"display_currency": None}, headers=headers).json()
    assert (back["display_currency"], back["chosen"]) == ("GBP", False)


# --- the hourly job ----------------------------------------------------------------------------


def test_the_job_stores_the_day_and_reindexes_pound_prices(db_session):
    pro = uuid.uuid4()
    db_session.add(ProPublicIndex(pro_user_id=pro, currency="GBP", min_package_price=D("425.00"), min_package_price_base_minor=None))
    db_session.commit()

    result = fx.refresh_rates(db_session, fetch=lambda: ECB_XML.format(day=london_today().isoformat()).replace("0.85123", "0.85"))
    db_session.commit()

    assert (result["stored"], result["stale"], result["error"]) == (1, [], None)
    assert db_session.get(ProPublicIndex, pro).min_package_price_base_minor == 50000


def test_a_failed_fetch_changes_nothing_and_a_stale_rate_is_reported(db_session, monkeypatch):
    reported = []
    monkeypatch.setattr("app.core.sentry.capture_message", lambda message, **kw: reported.append((message, kw)))
    _rate(db_session, "0.85", days_old=6)

    def broken():
        raise OSError("unreachable")

    result = fx.refresh_rates(db_session, fetch=broken)

    assert (result["stored"], result["stale"], result["error"]) == (0, ["GBP"], "OSError")
    assert reported and reported[0][0] == "Exchange rate older than 4 days"
    assert db_session.execute(select(FxRate)).scalars().all()[0].rate == D("0.85000000")


def test_a_pound_booking_waiting_for_a_rate_earns_its_raww_once_there_is_one(db_session):
    from tests.test_currency_m4 import _completed_booking, _raww

    gig = _completed_booking(db_session, "GBP")
    assert _raww(db_session, gig) == []

    # the hourly job values it once it has stored a rate
    result = fx.refresh_rates(db_session, fetch=lambda: ECB_XML.format(day=london_today().isoformat()).replace("0.85123", "0.85"))
    assert result["raww_valued"] == 1
    [entry] = _raww(db_session, gig)
    assert (entry.amount, entry.raww_value, entry.raww_value_currency, entry.raww_eur_value) == (59, D("0.0850"), "GBP", D("0.1000"))


# --- where the display currency is used ----------------------------------------------------------


def test_a_chosen_currency_that_is_switched_off_falls_back_to_the_default(client, db_session):
    from app.services.currencies import default_currency, display_currency

    user = _user(db_session)
    headers = {"X-User-Id": str(user)}
    assert client.put("/v1/me/display-currency", json={"display_currency": "GBP"}, headers=headers).status_code == 200
    assert display_currency(db_session, user) == "GBP"

    db_session.add(CurrencySettings(id=1, enabled_currencies=["EUR"], payout_minimums={"EUR": "50.00"}))
    db_session.commit()
    db_session.expire_all()
    assert display_currency(db_session, user) == default_currency() == "EUR"


def _listed(db, *, currency: str, price: str, base: int | None) -> str:
    from app.models.admin import KYCStatus
    from app.models.launch_ops import ProOnboarding, ProOnboardingStatus

    pro = uuid.uuid4()
    db.add(UserAccount(user_id=pro, email=f"{pro}@example.com"))
    db.flush()
    db.add(ProOnboarding(pro_user_id=pro, status=ProOnboardingStatus.approved_public, current_city={"city": "Lisbon", "country": "PT"}))
    db.add(ProPublicIndex(pro_user_id=pro, currency=currency, min_package_price=D(price), min_package_price_base_minor=base,
                          kyc_status=KYCStatus.approved, is_accepting_bookings=True, completeness_score=90))
    db.commit()
    return str(pro)


def test_a_budget_without_a_currency_is_in_the_readers_display_currency(client, db_session):
    gbp = _listed(db_session, currency="GBP", price="500.00", base=None)
    eur = _listed(db_session, currency="EUR", price="500.00", base=50000)
    user = _user(db_session)
    headers = {"X-User-Id": str(user)}

    def found():
        body = client.get("/v1/discover/pros?max_price=600&limit=50", headers=headers).json()
        return {item["pro_user_id"] for item in body["items"]} & {gbp, eur}

    assert found() == {eur}  # the suite's default, the euro
    client.put("/v1/me/display-currency", json={"display_currency": "GBP"}, headers=headers)
    assert found() == {gbp}  # a pound budget: the pound price exactly, the euro one has no pound value


def test_the_client_preference_names_the_budget_currency(client, db_session):
    user = _user(db_session)
    headers = {"X-User-Id": str(user)}
    client.put("/v1/me/display-currency", json={"display_currency": "GBP"}, headers=headers)
    body = client.get("/v1/me/client-preference", headers=headers).json()
    assert body["currency"] == "GBP"


def test_rates_are_refreshed_every_hour_and_times_default_to_london():
    from celery.schedules import crontab

    from app.core.config import Settings
    from app.tasks.celery_app import celery_app

    entry = celery_app.conf.beat_schedule["fx-refresh"]
    assert entry["task"] == "app.tasks.scheduled.fx_refresh"
    assert entry["schedule"] == crontab(minute=15)
    assert Settings.model_fields["notification_default_timezone"].default == "Europe/London"
