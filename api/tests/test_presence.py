"""Whether a photographer is online, and when a client is shown it.

The pro app sends a heartbeat at most once a minute while it is open. The
server keeps the latest in one Redis key per photographer that expires
after PRESENCE_WINDOW_SECONDS (300): an app that closes, crashes or loses
its signal simply stops, and the key - and the dot - is gone within the
window. Nothing is ever shown but online / not shown: no last-seen time.

Two different questions read the same key. photographer_is_online - is this
person around - is what the assistant's hold (and later "Available now")
asks; it ignores visibility, because hiding the dot is a privacy choice
about what clients see, not a way to stop being reachable. shown_online -
should a client see a dot - also requires visibility, which is persisted on
the profile and copied into the key so one batched lookup answers it.
"""
import json
import time
import uuid

import pytest
from app.core.config import get_settings
from app.models.admin import ProProfile, UserAccount, UserRole, UserRoleType
from app.schemas.client_launch import ClientDiscoverCard, ClientProProfileResponse
from app.services import presence
from app.services.cache import get_public_index_version, get_redis_client

from tests.test_client_home_rows import _city, _clear_home_cache, _pro  # noqa: F401 - _clear_home_cache is autouse
from tests.test_client_launch import _enable_city_and_flags


def _photographer(db_session, name="Ana Lima", gigs=0) -> uuid.UUID:
    pro_id = _pro(db_session, name=name, gigs=gigs)
    db_session.add(UserRole(user_id=pro_id, role=UserRoleType.pro))
    db_session.commit()
    return pro_id


def _viewer(db_session) -> uuid.UUID:
    user_id = uuid.uuid4()
    db_session.add(UserAccount(user_id=user_id))
    db_session.flush()
    db_session.add(UserRole(user_id=user_id, role=UserRoleType.client))
    db_session.commit()
    return user_id


@pytest.fixture
def lisbon(db_session):
    _city(db_session)
    _enable_city_and_flags(db_session)
    return _viewer(db_session)


@pytest.fixture(autouse=True)
def _no_presence_left_over():
    """Redis outlives the per-test database wipe."""
    redis = get_redis_client()
    for key in redis.scan_iter(match="presence:pro:*"):
        redis.delete(key)
    yield


def _beat(client, pro_id):
    return client.post("/v1/pro/presence/heartbeat", headers={"X-User-Id": str(pro_id)})


def _home_dots(client, viewer) -> dict[str, bool]:
    resp = client.get("/v1/client/home?city=Lisbon&country=PT", headers={"X-User-Id": str(viewer)})
    assert resp.status_code == 200, resp.text
    return {card["pro_user_id"]: card["online"] for row in resp.json()["rows"] for card in row["items"]}


def _discover_dots(client, viewer) -> dict[str, bool]:
    resp = client.get("/v1/client/discover?city=Lisbon&country=PT", headers={"X-User-Id": str(viewer)})
    assert resp.status_code == 200, resp.text
    return {card["pro_user_id"]: card["online"] for card in resp.json()["items"]}


def _profile_dot(client, viewer, pro_id) -> bool:
    resp = client.get(f"/v1/client/pros/{pro_id}?city=Lisbon&country=PT", headers={"X-User-Id": str(viewer)})
    assert resp.status_code == 200, resp.text
    return resp.json()["online"]


# --- the heartbeat -------------------------------------------------------------


def test_a_heartbeat_puts_the_dot_on_cards_and_the_profile(client, db_session, lisbon):
    pro = _photographer(db_session)
    assert _home_dots(client, lisbon)[str(pro)] is False

    assert _beat(client, pro).status_code == 200

    assert _home_dots(client, lisbon)[str(pro)] is True
    assert _discover_dots(client, lisbon)[str(pro)] is True
    assert _profile_dot(client, lisbon, pro) is True
    assert presence.photographer_is_online(db_session, pro) is True


def test_only_a_photographer_can_send_a_heartbeat(client, db_session, lisbon):
    resp = client.post("/v1/pro/presence/heartbeat", headers={"X-User-Id": str(lisbon)})

    assert resp.status_code == 403


