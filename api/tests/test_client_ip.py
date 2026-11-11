"""The client's IP: X-Forwarded-For is believed only from a trusted proxy.

The admin IP allowlist and the rate limits key on `core/client_ip.client_ip`.
A caller who sets the header itself changes nothing; a header a configured
proxy adds is read from the right.
"""
import uuid

import pytest
from fastapi.testclient import TestClient
from starlette.requests import Request

from app.api.deps import get_db_read_session, get_db_session, get_db_write_session
from app.core.client_ip import client_ip, parse_ip
from app.core.config import get_settings
from app.main import app
from app.models.admin import UserAccount, UserRole, UserRoleType
from app.services import rate_limit as rl

PROXY = "10.0.0.5"
CLIENT = "203.0.113.10"
OTHER = "198.51.100.7"
ADMIN_URL = "/v1/admin/shelf/settings"


def _request(peer: str, xff: str | None = None) -> Request:
    headers = [(b"x-forwarded-for", xff.encode())] if xff is not None else []
    return Request({"type": "http", "method": "GET", "path": "/", "headers": headers, "client": (peer, 1234)})


@pytest.fixture
def proxies(monkeypatch):
    settings = get_settings()

    def configure(ips: str, hops: int = 1) -> None:
        monkeypatch.setattr(settings, "trusted_proxy_ips", ips)
        monkeypatch.setattr(settings, "trusted_proxy_hops", hops)

    configure("", 1)
    return configure


@pytest.fixture
def connect(db_session):
    """A TestClient whose connection comes from the given address."""
    def override():
        yield db_session

    app.dependency_overrides[get_db_session] = override
    app.dependency_overrides[get_db_write_session] = override
    app.dependency_overrides[get_db_read_session] = override
    opened = []

    def make(peer: str) -> TestClient:
        c = TestClient(app, client=(peer, 50000))
        c.__enter__()
        opened.append(c)
        return c

    yield make
    for c in opened:
        c.__exit__(None, None, None)
    app.dependency_overrides.clear()


def _admin(db) -> dict:
    uid = uuid.uuid4()
    db.add(UserAccount(user_id=uid))
    db.flush()
    db.add(UserRole(user_id=uid, role=UserRoleType.admin))
    db.commit()
    return {"X-User-Id": str(uid)}


# --- the rule itself ---------------------------------------------------------


def test_with_no_trusted_proxy_the_header_is_ignored(proxies):
    proxies("")
    assert client_ip(_request(OTHER, CLIENT)) == OTHER
    assert client_ip(_request(OTHER)) == OTHER
    assert client_ip(None) is None


def test_a_spoofed_header_from_an_untrusted_peer_is_ignored(proxies):
    proxies("10.0.0.0/8")
    assert client_ip(_request(OTHER, f"{CLIENT}, 10.0.0.9")) == OTHER


def test_a_trusted_proxy_is_read_from_the_right(proxies):
    proxies("10.0.0.0/8")
    # Caddy appended the address it saw; the entries to its left are the caller's.
    assert client_ip(_request(PROXY, CLIENT)) == CLIENT
    assert client_ip(_request(PROXY, f"{OTHER}, {CLIENT}")) == CLIENT
    # A trusted proxy with no header is itself the client.
    assert client_ip(_request(PROXY)) == PROXY


def test_hops_bound_how_far_back_it_steps(proxies):
    proxies("10.0.0.0/8", hops=1)
    assert client_ip(_request(PROXY, f"{CLIENT}, 10.0.0.9")) == "10.0.0.9"
    proxies("10.0.0.0/8", hops=2)
    assert client_ip(_request(PROXY, f"{OTHER}, {CLIENT}, 10.0.0.9")) == CLIENT


def test_malformed_entries_and_ports(proxies):
    proxies("10.0.0.0/8, 2001:db8::/32")
    assert client_ip(_request(PROXY, "not-an-ip")) == PROXY
    assert client_ip(_request(PROXY, f"{CLIENT}:4431")) == CLIENT
    assert client_ip(_request("2001:db8::1", "[2001:db8:ffff::1]:443, 2a00:1450::1")) == "2a00:1450::1"
    assert parse_ip("unknown") is None
    assert parse_ip(" 203.0.113.10 ") == CLIENT


# --- the admin IP allowlist --------------------------------------------------


def test_admin_allowlist_ignores_a_spoofed_header(proxies, connect, db_session, monkeypatch):
    proxies("")
    monkeypatch.setattr(get_settings(), "admin_ip_allowlist", CLIENT)
    admin = _admin(db_session)
    c = connect(OTHER)
    resp = c.get(ADMIN_URL, headers={**admin, "X-Forwarded-For": CLIENT})
    assert resp.status_code == 403, resp.text
    assert "IP" in resp.json()["error"]["message"]


def test_admin_allowlist_uses_the_address_a_trusted_proxy_saw(proxies, connect, db_session, monkeypatch):
    proxies("10.0.0.0/8")
    monkeypatch.setattr(get_settings(), "admin_ip_allowlist", CLIENT)
    admin = _admin(db_session)
    c = connect(PROXY)
    assert c.get(ADMIN_URL, headers={**admin, "X-Forwarded-For": CLIENT}).status_code == 200
    # The caller put the allowed address on the left; the proxy appended the real one.
    assert c.get(ADMIN_URL, headers={**admin, "X-Forwarded-For": f"{CLIENT}, {OTHER}"}).status_code == 403


def test_admin_allowlist_with_the_real_connection_address(proxies, connect, db_session, monkeypatch):
    proxies("")
    monkeypatch.setattr(get_settings(), "admin_ip_allowlist", CLIENT)
    admin = _admin(db_session)
    assert connect(CLIENT).get(ADMIN_URL, headers=admin).status_code == 200


# --- the rate limits ---------------------------------------------------------


def _register(c: TestClient, xff: str | None = None):
    headers = {"X-Forwarded-For": xff} if xff else {}
    body = {"email": f"ip-{uuid.uuid4().hex[:10]}@rawwers.test", "password": "Passw0rd!long", "display_name": "IP"}
    return c.post("/v1/auth/register", json=body, headers=headers)


def test_rotating_a_spoofed_header_does_not_dodge_the_rate_limit(proxies, connect, monkeypatch):
    proxies("")
    monkeypatch.setitem(rl.RATE_LIMIT_RULES, "auth_mutation", (2, 60))
    peer = f"198.51.100.{uuid.uuid4().int % 200 + 20}"
    c = connect(peer)
    codes = [_register(c, f"203.0.113.{n}").status_code for n in range(3)]
    assert codes[:2] == [201, 201], codes
    assert codes[2] == 429


def test_behind_a_trusted_proxy_each_client_has_its_own_limit(proxies, connect, monkeypatch):
    proxies("10.0.0.0/8")
    monkeypatch.setitem(rl.RATE_LIMIT_RULES, "auth_mutation", (2, 60))
    base = uuid.uuid4().int % 200 + 20
    c = connect(PROXY)
    first, second = f"203.0.113.{base}", f"203.0.113.{base + 1}"
    assert [_register(c, first).status_code for _ in range(2)] == [201, 201]
    assert _register(c, first).status_code == 429
    # Another client behind the same proxy is not limited by the first.
    assert _register(c, second).status_code == 201


def test_dev_default_still_works(client):
    # No trusted proxies, TestClient's own address: registering just works.
    assert _register(client).status_code == 201
