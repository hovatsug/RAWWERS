"""Signing out takes the photographer offline at once, and nothing sent
from that session afterwards can bring them back online.

Before, the app's sign-out only forgot its own session: the server was
never told, the dot stayed up to five minutes, and a heartbeat already in
flight - its access token still valid - would put it straight back.

Now the server's logout clears presence and closes the session for as long
as its access tokens live; a heartbeat carrying a closed session's token is
refused. Another device's session is untouched.
"""
import uuid

from app.services import presence
from app.services.cache import get_redis_client

from tests.test_presence import _no_presence_left_over  # noqa: F401 - autouse


def _sign_in(client, email, password="correct-horse-8") -> dict:
    resp = client.post("/v1/auth/login", json={"email": email, "password": password})
    assert resp.status_code == 200, resp.text
    return resp.json()


def _photographer(client) -> tuple[str, uuid.UUID]:
    email = f"pro-{uuid.uuid4().hex[:10]}@example.com"
    assert client.post("/v1/auth/register", json={"email": email, "password": "correct-horse-8"}).status_code == 201
    tokens = _sign_in(client, email)
    me = client.get("/v1/me", headers={"Authorization": f"Bearer {tokens['access_token']}"}).json()
    assert client.post("/v1/me/upgrade-to-pro", headers={"Authorization": f"Bearer {tokens['access_token']}"}).status_code == 200
    return email, uuid.UUID(me["user_id"])


def _beat(client, tokens):
    return client.post("/v1/pro/presence/heartbeat", headers={"Authorization": f"Bearer {tokens['access_token']}"})


def _logout(client, tokens):
    return client.post(
        "/v1/auth/logout",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
        json={"refresh_token": tokens["refresh_token"]},
    )


def _online(db_session, pro) -> bool:
    return presence.photographer_is_online(db_session, pro)


def test_signing_out_takes_the_photographer_offline_at_once(client, db_session):
    email, pro = _photographer(client)
    session = _sign_in(client, email)
    assert _beat(client, session).status_code == 200
    assert _online(db_session, pro)

    assert _logout(client, session).status_code == 204

    assert not _online(db_session, pro)


def test_a_heartbeat_from_the_closed_session_cannot_bring_the_dot_back(client, db_session):
    email, pro = _photographer(client)
    session = _sign_in(client, email)
    _beat(client, session)
    _logout(client, session)

    late = _beat(client, session)  # in flight when they signed out; its token still unexpired

    assert late.status_code == 401, late.text
    assert late.json()["error"]["code"] == "session_ended"
    assert not _online(db_session, pro)


def test_signing_in_again_goes_online_again(client, db_session):
    email, pro = _photographer(client)
    first = _sign_in(client, email)
    _beat(client, first)
    _logout(client, first)

    second = _sign_in(client, email)
    get_redis_client().delete(f"presence:pro:{pro}")  # past the heartbeat throttle

    assert _beat(client, second).status_code == 200
    assert _online(db_session, pro)


def test_signing_out_on_one_device_leaves_the_other_sessions_heartbeat_working(client, db_session):
    email, pro = _photographer(client)
    phone, tablet = _sign_in(client, email), _sign_in(client, email)
    _beat(client, phone)
    _logout(client, phone)

    assert _beat(client, tablet).status_code == 200
    assert _online(db_session, pro), "the tablet is still open"


def test_the_closed_session_is_remembered_only_as_long_as_its_tokens_live(client, db_session):
    from app.core.config import get_settings

    email, pro = _photographer(client)
    session = _sign_in(client, email)
    _logout(client, session)

    keys = list(get_redis_client().scan_iter(match="presence:closed:*"))
    assert len(keys) == 1
    ttl = get_redis_client().ttl(keys[0])
    assert 0 < ttl <= get_settings().auth_access_token_ttl_minutes * 60
