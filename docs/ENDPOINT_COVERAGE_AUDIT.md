# RAWWERS API Endpoint Coverage Audit (web/)

Scope: `api/` (403 routes cataloged in `docs/api_endpoints.md`) vs. actual call sites in `web/` (Next.js). Flutter is out of scope. Read-only audit, no code changed.

## Summary

- **Total backend endpoints:** 403 (per `docs/api_endpoints.md`, verified: 403 table rows)
- **Endpoints correctly called by `web/` code:** 54 / 403 ≈ **13.4%**, plus **6 more** where `web/` does hit the right route but with a broken request/response shape or default payload (counted separately as "Broken" in the table, detailed in List B) — **60 / 403 ≈ 14.9%** of all backend endpoints have *any* real call attempt from `web/`.
- **MVP-scope endpoints (per `rawwers-mvp-screens-and-booking-flow.md`):** 121 of 403 are clearly in scope, plus 42 more marked **Ambiguous** (shared infra or judgment calls the spec doesn't directly resolve — see methodology). Of the 121 clear-MVP endpoints: only **49 (40%)** have a correctly-working caller, **6** are called but broken, and **66 (55%)** have no caller in `web/` at all.
- **List A (MVP endpoints with no frontend caller):** 47 entries (a curated, most-severe subset of the 66 "MVP + No caller" rows in the full table — see the note at the end of List A for the remainder)
- **List B (broken wiring — wrong/missing route or field-shape mismatch):** 9 entries, covering the 6 "Broken" table rows plus 2 nonexistent routes with no matching table row at all (`GET /v1/feature-flags`, `GET /v1/client/bookings`) plus 1 response-shape bug that doesn't change the Called verdict (`GET /v1/pro/earnings/balance`, called twice from two files)
- **List C (non-MVP endpoints with a frontend caller anyway):** 6 entries

Headline findings:
1. `web/` has **three parallel, mostly-unused API client layers** — `lib/api/endpoints.ts` (older, has real path bugs, actively used by 13 pages), `lib/api/clientApi.ts` (newer, paths are all correct, but ~80% of its functions are never called from any page), and `lib/api/proApi.ts` (paths all correct, ~55% never called). A large fraction of both docs' "used" endpoint lists are wrapper functions that exist in code but are never invoked by any screen.
2. The single most important MVP flow — **client booking request (C5)** — is wired to the wrong request shape and will fail every real submission (`app/pros/[id]/page.tsx`, see List B).
3. **Client-side messaging (C8)** has zero backend wiring at all — `app/chat/[threadId]/page.tsx` is pure local state.
4. **Pro onboarding stage submission (P2–P7)** — profile/niches/packages/portfolio/KYC completion calls — is entirely unwired; the onboarding page only reads status.
5. **Booking-request accept/decline/confirm-slot (P10/P11)** on the pro side are unwired — the buttons exist with no `onClick`.
6. Client can never see a pro's **availability calendar** (`GET /v1/pro/{pro_user_id}/availability`) — required by C4 — because `proApi.getPublicAvailability` is defined but never called.
7. Two known field-shape bugs from the earlier audit are confirmed still live: pro wallet reads `available_balance`/`available` instead of `pending_eur`/`available_eur`/`held_eur`/`reserved_eur`/`withdrawable_eur`, and the packages page posts `price_per_photo`/`min_photo_qty` instead of `price`/`included_photos`/`extra_photo_price`.

## Methodology

- "Called from web?" means a `web/` file actually invokes the client function at runtime (traced through `lib/api/endpoints.ts`, `lib/api/clientApi.ts`, `lib/api/proApi.ts` into the page/component that calls it) — not merely that a wrapper function exists in one of those three files. A large amount of wrapper code in `clientApi.ts`/`proApi.ts`/`endpoints.ts` is never invoked anywhere; those are marked "No caller" even though a matching function exists.
- MVP scope is judged against `rawwers-mvp-screens-and-booking-flow.md`'s explicit inclusion list (photographer onboarding + RAW verification, 2 training modules with gate, booking, selection gallery, Stripe escrow, delivery, messaging, mandatory review, $RAWW earning ledger) and explicit exclusion list (Studioverse, gear e-commerce storefront, Gear Loan Vault, Legacy Shoot, AI tooling, on-chain anything, client-side ecommerce beyond a balance display). By extension, treated as **non-MVP**: the full e-learning/LMS marketplace (`/v1/courses`, `/v1/learn/*`, `/v1/instructor/*`, `/v1/partner/learn/*` — a separate "E-learning v1" build item, bigger than the "2 training modules with gate" the MVP doc actually asks for), the referral/growth engine (`/v1/referrals/*`, `/v1/ref/*`, `/v1/me/referral-code*`, `/v1/share/*`, gig share-links), gamification/quests (`/v1/me/game/*`, `/v1/me/gamification/*`), prints (client-side ecommerce beyond a balance display), repairs/Gear Loan Vault, Legacy Shoot, Studioverse, and outbound-call/AI-summary tooling.
- **Admin panel:** the MVP doc covers only the Client and Pro apps, and the Admin Panel is its own separate build item in the repo history — so `/v1/admin/*` is marked non-MVP **except** the narrow set of endpoints the MVP doc's own text implies are operationally required at MVP ("manual resolution by you", "manual approval at MVP" for RAW verification, manual redemption fulfilment): pro-onboarding approve/reject, dispute list/resolve, escrow hold create/release, refund retry, payout approve/mark-paid/reject, and KYC update. Those are marked **Ambiguous** rather than a hard Yes, since no admin UI exists in `web/` either way.
- Rows marked **Ambiguous** are shared infrastructure (health checks, i18n bundles, locale) or genuinely borderline per the note above — noted rather than forced to a binary call, per the audit brief.
- "Non-existent route" in List B means the frontend calls a path with no matching row in `docs/api_endpoints.md` at all. "Field mismatch" means it hits a real route but with request/response field names that don't match the backend Pydantic schema (verified by reading the schema in `api/app/schemas/`).

---

## Full coverage table

Grouped by path prefix in the same order as `docs/api_endpoints.md`. **Called** = Yes/No/Broken (Broken = code calls it but at wrong path or with a shape bug — see List B for detail). **MVP** = Yes/No/Ambiguous.

### Health / metrics

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/health/ready` | No | — | Ambiguous (infra) |
| GET | `/health/replica` | No | — | Ambiguous (infra) |
| GET | `/healthz` | No | — | Ambiguous (infra) |
| GET | `/metrics` | No | — | Ambiguous (infra) |

### Admin (`/v1/admin/*`) — none called from `web/`

`web/app/admin/page.tsx` is the only admin screen and it calls just `GET /v1/i18n/bundles` (a non-admin route, listed under i18n below). Every `/v1/admin/*` route below has **No** caller in `web/`.

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/admin/abuse/signals` | No | — | No |
| POST | `/v1/admin/abuse/signals/{signal_id}/resolve` | No | — | No |
| PUT | `/v1/admin/ai/feature-flags` | No | — | No |
| GET | `/v1/admin/ai/logs` | No | — | No |
| GET | `/v1/admin/consent/events` | No | — | No |
| GET | `/v1/admin/courses` | No | — | No |
| POST | `/v1/admin/courses/{course_id}/unpublish` | No | — | No |
| GET | `/v1/admin/disputes` | No | — | Ambiguous (manual resolution) |
| GET | `/v1/admin/disputes/{dispute_id}` | No | — | Ambiguous |
| POST | `/v1/admin/disputes/{dispute_id}/resolve` | No | — | Ambiguous |
| POST | `/v1/admin/disputes/{dispute_id}/set-status` | No | — | Ambiguous |
| POST | `/v1/admin/disputes/{dispute_id}/status` | No | — | Ambiguous |
| POST | `/v1/admin/entitlement-holds/{hold_id}/release` | No | — | Ambiguous (escrow ops) |
| GET | `/v1/admin/feature-flags` | No | — | No |
| PUT | `/v1/admin/feature-flags/{key}` | No | — | No |
| GET | `/v1/admin/finance/fee-policy` | No | — | No |
| PUT | `/v1/admin/finance/fee-policy` | No | — | No |
| GET | `/v1/admin/finance/pros` | No | — | No |
| GET | `/v1/admin/finance/pros/{pro_user_id}` | No | — | No |
| POST | `/v1/admin/followups/rebuild` | No | — | No |
| POST | `/v1/admin/followups/rules/seed` | No | — | No |
| GET | `/v1/admin/funnel/clients` | No | — | No |
| POST | `/v1/admin/gamification/cycles` | No | — | No |
| PUT | `/v1/admin/gamification/cycles` | No | — | No |
| POST | `/v1/admin/gamification/milestones` | No | — | No |
| PUT | `/v1/admin/gamification/milestones` | No | — | No |
| POST | `/v1/admin/gamification/recompute` | No | — | No |
| POST | `/v1/admin/gigs/{gig_id}/refunds` | No | — | Ambiguous (escrow ops) |
| POST | `/v1/admin/gigs/{gig_id}/status` | No | — | Ambiguous |
| POST | `/v1/admin/holds/create` | No | — | Ambiguous (escrow ops) |
| POST | `/v1/admin/holds/{hold_id}/release` | No | — | Ambiguous |
| GET | `/v1/admin/i18n/bundles` | No | — | No |
| POST | `/v1/admin/i18n/bundles` | No | — | No |
| POST | `/v1/admin/i18n/bundles/{bundle_id}/activate` | No | — | No |
| GET | `/v1/admin/i18n/locales` | No | — | No |
| GET | `/v1/admin/i18n/missing-keys` | No | — | No |
| POST | `/v1/admin/impersonate/end` | No | — | No |
| POST | `/v1/admin/impersonate/start` | No | — | No |
| POST | `/v1/admin/index/pro/rebuild-all` | No | — | No |
| POST | `/v1/admin/index/pro/{pro_user_id}/rebuild` | No | — | No |
| POST | `/v1/admin/instructors/{user_id}/approve` | No | — | No |
| POST | `/v1/admin/instructors/{user_id}/reject` | No | — | No |
| GET | `/v1/admin/invites/codes` | No | — | No |
| POST | `/v1/admin/invites/codes/{code}/revoke` | No | — | No |
| GET | `/v1/admin/invites/waves` | No | — | No |
| POST | `/v1/admin/invites/waves` | No | — | No |
| POST | `/v1/admin/invites/waves/{wave_id}/generate` | No | — | No |
| POST | `/v1/admin/jobs/expire-booking-requests` | No | — | Ambiguous (booking timers) |
| POST | `/v1/admin/jobs/recompute-niche-skills` | No | — | No |
| GET | `/v1/admin/learn/courses` | No | — | No |
| POST | `/v1/admin/learn/courses/{course_id}/review` | No | — | No |
| GET | `/v1/admin/learn/fee-policy` | No | — | No |
| PUT | `/v1/admin/learn/fee-policy` | No | — | No |
| GET | `/v1/admin/learn/partners` | No | — | No |
| POST | `/v1/admin/learn/partners` | No | — | No |
| GET | `/v1/admin/learn/sales` | No | — | No |
| GET | `/v1/admin/legacy/orders` | No | — | No |
| POST | `/v1/admin/legacy/{legacy_booking_id}/assign-pro` | No | — | No |
| GET | `/v1/admin/legacy/{legacy_booking_id}/audit` | No | — | No |
| POST | `/v1/admin/legacy/{legacy_booking_id}/set-status` | No | — | No |
| POST | `/v1/admin/niche-skill/recalc` | No | — | No |
| GET | `/v1/admin/niches` | No | — | No |
| PUT | `/v1/admin/niches` | No | — | No |
| GET | `/v1/admin/niches/{niche_id}/tier-policy` | No | — | No |
| PUT | `/v1/admin/niches/{niche_id}/tier-policy` | No | — | No |
| POST | `/v1/admin/niches/{niche_slug}/requirements` | No | — | No |
| GET | `/v1/admin/notifications/logs` | No | — | No |
| POST | `/v1/admin/notifications/resend` | No | — | No |
| GET | `/v1/admin/onboarding/pros` | No | — | Ambiguous (manual RAW verification approval, P4/P5) |
| POST | `/v1/admin/onboarding/pros/{pro_user_id}/approve` | No | — | Ambiguous |
| POST | `/v1/admin/onboarding/pros/{pro_user_id}/reject` | No | — | Ambiguous |
| POST | `/v1/admin/onboarding/pros/{pro_user_id}/set-status` | No | — | Ambiguous |
| GET | `/v1/admin/ops/metrics-summary` | No | — | No |
| GET | `/v1/admin/payouts` | No | — | Ambiguous (P14 manual payout) |
| POST | `/v1/admin/payouts/{payout_request_id}/approve` | No | — | Ambiguous |
| POST | `/v1/admin/payouts/{payout_request_id}/mark-paid` | No | — | Ambiguous |
| POST | `/v1/admin/payouts/{payout_request_id}/reject` | No | — | Ambiguous |
| GET | `/v1/admin/pricing/extra-image-policies` | No | — | No |
| PUT | `/v1/admin/pricing/extra-image-policies` | No | — | No |
| GET | `/v1/admin/pricing/pro-extra-image-price/{pro_user_id}` | No | — | No |
| PUT | `/v1/admin/pricing/pro-extra-image-price/{pro_user_id}` | No | — | No |
| GET | `/v1/admin/prints/catalog/products` | No | — | No |
| PUT | `/v1/admin/prints/catalog/products` | No | — | No |
| GET | `/v1/admin/prints/orders` | No | — | No |
| GET | `/v1/admin/prints/orders/{order_id}` | No | — | No |
| POST | `/v1/admin/prints/orders/{order_id}/set-status` | No | — | No |
| POST | `/v1/admin/prints/orders/{order_id}/set-tracking` | No | — | No |
| GET | `/v1/admin/prints/partners` | No | — | No |
| PUT | `/v1/admin/prints/partners` | No | — | No |
| PUT | `/v1/admin/pros/{pro_user_id}/ai-profile` | No | — | No |
| GET | `/v1/admin/pros/{pro_user_id}/niche-skill` | No | — | No |
| POST | `/v1/admin/pros/{pro_user_id}/niche-skill/{niche_id}/override` | No | — | No |
| POST | `/v1/admin/pros/{pro_user_id}/niches/{niche_slug}/recompute` | No | — | No |
| POST | `/v1/admin/pros/{pro_user_id}/skills/{niche_slug}/override` | No | — | No |
| POST | `/v1/admin/pros/{user_id}/kyc` | No | — | Ambiguous (manual KYC review, P4) |
| GET | `/v1/admin/raww/caps` | No | — | No |
| PUT | `/v1/admin/raww/caps` | No | — | No |
| POST | `/v1/admin/raww/clawback` | No | — | No |
| GET | `/v1/admin/raww/issuance-rules` | No | — | No |
| PUT | `/v1/admin/raww/issuance-rules` | No | — | No |
| GET | `/v1/admin/raww/mints` | No | — | No |
| GET | `/v1/admin/raww/multiplier-policy` | No | — | No |
| PUT | `/v1/admin/raww/multiplier-policy` | No | — | No |
| DELETE | `/v1/admin/referrals/blacklist/{user_id}` | No | — | No |
| POST | `/v1/admin/referrals/blacklist/{user_id}` | No | — | No |
| GET | `/v1/admin/referrals/policy` | No | — | No |
| PUT | `/v1/admin/referrals/policy` | No | — | No |
| GET | `/v1/admin/referrals/report` | No | — | No |
| GET | `/v1/admin/refunds` | No | — | Ambiguous |
| POST | `/v1/admin/refunds/{refund_case_id}/retry` | No | — | Ambiguous |
| GET | `/v1/admin/repairs/loaners` | No | — | No |
| POST | `/v1/admin/repairs/loaners/{loaner_request_id}/set-status` | No | — | No |
| POST | `/v1/admin/repairs/overrides/{pro_user_id}` | No | — | No |
| GET | `/v1/admin/repairs/partners` | No | — | No |
| POST | `/v1/admin/repairs/partners` | No | — | No |
| PUT | `/v1/admin/repairs/partners/{partner_id}` | No | — | No |
| POST | `/v1/admin/repairs/partners/{partner_id}/recompute-score` | No | — | No |
| POST | `/v1/admin/repairs/partners/{partner_id}/set-active` | No | — | No |
| GET | `/v1/admin/repairs/policy` | No | — | No |
| PUT | `/v1/admin/repairs/policy` | No | — | No |
| GET | `/v1/admin/repairs/tickets` | No | — | No |
| POST | `/v1/admin/repairs/tickets/{ticket_id}/assign-partner` | No | — | No |
| POST | `/v1/admin/repairs/tickets/{ticket_id}/set-quote` | No | — | No |
| POST | `/v1/admin/repairs/tickets/{ticket_id}/set-status` | No | — | No |
| POST | `/v1/admin/reviews/{review_id}/moderate` | No | — | No |
| POST | `/v1/admin/rewards/adjust` | No | — | No |
| GET | `/v1/admin/rewards/consent-policies` | No | — | No |
| PUT | `/v1/admin/rewards/consent-policies` | No | — | No |
| GET | `/v1/admin/rewards/rules` | No | — | No |
| POST | `/v1/admin/rewards/rules/{code}` | No | — | No |
| GET | `/v1/admin/rewards/share-fraud-settings` | No | — | No |
| PUT | `/v1/admin/rewards/share-fraud-settings` | No | — | No |
| GET | `/v1/admin/rewards/share-grants` | No | — | No |
| GET | `/v1/admin/rewards/share-thresholds` | No | — | No |
| PUT | `/v1/admin/rewards/share-thresholds` | No | — | No |
| GET | `/v1/admin/risk/rules` | No | — | No |
| PUT | `/v1/admin/risk/rules/{rule_id}` | No | — | No |
| GET | `/v1/admin/risk/users` | No | — | No |
| GET | `/v1/admin/risk/users/{user_id}` | No | — | No |
| POST | `/v1/admin/risk/users/{user_id}/clear-action` | No | — | No |
| POST | `/v1/admin/risk/users/{user_id}/set-score` | No | — | No |
| GET | `/v1/admin/rollout/cities` | No | — | No |
| PUT | `/v1/admin/rollout/cities` | No | — | No |
| POST | `/v1/admin/rollout/cities/bulk-enable` | No | — | No |
| GET | `/v1/admin/rollout/overrides/{user_id}` | No | — | No |
| PUT | `/v1/admin/rollout/overrides/{user_id}` | No | — | No |
| GET | `/v1/admin/scheduling/conflicts` | No | — | No |
| POST | `/v1/admin/search/purge` | No | — | No |
| POST | `/v1/admin/search/rebuild` | No | — | No |
| GET | `/v1/admin/search/status` | No | — | No |
| POST | `/v1/admin/share-links/{share_link_id}/revoke` | No | — | No |
| POST | `/v1/admin/store/orders/{order_id}/update-status` | No | — | No |
| POST | `/v1/admin/store/overrides/{pro_user_id}` | No | — | No |
| GET | `/v1/admin/store/partners` | No | — | No |
| POST | `/v1/admin/store/partners` | No | — | No |
| PUT | `/v1/admin/store/partners/{partner_id}` | No | — | No |
| POST | `/v1/admin/store/partners/{partner_id}/sync` | No | — | No |
| GET | `/v1/admin/store/policy` | No | — | No |
| PUT | `/v1/admin/store/policy` | No | — | No |
| GET | `/v1/admin/store/price-rules` | No | — | No |
| POST | `/v1/admin/store/price-rules` | No | — | No |
| PUT | `/v1/admin/store/price-rules/{rule_id}` | No | — | No |
| GET | `/v1/admin/store/products` | No | — | No |
| POST | `/v1/admin/store/products` | No | — | No |
| PUT | `/v1/admin/store/products/{product_id}` | No | — | No |
| GET | `/v1/admin/studioverse/packs` | No | — | No |
| POST | `/v1/admin/studioverse/packs/{pack_id}/review` | No | — | No |
| POST | `/v1/admin/studioverse/packs/{pack_id}/takedown` | No | — | No |
| GET | `/v1/admin/users` | No | — | No |
| GET | `/v1/admin/users/{user_id}` | No | — | No |
| POST | `/v1/admin/users/{user_id}/ban` | No | — | No |
| POST | `/v1/admin/users/{user_id}/roles` | No | — | No |

### Analytics

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/analytics` | Yes | `web/app/pro/dashboard/page.tsx:46`, `web/app/pro/profile/packages/page.tsx:25,36`, `web/app/pro/profile/portfolio/page.tsx:23`, `web/app/pro/wallet/page.tsx:27,39` (all via `proApi.track`) | Ambiguous (infra) |

### Auth

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/auth/login` | Yes | `web/app/login/page.tsx:24`, `web/app/pro/login/page.tsx:23`, `web/app/pro/register/page.tsx:19` (via `endpoints.login`) | Yes |
| POST | `/v1/auth/logout` | Yes | `web/components/app-shell.tsx:46` (via `endpoints.logout`) | Yes |
| POST | `/v1/auth/password-reset/confirm` | No | — | Yes |
| POST | `/v1/auth/password-reset/request` | No | — | Yes |
| POST | `/v1/auth/refresh` | No | `clientApi.refresh`/`proApi.refresh` defined but never invoked (no refresh-on-401 wiring found) | Yes |
| POST | `/v1/auth/register` | Yes | `web/app/pro/register/page.tsx:37`, `web/app/register/page.tsx:19` (via `endpoints.register`) | Yes |
| POST | `/v1/auth/verify-email/confirm` | No | — | Yes |
| POST | `/v1/auth/verify-email/request` | No | — | Yes |

### Booking requests

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/booking-requests/{request_id}` | No | `clientApi.getBookingRequest`/`proApi.getBookingRequest` defined, never called | Yes |
| POST | `/v1/booking-requests/{request_id}/accept` | No | `proApi.acceptBookingRequest` defined, never called (`web/app/pro/bookings/[id]/page.tsx` "Accept request" button has no `onClick`) | Yes |
| POST | `/v1/booking-requests/{request_id}/cancel` | No | `clientApi.cancelBookingRequest`/`proApi.cancelBookingRequest` defined, never called | Yes |
| POST | `/v1/booking-requests/{request_id}/decline` | No | `proApi.declineBookingRequest` defined, never called | Yes |

### Calls (AI outbound calling — excluded from MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/calls/request` | No | — | No |
| POST | `/v1/calls/{call_session_id}/ai/summary` | No | — | No |

### Chat / Chats (client-facing threads — separate from `/v1/pro/chat/threads`)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/chat/threads` | No | — | Yes |
| GET | `/v1/chat/threads/{thread_id}` | No | — | Yes |
| POST | `/v1/chat/threads/{thread_id}/create-booking` | No | — | Yes |
| POST | `/v1/chat/threads/{thread_id}/messages` | No | — | Yes |
| GET | `/v1/chats/{thread_id}` | No | — | Yes |
| POST | `/v1/chats/{thread_id}/close` | No | — | Yes |
| POST | `/v1/chats/{thread_id}/create-booking-request` | No | — | Yes |
| POST | `/v1/chats/{thread_id}/messages` | No | — | Yes |
| POST | `/v1/chats/{thread_id}/takeover` | No | — | Yes |

### Client

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/client/access` | Yes | `web/app/waitlist/page.tsx:14` (`clientApi.getClientAccess`) | Ambiguous (waitlist isn't an MVP screen, but access gating may be) |
| POST | `/v1/client/bookings/request` | Broken | `web/app/pros/[id]/page.tsx:21` (via `endpoints.createBookingRequest`) — **field/shape mismatch, see List B** | Yes |
| GET | `/v1/client/bookings/{booking_id}` | Yes | `web/app/client/bookings/[id]/page.tsx:13` (`endpoints.clientBooking`) | Yes |
| POST | `/v1/client/bookings/{booking_id}/pay` | Yes | `web/app/client/bookings/[id]/page.tsx:14` (`endpoints.payBooking`) | Yes |
| POST | `/v1/client/bookings/{booking_request_id}/time-windows` | No | `clientApi.submitTimeWindows` defined, never called | Yes |
| GET | `/v1/client/discover` | Broken | `web/app/discover/page.tsx:13` (`endpoints.discover`) — **missing required query params, see List B** | Yes |
| POST | `/v1/client/match` | No | `clientApi.clientMatch` defined, never called | Yes |
| GET | `/v1/client/pros/{pro_user_id}` | Yes | `web/app/pros/[id]/page.tsx:18` (`endpoints.proProfile`) | Yes |
| POST | `/v1/client/waitlist` | Yes | `web/app/waitlist/page.tsx:15` (`clientApi.joinWaitlist`) | Ambiguous (waitlist not in MVP screen list) |

### Courses (public — e-learning marketplace, non-MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/courses` | No | — | No |
| GET | `/v1/courses/{course_id}` | No | — | No |
| POST | `/v1/courses/{course_id}/enroll` | No | — | No |

### Discover

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/discover/match` | No | — | Yes |
| GET | `/v1/discover/pros` | No | — | Yes |

### Disputes

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/disputes` | No | `clientApi.listDisputes` defined, never called | Ambiguous |
| POST | `/v1/disputes` | No | `clientApi.createDispute` defined, never called | Ambiguous |
| GET | `/v1/disputes/{dispute_id}` | No | `clientApi.getDispute` defined, never called | Ambiguous |
| POST | `/v1/disputes/{dispute_id}/cancel` | No | `clientApi.cancelDispute` defined, never called | Ambiguous |
| POST | `/v1/disputes/{dispute_id}/evidence` | No | `clientApi.addDisputeEvidence` defined, never called | Ambiguous |
| POST | `/v1/disputes/{dispute_id}/messages` | No | `clientApi.addDisputeMessage` defined, never called | Ambiguous |

### Enrollments (e-learning, non-MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/enrollments/{enrollment_id}/lessons/{lesson_id}/progress` | No | — | No |
| POST | `/v1/enrollments/{enrollment_id}/lessons/{lesson_id}/quiz-attempt` | No | — | No |

### Gigs

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/gigs` | No | `proApi.createGig` defined, never called | Yes |
| GET | `/v1/gigs/{gig_id}` | Yes | `web/app/gigs/[gigId]/page.tsx:14` (client, `clientApi.getGig`), `web/app/pro/gigs/[gigId]/page.tsx:12` (pro, `proApi.getGig`) | Yes |
| POST | `/v1/gigs/{gig_id}/cancel-slot` | No | `proApi.cancelGigSlot` defined, never called | Yes |
| GET | `/v1/gigs/{gig_id}/consent` | No | `clientApi.getGigConsent`/`proApi.getGigConsent` defined, never called | Yes |
| PUT | `/v1/gigs/{gig_id}/consent` | No | `clientApi.putGigConsent`/`proApi.putGigConsent` defined, never called | Yes |
| GET | `/v1/gigs/{gig_id}/media` | Yes | `web/app/gigs/[gigId]/delivery/page.tsx:12` (`clientApi.listGigMedia`) | Yes |
| GET | `/v1/gigs/{gig_id}/media/{media_asset_id}/download` | No | `clientApi.downloadGigMedia`/`proApi.downloadGigMedia` defined, never called | Yes |
| GET | `/v1/gigs/{gig_id}/media/{media_asset_id}/signed-url` | No | `clientApi.getGigMediaSignedUrl`/`proApi.getGigMediaSignedUrl` defined, never called | Yes |
| POST | `/v1/gigs/{gig_id}/payments/stripe/create-intent` | No | `clientApi.createGigStripeIntent` defined, never called | Yes |
| POST | `/v1/gigs/{gig_id}/prints/orders` | No | `clientApi.createGigPrintOrder` defined, never called | No |
| POST | `/v1/gigs/{gig_id}/proof-gallery` | Yes | `web/app/pro/gigs/[gigId]/delivery/page.tsx:16` (`proApi.createProofGalleryForGig`) | Yes |
| POST | `/v1/gigs/{gig_id}/refunds/stripe` | No | — | Yes |
| POST | `/v1/gigs/{gig_id}/reschedule-request` | No | `proApi.requestReschedule` defined, never called | Yes |
| POST | `/v1/gigs/{gig_id}/review` | No | `clientApi.createGigReview` defined, never called | Yes |
| POST | `/v1/gigs/{gig_id}/share-links` | No | `proApi.createGigShareLink` defined, never called | No |

### i18n

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/i18n/bundles` | Yes | `web/app/admin/page.tsx:8` (`endpoints.i18nBundle`) | Ambiguous (infra) |

### Instructor / Partner-learn (e-learning, non-MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/instructor/courses` | No | — | No |
| PUT | `/v1/instructor/courses/{course_id}` | No | — | No |
| POST | `/v1/instructor/courses/{course_id}/modules` | No | — | No |
| POST | `/v1/instructor/courses/{course_id}/publish` | No | — | No |
| POST | `/v1/instructor/modules/{module_id}/lessons` | No | — | No |
| POST | `/v1/partner/learn/courses` | No | — | No |
| GET | `/v1/partner/learn/courses/mine` | No | — | No |
| PUT | `/v1/partner/learn/courses/{course_id}` | No | — | No |
| POST | `/v1/partner/learn/courses/{course_id}/submit` | No | — | No |

### Learn (e-learning, non-MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/learn/certificates/mine` | No | — | No |
| GET | `/v1/learn/certificates/{verification_code}` | No | — | No |
| GET | `/v1/learn/courses` | No | — | No |
| GET | `/v1/learn/courses/{course_id}` | No | — | No |
| POST | `/v1/learn/courses/{course_id}/enroll` | No | — | No |
| GET | `/v1/learn/curricula` | No | — | No |
| POST | `/v1/learn/enrollments/{enrollment_id}/modules/{module_id}/progress` | No | — | No |
| POST | `/v1/learn/enrollments/{enrollment_id}/modules/{module_id}/quiz` | No | — | No |
| POST | `/v1/learn/enrollments/{enrollment_id}/pay` | No | — | No |

### Legacy Shoot (excluded from MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/legacy/checkout` | No | — | No |
| GET | `/v1/legacy/{legacy_booking_id}` | No | — | No |
| PUT | `/v1/legacy/{legacy_booking_id}/brief` | No | — | No |
| PUT | `/v1/legacy/{legacy_booking_id}/marketing-consent` | No | — | No |
| POST | `/v1/legacy/{legacy_booking_id}/reviews/{review_id}/respond` | No | — | No |
| GET | `/v1/legacy/{legacy_booking_id}/vault` | No | — | No |
| POST | `/v1/legacy/{legacy_booking_id}/vault/{vault_item_id}/download` | No | — | No |
| GET | `/v1/pro/legacy/assigned` | No | — | No |
| POST | `/v1/pro/legacy/{legacy_booking_id}/mark-shoot-done` | No | — | No |
| POST | `/v1/pro/legacy/{legacy_booking_id}/reviews/submit` | No | — | No |
| POST | `/v1/pro/legacy/{legacy_booking_id}/vault/upload` | No | — | No |

### Me / account

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/me` | Yes | `web/app/login/page.tsx:25`, `web/app/pro/login/page.tsx:24,27`, `web/app/pro/register/page.tsx:21` (`endpoints.me`) | Yes |
| GET | `/v1/me/certificates` | No | — | No |
| GET | `/v1/me/client-preference` | Yes | `web/app/settings/page.tsx:13` (`clientApi.getClientPreference`) | Yes |
| PUT | `/v1/me/client-preference` | No | `clientApi.putClientPreference` defined, never called | Yes |
| POST | `/v1/me/consent` | No | — | Ambiguous (media/review consent, MVP-adjacent) |
| PUT | `/v1/me/contact` | Yes | `web/app/settings/page.tsx:16` (`clientApi.putContact`) | Yes |
| GET | `/v1/me/enrollments` | No | — | No |
| GET | `/v1/me/game/quests` | No | — | No |
| GET | `/v1/me/game/seasons/current` | No | — | No |
| GET | `/v1/me/gamification/credentials` | No | — | No |
| GET | `/v1/me/gamification/cycle/current` | No | — | No |
| GET | `/v1/me/gamification/milestones` | No | — | No |
| GET | `/v1/me/locale` | No | — | Ambiguous (infra) |
| PUT | `/v1/me/locale` | No | — | Ambiguous |
| GET | `/v1/me/notification-preferences` | Yes | `web/app/settings/page.tsx:14` (`clientApi.getNotificationPreferences`) | Yes |
| PUT | `/v1/me/notification-preferences` | No | `clientApi.putNotificationPreferences` defined, never called | Yes |
| GET | `/v1/me/notification-topic-preferences` | No | — | Ambiguous |
| PUT | `/v1/me/notification-topic-preferences` | No | — | Ambiguous |
| GET | `/v1/me/notifications` | Broken | `web/app/client/notifications/page.tsx:10` calls `/v1/notifications` instead (wrong path) — **see List B** | Yes |
| POST | `/v1/me/notifications/read-all` | No | `clientApi.readAllNotifications` defined, never called | Yes |
| POST | `/v1/me/notifications/{notification_id}/read` | Broken | `web/app/client/notifications/page.tsx:12` calls `/v1/notifications/{id}/read` instead (wrong path) — **see List B** | Yes |
| GET | `/v1/me/referral-code` | No | — | No |
| POST | `/v1/me/referral-code/regenerate` | No | — | No |
| GET | `/v1/me/referrals/stats` | No | — | No |
| GET | `/v1/me/rewards/balance` | Yes | `web/app/rewards/page.tsx:11` (`clientApi.rewardsBalance`) | Yes |
| POST | `/v1/me/upgrade-to-pro` | Yes | `web/app/pro/login/page.tsx:26`, `web/app/pro/register/page.tsx:20` (`endpoints.upgradeToPro`) | Yes |

### Media

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/media/photos/uploads` | Yes | `web/app/pro/profile/portfolio/page.tsx:20` (`proApi.createPhotoUpload`) | Yes |
| POST | `/v1/media/photos/{media_asset_id}/complete` | Yes | `web/app/pro/profile/portfolio/page.tsx:30` (`proApi.completePhotoUpload`) | Yes |
| POST | `/v1/media/videos/mux/uploads` | No | — | Yes |
| POST | `/v1/media/videos/{media_asset_id}/playback-token` | No | — | Yes |
| GET | `/v1/media/{media_asset_id}` | No | `proApi.getMediaAsset` defined, never called | Yes |

### Niches

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/niches` | Yes | `web/app/pro/profile/listing-card/page.tsx:24` (`endpoints.nichesCatalog`) | Yes |

### Prints (client-side ecommerce beyond a balance display — excluded)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/prints/catalog` | No | `clientApi.printsCatalog` defined, never called | No |
| GET | `/v1/prints/orders/mine` | No | `clientApi.myPrintOrders` defined, never called | No |
| GET | `/v1/prints/orders/{order_id}` | No | `clientApi.printOrderDetail` defined, never called | No |
| PUT | `/v1/prints/orders/{order_id}` | No | `clientApi.updatePrintOrder` defined, never called | No |
| POST | `/v1/prints/orders/{order_id}/pay` | No | `clientApi.payPrintOrder` defined, never called | No |

### Pro

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/pro/bookings/{booking_request_id}/confirm-slot` | No | `proApi.confirmSlot` defined, never called (`web/app/pro/bookings/[id]/page.tsx` "Confirm schedule slot" button has no `onClick`) | Yes |
| GET | `/v1/pro/chat/threads` | Yes | `web/app/pro/dashboard/page.tsx:42`, `web/app/pro/inbox/page.tsx:11`, `web/app/pro/leads/page.tsx:11` (`proApi.listProThreads`) | Yes |
| GET | `/v1/pro/chat/threads/{thread_id}` | Yes | `web/app/pro/gigs/[gigId]/chat/page.tsx:16` (`proApi.getProThread`) | Yes |
| POST | `/v1/pro/chat/threads/{thread_id}/ai-draft` | Yes | `web/app/pro/gigs/[gigId]/chat/page.tsx:18` (`proApi.getAIDraft`) | **No — see List C** |
| POST | `/v1/pro/chat/threads/{thread_id}/messages` | Yes | `web/app/pro/gigs/[gigId]/chat/page.tsx:17` (`proApi.sendProMessage`) | Yes |
| GET | `/v1/pro/earnings/balance` | Yes | `web/app/pro/dashboard/page.tsx:41`, `web/app/pro/wallet/page.tsx:15` (`proApi.getEarningsBalance`) — response fields misread, see List B | Yes |
| GET | `/v1/pro/earnings/ledger` | Yes | `web/app/pro/wallet/page.tsx:16` (`proApi.getEarningsLedger`) | Yes |
| POST | `/v1/pro/me/activate` | No | — | Yes |
| POST | `/v1/pro/me/availability/blackouts` | No | — | Yes |
| POST | `/v1/pro/me/availability/rules` | No | — | Yes |
| GET | `/v1/pro/me/gear-benefits/access` | No | — | No (Gear Loan Vault-adjacent) |
| GET | `/v1/pro/me/gear-items` | No | — | Yes |
| POST | `/v1/pro/me/gear-items` | No | — | Yes |
| PUT | `/v1/pro/me/gear-items/{gear_item_id}` | No | — | Yes |
| PUT | `/v1/pro/me/niches` | No | — | Yes |
| POST | `/v1/pro/me/packages` | Broken | `web/app/pro/profile/packages/page.tsx:21` (`proApi.createPackage`) — **field mismatch, see List B** | Yes |
| PUT | `/v1/pro/me/packages/{package_id}` | Yes | `web/app/pro/profile/packages/page.tsx:32` (`proApi.updatePackage`) | Yes |
| POST | `/v1/pro/me/packages/{package_id}/disable` | Yes | `web/app/pro/profile/packages/page.tsx:41` (`proApi.disablePackage`) | Yes |
| POST | `/v1/pro/me/portfolio/{media_asset_id}/niches` | Yes | `web/app/pro/profile/portfolio/page.tsx:37` (`proApi.tagPortfolioMediaNiches`) | Yes |
| GET | `/v1/pro/me/profile` | Yes | `web/app/pro/profile/listing-card/page.tsx:22`, `web/app/pro/profile/page.tsx:65` | Yes |
| PUT | `/v1/pro/me/profile` | Yes | `web/app/pro/profile/listing-card/page.tsx:79`, `web/app/pro/profile/page.tsx:128` | Yes |
| GET | `/v1/pro/me/skills` | No | — | Yes |
| GET | `/v1/pro/niches/mine` | Yes | `web/app/pro/profile/listing-card/page.tsx:23` (`endpoints.myNiches`) | Yes |
| PUT | `/v1/pro/niches/mine` | Yes | `web/app/pro/profile/listing-card/page.tsx:89` (`endpoints.updateMyNiches`) | Yes |
| GET | `/v1/pro/onboarding` | Yes | `web/app/pro/onboarding/page.tsx:11` (`proApi.getOnboarding`) | Yes |
| GET | `/v1/pro/onboarding/checks` | Yes | `web/app/pro/onboarding/page.tsx:12`, `web/app/pro/dashboard/page.tsx:40` | Yes |
| POST | `/v1/pro/onboarding/complete-profile` | No | `proApi.onboardingCompleteProfile` defined, never called | Yes |
| POST | `/v1/pro/onboarding/configure-packages` | No | `proApi.onboardingConfigurePackages` defined, never called | Yes |
| POST | `/v1/pro/onboarding/select-niches` | No | `proApi.onboardingSelectNiches` defined, never called | Yes |
| POST | `/v1/pro/onboarding/start` | No | `proApi.onboardingStart` defined, never called | Yes |
| POST | `/v1/pro/onboarding/submit-kyc` | No | `proApi.onboardingSubmitKyc` defined, never called | Yes |
| POST | `/v1/pro/onboarding/upload-portfolio` | No | `proApi.onboardingUploadPortfolio` defined, never called | Yes |
| GET | `/v1/pro/payouts` | Yes | `web/app/pro/wallet/page.tsx:17` (`proApi.getPayouts`) | Yes |
| GET | `/v1/pro/payouts/account` | Yes | `web/app/pro/wallet/page.tsx:18` (`proApi.getPayoutAccount`) | Yes |
| PUT | `/v1/pro/payouts/account` | Yes | `web/app/pro/wallet/page.tsx:23` (`proApi.putPayoutAccount`) | Yes |
| POST | `/v1/pro/payouts/request` | Broken | `web/app/pro/wallet/page.tsx:34` (`proApi.requestPayout`) — default payload field mismatch, see List B | Yes |
| GET | `/v1/pro/scheduling/availability-rules` | Yes | `web/app/pro/calendar/page.tsx:16` | Yes |
| PUT | `/v1/pro/scheduling/availability-rules` | Yes | `web/app/pro/calendar/page.tsx:28` | Yes |
| GET | `/v1/pro/scheduling/exceptions` | Yes | `web/app/pro/calendar/page.tsx:17` | Yes |
| PUT | `/v1/pro/scheduling/exceptions` | Yes | `web/app/pro/calendar/page.tsx:35` | Yes |
| GET | `/v1/pro/scheduling/policy` | Yes | `web/app/pro/calendar/page.tsx:18` | Yes |
| PUT | `/v1/pro/scheduling/policy` | Yes | `web/app/pro/calendar/page.tsx:42` | Yes |
| GET | `/v1/pro/scheduling/slots` | Yes | `web/app/pro/calendar/page.tsx:21` | Yes |
| GET | `/v1/pro/{pro_user_id}/availability` | No | `proApi.getPublicAvailability` defined, never called | Yes |
| GET | `/v1/pro/{pro_user_id}/packages` | No | — | Yes |

### Proof galleries

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/proof-galleries/{gallery_id}` | Yes | `web/app/gigs/[gigId]/gallery/[galleryId]/page.tsx:15` (client) | Yes |
| GET | `/v1/proof-galleries/{gallery_id}/downloads` | No | `clientApi.getGalleryDownloads`/`proApi.getProofGalleryDownloads` defined, never called | Yes |
| POST | `/v1/proof-galleries/{gallery_id}/items` | No | `proApi.addProofGalleryItems` defined, never called | Yes |
| POST | `/v1/proof-galleries/{gallery_id}/publish` | Yes | `web/app/pro/gigs/[gigId]/delivery/page.tsx:17` (`proApi.publishProofGallery`) | Yes |
| POST | `/v1/proof-galleries/{gallery_id}/selections` | Yes | `web/app/gigs/[gigId]/gallery/[galleryId]/page.tsx:16` (client only; `proApi.saveGallerySelection` unused on pro side) | Yes |
| POST | `/v1/proof-galleries/{gallery_id}/selections/submit` | Yes | `web/app/gigs/[gigId]/gallery/[galleryId]/page.tsx:17` | Yes |
| POST | `/v1/proof-galleries/{gallery_id}/upsell/create-intent` | No | `clientApi.createUpsellIntent`/`proApi.createUpsellIntent` defined, never called | Yes |

### Pros (public)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/pros/{pro_user_id}/booking-requests` | No | — | Yes |
| POST | `/v1/pros/{pro_user_id}/chats` | No | — | Yes |
| GET | `/v1/pros/{pro_user_id}/public` | Yes | `web/app/pro/profile/listing-card/page.tsx:27,109`, `web/app/pro/profile/packages/page.tsx:16` | Yes |
| GET | `/v1/pros/{pro_user_id}/reviews` | No | — | Yes |
| GET | `/v1/pros/{pro_user_id}/skills` | No | — | Yes |

### Referrals / share / gamification (growth engine — excluded from MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/ref/{code}` | No | `clientApi.referralLanding` defined, never called | No |
| POST | `/v1/referrals/claim` | No | `clientApi.claimReferral` defined, never called | No |
| GET | `/v1/referrals/me` | No | — | No |
| GET | `/v1/share/{token}` | No | — | No |
| POST | `/v1/share/{token}/cta-click` | No | — | No |
| POST | `/v1/share/{token}/ping` | No | — | No |

### Repairs (Gear Loan Vault — excluded from MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/repairs/partners` | No | — | No |
| POST | `/v1/repairs/tickets` | No | — | No |
| GET | `/v1/repairs/tickets/{ticket_id}` | No | — | No |
| POST | `/v1/repairs/tickets/{ticket_id}/approve-quote` | No | — | No |
| POST | `/v1/repairs/tickets/{ticket_id}/close` | No | — | No |
| POST | `/v1/repairs/tickets/{ticket_id}/decline-quote` | No | — | No |
| POST | `/v1/repairs/tickets/{ticket_id}/request-loaner` | No | — | No |

### Reviews / rewards

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/reviews/{review_id}/reply` | No | — | Ambiguous (C11 mandatory review) |
| GET | `/v1/rewards/balance` | No | `clientApi.rewardsBalanceShared` defined, never called | Yes |
| GET | `/v1/rewards/ledger` | Yes | `web/app/rewards/page.tsx:12` (`clientApi.rewardsLedger`) | Yes |
| POST | `/v1/rewards/spend` | No | `clientApi.rewardsSpend` defined, never called | Yes |

### Search

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/search/courses` | No | — | No |
| GET | `/v1/search/products` | No | — | No |
| GET | `/v1/search/pros` | Yes | `web/app/search/page.tsx:16` (`clientApi.searchPros`), `web/app/pro/profile/listing-card/page.tsx:110` (`endpoints.searchPros`) | Yes |
| GET | `/v1/search/repair-partners` | No | — | No |

### Store (gear e-commerce storefront — excluded from MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/store/access` | No | — | No |
| GET | `/v1/store/cart` | No | — | No |
| POST | `/v1/store/cart/items` | No | — | No |
| DELETE | `/v1/store/cart/items/{item_id}` | No | — | No |
| POST | `/v1/store/checkout` | No | — | No |
| GET | `/v1/store/orders` | No | — | No |
| GET | `/v1/store/orders/{order_id}` | No | — | No |
| GET | `/v1/store/products` | No | — | No |
| GET | `/v1/store/products/{product_id}` | No | — | No |

### Studioverse (excluded from MVP)

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| GET | `/v1/studioverse/orders/mine` | No | — | No |
| POST | `/v1/studioverse/orders/{order_id}/download` | No | — | No |
| GET | `/v1/studioverse/packs` | No | — | No |
| POST | `/v1/studioverse/packs` | No | — | No |
| GET | `/v1/studioverse/packs/mine` | No | — | No |
| GET | `/v1/studioverse/packs/{pack_id}` | No | — | No |
| PUT | `/v1/studioverse/packs/{pack_id}` | No | — | No |
| POST | `/v1/studioverse/packs/{pack_id}/checkout` | No | — | No |
| POST | `/v1/studioverse/packs/{pack_id}/submit` | No | — | No |

### Webhooks

| Method | Path | Called? | Caller file(s) | MVP? |
|---|---|---|---|---|
| POST | `/v1/webhooks/mux` | No (server-to-server, expected) | — | Yes (infra) |
| POST | `/v1/webhooks/stripe` | No (server-to-server, expected) | — | Yes (infra) |
| POST | `/v1/webhooks/telephony` | No (server-to-server, expected) | — | No |

---

## List A — MVP endpoints with no frontend caller

The real gaps: MVP-scope endpoints nothing in `web/` calls (excludes the "Broken" rows above, which are covered in List B; a caller exists there, it's just wrong).

1. `GET /v1/booking-requests/{request_id}` — no caller. `clientApi.getBookingRequest` (`web/lib/api/clientApi.ts:80`) and `proApi.getBookingRequest` (`web/lib/api/proApi.ts:94`) are defined but never invoked.
2. `POST /v1/booking-requests/{request_id}/accept` — no caller. `proApi.acceptBookingRequest` (`web/lib/api/proApi.ts:95`) is unused; `web/app/pro/bookings/[id]/page.tsx:17` renders an "Accept request" `<Button>` with no `onClick`.
3. `POST /v1/booking-requests/{request_id}/decline` — no caller. `proApi.declineBookingRequest` (`web/lib/api/proApi.ts:96`) is unused; there is no decline UI at all.
4. `POST /v1/booking-requests/{request_id}/cancel` — no caller on either side. `clientApi.cancelBookingRequest` (`web/lib/api/clientApi.ts:81`) and `proApi.cancelBookingRequest` (`web/lib/api/proApi.ts:97`) are unused.
5. `POST /v1/pro/bookings/{booking_request_id}/confirm-slot` — no caller. `proApi.confirmSlot` (`web/lib/api/proApi.ts:98`) is unused; `web/app/pro/bookings/[id]/page.tsx:18` renders a "Confirm schedule slot" `<Button>` with no `onClick`. Together with #2–#4, the entire P10/P11 accept → confirm → decline flow is UI-decoration only.
6. `POST /v1/pro/onboarding/start` — no caller. `proApi.onboardingStart` (`web/lib/api/proApi.ts:68`) unused.
7. `POST /v1/pro/onboarding/complete-profile` — no caller. `proApi.onboardingCompleteProfile` (`web/lib/api/proApi.ts:69`) unused.
8. `POST /v1/pro/onboarding/select-niches` — no caller. `proApi.onboardingSelectNiches` (`web/lib/api/proApi.ts:70`) unused.
9. `POST /v1/pro/onboarding/configure-packages` — no caller. `proApi.onboardingConfigurePackages` (`web/lib/api/proApi.ts:71`) unused.
10. `POST /v1/pro/onboarding/upload-portfolio` — no caller. `proApi.onboardingUploadPortfolio` (`web/lib/api/proApi.ts:72`) unused.
11. `POST /v1/pro/onboarding/submit-kyc` — no caller. `proApi.onboardingSubmitKyc` (`web/lib/api/proApi.ts:73`) unused. Together with #6–#11, `web/app/pro/onboarding/page.tsx` (lines 11–12) only ever reads onboarding status; nothing in `web/` can actually complete any onboarding stage (P2–P7 in the MVP spec).
12. `GET /v1/pro/me/gear-items` — no caller anywhere. There is no gear-registration screen in `web/` at all (MVP spec P3 "Gear registration").
13. `POST /v1/pro/me/gear-items` — no caller, same gap as #12.
14. `PUT /v1/pro/me/gear-items/{gear_item_id}` — no caller, same gap.
15. `PUT /v1/pro/me/niches` — no caller (distinct from `/v1/pro/niches/mine`, which *is* called).
16. `GET /v1/pro/me/skills` — no caller. No niche-skill/tier display anywhere in `web/`.
17. `GET /v1/pro/{pro_user_id}/availability` — no caller. `proApi.getPublicAvailability` (`web/lib/api/proApi.ts:92`) is unused, so the client can never see a pro's booking calendar — MVP spec C4 explicitly requires "Availability calendar" on the photographer profile screen, and `web/app/pros/[id]/page.tsx` has no calendar UI.
18. `GET /v1/pro/{pro_user_id}/packages` — no caller. No screen renders a pro's package/pricing list to a client (C4 "decay curve shown as a simple table").
19. `POST /v1/pros/{pro_user_id}/booking-requests` — no caller (the pro-scoped alternate booking-request creation route; `web/app/pros/[id]/page.tsx` uses `/v1/client/bookings/request` instead, which is itself broken — see List B item 1).
20. `POST /v1/pros/{pro_user_id}/chats` — no caller. No chat-thread creation from a pro's profile page.
21. `GET /v1/pros/{pro_user_id}/reviews` — no caller. MVP spec C4 requires "Reviews (star breakdown, text, video reviews)" on the profile screen; nothing fetches them.
22. `GET /v1/pros/{pro_user_id}/skills` — no caller.
23. `POST /v1/gigs` — no caller. `proApi.createGig` (`web/lib/api/proApi.ts:101`) unused; there is no UI path that creates a gig record.
24. `POST /v1/gigs/{gig_id}/cancel-slot` — no caller. `proApi.cancelGigSlot` (`web/lib/api/proApi.ts:102`) unused.
25. `GET /v1/gigs/{gig_id}/consent` — no caller. `clientApi.getGigConsent`/`proApi.getGigConsent` unused.
26. `PUT /v1/gigs/{gig_id}/consent` — no caller. `clientApi.putGigConsent`/`proApi.putGigConsent` unused (C11 Step 3 consent toggle has no backend wiring).
27. `GET /v1/gigs/{gig_id}/media/{media_asset_id}/download` — no caller (C12 "Full-resolution downloads, individual + zip").
28. `GET /v1/gigs/{gig_id}/media/{media_asset_id}/signed-url` — no caller.
29. `POST /v1/gigs/{gig_id}/payments/stripe/create-intent` — no caller. `clientApi.createGigStripeIntent` unused — C6 "Stripe payment sheet → authorise/hold" has no wiring.
30. `POST /v1/gigs/{gig_id}/reschedule-request` — no caller.
31. `POST /v1/gigs/{gig_id}/review` — no caller. `clientApi.createGigReview` unused — **C11 mandatory review, the download gate, has zero backend wiring in `web/`.**
32. `GET /v1/proof-galleries/{gallery_id}/downloads` — no caller. C12 delivery/expiry-link screen has nothing behind it.
33. `POST /v1/proof-galleries/{gallery_id}/items` — no caller. `proApi.addProofGalleryItems` unused — pro can create+publish a gallery (per the table above) but never add items to it first.
34. `POST /v1/proof-galleries/{gallery_id}/upsell/create-intent` — no caller.
35. `POST /v1/media/videos/mux/uploads` — no caller. No video-review upload path (C11 Step 3 "30–60s video review").
36. `POST /v1/media/videos/{media_asset_id}/playback-token` — no caller.
37. `GET /v1/media/{media_asset_id}` — no caller. `proApi.getMediaAsset` unused.
38. `POST /v1/chat/threads` — no caller.
39. `GET /v1/chat/threads/{thread_id}` — no caller.
40. `POST /v1/chat/threads/{thread_id}/messages` — no caller.
41. `POST /v1/chat/threads/{thread_id}/create-booking` — no caller.
42. `GET /v1/chats/{thread_id}` — no caller.
43. `POST /v1/chats/{thread_id}/messages` — no caller.
44. `POST /v1/chats/{thread_id}/create-booking-request` — no caller.
45. `POST /v1/chats/{thread_id}/close` — no caller.
46. `POST /v1/chats/{thread_id}/takeover` — no caller. Items #38–46: **the client-facing messaging surface (C8) is completely unwired.** `web/app/chat/[threadId]/page.tsx` is a `useState`-only mock with a hardcoded "Hello, I want to discuss the booking." message and no network call of any kind — not even a real send button handler.
47. `POST /v1/client/match` — no caller. `clientApi.clientMatch` (`web/lib/api/clientApi.ts:69`) is unused; nothing implements the C2/C3 "match" flow distinct from plain `discover`.

(Note: `PUT /v1/me/client-preference`, `PUT /v1/me/notification-preferences`, `POST /v1/me/notifications/read-all`, `GET /v1/rewards/balance`, and `POST /v1/rewards/spend` are also unused MVP-adjacent endpoints, but are lower-severity infra/account gaps and are omitted from the numbered list above for brevity — they're visible as "No" rows with "MVP: Yes" in the full table.)

---

## List B — Frontend calls to endpoints that don't exist or have the wrong shape

1. **`web/app/discover/page.tsx:13`** calls `endpoints.discover(accessToken)` → `GET /v1/client/discover` with **no query parameters**. The real handler (`api/app/api/v1/client_launch.py:115-118`) declares `country: str` and `city: str` as required, default-less query parameters. Every real call from the Discover screen (C2, the client app's home screen) will 422. `endpoints.discover` (`web/lib/api/endpoints.ts:86`) never accepts or forwards a query object at all.

2. **`web/app/pros/[id]/page.tsx:21-29`** calls `endpoints.createBookingRequest(...)` → `POST /v1/client/bookings/request` with payload `{ pro_user_id, requested_start, requested_end, message }`. The real request schema, `ClientBookingRequestCreateRequest` (`api/app/schemas/client_launch.py:129-136`), requires `pro_user_id` (uuid, ✓ present), `niche_slug: str` (**missing — no UI field**), `date_window: { start_at, end_at }` (a **nested object**; the frontend sends flat `requested_start`/`requested_end` at the top level instead), `package_id: uuid` (**required, missing — no UI field**), and `notes` (the frontend sends `message` instead, which the backend never reads). This is the C5 "Booking request" screen's submit action — as written it cannot succeed against the real API (missing two required fields plus a shape mismatch on the date window). The response is also misread: the real response is `ClientBookingRequestCreateResponse { booking_id, status }` (`api/app/schemas/client_launch.py:139-141`), but `web/app/pros/[id]/page.tsx:44` reads `create.data.booking_request_id`, a field that doesn't exist on the response.

3. **`web/app/pro/profile/packages/page.tsx:11`** — the "Create package" textarea defaults to `{"title":"","price_per_photo":0,"min_photo_qty":0}`, posted via `proApi.createPackage` to `POST /v1/pro/me/packages`. The real schema, `ProPackageCreateRequest` (`api/app/schemas/onboarding.py:44-56`), has no `price_per_photo` or `min_photo_qty` fields; it requires `title`, `duration_minutes`, `price`, `included_photos`, `extra_photo_price` (plus optional `niche_id`/`niche_slug`/`currency`/etc). Confirms the earlier-audit finding is still live and gets the field names wrong in both directions (the two fields it does send don't exist on the schema; three required fields — `duration_minutes`, `price`, `included_photos`/`extra_photo_price` — are absent). Also, the same page's rendering at **line 62-63** reads `pkg.price_per_photo ?? pkg.extra_photo_price` and `pkg.min_photo_qty` from the public-profile packages list — `min_photo_qty` doesn't exist on `ClientProfilePackage`/`PublicProProfile.packages` either (`web/lib/api/endpoints.ts:34-41`), so "min qty" always renders as 0.

4. **`web/app/pro/wallet/page.tsx:62`** reads `(balanceQ.data.data as any).available_balance ?? (balanceQ.data.data as any).available` from the response of `GET /v1/pro/earnings/balance`. The real response fields (`api/app/services/payouts.py:335-339`, backed by `EarningsBalanceSnapshot`/schema in `api/app/schemas/payouts.py:20-24,89-93`) are `pending_eur`, `available_eur`, `held_eur`, `reserved_eur`, `withdrawable_eur`. Neither `available_balance` nor `available` exists — the wallet balance tile always renders `"-"`. Confirms the earlier-audit finding is still live.

5. **`web/app/pro/dashboard/page.tsx:74`** — the same bug as #4, independently: `String((balance as any).available_balance ?? (balance as any).available ?? "—")` reading the same `GET /v1/pro/earnings/balance` response on the dashboard's "Earnings balance" stat tile. Always renders `"—"`.

6. **`web/app/pro/wallet/page.tsx:12`** — the "Request payout" input defaults to `'{"amount": 0}'`, posted via `proApi.requestPayout` to `POST /v1/pro/payouts/request`. The real schema `PayoutRequestCreateRequest` (`api/app/schemas/payouts.py:61-62`) has one field, `amount_eur`, not `amount`. Submitting the default payload as-is will 422 (or, if `amount` is silently ignored by Pydantic and `amount_eur` is required, 422 regardless).

7. **`web/app/providers.tsx:16`** calls `endpoints.flags(accessToken)` → `GET /v1/feature-flags`. No such route exists — `docs/api_endpoints.md` only has `GET /v1/admin/feature-flags` (admin-only) and `PUT /v1/admin/ai/feature-flags`. `endpoints.flags` (`web/lib/api/endpoints.ts:95`) targets a route that was never built for non-admin users. The call always fails and the app silently falls back to a hardcoded flag map (`web/app/providers.tsx:19-30`), so in practice every feature flag in the app is client-hardcoded, never server-controlled, masking the bug in normal use.

8. **`web/app/client/bookings/page.tsx:11`** calls `endpoints.clientBookings(accessToken)` → `GET /v1/client/bookings`. No such route exists; `docs/api_endpoints.md` only has `GET /v1/client/bookings/{booking_id}` (requires an id) and `POST /v1/client/bookings/request`. There is no "list my bookings" endpoint at all in the current API, so the C13 "My bookings" list screen cannot be implemented against this backend as written. `endpoints.clientBookings` (`web/lib/api/endpoints.ts:90`).

9. **`web/app/client/notifications/page.tsx:10,12`** calls `endpoints.notifications(accessToken)` → `GET /v1/notifications` and `endpoints.markNotificationRead(id, accessToken)` → `POST /v1/notifications/{id}/read`. The real routes are `GET /v1/me/notifications` and `POST /v1/me/notifications/{notification_id}/read` (both missing the `/me` prefix in the frontend). `endpoints.notifications`/`endpoints.markNotificationRead` (`web/lib/api/endpoints.ts:93-94`). Both calls 404 every time the notifications screen loads.

---

## List C — Non-MVP endpoints with frontend callers

1. **`POST /v1/pro/chat/threads/{thread_id}/ai-draft`** — called from `web/app/pro/gigs/[gigId]/chat/page.tsx:18` ("AI Draft" button, `proApi.getAIDraft`). The MVP spec explicitly excludes "AI tooling" from launch scope; this wires a live AI-assist feature into the pro chat screen anyway.
2. **`GET /v1/client/access`** and **`POST /v1/client/waitlist`** — called from `web/app/waitlist/page.tsx:14-15`. There is no Waitlist screen anywhere in the MVP spec's 13 client screens (C1–C13); this looks like a pre-launch gating mechanism built for a phase before the MVP's normal booking flow, not part of it.
3. **`web/app/client/gigs/[id]/checkout-extras/page.tsx`** — gated behind a `checkout_extras_enabled` flag; simulates "Purchase extra images and unlock final download entitlement" with local state only (no real endpoint call yet), for a feature not described anywhere in the MVP spec (MVP scope is capped at "client-side ecommerce beyond a balance display" being excluded). Flagged here because it's built and routed even though not wired to a real call yet — worth tracking as scope creep once it is wired.
4. **`web/app/rewards/page.tsx`** calling `GET /v1/me/rewards/balance` and `GET /v1/rewards/ledger` is itself in-scope ($RAWW ledger is explicit MVP scope) — but note `web/lib/api/clientApi.ts` also defines `rewardsSpend` (`POST /v1/rewards/spend`) with no caller, and the MVP spec's P15 "$RAWW wallet" redemption flow is pro-side, not client-side; the client `rewards` page duplicates ledger display without a redemption action, suggesting the two didn't get built to the same spec.
5. **`web/app/pro/profile/listing-card/page.tsx`** ("Listing Card" editor, distinct from `web/app/pro/profile/page.tsx`'s "Profile" editor) — both screens edit overlapping fields (`headline`, `cover_media_asset_id`) via the same two endpoints (`GET/PUT /v1/pro/me/profile`), plus niches. This isn't calling a non-existent endpoint, but it's a second, redundant profile-editing screen not distinguished anywhere in the MVP spec's single P2 "Onboarding — profile" screen — worth flagging as duplicate screens against the same MVP-scope endpoints rather than a distinct non-MVP feature.
6. **`GET /v1/i18n/bundles`** — called from `web/app/admin/page.tsx:8`. i18n bundle loading is infrastructure for a multi-locale rollout (the repo's commit history shows "Internationalization v1 (locales, bundles, templates)" as its own separate build item), not anything the MVP screens/booking-flow doc mentions.

---

## Reconciliation against existing docs

### `docs/CLIENT_ENDPOINTS_USED.md`

The doc's header (line 4) says these endpoints are "Implemented in: `web/lib/api/clientApi.ts`". That's misleading on two counts: (a) a large share of the endpoints it lists as "used" are functions that exist in `clientApi.ts` but are **never called from any page** — the file defines a wrapper, nothing invokes it; (b) several endpoints that genuinely *are* wired up in the running app go through `web/lib/api/endpoints.ts`, a completely different, older client file the doc never mentions at all — and that file has real bugs the doc can't surface since it doesn't know the file exists.

Specific problems, by section:

- **Auth / identity (lines 8-16):** All 9 listed endpoints (`/v1/me`, login, register, logout, refresh, password-reset ×2, verify-email ×2) are defined in `clientApi.ts` but **none of them are actually invoked from `clientApi.ts` at runtime** — every real auth call in `web/` (login/register/me/logout pages) goes through `endpoints.ts` instead (`web/app/login/page.tsx`, `web/app/pro/login/page.tsx`, `web/app/pro/register/page.tsx`, `web/app/register/page.tsx`, `web/components/app-shell.tsx`). The doc's file attribution is wrong for the entire section. Also, `refresh`, password-reset, and verify-email are not called from *any* file, correct or otherwise — no refresh-token-on-401 flow exists in `web/`, and there is no UI for password reset or email verification beyond static placeholder pages (`web/app/reset-password/page.tsx`, `web/app/verify-email/page.tsx` — both call nothing).
- **Discovery / matching (lines 18-26):** `POST /v1/client/match` (line 21) and `GET /v1/pros/{pro_user_id}/public` (line 23, as called from `clientApi.getProPublic`) are listed as used but have **zero callers** anywhere in `web/`. `GET /v1/client/discover` (line 20) is called, but is broken (List B #1) — the doc doesn't note this. `GET /v1/client/pros/{pro_user_id}` (line 24) is called, but via `endpoints.ts`, not `clientApi.ts` as the doc implies.
- **Booking / requests (lines 28-33):** `GET /v1/client/bookings/{booking_id}` and `POST /v1/client/bookings/{booking_id}/pay` (lines 29-30) are called, correctly, but via `endpoints.ts` (`web/app/client/bookings/[id]/page.tsx`), not `clientApi.ts`. `POST /v1/client/bookings/{booking_request_id}/time-windows` (line 31), `GET /v1/booking-requests/{request_id}` (line 32), and `POST /v1/booking-requests/{request_id}/cancel` (line 33) are listed as used but have no caller at all. `POST /v1/client/bookings/request` (line 28) *is* called (`web/app/pros/[id]/page.tsx`, via `endpoints.ts` again) but is broken (List B #2) — not noted.
- **Gigs / gallery / media (lines 35-48):** Of the 13 endpoints listed, only 6 are actually called (`gigs/{gig_id}`, `gigs/{gig_id}/media`, `proof-galleries/{gallery_id}`, `.../selections`, `.../selections/submit`). The other 7 — `gigs/{gig_id}/consent` (get+put), `payments/stripe/create-intent`, `review`, `media/{id}/signed-url`, `media/{id}/download`, `upsell/create-intent`, `downloads` — are listed as "used" but have no caller anywhere in `web/`. Notably `POST /v1/gigs/{gig_id}/review` — the mandatory-review download gate that's core to the MVP spec (C11) — is claimed as used and isn't.
- **Disputes (lines 50-56):** All 6 listed dispute endpoints have **zero callers**. `clientApi.ts` defines wrapper functions for all of them; none is invoked from any page (there's a `web/app/client/disputes/page.tsx` route, but it's a static `EmptyState` with no query or mutation at all).
- **Preferences / notifications / rewards (lines 58-70):** `PUT /v1/me/client-preference`, `PUT /v1/me/notification-preferences`, `GET /v1/me/notifications`, `POST /v1/me/notifications/read-all`, `POST /v1/me/notifications/{notification_id}/read`, `GET /v1/rewards/balance` (the non-`/me` variant), `POST /v1/rewards/spend` — all listed as used, none actually called via `clientApi.ts`. Worse: the *real* notifications endpoints (`GET /v1/me/notifications`, `POST /v1/me/notifications/{id}/read`) genuinely are hit by the app, but through `endpoints.ts` calling the **wrong path** (List B #9) — the doc lists the correct path as "used" when what's actually running is a 404.
- **Prints / referrals (lines 72-84):** All 11 listed endpoints have **zero callers** anywhere in `web/` — not just unused via `clientApi.ts`, unused period. There is no prints or referrals UI in the app at all beyond the wrapper functions.
- **Analytics (line 86):** `POST /v1/analytics` is listed and is indeed called — but via `proApi.track` (pro side) in several pro pages, not via `clientApi.track` on the client side, which is unused.

### `docs/PRO_ENDPOINTS_USED.md`

This doc is closer to reality than the client one — most of what it lists genuinely is defined in `web/lib/api/proApi.ts` and the file attribution (line 3, "Used by `web/lib/api/proApi.ts`") is directionally accurate — but roughly a third of the listed endpoints still have no actual caller, and the biggest gaps cluster around onboarding and booking-request lifecycle, both MVP-critical:

- **Onboarding (lines 12-19):** `POST /v1/pro/onboarding/start`, `.../complete-profile`, `.../select-niches`, `.../configure-packages`, `.../upload-portfolio`, `.../submit-kyc` — all 6 listed as used; **none are called**. `web/app/pro/onboarding/page.tsx` only calls the two `GET` endpoints (lines 12-13 of the doc, correctly). The doc overstates onboarding coverage significantly — the actual onboarding *submission* flow doesn't exist in `web/` at all.
- **Niches (lines 20-22):** `GET/PUT /v1/pro/niches/mine` are listed and called, but via `endpoints.ts` (`web/app/pro/profile/listing-card/page.tsx`), not `proApi.ts` as the doc's header implies — same cross-file attribution issue as the client doc. `GET /v1/niches` (line 22) likewise via `endpoints.ts`.
- **Search / public profile (lines 27-28):** `GET /v1/search/pros` and `GET /v1/pros/{pro_user_id}/public` are listed as used by `proApi.ts`; `proApi.searchPros` itself is never called (the only live caller of `/v1/search/pros` on the pro side goes through `endpoints.ts` in the listing-card page), though `proApi.getPublicProProfile` is genuinely called (`web/app/pro/profile/packages/page.tsx:16`).
- **Scheduling (lines 29-36):** All 8 listed scheduling endpoints (availability-rules get/put, exceptions get/put, policy get/put, slots, public availability) are listed as used. Seven of the eight really are called from `web/app/pro/calendar/page.tsx`. The eighth, `GET /v1/pro/{pro_user_id}/availability` (line 36), has **no caller** — it's the public-facing calendar a client would need to see (List A #17), and nothing in the pro app needs to call it either, so it's simply dead.
- **Booking requests (lines 37-41):** `GET /v1/booking-requests/{request_id}`, `POST .../accept`, `POST .../decline`, `POST .../cancel`, `POST /v1/pro/bookings/{id}/confirm-slot` — all 5 listed as used; **none are called**. This is the single biggest gap in the doc: it claims the accept/decline/confirm-slot lifecycle is wired up, but `web/app/pro/bookings/[id]/page.tsx` is a static page with inert buttons (List A #2-5).
- **Gigs (lines 42-45):** `POST /v1/gigs`, `POST .../cancel-slot`, `POST .../reschedule-request` — listed as used, **not called**. `GET /v1/gigs/{gig_id}` (line 43) is correctly called.
- **Consent (lines 46-47):** `GET/PUT /v1/gigs/{gig_id}/consent` — listed, not called.
- **Media / gallery (lines 48-59):** Of 10 listed, 4 are genuinely called (`share-links` is not — line 51 — nor is `proof-gallery` create's sibling `items`/`downloads`/`upsell` at lines 54, 58-59; `POST /v1/gigs/{gig_id}/proof-gallery` and `POST /v1/proof-galleries/{gallery_id}/publish`, lines 52 and 55, are the two that are real). `saveGallerySelection`/`submitGallerySelection` (lines 56-57) are also defined but unused on the pro side (the client side does use the same paths, just via `clientApi`, so the paths themselves aren't dead — but as "pro endpoints used" the doc's claim is specifically wrong).
- **Payouts / earnings (lines 67-72):** All correctly listed and called (`getEarningsBalance`, `getEarningsLedger`, `getPayouts`, `getPayoutAccount`, `putPayoutAccount`, `requestPayout`) — this section of the doc is accurate, modulo the field-shape bugs in List B (which the doc, reasonably, wouldn't be expected to catch since it only tracks call sites, not payload correctness).
- **Analytics (line 73):** `POST /v1/analytics` — correct, called via `proApi.track` from several pages.

Neither doc names a caller file incorrectly in the sense of pointing at a file that's been renamed or deleted — both file paths (`web/lib/api/clientApi.ts`, `web/lib/api/proApi.ts`) exist and are current. The inaccuracy in both is entirely about **listing endpoints as "used" when the defining function is never invoked**, and, in the client doc's case, about **not knowing `web/lib/api/endpoints.ts` exists** even though it's the file that actually drives auth, discover, pro-profile, listing-card, admin, and notifications — including three of this audit's route-level bugs.
