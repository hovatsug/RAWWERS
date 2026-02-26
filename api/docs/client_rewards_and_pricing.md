# Client Rewards And Tier Pricing

## Consent rewards
- Consent updates (`PUT /v1/gigs/{gig_id}/consent`) can award points by consent level.
- Policies are configured in `consent_reward_policy` and managed in admin endpoints.
- Awards are idempotent per `gig + client + consent_level` via outbox-driven processing.
- Downgrade clawbacks are supported during policy cooldown windows, with negative balances capped by `REWARD_BALANCE_FLOOR`.

## Share engagement rewards
- Public share views are deduplicated per `share_link + fingerprint + day`.
- Engagement requires accumulated view time (`min_seconds_viewed`) to count toward thresholds.
- Thresholds are configured in `share_reward_threshold` and grants in `share_reward_grant` are unique per `(share_link, metric, threshold, user)`.
- Fraud knobs:
  - `min_seconds_viewed`
  - `max_views_per_ip_per_day`
  - `max_rewards_per_user_per_month`
- Abuse signals are emitted for suspicious share-farming patterns.

## Extra image pricing
- Unit price is computed from:
  - pro configured price (`pro_extra_image_price`) or gallery default
  - niche+tier policy (`extra_image_pricing_policy`)
- Effective price applies deterministic clamp:
  - `max(unit_price_min, configured_price)`
  - then `min(..., unit_price_max)` when max exists
- Tier is resolved from `pro_niche_skill` for gig niche.
- `max_extra_images` is enforced when policy defines it.
- Purchase snapshots are stored in `extra_image_purchase` and include configured/applied policy values.

## Gamification tie-in
- Client milestones reuse the existing gamification framework with `milestone.audience` and criteria types:
  - `share_unique_views_reached`
  - `consent_level_set`
  - `extra_images_purchased`
  - `review_left`
- Existing `/v1/me/game/quests` and `/v1/me/game/seasons/current` routes map to milestone/cycle data.

## Admin endpoints
- Pricing policies:
  - `GET/PUT /v1/admin/pricing/extra-image-policies`
  - `GET/PUT /v1/admin/pricing/pro-extra-image-price/{pro_user_id}`
- Reward policies:
  - `GET/PUT /v1/admin/rewards/consent-policies`
  - `GET/PUT /v1/admin/rewards/share-thresholds`
  - `GET /v1/admin/rewards/share-grants`
- Fraud settings:
  - `GET/PUT /v1/admin/rewards/share-fraud-settings`

All admin writes are audit-logged via `admin_audit_log`.
