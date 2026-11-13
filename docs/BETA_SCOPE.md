# Beta scope (closed beta)

**FEATURE FREEZE DECLARED 2026-11-11.** From now on only the MUST items below and bug fixes are built. Everything else is LATER. The owner's decisions are in section 4.4, and the batch plan in 4.2.

**UK FIRST (decided 2026-11-13).** The first wave is the United Kingdom. GBP is the main currency and the default for new users; EUR stays supported as the second currency. The apps stay in English. The UK items are #54–#59 (section 4.1) and decision 2 (section 4.4).

Written 2026-11-10 on `the-shelf-wip` at 84ead7f. **Read-only check**: the code, routes and tests were read, nothing was run or built. The beta is a small invited group of real clients and photographers. Its first wave is the **United Kingdom** (decided 2026-11-13): GBP is the main currency and the default for new users, EUR the second; the UK cities are chosen by the owner later. Stripe runs in test mode first, then live. `shelf_enabled` stays off in production. *(2026-11-11: city and country assumptions removed; 2026-11-13: the country is the UK, the cities are still the owner's to choose.)*

**Classes.** MUST: without it a real beta user cannot finish a core journey, or money, data or legal safety is at risk. A MUST is also anything that has to be in the first app build, because a build already installed cannot be changed later. Anything that can wait a month without harm is not MUST. BUG FIX: a defect, fixed after the freeze like any bug. LATER: after the beta. *(The SHOULD class of 2026-11-10 became LATER at the freeze, owner's decision.)*
**Effort.** S: half a day of agent work or less. M: about a day. L: more than a day.

**Counts (2026-11-13, after the UK-first decision):** 22 MUST (#1–14, #54–56, #58–59; #15–17 at GATE 2, batch 4) · 1 BUG FIX (#19, dated) · 36 LATER (#57 added). *The owner's "SHOULD" maps to LATER since the freeze.*

---

## Part 1. The critical journeys

The one end-to-end run on record is the Stage 1 loop (`docs/STAGE1_LOOP.md`, run 2026-10-28..30). It covered a seeded, already-approved photographer paid in EUR, in Stripe test mode, on simulators: payout setup → request → accept → pay → deliver → select → review → settle → payout → admin approval → transfer. Everything else below is read from code and tests.

### a. Client: works end to end in EUR. Sign-up depends on Brevo being on. Nothing tells the client the rules or how to reach us.

| Step | Evidence | Status |
|---|---|---|
| Sign up, verify, log in, reset | `shared/auth/*_screen.dart`; `POST /v1/auth/register·login·verify-email/*·password-reset/*`; `test_auth_v1.py`, `test_brevo_sending.py` | Works. The codes arrive only once `EMAIL_SENDING_ENABLED=true` and the Brevo domain is set up. A verified email is not needed to book. |
| Find a photographer | `client/discover`, `client/pro_profile`; `/v1/discover/*`; `test_discovery.py`, `test_client_home_rows.py` | Works. A photographer shows only when `approved_public` **and** client browsing is on for their city (`launch_ops.py:405-415`). No admin page sets rollout cities; it is API only. The search screen is unreachable (BACKEND_GAPS). |
| Book, pay | `client/booking_request`, `booking_payment_controller.dart`; `POST /v1/pros/{id}/booking-requests`, `/v1/client/bookings/{id}/pay`; `test_client_booking_pay.py`, `test_missed_payment_webhook.py`, `test_stripe_reconcile.py` | Works in EUR. **No cancellation or refund rules are shown anywhere before paying.** |
| Gallery, choose, add-on window, download | `client/gallery/*`; `test_selection_*`, `test_selection_addons.py`, `test_download_payment_gate.py`, `test_review_gate.py` | Works. Downloads wait for a star rating or "Report a problem". |
| Review | `bookings/review_panel.dart`; `POST /v1/gigs/{id}/review`; `test_reviews.py` | Works. |
| **Breaks** | | GBP: the app formats every amount as € (`RMoney` falls back to EUR), so a GBP booking reads wrong. A client cannot cancel a paid booking and cannot open a dispute before delivery: `/v1/disputes` exists, but no screen uses it. **There is no way to contact us** anywhere in the app. |

### b. Photographer: works end to end for a EUR photographer the admin approves. A GBP photographer is paid wrong. Nothing is missing on the road to going live.

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
| 1 | Triage the money and KYC known failures (KF: ledger totals, redemption, KYC gating ×2): is the product or the test wrong? | Never diagnosed; one fails 401 before reaching the gate (BG "Eleven test failures") | **MUST** · batch 1 | S | A real money or KYC bug ships unseen | — |
| 2 | Dependency lockfile | No `poetry.lock`; two builds of one commit differed (BG) | **MUST** · batch 1 | S | Deploy-day breakage, unknown versions in production | — |
| 3 | Trusted proxy IP (`TRUSTED_PROXY_IPS`, one helper) | Leftmost `X-Forwarded-For` trusted in about 10 places (BG; `deps.py:190`) | **MUST** · batch 1 | S | Admin IP allowlist and rate limits bypassable; download IP evidence forgeable | Host (which proxy) |
| 4 | Error alerting (Sentry, EU region) for API, worker, beat and web admin, including failed emails and an admin list to resend them | None (• Part 1g) | **MUST** · batch 1 | M | 500s, failed emails and stuck jobs go unseen during the beta | Owner: Sentry account and DPA |
| 5 | Minimum app version and maintenance switch | None (•) | **MUST** · batch 2 | S | Build 1 can never be forced to update or stopped | — |
| 6 | Support channel: support@rawwers.com behind "Get help" in both apps (with user id, app version and request id), and as the reply-to on every email; fix the "Get in touch" and stale email-switch texts | None (• Part 1g) | **MUST** · batch 2 | S | Users stuck with money problems cannot reach us; Apple requires contact information | — (decided) |
| 7 | Terms, privacy and photographer agreement: versioned, accepted at sign-up and on becoming a pro, linked in both apps and on the web. Placeholder texts until the lawyer's | None (• Part 2) | **MUST** · batch 3 | M | No legal basis for contracts or processing; store listings need the privacy URL | **Lawyer** (texts) |
| 8 | Cancellation rule (decided, 4.4): every number an admin setting; shown before booking and before paying; a "Request cancellation" button that shows the rule and the refund amount and creates an admin task; the admin applies it by hand (price reduction) | Admin tool exists (`price_reduction.py`); no rule, text or request (•) | **MUST** · batch 3 | M | Consumer-law exposure and disputes with no agreed rule | Lawyer (wording) |
| 9 | Account deletion in both apps (anonymise, keep money records for the legal period, withdraw marketing consents, end sessions; refused while a booking, a balance or a dispute is open) | Missing (BG "Account deletion") | **MUST** · batch 3 | L | Apple rejects; GDPR erasure requests unanswerable | Lawyer and accountant (retention period) |
| 10 | Google Play account-deletion web page | Missing (BG) | **MUST** · batch 3 | S | Play Data safety form cannot be completed | Lawyer (text) |
| 11 | User-generated content safety: report a photographer, message or review; block in chat; admin report queue; admin hides a portfolio photo; photographer removes their own photo | None (• Part 1e) | **MUST** · batch 4 | M | App Store guideline 1.2 rejection; no takedown for an unlawful or unconsented photo | — |
| 12 | Release builds: Android upload key, release manifest check, production env files (API URL, live Stripe publishable key), iOS archive | Debug signing, localhost env (•) | **MUST** · batch 2 | S | Nothing can be distributed | Owner: signing keys, Apple and Google accounts |
| 13 | Database backups and a tested restore | None (`compose.prod.yml`) | **MUST** · batch 4 | S | One disk fault loses every booking and ledger | Owner: the deploy plan |
| 14 | GBP and EUR (decided, option A; **GBP main and the default for new users**, 2026-11-13): each photographer prices and is paid in one currency, the currency of their Stripe account's country; each user picks a display currency and sees an approximate conversion labelled with the charged currency. Design: `docs/MULTI_CURRENCY.md` | Package and gig carry a currency; payouts hard-coded to EUR; apps assume € (BG ×2) | **MUST** · batch M, after the owner approves the design | L | GBP clients and photographers see and receive wrong amounts | **Owner** (design approval), Stripe, accountant |
| 15 | SA3: error bodies never leak internals | Open (SA) | **MUST** · GATE 2, batch 4 | M | Information leak | — |
| 16 | SA1: verify and reset codes in plain text in the outbox | Open (SA, BG) | **MUST** · GATE 2, batch 4 | S | A database reader can take over accounts | — |
| 17 | SA2: the error-body security test (the chat-spam half was fixed in batch 1) | Open (SA) | **MUST** · GATE 2, batch 4 | S | The error-body rule stays untested | — |
| 18 | Stripe call timeout and retry | Library defaults; 10–20 s stalls seen (BG) | LATER | S | Slow screens and timeouts; recovers on retry | — |
| 19 | DST: bookable grid wrong on 2027-03-28 | Open (BG) | **BUG FIX**, dated: by 2027-01-31 | M | Zero-length or doubled slots for that night | — |
| 20 | Photographer "pause bookings" switch | One-way switch (BG) | LATER | S | Photographers who are away stay bookable (the workaround is clearing hours) | — |
| 21 | Admin Users page: search, see email, suspend, ban, lift | API only (•) | LATER | M | The admin works through the API by hand | — |
| 22 | Client notification settings screen | API only; unsubscribe links work (BG c1) | LATER | S | Switching email back on needs support | — |
| 23 | Push notifications | Not built (BG) | LATER (decided: none in the beta) | L | Requests are seen later (email covers the 48 h window) | — |
| 24 | Self-service cancellation that refunds by itself (client and photographer) | The beta has the request button (#8); the admin applies it | LATER | M | Support load | — |
| 25 | Client dispute or "problem" screen before delivery | API `/v1/disputes`, no screen; the cancellation request (#8) and support (#6) cover it | LATER | M | No-shows reach us only by email | — |
| 26 | App crash reporting | None; TestFlight and Play give basic crash data | LATER | S | Crashes are reported only by users | — |
| 27 | Fee-policy PATCH or admin screen | `PUT` replaces every field (BG) | LATER | S | A typo changes a fee | — |
| 28 | Remove the stale `deploy/docker-compose.{prod,staging}.yml` | Duplicates (BG) | LATER (with the deploy plan) | S | Deploying the wrong file | — |
| 29 | Notifications that link to screens the apps do not have | Open (BG b) | LATER | S | Tapping some notifications opens nothing | — |
| 30 | Client invite gate at sign-up | Pros are gated; clients are open (•) | LATER (decided: tester lists only, no invite code) | S | Strangers with a build could sign up (low risk while builds are invite-only) | — |
| 31 | Rollout cities admin page | API only | LATER | S | The owner's cities must be enabled by API call | — |
| 32 | Portuguese and Spanish: the apps have no localisation layer at all; email texts are English | (BG; • no `.arb`, no `flutter_localizations`) | LATER (decided) | L | — | Owner, translators, lawyer (language law) |
| 33 | Data export (self-service) | None; answer by email within a month | LATER | M | — | Lawyer |
| 34 | Change email or password while signed in | Reset by email works | LATER | S | — | — |
| 35 | Email verification required before booking | Not enforced | LATER | S | — | — |
| 36 | Flavor isolation: client `messages/thread_screen.dart` imports pro code | 1 import found (`thread_screen.dart:14`); the checker counts 3 | LATER | S | None for users | — |
| 37 | Mux video upload screen | Backend only | LATER | M | — | — |
| 38 | Referral screen | Backend only (BG) | LATER | M | — | — |
| 39 | Print store | Off (`ecom_enabled`) | LATER | L | — | — |
| 40 | The Shelf and RAWW in production | Built, off. Stays off (it is UK and GBP only); RAWW keep accruing silently and the expiry clock starts the day the Shelf opens (decided) | LATER | — | — | Lawyer (terms) |
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
| **54** | **UK consumer cancellation rules for dated leisure services.** The 14-day cancellation right of the Consumer Contracts Regulations 2013 has an exception for leisure services on a specific date (reg. 28(1)(b)); whether a photo shoot qualifies, and whether the 7-day and 48-hour defaults are fair under the Consumer Rights Act 2015 (Part 2, unfair terms), is the lawyer's call. The DMCC Act 2024 also bans fake or concealed-incentive reviews and requires the total price, with every mandatory charge, up front | The rule's numbers are admin settings (#8); the client pays the package price, with no fee on top; reviews come only from completed bookings (`test_reviews.py`); review rewards exist for clients (BG "client reward ladder") | **MUST** · in #8 and #7 (wording), no extra code expected | S | A cancellation term that is unenforceable, or a review incentive that breaks the DMCC Act | **Lawyer** |
| **55** | **UK GDPR and the ICO.** A UK company pays the ICO data protection fee (registration). A company outside the UK serving UK users needs a UK representative (UK GDPR Art. 27) and, the lawyer to confirm, may not need the fee. A UK company serving EU photographers needs an **EU** representative (EU GDPR Art. 27) instead. Which applies depends on the company (`docs/MULTI_CURRENCY.md`, Company scenarios) | `PRIVACY_NOTICE_INPUTS.md` (inputs only) | **MUST** · outside the code, in the privacy notice (#7) | — | Processing without the registration or representative the law requires | **Lawyer**, owner (company) |
| **56** | **UK VAT on the platform fee.** A UK company registers above the £90,000 threshold (voluntarily below it); a non-UK company supplying UK customers is a non-established taxable person with **no threshold**. Who the fee is supplied to (photographer, often unregistered) decides the place of supply | `country_tax_rule` holds one row per country (rate, threshold, number format); each gig stamps `vat_rate_percent`, `vat_status`, `vat_number` (`models/gig.py:110-115`); the invoice shows the fee and its VAT | **MUST** · outside the code; production data: a `GB` row in `country_tax_rule` | S | Wrong or missing VAT on every fee | **Accountant** |
| **57** | **UK addresses and postcodes.** The shoot address is free text (`location_text`), so UK addresses work as typed. Shelf addresses require a postcode but do not check its format (`services/addresses.py:30-41`). No address autocomplete | Works for the beta | LATER (UK postcode format check with the Shelf; autocomplete after the beta) | S | A mistyped postcode on a Shelf order | — |
| **58** | **Payout bank details for UK photographers.** Stripe's hosted Express onboarding collects the UK sort code and account number; we store none. Needed: `DEFAULT_CONNECT_COUNTRY` is `PT` (`config.py:60`) and must follow the photographer's country (GB); UK accounts are created with the **full** service agreement (Stripe's answer, `MULTI_CURRENCY.md`), recorded on the account. The manual bank method (`bank_details_encrypted`, a free-form dict) has no UK shape and is not used in the beta | Express onboarding works for a PT account in test mode | **MUST** · batch M **(high-risk: money)** | S | UK photographers cannot be paid | Stripe (cross-border eligibility, in writing) |
| **59** | **Everything in the code that assumes the EU or the euro** (list below the table). GBP becomes the default | See the list | **MUST** · batch M **(high-risk: money, migration)** | in M's estimate | GBP users see €, and defaults create EUR rows for UK users | — |

**#59, the EU and euro assumptions found (2026-11-13, read-only search):**
- **Currency defaults:** `default="EUR"` on 20 currency columns (bookings, gigs, payments' neighbours, packages, price caps, galleries, credit, BI, dormant store tables) and `currency: str = "EUR"` in 9 schemas; `GET /v1/pro/me/pricing/niches/{id}` defaults to EUR; `or "EUR"` fallbacks (`MULTI_CURRENCY.md` 1.1). Batch M removes the defaults (a missing currency is a bug) and makes GBP the default where a default is still needed.
- **Payouts:** `MIN_PAYOUT_EUR` 50 and `Transfer.create(currency="eur")` (`services/payouts.py:40, 498`); earnings, balances, holds and payouts are `_eur` columns.
- **Apps and web:** `RMoney` falls back to EUR (`app/lib/core/format/money.dart:33`); "€" literals in four app screens; the web admin's `money()` defaults to EUR and BI formats €.
- **Country:** `DEFAULT_CONNECT_COUNTRY=PT` and `WARMUP_HOME_COUNTRY=PT` (`config.py:38, 60`); the prints EU country list (`prints_fulfillment.py:44`, dormant).
- **Time zone:** `Europe/Lisbon` is the default for notification quiet hours, email times and call compliance (`config.py:231`, `models/communication.py:108, 282`, `email_texts.py:70`, `call_compliance.py:30, 80`). Lisbon keeps the same clock as London all year, so nothing is wrong today; batch M changes the default to `Europe/London`.
- **Reporting:** BI counts EUR only and leaves other lines out (`services/bi.py`, `bi_stripe.py:104`); the liquid and money-owed views read EUR only (`bi.py:666`).
- **Payment methods:** automatic methods without redirects; the comment names iDEAL, Bancontact and Multibanco (`payment_intents.py:337`). Cards and wallets cover the UK; nothing to change.
- **Not an assumption:** the web admin already formats dates `en-GB`; the apps' formatter already knows £.

---

## 4.2. The batch plan (decided 2026-11-11)

**High-risk** means money, authentication, authorization, IP handling, email or a migration. The whole related test files are run before such a commit. A batch is about a day of agent work unless noted.

| Batch | Items | Notes |
|---|---|---|
| **1** | #1 money and KYC known failures; #2 lockfile; #3 client IP header **(high-risk)**; #4 Sentry and failed emails **(high-risk: email)** | Built 2026-11-11. |
| **M. Multi-currency** | #14, #58, #59, from `docs/MULTI_CURRENCY.md` **(high-risk: money, migrations)**; GBP the default | Starts only after the owner approves the design. Several days; the estimate and the order (the batches safe in both company scenarios first) are in the design. |
| **2** | #5 minimum app version and maintenance switch; #6 contact (support@rawwers.com); #12 release builds | After batch 2 a TestFlight or Play internal build is possible. |
| **3** | #8 cancellation rule and request; #7 terms, privacy and photographer agreement acceptance with placeholder texts **(high-risk: migration)**; #9 account deletion **(high-risk: personal data, money records, migration)**; #10 Google Play deletion page | About 3 days. The lawyer writes the real texts. |
| **4** | #11 report, block and takedown **(high-risk: migration, authorization)**; #13 backups; GATE 2 items #15–17 **(high-risk: security)** | Backups follow the deploy plan. |

Bug fixes, such as #19 (dated), go in when found.

---

## 4.3. The cut list: not built before the beta

| Item | Why it is safe to wait |
|---|---|
| Push (#23) | Decided: none in the beta. Email reaches the photographer within the 48 h request window, and in-app covers the rest. |
| Automatic self-service cancellation and the dispute screen (#24, #25) | The beta has the cancellation request (#8); with a small group, the admin applies the rule. |
| Admin Users, rollout and fee pages (#21, #27, #31) | The API does all three. Each is an occasional admin act. |
| Pause bookings (#20) | Clearing working hours or adding a blackout already stops bookings. |
| Client notification switches (#22) | Every email has a working unsubscribe link. |
| Crash SDK (#26) | TestFlight and Play Console collect crashes from testers; server errors are covered by #4. |
| Client invite code (#30) | Decided: the TestFlight and Play tester lists are the gate. |
| Portuguese and Spanish (#32) | Decided: LATER. |
| Data export, email and password change (#33, #34) | Rare. Handled by email within the legal month. |
| Referral, Mux video upload, print store, Shelf and RAWW (#37–#40) | Growth or optional features. All are off or unreachable. |
| Short payment, delayed methods, booking history (#41–#43) | Delayed methods stay disabled in Stripe, so short payments do not occur with cards. History is cosmetic. |
| Stripe timeouts (#18) | Retrying recovers; revisit with the deploy plan's network. |
| Everything else marked LATER | No core journey depends on it. |

---

## 4.4. The owner's decisions (decided 2026-11-11)

1. **Currencies: EUR and GBP are both required for launch. Option A.**
   - Each photographer prices and is paid in **one** currency, EUR or GBP.
   - Each user chooses a display currency and sees an approximate conversion, clearly labelled with the currency actually charged (for example "about £850, charged in €1,000").
   - The platform takes no exchange-rate risk. Paying in the client's own currency (option B) is not wanted.
   - This moves GBP from LATER to MUST (#14). The design is `docs/MULTI_CURRENCY.md`.
2. **UK first (decided 2026-11-13).** The first wave is the **United Kingdom**. GBP is the main currency and the default for new users; EUR stays supported as the second currency. The apps stay in English. The Shelf (UK, GBP) fits this wave. The UK cities are chosen by the owner later.
3. **Cancellation rule.** These are defaults, and every number is an admin setting, not hard-coded:
   - The client cancels free until 7 days before the shoot, gets 50% back until 48 hours before, and nothing after.
   - A photographer who cancels means a full refund.
   - Weather or illness means a reschedule first.
   - What the platform keeps from a client's cancellation is a normal earning: the photographer's share plus the fee, with the normal RAWW credit.
   - **In the beta:**
     - The apps show the rule before booking and before paying.
     - A "Request cancellation" button shows the rule and the refund amount, and creates an admin task.
     - The admin applies it by hand.
   - The lawyer confirms the wording.
4. **Entry:** TestFlight and Play tester lists only, no invite code.
5. **No push notifications in the beta.**
6. **Account deletion:** refused while a booking, a balance or a dispute is open. Otherwise the account is anonymised, and money records are kept for the legal period.
7. **Error reporting:** Sentry, EU region.
8. **Support address:** support@rawwers.com, in both apps and as the reply-to on every email.
9. **RAWW while the Shelf is off:** keep accruing silently. The expiry clock starts the day the Shelf opens. The Shelf stays off (it remains UK and GBP only). *(2026-11-13: the Shelf stays OFF: it needs the terms and the RAWW expiry review first.)*
10. **Hosting and backups:** decided in the deploy plan.
11. **Portuguese and Spanish translations:** LATER.
12. **After the freeze:** only MUST items and bug fixes. Anything else goes to LATER.

---

## 4.5. Outside the code (you)

- **Company and accounts:**
  - Company registration and a D-U-N-S number, needed for Apple and Google organisation accounts. A new personal Play account would need 12 testers for 14 days of closed testing before production; an organisation account is exempt.
  - Apple Developer Program and Google Play Console.
  - The Android upload key. iOS signing (team, profiles).
- **Lawyer:**
  - Terms, privacy policy, photographer agreement and cancellation wording.
  - The photographer agreement states how a lost dispute that is the photographer's fault is recovered (M9, `MULTI_CURRENCY.md` section 8): the held earning, then future earnings, then a transfer reversal only if the admin chooses, then written off after 90 days; not their fault, the platform absorbs it. Stripe fees are never passed on (M10).
  - The deletion-page text and the marketing-consent wording.
  - UK data protection (#55): the ICO fee for a UK company, or a UK Article 27 representative for a non-UK one; an EU representative if a UK company serves EU photographers.
  - UK consumer law for the cancellation rule and reviews (#54).
  - The IP retention figures (`PRIVACY_NOTICE_INPUTS.md`).
  - Stripe's cross-border payouts: the UK photographers accept Stripe's **full** service agreement, and Stripe's terms for them (`MULTI_CURRENCY.md`, Stripe answers).
- **Accountant:** UK VAT on the platform fee (#56), invoices, record retention (the legal period for deletion), and handling of EUR and GBP: the GBP balance held at Stripe, the multi-currency settlement and international card fees as costs, and the base currency of the books (`MULTI_CURRENCY.md`, Company scenarios).
- **Company:** which company runs the platform, UK or Portuguese (`MULTI_CURRENCY.md`, Company scenarios); it changes the Stripe account, VAT, data protection and the fees.
- **Stripe:** answers received 2026-11-13 from Stripe's chat, to be confirmed in writing by a Stripe human (`docs/MULTI_CURRENCY.md`, Stripe answers).
  - **Enable GBP as a settlement currency and link a GBP bank account** (UK or Gibraltar) to the platform account; without it GBP charges are converted to EUR.
  - Written confirmation of cross-border payout eligibility for UK connected accounts and of the fee figures.
  - Live activation and the Connect platform profile and branding.
  - Keep delayed payment methods off in live mode.
  - Live webhook endpoints and secrets, and the statement descriptor.
- **Store listings:**
  - Privacy policy URL, support URL (support@rawwers.com), the App Privacy labels and Play Data safety (inventory above), screenshots and descriptions.
  - TestFlight external group (Beta App Review) and Play internal testers.
  - **Reviewer accounts in production:** a client, plus an approved photographer already through Connect, in a city with browsing on.
- **Domain and DNS:**
  - The API host with TLS, `API_PUBLIC_URL`, https `CONNECT_RETURN_URL` and `CONNECT_REFRESH_URL`.
  - Fix the dead SPF include on rawwers.com; DKIM and DMARC for the sender.
- **Sentry:** an EU-region organisation, a DPA, and one DSN per service (DEPLOY_CHECKLIST).
- **Brevo:** the DPA, authorised IPs (or none) for the production host, the sender address, then `EMAIL_SENDING_ENABLED=true`.
- **Mux and R2:** production environments, the webhook secret and production buckets.
- **Production data** (DEPLOY_CHECKLIST):
  - Import the price caps (zero rows today; GBP caps for the UK) and enable the UK cities the owner chooses later.
  - A `GB` row in `country_tax_rule` (#56).
  - Import the camera reference and set `settlement_delay_days`.
  - Run the BI backfill.
  - Keep `shelf_enabled` off.
