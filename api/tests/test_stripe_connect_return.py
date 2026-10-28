"""Where Stripe sends a photographer after hosted Connect onboarding.

Stripe refuses a custom-scheme return_url ("Not a valid URL", seen on real
Stripe in test mode), so it returns to two static pages the API serves,
which hand over to the pro app through its own scheme. The pages are a
hint, never the truth: the app asks the server for the account's status
when it comes back, and nothing here reads, stores or repeats what is in
the address.

These cover the pages (static, hardened, ignore the query string), the
configuration rule for the two URLs, and that the onboarding link is
minted with the configured URLs. Stripe is faked throughout.
"""
import pytest
from pydantic import ValidationError

from app.core.config import Settings, get_settings
from app.services import stripe_connect
from app.services.connect_return import PRO_APP_SCHEME

PAGES = {
    "/v1/payouts/connect/return": f"{PRO_APP_SCHEME}://payouts/return",
    "/v1/payouts/connect/refresh": f"{PRO_APP_SCHEME}://payouts/refresh",
}

SCRIPT = "<script>alert(1)</script>"


@pytest.mark.parametrize("path", sorted(PAGES))
def test_the_page_hands_over_to_the_pro_app_with_a_visible_button(client, path):
    response = client.get(path)
    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/html")
    body = response.text
    # The automatic hand-off, and the button for when the browser blocks it.
    assert f'href="{PAGES[path]}"' in body
    assert "Back to RAWWERS Pro" in body
    assert f'content="0;url={PAGES[path]}"' in body


@pytest.mark.parametrize("path", sorted(PAGES))
def test_the_page_needs_no_login(client, path):
    # Stripe redirects a browser: there is no token to send.
    assert client.get(path, headers={}).status_code == 200


@pytest.mark.parametrize("path", sorted(PAGES))
def test_the_page_never_reflects_the_query_string(client, path):
    plain = client.get(path).text
    for query in (
        {"q": SCRIPT},
        {SCRIPT: "1"},
        {"account": "acct_123", "state": SCRIPT, "redirect": "https://evil.test"},
    ):
        response = client.get(path, params=query)
        assert response.status_code == 200
        assert SCRIPT not in response.text
        assert "alert(1)" not in response.text
        assert "acct_123" not in response.text
        assert "evil.test" not in response.text
        # Static: byte for byte the page without a query string.
        assert response.text == plain


@pytest.mark.parametrize("path", sorted(PAGES))
def test_the_page_is_hardened(client, path):
    headers = client.get(path, params={"x": "1"}).headers
    assert headers["cache-control"] == "no-store"
    assert headers["referrer-policy"] == "no-referrer"
    assert headers["x-content-type-options"] == "nosniff"
    # No script at all, and nothing loaded from anywhere.
    assert "default-src 'none'" in headers["content-security-policy"]


@pytest.mark.parametrize("path", sorted(PAGES))
def test_the_page_carries_no_script_and_no_user_data(client, path):
    body = client.get(path).text.lower()
    assert "<script" not in body
    assert "@" not in body
    assert "acct_" not in body


def test_return_and_refresh_say_different_things(client):
    returned = client.get("/v1/payouts/connect/return").text
    refreshed = client.get("/v1/payouts/connect/refresh").text
    assert "expired" in refreshed.lower()
    assert "expired" not in returned.lower()


# --- The configured URLs ----------------------------------------------------


def _settings(**overrides) -> Settings:
    """A Settings built from the test environment with two values changed."""
    base = get_settings().model_dump(by_alias=True)
    base.update(overrides)
    return Settings(**base)


def test_the_defaults_are_the_apis_own_pages_over_http():
    defaults = Settings.model_fields
    assert defaults["connect_return_url"].default.endswith("/v1/payouts/connect/return")
    assert defaults["connect_refresh_url"].default.endswith("/v1/payouts/connect/refresh")
    for name in ("connect_return_url", "connect_refresh_url"):
        assert defaults[name].default.startswith("http://")


@pytest.mark.parametrize("env", ["development", "test", "staging"])
def test_http_is_accepted_outside_production(env):
    s = _settings(
        APP_ENV=env,
        CONNECT_RETURN_URL="http://mac.local:8000/v1/payouts/connect/return",
        CONNECT_REFRESH_URL="http://mac.local:8000/v1/payouts/connect/refresh",
    )
    assert s.connect_return_url.startswith("http://")


@pytest.mark.parametrize("env", ["production", "prod", "PRODUCTION"])
@pytest.mark.parametrize("field", ["CONNECT_RETURN_URL", "CONNECT_REFRESH_URL"])
def test_production_refuses_plain_http_readably(env, field):
    with pytest.raises(ValidationError) as caught:
        _settings(
            **{
                "APP_ENV": env,
                "CONNECT_RETURN_URL": "https://api.example.test/v1/payouts/connect/return",
                "CONNECT_REFRESH_URL": "https://api.example.test/v1/payouts/connect/refresh",
                field: "http://api.example.test/v1/payouts/connect/x",
            }
        )
    message = str(caught.value)
    assert field in message
    assert "https" in message


def test_production_accepts_https():
    s = _settings(
        APP_ENV="production",
        CONNECT_RETURN_URL="https://api.example.test/v1/payouts/connect/return",
        CONNECT_REFRESH_URL="https://api.example.test/v1/payouts/connect/refresh",
    )
    assert s.connect_refresh_url.startswith("https://")


@pytest.mark.parametrize("env", ["development", "production"])
@pytest.mark.parametrize(
    "bad",
    [
        "rawwerspro://payouts/return",  # Stripe rejects it: "Not a valid URL"
        "ftp://example.test/return",
        "javascript:alert(1)",
        "/v1/payouts/connect/return",  # no scheme, no host
        "http://",  # no host
        "",
    ],
)
@pytest.mark.parametrize("field", ["CONNECT_RETURN_URL", "CONNECT_REFRESH_URL"])
def test_anything_but_http_or_https_is_refused_everywhere(env, bad, field):
    good = "https://api.example.test/v1/payouts/connect/ok"
    with pytest.raises(ValidationError) as caught:
        _settings(**{"APP_ENV": env, "CONNECT_RETURN_URL": good, "CONNECT_REFRESH_URL": good, field: bad})
    message = str(caught.value)
    assert field in message
    assert "http" in message


# --- The link is minted with them --------------------------------------------


class _FakeAccount:
    def create(self, **kwargs):
        return {"id": "acct_fake_return"}


class _FakeAccountLink:
    def __init__(self):
        self.calls = []

    def create(self, **kwargs):
        self.calls.append(kwargs)
        return {"url": f"https://connect.stripe.test/setup/{len(self.calls)}"}


class _FakeStripe:
    def __init__(self):
        self.Account = _FakeAccount()
        self.AccountLink = _FakeAccountLink()


def test_the_onboarding_link_returns_to_the_configured_pages(client, db_session, monkeypatch):
    from tests.test_stripe_connect import _seed_pro

    fake = _FakeStripe()
    monkeypatch.setattr(stripe_connect, "_stripe", lambda: fake)
    uid = _seed_pro(db_session)

    response = client.post("/v1/pro/payouts/connect/onboarding-link", headers={"X-User-Id": str(uid)})
    assert response.status_code == 200, response.text
    sent = fake.AccountLink.calls[0]
    settings = get_settings()
    assert sent["return_url"] == settings.connect_return_url
    assert sent["refresh_url"] == settings.connect_refresh_url
    for url in (sent["return_url"], sent["refresh_url"]):
        assert url.startswith(("http://", "https://"))
