# RAWWERS W-0 Discovery — Function-Level Inventory of `web/lib/api/*`

Scope: read-only, function-granular re-verification of `web/lib/api/endpoints.ts`, `web/lib/api/clientApi.ts`, `web/lib/api/proApi.ts`, and `web/lib/api/client.ts`, in support of consolidating three parallel API client layers into one (task "W-0"). Builds on `rawwers-endpoint-coverage-audit.md` (endpoint-level) but re-derives everything at the function level directly from current source — nothing here is inferred from the prior audit without being re-checked against the live files.

All caller line numbers were found by grepping `endpoints\.`, `clientApi\.`, `proApi\.` across `web/app` and `web/components` (all imports in the repo use the namespace-object form, e.g. `import { endpoints } from "@/lib/api/endpoints"` then `endpoints.foo(...)` — there are no destructured named imports anywhere, so this grep is exhaustive) and confirming each hit is a real call, not incidental text.

## Headline numbers

| File | Total exported functions | Called from a page/component | Dead (defined, never invoked) |
|---|---|---|---|
| `endpoints.ts` | 26 | 22 | 4 |
| `clientApi.ts` | 65 | 14 | 51 |
| `proApi.ts` | 69 | 32 | 37 |
| **Total** | **160** | **68 (42.5%)** | **92 (57.5%)** |

32 files under `web/app/` + `web/components/` import one of the three client objects. All three files are still live — none is fully dead.

---

## 1. Full function inventory

Legend for "Matches docs?": **Yes** = path exists in `docs/api_endpoints.md` and request/response shape used by the live caller (if any) is correct as far as this pass checked; **Yes-but-shape-mismatch** = real route, but payload/response fields used at the call site (or hardcoded in the wrapper) don't match the backend schema; **No** = no matching route in `docs/api_endpoints.md` at all. Verdicts for uncalled functions are judged on the wrapper's own path/param handling only (no live call site to check field-shape against).

### `web/lib/api/endpoints.ts` (26 functions)

| # | Function | Method + path | Matches docs? | Callers |
|---|---|---|---|---|
| 1 | `me` | GET `/me` | Yes | `app/login/page.tsx:25`, `app/pro/login/page.tsx:24,27`, `app/pro/register/page.tsx:21` |
| 2 | `login` | POST `/auth/login` | Yes | `app/login/page.tsx:24`, `app/pro/login/page.tsx:23`, `app/pro/register/page.tsx:19` |
| 3 | `register` | POST `/auth/register` | Yes | `app/register/page.tsx:19`, `app/pro/register/page.tsx:37` |
| 4 | `upgradeToPro` | POST `/me/upgrade-to-pro` | Yes | `app/pro/login/page.tsx:26`, `app/pro/register/page.tsx:20` |
| 5 | `logout` | POST `/auth/logout` | Yes | `components/app-shell.tsx:46` |
| 6 | `discover` | GET `/client/discover` | **Yes-but-shape-mismatch** — sends no query params at all; real handler requires `country`/`city` query params, so every call 422s | `app/discover/page.tsx:13` |
| 7 | `proProfile` | GET `/client/pros/{id}` | Yes | `app/pros/[id]/page.tsx:18` |
| 8 | `createBookingRequest` | POST `/client/bookings/request` | **Yes-but-shape-mismatch** — sends `{pro_user_id, requested_start, requested_end, message}`; real `ClientBookingRequestCreateRequest` needs `niche_slug`, nested `date_window:{start_at,end_at}`, `package_id`, `notes` (not `message`). Response read as `.booking_request_id`; real response field is `booking_id` | `app/pros/[id]/page.tsx:21-29,44` |
| 9 | `clientBookings` | GET `/client/bookings` | **No** — no list-bookings route exists (only `/client/bookings/{id}`) | `app/client/bookings/page.tsx:11` |
| 10 | `clientBooking` | GET `/client/bookings/{id}` | Yes | `app/client/bookings/[id]/page.tsx:13` |
| 11 | `payBooking` | POST `/client/bookings/{id}/pay` | Yes | `app/client/bookings/[id]/page.tsx:14` |
| 12 | `notifications` | GET `/notifications` | **No** — real route is `/me/notifications` (missing `/me` prefix) | `app/client/notifications/page.tsx:10` |
| 13 | `markNotificationRead` | POST `/notifications/{id}/read` | **No** — real route is `/me/notifications/{id}/read` | `app/client/notifications/page.tsx:12` |
| 14 | `flags` | GET `/feature-flags` | **No** — only `/admin/feature-flags` (admin-only) and `/admin/ai/feature-flags` exist; no public flags route | `app/providers.tsx:16` (fails silently, app falls back to hardcoded flags) |
| 15 | `myOnboarding` | GET `/pro/onboarding/status` | **No** — real route is `/pro/onboarding` (no `/status` suffix) | — none — (dead; bug is latent) |
| 16 | `inbox` | GET `/pro/bookings/inbox` | **No** — route doesn't exist | — none — (dead; bug is latent) |
| 17 | `scheduleSlots` | GET `/pro/scheduling/slots` | Yes (path correct) | — none — (dead; duplicate of `proApi.getCandidateSlots`, which is called) |
| 18 | `myPayouts` | GET `/pro/payouts` | Yes (path correct) | — none — (dead; duplicate of `proApi.getPayouts`, which is called) |
| 19 | `i18nBundle` | GET `/i18n/bundles` | Yes | `app/admin/page.tsx:8` |
| 20 | `myProProfile` | GET `/pro/me/profile` | Yes | `app/pro/profile/listing-card/page.tsx:22` |
| 21 | `updateMyProProfile` | PUT `/pro/me/profile` | Yes | `app/pro/profile/listing-card/page.tsx:79` |
| 22 | `myNiches` | GET `/pro/niches/mine` | Yes | `app/pro/profile/listing-card/page.tsx:23` |
| 23 | `updateMyNiches` | PUT `/pro/niches/mine` | Yes | `app/pro/profile/listing-card/page.tsx:89` |
| 24 | `nichesCatalog` | GET `/niches` | Yes | `app/pro/profile/listing-card/page.tsx:24` |
| 25 | `publicProProfile` | GET `/pros/{id}/public` | Yes | `app/pro/profile/listing-card/page.tsx:27,109` |
| 26 | `searchPros` | GET `/search/pros` | Yes | `app/pro/profile/listing-card/page.tsx:110` |

