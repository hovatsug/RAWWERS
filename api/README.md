# RAWWERS API - Foundations v1-v20

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
- v13: Gamification v0 (credentials, milestones, performance cycles, benefits)
- v14: Pro-only commerce v0 (partner inventory, access gating, checkout, rewards discounts)
- v15: Gear Continuity v0 (repair partners + loaner workflow, loyalty-gated)
- v16: Multi-region + reliability (EU-primary writes, replica-safe reads, outbox webhooks, public cache)
- v17: Observability + security hardening + abuse/fraud baseline
- v18: Search + indexing v0 (pros, courses, products, repair partners)
- v19: Auth + identity + RBAC v1 (JWT sessions, verification/reset, impersonation)
- v20: Notifications + messaging v1 (in-app + email, preferences, templates, reliable delivery)

## Do not use `git stash` in this checkout

Use a git worktree instead:

```
git worktree add ../rawwers-baseline HEAD
```

`git stash push` / `pop` here has twice produced macOS-style duplicate
files alongside the originals - `admin 2.py`, `outbox_tasks 2.py` - and
once left the original truncated by 350 lines while the duplicate held the
intact copy. Both were caught only by comparing line counts against
`git show HEAD:<path> | wc -l`.

The cause is the interaction between rapid stash rewrites and the file
watcher syncing this directory into Docker; it is an environment hazard,
not something to remember not to do. Baselining a test run against HEAD is
the usual reason to want a stash, and a worktree does that without
touching the working copy at all.

If you do end up stashing, check line counts before trusting the result.

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
- `PRIMARY_DATABASE_URL`, `REPLICA_DATABASE_URL`, `MAX_REPLICA_LAG_SECONDS`
- `PUBLIC_CACHE_ENABLED`, `DISCOVER_CACHE_TTL_SECONDS`, `PRO_PUBLIC_CACHE_TTL_SECONDS`
- `OUTBOX_BATCH_SIZE`, `OUTBOX_MAX_ATTEMPTS`
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
- `MAX_JSON_BODY_BYTES` (default `1048576`)
- `MAX_CHAT_MESSAGE_LENGTH` (default `2000`)
- `MAX_REVIEW_TEXT_LENGTH` (default `2000`)
- `MAX_UPLOAD_BYTES` (default `25000000`)
- `ALLOWED_UPLOAD_MIME_TYPES` (CSV)
- `RATE_LIMIT_PUBLIC_READ_PER_MIN`, `RATE_LIMIT_AUTH_MUTATION_PER_MIN`
- `RATE_LIMIT_CHAT_MESSAGES_PER_MIN`, `RATE_LIMIT_REVIEWS_PER_DAY`
- `RATE_LIMIT_REFERRAL_CLAIMS_PER_DAY`, `RATE_LIMIT_PAYMENTS_PER_HOUR`
- `RATE_LIMIT_UPLOADS_PER_HOUR`, `RATE_LIMIT_ADMIN_PER_MIN`
- `ADMIN_IP_ALLOWLIST` (optional CSV)
- `ADMIN_API_KEYS` (optional CSV)
- `SEARCH_PROVIDER`, `SEARCH_ENABLED`, `SEARCH_INDEX_PREFIX`
- `MEILI_URL`, `MEILI_API_KEY`
- `SEARCH_FALLBACK_CACHE_TTL_SECONDS`
- `AUTH_JWT_SECRET`
- `AUTH_ACCESS_TOKEN_TTL_MINUTES`, `AUTH_REFRESH_TOKEN_TTL_DAYS`
- `AUTH_EMAIL_VERIFICATION_TTL_MINUTES`, `AUTH_PASSWORD_RESET_TTL_MINUTES`
- `AUTH_DEV_BYPASS` (must be false in production)
- `NOTIFICATION_DEFAULT_TIMEZONE` (default `Europe/Lisbon`)
- `NOTIFICATION_CRITICAL_BYPASS_QUIET_HOURS` (default `true`)
- `RATE_LIMIT_NOTIFICATIONS_EMAIL_PER_DAY` (default `20`)
- `RATE_LIMIT_NOTIFICATIONS_INAPP_PER_DAY` (default `60`)
- `RATE_LIMIT_NOTIFICATIONS_BURST_PER_MIN` (default `30`)

