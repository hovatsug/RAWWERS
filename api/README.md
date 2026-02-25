# RAWWERS API - Foundations v1-v8

Backend foundations implemented:
- v1: Media subsystem (R2 photos + Mux videos)
- v2: Gigs + Stripe full-payment + ledger
- v3: Admin ops + KYC + bans + disputes/refunds
- v4: Proof gallery + selections + upsell + delivery
- v5: Pro onboarding + packages + availability + booking requests
- v6: Discovery + matching + ranking + analytics + reindexing
- v7: Reviews + reputation + moderation + trust signals
- v8: Referrals + rewards ledger + discount redemption + retention reminders

## Setup
```bash
cd api
cp .env.example .env
make up
make migrate
make test
```

## Key Environment Variables
- `DATABASE_URL`, `REDIS_URL`
- `R2_*`, `MUX_*`, `STRIPE_*`
- `ADMIN_USER_IDS`, `BAN_ENFORCEMENT_MODE`
- `ALLOW_UNVERIFIED_PRO`

## Discovery Ranking (v0)
`ranking_score` is deterministic:
- base `100`
- `+ completeness_score * 0.5`
- `+ log1p(portfolio_photo_count + portfolio_video_count) * 10`
- `+ gigs_completed * 1.0`
- `- gigs_cancelled * 2.0`
- `- disputes_count * 5.0`
- responsiveness bonus:
- `< 60 min => +10`
- `< 180 min => +5`
- otherwise `+0`
- review reputation bonus:
- `+ (avg_rating - 4.0) * 20 * log1p(review_count) * confidence`
- `confidence = min(review_count, 5) / 5`
- clamped to `[0, 1000]`

## Discovery Endpoints
Discover pros:
```bash
curl -X GET "http://localhost:8000/v1/discover/pros?city=Lisbon&styles=editorial,street&sort=rank&limit=20&offset=0"
```

Public pro profile:
```bash
curl -X GET http://localhost:8000/v1/pros/<pro_user_id>/public
```
Includes `avg_rating` and `review_count` from `pro_public_index`.

Deterministic match suggestions:
```bash
curl -X POST http://localhost:8000/v1/discover/match \
  -H "Content-Type: application/json" \
  -d '{"city":"Lisbon","styles":["editorial"],"budget":"150.00","limit":10}'
```

Analytics ingest:
```bash
curl -X POST http://localhost:8000/v1/analytics \
  -H "Content-Type: application/json" \
  -d '{"event_name":"discover.search","properties":{"city":"Lisbon"},"session_id":"sess_1"}'
```

## Reindex Endpoints (Admin)
Single pro reindex:
```bash
curl -X POST http://localhost:8000/v1/admin/index/pro/<pro_user_id>/rebuild \
  -H "X-User-Id: <admin_user_id>"
```

Rebuild all:
```bash
curl -X POST http://localhost:8000/v1/admin/index/pro/rebuild-all \
  -H "X-User-Id: <admin_user_id>"
```

## Foundation #5 Booking Flow
- Pro updates profile + creates package + sets availability + activates
- Client creates booking request
- Pro accepts -> API creates gig (`payment_pending`) + Stripe PaymentIntent

## Foundation #7 Review Flow
Create review (client, only after completed/final_delivered gig):
```bash
curl -X POST http://localhost:8000/v1/gigs/<gig_id>/review \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <client_user_id>" \
  -d '{"rating":5,"tags":["punctual","creative"],"text":"Excellent delivery","would_book_again":true}'
```

List published reviews for a pro:
```bash
curl -X GET "http://localhost:8000/v1/pros/<pro_user_id>/reviews?limit=20&offset=0"
```

Create single pro reply:
```bash
curl -X POST http://localhost:8000/v1/reviews/<review_id>/reply \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <pro_user_id>" \
  -d '{"text":"Thank you for the feedback."}'
```

Admin moderation:
```bash
curl -X POST http://localhost:8000/v1/admin/reviews/<review_id>/moderate \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <admin_user_id>" \
  -d '{"action":"hidden","reason":"policy violation"}'
```

## Foundation #8 Referrals + Rewards
Get/create my referral code:
```bash
curl -X GET http://localhost:8000/v1/referrals/me \
  -H "X-User-Id: <user_id>"
```

Claim referral code:
```bash
curl -X POST http://localhost:8000/v1/referrals/claim \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <referred_user_id>" \
  -d '{"code":"AB12CD34"}'
```

Check rewards:
```bash
curl -X GET http://localhost:8000/v1/rewards/balance -H "X-User-Id: <user_id>"
curl -X GET "http://localhost:8000/v1/rewards/ledger?limit=20&offset=0" -H "X-User-Id: <user_id>"
```

Reserve points for a context:
```bash
curl -X POST http://localhost:8000/v1/rewards/spend \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <user_id>" \
  -d '{"context_type":"gig_payment","context_id":"<gig_uuid>","points":500,"payment_amount":"120.00","currency":"EUR"}'
```

Admin reward controls:
```bash
curl -X GET http://localhost:8000/v1/admin/rewards/rules -H "X-User-Id: <admin_user_id>"

curl -X POST http://localhost:8000/v1/admin/rewards/rules/client_first_booking_paid \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <admin_user_id>" \
  -d '{"is_enabled":true,"amount":500,"daily_cap_per_user":5000,"lifetime_cap_per_user":50000}'

curl -X POST http://localhost:8000/v1/admin/rewards/adjust \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <admin_user_id>" \
  -d '{"user_id":"<user_uuid>","amount":250,"reason":"support adjustment"}'
```

### Rewards conversion configuration
- `REWARD_POINTS_PER_EUR` (default `100`): points needed for `€1` discount.
- `REWARD_MAX_DISCOUNT_PERCENT` (default `20`): max discount against payment amount.
- Optional override via `reward_rule` with code `discount_conversion` and metadata:
  - `{"points_per_eur":100,"max_discount_percent":20}`

### Reminder hooks
- On proof gallery publish, reminder jobs are scheduled at +24h and +72h for pending client selection.
- Placeholder sending is implemented as status transitions + analytics events (`reminder.sent`).
- Messaging transport (email/push) remains a dev placeholder in this slice.

## Webhooks
- Stripe: `POST /v1/webhooks/stripe`
- Mux: `POST /v1/webhooks/mux`

## Notes
- `X-User-Id` auth still used for dev.
- Discovery read endpoints support optional auth dependency (structured for future public mode).
- Banned/suspended users are blocked from write actions.