def test_the_server_throttles_heartbeats(client, db_session, lisbon):
    pro = _photographer(db_session)
    first, second = _beat(client, pro).json(), _beat(client, pro).json()

    assert first == {"recorded": True}
    assert second == {"recorded": False}, "a second beat inside the minimum interval writes nothing"


def test_going_to_the_background_clears_the_dot_at_once(client, db_session, lisbon):
    pro = _photographer(db_session)
    _beat(client, pro)

    resp = client.delete("/v1/pro/presence", headers={"X-User-Id": str(pro)})

    assert resp.status_code == 200
    assert _home_dots(client, lisbon)[str(pro)] is False
    assert presence.photographer_is_online(db_session, pro) is False


# --- the backstop: no clear arrives ------------------------------------------


def test_the_window_is_five_minutes_unless_configured_otherwise():
    assert get_settings().presence_window_seconds == 300


def test_without_a_clear_the_dot_goes_when_the_window_runs_out(client, db_session, lisbon, monkeypatch):
    """A force-quit, a crash, a dead battery: no clear is ever sent. Real
    Redis expiry, with the window shortened to 2 seconds."""
    monkeypatch.setattr(get_settings(), "presence_window_seconds", 2)
    pro = _photographer(db_session)
    _beat(client, pro)
    assert _home_dots(client, lisbon)[str(pro)] is True

    time.sleep(3)

    assert _home_dots(client, lisbon)[str(pro)] is False
    assert _profile_dot(client, lisbon, pro) is False
    assert get_redis_client().exists(f"presence:pro:{pro}") == 0, "expired by Redis, not just read as stale"


# --- visibility ----------------------------------------------------------------


def _hide(client, pro, hidden=True):
    resp = client.put("/v1/pro/presence/visibility", headers={"X-User-Id": str(pro)}, json={"visible": not hidden})
    assert resp.status_code == 200, resp.text
    return resp.json()


def test_visibility_is_on_unless_the_photographer_turns_it_off(client, db_session, lisbon):
    pro = _photographer(db_session)

    assert client.get("/v1/pro/presence/visibility", headers={"X-User-Id": str(pro)}).json() == {"visible": True}
    assert db_session.get(ProProfile, pro).presence_visible is True


def test_hiding_takes_effect_at_once_and_hides_only_the_dot(client, db_session, lisbon):
    pro = _photographer(db_session)
    _beat(client, pro)

    _hide(client, pro)

    db_session.expire_all()
    assert db_session.get(ProProfile, pro).presence_visible is False, "the column is the source of truth"
    assert _home_dots(client, lisbon)[str(pro)] is False
    assert _profile_dot(client, lisbon, pro) is False
    assert presence.photographer_is_online(db_session, pro) is True, "the assistant's hold still knows they are around"


def test_a_hidden_photographer_stays_hidden_after_the_key_expires_and_comes_back(client, db_session, lisbon):
    pro = _photographer(db_session)
    _beat(client, pro)
    _hide(client, pro)
    get_redis_client().delete(f"presence:pro:{pro}")  # expired

    _beat(client, pro)

    assert _home_dots(client, lisbon)[str(pro)] is False


def test_showing_again_takes_effect_at_once(client, db_session, lisbon):
    pro = _photographer(db_session)
    _beat(client, pro)
    _hide(client, pro)

    _hide(client, pro, hidden=False)

    assert _home_dots(client, lisbon)[str(pro)] is True


@pytest.mark.parametrize(
    "stored",
    [json.dumps({"ts": time.time()}), json.dumps({"ts": time.time(), "visible": "yes"}), "not json", json.dumps([1, 2])],
    ids=["no-visibility", "visibility-not-a-boolean", "garbage", "wrong-shape"],
)
def test_anything_unreadable_in_the_key_reads_as_hidden(client, db_session, lisbon, stored):
    pro = _photographer(db_session)
    get_redis_client().set(f"presence:pro:{pro}", stored, ex=300)

    assert _home_dots(client, lisbon)[str(pro)] is False