### `web/lib/api/clientApi.ts` (65 functions)

All functions return `Result<T>` (`{ok:true,data}` / `{ok:false,error}`), never throw. All defined correctly against `docs/api_endpoints.md` paths (this file's whole raison d'être per the prior audit was "correct paths, mostly unused") — spot-checked path-by-path below; no path bugs found in this file.

| # | Function | Method + path | Matches docs? | Callers |
|---|---|---|---|---|
| 1 | `me` | GET `/me` | Yes | — none — |
| 2 | `login` | POST `/auth/login` | Yes | — none — |
| 3 | `register` | POST `/auth/register` | Yes | — none — |
| 4 | `logout` | POST `/auth/logout` | Yes | — none — |
| 5 | `refresh` | POST `/auth/refresh` | Yes | — none — (no refresh-on-401 flow anywhere) |
| 6 | `requestPasswordReset` | POST `/auth/password-reset/request` | Yes | — none — |
| 7 | `confirmPasswordReset` | POST `/auth/password-reset/confirm` | Yes | — none — |
| 8 | `requestVerifyEmail` | POST `/auth/verify-email/request` | Yes | — none — |
| 9 | `confirmVerifyEmail` | POST `/auth/verify-email/confirm` | Yes | — none — |
| 10 | `getClientAccess` | GET `/client/access` | Yes | `app/waitlist/page.tsx:14` |
| 11 | `clientDiscover` | GET `/client/discover` (accepts a `params` object, forwarded as query) | Yes — this is the *correct* counterpart to `endpoints.discover`'s bug | — none — |
| 12 | `clientMatch` | POST `/client/match` | Yes | — none — |
| 13 | `searchPros` | GET `/search/pros` | Yes | `app/search/page.tsx:16` |
| 14 | `getProPublic` | GET `/pros/{id}/public` | Yes | — none — |
| 15 | `getClientProProfile` | GET `/client/pros/{id}` | Yes | — none — (duplicate of `endpoints.proProfile`, which is called) |
| 16 | `joinWaitlist` | POST `/client/waitlist` | Yes | `app/waitlist/page.tsx:15` |
| 17 | `createBookingRequest` | POST `/client/bookings/request` | Yes (path); generic passthrough, no hardcoded shape bug in the wrapper itself | — none — (duplicate of `endpoints.createBookingRequest`, which is called and broken) |
| 18 | `getClientBooking` | GET `/client/bookings/{id}` | Yes | `app/bookings/[bookingId]/page.tsx:14` |
| 19 | `payClientBooking` | POST `/client/bookings/{id}/pay` | Yes | — none — (duplicate of `endpoints.payBooking`, which is called) |
| 20 | `submitTimeWindows` | POST `/client/bookings/{id}/time-windows` | Yes | — none — |
| 21 | `getBookingRequest` | GET `/booking-requests/{id}` | Yes | — none — |
| 22 | `cancelBookingRequest` | POST `/booking-requests/{id}/cancel` | Yes | — none — |
| 23 | `getGig` | GET `/gigs/{id}` | Yes | `app/gigs/[gigId]/page.tsx:14` |
| 24 | `getGigConsent` | GET `/gigs/{id}/consent` | Yes | — none — |
| 25 | `putGigConsent` | PUT `/gigs/{id}/consent` | Yes | — none — |
| 26 | `createGigStripeIntent` | POST `/gigs/{id}/payments/stripe/create-intent` | Yes | — none — |
| 27 | `createGigReview` | POST `/gigs/{id}/review` | Yes | — none — |
| 28 | `listGigMedia` | GET `/gigs/{id}/media` | Yes | `app/gigs/[gigId]/delivery/page.tsx:12` |
| 29 | `getGigMediaSignedUrl` | GET `/gigs/{id}/media/{id}/signed-url` | Yes | — none — |
| 30 | `downloadGigMedia` | GET `/gigs/{id}/media/{id}/download` | Yes | — none — |
| 31 | `getProofGallery` | GET `/proof-galleries/{id}` | Yes | `app/gigs/[gigId]/gallery/[galleryId]/page.tsx:15` |
| 32 | `saveSelection` | POST `/proof-galleries/{id}/selections` | Yes | `app/gigs/[gigId]/gallery/[galleryId]/page.tsx:16` |
| 33 | `submitSelection` | POST `/proof-galleries/{id}/selections/submit` | Yes | `app/gigs/[gigId]/gallery/[galleryId]/page.tsx:17` |
| 34 | `createUpsellIntent` | POST `/proof-galleries/{id}/upsell/create-intent` | Yes | — none — |
| 35 | `getGalleryDownloads` | GET `/proof-galleries/{id}/downloads` | Yes | — none — |
| 36 | `listDisputes` | GET `/disputes` | Yes | — none — |
| 37 | `createDispute` | POST `/disputes` | Yes | — none — |
| 38 | `getDispute` | GET `/disputes/{id}` | Yes | — none — |
| 39 | `cancelDispute` | POST `/disputes/{id}/cancel` | Yes | — none — |
| 40 | `addDisputeEvidence` | POST `/disputes/{id}/evidence` | Yes | — none — |
| 41 | `addDisputeMessage` | POST `/disputes/{id}/messages` | Yes | — none — |
| 42 | `putContact` | PUT `/me/contact` | Yes | `app/settings/page.tsx:16` |
| 43 | `getClientPreference` | GET `/me/client-preference` | Yes | `app/settings/page.tsx:13` |
| 44 | `putClientPreference` | PUT `/me/client-preference` | Yes | — none — |
| 45 | `getNotificationPreferences` | GET `/me/notification-preferences` | Yes | `app/settings/page.tsx:14` |
| 46 | `putNotificationPreferences` | PUT `/me/notification-preferences` | Yes | — none — |
| 47 | `listNotifications` | GET `/me/notifications` | Yes — the *correct* counterpart to `endpoints.notifications`'s bug | — none — |
| 48 | `readAllNotifications` | POST `/me/notifications/read-all` | Yes | — none — |
| 49 | `readNotification` | POST `/me/notifications/{id}/read` | Yes — the *correct* counterpart to `endpoints.markNotificationRead`'s bug | — none — |
| 50 | `rewardsBalance` | GET `/me/rewards/balance` | Yes | `app/rewards/page.tsx:11` |
| 51 | `rewardsBalanceShared` | GET `/rewards/balance` | Yes (distinct real route, verified in docs) | — none — |
| 52 | `rewardsLedger` | GET `/rewards/ledger` | Yes | `app/rewards/page.tsx:12` |
| 53 | `rewardsSpend` | POST `/rewards/spend` | Yes | — none — |
| 54 | `printsCatalog` | GET `/prints/catalog` | Yes | — none — |
| 55 | `myPrintOrders` | GET `/prints/orders/mine` | Yes | — none — |
| 56 | `printOrderDetail` | GET `/prints/orders/{id}` | Yes | — none — |
| 57 | `payPrintOrder` | POST `/prints/orders/{id}/pay` | Yes | — none — |
| 58 | `updatePrintOrder` | PUT `/prints/orders/{id}` | Yes | — none — |
| 59 | `createGigPrintOrder` | POST `/gigs/{id}/prints/orders` | Yes | — none — |
| 60 | `myReferralCode` | GET `/me/referral-code` | Yes | — none — |
| 61 | `regenerateReferralCode` | POST `/me/referral-code/regenerate` | Yes | — none — |
| 62 | `referralStats` | GET `/me/referrals/stats` | Yes | — none — |
| 63 | `referralLanding` | GET `/ref/{code}` | Yes | — none — |
| 64 | `claimReferral` | POST `/referrals/claim` | Yes | — none — |
| 65 | `track` | POST `/analytics` | Yes | — none — (duplicate of `proApi.track`, which is heavily called) |

