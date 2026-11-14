# Deploy checklist

Every step a deploy needs beyond shipping the image, in the order they happen. Each item links to the entry in [BACKEND_GAPS.md](BACKEND_GAPS.md) that explains why it exists and what goes wrong without it - read that before skipping one. When a change adds a deploy step, it is added here in the same commit.

`[ ]` items are per deploy. Items marked **once** stay until the environment has had them done; tick them off per environment in the table at the end.

## 1. Before deploying - checks against the target database

- [ ] **Paid gigs without a settled base payment.** Run the query in [DEPLOY CHECK: paid gigs without a settled base payment now release nothing](BACKEND_GAPS.md#deploy-check-paid-gigs-without-a-settled-base-payment-now-release-nothing). Any row is a client who chose photos and would be refused them. Fix the data before deploying; it is not a code change.
- [ ] **Reference data present.** Run the count query in [DEPLOY READINESS: production has no way to get the camera reference table or the price caps](BACKEND_GAPS.md#deploy-readiness-production-has-no-way-to-get-the-camera-reference-table-or-the-price-caps). Empty `camera_model_reference` sends every gear submission to review; empty `niche_package_price_cap` means the entry-price cap enforces nothing. Load both from the admin (Catalog & pricing) - the seed scripts refuse production by design.
- [ ] **Every active niche and tier has a price-cap row.** A missing (niche, tier) pair is not an error - `enforce_entry_price_cap` treats it as unrestricted - so a partial table looks configured while leaving whole niches uncapped. This must return no rows:

      SELECT n.slug, t.tier
      FROM niche n
      CROSS JOIN (VALUES ('rookie'), ('skilled'), ('pro'), ('elite'), ('master')) AS t(tier)
      WHERE n.is_active
        AND NOT EXISTS (
          SELECT 1 FROM niche_package_price_cap c WHERE c.niche_id = n.id AND c.tier = t.tier
        );

  A `master` row with no maximum is correct: master is uncapped by design, and the row has to exist anyway.

- [ ] **Duplicated reward-ledger references (migration `0079`).** `0079` adds a unique index on `reward_ledger_entry (user_id, entry_type, reference_type, reference_id)`. It first lists any existing duplicates and, if there are any, stops without changing or deleting anything. Run this first; it must return no rows:

      SELECT user_id, entry_type, reference_type, reference_id, count(*), sum(amount)
      FROM reward_ledger_entry
      WHERE reference_type IS NOT NULL AND reference_id IS NOT NULL
      GROUP BY 1, 2, 3, 4 HAVING count(*) > 1;

  Each row is an event credited more than once. Decide it with an admin adjustment, then deploy.

- [ ] **Run the integration tests against a live backend, and they must pass.** With the release candidate's `api/` up on this machine (`docker compose up`, a development or test `APP_ENV`), run in `app/`:

      flutter test --tags integration --run-skipped

  The summary must show **3 passed, 0 skipped, 0 failed**. An ordinary `flutter test` skips them by tag, and CI excludes them, so nothing else runs them: the real transport stack and the register-login-upgrade-logout flow are proven only here. Run on request they never skip. Before any test they check that the backend is on this machine and reports a development or test environment (`/v1/dev/environment`, which production does not have), and if it isn't, every test fails. The account the flow registers is deleted at the end of the run (`DELETE /v1/dev/test-accounts/me`), so a run leaves nothing behind.

- [ ] **Gigs made from requests that could not be booked.** Until confirm-slot checked the request it was answering, a photographer could make an unpaid gig from a request that had expired, that they had declined, or that the client had withdrawn. Count them:

      SELECT r.status AS request_status, g.status AS gig_status, count(*)
      FROM gig g
      JOIN booking_request r ON r.id::text = g.metadata->>'booking_request_id'
      WHERE r.status IN ('declined', 'cancelled', 'expired')
      GROUP BY r.status, g.status;

  Any row is a booking the client did not agree to, or no longer wanted. **Nothing deletes these automatically** - a paid one involves money and a person - so each is a decision: cancel and refund, or contact the client. Dev, 2026-10-12: none.

- [ ] **Admin tier overrides lost before migration `20261013_0059`.** Until then an override was undone by the first recompute after the hysteresis window - and rebuild-all, which this deploy runs, would have undone every one at once. `0059` keeps overrides (tier, admin, time, reason) and carries over any still in place; one already erased cannot be recovered from the skill row. List them from the event log, before and after migrating, and re-apply on the admin page (Photographers -> the photographer -> Niche tiers) any that should stand:

      SELECT e.pro_user_id, n.slug, e.to_tier, e.actor_user_id, e.created_at, e.reasons->>'note' AS reason,
             s.tier AS tier_now, s.override_tier
      FROM pro_niche_skill_event e
      JOIN niche n ON n.id = e.niche_id
      LEFT JOIN pro_niche_skill s ON s.pro_user_id = e.pro_user_id AND s.niche_id = e.niche_id
      WHERE e.event_type = 'admin_override'
        AND e.created_at = (SELECT max(created_at) FROM pro_niche_skill_event x
                            WHERE x.pro_user_id = e.pro_user_id AND x.niche_id = e.niche_id AND x.event_type = 'admin_override')
      ORDER BY e.created_at;

  A row where `override_tier` is empty after migrating is an override that was lost. Dev: none.

- [ ] **More than one refund in flight on one payment - before migration `20261018_0063`.** `0063` adds a partial unique index allowing one refund case in flight (`pending`, `requested`, `approved`, `refund_initiated`, `processing`) per payment intent. If two already share one, the migration stops and lists them rather than choosing; a refund record is money, so which one is real is a person's call. This must return no rows:

      SELECT stripe_payment_intent_id, count(*), string_agg(id::text || ' ' || status, ', ')
      FROM refund_case
      WHERE stripe_payment_intent_id IS NOT NULL
        AND status IN ('pending', 'requested', 'approved', 'refund_initiated', 'processing')
      GROUP BY stripe_payment_intent_id
      HAVING count(*) > 1;

  For each row, check the payment in the Stripe dashboard: keep the case that matches a refund Stripe has, and set the other to `cancelled` with a note in `admin_note`. Dev, 2026-10-18: none.

- [ ] **Paid payments left `pending` by an admin refund - repaired by migration `20261019_0064`.** Until then an admin refund marked its payment `pending` as soon as it was asked for, whatever the amount, so a part-refunded booking looked unpaid. `0064` puts each one back to `succeeded` (or `refunded` if its settled refunds add up to all of it) and records the amount refunded. Count them before migrating, so the change is known:

      SELECT count(*), sum(p.amount)
      FROM stripe_payment p
      WHERE p.status = 'pending' AND p.metadata ? 'paid_at'
        AND EXISTS (SELECT 1 FROM refund_case c
                    WHERE c.stripe_payment_intent_id = p.stripe_payment_intent_id
                       OR c.metadata->>'stripe_payment_id' = p.id::text);

  Dev, 2026-10-19: none. Each repaired booking's finals unlock again if the rest of it was paid - which is the point: a partial refund was never meant to lock them.

## 2. Deploying

- [ ] **The production image starts.** Build the `runtime` stage, which installs no dev dependencies, and import the app in it with the environment's settings (from the repo root; `deploy/.env.prod` is the file `deploy/compose.prod.yml` uses, use the staging one for staging):

      docker build --target runtime -t rawwers-api-runtime-check api
      docker run --rm --env-file deploy/.env.prod rawwers-api-runtime-check python -c "import app.main; print('ok')"

  Expect `ok`. Without the settings the import stops at the first required one (`Field required`), which says nothing about the image. Dev builds the `dev` stage (`BUILD_TARGET=dev`), which has every dev dependency too, so a production-only dependency that is missing never shows there: `httpx` was dev-only while the start-up warmup imported it, and the production image could not start. See [No dependency lockfile](BACKEND_GAPS.md#no-dependency-lockfile-pin-before-production---logged).
- [ ] **Client IP: only Caddy is reachable, and the API knows it (2026-11-11, `api/app/core/client_ip.py`).** The admin IP allowlist, every rate limit, download evidence and the risk signals key on the client's address. The API reads `X-Forwarded-For` **only** when the connection comes from an address in `TRUSTED_PROXY_IPS`, and then from the right. Uvicorn runs with `--no-proxy-headers` (the image's CMD), so it never rewrites the address itself. Set up:
  - **Caddy is the only thing published.** Remove `ports: "8000:8000"` from `api` (and any port on `web`) in `deploy/compose.prod.yml`; Caddy reaches them on the compose network. Anything that can reach the API or web directly can claim any address.
  - **Caddyfile** (Caddy v2 replaces a client's own `X-Forwarded-For` unless that client is in Caddy's `trusted_proxies`; leave that unset while nothing sits in front of Caddy):

        api.<domain> {
            reverse_proxy api:8000
        }
        admin.<domain> {
            reverse_proxy web:3000
        }

  - **`TRUSTED_PROXY_IPS`** on the API: the compose network's subnet, which covers Caddy and the web server (the web admin's proxy, `web/app/api/admin/[...path]/route.ts`, passes the admin's address on). Find it with `docker network inspect <project>_default --format '{{(index .IPAM.Config 0).Subnet}}'`, for example `172.18.0.0/16`. Pin the subnet in the compose file so it does not change on recreate.
  - **`TRUSTED_PROXY_HOPS`**: `1` for Caddy alone. `2` if a CDN (for example Cloudflare) sits in front of Caddy, and then add the CDN's ranges to Caddy's `trusted_proxies` and to `TRUSTED_PROXY_IPS`.
  - **Check after deploy** (with `ADMIN_IP_ALLOWLIST` set to your address): an admin page opens from your address. From another network, `curl -s -H 'X-Forwarded-For: <your address>' -H 'Authorization: Bearer <an admin token>' https://api.<domain>/v1/admin/shelf/settings` must still answer 403 "Admin endpoint not allowed from this IP".
- [ ] **Error reporting: Sentry, EU region (2026-11-11, `api/app/core/sentry.py`, `web/lib/sentry/`).** Off unless a DSN is set; nothing is sent from dev or tests.
  - In Sentry, create the organisation **in the EU region** (data in Frankfurt; DSNs end in `.de.sentry.io`), sign its DPA, and make two projects: `rawwers-api` (Python) and `rawwers-web` (Next.js). Done 2026-11-13: the `rawwers` organisation is in the EU region and both projects exist; their DSNs are kept outside git.
  - API, `worker`, `worker-photos` and `beat`: `SENTRY_DSN=<rawwers-api DSN>`, `SENTRY_ENVIRONMENT=production` (or `staging`), `SENTRY_RELEASE=<git sha>`. `SENTRY_TRACES_SAMPLE_RATE` stays `0` (errors only).
  - Web: `SENTRY_DSN=<rawwers-web DSN>` at run time, and `NEXT_PUBLIC_SENTRY_DSN` (the same DSN) as a **build argument** of `web/Dockerfile`, because the browser's copy is inlined at build time. No auth token is needed: no source maps are uploaded.
  - Web source maps (decide in the deploy plan): they are off (`sourcemaps: { disable: true }` in `web/next.config.mjs`), so admin-panel stack traces are minified; turning them on needs a Sentry auth token (`SENTRY_AUTH_TOKEN`) at build time, created by the owner and never committed.
  - What is sent: unhandled API errors and failed Celery tasks, ERROR log lines (an outbox event given up, for example), email failures that are not retried, admin-panel errors and the admin API's 5xx. Every event is scrubbed: no IP, cookie or email address, no authorization header, token, code or password (`scrub_event`, tests in `api/tests/test_sentry.py`). Each event carries the request id (`request_id` tag; for an unhandled API error since 2026-11-13, `api/tests/test_error_responses.py`), and every API 500 carries it in the `X-Request-Id` header and the body and the component (`api`, `worker`, `beat`, `web`).
  - **Check after deploy:** on the server, `docker compose exec api python -c "from app.core.sentry import init_sentry, capture_message; init_sentry('api'); capture_message('deploy check'); import sentry_sdk; sentry_sdk.flush()"`, then see "deploy check" in the `rawwers-api` project.
  - Set alert rules in Sentry: e-mail the owner on every new issue, and on `email_failure:config`.
- [ ] **GBP at Stripe, before any GBP booking (UK first, 2026-11-13; `docs/MULTI_CURRENCY.md`, Stripe answers).** In the platform's Stripe account, enable **GBP as a settlement currency** and link a **GBP bank account** (in the UK or Gibraltar). Without it Stripe converts every GBP charge to EUR, and the platform carries the exchange-rate risk the design forbids. Check in the dashboard (Balances) that a GBP balance exists before `multi_currency_enabled` is switched on. Get Stripe's written confirmation that UK connected accounts are eligible for cross-border payouts on the **full** service agreement, and of the fee figures (international cards, multi-currency settlement, cross-border payouts). In a Portuguese-company setup this is required; in a UK-company setup the same applies to **EUR** (a EUR settlement account), only if EUR is switched on.
- [ ] **Build `api` and `worker` together** - `docker compose build api worker`. They are separate images from one Dockerfile; building only `api` leaves webhooks, outbox effects and photo processing on the old code with nothing failing. See [Rebuilding `api` does not rebuild `worker`](BACKEND_GAPS.md#rebuilding-api-does-not-rebuild-worker).
- [ ] **Use `deploy/compose.prod.yml` / `compose.staging.yml`**, never the `deploy/docker-compose.*` pair beside them: those are stale copies, and the prod one has no `beat` service. See [stale duplicates](BACKEND_GAPS.md#deploydocker-composeprodstagingyml-are-stale-duplicates---logged).
  **Open question:** `make deploy` in `api/` is a second path - it rsyncs `api/` to the server and runs `docker compose up -d --build` with `api/docker-compose.yml`, not either file above. Which one production actually uses needs confirming; until then, check the server's running services against this list rather than assuming.
- [ ] **Confirm `beat` and every queue's worker are running.** Without `beat` the outbox is never drained: no in-app notifications, no AI replies, no request expiry. `tests/test_queue_consumers.py` checks the compose files; this checks the running stack.
- [ ] **Migrations `20261012_0058`, `20261013_0059`, `20261013_0060` and `20261014_0061` are one-way in production.** Each has a `downgrade()`, but none carries its data back. It is for dev and tests only:
  - **0058**: dropping `presence_visible` makes every photographer who hid their online dot visible again the moment the old code runs. That breaks a privacy choice they made.
  - **0059**: dropping the override columns loses every admin tier override: tier, admin, time and reason. The code before 0059 would not keep them either, because its recompute undid overrides after the hysteresis window. So a rollback must not go back past 0059.

  - **0060** (down-tested 2026-10-13 on a copy of dev; every other column of the four tables it touches came back byte-identical): it loses who is switched on and their preparation time, the per-package short-notice flags, and each request's recorded terms. On re-upgrade, an unpaid short-notice booking's 30-minute pay deadline comes back as 24 hours, because the backfill is `created_at + 24h`. The time stays held for a day that the client was told was half an hour.

  - **0061** changes data on the way up, not only on a round trip. Preparation time moves from hours to minutes, rounded *up* to an allowed option, and the hours column is dropped. A photographer who chose **1 hour**, below the new 90-minute floor, now has **90 minutes**; one who chose **5 hours** now has **6**. Nobody is told, and fewer short-notice slots are offered for them until they change it. 2, 3, 4 and 6 hours are unchanged. Before migrating, count who moves:

        SELECT short_notice_prep_hours, count(*) FROM pro_scheduling_policy
        WHERE short_notice_prep_hours IN (1, 5) GROUP BY 1;

    Dev, 2026-10-14: none (all 11 policies were at the 2-hour default). The downgrade rounds up again (90 min becomes 2 h), so a round trip also lengthens 90-minute choices to 120.

  `20261014_0062` only adds an index; it reverses cleanly.
  `20261018_0063` only adds a unique partial index on `refund_case`; it reverses cleanly (up, down and up again tested 2026-10-18 on a copy of dev). It refuses to run while the duplicates query above returns rows.
  `20261019_0064` adds `stripe_payment.amount_refunded` and repairs the payments above (up, down and up tested 2026-10-19 on a copy of dev, with one such payment planted). Its downgrade drops the column and leaves the repaired statuses as they are, so a round trip loses the amount refunded on a repaired part-refunded payment: it reads 0 until Stripe's next charge.refunded for it.

  If a release containing them has to be rolled back, roll back the code and leave the schema at head - with one exception. 0058-0060 only add columns that are nullable or have a server default, so the older code runs against them. **0061 is the exception:** it drops `short_notice_prep_hours`, which code from before it reads, so taking the code back past 0061 needs `alembic downgrade 20261013_0060` as well. That costs only the 90-minute choices, which become 2 hours. One cost while it runs: its recompute ignores the override columns, so overridden tiers show the evidence tier until the new code is back. The overrides stay stored, and the first recompute after that restores them.
- [ ] **API before the pro app (Stage 1).** The pro app's Payouts screen requires `setup_state` in `GET /v1/pro/payouts/connect/status` (added with the one setup mapping, `stripe_connect.setup_from_account`). A pro app built from this branch against an older API cannot read the response and shows "Couldn't check your payout setup" for everyone. Deploy the API first; the pro app already in the store ignores the new field.
- [ ] **What counts as `active` changed (Stage 1).** A payout account is `active` - and Request payout appears - when Stripe reports `details_submitted` and `payouts_enabled`; `charges_enabled` no longer counts (owner's decision, 2026-10-28). No migration: an account Stripe pays out to but has not enabled charges on moves from `pending_verification` to `active` on its next `account.updated` or the next time its photographer opens Payouts. Before deploying, count the accounts that may move, so a jump in withdrawals is expected:

      SELECT count(*) FROM payout_account
      WHERE payout_method = 'stripe_connect' AND status = 'pending_verification'
        AND stripe_connect_account_id IS NOT NULL;

  Any of them may move; which ones only Stripe knows. Dev, 2026-10-28: pro1 was already `active` with charges enabled.
- [ ] **`alembic upgrade head`.** Migration `20261007_0056` also backfills the response-time label in SQL, so labels are right immediately.
  Migration `20261014_0061` moves each photographer's preparation time to minutes, rounded up to an option (1-6 hours: 90, 120, 180, 240, 360). `20261014_0062` builds a partial index on pending requests' deadlines for the every-minute sweep. It is a plain `CREATE INDEX`, which briefly blocks writes to `booking_request` while it builds; that table is small.
  Migration `20261013_0060` (Available now) adds columns only, with defaults that change nothing until a photographer switches it on: every existing package starts not bookable at short notice. It records a pay deadline on every gig still waiting for payment - when it was made plus 24 hours, the rule those gigs were made under - so no unpaid booking's terms move.

## 3. After deploying - data steps

- [ ] **Recompute every public index row** - after `0059`, which keeps admin tier overrides through it - `POST /v1/admin/index/pro/rebuild-all`, or `recompute_pro_public_index` over every `ProPublicIndex` row. **Once per environment** for each of:
  - `min_package_price` changed unit (per-photo rate to starting total). Until recomputed, the budget filter and price sort mix units. See [DEPLOY REQUIREMENT: recompute every `min_package_price`](BACKEND_GAPS.md#deploy-requirement-recompute-every-min_package_price-before-trusting-the-budget-filter).
  - `gigs_cancelled` and `disputes_count` count only the photographer's own cancellations and disputes with a recorded fault finding (2026-10-20). Until recomputed, client cancellations and every dispute still cost photographers points in `ranking_score`, the match score, the "high reliability" reason and their public profile counts. On dev the change raised three scores and reordered no row in any of the 4 cities (92 rows compared by name).
  - `is_accepting_bookings` is false while a photographer is banned or suspended (2026-10-23). Until recomputed, photographers banned before this release stay on Discover. This one **does** change `listed`: it drops by exactly the number of photographers banned, or suspended with an end not yet reached - count them first (`SELECT count(DISTINCT user_id) ...` on `ban_action`, latest row per user being `banned`, or `suspended` with `ends_at` null or in the future). A photographer whose suspension has ended is put back by the `relist-after-suspensions` beat task within 10 minutes.
  - `ranking_score` lost the response bonus. Until recomputed, photographers who once replied quickly keep up to 10 points they no longer earn. See [DEPLOY REQUIREMENT: recompute every `ranking_score`](BACKEND_GAPS.md#deploy-requirement-recompute-every-ranking_score-after-the-response-time-change).

  One run covers both, and it bumps the public index version so cached home and discover responses are dropped. The task logs `rebuild_all_pro_indexes` with `rows`, `listed` and `overrides_preserved`. Check two of them:
  - **`listed`**: the photographers clients can see, which a recompute should not change. Count them before the run with the query below; `listed` afterwards must be the same number, and a difference is a photographer who appeared or vanished. **`rows` is not a check.** It counts every profile, test accounts and unfinished ones included (dev, 2026-10-14: 159 rows, 42 listed).

        SELECT count(*)
        FROM pro_public_index i
        JOIN pro_onboarding o ON o.pro_user_id = i.pro_user_id AND o.status = 'approved_public'
        WHERE i.kyc_status = 'approved' AND i.is_accepting_bookings
          AND i.completeness_score >= 60 AND i.min_package_price IS NOT NULL;

  - **`overrides_preserved`**: the admin tier overrides still in force afterwards. It should equal the count of `override_tier IS NOT NULL` rows before the run.

  **A database that already ran migration `20261007_0056` needs this run regardless.** That migration's backfill was changed after it first ran (an expired request now counts as 24 hours and a minute whatever its own window was, and an even sample takes the higher middle value), and alembic will not run it again, so its `response_bucket` and `response_median_minutes` hold the old rule's answers until each row is recomputed. Dev ran the old version; a database migrating for the first time gets the new backfill and needs nothing extra for this.
- [ ] **Recompute niche skills** - after the release that drops the refund penalty from niche skill scores: `POST /v1/admin/jobs/recompute-niche-skills`, then the public index rebuild above so ranking picks up the new tiers. Until then, a photographer with a dispute settled by a refund in the last 90 days keeps up to 30 points less, and possibly a lower tier, than the formula now gives. Count who moves first:

        SELECT count(DISTINCT g.pro_user_id)
        FROM dispute d JOIN gig g ON g.id = d.gig_id
        WHERE d.status IN ('resolved_refund', 'resolved_partial_refund')
          AND d.updated_at >= now() - interval '90 days';

  Dev, 2026-10-19: 2. Migration `20261019_0065` (the photographer-fault table) only adds a table; it reverses cleanly (up, down and up tested on a copy of dev).
- [ ] **Chargebacks** - after the release that reconciles them (migration `20261021_0067` adds two columns to `money_attention_item`; it reverses cleanly). From then every `charge.dispute.*` event is reconciled from Stripe's dispute: the ledger gets the amount taken and Stripe's fee (EUR 20 in test mode, kept by Stripe even when won), a won chargeback puts the amount back and returns the booking to how it was, a lost one ends it as `refunded` with its finals revoked. Beta policy: the platform absorbs a lost chargeback (ledger plus a "Chargeback lost" item); the photographer's earnings are untouched unless an admin recorded a photographer-fault finding on the booking. Chargebacks opened before this release are picked up by the next event Stripe sends about them; one that is already closed sends none - list them in the Stripe dashboard (Payments, Disputes) and check each booking by hand.
- [ ] **Price reductions after payment** - after the release that refunds them (migration `20261023_0070` adds `price_reduction`, `price_reduction_reason` seeded with the five reason codes, and `delivery_review_policy` seeded with a 1-photo shortfall; it reverses cleanly). From then a client who chooses fewer photos than they paid for is refunded the difference automatically, split by reason (photos not delivered / client chose fewer), and a booking whose gallery held fewer photos than were included is flagged "Fewer photos delivered than included" on "Money to act on" for an admin to review - a flag, never a finding. Reason wording and the shortfall threshold are edited at `GET/PUT /v1/admin/price-reduction-reasons` and `/v1/admin/policies/delivery-review`; check both read as intended before real clients see the wording. Bookings whose selection was cheaper than the deposit **before** this release were never refunded: the "client owed" check (next item) lists them.
- [ ] **Delivery uploads** - after the release with the delivery bucket (migration `20261029_0074` adds `media_asset.delivery_gallery_id` and a partial unique index on (gallery, SHA-256) for live photos; up, down and up tested 2026-10-31 on a copy of dev, all 899 photo rows identical after each). Nothing existing changes: older photos have neither value. Proofs now count against `RATE_LIMIT_DELIVERY_UPLOADS_PER_HOUR` (default 2000 an hour per photographer) instead of the 30 an hour every other upload keeps (`RATE_LIMIT_UPLOADS_PER_HOUR`); set it only to change that default.
  Delivered proofs may now be up to 50 MB (`DELIVERY_MAX_UPLOAD_BYTES`; every other photo keeps `MAX_UPLOAD_BYTES`, 25 MB). **The photo worker needs a server with at least 4 GB of memory free for it** (owner's decision 9). A 60 MP JPEG took about 7 s and 760 MB at peak (measured 2026-10-31), whatever its file size, and the worker runs `PHOTO_WORKER_CONCURRENCY` jobs at once (default 4). Plan 1 GB per parallel job - the peak plus the worker process itself:

  | Memory free for the photo worker | `PHOTO_WORKER_CONCURRENCY` |
  |---|---|
  | 4 GB (the minimum) | 4 (the default) |
  | 6 GB | 6 |
  | 8 GB | 8 |

  Never more than the server's CPU cores either: each job keeps one core busy for its 7 s, so jobs beyond the core count only queue inside the worker while holding memory. With less than 4 GB free, lower `PHOTO_WORKER_CONCURRENCY` to the GB available (2 GB: 2) rather than risk the worker being killed mid-delivery; photos then wait in the queue, nothing is lost. Check on the server with `free -g` before the release, and `docker stats` during the first large delivery. No compose file sets a memory limit today.
- [ ] **Lightroom pairing** - after the release with delivery tokens (migration `20261031_0075` adds `delivery_pairing_code` and `delivery_token`, new tables only; up, down and up tested 2026-10-31 on a copy of dev, together with `0074`). **The API ships before the pro app's Connect Lightroom screen**, which calls `/v1/pro/lightroom/*`. Settings: `LIGHTROOM_PLUGIN_LATEST_VERSION` (default `1.0.0`; raise it with each plugin release so older plugins are told to update) and `RATE_LIMIT_DELIVERY_TOKEN_UPLOADS_PER_DAY` (default 5000 per paired device). Pairing is limited per address through `X-Forwarded-For`, which the client can set (see [The client's IP is whatever `X-Forwarded-For` says](BACKEND_GAPS.md#the-clients-ip-is-whatever-x-forwarded-for-says---logged)); the overall limit on code attempts does not depend on it.
- [ ] **Lightroom plug-in release** - build on the Mac, from the repo root: `RAWWERS_LIGHTROOM_API_URL_PRODUCTION=<the production API address> lightroom/build.sh --version X.Y.Z --target production`, or put that one line in `lightroom/build.env` (gitignored; the environment wins over it). The production address is not written anywhere in the repository, on purpose: the build refuses to run without it, and refuses http, this Mac and the local network. `--target dev` uses the dev plug-in's address (`http://localhost:8000`) or `RAWWERS_LIGHTROOM_API_URL_DEV`, and its zip is named `-dev` so the two are never confused. The build writes `lightroom/build/rawwers-lightroom-X.Y.Z.zip`; `lightroom/tests/test_build.sh` checks the script. Then set `LIGHTROOM_PLUGIN_LATEST_VERSION` on the API to X.Y.Z - on **every** released build, so older plug-ins are told an update is available. Raise `LIGHTROOM_PLUGIN_MIN_VERSION` (default `1.0.0`) **only** for a breaking change, and only once the new plug-in is downloadable: a plug-in below it is refused (426, "too old: version … or newer is needed", pointing to Settings > Connect Lightroom) on pairing and on every delivery call, without disconnecting the Mac, so updating is all it takes. The minimum is never applied above the latest version, so a typo cannot lock out the newest plug-in. Once the zip is hosted (with the deploy plan), set `LIGHTROOM_PLUGIN_DOWNLOAD_URL` to its https address: the pro app's Connect Lightroom screen shows its Download button only then (an http or empty value hides it), with the version from `LIGHTROOM_PLUGIN_LATEST_VERSION`, so the two change together.
- [ ] **Meet the photographer** - after the release with the interview (migration `20261023_0073` adds `interview_question` and `pro_interview_answer`; it reverses cleanly and changes nothing existing). The five questions, from the intro-video guide, are written the first time anyone opens them; read them at `/admin/interview-questions` before photographers do - the prompt is what they are asked, the title what clients read, and the lengths are enforced when they publish. Leave `PRESENTATION_VIDEO_ENABLED` unset (off): nothing produces a video yet, and the profile's video slot stays empty until the video work lands. Nothing here gates onboarding or feeds ranking.
- [ ] **Niche banners** - after the release with banners (migration `20261023_0072` adds `niche.banner_style` - `image` for every niche, which is what each was - `banner_tagline`, `banner_tagline_key` and the `niche_banner` table; it reverses cleanly and creates no banner). From this release a niche's banner is data: no niche has an image until one is loaded, so Discover's niche tiles show the plain ground instead of the top photographer's cover until then. Load them right after the release, through the admin upload service, not by hand: `docker compose run --rm -v <folder>:/nb api python scripts/load_niche_banners.py /nb/picks.json /nb/candidates.json --admin-email <admin>` (dry run first, then `--apply`), with the picks agreed from the contact sheet. Then open `/admin/niches`: nothing should say "Image missing" except a niche left on purpose. The admin page's own uploads also need the bucket's CORS rule (section 4).
- [ ] **Photographer accountability for non-delivery** - after the release with findings (migration `20261023_0071` adds `accountability_policy` seeded with the agreed defaults, `photographer_finding` and `booking_pause`; it reverses cleanly). Nothing existing becomes a finding: earlier fault records are not strikes. Before real photographers see it:
  1. Read the policy at `/admin/accountability` (7 days to respond, 14 days before the window starts if unseen, 12-month rolling window, pause at the second strike, suspension review at the third) and the reason wording at `GET /v1/admin/price-reduction-reasons`; both are what photographers read.
  2. Check the `apply-due-findings` beat task runs (every 15 minutes): a confirmed finding takes effect only through it once the window has ended.
  A booking pause takes the photographer off Discover and stops new bookings (their existing bookings are listed on "Money to act on"); only an admin lifts it, from their page. Email of the finding notice goes out through the same notification as the in-app one once email is delivered (section 5).
- [ ] **Payout requests leave Available when made** - after the release with the Requested bucket (no migration). A payout request now moves its amount out of Available into Requested at once; rejecting it puts it back, approving moves it to Reserved. A second request can only ask for what is still available. Requests already open when the release lands are counted the same way from then on, so a photographer with an open request sees Available drop by it. Before releasing, list open requests (`GET /v1/admin/payouts?status=requested`) and check each still fits: one that does not shows that photographer's real `available_eur` below zero on the admin finance views - decide it (approve what fits, reject the rest) rather than leave it.
- [ ] **Clients owed money, found** - after the release with the "client owed" check (no migration). An hourly beat task (`raise-clients-owed`) puts every booking whose client has kept more than its price, with no refund covering the difference, on "Money to act on" as "Client owed", oldest first. Run it once by hand right after the release rather than wait the hour: `docker compose run --rm api python -c "from app.db.session import SessionLocal; from app.services.client_owed import raise_clients_owed; db=SessionLocal(); print(raise_clients_owed(db)); db.commit()"`. In dev on 2026-10-22 it would list one booking, `605304bd` (EUR 27.31). Each item is closed with a note saying what was done.
  Repairing one such booking is a single price reduction, which refunds the client, lowers the photographer's earnings and RAWW, and stamps the final split in one step. The script must load every model first (`import app.db.base`): without it the run stops with `NoReferencedTableError` before writing anything. Pro1's booking `605304bd` (dev, Stripe test mode, done 2026-10-23: refund EUR 27.31, earnings 63.79 to 41.95), with the reason split and the delivered count taken from the booking:
  ```
  docker compose run --rm -T api python -c "
  import app.db.base  # every model registered
  import uuid; from decimal import Decimal as D
  from app.db.session import SessionLocal; from app.models.gig import Gig
  from app.services.price_reduction import ReductionLine, apply_price_reduction, flag_short_delivery
  db=SessionLocal(); g=db.get(Gig, uuid.UUID('605304bd-bb7b-4ec3-8ef3-b1d0614f96dc'))
  r=apply_price_reduction(db, g, new_final=D('52.43'), from_amount=D('79.74'), lines=[ReductionLine('photographer_non_delivery', D('15.96')), ReductionLine('client_selected_fewer', D('11.35'))], note='Repair: 11 chosen, 14 of 20 delivered, never refunded', source='selection', key='repair:605304bd', actor_user_id=None)
  flag_short_delivery(db, g, delivered=14, included=20, amount=D('15.96')); print('refund', r.refund_amount, 'reduction', r.id); db.commit()"
  ```
  The key makes a second run a no-op. Afterwards check the Stripe refund, the photographer's balance (`GET /v1/pro/earnings/balance`) and that "Money to act on" holds only the short-delivery item.
- [ ] **Photographer earnings recomputed** - after the release with one money source (migration `20261023_0069` adds the stamped final split to `gig`; it only adds columns and reverses cleanly). Earnings used to be 80% of the sum of a booking's payments; they are now its final price net of refunds, split by the invoice method (15% and 5% rounded separately). Bookings completed before the release keep their old entry until recomputed:
  1. Dry run: `docker compose run --rm api python scripts/recompute_earnings.py` - lists every booking whose earnings change (old net, new net) and writes nothing. In dev on 2026-10-22 that was pro1's booking `605304bd` (63.79 to 41.95) and a few cents on four seeded photographers.
  2. Before applying, check `GET /v1/admin/payouts` and `paid_out_eur` for each photographer listed: where a recomputed booking's earnings were already paid out, their balance goes negative and the Wallet shows "Adjustment owed". That is the honest state, not an error.
  3. `... scripts/recompute_earnings.py --apply`.
  The Wallet's "Reserved" no longer includes payouts already paid: those are now "Paid out". Admin finance views show the real `available_eur`, which can be negative; photographers see `withdrawable_eur` (never below 0) and the adjustment owed.
- [ ] **Clients' raw IP on their downloads** - after the release that keeps it (migration `20261022_0068` adds `media_access_log.ip_address`; it only adds a column and reverses cleanly). From then a download or view by the booking's own client stores their IP next to the hash, for chargeback evidence (Stripe asks for the customer's IP; a hash cannot be given to it). Nobody else's raw IP is stored. Rows from before the release have none: their IP was never kept, so a chargeback on an older booking has the hash only. The daily `purge_raw_access_ips` job (on `beat`) clears it after the retention period, except on a booking whose chargeback evidence is still due. Check that the privacy notice says this before the release reaches real clients (section 5).
- [ ] **Refunds made outside RAWWERS and clients owed** - after the release with refund reconciliation (migration `20261020_0066` adds its table; it only adds a table and reverses cleanly). Reconciling adopts every refund Stripe has that our routes did not make, and raises a "client owed" item for every refund that failed. Look at `GET /v1/admin/money-attention` after the first day: each item needs a person - check an adopted refund was intended; pay back a client owed (then `POST /v1/admin/money-attention/{id}/resolve` with what was done).
- [ ] **Watermark backfill** (**once**, existing objects only): `scripts/backfill_watermark_previews.py`, dry run first. Done locally; see [The watermark fix is now actually in the bucket](BACKEND_GAPS.md#the-watermark-fix-is-now-actually-in-the-bucket-resolved).
- [ ] **Business dashboard** (migration `20261109_0092`: tables `bi_daily`, `bi_cost`, `bi_company_cash`, `bi_stripe_txn`, `bi_stripe_sync_day` and the read-only `bi_*` views; new objects only, reverses cleanly). Then fill it once: `docker compose run --rm api python scripts/bi_backfill.py --from <first booking date> --stripe` (mirrors Stripe's balance transactions and recomputes `bi_daily`). From then `beat` runs `bi-hourly` at half past every hour: Stripe's last three days, then `bi_daily` for them. Check `/admin/bi`: the reconciliation card should match Stripe, and any difference is a day to look at. Enter the company's bank balances and the month's costs under *Costs & company cash*. See [BI.md](BI.md).
- [ ] **Business dashboard records what it estimated** (migration `20261110_0093`, high-risk: adds `ledger_entry.stripe_payment_id`, `gig.pro_tier`/`pro_tier_estimated`, Shelf order cost and shipping columns; backfills them, marking backfilled values estimated; recreates the `bi_*` views; empties `bi_daily`). Downgrade drops the columns and restores the 0092 views. After it, run the backfill again (`scripts/bi_backfill.py --from <first booking date> --stripe`) so `bi_daily` is refilled; until then days are computed live. Then enter the shipping cost of shipped Shelf orders under *Shelf orders*.
- [ ] **Business dashboard: old add-on refunds, Shelf shipping per order** (migration `20261110_0094`, high-risk: recreates the `bi_*` views, adds `bi_daily.refund_date_estimated_cents`, empties `bi_daily`; no other data changes; up, down and up tested 2026-11-10 on a copy of dev). Downgrade drops the column and restores the 0093 views. Run it together with 0093, then the backfill once (as above) for both. Shelf shipping is now entered only per order: the `shelf_shipping` cost category is refused for new costs; old rows show "legacy" and still count, and orders shipped on or before the last one take their shipping from it (enter shipping only for orders the page asks for). `/v1/admin/bi/*` has its own rate limit, `RATE_LIMIT_ADMIN_BI_PER_MIN` (default 240 a minute); the other admin routes keep `RATE_LIMIT_ADMIN_PER_MIN` (60). Set either only to change those defaults.
- [ ] **Multi-currency M1: the photographer's money carries its currency** (migration `20261113_0095`, **high-risk: money**; up, down and up tested 2026-11-13 on a copy of dev). It adds `currency_settings` (empty: the code's defaults apply, **GBP only**, minimums GBP 45.00 and EUR 50.00), `pro_profile.currency` (backfilled from the photographer's packages, else their country, else EUR) and `currency` on the earnings ledger, balance snapshot, holds, payout requests and allocations (backfilled EUR); renames their `_eur` columns (`gross`, `platform_fee`, `net`, `pro_raww`, `pending`, `available`, `held`, `amount`); drops the `'EUR'` server default from `pro_package`, `gig` and `dispute`; recreates the `bi_*` views. Downgrade refuses while any of those rows is not EUR. **The API's payout fields change name** (`withdrawable_eur` becomes `withdrawable` beside `currency`, and so on): deploy it with the app and web admin of the same commit; no app has been distributed. After it, a EUR photographer can still be paid and booked, but **new EUR packages and EUR payout accounts are refused until an admin enables EUR**: `PUT /v1/admin/finance/currency-settings` with `{"enabled_currencies": ["GBP", "EUR"], "payout_minimums": {"GBP": "45.00", "EUR": "50.00"}}`. `DEFAULT_CURRENCY` (default `GBP`) is the currency of a photographer whose country gives none.
- [ ] **Multi-currency M2: every money value carries its currency** (no migration; high-risk: the API contract). More response fields are renamed (the client's payment `credit`/`amount`, the credit balance, history, preview and marketing budget, the marketing consent `credit_amount`) and many gain `currency`; the balance gains `payout_minimum`. Deploy the API, both apps and the web admin of the same commit together; no app has been distributed. Client credit (euros) is no longer offered on a booking in pounds.
