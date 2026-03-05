# RAWWERS Growth Engine v1 (Foundation #35)

This slice introduces end-to-end referral + attribution mechanics integrated with rewards, share links, webhooks, and abuse controls.

## Scope

- Referral identity (`referral_profile`, `referral_link`)
- Attribution touchpoints (`attribution_touch`, `conversion_attribution`)
- Referral conversion policies (`referral_reward_policy`)
- Idempotent reward grants (`referral_reward_grant`)
- Blacklist controls (`referral_blacklist`)
- Viral mechanics on share links (CTA + "Powered by RAWWERS")

## Attribution Logic

### 1) Referral landing

- Public endpoint: `GET /v1/ref/{code}`
- Valid code flow:
  - records referral click (`referral_link` with `clicked`)
  - creates/updates session cookie `rw_sid`
  - when consent is true, records `attribution_touch` (`source=referral`)
  - sets `rw_ref` cookie for registration binding

### 2) Registration binding

- On `POST /v1/auth/register`:
  - ensures referral code profile for new user
  - binds anonymous touches (`rw_sid`) to user when tracking consent cookie exists
  - links referee to referrer if `rw_ref` is present

### 3) Share-link attribution

- `GET /v1/share/{token}`:
  - logs `viral.share_view`
  - when consent exists, records `attribution_touch(source=share_link, content=<share_link_id>)`
  - returns CTA footer fields

### 4) Conversion attribution priority

On conversion recording:

1. If referral exists for user, primary attribution is referral.
2. Else if share link id is present, primary attribution is share link.
3. Else fallback to latest UTM touch.

Stored in `conversion_attribution.attributed_to`.

## Reward Issuance and Idempotency

Conversion rewards are triggered in Stripe webhook success handling:

- Booking payment success -> `booking_paid`
- Extras payment success -> `extras_paid`

Rules:

- policy-driven points for referrer/referee
- min conversion value guard
- monthly cap per referrer
- cooldown days per referrer/referee pair
- referrer blacklist check
- hard idempotency by unique `(conversion_type, conversion_id)` in `referral_reward_grant`
- reward ledger entries use deterministic references (`referral_conversion:<type>:<id>:referrer|referee`)

## Admin Controls

- `GET /v1/admin/referrals/report?from=&to=&city=`
- `GET /v1/admin/referrals/policy`
- `PUT /v1/admin/referrals/policy`
- `POST /v1/admin/referrals/blacklist/{user_id}`
- `DELETE /v1/admin/referrals/blacklist/{user_id}`

## User Endpoints

- `GET /v1/me/referral-code`
- `POST /v1/me/referral-code/regenerate`
- `GET /v1/me/referrals/stats`

Legacy endpoints remain available for compatibility:

- `GET /v1/referrals/me`
- `POST /v1/referrals/claim`

## Abuse Prevention

- Referral claim rate limits (`referral_claims` + `auth_mutation`)
- Blacklist hard-blocks reward grants and marks link as `blocked`
- Existing abuse signal system still observes suspicious referral patterns

## GDPR / Consent Notes

Attribution storage is consent-gated using `rw_tracking_consent=yes` cookie.

- Without consent:
  - session cookie can still be set for flow continuity
  - UTM/ref touch rows are not persisted
- With consent:
  - source/utm/share touch metadata is recorded

Adjust frontend consent UI to explicitly set `rw_tracking_consent` before attribution calls.

## Viral Watermarking

Media pipeline update:

- non-share preview variant (`watermark_preview`): standard watermark
- share derivative (`preview_watermarked`): includes subtle "Powered by RAWWERS" footer
- final downloads (`full_res`) unchanged

## Operational Notes

- Alembic revision: `20260305_0032_growth_engine_v1`
- Integrates with:
  - share links/media rights (#21)
  - rewards/gamification (#22)
  - client funnel + webhooks (#25, #2)
  - analytics/metrics/abuse (#17)
  - outbox hooks remain compatible (#16)