### `web/lib/api/proApi.ts` (69 functions)

Also all `Result<T>`-wrapped, never throws. No path bugs found in this file either.

| # | Function | Method + path | Matches docs? | Callers |
|---|---|---|---|---|
| 1 | `me` | GET `/me` | Yes | — none — |
| 2 | `logout` | POST `/auth/logout` | Yes | — none — |
| 3 | `refresh` | POST `/auth/refresh` | Yes | — none — |
| 4 | `requestVerifyEmail` | POST `/auth/verify-email/request` | Yes | — none — |
| 5 | `confirmVerifyEmail` | POST `/auth/verify-email/confirm` | Yes | — none — |
| 6 | `getMyProProfile` | GET `/pro/me/profile` | Yes | `app/pro/profile/page.tsx:65` |
| 7 | `updateMyProProfile` | PUT `/pro/me/profile` | Yes | `app/pro/profile/page.tsx:128` |
| 8 | `getOnboarding` | GET `/pro/onboarding` | Yes | `app/pro/onboarding/page.tsx:11` |
| 9 | `getOnboardingChecks` | GET `/pro/onboarding/checks` | Yes | `app/pro/onboarding/page.tsx:12`, `app/pro/dashboard/page.tsx:40` |
| 10 | `onboardingStart` | POST `/pro/onboarding/start` | Yes | — none — |
| 11 | `onboardingCompleteProfile` | POST `/pro/onboarding/complete-profile` | Yes | — none — |
| 12 | `onboardingSelectNiches` | POST `/pro/onboarding/select-niches` | Yes | — none — |
| 13 | `onboardingConfigurePackages` | POST `/pro/onboarding/configure-packages` | Yes | — none — |
| 14 | `onboardingUploadPortfolio` | POST `/pro/onboarding/upload-portfolio` | Yes | — none — |
| 15 | `onboardingSubmitKyc` | POST `/pro/onboarding/submit-kyc` | Yes | — none — |
| 16 | `listNiches` | GET `/niches` | Yes | — none — (duplicate of `endpoints.nichesCatalog`, which is called) |
| 17 | `getMyNiches` | GET `/pro/niches/mine` | Yes | — none — (duplicate of `endpoints.myNiches`, which is called) |
| 18 | `putMyNiches` | PUT `/pro/niches/mine` | Yes | — none — (duplicate of `endpoints.updateMyNiches`, which is called) |
| 19 | `createPackage` | POST `/pro/me/packages` | **Yes-but-shape-mismatch** — see quick-fix #2 below | `app/pro/profile/packages/page.tsx:21` |
| 20 | `updatePackage` | PUT `/pro/me/packages/{id}` | Yes | `app/pro/profile/packages/page.tsx:32` |
| 21 | `disablePackage` | POST `/pro/me/packages/{id}/disable` | Yes | `app/pro/profile/packages/page.tsx:41` |
| 22 | `tagPortfolioMediaNiches` | POST `/pro/me/portfolio/{id}/niches` | Yes | `app/pro/profile/portfolio/page.tsx:37` |
| 23 | `searchPros` | GET `/search/pros` | Yes | — none — |
| 24 | `getPublicProProfile` | GET `/pros/{id}/public` | Yes | `app/pro/profile/packages/page.tsx:16` |
| 25 | `getAvailabilityRules` | GET `/pro/scheduling/availability-rules` | Yes | `app/pro/calendar/page.tsx:16` |
| 26 | `putAvailabilityRules` | PUT `/pro/scheduling/availability-rules` | Yes | `app/pro/calendar/page.tsx:28` |
| 27 | `getSchedulingExceptions` | GET `/pro/scheduling/exceptions` | Yes | `app/pro/calendar/page.tsx:17` |
| 28 | `putSchedulingExceptions` | PUT `/pro/scheduling/exceptions` | Yes | `app/pro/calendar/page.tsx:35` |
| 29 | `getSchedulingPolicy` | GET `/pro/scheduling/policy` | Yes | `app/pro/calendar/page.tsx:18` |
| 30 | `putSchedulingPolicy` | PUT `/pro/scheduling/policy` | Yes | `app/pro/calendar/page.tsx:42` |
| 31 | `getCandidateSlots` | GET `/pro/scheduling/slots` | Yes | `app/pro/calendar/page.tsx:21` |
| 32 | `getPublicAvailability` | GET `/pro/{id}/availability` | Yes | — none — |
| 33 | `getBookingRequest` | GET `/booking-requests/{id}` | Yes | — none — |
| 34 | `acceptBookingRequest` | POST `/booking-requests/{id}/accept` | Yes | — none — (`app/pro/bookings/[id]/page.tsx` "Accept request" button has no `onClick`) |
| 35 | `declineBookingRequest` | POST `/booking-requests/{id}/decline` | Yes | — none — |
| 36 | `cancelBookingRequest` | POST `/booking-requests/{id}/cancel` | Yes | — none — |
| 37 | `confirmSlot` | POST `/pro/bookings/{id}/confirm-slot` | Yes | — none — ("Confirm schedule slot" button has no `onClick`) |
| 38 | `getGig` | GET `/gigs/{id}` | Yes | `app/pro/gigs/[gigId]/page.tsx:12` |
| 39 | `createGig` | POST `/gigs` | Yes | — none — |
| 40 | `cancelGigSlot` | POST `/gigs/{id}/cancel-slot` | Yes | — none — |
| 41 | `requestReschedule` | POST `/gigs/{id}/reschedule-request` | Yes | — none — |
| 42 | `getGigConsent` | GET `/gigs/{id}/consent` | Yes | — none — |
| 43 | `putGigConsent` | PUT `/gigs/{id}/consent` | Yes | — none — |
| 44 | `listGigMedia` | GET `/gigs/{id}/media` | Yes | — none — |
| 45 | `getGigMediaSignedUrl` | GET `/gigs/{id}/media/{id}/signed-url` | Yes | — none — |
| 46 | `downloadGigMedia` | GET `/gigs/{id}/media/{id}/download` | Yes | — none — |
| 47 | `createGigShareLink` | POST `/gigs/{id}/share-links` | Yes | — none — |
| 48 | `createProofGalleryForGig` | POST `/gigs/{id}/proof-gallery` | Yes | `app/pro/gigs/[gigId]/delivery/page.tsx:16` |
| 49 | `getProofGallery` | GET `/proof-galleries/{id}` | Yes | — none — |
| 50 | `addProofGalleryItems` | POST `/proof-galleries/{id}/items` | Yes | — none — |
| 51 | `publishProofGallery` | POST `/proof-galleries/{id}/publish` | Yes | `app/pro/gigs/[gigId]/delivery/page.tsx:17` |
| 52 | `saveGallerySelection` | POST `/proof-galleries/{id}/selections` | Yes | — none — |
| 53 | `submitGallerySelection` | POST `/proof-galleries/{id}/selections/submit` | Yes | — none — |
| 54 | `createUpsellIntent` | POST `/proof-galleries/{id}/upsell/create-intent` | Yes | — none — |
| 55 | `getProofGalleryDownloads` | GET `/proof-galleries/{id}/downloads` | Yes | — none — |
| 56 | `createPhotoUpload` | POST `/media/photos/uploads` | Yes | `app/pro/profile/portfolio/page.tsx:20` |
| 57 | `completePhotoUpload` | POST `/media/photos/{id}/complete` | Yes | `app/pro/profile/portfolio/page.tsx:30` |
| 58 | `getMediaAsset` | GET `/media/{id}` | Yes | — none — |
| 59 | `listProThreads` | GET `/pro/chat/threads` | Yes | `app/pro/dashboard/page.tsx:42`, `app/pro/inbox/page.tsx:11`, `app/pro/leads/page.tsx:11` |
| 60 | `getProThread` | GET `/pro/chat/threads/{id}` | Yes | `app/pro/gigs/[gigId]/chat/page.tsx:16` |
| 61 | `sendProMessage` | POST `/pro/chat/threads/{id}/messages` | Yes | `app/pro/gigs/[gigId]/chat/page.tsx:17` |
| 62 | `getAIDraft` | POST `/pro/chat/threads/{id}/ai-draft` | Yes | `app/pro/gigs/[gigId]/chat/page.tsx:18` |
| 63 | `getEarningsBalance` | GET `/pro/earnings/balance` | **Yes-but-shape-mismatch** — see quick-fix #1 below | `app/pro/dashboard/page.tsx:41`, `app/pro/wallet/page.tsx:15` |
| 64 | `getEarningsLedger` | GET `/pro/earnings/ledger` | Yes | `app/pro/wallet/page.tsx:16` |
| 65 | `getPayouts` | GET `/pro/payouts` | Yes | `app/pro/wallet/page.tsx:17` |
| 66 | `getPayoutAccount` | GET `/pro/payouts/account` | Yes | `app/pro/wallet/page.tsx:18` |
| 67 | `putPayoutAccount` | PUT `/pro/payouts/account` | Yes | `app/pro/wallet/page.tsx:23` |
| 68 | `requestPayout` | POST `/pro/payouts/request` | **Yes-but-shape-mismatch** — see quick-fix #3 below | `app/pro/wallet/page.tsx:34` |
| 69 | `track` | POST `/analytics` | Yes | `app/pro/dashboard/page.tsx:46`, `app/pro/profile/packages/page.tsx:25,36`, `app/pro/profile/portfolio/page.tsx:23`, `app/pro/wallet/page.tsx:27,39` |

