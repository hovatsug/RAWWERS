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
- [ ] **`alembic upgrade head`.** Migration `20261007_0056` also backfills the response-time label in SQL, so labels are right immediately.
  Migration `20261014_0061` moves each photographer's preparation time to minutes, rounded up to an option (1-6 hours: 90, 120, 180, 240, 360). `20261014_0062` builds a partial index on pending requests' deadlines for the every-minute sweep. It is a plain `CREATE INDEX`, which briefly blocks writes to `booking_request` while it builds; that table is small.
  Migration `20261013_0060` (Available now) adds columns only, with defaults that change nothing until a photographer switches it on: every existing package starts not bookable at short notice. It records a pay deadline on every gig still waiting for payment - when it was made plus 24 hours, the rule those gigs were made under - so no unpaid booking's terms move.

## 3. After deploying - data steps

- [ ] **Recompute every public index row** - after `0059`, which keeps admin tier overrides through it - `POST /v1/admin/index/pro/rebuild-all`, or `recompute_pro_public_index` over every `ProPublicIndex` row. **Once per environment** for each of:
  - `min_package_price` changed unit (per-photo rate to starting total). Until recomputed, the budget filter and price sort mix units. See [DEPLOY REQUIREMENT: recompute every `min_package_price`](BACKEND_GAPS.md#deploy-requirement-recompute-every-min_package_price-before-trusting-the-budget-filter).
  - `gigs_cancelled` and `disputes_count` count only the photographer's own cancellations and disputes with a recorded fault finding (2026-10-20). Until recomputed, client cancellations and every dispute still cost photographers points in `ranking_score`, the match score, the "high reliability" reason and their public profile counts. On dev the change raised three scores and reordered no row in any of the 4 cities (92 rows compared by name).
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
- [ ] **Refunds made outside RAWWERS and clients owed** - after the release with refund reconciliation (migration `20261020_0066` adds its table; it only adds a table and reverses cleanly). Reconciling adopts every refund Stripe has that our routes did not make, and raises a "client owed" item for every refund that failed. Look at `GET /v1/admin/money-attention` after the first day: each item needs a person - check an adopted refund was intended; pay back a client owed (then `POST /v1/admin/money-attention/{id}/resolve` with what was done).
- [ ] **Watermark backfill** (**once**, existing objects only): `scripts/backfill_watermark_previews.py`, dry run first. Done locally; see [The watermark fix is now actually in the bucket](BACKEND_GAPS.md#the-watermark-fix-is-now-actually-in-the-bucket-resolved).
- [ ] **Release gate** - `python3 deploy/release_gate.py --env <staging|production>` ([release_engineering.md](release_engineering.md)).

## 4. Configuration outside the code

- [ ] **Stripe webhook endpoints, registered and pinned** - once per mode (test for staging and dev, live for production), and again whenever `HANDLED_STRIPE_EVENTS` in `app/api/v1/webhooks.py` changes. Nothing reaches the webhook until this is done: on 2026-10-20 the test account had no endpoint at all. Two endpoints on the same URL, both pinned to `STRIPE_API_VERSION` (`2025-12-15.clover`, a constant in `app/core/config.py`), so events arrive in the version our calls use and the fixtures were captured in:
  - **platform**: `payment_intent.succeeded`, `payment_intent.payment_failed`, `payment_intent.canceled`, `charge.refunded`, `charge.refund.updated`, `refund.created`, `refund.updated`, `refund.failed`, `charge.dispute.created`, `transfer.created`, `transfer.reversed`;
  - **connect** (events from photographers' connected accounts): `account.updated`.

  Run, with the mode's secret key, first without `--apply` to see what it would do:

      docker compose run --rm api python scripts/register_stripe_webhook.py --url https://<api host>/v1/webhooks/stripe --mode test --apply
      docker compose run --rm api python scripts/register_stripe_webhook.py --url https://api.rawwers.com/v1/webhooks/stripe --mode live --apply

  Each new endpoint prints its signing secret once. Put **both** in `STRIPE_WEBHOOK_SECRET`, comma-separated (`whsec_platform,whsec_connect`): with only one, every event of the other endpoint is refused as unsigned. Stripe sets an endpoint's API version only when it is created - the script reports an endpoint pinned to another version; delete that one in the dashboard and run again. After deploying, the API log must show no `stripe_event_api_version_mismatch`.
- [ ] **Dev: `stripe listen`** instead of an endpoint - the dev stack has no public URL. With the Stripe CLI and the test key:

      stripe listen --api-key "$STRIPE_SECRET_KEY" --events payment_intent.succeeded,payment_intent.payment_failed,payment_intent.canceled,charge.refunded,charge.refund.updated,refund.created,refund.updated,refund.failed,charge.dispute.created,transfer.created,transfer.reversed,account.updated --forward-to localhost:8000/v1/webhooks/stripe --forward-connect-to localhost:8000/v1/webhooks/stripe

  It prints a `whsec_...` signing secret: put it in dev's `STRIPE_WEBHOOK_SECRET`. `stripe listen` delivers in the account's default API version - `2025-12-15.clover`, the pinned one, on 2026-10-21. If the account's default is ever upgraded, dev starts logging `stripe_event_api_version_mismatch`: that is the moment to move `STRIPE_API_VERSION` and recapture the fixtures, not to ignore it.
- [ ] **`STRIPE_API_VERSION`** - leave unset (the constant in `app/core/config.py`) or `2025-12-15.clover`. Any other value makes our calls disagree with the pinned endpoints and the tested fixtures.
- [ ] **`REFUND_RECONCILE_INTERVAL_SECONDS`** (900) - how often refund cases still in flight 15 minutes after their last change are fetched from Stripe (`app.tasks.scheduled.reconcile_stuck_refunds`, on `beat`).

- [ ] **`AUTH_DEV_BYPASS` is false** in production ([api/README.md](../api/README.md)).
- [ ] **Stripe: delayed-notification payment methods stay disabled** in the dashboard (Multibanco, SEPA debit, bank redirects). Turning any on arms unhandled paths with no deploy. See [Delayed-notification payment methods](BACKEND_GAPS.md#delayed-notification-payment-methods-are-not-handled-mitigated-for-launch-by-stripe-dashboard-config).
- [ ] **Stripe: the live payment-method configuration is cards and wallets only** (Card, Apple Pay, Google Pay; Link if wanted) - in the live dashboard under Settings → Payment methods, the configuration the account uses by default. Every PaymentIntent is created with `allow_redirects: "never"` (`PAYMENT_METHODS` in `app/services/stripe_service.py`; a test fails on any creation path without it), so a redirect method switched on there is silently never offered - but the dashboard should say the same as the code, so nobody turns one on expecting it to work. The app has no `returnURL` or iOS URL scheme yet; until it does, no iDEAL, Bancontact, Multibanco or other bank-redirect method.
- [ ] **Available now settings** - defaults are the agreed values; set them only to change one: `AVAILABLE_NOW_FRESH_SECONDS` (120 - how recently the app must have checked in), `AVAILABLE_NOW_HOURS` (4 - when it switches itself off), `SHORT_NOTICE_ACCEPT_MINUTES` (30), `SHORT_NOTICE_PAY_MINUTES` (30), `PAY_DEADLINE_MARGIN_MINUTES` (30 - payment closes at least this long before the shoot), `PAYMENT_WINDOW_HOURS` (24 - the ordinary pay window, formerly a constant), `BOOKING_REQUEST_EXPIRY_SWEEP_INTERVAL_SECONDS` (60 - both the request-expiry and the unpaid-booking sweep; a run that overlaps the previous one skips). The preparation-time options (1.5, 2, 3, 4, 6 hours) are not a setting: 90 minutes is the floor that leaves time to accept, pay and keep the margin, and a test holds it.
- [ ] **Self-service refunds are off** outside `APP_ENV` development, dev, local and test: the client's refund route answers 403 `self_service_refunds_off` and asks Stripe for nothing. Refunds go through support (the admin refund) until the platform cancellation standard replaces this. Nothing to set; check that `APP_ENV` is `production` or `staging`, not a development value.
- [ ] **Startup warm-up** (`app/services/warmup.py`) runs before the API takes traffic, bounded at 10 seconds and never stopping startup. `STARTUP_WARMUP` (true) turns it off; `WARMUP_HOME_COUNTRY` / `WARMUP_HOME_CITY` (PT / Lisbon) name the launched city whose home it requests - set them to a city the environment has enabled, or the request is refused at the city gate and warms less. After a deploy, the `startup_warmup` log line shows each step: every one should be `ok` (`replica_db` may be `not configured`) and `home` should be `http 200`.
- [ ] **R2 lifecycle rule** expiring incomplete multipart uploads (**once** per bucket; not yet configured). See [Upload resume survives a dropped connection, not a killed app](BACKEND_GAPS.md#upload-resume-survives-a-dropped-connection-not-a-killed-app---logged).

## 5. Not deploy steps - they block a launch to real clients

Listed so a successful deploy is not mistaken for launch readiness.

- **No email is delivered and push does not exist.** A photographer is never told a request arrived. See [LAUNCH BLOCKER: no email is ever delivered](BACKEND_GAPS.md#launch-blocker-no-email-is-ever-delivered-and-push-does-not-exist). "Available now" also waits on this.
- **Price caps** - see section 1; enforcement is inert until the rows exist ([LAUNCH BLOCKER: the tier price cap enforces nothing](BACKEND_GAPS.md#launch-blocker-the-tier-price-cap-enforces-nothing--zero-rows)).
- **Cancellation and no-show terms for short-notice bookings** - an open product decision.
- **Nobody is told a chargeback's evidence is due.** A chargeback is lost by default if no evidence reaches Stripe by its deadline (`evidence_details.due_by`; in test mode about 3 weeks). Reconciliation raises a "Chargeback: evidence due" item with the deadline, and the admin page "Money to act on" sorts it first - but only someone who opens that page sees it: no email or message goes out (no email is delivered at all yet, see above). Before real clients: an alert to ops when a chargeback opens, and again a few days before its deadline, through whatever channel exists by then.
- **Presence on a physical iPhone, never yet checked.** With the pro app on a real phone (Developer Mode on, paired in Xcode, signed with a team, `env/pro.json` pointing at an address the phone can reach), and the client app or `GET /v1/client/pros/<id>` watching that photographer:
  1. Open the pro app: the dot appears within a few seconds.
  2. Send it to the background (home gesture): the dot goes at once.
  3. Reopen, then force-quit it (swipe it away): the dot is gone within 5 minutes. Record the times.
  4. Reopen, then turn on airplane mode with the app open: the dot is gone within 5 minutes. Record the times.
  5. Lock the phone with the app open for 10 minutes: the dot is gone within 5 minutes of locking.

  Simulators covered steps 1-3; steps 3-5 on a phone are what the five-minute expiry exists for. See BACKEND_GAPS.md, "iOS suspension unverified on a physical device".

## 6. Blocks beta - money and access routes no test calls

From listing every route and searching the tests for a call to each (2026-10-14: 205 of 458 routes called, 231 never). These are the money and access routes among the 231, most dangerous first. Each needs a test - the route's own rule, and who may call it - before beta users can reach it. Where a feature is off for beta, its routes can wait until it is turned on; say so here instead of deleting the line.

1. ~~**Refunds**~~ - tested since 2026-10-14 (`test_refund_routes.py`), with the caps, the one-in-flight rule and self-service off outside dev since 2026-10-18.
2. ~~**Payouts**~~ - request, approve, mark-paid and reject tested since 2026-10-14 (`test_payout_routes.py`).
3. **Where payouts go** - `POST /v1/pro/payouts/connect/account`, `/connect/onboarding-link`, `GET /connect/status`, `GET`/`PUT /v1/pro/payouts/account`. Whose account receives the money.
4. **Charges outside bookings** - `POST /v1/prints/orders/{order_id}/pay`, `POST /v1/gigs/{gig_id}/prints/orders`, `PUT /v1/prints/orders/{order_id}`. Charge a card.
5. **Earnings holds** - `POST /v1/admin/holds/create`, `POST /v1/admin/holds/{hold_id}/release`. Decide when a photographer's money becomes payable.
6. ~~**Roles and bans**~~ - roles, ban and impersonation start/end tested (`test_access_routes.py`, `test_ban_enforcement.py`). An ended impersonation's token now stops working at once.
7. **Disputes** - `POST /v1/disputes/{id}/cancel`, `/evidence`. Decide who can withdraw a dispute and add to it. (`/set-status` and `/status` are tested since 2026-10-19: admin only, audited, and a refund outcome only through `/resolve`.)
8. **What everyone pays** - `PUT /v1/admin/finance/fee-policy`, `PUT /v1/admin/learn/fee-policy`, `PUT /v1/admin/raww/multiplier-policy`, `PUT /v1/admin/pricing/extra-image-policies`, `POST`/`PUT /v1/admin/store/price-rules`. One request changes the platform's take or prices for everyone.
9. ~~**Private media**~~ - `POST /v1/media/videos/{media_asset_id}/playback-token` tested: the owner only, this video's playback id only, and not for a banned account.
10. ~~**Becoming a photographer**~~ - `POST /v1/me/upgrade-to-pro` tested: signed in, not banned, once.
11. **Money and tax records** - `GET /v1/pro/earnings/balance`, `/ledger`, `/summary`, `/invoices`, `/invoices/{gig_id}`, `GET`/`PUT /v1/pro/tax-profile`, `GET /v1/admin/finance/pros`, `/pros/{pro_user_id}`. Read-only for money, but each must show one person's records to that person (and admins) only. The tax profile holds identity data.
12. **Contact and verification** - `PUT /v1/me/contact`, `POST /v1/auth/verify-email/request`. Where account messages go.

## Done per environment

| Item | dev | staging | production |
|---|---|---|---|
| Recompute index (`min_package_price`) | done | | |
| Recompute index (`ranking_score`, and `0056`'s labels under the current rule) | done 2026-10-12 - the later 24h-and-a-minute change gives the same answers there, every dev request having a 24-hour window | | |
| Watermark backfill | done | | |
| Camera reference loaded | 98 cameras | | |
| Price cap row for every active niche and tier | 40 of 60 - none for architecture, automotive, maternity, sports | | |
| R2 multipart lifecycle rule | | | |
