# Lightroom plug-in: publishing to the portfolio

Owner's decision, 2026-11-14: in the closed beta, as an approved addition to the freeze (BETA_SCOPE #61). A photographer puts photos in their portfolio from Lightroom Classic and chooses where they go. This file holds the assessment and what version 1 builds.

## 1. The portfolio today (pro app and API)

- **What it is.** There is one portfolio per photographer. It holds `media_asset` rows with `purpose = portfolio_reel`, kind `photo` or `video`, and visibility `public`. There are no albums. The only grouping is **niches**: each photo carries `niche_tags` (slugs), which feed niche skills, the Discover index and the public profile's niche sections.
- **Upload (app).** The app picks several photos, runs 3 uploads at a time, and makes these calls:
  - `POST /v1/media/photos/uploads`: purpose `portfolio_reel`, JPEG, PNG or WebP.
  - A presigned PUT, or multipart for large files.
  - `POST /v1/media/photos/{id}/complete`.
  - Then `POST /v1/pro/me/portfolio/{id}/niches` to tag the photo, which recomputes niche skills and the index.
- **Limits.**
  - **25 MB** per photo (`MAX_UPLOAD_BYTES`), checked at start, at complete and by the worker on the stored object.
  - **30 uploads an hour** per photographer (`uploads`) plus **30 starts a minute** (`auth_mutation`).
  - No maximum number of photos. A minimum of **12 ready photos** to finish onboarding.
- **Processing.** The worker (`process_photo_variants`):
  - checks the stored size and the declared SHA-256;
  - makes a thumbnail (512 px), a web-resolution copy and a watermarked preview.
  
  These copies are re-encoded with Pillow without EXIF. The original stays private, and only the copies are served (`resolve_image_urls` returns thumbnails first). The public lists count `ready` photos only.