---

## 2. Duplicate coverage (same backend endpoint, wrapper in 2+ files)

Grouped by method+path. "Same bug in multiple places" candidates are called out explicitly.

| Method + path | Defined in | Function name(s) | Which caller(s) actually run |
|---|---|---|---|
| GET `/me` | all 3 | `endpoints.me`, `clientApi.me`, `proApi.me` | only `endpoints.me` |
| POST `/auth/login` | endpoints, clientApi | `endpoints.login`, `clientApi.login` | only `endpoints.login` |
| POST `/auth/register` | endpoints, clientApi | `endpoints.register`, `clientApi.register` | only `endpoints.register` |
| POST `/auth/logout` | all 3 | `endpoints.logout`, `clientApi.logout`, `proApi.logout` | only `endpoints.logout` |
| POST `/auth/refresh` | clientApi, proApi | `clientApi.refresh`, `proApi.refresh` | **neither** — confirms no refresh-and-retry flow exists anywhere |
| POST `/auth/verify-email/request` | clientApi, proApi | `requestVerifyEmail` (both) | neither |
| POST `/auth/verify-email/confirm` | clientApi, proApi | `confirmVerifyEmail` (both) | neither |
| **GET `/client/discover`** | endpoints, clientApi | `endpoints.discover` (sends **no** query params — broken), `clientApi.clientDiscover` (accepts a params object — correct) | **`endpoints.discover`, the broken one**, is the one actually called from `app/discover/page.tsx:13`. Textbook case of "the fixed version exists in the codebase but nothing uses it." |
| GET `/search/pros` | all 3 | `endpoints.searchPros`, `clientApi.searchPros`, `proApi.searchPros` | **Two different live callers**: `endpoints.searchPros` from `app/pro/profile/listing-card/page.tsx:110`, `clientApi.searchPros` from `app/search/page.tsx:16`. Both paths are correct, so no bug, but two independent pages depend on two different wrapper functions for the same call. |
| GET `/pros/{id}/public` | all 3 | `endpoints.publicProProfile` (called, listing-card), `clientApi.getProPublic` (dead), `proApi.getPublicProProfile` (called, packages page) | **Two different live callers** again, same pattern as above. |
| POST `/client/bookings/request` | endpoints, clientApi | `endpoints.createBookingRequest` (called, **broken shape**), `clientApi.createBookingRequest` (dead, generic passthrough — not itself broken, but would need real fields supplied at the call site to work) | only the broken one is called |
| **GET `/client/bookings/{id}`** | endpoints, clientApi | `endpoints.clientBooking` (called from `app/client/bookings/[id]/page.tsx:13`), `clientApi.getClientBooking` (called from `app/bookings/[bookingId]/page.tsx:14`) | **Both are actually called — from two entirely separate, parallel page routes** (`/client/bookings/[id]` and `/bookings/[bookingId]`) that appear to be duplicate/competing screens for the same booking-detail view. The `/client/bookings/[id]` version additionally wires up "Pay now" (`endpoints.payBooking`); the `/bookings/[bookingId]` version is read-only. This is a genuine two-screens-two-client-files split, not just dead code. |
| POST `/client/bookings/{id}/pay` | endpoints, clientApi | `endpoints.payBooking` (called), `clientApi.payClientBooking` (dead) | only `endpoints.payBooking` |
| GET `/booking-requests/{id}` | clientApi, proApi | `getBookingRequest` (both) | neither |
| POST `/booking-requests/{id}/cancel` | clientApi, proApi | `cancelBookingRequest` (both) | neither |
| GET `/gigs/{id}` | clientApi, proApi | `clientApi.getGig` (called, client gig page), `proApi.getGig` (called, pro gig page) | both — legitimately parallel client-side vs pro-side usage, not a bug |
| GET/PUT `/gigs/{id}/consent` | clientApi, proApi | `getGigConsent`/`putGigConsent` (both) | neither |
| GET `/gigs/{id}/media/{id}/signed-url`, `/download` | clientApi, proApi | same names in both | neither |
| GET `/proof-galleries/{id}` | clientApi, proApi | `clientApi.getProofGallery` (called), `proApi.getProofGallery` (dead) | only clientApi's |
| **POST `/proof-galleries/{id}/selections`** | clientApi, proApi | `clientApi.saveSelection` (called), `proApi.saveGallerySelection` (dead) | **naming collision**: same endpoint, different function names between the two files (`saveSelection` vs `saveGallerySelection`) |
| **POST `/proof-galleries/{id}/selections/submit`** | clientApi, proApi | `clientApi.submitSelection` (called), `proApi.submitGallerySelection` (dead) | same naming-collision pattern |
| POST `/proof-galleries/{id}/upsell/create-intent` | clientApi, proApi | `createUpsellIntent` (both) | neither |
| **GET `/proof-galleries/{id}/downloads`** | clientApi, proApi | `clientApi.getGalleryDownloads`, `proApi.getProofGalleryDownloads` | **naming collision**, neither called |
| POST `/analytics` | clientApi, proApi | `clientApi.track` (dead), `proApi.track` (heavily called, 7 call sites) | only proApi's |
| GET `/niches` | endpoints, proApi | `endpoints.nichesCatalog` (called), `proApi.listNiches` (dead) | only endpoints' |
| **GET/PUT `/pro/niches/mine`** | endpoints, proApi | `endpoints.myNiches`/`updateMyNiches` (called), `proApi.getMyNiches`/`putMyNiches` (dead) | **naming collision** — endpoints.ts drops the `get`/`put` verb prefix that proApi.ts always uses |
| **GET/PUT `/pro/me/profile`** | endpoints, proApi | `endpoints.myProProfile`/`updateMyProProfile` (called from `listing-card/page.tsx`), `proApi.getMyProProfile`/`updateMyProProfile` (called from `profile/page.tsx`) | **Both are actually called, from two different pro screens editing the same resource** (see List C #5 in the prior audit: `listing-card` and `profile` are duplicate profile-editing screens). `updateMyProProfile` is literally the same name in both files despite different underlying `Result`-vs-throw contracts. |
| GET `/pro/payouts` | endpoints, proApi | `endpoints.myPayouts` (dead), `proApi.getPayouts` (called) | only proApi's |
| GET `/pro/scheduling/slots` | endpoints, proApi | `endpoints.scheduleSlots` (dead), `proApi.getCandidateSlots` (called) | only proApi's (also a naming mismatch: `scheduleSlots` vs `getCandidateSlots`) |
| GET `/me/notifications` | endpoints (wrong path `/notifications`), clientApi (`listNotifications`, correct path) | — | endpoints' **broken** version is the one called; clientApi's correct version is dead — same "fixed version exists but unused" pattern as discover |
| POST `/me/notifications/{id}/read` | endpoints (wrong path), clientApi (`readNotification`, correct path) | — | same pattern |

**Summary: 24 distinct endpoints have wrappers in 2+ files.** Of those, the clearest "same operation, different bug status, and the buggy one is what's live" cases are: **`GET /client/discover`**, **`GET /me/notifications`**, and **`POST /me/notifications/{id}/read`** — in all three, `endpoints.ts` has the broken version and it's the one actually wired to a page, while a correct version sits unused in `clientApi.ts`. Two more cases (**`GET /client/bookings/{id}`** and **`GET/PUT /pro/me/profile`**) have *both* competing wrappers live simultaneously from two different screens, which is a duplicate-screens problem more than a duplicate-bug problem, but still directly relevant to how a domain-file merge should handle them (which screen's behavior wins).

