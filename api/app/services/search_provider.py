from __future__ import annotations

import logging
from dataclasses import dataclass

import requests

from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


@dataclass
class SearchResult:
    items: list[dict]
    total: int


class SearchProvider:
    def upsert_documents(self, index_name: str, docs: list[dict]) -> None:
        raise NotImplementedError

    def delete_documents(self, index_name: str, ids: list[str]) -> None:
        raise NotImplementedError

    def search(
        self,
        index_name: str,
        query: str,
        filters: str | None,
        sort: list[str] | None,
        limit: int,
        offset: int,
    ) -> SearchResult:
        raise NotImplementedError

    def index_stats(self, index_name: str) -> dict:
        return {"index_name": index_name, "documents": 0}

    def purge_index(self, index_name: str) -> None:
        return


class NoopProvider(SearchProvider):
    def upsert_documents(self, index_name: str, docs: list[dict]) -> None:
        return

    def delete_documents(self, index_name: str, ids: list[str]) -> None:
        return

    def search(self, index_name: str, query: str, filters: str | None, sort: list[str] | None, limit: int, offset: int) -> SearchResult:
        return SearchResult(items=[], total=0)


class MeiliSearchProvider(SearchProvider):
    def __init__(self, base_url: str, api_key: str | None = None):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.headers = {"Content-Type": "application/json"}
        if api_key:
            self.headers["Authorization"] = f"Bearer {api_key}"

    def _ensure_index(self, index_name: str) -> None:
        created = False
        resp = self.session.get(f"{self.base_url}/indexes/{index_name}", headers=self.headers, timeout=5)
        if resp.status_code == 404:
            create = self.session.post(
                f"{self.base_url}/indexes",
                headers=self.headers,
                json={"uid": index_name, "primaryKey": "id"},
                timeout=5,
            )
            create.raise_for_status()
            created = True
        else:
            resp.raise_for_status()
        if created:
            self._apply_index_settings(index_name)

    def _apply_index_settings(self, index_name: str) -> None:
        suffix = index_name.split("_")[-1]
        settings_payload: dict = {}
        if suffix == "pros":
            settings_payload = {
                "filterableAttributes": ["city", "country", "niche_slugs", "is_kyc_approved", "is_available", "price_min"],
                "sortableAttributes": ["avg_rating", "price_min", "last_active_at", "completed_gigs_total"],
            }
        elif suffix == "courses":
            settings_payload = {
                "filterableAttributes": ["niche_slug", "level", "is_mandatory", "is_published", "price"],
                "sortableAttributes": ["updated_at", "price"],
            }
        elif suffix == "products":
            settings_payload = {
                "filterableAttributes": ["category", "brand", "is_available", "stock_status", "price"],
                "sortableAttributes": ["updated_at", "price"],
            }
        elif suffix == "partners" or suffix == "repair_partners":
            settings_payload = {
                "filterableAttributes": ["country", "city", "categories_supported", "brands_supported", "loaner_supported", "is_active"],
                "sortableAttributes": ["updated_at", "sla_quote_hours", "sla_turnaround_days"],
            }
        elif suffix == "content_packs" or index_name.endswith("_content_packs") or suffix == "packs":
            settings_payload = {
                "filterableAttributes": ["status", "category", "niche_slugs", "tags", "price_eur", "price_raww"],
                "sortableAttributes": ["updated_at", "price_eur", "price_raww"],
            }
        if not settings_payload:
            return
        resp = self.session.patch(
            f"{self.base_url}/indexes/{index_name}/settings",
            headers=self.headers,
            json=settings_payload,
            timeout=10,
        )
        resp.raise_for_status()

    def upsert_documents(self, index_name: str, docs: list[dict]) -> None:
        if not docs:
            return
        self._ensure_index(index_name)
        resp = self.session.post(
            f"{self.base_url}/indexes/{index_name}/documents",
            headers=self.headers,
            json=docs,
            timeout=10,
        )
        resp.raise_for_status()

    def delete_documents(self, index_name: str, ids: list[str]) -> None:
        if not ids:
            return
        self._ensure_index(index_name)
        resp = self.session.post(
            f"{self.base_url}/indexes/{index_name}/documents/delete-batch",
            headers=self.headers,
            json=ids,
            timeout=10,
        )
        resp.raise_for_status()

    def search(self, index_name: str, query: str, filters: str | None, sort: list[str] | None, limit: int, offset: int) -> SearchResult:
        self._ensure_index(index_name)
        payload: dict = {
            "q": query or "",
            "limit": limit,
            "offset": offset,
        }
        if filters:
            payload["filter"] = filters
        if sort:
            payload["sort"] = sort
        resp = self.session.post(
            f"{self.base_url}/indexes/{index_name}/search",
            headers=self.headers,
            json=payload,
            timeout=10,
        )
        resp.raise_for_status()
        data = resp.json()
        return SearchResult(items=data.get("hits", []), total=int(data.get("estimatedTotalHits", 0)))

    def index_stats(self, index_name: str) -> dict:
        self._ensure_index(index_name)
        resp = self.session.get(f"{self.base_url}/indexes/{index_name}/stats", headers=self.headers, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        return {"index_name": index_name, "documents": int(data.get("numberOfDocuments", 0)), "raw": data}

    def purge_index(self, index_name: str) -> None:
        self._ensure_index(index_name)
        resp = self.session.delete(f"{self.base_url}/indexes/{index_name}", headers=self.headers, timeout=10)
        if resp.status_code not in (200, 202, 204, 404):
            resp.raise_for_status()
        # Recreate for future writes.
        self._ensure_index(index_name)


class TypesenseProvider(NoopProvider):
    pass


_provider: SearchProvider | None = None


def get_search_provider() -> SearchProvider:
    global _provider
    if _provider is not None:
        return _provider

    provider = settings.search_provider.lower().strip()
    if provider == "meili":
        _provider = MeiliSearchProvider(settings.meili_url, settings.meili_api_key)
    elif provider == "typesense":
        _provider = TypesenseProvider()
    else:
        _provider = NoopProvider()
    return _provider


def get_index_name(kind: str) -> str:
    return f"{settings.search_index_prefix}_{kind}"


def search_provider_enabled() -> bool:
    return settings.search_enabled and settings.search_provider.lower() != "none"
