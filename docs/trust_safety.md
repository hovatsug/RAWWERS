# Trust & Safety v1

RAWWERS Foundation #36 introduces a deterministic risk-control layer for abuse detection and automated protection of bookings, rewards, share links, and payouts.

## Rule Set (v1)

- `auth.velocity_login_failures`
  - Trigger: failed logins exceed threshold in window.
  - Action: `require_verification`.
- `referral.farm_suspected`
  - Trigger: repeated referral activity from same hashed IP in window.
  - Actions: `freeze_rewards`, `manual_review`.
- `share.view_farm_suspected`
  - Trigger: low-engagement share views from same hashed IP exceed threshold.
  - Actions: `disable_share_links`, `freeze_rewards`.
- `booking.spam`
  - Trigger: booking requests exceed threshold/day.
  - Action: `throttle_bookings`.
- `payment.failure_rate`
  - Trigger: payment failures exceed threshold/24h.
  - Action: `require_verification`.
- `payout.anomaly`
  - Trigger: payout request near first earnings availability.
  - Actions: `freeze_payouts`, `manual_review`.
- `dispute.rate_high`
  - Trigger: dispute opens exceed threshold/30d.
  - Action: `manual_review`.

Rules are stored in `risk_rule` and are admin-editable.

## Enforcement Points

- Booking request creation (`/v1/client/bookings/request`)
  - blocks when `throttle_bookings` is active.
- Share link creation and public share views (`/v1/gigs/{gig_id}/share-links`, `/v1/share/{token}`)
  - blocks/invalidates when `disable_share_links` is active.
- Reward issuance (`services/rewards.py`, share reward evaluator)
  - skipped when `freeze_rewards` is active.
- Payout requests (`services/payouts.py`)
  - blocked when `freeze_payouts` is active.
- Authenticated flows (`require_not_banned` dependency)
  - sensitive actions blocked for non-verified users when `require_verification` is active.

## Admin API

- `GET /v1/admin/risk/users?level=&score_min=`
- `GET /v1/admin/risk/users/{user_id}`
- `POST /v1/admin/risk/users/{user_id}/clear-action`
- `POST /v1/admin/risk/users/{user_id}/set-score`
- `GET /v1/admin/risk/rules`
- `PUT /v1/admin/risk/rules/{rule_id}`

## Privacy and Retention

- Raw IP, device ID, and session IDs are not stored.
- Stored values are salted hashes:
  - `risk_ip_hash_pepper`
  - `risk_device_hash_pepper`
  - `risk_session_hash_pepper`
- Detailed risk signals are retained per `risk_signal_retention_days` (default: 90 days).

## Operations Runbook

1. Monitor risk events and active actions via `/v1/admin/risk/users/{user_id}`.
2. For false positives, clear targeted actions first, then adjust score if needed.
3. Keep high-risk actions (`freeze_payouts`, `freeze_rewards`) until manual verification.
4. Tune thresholds in `risk_rule` before changing score deltas.
5. Use feature flags/rollout overrides to limit blast radius when tightening rules.

## Background Jobs

- `app.tasks.trust_safety_tasks.reconcile_risk_profiles`
  - daily (recommended): recompute profile score from recent events.
- `app.tasks.trust_safety_tasks.purge_risk_signals`
  - daily (recommended): purge stale signals by retention window.