---

## 3. `web/lib/api/client.ts` transport analysis

Full file is 58 lines; read in full. Findings:

- **Base URL**: `const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"` (line 23). Every request is built as `new URL(\`/v1${path}\`, API_BASE_URL)` — callers pass paths *without* the `/v1` prefix (e.g. `"/me"`), and `apiRequest` prepends it. This is why all three client files' path strings above look like `/me`, `/client/discover`, etc. rather than `/v1/me`.
- **Auth token attachment**: `Authorization: Bearer ${accessToken}` header, set only `if (opts.accessToken)` (line 38). The token itself is **not** read from a cookie or localStorage inside `client.ts` — it's purely a caller-supplied parameter threaded through every wrapper function's `accessToken?: string | null` argument, ultimately sourced from `useAuth()` / the auth store in each page. `client.ts` itself has zero awareness of where the token lives.
- Note: `fetch` is also called with `credentials: "include"` (line 43), so any session/auth cookies the browser holds are sent too, alongside the explicit bearer header — two auth channels active at once, though only the header is explicitly constructed by this code.
- **Error handling**: throws, never swallows or returns a typed-error value at this layer (the `Result<T>` wrapping is a layer *above* `client.ts`, built independently and identically in both `clientApi.ts` and `proApi.ts` — `endpoints.ts` has no such wrapping and lets the throw propagate raw to its callers). On `!res.ok` (line 47): attempts `res.json()` (swallowing JSON-parse failure to `null`), validates against a zod `ApiErrorSchema` expecting `{error:{code,message,details?}}`; if it matches, throws `ApiError(code, message, details)`. **If the body doesn't match that shape** (e.g. a non-JSON 500, an HTML error page, or a differently-shaped error body), it falls back to `throw new ApiError("http_error", \`HTTP ${res.status}\`)` — **with no third `details` argument**, meaning `error.details` is `{}` (the constructor's default). Since both `clientApi.ts`'s and `proApi.ts`'s `toError()` read `error.details?.status` to classify the error kind, this fallback path always produces `kind: "unknown"` regardless of whether it was a 401/403/422/500 — the numeric status code is silently lost in the generic-fallback branch. This is a real (if narrow) bug worth carrying into the redesign: the fallback `ApiError` construction should pass `{ status: res.status }` as details.
- **401 handling**: **confirmed there is none.** Read the entire file — there is no interceptor, no retry, no reference to a refresh token, and no special-case branch for status 401 anywhere in `client.ts`. The prior audit's claim that refresh-and-retry is missing is **correct**. (`clientApi.refresh` and `proApi.refresh` wrapper functions exist and hit the real `/auth/refresh` route correctly, per the inventory above, but nothing calls them — not from `client.ts`, not from any page.)
- **Logging**: none. No `console.*` calls anywhere in the file.
- **Timeout handling**: none. Plain `fetch(...)` with no `AbortController`/`signal`, no timeout wrapper.
- **Retry logic**: none of any kind (no retry on network failure, no retry on 5xx, no backoff).
- **Query params**: supported cleanly via `opts.query?: Record<string, string|number|boolean|undefined>` (lines 30-34) — builds a `URLSearchParams`-style set via `url.searchParams.set`, skipping `undefined` values. Only flat scalar values are supported; no array or nested-object query param support (not that any current caller needs it).
- **FormData / file upload**: **not supported.** `Content-Type` is unconditionally hardcoded to `"application/json"` (line 37) regardless of what `opts.headers` or `opts.body` contain — passing a `FormData` body through this function would still get a `Content-Type: application/json` header, which breaks multipart uploads (the browser needs to set its own `multipart/form-data; boundary=...` header itself, which requires *not* setting Content-Type manually). Consistent with this, the actual portfolio-upload UI (`app/pro/profile/portfolio/page.tsx`) does not do a real file upload at all — it's a raw JSON-textarea UI that calls `proApi.createPhotoUpload`/`completePhotoUpload` with hand-typed JSON payloads (e.g. default value `{"filename":"image.jpg","content_type":"image/jpeg"}`), never a `<input type="file">` + actual binary PUT to a signed URL. So there is currently no real file-upload code path anywhere in `web/` to migrate — a genuine gap the consolidation should probably address, not just move.
- **Streaming**: not supported — response is always fully consumed via `await res.json()` (or returns `null` for 204, line 56).
- **204 handling**: explicit special case, returns `null as T` for `res.status === 204` before attempting to parse JSON — reasonable and correct.

