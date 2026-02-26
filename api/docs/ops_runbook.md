# RAWWERS Ops Runbook (Foundation #17)

## 1) Check API/Worker Health
- API liveness: `GET /healthz`
- API readiness (DB + Redis): `GET /health/ready`
- Replica lag health: `GET /health/replica`
- Prometheus metrics: `GET /metrics`

## 2) Check Queue Backlog
- Primary queue depth is exposed at `celery_queue_depth{queue="media"}` in `/metrics`.
- Admin quick view: `GET /v1/admin/ops/metrics-summary` (returns `queue_depth_media`).
- Manual Redis check:
  - `redis-cli LLEN media`

## 3) Pause Risky Features (Kill Switches)
Feature flags endpoint:
- List: `GET /v1/admin/feature-flags`
- Update: `PUT /v1/admin/feature-flags/{key}`

Critical flags:
- `ai_calls_enabled`
- `rewards_spend_enabled`
- `ecom_enabled`
- `loaners_enabled`
- `video_uploads_enabled`

Example emergency disable:
```bash
curl -X PUT http://localhost:8000/v1/admin/feature-flags/ai_calls_enabled \
  -H "X-User-Id: <admin_user_id>" \
  -H "Content-Type: application/json" \
  -d '{"is_enabled":false,"scope":"global","rules":{}}'
```

## 4) Webhook Signature Incidents (Stripe/Mux)
- Signature outcomes are logged in `webhook_security_log` and counted in `/metrics`:
  - `webhook_events_total{provider="stripe|mux",signature_valid="true|false"}`
- Check failures:
  - `GET /v1/admin/ops/metrics-summary` -> `webhook_signature_failures_24h`
  - Query DB table `webhook_security_log` for details (`ip`, metadata, timestamps)

## 5) Webhook Replay Procedure (Outbox)
- Webhooks are ingested durably into `outbox_event`.
- Replay pattern:
1. Identify failed/pending outbox rows (`status in ('failed','pending')`).
2. Reset row status to `pending` and `next_attempt_at=now()` if required.
3. Trigger dispatcher task (`dispatch_outbox_events`).
4. Verify downstream state transitions and idempotency keys.

## 6) Abuse/Fraud Triage
- List abuse signals:
  - `GET /v1/admin/abuse/signals?status=open`
- Resolve/ignore signal:
  - `POST /v1/admin/abuse/signals/{id}/resolve`
- High-priority signal types:
  - `payment_anomaly`
  - `referral_abuse`
  - `scraping`
  - `spam_chat`
  - `review_fraud`

## 7) Incident Response Checklist
1. Confirm blast radius (affected endpoints, users, payment flows).
2. Enable kill switches for risky paths.
3. Verify webhook signatures and replay only trusted events.
4. Tighten rate limits temporarily via env and rollout.
5. Review open abuse signals and resolve/escalate.
6. Audit admin actions through `admin_audit_log`.
7. Post-incident: document timeline, root cause, and permanent controls.
