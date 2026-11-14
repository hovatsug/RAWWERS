"""Multi-currency M1: the photographer's money carries its currency
(docs/MULTI_CURRENCY.md 2.1, 10.1, 10.3; services/currencies.py).

Hand-computed: a £100.00 booking at the 20% fee (15% kept, 5% RAWW) earns
the photographer £80.00 - the same digits as in euros, in pounds."""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal

import pytest

from app.core.errors import APIError
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.models.booking import ProPackage
from app.models.currency import CurrencySettings
from app.models.payouts import EarningsSourceType, PayoutAllocation, PayoutRequestStatus
from app.services import currencies, payouts as payouts_service
from app.services.payouts import (
    approve_payout_request,
    create_earnings_entry,
    create_payout_request,
    execute_payout_request,
    payout_balance_view,
    settle_due_earnings_entries,
)


def _pro(db, *, country: str | None, admin: bool = False) -> uuid.UUID:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid, email=f"{uid}@example.com"))
    db.flush()
    db.add(UserRole(user_id=uid, role=UserRoleType.admin if admin else UserRoleType.pro))
    if not admin:
        db.add(ProProfile(user_id=uid, display_name="Mo", country=country))
    db.commit()
    return uid


def _package_body(currency: str | None = None) -> dict:
    body = {
        "niche_slug": "portraits",
        "title": "Session",
        "duration_minutes": 60,
        "price": "100.00",
        "included_photos": 20,
        "extra_photo_price": "5.00",
        "addons": [],
    }
    if currency is not None:
        body["currency"] = currency
    return body


def _available(db, pro: uuid.UUID, gross: str, currency: str) -> None:
    entry = create_earnings_entry(
        db, pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=uuid.uuid4(), gross=Decimal(gross), currency=currency
    )
    entry.available_at = datetime.now(timezone.utc) - timedelta(days=1)
    db.flush()
    settle_due_earnings_entries(db)


# --- who gets which currency -------------------------------------------------------------------


@pytest.mark.uk_defaults
@pytest.mark.parametrize("country, expected", [("GB", "GBP"), ("gb", "GBP"), ("PT", "EUR"), ("IE", "EUR"), (None, "GBP"), ("US", "GBP")])
def test_a_new_photographer_takes_their_countrys_currency_else_gbp(db_session, country, expected):
    pro = _pro(db_session, country=country)
    assert db_session.get(ProProfile, pro).currency == expected


@pytest.mark.uk_defaults
def test_the_production_defaults_are_gbp_only(db_session):
    view = currencies.get_currency_settings(db_session)
    assert view.enabled_currencies == ("GBP",) and view.from_defaults
    assert view.payout_minimums == {"GBP": Decimal("45.00"), "EUR": Decimal("50.00")}
    assert currencies.default_currency() == "GBP"


@pytest.mark.parametrize("bad", [None, "", "  ", "usd", "XXX"])
def test_a_missing_or_unknown_currency_is_an_error(bad):
    with pytest.raises(APIError) as err:
        currencies.normalise(bad)
    assert err.value.code in {"currency_required", "unsupported_currency"}


def test_the_country_moves_the_currency_only_before_anything_exists(db_session, client):
    pro = _pro(db_session, country="PT")
    headers = {"X-User-Id": str(pro)}
    assert client.put("/v1/pro/me/profile", json={"country": "GB"}, headers=headers).status_code == 200
    db_session.expire_all()
    assert db_session.get(ProProfile, pro).currency == "GBP"

    assert client.post("/v1/pro/me/packages", json=_package_body(), headers=headers).status_code == 200
    assert client.put("/v1/pro/me/profile", json={"country": "PT"}, headers=headers).status_code == 200
    db_session.expire_all()
    assert db_session.get(ProProfile, pro).currency == "GBP"  # a package exists: fixed


# --- packages ----------------------------------------------------------------------------------


@pytest.mark.uk_defaults
def test_a_package_is_in_the_photographers_currency(db_session, client):
    pro = _pro(db_session, country="GB")
    resp = client.post("/v1/pro/me/packages", json=_package_body(), headers={"X-User-Id": str(pro)})
    assert resp.status_code == 200, resp.text
    assert resp.json()["currency"] == "GBP"
    assert db_session.query(ProPackage).filter_by(pro_user_id=pro).one().currency == "GBP"