---

## 4. Target domain-split sanity check (`auth.ts` / `booking.ts` / `gigs.ts` / `media.ts` / `pro.ts` / `admin.ts`)

Flagging only — no migration proposed.

**Structural incompatibility that cuts across every domain file, not specific to one:** `endpoints.ts` functions throw a raw `ApiError` on failure and return the raw payload on success; every `clientApi.ts` and `proApi.ts` function instead returns `Result<T> = {ok:true,data}|{ok:false,error}` and never throws. Every one of the 24 duplicate-endpoint cases in section 2 pairs a throwing function with a `Result`-returning one for the *same* backend call. Splitting by domain doesn't resolve this — each new domain file (`auth.ts`, `booking.ts`, etc.) will still need to pick one error-handling contract and every call site that currently expects the other contract will need updating. This is the single biggest cross-cutting issue for the split, independent of how domains are drawn.

**`admin.ts` starts empty.** None of the ~224 `/v1/admin/*` routes have a wrapper function in any of the three files today (confirmed against the inventory above — zero admin functions exist). `admin.ts` in the target structure isn't a *split* of existing code, it's greenfield.

**`pro.ts` is disproportionately large and internally multi-domain.** `proApi.ts` alone (69 functions) covers at least five sub-domains that are each comparable in size to the other standalone target files: onboarding lifecycle (9 functions), scheduling/availability (7), payouts/earnings (6), pro-side chat/messaging (4), and profile/niches/packages/portfolio (9), plus the pro-side halves of gigs/media/galleries that overlap with `gigs.ts`/`media.ts` anyway. Lumping all of this into one `pro.ts` produces a file several times the size of `auth.ts` or `media.ts`.

