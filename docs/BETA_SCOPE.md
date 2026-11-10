# Beta scope (closed beta, before the FEATURE FREEZE)

Written 2026-11-10 on `the-shelf-wip` at 84ead7f. **Read-only check**: the code, routes and tests were read, nothing was run or built. The beta is a small invited group of real clients and photographers. The UK goes first and Portugal and Spain second. Stripe runs in test mode first, then live. `shelf_enabled` stays off in production.

**Classes.** MUST: without it a real beta user cannot finish a core journey, or money, data or legal safety is at risk. A MUST is also anything that has to be in the first app build, because a build already installed cannot be changed later. Anything that can wait a month without harm is not MUST. SHOULD: worth doing during the beta. LATER: after the beta.
**Effort.** S: half a day of agent work or less. M: about a day. L: more than a day.

**Counts:** 15 MUST (#1–13 always; #14 GBP while the UK goes first; #15 fixed at GATE 2) · 16 SHOULD · 22 LATER.

---

## Part 1. The critical journeys

The one end-to-end run on record is the Stage 1 loop (`docs/STAGE1_LOOP.md`, run 2026-10-28..30). It covered a seeded, already-approved Lisbon photographer, EUR and Stripe test mode, on simulators: payout setup → request → accept → pay → deliver → select → review → settle → payout → admin approval → transfer. Everything else below is read from code and tests.

### a. Client: works end to end in EUR. Sign-up depends on Brevo being on. Nothing tells the client the rules or how to reach us.

| Step | Evidence | Status |
|---|---|---|
| Sign up, verify, log in, reset | `shared/auth/*_screen.dart`; `POST /v1/auth/register·login·verify-email/*·password-reset/*`; `test_auth_v1.py`, `test_brevo_sending.py` | Works. The codes arrive only once `EMAIL_SENDING_ENABLED=true` and the Brevo domain is set up. A verified email is not needed to book. |
| Find a photographer | `client/discover`, `client/pro_profile`; `/v1/discover/*`; `test_discovery.py`, `test_client_home_rows.py` | Works. A photographer shows only when `approved_public` **and** client browsing is on for their city (`launch_ops.py:405-415`). No admin page sets rollout cities; it is API only. The search screen is unreachable (BACKEND_GAPS). |
| Book, pay | `client/booking_request`, `booking_payment_controller.dart`; `POST /v1/pros/{id}/booking-requests`, `/v1/client/bookings/{id}/pay`; `test_client_booking_pay.py`, `test_missed_payment_webhook.py`, `test_stripe_reconcile.py` | Works in EUR. **No cancellation or refund rules are shown anywhere before paying.** |
| Gallery, choose, add-on window, download | `client/gallery/*`; `test_selection_*`, `test_selection_addons.py`, `test_download_payment_gate.py`, `test_review_gate.py` | Works. Downloads wait for a star rating or "Report a problem". |
| Review | `bookings/review_panel.dart`; `POST /v1/gigs/{id}/review`; `test_reviews.py` | Works. |
| **Breaks** | | GBP: the app formats every amount as € (`RMoney` falls back to EUR), so a UK booking reads wrong. A client cannot cancel a paid booking and cannot open a dispute before delivery: `/v1/disputes` exists, but no screen uses it. **There is no way to contact us** anywhere in the app. |

### b. Photographer: works end to end for a Lisbon photographer the admin approves. A UK photographer is paid wrong. Nothing is missing on the road to going live.

| Step | Evidence | Status |
|---|---|---|
| Sign up, become a pro, onboarding | `upgrade`, `onboarding/onboarding_controller.dart` (stages, `submit-kyc`, `activate`); `test_pro_onboarding_booking.py`, `test_launch_ops.py` | Works. Two admin approvals: KYC, then publishing (`/admin` Photographers → `pros/{id}/approve`). **No photographer agreement is shown or accepted.** |
| Stripe Connect | `payouts_screen.dart`; `/v1/pro/payouts/connect/*`; `test_stripe_connect*.py`, `test_payout_setup_state.py` | Works for a PT account, against real Stripe test mode. The account country follows the profile (`payouts.py:339`), but **a GB account on the PT platform has never been tried**. |
| Packages, availability | `pricing`, `availability`; `test_package_pricing.py`, `test_bookable_time.py`, `test_scheduling_*` | Works. **Price caps have zero rows until they are imported in production.** **There is no "pause bookings" switch** (`is_accepting_bookings` is only ever set to True). DST bug on 2027-03-28. |
| Request, accept, deliver | `requests`, `gigs/delivery`, Lightroom plug-in; `test_answering_a_request.py`, `test_delivery_*`, `test_server_attach.py` | Works. A new request reaches the photographer by email (Brevo) and in-app. There is no push. |
| Earnings, hold, settlement, withdraw | `wallet/*`, `payouts`; `test_photographer_money.py`, `test_hold_release.py`, `test_payouts_v1.py`, `test_payout_routes.py` | Works in EUR. **Payouts are hard-coded to EUR** (`payouts.py:498`), and earnings responses carry no currency. |
| **Breaks** | | GBP pay-out and display. A photographer cannot cancel an accepted booking (support only). The Settings email switch still says "Not being delivered yet" (`pro_settings_screen.dart:352`), and that is wrong once Brevo is on. "Get in touch" appears with no contact given. |

### c. Money: refunds, cancellations, disputes, chargebacks. The tools exist, but only the admin can use them, and no written rules exist.

| Who | Can do | Evidence |
|---|---|---|
| Client | Pay. Choose fewer photos and get the rest back automatically. "Report a problem" after delivery, which holds the photographer's earning. Raise a card chargeback with their bank. | `price_reduction.py`, `reviews.py:126`, `chargebacks.py` |
| Client | **Cannot** cancel a paid booking, ask for a refund, or open a dispute in the app. Self-service refunds are off outside dev by design (`test_self_service_refunds.py`). The "platform cancellation standard" is not built (`full_refund.py` docstring). | |
| Photographer | Decline a request. **Cannot** cancel an accepted or paid booking. | `pro_onboarding.py:1295` |
| Admin | Lower a price down to zero, which refunds the client through reconciled refunds. A full refund ends the booking as `refunded`, frees the calendar, revokes downloads and reverses earnings. Can also resolve disputes, act on the money-attention queue (client owed, chargeback evidence due or lost) and release or keep holds. | web `/admin/bookings/[id]`, `/admin/disputes`, `/admin/money-attention`; `test_price_reduction.py`, `test_full_refund_settles_gig.py`, `test_disputes_refunds.py`, `test_chargebacks.py`, `test_refund_reconcile.py` |
| Admin | Chargeback evidence is submitted in the Stripe dashboard (the item says so). | |

**Verdict:** a cancellation works if the client reaches us and the admin applies a rule. The rule does not exist, and the client has no way to reach us. Three money-path tests are on the known-failures list and have never been diagnosed: `test_stripe_webhook_idempotency_and_ledger_totals`, `test_payment_succeeded_finalizes_gig_redemption` and `test_kyc_gating_blocks_payment_intent_in_production`.

### d. RAWW and The Shelf: built and tested, off in production. Nothing needed for the beta.

- **Built:** earn, balance (`wallet/raww_card.dart`), spend, order, admin shipping and expiry. Tests: `test_raww_*`, `test_shelf_*`.
- **While `shelf_open` is false:** the browse route refuses, the wallet hides RAWW and the expiry job does nothing (`raww_expiry.py:31`).
- **RAWW still accrue silently in the ledger.** On the day the Shelf opens, old balances will be measured from their last earning (see decision 8).

### e. Admin: money is covered. Users are API-only. Photos cannot be moderated.

| Need | Today |
|---|---|
| Approve photographers, gear, reviews | Web: Photographers, Gear and Reviews (moderate). |
| Disputes, refunds, money | Web: Disputes, Money to act on, Payouts, booking page (price reductions), Dashboard and Costs (BI). |
| See a user, contact them, suspend or ban | **API only**: `GET /v1/admin/users`, `POST /v1/admin/users/{id}/ban` (suspend, ban, lift; it ends sessions and hides from Discover; `test_ban_enforcement.py`, `test_pro_shut_out.py`). No web page, and no way to message a user. |
| Remove a photo | **Nothing.** Neither the admin nor the photographer can remove a portfolio photo. There is no report button on profiles, messages or photos, and no block. |
| Rollout cities, feature flags, fee policy | API only (`/v1/admin/rollout/cities`, `/feature-flags`, `PUT /finance/fee-policy` replaces every field). |

### f. Account life: deletion is missing (Apple and Google require it). The rest is thin.

| Need | Today |
|---|---|
| Change password | Only through "forgot password" (email). There is no signed-in change. |
| Change email | **No route.** |
| Notification settings | Pro: in-app and email switches (stale text). Client: **no screen**. API: `/v1/me/notification-preferences`, topic preferences. |
| Unsubscribe | Built: signed links, web `/unsubscribe`, one-click headers (`test_unsubscribe.py`). |
| Delete account | **Missing.** Only `DELETE /v1/dev/test-accounts/me` (dev-only). The Google Play web page is missing too. |
| Export my data | **Missing.** There is no route; it would be a manual reply by email. |

### g. Support: missing

- **Reaching us:** there is no support address, form or help link in either app, the web or the emails. The only address setting is `BREVO_REPLY_TO`.
- **What we can see:**
  - Error bodies carry a `request_id`, and the API logs a structured line (`core/errors.py:39`).
  - **There is no error alerting.** No Sentry or similar exists in the API, worker or apps. Logs exist only where the host keeps container output.
  - A Brevo send that is refused or times out is logged and dropped (`outbox_tasks.py:120-124`). An outbox event that runs out of retries is marked failed, and nobody is alerted.

---

## Part 2. The store and legal basics

| Item | Exists? | Evidence |
|---|---|---|
| Terms of service | No | Only the Shelf's draft terms, which are gated (`shelf_settings`). |
| Privacy policy | No | `docs/PRIVACY_NOTICE_INPUTS.md` holds input for the lawyer, not a notice. |
| Photographer agreement | No | |
| Consent wording | Marketing consent only: drafts, off in production until a reviewed version is published (`/admin/marketing-wording`) | |
| Cancellation and refund rules shown to users | No | |
| Account deletion page (Google Play) | No | BACKEND_GAPS "Account deletion does not exist" |
| Privacy label data | Inventory below | |
| Minimum app version or kill switch | No | Only `ai_chat_kill_switch` and the Lightroom plug-in's minimum version exist |
| Push notifications | No | No FCM, APNs or device tokens |
| Store reviewer test accounts | No | Dev seeds only; they are refused in production (`test_seed_guard.py`) |
| TestFlight and Play internal testing | Not set up | Bundle IDs `com.rawwers.client` and `.pro`; per-flavor icons exist. **Android release is signed with the debug key** (`android/app/build.gradle.kts:44-47`). The `INTERNET` permission is only in the debug and profile manifests, so a release build relies on a plugin merging it in (unverified). |
| Invite or waitlist control | Partial | Photographers need admin approval. Invite codes exist for pro onboarding only. **Client sign-up is open to anyone who has the app.** Store distribution is the only limit. |
| Crash and error reporting | No | |
| Backups | No | `deploy/compose.prod.yml` runs Postgres in a local volume. No dump job or restore doc exists. |
| Rate limits | Yes | Named buckets (`services/rate_limit.py`), admin 60/min, BI 240/min. **But** client IP is the leftmost `X-Forwarded-For` (`deps.py:190`, `auth.py:316`): a caller can spoof it to dodge rate limits, **and to pass `ADMIN_IP_ALLOWLIST`**. |
| Moderation of uploaded photos | No | No scanning, reporting or takedown. Only the photographer approval at onboarding. |

**Privacy label inventory** (what the code collects, for the App Store labels and Play's Data safety form; the lawyer confirms):
- **Contact:** email, display name, optional phone.
- **User content:** portfolio and delivered photos, Mux video, messages, reviews, problem reports.
- **Location:** city and country on the profile, and the shoot address on a booking. No device location; the app asks for no location permission.
- **Payment:** handled by Stripe; we keep payment intent ids and amounts, never card data. Connect identity checks are held by Stripe.
- **Identifiers:**
  - user id;
  - user agent and a hashed IP on sign-in;
  - the raw IP on downloads, kept 120 days;
  - hashed IPs for risk and share signals.
- **Usage:** analytics events (`analytics_event`) linked to the user. No third-party tracking SDK in the apps.
- **Shipping address:** Shelf only, encrypted, and off.
- **Processors:** Stripe, Cloudflare R2, Mux, Brevo, the host. The LLM and telephony providers are mock or unmounted.

---

## Part 3 and 4.1. Every item, classified

Sources: this check (marked •), `docs/BACKEND_GAPS.md` (BG), `docs/SECURITY_AUDIT_LIST.md` (SA), `docs/KNOWN_FAILURES.txt` (KF).

| # | Item | What exists today (evidence) | Class | Effort | Risk if skipped | Who decides or provides |
|---|---|---|---|---|---|---|
| 1 | Triage the money and KYC known failures (KF: ledger totals, redemption, KYC gating ×2): is the product or the test wrong? | Never diagnosed; one fails 401 before reaching the gate (BG "Eleven test failures") | **MUST** | S | A real money or KYC bug ships unseen | — |
| 2 | Dependency lockfile | No `poetry.lock`; two builds of one commit differed (BG) | **MUST** | S | Deploy-day breakage, unknown versions in production | — |
| 3 | Trusted proxy IP (`TRUSTED_PROXY_IPS`, one helper) | Leftmost `X-Forwarded-For` trusted in about 10 places (BG; `deps.py:190`) | **MUST** | S | Admin IP allowlist and rate limits bypassable; download IP evidence forgeable | Host (which proxy) |
| 4 | Server error alerting (API and worker), including mail and outbox failures | None (• Part 1g) | **MUST** | S | 500s, failed emails and stuck jobs go unseen during the beta | Owner: vendor and DPA |
| 5 | Minimum app version and maintenance switch | None (•) | **MUST** | S | Build 1 can never be forced to update or stopped | — |
| 6 | Support channel: "Get help" in both apps (with user id, app version and request id), support address as email reply-to, web support page; fix the "Get in touch" and stale email-switch texts | None (• Part 1g) | **MUST** | S | Users stuck with money problems cannot reach us; Apple requires contact information | Owner: support address |
| 7 | Terms, privacy and photographer agreement: versioned, accepted at sign-up and on becoming a pro, linked in both apps and on the web | None (• Part 2) | **MUST** | M | No legal basis for contracts or processing; store listings need the privacy URL | **Lawyer** (texts), owner |
| 8 | Cancellation and refund rules shown before sending a request and before paying, and on the booking; the admin applies them with price reductions | Admin tool exists (`price_reduction.py`); no rules, no text (•) | **MUST** | S | Consumer-law exposure and disputes with no agreed rule | **Owner** (policy), lawyer |
| 9 | Account deletion in both apps (anonymise, keep money and tax records, withdraw marketing consents, end sessions; refused while a booking, balance or dispute is open) | Missing (BG "Account deletion") | **MUST** | L | Apple rejects; GDPR erasure requests unanswerable | Lawyer and accountant (retention) |
| 10 | Google Play account-deletion web page | Missing (BG) | **MUST** | S | Play Data safety form cannot be completed | Lawyer (text) |
| 11 | User-generated content safety: report a photographer, message or review; block in chat; admin report queue; admin hides a portfolio photo; photographer removes their own photo | None (• Part 1e) | **MUST** | M | App Store guideline 1.2 rejection; no takedown for an unlawful or unconsented photo | — |
| 12 | Release builds: Android upload key, release manifest check, production env files (API URL, live Stripe publishable key), iOS archive | Debug signing, localhost env (•) | **MUST** | S | Nothing can be distributed | Owner: signing keys, Apple and Google accounts |
| 13 | Database backups and a tested restore | None (`compose.prod.yml`) | **MUST** | S | One disk fault loses every booking and ledger | **Owner**: host or managed Postgres |
| 14 | GBP end to end (UK first): a currency on every money response, payouts in the account's currency, apps format by currency, caps and pricing per currency, BI conversion, a GB Connect account tested on the PT platform | Package and gig carry a currency; payouts hard-coded to EUR; apps assume € (BG ×2) | **MUST** if the UK goes first | L (about 4 days) | UK clients and photographers see and receive wrong amounts | **Owner**, Stripe, accountant |
| 15 | SA3: error bodies never leak internals | Open (SA) | **MUST** (GATE 2) | M | Information leak | — |
| 16 | SA1: verify and reset codes in plain text in the outbox | Open (SA, BG) | SHOULD (GATE 2) | S | A database reader can take over accounts | — |
| 17 | SA2: two security tests (and the 500 on the deprecated `/v1/chats` route, which the apps no longer use) | Open (SA) | SHOULD (GATE 2) | S | Spam signal untested; dead route errors | — |
| 18 | Stripe call timeout and retry | Library defaults; 10–20 s stalls seen (BG) | SHOULD | S | Slow screens and timeouts; recovers on retry | — |
| 19 | DST: bookable grid wrong on 2027-03-28 | Open (BG) | SHOULD, **dated**: fix by 2027-01-31 | M | Zero-length or doubled slots for that night | — |
| 20 | Photographer "pause bookings" switch | One-way switch (BG) | SHOULD | S | Photographers who are away stay bookable (the workaround is clearing hours) | — |
| 21 | Admin Users page: search, see email, suspend, ban, lift | API only (•) | SHOULD | M | The admin works through the API by hand | — |
| 22 | Client notification settings screen | API only; unsubscribe links work (BG c1) | SHOULD | S | Switching email back on needs support | — |
| 23 | Push notifications | Not built (BG) | SHOULD | L | Requests are seen later (email covers the 48 h window) | Apple and Google keys |
| 24 | Self-service cancellation (client and photographer) | None; the admin does it (•) | SHOULD | M | Support load | Owner (policy first) |
| 25 | Client dispute or "problem" screen before delivery | API `/v1/disputes`, no screen | SHOULD | M | No-shows reach us only by email | — |
| 26 | App crash reporting | None; TestFlight and Play give basic crash data | SHOULD | S | Crashes are reported only by users | Owner: vendor |
| 27 | Fee-policy PATCH or admin screen | `PUT` replaces every field (BG) | SHOULD | S | A typo changes a fee | — |
| 28 | Remove the stale `deploy/docker-compose.{prod,staging}.yml` | Duplicates (BG) | SHOULD | S | Deploying the wrong file | — |
| 29 | Notifications that link to screens the apps do not have | Open (BG b) | SHOULD | S | Tapping some notifications opens nothing | — |
| 30 | Client invite gate at sign-up | Pros are gated; clients are open (•) | SHOULD | S | Strangers with a build could sign up (low risk while builds are invite-only) | Owner (decision 3) |
| 31 | Rollout cities admin page | API only | SHOULD | S | London must be enabled by API call | — |
| 32 | Portuguese and Spanish: the apps have no localisation layer at all; email texts are English | (BG; • no `.arb`, no `flutter_localizations`) | LATER, before the PT/ES wave | L | — | Owner, translators, lawyer (language law) |
| 33 | Data export (self-service) | None; answer by email within a month | LATER | M | — | Lawyer |
| 34 | Change email or password while signed in | Reset by email works | LATER | S | — | — |
| 35 | Email verification required before booking | Not enforced | LATER | S | — | — |
| 36 | Flavor isolation: client `messages/thread_screen.dart` imports pro code | 1 import found (`thread_screen.dart:14`); the checker counts 3 | LATER | S | None for users | — |
| 37 | Mux video upload screen | Backend only | LATER | M | — | — |
| 38 | Referral screen | Backend only (BG) | LATER | M | — | — |
| 39 | Print store | Off (`ecom_enabled`) | LATER | L | — | — |
| 40 | The Shelf and RAWW in production | Built, off | LATER | — | — | Lawyer (terms) |
| 41 | Short payment: nothing tells the client | Open (BG PRIORITY) | LATER | M | Rare with cards | — |
| 42 | Delayed payment methods (Multibanco, SEPA) | Disabled in the Stripe dashboard (BG) | LATER | M | Keep them off in live mode | Owner (Stripe setting) |
| 43 | Booking history shows only the request's changes | Open (BG) | LATER | M | — | — |
| 44 | Search screen unreachable; niche tiles home-only | Open (BG) | LATER | S | — | — |
| 45 | Review editing; client reward ladder; review tags | Open (BG) | LATER | M | — | — |
| 46 | Pricing gaps: freeze old bookings' curve, bound `included_photos` | Open (owner's call) | LATER | M | — | Owner |
| 47 | Upload resume after the app is killed; iOS suspension on a device | Open (BG); Lightroom covers big jobs | LATER | M | — | — |
| 48 | Add-on refunds all or none; admin galleries page read-only | Open (BG) | LATER | M | — | — |
| 49 | Marketing consent and video-review marketing use | Off until the lawyer's wording | LATER | — | — | Lawyer |
| 50 | Brevo: invite and waitlist emails | Not on the allow-list | LATER | S | — | Owner (texts) |
| 51 | Portfolio edge caching, video poster frames | Open (BG) | LATER | M | — | Owner (bucket) |
| 52 | Address key rotation, admin-only credit never expires | Shelf only, off | LATER | S | — | — |
| 53 | Test-suite run time (9 h 34 min) | Logged (BG) | LATER | M | Slow gates | — |

---

## 4.2. The freeze list: MUST items in build order

**High-risk** means money, a migration, authentication or security. The whole related test files are run before such a commit. Each batch is about a day of agent work.

| Batch | Items | Notes |
|---|---|---|
| **B1. Safety rails** | #1 triage of the money and KYC known failures **(high-risk)**; #2 lockfile; #3 trusted proxy IP **(high-risk, security)**; #4 server error alerting | #1 first: if a product bug turns up, it is fixed here before anything is built on top. |
| **B2. What build 1 must carry** | #5 minimum version and maintenance switch; #6 support channel and stale texts; #8 cancellation and refund text (placeholder until the owner's rule); #12 release builds | After B2 a TestFlight or Play internal build is possible. |
| **B3. Legal acceptance** | #7 terms, privacy and photographer agreement, versioned and recorded **(high-risk: migration)**; web pages `/terms`, `/privacy`, `/photographer-terms` | Built like the Shelf terms: production refuses to show draft text until a reviewed version is approved. |
| **B4–B5. Account deletion** | #9 deletion in both apps and the API **(high-risk: personal data, money records, migration)**; #10 Google Play web page | About 1.5 days. Needs decision 5 first. |
| **B6. Content safety** | #11 report, block, admin queue, photo takedown and self-removal **(high-risk: migration, authorization)** | |
| **B7. Backups** | #13 dump job to off-site storage, restore drill documented | Small; can join B1 once the host is chosen (decision 7). |
| **B8–B11. GBP** (only if the UK stays first) | #14 currency on money responses and payouts **(high-risk)**; apps formatting; caps, pricing and BI per currency **(high-risk)**; GB Connect account and one transfer in test mode | About 4 days, all money. |

**Total:** about 7 days without GBP, about 11 with it. GATE 2 (#15–17) follows the freeze as fixes, not features.

---

## 4.3. The cut list: not built before the beta

| Item | Why it is safe to wait |
|---|---|
| Push (#23) | Email reaches the photographer within the 48 h request window, and in-app covers the rest. |
| Self-service cancellation and the dispute screen (#24, #25) | With a small group, the admin applies the written rule from a support email. |
| Admin Users, rollout and fee pages (#21, #27, #31) | The API does all three. Each is an occasional admin act. |
| Pause bookings (#20) | Clearing working hours or adding a blackout already stops bookings. |
| Client notification switches (#22) | Every email has a working unsubscribe link. |
| Crash SDK (#26) | TestFlight and Play Console collect crashes from testers; server errors are covered by #4. |
| DST (#19) | The bad night is 2027-03-28. It is fixed as a dated bug fix before 2027-01-31. |
| Portuguese and Spanish (#32) | The UK wave is English. They are needed before the PT/ES wave, not before the start. |
| Data export, email and password change (#33, #34) | Rare. Handled by email within the legal month. |
| Referral, Mux video upload, print store, Shelf and RAWW (#37–#40) | Growth or optional features. All are off or unreachable. |
| Short payment, delayed methods, booking history (#41–#43) | Delayed methods stay disabled in Stripe, so short payments do not occur with cards. History is cosmetic. |
| Everything else marked LATER | No core journey depends on it. |

---

## 4.4. Your decisions (questions, with my recommendation)

1. **Which market goes first?** The UK needs GBP: about 4 days of high-risk money work, plus an unverified Stripe question (a GB connected account on the PT platform). Lisbon in EUR is the only path ever run end to end. Starting there would need either English-only acceptance from the lawyer or the localisation layer (L).
   **Recommendation:** keep the UK first only if there is a business reason. Otherwise start with a small English-speaking Lisbon group in EUR, and build GBP during the beta for the UK wave. Either way, ask Stripe about GB accounts now.
2. **What are the cancellation and refund rules?**
   **Recommendation:**
   - The client cancels free until 7 days before the shoot, gets 50% back up to 48 hours before, and nothing after.
   - A photographer who cancels means a full refund and a recorded finding.
   - Weather or illness means a reschedule first.
   - The admin applies all of these by hand during the beta.
3. **Is store-level invite enough?** TestFlight and Play testers are named. **Recommendation:** yes. Skip the client invite gate (#30) unless a link leaks.
4. **Push before the beta?** **Recommendation:** no. Email and in-app are enough for a small group.
5. **When can an account be deleted, and what is kept?**
   **Recommendation:**
   - Refuse while a booking is open, a balance is unpaid or a dispute is open.
   - Otherwise anonymise the person and keep invoices and ledger rows for the legal period (10 years for Portuguese accounting, to be confirmed by the accountant).
   - Delete portfolio photos.
   - Deliveries stay with the other party's booking until its own retention ends.
6. **Which error-reporting vendor?** **Recommendation:** Sentry, EU region, with a DPA. The same one for the apps later.
7. **Where does production run?** **Recommendation:** managed Postgres with point-in-time recovery (EU region) rather than Postgres in a container volume, behind a TLS proxy whose address goes into `TRUSTED_PROXY_IPS`.
8. **Do RAWW keep accruing while the Shelf is off?** **Recommendation:** yes, silently. When the Shelf opens, start every balance's expiry clock from the opening day.
9. **Does the PT/ES wave start inside this beta?** If yes, localisation (#32, L) becomes MUST before that wave. **Recommendation:** plan it as a post-freeze batch with its own gate.
10. **Which support address?** **Recommendation:** `support@` on the sending domain, used both as the in-app contact and as the reply-to on every email.

---

## 4.5. Outside the code (you)

- **Company and accounts:**
  - Company registration and a D-U-N-S number, needed for Apple and Google organisation accounts. A new personal Play account would need 12 testers for 14 days of closed testing before production; an organisation account is exempt.
  - Apple Developer Program and Google Play Console.
  - The Android upload key. iOS signing (team, profiles).
- **Lawyer:**
  - Terms, privacy policy, photographer agreement and cancellation text.
  - The deletion-page text and the marketing-consent wording.
  - Whether a Portuguese company needs a UK GDPR Article 27 representative and ICO registration.
  - The language rules for Portugal and Spain, and the IP retention figures (`PRIVACY_NOTICE_INPUTS.md`).
- **Accountant:** VAT on the platform fee in the UK and Portugal, invoices, record retention, GBP handling and the FX cost.
- **Stripe:**
  - Live activation and the Connect platform profile and branding.
  - The GB connected-account question, keeping delayed payment methods off in live mode, and live webhook endpoints and secrets.
  - Statement descriptor.
- **Store listings:**
  - Privacy policy URL, support URL, the App Privacy labels and Play Data safety (inventory above), screenshots and descriptions.
  - TestFlight external group (Beta App Review) and Play internal testers.
  - **Reviewer accounts in production:** a client, plus an approved photographer already through Connect, in a city with browsing on.
- **Domain and DNS:**
  - The API host with TLS, `API_PUBLIC_URL`, https `CONNECT_RETURN_URL` and `CONNECT_REFRESH_URL`.
  - Fix the dead SPF include on rawwers.com; DKIM and DMARC for the sender.
- **Brevo:** the DPA, authorised IPs (or none) for the production host, the sender address, then `EMAIL_SENDING_ENABLED=true`.
- **Mux and R2:** production environments, the webhook secret and production buckets.
- **Production data** (DEPLOY_CHECKLIST):
  - Import the price caps (zero rows today) and the camera reference.
  - Enable London (rollout city) and set `settlement_delay_days`.
  - Run the BI backfill.
  - Keep `shelf_enabled` off.
