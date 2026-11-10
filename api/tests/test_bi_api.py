"""/v1/admin/bi/*: admin only, every route; the numbers through the API; the
manual tables with their audit trail; pagination and caps."""
import uuid
from datetime import date

import pytest
from sqlalchemy import select

from app.models.admin import AdminAuditLog, UserAccount, UserRole, UserRoleType
from app.models.bi import BiCost
from app.services import bi_stripe

from tests.test_bi import D1, D2, build_world

ADMIN = {"X-User-Id": "00000000-0000-0000-0000-0000000000aa"}
PERIOD = {"period": "custom", "start": D1.isoformat(), "end": D2.isoformat()}
COST = {"date": "2026-10-05", "category": "ad_spend", "amount": "12.34", "note": "Meta ads"}
CASH = {"date": "2026-10-05", "account": "Bank", "amount": "1000.00"}

READS = [
    "/v1/admin/bi/overview", "/v1/admin/bi/series", "/v1/admin/bi/breakdown?by=niche", "/v1/admin/bi/bookings",
    "/v1/admin/bi/reconciliation", "/v1/admin/bi/owed", "/v1/admin/bi/costs", "/v1/admin/bi/cash",
]
WRITES = [
    ("post", "/v1/admin/bi/costs", COST), ("patch", f"/v1/admin/bi/costs/{uuid.uuid4()}", {"note": "x"}),
    ("delete", f"/v1/admin/bi/costs/{uuid.uuid4()}", None), ("post", "/v1/admin/bi/cash", CASH),
    ("patch", f"/v1/admin/bi/cash/{uuid.uuid4()}", {"note": "x"}), ("delete", f"/v1/admin/bi/cash/{uuid.uuid4()}", None),
    ("post", "/v1/admin/bi/recompute", {"start": "2026-10-05", "end": "2026-10-06"}),
    ("post", "/v1/admin/bi/stripe-sync", {"start": "2026-10-05", "end": "2026-10-06"}),
]


def _person(db, role: UserRoleType | None) -> dict:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid))
    db.flush()
    if role is not None:
        db.add(UserRole(user_id=uid, role=role))
    db.commit()
    return {"X-User-Id": str(uid)}


def _call(client, method, url, body, headers):
    kwargs = {"headers": headers}
    if body is not None:
        kwargs["json"] = body
    return getattr(client, method)(url, **kwargs)


def test_every_route_refuses_everyone_but_an_admin(client, db_session):
    callers = {
        "anonymous": ({}, (401,)),
        "client": (_person(db_session, UserRoleType.client), (403,)),
        "photographer": (_person(db_session, UserRoleType.pro), (403,)),
    }
    routes = [("get", url, None) for url in READS] + WRITES
    for who, (headers, expected) in callers.items():
        for method, url, body in routes:
            status = _call(client, method, url, body, headers).status_code
            assert status in expected, (who, method, url, status)
    assert db_session.execute(select(BiCost)).first() is None


def test_an_admin_reads_every_route(client, db_session, monkeypatch):
    monkeypatch.setattr(bi_stripe, "stripe_configured", lambda: False)
    for url in READS:
        sep = "&" if "?" in url else "?"
        resp = client.get(f"{url}{sep}period=custom&start={D1}&end={D2}", headers=ADMIN)
        assert resp.status_code == 200, (url, resp.text)


def test_the_overview_through_the_api(client, db_session):
    build_world(db_session)
    body = client.get("/v1/admin/bi/overview", params=PERIOD, headers=ADMIN).json()
    kpis = {k["key"]: k for k in body["kpis"]}
    assert kpis["gmv"]["value"] == 17243 and kpis["operating_profit"]["value"] == -14987
    assert kpis["gmv"]["previous"] == 0 and kpis["gmv"]["change_bp"] is None
    assert body["waterfall"]["adds_up"] is True
    assert body["previous"] == {"from": "2026-10-03", "to": "2026-10-04"}


