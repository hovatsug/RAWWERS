"""A delivery token opens the delivery routes and nothing else.

Every route outside /v1/delivery is called twice: with no credentials, and
with a working delivery token. The token must never get further than no
credentials at all: wherever anonymous is refused, the token is refused too.
A new route that accepted it - by reading the token some other way - fails
here.

(What the delivery routes themselves return about a client is pinned in
test_delivery_gigs.py.)
"""
import re
import uuid

import pytest
from fastapi.routing import APIRoute
from fastapi.testclient import TestClient

from app.main import app
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.services import rate_limit


def _ok(status: int) -> bool:
    return 200 <= status < 300


def _routes():
    for route in app.routes:
        if not isinstance(route, APIRoute) or route.path.startswith("/v1/delivery"):
            continue
        for method in sorted(route.methods - {"HEAD", "OPTIONS"}):
            yield method, route.path


def _fill(path: str) -> str:
    return re.sub(r"\{[^}]+\}", lambda _m: str(uuid.uuid4()), path)


@pytest.fixture
def token(client, db_session, monkeypatch):
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_ip", (100_000, 600))
    monkeypatch.setitem(rate_limit.RATE_LIMIT_RULES, "delivery_pair_all", (100_000, 600))
    pro = uuid.uuid4()
    db_session.add(UserAccount(user_id=pro))
    db_session.flush()
    db_session.add(UserRole(user_id=pro, role=UserRoleType.pro))
    db_session.add(ProProfile(user_id=pro, display_name="Scope Test"))
    db_session.commit()
    code = client.post("/v1/pro/lightroom/pairing-code", headers={"X-User-Id": str(pro)}).json()["code"]
    paired = client.post("/v1/delivery/pair", json={"code": code, "device_name": "Scope"})
    assert paired.status_code == 200, paired.text
    return paired.json()["token"]


def test_there_are_routes_to_check():
    assert len(list(_routes())) > 200


def test_the_token_gets_no_further_than_no_credentials_anywhere_else(client, token):
    # A route that crashes on an empty body is a 500 here, not a stopped test:
    # a crash is not access. (The `client` fixture's database overrides stay
    # in force for this second client.)
    sweep = TestClient(app, raise_server_exceptions=False)
    widened = []
    for method, path in _routes():
        url = _fill(path)
        anonymous = sweep.request(method, url, json={})
        with_token = sweep.request(method, url, json={}, headers={"Authorization": f"Bearer {token}"})
        if _ok(with_token.status_code) and not _ok(anonymous.status_code):
            widened.append(f"{method} {path}: {anonymous.status_code} anonymous, {with_token.status_code} with the token")
    assert widened == []


def test_the_token_works_where_it_should(client, token):
    # The check above means nothing if the token were simply broken.
    assert client.get("/v1/delivery/me", headers={"Authorization": f"Bearer {token}"}).status_code == 200
