from app.services.search_provider import NoopProvider, SearchResult


def test_noop_provider_search_returns_empty():
    provider = NoopProvider()
    result = provider.search("idx", query="abc", filters=None, sort=None, limit=10, offset=0)
    assert isinstance(result, SearchResult)
    assert result.total == 0
    assert result.items == []
