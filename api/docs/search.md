# Search + Indexing v0 (Foundation #18)

## Provider
Supported providers:
- `meili` (recommended)
- `typesense` (placeholder adapter in this slice)
- `none` (Noop provider)

Env vars:
- `SEARCH_PROVIDER=meili|typesense|none`
- `SEARCH_ENABLED=true|false`
- `SEARCH_INDEX_PREFIX=rawwers_dev`
- `MEILI_URL=http://localhost:7700`
- `MEILI_API_KEY=`
- `SEARCH_FALLBACK_CACHE_TTL_SECONDS=30`

Feature flags:
- `search_enabled`
- `search_force_db_fallback`

## Local Meilisearch
Docker compose snippet:
```yaml
services:
  meilisearch:
    image: getmeili/meilisearch:v1.12
    ports:
      - "7700:7700"
    environment:
      - MEILI_NO_ANALYTICS=true
      - MEILI_MASTER_KEY=local-dev-key
```

## Indexes
- `{prefix}_pros`
- `{prefix}_courses`
- `{prefix}_products`
- `{prefix}_repair_partners`

## Incremental indexing (Outbox topics)
- `index.pro.upsert` / `index.pro.delete`
- `index.course.upsert` / `index.course.delete`
- `index.product.upsert` / `index.product.delete`
- `index.repair_partner.upsert` / `index.repair_partner.delete`

Outbox dispatcher consumes these and calls `process_index_event`.
Indexing is idempotent by outbox idempotency keys.

## APIs
Public:
- `GET /v1/search/pros`
- `GET /v1/search/courses`
- `GET /v1/search/products`
- `GET /v1/search/repair-partners`

Admin:
- `GET /v1/admin/search/status`
- `POST /v1/admin/search/rebuild`
- `POST /v1/admin/search/purge` (`X-Confirm: YES` required)

## Fallback behavior
If provider is unavailable or force-fallback flag is active:
- API falls back to DB queries
- Response sets `used_fallback=true`
- Fallback responses are cached briefly in Redis

## Rebuild operations
Rebuild by index:
```bash
curl -X POST http://localhost:8000/v1/admin/search/rebuild \
  -H "X-User-Id: <admin_user_id>" \
  -H "Content-Type: application/json" \
  -d '{"index":"pros"}'
```

Rebuild all:
```bash
curl -X POST http://localhost:8000/v1/admin/search/rebuild \
  -H "X-User-Id: <admin_user_id>" \
  -H "Content-Type: application/json" \
  -d '{"index":"all"}'
```