@pytest.mark.uk_defaults
def test_a_package_in_another_currency_is_refused(db_session, client):
    pro = _pro(db_session, country="GB")
    resp = client.post("/v1/pro/me/packages", json=_package_body("EUR"), headers={"X-User-Id": str(pro)})
    assert resp.status_code == 422 and resp.json()["error"]["code"] == "currency_mismatch"


@pytest.mark.uk_defaults
def test_a_currency_that_is_not_enabled_gets_no_package(db_session, client):
    pro = _pro(db_session, country="PT")  # EUR, and only GBP is enabled
    resp = client.post("/v1/pro/me/packages", json=_package_body(), headers={"X-User-Id": str(pro)})
    assert resp.status_code == 422 and resp.json()["error"]["code"] == "currency_not_enabled"
    # Enabled by the admin setting: then it works.
    currencies.update_currency_settings(
        db_session, enabled_currencies=["GBP", "EUR"], payout_minimums={"GBP": Decimal("45"), "EUR": Decimal("50")}, admin_user_id=None
    )
    db_session.commit()
    resp = client.post("/v1/pro/me/packages", json=_package_body(), headers={"X-User-Id": str(pro)})
    assert resp.status_code == 200 and resp.json()["currency"] == "EUR"


# --- earnings, balance, payouts ----------------------------------------------------------------


@pytest.mark.uk_defaults
def test_a_gbp_photographers_earnings_balance_and_payout_are_in_gbp(db_session, monkeypatch):
    pro = _pro(db_session, country="GB")
    _available(db_session, pro, "100.00", "GBP")

    balance = payout_balance_view(db_session, pro_user_id=pro)
    assert balance["currency"] == "GBP"
    assert balance["withdrawable"] == Decimal("80.00")  # £100 less the 20% fee

    sent = []
    monkeypatch.setattr(payouts_service.stripe.Transfer, "create", lambda **kw: sent.append(kw) or type("T", (), {"id": "tr_1"})())
    payouts_service.get_or_create_payout_account(db_session, pro_user_id=pro)
    account = payouts_service.get_or_create_payout_account(db_session, pro_user_id=pro)
    account.payout_method = payouts_service.PayoutMethod.stripe_connect
    account.status = payouts_service.PayoutAccountStatus.active
    account.stripe_connect_account_id = "acct_gb"
    account.updated_at = datetime.now(timezone.utc) - timedelta(days=3)  # not a just-changed account (payout anomaly rule)

    row = create_payout_request(db_session, pro_user_id=pro, amount=Decimal("45.00"))
    assert (row.currency, row.amount) == ("GBP", Decimal("45.00"))
    admin = _pro(db_session, country=None, admin=True)
    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=admin)
    [alloc] = db_session.query(PayoutAllocation).filter_by(payout_request_id=row.id).all()
    assert (alloc.currency, alloc.amount) == ("GBP", Decimal("45.00"))

    execute_payout_request(db_session, payout_request_id=row.id)
    assert row.status == PayoutRequestStatus.paid
    assert sent[0]["currency"] == "gbp" and sent[0]["amount"] == 4500


@pytest.mark.uk_defaults
def test_the_withdrawal_minimum_is_per_currency(db_session):
    gbp = _pro(db_session, country="GB")
    _available(db_session, gbp, "100.00", "GBP")
    with pytest.raises(APIError) as err:
        create_payout_request(db_session, pro_user_id=gbp, amount=Decimal("44.99"))
    assert err.value.details == {"minimum": "45.00", "currency": "GBP"}
    assert "£45.00" in err.value.message
    assert create_payout_request(db_session, pro_user_id=gbp, amount=Decimal("45.00")).currency == "GBP"


def test_the_eur_minimum_stays_50(db_session):
    eur = _pro(db_session, country="PT")
    _available(db_session, eur, "100.00", "EUR")
    with pytest.raises(APIError) as err:
        create_payout_request(db_session, pro_user_id=eur, amount=Decimal("49.99"))
    assert err.value.details == {"minimum": "50.00", "currency": "EUR"}


@pytest.mark.uk_defaults
def test_an_earning_in_another_currency_is_refused(db_session):
    pro = _pro(db_session, country="GB")
    with pytest.raises(APIError) as err:
        create_earnings_entry(
            db_session, pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=uuid.uuid4(),
            gross=Decimal("100.00"), currency="EUR",
        )
    assert err.value.code == "currency_mismatch"