- **Missing today.**
  - **Moderation:** there is no review of portfolio photos (BETA_SCOPE #11).
  - **Captions:** no field and no display, in the API or either app.
  - **Ordering:** newest first, fixed.
  - **Cover:** a profile field, not set from the grid.
  - **Deletion:** neither the photographer nor the admin can remove a portfolio photo (BETA_SCOPE Part 1e, #11).

## 2. The plug-in today (1.0.0, delivery only)

- **What it does.** "Export To: RAWWERS" delivers a paid gig's photos to its draft proof gallery: JPEG and sRGB only, the rendered file deleted afterwards.
- **Authentication.**
  - The pro app issues a pairing code: 8 characters, valid 10 minutes, usable once.
  - Pairing exchanges it for an `rwd_` **delivery token**: random, stored only as a hash, one photographer, at most 3 active devices.
  - The token stops after 90 idle days, on a password reset, on sign-out everywhere, a ban or a revoke.
  - Lightroom keeps it in the system keychain (`LrPasswords`), one entry per server. Presets never contain it.
- **Scope.** Only the `/v1/delivery/*` routes read the token. Every other route reads a signed access token. `test_delivery_scope.py` calls every route outside `/v1/delivery` with the token and fails if any gets further than with no credentials.
- **Upload flow.** Each photo goes through these steps:
  1. Hashed (SHA-256).
  2. `POST /delivery/gigs/{gig}/uploads` (name, size, hash, position). The same hash answers "duplicate", so exporting again resumes.
  3. One presigned PUT, or multipart above 16 MB (parts already held are skipped).
  4. `/complete` with the same hash.

  How it behaves:
  - 3 photos at a time, with Lightroom's progress bar.
  - Retries after 2, 5, 15 and 30 s on network errors and 5xx.
  - 401: connect again. 426: update the plug-in.
  - Limits: 50 MB per photo, 2,000 an hour per photographer and 5,000 a day per device.
  - Versions: every answer says whether a newer plug-in exists. `LIGHTROOM_PLUGIN_MIN_VERSION` refuses older ones with a 426.

## 3. Version 1: "RAWWERS Portfolio", a Lightroom Publish Service

A Publish Service fits: Lightroom keeps track of what was published, re-publishes edited photos and removes photos taken out of a collection.

- **The portfolio choice is a niche.** The portfolio has no albums, only niches.
  - The service's published collections are one per niche, chosen in the collection's settings from the photographer's own niches (`GET /v1/delivery/portfolio`).
  - The default collection is the primary niche.
  - Every photo published to a collection is tagged with that niche, as the app's tagging does.
- **Publish.** Same rendering and upload as delivery: JPEG, sRGB, location removed by default, with the hash and the same resume. The size limit is the portfolio's: **25 MB**, checked in the plug-in before sending and on the server.
- **Update.** An edited photo is re-published by uploading the new version, then removing the old one, so the portfolio never shows both or neither.
- **Remove.** Taking a photo out of a collection and publishing removes it from the portfolio. The token can remove only photos the plug-in published, never ones added in the app.
- **Left out of version 1:**
  - **captions**: the portfolio has no caption anywhere, so adding one means a new field of user content, its display in both apps and its moderation (about half a day more; owner's call);
  - order within the portfolio (newest first, as in the app);
  - choosing the cover;
  - videos;
  - one photo in several niches (publish it to each collection: one copy per niche);
  - comments and ratings from Lightroom;
  - removing photos that were added in the app.

## 4. API changes

These are new delivery-token routes, so they are inside the token's scope by construction. They call the same functions as the app's routes.

- `GET /v1/delivery/portfolio`: the photographer's niches (slug, name, primary), the number of ready photos and the minimum. The plug-in also uses it as its version check.
- `POST /v1/delivery/portfolio/uploads` `{file_name, content_type, byte_size, sha256, niche_slug}`:
  - runs the app's upload start (purpose `portfolio_reel`, visibility public, the same content types and the same **30 starts a minute**), but against the plug-in's own hourly bucket, **100 an hour** per photographer (`plugin_portfolio_uploads`, owner 2026-11-15), which does not touch the app's 30; plus the device's daily bucket. The URL refresh and multipart start of a Lightroom portfolio photo count against the same 100;
  - marks the photo as published from Lightroom;
  - the same hash already published to this niche is answered as a duplicate (resume).
- The URL, multipart and complete routes (`/v1/delivery/uploads/{id}/...`) accept the plug-in's own portfolio uploads as well as deliveries.
- On complete, the niche is tagged through the app's tagging function (niche skills and index recomputed).
- `DELETE /v1/delivery/portfolio/{id}`: only a photo this photographer published from Lightroom. It marks the photo deleted, clears it as cover, recomputes skills and the index, and deletes its stored files (best effort; a file storage does not delete is left to the unfinished-uploads sweep). `GET /v1/pro/me/portfolio` no longer lists deleted photos.
- **Minimum version:** the portfolio routes need plug-in **1.1.0** or newer (426 otherwise). Delivery keeps its own minimum (1.0.0). `LIGHTROOM_PLUGIN_LATEST_VERSION` defaults to **1.2.0** (section 7), so 1.0.0 and 1.1.0 users are told about the update.

## 5. Risks

- **Stolen or copyrighted images.** The risk is the same as for the app's upload: no check of who owns a photo, and no moderation. The plug-in makes bulk upload easier; its 100-an-hour limit and the device's daily cap bound it. Mitigation: BETA_SCOPE #11 (report, admin hides a photo) covers both; until then an admin can ban the photographer.
- **EXIF and location.** Served copies carry no EXIF, as in the app. The plug-in also ticks Remove Location Info by default. The private original keeps what Lightroom wrote.
- **Large files.** 25 MB is refused in the plug-in before sending and again on the server. Multipart is used above 16 MB.
- **Wrong portfolio.** Each collection names its niche in Lightroom, and the summary says which niche received the photos. A wrong niche is fixed by moving the photo between collections, which removes and re-publishes it.
- **Abuse with a stolen token.**
  - The token reaches delivery and the photographer's own portfolio, nothing else.
  - It can remove only Lightroom-published photos.
  - It has a per-device daily cap.
  - The photographer can revoke it in the app.
- **Rate limit.** At 100 an hour a 100-photo publish fits in one hour; past it, the plug-in stops with the server's message, and publishing again later carries on.

## The owner's decisions (2026-11-15)

- **Hourly limit:** 100 an hour for the plug-in's portfolio publish only (`RATE_LIMIT_PLUGIN_PORTFOLIO_UPLOADS_PER_HOUR`, default 100). The app's 30 an hour and the device's daily limit stay as they are. Built 2026-11-15.
- **Captions, photo order and the cover choice: LATER (v2)**, recorded as LATER items in BETA_SCOPE.md.
- **Deploy order:** host plug-in 1.1.0 before deploying the API, or set `LIGHTROOM_PLUGIN_LATEST_VERSION=1.0.0` until then (DEPLOY_CHECKLIST.md). With 1.2.0 the same holds for 1.2.0.
- **Niches from the plug-in** (section 7): the photographer chooses and adds niches in Lightroom; adding only; at most 3 niches (asked and answered 2026-11-15).

## 7. Niches from the plug-in (1.2.0)

Owner's decision, 2026-11-15, found while testing 1.1.0: a photographer must be able to choose their niche, and set niches up if they have none, without leaving Lightroom. The publish service said "Your niches: none yet" and sent them to the pro app.

### The niche rules (what exists, 2026-11-15)

- **Where niches are written.** Only `PUT /v1/pro/me/niches` (alias `PUT /v1/pro/niches/mine`) writes a photographer's niches, as a whole list. **The pro app has no screen that calls it**: its onboarding step "niches" only checks the count (`POST /v1/pro/onboarding/select-niches`). Until 1.2.0, the seed and the API were the only ways to get a niche.
- **Allowed niches:** active niches only (`niche.is_active`); an unknown or inactive slug is refused (422).
- **Minimum:** `niches_min` (onboarding requirement, default 1) gates the onboarding step, not the write.
- **Maximum:** none existed. Owner's decision 2026-11-15: **at most 3**, an onboarding requirement `niches_max` (default 3) next to `niches_min`. There is no admin screen for either; change it in the `onboarding_requirement` table. A photographer already above it keeps their niches and can shrink the list, but not grow it.
- **Main niche:** one `is_primary` row. The app's list write sets it only when asked; nothing set it by itself. The default Lightroom collection publishes to it.
- **No approval or prerequisite** to add a niche. Tiers come afterwards: adding a niche writes its skill row (`recompute_pro_niche_skills`, starting at rookie) and recomputes the public index (Discover, search). Price caps apply per niche and tier when packages are made, not when a niche is added. The gear floor reads the photographer's niches (the lighting rule), so a niche added can change what gear they need.
- **Declared level** (beginner/intermediate/...) is optional and left empty from the plug-in.

### What 1.2.0 adds

- **One rule for both callers:** `app/services/pro_niches.py`. The app's list write now applies the maximum through it; the plug-in's add goes through it entirely.
- `GET /v1/delivery/portfolio/niches`: every active niche with `mine` and `primary`, the photographer's `count` and the `maximum`.
- `POST /v1/delivery/portfolio/niches` `{slug}`: adds one niche to the token's own photographer.
  - The first niche (any niche when none is main) becomes the **main niche**.
  - Refusals, in the server's words: unknown or inactive niche (422 `unknown_niche`), already theirs (409 `niche_already_yours`), the maximum (422 `niche_limit_reached`: "You can have at most 3 niches, and you have 3. To change one, remove a niche in the RAWWERS Pro app first.").
  - The app's side effects: skill row and public index recomputed.
  - An audit row (`admin_audit_log`, target `pro_niche`, action `niche_added`, source `lightroom`, the device id).
  - Rate limit `delivery_niche_add`: 20 an hour per device.
- **Refused to the plug-in, on purpose:** removing a niche, changing the main niche, setting a declared level or a niche description, and anything for another photographer. There are no such routes; the body names only a slug.
- **Version:** both routes need plug-in **1.2.0** (426 for 1.1.0 and older, which keep publishing).
- **In Lightroom:**
  - The publish service's settings list the niches ("Connected. Your niches: Portraits (main), Weddings.") with an **Add a niche...** menu of the niches not yet theirs; with none: "Connected. You have no niches yet. Choose one to add." Choosing one adds it and says "Added Food, your main niche." At the maximum the menu goes and the line says so.
  - A collection's **Niche** menu lists their niches and ends with **Add a niche...**, which opens a small dialog with the niches not yet theirs; the one added is chosen for the collection.
- **Gap left:** the pro app still cannot add or remove niches, or change the main one (no screen). A photographer at 3 who wants a different niche has no way to swap until it has one.


### 1.2.1: the connection and Save

1.2.0 could not save the publish service: the settings said "Connected" but Save stayed blocked ("Can't Save Changes: Connect to RAWWERS first"). The Save check was an observer whose expression, `connected and nil or reason`, always gave the reason (in Lua, `x and nil or y` is always `y`). It was there since 1.1.0. Since 1.2.1 one state (`Portfolio.Connection` in `RawwersPortfolio.lua`) sets the line, the pairing row, a **Check again** button and Save together, and "Connected" (the only state that allows Save) is reached only after the server answered with this Mac's stored pairing:

- no pairing stored: "Not connected. Type the pairing code...", Save blocked;
- pairing refused by the server (401: revoked or expired): the token is forgotten, "Not connected. Type a new pairing code...", Save blocked;
- server unreachable or failing: the pairing is kept, "Could not check the connection..." with **Check again**, Save blocked;
- plug-in refused as too old (426): Save blocked;
- after **Connect**, the new pairing is checked the same way before "Connected".

1.2.2 is the same fix with no new file: 1.2.1 put it in a new `RawwersConnection.lua`, and a Lightroom that was already open could not load it ("Could not load toolkit script: RawwersConnection") until restarted. A test now fails when a file is added to the plug-in, so a new file comes with a note to restart Lightroom.

No API change: `LIGHTROOM_PLUGIN_LATEST_VERSION` stays 1.2.0, and the niche routes accept 1.2.2.

## 6. Effort and what the owner provides

- **Estimate: 1.5 agent-days.**
  - API and tests: 0.5.
  - Plug-in Publish Service and its plain-Lua tests: 0.6.
  - Break checks, docs and checklist: 0.4.
- Under the 2-day rule, so version 1 is built.
- **The owner provides:**
  - the manual run in Lightroom Classic (the SDK cannot run here; steps in `docs/LIGHTROOM_CHECKLIST.md`, part P);
  - the 1.1.0 build hosted at `LIGHTROOM_PLUGIN_DOWNLOAD_URL`;
  - the decision on the rate limit and on captions.