def test_filters_and_drill_down_through_the_api(client, db_session):
    world = build_world(db_session)
    body = client.get("/v1/admin/bi/overview", params={**PERIOD, "country": "pt"}, headers=ADMIN).json()
    assert body["filters"]["country"] == "PT" and body["values"]["gmv"] == 11000
    page = client.get("/v1/admin/bi/bookings", params={**PERIOD, "country": "PT"}, headers=ADMIN).json()
    assert [i["gig_id"] for i in page["items"]] == [str(world.g1.id)]
    page = client.get("/v1/admin/bi/bookings", params={**PERIOD, "pro": str(world.p2)}, headers=ADMIN).json()
    assert [i["gig_id"] for i in page["items"]] == [str(world.g2.id)]


def test_a_cost_s_life_is_audited(client, db_session):
    created = client.post("/v1/admin/bi/costs", json=COST, headers=ADMIN)
    assert created.status_code == 201
    cost = created.json()
    assert cost["amount_cents"] == 1234 and cost["created_by"] == ADMIN["X-User-Id"]
    edited = client.patch(f"/v1/admin/bi/costs/{cost['id']}", json={"amount": "20.00"}, headers=ADMIN).json()
    assert edited["amount_cents"] == 2000 and edited["updated_by"] == ADMIN["X-User-Id"] and edited["updated_at"]
    assert client.delete(f"/v1/admin/bi/costs/{cost['id']}", headers=ADMIN).json() == {"deleted": True}
    assert client.get("/v1/admin/bi/costs", headers=ADMIN).json()["items"] == []
    log = db_session.execute(select(AdminAuditLog).where(AdminAuditLog.target_id == cost["id"]).order_by(AdminAuditLog.created_at)).scalars().all()
    assert [entry.action for entry in log] == ["create", "update", "delete"]
    assert log[1].meta["before"]["amount_cents"] == 1234 and log[1].meta["after"]["amount_cents"] == 2000
    row = db_session.get(BiCost, uuid.UUID(cost["id"]))
    assert row.deleted_at is not None and str(row.deleted_by) == ADMIN["X-User-Id"]


@pytest.mark.parametrize("bad", [
    {"category": "lunch"}, {"amount": "0"}, {"amount": "-5"}, {"amount": "1.234"}, {"currency": "EURO"},
    {"end_date": "2026-12-01"},
])
def test_a_bad_cost_is_refused(client, db_session, bad):
    assert client.post("/v1/admin/bi/costs", json={**COST, **bad}, headers=ADMIN).status_code == 422
    assert db_session.execute(select(BiCost)).first() is None


def test_company_cash_and_the_latest_balance(client, db_session, monkeypatch):
    monkeypatch.setattr(bi_stripe, "stripe_configured", lambda: False)
    first = client.post("/v1/admin/bi/cash", json=CASH, headers=ADMIN).json()
    client.post("/v1/admin/bi/cash", json={**CASH, "date": "2026-10-09", "amount": "1500.50"}, headers=ADMIN)
    client.patch(f"/v1/admin/bi/cash/{first['id']}", json={"note": "opening"}, headers=ADMIN)
    owed = client.get("/v1/admin/bi/owed", headers=ADMIN).json()
    assert owed["company_cash"]["total_cents"] == 150050
    assert owed["liquid"] == {"cents": None, "reason": "Stripe is not configured"}


def test_lists_are_paginated(client, db_session):
    for i in range(3):
        client.post("/v1/admin/bi/costs", json={**COST, "date": f"2026-10-0{i + 1}"}, headers=ADMIN)
    page = client.get("/v1/admin/bi/costs", params={"limit": 2}, headers=ADMIN).json()
    assert len(page["items"]) == 2 and page["next_offset"] == 2
    rest = client.get("/v1/admin/bi/costs", params={"limit": 2, "offset": 2}, headers=ADMIN).json()
    assert len(rest["items"]) == 1 and rest["next_offset"] is None
    assert client.get("/v1/admin/bi/costs", params={"limit": 101}, headers=ADMIN).status_code == 422


def test_days_are_capped_per_request(client, db_session):
    long = {"period": "custom", "start": "2023-01-01", "end": "2026-01-01"}
    assert client.get("/v1/admin/bi/overview", params=long, headers=ADMIN).status_code == 422
    resp = client.post("/v1/admin/bi/recompute", json={"start": "2026-01-01", "end": "2026-06-01"}, headers=ADMIN)
    assert resp.status_code == 422


