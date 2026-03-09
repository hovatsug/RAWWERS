# CLIENT Web Integration Map

## Existing foundation reused
- API client: `web/lib/api/client.ts`
  - `apiRequest(path, opts)`
  - Handles `/v1` prefix + bearer + error wrapping
- Auth/session: `web/lib/auth/store.tsx`
  - Session keys: `accessToken`, `refreshToken`, `roles`, `userId`, `locale`
- Query provider: `web/app/providers.tsx`
- Existing client pages (partial):
  - `web/app/discover/page.tsx`
  - `web/app/pros/[id]/page.tsx`
  - `web/app/client/bookings/*`
  - `web/app/client/notifications/page.tsx`
  - `web/app/client/gigs/[id]/proofs/page.tsx`

## Client adapter added
- `web/lib/api/clientApi.ts`
  - Uniform `Result<T>`:
    - `{ ok: true, data }`
    - `{ ok: false, error }`
  - Covers auth, discovery, bookings, gigs, proof gallery, disputes, notifications, rewards, prints, referrals.

## Compatibility export
- `apps/client_web/src/api/clientApi.ts`

## Safe extension rules
1. Add endpoint methods only in `web/lib/api/clientApi.ts`.
2. Keep pages/components free of raw fetch URL strings.
3. Use existing query/state patterns in `web/app/providers.tsx`.

## Missing/constraints observed
- No list endpoint for `GET /v1/client/bookings` in required catalog, but old UI had one. Current safe fallback should store recent booking IDs locally and fetch by id.
- Some payment/intent response fields are schema-unknown; keep payload passthrough in UI until backend fields are explicit.
