# Multi-Region Blueprint (Foundation #16)

## Architecture (v0)
```text
                           +---------------------------+
                           |  Global Clients           |
                           +-------------+-------------+
                                         |
                                    CDN / Edge Cache
                                         |
          +------------------------------+------------------------------+
          |                                                             |
+---------v-----------+                                      +----------v----------+
| EU Primary Region   |                                      | Non-EU Read Region  |
| (authoritative)     |                                      | (optional)          |
|                     |                                      |                     |
| FastAPI (R/W)       |                                      | FastAPI (read-heavy)|
| Celery workers      |                                      | FastAPI (public GET)|
| Redis (queue/cache) |                                      | Redis cache (opt.)  |
| Postgres Primary    | <--------- replication ------------> | Postgres Replica    |
+---------------------+                                      +---------------------+
```

## Reliability Posture
- Writes are EU-primary only (`PRIMARY_DATABASE_URL` or `DATABASE_URL` fallback).
- Public read endpoints can use replica (`REPLICA_DATABASE_URL`) with lag guard.
- Webhooks are durable ingests: payload persisted in `outbox_event`, async processed.
- Worker dispatch uses retries + exponential backoff and idempotency keys.

## Environment Variables
- `DATABASE_URL`: single-region fallback and default primary.
- `PRIMARY_DATABASE_URL`: explicit write DB URL; if empty, `DATABASE_URL` is used.
- `REPLICA_DATABASE_URL`: optional read replica URL for public reads.
- `MAX_REPLICA_LAG_SECONDS`: max lag allowed before fallback to primary reads.
- `PUBLIC_CACHE_ENABLED`: enable/disable Redis cache for public discovery/profile.
- `DISCOVER_CACHE_TTL_SECONDS`: TTL for `/v1/discover/pros` cache.
- `PRO_PUBLIC_CACHE_TTL_SECONDS`: TTL for `/v1/pros/{id}/public` cache.
- `OUTBOX_BATCH_SIZE`: max outbox rows claimed per dispatcher run.
- `OUTBOX_MAX_ATTEMPTS`: max retries before marking `outbox_event` as failed.

## Read/Write Routing
- Write session dependency: `get_db_write_session()` -> primary only.
- Read session dependency: `get_db_read_session()` -> replica if configured and healthy, otherwise primary.
- Lag check:
  - Uses `pg_last_xact_replay_timestamp()` where supported.
  - If lag unavailable or query fails, routing safely falls back to primary.

## Public Cache Design
- Cached endpoints:
  - `GET /v1/discover/pros`
  - `GET /v1/pros/{id}/public`
- Cache key includes:
  - request filters/paging
  - `public_index_version` global key
- Invalidation strategy:
  - Reindex/update of public profile index bumps `public_index_version`.
  - New requests read/write under new versioned keys.

## Durable Webhook Ingest
1. Verify webhook signature at ingress.
2. Create idempotency key (`stripe:{event_id}` / `mux:{event_id}`).
3. Persist `outbox_event(topic=...)` in DB transaction.
4. Return `200` immediately.
5. `dispatch_outbox_events` worker claims rows with `FOR UPDATE SKIP LOCKED`.
6. Route by topic to idempotent handler and mark delivered/failed.

## Outbox Topics (v0)
- `stripe.event`
- `mux.event`
- `reindex.pro`
- `recompute.skills`

## Replica Lag Operations
### Monitoring
- `GET /health/replica` reports:
  - `replica_configured`
  - `healthy`
  - `lag_seconds`
  - `max_allowed_lag_seconds`

### Degrade/Fallback Rule
- If lag > `MAX_REPLICA_LAG_SECONDS`, app routes public reads to primary automatically.
- If replica unavailable, app routes public reads to primary automatically.

## Failover Plan (EU Primary Down)
1. Enter degraded mode (read-only for public endpoints where possible).
2. Disable mutating traffic at ingress/API gateway.
3. Keep webhook ingress alive only if outbox DB is writable; otherwise return operational incident response.
4. Promote a standby primary (provider-specific).
5. Update `PRIMARY_DATABASE_URL` and restart API/workers.
6. Re-enable writes after health checks and queue drain validation.

## Data Residency Notes (EU-first)
- EU-only persistence (authoritative): user accounts, KYC/admin logs, payments/rewards ledger, chats, orders.
- Global cache/read candidates: derived public discovery index, public profile snapshots, published public reviews/courses.
- R2 and Mux remain globally delivered services; metadata control stays in EU-primary DB.

## Single-Region Dev
- Existing `docker-compose.yml` remains valid.
- Set only `DATABASE_URL` + `REDIS_URL`.
- Leave `REPLICA_DATABASE_URL` empty.

## Operational Runbook: Add a Replica
1. Provision PostgreSQL replica from EU primary.
2. Set `REPLICA_DATABASE_URL` in API deployment.
3. Set `MAX_REPLICA_LAG_SECONDS` (recommended start: `10-20`).
4. Deploy API and verify:
  - `/health/ready` healthy
  - `/health/replica` healthy and lag under threshold
5. Observe p95 for public endpoints and replication lag over time.
6. If lag spikes repeatedly, raise threshold or disable replica reads temporarily.