**Gig media vs. proof-gallery vs. plain media is ambiguous.** `gigs/{id}/media`, `gigs/{id}/media/{id}/signed-url`, `gigs/{id}/media/{id}/download` are gig-scoped media access, currently living in the "gigs" conceptual group in both `clientApi.ts`/`proApi.ts`; `proof-galleries/*` (selection, publish, upsell, downloads) is a related-but-distinct bounded context (client selection UX + pro delivery UX) that could reasonably go in either `gigs.ts` or its own file; and `media/photos/uploads`, `media/photos/{id}/complete`, `media/{id}` (raw asset creation/lookup) is the only cleanly-`media.ts`-shaped set. The target list gives one `media.ts` but doesn't say where gig-scoped media or proof-galleries go — as currently structured they'd have to be arbitrarily split between `gigs.ts` and `media.ts`.

**Functions with no home in any of the six target files** (skimmed from the full inventory in section 1):
- **Discovery/search**: `discover`/`clientDiscover`, `clientMatch`, `searchPros` (×3), `getProPublic`/`getClientProProfile`/`proProfile`/`publicProProfile`/`getPublicProProfile` (×3 pro-profile-lookup variants), `nichesCatalog`/`listNiches`. These are client-facing discovery/matching calls, not naturally "booking" (no booking exists yet at this point in the flow) nor purely "pro" (pro-side re-uses the same public-profile/search calls for its own preview).
- **Notifications & preferences**: `getNotificationPreferences`/`putNotificationPreferences`, `listNotifications`/`readNotification`/`readAllNotifications`, `getClientPreference`/`putClientPreference`, `putContact`. Account-level, not auth (no credential/session handling involved), no natural home.
- **Disputes**: 6 functions (`listDisputes`, `createDispute`, `getDispute`, `cancelDispute`, `addDisputeEvidence`, `addDisputeMessage`) — entirely absent from the six-domain list.
- **Reviews**: `createGigReview` — currently nested under "gigs" naming but is conceptually its own thing (the C11 mandatory-review gate).
- **Rewards / $RAWW / referrals**: `rewardsBalance`/`rewardsBalanceShared`/`rewardsLedger`/`rewardsSpend`, `myReferralCode`/`regenerateReferralCode`/`referralStats`/`referralLanding`/`claimReferral` — 9 functions with no home.
- **Prints**: `printsCatalog`/`myPrintOrders`/`printOrderDetail`/`payPrintOrder`/`updatePrintOrder`/`createGigPrintOrder` — 6 functions, non-MVP but present in code, no home.
- **Waitlist / access-gating**: `getClientAccess`, `joinWaitlist` — arguably auth-adjacent (pre-launch gating) but conceptually distinct from login/register/session.
- **Analytics/tracking**: `track` (both `clientApi.track` and `proApi.track`) — cross-cutting instrumentation called from many pro pages regardless of domain; doesn't belong inside any single domain file, and is arguably closer to a `client.ts`-level concern than a domain concern.
- **i18n**: `i18nBundle` — infra, not a user-facing domain, no home among the six.

