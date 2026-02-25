# RAWWERS API - Foundations v1-v12

Backend foundations implemented:
- v1: Media subsystem (R2 photos + Mux videos)
- v2: Gigs + Stripe full-payment + ledger
- v3: Admin ops + KYC + bans + disputes/refunds
- v4: Proof gallery + selections + upsell + delivery
- v5: Pro onboarding + packages + availability + booking requests
- v6: Discovery + matching + ranking + analytics + reindexing
- v7: Reviews + reputation + moderation + trust signals
- v8: Referrals + rewards ledger + discount redemption + retention reminders
- v9: AI Concierge v0 (text chat qualification + booking conversion)
- v10: Follow-ups + notifications + AI calling agent v0 (compliance-first)
- v11: Niches taxonomy + per-niche hybrid skill levels (courses + performance)
- v12: E-learning v0 (verified instructors, courses, enrollments, certificates, niche gates)

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
- `LLM_PROVIDER` (`mock` or `openai`)
- `OPENAI_API_KEY`, `OPENAI_MODEL` (required when `LLM_PROVIDER=openai`)
- `LLM_MAX_TOKENS_PER_THREAD`, `LLM_MAX_MESSAGES_PER_THREAD`
- `TELEPHONY_PROVIDER` (default `mock`)
- `TELEPHONY_FROM_E164` (required for non-mock provider)
- `TELEPHONY_WEBHOOK_SECRET`
- `CALL_RATE_LIMIT_PER_USER_PER_DAY` (default `2`)
- `CALL_RATE_LIMIT_PER_PRO_PER_DAY` (default `20`)

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
Niche-filtered discover (tier-aware ordering):
```bash
curl -X GET "http://localhost:8000/v1/discover/pros?niche=weddings&limit=20&offset=0"
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

## Foundation #9 AI Concierge (Text)
- Chat endpoints:
  - `POST /v1/pros/{pro_user_id}/chats`
  - `GET /v1/chats/{thread_id}`
  - `POST /v1/chats/{thread_id}/messages`
  - `POST /v1/chats/{thread_id}/takeover`
  - `POST /v1/chats/{thread_id}/close`
  - `POST /v1/chats/{thread_id}/create-booking-request`
- Grounding rule: AI replies only from `context_snapshot` captured at thread creation:
  - public pro profile fields
  - active packages
  - availability summary
  - platform policies (`platform_policy` table)
- If question is outside grounded data, assistant responds that it will confirm with the photographer.
- Provider abstraction:
  - `mock` provider is deterministic and used for local/test workflows
  - `openai` provider scaffold uses `OPENAI_MODEL` and does not hardcode model IDs
- AI emits optional `booking_request_draft` tool output; draft is persisted in thread snapshot and can be converted into a booking request by client.

## Foundation #10 Follow-ups + Calling
- Contact and consent:
  - `PUT /v1/me/contact`
  - `POST /v1/me/consent`
- Follow-up admin:
  - `POST /v1/admin/followups/rules/seed`
  - `POST /v1/admin/followups/rebuild`
- Calling:
  - `POST /v1/calls/request`
  - `POST /v1/webhooks/telephony`
  - `POST /v1/calls/{call_session_id}/ai/summary`

### Follow-up behavior
- Rules are stored in `followup_rule` and jobs in `followup_job`.
- Jobs are idempotent by `(rule_code, user_id, target_type, target_id, scheduled_for)`.
- Current implementation sends in-app notifications (`notification` table) and can queue transactional phone calls for phone-call rules.

### Compliance rules enforced
- Transactional phone consent required (`contact_consent`) before calls.
- Exception: one-time `call_me_button` source is allowed and logged as a consent event.
- Quiet hours are enforced using `user_contact.timezone` + `quiet_hours_start/end`.
- Daily rate limits enforced per recipient and per pro.
- Transcript is stored only when active consent metadata includes `{"transcription_ok": true}`.
- Audit logs are recorded for consent changes and admin-triggered calls.

## Foundation #11 Niches + Skills
- Niche taxonomy is in `niche` and seeded with:
  - `weddings`, `portraits`, `family`, `corporate`, `events_nightlife`, `product`, `real_estate`, `food`, `automotive`, `sports`, `maternity`, `architecture`
- Niche linkage:
  - pros self-declare via `PUT /v1/pro/me/niches`
  - packages must include `niche_id` or `niche_slug` on create/update
  - gigs inherit niche from accepted booking package and store immutable `metadata.niche_slug` / `metadata.niche_name`
  - reviews are niche-scoped by gig niche
  - portfolio assets can be niche-tagged via `POST /v1/pro/me/portfolio/{media_asset_id}/niches`
- Hybrid scoring table: `pro_niche_skill`
  - `capability_score` (performance signals)
  - `certification_score` (placeholder certifications from `certification_record`)
  - `confidence` (evidence volume)
  - `tier` gates:
    - `rookie`: default
    - `skilled`: `certification >= 40` OR (`capability >= 55` and `confidence >= 0.20`)
    - `pro`: `certification >= 60` AND `capability >= 65` AND `confidence >= 0.35`
    - `elite`: `certification >= 75` AND `capability >= 75` AND `confidence >= 0.55`
    - `master`: `certification >= 85` AND `capability >= 85` AND `confidence >= 0.70` AND `evidence_gigs >= 15`
- Skill read endpoints:
  - `GET /v1/pros/{pro_user_id}/skills`
  - `GET /v1/pro/me/skills`
- Admin override:
  - `POST /v1/admin/pros/{pro_user_id}/skills/{niche_slug}/override`
  - override metadata is stored under `pro_niche_skill.breakdown.override` and audit logged.

## Foundation #12 E-Learning v0
- Only admin-approved instructors can publish and manage course content.
- Course publish checklist:
  - instructor status must be `approved`
  - at least 1 module and 1 lesson
  - video lessons must include `video_media_asset_id`
  - short-video policy enforced (`duration_seconds <= 900` when provided)
- Completion issues `certificate` and upserts `certification_record` used by #11 hybrid niche scoring.
- Certification score influence:
  - default mapping from course level:
    - beginner `60`, intermediate `70`, advanced `80`, master `90`
  - if quiz attempts exist, highest quiz score is used (0..100)
  - advanced/master can expire in 2 years (`expires_at`)

### Instructor approval flow
- Admin approves:
  - `POST /v1/admin/instructors/{user_id}/approve`
- Admin rejects:
  - `POST /v1/admin/instructors/{user_id}/reject`

### Courses and learning
- List published courses:
```bash
curl -X GET "http://localhost:8000/v1/courses?niche_slug=weddings&free_only=true&limit=20&offset=0"
```
- Enroll:
```bash
curl -X POST http://localhost:8000/v1/courses/<course_id>/enroll \
  -H "X-User-Id: <user_id>"