@pytest.mark.uk_defaults
def test_a_payout_in_the_wrong_currency_is_never_transferred(db_session, monkeypatch):
    pro = _pro(db_session, country="GB")
    _available(db_session, pro, "100.00", "GBP")
    sent = []
    monkeypatch.setattr(payouts_service.stripe.Transfer, "create", lambda **kw: sent.append(kw))
    account = payouts_service.get_or_create_payout_account(db_session, pro_user_id=pro)
    account.payout_method = payouts_service.PayoutMethod.stripe_connect
    account.status = payouts_service.PayoutAccountStatus.active
    account.stripe_connect_account_id = "acct_gb"
    account.updated_at = datetime.now(timezone.utc) - timedelta(days=3)  # not a just-changed account (payout anomaly rule)
    row = create_payout_request(db_session, pro_user_id=pro, amount=Decimal("50.00"))
    row.status = PayoutRequestStatus.approved
    row.currency = "EUR"  # as if written wrongly
    execute_payout_request(db_session, payout_request_id=row.id)
    assert sent == [] and row.status == PayoutRequestStatus.failed
    assert row.failure_reason.startswith("currency_mismatch")


@pytest.mark.uk_defaults
def test_the_payout_notice_is_in_the_payouts_currency(db_session):
    from app.models.outbox import OutboxEvent

    pro = _pro(db_session, country="GB")
    _available(db_session, pro, "100.00", "GBP")
    row = create_payout_request(db_session, pro_user_id=pro, amount=Decimal("60.00"))
    payouts_service._notify_payout_paid(db_session, row)
    db_session.flush()
    [event] = [
        e for e in db_session.query(OutboxEvent).filter_by(topic="notify.create_inapp").all()
        if e.payload.get("user_id") == str(pro) and e.payload.get("type") == "payout.paid"
    ]
    assert event.payload["payload"]["body"] == "£60.00 is on its way to your bank account."
    assert event.payload["payload"]["currency"] == "GBP"


def test_the_balance_route_returns_the_currency(db_session, client):
    pro = _pro(db_session, country="PT")
    _available(db_session, pro, "100.00", "EUR")
    db_session.commit()
    body = client.get("/v1/pro/earnings/balance", headers={"X-User-Id": str(pro)}).json()
    assert body["currency"] == "EUR" and body["withdrawable"] == "80.00"
    assert not any(key.endswith("_eur") for key in body)
    ledger = client.get("/v1/pro/earnings/ledger", headers={"X-User-Id": str(pro)}).json()["items"]
    assert ledger[0]["currency"] == "EUR" and ledger[0]["net"] == "80.00"


# --- Connect -----------------------------------------------------------------------------------


@pytest.mark.uk_defaults
def test_a_connect_account_sets_the_currency_from_its_country(db_session, monkeypatch):
    from app.services import stripe_connect

    created = []
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: type("S", (), {"Account": type("A", (), {"create": staticmethod(lambda **kw: created.append(kw) or {"id": "acct_1"})})}))
    pro = _pro(db_session, country=None)
    stripe_connect.ensure_connect_account(db_session, pro_user_id=pro, email=None, country="GB")
    assert created[0]["country"] == "GB"
    assert db_session.get(ProProfile, pro).currency == "GBP"


@pytest.mark.uk_defaults
@pytest.mark.parametrize("country, code", [("PT", "currency_not_enabled"), ("US", "country_not_supported")])
def test_a_connect_account_in_a_currency_not_enabled_is_refused(db_session, monkeypatch, country, code):
    from app.services import stripe_connect

    created = []
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: type("S", (), {"Account": type("A", (), {"create": staticmethod(lambda **kw: created.append(kw) or {"id": "acct_1"})})}))
    pro = _pro(db_session, country=None)
    with pytest.raises(APIError) as err:
        stripe_connect.ensure_connect_account(db_session, pro_user_id=pro, email=None, country=country)
    assert err.value.code == code and created == []


