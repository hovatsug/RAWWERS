# PRO Web Integration Map

## Existing foundation reused
- API client: `web/lib/api/client.ts`
  - Function: `apiRequest(path, opts)`
  - Handles: `/v1` prefix, bearer token header, typed `ApiError`
- Endpoint module: `web/lib/api/endpoints.ts`
  - Existing auth + pro/profile/listing-card calls
- Auth/session: `web/lib/auth/store.tsx`
  - Session storage keys in `rawwers_session`
  - Fields: `accessToken`, `refreshToken`, `roles`, `userId`
- Query + app providers: `web/app/providers.tsx`
- Existing Pro routes:
  - `web/app/pro/onboarding/page.tsx`
  - `web/app/pro/inbox/page.tsx`
  - `web/app/pro/bookings/[id]/page.tsx`
  - `web/app/pro/gigs/[id]/upload/page.tsx`
  - `web/app/pro/gigs/[id]/publish/page.tsx`
  - `web/app/pro/profile/listing-card/page.tsx`

## New adapter added
- `web/lib/api/proApi.ts`
  - Consistent Result type:
    - `{ ok: true, data }`
    - `{ ok: false, error }`
  - Covers auth/me, onboarding/profile, scheduling, booking/gig, proof galleries, media uploads, chat, payouts, analytics
- Compatibility export:
  - `apps/pro_web/src/api/proApi.ts`

## How to add endpoints safely
1. Prefer adapter additions in `web/lib/api/proApi.ts`.
2. Keep direct URL usage out of pages/components.
3. Use `apiRequest` only (for shared error behavior).
4. Return `Result<T>` from every adapter method.

## Where to place glue code
- New query hooks: `web/lib/pro/*` (recommended)
- Feature pages: `web/app/pro/**`
- Shared Pro UI components: `web/components/pro/**` (recommended)

## Missing / constraints
- No dedicated list endpoint for gigs or booking requests in provided catalog:
  - use thread metadata and id-driven fetch flows
- Listing-card cover media persistence depends on profile schema support; fallback is selected portfolio id persisted in profile when available.
