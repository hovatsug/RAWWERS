# Mux webhooks on the dev API

Mux tells the API what happened to an uploaded video through webhooks. In dev, Mux cannot reach `localhost`, so the Mux CLI receives the events and forwards them to the dev API, signed with a secret of its own.

## What the API has

- **The route:** `POST /v1/webhooks/mux`. On the dev stack that is `http://localhost:8000/v1/webhooks/mux` (container `api-api-1`, port 8000).
- **The signature:** the `mux-signature` header (`t=<unix time>,v1=<HMAC-SHA256 of "<t>.<body>">`) is checked against `MUX_WEBHOOK_SECRET`. A wrong signature, one older than 5 minutes, or an empty `MUX_WEBHOOK_SECRET` gets 401 and changes nothing.
- **A quick answer:** the route stores the event in the outbox, keyed by Mux's event id, and answers 200. The worker applies it. A repeat delivery (Mux retries for up to 24 hours) is stored once.
- **The events it applies:**

  | Event | What happens to the video |
  |---|---|
  | `video.upload.asset_created` | linked to its Mux asset, now `processing` |
  | `video.asset.ready` | `ready`, with its playback id |
  | `video.asset.errored` | `failed`, with Mux's error |
  | `video.upload.errored`, `video.upload.cancelled` | `failed` (the upload itself failed or timed out) |

  If an asset event arrives before `asset_created`, the video is found by its upload id. A ready or failed video never moves back.
- **If no webhook arrives:** the `mux-sync` job (beat, every `MUX_SYNC_INTERVAL_SECONDS`, 300) asks Mux about each video still uploading or processing after `MUX_SYNC_STALE_MINUTES` (10), up to `MUX_SYNC_MAX_AGE_HOURS` (48) old. It applies what Mux reports through the same handler. So in dev a video settles within about 15 minutes even with no CLI running. The webhook makes it immediate.
- **The other Mux settings** (`api/.env`): `MUX_TOKEN_ID` and `MUX_TOKEN_SECRET` (API access), `MUX_SIGNING_KEY_ID` and `MUX_SIGNING_KEY_PRIVATE` (signed playback tokens).

## Forwarding to the dev API

1. **Sign the CLI in to the same Mux environment as the API.** Either:
   - `mux login --env-file api/.env`, which reads `MUX_TOKEN_ID` and `MUX_TOKEN_SECRET` from that file; or
   - `mux login`, which opens the browser. Pick the environment the API's token belongs to.

   Check with `mux whoami`.
2. **Start forwarding** (leave it running in its own terminal):

   ```sh
   mux webhooks listen --forward-to http://localhost:8000/v1/webhooks/mux
   ```

   It prints `Webhook signing secret: <hex>`. The CLI keeps that secret per Mux environment, so it stays the same on every run. You set it once.
3. **Give the API the secret.** In `api/.env`:

   ```sh
   MUX_WEBHOOK_SECRET=<the hex the CLI printed>
   ```

   Only the `api` container checks it.
4. **Restart the API** so it reads `.env` again. `docker compose restart` does not re-read `env_file`, so recreate it:

   ```sh
   cd api
   docker compose up -d --force-recreate api
   ```

   If the API image is older than the commit that added these events and the `mux-sync` job (4134da5), rebuild first. `beat` and the workers run that code too:

   ```sh
   docker compose build api worker worker-photos beat
   docker compose up -d --force-recreate api worker worker-photos beat
   ```
5. **Check the signature path** with a sample event:

   ```sh
   mux webhooks trigger video.asset.ready --forward-to http://localhost:8000/v1/webhooks/mux
   ```

   `[200]` means the secret matches. The sample's ids match no video, so nothing changes. `[401]` means `MUX_WEBHOOK_SECRET` is not the printed secret, or the API was not recreated.

Each forwarded event shows in the `listen` terminal with the API's answer, for example `video.asset.ready  <id>  [200]`. `mux webhooks events list` shows the ones stored locally, and `mux webhooks events replay <event-id>` sends one again.

## Production

Production does **not** use the CLI or its secret. In the **production** Mux environment, create a webhook to the deployed https URL, for example `https://api.rawwers.com/v1/webhooks/mux` (dashboard *Settings → Webhooks*, or `mux webhooks create --address <url>` signed in to that environment). Set `MUX_WEBHOOK_SECRET` in production to the signing secret **that** webhook shows. Staging gets its own webhook and secret in the same way. See DEPLOY_CHECKLIST, Mux.
