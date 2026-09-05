# RAWWERS Web (Slice #32)

Mobile-first PWA-capable Next.js web app scaffold aligned to backend slices and designed to mirror Flutter later.

## Stack

- Next.js App Router + TypeScript
- Tailwind with strict design tokens
- TanStack Query for data fetching/cache
- Zod for form validation
- OpenAPI codegen (`openapi-typescript`)
- Optional PWA via `next-pwa`

## Setup

1. Install deps:

```bash
cd web
pnpm install
```

2. Configure env:

```bash
cp .env.example .env.local
```

3. Generate typed API schema:

```bash
pnpm run generate:api
```

4. Run dev server:

```bash
pnpm dev
```

## Env vars

- `NEXT_PUBLIC_API_BASE_URL`: backend base URL (default `http://localhost:8000`)
- `OPENAPI_SCHEMA_URL`: OpenAPI URL for codegen
- `NEXT_PUBLIC_ANALYTICS_ENDPOINT`: optional analytics collector endpoint
- `PLAYWRIGHT_BASE_URL`: base URL for e2e tests

## API codegen

Command:

```bash
pnpm run generate:api
```

Output file:

- `lib/api/generated/schema.ts`

`lib/api/endpoints.ts` uses generated types where available and provides typed wrappers for core flows.

## Auth model

Current web v1:

- Access token kept in memory/session storage.
- Refresh token kept in session storage (temporary until backend cookie refresh endpoint is finalized for web).
- API wrapper injects `Authorization: Bearer <access_token>`.
- `credentials: include` enabled to support future httpOnly refresh cookie migration without API redesign.

## Feature flags

- Flags fetched from backend via `lib/api/endpoints.ts` and cached in React Query.
- Use `<Flag name="..." fallback={...}>...</Flag>` to gate modules.

Current gates used in UI:

- `client_discovery_enabled`
- `proof_gallery_enabled`
- `pro_onboarding_enabled`
- `ai_concierge_enabled`

## Design system

Single-source tokens:

- `design-system/tokens.ts`
- mirrored in `tailwind.config.ts`

Core primitives:

- Button, IconButton
- Card
- Input, Textarea, Select
- BottomSheet
- Tabs
- Badge
- Toast
- Skeleton
- EmptyState

No ad-hoc page CSS outside tokenized utilities.

## Core routes implemented

Public:

- `/`
- `/discover`
- `/pros/[id]`
- `/share/[token]`

Auth:

- `/login`
- `/register`
- `/verify-email`
- `/reset-password`

Client:

- `/client/home`
- `/client/bookings`
- `/client/bookings/[id]`
- `/client/gigs/[id]/proofs`
- `/client/gigs/[id]/checkout-extras`
- `/client/notifications`
- `/client/disputes`

Pro:

- `/pro/onboarding`
- `/pro/inbox`
- `/pro/bookings/[id]`
- `/pro/gigs/[id]/upload`
- `/pro/gigs/[id]/publish`
- `/pro/notifications`

Shared:

- `/chat/[threadId]`

## Performance / reliability

- Route-level loading skeletons on key flows
- Query stale times configured for hot paths
- Global error boundary with request-id slot
- PWA manifest + service worker registration via `next-pwa`

## Tests

Playwright smoke tests:

```bash
pnpm run test:e2e
```

Includes checks for:

- login page
- discover flow shell
- booking request page load
- proof selection page load

## Deployment notes

### Vercel

- Set `NEXT_PUBLIC_API_BASE_URL` to your backend public URL.
- Ensure backend CORS allows web origin and credentials for refresh-cookie migration.
- Build command: `pnpm build`.

### Container

- Build a Node 20 image and run `pnpm build && pnpm start`.
- Expose port `3000`.
- Pass env vars from `.env.example`.

## Flutter mirroring guidance

To mirror in Flutter with minimal redesign:

- Reuse token values from `design-system/tokens.ts`
- Keep component API atomic (Button/Card/Input/etc.)
- Keep route modules bounded by feature flags
- Keep API wrapper semantics consistent (`endpoints.ts`) across clients

## Before committing


> rawwers-web@0.1.0 verify /Users/gustavobarbosa/Documents/RAWWERS/web
> pnpm lint && pnpm typecheck && pnpm build


> rawwers-web@0.1.0 lint /Users/gustavobarbosa/Documents/RAWWERS/web
> next lint

? How would you like to configure ESLint? https://nextjs.org/docs/basic-features/eslint
[?25l❯  Strict (recommended)
   Base
   Cancel ELIFECYCLE  Command failed with exit code 1.
 ELIFECYCLE  Command failed with exit code 1.

Runs lint, typecheck and build - the same three the CI web job runs.

Worth doing locally because CI only runs on push, and this repository has
gone long stretches unpushed. The build broke on 2026-09-03 (a stale
import left behind by the API client consolidation) and stayed broken,
because nothing ran between the commit and the next person to try.
