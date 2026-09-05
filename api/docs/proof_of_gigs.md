# Proof of Gigs v1

## Philosophy
Proof of Gigs is an internal, non-tradable RAWW credits issuance engine.
Credits are minted only from verified platform events and always recorded in the rewards ledger and `raww_mint_event` audit trail.

Principles:
- Deterministic: no probabilistic scoring.
- Idempotent: each issuance event mints at most once.
- Auditable: every mint/clawback has snapshot metadata and admin logs.
- Reversible: refunds/disputes can reverse prior minted credits.

## Issuance Rules
Event types:
- `gig.completed`
- `gig.delivery_confirmed`
- `review.posted`
- `gig.extras_purchased`
- `studioverse.pack_sold`
- `studioverse.milestone_reached`

Rule config table: `raww_issuance_rule`
- `base_raww`
- `min_eur_value`
- `max_raww_per_event`
- `is_active`

Mint flow:
1. Load active rule.
2. Resolve verified business reference (gig/review/extra/order/milestone).
3. Check minimum EUR threshold.
4. Apply deterministic multipliers and penalties.
5. Apply per-pro and global caps.
6. Insert `raww_mint_event` (idempotent unique key).
7. Credit rewards ledger (`proof_of_gigs` rule code).

## Configuration Knobs
Admin endpoints:
- `GET/PUT /v1/admin/raww/issuance-rules`
- `GET/PUT /v1/admin/raww/multiplier-policy`
- `GET/PUT /v1/admin/raww/caps`
- `GET /v1/admin/raww/mints`
- `POST /v1/admin/raww/clawback`

Feature flags:
- `raww_minting_enabled`
- `raww_minting_event_gig_completed_enabled`
- `raww_minting_event_pack_sold_enabled`

## Anti-Gaming Strategy
Hard blocks:
- Self-dealing: client and pro are same user.
- Abuse threshold exceeded (open high-severity abuse signals).

Deterministic reductions:
- Repeated low-value pro-client pair pattern in 30-day window.
- Open disputes and refund outcomes reduce mint multiplier.

Caps:
- `pro_daily`
- `pro_weekly`
- `pro_monthly`
- `global_daily`

When caps are hit, award is clamped; if no remaining allowance, mint is blocked.

## Reversals and Clawbacks
Automatic reversal:
- On refund success, related gig mints are reversed via outbox event (`raww.reverse_refund`).

Manual clawback:
- Admin endpoint writes `raww_clawback` + negative rewards ledger adjustment.
- All clawbacks produce admin audit log and analytics event `raww.clawback`.

## Milestones Runbook
Weekly job:
- Celery task `app.tasks.proof_of_gigs_tasks.scan_studioverse_milestones` enqueues `raww.milestone.scan`.
- Scanner checks paid sales per content pack.
- Milestones: 10, 50, 200 sales.
- Emits deterministic milestone mint events with stable idempotency keys.

## Incident Response
1. Disable `raww_minting_enabled` immediately.
2. Inspect `raww_mint_event` for blocked/minted distribution.
3. If fraud found, run targeted clawbacks and capture reason in admin audit.
4. Re-enable event flags incrementally after rule/cap adjustments.