def test_recompute_and_stripe_sync(client, db_session, monkeypatch):
    class FakeStripe:
        def balance_transactions(self, gte, lt):
            return [{"id": f"txn_{gte}", "type": "charge", "currency": "eur", "amount": 1000, "fee": 40, "net": 960,
                     "created": gte + 3600, "available_on": gte + 86400 * 2, "source": "ch_1"}]

    monkeypatch.setattr(bi_stripe, "stripe_configured", lambda: True)
    monkeypatch.setattr(bi_stripe, "LiveStripe", FakeStripe)
    resp = client.post("/v1/admin/bi/stripe-sync", json={"start": "2026-10-05", "end": "2026-10-06"}, headers=ADMIN)
    assert resp.json() == {"days": 2, "transactions": 2}
    body = client.get("/v1/admin/bi/overview", params=PERIOD, headers=ADMIN).json()
    assert body["values"]["stripe_fees"] == 80
    assert client.post("/v1/admin/bi/stripe-sync", json={"start": "2026-10-05", "end": "2026-10-06"}, headers=ADMIN).json()["transactions"] == 2
    body = client.get("/v1/admin/bi/overview", params=PERIOD, headers=ADMIN).json()
    assert body["values"]["stripe_fees"] == 80  # mirrored again, not twice
    assert client.post("/v1/admin/bi/recompute", json={"start": "2026-10-05", "end": "2026-10-06"}, headers=ADMIN).json()["rows"] == 2


def test_periods(client, db_session):
    from datetime import datetime, timezone

    from app.services.bi import period_bounds

    now = datetime(2026, 11, 9, 12, tzinfo=timezone.utc)
    assert period_bounds("today", None, None, now) == (date(2026, 11, 9), date(2026, 11, 9))
    assert period_bounds("7d", None, None, now) == (date(2026, 11, 3), date(2026, 11, 9))
    assert period_bounds("this_month", None, None, now) == (date(2026, 11, 1), date(2026, 11, 9))
    assert period_bounds("last_month", None, None, now) == (date(2026, 10, 1), date(2026, 10, 31))
    assert client.get("/v1/admin/bi/overview", params={"period": "fortnight"}, headers=ADMIN).status_code == 422


def test_the_bi_routes_have_their_own_higher_rate_limit(client, db_session, monkeypatch):
    from app.services import rate_limit as rl

    # The configured allowances: 240 a minute for /v1/admin/bi/*, 60 for the rest.
    assert rl.RATE_LIMIT_RULES["admin_bi"] == (240, 60)
    assert rl.RATE_LIMIT_RULES["admin"] == (60, 60)

    # Scaled down to count them: BI 4, other admin routes 2. A fresh admin each
    # run, since the counters live in the real Redis for a minute.
    monkeypatch.setitem(rl.RATE_LIMIT_RULES, "admin_bi", (4, 60))
    monkeypatch.setitem(rl.RATE_LIMIT_RULES, "admin", (2, 60))
    admin = _person(db_session, UserRoleType.admin)
    bi, other = "/v1/admin/bi/owed", "/v1/admin/shelf/settings"

    assert [client.get(bi, headers=admin).status_code for _ in range(4)] == [200] * 4
    assert client.get(bi, headers=admin).status_code == 429
    # The BI calls spent none of the general allowance, which stays at its own 2.
    assert [client.get(other, headers=admin).status_code for _ in range(2)] == [200] * 2
    over = client.get(other, headers=admin)
    assert over.status_code == 429 and over.json()["error"]["details"]["limit"] == 2


def test_who_you_are_is_settled_before_any_rate_limit(client, db_session, monkeypatch):
    from app.services import rate_limit as rl

    # No allowance at all: an admin is limited, everyone else is still refused
    # for who they are (401/403), never 429.
    monkeypatch.setitem(rl.RATE_LIMIT_RULES, "admin_bi", (0, 60))
    monkeypatch.setitem(rl.RATE_LIMIT_RULES, "admin", (0, 60))
    callers = {
        "anonymous": ({}, 401),
        "client": (_person(db_session, UserRoleType.client), 403),
        "photographer": (_person(db_session, UserRoleType.pro), 403),
        "admin": (_person(db_session, UserRoleType.admin), 429),
    }
    for url in ("/v1/admin/bi/overview", "/v1/admin/shelf/settings"):
        for who, (headers, expected) in callers.items():
            assert client.get(url, headers=headers).status_code == expected, (who, url)
