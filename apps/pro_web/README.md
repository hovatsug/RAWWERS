# RAWWERS Pro Web

This package reuses the existing `web/` Next.js foundation.

- Core API client: `web/lib/api/client.ts`
- Pro adapter: `web/lib/api/proApi.ts`
- Compatibility export: `apps/pro_web/src/api/proApi.ts`

Run the existing web app:

```bash
cd web
pnpm install
pnpm dev
```

Primary Pro routes currently live under `web/app/pro/*`.
