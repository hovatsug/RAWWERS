# Disputes, Refunds, and Contract Enforcement (v1)

## Lifecycle
- `POST /v1/disputes` opens a dispute for a `gig_id` or `extra_purchase_id`.
- Participants exchange evidence with `POST /v1/disputes/{id}/messages`.
- Admin can inspect via:
  - `GET /v1/admin/disputes`
  - `GET /v1/admin/disputes/{id}`
- Admin actions:
  - `POST /v1/admin/disputes/{id}/set-status`
  - `POST /v1/admin/disputes/{id}/resolve`
- Resolution events are stored in `dispute_event`.

## Refund Rules
- Rules are configured by `refund_policy` per dispute category.
- Response windows (`due_response_at`) are set from policy.
- Late-delivery partial refunds use deterministic tiers from `delivery_sla_snapshot`:
  - `<2 days`: 0%
  - `2-7 days`: 10-30% linear
  - `>7 days`: 50%
- Admin resolution can be:
  - `full_refund`
  - `partial_refund`
  - `no_refund`

## Refund Execution
- Admin resolution creates/uses `refund_case` and enqueues `refund.initiate`.
- Outbox dispatcher runs Stripe refund calls idempotently with key `refund-case:{refund_case_id}`.
- Webhooks finalize via:
  - `refund.succeeded` -> `refund_event(type=refund_succeeded)`, dispute resolved, holds released, penalties applied.
  - `refund.failed` -> `refund_event(type=refund_failed)`.

## Entitlement Freezing and Revocation
- `entitlement_hold` types:
  - `downloads_frozen`
  - `share_disabled`
- Media access endpoints enforce holds:
  - download/full/web denied while `downloads_frozen` active
  - share-link creation/view disabled while `share_disabled` active
- For refunded extra-image purchases, extra download entitlement quantity is decremented; included finals remain.

## Contract and SLA Snapshots
- `gig_contract_snapshot` captures immutable pricing/terms at booking/gig creation.
- `delivery_sla_snapshot` records due/published/delivered timestamps for proofs/finals.
- Snapshots prevent disputes from relying on mutable runtime data.

## Admin Runbook
1. Review dispute detail and evidence timeline.
2. Validate contract/SLA snapshots.
3. Set status to `awaiting_admin`/`in_review` if needed.
4. Resolve with rationale and amount.
5. Monitor refund case (`GET /v1/admin/refunds`) and retry failures (`POST /v1/admin/refunds/{id}/retry`).
6. Release stale holds if needed (`POST /v1/admin/entitlement-holds/{id}/release`).
7. Confirm admin audit trail in `admin_audit_log`.