## Foundation #17 Observability + Security + Abuse Baseline
- Structured request logs with correlation (`request_id`) and response summary fields.
- Prometheus metrics endpoint: `GET /metrics` with:
  - HTTP totals and latency histograms
  - Celery task duration/failure metrics
  - Webhook verification counters
  - Business event counters
- Safe error responses with `request_id` in response payload.
- Redis-backed rate limiting buckets:
  - `public_read`, `auth_mutation`, `chat_messages`, `reviews`, `referral_claims`, `payments`, `uploads`, `admin`
- Strict webhook signature auditing:
  - `webhook_security_log` table for Stripe/Mux verification outcomes
- Abuse signal baseline:
  - `abuse_signal` table + admin triage endpoints
- Kill switches / feature flags:
  - `feature_flag` table
  - `GET /v1/admin/feature-flags`
  - `PUT /v1/admin/feature-flags/{key}`
- Ops/admin APIs:
  - `GET /v1/admin/ops/metrics-summary`
  - `GET /v1/admin/abuse/signals`
  - `POST /v1/admin/abuse/signals/{id}/resolve`

### Webhook security notes
- Stripe and Mux webhooks now persist verification outcomes (success/failure) with source IP and metadata.
- Signature failures return safe error payloads and are counted in metrics for alerting.

### Abuse handling notes
- Deterministic baseline rules detect:
  - repeated chat spam patterns
  - suspicious referral concentration from same IP
  - high-frequency discovery scraping signals
  - repeated payment-failure anomalies
- Signals are triaged through admin abuse endpoints and tracked in immutable admin audit logs on resolution actions.

## Foundation #18 Search + Indexing v0
- Public search endpoints:
  - `GET /v1/search/pros`
  - `GET /v1/search/courses`
  - `GET /v1/search/products`
  - `GET /v1/search/repair-partners`
- Admin search ops:
  - `GET /v1/admin/search/status`
  - `POST /v1/admin/search/rebuild`
  - `POST /v1/admin/search/purge` (requires `X-Confirm: YES`)
- Incremental indexing runs through outbox topics (`index.*`) and dispatcher worker.
- Safe degradation: automatic DB fallback when provider is down or fallback flag is forced.
- Full docs: [`docs/search.md`](docs/search.md)

## Foundation #19 Auth + Identity + RBAC v1
- Bearer access token auth is supported across protected endpoints.
- Refresh token rotation + reuse detection are enforced.
- Email verification and password reset flows are outbox-backed:
  - `email.verify.send`
  - `email.reset.send`
- Admin impersonation access tokens are short-lived and non-refreshable.
- Local-only bypass via `X-User-Id` is available only when:
  - `AUTH_DEV_BYPASS=true`
  - `APP_ENV` is not `prod` / `production`
- Full docs: [`docs/auth.md`](docs/auth.md)

## Foundation #20 Notifications + Messaging v1
- In-app notifications with read/unread state:
  - `GET /v1/me/notifications`
  - `POST /v1/me/notifications/{id}/read`
  - `POST /v1/me/notifications/read-all`
- Preferences by channel/topic:
  - `GET/PUT /v1/me/notification-preferences`
  - `GET/PUT /v1/me/notification-topic-preferences`
- Outbox-backed delivery topics:
  - `notify.create_inapp`
  - `notify.send_email`
- Delivery safeguards:
  - dedupe keys
  - per-user/channel rate limits
  - quiet-hours scheduling (`scheduled_notification`)
- Admin visibility + resend:
  - `GET /v1/admin/notifications/logs`
  - `POST /v1/admin/notifications/resend`
