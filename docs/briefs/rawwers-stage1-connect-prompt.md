# RAWWERS — Stage 1: payouts can be set up, and one full test booking works

Save this file verbatim as `docs/briefs/rawwers-stage1-connect-prompt.md`, then do the task below.

## Why
Photographers cannot set up payouts: the Stripe Connect onboarding link cannot open from the pro app (no `url_launcher`, no iOS URL scheme). Until that works nobody can be paid, so nothing else matters yet.

Goal of this stage: on the simulator, in Stripe TEST mode, one person plays a photographer and a client and completes the whole loop: payout onboarding, booking, payment held, delivery, review, payout request. No real money, no real people.

## Decisions already made (do not reopen)
1. **Pro app only.** The client app is not touched.
2. **Test mode only.** No live keys anywhere. No secrets in the repo, logs, screenshots, reports or chat (environment variable NAMES are fine, values never).
3. **No Apple Developer account yet.** So: no universal links, no associated domains, no push. The return from Stripe uses a custom URL scheme (pro flavor only) plus an Android intent filter for the pro flavor. Propose the scheme name in Part A.
4. **The deep link is a hint, not the truth.** When the app comes back (by link, or because the person closed the browser), it asks the server for the account status. The server reads it from Stripe (and from the webhook if that already exists). The app never trusts parameters in the link.
5. **No change to money logic**: fees, escrow, ledger, tiers, ranking, availability, refunds, cancellation. This task is integration plumbing, a status UI and tests. If you find money logic must change, stop and report.
6. Honest, plain copy for every state. No hardcoded colours, sizes or radii. Strings follow the app's existing localisation approach. Currency symbols and amounts come from server data.
7. Do not deploy, do not touch any server, do not merge to `main`. Push the branch only.

## Process rules (as always)
Tests first, with break checks (break the rule, the test must fail). One commit per step. Clean worktree per commit. API suite only for commits touching `api/` (it takes about 5 hours; 26 known failures listed in `docs/KNOWN_FAILURES.txt`); run it once on the whole branch before pushing and diff by name. Max 3 parallel suites. Byte-identical branch check before pushing. No new dependency without pinning its version and saying why. Stripe in tests is always faked: no network calls in tests.

---

## PART A — Discovery (report only; then stop and wait for approval)

1. **Connect today, API.** Which Connect account type is used (Express, Standard or Custom). Existing endpoints for creating the connected account and account links. What is stored (account id, status fields). Is there a webhook handler for `account.updated` (signature verified? idempotent?). Country handling (UK photographers). What `return_url` and `refresh_url` are used today. What a payout request does when the account is not ready.
2. **Connect today, app.** Where the onboarding button/screen is, what it calls, what happens on tap, which states exist. Is `url_launcher` present? Current iOS `Info.plist` URL types and queried schemes per flavor, Android manifest and intent filters per flavor, and how `go_router` handles incoming links today.
3. **Return-flow design proposal.** Options: server-hosted return page that redirects into the app, versus a direct custom scheme. What does Stripe allow for `return_url` in test mode (is plain http on localhost accepted)? How does the app handle an expired link (`refresh_url`) and an abandoned flow? Recommend scheme names (pro flavor only). Recommend how to receive incoming links (`go_router` built-in or a pinned package) and why.
4. **Status model.** Map the Stripe fields (`details_submitted`, `charges_enabled`, `payouts_enabled`, `requirements.currently_due`, `disabled_reason`) to app states: not started, in progress (resume), under review, action needed, ready, error. Draft the plain-language copy for each state, with what the photographer should do next.
5. **The full test loop today.** Which parts already work locally (create client and pro, booking, test-card payment, payment held, delivery, review, payout request) and which are missing or unreachable from the simulator. List blockers.
6. **Local setup.** How to run the API, Stripe CLI webhook forwarding and the simulator together. Env var names needed (names only).
7. **Report-only items for the owner (change nothing):**
   a. **Deploy gap.** What is deployed on the server right now (commit, date), how far behind `availability-holds` is, which Alembic migrations on the branch are not applied there, what `DEPLOY_CHECKLIST.md` says for each, whether the server has a public https address and a Stripe test-mode webhook endpoint, and whether the Brevo sender domain is verified and IP restrictions are on or off. No secrets.
   b. **Email today.** How the API sends email, and whether a dev backend (log/console) exists. Do not wire Brevo.
   c. **Cancellation and no-show today.** What the code does now (refund windows, no-show handling). Report only; the owner will decide the rules.
   d. **`docs/BACKEND_GAPS.md`.** Is the missing currency field on balance and booking responses listed? If not, say so.
8. **Commit plan**, files grouped by commit. Then **stop**.

---

## PART B — Build (after approval). One commit per step

**B1. Backend tests first** (only for gaps found in Part A): account-link creation for a pro user, link refresh, a status endpoint that reads from Stripe, and webhook updates. Fake Stripe client, no network. Break check per test. Fix only what is missing.

**B2. App plumbing.** Add `url_launcher` (pinned). The onboarding button opens the link (in-app browser view where supported). Pro-flavor-only custom URL scheme on iOS and an intent filter on Android. Incoming-link handler that does nothing except trigger a status refetch. Refetch also on app resume.

**B3. Status UI.** Build every state from Part A item 4, using existing components (`r_empty_state`, `r_error_state`, the header band pattern). "Request payout" is enabled only when the server says payouts are enabled; existing disabled and explanatory states stay untouched. Widget tests per state at normal and 1.3 text scale.

**B4. End-to-end loop.** Write `docs/STAGE1_LOOP.md`: a click-by-click checklist for the OWNER to run on the simulator in test mode (you cannot tap), with the exact test data to use for Stripe's hosted onboarding form, taken from Stripe's test-mode documentation. Include a screenshot of each step you CAN reach (test routes, widget gallery), and say plainly which steps you could not reach.

**B5. Wrap-up.** Open a pull request `availability-holds` into `main` (do NOT merge). DEPLOY_CHECKLIST.md entries for anything that needs deploying. Update `docs/BACKEND_GAPS.md` (currency field) if missing. Run the full suites once on the whole branch and diff by name against `docs/KNOWN_FAILURES.txt`. Run the Flutter test suites for both flavors.

## Not in this task
Merging to `main`. Deploying. Brevo. Push notifications. Universal links. Store accounts. Cancellation or no-show logic. The currency field fix. Any client app change. Live mode.

## Reporting
Part A: tables, then a "needs a decision from the owner" list, then stop. Part B: per commit, what changed, files, test and break-check counts, full-suite diff by name, what you could not verify, and "how to see it".
