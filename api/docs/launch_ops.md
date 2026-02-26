# Launch Ops v1

## Strategy
- Launch is `pros-first`, then client browsing by city.
- Pro onboarding and client discovery are separately gated:
  - `rollout_city.is_pro_onboarding_enabled`
  - `rollout_city.is_client_browsing_enabled`
- Feature flags can globally override:
  - `pro_onboarding_enabled`
  - `client_browsing_enabled`

## Invite Waves
- Admin creates an `invite_wave` with capacity, role scope, and optional allowed cities.
- Admin generates `invite_code` records under the wave.
- Each code is single-use and transitions:
  - `issued -> redeemed`
  - `issued -> revoked`
  - `issued -> expired`
- Invite email delivery is queued through outbox topic `launch.invite.email`.

## Pro Onboarding Funnel
- State machine:
  - `started`
  - `profile_completed`
  - `portfolio_uploaded`
  - `packages_configured`
  - `niches_selected`
  - `kyc_submitted`
  - `kyc_approved`
  - `ready_for_review`
  - `approved_public`
  - `rejected`
- Transition enforcement is deterministic and auditable via `pro_onboarding_event`.

## Quality Gates
- Requirements stored in `onboarding_requirement`:
  - `portfolio_min_items`
  - `packages_required`
  - `niches_min`
  - `require_extra_image_price_config`
  - `require_identity_verified`
- `approved_public` triggers:
  - `reindex.pro` outbox event
  - pro notification
  - analytics event

## Emergency Rollback
1. Disable client browsing for cities:
   - `PUT /v1/admin/rollout/cities`
2. Disable global browsing quickly:
   - feature flag `client_browsing_enabled = false`
3. Pause new pro starts:
   - feature flag `pro_onboarding_enabled = false`
4. Pause invites:
   - set waves `is_active = false` (or revoke codes)
