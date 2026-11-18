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
  - **Deletion:** neither the photographer nor the admin can remove a portfolio photo (BETA_SCOPE Part 1e, #11). *Since 2026-11-17 the photographer can, in the Pro app (#70, section 9).*

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
- ~~**Gap left:** the pro app still cannot add or remove niches, or change the main one (no screen).~~ **Closed 2026-11-17:** the Pro app's niches screen (Settings > Your niches; BETA_SCOPE #71), section 9.


### 1.2.1: the connection and Save

1.2.0 could not save the publish service: the settings said "Connected" but Save stayed blocked ("Can't Save Changes: Connect to RAWWERS first"). The Save check was an observer whose expression, `connected and nil or reason`, always gave the reason (in Lua, `x and nil or y` is always `y`). It was there since 1.1.0. Since 1.2.1 one state (`Portfolio.Connection` in `RawwersPortfolio.lua`) sets the line, the pairing row, a **Check again** button and Save together, and "Connected" (the only state that allows Save) is reached only after the server answered with this Mac's stored pairing:

- no pairing stored: "Not connected. Type the pairing code...", Save blocked;
- pairing refused by the server (401: revoked or expired): the token is forgotten, "Not connected. Type a new pairing code...", Save blocked;
- server unreachable or failing: the pairing is kept, "Could not check the connection..." with **Check again**, Save blocked;
- plug-in refused as too old (426): Save blocked;
- after **Connect**, the new pairing is checked the same way before "Connected".

1.2.2 is the same fix with no new file: 1.2.1 put it in a new `RawwersConnection.lua`, and a Lightroom that was already open could not load it ("Could not load toolkit script: RawwersConnection") until restarted. A test now fails when a file is added to the plug-in, so a new file comes with a note to restart Lightroom.

No API change: `LIGHTROOM_PLUGIN_LATEST_VERSION` stays 1.2.0, and the niche routes accept 1.2.2.

## 8. Publishing again is safe (1.2.3, 1.2.4)

**What happened (dev, 2026-11-16).** Four photos published at once. Finishing two of them (`POST /v1/delivery/uploads/{id}/complete`) committed the photo as `processing`, then recomputed the niche skills and **deadlocked** with the other finish running at the same time (two requests updating the same `pro_niche_skill` rows in different orders): HTTP 500. The photo was already on the server and was processed to `ready`, but without its niche tag ("Untagged" in the pro app). The plug-in retried the finish and got 409 "Photo upload cannot be completed from current state", so Lightroom left the photo as new. Publishing again rendered the photo again; Lightroom writes the export time into every render (EXIF and XMP dates), so the file's SHA-256 differed, the server's only guard (same file hash in the same niche) did not match, and a second photo was made.

**Since 1.2.3:**

- **One photo per Lightroom photo and niche.** The plug-in sends a key per Lightroom photo and collection (`publish_key`, `lr:<photo uuid>:<collection id>`) and the hash of the picture without its metadata (`image_sha256`: the JPEG without its APPn and comment segments). The server answers the same Lightroom photo whose upload never finished with that upload (a crash or a timeout between steps: resumed and finished, with the new render's hash), and the same picture or the same file in that niche with the photo it has ("already there"; the plug-in marks it published). The same Lightroom photo with another picture is an edit: a new photo, and the server names the old one (`replaces`) so the plug-in removes it once the new one is finished. The same photo in **another niche** is another photo, as before.
- **Finishing is one step and can be repeated.** Processing and the niche tag (with the skills and Discover recompute) are one transaction, behind a per-photographer lock, and the niche recompute goes in a fixed order: no deadlock, and never a photo processing without its niche. Finishing a photo that is already processing or ready answers the same success (deliveries too). A photo left processing without its niche (the old bug) is tagged when it is started or finished again.
- **Plain words.** A removed or failed photo: "This photo was removed from your portfolio. Publish it again to send it anew." / "RAWWERS could not process this photo. Publish it again to send it anew." A server error: "RAWWERS had a problem on its side (HTTP 500). Try again in a minute." A photo whose last step failed: "it reached RAWWERS but could not be finished (...). Publish again: it will be finished there, not sent twice." The app's message for the same refusal no longer says "current state".
- **The dialog's numbers are the server's:** "N photos are in your RAWWERS portfolio (Family): X new, Y already there." and "Family now has T photos on RAWWERS." (`GET /v1/delivery/portfolio` now gives `niche_photo_counts`: processing or ready, per niche).
- **Plug-ins before 1.2.3** still get the file-hash guard only (a re-render is a second photo), but the finish no longer fails: `LIGHTROOM_PLUGIN_LATEST_VERSION` is 1.2.3, so they are told to update.
- **Known limit (beta, owner 2026-11-16):** the same photo in two collections with the same niche is one portfolio photo (the second collection gets "already there"). Removing it from one collection removes it from the portfolio, although the other collection still lists it. Keeping it until no collection uses it is BETA_SCOPE #65, LATER.

### 1.2.4: deliveries, and what the removal of an old version can reach

- **Deliveries ("Export To: RAWWERS") follow the same rules** since 1.2.4: the plug-in sends a key per Lightroom photo and **gig** (`delivery_key`, `lr:<photo uuid>:gig:<gig id>`) and the picture hash. In that gig's gallery the same Lightroom photo still waiting is resumed (and the parts of the old render already in storage are dropped), and the same picture or file is "already there". The same photo in another gig is another photo. Finishing again, and joining the parts again once joined, answer the same success. The dialog: "N photos are in the client's gallery: X new, Y already there." and "The gallery now has T photos (P still processing)." (from `GET /v1/delivery/galleries/{id}/status`). An edited photo exported again is **added**: a delivery is never replaced or removed automatically.
- **The old version of an edited portfolio photo is removed by the server, never by the plug-in.** Lightroom's re-publish sends the old photo's id (`previous_id`) with the start; the new version is uploaded; when it is finished, in the same transaction, the server removes the old one only if it is, all at once: the same photographer's; published from Lightroom (not added in the app, not a delivery); processing or ready; in the **same niche**; the **same Lightroom photo** (the same publish key; or, for a photo published before keys existed, the very photo Lightroom names); and **used by nothing else** - not the profile cover, and no row anywhere points at it (a gig gallery, a client's selection, a share link, a banner, a dispute, a consent record...). Otherwise it is kept and the dialog says why ("The old version was kept in your portfolio: it is your profile cover."). The checks run again at the finish, so a photo that became the cover meanwhile is kept.
- **What the token can still remove by hand:** `DELETE /v1/delivery/portfolio/{id}` (a photo taken out of a collection) reaches only this photographer's photos published from Lightroom, in any niche; since 1.2.4 it refuses one that anything else uses ("This photo was kept in your portfolio: ..."), except the cover, which the removal clears as before.

## 9. Niches and photos removed in the Pro app (1.2.5, 2026-11-17)

The Pro app can now remove a niche (BETA_SCOPE #71) and a portfolio photo (#70). What the plug-in does about each:

- **A collection whose niche was removed.** Publishing sends nothing: "This collection publishes to a niche that is no longer one of yours ("food"). Niches are removed in the RAWWERS Pro app. Nothing was sent. Edit the collection (right-click > Edit Collection) and choose another niche." Also the default collection, if it had chosen that niche: its photos never go to the main niche instead without being asked. The server refuses a start into a niche the photographer does not have anyway (`require_own_niche`, "niches are removed in the RAWWERS Pro app"). Photos already published from that collection stay in the portfolio, with their tag; taking them out of the collection removes them as before.
- **What removing a niche keeps** (`services/pro_niches.py`): the photos tagged with it (tag included; the client profile still shows them, grouped under that niche, since it groups by the photos' tags), its packages (still bookable), its skill row (evidence: gigs, reviews, certificates). The photographer leaves that niche's Discover row unless they earned a member tier in it (`client_launch._in_niche`: the main niche, or a tier earned there). Search still uses the top three skill rows (BACKEND_GAPS). The lighting rule follows the niches chosen, so removing one can only lift a requirement. Refused: a niche with a booking that is not finished (any status but completed, cancelled or refunded; a dispute is not finished) or a booking request still waiting; below the minimum; the main niche without choosing another.
- **A photo removed in the app** (`DELETE /v1/pro/me/portfolio/{id}`, the plug-in's removal path, `meta.removed = "app"`). The server lists such photos to the plug-in (`removed_in_app` in `GET /v1/delivery/portfolio`) and refuses a re-publish that names one as the photo it replaces (409 `photo_removed_in_app`, whatever the plug-in's version). The plug-in 1.2.5:
  - never sends it again on its own: an edited photo, or one marked to re-publish, is skipped (`rendition:skipRender`) and failed with the reason (`rendition:uploadFailed`), so Lightroom keeps it to re-publish and lists it as not published; the dialog says "N photos not sent again: removed from your portfolio in the RAWWERS Pro app (names). To publish one again, take it out of this collection, publish, then add it back.";
  - says it: the dialog of any publish of that collection counts its other photos removed in the app ("shown as published here, but not on RAWWERS"), and Lightroom's **Comments** panel shows the same sentence on each such photo (`getCommentsFromPublishedCollection`);
  - lets the photographer choose to publish it again: taken out of the collection (the removal answers success, it is gone already) and added back, it is a new photo.
  - **Why this and not something else:** the Publish Service API has no "removed elsewhere" state. Lightroom could take the photo out of the collection itself (a catalog write during a publish), but that changes the photographer's catalog without asking. Marking it "to re-publish" would put it in the queue every time and could be read as an invitation to send it. A failed re-publish with the reason, a dialog line and a comment are all read-only for the catalog, say what happened where the photographer looks, and leave the choice to them.
- **Removing below the minimum** applies to the plug-in too: a live photographer at the portfolio minimum who takes a photo out of a collection gets "RAWWERS could not remove 1 photo(s): Add another photo first, then remove this one..." and Lightroom keeps it in **Deleted Photos to Remove**.
- **Texts now true:** "Adds it to your RAWWERS profile. Remove niches in the RAWWERS Pro app: Settings > Your niches." (service settings), "You can remove it there (Settings > Your niches), not here." (the add dialog), the server's "To change one, remove a niche in the RAWWERS Pro app first (Settings > Your niches)."
- **Tests:** `lightroom/tests/test_export.lua` (removed niche, skip and reason, the collection's others, publish anew, comments) and `test_logic.lua`; the API in `tests/test_portfolio_photo_removal.py` and `tests/test_pro_niches_screen.py`. Manual: `LIGHTROOM_CHECKLIST.md` part Q.

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
