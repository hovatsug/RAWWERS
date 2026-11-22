# Commits since the last full pass

The last full pass is **GATE 1 on 41fd970** (2026-11-17, below; the one before was 13148e8, 2026-11-08). The list restarts from 41fd970 (owner, 2026-11-17); the earlier rows are in git history. Every commit after it is listed here until the next gate (GATE 1: feature freeze; GATE 2: after the security audit fixes; GATE 3: before deploy). At a gate, run both full suites once and use this list to know what to watch. Then start a new list from the gate's commit.

## GATE 1 — run on 41fd970 (2026-11-17)

From the pinned worktree `~/Developer/RAWWERS-work/wt-gate1`; the progress log is in the owner's scratch folder (`gate1-progress.txt`).

| Stage | Result | Time |
|---|---|---|
| API lane 1 (66 files) | 956 passed, 2 xfailed, 0 failed, 0 errors | 2 h 47 min |
| API lane 2 (66 files) | 810 passed, 0 failed, 0 errors | 1 h 56 min |
| API lane 3 (66 files) | 873 passed, **2 failed**, 0 errors: two outdated tests (`test_check_known_failures`: the list may now be empty; `test_answering_a_request`: a hand-set tier, demoted by the recompute since 11e30c5). Fixed in 34f1b68; both whole files pass | 2 h 39 min |
| API total | 2,639 passed, 2 xfailed, 2 failed (fixed), 0 errors; KNOWN_FAILURES: 0 | |
| Flutter (`flutter test`) | 1,128 passed, 39 skipped, 0 failed | 3 min 41 s |
| Web (`pnpm verify`: lint, build, typecheck, isolation and user-page checks) | passed | 2 min |
| E2E (Playwright, 83 tests) | **The web Docker image does not build** (Corepack fetches the newest pnpm, 12.x, which refuses to install; with pnpm pinned, `Module not found: @sentry/core` because there is no `web/.dockerignore` and `COPY . .` brings the host's node_modules; Google Fonts unreachable in the build). Run instead with the e2e API stack in Docker (18000) and the web app started from the pinned worktree (13000): 78 passed, 3 failed, 2 skipped. Two outdated checks fixed in 7481ae2 (rerun: pass); **the funnel fails because `seed_dev.py --deterministic` crashes on a fresh database** ("Photographer profile not found", since c291946) | 4 min |

Not clean: two real bugs reported to the owner (the web image build, the seed on a fresh database), not fixed in the gate.

**GATE 1 CLOSED on 81a4c5e (2026-11-17):** the two bugs fixed (7ee2f09, ae0945b), then the end-to-end suite rerun against the e2e stack with the web **image** built with no cache from the repo's Dockerfile (pinned 9331183; ports 18000 and 13000): 79 passed, 3 failed, 1 skipped. The funnel test was outdated (New York and a made-up time; fixed in 81a4c5e: Lisbon and an offered start time). The two admin-menu failures were flaky: they passed on a rerun of that file and in the full suite after. Full suite at 81a4c5e on the same images: **82 passed, 0 failed, 1 skipped** (the approval test needs a pending photographer fixture). The review-queue test now runs (the seeded admin).

## Commits since 41fd970

| Commit | Date | What | High-risk |
|---|---|---|---|
| 34f1b68 | 2026-11-17 | Tests: two outdated tests found by Gate 1 (an empty known-failures list; a hand-set tier pinned as an override) | no (tests only) |
| 7481ae2 | 2026-11-17 | E2E: the login heading locator; the admin key the web proxy needs in compose.e2e | no (e2e tests and e2e compose only) |
| 4268ffd | 2026-11-17 | Docs: GATE 1 result; two real bugs logged | no (docs only) |
| 7ee2f09 | 2026-11-17 | Web image: pnpm pinned (packageManager, Dockerfile, CI), web/.dockerignore, self-hosted fonts | no (build and CI; a no-cache image build and pnpm verify pass) |
| ae0945b | 2026-11-17 | Seed on a fresh database (profile flushed before its currency is read); DEPLOY_CHECKLIST section 0, the empty-database sequence | no (dev seed script and docs) |
| c9557a9 | 2026-11-17 | Chat message emails (#69): photographer on a client's message, client on a reply; hold, unread, 15-minute window | **yes** (email, chat) |
| aea9f6e | 2026-11-17 | ruff.toml (E9, F63, F7, F82), ruff pinned in CI; repair partner index document returned again; CertificateView imported | no (lint config; two small fixes, failing tests first) |
| 9331183 | 2026-11-17 | Docs and e2e: JWT length, web image checks, deprecations LATER; the list restarted; the admin review-queue e2e test runs with the seeded admin | no (docs and e2e only) |
| 81a4c5e | 2026-11-17 | E2E: the funnel books in Lisbon at a time the calendar offers; **Gate 1 closes here** | no (e2e test only) |
| 4105446 | 2026-11-17 | CI: the empty-database job (DEPLOY_CHECKLIST section 0, `scripts/check-empty-database.py`) | no (CI and a check script; checked locally on a throw-away database, and with the API stopped) |
| ea53a59 | 2026-11-17 | E2E: the seeded photographer waiting for approval (PENDING_PRO); the approval test runs. E2E once with the web image: 82 passed, 1 failed (a 30 s timeout in admin-money-attention, unrelated), 0 skipped | no (dev seed and e2e only) |
| 2830c88 | 2026-11-17 | Portfolio: a photographer removes their own photo (#70); plug-in-facing `removed_in_app` and the re-publish refusal | **yes** (deletes content) |
| 64ad6a2 | 2026-11-17 | Lightroom plug-in 1.2.5: niches and photos removed in the Pro app | no (plug-in; 123 plug-in tests, 4 of 4 break checks) |
| 582a440 | 2026-11-17 | Niches: the shared rules for the Pro app's niches screen (#71) | **yes** (writes to the profile, onboarding) |
| a0a55d6 | 2026-11-17 | Pro app: Your niches screen, Remove from portfolio, the tagger offers own niches; API client regenerated | **yes** (onboarding, profile writes, deletes content) |
| fac1460 | 2026-11-17 | Docs: #70, #71, LATER #72-73, plug-in 1.2.5 docs, CI findings, DEPLOY_CHECKLIST step 8 | no (docs only) |
| e5a6e77 | 2026-11-18 | Cover (#74): one server rule (chosen, else earliest main-niche photo, else earliest ready photo) for every place that shows a photographer's image; Set as cover; the profile save takes only the photographer's own ready photo as cover | **yes** (writes to the profile, changes what clients see in Discover; 316 tests in 21 related files, 14 of 14 break checks) |
| ce6b209 | 2026-11-18 | Pro app: Set as cover, the Cover badge, Remove from portfolio readable on the dark viewer and full width; Your listing says where the photo comes from; API client regenerated | **yes** (profile writes; 115 Flutter tests in 9 related files, 10 of 10 break checks) |
| 40993c0 | 2026-11-18 | Docs: #74 MUST, #64 updated, crop and photo-count findings, endpoint lists | no (docs only) |
| 17fb175 | 2026-11-18 | Ownership audit: a content pack's cover and previews must be the creator's own uploads; fixes a 500 for packs with previews | **yes** (checks ownership of content; with 33c8f5f: 498 tests in 25 related files, 12 of 12 break checks) |
| 33c8f5f | 2026-11-18 | Discover card, listing preview and profile header use the 2048 px web copy; optional cover_width and cover_height on cards and the profile | **yes** (changes what clients see in Discover; see 17fb175) |
| c568677 | 2026-11-18 | Client app: a portrait cover's crop leans to its upper third (card, listing, header, home tiles); API client regenerated | **yes** (changes what clients see in Discover; 141 Flutter tests in the related files, 8 of 8 break checks, 2 of them after strengthening the tests) |
| 1cee0dd | 2026-11-18 | Docs: MEDIA_OWNERSHIP_AUDIT, crop fixed, image-size options, LATER #75-76 | no (docs only) |
| 2204736 | 2026-11-20 | WebP card copy for portfolio photos (processing, covers everywhere, fallbacks); ready only with every copy; share token gives previews only; unnamed copy kinds refused to clients; dev seeds and dev-only backfill | **yes** (media processing, Discover, ownership; with a2b8a81: 447 tests in 33 related files, 15 of 15 break checks) |
| a2b8a81 | 2026-11-20 | `studioverse_enabled` off outside development (user routes answer as unmounted); print user routes behind `ecom_enabled` | **yes** (feature switches; see 2204736) |
| 08f1b16 | 2026-11-20 | App: regenerated API client (card kind); WebP decode test | no (generated client and a test; 102 Flutter tests in the related files) |
| 2ef184b | 2026-11-20 | Docs: card copy, the seed cause, the beta flag table in DEPLOY_CHECKLIST, audit fixes, BETA_SCOPE #39 precondition and LATER #77-79, COVER_TEST_STEPS | no (docs only) |
| 8a5588d | 2026-11-21 | "Meet the photographer" video API, built against a development fake Mux; Mux client fixes from its documentation (signed-only playback, basic quality, base64 signing key, thumbnail token, asset deleted event) | **yes** (uploads, media, ownership, what clients see; 231 tests in 15 related files, 17 of 17 break checks) |
| 892b72e | 2026-11-21 | Apps: Pro "Your introduction video", the Client profile video; iOS camera/microphone strings; Android camera query and INTERNET; video_player; API client regenerated | **yes** (uploads, what clients see; 86 Flutter tests in the related files, 8 of 8 break checks) |
| 3e2a8cc | 2026-11-21 | Docs: BETA_SCOPE #37 MUST and #80-81, account deletion note; DEPLOY_CHECKLIST section 4 (Mux setup, post-deploy verification) and flags; MUX_LOCAL_WEBHOOKS fake and assumptions; PRESENTATION_VIDEO_TEST_STEPS | no (docs only) |
| be144e2 | 2026-11-21 | Video upload limit 100 MB (owner: save mobile data); docs say the owner has a Mux account, dev keys real, production its own environment | **yes** (uploads; test_presentation_video.py 35 passed, Flutter screen test 10 passed, 1 of 1 break check) |
| 9e0565c | 2026-11-21 | MUX_PLAYBACK_MAX_RESOLUTION 720p inside the signed token; loaners_enabled and rewards_spend_enabled off outside development (client credit unaffected, video uploads on); PRESENTATION_VIDEO_ENABLED default pinned off | **yes** (what clients see, money switches; 15 related files 246 passed after a test fix; 6 of 6 break checks) |
| 7de1061 | 2026-11-21 | Pro app: in-app camera for the introduction video (iOS 1080p 8 Mbit/s, Android 720p, stops at 60 s); Android camera permissions Pro only | **yes** (uploads; 16 Flutter tests in the related files, 5 of 5 break checks, iOS debug simulator build) |
| 26b8fe0 | 2026-11-21 | Docs: flag table and post-deploy step 5, Mux assumption row, BETA_SCOPE #37 and LATER #82, test steps (fake on, switching to real Mux, recording sizes) | no (docs only) |
| cc7ec96 | 2026-11-22 | Client address behind Cloudflare: CF-Connecting-IP believed only from Cloudflare's published ranges (TRUST_CLOUDFLARE, api/app/core/cloudflare_ips.txt); the admin proxy forwards it | **yes** (client IP, rate limits; test_client_ip.py whole file, admin key and dev-only route files; 4 of 4 break checks: CF header from any source, rate limit keyed on the proxy, Caddy trusting X-Forwarded-For, API published directly) |
| 4606c5e | 2026-11-22 | Production refuses to start with unsafe or missing settings (API and Celery, plain-words list); DEPLOYMENT_MODE test keeps the email allowlist; API docs and /metrics off in production; /healthz shows the release | **yes** (startup guards, config, secrets handling, email; test_production_guard.py 48, test_telephony_mount.py, test_brevo_sending.py, test_startup_warmup.py whole files; 12 of 12 break checks) |
| a2390e5 | 2026-11-22 | Production stack: deploy/compose.prod.yml rewritten (memory limits, health checks, log rotation, one beat, only Caddy published), deploy/Caddyfile, non-root API image, api/.dockerignore, old deploy targets and workflow jobs removed | **yes** (config, secrets handling, admin access, client IP; test_compose_prod.py 13, test_queue_consumers.py whole files; 9 of 9 break checks; local rehearsal: migrations, bootstrap, smoke, backup, restore, kill-and-restart) |
| 90afaa9 | 2026-11-22 | Deploy scripts: bootstrap_reference_data, smoke, version, server baseline, email DNS check, generate-secrets, build-and-push, backup, restore test, image check, delete smoke accounts | no (scripts; test_deploy_scripts.py 5, test_bootstrap_reference_data.py 2; 5 of 5 break checks; run in the rehearsal) |
| 65c2fdb | 2026-11-22 | Docs: DEPLOY_RUNBOOK, DEPLOY_SECRETS, DEPLOY_AUDIT, .env.production.example, checklist corrections, BETA_SCOPE #28 done and LATER #83-93 | no (docs only) |
