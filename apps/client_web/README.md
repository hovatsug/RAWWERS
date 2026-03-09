# RAWWERS Client Web

This app currently reuses the existing Next.js implementation under `web/`.

## API adapter
- `web/lib/api/clientApi.ts`
- Compatibility export: `apps/client_web/src/api/clientApi.ts`

## Run
```bash
cd web
pnpm install
pnpm dev
```

## Main routes
- `/`
- `/discover` / `/search`
- `/pros/[id]`
- `/client/bookings/*`
- `/client/notifications`
- `/client/gigs/[id]/proofs`