```
- Mark lesson progress:
```bash
curl -X POST http://localhost:8000/v1/enrollments/<enrollment_id>/lessons/<lesson_id>/progress \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <user_id>" \
  -d '{"status":"completed","progress_percent":100}'
```
- Publish instructor course:
```bash
curl -X POST http://localhost:8000/v1/instructor/courses/<course_id>/publish \
  -H "X-User-Id: <instructor_user_id>"
```

### Admin learning moderation and gates
- List courses (admin):
```bash
curl -X GET "http://localhost:8000/v1/admin/courses?published=true" \
  -H "X-User-Id: <admin_user_id>"
```
- Unpublish course:
```bash
curl -X POST "http://localhost:8000/v1/admin/courses/<course_id>/unpublish?reason=policy" \
  -H "X-User-Id: <admin_user_id>"
```
- Set niche program requirements:
```bash
curl -X POST http://localhost:8000/v1/admin/niches/weddings/requirements \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <admin_user_id>" \
  -d '{"tier_target":"pro","course_ids":["<course_uuid>"],"is_mandatory":true}'
```

## Webhooks
- Stripe: `POST /v1/webhooks/stripe`
- Mux: `POST /v1/webhooks/mux`

## Notes
- `X-User-Id` auth still used for dev.
- Discovery read endpoints support optional auth dependency (structured for future public mode).
- Banned/suspended users are blocked from write actions.
