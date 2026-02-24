# RAWWERS API - Foundations v1/v2/v3/v4

Backend foundation for:
- Media subsystem (R2 photos + Mux short-video upload/webhooks/playback token)
- Gig lifecycle + Stripe full-payment flow + internal ledger
- Admin operations v0 (roles, KYC hooks, bans, disputes, refund ops, audit logs)
- Proof galleries + client selection + paid extras + original delivery

## Stack
- FastAPI + SQLAlchemy + Alembic
- PostgreSQL (EU region recommended in production)
- Celery + Redis
- Cloudflare R2 (S3-compatible)
- Mux + Stripe

## Environment Variables
Copy `.env.example` to `.env` and set values:
- `DATABASE_URL`
- `REDIS_URL`
- `R2_ENDPOINT_URL`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET`
- `R2_REGION`
- `MUX_TOKEN_ID`
- `MUX_TOKEN_SECRET`
- `MUX_WEBHOOK_SECRET`
- `MUX_SIGNING_KEY_ID`
- `MUX_SIGNING_KEY_PRIVATE`
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_API_VERSION`
- `STRIPE_WEBHOOK_ALLOW_UNVERIFIED` (default false; dev/test only)
- `PLATFORM_FEE_BPS` (default 2000 => 20%)
- `APP_PUBLIC_URL`
- `ADMIN_USER_IDS` (comma-separated UUIDs that auto-seed admin role)
- `BAN_ENFORCEMENT_MODE` (`strict` default, `warn` logs-only)
- `APP_ENV`
- `LOG_LEVEL`

## Local Run
```bash
cd api
cp .env.example .env
make up
```

## Migrations
```bash
cd api
make migrate
```

## Tests
```bash
cd api
make test
```

## API Base Path
`/v1`

## Dev Auth
Set header `X-User-Id: <uuid>`.

## Admin Seeding
Set `ADMIN_USER_IDS` in `.env`:
```env
ADMIN_USER_IDS=00000000-0000-0000-0000-0000000000aa
```
When that user hits any admin endpoint, role `admin` is persisted in DB automatically if missing.

## Safety Rails
- Banned/suspended users are blocked from create flows (gig creation, media upload, payment intent creation, dispute/evidence creation, proof selection changes).
- In `BAN_ENFORCEMENT_MODE=strict`, banned users get `403`.
- Payment intent creation requires pro KYC approved in non-dev environments unless `gig.metadata.allow_unverified_pro=true` and app is dev.

## Foundation #4 Flow (Proof Gallery)
1. Pro creates gallery for a gig.
2. Pro attaches proof photos (must be pro-owned photo media with `watermark_preview` ready).
3. Pro publishes gallery.
4. Client saves and submits selection.
5. If selection exceeds included photos, upsell PaymentIntent is created.
6. Stripe webhook marks upsell succeeded.
7. Client downloads unlocked originals (signed short-lived links).

## Proof Gallery cURL
Create gallery (pro):
```bash
curl -X POST http://localhost:8000/v1/gigs/<gig_id>/proof-gallery \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <pro_user_id>" \
  -d '{"included_photos":20,"extra_photo_price":"10.00"}'
```

Add gallery items (pro):
```bash
curl -X POST http://localhost:8000/v1/proof-galleries/<gallery_id>/items \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <pro_user_id>" \
  -d '{"media_asset_ids":["<media_asset_uuid_1>","<media_asset_uuid_2>"]}'
```

Publish gallery (pro):
```bash
curl -X POST http://localhost:8000/v1/proof-galleries/<gallery_id>/publish \
  -H "X-User-Id: <pro_user_id>"
```

View gallery (client/pro/admin):
```bash
curl -X GET http://localhost:8000/v1/proof-galleries/<gallery_id> \
  -H "X-User-Id: <client_or_pro_or_admin_id>"
```

Save selection draft (client):
```bash
curl -X POST http://localhost:8000/v1/proof-galleries/<gallery_id>/selections \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <client_user_id>" \
  -d '{"media_asset_ids":["<media_asset_uuid_1>","<media_asset_uuid_2>"]}'
```

Submit selection (client):
```bash
curl -X POST http://localhost:8000/v1/proof-galleries/<gallery_id>/selections/submit \
  -H "X-User-Id: <client_user_id>"
```

Create/retrieve upsell intent (client):
```bash
curl -X POST http://localhost:8000/v1/proof-galleries/<gallery_id>/upsell/create-intent \
  -H "X-User-Id: <client_user_id>"
```

Get download links for unlocked originals (client/admin):
```bash
curl -X GET http://localhost:8000/v1/proof-galleries/<gallery_id>/downloads \
  -H "X-User-Id: <client_or_admin_user_id>"
```

## Admin cURL
List users:
```bash
curl -X GET "http://localhost:8000/v1/admin/users?limit=20&offset=0" \
  -H "X-User-Id: 00000000-0000-0000-0000-0000000000aa"
```

Ban user:
```bash
curl -X POST http://localhost:8000/v1/admin/users/<user_id>/ban \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 00000000-0000-0000-0000-0000000000aa" \
  -d '{"action":"banned","reason":"Fraud risk"}'
```

KYC approve pro:
```bash
curl -X POST http://localhost:8000/v1/admin/pros/<pro_user_id>/kyc \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 00000000-0000-0000-0000-0000000000aa" \
  -d '{"kyc_status":"approved","note":"Documents verified"}'
```

Open dispute (participant):
```bash
curl -X POST http://localhost:8000/v1/disputes \
  -H "Content-Type: application/json" \
  -H "X-User-Id: <client_or_pro_user_id>" \
  -d '{"gig_id":"<gig_id>","category":"quality","summary":"Final edit quality mismatch"}'
```

Admin refund:
```bash
curl -X POST http://localhost:8000/v1/admin/gigs/<gig_id>/refunds \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 00000000-0000-0000-0000-0000000000aa" \
  -d '{"reason":"Dispute resolution"}'
```

## Webhooks Local
Stripe webhook target:
- `http://localhost:8000/v1/webhooks/stripe`

Mux webhook target:
- `http://localhost:8000/v1/webhooks/mux`

If you need unsigned Stripe payloads in development only:
- set `STRIPE_WEBHOOK_ALLOW_UNVERIFIED=true`
- keep `APP_ENV=development`

## Ledger Convention
- Positive `ledger_entry.amount`: money received by platform.
- Negative `ledger_entry.amount`: money leaving platform.
- Hold entries use `amount=0.00` with hold amount in description.

## Notes
- Webhooks are idempotent.
- Stripe verification uses `stripe.Webhook.construct_event` and fails closed unless dev override is explicitly enabled.
- User uploads are never stored on local disk.
