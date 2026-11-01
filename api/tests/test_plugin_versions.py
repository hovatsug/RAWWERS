"""The Lightroom plug-in's two versions: the newest, and the oldest still supported.

Owner's decision 7 (2026-11-01): LIGHTROOM_PLUGIN_LATEST_VERSION is raised on
every released build, and older plug-ins are told an update is available;
LIGHTROOM_PLUGIN_MIN_VERSION is raised only for a breaking change, and a
plug-in below it is refused with a 426 that says where to get the new one -
without disconnecting the Mac, so updating is all it takes.

A plug-in that does not say its version is not refused: every RAWWERS
plug-in sends it, so its absence means something other than an old plug-in,
and the token alone decides what it may do.
"""
import pytest

from app.core.config import get_settings
from app.services.delivery_access import plugin_supported
from tests.test_delivery_gigs import _gig, _pro, _start, _token
from tests.test_delivery_gigs import fakes  # noqa: F401  (autouse fixture)


@pytest.fixture
def versions(monkeypatch):
    settings = get_settings()

    def set_versions(latest="2.0.0", minimum="1.0.0"):
        monkeypatch.setattr(settings, "lightroom_plugin_latest_version", latest)
        monkeypatch.setattr(settings, "lightroom_plugin_min_version", minimum)

    return set_versions


def _headers(token, version):
    headers = {"Authorization": f"Bearer {token}"}
    if version is not None:
        headers["X-Rawwers-Plugin-Version"] = version
    return headers


def test_the_minimum_is_a_setting_that_starts_at_the_first_release():
    assert get_settings().lightroom_plugin_min_version == "1.0.0"


@pytest.mark.parametrize(
    ("version", "supported"),
    [("1.4.0", False), ("1.9.9", False), ("2.0.0", True), ("2.0", True), ("2.1.0", True), ("10.0.0", True), (None, True), ("not-a-version", True)],
)
def test_below_the_minimum_is_unsupported(versions, version, supported):
    versions(latest="2.1.0", minimum="2.0.0")
    assert plugin_supported(version) is supported


def test_the_newest_plugin_is_never_refused_even_if_the_minimum_is_set_above_it(versions):
    versions(latest="1.2.0", minimum="3.0.0")
    assert plugin_supported("1.2.0") is True
    assert plugin_supported("1.1.0") is False


def test_a_plugin_too_old_is_refused_with_where_to_get_the_new_one(client, db_session, versions):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    versions(latest="2.1.0", minimum="2.0.0")

    for method, path in [("GET", "/v1/delivery/me"), ("GET", "/v1/delivery/gigs")]:
        answer = client.request(method, path, headers=_headers(token, "1.0.0"))
        assert answer.status_code == 426, (path, answer.text)
        error = answer.json()["error"]
        assert error["code"] == "plugin_outdated"
        assert "1.0.0" in error["message"] and "2.1.0" in error["message"]
        assert "Connect Lightroom" in error["message"]

    started = client.post(
        f"/v1/delivery/gigs/{gig.id}/uploads",
        headers=_headers(token, "1.0.0"),
        json={"file_name": "a.jpg", "content_type": "image/jpeg", "byte_size": 1000, "sha256": "ab" * 32},
    )
    assert started.status_code == 426


def test_refusing_an_old_plugin_keeps_the_mac_connected(client, db_session, versions):
    pro = _pro(db_session)
    token = _token(client, pro)
    versions(latest="2.1.0", minimum="2.0.0")
    assert client.get("/v1/delivery/me", headers=_headers(token, "1.0.0")).status_code == 426

    after_update = client.get("/v1/delivery/me", headers=_headers(token, "2.1.0"))

    assert after_update.status_code == 200, after_update.text
    assert after_update.headers["X-Rawwers-Update-Available"] == "false"


def test_a_supported_but_older_plugin_works_and_is_told_to_update(client, db_session, versions):
    pro = _pro(db_session)
    gig = _gig(db_session, pro)
    token = _token(client, pro)
    versions(latest="2.1.0", minimum="1.0.0")

    me = client.get("/v1/delivery/me", headers=_headers(token, "1.0.0"))

    assert me.status_code == 200
    assert me.headers["X-Rawwers-Update-Available"] == "true"
    assert me.json()["update_available"] is True and me.json()["latest_version"] == "2.1.0"
    assert _start(client, token, gig.id).status_code == 200


def test_pairing_with_a_plugin_too_old_is_refused_before_the_code_is_used(client, db_session, versions):
    pro = _pro(db_session)
    code = client.post("/v1/pro/lightroom/pairing-code", headers={"X-User-Id": str(pro)}).json()["code"]
    versions(latest="2.1.0", minimum="2.0.0")

    old = client.post("/v1/delivery/pair", json={"code": code, "device_name": "Mac", "plugin_version": "1.0.0"})
    assert old.status_code == 426 and old.json()["error"]["code"] == "plugin_outdated"

    # The code was not spent: the updated plug-in can still use it.
    new = client.post("/v1/delivery/pair", json={"code": code, "device_name": "Mac", "plugin_version": "2.1.0"})
    assert new.status_code == 200, new.text


def test_a_plugin_that_does_not_say_its_version_is_not_refused(client, db_session, versions):
    pro = _pro(db_session)
    token = _token(client, pro)
    versions(latest="2.1.0", minimum="2.0.0")

    assert client.get("/v1/delivery/me", headers=_headers(token, None)).status_code == 200


def test_a_bad_token_from_an_old_plugin_is_told_to_update_first(client, db_session, versions):
    # Updating is the step that helps: with the old plug-in, pairing again
    # would be refused anyway.
    versions(latest="2.1.0", minimum="2.0.0")

    answer = client.get("/v1/delivery/me", headers=_headers("rwd_not-a-token", "1.0.0"))

    assert answer.status_code == 426