def test_a_connect_account_cannot_switch_a_photographers_money_to_another_currency(db_session, monkeypatch):
    from app.services import stripe_connect

    created = []
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: type("S", (), {"Account": type("A", (), {"create": staticmethod(lambda **kw: created.append(kw) or {"id": "acct_1"})})}))
    pro = _pro(db_session, country="PT")
    _available(db_session, pro, "100.00", "EUR")
    with pytest.raises(APIError) as err:
        stripe_connect.ensure_connect_account(db_session, pro_user_id=pro, email=None, country="GB")
    assert err.value.code == "currency_mismatch" and created == []


# --- the admin setting -------------------------------------------------------------------------


@pytest.mark.uk_defaults
def test_the_admin_reads_and_changes_the_currency_settings(db_session, client):
    admin = _pro(db_session, country=None, admin=True)
    headers = {"X-User-Id": str(admin)}
    body = client.get("/v1/admin/finance/currency-settings", headers=headers).json()
    assert body == {"enabled_currencies": ["GBP"], "payout_minimums": {"GBP": "45.00", "EUR": "50.00"}, "default_currency": "GBP", "from_defaults": True}

    missing = client.put("/v1/admin/finance/currency-settings", json={"enabled_currencies": ["GBP", "EUR"], "payout_minimums": {"GBP": "45"}}, headers=headers)
    assert missing.status_code == 422

    ok = client.put("/v1/admin/finance/currency-settings", json={"enabled_currencies": ["gbp", "EUR"], "payout_minimums": {"GBP": "45", "EUR": "50"}}, headers=headers)
    assert ok.status_code == 200, ok.text
    assert ok.json()["enabled_currencies"] == ["GBP", "EUR"] and ok.json()["from_defaults"] is False
    db_session.expire_all()
    assert db_session.get(CurrencySettings, 1).payout_minimums == {"GBP": "45.00", "EUR": "50.00"}


def test_only_an_admin_changes_the_currency_settings(db_session, client):
    pro = _pro(db_session, country="GB")
    resp = client.put("/v1/admin/finance/currency-settings", json={"enabled_currencies": ["EUR"], "payout_minimums": {"EUR": "1"}}, headers={"X-User-Id": str(pro)})
    assert resp.status_code == 403


# --- BI counts euros only (until M5) -----------------------------------------------------------


def test_bi_leaves_gbp_photographer_money_out_of_its_euro_totals(db_session):
    from app.services import bi

    eur = _pro(db_session, country="PT")
    gbp = _pro(db_session, country="GB")
    _available(db_session, eur, "100.00", "EUR")
    _available(db_session, gbp, "100.00", "GBP")
    db_session.commit()
    owed = bi.owed(db_session, None)
    assert owed["photographers"]["due_cents"] == 8000  # €80.00 only; the £80.00 is left out


@pytest.mark.uk_defaults
def test_a_stray_row_in_another_currency_is_never_counted_or_paid_out(db_session):
    """Defence in depth: should a row in another currency ever exist (written
    by hand, say), the balance leaves it out and a payout never takes it."""
    from app.models.payouts import EarningsEntryStatus, EarningsLedgerEntry

    pro = _pro(db_session, country="GB")
    _available(db_session, pro, "100.00", "GBP")  # £80.00 withdrawable
    db_session.add(EarningsLedgerEntry(
        pro_user_id=pro, source_type=EarningsSourceType.gig_base, source_id=uuid.uuid4(), currency="EUR",
        gross=Decimal("1000.00"), platform_fee=Decimal("200.00"), net=Decimal("800.00"),
        status=EarningsEntryStatus.available, available_at=datetime.now(timezone.utc) - timedelta(days=1),
        created_at=datetime.now(timezone.utc) - timedelta(days=10),  # older: allocation takes the oldest first
    ))
    db_session.flush()
    assert payout_balance_view(db_session, pro_user_id=pro)["withdrawable"] == Decimal("80.00")

    row = create_payout_request(db_session, pro_user_id=pro, amount=Decimal("80.00"))
    approve_payout_request(db_session, payout_request_id=row.id, admin_user_id=_pro(db_session, country=None, admin=True))
    allocations = db_session.query(PayoutAllocation).filter_by(payout_request_id=row.id).all()
    assert {a.currency for a in allocations} == {"GBP"}
    assert sum(a.amount for a in allocations) == Decimal("80.00")
    # Taken from the pound earning, never from the older euro row.
    assert {db_session.get(EarningsLedgerEntry, a.earnings_ledger_entry_id).currency for a in allocations} == {"GBP"}
