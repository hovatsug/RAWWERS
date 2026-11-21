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

## The fake Mux (development only, 2026-11-21)

To click through the "Meet the photographer" video in the simulators without reaching Mux (dev's `.env` holds real Mux keys; with `MUX_FAKE=true` the fake is used instead of them):

1. In `api/.env` set `MUX_FAKE=true` and `PRESENTATION_VIDEO_ENABLED=true`. `APP_ENV` must be `development` (it is on dev): in any other environment `MUX_FAKE` is ignored.
2. Recreate the API, workers and beat so they read `.env` (`scratch/rebuild_dev.sh <sha>` does it, or `docker compose up -d --force-recreate api worker worker-photos beat` in `api/`).
3. **How you know it is on:** `curl http://localhost:8000/v1/dev/fake-mux/status` answers `{"fake_mux":"on"}`; with it off, 404. The Pro app's "Your introduction video" screen offers Choose and Record instead of "Video is not available right now".

What the fake does (`api/app/services/mux_fake.py`): a direct upload gets an address on the dev API (`PUT /v1/dev/fake-mux/uploads/{id}`) instead of Mux's; when the file arrives it reads the video's duration from the file, then sends the same events Mux sends (`video.upload.asset_created` at once, `video.asset.ready` about 6 seconds later, or `video.asset.errored` for a file that is not a video) through the same outbox and handler as real webhooks. Playback and the poster are a small bundled sample clip and image (`api/app/dev_assets/`), whatever was uploaded, behind a five-minute token. Deletions are recorded; `fake_fail_next_delete(True)` makes the next one fail, to see the retry.

## What the code assumes about Mux (checked against Mux's documentation on 2026-11-21)

| Assumption | In the code | Mux's documentation | Result |
|---|---|---|---|
| Webhook signature header `mux-signature`, `t=<unix time>,v1=<hex>` | `security.verify_mux_webhook_signature` | Same | matches |
| Signed text is `<t>.<raw body>`, HMAC-SHA256 with the webhook's secret; 5-minute tolerance | same | Same; Mux's SDKs default to 5 minutes | matches |
| Event envelope `id`, `type`, `data` | `webhooks.mux_webhook` | Also `object`, `created_at`, `environment`, `attempts` | matches (extra fields unused) |
| Repeats and any order: dedupe by event id; never move a settled video back | outbox key `mux:<event id>`; `_MUX_SETTLED` | Duplicates possible; no order promised; retries for 24 hours | matches |
| `video.upload.asset_created`: `data.id` the upload id, `data.asset_id` | `_apply_mux_event` | `asset_id` documented; the upload id's place not stated in what could be read | **unconfirmed**: also matched by `passthrough` now, and by `upload_id` on the asset events |
| `video.asset.ready`: `data.id` asset, `data.playback_ids[].id`/`.policy`, `data.duration` seconds, `data.upload_id`, `data.passthrough` | same | Same | matches |
| `video.asset.errored`: `data.errors` `{type, messages}` | stored as the error | Same | matches |
| `video.asset.deleted` exists | handled since 2026-11-21 | Exists | **was missing**, added |
| A timed-out upload sends no event | `mux_sync` maps upload status `timed_out` | No timeout event found; the upload's status is `timed_out` | matches |
| Direct upload: `POST /video/v1/uploads`, `new_asset_settings`, `cors_origin`, `timeout` (default 3600); answer `data.id`, `data.url`, `data.timeout`, `data.status` | `MuxClient.create_direct_upload` | Same; `cors_origin` marked required | **was missing `cors_origin`**, now `"*"` |
| `playback_policies` | was the singular `playback_policy` with `["public", "signed"]`, keeping the **first** id | Singular deprecated; several policies give several ids in no stated order; a public id plays without a token | **mismatch, fixed**: `playback_policies: ["signed"]`, and the signed id is picked by its policy |
| The file is sent with an HTTP `PUT` of its bytes | the Pro app | Same (whole-file PUT, content type optional) | matches |
| No size or duration cap on a direct upload | server checks the declared size and duration, then Mux's measured duration on ready | None documented | matches (our own limits) |
| Signed playback: RS256, `sub` playback id, `aud` `v` (video) / `t` (thumbnail), `exp`, `kid` | `security.create_mux_playback_token` | Same; examples put `kid` in the claims or the header | **`kid` now in both**; thumbnail token (`aud: t`, options in the claims) **was missing**, added |
| The signing key's private key | used as given | Delivered **base64-encoded** (a PEM inside) | **mismatch, fixed**: decoded when not a PEM |
| URLs `https://stream.mux.com/{id}.m3u8?token=…`, `https://image.mux.com/{id}/thumbnail.jpg?token=…` | `MuxClient.playback_url`, `poster_url` | Same | matches |
| Playback resolution cap: `max_resolution=720p` (owner, 2026-11-21) | in the signed video token's claims (`max_resolution`), never beside `token` in the URL; `MUX_PLAYBACK_MAX_RESOLUTION`, default 720p | "Control playback resolution": `max_resolution` takes 270p-2160p; with signed playback ids, modifiers "must be encoded in the token"; a signed URL "should only contain the token parameter" | matches the rule; the claim name `max_resolution` is **inferred** (the guide shows other modifiers as claims, not this one): checked in post-deploy step 5 |
| Delete: `DELETE /video/v1/assets/{id}`, 204 | `MuxClient.delete_asset` (404 taken as gone) | 204; a deleted asset's answer is not documented | **unconfirmed** (404 assumed) |
| Cheapest setting: `video_quality: basic`, `max_resolution_tier: 1080p` | `NEW_ASSET_SETTINGS` | Basic: no encoding charge, one-month minimum storage; 1080p is the default cap | matches |

Untested against the real service (only a real round trip can show them): the upload URL accepting the app's PUT, the real webhook delivery and signature with the production secret, playback with the real signing key (HLS on iOS and Android), the thumbnail token, the delete answer for an already-deleted asset, and the upload-id field of `video.upload.asset_created`. All are steps of DEPLOY_CHECKLIST section 4b.
