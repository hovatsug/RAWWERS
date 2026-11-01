"""Connect Lightroom's download button, driven by a setting.

Owner's decision 5 (2026-11-01): the plug-in's zip will be hosted on our
storage, with a download button in the pro app's Connect Lightroom screen.
For now only the button: the devices list carries the download address from
LIGHTROOM_PLUGIN_DOWNLOAD_URL, and nothing while it is unset, so the app
hides the button. Only an https address is handed out: the app opens it.
"""
import pytest

from app.core.config import get_settings
from tests.test_delivery_pairing import _h, _pro


def _devices(client, pro):
    response = client.get("/v1/pro/lightroom/devices", headers=_h(pro))
    assert response.status_code == 200, response.text
    return response.json()


def test_the_download_address_is_unset_until_hosting_is_decided():
    assert get_settings().lightroom_plugin_download_url == ""


def test_with_no_address_there_is_nothing_to_download(client, db_session):
    body = _devices(client, _pro(db_session))
    assert body["plugin_download_url"] is None
    assert body["plugin_latest_version"] == get_settings().lightroom_plugin_latest_version


def test_the_address_and_the_version_it_holds_come_from_the_settings(client, db_session, monkeypatch):
    settings = get_settings()
    monkeypatch.setattr(settings, "lightroom_plugin_download_url", "https://downloads.example.test/rawwers-lightroom-1.2.0.zip")
    monkeypatch.setattr(settings, "lightroom_plugin_latest_version", "1.2.0")

    body = _devices(client, _pro(db_session))

    assert body["plugin_download_url"] == "https://downloads.example.test/rawwers-lightroom-1.2.0.zip"
    assert body["plugin_latest_version"] == "1.2.0"


@pytest.mark.parametrize("address", ["http://downloads.example.test/a.zip", "javascript:alert(1)", "  ", "downloads.example.test/a.zip"])
def test_only_an_https_address_is_handed_to_the_app(client, db_session, monkeypatch, address):
    monkeypatch.setattr(get_settings(), "lightroom_plugin_download_url", address)
    assert _devices(client, _pro(db_session))["plugin_download_url"] is None


def test_surrounding_spaces_in_the_setting_do_not_matter(client, db_session, monkeypatch):
    monkeypatch.setattr(get_settings(), "lightroom_plugin_download_url", "  https://downloads.example.test/a.zip \n")
    assert _devices(client, _pro(db_session))["plugin_download_url"] == "https://downloads.example.test/a.zip"
