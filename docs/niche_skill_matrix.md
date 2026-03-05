# RAWWERS Niche Skill Matrix v2

## Overview
Slice #40 upgrades niche competency into a deterministic, per-niche matrix used by discovery, premium eligibility, and pricing constraints.

Each `(pro_user_id, niche_id)` now has:
- `tier`: `rookie|skilled|pro|elite|master`
- `score`: `0..100`
- `verified`: curriculum/certification-backed
- quality evidence (`gigs_completed`, `avg_rating`, `review_count`)
- explainability log in `pro_niche_skill_event`

## Score formula
For each pro+niche:
- `gigs_points = min(gigs_completed, 120) * 0.5` (max 60)
- `rating_points = clamp((avg_rating - 4.0) * 25, 0, 25)` if `review_count >= 10`
- `rating_points = clamp((avg_rating - 4.0) * 15, 0, 15)` if `review_count < 10`
- `verified_bonus = 10` if verified else `0`
- `penalty = min(disputes_lost_90d * 10, 30)`
- `score = clamp(gigs_points + rating_points + verified_bonus - penalty, 0, 100)`

## Tier policy
`niche_tier_policy.thresholds` is admin-configurable per niche.
Default schema:
- `rookie`: min score/gigs/rating baseline
- `skilled`: moderate threshold
- `pro|elite|master`: require `verified=true` by default

Highest satisfied tier is assigned.

## Hysteresis
To avoid oscillation:
- promotion/demotion changes are rate-limited with 7-day hysteresis
- admin override can bypass this behavior

## Events and auditability
Every recalc/override writes `pro_niche_skill_event` with:
- before/after tier
- before/after score
- reasons payload (signal values + threshold snapshot)
- actor (`system|admin`)

## Badges
Current-only niche badges are synchronized on tier/verified updates:
- tier badge: `tier_{nicheSlug}_{tier}`
- verification badge: `verified_{nicheSlug}`

Old niche-tier badges are revoked when new status is applied.

## Integrations
- **Discovery/indexing**:
  - `pro_public_index.niche_tiers` map
  - `pro_public_index.verified_niches` list
  - ranking adds top-tier bonus
- **Extra image pricing**:
  - clamps use `pro_niche_skill.tier` for gig niche
  - fallback tier = rookie if missing
- **Legacy Shoot eligibility**:
  - requires `tier >= min_tier` and `verified = true`

## Admin runbook
- Manage niches: `GET/PUT /v1/admin/niches`
- Manage tier policy: `GET/PUT /v1/admin/niches/{niche_id}/tier-policy`
- Inspect pro matrix: `GET /v1/admin/pros/{pro_user_id}/niche-skill`
- Override value: `POST /v1/admin/pros/{pro_user_id}/niche-skill/{niche_id}/override`
- Recalc queue: `POST /v1/admin/niche-skill/recalc`

## Operational notes
- Recalc requests are pushed to outbox topic `niche_skill.recalc`
- Worker consumes outbox and runs deterministic recomputation
- This keeps writes multi-region-safe and avoids expensive sync recalcs in hot paths