- Full docs: [`docs/notifications.md`](docs/notifications.md)

## Foundation #16 Multi-Region + Reliability
- Write path remains authoritative in EU primary DB.
- Public read endpoints can route to replica with lag guard fallback to primary.
- Webhooks (Stripe/Mux) are durable ingests using `outbox_event` and async dispatch.
- Public discovery/profile endpoints use short-lived Redis cache keyed by index version.
- Runbook and architecture details: [`docs/multi_region.md`](docs/multi_region.md)

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

## Foundation #13 Gamification v0
- Credentials are derived from `pro_niche_skill` and persisted as snapshots in `pro_credential`:
  - mode `current`: latest tier for each niche
  - mode `highest_ever`: max tier ever reached for each niche
- Milestones are admin-defined deterministic rules (`milestone`) with derived progress (`milestone_progress`) and completion records (`milestone_completion`).
- Performance cycles (`performance_cycle`) aggregate points in `cycle_points` and append immutable events in `cycle_event`.
- Milestone completion can issue benefits through rewards rules (`reward_rule_code`) via reward ledger with rule caps enforced.

### Criteria schema (`milestone.criteria`)
- `{"type":"gig_count_completed","count":10}`
- `{"type":"delivery_sla_streak","streak":5}`
- `{"type":"dispute_free_streak","streak":8}`
- `{"type":"response_time_avg","max_minutes":60}`
- `{"type":"course_completion","course_ids":["<course_uuid>","<course_uuid>"]}`
- `{"type":"course_completion","min_count":3}`
- `{"type":"tier_reached","tier":"elite"}`
- Optional cycle points override for any milestone: add `"cycle_points": <int>`; otherwise defaults by difficulty (`standard=50`, `advanced=100`, `elite=200`).

### Gamification endpoints
- Pro:
  - `GET /v1/me/gamification/credentials`
  - `GET /v1/me/gamification/milestones`
  - `GET /v1/me/gamification/cycle/current`
- Admin:
  - `POST|PUT /v1/admin/gamification/milestones`
  - `POST|PUT /v1/admin/gamification/cycles`
  - `POST /v1/admin/gamification/recompute`

## Foundation #14 Pro Store (E-commerce v0)
- Store access is pro-only and policy-gated:
  - pro role required
  - KYC approved (policy-controlled)
  - not banned/suspended (policy-controlled)
  - highest niche tier must meet policy minimum (default `skilled`)
  - optional admin override in `store_access_override`
- Partner inventory model:
  - `manual`: admin CRUD products
  - `feed_url`: sync from JSON/CSV feed URL in `commerce_partner.api_config.feed_url`
  - `api`: provider stub for future direct integrations
- Pricing:
  - base from `product.partner_price`
  - optional `price_rule` discount (tier-gated, deterministic)
  - optional rewards discount at checkout via `discount_redemption` with `context_type=commerce_order`
  - no subsidization in v0
- Orders:
  - one partner per order in v0
  - payment tracked in `order_payment`
  - payment success triggers partner submission task
  - fulfillment status tracked on order (`submitted_to_partner`, `shipped`, `delivered`, etc.)

### Pro store endpoints
- `GET /v1/store/access`
- `GET /v1/store/products`
- `GET /v1/store/products/{product_id}`
- `POST /v1/store/cart/items`
- `GET /v1/store/cart`
- `DELETE /v1/store/cart/items/{item_id}`
- `POST /v1/store/checkout`
- `GET /v1/store/orders`
- `GET /v1/store/orders/{order_id}`

### Admin store endpoints
- `GET|POST /v1/admin/store/partners`
- `PUT /v1/admin/store/partners/{partner_id}`
- `POST /v1/admin/store/partners/{partner_id}/sync`
- `GET|POST /v1/admin/store/products`
- `PUT /v1/admin/store/products/{product_id}`
- `GET|POST /v1/admin/store/price-rules`
- `PUT /v1/admin/store/price-rules/{rule_id}`
- `GET|PUT /v1/admin/store/policy`
- `POST /v1/admin/store/overrides/{pro_user_id}`
- `POST /v1/admin/store/orders/{order_id}/update-status`