# --- one lookup, and its failure ------------------------------------------------


def test_a_screen_of_cards_costs_one_lookup(client, db_session, lisbon, monkeypatch):
    for n in range(4):
        _beat(client, _photographer(db_session, name=f"P{n}"))
    real = presence._mget
    calls = []
    monkeypatch.setattr(presence, "_mget", lambda keys: calls.append(list(keys)) or real(keys))

    dots = _home_dots(client, lisbon)

    assert len(calls) == 1 and len(calls[0]) == len(dots)


def test_if_the_lookup_fails_there_is_no_dot_and_no_error(client, db_session, lisbon, monkeypatch):
    pro = _photographer(db_session)
    _beat(client, pro)

    def broken(keys):
        raise ConnectionError("redis down")

    monkeypatch.setattr(presence, "_mget", broken)

    assert _home_dots(client, lisbon)[str(pro)] is False
    assert _discover_dots(client, lisbon)[str(pro)] is False
    assert _profile_dot(client, lisbon, pro) is False


def test_the_dot_is_live_not_cached(client, db_session, lisbon):
    """Cards are cached until the public index changes; presence changes by
    the minute. The dot is added after the cache, so it is right on the very
    next request and the cache is never invalidated for it."""
    pro = _photographer(db_session)
    assert _home_dots(client, lisbon)[str(pro)] is False  # now cached
    version = get_public_index_version()

    _beat(client, pro)

    assert _home_dots(client, lisbon)[str(pro)] is True
    assert get_public_index_version() == version


# --- what it never does ---------------------------------------------------------


def test_presence_never_changes_any_order(client, db_session, lisbon):
    pros = [_photographer(db_session, name=f"P{n}", gigs=n) for n in range(5)]

    def orders():
        home = client.get("/v1/client/home?city=Lisbon&country=PT", headers={"X-User-Id": str(lisbon)}).json()
        discover = client.get("/v1/client/discover?city=Lisbon&country=PT", headers={"X-User-Id": str(lisbon)}).json()
        return (
            [(row["key"], [c["pro_user_id"] for c in row["items"]]) for row in home["rows"]],
            [c["pro_user_id"] for c in discover["items"]],
        )

    before = orders()
    for pro in pros[::2]:
        _beat(client, pro)

    assert orders() == before


def test_no_payload_ever_says_when_someone_was_last_seen(client, db_session, lisbon):
    pro = _photographer(db_session)
    _beat(client, pro)
    ts = json.loads(get_redis_client().get(f"presence:pro:{pro}"))["ts"]

    for schema in (ClientDiscoverCard, ClientProProfileResponse):
        timing = [f for f in schema.model_fields if any(w in f for w in ("seen", "active", "heartbeat", "presence"))]
        assert timing == [], (schema.__name__, timing)
    from datetime import datetime, timezone

    beat_at = datetime.fromtimestamp(ts, tz=timezone.utc)
    # The heartbeat time in every form it could leak as: epoch seconds, and
    # ISO to the minute - which also catches any later field.
    leaks = (str(int(ts)), beat_at.strftime("%Y-%m-%dT%H:%M"))

    def keys(value):
        if isinstance(value, dict):
            for k, v in value.items():
                yield k
                yield from keys(v)
        elif isinstance(value, list):
            for v in value:
                yield from keys(v)

    for resp in (
        client.get("/v1/client/home?city=Lisbon&country=PT", headers={"X-User-Id": str(lisbon)}),
        client.get(f"/v1/client/pros/{pro}?city=Lisbon&country=PT", headers={"X-User-Id": str(lisbon)}),
        client.get("/v1/client/discover?city=Lisbon&country=PT", headers={"X-User-Id": str(lisbon)}),
        _beat(client, pro),
    ):
        assert not any(leak in resp.text for leak in leaks), resp.request.url
        named = [k for k in keys(resp.json()) if any(w in k for w in ("seen", "heartbeat", "last_active"))]
        assert named == [], (resp.request.url, named)
