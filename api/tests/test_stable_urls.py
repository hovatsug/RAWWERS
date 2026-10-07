"""Stable signed URLs for browsing previews, and nothing else.

The same photo used to come back with a new signature in every response, so
no cache downstream could recognise it. These pin both halves of the change:
browsing previews keep their URL while it has at least half its life left,
and no URL lives longer than the TTL it was signed with.
"""
import time
import uuid
from urllib.parse import parse_qs, urlparse

from app.services import storage
from app.services.cache import get_redis_client
from app.services.storage import _stable_url_cache_key, stable_presigned_gets


def _keys(n=2):
    return [f"users/test/{uuid.uuid4()}_thumbnail.jpg" for _ in range(n)]


def _expires(url: str) -> int:
    return int(parse_qs(urlparse(url).query)["X-Amz-Expires"][0])


def test_the_same_object_keeps_the_same_url_across_responses():
    keys = _keys()
    first = stable_presigned_gets(keys, 900)
    # Over a second later: a signature carries the time to the second, so two
    # signings within one second match by accident, cache or no cache.
    time.sleep(1.1)
    second = stable_presigned_gets(list(reversed(keys)), 900)

    assert first == second
    assert first[keys[0]] != first[keys[1]]


def test_no_url_lives_longer_than_it_was_signed_for():
    [key] = _keys(1)
    url = stable_presigned_gets([key], 900)[key]

    assert _expires(url) == 900, "the signature's own lifetime is unchanged"
    remaining = get_redis_client().ttl(_stable_url_cache_key(key, 900))
    assert 0 < remaining <= 450, "handed out again only while at least half its life is left"


def test_a_different_lifetime_is_a_different_url():
    [key] = _keys(1)
    short = stable_presigned_gets([key], 300)[key]
    long = stable_presigned_gets([key], 3600)[key]

    assert _expires(short) == 300 and _expires(long) == 3600


def test_without_redis_it_still_signs(monkeypatch):
    def broken():
        raise ConnectionError("redis down")

    monkeypatch.setattr(storage, "get_redis_client", broken)
    [key] = _keys(1)

    url = stable_presigned_gets([key], 900)[key]

    assert _expires(url) == 900


def test_downloads_of_full_copies_are_never_reused(client, db_session, monkeypatch):
    """resolve_derivative_urls serves web_res - an unwatermarked copy - and
    keeps a fresh signature per request: it must not go near the cache."""
    from app.services import media_urls

    calls = []
    monkeypatch.setattr(media_urls, "stable_presigned_gets", lambda *a, **k: calls.append(a) or {})
    media_urls.resolve_derivative_urls(db_session, [uuid.uuid4()], kinds=(media_urls.MediaDerivativeKind.web_res,))

    assert calls == []