### Operational notes (manual fulfillment)
- Partner stock is external: RAWWERS does not hold inventory.
- For `manual`/`feed_url` partners, order submission sets a placeholder `partner_order_id`; fulfillment progression is admin-driven in v0.
- Store partner config should contain secret references only (never raw secrets).

## Foundation #15 Gear Continuity v0
- RAWWERS is not a repair provider and does not own/subsidize gear in v0.
- Loaners are partner-provided and "if available" unless explicit partner terms state guarantees.
- Eligibility gate (`can_access_gear_benefits`):
  - pro role required
  - KYC approved (policy-controlled)
  - not banned/suspended (policy-controlled)
  - highest niche tier >= policy minimum (`skilled` by default)
  - admin override may allow/deny
- Behavior:
  - repair ticket creation is available to pros
  - loaner request requires benefit eligibility

### Repair flow
- Pro registers gear item
- Pro opens repair ticket with evidence media they own
- Admin/operator assigns partner and manages transitions:
  - `submitted -> partner_assigned -> awaiting_quote -> quote_sent -> quote_approved -> in_repair -> ready_for_return -> shipped_back -> closed`
- Quote approval/decline endpoints for pro.

### Loaner flow
- Pro requests loaner against a ticket
- Admin/operator lifecycle:
  - `requested -> approved/declined/cancelled -> ready_for_pickup|shipped_to_pro -> in_use -> return_due -> returned -> closed`
- On approval, partner terms are snapshotted into the request.

### Repair endpoints
- Pro:
  - `GET /v1/pro/me/gear-benefits/access`
  - `POST|GET|PUT /v1/pro/me/gear-items[...]`
  - `POST /v1/repairs/tickets`
  - `GET /v1/repairs/tickets/{ticket_id}`
  - `POST /v1/repairs/tickets/{ticket_id}/request-loaner`
  - `POST /v1/repairs/tickets/{ticket_id}/approve-quote`
  - `POST /v1/repairs/tickets/{ticket_id}/decline-quote`
  - `POST /v1/repairs/tickets/{ticket_id}/close`
  - `GET /v1/repairs/partners`
- Admin:
  - `POST|PUT|GET /v1/admin/repairs/partners[...]`
  - `POST /v1/admin/repairs/partners/{partner_id}/set-active`
  - `GET /v1/admin/repairs/tickets`
  - `POST /v1/admin/repairs/tickets/{ticket_id}/assign-partner`
  - `POST /v1/admin/repairs/tickets/{ticket_id}/set-status`
  - `POST /v1/admin/repairs/tickets/{ticket_id}/set-quote`
  - `GET /v1/admin/repairs/loaners`
  - `POST /v1/admin/repairs/loaners/{loaner_request_id}/set-status`
  - `GET|PUT /v1/admin/repairs/policy`
  - `POST /v1/admin/repairs/overrides/{pro_user_id}`
  - `POST /v1/admin/repairs/partners/{partner_id}/recompute-score`

### Partner onboarding checklist (v0)
- Define categories/brands supported
- Set SLAs (`sla_quote_hours`, `sla_turnaround_days`)
- Set shipping/pickup capabilities
- Configure `partner_terms`:
  - loaner availability/disclaimers
  - deposit rules (external reference only; no RAWWERS charge handling in v0)

### Disclaimers
- Loaner support is capability-based and not guaranteed by default.
- RAWWERS does not buy inventory and does not fund repair subsidies in this slice.

## Webhooks
- Stripe: `POST /v1/webhooks/stripe`
- Mux: `POST /v1/webhooks/mux`

## Notes
- `X-User-Id` auth still used for dev.
- Discovery read endpoints support optional auth dependency (structured for future public mode).
- Banned/suspended users are blocked from write actions.
