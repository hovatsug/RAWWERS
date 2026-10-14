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

## 2. Deploying

- [ ] **Build `api` and `worker` together** - `docker compose build api worker`. They are separate images from one Dockerfile; building only `api` leaves webhooks, outbox effects and photo processing on the old code with nothing failing. See [Rebuilding `api` does not rebuild `worker`](BACKEND_GAPS.md#rebuilding-api-does-not-rebuild-worker).
- [ ] **Use `deploy/compose.prod.yml` / `compose.staging.yml`**, never the `deploy/docker-compose.*` pair beside them: those are stale copies, and the prod one has no `beat` service. See [stale duplicates](BACKEND_GAPS.md#deploydocker-composeprodstagingyml-are-stale-duplicates---logged).
  **Open question:** `make deploy` in `api/` is a second path - it rsyncs `api/` to the server and runs `docker compose up -d --build` with `api/docker-compose.yml`, not either file above. Which one production actually uses needs confirming; until then, check the server's running services against this list rather than assuming.
- [ ] **Confirm `beat` and every queue's worker are running.** Without `beat` the outbox is never drained: no in-app notifications, no AI replies, no request expiry. `tests/test_queue_consumers.py` checks the compose files; this checks the running stack.
- [ ] **Migrations `20261012_0058`, `20261013_0059` and `20261013_0060` are one-way in production.** Each has a `downgrade()`, but neither carries its data back. It is for dev and tests only:
  - **0058**: dropping `presence_visible` makes every photographer who hid their online dot visible again the moment the old code runs. That breaks a privacy choice they made.
  - **0059**: dropping the override columns loses every admin tier override: tier, admin, time and reason. The code before 0059 would not keep them either, because its recompute undid overrides after the hysteresis window. So a rollback must not go back past 0059.

  - **0060** (down-tested 2026-10-13 on a copy of dev; every other column of the four tables it touches came back byte-identical): it loses who is switched on and their preparation time, the per-package short-notice flags, and each request's recorded terms. On re-upgrade, an unpaid short-notice booking's 30-minute pay deadline comes back as 24 hours, because the backfill is `created_at + 24h`. The time stays held for a day that the client was told was half an hour.

  If a release containing them has to be rolled back, roll back the code and leave the schema at head. Both migrations only add columns that are nullable or have a server default, so the older code runs against them. One cost while it runs: its recompute ignores the override columns, so overridden tiers show the evidence tier until the new code is back. The overrides stay stored, and the first recompute after that restores them.
- [ ] **`alembic upgrade head`.** Migration `20261007_0056` also backfills the response-time label in SQL, so labels are right immediately.
  Migration `20261013_0060` (Available now) adds columns only, with defaults that change nothing until a photographer switches it on: every existing package starts not bookable at short notice. It records a pay deadline on every gig still waiting for payment - when it was made plus 24 hours, the rule those gigs were made under - so no unpaid booking's terms move.

## 3. After deploying - data steps

- [ ] **Recompute every public index row** - after `0059`, which keeps admin tier overrides through it - `POST /v1/admin/index/pro/rebuild-all`, or `recompute_pro_public_index` over every `ProPublicIndex` row. **Once per environment** for each of:
  - `min_package_price` changed unit (per-photo rate to starting total). Until recomputed, the budget filter and price sort mix units. See [DEPLOY REQUIREMENT: recompute every `min_package_price`](BACKEND_GAPS.md#deploy-requirement-recompute-every-min_package_price-before-trusting-the-budget-filter).
  - `ranking_score` lost the response bonus. Until recomputed, photographers who once replied quickly keep up to 10 points they no longer earn. See [DEPLOY REQUIREMENT: recompute every `ranking_score`](BACKEND_GAPS.md#deploy-requirement-recompute-every-ranking_score-after-the-response-time-change).

  One run covers both, and it bumps the public index version so cached home and discover responses are dropped. The task logs `rebuild_all_pro_indexes` with `rows` and `overrides_preserved` - the admin tier overrides still in force afterwards; it should equal the count of `override_tier IS NOT NULL` rows before the run.

  **A database that already ran migration `20261007_0056` needs this run regardless.** That migration's backfill was changed after it first ran (an expired request now counts as 24 hours and a minute whatever its own window was, and an even sample takes the higher middle value), and alembic will not run it again, so its `response_bucket` and `response_median_minutes` hold the old rule's answers until each row is recomputed. Dev ran the old version; a database migrating for the first time gets the new backfill and needs nothing extra for this.
- [ ] **Watermark backfill** (**once**, existing objects only): `scripts/backfill_watermark_previews.py`, dry run first. Done locally; see [The watermark fix is now actually in the bucket](BACKEND_GAPS.md#the-watermark-fix-is-now-actually-in-the-bucket-resolved).
- [ ] **Release gate** - `python3 deploy/release_gate.py --env <staging|production>` ([release_engineering.md](release_engineering.md)).

## 4. Configuration outside the code

- [ ] **`AUTH_DEV_BYPASS` is false** in production ([api/README.md](../api/README.md)).
- [ ] **Stripe: delayed-notification payment methods stay disabled** in the dashboard (Multibanco, SEPA debit, bank redirects). Turning any on arms unhandled paths with no deploy. See [Delayed-notification payment methods](BACKEND_GAPS.md#delayed-notification-payment-methods-are-not-handled-mitigated-for-launch-by-stripe-dashboard-config).
- [ ] **Available now settings** - defaults are the agreed values; set them only to change one: `AVAILABLE_NOW_FRESH_SECONDS` (120 - how recently the app must have checked in), `AVAILABLE_NOW_HOURS` (4 - when it switches itself off), `SHORT_NOTICE_ACCEPT_MINUTES` (30), `SHORT_NOTICE_PAY_MINUTES` (30), `PAY_DEADLINE_MARGIN_MINUTES` (60 - payment closes at least this long before the shoot), `PAYMENT_WINDOW_HOURS` (24 - the ordinary pay window, formerly a constant).
- [ ] **R2 lifecycle rule** expiring incomplete multipart uploads (**once** per bucket; not yet configured). See [Upload resume survives a dropped connection, not a killed app](BACKEND_GAPS.md#upload-resume-survives-a-dropped-connection-not-a-killed-app---logged).

## 5. Not deploy steps - they block a launch to real clients

Listed so a successful deploy is not mistaken for launch readiness.

- **No email is delivered and push does not exist.** A photographer is never told a request arrived. See [LAUNCH BLOCKER: no email is ever delivered](BACKEND_GAPS.md#launch-blocker-no-email-is-ever-delivered-and-push-does-not-exist). "Available now" also waits on this.
- **Price caps** - see section 1; enforcement is inert until the rows exist ([LAUNCH BLOCKER: the tier price cap enforces nothing](BACKEND_GAPS.md#launch-blocker-the-tier-price-cap-enforces-nothing--zero-rows)).
- **Cancellation and no-show terms for short-notice bookings** - an open product decision.
- **Presence on a physical iPhone, never yet checked.** With the pro app on a real phone (Developer Mode on, paired in Xcode, signed with a team, `env/pro.json` pointing at an address the phone can reach), and the client app or `GET /v1/client/pros/<id>` watching that photographer:
  1. Open the pro app: the dot appears within a few seconds.
  2. Send it to the background (home gesture): the dot goes at once.
  3. Reopen, then force-quit it (swipe it away): the dot is gone within 5 minutes. Record the times.
  4. Reopen, then turn on airplane mode with the app open: the dot is gone within 5 minutes. Record the times.
  5. Lock the phone with the app open for 10 minutes: the dot is gone within 5 minutes of locking.

  Simulators covered steps 1-3; steps 3-5 on a phone are what the five-minute expiry exists for. See BACKEND_GAPS.md, "iOS suspension unverified on a physical device".

## Done per environment

| Item | dev | staging | production |
|---|---|---|---|
| Recompute index (`min_package_price`) | done | | |
| Recompute index (`ranking_score`, and `0056`'s labels under the current rule) | done 2026-10-12 - the later 24h-and-a-minute change gives the same answers there, every dev request having a 24-hour window | | |
| Watermark backfill | done | | |
| Camera reference loaded | 98 cameras | | |
| Price cap row for every active niche and tier | 40 of 60 - none for architecture, automotive, maternity, sports | | |
| R2 multipart lifecycle rule | | | |