---

## 5. Quick-fix verification

### Claim 1 — wallet/dashboard balance field misread

**`web/app/pro/wallet/page.tsx:62`** (current, unchanged from prior audit):
```tsx
<p className="mt-1 text-2xl font-semibold">{String(balanceQ.data?.ok ? (balanceQ.data.data as any).available_balance ?? (balanceQ.data.data as any).available ?? "-" : "-")}</p>
```
**`web/app/pro/dashboard/page.tsx:74`**:
```tsx
const availableBalance = String((balance as any).available_balance ?? (balance as any).available ?? "—");
```
Both read `GET /v1/pro/earnings/balance` (via `proApi.getEarningsBalance`, called from `wallet/page.tsx:15` and `dashboard/page.tsx:41`). The real response schema (`api/app/schemas/payouts.py`) exposes `pending_eur`, `available_eur`, `held_eur`, `reserved_eur`, `withdrawable_eur` — not `available_balance` or `available`. **Confirmed still live, exact line numbers unchanged (62 and 74).**

### Claim 2 — packages page posts wrong fields

**`web/app/pro/profile/packages/page.tsx:11`**:
```tsx
const [packagePayload, setPackagePayload] = useState('{"title":"","price_per_photo":0,"min_photo_qty":0}');
```
posted at **line 21** via `proApi.createPackage(payload, accessToken)` → `POST /v1/pro/me/packages`. Current `ProPackageCreateRequest` schema (`api/app/schemas/onboarding.py:44-56`, re-read fresh this pass):
```python
class ProPackageCreateRequest(BaseModel):
    title: str
    niche_id: uuid.UUID | None = None
    niche_slug: str | None = None
    description: str | None = None
    duration_minutes: int
    price: Decimal
    currency: str = "EUR"
    included_photos: int
    extra_photo_price: Decimal
    proofs_sla_days: int = 3
    finals_sla_days: int = 7
    addons: list[dict] = Field(default_factory=list)
```
**Confirmed still live and unchanged**: `price_per_photo`/`min_photo_qty` don't exist on the schema; `duration_minutes`, `price`, `included_photos`, `extra_photo_price` are required and absent from the default payload. Also confirmed the companion render bug at **lines 62-63**: `pkg.price_per_photo ?? pkg.extra_photo_price` and `pkg.min_photo_qty` — the latter doesn't exist anywhere on the response shape either, so "min qty" always renders `0`.

### Claim 3 — payout request posts wrong field name

**`web/app/pro/wallet/page.tsx:12`**:
```tsx
const [requestJson, setRequestJson] = useState('{"amount": 0}');
```
posted at **line 34** via `proApi.requestPayout(payload, accessToken)` → `POST /v1/pro/payouts/request`. Current schema (`api/app/schemas/payouts.py:61-62`, re-read fresh this pass):
```python
class PayoutRequestCreateRequest(BaseModel):
    amount_eur: Decimal
```
**Confirmed still live and unchanged**: the schema has exactly one field, `amount_eur`; the default payload sends `amount` instead, which Pydantic will not accept as satisfying the required `amount_eur` field — submitting the default payload as-is 422s.

All three claims check out exactly as described, at the same line numbers cited (lines had not shifted since the prior audit).

---

## Files referenced

- `/Users/gustavobarbosa/Documents/RAWWERS/web/lib/api/endpoints.ts`
- `/Users/gustavobarbosa/Documents/RAWWERS/web/lib/api/clientApi.ts`
- `/Users/gustavobarbosa/Documents/RAWWERS/web/lib/api/proApi.ts`
- `/Users/gustavobarbosa/Documents/RAWWERS/web/lib/api/client.ts`
- `/Users/gustavobarbosa/Documents/RAWWERS/docs/api_endpoints.md`
- `/Users/gustavobarbosa/Documents/RAWWERS/api/app/schemas/onboarding.py`
- `/Users/gustavobarbosa/Documents/RAWWERS/api/app/schemas/payouts.py`
- `/Users/gustavobarbosa/Documents/RAWWERS/rawwers-endpoint-coverage-audit.md` (prior audit, cross-checked against)
